-- 网点附近妥投

select
    a1.client_id '客户Client ID'
    ,a1.client_type '平台Platform'
    ,'网点附近妥投' '妥投类型 Delivery type'
    ,if(a1.returned = 1, a1.customary_pno, a1.pno) '原始单号Tracking_Number'
    ,if(a1.returned = 1, a1.pno, null) '退件单号Return Tracking Number'
    ,convert_tz(a1.finished_at, '+00:00', '+08:00') '妥投时间Delivery Time'
    ,a1.ticket_delivery_staff_info_id '妥投快递员Courier ID'
    ,dp.store_name '网点Branach'
    ,dp.piece_name '片区District'
    ,dp.region_name '大区Area'
    ,a1.third_sorting_code '分拣码Sorting_code'
from
    (
        select
            pi.pno
            ,pi.customary_pno
            ,pi.finished_at
            ,pi.client_id
            ,pi.returned
            ,pi.dst_name
            ,pi.ticket_delivery_staff_info_id
            ,pi.ticket_delivery_store_id
            ,case
                when bc.`client_id` is not null then bc.client_name
                when kp.id is not null and bc.client_id is null then '普通ka'
                when kp.`id` is null then '小c'
            end as client_type
            ,ps.third_sorting_code
            ,row_number() over (partition by pi.pno order by ps.created_at desc) as rn
        from ph_staging.parcel_info pi
        left join ph_staging.sys_store ss on ss.id = pi.dst_store_id
        left join ph_staging.ka_profile kp on kp.id = pi.client_id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
        left join ph_drds.parcel_sorting_code_info ps on ps.pno = pi.pno
        where
            pi.state = 5
            and pi.cod_amount < 50000
            and pi.finished_at > date_sub(curdate(), interval 32 hour )
            and pi.finished_at < date_sub(curdate(), interval 8 hour )
            and ss.province_code in ('PH12', 'PH18', 'PH19', 'PH21')
            and st_distance_sphere(point(pi.ticket_pickup_staff_lng, pi.ticket_pickup_staff_lat), point(pi.ticket_delivery_staff_lng, pi.ticket_delivery_staff_lat)) < 100
    ) a1
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = a1.ticket_delivery_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
where
    a1.rn = 1

;


-- 5分钟妥投10件


with t as
    (
        select
            pi.pno
            ,pi.customary_pno
            ,pi.finished_at
            ,pi.client_id
            ,pi.returned
            ,pi.dst_name
            ,pi.ticket_delivery_staff_info_id
            ,pi.ticket_delivery_store_id
            ,case
                when bc.`client_id` is not null then bc.client_name
                when kp.id is not null and bc.client_id is null then '普通ka'
                when kp.`id` is null then '小c'
            end as client_type
            ,lead(pi.finished_at, 9) over (partition by pi.ticket_delivery_staff_info_id order by pi.finished_at) as ten_fin_at
        from ph_staging.parcel_info pi
        left join ph_staging.sys_store ss on ss.id = pi.dst_store_id
        left join ph_staging.ka_profile kp on kp.id = pi.client_id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
        where
            pi.state = 5
            and pi.finished_at > date_sub(curdate(), interval 32 hour )
            and pi.finished_at < date_sub(curdate(), interval 8 hour )
            and pi.returned = 0
            and pi.cod_amount < 500000
            and ss.province_code in ('PH12', 'PH18', 'PH19', 'PH21','PH61')
    )
, b as
    (
        select
                    t1.*
                from t t1
                join
                    (
                        select
                            t1.ticket_delivery_staff_info_id
                            ,t1.finished_at
                            ,t1.pno
                            ,t1.dst_name
                            ,t1.ten_fin_at
                        from t t1
                        where
                            timestampdiff(minute, t1.finished_at, t1.ten_fin_at) < 5
                    ) a on a.ticket_delivery_staff_info_id = t1.ticket_delivery_staff_info_id
                where
                    t1.finished_at >= a.finished_at
                    and t1.finished_at <= a.ten_fin_at
    )
