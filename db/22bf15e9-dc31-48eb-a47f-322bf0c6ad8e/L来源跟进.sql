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
    ,pcol.created_at
    ,plt.penalties
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as  ka_type
    ,pcol.action
#         ,plt.id
from bi_pro.parcel_lose_task plt
left join fle_staging.ka_profile kp on plt.client_id = kp.id
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = plt.client_id
left join bi_pro.parcel_cs_operation_log pcol on pcol.task_id = plt.id and pcol.type = 1
where
    plt.created_at >= '2023-05-01'
    and plt.created_at < '2023-05-08'
    and plt.source = 12
)
select
    a1.pno 包裹
    ,a1.id 闪速任务ID
    ,timestampdiff(second, a1.created_at, a2.created_at)/3600 认定后无需追责时间_H
from
    (
        select
            t1.pno
            ,t1.id
            ,t1.created_at
            ,t1.action
        from t t1
        where
            t1.action = 4
    ) a1
join
    (
        select
            t1.pno
            ,t1.id
            ,t1.created_at
            ,t1.action
        from t t1
        where
            t1.action = 3
    ) a2 on a2.id = a1.id
where
    a2.created_at > a1.created_at