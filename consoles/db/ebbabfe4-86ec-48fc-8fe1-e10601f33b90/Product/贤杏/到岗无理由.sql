with t as
    (
        select
            pssn.pno
            ,if(pi.returned = 1 , '退件', '正向') parcel_type
            ,pssn.store_name
            ,json_extract(pssn.first_route_extra_value, '$.leaveStoreName') leave_store_name
            ,pi.state
            ,timestampdiff(minute ,pssn.van_arrived_at ,pssn.first_valid_routed_at)/60 diff_hour
        from dwm.parcel_store_stage_new pssn
        left join my_staging.parcel_info pi on pi.pno = pssn.pno
        where
            pssn.created_at > '2024-04-30 16:00:00'
            and pssn.created_at > '2024-06-17 16:00:00'
            and pssn.first_route_action = 'ARRIVAL_GOODS_VAN_CHECK_SCAN'
            and ( pssn.arrived_at is null or timestampdiff(minute ,pssn.van_arrived_at ,pssn.arrived_at)/60 > 3 )
    )

select
    t1.pno
    ,t1.parcel_type 包裹方向
    ,t1.store_name 卸车网点
    ,t1.leave_store_name 发车网点
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
    end 包裹状态
    ,if(plt.pno is not null, '是', '否') 是否判责丢失
    ,ddd.cn_element 最后有效路由
    ,ss.name    最后有效路由网点
    ,t1.diff_hour 卸车后距离多少小时才产生有效路由
from t t1
left join
    (
        select
            distinct
            plt.pno
        from my_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.parcel_created_at > '2024-05-01'
            and plt.state = 6
            and plt.duty_result = 1
            and plt.penalties > 0
    ) plt on t1.pno = plt.pno
left join my_bi.parcel_detail pd on pd.pno = t1.pno
left join dwm.dwd_dim_dict ddd on ddd.element = pd.last_valid_action and ddd.db = 'my_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
left join my_staging.sys_store ss on ss.id = pd.last_valid_store_id


;



with t as
    (
        select
            pssn.pno
            ,if(pi.returned = 1 , '退件', '正向') parcel_type
            ,pssn.store_name
            ,pssn.store_id
            ,json_extract(pssn.first_route_extra_value, '$.leaveStoreName') leave_store_name
            ,pi.state
            ,timestampdiff(minute ,pssn.van_arrived_at ,pssn.first_valid_routed_at)/60 diff_hour
        from dwm.parcel_store_stage_new pssn
        left join my_staging.parcel_info pi on pi.pno = pssn.pno
        where
            pssn.created_at > '2024-07-31 16:00:00'
            and pssn.created_at < '2024-08-19 16:00:00'
            and pssn.first_route_action = 'ARRIVAL_GOODS_VAN_CHECK_SCAN'
            and ( pssn.first_valid_routed_at is null or timestampdiff(minute ,pssn.van_arrived_at ,pssn.first_valid_routed_at)/60 > 3 )
    )

select
    t1.pno
    ,t1.parcel_type 包裹方向
    ,t1.store_name 卸车网点
    ,dm.piece_name 片区
    ,dm.region_name 大区
    ,t1.leave_store_name 发车网点
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
    end 包裹状态
    ,if(plt.pno is not null, '是', '否') 是否判责丢失
    ,ddd.cn_element 最后有效路由
    ,ss.name    最后有效路由网点
    ,t1.diff_hour 卸车后距离多少小时才产生有效路由
#     count(1)
from t t1
left join dwm.dim_my_sys_store_rd dm on dm.store_id = t1.store_id and dm.stat_date = date_sub(curdate(), interval 1 day)
left join
    (
        select
            distinct
            plt.pno
        from my_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.parcel_created_at > '2024-05-01'
            and plt.state = 6
            and plt.duty_result = 1
            and plt.penalties > 0
    ) plt on t1.pno = plt.pno
left join my_bi.parcel_detail pd on pd.pno = t1.pno
left join dwm.dwd_dim_dict ddd on ddd.element = pd.last_valid_action and ddd.db = 'my_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
left join my_staging.sys_store ss on ss.id = pd.last_valid_store_id
