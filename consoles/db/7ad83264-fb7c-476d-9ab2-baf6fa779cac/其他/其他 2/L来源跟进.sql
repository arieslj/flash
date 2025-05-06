
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
from ph_bi.parcel_lose_task plt
where
    plt.created_at >= '2023-06-14 16:00:00'
    and plt.created_at < '2023-06-30 16:00:00'
    and plt.source = 12
)
, po as
(
   select
       a.*
   from
       (
            select
                pr.pno
                ,dpr.route_extra_id
                ,pr.store_id
                ,pr.staff_info_id
                ,replace(replace(replace(json_extract(dpr.extra_value, '$.images'), '"', ''),'[', ''),']', '') image
            from ph_staging.parcel_route pr
            left join dwm.drds_ph_parcel_route_extra dpr on dpr.route_extra_id = json_extract(pr.extra_value, '$.routeExtraId')
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
       ) a
    lateral view explode(split(a.image, ',')) a as link_id
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
        when kp.id is not null and bc.client_id is null then '普通ka'
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
    ,if(dt.爆仓预警 = 'Alert', '是', '否') 当日是否爆仓
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
                from ph_staging.stranded_force_photo_ai_record sfp
                join t t1 on t1.pno = sfp.pno
                where
                    sfp.created_at < date_sub(t1.created_at, interval 7 hour)
                    and (sfp.parcel_enabled = 0 or sfp.matching_enabled = 0)
                    and sfp.force_take_photos_type is not null
            ) sf
        where
            sf.rk = 1
    ) a
left join ph_staging.ka_profile kp on kp.id = a.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = a.client_id
left join ph_staging.parcel_info pi on pi.pno = a.pno
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
                from ph_staging.parcel_route pr
                join t t1 on t1.pno = pr.pno
                join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'rot_pro' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action' and ddd.remark = 'valid'
                where
                    pr.routed_at > date_sub(t1.updated_time, interval 8 hour)
                group by 1
            ) pr on pr.pno = t2.pno
    ) b on b.pno = a.pno
left join dwm.dwd_ph_network_spill_detl_rd dt on dt.统计日期 = date(a.created_at) and dt.网点ID = a.last_valid_store_id
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
                from ph_bi.parcel_lose_task plt3
                where
                    plt3.created_at >= '2023-06-14 16:00:00'
                    and plt3.created_at < '2023-06-30 16:00:00'
                    and plt3.source != 12 -- 非L来源
            ) pl
        join t t1 on t1.pno = pl.pno
        where
            pl.updated_time > t1.created_at
            and pl.created_time < t1.updated_time
        group by 1
    ) plt3 on plt3.pno = a.pno
left join ph_staging.stranded_force_photo_info sfp on sfp.ai_record_id = a.record_id
left join ph_staging.sys_attachment sa on sa.object_key = sfp.url
left join po po1 on po1.link_id = sa.id
left join dwm.dim_ph_sys_store_rd dt on dt.store_id = po1.store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
left join ph_staging.parcel_info pi2 on pi2.pno = pi.returned_pno
;
