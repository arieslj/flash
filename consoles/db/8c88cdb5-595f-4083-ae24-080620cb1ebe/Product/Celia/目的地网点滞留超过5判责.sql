with t as
    (
        select
            a.*
        from
            (
                select
                    plt.pno
                    ,if(pi.dst_store_id = 'TH05110303', pcd.old_value, pi.dst_store_id) dst_store
                    ,plt.last_valid_store_id
                    ,plt.updated_at
                    ,plt.created_at
                    ,plt.parcel_created_at
                    ,plt.last_valid_action
                    ,plt.source
                    ,plt.id
                from bi_pro.parcel_lose_task plt
                left join fle_staging.parcel_info pi on pi.pno = plt.pno and pi.created_at > '2023-10-20'
                left join fle_staging.parcel_change_detail pcd on pcd.pno = plt.pno and pcd.field_name = 'dst_store_id' and pcd.new_value = pi.dst_store_id
                where
                    plt.state = 6
                    and plt.duty_result = 1
                    and plt.source in (1,12)
                    and plt.parcel_created_at >= '2023-11-01'
                    and plt.penalties > 0
                group by 1,2,3,4,5,6,7,8
            ) a
        where
            a.last_valid_store_id = a.dst_store
    )
, f as
    (
        select
            a2.*
            ,datediff(a2.created_at, a2.first_valid_routed_at) stay_length
        from
            (
                select
                    a.*
                from
                    (
                        select
                            t1.*
                            ,pssn.first_valid_routed_at
                            ,date(pssn.first_valid_routed_at) valid_date
                            ,row_number() over (partition by t1.pno order by pssn.first_valid_routed_at desc) rn
                        from t t1
                        left join dw_dmd.parcel_store_stage_new pssn on t1.dst_store = pssn.store_id and t1.pno = pssn.pno
                    ) a
                where
                    a.rn = 1
            ) a2
        where
            datediff(a2.created_at, a2.first_valid_routed_at) >= 5
    )
select
    f1.pno
    ,case f1.source
        WHEN 1 THEN 'A-问题件-丢失'
        WHEN 2 THEN 'B-记录本-丢失'
        WHEN 3 THEN 'C-包裹状态未更新'
        WHEN 4 THEN 'D-问题件-破损/短少'
        WHEN 5 THEN 'E-记录本-索赔-丢失'
        WHEN 6 THEN 'F-记录本-索赔-破损/短少'
        WHEN 7 THEN 'G-记录本-索赔-其他'
        WHEN 8 THEN 'H-包裹状态未更新-IPC计数'
        WHEN 9 THEN 'I-问题件-外包装破损险'
        WHEN 10 THEN 'J-问题记录本-外包装破损险'
        when 11 then 'K-超时效包裹'
        when 12 then 'L-高度疑似丢失'
    end 问题来源渠道
    ,f1.parcel_created_at 包裹揽收时间
    ,f1.created_at 任务生成时间
    ,f1.updated_at 判责时间
    ,ddd.CN_element 最后有效路由
    ,f1.stay_length 滞留时长
    ,tra.tra_count 转单次数
    ,tra.tra_time 转单时间
    ,sc.mark 20点后标记
    ,sc.mark_count 20点后标记次数
    ,sc.mark_time 20点后标记时间
    ,pi.cod_amount/100 cod金额
    ,ch.change_count 收件人改约次数
    ,sc1.diff_hour 收件人改约时长
    ,if(am.pno is null, 'n', 'y') 是否有丢失申诉
    ,if(foc.pno is null, 'n', 'y' ) 是否有强制拍照
    ,du.duty_store 责任网点
    ,if(dt.双重预警 = 'Alert', '是', '否') 当日是否爆仓
from f f1
left join fle_staging.parcel_info pi on pi.pno = f1.pno and pi.created_at > '2023-10-20'
left join
    (
        select
            t1.pno
            ,count(distinct pr.id) tra_count
            ,group_concat(convert_tz(pr.routed_at, '+00:00', '+07:00')) tra_time
        from rot_pro.parcel_route pr
        join  t t1 on t1.pno = pr.pno
        where
            pr.routed_at > '2023-10-30'
            and pr.route_action = 'DELIVERY_TRANSFER'
        group by 1
        having count(distinct pr.id) > 2
    ) tra on tra.pno = f1.pno
