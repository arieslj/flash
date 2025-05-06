-- 需求文档：https://flashexpress.feishu.cn/wiki/NlwUwfdPjir1Sjk2yUPcS5lenBb

-- 仓管员/ 主管拆包不逐一扫描完包裹
select
    pud.pno 运单号
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
    end 包裹状态
    ,pi2.client_id 客户ID
    ,pi.pack_no 集包号
    ,convert_tz(pi.seal_at, '+00:00', '+08:00') 集包时间
    ,convert_tz(pi.unseal_at, '+00:00', '+08:00') 拆包时间
    ,pi.seal_staff_info_id 操作集包员工
    ,pi.unseal_staff_info_id 操作拆包员工
    ,pi.seal_store_name 集包始发网点
    ,pi.es_unseal_store_name 集包目的地网点
    ,if(pi2.cod_enabled = 1, '是', '否') 是否COD包裹
    ,pi3.cod_amount/100 COO
    ,if(bc.client_name = 'lazada', pi3.insure_declare_value/100, pai.cogs_amount/100) COGS
from ph_staging.pack_info pi
join ph_staging.pack_unseal_detail pud on pi.pack_no = pud.pack_no
left join ph_staging.parcel_info pi2 on pi2.pno = pud.pno
left join ph_staging.parcel_info pi3 on if(pi2.returned = 1, pi2.customary_pno, pi2.pno) = pi3.pno
left join ph_staging.parcel_additional_info pai on pai.pno = pi3.pno
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi2.client_id
where
    pi.unseal_at < date_sub(curdate(), interval 8 hour )
    and pi.unseal_at >= date_sub(curdate(), interval 32 hour )
    and pi.unseal_count < pi.seal_count
;

-- 换单打印

select
    pr.pno 运单号
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
    end 包裹状态
    ,pi.client_id 客户ID
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 换单时间
    ,pr.staff_info_id 员工
    ,pr.store_name 操作换单网点
    ,if(swa.started_at is not null or swa.end_at is not null, 'Y', 'N') 员工是否有打卡记录
    ,if(hst.staff_info_id is not null, '是', '否') 员工近一周是否停职
    ,case
        when hsi.state = 1 and hsi.wait_leave_state = 0 then '在职'
        when hsi.state = 1 and hsi.wait_leave_state = 1 then '待离职'
        when hsi.state = 2 then '离职'
        when hsi.state = 3 then '停职'
    end 员工状态
    ,case
        when bc.client_name = 'lazada' then pi2.insure_declare_value/100
        when bc.client_name is not null and bc.client_name != 'lazada' then pai.cogs_amount/100
        when bc.client_name is null and pai.cogs_amount is not null then pai.cogs_amount/100
        when bc.client_name is null and pai.cogs_amount is null then pi2.cod_amount/100
        else null
    end 包裹价值
from ph_staging.parcel_route pr
left join ph_backyard.staff_work_attendance swa on swa.staff_info_id = pr.staff_info_id and swa.attendance_date = date_sub(curdate(), interval 1 day)
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pr.staff_info_id
left join ph_staging.parcel_info pi on pi.pno = pr.pno
left join ph_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 1,pi.customary_pno, pi.pno)
left join ph_staging.parcel_additional_info pai on pai.pno = pi2.pno
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
left join
    (
        select
            hst.staff_info_id
        from ph_bi.hr_staff_transfer hst
        where
            hst.stat_date <= date_sub(curdate(), interval 1 day )
            and hst.stat_date >= date_sub(curdate(), interval 6 day )
            and hst.state = 3
        group by 1
    ) hst on hst.staff_info_id = pr.staff_info_id
where
    pr.route_action = 'REPLACE_PNO'
    and pr.routed_at < date_sub(curdate(), interval 8 hour )
    and pr.routed_at >= date_sub(curdate(), interval 32 hour )
    and hsi.state is not null -- 员工状态不为null
    and
    (
        (swa.started_at is null and swa.end_at is null)
        or ( hsi.state = 1 and hsi.wait_leave_state = 1)
        or hst.staff_info_id is not null
        or ( if(bc.client_name = 'lazada', pi2.insure_declare_value, pai.cogs_amount)) > 500000
        or pi2.cod_amount > 500000
    )
;

-- 交接高价值的包裹未回仓

