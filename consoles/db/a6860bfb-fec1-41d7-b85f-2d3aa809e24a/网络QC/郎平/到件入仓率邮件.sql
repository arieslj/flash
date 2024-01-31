SELECT
    date_sub(curdate(),interval 1 day) 日期
    ,ss.`name` 网点名称
    ,smr.`name` 大区
    ,smp.`name` 片区
    ,pr1.应到量
    ,pr2.实到量
    ,concat(round(pr2.实到量/pr1.应到量,4)*100,'%') 到件入仓率
from
    (
        select
            *
        from `ph_staging`.`sys_store` ss
        where
            ss.category in (8,12)
    ) ss
left join `ph_staging`.`sys_manage_region` smr on smr.`id`  =ss.`manage_region`
left join `ph_staging`.`sys_manage_piece` smp on smp.`id`  =ss.`manage_piece`
LEFT JOIN
    (
        select #应到
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 应到量
        from `ph_staging`.`parcel_route` pr
        join ph_staging.sys_store ss on ss.id = pr.store_id and ss.category in (8,12)
        where
            pr.`route_action` in ('ARRIVAL_GOODS_VAN_CHECK_SCAN')
          --  and date_format(convert_tz(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d') = date_sub(curdate(),interval 1 day)
			and pr.`routed_at`>=convert_tz(date_sub(curdate(),interval 1 day), '+08:00', '+00:00')
			and pr.`routed_at`<convert_tz(curdate(), '+08:00', '+00:00')

		group by 1
    )pr1 on pr1.`store_id`=ss.`id`
left join
    (
        select #实到
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 实到量
        from
            (
                select #车货关联到港
                    pr.`pno`
                    ,pr.`store_id`
                    ,pr.`routed_at`
					,date_add(pr.`routed_at`,interval 4 hour) routed_at1
                from `ph_staging`.`parcel_route` pr
                join ph_staging.sys_store ss on ss.id = pr.store_id and ss.category in (8,12)
                where
                    pr.`route_action` in ('ARRIVAL_GOODS_VAN_CHECK_SCAN')
                   -- and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')=date_sub(curdate(),interval 1 day)
                    and pr.`routed_at`>=convert_tz(date_sub(curdate(),interval 1 day), '+08:00', '+00:00')
					and pr.`routed_at`<convert_tz(curdate(), '+08:00', '+00:00')

			)pr
        join
            (
                select #有效路由
                    pr.`pno`
                    ,pr.store_id
                    ,pr.`routed_at`
                    ,pr.route_action
                    ,pr.store_name
                    ,pr.staff_info_id
                    ,pr.staff_info_phone
                    ,pr.staff_info_name
                    ,pr.extra_value
                from `ph_staging`.`parcel_route` pr
                join ph_staging.sys_store ss on ss.id = pr.store_id and ss.category in (8,12)
                where
                    pr.`route_action` in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN',
                                       'ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM',
                                       'DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED',
                                       'STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT',
                                       'DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN',
                                       'ARRIVAL_WAREHOUSE_SCAN','SORTING_SCAN', 'INVENTORY')
                    and pr.`routed_at`>=convert_tz(date_sub(curdate(),interval 1 day), '+08:00', '+00:00')
            ) pr1 on pr1.pno = pr.`pno`
        where
            pr1.store_id=pr.store_id
            and pr1.`routed_at`<= pr.routed_at1
        group by 1
    )pr2 on  pr2.`store_id`=ss.`id`

;

select
    curdate() 日期
    ,pssn.store_name 网点名称
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,count(distinct if(pssn.van_arrived_at is not null, pssn.pno, null)) 应到量
    ,count(distinct if(pssn.van_arrived_at is not null and pssn.first_valid_routed_at is not null ,pssn.pno , null)) 实到量
    ,count(distinct if(pssn.van_arrived_at is not null and pssn.first_valid_routed_at is null, pssn.pno, null)) 未到量
    ,count(distinct if(pssn.van_arrived_at is not null and pssn.first_valid_routed_at is not null ,pssn.pno , null))/count(distinct if(pssn.van_arrived_at is not null, pssn.pno, null)) 到件入仓率
from dw_dmd.parcel_store_stage_new pssn
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pssn.store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
where
    pssn.store_category in (1,10)
    and pssn.van_arrived_at >= date_sub(curdate(), interval 8 hour)
    and pssn.van_arrived_at < date_add(curdate(), interval 16 hour)
group by 1,2,3,4

;
with t as
    (
         select
            pssn.pno
            ,pssn.store_name
            ,dp.piece_name
            ,dp.region_name
        from dw_dmd.parcel_store_stage_new pssn
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pssn.store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
        where
            pssn.store_category in (1,10)
            and pssn.van_arrived_at >= date_sub(curdate(), interval 8 hour)
            and pssn.van_arrived_at < date_add(curdate(), interval 16 hour)
            and pssn.van_arrived_at is not null
            and pssn.first_valid_routed_at is null
    )

select
    t1.pno
    ,a.store_name 最后有效路由操作网点
    ,convert_tz(a.routed_at, '+00:00', '+08:00') 最后有效路由操作时间
    ,a.CN_element 最后有效路由
    ,t1.store_name 下一站网点
    ,t1.piece_name 下一站片区
    ,t1.region_name 下一站大区
from t t1
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,ddd.CN_element
            ,pr.store_name
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
        where
            pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
            and pr.routed_at > date_sub(curdate(), interval 1 month )
    ) a on a.pno = t1.pno and a.rk = 1