select
    distinct
    a1.client_id '客户Client ID'
    ,a1.client_type '平台Platform'
    ,'5分钟妥投10件以上 Sign more than 10 waybills in 5 minutes' 妥投类型Delivery_type
    ,a1.pno '单号Tracking Number'
    ,convert_tz(a1.finished_at, '+00:00', '+08:00') '妥投时间Delivery Time'
    ,a1.ticket_delivery_staff_info_id '妥投快递员Courier ID'
    ,dp.store_name '网点Branach'
    ,dp.piece_name '片区District'
    ,dp.region_name '大区Area'
    ,a1.third_sorting_code '分拣码Sorting_code'
from
    (
        select
            a.*
            ,ps.third_sorting_code
            ,row_number() over (partition by a.pno order by ps.created_at desc ) as rn
        from b a
        join
            (
                select
                    b1.finished_at
                    ,b1.ticket_delivery_staff_info_id
                from b b1
                group by 1,2
                having count(distinct b1.dst_name) > 1
            ) a1 on a1.ticket_delivery_staff_info_id = a.ticket_delivery_staff_info_id and a1.finished_at = a.finished_at
        left join ph_drds.parcel_sorting_code_info ps on ps.pno = a.pno
    ) a1
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = a1.ticket_delivery_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
where
    a1.rn = 1
order by 7,6

;
-- 收件人拒收后妥投

with t as
    (
        select
            pi.pno
            ,pi.customary_pno
            ,pi.finished_at
            ,pi.client_id
            ,pi.returned
            ,pi.dst_name
            ,pi.ticket_delivery_staff_info_id
            ,pi.ticket_delivery_store_id
            ,case
                when bc.`client_id` is not null then bc.client_name
                when kp.id is not null and bc.client_id is null then '普通ka'
                when kp.`id` is null then '小c'
            end as client_type
        from ph_staging.parcel_info pi
        left join ph_staging.ka_profile kp on kp.id = pi.client_id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
        where
            pi.state = 5
            and pi.cod_amount < 50000
            and pi.cod_enabled = 1
            and pi.finished_at > date_sub(curdate(), interval 32 hour )
            and pi.finished_at < date_sub(curdate(), interval 8 hour )
    )
select
    a1.client_id '客户Client ID'
    ,a1.client_type '平台Platform'
    ,'收件人拒收后妥投' '妥投类型 Delivery type'
    ,if(a1.returned = 1, a1.customary_pno, a1.pno) '原始单号Tracking_Number'
    ,if(a1.returned = 1, a1.pno, null) '退件单号Return Tracking Number'
    ,convert_tz(a1.finished_at, '+00:00', '+08:00') '妥投时间Delivery Time'
    ,a1.ticket_delivery_staff_info_id '妥投快递员Courier ID'
    ,dp.store_name '网点Branach'
    ,dp.piece_name '片区District'
    ,dp.region_name '大区Area'
    ,a1.third_sorting_code '分拣码Sorting_code'
from
    (
        select
            t1.*
            ,ps.third_sorting_code
            ,row_number() over (partition by t1.pno order by ps.created_at desc) as rk
        from t t1
        join
            (
                select
                    pr.pno
                from ph_staging.parcel_route pr
                join t t1 on t1.pno = pr.pno
                where
                    pr.routed_at > date_sub(curdate(), interval 32 hour )
                    and pr.routed_at < date_sub(curdate(), interval 8 hour )
                    and pr.routed_at < t1.finished_at
                    and pr.route_action = 'DELIVERY_MARKER'
                    and pr.marker_category = 2
                group by 1
            ) a on t1.pno = a.pno
        left join ph_drds.parcel_sorting_code_info ps on ps.pno = t1.pno
    ) a1
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = a1.ticket_delivery_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
where
    a1.rk = 1
;

-- 21：00后妥投且无通话记录