with t as
    (
        select
            pr.pno
            ,case
                when bc.client_name = 'lazada' then pi2.insure_declare_value/100
                when bc.client_name is not null and bc.client_name != 'lazada' then pai.cogs_amount/100
                when bc.client_name is null and pai.cogs_amount is not null then pai.cogs_amount/100
                when bc.client_name is null and pai.cogs_amount is null then pi2.cod_amount/100
                else null
            end parcel_value
            ,pr.staff_info_id
            ,pi.client_id
            ,convert_tz(pr.routed_at, '+00:00', '+08:00') scan_at
            ,pr.store_name
           -- ,pi.state pi_state
        from ph_staging.parcel_route pr
        left join ph_staging.parcel_info pi on pi.pno = pr.pno
        left join ph_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 1,pi.customary_pno, pi.pno)
        left join ph_staging.parcel_additional_info pai on pai.pno = pi2.pno
        left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
        left join ph_staging.parcel_problem_detail ppd on ppd.pno = pr.pno and ppd.created_at >= date_sub(curdate(), interval 32 hour) and ppd.created_at < date_sub(curdate(), interval 8 hour )
        where
            pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
            and pr.routed_at < date_sub(curdate(), interval 8 hour )
            and pr.routed_at >= date_sub(curdate(), interval 32 hour )
            and (( if(bc.client_name = 'lazada', pi2.insure_declare_value, pai.cogs_amount)) > 500000 or  pi2.cod_amount > 500000)
            and ppd.pno is null
            and pi.state != 5
    )
select
    t1.pno 运单号
    ,t1.parcel_value 包裹价值
    ,t1.client_id 客户ID
    ,t1.staff_info_id 交接员工
    ,t1.scan_at 交接时间
    ,t1.store_name 网点
    ,a1.CN_element 最后有效路由
    ,convert_tz(a1.routed_at, '+00:00', '+08:00') 最后有效路由时间
from t t1
left join
    (
        select
            ddd.CN_element
            ,pr.pno
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
        from ph_staging.parcel_route pr
        join ( select t1.pno from t t1 group by 1) t1 on t1.pno = pr.pno
        left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
        where
            pr.routed_at > date_sub(curdate(), interval 1 month)
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
    ) a1 on a1.pno = t1.pno and a1.rk = 1

;

-- 高价值包裹扫空单
select
    p.pno
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
    ,pi.client_id 客户ID
    ,p.staff_info_id 最后操作改约的工号
    ,convert_tz(p.routed_at, '+00:00', '+08:00') 操作改约时间
    ,p.store_name  网点
from ph_staging.parcel_info pi
join
    (

        select
            p1.*
            ,row_number() over (partition by p1.pno order by p1.routed_at desc) rk
        from
            (
                select
                    pr.pno
                    ,pr.store_name
                    ,pr.routed_at
                    ,pr.staff_info_id
                from ph_staging.parcel_route pr
                left join ph_staging.parcel_info pi on pi.pno = pr.pno
                left join ph_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 1,pi.customary_pno, pi.pno)
                left join ph_staging.parcel_additional_info pai on pai.pno = pi2.pno
                left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
                where
                    pr.route_action = 'DELIVERY_MARKER'
                    and pr.routed_at < date_sub(curdate(), interval 8 hour )
                    and pr.routed_at >= date_sub(curdate(), interval 32 hour )
                    and pr.marker_category = 70
                    and ((if(bc.client_name = 'lazada', pi2.insure_declare_value, pai.cogs_amount)) > 500000 or  pi2.cod_amount > 500000)

            ) p1
        join
            (
                select
                    pr.pno
                from ph_staging.parcel_route pr
                where
                    pr.route_action = 'DELIVERY_MARKER'
                    and pr.routed_at < date_sub(curdate(), interval 32 hour )
                    and pr.routed_at >= date_sub(curdate(), interval 56 hour )
                    and pr.marker_category = 70
                group by 1
            ) p2 on p2.pno = p1.pno
        join
            (
                select
                    pr.pno
                from ph_staging.parcel_route pr
                where
                    pr.route_action = 'DELIVERY_MARKER'
                    and pr.routed_at < date_sub(curdate(), interval 56 hour )
                    and pr.routed_at >= date_sub(curdate(), interval 80 hour )
                    and pr.marker_category = 70
                group by 1
            ) p3 on p3.pno = p1.pno
    ) p on p.pno = pi.pno and p.rk = 1

;


-- 高价值包裹连续盘库多日且没有其他路由

