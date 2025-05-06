select
    a.ss_category
    ,sum(a.rate) 责任分布
from
    (
        select
            plt.id
            ,plt.pno
            ,plr.store_id
            ,case
                when ss.category in (1,10) then 'NW'
                when ss.category in (8,12) then 'HUB'
                when ss.category = 6 then 'FH'
                when ss.category = 2 then 'DC'
                when ss.category = 4 then 'SHOP'
                when ss.category = 5 then 'SHOP'
                when ss.category = 7 then 'SHOP'
                when ss.category = 9 then 'Onsite'
                when ss.category = 11 then 'fulfillment'
                when ss.category = 13 then 'CDC'
                when ss.category = 14 then 'PDC'
            end ss_category
            ,sum(plr.duty_ratio) rate
        from ph_bi.parcel_lose_task plt
        join ph_staging.parcel_info pi on pi.pno = plt.pno
        left join dwm.dwd_dim_bigClient bc on bc.client_id = plt.client_id
        left join ph_staging.order_info oi on plt.pno = oi.pno
        left join ph_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
        left join ph_staging.sys_store ss on ss.id = plr.store_id
        where
            plt.state = 6
            and plt.duty_result = 1
            and plt.updated_at >= '2023-09-01'
            and plt.updated_at < '2023-12-01'
            and plt.penalties > 0
            and coalesce(if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100), pi.cod_amount/100) > 5000
        group by 1,2,3
    ) a
group by 1


;

-- 按照最后有效路由看
select
    a.ss_category
   ,count(distinct a.pno ) 网点分布
from
    (
        select
            plt.id
            ,plt.pno
            ,case
                when ss.category in (1,10) then 'NW'
                when ss.category in (8,12) then 'HUB'
                when ss.category = 6 then 'FH'
                when ss.category = 2 then 'DC'
                when ss.category = 4 then 'SHOP'
                when ss.category = 5 then 'SHOP'
                when ss.category = 7 then 'SHOP'
                when ss.category = 9 then 'Onsite'
                when ss.category = 11 then 'fulfillment'
                when ss.category = 13 then 'CDC'
                when ss.category = 14 then 'PDC'
            end ss_category
        from ph_bi.parcel_lose_task plt
        join ph_staging.parcel_info pi on pi.pno = plt.pno
        left join dwm.dwd_dim_bigClient bc on bc.client_id = plt.client_id
        left join ph_staging.order_info oi on plt.pno = oi.pno
        left join ph_staging.sys_store ss on ss.id = plt.last_valid_store_id
        where
            plt.state = 6
            and plt.duty_result = 1
            and plt.updated_at >= '2023-09-01'
            and plt.updated_at < '2023-12-01'
            and plt.penalties > 0
            and coalesce(if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100), pi.cod_amount/100) > 5000
    ) a
group by 1

;

-- 被判责网点/员工集中性
select
    ss.name ss_name
    ,sum(plr.duty_ratio)/100  rate
from ph_bi.parcel_lose_task plt
join ph_staging.parcel_info pi on pi.pno = plt.pno
left join dwm.dwd_dim_bigClient bc on bc.client_id = plt.client_id
left join ph_staging.order_info oi on plt.pno = oi.pno
left join ph_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
left join ph_staging.sys_store ss on ss.id = plr.store_id
where
    plt.state = 6
    and plt.duty_result = 1
    and plt.updated_at >= '2023-09-01'
    and plt.updated_at < '2023-12-01'
    and plt.penalties > 0
    and coalesce(if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100), pi.cod_amount/100) > 5000
group by 1

;


select
    t.*
    ,case
        when hsi.state = 1 and hsi.wait_leave_state = 1 then '待离职'
        when hsi.hire_date > date(date_sub(t.last_valid_routed_at, interval 30 day)) then '新员工'
        when a2.staff_info_id is not null then '操作前30天内有旷工'
    end 员工状态
    ,if(hsi.hire_type = 12, '是', '否' ) 是否众包
    ,if(hsa.staff_info_id is not null, '是', '否') 是否支援
    ,if(t.returned = 1, '是', '否') 是否退件包裹
    ,if(t.returned = 1 and t.last_valid_action = 'SHIPMENT_WAREHOUSE_SCAN', '是', '否') 是否退件发件出仓丢失
    ,a3.weight - a3.ori_weight '退件重量-正向件重量'
    ,case
        when a4.arrival_pack_no is not null and a4.pno is not null then '是'
        when a4.arrival_pack_no is not null and a4.pno is null then '否'
        else null
    end 集包件是否有拆包
from tmpale.tmp_ph_pno_plt_1202 t
left join ph_bi.hr_staff_transfer hst on hst.staff_info_id = t.last_valid_staff_info_id and hst.stat_date = date(last_valid_routed_at)
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = t.last_valid_staff_info_id
left join
    (
        select
            ad.staff_info_id
        from ph_bi.attendance_data_v2 ad
        join tmpale.tmp_ph_pno_plt_1202 t1 on t1.last_valid_staff_info_id = ad.staff_info_id
        where
            ad.stat_date > '2023-08-01'
            and ad.stat_date < date(t1.last_valid_routed_at)
            and ad.stat_date > date_sub(date(t1.last_valid_routed_at), interval 30 day)
            and ad.attendance_started_at is null
            and ad.attendance_end_at is null
            and ad.attendance_time + ad.BT + ad.BT_Y + ad.AB > 0
        group by 1
    ) a2 on a2.staff_info_id = t.last_valid_staff_info_id
