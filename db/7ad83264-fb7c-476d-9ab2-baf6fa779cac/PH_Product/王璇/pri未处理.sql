with t as
    (
        select
            ds.store_id
            ,ds.pno
            ,pi.state
            ,date(convert_tz(ppd.created_at, '+00:00', '+08:00')) pri_date
        from ph_bi.dc_should_delivery_today ds
        join ph_staging.parcel_info pi on pi.pno = ds.pno
        left join ph_staging.parcel_priority_delivery_detail ppd on ds.pno = ppd.pno
        where
            ds.is_pri_package = 2

    )
select
    curdate() 日期
    ,dp.region_name 大区
    ,dp.piece_name 片区
    ,dp.store_name 目的网点
    ,count(distinct if(t1.state in (5,7,8,9), t1.pno, null)) / count(distinct t1.pno) PRI包裹处理及时率
    ,count(distinct t1.pno) PRI包裹总量
    ,count(distinct if(t1.state in (1,2,3,4,6), t1.pno, null)) 未终态PRI包裹数量
    ,count(distinct if(t1.state in (1,2,3,4,6) and sc.pno is null, t1.pno, null)) 未交接PRI包裹数量
    ,count(distinct if(t1.state in (1,2,3,4,6) and inv.pno is null, t1.pno, null)) 未盘库PRI包裹数量
    ,count(distinct if(t1.state in (1,2,3,4,6) and datediff(curdate(), t1.pri_date) >= 2, t1.pno, null)) ≥2天PRI包裹数量
    ,count(distinct if(t1.state in (1,2,3,4,6) and prn.pno is not null, t1.pno, null)) 待退件PRI包裹数量
from t t1
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = t1.store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
left join
    (
        select
            pr.pno
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > date_sub(curdate(), interval 8 hour)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        group by 1
    ) sc on t1.pno = sc.pno
left join
    (
        select
            pr.pno
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > date_sub(curdate(), interval 8 hour)
            and pr.route_action = 'INVENTORY'
        group by 1
    ) inv on t1.pno = inv.pno
left join
    (
        select
            pr.pno
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > date_sub(curdate(), interval 2 month )
            and pr.route_action = 'PENDING_RETURN'
        group by 1
    ) prn on t1.pno = prn.pno
group by 1,2,3,4

;

-- 明细

with t as
    (
        select
            ds.store_id
            ,ds.pno
            ,pi.state
            ,pi.returned
            ,ds.client_id
            ,date(convert_tz(ppd.created_at, '+00:00', '+08:00')) pri_date
            ,ppd.basis_type
            ,pi.customary_pno
        from ph_bi.dc_should_delivery_today ds
        join ph_staging.parcel_info pi on pi.pno = ds.pno
        left join ph_staging.parcel_priority_delivery_detail ppd on ds.pno = ppd.pno
        where
            ds.is_pri_package = 2
            and ds.pno in ('P81015WQQ0GAR','P81015WQQ0GAR','PT1820DWWKJ1Z','PT3436DU5S93Z','PT1820DR3GD8Z','PT1820DR3GD8Z','PT1820DR3GD8Z','P81165VQFTSBZ','PT6126DWAY97Z')
    )
select
    curdate() 日期
    ,t1.pno 运单号
    ,dp.region_name 大区
    ,dp.piece_name 片区
    ,dp.store_name 目的网点
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as  客户类型
    ,t1.client_id 客户ID
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
    ,case t1.returned
        when 1 then '已退件'
        when 0 then '未退件'
    end as 包裹流向
    ,convert_tz(sc.routed_at, '+00:00', '+08:00') 当日最后交接时间
    ,convert_tz(inv.routed_at, '+00:00', '+08:00') 当日最后盘库时间
    ,if(prn.pno is not null, '是', '否') 是否有待退件标记
    ,date(convert_tz(prn.routed_at, '+00:00', '+08:00')) 待退件时间
    ,t1.pri_date 成为PRI日期
    ,datediff(curdate(), t1.pri_date) 成为PRI包裹天数
    ,case t1.basis_type
        when 1 then '目的地路由'
        when 2 then '改约时间'
        when 3 then '疑难件时间'
        when 4 then '催单'
        when 5 then 'lazada超时或者临近'
        when 6 then 'shopee超时或者临近'
        when 7 then 'tiktok目的地路由'
        when 8 then 'OTIF当天尝试派送次数不满3次'
        when 9 then '紧急派送包裹'
        when 10 then 'lazada/shopee/tt D7'
        when 11 then 'shein超时或者临近'
        when 12 then 'lazaday临近一派时效'
        when 13 then 'Tiktok 进入pri 临近时效'
        when 14 then 'Shopee 进入pri 临近时效'
        when 15 then 'Lazada  进入pri 临近时效'
        when 16 then 'Shein 进入pri 临近时效'
        when 17 then '包裹在本网点超过X1天且仓管做问题件/留仓件标记的次数<=X2次'
        when 18 then '消费者自费的Speed包裹(parcel_speed_sla,gift_enabled=0)，包裹前一日的当日应派未终态且未打上“丢弃”标记，次日进入PRI表'
        when 19 then '进入pri逻辑 其他通用逻辑（适用于所有客户）'
        when 20 then 'Tiktok、Shopee 进入pri 临近时效'
        when 21 then 'Tiktok、Shopee 进入pri 临近时效逆向'
        when 22 then 'Tiktok跨境 进入pri 无回调'
        when 23 then 'Lazada、Shein按“快件已揽收”日为D0计算，到达X}日，会在X3凌晨跑任务，进入PRI表'
        when 24 then '消费者自费的Speed包裹(parcel_speed_sla,gift_enabled=0)，包裹前一日的当日应派未终态，且未打上“丢弃”标记'
    end as PRI类型
     ,case
        when bc.client_name = 'lazada' then la.delievey_end_date
        when bc.client_name = 'shopee' then sp2.delievey_end_date
        when bc.client_name = 'tiktok' then tt.end_date
    end SLA
    ,case
        when bc.client_name = 'lazada' then la.whole_end_date
        when bc.client_name = 'shopee' then sp.end_date
        when bc.client_name = 'tiktok' then if(t1.returned = 0, tt.end_7_date, tt.end_7_plus_date)
    end 丢失SLA
from t t1
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = t1.store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
left join ph_staging.ka_profile kp on kp.id = t1.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = t1.client_id
left join dwm.dwd_ex_ph_lazada_pno_period la on la.pno = t1.pno
left join dwm.dwd_ex_shopee_lost_pno_period sp on sp.pno = t1.pno
left join dwm.dwd_ex_ph_shopee_sla_detail sp2 on sp2.pno = t1.pno
left join dwm.dwd_ex_ph_tiktok_sla_detail tt on tt.pno = if(t1.returned = 0, t1.pno, t1.customary_pno)
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > date_sub(curdate(), interval 8 hour)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    ) sc on t1.pno = sc.pno and sc.rk = 1
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > date_sub(curdate(), interval 8 hour)
            and pr.route_action = 'INVENTORY'
    ) inv on t1.pno = inv.pno and inv.rk = 1
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > date_sub(curdate(), interval 2 month )
            and pr.route_action = 'PENDING_RETURN'
    ) prn on t1.pno = prn.pno and prn.rk = 1