with t as
    (
        select
            a.pno
            ,a.staff_info_id
            ,a.store_name
            ,a.pi_state
            ,a.client_id
        from
            (
                select
                    p1.*
                    ,row_number() over (partition by p1.pno order by p1.routed_at desc) rk
                from
                    (
                        select
                            pr.pno
                            ,pr.store_name
                            ,pr.routed_at
                            ,pi.state pi_state
                            ,pi.client_id
                            ,pr.staff_info_id
                        from ph_staging.parcel_route pr
                        left join ph_staging.parcel_info pi on pi.pno = pr.pno
                        left join ph_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 1,pi.customary_pno, pi.pno)
                        left join ph_staging.parcel_additional_info pai on pai.pno = pi2.pno
                        left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
                        where
                            pr.route_action = 'INVENTORY'
                            and pr.routed_at < date_sub(curdate(), interval 8 hour )
                            and pr.routed_at >= date_sub(curdate(), interval 32 hour )
                            and ((if(bc.client_name = 'lazada', pi2.insure_declare_value, pai.cogs_amount)) > 500000 or  pi2.cod_amount > 500000)
                    ) p1
                join
                    (
                        select
                            pr.pno
                        from ph_staging.parcel_route pr
                        where
                            pr.route_action = 'INVENTORY'
                            and pr.routed_at < date_sub(curdate(), interval 32 hour )
                            and pr.routed_at >= date_sub(curdate(), interval 56 hour )
                        group by 1
                    ) p2 on p2.pno = p1.pno
                join
                    (
                        select
                            pr.pno
                        from ph_staging.parcel_route pr
                        where
                            pr.route_action = 'INVENTORY'
                            and pr.routed_at < date_sub(curdate(), interval 56 hour )
                            and pr.routed_at >= date_sub(curdate(), interval 80 hour )
                        group by 1
                    ) p3 on p3.pno = p1.pno
                left join
                    (
                        select
                            pr.pno
                        from ph_staging.parcel_route pr
                        where
                            pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
                            and pr.routed_at < date_sub(curdate(), interval 8 hour )
                            and pr.routed_at >= date_sub(curdate(), interval 80 hour )
                        group by 1
                    ) p on p.pno = p1.pno
                where
                    p.pno is null
            ) a
        where
            a.rk = 1
    )
select
    t1.pno 运单号
    ,case t1.pi_state
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
    ,t1.client_id 客户id
    ,t1.staff_info_id 最后操作盘库员工
    ,t1.store_name  最后操作盘库的网点
    ,pr.CN_element 最后有效路由（非盘库）
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 最后有效路由时间
from t t1
left join
    (
        select
            ddd.CN_element
            ,pr.pno
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
        from ph_staging.parcel_route pr
        join t t1 on pr.pno = t1.pno
        left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
        where
            pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
            and pr.routed_at > date_sub(curdate(), interval 1 month)
    ) pr on pr.pno = t1.pno and pr.rk = 1
left join
    (
        select
            pr.pno
        from ph_staging.parcel_route pr
        join t t1 on pr.pno = t1.pno
        where
            pr.route_action = 'REFUND_CONFIRM'
            and pr.routed_at > date_sub(curdate(), interval 1 month)
        group by 1
    ) hol on hol.pno = t1.pno
where
    hol.pno is null

;

-- 6. 操作其他路由并且操作员工没有打卡（有的操作收件入仓的工号没有打卡）

select
    pr.pno
    ,pi.client_id 客户id
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
    ,ddd.CN_element 路由动作
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 路由时间
    ,pr.staff_info_id 操作员工
    ,pr.store_name 网点
from ph_staging.parcel_route pr
left join ph_staging.parcel_info pi on pi.pno = pr.pno
left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
left join ph_backyard.staff_work_attendance swa on swa.staff_info_id = pr.staff_info_id and swa.attendance_date = date_sub(curdate(), interval 1 day)
where
    pr.route_action in ('RECEIVE_WAREHOUSE_SCAN', 'SHIPMENT_WAREHOUSE_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'DETAIN_WAREHOUSE', 'DIFFICULTY_HANDOVER')
    and pr.routed_at < date_sub(curdate(), interval 8 hour )
    and pr.routed_at >= date_sub(curdate(), interval 32 hour )
    and pr.store_category in (1,10,14) -- sp,bdc,pdc
    and swa.started_at is null
    and swa.end_at is null