with t as
    (
        select
            pi.pno
            ,pi.customary_pno
            ,pi.finished_at
            ,pi.client_id
            ,pi.returned
            ,pi.dst_name
            ,pi.ticket_delivery_staff_info_id
            ,pi.ticket_delivery_store_id
            ,case
                when bc.`client_id` is not null then bc.client_name
                when kp.id is not null and bc.client_id is null then '普通ka'
                when kp.`id` is null then '小c'
            end as client_type
        from ph_staging.parcel_info pi
        left join ph_staging.sys_store ss on ss.id  = pi.dst_store_id
        left join ph_staging.ka_profile kp on kp.id = pi.client_id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
        where
            pi.state = 5
            and pi.cod_amount < 50000
            and pi.finished_at > date_sub(curdate(), interval 32 hour )
            and pi.finished_at < date_sub(curdate(), interval 8 hour )
            and hour(convert_tz(pi.finished_at, '+00:00', '+08:00')) > 20
            and ss.province_code in ('PH12', 'PH18', 'PH19', 'PH21','PH61')
    )
select
    a1.client_id '客户Client ID'
    ,a1.client_type '平台Platform'
    ,'21点后妥投无通话记录No call records after 21' 妥投类型Delivery_type
    ,if(a1.returned = 1, a1.customary_pno, a1.pno) '原始单号Tracking_Number'
    ,if(a1.returned = 1, a1.pno, null) '退件单号Return Tracking Number'
    ,convert_tz(a1.finished_at, '+00:00', '+08:00') '妥投时间Delivery Time'
    ,a1.ticket_delivery_staff_info_id '妥投快递员Courier ID'
    ,dp.store_name '网点Branach'
    ,dp.piece_name '片区District'
    ,dp.region_name '大区Area'
    ,a1.third_sorting_code '分拣码Sorting_code'
from
    (
        select
            t1.*
            ,ps.third_sorting_code
            ,row_number() over (partition by t1.pno order by ps.created_at desc) as rk
        from t t1
        join
            (
                select
                    pr.pno
                    ,sum(ifnull(json_extract(pr.extra_value, '$.callDuration'), 0))  call_cnt
                from ph_staging.parcel_route pr
                join t t1 on t1.pno = pr.pno
                where
                    pr.routed_at > date_sub(curdate(), interval 32 hour )
                    and pr.routed_at < date_sub(curdate(), interval 8 hour )
                    and pr.route_action in ('PHONE', 'INCOMING_CALL' )
                    and pr.routed_at < t1.finished_at
                group by 1
            ) a on t1.pno = a.pno and a.call_cnt = 0
        left join ph_drds.parcel_sorting_code_info ps on ps.pno = t1.pno
    ) a1
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = a1.ticket_delivery_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
where
    a1.rk = 1


;



-- 妥投24小时后还有扫码记录


with t as
    (
        select
            pr.pno
            ,pr.routed_at
        from ph_staging.parcel_route pr
        where
            pr.route_action = 'DELIVERY_CONFIRM'
            and pr.routed_at > date_sub(curdate(), interval 10 day )
            and pr.routed_at < date_sub(curdate(), interval 8 hour )
    )
, r as
    (
        select
            pr.pno
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT', 'DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN''DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY', 'REFUND_CONFIRM','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
            and pr.routed_at > date_sub(curdate(), interval 32 hour )
            and pr.routed_at < date_sub(curdate(), interval 8 hour )
            and timestampdiff(second , t1.routed_at, pr.routed_at) > 0
    )
select
    a1.client_id '客户Client ID'
    ,a1.client_type '平台Platform'
    ,'妥投后仍有有效路由effective route after signing' as '妥投类型Delivery type'
    ,a1.pno 'Tracking Number'
    ,convert_tz(a1.finished_at, '+00:00', '+08:00') '妥投时间Delivery Time'
    ,a1.ticket_delivery_staff_info_id '妥投快递员Courier ID'
    ,dp.store_name '网点Branach'
    ,dp.piece_name '片区District'
    ,dp.region_name '大区Area'
    ,a1.third_sorting_code '分拣码Sorting_code'
    ,concat(pd.last_valid_action, ddd.CN_element)  '最后有效路由动作Last effective route'
    ,hjt.job_name '最后有效路由操作岗位Last operator post'
    ,pd.resp_store_updated '最后有效路由时间Last effective routing time'
