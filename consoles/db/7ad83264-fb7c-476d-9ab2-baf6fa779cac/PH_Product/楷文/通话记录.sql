
select
    a1.staff 交接员工
    ,td.pno 运单号
    ,date (convert_tz(td.created_at, '+00:00', '+08:00')) as 日期
    ,td.store_id 网点id
    ,dp.store_name 网点
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,dp.area_name 区域
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as 订单平台
    ,ddd.CN_element 标记原因
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') as 电话时间

from
    (
        select
            *
        from
            (
                select
                    t.staff
                    ,t.ticket_list
                    ,replace(replace(replace(t.ticket_list, '[', ''), ']', ''), ',"ticket_type":2', '') ticket_list1
                from tmpale.tmp_ph_phone_lj_0603 t
            ) a
        lateral view explode(split(a.ticket_list1, ',')) id as ticket_id
    ) a1
left join ph_staging.ticket_delivery td on td.id = json_extract(a1.ticket_id, '$.ticket_id')
left join ph_staging.ticket_delivery_marker tdm on tdm.delivery_id = td.id
left join dwm.dwd_dim_dict ddd on ddd.element = tdm.marker_id and ddd.db = 'ph_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
left join ph_staging.parcel_route pr on pr.pno = td.pno and pr.route_action = 'PHONE' and pr.routed_at > '2024-06-02 16:00:00' and pr.routed_at < '2024-06-03 16:00:00'
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = td.store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
left join ph_staging.ka_profile kp on kp.id = td.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = td.client_id
;



select
    oi.pno
    ,case tp.state
		when 0	then '待分配'
		when 1	then '待揽件'
		when 2	then '已揽件'
		when 3	then '已终止'
		when 4	then '已取消'
        else null
    end as 揽件任务状态
from ph_staging.order_info oi
left join ph_staging.ticket_pickup_order_relation tpor on oi.id = tpor.order_id
left join ph_staging.ticket_pickup tp on tp.id = tpor.ticket_pickup_id
where
    oi.pno in ('P11084PU1ENAC', 'P11084PU1ENAC、', 'P41204JT4XNAA')