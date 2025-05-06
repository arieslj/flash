  /*
        =====================================================================+
        表名称：1615d_ph_parcel_lose_sub_c
        功能描述：疑似丢失网点数据

        需求来源：
        编写人员: 吕杰
        设计日期：2023-07-15
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
            dp.store_name 网点Branch
            ,dp.piece_name 片区District
            ,dp.region_name 大区Area
            ,plt.pno 运单Tracking_Number
            ,pi.exhibition_weight 重量
            ,concat_ws('*', pi.exhibition_length, pi.exhibition_width, pi.exhibition_height) 尺寸
            ,pi2.cod_amount/100 COD
            ,plt.created_at 任务创建时间Task_Generation_time
            ,plt.parcel_created_at 包裹揽收时间Receive_time
            ,concat(ddd.element, ddd.CN_element) 最后有效路由Last_effective_route
            ,plt.last_valid_routed_at 最后有效路由操作时间Last_effective_routing_time
            ,plt.last_valid_staff_info_id 最后有效路由操作员工Last_effective_route_operate_id
            ,ss.name 最后有效路由操作网点Last_operate_branch
            ,case when pi.state = 1 then '已揽收'
                when pi.state = 2 then '运输中'
                when pi.state = 3 then '派送中'
                when pi.state = 4 then '已滞留'
                when pi.state = 5 then '已签收'
                when pi.state = 6 then '疑难件处理中'
                when pi.state = 7 then '已退件'
                when pi.state = 8 then '异常关闭'
                when pi.state = 9 then '已撤销'
                end as 包裹最新状态latest_parcel_status
            ,if(rd3.store_name = rd.store_name, rd2.store_name, rd3.store_name) AS "理论下一站网点 Theoretically_Destination_Store"
            ,rd2.store_name 目的地网点Dst_Store_Name
        from ph_bi.parcel_lose_task plt
        left join ph_bi.parcel_detail pd on pd.pno = plt.pno
        left join ph_staging.parcel_info pi on pi.pno = plt.pno and pi.created_at > date_sub(curdate(), interval 3 month )
        left join  ph_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pd.resp_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
        left join dwm.dwd_dim_dict ddd on ddd.element = plt.last_valid_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
        left join dwm.dim_ph_sys_store_rd dp2 on dp2.store_id = plt.last_valid_store_id and dp2.stat_date = date_sub(curdate(), interval 1 day)
        left join ph_staging.sys_store ss on ss.id = plt.last_valid_store_id
        left join dwm.dim_ph_sys_store_rd rd on rd.store_id = pi.duty_store_id and rd.store_category in (8,12)  and rd.stat_date = date_sub(curdate(),interval 1 day)  and rd.state_desc = '激活' and rd.is_close = 0
        left join dwm.dim_ph_sys_store_rd rd2 on rd2.store_id = pi.dst_store_id and rd2.stat_date = date_sub(curdate(),interval 1 day) and rd2.state_desc = '激活' and rd2.is_close = 0
        left join dwm.dim_ph_sys_store_rd rd3 on rd3.store_id = rd2.par_store_id and rd3.stat_date = date_sub(curdate(),interval 1 day) and rd3.state_desc = '激活' and rd3.is_close = 0
        where
            plt.source in (3,33)
            and plt.state in (1,2,3,4)
    )
select
   t1.*
    ,convert_tz(a.first_valid_routed_at, '+00:00', '+08:00') 到达网点时间
    ,sor.sorting_code 三段码
    ,a2.next_store_name 实际下一站网点
    ,a3.store_name 上一站网点
from t t1
left join
    (
        select
            pr.first_valid_routed_at
            ,pr.pno
            ,row_number() over (partition by pr.pno order by pr.first_valid_routed_at desc ) rn
        from dw_dmd.parcel_store_stage_new  pr
        join t t1 on t1.运单Tracking_Number = pr.pno and t1.网点Branch = pr.store_name
        where
            pr.first_valid_routed_at > date_sub(curdate(), interval 2 month)
    ) a on a.pno = t1.运单Tracking_Number and a.rn = 1
left join
    (
        select
            ps.pno
            ,ps.sorting_code
            ,row_number() over (partition by ps.pno order by ps.created_at desc) rn
        from ph_drds.parcel_sorting_code_info ps
        join t t1 on t1.运单Tracking_Number = ps.pno
        where
            ps.created_at > date_sub(curdate(), interval 3 month)
    ) sor on sor.pno = t1.运单Tracking_Number and sor.rn = 1
left join
    (
        select
            pr.routed_at
            ,pr.pno
            ,pr.next_store_name
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rn
        from ph_staging.parcel_route pr
        join t t1 on t1.运单Tracking_Number = pr.pno and t1.网点Branch = pr.store_name
        where
            pr.routed_at > date_sub(curdate(), interval 2 month)
            and pr.route_action in ('SHIPMENT_WAREHOUSE_SCAN')
    ) a2 on a2.pno = t1.运单Tracking_Number and a2.rn = 1
left join
    (
         select
             pssn.pno
            ,pssn.store_name
            ,row_number() over (partition by pssn.pno order by pssn.last_valid_routed_at desc) rn
         from dw_dmd.parcel_store_stage_new pssn
         join  t t1 on t1.运单Tracking_Number = pssn.pno
         where
             pssn.last_valid_routed_at < date_sub(t1.任务创建时间Task_Generation_time, interval 8 hour)
    ) a3 on a3.pno = t1.运单Tracking_Number and a3.rn = 1


;

select
    pi.pno
    ,ss.name
    ,ss.category
    ,ss.state
from ph_staging.parcel_info pi
left join ph_staging.sys_store ss on ss.id = pi.duty_store_id
where
    pi.pno = 'PT4115GTFG42Z'

;


select
            dp.store_name 网点Branch
            ,dp.piece_name 片区District
            ,dp.region_name 大区Area
            ,plt.pno 运单Tracking_Number
            ,pi.exhibition_weight 重量
            ,concat_ws('*', pi.exhibition_length, pi.exhibition_width, pi.exhibition_height) 尺寸
            ,pi2.cod_amount/100 COD
            ,plt.created_at 任务创建时间Task_Generation_time
            ,plt.parcel_created_at 包裹揽收时间Receive_time
            ,concat(ddd.element, ddd.CN_element) 最后有效路由Last_effective_route
            ,plt.last_valid_routed_at 最后有效路由操作时间Last_effective_routing_time
            ,plt.last_valid_staff_info_id 最后有效路由操作员工Last_effective_route_operate_id
            ,ss.name 最后有效路由操作网点Last_operate_branch
            ,case when pi.state = 1 then '已揽收'
                when pi.state = 2 then '运输中'
                when pi.state = 3 then '派送中'
                when pi.state = 4 then '已滞留'
                when pi.state = 5 then '已签收'
                when pi.state = 6 then '疑难件处理中'
                when pi.state = 7 then '已退件'
                when pi.state = 8 then '异常关闭'
                when pi.state = 9 then '已撤销'
                end as 包裹最新状态latest_parcel_status
            ,if(rd3.store_name = rd.store_name, rd2.store_name, rd3.store_name) AS "理论下一站网点 Theoretically_Destination_Store"
            ,rd3.store_name
            ,rd.store_name
            ,rd2.store_name 目的地网点Dst_Store_Name
        from ph_bi.parcel_lose_task plt
        left join ph_bi.parcel_detail pd on pd.pno = plt.pno
        left join ph_staging.parcel_info pi on pi.pno = plt.pno and pi.created_at > date_sub(curdate(), interval 3 month )
        left join  ph_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pd.resp_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
        left join dwm.dwd_dim_dict ddd on ddd.element = plt.last_valid_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
        left join dwm.dim_ph_sys_store_rd dp2 on dp2.store_id = plt.last_valid_store_id and dp2.stat_date = date_sub(curdate(), interval 1 day)
        left join ph_staging.sys_store ss on ss.id = plt.last_valid_store_id
        left join dwm.dim_ph_sys_store_rd rd on rd.store_id = pi.duty_store_id and rd.store_category in (8,12)  and rd.stat_date = date_sub(curdate(),interval 1 day)  and rd.state_desc = '激活' and rd.is_close = 0
        left join dwm.dim_ph_sys_store_rd rd2 on rd2.store_id = pi.dst_store_id and rd2.stat_date = date_sub(curdate(),interval 1 day) and rd2.state_desc = '激活' and rd2.is_close = 0
        left join dwm.dim_ph_sys_store_rd rd3 on rd3.store_id = rd2.par_store_id and rd3.stat_date = date_sub(curdate(),interval 1 day) and rd3.state_desc = '激活' and rd3.is_close = 0
        where
            plt.source in (3,33)
            and plt.state in (1,2,3,4)
    and plt.pno = 'PT4115GTFG42Z'