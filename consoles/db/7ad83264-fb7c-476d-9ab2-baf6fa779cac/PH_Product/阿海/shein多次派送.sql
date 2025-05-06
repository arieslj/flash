select
    a.pr_date 日期
    ,a.client_id 客户ID
    ,a.pno 单号
    ,case a.marker_category
        when 40 then '联系不上客户'
        when 78 then '收件人电话号码是空号'
        when 75 then '收件人电话号码错误'
    end 标记原因
    ,if(a.state = 5, '是', '否') 最终是否正向妥投成功
from
    (
        select
            date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
            ,pr.marker_category
            ,pi.client_id
            ,pr.pno
            ,pi.state
            ,json_extract(pr.extra_value, '$.deliveryAttemptNum') delivery_attempt_num
        from ph_staging.parcel_route pr
        join ph_staging.parcel_info pi on pi.pno = pr.pno
        where
            pr.route_action in ('DIFFICULTY_HANDOVER', 'DETAIN_WAREHOUSE')
            and pr.routed_at > '2023-09-01'
            and pi.returned = 0
            and pi.client_id in ('AA0148','AA0149')
    ) a
where
    a.delivery_attempt_num >= 3
    and a.pr_date >= '2023-12-01'
    and a.pr_date <= '2023-12-31'
    and a.marker_category in (40,78,75)


;


with t as
    (
        select
            date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
            ,pr.marker_category
            ,pi.client_id
            ,pr.pno
            ,pi.state
            ,pr.route_action
            ,ddd.EN_element
            ,json_unquote(json_extract(pr.extra_value, '$.deliveryAttemptNum')) delivery_attempt_num
            ,case json_unquote(json_extract(pr.extra_value, '$.deliveryAttempt'))
                when 'true' then 1
                when 'false' then 0
            end delivery_attempt
        from ph_staging.parcel_route pr
        join ph_staging.parcel_info pi on pi.pno = pr.pno
        left join dwm.dwd_dim_dict ddd on ddd.element = pr.marker_category and ddd.db = 'ph_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
        where
            pr.route_action in ('DIFFICULTY_HANDOVER', 'DETAIN_WAREHOUSE', 'DELIVERY_MARKER')
            and pr.routed_at > '2023-09-01'
            and pi.returned = 0
            and pi.client_id in ('AA0148','AA0149')
#             and json_extract(pr.extra_value, '$.deliveryAttemptNum')
    )
select
    date(convert_tz(dai.last_delivery_attempt_at, '+00:00', '+08:00')) 最后一次派送日期
    ,a1.client_id 客户ID
    ,a1.pno 运单号
    ,dai.delivery_attempt_num 尝试派送次数
    ,if(a1.state = 5, '是', '否') 是否派送成功
    ,group_concat(distinct a2.EN_element) 标记原因
from
    (
        select
            t1.*
        from t t1
        where
            t1.marker_category in (40,78,75)
            and t1.delivery_attempt_num = 3
            and t1.pr_date >= '2023-12-01'
            and t1.pr_date <= '2023-12-31'
            and t1.delivery_attempt = 1
    ) a1
left join ph_staging.delivery_attempt_info dai on dai.pno = a1.pno
left join t a2 on a2.pno = a1.pno and a2.route_action = 'DELIVERY_MARKER'
group by 1,2,3,4,5

;

with t as
    (
        select
            date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
            ,pr.marker_category
#             ,pi.client_id
            ,pr.pno
#             ,pr.route_action
            ,ddd.CN_element
#             ,json_unquote(json_extract(pr.extra_value, '$.deliveryAttemptNum')) delivery_attempt_num
#             ,case json_unquote(json_extract(pr.extra_value, '$.deliveryAttempt'))
#                 when 'true' then 1
#                 when 'false' then 0
#             end delivery_attempt
        from ph_staging.parcel_route pr
        join ph_staging.parcel_info pi on pi.pno = pr.pno
        left join dwm.dwd_dim_dict ddd on ddd.element = pr.marker_category and ddd.db = 'ph_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
        where
            pr.route_action in ('DELIVERY_MARKER')
            and pr.routed_at > '2023-09-01'
            and pi.returned = 0
            and pi.client_id in ('AA0148','AA0149')
#             and json_extract(pr.extra_value, '$.deliveryAttemptNum')
    )
select
    date(convert_tz(dai.last_delivery_attempt_at, '+00:00', '+08:00')) 最后一次派送日期
    ,dai.client_id 客户ID
    ,dai.pno 运单号
    ,dai.delivery_attempt_num 尝试派送次数
    ,if(pi.state = 5, '是', '否') 是否派送成功
    ,group_concat(distinct t1.CN_element) 派件标记
from ph_staging.delivery_attempt_info dai
left join t t1 on t1.pno = dai.pno
left join ph_staging.parcel_info pi on pi.pno = dai.pno
where
    dai.delivery_attempt_num >= 3
    and dai.last_marker_id in (40,29,25)
    and dai.last_delivery_attempt_at >= '2023-11-30 16:00:00'
    and dai.last_delivery_attempt_at < '2023-12-31 16:00:00'
    and dai.client_id in ('AA0148','AA0149')
group by 1,2,3,4,5