left join
    (
        select
            t1.pno
            ,count(pr.id) mark_count
            ,group_concat(ddd.CN_element) mark
            ,group_concat(convert_tz(pr.routed_at, '+00:00', '+07:00')) mark_time
        from rot_pro.parcel_route pr
        join t t1 on t1.pno = pr.pno
        left join dwm.dwd_dim_dict ddd on ddd.element = pr.marker_category and ddd.db = 'fle_staging' and ddd.tablename = 'diff_info' and ddd.fieldname ='diff_marker_category'
        where
            pr.routed_at > '2023-10-30'
            and pr.route_action = 'DELIVERY_MARKER'
            and hour(convert_tz(pr.routed_at, '+00:00', '+07:00')) >= 20
        having count(pr.id) > 3
    ) sc on sc.pno = f1.pno
left join
    (
        select
            t1.pno
            ,count(pr.id) change_count
        from rot_pro.parcel_route pr
        join t t1 on t1.pno = pr.pno
        left join dwm.dwd_dim_dict ddd on ddd.element = pr.marker_category and ddd.db = 'fle_staging' and ddd.tablename = 'diff_info' and ddd.fieldname ='diff_marker_category'
        where
            pr.routed_at > '2023-10-30'
            and pr.route_action = 'DELIVERY_MARKER'
            and pr.marker_category in (9,14,70)
        group by 1
    ) ch on ch.pno = f1.pno
left join
    (
        select
            t1.pno
            ,timestampdiff(hour, convert_tz(pr.routed_at, '+00:00', '+07:00'), now()) diff_hour
            ,row_number() over (partition by t1.pno order by pr.routed_at) rk
        from rot_pro.parcel_route pr
        join t t1 on t1.pno = pr.pno
        left join dwm.dwd_dim_dict ddd on ddd.element = pr.marker_category and ddd.db = 'fle_staging' and ddd.tablename = 'diff_info' and ddd.fieldname ='diff_marker_category'
        where
            pr.routed_at > '2023-10-30'
            and pr.route_action = 'DELIVERY_MARKER'
            and pr.marker_category in (9,14,70)
    ) sc1 on sc1.pno = f1.pno and sc1.rk = 1
left join
    (
        select
            t1.pno
        from rot_pro.parcel_route pr
        join t t1 on t1.pno = pr.pno
        left join dwm.dwd_dim_dict ddd on ddd.element = pr.marker_category and ddd.db = 'fle_staging' and ddd.tablename = 'diff_info' and ddd.fieldname ='diff_marker_category'
        where
            pr.routed_at > '2023-10-30'
            and pr.route_action = 'FORCE_TAKE_PHOTO'
        group by 1
    ) foc on foc.pno = f1.pno
left join
    (
        select
            t1.pno
            ,group_concat(distinct ss.name) duty_store
        from bi_pro.parcel_lose_responsible plr
        join t t1 on t1.id = plr.lose_task_id
        left join fle_staging.sys_store ss on ss.id = plr.store_id
        where
            plr.created_at > '2023-10-20'
        group by 1
    ) du on du.pno = f1.pno
left join
    (
        select
            t1.pno
        from bi_pro.abnormal_message am
        join t t1 on t1.id = json_extract(am.extra_info, '$.losr_task_id')
        where
            am.created_at > '2023-10-20'
            and am.isappeal > 1
            and am.isdel = 0
        group by 1
    ) am on am.pno = f1.pno
left join dwm.dwd_th_network_spill_detl_rd dt on dt.网点ID = f1.dst_store and dt.统计日期 = f1.valid_date
left join dwm.dwd_dim_dict ddd on ddd.element = f1.last_valid_action and ddd.db = 'rot_pro' and ddd.tablename = 'parcel_route' and ddd.fieldname ='route_action'