left join ph_backyard.hr_staff_apply_support_store hsa on hsa.staff_info_id = t.last_valid_staff_info_id and hsa.status = 2 and hsa.employment_begin_date <= date(last_valid_routed_at) and hsa.employment_end_date >= date(last_valid_routed_at)
left join
    (
        select
            t.pno
            ,coalesce(b.after_weight, pi.exhibition_weight) weight
            ,pi2.exhibition_weight ori_weight
        from tmpale.tmp_ph_pno_plt_1202 t
        left join ph_staging.parcel_info pi on pi.pno = t.pno
        left join
            (
                select
                    t.pno
                    ,pwr.after_weight
                    ,row_number() over (partition by t.pno order by pwr.created_at desc) rn
                from tmpale.tmp_ph_pno_plt_1202 t
                join dwm.drds_ph_parcel_weight_revise_record_d pwr on pwr.pno = t.pno
                where
                    t.returned = 1
            ) b on b.pno = t.pno and b.rn = 1
        left join ph_staging.parcel_info pi2 on pi2.returned_pno = t.pno
        where
            t.returned = 1
    ) a3 on a3.pno = t.pno
left join
    (
        select
            b1.*
            ,pr.route_action
        from
            (
                select
                    t.pno
                    ,t.last_valid_store_id
                    ,pssn.arrival_pack_no
                from tmpale.tmp_ph_pno_plt_1202 t
                join dw_dmd.parcel_store_stage_new pssn on pssn.pno = t.pno and pssn.store_id = t.last_valid_store_id
                where
                    pssn.arrival_pack_no is not null
                group by 1,2,3
            ) b1
        left join ph_staging.parcel_route pr on b1.pno = pr.pno and pr.route_action = 'UNSEAL' and pr.store_id = b1.last_valid_store_id
        group by 1,2,3,4
    ) a4 on a4.pno = t.pno
;

with t as
    (
        select
            plt.pno
            ,pi.returned
            ,plt.client_id
            ,plt.last_valid_routed_at
            ,bc.client_name
            ,plt.last_valid_store_id
            ,ss.name last_valid_store
            ,plt.last_valid_action
            ,plt.last_valid_staff_info_id
            ,plt.operator_id
            ,coalesce(if(if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100)=0, null,if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100)), pi.cod_amount/100) value
        from ph_bi.parcel_lose_task plt
        join ph_staging.parcel_info pi on pi.pno = plt.pno
        left join dwm.dwd_dim_bigClient bc on bc.client_id = plt.client_id
        left join ph_staging.order_info oi on if(pi.returned = 0, pi.pno, pi.customary_pno) = oi.pno
        left join ph_staging.sys_store ss on ss.id = plt.last_valid_store_id
        where
            plt.state = 6
            and plt.duty_result = 1
            and plt.updated_at >= '2023-09-01'
            and plt.updated_at < '2023-12-01'
            -- and plt.penalties > 0
            and coalesce(if(if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100)=0, null,if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100)), pi.cod_amount/100) > 5000
        group by 1
    )
select
    t1.*
    ,dp.attendance_started_at 员工上班打卡时间
    ,dp.attendance_end_at 员工下班打卡时间
    ,dp.pickup_par_cnt 员工当日揽收包裹数
    ,dp.delivery_par_cnt '妥投包裹数'
    ,dp.delivery_big_par_cnt '妥投大件包裹数'
    ,dp.delivery_sma_par_cnt 妥投小件包裹数
from t t1
left join dwm.dws_ph_staff_wide_s dp on dp.staff_info_id = t1.last_valid_staff_info_id and dp.stat_date = date(t1.last_valid_routed_at)

;

with t as
    (
        select
            plt.pno
            ,pi.returned
            ,plt.client_id
            ,plt.last_valid_routed_at
            ,bc.client_name
            ,plt.last_valid_store_id
            ,ss.name last_valid_store
            ,plt.last_valid_action
            ,plt.last_valid_staff_info_id
            ,plt.operator_id
            ,coalesce(if(if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100)=0, null,if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100)), pi.cod_amount/100) value
        from ph_bi.parcel_lose_task plt
        join ph_staging.parcel_info pi on pi.pno = plt.pno
        left join dwm.dwd_dim_bigClient bc on bc.client_id = plt.client_id
        left join ph_staging.order_info oi on if(pi.returned = 0, pi.pno, pi.customary_pno) = oi.pno
        left join ph_staging.sys_store ss on ss.id = plt.last_valid_store_id
        where
            plt.state = 6
            and plt.duty_result = 1
            and plt.updated_at >= '2023-09-01'
            and plt.updated_at < '2023-12-01'
            -- and plt.penalties > 0
            and coalesce(if(if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100)=0, null,if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100)), pi.cod_amount/100) > 5000
        group by 1
    )
select
    a1.pno, a1.returned, a1.client_id, a1.last_valid_routed_at, a1.client_name, a1.last_valid_store_id, a1.last_valid_store, a1.last_valid_action, a1.last_valid_staff_info_id, a1.operator_id, a1.value, a1.device_id
    ,group_concat(ldr.staff_info_id) 该设备登录员工ID
    ,count(ldr.staff_info_id) 该设备登录员工数
from
    (
        select
            a.*
        from
            (
                select
                    t1.*
                    ,json_extract(pr.extra_value, '$.deviceId') device_id
                    ,row_number() over (partition by t1.pno order by pr.created_at desc) rn
                from ph_staging.parcel_route pr
                join t t1 on t1.pno = pr.pno and t1.last_valid_store_id = pr.store_id and pr.route_action = t1.last_valid_action
            ) a
        where
            a.rn = 1
    ) a1
left join ph_staging.login_device_record ldr on ldr.device_id = a1.device_id and ldr.created_at > date_sub(date(a1.last_valid_routed_at), interval  8 hour) and ldr.created_at < date_add(date(a1.last_valid_routed_at), interval 16 hour)
group by 1

