
/*
  =====================================================================+
  表名称：1698d_ph_parcel_backlog_info
  功能描述：菲律宾包裹积压件明细

  需求来源：
  编写人员: 吕杰
  设计日期：2023-09-05
  修改日期:
  修改人员:
  修改原因:
  -----------------------------------------------------------------------
  ---存在问题：
  -----------------------------------------------------------------------
  +=====================================================================
*/
with t as
(
    select
        pi.pno
        ,pi.state
        ,pi.ticket_pickup_store_id
        ,pi.returned
        ,pi.dst_store_id
        ,pi.client_id
        ,pi.cod_enabled
    from ph_staging.parcel_info pi
    join ph_staging.parcel_overdue_date_record pod on pod.pno = pi.pno
    where
        pi.created_at > date_sub(curdate(), interval 90 day)
        and pi.state not in (5,7,8,9)
)
select
    t1.pno
    ,if(t1.returned = 1, '退件', '正向件')  方向
    ,t1.client_id 客户ID
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as 客户类型
    ,case t1.state
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
    ,d2.CN_element 疑难原因
    ,datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) 最后有效路由距今天数
    ,ddd.CN_element 最后一条路由
    ,pr.store_name 最后有效路由动作网点
    ,convert_tz(pr.routed_at ,'+00:00', '+08:00') 最新一条有效路由时间
    ,datediff(now(), de.dst_routed_at) 目的地网点停留时间
    ,de.dst_store 目的地网点
    ,dsts.name 揽收目的地网点
    ,de.dst_piece
    ,de.dst_region
    ,de.src_store 揽收网点
    ,de.pickup_time 揽收时间
    ,de.pick_date 揽收日期
    ,if(hold.pno is not null, 'yes', 'no' ) 是否有holding标记
    ,if(pr3.pno is not null, 'yes', 'no') 是否有待退件标记
    ,td.try_num 尝试派送次数
    ,di3.拒收次数
    ,di3.改约次数
    ,di3.联系不上次数
    ,di3.错分次数
    ,plt2.plt_cnt 进入闪速次数
    ,if(c.pno is not null, '是', '否') 是否禁运品
    ,pssn.store_num '网点&HUB之间发出次数'
    ,p2.diff_days 当前网点停留时间H
from t t1
left join ph_staging.ka_profile kp on t1.client_id = kp.id
left join dwm.dwd_dim_bigClient bc on bc.client_id = t1.client_id
left join dwm.dwd_ex_ph_parcel_details de on de.pno = t1.pno and de.pick_date >= date_sub(curdate(), interval 90 day)
left join
    (
        select
            t2.pno
            ,cdt.negotiation_result_category
            ,di.diff_marker_category
            ,case
                when di.diff_marker_category in (20,21)  and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 0 then ss2.name
                WHEN di.diff_marker_category in (20,21) and cdt.vip_enable = 0 then ss2.name
            end sh_do
        from ph_staging.diff_info di
        join t t2 on t2.pno = di.pno
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join ph_bi.parcel_lose_task plt on plt.source_id = cdt.id
        left join ph_staging.sys_store ss2 on ss2.id = t2.ticket_pickup_store_id
        where
            cdt.negotiation_result_category is null
            and di.created_at > date_sub(curdate(), interval 90 day)
    ) di on di.pno = t1.pno
