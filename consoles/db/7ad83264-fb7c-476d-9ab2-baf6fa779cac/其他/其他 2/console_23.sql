
with t as
(
    select
        ssp.pno
        ,ssp.stat_date
        ,ssp.inventory_class
        ,ssp.resp_store_id
        ,ssp.last_valid_action_route_at
        ,ddd2.CN_element
    from ph_bi.should_stocktaking_parcel_info_recently ssp
    left join dwm.dwd_dim_dict ddd2 on ddd2.element = ssp.last_valid_action and  ddd2.db = 'ph_staging' and ddd2.tablename = 'parcel_route'
    where
        ssp.stat_date = curdate()
        and ssp.hour = hour(now())
        and hour(now()) <= 23

    union all

    select
        ssp.pno
        ,ssp.stat_date
        ,ssp.inventory_class
        ,ssp.resp_store_id
        ,ssp.last_valid_action_route_at
        ,ddd2.CN_element
    from ph_bi.should_stocktaking_parcel_info_recently ssp
    left join dwm.dwd_dim_dict ddd2 on ddd2.element = ssp.last_valid_action and  ddd2.db = 'ph_staging' and ddd2.tablename = 'parcel_route'
    where
        ssp.stat_date = date_sub(curdate(), interval 1 day)
        and ssp.hour = 24
        and hour(now()) = 0


)
select
    t1.pno
    ,case t1.inventory_class
        when 1 then '今日应到包裹未入仓'
        when 2 then '历史应到包裹未更新'
        when 3 then '今日应盘留仓件'
        when 4 then '今日应盘问题件'
    end 应盘类型
    ,pi.src_name 寄件人姓名
    ,pi.src_detail_address 寄件人地址
    ,pi.dst_name 收件人姓名
    ,pi.dst_detail_address 收件人地址
    ,pi.dst_phone 收件人电话
    ,pi.dst_home_phone 收件人家庭电话
    ,dp.store_name 当前网点
    ,dp.piece_name 当前片区
    ,dp.region_name 当前大区
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
    ,if(pi.returned = 1, '退件', '正向') 流向
    ,if(de.client_id in ('AA0050','AA0121','AA0139','AA0051','AA0080'), oi.insure_declare_value/100, oi.cogs_amount/100) 正向物品价值
    ,oi.cod_amount/100 COD金额
    ,convert_tz(pi.created_at, '+00:00', '+08:00') 揽收时间
    ,dp2.store_name 揽收网点
    ,dp2.piece_name 揽收片区
    ,dp2.region_name 揽收大区
    ,ss.name 目的地网点
    ,t1.CN_element 最后一条有效路由
    ,t1.last_valid_action_route_at 最后一条有效路由时间
    ,if(pi.state = 1, datediff(now(), convert_tz(pi.created_at, '+00:00', '+08:00')), datediff(now(), de.dst_routed_at)) 在仓天数
    ,de.discard_enabled 是否为丢弃
    ,de.inventorys 盘库次数
    ,convert_tz(pr2.routed_at, '+00:00', '+08:00') 最后一次盘库时间
    ,date(convert_tz(pr2.routed_at, '+00:00', '+08:00')) 最后一次盘库日期
    ,if(pr2.routed_at > date_sub(t1.stat_date, interval 8 hour), '是', '否') 今日是否盘库
    ,if(pr2.routed_at > date_sub(t1.stat_date, interval 8 hour), convert_tz(pr2.routed_at, '+00:00', '+08:00'), null) 今日最后一次盘库时间
from  t t1
left join dwm.dwd_ex_ph_parcel_details de on de.pno = t1.pno
left join ph_staging.parcel_info pi on pi.pno = t1.pno
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = t1.resp_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
left join ph_staging.order_info oi on if(pi.returned = 1, pi.customary_pno, pi.pno) = oi.pno
left join dwm.dim_ph_sys_store_rd dp2 on dp2.store_id = pi.ticket_pickup_store_id and dp2.stat_date = date_sub(curdate(), interval 1 day)
left join ph_staging.sys_store ss on ss.id = pi.dst_store_id
left join
    (
        select
            b.*
        from
            (
                select
                    pr.pno
                    ,pr.routed_at
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
                from ph_staging.parcel_route pr
                join t t1 on t1.pno = pr.pno
                where
                    pr.route_action = 'INVENTORY'
            ) b
        where
            b.rn = 1
    ) pr2 on pr2.pno = t1.pno

;



