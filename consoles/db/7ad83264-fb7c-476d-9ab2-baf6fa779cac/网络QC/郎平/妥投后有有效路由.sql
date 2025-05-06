with t as
    (
        select
            pd.pno
            ,pd.last_valid_action
            ,pd.resp_store_updated
            ,date_sub(pd.resp_store_updated, interval 8 hour) route_time
            ,pd.last_valid_staff_info_id
            ,hjt.job_name
            ,pd.last_valid_store_id
        from ph_bi.parcel_detail pd
        left join ph_bi.hr_staff_transfer hst on hst.staff_info_id = pd.last_valid_staff_info_id and hst.stat_date = date_sub(curdate(), interval 1 day)
        left join ph_bi.hr_job_title hjt on hjt.id = hst.job_title
        where
            pd.resp_store_updated >= date_sub(curdate(), interval 1 day)
            and pd.resp_store_updated < curdate()
           -- and pd.state in (1,2,3,4,6)
    )
select
    dp.store_name '网点Branch'
    ,dp.piece_name '片区District'
    ,dp.region_name '大区Area'
    ,a1.pno '运单Tracking_Number'
    ,date_format(convert_tz(a1.routed_at, '+00:00', '+08:00'), '%Y-%m-%d %H:%i:%s') '妥投时间Delivery time'
    ,a1.staff_info_id '"妥投快递员Courier ID"'
    ,ddd.CN_element '最后有效路由Last_effective_route'
    ,a1.resp_store_updated '最后有效路由操作时间Last_effective_routing_time'
    ,a1.last_valid_staff_info_id '最后有效路由操作员工Last_effective_route_operate_id'
    ,a1.job_name '最后有效路由操作员工岗位Last_effective_route_operate_post'
    ,ss.name '最后有效路由操作网点Last_operate_branch'
    ,pi.exhibition_weight/1000 '重量Weight'
    ,concat_ws('*', pi.exhibition_length, pi.exhibition_width, pi.exhibition_height) '尺寸Size'
    ,sor.sorting_code '三段码Sorting_code'
from
    (
        select
            t1.*
            ,pr.store_id
            ,pr.routed_at
            ,pr.staff_info_id
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > date_sub(curdate(), interval 6 month)
            and pr.route_action = 'DELIVERY_CONFIRM'
            and pr.routed_at < t1.route_time
    ) a1
left join ph_staging.parcel_info pi on pi.pno = a1.pno
left join ph_staging.sys_store ss on ss.id = a1.last_valid_store_id
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = a1.store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
left join dwm.dwd_dim_dict ddd on ddd.element = a1.last_valid_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
left join
    (
        select
            ps.pno
            ,ps.sorting_code
            ,row_number() over (partition by ps.pno order by ps.created_at desc) rn
        from ph_drds.parcel_sorting_code_info ps
        join t t1 on t1.pno = ps.pno
        where
            ps.created_at > date_sub(curdate(), interval 4 month)
    ) sor on sor.pno = a1.pno and sor.rn = 1
where
    pi.cod_enabled = 0