left join dwm.dwd_dim_dict d2 on d2.element = di.diff_marker_category and d2.db = 'ph_staging' and d2.tablename = 'diff_info' and d2.fieldname = 'diff_marker_category'
left join
    (
        select
            pr.pno
            ,pr.store_name
            ,pr.routed_at
            ,pr.route_action
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
        from  ph_staging.parcel_route pr
        join t t3 on t3.pno = pr.pno
        where
            pr.route_action in ('INVENTORY','RECEIVED' ,'RECEIVE_WAREHOUSE_SCAN', 'SORTING_SCAN', 'DELIVERY_TICKET_CREATION_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SHIPMENT_WAREHOUSE_SCAN', 'DETAIN_WAREHOUSE', 'DELIVERY_CONFIRM', 'DIFFICULTY_HANDOVER', 'DELIVERY_MARKER', 'REPLACE_PNO','SEAL', 'UNSEAL', 'STAFF_INFO_UPDATE_WEIGHT', 'STORE_KEEPER_UPDATE_WEIGHT', 'STORE_SORTER_UPDATE_WEIGHT', 'DISCARD_RETURN_BKK', 'DELIVERY_TRANSFER', 'PICKUP_RETURN_RECEIPT', 'FLASH_HOME_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SORTING_SCAN ', 'DELIVERY_PICKUP_STORE_SCAN', 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE', 'REFUND_CONFIRM', 'ACCEPT_PARCEL')
            and pr.organization_type = 1
            and pr.routed_at > date_sub(curdate(), interval 90 day)
        ) pr on pr.pno = t1.pno and pr.rk = 1
left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
left join
    (
        select
            plt.pno
            ,count(distinct plt.id) plt_cnt
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.created_at > date_sub(curdate(), interval 90 day)
        group by 1
    ) plt2 on plt2.pno = t1.pno
left join
    (
        select
            plt.pno
        from ph_bi.parcel_claim_task plt
        join t t4  on t4.pno = plt.pno
        where
            plt.state not in (6,7,8)
            and plt.source = 11
        group by 1
    ) pct on pct.pno = t1.pno
left join
    (
        select
            pr2.pno
        from ph_staging.parcel_route pr2
        join t t1 on t1.pno = pr2.pno
        where
            pr2.route_action = 'REFUND_CONFIRM'
            and pr2.routed_at > date_sub(curdate(), interval 90 day)
        group by 1
    ) hold on hold.pno = t1.pno
left join
    (
        select
            pr2.pno
        from  ph_staging.parcel_route pr2
        join t t1 on t1.pno = pr2.pno
        where
            pr2.route_action = 'PENDING_RETURN'
            and pr2.routed_at > date_sub(curdate(), interval 90 day)
        group by 1
    ) pr3 on pr3.pno = t1.pno
left join
    (
        select
            td.pno
            ,count(distinct date(convert_tz(tdm.created_at, '+00:00', '+08:00'))) try_num
        from ph_staging.ticket_delivery td
        join t t1 on t1.pno = td.pno
        left join ph_staging.ticket_delivery_marker tdm on tdm.delivery_id = td.id
        where
            td.created_at > date_sub(curdate(), interval 90 day)
        group by 1
    ) td on td.pno = t1.pno
left join
    (
        select
            t1.pno
            ,count(distinct if(ppd.diff_marker_category = 17, date(convert_tz(ppd.created_at, '+00:00', '+08:00')), null)) 拒收次数
            ,count(distinct if(ppd.diff_marker_category = 40, date(convert_tz(ppd.created_at, '+00:00', '+08:00')), null)) 联系不上次数
            ,count(distinct if(ppd.diff_marker_category = 14, date(convert_tz(ppd.created_at, '+00:00', '+08:00')), null)) 改约次数
            ,count(distinct if(ppd.diff_marker_category = 31, date(convert_tz(ppd.created_at, '+00:00', '+08:00')), null)) 错分次数
        from ph_staging.parcel_problem_detail ppd
        join t t1 on t1.pno = ppd.pno
        where
            ppd.created_at > date_sub(curdate(), interval 90 day)
            and ppd.diff_marker_category in (17,14,40,31) -- 17 拒收 -- 14 改约 -- 40 联系不上 -- 31  错分
        group by 1
    ) di3 on di3.pno = t1.pno
left join
    (
        select
            t1.pno
            ,count(distinct ps.valid_store_order) store_num
        from dw_dmd.parcel_store_stage_new ps
        join t t1 on t1.pno = ps.pno
        where
            ps.valid_store_order is not null
            and ps.created_at > date_sub(curdate(), interval 90 day)
        group by 1
    ) pssn on pssn.pno = t1.pno
left join
    (
        select
            p1.pno
            ,timestampdiff(hour,convert_tz(p1.first_valid_routed_at, '+00:00', '+08:00'), now()) diff_days
        from
            (
                select
                    ps.first_valid_routed_at
                    ,ps.pno
                    ,row_number() over (partition by ps.pno order by ps.first_valid_routed_at desc) rk
                from dw_dmd.parcel_store_stage_new ps
                join t t1 on t1.pno = ps.pno
                where
                    ps.created_at > date_sub(curdate(), interval 90 day)
            ) p1
        where
            p1.rk = 1
    ) p2 on p2.pno = t1.pno
left join
    (
        select
            pcd.pno
            ,ss.name
        from ph_staging.parcel_change_detail pcd
        join t t1 on t1.pno = pcd.pno
        left join ph_staging.sys_store ss on ss.id = pcd.old_value
        where
            pcd.created_at > date_sub(curdate(), interval 3 month)
            and pcd.field_name = 'dst_store_id'
            and pcd.new_value = 'PH19040F05'
    ) dsts on dsts.pno = t1.pno
left join ph_bi.contraband c on c.pno = t1.pno and c.duty_level in (1,2)
group by t1.pno