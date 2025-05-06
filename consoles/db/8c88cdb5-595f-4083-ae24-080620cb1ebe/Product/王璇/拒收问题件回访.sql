select
    mpa.pno
    ,mpa.stat_date
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.id is null then '普通ka'
        when kp.`id` is null then '小c'
    end 客户类型
    ,if(ivr.link_id is not null, 'y', 'n') 是否有IVR回访结果继续派送
    ,if(hm.link_id is not null, 'y', 'n') 是否有人工回访结果继续派送
    ,if(prr.pno is not null, 'y', 'n') 是否有拒收复核上报
    ,convert_tz(di.updated_at, '+00:00', '+07:00') 协商完成时间
from
    (
        select
            mpa.stat_date
            ,mpa.pno
        from bi_center.msdashboard_pri_abnormal_data_save mpa
        left join fle_staging.parcel_priority_delivery_detail pri on mpa.pno = pri.pno
        where
            mpa.stat_date >= '2024-12-05'
            and mpa.stat_date <= '2024-12-15'
            and pri.basis_type = 27
    ) mpa
left join fle_staging.diff_info di on di.pno = mpa.pno
join fle_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id and cdt.negotiation_result_category in (5,6,9)
left join
    (
        select
            vrv.link_id
            ,vrv.id
        from nl_production.violation_return_visit vrv
        where
            vrv.created_at > '2024-11-15'
            and vrv.type = 3
            and vrv.visit_staff_id in (10000, 10001)
            and json_extract(vrv.extra_value, '$.rejection_delivery_again') = 2 -- 拒收回访继续派送
    ) ivr on ivr.link_id = mpa.pno
left join
    (
        select
            vrv.link_id
            ,vrv.id
        from nl_production.violation_return_visit vrv
        where
            vrv.created_at > '2024-11-15'
            and vrv.type = 3
            and vrv.visit_staff_id not in (10000, 10001)
            and json_extract(vrv.extra_value, '$.rejection_delivery_again') = 2 -- 拒收回访继续派送
    ) hm on hm.link_id = mpa.pno
left join fle_staging.parcel_reject_report_info prr on prr.pno = mpa.pno and prr.state = 2
left join fle_staging.parcel_info pi on pi.pno = mpa.pno
left join fle_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id
