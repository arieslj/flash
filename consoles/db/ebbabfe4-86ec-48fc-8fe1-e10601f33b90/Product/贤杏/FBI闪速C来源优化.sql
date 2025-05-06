-- 1.非平台包裹被操作有效路由后，包裹修改至运输中
select
    pi.pno
from my_staging.parcel_info pi
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id
left join my_bi.parcel_lose_task plt on plt.pno = pi.pno
join my_bi.parcel_cs_operation_log pcol on pcol.task_id = plt.id and pcol.action = 4
where
    pi.state = 2
    and plt.duty_result = 1
    and bc.client_id is null
    and pcol.created_at < date_sub(pi.state_change_at, interval 8 hour )
group by 1

;
-- 2.包裹因为有理赔任务被客服修改包裹状态

select
    *
from my_staging.parcel_info pi

;

select
    pi.pno
from my_staging.parcel_info pi
left join my_staging.parcel_info pi2 on pi2.pno = pi.returned_pno
where
    pi2.state = 9
    and pi.state = 2
