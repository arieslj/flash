
select * from bi_pro.parcel_lose_task plt
where
    plt.source_id LIKE 'return_visit_1_%' and plt.created_at > '2023-11-01' and plt.source = 2;

# select
#     *
# from
#     (
#         select
#             a2.*
#             ,link_id
#         from
#             (
#                 select
#                     a1.*
#                     ,replace(replace(replace(json_extract(dpr.extra_value, '$.images'), '"', ''),'[', ''),']', '') valu
#                 from
#                     (
#                         select
#                             a.pno
#                             ,a.forceTakePhotoCategory
#                             ,a.ka_type
#                             ,a.pr_date
#                             ,a.routeExtraId
#                         from
#                             (
#                                 select
#                                     pr.pno
#                                     ,case
#                                         when bc.`client_id` is not null then bc.client_name
#                                         when kp.id is not null and bc.id is null then '普通ka'
#                                         when kp.`id` is null then '小c'
#                                     end as  ka_type
#                                     ,date(convert_tz(pr.routed_at, '+00:00', '+07:00')) pr_date
#                                     ,json_extract(pr.extra_value, '$.routeExtraId') routeExtraId
#                                     ,json_extract(pr.extra_value, '$.forceTakePhotoCategory') forceTakePhotoCategory
#                                     ,row_number() over (partition by pr.pno, date(convert_tz(pr.routed_at, '+00:00', '+07:00')) order by pr.routed_at ) rk
#                                 from rot_pro.parcel_route pr
#                                 left join fle_staging.parcel_info pi on pi.pno = pr.pno
#                                 left join fle_staging.ka_profile kp on pi.client_id = kp.id
#                                 left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id
#                                 # left join dwm.drds_parcel_route_extra dpr on dpr.id = json_extract(pr.extra_value, '$.routeExtraId')
#                                 where
#                                     pr.route_action in ('TAKE_PHOTO')
#                                     and pr.routed_at > '2023-04-30 17:00:00'
#                                     and pr.routed_at < '2023-05-07 17:00:00'
#                             ) a
#                         where
#                             a.rk = 1
#                     )a1
#                 left join dwm.drds_parcel_route_extra dpr on dpr.route_extra_id = a1.routeExtraId
#             ) a2
#         lateral view explode(split(a.valu, ',')) id as link_id
#     ) a3
# left join fle_staging.sys_attachment sa on sa.id = a3.link_id



select
    a1.pno
    ,a1.staff_info_id 员工
    ,a1.pr_date 日期
    ,a1.ka_type 客户类型
    ,case a1.forceTakePhotoCategory
        when 1 then '打印面单'
        when 2 then '收件人拒收'
        when 3 then '滞留强制拍照'
    end 拍照类型
    ,if(dt.双重预警 = 'Alert', '是', '否') 当日是否爆仓
from
    (
        select
            a.pno
            ,a.forceTakePhotoCategory
            ,a.ka_type
            ,a.pr_date
            ,a.store_id
            ,a.staff_info_id
            ,a.routeExtraId
        from
            (
                select
                    pr.pno
                    ,pr.store_id
                    ,case
                        when bc.`client_id` is not null then bc.client_name
                        when kp.id is not null and bc.id is null then '普通ka'
                        when kp.`id` is null then '小c'
                    end as  ka_type
                    ,date(convert_tz(pr.routed_at, '+00:00', '+07:00')) pr_date
                    ,json_extract(pr.extra_value, '$.routeExtraId') routeExtraId
                    ,pr.staff_info_id
                    ,json_extract(pr.extra_value, '$.forceTakePhotoCategory') forceTakePhotoCategory
                    ,row_number() over (partition by pr.pno, date(convert_tz(pr.routed_at, '+00:00', '+07:00')) order by pr.routed_at ) rk
                from rot_pro.parcel_route pr
                left join fle_staging.parcel_info pi on pi.pno = pr.pno
                left join fle_staging.ka_profile kp on pi.client_id = kp.id
                left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id
                # left join dwm.drds_parcel_route_extra dpr on dpr.id = json_extract(pr.extra_value, '$.routeExtraId')
                where
                    pr.route_action in ('TAKE_PHOTO')
                    and pr.routed_at > '2023-04-30 17:00:00'
                    and pr.routed_at < '2023-05-07 17:00:00'
            ) a
        where
            a.rk = 1
    ) a1
left join dwm.dwd_th_network_spill_detl_rd dt on dt.网点ID = a1.store_id and dt.统计日期 = a1.pr_date

;


