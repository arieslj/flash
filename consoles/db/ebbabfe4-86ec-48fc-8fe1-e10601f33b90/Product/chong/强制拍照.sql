with t as
    (
        select
            a.pno
            ,a.remark
            ,a.store_id
            ,a.store_name
            ,a.taken_cnt
            ,a.routed_at
            ,coalesce(a.next_routed_at, '2024-07-02 16:00:00') next_routed_time
        from
            (
                select
                    pr.pno
                    ,pr.remark
                    ,pr.store_id
                    ,pr.store_name
                    ,pr.routed_at
                    ,count() over (partition by pr.pno) taken_cnt
                    ,lead(pr.routed_at, 1) over (partition by pr.pno order by pr.routed_at) next_routed_at
                from my_staging.parcel_route pr
                where
                    pr.routed_at > '2024-07-01 16:00:00'
                    and pr.routed_at < '2024-07-02 16:00:00'
                    and pr.route_action = 'FORCE_TAKE_PHOTO'
            ) a
    )
select
    t1.pno
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
    end 当前状态
    ,t1.taken_cnt 包裹今日触发拍照次数
    ,ddd.cn_element 最新触发拍照的节点
    ,if(pr.pno is not null, '是', '否') 本次触发是否已完成拍照
    ,dm.store_name 触发拍照的网点
    ,dm.region_name 触发拍照的网点大区
from t t1
left join my_staging.parcel_info pi on pi.pno = t1.pno
left join my_staging.parcel_route pr on pr.pno = t1.pno and pr.route_action = 'TAKE_PHOTO' and pr.routed_at > '2024-07-01 16:00:00' and pr.routed_at < '2024-07-02 16:00:00' and pr.routed_at > t1.routed_at and pr.routed_at < t1.next_routed_time
left join dwm.dim_my_sys_store_rd dm on dm.store_id = t1.store_id and dm.stat_date = curdate()
left join dwm.dwd_dim_dict ddd on ddd.element = t1.remark and ddd.db = 'my_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'