from
    (
        select
            pi.pno
            ,pi.customary_pno
            ,pi.finished_at
            ,pi.client_id
            ,pi.returned
            ,pi.dst_name
            ,pi.ticket_delivery_staff_info_id
            ,pi.ticket_delivery_store_id
            ,case
                when bc.`client_id` is not null then bc.client_name
                when kp.id is not null and bc.client_id is null then '普通ka'
                when kp.`id` is null then '小c'
            end as client_type
            ,ps.third_sorting_code
            ,row_number() over (partition by r1.pno order by ps.created_at desc) as rk
        from ph_staging.parcel_info pi
        join r r1 on r1.pno = pi.pno
        left join ph_staging.ka_profile kp on kp.id = pi.client_id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
        left join ph_drds.parcel_sorting_code_info ps on ps.pno = pi.pno
        where
            pi.cod_amount < 50000
            and pi.created_at > date_sub(curdate(), interval 3 month)
    ) a1
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = a1.ticket_delivery_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
left join ph_bi.parcel_detail pd on pd.pno = a1.pno
left join dwm.dwd_dim_dict ddd on ddd.element = pd.last_valid_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pd.last_valid_staff_info_id
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
where
    a1.rk = 1



;





with t as
    (
        select
            pr.pno
            ,pr.routed_at
        from ph_staging.parcel_route pr
        where
            pr.route_action = 'DELIVERY_CONFIRM'
            and pr.routed_at > date_sub(curdate(), interval 10 day )
            and pr.routed_at < date_sub(curdate(), interval 8 hour )
    )
, r as
    (
        select
            pr.pno
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT', 'DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN''DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY', 'REFUND_CONFIRM','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
            and pr.routed_at > date_sub(curdate(), interval 32 hour )
            and pr.routed_at < date_sub(curdate(), interval 8 hour )
            and date (convert_tz(pr.routed_at, '+00:00', '+08:00')) > date (convert_tz(t1.routed_at, '+00:00', '+08:00'))
    )
select
    a1.client_id '客户Client ID'
    ,a1.client_type '平台Platform'
    ,'妥投后隔夜有有效路由Effective route the next day after signing' as '妥投类型Delivery type'
    ,a1.pno 'Tracking Number'
    ,convert_tz(a1.finished_at, '+00:00', '+08:00') '妥投时间Delivery Time'
    ,a1.ticket_delivery_staff_info_id '妥投快递员Courier ID'
    ,dp.store_name '网点Branach'
    ,dp.piece_name '片区District'
    ,dp.region_name '大区Area'
    ,a1.third_sorting_code '分拣码Sorting_code'
    ,concat(pd.last_valid_action, ddd.CN_element) '最后有效路由动作Last effective route'
    ,hjt.job_name '最后有效路由操作岗位Last operator post'
    ,pd.resp_store_updated '最后有效路由时间Last effective routing time'
from
    (
        select
            pi.pno
            ,pi.customary_pno
            ,pi.finished_at
            ,pi.client_id
            ,pi.returned
            ,pi.dst_name
            ,pi.ticket_delivery_staff_info_id
            ,pi.ticket_delivery_store_id
            ,case
                when bc.`client_id` is not null then bc.client_name
                when kp.id is not null and bc.client_id is null then '普通ka'
                when kp.`id` is null then '小c'
            end as client_type
            ,ps.third_sorting_code
            ,row_number() over (partition by r1.pno order by ps.created_at desc) as rk
        from ph_staging.parcel_info pi
        join r r1 on r1.pno = pi.pno
        left join ph_staging.ka_profile kp on kp.id = pi.client_id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
        left join ph_drds.parcel_sorting_code_info ps on ps.pno = pi.pno
        where
            pi.cod_amount < 50000
            and pi.created_at > date_sub(curdate(), interval 3 month)
    ) a1
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = a1.ticket_delivery_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
left join ph_bi.parcel_detail pd on pd.pno = a1.pno
left join dwm.dwd_dim_dict ddd on ddd.element = pd.last_valid_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pd.last_valid_staff_info_id
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
where
    a1.rk = 1


