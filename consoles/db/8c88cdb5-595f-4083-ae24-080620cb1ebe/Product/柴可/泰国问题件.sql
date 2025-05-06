select
    a1.p_date 日期
    ,a1.client_type 客户类型
    ,a1.CN_element 问题件类型
    ,a1.diff_cnt 单量
    ,a1.diff_cnt/a2.diff_cnt 单量占比
from
    (
        select
            case
                when bc.`client_id` is not null then bc.client_name
                when kp.id is not null and bc.client_id is null then '普通ka'
                when kp.`id` is null then '小c'
            end client_type
            ,ddd.CN_element
            ,date (convert_tz(ppd.created_at, '+00:00', '+07:00')) p_date
            ,count(ppd.id) diff_cnt
        from fle_staging.parcel_problem_detail  ppd
        left join fle_staging.parcel_info pi on pi.pno = ppd.pno
        left join fle_staging.ka_profile kp on kp.id = pi.client_id
        left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id
        left join dwm.dwd_dim_dict ddd on ddd.element = ppd.diff_marker_category and ddd.db = 'fle_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
        where
            ppd.created_at > '2024-03-31 17:00:00'
        group by 1,2,3
    ) a1
left join
    (
        select
            case
                when bc.`client_id` is not null then bc.client_name
                when kp.id is not null and bc.client_id is null then '普通ka'
                when kp.`id` is null then '小c'
            end client_type
            ,date (convert_tz(ppd.created_at, '+00:00', '+07:00')) p_date
            ,count(ppd.id) diff_cnt
        from fle_staging.parcel_problem_detail  ppd
        left join fle_staging.parcel_info pi on pi.pno = ppd.pno
        left join fle_staging.ka_profile kp on kp.id = pi.client_id
        left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id
      --  left join dwm.dwd_dim_dict ddd on ddd.element = ppd.diff_marker_category and ddd.db = 'fle_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
        where
            ppd.created_at > '2024-03-31 17:00:00'
        group by 1,2
    ) a2 on a2.client_type = a1.client_type and a2.p_date = a1.p_date

;

select
    case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end 客户类型
    ,date (convert_tz(di.created_at, '+00:00', '+07:00')) 日期
    ,count(di.id) 单量
from fle_staging.diff_info di
left join fle_staging.parcel_info pi on pi.pno = di.pno
left join fle_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id
left join nl_production.violation_return_visit vrv on json_extract(vrv.extra_value, '$.diff_id') = di.id or json_extract(vrv.extra_value, '$.diff_id') = di.id
where
    di.created_at > '2024-03-31 17:00:00'
    and di.diff_marker_category in (17)
group by 1,2

;


select
    case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end 客户类型
    ,case vrv.type
        when 1 then '揽件任务异常取消'
        when 2 then '虚假妥投'
        when 3 then '收件人拒收'
        when 4 then '标记客户改约时间'
        when 5 then 'KA现场不揽收'
        when 6 then '包裹未准备好'
        when 7 then '上报错分未妥投'
        when 8 then '多次尝试派送失败'
    end 回访类型
    ,date (vrv.created_at) 日期
    ,count(vrv.id) 单量
from nl_production.violation_return_visit vrv
left join fle_staging.ka_profile kp on kp.id = vrv.client_id
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = vrv.client_id
where
    vrv.created_at > '2024-04-01 00:00:00'
    and vrv.type in (3,4)
    and ( vrv.visit_result in (8,18,19,20,21,31,32,22,23,24) or vrv.complaint = 2)
group by 1,2,3
