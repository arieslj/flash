
select
    case
        when dm.store_category = 6 then 'FH'
        when dm.store_category in (8,12) then 'HUB'
        else dm.region_name
    end 大区
    ,dm.piece_name 片区
    ,dm.store_id 网点ID
    ,dm.store_name 网点
    ,dm.store_type 网点类型
    ,count(distinct if(ppd.basis_type in (17), ppd.pno, null)) as '在仓X天'
    ,count(distinct if(ppd.basis_type in (19), ppd.pno, null)) as 催单
    ,count(distinct if(ppd.basis_type in (13,14,15,16), ppd.pno, null)) as '临近时效'
    ,count(distinct if(ppd.basis_type not in (13,14,15,16,17,19), ppd.pno, null)) 其他
from my_staging.parcel_priority_delivery_detail ppd
join my_staging.parcel_info pi on ppd.pno = pi.pno
left join dwm.dim_my_sys_store_rd dm on dm.store_id = ppd.dst_store_id and dm.stat_date = date_sub(curdate(), interval 1 day)
left join my_staging.parcel_problem_detail ppd2 on ppd.pno = ppd2.pno and ppd2.created_at > date_sub(curdate(), interval 8 hour) and ppd2.created_at < date_add(curdate(), interval 16 hour)
where
    ppd.screening_date = curdate()
  --  and pi.state in (1,2,3,4)
  --  and ppd2.pno is null
group by 1,2,3,4
order by 1,2,3,4


    ;

with t as
    (
        select
            ppd.pno
            ,pi.client_id
            ,ppd.dst_store_id
            ,pi.returned
            ,pi.cod_enabled
            ,dm.store_category
            ,pi.state
            ,ppd.basis_type
            ,dm.region_name
            ,dm.piece_name
            ,dm.store_name
        from my_staging.parcel_priority_delivery_detail ppd
        join my_staging.parcel_info pi on ppd.pno = pi.pno and ppd.dst_store_id = pi.dst_store_id
        left join dwm.dim_my_sys_store_rd dm on dm.store_id = ppd.dst_store_id and dm.stat_date = date_sub(curdate(), interval 1 day)
        left join my_staging.parcel_problem_detail ppd2 on ppd.pno = ppd2.pno and ppd2.created_at > date_sub(curdate(), interval 8 hour) and ppd2.created_at < date_add(curdate(), interval 16 hour)
        where
            ppd.screening_date = curdate()
            and pi.state in (1,2,3,4)
            and ppd2.pno is null
    )
select
    t1.pno 运单号
    ,t1.client_id 客户ID
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.id is null then '普通ka'
        when kp.`id` is null then '小c'
    end 客户类型
    ,case
        when t1.basis_type in (17) then '在仓X天'
        when t1.basis_type in (19) then '催单'
        when t1.basis_type in (13,14,15,16) then '临近时效'
        when t1.basis_type not in (13,14,15,16,17,19) then '其他'
    end PRI类型
    ,case t1.returned
        when 0 then '正向'
        when 1 then '退件'
    end '正向/退件包裹'
    ,case t1.cod_enabled
        when 0 then '否'
        when 1 then '是'
    end 是否为COD
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
    ,d1.cn_element 最后有效路由动作
    ,pd.resp_store_updated 最后有效路由动作时间
    ,dm2.store_name '责任网点（包裹当前网点）'
    ,dm2.store_type '责任网点（包裹当前网点）类型'
    ,dm2.piece_name '责任网点（包裹当前网点）片区'
    ,dm2.region_name '责任网点（包裹当前网点）大区'
    ,case
        when dm2.store_category = 6 then 'FH'
        when dm2.store_category in (8,12) then 'HUB'
        else dm2.region_name
    end '责任网点（包裹当前网点）大区'
    ,ss2.name 目的地网点
    ,case ss2.category
        when 1 then 'SP'
        when 2 then 'DC'
        when 4 then 'SHOP'
        when 5 then 'SHOP'
        when 6 then 'FH'
        when 7 then 'SHOP'
        when 8 then 'Hub'
        when 9 then 'Onsite'
        when 10 then 'BDC'
        when 11 then 'fulfillment'
        when 12 then 'B-HUB'
        when 13 then 'CDC'
        when 14 then 'PDC'
    end 目的地网点类型
    ,case
        when t1.store_category = 6 then 'FH'
        when t1.store_category in (8,12) then 'HUB'
        else t1.region_name
    end 目的地大区
    ,t1.piece_name 目的地片区
    ,ps.third_sorting_code 网格
    ,sc.staff_info_id 最后交接快递员ID
    ,dm.cn_element 快递员最后标记原因
    ,dc.date_cnts 包裹尝试派送次数
    ,if(ds.pno is not null, '是', '否') 是否当日应派
from t t1
left join my_bi.dc_should_delivery_today ds on ds.pno = t1.pno and ds.stat_date = curdate()
left join my_staging.ka_profile kp on kp.id = t1.client_id
left join my_staging.sys_store ss2 on ss2.id = t1.dst_store_id
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = kp.id
left join my_bi.parcel_detail pd on t1.pno = pd.pno
left join dwm.dim_my_sys_store_rd dm2 on pd.resp_store_id = dm2.store_id and dm2.stat_date = date_sub(curdate(), interval 1 day)
left join dwm.dwd_dim_dict d1 on d1.element = pd.last_valid_action and d1.db = 'my_staging' and d1.tablename = 'parcel_route' and d1.fieldname = 'route_action'
left join
    (
        select
            pr.pno
            ,pr.staff_info_id
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
            and pr.routed_at >= date_sub(curdate(), interval 2 day )
          --  and pr.routed_at < date_sub(curdate(), interval 8 hour)
    ) sc on sc.pno = t1.pno and sc.rk = 1
left join
    (
        select
            pr.pno
            ,ddd.cn_element
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        left join dwm.dwd_dim_dict ddd on ddd.element = pr.marker_category and ddd.db = 'my_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
        where
            pr.route_action = 'DELIVERY_MARKER'
            and pr.routed_at >= date_sub(curdate(), interval 2 day )
          --  and pr.routed_at < date_sub(curdate(), interval 8 hour)
    ) dm on dm.pno = t1.pno and dm.rk = 1
left join
    (
        select
            ppd.pno
            ,count(distinct date(convert_tz(ppd.created_at, '+00:00', '+08:00'))) date_cnts
        from my_staging.parcel_problem_detail ppd
        join t t1 on t1.pno = ppd.pno
        where
            ppd.created_at > date_sub(curdate(), interval 2 month)
        group by 1
    ) dc on dc.pno = t1.pno
left join
    (
        select
            ps.pno
            ,ps.third_sorting_code
            ,row_number() over (partition by ps.pno order by ps.created_at desc) rk
        from my_drds_pro.parcel_sorting_code_info ps
        join t t1 on t1.pno = ps.pno
        where
            ps.created_at > date_sub(curdate(), interval 2 month)
    ) ps on ps.pno = t1.pno and ps.rk = 1
