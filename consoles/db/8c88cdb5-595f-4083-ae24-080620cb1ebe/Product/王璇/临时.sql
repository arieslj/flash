-- 问题件协商结果为3/4/9、且协商结果当日为pri（取bi_center.msdashboard_pri_abnormal_data_save）的包裹明细


select
    di.pno
    ,mpa.stat_date
from fle_staging.customer_diff_ticket cdt
left join fle_staging.diff_info di on di.id = cdt.diff_info_id
join bi_center.msdashboard_pri_abnormal_data_save mpa on mpa.pno = di.pno
join bi_pro.abnormal_message am on am.merge_column = di.pno and am.punish_category = 72 and am.abnormal_time = mpa.stat_date
where
    cdt.negotiation_result_category in (3,4,9)
    and cdt.updated_at > '2024-05-31 17:00:00'
    and cdt.updated_at > date_sub(mpa.stat_date, interval 7 hour)
    and cdt.updated_at < date_add(mpa.stat_date, interval 17 hour)





;


select
    *
from fle_staging.









select
    *
from rot_pro.parcel_route pr
where
    pr.route_action = 'RECEIVED'
    and extra_value like '%routeExtraId%'
    and routed_at > '2024-06-25'