with t as
(
    select
        ssp.pno
        ,ssp.stat_date
        ,ssp.inventory_class
        ,ssp.resp_store_id
        ,ssp.last_valid_action_route_at
        ,ddd2.CN_element
    from ph_bi.should_stocktaking_parcel_info_recently ssp
    left join dwm.dwd_dim_dict ddd2 on ddd2.element = ssp.last_valid_action and  ddd2.db = 'ph_staging' and ddd2.tablename = 'parcel_route'
    where
        ssp.stat_date = curdate()
        and ssp.hour = hour(now())
        and hour(now()) <= 23

    union all

    select
        ssp.pno
        ,ssp.stat_date
        ,ssp.inventory_class
        ,ssp.resp_store_id
        ,ssp.last_valid_action_route_at
        ,ddd2.CN_element
    from ph_bi.should_stocktaking_parcel_info_recently ssp
    left join dwm.dwd_dim_dict ddd2 on ddd2.element = ssp.last_valid_action and  ddd2.db = 'ph_staging' and ddd2.tablename = 'parcel_route'
    where
        ssp.stat_date = date_sub(curdate(), interval 1 day)
        and ssp.hour = 24
        and hour(now()) = 0


)
select
    t1.pno
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as 客户类型
    ,case t1.inventory_class
        when 1 then '今日应到包裹未入仓'
        when 2 then '历史应到包裹未更新'
        when 3 then '今日应盘留仓件'
        when 4 then '今日应盘问题件'
    end 应盘类型
#     ,pi.src_name 寄件人姓名
#     ,pi.src_detail_address 寄件人地址
#     ,pi.dst_name 收件人姓名
#     ,pi.dst_detail_address 收件人地址
#     ,pi.dst_phone 收件人电话
#     ,pi.dst_home_phone 收件人家庭电话
    ,dp.store_name 当前网点
    ,dp.piece_name 当前片区
    ,dp.region_name 当前大区
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
    ,if(pi.returned = 1, '退件', '正向') 流向
#     ,if(de.client_id in ('AA0050','AA0121','AA0139','AA0051','AA0080'), oi.insure_declare_value/100, oi.cogs_amount/100) 正向物品价值
#     ,oi.cod_amount/100 COD金额
    ,convert_tz(pi.created_at, '+00:00', '+08:00') 揽收时间
    ,dp2.store_name 揽收网点
    ,dp2.piece_name 揽收片区
    ,dp2.region_name 揽收大区
    ,ss.name 目的地网点
    ,t1.CN_element 最后一条有效路由
    ,t1.last_valid_action_route_at 最后一条有效路由时间
    ,if(pi.state = 1, datediff(now(), convert_tz(pi.created_at, '+00:00', '+08:00')), datediff(now(), de.dst_routed_at)) 在仓天数
    ,de.discard_enabled 是否为丢弃
    ,de.inventorys 盘库次数
    ,convert_tz(pr2.routed_at, '+00:00', '+08:00') 最后一次盘库时间
    ,date(convert_tz(pr2.routed_at, '+00:00', '+08:00')) 最后一次盘库日期
    ,if(pr2.routed_at > date_sub(t1.stat_date, interval 8 hour), '是', '否') 今日是否盘库
    ,if(pr2.routed_at > date_sub(t1.stat_date, interval 8 hour), convert_tz(pr2.routed_at, '+00:00', '+08:00'), null) 今日最后一次盘库时间
from  t t1
left join dwm.dwd_ex_ph_parcel_details de on de.pno = t1.pno
left join ph_staging.parcel_info pi on pi.pno = t1.pno and pi.created_at > date_sub(curdate(), interval 2 month)
left join ph_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = t1.resp_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
left join ph_staging.order_info oi on if(pi.returned = 1, pi.customary_pno, pi.pno) = oi.pno and oi.created_at > date_sub(curdate(), interval 2 month)
left join dwm.dim_ph_sys_store_rd dp2 on dp2.store_id = pi.ticket_pickup_store_id and dp2.stat_date = date_sub(curdate(), interval 1 day)
left join ph_staging.sys_store ss on ss.id = pi.dst_store_id
left join
    (
        select
            b.*
        from
            (
                select
                    pr.pno
                    ,pr.routed_at
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
                from ph_staging.parcel_route pr
                join t t1 on t1.pno = pr.pno
                where
                    pr.route_action = 'INVENTORY'
                    and pr.routed_at > date_sub(curdate(), interval 30 day)
            ) b
        where
            b.rn = 1
    ) pr2 on pr2.pno = t1.pno