with t as
(
    select
        plt.pno
        ,plt.updated_at
        ,plt.state
        ,plt.created_at
        ,plt.penalties
        ,case
            when bc.`client_id` is not null then bc.client_name
            when kp.id is not null and bc.id is null then '普通ka'
            when kp.`id` is null then '小c'
        end as  ka_type
#         ,plt.id
    from bi_pro.parcel_lose_task plt
    left join fle_staging.ka_profile kp on plt.client_id = kp.id
    left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = plt.client_id
    # left join bi_pro.parcel_cs_operation_log pcol on pcol.task_id = plt.id and pcol.type = 1
    where
        plt.created_at >= '2023-05-01'
        and plt.created_at < '2023-05-08'
        and plt.source = 12
)
select
    t1.pno
    ,t1.state
    ,case
        when t1.state = 6 and t1.penalties > 0 then 'L来源判责丢失'
        when t1.state = 6 and plt2.id is not null  then '其他来源判责丢失'
        when plt3.id is null and t1.state = 5 then 'L来源被判无须追责'
        when t1.state = 5 then '无须追责'
        else null
    end 分类
    ,t1.created_at 任务生成时间
    ,t1.ka_type 客户类型
    ,t1.updated_at 处理时间
from t t1
left join bi_pro.parcel_lose_task plt2 on plt2.pno = t1.pno and plt2.source not in (12) and plt2.state = 6 and plt2.penalties > 0
left join bi_pro.parcel_lose_task plt3 on plt3.pno = t1.pno and plt3.source not in (12) and plt3.state = 5 and plt3.updated_at = t1.updated_at
;

with  t as
(
select
    plt.pno
    ,plt.id
    ,plt.updated_at
    ,plt.state
    ,plt.penalties
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as  ka_type
from bi_pro.parcel_lose_task plt
left join fle_staging.ka_profile kp on plt.client_id = kp.id
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = plt.client_id
where
    plt.updated_at >= '2023-05-01'
    and plt.updated_at < '2023-06-01'
    and plt.duty_result = 1
    and plt.state = 6
#     and plt.source = 12
)
select
    b.ka_type 客户分类
    ,count(b.id) 5月判责丢失量
    ,count(if(b.24hour = 'y', b.id, null)) 丢失后24H内找回量
    ,count(if(b.24hour = 'n', b.id, null)) 判责丢失后24H后找回量
from
    (
        select
            t2.*
            ,case
                when timestampdiff(second, t2.updated_at, pr.min_prat)/3600 <= 24 then 'y'
                when timestampdiff(second, t2.updated_at, pr.min_prat)/3600 > 24 then 'n'
                else null
            end 24hour
        from t t2
        left join
            (
                select
                    pr.pno
                    ,min(convert_tz(pr.routed_at, '+00:00', '+07:00')) min_prat
                from rot_pro.parcel_route pr
                join t t1 on t1.pno = pr.pno
                join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'rot_pro' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action' and ddd.remark = 'valid'
                where
                    pr.routed_at > date_sub(t1.updated_at, interval 7 hour)
                group by 1
            ) pr on pr.pno = t2.pno
    ) b
group by 1



;



with t as
(
    select
        pr.pno
        ,pr.routed_at
        ,pr.id
        ,case json_extract(pr.extra_value, '$.forceTakePhotoCategory')
            when 1 then '打印面单'
            when 2 then '收件人拒收'
            when 3 then '滞留包裹强制拍照'
        end photo_type
    from rot_pro.parcel_route pr
    where
        pr.route_action = 'TAKE_PHOTO'
        and pr.routed_at > '2023-10-17 17:00:00'
        -- and pr.routed_at < '2023-06-30 17:00:00'
)
select
    ddd.CN_element
    ,a.photo_type
    ,count(a.id) action_count
from
    (
        select
            t1.pno
            ,t1.id
            ,t1.photo_type
            ,pr2.remark
            ,row_number() over (partition by pr2.pno order by pr2.routed_at desc) rk
        from rot_pro.parcel_route pr2
        join t t1 on pr2.pno = t1.pno
        where
            pr2.routed_at < t1.routed_at
            and pr2.route_action = 'FORCE_TAKE_PHOTO'
            and pr2.routed_at > '2023-10-17 17:00:00'
            -- and pr2.routed_at < '2023-06-30 17:00:00'
#             and pr2.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
    ) a
left join dwm.dwd_dim_dict ddd on ddd.element = a.remark and ddd.db = 'rot_pro' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
where
    a.rk = 1