;



 --  最近7天妥投包裹在昨日有操作记录

with t as
    (
        select
            pr.pno
            ,pi.finished_at
            ,pi.client_id
            ,pi.returned
            ,pi.dst_name
            ,pi.ticket_delivery_staff_info_id
            ,pi.ticket_delivery_store_id
        from ph_staging.parcel_route pr
        join ph_staging.parcel_info pi on pi.pno = pr.pno
        where
            pr.route_action = 'DELIVERY_CONFIRM'
            and pr.routed_at > date_sub(date_sub(curdate(), interval 8 day ), interval 8 hour)
            and pr.routed_at < date_sub(date_sub(curdate(), interval 1 day ), interval 8 hour)
            and pi.returned = 0
        group by 1
    )
select
    a1.client_id
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end client_type
    ,'最近7天妥投的包裹在昨日有操作 Operated yesterday sign in last 7 days' as del_type
    ,a1.pno
    ,convert_tz(a1.finished_at, '+00:00', '+08:00') del_time
    ,a1.ticket_delivery_staff_info_id
    ,dp.store_name
    ,dp.piece_name
    ,dp.region_name
    ,a1.third_sorting_code
    ,concat(ddd.element, ddd.CN_element) pr_route
    ,hjt.job_name
    ,convert_tz(a1.routed_at, '+00:00', '+08:00') last_valid_time
    ,date_sub(curdate(), interval 1 day) p_date
from
    (
        select
            a.*
            ,ps.third_sorting_code
            ,row_number() over (partition by a.pno order by ps.created_at desc) rn
        from
            (
                select
                    t1.*
                    ,pr.route_action
                    ,pr.routed_at
                    ,pr.staff_info_id
                    ,pr.store_category
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
                from ph_staging.parcel_route pr
                join t t1 on t1.pno = pr.pno
                left join ph_bi.parcel_complaint_inquiry pci on pci.merge_column = t1.pno
                where
                    pr.routed_at > date_sub(date_sub(curdate(), interval 1 day ), interval 8 hour)
                    and pr.routed_at < date_sub(date_sub(curdate(), interval 0 day ), interval 8 hour)
                    and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT', 'DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN''DETAIN_WAREHOUSE','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY', 'REFUND_CONFIRM','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
                    and pci.merge_column is null
            ) a
        left join ph_drds.parcel_sorting_code_info ps on ps.pno = a.pno
        where
            a.rk = 1
            and a.store_category not in (8,12)
    ) a1
left join ph_staging.ka_profile kp on kp.id = a1.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = a1.client_id
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = a1.ticket_delivery_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
left join dwm.dwd_dim_dict ddd on ddd.element = a1.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = a1.staff_info_id
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
where
    a1.rn = 1

;


select
    a1.client_id '客户Client ID'
    ,a1.client_type '平台Platform'
    ,'最近7天妥投的包裹在昨日有操作 Operated yesterday sign in last 7 days' as '妥投类型Delivery type'
    ,a1.pno 'Tracking Number'
    ,a1.del_time '妥投时间Delivery Time'
    ,a1.ticket_delivery_staff_info_id  '妥投快递员Courier ID'
    ,a1.store_name '网点Branach'
    ,a1.piece_name 片区District
    ,a1.region_name '大区Area'
    ,a1.third_sorting_code '分拣码Sorting_code'
    ,a1.pr_route '最后有效路由动作Last effective route'
    ,a1.job_name '最后有效路由操作岗位Last operator post'
    ,a1.last_valid_time '最后有效路由时间Last effective routing time'
    ,date_sub(curdate(), interval 1 day) p_date
from tmpale.tmp_ph_false_delivery_d a1
left join tmpale.tmp_ph_false_delivery_d t2 on t2.pno = a1.pno and t2.p_date < date_sub(curdate(), interval 2 day)
where
	t2.pno is null
    and a1.p_date = date_sub(curdate(), interval 1 day)