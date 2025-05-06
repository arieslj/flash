with t as
    (
        select
            di.pno
            ,di.store_id
            ,ss.name
            ,di.created_at
            ,ddd.CN_element diff_marker_category
        from ph_staging.diff_info di
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        join ph_staging.sys_store ss on ss.id = di.store_id
        left join dwm.dwd_dim_dict ddd on ddd.element = di.diff_marker_category and ddd.db = 'ph_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
        where
            di.created_at > date_sub(curdate(), interval 90 day)
            and cdt.created_at > date_sub(curdate(), interval 90 day)
         --   and ss.category = 14 -- PDC
            and
                (
                    ( cdt.state in (0,2) )
                    or ( cdt.state = 1 and cdt.created_at < date_sub(curdate(), interval 7 hour ) and cdt.updated_at >= date_sub(curdate(), interval 7 hour ) )
                )

        union all

        select
            pr.pno
            ,pi.dst_store_id  store_id
            ,ss2.name
            ,pr.routed_at created_at
            ,'holding' diff_marker_category
        from ph_staging.parcel_route pr
        join ph_staging.parcel_info pi on pi.pno = pr.pno
        left join ph_staging.sys_store ss2 on ss2.id = pi.dst_store_id
        where
            pr.routed_at > date_sub(curdate(), interval 90 day)
            and pr.route_action = 'REFUND_CONFIRM' -- holding
            and
                (
                    ( pi.state in (5,7,8) and pi.state_change_at > date_sub(curdate(), interval 7 hour ) )
                    or ( pi.state in (1,2,3,4,6) )
                )
    )
select
    t1.pno 运单号
    ,ds.store_name 网点
    ,ds.piece_name 片区
    ,ds.region_name 大区
    ,convert_tz(t1.created_at, '+00:00', '+08:00') '问题件/holding提交时间'
    ,datediff(now(), convert_tz(t1.created_at, '+00:00', '+08:00')) '问题件/holding提交至今时长_day'
    ,t1.diff_marker_category '问题件类型/holding动作'
    ,cur.CN_element 快递员最新有效路由动作
    ,convert_tz(cur.routed_at, '+00:00', '+08:00') 快递员最新有效路由时间
    ,cur.staff_info_id 快递员ID
    ,cur.staff_info_name 快递员
    ,dco.CN_element 仓管最新有效路由动作
    ,convert_tz(dco.routed_at, '+00:00', '+08:00') 仓管最新有效路由时间
    ,dco.staff_info_id 操作人
    ,dco.job_name 操作人岗位
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
    end 当前包裹状态
from t t1
left join
    (
        select
            t1.pno
            ,t1.diff_marker_category
        from
            ( select *  from t t1 where t1.diff_marker_category = '多次尝试派件失败' ) t1
        join
            ( select *  from t t1 where t1.diff_marker_category = 'holding' ) t2 on t1.pno = t2.pno
    ) ep on ep.pno = t1.pno and ep.diff_marker_category = t1.diff_marker_category
left join dwm.dim_ph_sys_store_rd  ds on ds.store_id = t1.store_id and ds.stat_date = date_sub(curdate(), interval 1 day)
left join
    (
        select
            pr.pno
            ,pr.staff_info_id
            ,pr.staff_info_name
            ,ddd2.CN_element
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rn
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pr.staff_info_id
        left join dwm.dwd_dim_dict ddd2 on ddd2.element = pr.route_action and ddd2.db = 'ph_staging' and ddd2.tablename = 'parcel_route' and ddd2.fieldname = 'route_action'
        where
            pr.routed_at > date_sub(curdate(), interval 7 hour)
            and pr.routed_at > t1.created_at
            and hsi.job_title in (13,110,1000) -- 快递员
    ) cur on t1.pno = cur.pno and cur.rn = 1
left join
    (
        select
            pr.pno
            ,pr.staff_info_id
            ,pr.staff_info_name
            ,ddd2.CN_element
            ,hjt.job_name
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rn
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pr.staff_info_id
        left join dwm.dwd_dim_dict ddd2 on ddd2.element = pr.route_action and ddd2.db = 'ph_staging' and ddd2.tablename = 'parcel_route' and ddd2.fieldname = 'route_action'
        left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
        where
            pr.routed_at > date_sub(curdate(), interval 7 hour)
            and pr.routed_at > t1.created_at
            and hsi.job_title in (37,16,1553) -- 仓管员,主管,副主管
    ) dco on t1.pno = dco.pno and dco.rn = 1
left join ph_staging.parcel_info pi2 on t1.pno = pi2.pno and pi2.created_at > date_sub(curdate(), interval 90 day)
where
    ep.pno is null