#     and ddd.CN_element = '到件入仓扫描'
group by 1,2

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
;
with t as
(
select
    plt.pno
    ,plt.id
    ,plt.created_at
    ,plt.updated_at
    ,plt.state
    ,plt.operator_id
    ,plt.client_id
    ,plt.last_valid_store_id
    ,if(plt.state = 6 and plt.duty_result = 1, plt.updated_at, null) updated_time
from bi_pro.parcel_lose_task plt
where
    plt.created_at >= '2023-06-14 17:00:00'
    and plt.created_at < '2023-06-30 17:00:00'
    and plt.source = 12
)
, po as
(
    select
        pr.pno
        ,dpr.route_extra_id
        ,pr.store_id
        ,pr.staff_info_id
        ,replace(replace(replace(json_extract(dpr.extra_value, '$.images'), '"', ''),'[', ''),']', '') image
    from rot_pro.parcel_route pr
    left join dwm.drds_parcel_route_extra dpr on dpr.route_extra_id = json_extract(pr.extra_value, '$.routeExtraId')
    join
        (
            select
                t1.pno
            from t t1
            group by 1
        ) pl on pl.pno = pr.pno
    where
        pr.routed_at > '2023-06-01'
        and pr.route_action = 'TAKE_PHOTO'
)
select
    a.pno
    ,case a.force_take_photos_type
        when 1 then '打印面单'
        when 2 then '收件人拒收'
        when 3 then '滞留强制拍照'
    end 拍照类型
    ,case
        when  a.state = 1 then '丢失件待处理'
        when  a.state = 2 then '疑似丢失件待处理'
        when  a.state = 3 then '待工单回复'
        when  a.state = 4 then '已工单回复'
        when  a.state = 5 and a.operator_id in (10000,10001,10002) then '自动判责—包裹未丢失'
        when  a.state = 5 and a.operator_id not in (10000,10001,10002) then '人工-包裹未丢失'
        when  a.state = 6 then '丢失件处理完成'
    end 判责结果
    ,po1.staff_info_id 拍照快递员
    ,dt.store_name 拍照网点
    ,dt.piece_name 拍照网点片区
    ,dt.region_name 拍照网点大区
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.id is null then '普通ka'
        when kp.`id` is null then '小c'
    end 客户类型
    ,b.24hour 判责丢失24小时判断
    ,pi.cod_amount/100 cod金额
    ,case pi.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
    ,case pi2.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 退件包裹包裹状态
    ,if(dt.双重预警 = 'Alert', '是', '否') 当日是否爆仓
    ,plt3.pl_source 进L来源同时是否有替他来源任务
    ,if(a.state in (5,6) ,timestampdiff(hour, a.created_at, a.updated_at), null) 进入L来源时间到已处理时间段_hour
from
    (
        select
            sf.*
        from
            (
                select
                    t1.*
                    ,sfp.force_take_photos_type
                    ,sfp.id record_id
                    ,row_number() over (partition by sfp.pno order by sfp.created_at desc) rk
                from fle_staging.stranded_force_photo_ai_record sfp
                join t t1 on t1.pno = sfp.pno
                where
                    sfp.created_at < date_sub(t1.created_at, interval 7 hour)
                    and (sfp.parcel_enabled = 0 or sfp.matching_enabled = 0)
                    and sfp.force_take_photos_type is not null
            ) sf
        where
            sf.rk = 1
    ) a
left join fle_staging.ka_profile kp on kp.id = a.client_id
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = a.client_id
left join fle_staging.parcel_info pi on pi.pno = a.pno
left join
    (
        select
            t2.*
            ,case
                when timestampdiff(second, t2.updated_time, pr.min_prat)/3600 <= 24 then '1'
                when timestampdiff(second, t2.updated_time, pr.min_prat)/3600 > 24 then '2'
                else 0
            end 24hour
        from t t2
        left join
            (
                select
                    pr.pno
                    ,min(convert_tz(pr.routed_at, '+00:00', '+07:00')) min_prat
                from rot_pro.parcel_route pr
                join t t1 on t1.pno = pr.pno
                join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'rot_pro' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action' and ddd.remark = 'valid'
                where
                    pr.routed_at > date_sub(t1.updated_time, interval 7 hour)
                group by 1
            ) pr on pr.pno = t2.pno
    ) b on b.pno = a.pno
left join dwm.dwd_th_network_spill_detl_rd dt on dt.统计日期 = date(a.created_at) and dt.网点ID = a.last_valid_store_id
left join
    (
        select
            t1.pno
            ,group_concat(pl.plt_source) pl_source
        from
            (
                select
                    plt3.pno
                    ,plt3.source
                    ,case plt3.source
                        WHEN 1 THEN 'A'
                        WHEN 2 THEN 'B'
                        WHEN 3 THEN 'C'
                        WHEN 4 THEN 'D'
                        WHEN 5 THEN 'E'
                        WHEN 6 THEN 'F'
                        WHEN 7 THEN 'G'
                        WHEN 8 THEN 'H'
                        WHEN 9 THEN 'I'
                        WHEN 10 THEN 'J'
                        when 11 then 'K'
                        when 12 then 'L'
                    end plt_source
                    ,plt3.created_at created_time
                    ,if(plt3.state in (5,6), plt3.updated_at, now()) updated_time
                from bi_pro.parcel_lose_task plt3
                where
                    plt3.created_at >= '2023-06-14 17:00:00'
                    and plt3.created_at < '2023-06-30 17:00:00'
                    and plt3.source != 12 -- 非L来源
            ) pl
        join t t1 on t1.pno = pl.pno
        where
            pl.updated_time > t1.created_at
            and pl.created_time < t1.updated_time
        group by 1
    ) plt3 on plt3.pno = a.pno
left join fle_staging.stranded_force_photo_info sfp on sfp.ai_record_id = a.record_id
left join fle_staging.sys_attachment sa on sa.object_key = sfp.url
left join po po1 on po1.image = sa.id
left join dwm.dim_th_sys_store_rd dt on dt.store_id = po1.store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
left join fle_staging.parcel_info pi2 on pi2.pno = pi.returned_pno
;
