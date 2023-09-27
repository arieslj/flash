select
    hsi.staff_info_id
    ,hsi.name
    ,hsi.email
from my_bi.hr_staff_info hsi
where
    hsi.staff_info_id in ('131035','87239','54398','32482','131974');
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        plt.pno
        ,plt.updated_at
        ,pi.state
    from my_bi.parcel_lose_task plt
    join my_staging.parcel_info pi on plt.pno = pi.pno
    where
        plt.state = 6
        and plt.duty_result = 1
        and pi.state not in (5,7,8,9)
)
select
    t1.pno
    ,t1.updated_at 判责时间
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
    ,pr.route_time 最后一次有效路由时间
from  t t1
left join
    (
        select
            pr.pno
            ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
            ,row_number() over (partition by pr.pno order by  pr.routed_at desc ) rk
        from my_staging.parcel_route pr
        join t t1 on pr.pno = t1.pno
        where
            pr.route_action in ('DELIVERY_PICKUP_STORE_SCAN','SHIPMENT_WAREHOUSE_SCAN','RECEIVE_WAREHOUSE_SCAN','DIFFICULTY_HANDOVER','ARRIVAL_GOODS_VAN_CHECK_SCAN','FLASH_HOME_SCAN','RECEIVED','SEAL','UNSEAL','DISCARD_RETURN_BKK','REFUND_CONFIRM','ARRIVAL_WAREHOUSE_SCAN','DELIVERY_TRANSFER','DELIVERY_CONFIRM','STORE_KEEPER_UPDATE_WEIGHT','REPLACE_PNO','PICKUP_RETURN_RECEIPT','DETAIN_WAREHOUSE','DELIVERY_MARKER','DISTRIBUTION_INVENTORY','PARCEL_HEADLESS_PRINTED','STORE_SORTER_UPDATE_WEIGHT','SORTING_SCAN','DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE','DELIVERY_TICKET_CREATION_SCAN','INVENTORY','STAFF_INFO_UPDATE_WEIGHT','ACCEPT_PARCEL')
    ) pr on pr.pno = t1.pno and pr.rk = 1
where
    pr.route_time < t1.updated_at;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        plt.pno
    from my_bi.parcel_lose_task plt
    where
        plt.state = 6
        and plt.duty_result = 1
        and plt.updated_at >= '2023-05-01'
        and plt.updated_at < '2023-06-01'
    group by 1
)
select
    count(if(inv.inv_num = 1, inv.pno, null)) `盘库1次`
    ,count(if(inv.inv_num = 2, inv.pno, null)) `盘库2次`
    ,count(if(inv.inv_num = 3, inv.pno, null)) `盘库3次`
    ,count(if(inv.inv_num = 4, inv.pno, null)) `盘库4次`
    ,count(if(inv.inv_num = 5, inv.pno, null)) `盘库5次`
    ,count(if(inv.inv_num = 6, inv.pno, null)) `盘库6次`
    ,count(if(inv.inv_num >= 7, inv.pno, null)) `盘库7次以上`
from t t1
left join
    (
        select
            pr.pno
            ,count(pr.id) inv_num
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'INVENTORY'
        group by 1
    ) inv on inv.pno = t1.pno;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        plt.pno
    from my_bi.parcel_lose_task plt
    where
        plt.state = 6
        and plt.duty_result = 1
        and plt.updated_at >= '2023-05-01'
        and plt.updated_at < '2023-06-01'
    group by 1
)
select
    count(if(inv.inv_num = 1, inv.pno, null)) `改约1次`
    ,count(if(inv.inv_num = 2, inv.pno, null)) `改约2次`
    ,count(if(inv.inv_num = 3, inv.pno, null)) `改约3次`
    ,count(if(inv.inv_num = 4, inv.pno, null)) `改约4次`
    ,count(if(inv.inv_num = 5, inv.pno, null)) `改约5次`
    ,count(if(inv.inv_num = 6, inv.pno, null)) `改约6次`
    ,count(if(inv.inv_num >= 7, inv.pno, null)) `改约7次以上`
from t t1
left join
    (
        select
            pr.pno
            ,count(pr.id) inv_num
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'DELIVERY_MARKER'
            and pr.marker_category in (9,14,70)
        group by 1
    ) inv on inv.pno = t1.pno;
;-- -. . -..- - / . -. - .-. -.--
with  t as
(
select
    plt.pno
    ,plt.id
    ,plt.updated_at
    ,plt.state
    ,plt.penalties
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as  ka_type
from my_bi.parcel_lose_task plt
left join my_staging.ka_profile kp on plt.client_id = kp.id
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = plt.client_id
where
    plt.updated_at >= '2023-05-01'
    and plt.updated_at < '2023-06-01'
    and plt.duty_result = 1
    and plt.state = 6
#     and plt.source = 12
)
select
    b.ka_type 客户分类
    ,count(b.id) 5月判责丢失量
    ,count(if(b.24hour = 'y', b.id, null)) 丢失后24H内找回量
    ,count(if(b.24hour = 'n', b.id, null)) 判责丢失后24H后找回量
from
    (
        select
            t2.*
            ,case
                when timestampdiff(second, t2.updated_at, pr.min_prat)/3600 <= 24 then 'y'
                when timestampdiff(second, t2.updated_at, pr.min_prat)/3600 > 24 then 'n'
                else null
            end 24hour
        from t t2
        left join
            (
                select
                    pr.pno
                    ,min(convert_tz(pr.routed_at, '+00:00', '+07:00')) min_prat
                from my_staging.parcel_route pr
                join t t1 on t1.pno = pr.pno
                join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'rot_pro' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action' and ddd.remark = 'valid'
                where
                    pr.routed_at > date_sub(t1.updated_at, interval 7 hour)
                group by 1
            ) pr on pr.pno = t2.pno
    ) b
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with  t as
(
select
    plt.pno
    ,plt.id
    ,plt.updated_at
    ,plt.state
    ,plt.penalties
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as  ka_type
from my_bi.parcel_lose_task plt
left join my_staging.ka_profile kp on plt.client_id = kp.id
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = plt.client_id
where
    plt.updated_at >= '2023-05-01'
    and plt.updated_at < '2023-06-01'
    and plt.duty_result = 1
    and plt.state = 6
#     and plt.source = 12
)
select
    b.ka_type 客户分类
    ,count(b.id) 5月判责丢失量
    ,count(if(b.24hour = 'y', b.id, null)) 丢失后24H内找回量
    ,count(if(b.24hour = 'n', b.id, null)) 判责丢失后24H后找回量
from
    (
        select
            t2.*
            ,case
                when timestampdiff(second, t2.updated_at, pr.min_prat)/3600 <= 24 then 'y'
                when timestampdiff(second, t2.updated_at, pr.min_prat)/3600 > 24 then 'n'
                else null
            end 24hour
        from t t2
        left join
            (
                select
                    pr.pno
                    ,min(convert_tz(pr.routed_at, '+00:00', '+08:00')) min_prat
                from my_staging.parcel_route pr
                join t t1 on t1.pno = pr.pno
                join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'rot_pro' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action' and ddd.remark = 'valid'
                where
                    pr.routed_at > date_sub(t1.updated_at, interval 8 hour)
                group by 1
            ) pr on pr.pno = t2.pno
    ) b
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with  t as
(
select
    plt.pno
    ,plt.id
    ,plt.updated_at
    ,plt.state
    ,plt.penalties
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as  ka_type
from my_bi.parcel_lose_task plt
left join my_staging.ka_profile kp on plt.client_id = kp.id
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = plt.client_id
where
    plt.updated_at >= '2023-05-01'
    and plt.updated_at < '2023-06-01'
    and plt.duty_result = 1
    and plt.state = 6
#     and plt.source = 12
)
select
    b.ka_type 客户分类
    ,count(b.id) 5月判责丢失量
    ,count(if(b.24hour = 'y', b.id, null)) 丢失后24H内找回量
    ,count(if(b.24hour = 'n', b.id, null)) 判责丢失后24H后找回量
from
    (
        select
            t2.*
            ,case
                when timestampdiff(second, t2.updated_at, pr.min_prat)/3600 <= 24 then 'y'
                when timestampdiff(second, t2.updated_at, pr.min_prat)/3600 > 24 then 'n'
                else null
            end 24hour
        from t t2
        left join
            (
                select
                    pr.pno
                    ,min(convert_tz(pr.routed_at, '+00:00', '+08:00')) min_prat
                from my_staging.parcel_route pr
                join t t1 on t1.pno = pr.pno
                join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'my_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action' and ddd.remark = 'valid'
                where
                    pr.routed_at > date_sub(t1.updated_at, interval 8 hour)
                group by 1
            ) pr on pr.pno = t2.pno
    ) b
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
    from my_bi.dc_should_delivery_today ds
    where
        ds.stat_date >= '2023-07-04'
        and ds.stat_date <= '2023-07-04'
)

select
    a.stat_date 日期
    ,a.store_id 网点ID
    ,ss.name 网点名称
    ,smr.name 大区
    ,smp.name 片区
    ,a.应交接
    ,a.已交接
    ,concat(round(a.交接率*100,2),'%') as 交接率
    ,concat(ifnull(a.a_check,''), ifnull(a.b_check,''), ifnull(a.d_check,''), ifnull(a.e_check,''),if(a.a_check is null  and a.d_check is null and a.b_check is null and a.e_check is null, 'C', '')) 交接评级
    ,concat(round(a.A_rate * 100,2),'%')  'A时段（<0930 ）'
    ,concat(round(a.B_rate * 100,2),'%') 'B时段（0930<=X<1200）'
    ,concat(round(a.C_rate * 100,2),'%')'C时段（1200<=X<1600 ）'
    ,concat(round(a.D_rate * 100,2),'%')'D时段（>=1600）'
from
    (
        select
            t1.store_id
            ,t1.stat_date
            ,count(t1.pno) 应交接
            ,count(if(sc.pno is not null , t1.pno, null)) 已交接
            ,count(if(sc.pno is not null , t1.pno, null))/count(t1.pno) 交接率
            ,count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as A_rate
            ,count(if(time(sc.route_time) >= '09:30:00' and time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as B_rate
            ,count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as C_rate
            ,count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as D_rate

            ,if(count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.95, 'A', null ) a_check
            ,if(count(if(time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.98 and count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) <= 0.95, 'B', null ) b_check
            ,if(count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03, 'D', null ) d_check
            ,if(count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03 , 'E', null ) e_check
        from t t1
        left join
            (
                select
                    sc.*
                from
                    (
                        select
                            pr.pno
                            ,pr.store_id
                            ,pr.store_name
                            ,t1.stat_date
                            ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                            ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                            ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
                        from my_staging.parcel_route pr
                        join t t1 on t1.pno = pr.pno
                        where
                            pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                           and pr.routed_at >= date_sub(t1.stat_date, interval 8 hour)
                          and pr.routed_at < date_add(t1.stat_date, interval 16 hour )
                    ) sc
                where
                    sc.rk = 1
            ) sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
        group by 1,2
    ) a
left join my_staging.sys_store ss on ss.id = a.store_id
left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
where
    ss.category = 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
    from my_bi.dc_should_delivery_today ds
    where
        ds.stat_date >= '2023-07-05'
        and ds.stat_date <= '2023-07-05'
        and ds.arrival_scan_route_at < concat(ds.stat_date, ' 09:00:00')
)

select
    a.stat_date 日期
    ,a.store_id 网点ID
    ,ss.name 网点名称
    ,smr.name 大区
    ,smp.name 片区
    ,a.应交接
    ,a.已交接
    ,concat(round(a.交接率*100,2),'%') as 交接率
    ,concat(ifnull(a.a_check,''), ifnull(a.b_check,''), ifnull(a.d_check,''), ifnull(a.e_check,''),if(a.a_check is null  and a.d_check is null and a.b_check is null and a.e_check is null, 'C', '')) 交接评级
    ,concat(round(a.A_rate * 100,2),'%')  'A时段（<0930 ）'
    ,concat(round(a.B_rate * 100,2),'%') 'B时段（0930<=X<1200）'
    ,concat(round(a.C_rate * 100,2),'%')'C时段（1200<=X<1600 ）'
    ,concat(round(a.D_rate * 100,2),'%')'D时段（>=1600）'
from
    (
        select
            t1.store_id
            ,t1.stat_date
            ,count(t1.pno) 应交接
            ,count(if(sc.pno is not null , t1.pno, null)) 已交接
            ,count(if(sc.pno is not null , t1.pno, null))/count(t1.pno) 交接率
            ,count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as A_rate
            ,count(if(time(sc.route_time) >= '09:30:00' and time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as B_rate
            ,count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as C_rate
            ,count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as D_rate

            ,if(count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.95, 'A', null ) a_check
            ,if(count(if(time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.98 and count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) <= 0.95, 'B', null ) b_check
            ,if(count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03, 'D', null ) d_check
            ,if(count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03 , 'E', null ) e_check
        from t t1
        left join
            (
                select
                    sc.*
                from
                    (
                        select
                            pr.pno
                            ,pr.store_id
                            ,pr.store_name
                            ,t1.stat_date
                            ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                            ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                            ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
                        from my_staging.parcel_route pr
                        join t t1 on t1.pno = pr.pno
                        where
                            pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                           and pr.routed_at >= date_sub(t1.stat_date, interval 8 hour)
                          and pr.routed_at < date_add(t1.stat_date, interval 16 hour )
                    ) sc
                where
                    sc.rk = 1
            ) sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
        group by 1,2
    ) a
left join my_staging.sys_store ss on ss.id = a.store_id
left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
where
    ss.category = 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
    from my_bi.dc_should_delivery_today ds
    where
        ds.stat_date >= '2023-07-06'
        and ds.stat_date <= '2023-07-06'
        and ds.arrival_scan_route_at < concat(ds.stat_date, ' 09:00:00')
)

select
    a.stat_date 日期
    ,a.store_id 网点ID
    ,ss.name 网点名称
    ,smr.name 大区
    ,smp.name 片区
    ,a.应交接
    ,a.已交接
    ,concat(round(a.交接率*100,2),'%') as 交接率
    ,concat(ifnull(a.a_check,''), ifnull(a.b_check,''), ifnull(a.d_check,''), ifnull(a.e_check,''),if(a.a_check is null  and a.d_check is null and a.b_check is null and a.e_check is null, 'C', '')) 交接评级
    ,concat(round(a.A_rate * 100,2),'%')  'A时段（<0930 ）'
    ,concat(round(a.B_rate * 100,2),'%') 'B时段（0930<=X<1200）'
    ,concat(round(a.C_rate * 100,2),'%')'C时段（1200<=X<1600 ）'
    ,concat(round(a.D_rate * 100,2),'%')'D时段（>=1600）'
from
    (
        select
            t1.store_id
            ,t1.stat_date
            ,count(t1.pno) 应交接
            ,count(if(sc.pno is not null , t1.pno, null)) 已交接
            ,count(if(sc.pno is not null , t1.pno, null))/count(t1.pno) 交接率
            ,count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as A_rate
            ,count(if(time(sc.route_time) >= '09:30:00' and time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as B_rate
            ,count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as C_rate
            ,count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as D_rate

            ,if(count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.95, 'A', null ) a_check
            ,if(count(if(time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.98 and count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) <= 0.95, 'B', null ) b_check
            ,if(count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03, 'D', null ) d_check
            ,if(count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03 , 'E', null ) e_check
        from t t1
        left join
            (
                select
                    sc.*
                from
                    (
                        select
                            pr.pno
                            ,pr.store_id
                            ,pr.store_name
                            ,t1.stat_date
                            ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                            ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                            ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
                        from my_staging.parcel_route pr
                        join t t1 on t1.pno = pr.pno
                        where
                            pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                           and pr.routed_at >= date_sub(t1.stat_date, interval 8 hour)
                          and pr.routed_at < date_add(t1.stat_date, interval 16 hour )
                    ) sc
                where
                    sc.rk = 1
            ) sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
        group by 1,2
    ) a
left join my_staging.sys_store ss on ss.id = a.store_id
left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
where
    ss.category = 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
        ,ds.arrival_scan_route_at
    from my_bi.dc_should_delivery_today ds
    where
        ds.stat_date >= '2023-07-06'
        and ds.stat_date <= '2023-07-06'
        and ds.arrival_scan_route_at < concat(ds.stat_date, ' 09:00:00')
)

        select
            t1.*
            ,sc.route_time 第一次交接时间
        from t t1
        left join
            (
                select
                    sc.*
                from
                    (
                        select
                            pr.pno
                            ,pr.store_id
                            ,pr.store_name
                            ,t1.stat_date
                            ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                            ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                            ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
                        from my_staging.parcel_route pr
                        join t t1 on t1.pno = pr.pno
                        where
                            pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                           and pr.routed_at >= date_sub(t1.stat_date, interval 8 hour)
                          and pr.routed_at < date_add(t1.stat_date, interval 16 hour )
                    ) sc
                where
                    sc.rk = 1
            ) sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
        ,ds.arrival_scan_route_at
    from my_bi.dc_should_delivery_today ds
    where
        ds.stat_date >= '2023-07-06'
        and ds.stat_date <= '2023-07-06'
        and ds.arrival_scan_route_at < concat(ds.stat_date, ' 09:00:00')
)

        select
            t1.*
            ,ss.name
            ,sc.route_time 第一次交接时间
        from t t1
        left join
            (
                select
                    sc.*
                from
                    (
                        select
                            pr.pno
                            ,pr.store_id
                            ,pr.store_name
                            ,t1.stat_date
                            ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                            ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                            ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
                        from my_staging.parcel_route pr
                        join t t1 on t1.pno = pr.pno
                        where
                            pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                           and pr.routed_at >= date_sub(t1.stat_date, interval 8 hour)
                          and pr.routed_at < date_add(t1.stat_date, interval 16 hour )
                    ) sc
                where
                    sc.rk = 1
            ) sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
left join my_staging.sys_store ss on ss.id = t1.store_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
        ,ds.arrival_scan_route_at
    from my_bi.dc_should_delivery_today ds
    where
        ds.stat_date >= '2023-07-06'
        and ds.stat_date <= '2023-07-06'
        and ds.arrival_scan_route_at < concat(ds.stat_date, ' 09:00:00')
)

select
    a.stat_date 日期
    ,a.store_id 网点ID
    ,ss.name 网点名称
    ,smr.name 大区
    ,smp.name 片区
    ,a.应交接
    ,a.已交接
    ,concat(round(a.交接率*100,2),'%') as 交接率
    ,concat(ifnull(a.a_check,''), ifnull(a.b_check,''), ifnull(a.d_check,''), ifnull(a.e_check,''),if(a.a_check is null  and a.d_check is null and a.b_check is null and a.e_check is null, 'C', '')) 交接评级
    ,concat(round(a.A_rate * 100,2),'%')  'A时段（<0930 ）'
    ,concat(round(a.B_rate * 100,2),'%') 'B时段（0930<=X<1200）'
    ,concat(round(a.C_rate * 100,2),'%')'C时段（1200<=X<1600 ）'
    ,concat(round(a.D_rate * 100,2),'%')'D时段（>=1600）'
from
    (
        select
            t1.store_id
            ,t1.stat_date
            ,count(t1.pno) 应交接
            ,count(if(sc.pno is not null , t1.pno, null)) 已交接
            ,count(if(sc.pno is not null , t1.pno, null))/count(t1.pno) 交接率
            ,count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as A_rate
            ,count(if(time(sc.route_time) >= '09:30:00' and time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as B_rate
            ,count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as C_rate
            ,count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as D_rate

            ,if(count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.95, 'A', null ) a_check
            ,if(count(if(time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.98 and count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) <= 0.95, 'B', null ) b_check
            ,if(count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03, 'D', null ) d_check
            ,if(count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03 , 'E', null ) e_check
        from t t1
        left join
            (
                select
                    sc.*
                from
                    (
                        select
                            pr.pno
                            ,pr.store_id
                            ,pr.store_name
                            ,t1.stat_date
                            ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                            ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                            ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
                        from my_staging.parcel_route pr
                        join t t1 on t1.pno = pr.pno
                        where
                            pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                           and pr.routed_at >= date_sub(t1.stat_date, interval 8 hour)
                          and pr.routed_at < date_add(t1.stat_date, interval 16 hour )
                    ) sc
                where
                    sc.rk = 1
            ) sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
        group by 1,2
    ) a
left join my_staging.sys_store ss on ss.id = a.store_id
left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
where
    ss.category = 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
        ,ds.arrival_scan_route_at
    from my_bi.dc_should_delivery_today ds
    where
        ds.stat_date >= '2023-07-07'
        and ds.stat_date <= '2023-07-07'
        and ds.arrival_scan_route_at < concat(ds.stat_date, ' 09:00:00')
)

select
    a.stat_date 日期
    ,a.store_id 网点ID
    ,ss.name 网点名称
    ,smr.name 大区
    ,smp.name 片区
    ,a.应交接
    ,a.已交接
    ,concat(round(a.交接率*100,2),'%') as 交接率
    ,concat(ifnull(a.a_check,''), ifnull(a.b_check,''), ifnull(a.d_check,''), ifnull(a.e_check,''),if(a.a_check is null  and a.d_check is null and a.b_check is null and a.e_check is null, 'C', '')) 交接评级
    ,concat(round(a.A_rate * 100,2),'%')  'A时段（<0930 ）'
    ,concat(round(a.B_rate * 100,2),'%') 'B时段（0930<=X<1200）'
    ,concat(round(a.C_rate * 100,2),'%')'C时段（1200<=X<1600 ）'
    ,concat(round(a.D_rate * 100,2),'%')'D时段（>=1600）'
from
    (
        select
            t1.store_id
            ,t1.stat_date
            ,count(t1.pno) 应交接
            ,count(if(sc.pno is not null , t1.pno, null)) 已交接
            ,count(if(sc.pno is not null , t1.pno, null))/count(t1.pno) 交接率
            ,count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as A_rate
            ,count(if(time(sc.route_time) >= '09:30:00' and time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as B_rate
            ,count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as C_rate
            ,count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as D_rate

            ,if(count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.95, 'A', null ) a_check
            ,if(count(if(time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.98 and count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) <= 0.95, 'B', null ) b_check
            ,if(count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03, 'D', null ) d_check
            ,if(count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03 , 'E', null ) e_check
        from t t1
        left join
            (
                select
                    sc.*
                from
                    (
                        select
                            pr.pno
                            ,pr.store_id
                            ,pr.store_name
                            ,t1.stat_date
                            ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                            ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                            ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
                        from my_staging.parcel_route pr
                        join t t1 on t1.pno = pr.pno
                        where
                            pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                           and pr.routed_at >= date_sub(t1.stat_date, interval 8 hour)
                          and pr.routed_at < date_add(t1.stat_date, interval 16 hour )
                    ) sc
                where
                    sc.rk = 1
            ) sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
        group by 1,2
    ) a
left join my_staging.sys_store ss on ss.id = a.store_id
left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
where
    ss.category = 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
        ,ds.arrival_scan_route_at
    from my_bi.dc_should_delivery_today ds
    where
        ds.stat_date >= '2023-07-07'
        and ds.stat_date <= '2023-07-07'
        and ds.arrival_scan_route_at < concat(ds.stat_date, ' 09:00:00')
)

select
    a.日期
    ,a.大区
    ,a.交接评级
    ,count(a.网点ID) 网点数
from
    (
        select
            a.stat_date 日期
            ,a.store_id 网点ID
            ,ss.name 网点名称
            ,smr.name 大区
            ,smp.name 片区
            ,a.应交接
            ,a.已交接
            ,concat(round(a.交接率*100,2),'%') as 交接率
            ,concat(ifnull(a.a_check,''), ifnull(a.b_check,''), ifnull(a.d_check,''), ifnull(a.e_check,''),if(a.a_check is null  and a.d_check is null and a.b_check is null and a.e_check is null, 'C', '')) 交接评级
            ,concat(round(a.A_rate * 100,2),'%')  'A时段（<0930 ）'
            ,concat(round(a.B_rate * 100,2),'%') 'B时段（0930<=X<1200）'
            ,concat(round(a.C_rate * 100,2),'%')'C时段（1200<=X<1600 ）'
            ,concat(round(a.D_rate * 100,2),'%')'D时段（>=1600）'
        from
            (
                select
                    t1.store_id
                    ,t1.stat_date
                    ,count(t1.pno) 应交接
                    ,count(if(sc.pno is not null , t1.pno, null)) 已交接
                    ,count(if(sc.pno is not null , t1.pno, null))/count(t1.pno) 交接率
                    ,count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as A_rate
                    ,count(if(time(sc.route_time) >= '09:30:00' and time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as B_rate
                    ,count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as C_rate
                    ,count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as D_rate

                    ,if(count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.95, 'A', null ) a_check
                    ,if(count(if(time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.98 and count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) <= 0.95, 'B', null ) b_check
                    ,if(count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03, 'D', null ) d_check
                    ,if(count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03 , 'E', null ) e_check
                from t t1
                left join
                    (
                        select
                            sc.*
                        from
                            (
                                select
                                    pr.pno
                                    ,pr.store_id
                                    ,pr.store_name
                                    ,t1.stat_date
                                    ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                                    ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                                    ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
                                from my_staging.parcel_route pr
                                join t t1 on t1.pno = pr.pno
                                where
                                    pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                                   and pr.routed_at >= date_sub(t1.stat_date, interval 8 hour)
                                  and pr.routed_at < date_add(t1.stat_date, interval 16 hour )
                            ) sc
                        where
                            sc.rk = 1
                    ) sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
                group by 1,2
            ) a
        left join my_staging.sys_store ss on ss.id = a.store_id
        left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
        left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
        where
            ss.category = 1
    ) a
group by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
        ,ds.arrival_scan_route_at
    from my_bi.dc_should_delivery_today ds
    where
        ds.stat_date >= '2023-07-06'
        and ds.stat_date <= '2023-07-06'
        and ds.arrival_scan_route_at < concat(ds.stat_date, ' 09:00:00')
)

select
    a.日期
    ,a.大区
    ,a.交接评级
    ,count(a.网点ID) 网点数
from
    (
        select
            a.stat_date 日期
            ,a.store_id 网点ID
            ,ss.name 网点名称
            ,smr.name 大区
            ,smp.name 片区
            ,a.应交接
            ,a.已交接
            ,concat(round(a.交接率*100,2),'%') as 交接率
            ,concat(ifnull(a.a_check,''), ifnull(a.b_check,''), ifnull(a.d_check,''), ifnull(a.e_check,''),if(a.a_check is null  and a.d_check is null and a.b_check is null and a.e_check is null, 'C', '')) 交接评级
            ,concat(round(a.A_rate * 100,2),'%')  'A时段（<0930 ）'
            ,concat(round(a.B_rate * 100,2),'%') 'B时段（0930<=X<1200）'
            ,concat(round(a.C_rate * 100,2),'%')'C时段（1200<=X<1600 ）'
            ,concat(round(a.D_rate * 100,2),'%')'D时段（>=1600）'
        from
            (
                select
                    t1.store_id
                    ,t1.stat_date
                    ,count(t1.pno) 应交接
                    ,count(if(sc.pno is not null , t1.pno, null)) 已交接
                    ,count(if(sc.pno is not null , t1.pno, null))/count(t1.pno) 交接率

                    ,count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as A_rate
                    ,count(if(time(sc.route_time) >= '09:30:00' and time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as B_rate
                    ,count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as C_rate
                    ,count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as D_rate

                    ,if(count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.95, 'A', null ) a_check
                    ,if(count(if(time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.98 and count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) <= 0.95, 'B', null ) b_check
                    ,if(count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03, 'D', null ) d_check
                    ,if(count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03 , 'E', null ) e_check
                from t t1
                left join
                    (
                        select
                            sc.*
                        from
                            (
                                select
                                    pr.pno
                                    ,pr.store_id
                                    ,pr.store_name
                                    ,t1.stat_date
                                    ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                                    ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                                    ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
                                from my_staging.parcel_route pr
                                join t t1 on t1.pno = pr.pno
                                where
                                    pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                                   and pr.routed_at >= date_sub(t1.stat_date, interval 8 hour)
                                  and pr.routed_at < date_add(t1.stat_date, interval 16 hour )
                            ) sc
                        where
                            sc.rk = 1
                    ) sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
                group by 1,2
            ) a
        left join my_staging.sys_store ss on ss.id = a.store_id
        left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
        left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
        where
            ss.category = 1
    ) a
group by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
        ,ds.arrival_scan_route_at
    from my_bi.dc_should_delivery_today ds
    where
        ds.stat_date >= '2023-07-06'
        and ds.stat_date <= '2023-07-06'
        and ds.arrival_scan_route_at < concat(ds.stat_date, ' 09:00:00')
)
,b as
(
    select
        a.stat_date 日期
        ,a.store_id 网点ID
        ,ss.name 网点名称
        ,smr.name 大区
        ,smp.name 片区
        ,a.应交接
        ,a.已交接
        ,concat(round(a.交接率*100,2),'%') as 交接率
        ,concat(ifnull(a.a_check,''), ifnull(a.b_check,''), ifnull(a.d_check,''), ifnull(a.e_check,''),if(a.a_check is null  and a.d_check is null and a.b_check is null and a.e_check is null, 'C', '')) 交接评级
        ,concat(round(a.A_rate * 100,2),'%')  'A时段（<0930 ）'
        ,concat(round(a.B_rate * 100,2),'%') 'B时段（0930<=X<1200）'
        ,concat(round(a.C_rate * 100,2),'%')'C时段（1200<=X<1600 ）'
        ,concat(round(a.D_rate * 100,2),'%')'D时段（>=1600）'
    from
        (
            select
                t1.store_id
                ,t1.stat_date
                ,count(t1.pno) 应交接
                ,count(if(sc.pno is not null , t1.pno, null)) 已交接
                ,count(if(sc.pno is not null , t1.pno, null))/count(t1.pno) 交接率

                ,count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as A_rate
                ,count(if(time(sc.route_time) >= '09:30:00' and time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as B_rate
                ,count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as C_rate
                ,count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as D_rate

                ,if(count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.95, 'A', null ) a_check
                ,if(count(if(time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.98 and count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) <= 0.95, 'B', null ) b_check
                ,if(count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03, 'D', null ) d_check
                ,if(count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03 , 'E', null ) e_check
            from t t1
            left join
                (
                    select
                        sc.*
                    from
                        (
                            select
                                pr.pno
                                ,pr.store_id
                                ,pr.store_name
                                ,t1.stat_date
                                ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                                ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                                ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
                            from my_staging.parcel_route pr
                            join t t1 on t1.pno = pr.pno
                            where
                                pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                               and pr.routed_at >= date_sub(t1.stat_date, interval 8 hour)
                              and pr.routed_at < date_add(t1.stat_date, interval 16 hour )
                        ) sc
                    where
                        sc.rk = 1
                ) sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
            group by 1,2
        ) a
    left join my_staging.sys_store ss on ss.id = a.store_id
    left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
    left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
    where
        ss.category = 1
)
select
    t1.日期
    ,t1.大区
    ,t1.交接评级
    ,t1.store_num 网点数
    ,t1.store_num/t2.store_num 网点占比
from
    (
        select
            b1.日期
            ,b1.大区
            ,b1.交接评级
            ,count(b1.网点ID) store_num
        from b b1
        group by 1,2,3
    ) t1
left join
    (
        select
            b1.日期
            ,b1.大区
            ,count(b1.网点ID) store_num
        from b b1
        group by 1,2
    ) t2 on t2.日期 = t1.日期 and t2.大区 = t1.大区;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
        ,ds.arrival_scan_route_at
    from my_bi.dc_should_delivery_today ds
    where
        ds.stat_date >= '2023-07-06'
        and ds.stat_date <= '2023-07-06'
        and ds.arrival_scan_route_at < concat(ds.stat_date, ' 09:00:00')
)
,b as
(
    select
        a.stat_date 日期
        ,a.store_id 网点ID
        ,ss.name 网点名称
        ,smr.name 大区
        ,smp.name 片区
        ,a.应交接
        ,a.已交接
        ,concat(round(a.交接率*100,2),'%') as 交接率
        ,concat(ifnull(a.a_check,''), ifnull(a.b_check,''), ifnull(a.d_check,''), ifnull(a.e_check,''),if(a.a_check is null  and a.d_check is null and a.b_check is null and a.e_check is null, 'C', '')) 交接评级
        ,concat(round(a.A_rate * 100,2),'%')  'A时段（<0930 ）'
        ,concat(round(a.B_rate * 100,2),'%') 'B时段（0930<=X<1200）'
        ,concat(round(a.C_rate * 100,2),'%')'C时段（1200<=X<1600 ）'
        ,concat(round(a.D_rate * 100,2),'%')'D时段（>=1600）'
    from
        (
            select
                t1.store_id
                ,t1.stat_date
                ,count(t1.pno) 应交接
                ,count(if(sc.pno is not null , t1.pno, null)) 已交接
                ,count(if(sc.pno is not null , t1.pno, null))/count(t1.pno) 交接率

                ,count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as A_rate
                ,count(if(time(sc.route_time) >= '09:30:00' and time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as B_rate
                ,count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as C_rate
                ,count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as D_rate

                ,if(count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.95, 'A', null ) a_check
                ,if(count(if(time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.98 and count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) <= 0.95, 'B', null ) b_check
                ,if(count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03, 'D', null ) d_check
                ,if(count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03 , 'E', null ) e_check
            from t t1
            left join
                (
                    select
                        sc.*
                    from
                        (
                            select
                                pr.pno
                                ,pr.store_id
                                ,pr.store_name
                                ,t1.stat_date
                                ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                                ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                                ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
                            from my_staging.parcel_route pr
                            join t t1 on t1.pno = pr.pno
                            where
                                pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                               and pr.routed_at >= date_sub(t1.stat_date, interval 8 hour)
                              and pr.routed_at < date_add(t1.stat_date, interval 16 hour )
                        ) sc
                    where
                        sc.rk = 1
                ) sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
            group by 1,2
        ) a
    left join my_staging.sys_store ss on ss.id = a.store_id
    left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
    left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
    where
        ss.category = 1
)

        select
            b1.日期
            ,b1.大区
            ,count(if(b1.交接评级 regexp 'C|D|E', b1.网点ID, null)) CDE网点数
        from b b1
        group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
        ,ds.arrival_scan_route_at
    from my_bi.dc_should_delivery_today ds
    where
        ds.stat_date >= '2023-07-06'
        and ds.stat_date <= '2023-07-06'
        and ds.arrival_scan_route_at < concat(ds.stat_date, ' 09:00:00')
)
,b as
(
    select
        a.stat_date 日期
        ,a.store_id 网点ID
        ,ss.name 网点名称
        ,smr.name 大区
        ,smp.name 片区
        ,a.应交接
        ,a.已交接
        ,concat(round(a.交接率*100,2),'%') as 交接率
        ,concat(ifnull(a.a_check,''), ifnull(a.b_check,''), ifnull(a.d_check,''), ifnull(a.e_check,''),if(a.a_check is null  and a.d_check is null and a.b_check is null and a.e_check is null, 'C', '')) 交接评级
        ,concat(round(a.A_rate * 100,2),'%')  'A时段（<0930 ）'
        ,concat(round(a.B_rate * 100,2),'%') 'B时段（0930<=X<1200）'
        ,concat(round(a.C_rate * 100,2),'%')'C时段（1200<=X<1600 ）'
        ,concat(round(a.D_rate * 100,2),'%')'D时段（>=1600）'
    from
        (
            select
                t1.store_id
                ,t1.stat_date
                ,count(t1.pno) 应交接
                ,count(if(sc.pno is not null , t1.pno, null)) 已交接
                ,count(if(sc.pno is not null , t1.pno, null))/count(t1.pno) 交接率

                ,count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as A_rate
                ,count(if(time(sc.route_time) >= '09:30:00' and time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as B_rate
                ,count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as C_rate
                ,count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as D_rate

                ,if(count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.95, 'A', null ) a_check
                ,if(count(if(time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.98 and count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) <= 0.95, 'B', null ) b_check
                ,if(count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03, 'D', null ) d_check
                ,if(count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03 , 'E', null ) e_check
            from t t1
            left join
                (
                    select
                        sc.*
                    from
                        (
                            select
                                pr.pno
                                ,pr.store_id
                                ,pr.store_name
                                ,t1.stat_date
                                ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                                ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                                ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
                            from my_staging.parcel_route pr
                            join t t1 on t1.pno = pr.pno
                            where
                                pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                               and pr.routed_at >= date_sub(t1.stat_date, interval 8 hour)
                              and pr.routed_at < date_add(t1.stat_date, interval 16 hour )
                        ) sc
                    where
                        sc.rk = 1
                ) sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
            group by 1,2
        ) a
    left join my_staging.sys_store ss on ss.id = a.store_id
    left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
    left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
    where
        ss.category = 1
)
select
    t1.日期
    ,t1.交接评级
    ,t1.store_num 网点数
    ,t1.store_num/t2.store_num 网点占比
from
    (
        select
            b1.日期
            ,b1.交接评级
            ,count(b1.网点ID) store_num
        from b b1
        group by 1,2,3
    ) t1
left join
    (
        select
            b1.日期
            ,count(b1.网点ID) store_num
        from b b1
        group by 1,2
    ) t2 on t2.日期 = t1.日期;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
        ,ds.arrival_scan_route_at
    from my_bi.dc_should_delivery_today ds
    where
        ds.stat_date >= '2023-07-06'
        and ds.stat_date <= '2023-07-06'
        and ds.arrival_scan_route_at < concat(ds.stat_date, ' 09:00:00')
)
,b as
(
    select
        a.stat_date 日期
        ,a.store_id 网点ID
        ,ss.name 网点名称
        ,smr.name 大区
        ,smp.name 片区
        ,a.应交接
        ,a.已交接
        ,concat(round(a.交接率*100,2),'%') as 交接率
        ,concat(ifnull(a.a_check,''), ifnull(a.b_check,''), ifnull(a.d_check,''), ifnull(a.e_check,''),if(a.a_check is null  and a.d_check is null and a.b_check is null and a.e_check is null, 'C', '')) 交接评级
        ,concat(round(a.A_rate * 100,2),'%')  'A时段（<0930 ）'
        ,concat(round(a.B_rate * 100,2),'%') 'B时段（0930<=X<1200）'
        ,concat(round(a.C_rate * 100,2),'%')'C时段（1200<=X<1600 ）'
        ,concat(round(a.D_rate * 100,2),'%')'D时段（>=1600）'
    from
        (
            select
                t1.store_id
                ,t1.stat_date
                ,count(t1.pno) 应交接
                ,count(if(sc.pno is not null , t1.pno, null)) 已交接
                ,count(if(sc.pno is not null , t1.pno, null))/count(t1.pno) 交接率

                ,count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as A_rate
                ,count(if(time(sc.route_time) >= '09:30:00' and time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as B_rate
                ,count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as C_rate
                ,count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as D_rate

                ,if(count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.95, 'A', null ) a_check
                ,if(count(if(time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.98 and count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) <= 0.95, 'B', null ) b_check
                ,if(count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03, 'D', null ) d_check
                ,if(count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03 , 'E', null ) e_check
            from t t1
            left join
                (
                    select
                        sc.*
                    from
                        (
                            select
                                pr.pno
                                ,pr.store_id
                                ,pr.store_name
                                ,t1.stat_date
                                ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                                ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                                ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
                            from my_staging.parcel_route pr
                            join t t1 on t1.pno = pr.pno
                            where
                                pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                               and pr.routed_at >= date_sub(t1.stat_date, interval 8 hour)
                              and pr.routed_at < date_add(t1.stat_date, interval 16 hour )
                        ) sc
                    where
                        sc.rk = 1
                ) sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
            group by 1,2
        ) a
    left join my_staging.sys_store ss on ss.id = a.store_id
    left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
    left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
    where
        ss.category = 1
)
select
    t1.日期
    ,t1.交接评级
    ,t1.store_num 网点数
    ,t1.store_num/t2.store_num 网点占比
from
    (
        select
            b1.日期
            ,b1.交接评级
            ,count(b1.网点ID) store_num
        from b b1
        group by 1,2,3
    ) t1
left join
    (
        select
            b1.日期
            ,count(b1.网点ID) store_num
        from b b1
        group by 1
    ) t2 on t2.日期 = t1.日期;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
        ,ds.arrival_scan_route_at
    from my_bi.dc_should_delivery_today ds
    where
        ds.stat_date >= '2023-07-06'
        and ds.stat_date <= '2023-07-06'
        and ds.arrival_scan_route_at < concat(ds.stat_date, ' 09:00:00')
)
,b as
(
    select
        a.stat_date 日期
        ,a.store_id 网点ID
        ,ss.name 网点名称
        ,smr.name 大区
        ,smp.name 片区
        ,a.应交接
        ,a.已交接
        ,concat(round(a.交接率*100,2),'%') as 交接率
        ,concat(ifnull(a.a_check,''), ifnull(a.b_check,''), ifnull(a.d_check,''), ifnull(a.e_check,''),if(a.a_check is null  and a.d_check is null and a.b_check is null and a.e_check is null, 'C', '')) 交接评级
        ,concat(round(a.A_rate * 100,2),'%')  'A时段（<0930 ）'
        ,concat(round(a.B_rate * 100,2),'%') 'B时段（0930<=X<1200）'
        ,concat(round(a.C_rate * 100,2),'%')'C时段（1200<=X<1600 ）'
        ,concat(round(a.D_rate * 100,2),'%')'D时段（>=1600）'
    from
        (
            select
                t1.store_id
                ,t1.stat_date
                ,count(t1.pno) 应交接
                ,count(if(sc.pno is not null , t1.pno, null)) 已交接
                ,count(if(sc.pno is not null , t1.pno, null))/count(t1.pno) 交接率

                ,count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as A_rate
                ,count(if(time(sc.route_time) >= '09:30:00' and time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as B_rate
                ,count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as C_rate
                ,count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as D_rate

                ,if(count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.95, 'A', null ) a_check
                ,if(count(if(time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.98 and count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) <= 0.95, 'B', null ) b_check
                ,if(count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03, 'D', null ) d_check
                ,if(count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03 , 'E', null ) e_check
            from t t1
            left join
                (
                    select
                        sc.*
                    from
                        (
                            select
                                pr.pno
                                ,pr.store_id
                                ,pr.store_name
                                ,t1.stat_date
                                ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                                ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                                ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
                            from my_staging.parcel_route pr
                            join t t1 on t1.pno = pr.pno
                            where
                                pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                               and pr.routed_at >= date_sub(t1.stat_date, interval 8 hour)
                              and pr.routed_at < date_add(t1.stat_date, interval 16 hour )
                        ) sc
                    where
                        sc.rk = 1
                ) sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
            group by 1,2
        ) a
    left join my_staging.sys_store ss on ss.id = a.store_id
    left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
    left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
    where
        ss.category = 1
)
select
    t1.日期
    ,t1.交接评级
    ,t1.store_num 网点数
    ,t1.store_num/t2.store_num 网点占比
from
    (
        select
            b1.日期
            ,b1.交接评级
            ,count(b1.网点ID) store_num
        from b b1
        group by 1,2
    ) t1
left join
    (
        select
            b1.日期
            ,count(b1.网点ID) store_num
        from b b1
        group by 1
    ) t2 on t2.日期 = t1.日期;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
        ,ds.arrival_scan_route_at
    from my_bi.dc_should_delivery_today ds
    where
        ds.stat_date >= '2023-07-06'
        and ds.stat_date <= '2023-07-06'
        and ds.arrival_scan_route_at < concat(ds.stat_date, ' 09:00:00')
)
,b as
(
    select
        a.stat_date 日期
        ,a.store_id 网点ID
        ,ss.name 网点名称
        ,smr.name 大区
        ,smp.name 片区
        ,a.应交接
        ,a.已交接
        ,concat(round(a.交接率*100,2),'%') as 交接率
        ,concat(ifnull(a.a_check,''), ifnull(a.b_check,''), ifnull(a.d_check,''), ifnull(a.e_check,''),if(a.a_check is null  and a.d_check is null and a.b_check is null and a.e_check is null, 'C', '')) 交接评级
        ,concat(round(a.A_rate * 100,2),'%')  'A时段（<0930 ）'
        ,concat(round(a.B_rate * 100,2),'%') 'B时段（0930<=X<1200）'
        ,concat(round(a.C_rate * 100,2),'%')'C时段（1200<=X<1600 ）'
        ,concat(round(a.D_rate * 100,2),'%')'D时段（>=1600）'
    from
        (
            select
                t1.store_id
                ,t1.stat_date
                ,count(t1.pno) 应交接
                ,count(if(sc.pno is not null , t1.pno, null)) 已交接
                ,count(if(sc.pno is not null , t1.pno, null))/count(t1.pno) 交接率

                ,count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as A_rate
                ,count(if(time(sc.route_time) >= '09:30:00' and time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as B_rate
                ,count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as C_rate
                ,count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as D_rate

                ,if(count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.95, 'A', null ) a_check
                ,if(count(if(time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.98 and count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) <= 0.95, 'B', null ) b_check
                ,if(count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03, 'D', null ) d_check
                ,if(count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03 , 'E', null ) e_check
            from t t1
            left join
                (
                    select
                        sc.*
                    from
                        (
                            select
                                pr.pno
                                ,pr.store_id
                                ,pr.store_name
                                ,t1.stat_date
                                ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                                ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                                ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
                            from my_staging.parcel_route pr
                            join t t1 on t1.pno = pr.pno
                            where
                                pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                               and pr.routed_at >= date_sub(t1.stat_date, interval 8 hour)
                              and pr.routed_at < date_add(t1.stat_date, interval 16 hour )
                        ) sc
                    where
                        sc.rk = 1
                ) sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
            group by 1,2
        ) a
    left join my_staging.sys_store ss on ss.id = a.store_id
    left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
    left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
    where
        ss.category = 1
)

select
    b1.日期
    ,b1.大区
    ,count(if(b1.交接评级 regexp 'C|D|E', b1.网点ID, null))/count(b1.网点ID)  CDE网点占比
from b b1
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
        a.stat_date 日期
        ,a.store_id 网点ID
        ,ss.name 网点名称
        ,smr.name 大区
        ,smp.name 片区
        ,a.应交接
        ,a.已交接
        ,concat(round(a.交接率*100,2),'%') as 交接率
        ,concat(ifnull(a.a_check,''), ifnull(a.b_check,''), ifnull(a.d_check,''), ifnull(a.e_check,''),if(a.a_check is null  and a.d_check is null and a.b_check is null and a.e_check is null, 'C', '')) 交接评级
        ,concat(round(a.A_rate * 100,2),'%')  'A时段（<0930 ）'
        ,concat(round(a.B_rate * 100,2),'%') 'B时段（0930<=X<1200）'
        ,concat(round(a.C_rate * 100,2),'%')'C时段（1200<=X<1600 ）'
        ,concat(round(a.D_rate * 100,2),'%')'D时段（>=1600）'
    from
        (
            select
                t1.store_id
                ,t1.stat_date
                ,count(t1.pno) 应交接
                ,count(if(sc.pno is not null , t1.pno, null)) 已交接
                ,count(if(sc.pno is not null , t1.pno, null))/count(t1.pno) 交接率

                ,count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as A_rate
                ,count(if(time(sc.route_time) >= '09:30:00' and time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as B_rate
                ,count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as C_rate
                ,count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as D_rate

                ,if(count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.95, 'A', null ) a_check
                ,if(count(if(time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.98 and count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) <= 0.95, 'B', null ) b_check
                ,if(count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03, 'D', null ) d_check
                ,if(count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03 , 'E', null ) e_check
            from t t1
            left join
                (
                    select
                        sc.*
                    from
                        (
                            select
                                pr.pno
                                ,pr.store_id
                                ,pr.store_name
                                ,t1.stat_date
                                ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                                ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                                ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
                            from my_staging.parcel_route pr
                            join t t1 on t1.pno = pr.pno
                            where
                                pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                               and pr.routed_at >= date_sub(t1.stat_date, interval 8 hour)
                              and pr.routed_at < date_add(t1.stat_date, interval 16 hour )
                        ) sc
                    where
                        sc.rk = 1
                ) sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
            group by 1,2
        ) a
    left join my_staging.sys_store ss on ss.id = a.store_id
    left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
    left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
    where
        ss.category = 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
        ,ds.arrival_scan_route_at
    from my_bi.dc_should_delivery_today ds
    where
        ds.stat_date >= '2023-07-06'
        and ds.stat_date <= '2023-07-06'
        and ds.arrival_scan_route_at < concat(ds.stat_date, ' 09:00:00')
)
,b as
(
    select
        a.stat_date 日期
        ,a.store_id 网点ID
        ,ss.name 网点名称
        ,smr.name 大区
        ,smp.name 片区
        ,a.应交接
        ,a.已交接
        ,concat(round(a.交接率*100,2),'%') as 交接率
        ,concat(ifnull(a.a_check,''), ifnull(a.b_check,''), ifnull(a.d_check,''), ifnull(a.e_check,''),if(a.a_check is null  and a.d_check is null and a.b_check is null and a.e_check is null, 'C', '')) 交接评级
        ,concat(round(a.A_rate * 100,2),'%')  'A时段（<0930 ）'
        ,concat(round(a.B_rate * 100,2),'%') 'B时段（0930<=X<1200）'
        ,concat(round(a.C_rate * 100,2),'%')'C时段（1200<=X<1600 ）'
        ,concat(round(a.D_rate * 100,2),'%')'D时段（>=1600）'
    from
        (
            select
                t1.store_id
                ,t1.stat_date
                ,count(t1.pno) 应交接
                ,count(if(sc.pno is not null , t1.pno, null)) 已交接
                ,count(if(sc.pno is not null , t1.pno, null))/count(t1.pno) 交接率

                ,count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as A_rate
                ,count(if(time(sc.route_time) >= '09:30:00' and time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as B_rate
                ,count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as C_rate
                ,count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as D_rate

                ,if(count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.95, 'A', null ) a_check
                ,if(count(if(time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.98 and count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) <= 0.95, 'B', null ) b_check
                ,if(count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03, 'D', null ) d_check
                ,if(count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03 , 'E', null ) e_check
            from t t1
            left join
                (
                    select
                        sc.*
                    from
                        (
                            select
                                pr.pno
                                ,pr.store_id
                                ,pr.store_name
                                ,t1.stat_date
                                ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                                ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                                ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
                            from my_staging.parcel_route pr
                            join t t1 on t1.pno = pr.pno
                            where
                                pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                               and pr.routed_at >= date_sub(t1.stat_date, interval 8 hour)
                              and pr.routed_at < date_add(t1.stat_date, interval 16 hour )
                        ) sc
                    where
                        sc.rk = 1
                ) sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
            group by 1,2
        ) a
    left join my_staging.sys_store ss on ss.id = a.store_id
    left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
    left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
    where
        ss.category = 1
)

select
    b1.日期
    ,count(if(b1.交接评级 regexp 'C|D|E', b1.网点ID, null))/count(b1.网点ID)  CDE网点占比
from b b1
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
        ,ds.arrival_scan_route_at
    from my_bi.dc_should_delivery_today ds
    where
        ds.stat_date >= '2023-07-06'
        and ds.stat_date <= '2023-07-06'
        and ds.arrival_scan_route_at < concat(ds.stat_date, ' 09:00:00')
)
# ,b as
# (
    select
        a.stat_date 日期
        ,a.store_id 网点ID
        ,ss.name 网点名称
        ,smr.name 大区
        ,smp.name 片区
        ,a.应交接
        ,a.已交接
        ,concat(round(a.交接率*100,2),'%') as 交接率
        ,concat(ifnull(a.a_check,''), ifnull(a.b_check,''), ifnull(a.d_check,''), ifnull(a.e_check,''),if(a.a_check is null  and a.d_check is null and a.b_check is null and a.e_check is null, 'C', '')) 交接评级
        ,concat(round(a.A_rate * 100,2),'%')  'A时段（<0930 ）'
        ,concat(round(a.B_rate * 100,2),'%') 'B时段（0930<=X<1200）'
        ,concat(round(a.C_rate * 100,2),'%')'C时段（1200<=X<1600 ）'
        ,concat(round(a.D_rate * 100,2),'%')'D时段（>=1600）'
    from
        (
            select
                t1.store_id
                ,t1.stat_date
                ,count(t1.pno) 应交接
                ,count(if(sc.pno is not null , t1.pno, null)) 已交接
                ,count(if(sc.pno is not null , t1.pno, null))/count(t1.pno) 交接率

                ,count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as A_rate
                ,count(if(time(sc.route_time) >= '09:30:00' and time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as B_rate
                ,count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as C_rate
                ,count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as D_rate

                ,if(count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.95, 'A', null ) a_check
                ,if(count(if(time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.98 and count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) <= 0.95, 'B', null ) b_check
                ,if(count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03, 'D', null ) d_check
                ,if(count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03 , 'E', null ) e_check
            from t t1
            left join
                (
                    select
                        sc.*
                    from
                        (
                            select
                                pr.pno
                                ,pr.store_id
                                ,pr.store_name
                                ,t1.stat_date
                                ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                                ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                                ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
                            from my_staging.parcel_route pr
                            join t t1 on t1.pno = pr.pno
                            where
                                pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                               and pr.routed_at >= date_sub(t1.stat_date, interval 8 hour)
                              and pr.routed_at < date_add(t1.stat_date, interval 16 hour )
                        ) sc
                    where
                        sc.rk = 1
                ) sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
            group by 1,2
        ) a
    left join my_staging.sys_store ss on ss.id = a.store_id
    left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
    left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
    where
        ss.category = 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
        ,ds.arrival_scan_route_at
    from my_bi.dc_should_delivery_today ds
    where
        ds.stat_date >= '2023-07-07'
        and ds.stat_date <= '2023-07-07'
        and ds.arrival_scan_route_at < concat(ds.stat_date, ' 09:00:00')
)

        select
            t1.*
            ,ss.name
            ,sc.route_time 第一次交接时间
        from t t1
        left join
            (
                select
                    sc.*
                from
                    (
                        select
                            pr.pno
                            ,pr.store_id
                            ,pr.store_name
                            ,t1.stat_date
                            ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                            ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                            ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
                        from my_staging.parcel_route pr
                        join t t1 on t1.pno = pr.pno
                        where
                            pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                           and pr.routed_at >= date_sub(t1.stat_date, interval 8 hour)
                          and pr.routed_at < date_add(t1.stat_date, interval 16 hour )
                    ) sc
                where
                    sc.rk = 1
            ) sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
left join my_staging.sys_store ss on ss.id = t1.store_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
        ,ds.arrival_scan_route_at
    from my_bi.dc_should_delivery_today ds
    where
        ds.stat_date >= '2023-07-07'
        and ds.stat_date <= '2023-07-07'
        and ds.arrival_scan_route_at < concat(ds.stat_date, ' 09:00:00')
)
# ,b as
# (
    select
        a.stat_date 日期
        ,a.store_id 网点ID
        ,ss.name 网点名称
        ,smr.name 大区
        ,smp.name 片区
        ,a.应交接
        ,a.已交接
        ,concat(round(a.交接率*100,2),'%') as 交接率
        ,concat(ifnull(a.a_check,''), ifnull(a.b_check,''), ifnull(a.d_check,''), ifnull(a.e_check,''),if(a.a_check is null  and a.d_check is null and a.b_check is null and a.e_check is null, 'C', '')) 交接评级
        ,concat(round(a.A_rate * 100,2),'%')  'A时段（<0930 ）'
        ,concat(round(a.B_rate * 100,2),'%') 'B时段（0930<=X<1200）'
        ,concat(round(a.C_rate * 100,2),'%')'C时段（1200<=X<1600 ）'
        ,concat(round(a.D_rate * 100,2),'%')'D时段（>=1600）'
    from
        (
            select
                t1.store_id
                ,t1.stat_date
                ,count(t1.pno) 应交接
                ,count(if(sc.pno is not null , t1.pno, null)) 已交接
                ,count(if(sc.pno is not null , t1.pno, null))/count(t1.pno) 交接率

                ,count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as A_rate
                ,count(if(time(sc.route_time) >= '09:30:00' and time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as B_rate
                ,count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as C_rate
                ,count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as D_rate

                ,if(count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.95, 'A', null ) a_check
                ,if(count(if(time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.98 and count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) <= 0.95, 'B', null ) b_check
                ,if(count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03, 'D', null ) d_check
                ,if(count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03 , 'E', null ) e_check
            from t t1
            left join
                (
                    select
                        sc.*
                    from
                        (
                            select
                                pr.pno
                                ,pr.store_id
                                ,pr.store_name
                                ,t1.stat_date
                                ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                                ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                                ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
                            from my_staging.parcel_route pr
                            join t t1 on t1.pno = pr.pno
                            where
                                pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                               and pr.routed_at >= date_sub(t1.stat_date, interval 8 hour)
                              and pr.routed_at < date_add(t1.stat_date, interval 16 hour )
                        ) sc
                    where
                        sc.rk = 1
                ) sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
            group by 1,2
        ) a
    left join my_staging.sys_store ss on ss.id = a.store_id
    left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
    left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
    where
        ss.category = 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
        ,ds.arrival_scan_route_at
    from my_bi.dc_should_delivery_today ds
    where
        ds.stat_date >= '2023-07-07'
        and ds.stat_date <= '2023-07-07'
        and ds.arrival_scan_route_at < concat(ds.stat_date, ' 10:00:00')
)
# ,b as
# (
    select
        a.stat_date 日期
        ,a.store_id 网点ID
        ,ss.name 网点名称
        ,smr.name 大区
        ,smp.name 片区
        ,a.应交接
        ,a.已交接
        ,concat(round(a.交接率*100,2),'%') as 交接率
        ,concat(ifnull(a.a_check,''), ifnull(a.b_check,''), ifnull(a.d_check,''), ifnull(a.e_check,''),if(a.a_check is null  and a.d_check is null and a.b_check is null and a.e_check is null, 'C', '')) 交接评级
        ,concat(round(a.A_rate * 100,2),'%')  'A时段（<0930 ）'
        ,concat(round(a.B_rate * 100,2),'%') 'B时段（0930<=X<1200）'
        ,concat(round(a.C_rate * 100,2),'%')'C时段（1200<=X<1600 ）'
        ,concat(round(a.D_rate * 100,2),'%')'D时段（>=1600）'
    from
        (
            select
                t1.store_id
                ,t1.stat_date
                ,count(t1.pno) 应交接
                ,count(if(sc.pno is not null , t1.pno, null)) 已交接
                ,count(if(sc.pno is not null , t1.pno, null))/count(t1.pno) 交接率

                ,count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as A_rate
                ,count(if(time(sc.route_time) >= '09:30:00' and time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as B_rate
                ,count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as C_rate
                ,count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as D_rate

                ,if(count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.95, 'A', null ) a_check
                ,if(count(if(time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.98 and count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) <= 0.95, 'B', null ) b_check
                ,if(count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03, 'D', null ) d_check
                ,if(count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03 , 'E', null ) e_check
            from t t1
            left join
                (
                    select
                        sc.*
                    from
                        (
                            select
                                pr.pno
                                ,pr.store_id
                                ,pr.store_name
                                ,t1.stat_date
                                ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                                ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                                ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
                            from my_staging.parcel_route pr
                            join t t1 on t1.pno = pr.pno
                            where
                                pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                               and pr.routed_at >= date_sub(t1.stat_date, interval 8 hour)
                              and pr.routed_at < date_add(t1.stat_date, interval 16 hour )
                        ) sc
                    where
                        sc.rk = 1
                ) sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
            group by 1,2
        ) a
    left join my_staging.sys_store ss on ss.id = a.store_id
    left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
    left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
    where
        ss.category = 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
        ,ds.arrival_scan_route_at
    from my_bi.dc_should_delivery_today ds
    where
        ds.stat_date >= '2023-07-08'
        and ds.stat_date <= '2023-07-08'
        and ds.arrival_scan_route_at < concat(ds.stat_date, ' 10:00:00')
)
# ,b as
# (
    select
        a.stat_date 日期
        ,a.store_id 网点ID
        ,ss.name 网点名称
        ,smr.name 大区
        ,smp.name 片区
        ,a.应交接
        ,a.已交接
        ,concat(round(a.交接率*100,2),'%') as 交接率
        ,concat(ifnull(a.a_check,''), ifnull(a.b_check,''), ifnull(a.d_check,''), ifnull(a.e_check,''),if(a.a_check is null  and a.d_check is null and a.b_check is null and a.e_check is null, 'C', '')) 交接评级
        ,concat(round(a.A_rate * 100,2),'%')  'A时段（<0930 ）'
        ,concat(round(a.B_rate * 100,2),'%') 'B时段（0930<=X<1200）'
        ,concat(round(a.C_rate * 100,2),'%')'C时段（1200<=X<1600 ）'
        ,concat(round(a.D_rate * 100,2),'%')'D时段（>=1600）'
    from
        (
            select
                t1.store_id
                ,t1.stat_date
                ,count(t1.pno) 应交接
                ,count(if(sc.pno is not null , t1.pno, null)) 已交接
                ,count(if(sc.pno is not null , t1.pno, null))/count(t1.pno) 交接率

                ,count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as A_rate
                ,count(if(time(sc.route_time) >= '09:30:00' and time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as B_rate
                ,count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as C_rate
                ,count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as D_rate

                ,if(count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.95, 'A', null ) a_check
                ,if(count(if(time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.98 and count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) <= 0.95, 'B', null ) b_check
                ,if(count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03, 'D', null ) d_check
                ,if(count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03 , 'E', null ) e_check
            from t t1
            left join
                (
                    select
                        sc.*
                    from
                        (
                            select
                                pr.pno
                                ,pr.store_id
                                ,pr.store_name
                                ,t1.stat_date
                                ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                                ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                                ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
                            from my_staging.parcel_route pr
                            join t t1 on t1.pno = pr.pno
                            where
                                pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                               and pr.routed_at >= date_sub(t1.stat_date, interval 8 hour)
                              and pr.routed_at < date_add(t1.stat_date, interval 16 hour )
                        ) sc
                    where
                        sc.rk = 1
                ) sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
            group by 1,2
        ) a
    left join my_staging.sys_store ss on ss.id = a.store_id
    left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
    left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
    where
        ss.category = 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
        ,ds.arrival_scan_route_at
    from my_bi.dc_should_delivery_today ds
    where
        ds.stat_date >= '2023-07-08'
        and ds.stat_date <= '2023-07-08'
        and ds.arrival_scan_route_at < concat(ds.stat_date, ' 09:00:00')
)

        select
            t1.*
            ,ss.name
            ,sc.route_time 第一次交接时间
        from t t1
        left join
            (
                select
                    sc.*
                from
                    (
                        select
                            pr.pno
                            ,pr.store_id
                            ,pr.store_name
                            ,t1.stat_date
                            ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                            ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                            ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
                        from my_staging.parcel_route pr
                        join t t1 on t1.pno = pr.pno
                        where
                            pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                           and pr.routed_at >= date_sub(t1.stat_date, interval 8 hour)
                          and pr.routed_at < date_add(t1.stat_date, interval 16 hour )
                    ) sc
                where
                    sc.rk = 1
            ) sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
left join my_staging.sys_store ss on ss.id = t1.store_id
where
    sc.route_time is not null;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
        ,ds.arrival_scan_route_at
    from my_bi.dc_should_delivery_today ds
    where
        ds.stat_date >= '2023-07-08'
        and ds.stat_date <= '2023-07-08'
        and ds.arrival_scan_route_at < concat(ds.stat_date, ' 10:00:00')
)
,b as
(
    select
        a.stat_date 日期
        ,a.store_id 网点ID
        ,ss.name 网点名称
        ,ss.opening_at 开业日期
        ,smr.name 大区
        ,smp.name 片区
        ,a.应交接
        ,a.已交接
        ,concat(round(a.交接率*100,2),'%') as 交接率
        ,concat(ifnull(a.a_check,''), ifnull(a.b_check,''), ifnull(a.d_check,''), ifnull(a.e_check,''),if(a.a_check is null  and a.d_check is null and a.b_check is null and a.e_check is null, 'C', '')) 交接评级
        ,concat(round(a.A_rate * 100,2),'%')  'A时段（<0930 ）'
        ,concat(round(a.B_rate * 100,2),'%') 'B时段（0930<=X<1200）'
        ,concat(round(a.C_rate * 100,2),'%')'C时段（1200<=X<1600 ）'
        ,concat(round(a.D_rate * 100,2),'%')'D时段（>=1600）'
    from
        (
            select
                t1.store_id
                ,t1.stat_date
                ,count(t1.pno) 应交接
                ,count(if(sc.pno is not null , t1.pno, null)) 已交接
                ,count(if(sc.pno is not null , t1.pno, null))/count(t1.pno) 交接率

                ,count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as A_rate
                ,count(if(time(sc.route_time) >= '09:30:00' and time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as B_rate
                ,count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as C_rate
                ,count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as D_rate

                ,if(count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.95, 'A', null ) a_check
                ,if(count(if(time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.98 and count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) <= 0.95, 'B', null ) b_check
                ,if(count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03, 'D', null ) d_check
                ,if(count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03 , 'E', null ) e_check
            from t t1
            left join
                (
                    select
                        sc.*
                    from
                        (
                            select
                                pr.pno
                                ,pr.store_id
                                ,pr.store_name
                                ,t1.stat_date
                                ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                                ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                                ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
                            from my_staging.parcel_route pr
                            join t t1 on t1.pno = pr.pno
                            where
                                pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                               and pr.routed_at >= date_sub(t1.stat_date, interval 8 hour)
                              and pr.routed_at < date_add(t1.stat_date, interval 16 hour )
                        ) sc
                    where
                        sc.rk = 1
                ) sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
            group by 1,2
        ) a
    left join my_staging.sys_store ss on ss.id = a.store_id
    left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
    left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
    where
        ss.category = 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
        ,ds.arrival_scan_route_at
    from my_bi.dc_should_delivery_today ds
    where
        ds.stat_date >= '2023-07-08'
        and ds.stat_date <= '2023-07-08'
        and ds.arrival_scan_route_at < concat(ds.stat_date, ' 09:00:00')
)
# ,b as
# (
    select
        a.stat_date 日期
        ,a.store_id 网点ID
        ,ss.name 网点名称
        ,ss.opening_at 开业日期
        ,smr.name 大区
        ,smp.name 片区
        ,a.应交接
        ,a.已交接
        ,concat(round(a.交接率*100,2),'%') as 交接率
        ,concat(ifnull(a.a_check,''), ifnull(a.b_check,''), ifnull(a.d_check,''), ifnull(a.e_check,''),if(a.a_check is null  and a.d_check is null and a.b_check is null and a.e_check is null, 'C', '')) 交接评级
        ,concat(round(a.A_rate * 100,2),'%')  'A时段（<0930 ）'
        ,concat(round(a.B_rate * 100,2),'%') 'B时段（0930<=X<1200）'
        ,concat(round(a.C_rate * 100,2),'%')'C时段（1200<=X<1600 ）'
        ,concat(round(a.D_rate * 100,2),'%')'D时段（>=1600）'
    from
        (
            select
                t1.store_id
                ,t1.stat_date
                ,count(t1.pno) 应交接
                ,count(if(sc.pno is not null , t1.pno, null)) 已交接
                ,count(if(sc.pno is not null , t1.pno, null))/count(t1.pno) 交接率

                ,count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as A_rate
                ,count(if(time(sc.route_time) >= '09:30:00' and time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as B_rate
                ,count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as C_rate
                ,count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as D_rate

                ,if(count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.95, 'A', null ) a_check
                ,if(count(if(time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.98 and count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) <= 0.95, 'B', null ) b_check
                ,if(count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03, 'D', null ) d_check
                ,if(count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03 , 'E', null ) e_check
            from t t1
            left join
                (
                    select
                        sc.*
                    from
                        (
                            select
                                pr.pno
                                ,pr.store_id
                                ,pr.store_name
                                ,t1.stat_date
                                ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                                ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                                ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
                            from my_staging.parcel_route pr
                            join t t1 on t1.pno = pr.pno
                            where
                                pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                               and pr.routed_at >= date_sub(t1.stat_date, interval 8 hour)
                              and pr.routed_at < date_add(t1.stat_date, interval 16 hour )
                        ) sc
                    where
                        sc.rk = 1
                ) sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
            group by 1,2
        ) a
    left join my_staging.sys_store ss on ss.id = a.store_id
    left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
    left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
    where
        ss.category = 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
        ,ds.arrival_scan_route_at
    from my_bi.dc_should_delivery_today ds
    where
        ds.stat_date >= '2023-07-08'
        and ds.stat_date <= '2023-07-08'
        and ds.arrival_scan_route_at < concat(ds.stat_date, ' 09:00:00')
)
# ,b as
# (
    select
        a.stat_date 日期
        ,a.store_id 网点ID
        ,ss.name 网点名称
        ,ss.opening_at 开业日期
        ,smr.name 大区
        ,smp.name 片区
        ,a.应交接
        ,a.已交接
        ,concat(round(a.交接率*100,2),'%') as 交接率
        ,concat(ifnull(a.a_check,''), ifnull(a.b_check,''), ifnull(a.d_check,''), ifnull(a.e_check,''),if(a.a_check is null  and a.d_check is null and a.b_check is null and a.e_check is null, 'C', '')) 交接评级
        ,concat(round(a.A_rate * 100,2),'%')  'A时段（<0930 ）'
        ,concat(round(a.B_rate * 100,2),'%') 'B时段（0930<=X<1200）'
        ,concat(round(a.C_rate * 100,2),'%')'C时段（1200<=X<1600 ）'
        ,concat(round(a.D_rate * 100,2),'%')'D时段（>=1600）'
    from
        (
            select
                t1.store_id
                ,t1.stat_date
                ,count(t1.pno) 应交接
                ,count(if(sc.pno is not null , t1.pno, null)) 已交接
                ,count(if(sc.pno is not null , t1.pno, null))/count(t1.pno) 交接率

                ,count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as A_rate
                ,count(if(time(sc.route_time) >= '09:30:00' and time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as B_rate
                ,count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as C_rate
                ,count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as D_rate

                ,if(count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.95, 'A', null ) a_check
                ,if(count(if(time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.98 and count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) <= 0.95, 'B', null ) b_check
                ,if(count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03, 'D', null ) d_check
                ,if(count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03 , 'E', null ) e_check
            from t t1
            left join
                (
                    select
                        sc.*
                    from
                        (
                            select
                                pr.pno
                                ,pr.store_id
                                ,pr.store_name
                                ,t1.stat_date
                                ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                                ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                                ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
                            from my_staging.parcel_route pr
                            join t t1 on t1.pno = pr.pno
                            where
                                pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                               and pr.routed_at >= date_sub(t1.stat_date, interval 8 hour)
                              and pr.routed_at < date_add(t1.stat_date, interval 16 hour )
                        ) sc
                    where
                        sc.rk = 1
                ) sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
            group by 1,2
        ) a
    join
        (
            select
                sd.store_id
            from my_staging.sys_district sd
            where
                sd.deleted = 0
                and sd.store_id is not null
            group by 1

            union all

            select
                sd.separation_store_id store_id
            from my_staging.sys_district sd
            where
                sd.deleted = 0
                and sd.separation_store_id is not null
            group by 1
        ) sd on sd.store_id = a.store_id
    left join my_staging.sys_store ss on ss.id = a.store_id
    left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
    left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
    where
        ss.category = 1;
;-- -. . -..- - / . -. - .-. -.--
select
                sd.store_id
            from my_staging.sys_district sd
            where
                sd.deleted = 0
                and sd.store_id is not null
            group by 1

            union all

            select
                sd.separation_store_id store_id
            from my_staging.sys_district sd
            where
                sd.deleted = 0
                and sd.separation_store_id is not null
            group by 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
        ,ds.arrival_scan_route_at
    from my_bi.dc_should_delivery_today ds
    where
        ds.stat_date >= '2023-07-08'
        and ds.stat_date <= '2023-07-08'
        and ds.arrival_scan_route_at < concat(ds.stat_date, ' 09:00:00')
)
# ,b as
# (
    select
        a.stat_date 日期
        ,a.store_id 网点ID
        ,ss.name 网点名称
        ,ss.opening_at 开业日期
        ,smr.name 大区
        ,smp.name 片区
        ,a.应交接
        ,a.已交接
        ,concat(round(a.交接率*100,2),'%') as 交接率
        ,concat(ifnull(a.a_check,''), ifnull(a.b_check,''), ifnull(a.d_check,''), ifnull(a.e_check,''),if(a.a_check is null  and a.d_check is null and a.b_check is null and a.e_check is null, 'C', '')) 交接评级
        ,concat(round(a.A_rate * 100,2),'%')  'A时段（<0930 ）'
        ,concat(round(a.B_rate * 100,2),'%') 'B时段（0930<=X<1200）'
        ,concat(round(a.C_rate * 100,2),'%')'C时段（1200<=X<1600 ）'
        ,concat(round(a.D_rate * 100,2),'%')'D时段（>=1600）'
    from
        (
            select
                t1.store_id
                ,t1.stat_date
                ,count(t1.pno) 应交接
                ,count(if(sc.pno is not null , t1.pno, null)) 已交接
                ,count(if(sc.pno is not null , t1.pno, null))/count(t1.pno) 交接率

                ,count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as A_rate
                ,count(if(time(sc.route_time) >= '09:30:00' and time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as B_rate
                ,count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as C_rate
                ,count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as D_rate

                ,if(count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.95, 'A', null ) a_check
                ,if(count(if(time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.98 and count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) <= 0.95, 'B', null ) b_check
                ,if(count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03, 'D', null ) d_check
                ,if(count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03 , 'E', null ) e_check
            from t t1
            left join
                (
                    select
                        sc.*
                    from
                        (
                            select
                                pr.pno
                                ,pr.store_id
                                ,pr.store_name
                                ,t1.stat_date
                                ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                                ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                                ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
                            from my_staging.parcel_route pr
                            join t t1 on t1.pno = pr.pno
                            where
                                pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                               and pr.routed_at >= date_sub(t1.stat_date, interval 8 hour)
                              and pr.routed_at < date_add(t1.stat_date, interval 16 hour )
                        ) sc
                    where
                        sc.rk = 1
                ) sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
            group by 1,2
        ) a
#     join
#         (
#             select
#                 sd.store_id
#             from my_staging.sys_district sd
#             where
#                 sd.deleted = 0
#                 and sd.store_id is not null
#             group by 1
#
#             union all
#
#             select
#                 sd.separation_store_id store_id
#             from my_staging.sys_district sd
#             where
#                 sd.deleted = 0
#                 and sd.separation_store_id is not null
#             group by 1
#         ) sd on sd.store_id = a.store_id
    left join my_staging.sys_store ss on ss.id = a.store_id
    left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
    left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
    where
        ss.category = 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
        ,ds.arrival_scan_route_at
    from my_bi.dc_should_delivery_today ds
    where
        ds.stat_date >= '2023-07-08'
        and ds.stat_date <= '2023-07-08'
        and ds.arrival_scan_route_at < concat(ds.stat_date, ' 09:00:00')
)

        select
            t1.*
            ,ss.name
            ,sc.route_time 第一次交接时间
        from t t1
        left join
            (
                select
                    sc.*
                from
                    (
                        select
                            pr.pno
                            ,pr.store_id
                            ,pr.store_name
                            ,t1.stat_date
                            ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                            ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                            ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
                        from my_staging.parcel_route pr
                        join t t1 on t1.pno = pr.pno
                        where
                            pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                           and pr.routed_at >= date_sub(t1.stat_date, interval 8 hour)
                          and pr.routed_at < date_add(t1.stat_date, interval 16 hour )
                    ) sc
                where
                    sc.rk = 1
            ) sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
left join my_staging.sys_store ss on ss.id = t1.store_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
         ds.store_id 网点ID
        ,ds.pno 
        ,ds.stat_date 日期
        ,ds.arrival_scan_route_at 到达网点时间
    from my_bi.dc_should_delivery_today ds
    where
        ds.stat_date >= '2023-07-08'
        and ds.stat_date <= '2023-07-08'
        and ds.arrival_scan_route_at < concat(ds.stat_date, ' 09:00:00')
)

        select
            t1.*
            ,ss.name 网点名称
            ,sc.route_time 第一次交接时间
        from t t1
        left join
            (
                select
                    sc.*
                from
                    (
                        select
                            pr.pno
                            ,pr.store_id
                            ,pr.store_name
                            ,t1.日期
                            ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                            ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                            ,row_number() over (partition by pr.pno,t1.日期 order by pr.routed_at) rk
                        from my_staging.parcel_route pr
                        join t t1 on t1.pno = pr.pno
                        where
                            pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                           and pr.routed_at >= date_sub(t1.日期, interval 8 hour)
                          and pr.routed_at < date_add(t1.日期, interval 16 hour )
                    ) sc
                where
                    sc.rk = 1
            ) sc on sc.pno = t1.pno and t1.日期 = sc.stat_date
left join my_staging.sys_store ss on ss.id = t1.网点ID
where
    ss.id not in ('MY04040316','MY04040315','MY04070217');
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
         ds.store_id 网点ID
        ,ds.pno
        ,ds.stat_date 日期
        ,ds.arrival_scan_route_at 到达网点时间
    from my_bi.dc_should_delivery_today ds
    where
        ds.stat_date >= '2023-07-08'
        and ds.stat_date <= '2023-07-08'
        and ds.arrival_scan_route_at < concat(ds.stat_date, ' 09:00:00')
)

        select
            t1.*
            ,ss.name 网点名称
            ,sc.route_time 第一次交接时间
        from t t1
        left join
            (
                select
                    sc.*
                from
                    (
                        select
                            pr.pno
                            ,pr.store_id
                            ,pr.store_name
                            ,t1.日期
                            ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                            ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                            ,row_number() over (partition by pr.pno,t1.日期 order by pr.routed_at) rk
                        from my_staging.parcel_route pr
                        join t t1 on t1.pno = pr.pno
                        where
                            pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                           and pr.routed_at >= date_sub(t1.日期, interval 8 hour)
                          and pr.routed_at < date_add(t1.日期, interval 16 hour )
                    ) sc
                where
                    sc.rk = 1
            ) sc on sc.pno = t1.pno and t1.日期 = sc.日期
left join my_staging.sys_store ss on ss.id = t1.网点ID
where
    ss.id not in ('MY04040316','MY04040315','MY04070217');
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
        ,ds.arrival_scan_route_at
    from my_bi.dc_should_delivery_today ds
    where
        ds.stat_date >= '2023-07-12'
        and ds.stat_date <= '2023-07-12'
        and ds.arrival_scan_route_at < concat(ds.stat_date, ' 09:00:00')
)

select
    a.stat_date 日期
    ,a.store_id 网点ID
    ,ss.name 网点名称
    ,ss.opening_at 开业日期
    ,smr.name 大区
    ,smp.name 片区
    ,ft.plan_arrive_time 计划到达时间
    ,ft.real_arrive_time Kit到港考勤
    ,ft.sign_time fleet签到时间
    ,a.应交接
    ,a.已交接
    ,concat(round(a.交接率*100,2),'%') as 交接率
    ,concat(ifnull(a.a_check,''), ifnull(a.b_check,''), ifnull(a.d_check,''), ifnull(a.e_check,''),if(a.a_check is null  and a.d_check is null and a.b_check is null and a.e_check is null, 'C', '')) 交接评级
    ,concat(round(a.A_rate * 100,2),'%')  'A时段（<0930 ）'
    ,concat(round(a.B_rate * 100,2),'%') 'B时段（0930<=X<1200）'
    ,concat(round(a.C_rate * 100,2),'%')'C时段（1200<=X<1600 ）'
    ,concat(round(a.D_rate * 100,2),'%')'D时段（>=1600）'
from
    (
        select
            t1.store_id
            ,t1.stat_date
            ,count(t1.pno) 应交接
            ,count(if(sc.pno is not null , t1.pno, null)) 已交接
            ,count(if(sc.pno is not null , t1.pno, null))/count(t1.pno) 交接率

            ,count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as A_rate
            ,count(if(time(sc.route_time) >= '09:30:00' and time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as B_rate
            ,count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as C_rate
            ,count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as D_rate

            ,if(count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.95, 'A', null ) a_check
            ,if(count(if(time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.98 and count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) <= 0.95, 'B', null ) b_check
            ,if(count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03, 'D', null ) d_check
            ,if(count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03 , 'E', null ) e_check
        from t t1
        left join
            (
                select
                    sc.*
                from
                    (
                        select
                            pr.pno
                            ,pr.store_id
                            ,pr.store_name
                            ,t1.stat_date
                            ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                            ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                            ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
                        from my_staging.parcel_route pr
                        join t t1 on t1.pno = pr.pno
                        where
                            pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                           and pr.routed_at >= date_sub(t1.stat_date, interval 8 hour)
                          and pr.routed_at < date_add(t1.stat_date, interval 16 hour )
                    ) sc
                where
                    sc.rk = 1
            ) sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
        group by 1,2
    ) a
left join my_bi.fleet_time ft on ft.next_store_id = a.store_id and ft.store_id is null and a.stat_date = date(ft.real_arrive_time)
left join my_staging.sys_store ss on ss.id = a.store_id
left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
where
    ss.category = 1
    and ss.id not in ('MY04040316','MY04040315','MY04070217');
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
        ,ds.arrival_scan_route_at
    from my_bi.dc_should_delivery_today ds
    where
        ds.stat_date >= '2023-07-12'
        and ds.stat_date <= '2023-07-12'
        and ds.arrival_scan_route_at < concat(ds.stat_date, ' 09:00:00')
)

select
    a.stat_date 日期
    ,a.store_id 网点ID
    ,ss.name 网点名称
    ,ss.opening_at 开业日期
    ,smr.name 大区
    ,smp.name 片区
    ,ft.plan_arrive_time 计划到达时间
    ,ft.real_arrive_time Kit到港考勤
    ,ft.sign_time fleet签到时间
    ,a.应交接
    ,a.已交接
    ,concat(round(a.交接率*100,2),'%') as 交接率
    ,concat(ifnull(a.a_check,''), ifnull(a.b_check,''), ifnull(a.d_check,''), ifnull(a.e_check,''),if(a.a_check is null  and a.d_check is null and a.b_check is null and a.e_check is null, 'C', '')) 交接评级
    ,concat(round(a.A_rate * 100,2),'%')  'A时段（<0930 ）'
    ,concat(round(a.B_rate * 100,2),'%') 'B时段（0930<=X<1200）'
    ,concat(round(a.C_rate * 100,2),'%')'C时段（1200<=X<1600 ）'
    ,concat(round(a.D_rate * 100,2),'%')'D时段（>=1600）'
from
    (
        select
            t1.store_id
            ,t1.stat_date
            ,count(t1.pno) 应交接
            ,count(if(sc.pno is not null , t1.pno, null)) 已交接
            ,count(if(sc.pno is not null , t1.pno, null))/count(t1.pno) 交接率

            ,count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as A_rate
            ,count(if(time(sc.route_time) >= '09:30:00' and time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as B_rate
            ,count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as C_rate
            ,count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as D_rate

            ,if(count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.95, 'A', null ) a_check
            ,if(count(if(time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.98 and count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) <= 0.95, 'B', null ) b_check
            ,if(count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03, 'D', null ) d_check
            ,if(count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03 , 'E', null ) e_check
        from t t1
        left join
            (
                select
                    sc.*
                from
                    (
                        select
                            pr.pno
                            ,pr.store_id
                            ,pr.store_name
                            ,t1.stat_date
                            ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                            ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                            ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
                        from my_staging.parcel_route pr
                        join t t1 on t1.pno = pr.pno
                        where
                            pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                           and pr.routed_at >= date_sub(t1.stat_date, interval 8 hour)
                          and pr.routed_at < date_add(t1.stat_date, interval 16 hour )
                    ) sc
                where
                    sc.rk = 1
            ) sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
        group by 1,2
    ) a
left join my_bi.fleet_time ft on ft.next_store_id = a.store_id and ft.store_id is not null and a.stat_date = date(ft.real_arrive_time)
left join my_staging.sys_store ss on ss.id = a.store_id
left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
where
    ss.category = 1
    and ss.id not in ('MY04040316','MY04040315','MY04070217');
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
        ,ds.arrival_scan_route_at
    from my_bi.dc_should_delivery_today ds
    where
        ds.stat_date >= '2023-07-12'
        and ds.stat_date <= '2023-07-12'
        and ds.arrival_scan_route_at < concat(ds.stat_date, ' 09:00:00')
)

select
    a.stat_date 日期
    ,a.store_id 网点ID
    ,ss.name 网点名称
    ,ss.opening_at 开业日期
    ,smr.name 大区
    ,smp.name 片区
    ,ft.plan_arrive_time 计划到达时间
    ,ft.real_arrive_time Kit到港考勤
    ,ft.sign_time fleet签到时间
    ,a.应交接
    ,a.已交接
    ,concat(round(a.交接率*100,2),'%') as 交接率
    ,concat(ifnull(a.a_check,''), ifnull(a.b_check,''), ifnull(a.d_check,''), ifnull(a.e_check,''),if(a.a_check is null  and a.d_check is null and a.b_check is null and a.e_check is null, 'C', '')) 交接评级
    ,concat(round(a.A_rate * 100,2),'%')  'A时段（<0930 ）'
    ,concat(round(a.B_rate * 100,2),'%') 'B时段（0930<=X<1200）'
    ,concat(round(a.C_rate * 100,2),'%')'C时段（1200<=X<1600 ）'
    ,concat(round(a.D_rate * 100,2),'%')'D时段（>=1600）'
from
    (
        select
            t1.store_id
            ,t1.stat_date
            ,count(t1.pno) 应交接
            ,count(if(sc.pno is not null , t1.pno, null)) 已交接
            ,count(if(sc.pno is not null , t1.pno, null))/count(t1.pno) 交接率

            ,count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as A_rate
            ,count(if(time(sc.route_time) >= '09:30:00' and time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as B_rate
            ,count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as C_rate
            ,count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as D_rate

            ,if(count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.95, 'A', null ) a_check
            ,if(count(if(time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.98 and count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) <= 0.95, 'B', null ) b_check
            ,if(count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03, 'D', null ) d_check
            ,if(count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03 , 'E', null ) e_check
        from t t1
        left join
            (
                select
                    sc.*
                from
                    (
                        select
                            pr.pno
                            ,pr.store_id
                            ,pr.store_name
                            ,t1.stat_date
                            ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                            ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                            ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
                        from my_staging.parcel_route pr
                        join t t1 on t1.pno = pr.pno
                        where
                            pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                           and pr.routed_at >= date_sub(t1.stat_date, interval 8 hour)
                          and pr.routed_at < date_add(t1.stat_date, interval 16 hour )
                    ) sc
                where
                    sc.rk = 1
            ) sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
        group by 1,2
    ) a
left join my_bi.fleet_time ft on ft.next_store_id = a.store_id and a.stat_date = date(ft.plan_arrive_time) and ft.arrive_type in (3,5)
left join my_staging.sys_store ss on ss.id = a.store_id
left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
where
    ss.category = 1
    and ss.id not in ('MY04040316','MY04040315','MY04070217');
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
        ,ds.arrival_scan_route_at
    from my_bi.dc_should_delivery_today ds
    where
        ds.stat_date >= '2023-07-12'
        and ds.stat_date <= '2023-07-12'
        and ds.arrival_scan_route_at < concat(ds.stat_date, ' 09:00:00')
)
, s as
(
    select
        sc.*
    from
        (
            select
                pr.pno
                ,pr.store_id
                ,pr.store_name
                ,t1.stat_date
                ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                ,pr.staff_info_id
                ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
            from my_staging.parcel_route pr
            join t t1 on t1.pno = pr.pno
            where
                pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
               and pr.routed_at >= date_sub(t1.stat_date, interval 8 hour)
              and pr.routed_at < date_add(t1.stat_date, interval 16 hour )
        ) sc
    where
        sc.rk = 1
)
select
    s2.stat_date 日期
    ,s2.store_name 网点
    ,s2.staff_info_id 员工ID
    ,a1.交接评级
    ,s2.pno 运单号
    ,s2.route_time 第一次交接时间
from
    (
        select
            a.stat_date 日期
            ,a.store_id
            ,concat(ifnull(a.a_check,''), ifnull(a.b_check,''), ifnull(a.d_check,''), ifnull(a.e_check,''),if(a.a_check is null  and a.d_check is null and a.b_check is null and a.e_check is null, 'C', '')) 交接评级
        from
            (
                select
                    t1.store_id
                    ,t1.stat_date
                    ,count(t1.pno) 应交接
                    ,count(if(sc.pno is not null , t1.pno, null)) 已交接
                    ,count(if(sc.pno is not null , t1.pno, null))/count(t1.pno) 交接率

                    ,count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as A_rate
                    ,count(if(time(sc.route_time) >= '09:30:00' and time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as B_rate
                    ,count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as C_rate
                    ,count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as D_rate

                    ,if(count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.95, 'A', null ) a_check
                    ,if(count(if(time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.98 and count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) <= 0.95, 'B', null ) b_check
                    ,if(count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03, 'D', null ) d_check
                    ,if(count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03 , 'E', null ) e_check
                from t t1
                left join s sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
                group by 1,2
            ) a
        left join my_bi.fleet_time ft on ft.next_store_id = a.store_id and a.stat_date = date(ft.plan_arrive_time) and ft.arrive_type in (3,5)
        left join my_staging.sys_store ss on ss.id = a.store_id
        left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
        left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
        where
            ss.category = 1
            and ss.id not in ('MY04040316','MY04040315','MY04070217')
    ) a1
join s s2 on s2.store_id = a1.store_id
where
    a1.交接评级 regexp 'C|D|E'
    and a1.交接评级 not regexp 'A|B';
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
        ,ds.arrival_scan_route_at
    from my_bi.dc_should_delivery_today ds
    where
        ds.stat_date >= '2023-07-11'
        and ds.stat_date <= '2023-07-12'
        and ds.arrival_scan_route_at < concat(ds.stat_date, ' 09:00:00')
)
select
    a2.*
from
    (
        select
            a.stat_date 日期
            ,a.store_id 网点ID
            ,ss.name 网点名称
            ,ss.opening_at 开业日期
            ,smr.name 大区
            ,smp.name 片区
            ,a.应交接
            ,a.已交接
            ,concat(round(a.交接率*100,2),'%') as 交接率
            ,concat(ifnull(a.a_check,''), ifnull(a.b_check,''), ifnull(a.d_check,''), ifnull(a.e_check,''),if(a.a_check is null  and a.d_check is null and a.b_check is null and a.e_check is null, 'C', '')) 交接评级
            ,concat(round(a.A_rate * 100,2),'%')  'A时段（<0930 ）'
            ,concat(round(a.B_rate * 100,2),'%') 'B时段（0930<=X<1200）'
            ,concat(round(a.C_rate * 100,2),'%')'C时段（1200<=X<1600 ）'
            ,concat(round(a.D_rate * 100,2),'%')'D时段（>=1600）'
            ,row_number() over (partition by date(ft.real_arrive_time), ft.next_store_id order by ft.real_arrive_time) rk
        from
            (
                select
                    t1.store_id
                    ,t1.stat_date
                    ,count(t1.pno) 应交接
                    ,count(if(sc.pno is not null , t1.pno, null)) 已交接
                    ,count(if(sc.pno is not null , t1.pno, null))/count(t1.pno) 交接率

                    ,count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as A_rate
                    ,count(if(time(sc.route_time) >= '09:30:00' and time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as B_rate
                    ,count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as C_rate
                    ,count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as D_rate

                    ,if(count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.95, 'A', null ) a_check
                    ,if(count(if(time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.98 and count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) <= 0.95, 'B', null ) b_check
                    ,if(count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03, 'D', null ) d_check
                    ,if(count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03 , 'E', null ) e_check
                from t t1
                left join
                    (
                        select
                            sc.*
                        from
                            (
                                select
                                    pr.pno
                                    ,pr.store_id
                                    ,pr.store_name
                                    ,t1.stat_date
                                    ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                                    ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                                    ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
                                from my_staging.parcel_route pr
                                join t t1 on t1.pno = pr.pno
                                where
                                    pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                                   and pr.routed_at >= date_sub(t1.stat_date, interval 8 hour)
                                  and pr.routed_at < date_add(t1.stat_date, interval 16 hour )
                            ) sc
                        where
                            sc.rk = 1
                    ) sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
                group by 1,2
            ) a
        left join my_staging.sys_store ss on ss.id = a.store_id
        left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
        left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
        left join my_bi.fleet_time ft on ft.next_store_id = ss.id and ft.arrive_type in (3,5) and date(ft.real_arrive_time) >= '2023-07-11' and date(ft.real_arrive_time) <= '2023-07-12'
        where
            ss.category = 1
            and ss.id not in ('MY04040316','MY04040315','MY04070217')
    ) a2
where
    a2.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
        ,ds.arrival_scan_route_at
    from my_bi.dc_should_delivery_today ds
    where
        ds.stat_date >= '2023-07-11'
        and ds.stat_date <= '2023-07-12'
        and ds.arrival_scan_route_at < concat(ds.stat_date, ' 09:00:00')
)
select
    a2.*
from
    (
        select
            a.stat_date 日期
            ,a.store_id 网点ID
            ,ss.name 网点名称
            ,ss.opening_at 开业日期
            ,smr.name 大区
            ,smp.name 片区
            ,a.应交接
            ,a.已交接
            ,ft.plan_arrive_time
            ,ft.real_arrive_time
            ,ft.sign_time
            ,concat(round(a.交接率*100,2),'%') as 交接率
            ,concat(ifnull(a.a_check,''), ifnull(a.b_check,''), ifnull(a.d_check,''), ifnull(a.e_check,''),if(a.a_check is null  and a.d_check is null and a.b_check is null and a.e_check is null, 'C', '')) 交接评级
            ,concat(round(a.A_rate * 100,2),'%')  'A时段（<0930 ）'
            ,concat(round(a.B_rate * 100,2),'%') 'B时段（0930<=X<1200）'
            ,concat(round(a.C_rate * 100,2),'%')'C时段（1200<=X<1600 ）'
            ,concat(round(a.D_rate * 100,2),'%')'D时段（>=1600）'
            ,row_number() over (partition by date(ft.real_arrive_time), ft.next_store_id order by ft.real_arrive_time) rk
        from
            (
                select
                    t1.store_id
                    ,t1.stat_date
                    ,count(t1.pno) 应交接
                    ,count(if(sc.pno is not null , t1.pno, null)) 已交接
                    ,count(if(sc.pno is not null , t1.pno, null))/count(t1.pno) 交接率

                    ,count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as A_rate
                    ,count(if(time(sc.route_time) >= '09:30:00' and time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as B_rate
                    ,count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as C_rate
                    ,count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as D_rate

                    ,if(count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.95, 'A', null ) a_check
                    ,if(count(if(time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.98 and count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) <= 0.95, 'B', null ) b_check
                    ,if(count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03, 'D', null ) d_check
                    ,if(count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03 , 'E', null ) e_check
                from t t1
                left join
                    (
                        select
                            sc.*
                        from
                            (
                                select
                                    pr.pno
                                    ,pr.store_id
                                    ,pr.store_name
                                    ,t1.stat_date
                                    ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                                    ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                                    ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
                                from my_staging.parcel_route pr
                                join t t1 on t1.pno = pr.pno
                                where
                                    pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                                   and pr.routed_at >= date_sub(t1.stat_date, interval 8 hour)
                                  and pr.routed_at < date_add(t1.stat_date, interval 16 hour )
                            ) sc
                        where
                            sc.rk = 1
                    ) sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
                group by 1,2
            ) a
        left join my_staging.sys_store ss on ss.id = a.store_id
        left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
        left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
        left join my_bi.fleet_time ft on ft.next_store_id = ss.id and ft.arrive_type in (3,5) and date(ft.real_arrive_time) >= '2023-07-11' and date(ft.real_arrive_time) <= '2023-07-12'
        where
            ss.category = 1
            and ss.id not in ('MY04040316','MY04040315','MY04070217')
    ) a2
where
    a2.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
        ,ds.arrival_scan_route_at
    from my_bi.dc_should_delivery_today ds
    where
        ds.stat_date >= '2023-07-11'
        and ds.stat_date <= '2023-07-12'
        and ds.arrival_scan_route_at < concat(ds.stat_date, ' 09:00:00')
)
select
    a2.*
from
    (
        select
            a.stat_date 日期
            ,a.store_id 网点ID
            ,ss.name 网点名称
            ,ss.opening_at 开业日期
            ,smr.name 大区
            ,smp.name 片区
            ,a.应交接
            ,a.已交接
            ,ft.plan_arrive_time
            ,ft.real_arrive_time
            ,ft.sign_time
            ,concat(round(a.交接率*100,2),'%') as 交接率
            ,concat(ifnull(a.a_check,''), ifnull(a.b_check,''), ifnull(a.d_check,''), ifnull(a.e_check,''),if(a.a_check is null  and a.d_check is null and a.b_check is null and a.e_check is null, 'C', '')) 交接评级
            ,concat(round(a.A_rate * 100,2),'%')  'A时段（<0930 ）'
            ,concat(round(a.B_rate * 100,2),'%') 'B时段（0930<=X<1200）'
            ,concat(round(a.C_rate * 100,2),'%')'C时段（1200<=X<1600 ）'
            ,concat(round(a.D_rate * 100,2),'%')'D时段（>=1600）'
            ,row_number() over (partition by date(ft.real_arrive_time), ft.next_store_id order by ft.real_arrive_time) rk
        from
            (
                select
                    t1.store_id
                    ,t1.stat_date
                    ,count(t1.pno) 应交接
                    ,count(if(sc.pno is not null , t1.pno, null)) 已交接
                    ,count(if(sc.pno is not null , t1.pno, null))/count(t1.pno) 交接率

                    ,count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as A_rate
                    ,count(if(time(sc.route_time) >= '09:30:00' and time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as B_rate
                    ,count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as C_rate
                    ,count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as D_rate

                    ,if(count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.95, 'A', null ) a_check
                    ,if(count(if(time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.98 and count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) <= 0.95, 'B', null ) b_check
                    ,if(count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03, 'D', null ) d_check
                    ,if(count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03 , 'E', null ) e_check
                from t t1
                left join
                    (
                        select
                            sc.*
                        from
                            (
                                select
                                    pr.pno
                                    ,pr.store_id
                                    ,pr.store_name
                                    ,t1.stat_date
                                    ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                                    ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                                    ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
                                from my_staging.parcel_route pr
                                join t t1 on t1.pno = pr.pno
                                where
                                    pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                                   and pr.routed_at >= date_sub(t1.stat_date, interval 8 hour)
                                  and pr.routed_at < date_add(t1.stat_date, interval 16 hour )
                            ) sc
                        where
                            sc.rk = 1
                    ) sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
                group by 1,2
            ) a
        left join my_staging.sys_store ss on ss.id = a.store_id
        left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
        left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
        left join my_bi.fleet_time ft on ft.next_store_id = ss.id and ft.arrive_type in (3,5) and date(ft.real_arrive_time) = a.stat_date
        where
            ss.category = 1
            and ss.id not in ('MY04040316','MY04040315','MY04070217')
    ) a2
where
    a2.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
        ,ds.arrival_scan_route_at
    from my_bi.dc_should_delivery_today ds
    where
        ds.stat_date >= '2023-07-11'
        and ds.stat_date <= '2023-07-12'
        and ds.arrival_scan_route_at < concat(ds.stat_date, ' 09:00:00')
)
select
    a2.*
from
    (
        select
            a.stat_date 日期
            ,a.store_id 网点ID
            ,ss.name 网点名称
            ,ss.opening_at 开业日期
            ,smr.name 大区
            ,smp.name 片区
            ,a.应交接
            ,a.已交接
            ,ft.plan_arrive_time 计划到达时间
            ,ft.real_arrive_time Kit到港考勤
            ,ft.sign_time fleet签到时间
            ,concat(round(a.交接率*100,2),'%') as 交接率
            ,concat(ifnull(a.a_check,''), ifnull(a.b_check,''), ifnull(a.d_check,''), ifnull(a.e_check,''),if(a.a_check is null  and a.d_check is null and a.b_check is null and a.e_check is null, 'C', '')) 交接评级
            ,concat(round(a.A_rate * 100,2),'%')  'A时段（<0930 ）'
            ,concat(round(a.B_rate * 100,2),'%') 'B时段（0930<=X<1200）'
            ,concat(round(a.C_rate * 100,2),'%')'C时段（1200<=X<1600 ）'
            ,concat(round(a.D_rate * 100,2),'%')'D时段（>=1600）'
            ,row_number() over (partition by date(ft.real_arrive_time), ft.next_store_id order by ft.real_arrive_time) rk
        from
            (
                select
                    t1.store_id
                    ,t1.stat_date
                    ,count(t1.pno) 应交接
                    ,count(if(sc.pno is not null , t1.pno, null)) 已交接
                    ,count(if(sc.pno is not null , t1.pno, null))/count(t1.pno) 交接率

                    ,count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as A_rate
                    ,count(if(time(sc.route_time) >= '09:30:00' and time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as B_rate
                    ,count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as C_rate
                    ,count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as D_rate

                    ,if(count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.95, 'A', null ) a_check
                    ,if(count(if(time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.98 and count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) <= 0.95, 'B', null ) b_check
                    ,if(count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03, 'D', null ) d_check
                    ,if(count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03 , 'E', null ) e_check
                from t t1
                left join
                    (
                        select
                            sc.*
                        from
                            (
                                select
                                    pr.pno
                                    ,pr.store_id
                                    ,pr.store_name
                                    ,t1.stat_date
                                    ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                                    ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                                    ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
                                from my_staging.parcel_route pr
                                join t t1 on t1.pno = pr.pno
                                where
                                    pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                                   and pr.routed_at >= date_sub(t1.stat_date, interval 8 hour)
                                  and pr.routed_at < date_add(t1.stat_date, interval 16 hour )
                            ) sc
                        where
                            sc.rk = 1
                    ) sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
                group by 1,2
            ) a
        left join my_staging.sys_store ss on ss.id = a.store_id
        left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
        left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
        left join my_bi.fleet_time ft on ft.next_store_id = ss.id and ft.arrive_type in (3,5) and date(ft.real_arrive_time) = a.stat_date
        where
            ss.category = 1
            and ss.id not in ('MY04040316','MY04040315','MY04070217')
    ) a2
where
    a2.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
        ,ds.arrival_scan_route_at
    from my_bi.dc_should_delivery_today ds
    where
        ds.stat_date >= '2023-07-11'
        and ds.stat_date <= '2023-07-12'
        and ds.arrival_scan_route_at < concat(ds.stat_date, ' 09:00:00')
)
select
    a2.*
from
    (
        select
            a.stat_date 日期
            ,a.store_id 网点ID
            ,ss.name 网点名称
            ,ss.opening_at 开业日期
            ,smr.name 大区
            ,smp.name 片区
            ,a.应交接
            ,a.已交接
            ,date_format(ft.plan_arrive_time, '%Y-%m-%d %H:%i:%s') 计划到达时间
            ,date_format(ft.real_arrive_time, '%Y-%m-%d %H:%i:%s') Kit到港考勤
            ,date_format(ft.sign_time, '%Y-%m-%d %H:%i:%s') fleet签到时间
            ,concat(round(a.交接率*100,2),'%') as 交接率
            ,concat(ifnull(a.a_check,''), ifnull(a.b_check,''), ifnull(a.d_check,''), ifnull(a.e_check,''),if(a.a_check is null  and a.d_check is null and a.b_check is null and a.e_check is null, 'C', '')) 交接评级
            ,concat(round(a.A_rate * 100,2),'%')  'A时段（<0930 ）'
            ,concat(round(a.B_rate * 100,2),'%') 'B时段（0930<=X<1200）'
            ,concat(round(a.C_rate * 100,2),'%')'C时段（1200<=X<1600 ）'
            ,concat(round(a.D_rate * 100,2),'%')'D时段（>=1600）'
            ,row_number() over (partition by date(ft.real_arrive_time), ft.next_store_id order by ft.real_arrive_time) rk
        from
            (
                select
                    t1.store_id
                    ,t1.stat_date
                    ,count(t1.pno) 应交接
                    ,count(if(sc.pno is not null , t1.pno, null)) 已交接
                    ,count(if(sc.pno is not null , t1.pno, null))/count(t1.pno) 交接率

                    ,count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as A_rate
                    ,count(if(time(sc.route_time) >= '09:30:00' and time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as B_rate
                    ,count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as C_rate
                    ,count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as D_rate

                    ,if(count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.95, 'A', null ) a_check
                    ,if(count(if(time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.98 and count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) <= 0.95, 'B', null ) b_check
                    ,if(count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03, 'D', null ) d_check
                    ,if(count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03 , 'E', null ) e_check
                from t t1
                left join
                    (
                        select
                            sc.*
                        from
                            (
                                select
                                    pr.pno
                                    ,pr.store_id
                                    ,pr.store_name
                                    ,t1.stat_date
                                    ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                                    ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                                    ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
                                from my_staging.parcel_route pr
                                join t t1 on t1.pno = pr.pno
                                where
                                    pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                                   and pr.routed_at >= date_sub(t1.stat_date, interval 8 hour)
                                  and pr.routed_at < date_add(t1.stat_date, interval 16 hour )
                            ) sc
                        where
                            sc.rk = 1
                    ) sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
                group by 1,2
            ) a
        left join my_staging.sys_store ss on ss.id = a.store_id
        left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
        left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
        left join my_bi.fleet_time ft on ft.next_store_id = ss.id and ft.arrive_type in (3,5) and date(ft.real_arrive_time) = a.stat_date
        where
            ss.category = 1
            and ss.id not in ('MY04040316','MY04040315','MY04070217')
    ) a2
where
    a2.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
        ,ds.arrival_scan_route_at
    from my_bi.dc_should_delivery_today ds
    where
#         ds.stat_date >= '${date1}'
#         and ds.stat_date <= '${date2}'
        ds.stat_date = curdate()
        and ds.arrival_scan_route_at < concat(ds.stat_date, ' 09:00:00')
)
, s as
(
    select
        sc.*
    from
        (
            select
                pr.pno
                ,pr.store_id
                ,pr.store_name
                ,t1.stat_date
                ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                ,pr.staff_info_id
                ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
            from my_staging.parcel_route pr
            join t t1 on t1.pno = pr.pno
            where
                pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
               and pr.routed_at >= date_sub(t1.stat_date, interval 8 hour)
              and pr.routed_at < date_add(t1.stat_date, interval 16 hour )
        ) sc
    where
        sc.rk = 1
)
select
    s2.stat_date 日期
    ,s2.store_name 网点
    ,s2.staff_info_id 员工ID
    ,a1.交接评级
    ,s2.pno 运单号
    ,s2.route_time 第一次交接时间
from
    (
        select
            a.stat_date 日期
            ,a.store_id
            ,concat(ifnull(a.a_check,''), ifnull(a.b_check,''), ifnull(a.d_check,''), ifnull(a.e_check,''),if(a.a_check is null  and a.d_check is null and a.b_check is null and a.e_check is null, 'C', '')) 交接评级
        from
            (
                select
                    t1.store_id
                    ,t1.stat_date
                    ,count(t1.pno) 应交接
                    ,count(if(sc.pno is not null , t1.pno, null)) 已交接
                    ,count(if(sc.pno is not null , t1.pno, null))/count(t1.pno) 交接率

                    ,count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as A_rate
                    ,count(if(time(sc.route_time) >= '09:30:00' and time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as B_rate
                    ,count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as C_rate
                    ,count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as D_rate

                    ,if(count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.95, 'A', null ) a_check
                    ,if(count(if(time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.98 and count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) <= 0.95, 'B', null ) b_check
                    ,if(count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03, 'D', null ) d_check
                    ,if(count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03 , 'E', null ) e_check
                from t t1
                left join s sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
                group by 1,2
            ) a
        left join my_bi.fleet_time ft on ft.next_store_id = a.store_id and a.stat_date = date(ft.plan_arrive_time) and ft.arrive_type in (3,5)
        left join my_staging.sys_store ss on ss.id = a.store_id
        left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
        left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
        where
            ss.category = 1
            and ss.id not in ('MY04040316','MY04040315','MY04070217')
    ) a1
join s s2 on s2.store_id = a1.store_id
where
    a1.交接评级 regexp 'C|D|E'
    and a1.交接评级 not regexp 'A|B';
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ds.pno
    from my_bi.dc_should_delivery_today ds
    left join my_staging.sys_store ss on ss.id = ds.store_id
    where
        ds.stat_date = '2023-07-18'
        and ss.name in ('BBB_SP')
)
select
    t1.pno
    ,if(sc.pno is not null , '是', '否') 是否操作分拣扫描
    ,convert_tz(sc.routed_at, '+00:00', '+08:00') 第一次分拣扫描时间
    ,sc.staff_info_id 操作分拣扫描时间
    ,if(cf.pno is not null, '是', '否') 是否标记错分
    ,dmp.sorting_code 三段码
from t t1
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,pr.staff_info_id
            ,row_number() over (partition by pr.pno order by pr.routed_at ) rk
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'SORTING_SCAN'
            and pr.routed_at > '2023-07-17 18:00:00'
    ) sc on sc.pno = t1.pno
left join
    (
        select
            pr.pno
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'DELIVERY_MARKER'
            and pr.marker_category = 31
            and pr.routed_at > '2023-07-17 18:00:00'
        group by 1
    ) cf on cf.pno = t1.pno
left join dwm.drds_my_parcel_sorting_code_info dmp on dmp.pno = t1.pno;
;-- -. . -..- - / . -. - .-. -.--
select
        ds.pno
    from my_bi.dc_should_delivery_today ds
    left join my_staging.sys_store ss on ss.id = ds.store_id
    where
        ds.stat_date = '2023-07-18'
        and ss.name in ('BBB_SP');
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ds.pno
    from my_bi.dc_should_delivery_today ds
    where
        ds.stat_date = '2023-07-18'
        and ds.store_id = 'MY04020200' -- BBB_SP
)
select
    t1.pno
    ,if(sc.pno is not null , '是', '否') 是否操作分拣扫描
    ,convert_tz(sc.routed_at, '+00:00', '+08:00') 第一次分拣扫描时间
    ,sc.staff_info_id 操作分拣扫描时间
    ,if(cf.pno is not null, '是', '否') 是否标记错分
    ,dmp.sorting_code 三段码
from t t1
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,pr.staff_info_id
            ,row_number() over (partition by pr.pno order by pr.routed_at ) rk
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'SORTING_SCAN'
            and pr.routed_at > '2023-07-17 18:00:00'
    ) sc on sc.pno = t1.pno
left join
    (
        select
            pr.pno
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'DELIVERY_MARKER'
            and pr.marker_category = 31
            and pr.routed_at > '2023-07-17 18:00:00'
        group by 1
    ) cf on cf.pno = t1.pno
left join dwm.drds_my_parcel_sorting_code_info dmp on dmp.pno = t1.pno;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ds.pno
    from my_bi.dc_should_delivery_today ds
    where
        ds.stat_date = '2023-07-18'
        and ds.store_id = 'MY04020200' -- BBB_SP
)
select
    t1.pno
    ,if(sc.pno is not null , '是', '否') 是否操作分拣扫描
    ,convert_tz(sc.routed_at, '+00:00', '+08:00') 第一次分拣扫描时间
    ,sc.staff_info_id 操作分拣扫描时间
    ,if(cf.pno is not null, '是', '否') 是否标记错分
    ,dmp.sorting_code 三段码
from t t1
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,pr.staff_info_id
            ,row_number() over (partition by pr.pno order by pr.routed_at ) rk
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'SORTING_SCAN'
            and pr.routed_at > '2023-07-17 18:00:00'
    ) sc on sc.pno = t1.pno and sc.rk = 1
left join
    (
        select
            pr.pno
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'DELIVERY_MARKER'
            and pr.marker_category = 31
            and pr.routed_at > '2023-07-17 18:00:00'
        group by 1
    ) cf on cf.pno = t1.pno
left join dwm.drds_my_parcel_sorting_code_info dmp on dmp.pno = t1.pno;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ds.pno
    from my_bi.dc_should_delivery_today ds
    where
        ds.stat_date = '2023-07-18'
        and ds.store_id = 'MY04020200' -- BBB_SP
)
select
    t1.pno
    ,if(sc.pno is not null , '是', '否') 是否操作分拣扫描
    ,convert_tz(sc.routed_at, '+00:00', '+08:00') 第一次分拣扫描时间
    ,sc.staff_info_id 操作分拣扫描时间
    ,if(cf.pno is not null, '是', '否') 是否标记错分
    ,dmp.sorting_code 三段码
from t t1
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,pr.staff_info_id
            ,row_number() over (partition by pr.pno order by pr.routed_at ) rk
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'SORTING_SCAN'
            and pr.routed_at > '2023-07-17 18:00:00'
    ) sc on sc.pno = t1.pno and sc.rk = 1
left join
    (
        select
            pr.pno
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'DELIVERY_MARKER'
            and pr.marker_category = 31
            and pr.routed_at > '2023-07-17 18:00:00'
        group by 1
    ) cf on cf.pno = t1.pno
left join
    (
        select
            dmp.pno
            ,dmp.sorting_code
            ,row_number() over (partition by dmp.pno order by dmp.created_at desc) rk
        from dwm.drds_my_parcel_sorting_code_info dmp
        join t t1 on t1.pno = dmp.pno and dmp.dst_store_id = 'MY04020200'
    ) dmp on dmp.pno = t1.pno and dmp.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
with d as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
    from my_bi.dc_should_delivery_today ds
    where
        ds.stat_date >= '2023-07-18'
        and ds.stat_date <= '2023-07-18'
        and ds.arrival_scan_route_at < concat(ds.stat_date, ' 09:00:00')
)
, t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
    from d ds
    left join
        (
            select
                pr.pno
                ,ds.stat_date
                ,max(convert_tz(pr.routed_at,'+00:00','+08:00')) remote_marker_time
            from my_staging.parcel_route pr
            join d ds on pr.pno = ds.pno
            where 1=1
                and pr.routed_at >= date_sub(ds.stat_date, interval 8 hour)
                and pr.routed_at < date_add(ds.stat_date, interval 16 hour)
                and pr.route_action = 'DETAIN_WAREHOUSE'
                and pr.marker_category in (42,43) ##岛屿,偏远地区
            group by 1,2
        ) pr1  on ds.pno = pr1.pno and ds.stat_date = pr1.stat_date  #当日留仓标记为偏远地区留待次日派送
    left join
        (
            select
               pr.pno
                ,ds.stat_date
               ,convert_tz(pr.routed_at,'+00:00','+08:00') reschedule_marker_time
               ,row_number() over(partition by ds.stat_date, pr.pno order by pr.routed_at desc) rk
            from my_staging.parcel_route pr
            join d ds on ds.pno = pr.pno
            where 1=1
                and pr.routed_at >= date_sub(ds.stat_date ,interval 15 day)
                and pr.routed_at <  date_sub(ds.stat_date ,interval 8 hour) #限定当日之前的改约
                and pr.route_action = 'DETAIN_WAREHOUSE'
                and from_unixtime(json_extract(pr.extra_value,'$.desiredat')) > date_add(ds.stat_date, interval 16 hour)
                and pr.marker_category in (9,14,70) ##客户改约时间
        ) pr2 on ds.pno = pr2.pno and pr2.stat_date = ds.stat_date and  pr2.rk = 1 #当日之前客户改约时间
    left join my_bi .dc_should_delivery_today ds1 on ds.pno = ds1.pno and ds1.state = 6 and ds1.stat_date = date_sub(ds.stat_date,interval 1 day)
    where
        case
            when pr1.pno is not null then 'N'
            when pr2.pno is not null then 'N'
            when ds1.pno is not null  then 'N'  else 'Y'
        end = 'Y'
)
,b as
(
    select
        a.stat_date 日期
        ,a.store_id 网点ID
        ,ss.name 网点名称
        ,smr.name 大区
        ,smp.name 片区
        ,a.应交接
        ,a.已交接
        ,concat(round(a.交接率*100,2),'%') as 交接率
        ,concat(ifnull(a.a_check,''), ifnull(a.b_check,''), ifnull(a.d_check,''), ifnull(a.e_check,''),if(a.a_check is null  and a.d_check is null and a.b_check is null and a.e_check is null, 'C', '')) 交接评级
        ,concat(round(a.A_rate * 100,2),'%')  'A时段（<0930 ）'
        ,concat(round(a.B_rate * 100,2),'%') 'B时段（0930<=X<1200）'
        ,concat(round(a.C_rate * 100,2),'%')'C时段（1200<=X<1600 ）'
        ,concat(round(a.D_rate * 100,2),'%')'D时段（>=1600）'
    from
        (
            select
                t1.store_id
                ,t1.stat_date
                ,count(t1.pno) 应交接
                ,count(if(sc.pno is not null , t1.pno, null)) 已交接
                ,count(if(sc.pno is not null , t1.pno, null))/count(t1.pno) 交接率

                ,count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as A_rate
                ,count(if(time(sc.route_time) >= '09:30:00' and time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as B_rate
                ,count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as C_rate
                ,count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as D_rate

                ,if(count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.95, 'A', null ) a_check
                ,if(count(if(time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.98 and count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) <= 0.95, 'B', null ) b_check
                ,if(count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03, 'D', null ) d_check
                ,if(count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03 , 'E', null ) e_check
            from t t1
            left join
                (
                    select
                        sc.*
                    from
                        (
                            select
                                pr.pno
                                ,pr.store_id
                                ,pr.store_name
                                ,t1.stat_date
                                ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                                ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                                ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
                            from my_staging.parcel_route pr
                            join t t1 on t1.pno = pr.pno
                            where
                                pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                               and pr.routed_at >= date_sub(t1.stat_date, interval 8 hour)
                              and pr.routed_at < date_add(t1.stat_date, interval 16 hour )
                        ) sc
                    where
                        sc.rk = 1
                ) sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
            group by 1,2
        ) a
    left join my_staging.sys_store ss on ss.id = a.store_id
    left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
    left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
    where
        ss.category = 1
        and ss.id not in ('MY04040316','MY04040315','MY04070217')
)
select
    t1.日期
    ,t1.大区
    ,t1.交接评级
    ,t1.store_num 网点数
    ,t1.store_num/t2.store_num 网点占比
from
    (
        select
            b1.日期
            ,b1.大区
            ,b1.交接评级
            ,count(b1.网点ID) store_num
        from b b1
        group by 1,2,3
    ) t1
left join
    (
        select
            b1.日期
            ,b1.大区
            ,count(b1.网点ID) store_num
        from b b1
        group by 1,2
    ) t2 on t2.日期 = t1.日期 and t2.大区 = t1.大区;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ds.pno
    from my_bi.dc_should_delivery_today ds
    where
        ds.stat_date = '2023-07-19'
        and ds.store_id = 'MY04020200' -- BBB_SP
)
select
    t1.pno
    ,if(sc.pno is not null , '是', '否') 是否操作分拣扫描
    ,convert_tz(sc.routed_at, '+00:00', '+08:00') 第一次分拣扫描时间
    ,sc.staff_info_id 操作分拣扫描时间
    ,if(cf.pno is not null, '是', '否') 是否标记错分
    ,dmp.sorting_code 三段码
from t t1
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,pr.staff_info_id
            ,row_number() over (partition by pr.pno order by pr.routed_at ) rk
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'SORTING_SCAN'
            and pr.routed_at > '2023-07-18 18:00:00'
    ) sc on sc.pno = t1.pno and sc.rk = 1
left join
    (
        select
            pr.pno
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'DELIVERY_MARKER'
            and pr.marker_category = 31
            and pr.routed_at > '2023-07-18 18:00:00'
        group by 1
    ) cf on cf.pno = t1.pno
left join
    (
        select
            dmp.pno
            ,dmp.sorting_code
            ,row_number() over (partition by dmp.pno order by dmp.created_at desc) rk
        from dwm.drds_my_parcel_sorting_code_info dmp
        join t t1 on t1.pno = dmp.pno and dmp.dst_store_id = 'MY04020200'
    ) dmp on dmp.pno = t1.pno and dmp.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ds.stat_date
        ,ds.pno
    from my_bi.dc_should_delivery_today ds
    where
        ds.stat_date >= '2023-07-24'
        and ds.stat_date <= '2023-07-26'
        and ds.store_id = 'MY04020200' -- BBB_SP
)
select
    t1.stat_date 统计日期
    ,t1.pno 单号
    ,if(sc.pno is not null , '是', '否') 是否操作分拣扫描
    ,convert_tz(sc.routed_at, '+00:00', '+08:00') 第一次分拣扫描时间
    ,sc.staff_info_id 操作分拣扫描时间
    ,if(cf.pno is not null, '是', '否') 是否标记错分
    ,dmp.sorting_code 三段码
from t t1
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,pr.staff_info_id
            ,row_number() over (partition by pr.pno order by pr.routed_at ) rk
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'SORTING_SCAN'
            and pr.routed_at >= date_sub(t1.stat_date,interval 8 hour)
            and pr.routed_at < date_add(t1.stat_date, interval 16 hour)
    ) sc on sc.pno = t1.pno and sc.rk = 1
left join
    (
        select
            pr.pno
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'DELIVERY_MARKER'
            and pr.marker_category = 31
            and pr.routed_at >= date_sub(t1.stat_date,interval 8 hour)
            and pr.routed_at < date_add(t1.stat_date, interval 16 hour)
        group by 1
    ) cf on cf.pno = t1.pno
left join
    (
        select
            dmp.pno
            ,dmp.sorting_code
            ,row_number() over (partition by dmp.pno order by dmp.created_at desc) rk
        from dwm.drds_my_parcel_sorting_code_info dmp
        join t t1 on t1.pno = dmp.pno and dmp.dst_store_id = 'MY04020200'
    ) dmp on dmp.pno = t1.pno and dmp.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ds.stat_date
        ,ds.pno
    from my_bi.dc_should_delivery_today ds
    where
        ds.stat_date >= '2023-07-24'
        and ds.stat_date <= '2023-07-26'
        and ds.store_id = 'MY04020200' -- BBB_SP
)
select
    t1.stat_date 统计日期
    ,t1.pno 单号
    ,if(sc.pno is not null , '是', '否') 是否操作分拣扫描
    ,convert_tz(sc.routed_at, '+00:00', '+08:00') 第一次分拣扫描时间
    ,sc.staff_info_id 操作分拣扫描时间
    ,if(cf.pno is not null, '是', '否') 是否标记错分
    ,dmp.sorting_code 三段码
    ,dmp.third_sorting_code 第三段码
from t t1
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,pr.staff_info_id
            ,row_number() over (partition by pr.pno order by pr.routed_at ) rk
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'SORTING_SCAN'
            and pr.routed_at >= date_sub(t1.stat_date,interval 8 hour)
            and pr.routed_at < date_add(t1.stat_date, interval 16 hour)
    ) sc on sc.pno = t1.pno and sc.rk = 1
left join
    (
        select
            pr.pno
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'DELIVERY_MARKER'
            and pr.marker_category = 31
            and pr.routed_at >= date_sub(t1.stat_date,interval 8 hour)
            and pr.routed_at < date_add(t1.stat_date, interval 16 hour)
        group by 1
    ) cf on cf.pno = t1.pno
left join
    (
        select
            dmp.pno
            ,dmp.sorting_code
            ,dmp.third_sorting_code
            ,row_number() over (partition by dmp.pno order by dmp.created_at desc) rk
        from dwm.drds_my_parcel_sorting_code_info dmp
        join t t1 on t1.pno = dmp.pno and dmp.dst_store_id = 'MY04020200'
    ) dmp on dmp.pno = t1.pno and dmp.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
    ,convert_tz(pi.created_at, '+00:00', '+08:00') 揽收时间
from my_staging.parcel_info pi
join tmpale.tmp_my_pno_0731 t on t.pno = pi.pno;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ds.stat_date
        ,ds.pno
        ,ds.store_id
        ,ss.name
    from my_bi.dc_should_delivery_today ds
    left join my_staging.sys_store ss on ds.store_id = ss.id
    where
        ds.stat_date >= '2023-07-19'
        and ds.stat_date <= '2023-08-03'
#         and ds.store_id = 'MY04020200' -- BBB_SP
)
select
    t1.stat_date 统计日期
    ,t1.store_id 网点ID
    ,t1.name 网点
    ,t1.pno 单号
    ,if(sc.pno is not null , '是', '否') 当日是否操作分拣扫描
    ,convert_tz(sc.routed_at, '+00:00', '+08:00') 当日第一次分拣扫描时间
    ,sc.staff_info_id 操作分拣扫描时间
    ,if(cf.pno is not null, '是', '否') 是否标记错分
    ,dmp.sorting_code 三段码
    ,dmp.third_sorting_code 第三段码
from t t1
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,pr.staff_info_id
            ,t1.stat_date
            ,row_number() over (partition by t1.stat_date,pr.pno order by pr.routed_at ) rk
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'SORTING_SCAN'
            and pr.routed_at >= date_sub(t1.stat_date,interval 8 hour)
            and pr.routed_at < date_add(t1.stat_date, interval 16 hour)
    ) sc on sc.pno = t1.pno and sc.rk = 1
left join
    (
        select
            pr.pno
            ,t1.stat_date
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'DELIVERY_MARKER'
            and pr.marker_category = 31
            and pr.routed_at >= date_sub(t1.stat_date,interval 8 hour)
            and pr.routed_at < date_add(t1.stat_date, interval 16 hour)
        group by 1,2
    ) cf on cf.pno = t1.pno
left join
    (
        select
            dmp.pno
            ,dmp.sorting_code
            ,dmp.third_sorting_code
            ,row_number() over (partition by dmp.pno order by dmp.created_at desc) rk
        from dwm.drds_my_parcel_sorting_code_info dmp
        join t t1 on t1.pno = dmp.pno and dmp.dst_store_id = t1.store_id
    ) dmp on dmp.pno = t1.pno and dmp.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ds.stat_date
        ,ds.pno
        ,ds.store_id
        ,ss.name
    from my_bi.dc_should_delivery_today ds
    left join my_staging.sys_store ss on ds.store_id = ss.id
    where
        ds.stat_date >= '2023-07-19'
        and ds.stat_date <= '2023-08-03'
)
select
    t1.stat_date 统计日期
    ,t1.store_id 网点ID
    ,t1.name 网点
    ,t1.pno 单号
    ,if(sc.pno is not null , '是', '否') 当日是否操作分拣扫描
    ,convert_tz(sc.routed_at, '+00:00', '+08:00') 当日第一次分拣扫描时间
    ,sc.staff_info_id 操作分拣扫描员工
    ,if(cf.pno is not null, '是', '否') 是否标记错分
    ,dmp.sorting_code 三段码
    ,dmp.third_sorting_code 第三段码
from t t1
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,pr.staff_info_id
            ,t1.stat_date
            ,row_number() over (partition by t1.stat_date,pr.pno order by pr.routed_at ) rk
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'SORTING_SCAN'
            and pr.routed_at >= date_sub(t1.stat_date,interval 8 hour)
            and pr.routed_at < date_add(t1.stat_date, interval 16 hour)
    ) sc on sc.pno = t1.pno and sc.rk = 1
left join
    (
        select
            pr.pno
            ,t1.stat_date
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'DELIVERY_MARKER'
            and pr.marker_category = 31
            and pr.routed_at >= date_sub(t1.stat_date,interval 8 hour)
            and pr.routed_at < date_add(t1.stat_date, interval 16 hour)
        group by 1,2
    ) cf on cf.pno = t1.pno
left join
    (
        select
            dmp.pno
            ,dmp.sorting_code
            ,dmp.third_sorting_code
            ,row_number() over (partition by dmp.pno order by dmp.created_at desc) rk
        from dwm.drds_my_parcel_sorting_code_info dmp
        join t t1 on t1.pno = dmp.pno and dmp.dst_store_id = t1.store_id
    ) dmp on dmp.pno = t1.pno and dmp.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ds.stat_date
        ,ds.pno
        ,ds.store_id
        ,ss.name
    from my_bi.dc_should_delivery_today ds
    left join my_staging.sys_store ss on ds.store_id = ss.id
    where
        ds.stat_date >= '2023-07-28'
        and ds.stat_date <= '2023-08-03'
)
select
    t1.stat_date 统计日期
    ,t1.store_id 网点ID
    ,t1.name 网点
    ,t1.pno 单号
    ,if(sc.pno is not null , '是', '否') 当日是否操作分拣扫描
    ,convert_tz(sc.routed_at, '+00:00', '+08:00') 当日第一次分拣扫描时间
    ,sc.staff_info_id 操作分拣扫描员工
    ,if(cf.pno is not null, '是', '否') 是否标记错分
    ,dmp.sorting_code 三段码
    ,dmp.third_sorting_code 第三段码
from t t1
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,pr.staff_info_id
            ,t1.stat_date
            ,row_number() over (partition by t1.stat_date,pr.pno order by pr.routed_at ) rk
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'SORTING_SCAN'
            and pr.routed_at >= date_sub(t1.stat_date,interval 8 hour)
            and pr.routed_at < date_add(t1.stat_date, interval 16 hour)
    ) sc on sc.pno = t1.pno and sc.rk = 1
left join
    (
        select
            pr.pno
            ,t1.stat_date
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'DELIVERY_MARKER'
            and pr.marker_category = 31
            and pr.routed_at >= date_sub(t1.stat_date,interval 8 hour)
            and pr.routed_at < date_add(t1.stat_date, interval 16 hour)
        group by 1,2
    ) cf on cf.pno = t1.pno
left join
    (
        select
            dmp.pno
            ,dmp.sorting_code
            ,dmp.third_sorting_code
            ,row_number() over (partition by dmp.pno order by dmp.created_at desc) rk
        from dwm.drds_my_parcel_sorting_code_info dmp
        join t t1 on t1.pno = dmp.pno and dmp.dst_store_id = t1.store_id
    ) dmp on dmp.pno = t1.pno and dmp.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ds.stat_date
        ,ds.pno
        ,ds.store_id
        ,ss.name
    from my_bi.dc_should_delivery_today ds
    left join my_staging.sys_store ss on ds.store_id = ss.id
    where
        ds.stat_date >= '2023-07-28'
        and ds.stat_date <= '2023-08-03'
)
select
    t1.stat_date 统计日期
    ,t1.store_id 网点ID
    ,t1.name 网点
    ,t1.pno 单号
    ,if(sc.pno is not null , '是', '否') 当日是否操作分拣扫描
    ,convert_tz(sc.routed_at, '+00:00', '+08:00') 当日第一次分拣扫描时间
    ,sc.staff_info_id 操作分拣扫描员工
    ,if(cf.pno is not null, '是', '否') 是否标记错分
    ,dmp.sorting_code 三段码
    ,dmp.third_sorting_code 第三段码
from t t1
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,pr.staff_info_id
            ,t1.stat_date
            ,row_number() over (partition by t1.stat_date,pr.pno order by pr.routed_at ) rk
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'SORTING_SCAN'
            and pr.routed_at >= date_sub(t1.stat_date,interval 8 hour)
            and pr.routed_at < date_add(t1.stat_date, interval 16 hour)
    ) sc on sc.pno = t1.pno and sc.rk = 1 and sc.stat_date = t1.stat_date
left join
    (
        select
            pr.pno
            ,t1.stat_date
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'DELIVERY_MARKER'
            and pr.marker_category = 31
            and pr.routed_at >= date_sub(t1.stat_date,interval 8 hour)
            and pr.routed_at < date_add(t1.stat_date, interval 16 hour)
        group by 1,2
    ) cf on cf.pno = t1.pno and cf.stat_date = t1.stat_date
left join
    (
        select
            dmp.pno
            ,dmp.sorting_code
            ,dmp.third_sorting_code
            ,row_number() over (partition by dmp.pno order by dmp.created_at desc) rk
        from dwm.drds_my_parcel_sorting_code_info dmp
        join t t1 on t1.pno = dmp.pno and dmp.dst_store_id = t1.store_id
    ) dmp on dmp.pno = t1.pno and dmp.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
select
    oi.pno
    ,oi.cogs_amount/100 cog
from my_staging.order_info oi
join tmpale.tmp_my_pno_0804 t on t.pno = oi.pno;
;-- -. . -..- - / . -. - .-. -.--
select
    t.pno
    ,oi.cogs_amount/100 cog
from my_staging.order_info oi
join tmpale.tmp_my_pno_0804 t on t.pno = oi.pno;
;-- -. . -..- - / . -. - .-. -.--
select
    t.pno
    ,oi.cogs_amount/100 cog
from tmpale.tmp_my_pno_0804 t
left join my_staging.order_info oi  on t.pno = oi.pno;
;-- -. . -..- - / . -. - .-. -.--
select
    t.pno
    ,oi.cogs_amount/100 cog
    ,oi.client_id
from tmpale.tmp_my_pno_0804 t
left join my_staging.order_info oi  on t.pno = oi.pno;
;-- -. . -..- - / . -. - .-. -.--
select
    t.pno
    ,oi.cogs_amount/100 cog
    ,oi.client_id
    ,pi.created_at
from tmpale.tmp_my_pno_0804 t
left join my_staging.order_info oi  on t.pno = oi.pno
left join my_staging.parcel_info pi on pi.pno = t.pno;
;-- -. . -..- - / . -. - .-. -.--
select
    t.pno
    ,oi.cogs_amount/100 cog
    ,pi.client_id
    ,pi.created_at
from tmpale.tmp_my_pno_0804 t
left join my_staging.order_info oi  on t.pno = oi.pno
left join my_staging.parcel_info pi on pi.pno = t.pno;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        *
    from
        (
            select
                ad.*
                ,row_number() over (partition by ad.staff_info_id order by ad.stat_date desc) rk
            from
                (
                    select
                        ad.*
                        ,ad.attendance_time + ad.BT + ad.CT + ad.BT_Y + ad.AB total
                    from my_bi.attendance_data_v2 ad
                    join my_bi.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,1000,37,16) -- 在职且非待离职
                    where
                        ad.stat_date < curdate()
#                         and hsi.hire_date <= date_sub(curdate(), interval 7 day )
                ) ad
            where
                ad.total = 10
        ) ad
    where
        ad.rk < 8
)
select
    st.staff_info_id 工号
    ,if(hsi2.sys_store_id = '-1', 'Head office', dp.store_name) 网点
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,case
        when hsi2.job_title in (13,110,1000) then '快递员'
        when hsi2.job_title in (37) then '仓管员'
        when hsi2.job_title in (16) then '主管'
    end 角色
    ,st.late_num 迟到次数
    ,st.absence_sum 缺勤数据
    ,st.late_time_sum 迟到时长
    ,case
        when st.absence_sum = 0 and st.late_num <= 1 and st.late_time_sum < 30 then 'A'
        when st.absence_sum >= 2 or st.late_num >= 3  then 'C'
        else 'B'
    end 出勤评级
from
    (
        select
            a.staff_info_id
            ,count(if(a.late_or_not = 'y' ,a.stat_date, null)) late_num
            ,sum(if(a.late_or_not = 'y', a.late_time, 0)) late_time_sum
            ,sum(a.absence_time) absence_sum
        from
            (
                select
                    t1.*
                    ,if(t1.attendance_started_at > date_add(concat(t1.stat_date, ' ', t1.shift_start), interval 1 minute ) , 'y', 'n') late_or_not
                    ,if(t1.attendance_started_at > date_add(concat(t1.stat_date, ' ', t1.shift_start), interval 1 minute ) , timestampdiff(minute , concat(t1.stat_date, ' ', t1.shift_start), t1.attendance_started_at), 0) late_time
                    ,t1.AB/10 absence_time
                from t t1
            ) a
        group by 1
    ) st
left join my_bi.hr_staff_info hsi2 on hsi2.staff_info_id = st.staff_info_id
left join dwm.dim_my_sys_store_rd dp on dp.store_id = hsi2.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
order by 2,1;
;-- -. . -..- - / . -. - .-. -.--
with d as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
    from my_bi.dc_should_delivery_2023_07 ds
    where
        ds.stat_date >= '2023-07-28'
        and ds.stat_date <= '2023-07-31'
        and ds.arrival_scan_route_at < concat(ds.stat_date, ' 09:00:00')
)
, t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
    from d ds
    left join
        (
            select
                pr.pno
                ,ds.stat_date
                ,max(convert_tz(pr.routed_at,'+00:00','+08:00')) remote_marker_time
            from my_staging.parcel_route pr
            join d ds on pr.pno = ds.pno
            where 1=1
                and pr.routed_at >= date_sub(ds.stat_date, interval 8 hour)
                and pr.routed_at < date_add(ds.stat_date, interval 16 hour)
                and pr.route_action = 'DETAIN_WAREHOUSE'
                and pr.marker_category in (42,43) ##岛屿,偏远地区
            group by 1,2
        ) pr1  on ds.pno = pr1.pno and ds.stat_date = pr1.stat_date  #当日留仓标记为偏远地区留待次日派送
    left join
        (
            select
               pr.pno
                ,ds.stat_date
               ,convert_tz(pr.routed_at,'+00:00','+08:00') reschedule_marker_time
               ,row_number() over(partition by ds.stat_date, pr.pno order by pr.routed_at desc) rk
            from my_staging.parcel_route pr
            join d ds on ds.pno = pr.pno
            where 1=1
                and pr.routed_at >= date_sub(ds.stat_date ,interval 15 day)
                and pr.routed_at <  date_sub(ds.stat_date ,interval 8 hour) #限定当日之前的改约
                and pr.route_action = 'DETAIN_WAREHOUSE'
                and from_unixtime(json_extract(pr.extra_value,'$.desiredat')) > date_add(ds.stat_date, interval 16 hour)
                and pr.marker_category in (9,14,70) ##客户改约时间
        ) pr2 on ds.pno = pr2.pno and pr2.stat_date = ds.stat_date and  pr2.rk = 1 #当日之前客户改约时间
    left join my_bi .dc_should_delivery_today ds1 on ds.pno = ds1.pno and ds1.state = 6 and ds1.stat_date = date_sub(ds.stat_date,interval 1 day)
    where
        case
            when pr1.pno is not null then 'N'
            when pr2.pno is not null then 'N'
            when ds1.pno is not null  then 'N'  else 'Y'
        end = 'Y'
)
,b as
(
    select
        a.stat_date 日期
        ,a.store_id 网点ID
        ,ss.name 网点名称
        ,smr.name 大区
        ,smp.name 片区
        ,a.应交接
        ,a.已交接
        ,concat(round(a.交接率*100,2),'%') as 交接率
        ,concat(ifnull(a.a_check,''), ifnull(a.b_check,''), ifnull(a.d_check,''), ifnull(a.e_check,''),if(a.a_check is null  and a.d_check is null and a.b_check is null and a.e_check is null, 'C', '')) 交接评级
        ,concat(round(a.A_rate * 100,2),'%')  'A时段（<0930 ）'
        ,concat(round(a.B_rate * 100,2),'%') 'B时段（0930<=X<1200）'
        ,concat(round(a.C_rate * 100,2),'%')'C时段（1200<=X<1600 ）'
        ,concat(round(a.D_rate * 100,2),'%')'D时段（>=1600）'
    from
        (
            select
                t1.store_id
                ,t1.stat_date
                ,count(t1.pno) 应交接
                ,count(if(sc.pno is not null , t1.pno, null)) 已交接
                ,count(if(sc.pno is not null , t1.pno, null))/count(t1.pno) 交接率

                ,count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as A_rate
                ,count(if(time(sc.route_time) >= '09:30:00' and time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as B_rate
                ,count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as C_rate
                ,count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as D_rate

                ,if(count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.95, 'A', null ) a_check
                ,if(count(if(time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.98 and count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) <= 0.95, 'B', null ) b_check
                ,if(count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03, 'D', null ) d_check
                ,if(count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03 , 'E', null ) e_check
            from t t1
            left join
                (
                    select
                        sc.*
                    from
                        (
                            select
                                pr.pno
                                ,pr.store_id
                                ,pr.store_name
                                ,t1.stat_date
                                ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                                ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                                ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
                            from my_staging.parcel_route pr
                            join t t1 on t1.pno = pr.pno
                            where
                                pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                               and pr.routed_at >= date_sub(t1.stat_date, interval 8 hour)
                              and pr.routed_at < date_add(t1.stat_date, interval 16 hour )
                        ) sc
                    where
                        sc.rk = 1
                ) sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
            group by 1,2
        ) a
    left join my_staging.sys_store ss on ss.id = a.store_id
    left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
    left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
    where
        ss.category = 1
        and ss.id not in ('MY04040316','MY04040315','MY04070217')
)
select
    t1.日期
    ,t1.大区
    ,t1.交接评级
    ,t1.store_num 网点数
    ,t1.store_num/t2.store_num 网点占比
from
    (
        select
            b1.日期
            ,b1.大区
            ,b1.交接评级
            ,count(b1.网点ID) store_num
        from b b1
        group by 1,2,3
    ) t1
left join
    (
        select
            b1.日期
            ,b1.大区
            ,count(b1.网点ID) store_num
        from b b1
        group by 1,2
    ) t2 on t2.日期 = t1.日期 and t2.大区 = t1.大区;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ds.stat_date
        ,ds.pno
        ,ds.store_id
        ,ss.name
    from my_bi.dc_should_delivery_2023_07 ds
    left join my_staging.sys_store ss on ds.store_id = ss.id
    where
        ds.stat_date >= '2023-07-28'
        and ds.stat_date <= '2023-07-31'
)
select
    t1.stat_date 统计日期
    ,t1.store_id 网点ID
    ,t1.name 网点
    ,t1.pno 单号
    ,if(sc.pno is not null , '是', '否') 当日是否操作分拣扫描
    ,convert_tz(sc.routed_at, '+00:00', '+08:00') 当日第一次分拣扫描时间
    ,sc.staff_info_id 操作分拣扫描员工
    ,if(cf.pno is not null, '是', '否') 是否标记错分
    ,dmp.sorting_code 三段码
    ,dmp.third_sorting_code 第三段码
from t t1
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,pr.staff_info_id
            ,t1.stat_date
            ,row_number() over (partition by t1.stat_date,pr.pno order by pr.routed_at ) rk
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'SORTING_SCAN'
            and pr.routed_at >= date_sub(t1.stat_date,interval 8 hour)
            and pr.routed_at < date_add(t1.stat_date, interval 16 hour)
    ) sc on sc.pno = t1.pno and sc.rk = 1 and sc.stat_date = t1.stat_date
left join
    (
        select
            pr.pno
            ,t1.stat_date
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'DELIVERY_MARKER'
            and pr.marker_category = 31
            and pr.routed_at >= date_sub(t1.stat_date,interval 8 hour)
            and pr.routed_at < date_add(t1.stat_date, interval 16 hour)
        group by 1,2
    ) cf on cf.pno = t1.pno and cf.stat_date = t1.stat_date
left join
    (
        select
            dmp.pno
            ,dmp.sorting_code
            ,dmp.third_sorting_code
            ,row_number() over (partition by dmp.pno order by dmp.created_at desc) rk
        from dwm.drds_my_parcel_sorting_code_info dmp
        join t t1 on t1.pno = dmp.pno and dmp.dst_store_id = t1.store_id
    ) dmp on dmp.pno = t1.pno and dmp.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        *
    from
        (
            select
                ad.*
                ,row_number() over (partition by ad.staff_info_id order by ad.stat_date desc) rk
            from
                (
                    select
                        ad.*
                        ,ad.attendance_time + ad.BT + ad.CT + ad.BT_Y + ad.AB total
                    from my_bi.attendance_data_v2 ad
                    join my_bi.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,1000,37,16) -- 在职且非待离职
                    where
                        ad.stat_date < curdate()

                ) ad
            where
                ad.total = 10
        ) ad
    where
        ad.rk < 8
)
select
    st.staff_info_id 工号
    ,if(hsi2.sys_store_id = '-1', 'Head office', dp.store_name) 网点
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,case
        when hsi2.job_title in (13,110,1199) then '快递员'
        when hsi2.job_title in (37) then '仓管员'
        when hsi2.job_title in (16) then '主管'
    end 角色
    ,st.late_num 迟到次数
    ,st.absence_sum 缺勤数据
    ,st.late_time_sum 迟到时长
    ,case
        when st.absence_sum = 0 and st.late_num <= 1 and st.late_time_sum < 30 then 'A'
        when st.absence_sum >= 2 or st.late_num >= 3  then 'C'
        else 'B'
    end 出勤评级
from
    (
        select
            a.staff_info_id
            ,count(if(a.late_or_not = 'y' ,a.stat_date, null)) late_num
            ,sum(if(a.late_or_not = 'y', a.late_time, 0)) late_time_sum
            ,sum(a.absence_time) absence_sum
        from
            (
                select
                    t1.*
                    ,if(t1.attendance_started_at > date_add(concat(t1.stat_date, ' ', t1.shift_start), interval 1 minute ) , 'y', 'n') late_or_not
                    ,if(t1.attendance_started_at > date_add(concat(t1.stat_date, ' ', t1.shift_start), interval 1 minute ) , timestampdiff(minute , concat(t1.stat_date, ' ', t1.shift_start), t1.attendance_started_at), 0) late_time
                    ,t1.AB/10 absence_time
                from t t1
            ) a
        group by 1
    ) st
left join my_bi.hr_staff_info hsi2 on hsi2.staff_info_id = st.staff_info_id
left join dwm.dim_my_sys_store_rd dp on dp.store_id = hsi2.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
order by 2,1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        *
    from
        (
            select
                ad.*
                ,row_number() over (partition by ad.staff_info_id order by ad.stat_date desc) rk
            from
                (
                    select
                        ad.*
                        ,ad.attendance_time + ad.BT + ad.CT + ad.BT_Y + ad.AB total
                    from my_bi.attendance_data_v2 ad
                    join my_bi.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,1000,37,16) -- 在职且非待离职
                    where
                        ad.stat_date < curdate()

                ) ad
            where
                ad.total = 10
        ) ad
    where
        ad.rk < 8
)
select
    st.staff_info_id 工号
    ,if(hsi2.sys_store_id = '-1', 'Head office', dp.store_name) 网点
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,case
        when hsi2.job_title in (13,110,1199) then '快递员'
        when hsi2.job_title in (37) then '仓管员'
        when hsi2.job_title in (16) then '主管'
    end 角色
    ,hsi2.job_title
    ,st.late_num 迟到次数
    ,st.absence_sum 缺勤数据
    ,st.late_time_sum 迟到时长
    ,case
        when st.absence_sum = 0 and st.late_num <= 1 and st.late_time_sum < 30 then 'A'
        when st.absence_sum >= 2 or st.late_num >= 3  then 'C'
        else 'B'
    end 出勤评级
from
    (
        select
            a.staff_info_id
            ,count(if(a.late_or_not = 'y' ,a.stat_date, null)) late_num
            ,sum(if(a.late_or_not = 'y', a.late_time, 0)) late_time_sum
            ,sum(a.absence_time) absence_sum
        from
            (
                select
                    t1.*
                    ,if(t1.attendance_started_at > date_add(concat(t1.stat_date, ' ', t1.shift_start), interval 1 minute ) , 'y', 'n') late_or_not
                    ,if(t1.attendance_started_at > date_add(concat(t1.stat_date, ' ', t1.shift_start), interval 1 minute ) , timestampdiff(minute , concat(t1.stat_date, ' ', t1.shift_start), t1.attendance_started_at), 0) late_time
                    ,t1.AB/10 absence_time
                from t t1
            ) a
        group by 1
    ) st
left join my_bi.hr_staff_info hsi2 on hsi2.staff_info_id = st.staff_info_id
left join dwm.dim_my_sys_store_rd dp on dp.store_id = hsi2.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
order by 2,1;
;-- -. . -..- - / . -. - .-. -.--
with d as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
    from my_bi.dc_should_delivery_today ds
    where
        ds.stat_date >= '2023-08-05'
        and ds.stat_date <= '2023-08-05'
        and ds.arrival_scan_route_at < concat(ds.stat_date, ' 09:00:00')
)
, t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
    from d ds
    left join
        (
            select
                pr.pno
                ,ds.stat_date
                ,max(convert_tz(pr.routed_at,'+00:00','+08:00')) remote_marker_time
            from my_staging.parcel_route pr
            join d ds on pr.pno = ds.pno
            where 1=1
                and pr.routed_at >= date_sub(ds.stat_date, interval 8 hour)
                and pr.routed_at < date_add(ds.stat_date, interval 16 hour)
                and pr.route_action = 'DETAIN_WAREHOUSE'
                and pr.marker_category in (42,43) ##岛屿,偏远地区
            group by 1,2
        ) pr1  on ds.pno = pr1.pno and ds.stat_date = pr1.stat_date  #当日留仓标记为偏远地区留待次日派送
    left join
        (
            select
               pr.pno
                ,ds.stat_date
               ,convert_tz(pr.routed_at,'+00:00','+08:00') reschedule_marker_time
               ,row_number() over(partition by ds.stat_date, pr.pno order by pr.routed_at desc) rk
            from my_staging.parcel_route pr
            join d ds on ds.pno = pr.pno
            where 1=1
                and pr.routed_at >= date_sub(ds.stat_date ,interval 15 day)
                and pr.routed_at <  date_sub(ds.stat_date ,interval 8 hour) #限定当日之前的改约
                and pr.route_action = 'DETAIN_WAREHOUSE'
                and from_unixtime(json_extract(pr.extra_value,'$.desiredat')) > date_add(ds.stat_date, interval 16 hour)
                and pr.marker_category in (9,14,70) ##客户改约时间
        ) pr2 on ds.pno = pr2.pno and pr2.stat_date = ds.stat_date and  pr2.rk = 1 #当日之前客户改约时间
    left join my_bi .dc_should_delivery_today ds1 on ds.pno = ds1.pno and ds1.state = 6 and ds1.stat_date = date_sub(ds.stat_date,interval 1 day)
    where
        case
            when pr1.pno is not null then 'N'
            when pr2.pno is not null then 'N'
            when ds1.pno is not null  then 'N'  else 'Y'
        end = 'Y'
)
select
    a2.*
from
    (
        select
            a.stat_date 日期
            ,a.store_id 网点ID
            ,ss.name 网点名称
            ,ss.opening_at 开业日期
            ,smr.name 大区
            ,smp.name 片区
            ,a.应交接
            ,a.已交接
            ,date_format(ft.plan_arrive_time, '%Y-%m-%d %H:%i:%s') 计划到达时间
            ,date_format(ft.real_arrive_time, '%Y-%m-%d %H:%i:%s') Kit到港考勤
            ,date_format(ft.sign_time, '%Y-%m-%d %H:%i:%s') fleet签到时间
            ,concat(round(a.交接率*100,2),'%') as 交接率
            ,concat(ifnull(a.a_check,''), ifnull(a.b_check,''), ifnull(a.d_check,''), ifnull(a.e_check,''),if(a.a_check is null  and a.d_check is null and a.b_check is null and a.e_check is null, 'C', '')) 交接评级
            ,concat(round(a.A_rate * 100,2),'%')  'A时段（<0930 ）'
            ,concat(round(a.B_rate * 100,2),'%') 'B时段（0930<=X<1200）'
            ,concat(round(a.C_rate * 100,2),'%')'C时段（1200<=X<1600 ）'
            ,concat(round(a.D_rate * 100,2),'%')'D时段（>=1600）'
            ,row_number() over (partition by date(ft.real_arrive_time), ft.next_store_id order by ft.real_arrive_time) rk
        from
            (
                select
                    t1.store_id
                    ,t1.stat_date
                    ,count(t1.pno) 应交接
                    ,count(if(sc.pno is not null , t1.pno, null)) 已交接
                    ,count(if(sc.pno is not null , t1.pno, null))/count(t1.pno) 交接率

                    ,count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as A_rate
                    ,count(if(time(sc.route_time) >= '09:30:00' and time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as B_rate
                    ,count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as C_rate
                    ,count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as D_rate

                    ,if(count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.95, 'A', null ) a_check
                    ,if(count(if(time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.98 and count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) <= 0.95, 'B', null ) b_check
                    ,if(count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03, 'D', null ) d_check
                    ,if(count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03 , 'E', null ) e_check
                from t t1
                left join
                    (
                        select
                            sc.*
                        from
                            (
                                select
                                    pr.pno
                                    ,pr.store_id
                                    ,pr.store_name
                                    ,t1.stat_date
                                    ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                                    ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                                    ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
                                from my_staging.parcel_route pr
                                join t t1 on t1.pno = pr.pno
                                where
                                    pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                                   and pr.routed_at >= date_sub(t1.stat_date, interval 8 hour)
                                  and pr.routed_at < date_add(t1.stat_date, interval 16 hour )
                            ) sc
                        where
                            sc.rk = 1
                    ) sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
                group by 1,2
            ) a
        left join my_staging.sys_store ss on ss.id = a.store_id
        left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
        left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
        left join my_bi.fleet_time ft on ft.next_store_id = ss.id and ft.arrive_type in (3,5) and date(ft.real_arrive_time) = a.stat_date
        where
            ss.category = 1
            and ss.id not in ('MY04040316','MY04040315','MY04070217')
    ) a2
where
    a2.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
with d as
(
    select
         ds.dst_store_id store_id
        ,ds.pno
        ,ds.p_date stat_date
    from dwm.dwd_my_dc_should_be_delivery ds
    where
        ds.should_delevry_type = '1派应派包裹'
        and ds.p_date = '2023-08-05'
)
, t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
    from d ds
    left join
        (
            select
                pr.pno
                ,ds.stat_date
                ,max(convert_tz(pr.routed_at,'+00:00','+08:00')) remote_marker_time
            from my_staging.parcel_route pr
            join d ds on pr.pno = ds.pno
            where 1=1
                and pr.routed_at >= date_sub(ds.stat_date, interval 8 hour)
                and pr.routed_at < date_add(ds.stat_date, interval 16 hour)
                and pr.route_action = 'DETAIN_WAREHOUSE'
                and pr.marker_category in (42,43) ##岛屿,偏远地区
            group by 1,2
        ) pr1  on ds.pno = pr1.pno and ds.stat_date = pr1.stat_date  #当日留仓标记为偏远地区留待次日派送
    left join
        (
            select
               pr.pno
                ,ds.stat_date
               ,convert_tz(pr.routed_at,'+00:00','+08:00') reschedule_marker_time
               ,row_number() over(partition by ds.stat_date, pr.pno order by pr.routed_at desc) rk
            from my_staging.parcel_route pr
            join d ds on ds.pno = pr.pno
            where 1=1
                and pr.routed_at >= date_sub(ds.stat_date ,interval 15 day)
                and pr.routed_at <  date_sub(ds.stat_date ,interval 8 hour) #限定当日之前的改约
                and pr.route_action = 'DETAIN_WAREHOUSE'
                and from_unixtime(json_extract(pr.extra_value,'$.desiredat')) > date_add(ds.stat_date, interval 16 hour)
                and pr.marker_category in (9,14,70) ##客户改约时间
        ) pr2 on ds.pno = pr2.pno and pr2.stat_date = ds.stat_date and  pr2.rk = 1 #当日之前客户改约时间
    left join my_bi .dc_should_delivery_today ds1 on ds.pno = ds1.pno and ds1.state = 6 and ds1.stat_date = date_sub(ds.stat_date,interval 1 day)
    where
        case
            when pr1.pno is not null then 'N'
            when pr2.pno is not null then 'N'
            when ds1.pno is not null  then 'N'  else 'Y'
        end = 'Y'
)
select
    a2.*
from
    (
        select
            a.stat_date 日期
            ,a.store_id 网点ID
            ,ss.name 网点名称
            ,ss.opening_at 开业日期
            ,smr.name 大区
            ,smp.name 片区
            ,a.应交接
            ,a.已交接
            ,date_format(ft.plan_arrive_time, '%Y-%m-%d %H:%i:%s') 计划到达时间
            ,date_format(ft.real_arrive_time, '%Y-%m-%d %H:%i:%s') Kit到港考勤
            ,date_format(ft.sign_time, '%Y-%m-%d %H:%i:%s') fleet签到时间
            ,concat(round(a.交接率*100,2),'%') as 交接率
            ,concat(ifnull(a.a_check,''), ifnull(a.b_check,''), ifnull(a.d_check,''), ifnull(a.e_check,''),if(a.a_check is null  and a.d_check is null and a.b_check is null and a.e_check is null, 'C', '')) 交接评级
            ,concat(round(a.A_rate * 100,2),'%')  'A时段（<0930 ）'
            ,concat(round(a.B_rate * 100,2),'%') 'B时段（0930<=X<1200）'
            ,concat(round(a.C_rate * 100,2),'%')'C时段（1200<=X<1600 ）'
            ,concat(round(a.D_rate * 100,2),'%')'D时段（>=1600）'
            ,row_number() over (partition by date(ft.real_arrive_time), ft.next_store_id order by ft.real_arrive_time) rk
        from
            (
                select
                    t1.store_id
                    ,t1.stat_date
                    ,count(t1.pno) 应交接
                    ,count(if(sc.pno is not null , t1.pno, null)) 已交接
                    ,count(if(sc.pno is not null , t1.pno, null))/count(t1.pno) 交接率

                    ,count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as A_rate
                    ,count(if(time(sc.route_time) >= '09:30:00' and time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as B_rate
                    ,count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as C_rate
                    ,count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as D_rate

                    ,if(count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.95, 'A', null ) a_check
                    ,if(count(if(time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.98 and count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) <= 0.95, 'B', null ) b_check
                    ,if(count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03, 'D', null ) d_check
                    ,if(count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03 , 'E', null ) e_check
                from t t1
                left join
                    (
                        select
                            sc.*
                        from
                            (
                                select
                                    pr.pno
                                    ,pr.store_id
                                    ,pr.store_name
                                    ,t1.stat_date
                                    ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                                    ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                                    ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
                                from my_staging.parcel_route pr
                                join t t1 on t1.pno = pr.pno
                                where
                                    pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                                   and pr.routed_at >= date_sub(t1.stat_date, interval 8 hour)
                                  and pr.routed_at < date_add(t1.stat_date, interval 16 hour )
                            ) sc
                        where
                            sc.rk = 1
                    ) sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
                group by 1,2
            ) a
        left join my_staging.sys_store ss on ss.id = a.store_id
        left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
        left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
        left join my_bi.fleet_time ft on ft.next_store_id = ss.id and ft.arrive_type in (3,5) and date(ft.real_arrive_time) = a.stat_date
        where
            ss.category = 1
            and ss.id not in ('MY04040316','MY04040315','MY04070217')
    ) a2
where
    a2.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ds.dst_store_id as store_id
        ,pr.pno
        ,hst.sys_store_id hr_store_id
        ,hst.formal
        ,pr.staff_info_id
        ,pi.state
        ,hst.job_title
    from dwm.dwd_my_dc_should_be_delivery ds
    left join my_staging.parcel_route pr on pr.pno = ds.pno and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    left join my_staging.parcel_info pi on pi.pno = pr.pno
    left join my_bi.hr_staff_info hst on hst.staff_info_id = pr.staff_info_id
#     left join ph_bi.hr_staff_transfer hst  on hst.staff_info_id = pr.staff_info_id
    where
        ds.p_date = '2023-08-05'
        and pr.routed_at >= date_sub('2023-08-05', interval 8 hour )
        and pr.routed_at < date_add('2023-08-05', interval 16 hour)
        and ds.should_delevry_type != '非当日应派'
#         and hst.stat_date = '${date}'
#         and ds.dst_store_id = 'PH61060300'
)
    select
        dr.store_id 网点ID
        ,dr.store_name 网点
        ,coalesce(dr.opening_at, '未记录') 开业时间
        ,case ss.category
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
        end 网点类型
        ,smp.name 片区
        ,smr.name 大区
        ,coalesce(emp_cnt.staf_num, 0) 总快递员人数_在职
        ,coalesce(a3.self_staff_num, 0) 自有快递员出勤数
        ,coalesce(a3.other_staff_num, 0) '外协+支援快递员出勤数'
        ,coalesce(a3.dco_dcs_num, 0) 仓管主管_出勤数

        ,coalesce(a3.avg_scan_num, 0) 快递员平均交接量
        ,coalesce(a3.avg_del_num, 0) 快递员平均妥投量
        ,coalesce(a3.dco_dcs_avg_scan, 0) 仓管主管_平均交接量

        ,coalesce(sdb.code_num, 0) 网点三段码数量
        ,coalesce(a2.self_avg_staff_code, 0) 自有快递员三段码平均交接量
        ,coalesce(a2.other_avg_staff_code, 0) '外协+支援快递员三段码平均交接量'
        ,coalesce(a2.self_avg_staff_del_code, 0) 自有快递员三段码平均妥投量
        ,coalesce(a2.other_avg_staff_del_code, 0) '外协+支援快递员三段码平均妥投量'
        ,coalesce(a2.avg_code_staff, 0) 三段码平均交接快递员数
        ,case
            when a2.avg_code_staff < 2 then 'A'
            when a2.avg_code_staff >= 2 and a2.avg_code_staff < 3 then 'B'
            when a2.avg_code_staff >= 3 and a2.avg_code_staff < 4 then 'C'
            when a2.avg_code_staff >= 4 then 'D'
        end 评级
        ,a2.code_num
        ,a2.staff_code_num
        ,a2.staff_num
        ,a2.fin_staff_code_num
    from
        (
            select
                a1.store_id
                ,count(distinct if(a1.job_title in (13,110,1 ), a1.staff_code, null)) staff_code_num
                ,count(distinct if(a1.job_title in (13,110,1199), a1.third_sorting_code, null)) code_num
                ,count(distinct if(a1.job_title in (13,110,1199), a1.staff_info_id, null)) staff_num
                ,count(distinct if(a1.job_title in (13,110,1199), a1.staff_code, null)) fin_staff_code_num
                ,count(distinct if(a1.job_title in (13,110,1199), a1.staff_code, null))/ count(distinct if(a1.job_title in (13,110,1199), a1.third_sorting_code, null)) avg_code_staff
                ,count(distinct if(a1.is_self = 'y' and a1.job_title in (13,110,1199), a1.staff_code, null))/count(distinct if(a1.is_self = 'y' and a1.job_title in (13,110,1199), a1.staff_info_id, null)) self_avg_staff_code
                ,count(distinct if(a1.is_self = 'n' and a1.job_title in (13,110,1199), a1.staff_code, null))/count(distinct if(a1.is_self = 'n' and a1.job_title in (13,110,1199), a1.staff_info_id, null)) other_avg_staff_code
                ,count(distinct if(a1.state = 5 and a1.is_self = 'y' and a1.job_title in (13,110,1199), a1.staff_code, null))/count(distinct if(a1.is_self = 'y' and a1.job_title in (13,110,1199), a1.staff_info_id, null)) self_avg_staff_del_code
                ,count(distinct if(a1.state = 5 and a1.is_self = 'n' and a1.job_title in (13,110,1199), a1.staff_code, null))/count(distinct if(a1.is_self = 'n' and a1.job_title in (13,110,1199), a1.staff_info_id, null)) other_avg_staff_del_code
            from
                (
                select
                    a1.*
                    ,concat(a1.staff_info_id, a1.third_sorting_code) staff_code
                from
                    (
                        select
                            t1.store_id
                            ,t1.pno
                            ,t1.staff_info_id
                            ,if(t1.formal = 1 and t1.store_id = t1.hr_store_id, 'y', 'n') is_self
                            ,t1.state
                            ,t1.job_title
                            ,ps.third_sorting_code
                            ,rank() over (partition by t1.pno order by ps.created_at desc) rk
                        from t t1
                        join my_drds_pro.parcel_sorting_code_info ps on  ps.pno = t1.pno and ps.dst_store_id = t1.store_id and ps.third_sorting_code != 'XX'
                    ) a1
                where
                    a1.rk = 1
            ) a1
        left join my_staging.parcel_info pi on pi.pno = a1.pno
        group by 1
    ) a2
left join
    (
        select
            hr.sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  my_bi.hr_staff_info  hr
        where
            hr.formal = 1
            and hr.is_sub_staff= 0
            and hr.state = 1
            and hr.job_title in (13,110,1199)
        group by 1
    ) emp_cnt on emp_cnt.sys_store_id = a2.store_id
# left join
#     (
#         select
#            ad.sys_store_id
#            ,count(distinct ad.staff_info_id) as atd_emp_cnt -- 出勤人数
#        from ph_bi.attendance_data_v2 ad
#        left join ph_bi.hr_staff_info hr on hr.staff_info_id =ad.staff_info_id
#        where
#            (ad.attendance_started_at is not null or ad.attendance_end_at is not null)
#             and hr.job_title in (13,110,1000)
# #             and ad.stat_date = curdate()
#             and ad.stat_date = '${date}'
#        group by 1
#     ) att on att.sys_store_id = a2.store_id
left join dwm.dim_my_sys_store_rd dr on dr.store_id = a2.store_id and dr.stat_date = date_sub(curdate(), interval 1 day)
left join my_staging.sys_store ss on ss.id = a2.store_id
left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
left join
    (
        select
            t1.store_id
            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.formal = 1  and t1.job_title in (13,110,1199), t1.staff_info_id, null))  self_staff_num
            ,count(distinct if(t1.job_title in (13,110,1199) and ( t1.hr_store_id != t1.store_id or t1.formal != 1  ), t1.staff_info_id, null )) other_staff_num
            ,count(distinct if(t1.job_title in (13,110,1199), t1.pno, null))/count(distinct if(t1.job_title in (13,110,1199),  t1.staff_info_id, null)) avg_scan_num
            ,count(distinct if(t1.job_title in (13,110,1199) and t1.state = 5, t1.pno, null))/count(distinct if(t1.job_title in (13,110,1199) and t1.state = 5,  t1.staff_info_id, null)) avg_del_num

            ,count(distinct if(t1.job_title in (37,16), t1.staff_info_id, null)) dco_dcs_num
            ,count(distinct if(t1.job_title in (37,16), t1.pno, null))/count(distinct if(t1.job_title in (37,16), t1.staff_info_id, null)) dco_dcs_avg_scan
        from t t1
        group by 1
    ) a3  on a3.store_id = a2.store_id
left join
    (
        select
            sdb.store_id
            ,count(distinct sdb.district_code) code_num
        from my_staging.store_delivery_barangay_group_info sdb
        where
            sdb.deleted = 0
            and sdb.delivery_code != 'XX'
        group by 1
    ) sdb on sdb.store_id = a2.store_id
where
    ss.category in (1,10)
    and sdb.store_id is not null;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ds.dst_store_id as store_id
        ,pr.pno
        ,hst.sys_store_id hr_store_id
        ,hst.formal
        ,pr.staff_info_id
        ,pi.state
        ,hst.job_title
    from dwm.dwd_my_dc_should_be_delivery ds
    left join my_staging.parcel_route pr on pr.pno = ds.pno and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    left join my_staging.parcel_info pi on pi.pno = pr.pno
    left join my_bi.hr_staff_info hst on hst.staff_info_id = pr.staff_info_id
#     left join ph_bi.hr_staff_transfer hst  on hst.staff_info_id = pr.staff_info_id
    where
        ds.p_date = '2023-08-05'
        and pr.routed_at >= date_sub('2023-08-05', interval 8 hour )
        and pr.routed_at < date_add('2023-08-05', interval 16 hour)
        and ds.should_delevry_type != '非当日应派'
#         and hst.stat_date = '${date}'
#         and ds.dst_store_id = 'PH61060300'
)
#     select
#         dr.store_id 网点ID
#         ,dr.store_name 网点
#         ,coalesce(dr.opening_at, '未记录') 开业时间
#         ,case ss.category
#             when 1 then 'SP'
#             when 2 then 'DC'
#             when 4 then 'SHOP'
#             when 5 then 'SHOP'
#             when 6 then 'FH'
#             when 7 then 'SHOP'
#             when 8 then 'Hub'
#             when 9 then 'Onsite'
#             when 10 then 'BDC'
#             when 11 then 'fulfillment'
#             when 12 then 'B-HUB'
#             when 13 then 'CDC'
#             when 14 then 'PDC'
#         end 网点类型
#         ,smp.name 片区
#         ,smr.name 大区
#         ,coalesce(emp_cnt.staf_num, 0) 总快递员人数_在职
#         ,coalesce(a3.self_staff_num, 0) 自有快递员出勤数
#         ,coalesce(a3.other_staff_num, 0) '外协+支援快递员出勤数'
#         ,coalesce(a3.dco_dcs_num, 0) 仓管主管_出勤数
#
#         ,coalesce(a3.avg_scan_num, 0) 快递员平均交接量
#         ,coalesce(a3.avg_del_num, 0) 快递员平均妥投量
#         ,coalesce(a3.dco_dcs_avg_scan, 0) 仓管主管_平均交接量
#
#         ,coalesce(sdb.code_num, 0) 网点三段码数量
#         ,coalesce(a2.self_avg_staff_code, 0) 自有快递员三段码平均交接量
#         ,coalesce(a2.other_avg_staff_code, 0) '外协+支援快递员三段码平均交接量'
#         ,coalesce(a2.self_avg_staff_del_code, 0) 自有快递员三段码平均妥投量
#         ,coalesce(a2.other_avg_staff_del_code, 0) '外协+支援快递员三段码平均妥投量'
#         ,coalesce(a2.avg_code_staff, 0) 三段码平均交接快递员数
#         ,case
#             when a2.avg_code_staff < 2 then 'A'
#             when a2.avg_code_staff >= 2 and a2.avg_code_staff < 3 then 'B'
#             when a2.avg_code_staff >= 3 and a2.avg_code_staff < 4 then 'C'
#             when a2.avg_code_staff >= 4 then 'D'
#         end 评级
#         ,a2.code_num
#         ,a2.staff_code_num
#         ,a2.staff_num
#         ,a2.fin_staff_code_num
#     from
#         (
#             select
#                 a1.store_id
#                 ,count(distinct if(a1.job_title in (13,110,1 ), a1.staff_code, null)) staff_code_num
#                 ,count(distinct if(a1.job_title in (13,110,1199), a1.third_sorting_code, null)) code_num
#                 ,count(distinct if(a1.job_title in (13,110,1199), a1.staff_info_id, null)) staff_num
#                 ,count(distinct if(a1.job_title in (13,110,1199), a1.staff_code, null)) fin_staff_code_num
#                 ,count(distinct if(a1.job_title in (13,110,1199), a1.staff_code, null))/ count(distinct if(a1.job_title in (13,110,1199), a1.third_sorting_code, null)) avg_code_staff
#                 ,count(distinct if(a1.is_self = 'y' and a1.job_title in (13,110,1199), a1.staff_code, null))/count(distinct if(a1.is_self = 'y' and a1.job_title in (13,110,1199), a1.staff_info_id, null)) self_avg_staff_code
#                 ,count(distinct if(a1.is_self = 'n' and a1.job_title in (13,110,1199), a1.staff_code, null))/count(distinct if(a1.is_self = 'n' and a1.job_title in (13,110,1199), a1.staff_info_id, null)) other_avg_staff_code
#                 ,count(distinct if(a1.state = 5 and a1.is_self = 'y' and a1.job_title in (13,110,1199), a1.staff_code, null))/count(distinct if(a1.is_self = 'y' and a1.job_title in (13,110,1199), a1.staff_info_id, null)) self_avg_staff_del_code
#                 ,count(distinct if(a1.state = 5 and a1.is_self = 'n' and a1.job_title in (13,110,1199), a1.staff_code, null))/count(distinct if(a1.is_self = 'n' and a1.job_title in (13,110,1199), a1.staff_info_id, null)) other_avg_staff_del_code
#             from
#                 (
                select
                    a1.*
                    ,concat(a1.staff_info_id, a1.third_sorting_code) staff_code
                from
                    (
                        select
                            t1.store_id
                            ,t1.pno
                            ,t1.staff_info_id
                            ,if(t1.formal = 1 and t1.store_id = t1.hr_store_id, 'y', 'n') is_self
                            ,t1.state
                            ,t1.job_title
                            ,ps.third_sorting_code
                            ,rank() over (partition by t1.pno order by ps.created_at desc) rk
                        from t t1
                        join my_drds_pro.parcel_sorting_code_info ps on  ps.pno = t1.pno and ps.dst_store_id = t1.store_id and ps.third_sorting_code != 'XX'
                    ) a1
                where
                    a1.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ds.dst_store_id as store_id
        ,pr.pno
        ,hst.sys_store_id hr_store_id
        ,hst.formal
        ,pr.staff_info_id
        ,pi.state
        ,hst.job_title
    from dwm.dwd_my_dc_should_be_delivery ds
    left join my_staging.parcel_route pr on pr.pno = ds.pno and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    left join my_staging.parcel_info pi on pi.pno = pr.pno
    left join my_bi.hr_staff_info hst on hst.staff_info_id = pr.staff_info_id
#     left join ph_bi.hr_staff_transfer hst  on hst.staff_info_id = pr.staff_info_id
    where
        ds.p_date = '2023-08-05'
        and pr.routed_at >= date_sub('2023-08-05', interval 8 hour )
        and pr.routed_at < date_add('2023-08-05', interval 16 hour)
        and ds.should_delevry_type != '非当日应派'
#         and hst.stat_date = '${date}'
        and ds.dst_store_id = 'MY09090108'
)
#     select
#         dr.store_id 网点ID
#         ,dr.store_name 网点
#         ,coalesce(dr.opening_at, '未记录') 开业时间
#         ,case ss.category
#             when 1 then 'SP'
#             when 2 then 'DC'
#             when 4 then 'SHOP'
#             when 5 then 'SHOP'
#             when 6 then 'FH'
#             when 7 then 'SHOP'
#             when 8 then 'Hub'
#             when 9 then 'Onsite'
#             when 10 then 'BDC'
#             when 11 then 'fulfillment'
#             when 12 then 'B-HUB'
#             when 13 then 'CDC'
#             when 14 then 'PDC'
#         end 网点类型
#         ,smp.name 片区
#         ,smr.name 大区
#         ,coalesce(emp_cnt.staf_num, 0) 总快递员人数_在职
#         ,coalesce(a3.self_staff_num, 0) 自有快递员出勤数
#         ,coalesce(a3.other_staff_num, 0) '外协+支援快递员出勤数'
#         ,coalesce(a3.dco_dcs_num, 0) 仓管主管_出勤数
#
#         ,coalesce(a3.avg_scan_num, 0) 快递员平均交接量
#         ,coalesce(a3.avg_del_num, 0) 快递员平均妥投量
#         ,coalesce(a3.dco_dcs_avg_scan, 0) 仓管主管_平均交接量
#
#         ,coalesce(sdb.code_num, 0) 网点三段码数量
#         ,coalesce(a2.self_avg_staff_code, 0) 自有快递员三段码平均交接量
#         ,coalesce(a2.other_avg_staff_code, 0) '外协+支援快递员三段码平均交接量'
#         ,coalesce(a2.self_avg_staff_del_code, 0) 自有快递员三段码平均妥投量
#         ,coalesce(a2.other_avg_staff_del_code, 0) '外协+支援快递员三段码平均妥投量'
#         ,coalesce(a2.avg_code_staff, 0) 三段码平均交接快递员数
#         ,case
#             when a2.avg_code_staff < 2 then 'A'
#             when a2.avg_code_staff >= 2 and a2.avg_code_staff < 3 then 'B'
#             when a2.avg_code_staff >= 3 and a2.avg_code_staff < 4 then 'C'
#             when a2.avg_code_staff >= 4 then 'D'
#         end 评级
#         ,a2.code_num
#         ,a2.staff_code_num
#         ,a2.staff_num
#         ,a2.fin_staff_code_num
#     from
#         (
#             select
#                 a1.store_id
#                 ,count(distinct if(a1.job_title in (13,110,1 ), a1.staff_code, null)) staff_code_num
#                 ,count(distinct if(a1.job_title in (13,110,1199), a1.third_sorting_code, null)) code_num
#                 ,count(distinct if(a1.job_title in (13,110,1199), a1.staff_info_id, null)) staff_num
#                 ,count(distinct if(a1.job_title in (13,110,1199), a1.staff_code, null)) fin_staff_code_num
#                 ,count(distinct if(a1.job_title in (13,110,1199), a1.staff_code, null))/ count(distinct if(a1.job_title in (13,110,1199), a1.third_sorting_code, null)) avg_code_staff
#                 ,count(distinct if(a1.is_self = 'y' and a1.job_title in (13,110,1199), a1.staff_code, null))/count(distinct if(a1.is_self = 'y' and a1.job_title in (13,110,1199), a1.staff_info_id, null)) self_avg_staff_code
#                 ,count(distinct if(a1.is_self = 'n' and a1.job_title in (13,110,1199), a1.staff_code, null))/count(distinct if(a1.is_self = 'n' and a1.job_title in (13,110,1199), a1.staff_info_id, null)) other_avg_staff_code
#                 ,count(distinct if(a1.state = 5 and a1.is_self = 'y' and a1.job_title in (13,110,1199), a1.staff_code, null))/count(distinct if(a1.is_self = 'y' and a1.job_title in (13,110,1199), a1.staff_info_id, null)) self_avg_staff_del_code
#                 ,count(distinct if(a1.state = 5 and a1.is_self = 'n' and a1.job_title in (13,110,1199), a1.staff_code, null))/count(distinct if(a1.is_self = 'n' and a1.job_title in (13,110,1199), a1.staff_info_id, null)) other_avg_staff_del_code
#             from
#                 (
                select
                    a1.*
                    ,concat(a1.staff_info_id, a1.third_sorting_code) staff_code
                from
                    (
                        select
                            t1.store_id
                            ,t1.pno
                            ,t1.staff_info_id
                            ,if(t1.formal = 1 and t1.store_id = t1.hr_store_id, 'y', 'n') is_self
                            ,t1.state
                            ,t1.job_title
                            ,ps.third_sorting_code
                            ,rank() over (partition by t1.pno order by ps.created_at desc) rk
                        from t t1
                        join my_drds_pro.parcel_sorting_code_info ps on  ps.pno = t1.pno and ps.dst_store_id = t1.store_id and ps.third_sorting_code != 'XX'
                    ) a1
                where
                    a1.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ds.dst_store_id as store_id
        ,pr.pno
        ,hst.sys_store_id hr_store_id
        ,hst.formal
        ,pr.staff_info_id
        ,pi.state
        ,hst.job_title
    from dwm.dwd_my_dc_should_be_delivery ds
    left join my_staging.parcel_route pr on pr.pno = ds.pno and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    left join my_staging.parcel_info pi on pi.pno = pr.pno
    left join my_bi.hr_staff_info hst on hst.staff_info_id = pr.staff_info_id
#     left join ph_bi.hr_staff_transfer hst  on hst.staff_info_id = pr.staff_info_id
    where
        ds.p_date = '2023-08-05'
        and pr.routed_at >= date_sub('2023-08-05', interval 8 hour )
        and pr.routed_at < date_add('2023-08-05', interval 16 hour)
        and ds.should_delevry_type != '非当日应派'
#         and hst.stat_date = '${date}'
#         and ds.dst_store_id = 'MY09090108'
)
#     select
#         dr.store_id 网点ID
#         ,dr.store_name 网点
#         ,coalesce(dr.opening_at, '未记录') 开业时间
#         ,case ss.category
#             when 1 then 'SP'
#             when 2 then 'DC'
#             when 4 then 'SHOP'
#             when 5 then 'SHOP'
#             when 6 then 'FH'
#             when 7 then 'SHOP'
#             when 8 then 'Hub'
#             when 9 then 'Onsite'
#             when 10 then 'BDC'
#             when 11 then 'fulfillment'
#             when 12 then 'B-HUB'
#             when 13 then 'CDC'
#             when 14 then 'PDC'
#         end 网点类型
#         ,smp.name 片区
#         ,smr.name 大区
#         ,coalesce(emp_cnt.staf_num, 0) 总快递员人数_在职
#         ,coalesce(a3.self_staff_num, 0) 自有快递员出勤数
#         ,coalesce(a3.other_staff_num, 0) '外协+支援快递员出勤数'
#         ,coalesce(a3.dco_dcs_num, 0) 仓管主管_出勤数
#
#         ,coalesce(a3.avg_scan_num, 0) 快递员平均交接量
#         ,coalesce(a3.avg_del_num, 0) 快递员平均妥投量
#         ,coalesce(a3.dco_dcs_avg_scan, 0) 仓管主管_平均交接量
#
#         ,coalesce(sdb.code_num, 0) 网点三段码数量
#         ,coalesce(a2.self_avg_staff_code, 0) 自有快递员三段码平均交接量
#         ,coalesce(a2.other_avg_staff_code, 0) '外协+支援快递员三段码平均交接量'
#         ,coalesce(a2.self_avg_staff_del_code, 0) 自有快递员三段码平均妥投量
#         ,coalesce(a2.other_avg_staff_del_code, 0) '外协+支援快递员三段码平均妥投量'
#         ,coalesce(a2.avg_code_staff, 0) 三段码平均交接快递员数
#         ,case
#             when a2.avg_code_staff < 2 then 'A'
#             when a2.avg_code_staff >= 2 and a2.avg_code_staff < 3 then 'B'
#             when a2.avg_code_staff >= 3 and a2.avg_code_staff < 4 then 'C'
#             when a2.avg_code_staff >= 4 then 'D'
#         end 评级
#         ,a2.code_num
#         ,a2.staff_code_num
#         ,a2.staff_num
#         ,a2.fin_staff_code_num
#     from
#         (
#             select
#                 a1.store_id
#                 ,count(distinct if(a1.job_title in (13,110,1 ), a1.staff_code, null)) staff_code_num
#                 ,count(distinct if(a1.job_title in (13,110,1199), a1.third_sorting_code, null)) code_num
#                 ,count(distinct if(a1.job_title in (13,110,1199), a1.staff_info_id, null)) staff_num
#                 ,count(distinct if(a1.job_title in (13,110,1199), a1.staff_code, null)) fin_staff_code_num
#                 ,count(distinct if(a1.job_title in (13,110,1199), a1.staff_code, null))/ count(distinct if(a1.job_title in (13,110,1199), a1.third_sorting_code, null)) avg_code_staff
#                 ,count(distinct if(a1.is_self = 'y' and a1.job_title in (13,110,1199), a1.staff_code, null))/count(distinct if(a1.is_self = 'y' and a1.job_title in (13,110,1199), a1.staff_info_id, null)) self_avg_staff_code
#                 ,count(distinct if(a1.is_self = 'n' and a1.job_title in (13,110,1199), a1.staff_code, null))/count(distinct if(a1.is_self = 'n' and a1.job_title in (13,110,1199), a1.staff_info_id, null)) other_avg_staff_code
#                 ,count(distinct if(a1.state = 5 and a1.is_self = 'y' and a1.job_title in (13,110,1199), a1.staff_code, null))/count(distinct if(a1.is_self = 'y' and a1.job_title in (13,110,1199), a1.staff_info_id, null)) self_avg_staff_del_code
#                 ,count(distinct if(a1.state = 5 and a1.is_self = 'n' and a1.job_title in (13,110,1199), a1.staff_code, null))/count(distinct if(a1.is_self = 'n' and a1.job_title in (13,110,1199), a1.staff_info_id, null)) other_avg_staff_del_code
#             from
#                 (
                select
                    a1.*
                    ,concat(a1.staff_info_id, a1.third_sorting_code) staff_code
                from
                    (
                        select
                            t1.store_id
                            ,t1.pno
                            ,t1.staff_info_id
                            ,if(t1.formal = 1 and t1.store_id = t1.hr_store_id, 'y', 'n') is_self
                            ,t1.state
                            ,t1.job_title
                            ,ps.third_sorting_code
                            ,rank() over (partition by t1.pno order by ps.created_at desc) rk
                        from t t1
                        join my_drds_pro.parcel_sorting_code_info ps on  ps.pno = t1.pno and ps.dst_store_id = t1.store_id and ps.third_sorting_code != 'XX'
                    ) a1
                where
                    a1.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ds.dst_store_id as store_id
        ,pr.pno
        ,hst.sys_store_id hr_store_id
        ,hst.formal
        ,pr.staff_info_id
        ,pi.state
        ,hst.job_title
    from dwm.dwd_my_dc_should_be_delivery ds
    left join my_staging.parcel_route pr on pr.pno = ds.pno and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    left join my_staging.parcel_info pi on pi.pno = pr.pno
    left join my_bi.hr_staff_info hst on hst.staff_info_id = pr.staff_info_id
#     left join ph_bi.hr_staff_transfer hst  on hst.staff_info_id = pr.staff_info_id
    where
        ds.p_date = '2023-08-05'
        and pr.routed_at >= date_sub('2023-08-05', interval 8 hour )
        and pr.routed_at < date_add('2023-08-05', interval 16 hour)
        and ds.should_delevry_type != '非当日应派'
#         and hst.stat_date = '${date}'
#         and ds.dst_store_id = 'MY09090108'
)
    select
        dr.store_id 网点ID
        ,dr.store_name 网点
        ,coalesce(dr.opening_at, '未记录') 开业时间
        ,case ss.category
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
        end 网点类型
        ,smp.name 片区
        ,smr.name 大区
        ,coalesce(emp_cnt.staf_num, 0) 总快递员人数_在职
        ,coalesce(a3.self_staff_num, 0) 自有快递员出勤数
        ,coalesce(a3.other_staff_num, 0) '外协+支援快递员出勤数'
        ,coalesce(a3.dco_dcs_num, 0) 仓管主管_出勤数

        ,coalesce(a3.avg_scan_num, 0) 快递员平均交接量
        ,coalesce(a3.avg_del_num, 0) 快递员平均妥投量
        ,coalesce(a3.dco_dcs_avg_scan, 0) 仓管主管_平均交接量

        ,coalesce(sdb.code_num, 0) 网点三段码数量
        ,coalesce(a2.self_avg_staff_code, 0) 自有快递员三段码平均交接量
        ,coalesce(a2.other_avg_staff_code, 0) '外协+支援快递员三段码平均交接量'
        ,coalesce(a2.self_avg_staff_del_code, 0) 自有快递员三段码平均妥投量
        ,coalesce(a2.other_avg_staff_del_code, 0) '外协+支援快递员三段码平均妥投量'
        ,coalesce(a2.avg_code_staff, 0) 三段码平均交接快递员数
        ,case
            when a2.avg_code_staff < 2 then 'A'
            when a2.avg_code_staff >= 2 and a2.avg_code_staff < 3 then 'B'
            when a2.avg_code_staff >= 3 and a2.avg_code_staff < 4 then 'C'
            when a2.avg_code_staff >= 4 then 'D'
        end 评级
        ,a2.code_num
        ,a2.staff_code_num
        ,a2.staff_num
        ,a2.fin_staff_code_num
    from
        (
            select
                a1.store_id
                ,count(distinct if(a1.job_title in (13,110,1 ), a1.staff_code, null)) staff_code_num
                ,count(distinct if(a1.job_title in (13,110,1199), a1.third_sorting_code, null)) code_num
                ,count(distinct if(a1.job_title in (13,110,1199), a1.staff_info_id, null)) staff_num
                ,count(distinct if(a1.job_title in (13,110,1199), a1.staff_code, null)) fin_staff_code_num
                ,count(distinct if(a1.job_title in (13,110,1199), a1.staff_code, null))/ count(distinct if(a1.job_title in (13,110,1199), a1.third_sorting_code, null)) avg_code_staff
                ,count(distinct if(a1.is_self = 'y' and a1.job_title in (13,110,1199), a1.staff_code, null))/count(distinct if(a1.is_self = 'y' and a1.job_title in (13,110,1199), a1.staff_info_id, null)) self_avg_staff_code
                ,count(distinct if(a1.is_self = 'n' and a1.job_title in (13,110,1199), a1.staff_code, null))/count(distinct if(a1.is_self = 'n' and a1.job_title in (13,110,1199), a1.staff_info_id, null)) other_avg_staff_code
                ,count(distinct if(a1.state = 5 and a1.is_self = 'y' and a1.job_title in (13,110,1199), a1.staff_code, null))/count(distinct if(a1.is_self = 'y' and a1.job_title in (13,110,1199), a1.staff_info_id, null)) self_avg_staff_del_code
                ,count(distinct if(a1.state = 5 and a1.is_self = 'n' and a1.job_title in (13,110,1199), a1.staff_code, null))/count(distinct if(a1.is_self = 'n' and a1.job_title in (13,110,1199), a1.staff_info_id, null)) other_avg_staff_del_code
            from
                (
                select
                    a1.*
                    ,concat(a1.staff_info_id, a1.third_sorting_code) staff_code
                from
                    (
                        select
                            t1.store_id
                            ,t1.pno
                            ,t1.staff_info_id
                            ,if(t1.formal = 1 and t1.store_id = t1.hr_store_id, 'y', 'n') is_self
                            ,t1.state
                            ,t1.job_title
                            ,ps.third_sorting_code
                            ,rank() over (partition by t1.pno order by ps.created_at desc) rk
                        from t t1
                        join my_drds_pro.parcel_sorting_code_info ps on  ps.pno = t1.pno and ps.dst_store_id = t1.store_id and ps.third_sorting_code not in  ('XX', 'YY', 'ZZ', '00')
                    ) a1
                where
                    a1.rk = 1
            ) a1
        left join my_staging.parcel_info pi on pi.pno = a1.pno
        group by 1
    ) a2
left join
    (
        select
            hr.sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  my_bi.hr_staff_info  hr
        where
            hr.formal = 1
            and hr.is_sub_staff= 0
            and hr.state = 1
            and hr.job_title in (13,110,1199)
        group by 1
    ) emp_cnt on emp_cnt.sys_store_id = a2.store_id
# left join
#     (
#         select
#            ad.sys_store_id
#            ,count(distinct ad.staff_info_id) as atd_emp_cnt -- 出勤人数
#        from ph_bi.attendance_data_v2 ad
#        left join ph_bi.hr_staff_info hr on hr.staff_info_id =ad.staff_info_id
#        where
#            (ad.attendance_started_at is not null or ad.attendance_end_at is not null)
#             and hr.job_title in (13,110,1000)
# #             and ad.stat_date = curdate()
#             and ad.stat_date = '${date}'
#        group by 1
#     ) att on att.sys_store_id = a2.store_id
left join dwm.dim_my_sys_store_rd dr on dr.store_id = a2.store_id and dr.stat_date = date_sub(curdate(), interval 1 day)
left join my_staging.sys_store ss on ss.id = a2.store_id
left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
left join
    (
        select
            t1.store_id
            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.formal = 1  and t1.job_title in (13,110,1199), t1.staff_info_id, null))  self_staff_num
            ,count(distinct if(t1.job_title in (13,110,1199) and ( t1.hr_store_id != t1.store_id or t1.formal != 1  ), t1.staff_info_id, null )) other_staff_num
            ,count(distinct if(t1.job_title in (13,110,1199), t1.pno, null))/count(distinct if(t1.job_title in (13,110,1199),  t1.staff_info_id, null)) avg_scan_num
            ,count(distinct if(t1.job_title in (13,110,1199) and t1.state = 5, t1.pno, null))/count(distinct if(t1.job_title in (13,110,1199) and t1.state = 5,  t1.staff_info_id, null)) avg_del_num

            ,count(distinct if(t1.job_title in (37,16), t1.staff_info_id, null)) dco_dcs_num
            ,count(distinct if(t1.job_title in (37,16), t1.pno, null))/count(distinct if(t1.job_title in (37,16), t1.staff_info_id, null)) dco_dcs_avg_scan
        from t t1
        group by 1
    ) a3  on a3.store_id = a2.store_id
left join
    (
        select
            sdb.store_id
            ,count(distinct sdb.district_code) code_num
        from my_staging.store_delivery_barangay_group_info sdb
        where
            sdb.deleted = 0
            and sdb.district_code not in  ('XX', 'YY', 'ZZ', '00')
        group by 1
    ) sdb on sdb.store_id = a2.store_id
where
    ss.category in (1,10)
    and sdb.store_id is not null;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ds.dst_store_id store_id
        ,ss.name
        ,ds.pno
        ,convert_tz(pi.finished_at, '+00:00', '+08:00') finished_time
        ,pi.ticket_delivery_staff_info_id
        ,pi.state
        ,hsi.store_id hr_store_id
        ,coalesce(hsi.job_title, hs.job_title) job_title
        ,coalesce(hsi.formal, hs.formal) formal
        ,row_number() over (partition by ds.dst_store_id, pi.ticket_delivery_staff_info_id order by pi.finished_at) rk1
        ,row_number() over (partition by ds.dst_store_id, pi.ticket_delivery_staff_info_id order by pi.finished_at desc) rk2
    from dwm.dwd_my_dc_should_be_delivery ds
    join my_staging.parcel_info pi on pi.pno = ds.pno
    left join my_staging.sys_store ss on ss.id = ds.dst_store_id
    left join my_bi.hr_staff_transfer hsi on hsi.staff_info_id = pi.ticket_delivery_staff_info_id and hsi.stat_date = '2023-08-05'
    left join my_bi.hr_staff_info hs on hs.staff_info_id = pi.ticket_delivery_staff_info_id and if(hs.leave_date is null, 1 = 1, hs.leave_date >= '2023-08-05')
#     left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pi.ticket_delivery_staff_info_id
    where
        pi.state = 5
#         and pi.finished_at >= '2023-08-01 16:00:00'
#         and pi.finished_at < '2023-08-02 16:00:00'
        and ds.p_date = '2023-08-05'
        and pi.finished_at >= date_sub('2023-08-05', interval 8 hour )
        and pi.finished_at < date_add('2023-08-05', interval 16 hour)
        and ds.should_delevry_type != '非当日应派'
#         and ds.dst_store_id = 'PH81180100'
)
select
    dp.store_id 网点ID
    ,dp.store_name 网点
    ,coalesce(dp.opening_at, '未记录') 开业时间
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,coalesce(cour.staf_num, 0) 本网点所属快递员数
    ,coalesce(ds.sd_num, 0) 应派件量
    ,coalesce(del.pno_num, 0) '妥投量(快递员+仓管+主管)'
    ,coalesce(del_cou.self_staff_num, 0) 参与妥投快递员_自有
    ,coalesce(del_cou.other_staff_num, 0) 参与妥投快递员_外协支援
    ,coalesce(del_cou.dco_dcs_num, 0) 参与妥投_仓管主管

    ,coalesce(del_cou.self_effect, 0) 当日人效_自有
    ,coalesce(del_cou.other_effect, 0) 当日人效_外协支援
    ,coalesce(del_cou.dco_dcs_effect, 0) 仓管主管人效
    ,coalesce(del_hour.avg_del_hour, 0) 派件小时数
from
    (
        select
            dp.store_id
            ,dp.store_name
            ,dp.opening_at
            ,dp.piece_name
            ,dp.region_name
        from dwm.dim_my_sys_store_rd dp
        left join my_staging.sys_store ss on ss.id = dp.store_id
        where
            dp.state_desc = '激活'
            and dp.stat_date = date_sub(curdate(), interval 1 day)
            and ss.category in (1,10)
    ) dp
left join
    (
        select
            hr.store_id sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  my_bi.hr_staff_transfer   hr
        where
            hr.formal = 1
            and hr.state = 1
            and hr.job_title in (13,110,1000)
            and hr.stat_date = '2023-08-05'
        group by 1
    ) cour on cour.sys_store_id = dp.store_id
left join
    (
        select
            ds.dst_store_id
            ,count(distinct ds.pno) sd_num
        from dwm.dwd_my_dc_should_be_delivery ds
        where
             ds.should_delevry_type != '非当日应派'
            and ds.p_date = '2023-08-05'
        group by 1
    ) ds on ds.dst_store_id = dp.store_id
left join
    (
        select
            t1.store_id
            ,count(distinct t1.pno) pno_num
        from t t1
        group by 1
    ) del on del.store_id = dp.store_id
left join
    (
        select
            t1.store_id
            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (13,110,1199) and t1.formal = 1, t1.ticket_delivery_staff_info_id, null)) self_staff_num
            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (13,110,1199) and t1.formal = 1, t1.pno, null))/count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (13,110,1199) and t1.formal = 1, t1.ticket_delivery_staff_info_id, null)) self_effect
            ,count(distinct if((t1.hr_store_id != t1.store_id or t1.formal != 1) and t1.job_title in (13,110,1199), t1.ticket_delivery_staff_info_id, null)) other_staff_num
            ,count(distinct if((t1.hr_store_id != t1.store_id or t1.formal != 1) and t1.job_title in (13,110,1199), t1.pno, null))/count(distinct if((t1.hr_store_id != t1.store_id or t1.formal != 1) and t1.job_title in (13,110,1199), t1.ticket_delivery_staff_info_id, null)) other_effect

            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (16,37), t1.ticket_delivery_staff_info_id, null)) dco_dcs_num
            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (16,37), t1.pno, null))/count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (16,37), t1.ticket_delivery_staff_info_id, null)) dco_dcs_effect
        from t t1
        group by 1
    ) del_cou on del_cou.store_id = dp.store_id
left join
    (
        select
            a.store_id
            ,a.name
            ,sum(diff_hour)/count(distinct a.ticket_delivery_staff_info_id) avg_del_hour
        from
            (
                select
                    t1.store_id
                    ,t1.name
                    ,t1.ticket_delivery_staff_info_id
                    ,t1.finished_time
                    ,t2.finished_time finished_at_2
                    ,timestampdiff(second, t1.finished_time, t2.finished_time)/3600 diff_hour
                from
                    (
                        select * from t t1 where t1.rk1 = 1
                    ) t1
                join
                    (
                        select * from t t2 where t2.rk2 = 2
                    ) t2 on t2.store_id = t1.store_id and t2.ticket_delivery_staff_info_id = t1.ticket_delivery_staff_info_id
            ) a
        group by 1,2
    ) del_hour on del_hour.store_id = dp.store_id;
;-- -. . -..- - / . -. - .-. -.--
select
        ds.dst_store_id store_id
        ,ss.name
        ,ds.pno
        ,convert_tz(pi.finished_at, '+00:00', '+08:00') finished_time
        ,pi.ticket_delivery_staff_info_id
        ,pi.state
        ,hsi.store_id hr_store_id
        ,coalesce(hsi.job_title, hs.job_title) job_title
        ,coalesce(hsi.formal, hs.formal) formal
        ,row_number() over (partition by ds.dst_store_id, pi.ticket_delivery_staff_info_id order by pi.finished_at) rk1
        ,row_number() over (partition by ds.dst_store_id, pi.ticket_delivery_staff_info_id order by pi.finished_at desc) rk2
    from dwm.dwd_my_dc_should_be_delivery ds
    join my_staging.parcel_info pi on pi.pno = ds.pno
    left join my_staging.sys_store ss on ss.id = ds.dst_store_id
    left join my_bi.hr_staff_transfer hsi on hsi.staff_info_id = pi.ticket_delivery_staff_info_id and hsi.stat_date = '2023-08-05'
    left join my_bi.hr_staff_info hs on hs.staff_info_id = pi.ticket_delivery_staff_info_id and if(hs.leave_date is null, 1 = 1, hs.leave_date >= '2023-08-05')
#     left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pi.ticket_delivery_staff_info_id
    where
        pi.state = 5
#         and pi.finished_at >= '2023-08-01 16:00:00'
#         and pi.finished_at < '2023-08-02 16:00:00'
        and ds.p_date = '2023-08-05'
        and pi.finished_at >= date_sub('2023-08-05', interval 8 hour )
        and pi.finished_at < date_add('2023-08-05', interval 16 hour)
        and ds.should_delevry_type != '非当日应派';
;-- -. . -..- - / . -. - .-. -.--
with d as
(
    select
         ds.dst_store_id store_id
        ,ds.pno
        ,ds.p_date stat_date
    from dwm.dwd_my_dc_should_be_delivery ds
    where
        ds.should_delevry_type = '1派应派包裹'
        and ds.p_date = '2023-08-06'
)
, t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
    from d ds
    left join
        (
            select
                pr.pno
                ,ds.stat_date
                ,max(convert_tz(pr.routed_at,'+00:00','+08:00')) remote_marker_time
            from my_staging.parcel_route pr
            join d ds on pr.pno = ds.pno
            where 1=1
                and pr.routed_at >= date_sub(ds.stat_date, interval 8 hour)
                and pr.routed_at < date_add(ds.stat_date, interval 16 hour)
                and pr.route_action = 'DETAIN_WAREHOUSE'
                and pr.marker_category in (42,43) ##岛屿,偏远地区
            group by 1,2
        ) pr1  on ds.pno = pr1.pno and ds.stat_date = pr1.stat_date  #当日留仓标记为偏远地区留待次日派送
    left join
        (
            select
               pr.pno
                ,ds.stat_date
               ,convert_tz(pr.routed_at,'+00:00','+08:00') reschedule_marker_time
               ,row_number() over(partition by ds.stat_date, pr.pno order by pr.routed_at desc) rk
            from my_staging.parcel_route pr
            join d ds on ds.pno = pr.pno
            where 1=1
                and pr.routed_at >= date_sub(ds.stat_date ,interval 15 day)
                and pr.routed_at <  date_sub(ds.stat_date ,interval 8 hour) #限定当日之前的改约
                and pr.route_action = 'DETAIN_WAREHOUSE'
                and from_unixtime(json_extract(pr.extra_value,'$.desiredat')) > date_add(ds.stat_date, interval 16 hour)
                and pr.marker_category in (9,14,70) ##客户改约时间
        ) pr2 on ds.pno = pr2.pno and pr2.stat_date = ds.stat_date and  pr2.rk = 1 #当日之前客户改约时间
    left join my_bi .dc_should_delivery_today ds1 on ds.pno = ds1.pno and ds1.state = 6 and ds1.stat_date = date_sub(ds.stat_date,interval 1 day)
    where
        case
            when pr1.pno is not null then 'N'
            when pr2.pno is not null then 'N'
            when ds1.pno is not null  then 'N'  else 'Y'
        end = 'Y'
)
select
    a2.*
from
    (
        select
            a.stat_date 日期
            ,a.store_id 网点ID
            ,ss.name 网点名称
            ,ss.opening_at 开业日期
            ,smr.name 大区
            ,smp.name 片区
            ,a.应交接
            ,a.已交接
            ,date_format(ft.plan_arrive_time, '%Y-%m-%d %H:%i:%s') 计划到达时间
            ,date_format(ft.real_arrive_time, '%Y-%m-%d %H:%i:%s') Kit到港考勤
            ,date_format(ft.sign_time, '%Y-%m-%d %H:%i:%s') fleet签到时间
            ,concat(round(a.交接率*100,2),'%') as 交接率
            ,concat(ifnull(a.a_check,''), ifnull(a.b_check,''), ifnull(a.d_check,''), ifnull(a.e_check,''),if(a.a_check is null  and a.d_check is null and a.b_check is null and a.e_check is null, 'C', '')) 交接评级
            ,concat(round(a.A_rate * 100,2),'%')  'A时段（<0930 ）'
            ,concat(round(a.B_rate * 100,2),'%') 'B时段（0930<=X<1200）'
            ,concat(round(a.C_rate * 100,2),'%')'C时段（1200<=X<1600 ）'
            ,concat(round(a.D_rate * 100,2),'%')'D时段（>=1600）'
            ,row_number() over (partition by date(ft.real_arrive_time), ft.next_store_id order by ft.real_arrive_time) rk
        from
            (
                select
                    t1.store_id
                    ,t1.stat_date
                    ,count(t1.pno) 应交接
                    ,count(if(sc.pno is not null , t1.pno, null)) 已交接
                    ,count(if(sc.pno is not null , t1.pno, null))/count(t1.pno) 交接率

                    ,count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as A_rate
                    ,count(if(time(sc.route_time) >= '09:30:00' and time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as B_rate
                    ,count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as C_rate
                    ,count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as D_rate

                    ,if(count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.95, 'A', null ) a_check
                    ,if(count(if(time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.98 and count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) <= 0.95, 'B', null ) b_check
                    ,if(count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03, 'D', null ) d_check
                    ,if(count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03 , 'E', null ) e_check
                from t t1
                left join
                    (
                        select
                            sc.*
                        from
                            (
                                select
                                    pr.pno
                                    ,pr.store_id
                                    ,pr.store_name
                                    ,t1.stat_date
                                    ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                                    ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                                    ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
                                from my_staging.parcel_route pr
                                join t t1 on t1.pno = pr.pno
                                where
                                    pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                                   and pr.routed_at >= date_sub(t1.stat_date, interval 8 hour)
                                  and pr.routed_at < date_add(t1.stat_date, interval 16 hour )
                            ) sc
                        where
                            sc.rk = 1
                    ) sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
                group by 1,2
            ) a
        left join my_staging.sys_store ss on ss.id = a.store_id
        left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
        left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
        left join my_bi.fleet_time ft on ft.next_store_id = ss.id and ft.arrive_type in (3,5) and date(ft.real_arrive_time) = a.stat_date
        where
            ss.category = 1
            and ss.id not in ('MY04040316','MY04040315','MY04070217')
    ) a2
where
    a2.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ds.dst_store_id as store_id
        ,pr.pno
        ,hst.sys_store_id hr_store_id
        ,hst.formal
        ,pr.staff_info_id
        ,pi.state
        ,hst.job_title
    from dwm.dwd_my_dc_should_be_delivery ds
    left join my_staging.parcel_route pr on pr.pno = ds.pno and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    left join my_staging.parcel_info pi on pi.pno = pr.pno
    left join my_bi.hr_staff_info hst on hst.staff_info_id = pr.staff_info_id
#     left join ph_bi.hr_staff_transfer hst  on hst.staff_info_id = pr.staff_info_id
    where
        ds.p_date = '2023-08-05'
        and pr.routed_at >= date_sub('2023-08-05', interval 8 hour )
        and pr.routed_at < date_add('2023-08-05', interval 16 hour)
        and ds.should_delevry_type != '非当日应派'
#         and hst.stat_date = '${date}'
#         and ds.dst_store_id = 'MY09090108'
)
    select
        dr.store_id 网点ID
        ,dr.store_name 网点
        ,coalesce(dr.opening_at, '未记录') 开业时间
        ,case ss.category
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
        end 网点类型
        ,smp.name 片区
        ,smr.name 大区
        ,coalesce(emp_cnt.staf_num, 0) 总快递员人数_在职
        ,coalesce(a3.self_staff_num, 0) 自有快递员出勤数
        ,coalesce(a3.other_staff_num, 0) '外协+支援快递员出勤数'
        ,coalesce(a3.dco_dcs_num, 0) 仓管主管_出勤数

        ,coalesce(a3.avg_scan_num, 0) 快递员平均交接量
        ,coalesce(a3.avg_del_num, 0) 快递员平均妥投量
        ,coalesce(a3.dco_dcs_avg_scan, 0) 仓管主管_平均交接量

        ,coalesce(sdb.code_num, 0) 网点三段码数量
        ,coalesce(a2.self_avg_staff_code, 0) 自有快递员三段码平均交接量
        ,coalesce(a2.other_avg_staff_code, 0) '外协+支援快递员三段码平均交接量'
        ,coalesce(a2.self_avg_staff_del_code, 0) 自有快递员三段码平均妥投量
        ,coalesce(a2.other_avg_staff_del_code, 0) '外协+支援快递员三段码平均妥投量'
        ,coalesce(a2.avg_code_staff, 0) 三段码平均交接快递员数
        ,case
            when a2.avg_code_staff < 2 then 'A'
            when a2.avg_code_staff >= 2 and a2.avg_code_staff < 3 then 'B'
            when a2.avg_code_staff >= 3 and a2.avg_code_staff < 4 then 'C'
            when a2.avg_code_staff >= 4 then 'D'
        end 评级
        ,a2.code_num
        ,a2.staff_code_num
        ,a2.staff_num
        ,a2.fin_staff_code_num
    from
        (
            select
                a1.store_id
                ,count(distinct if(a1.job_title in (13,110,1 ), a1.staff_code, null)) staff_code_num
                ,count(distinct if(a1.job_title in (13,110,1199), a1.third_sorting_code, null)) code_num
                ,count(distinct if(a1.job_title in (13,110,1199), a1.staff_info_id, null)) staff_num
                ,count(distinct if(a1.job_title in (13,110,1199), a1.staff_code, null)) fin_staff_code_num
                ,count(distinct if(a1.job_title in (13,110,1199), a1.staff_code, null))/ count(distinct if(a1.job_title in (13,110,1199), a1.third_sorting_code, null)) avg_code_staff
                ,count(distinct if(a1.is_self = 'y' and a1.job_title in (13,110,1199), a1.staff_code, null))/count(distinct if(a1.is_self = 'y' and a1.job_title in (13,110,1199), a1.staff_info_id, null)) self_avg_staff_code
                ,count(distinct if(a1.is_self = 'n' and a1.job_title in (13,110,1199), a1.staff_code, null))/count(distinct if(a1.is_self = 'n' and a1.job_title in (13,110,1199), a1.staff_info_id, null)) other_avg_staff_code
                ,count(distinct if(a1.state = 5 and a1.is_self = 'y' and a1.job_title in (13,110,1199), a1.staff_code, null))/count(distinct if(a1.is_self = 'y' and a1.job_title in (13,110,1199), a1.staff_info_id, null)) self_avg_staff_del_code
                ,count(distinct if(a1.state = 5 and a1.is_self = 'n' and a1.job_title in (13,110,1199), a1.staff_code, null))/count(distinct if(a1.is_self = 'n' and a1.job_title in (13,110,1199), a1.staff_info_id, null)) other_avg_staff_del_code
            from
                (
                select
                    a1.*
                    ,concat(a1.staff_info_id, a1.third_sorting_code) staff_code
                from
                    (
                        select
                            t1.store_id
                            ,t1.pno
                            ,t1.staff_info_id
                            ,if(t1.formal = 1 and t1.store_id = t1.hr_store_id, 'y', 'n') is_self
                            ,t1.state
                            ,t1.job_title
                            ,ps.third_sorting_code
                            ,rank() over (partition by t1.pno order by ps.created_at desc) rk
                        from t t1
                        join my_drds_pro.parcel_sorting_code_info ps on  ps.pno = t1.pno and ps.dst_store_id = t1.store_id and ps.third_sorting_code not in  ('XX', 'YY', 'ZZ', '00')
                    ) a1
                where
                    a1.rk = 1
            ) a1
        left join my_staging.parcel_info pi on pi.pno = a1.pno
        group by 1
    ) a2
left join
    (
        select
            hr.sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  my_bi.hr_staff_info  hr
        where
            hr.formal = 1
            and hr.is_sub_staff= 0
            and hr.state = 1
            and hr.job_title in (13,110,1199)
        group by 1
    ) emp_cnt on emp_cnt.sys_store_id = a2.store_id
# left join
#     (
#         select
#            ad.sys_store_id
#            ,count(distinct ad.staff_info_id) as atd_emp_cnt -- 出勤人数
#        from ph_bi.attendance_data_v2 ad
#        left join ph_bi.hr_staff_info hr on hr.staff_info_id =ad.staff_info_id
#        where
#            (ad.attendance_started_at is not null or ad.attendance_end_at is not null)
#             and hr.job_title in (13,110,1000)
# #             and ad.stat_date = curdate()
#             and ad.stat_date = '${date}'
#        group by 1
#     ) att on att.sys_store_id = a2.store_id
left join dwm.dim_my_sys_store_rd dr on dr.store_id = a2.store_id and dr.stat_date = date_sub(curdate(), interval 1 day)
left join my_staging.sys_store ss on ss.id = a2.store_id
left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
left join
    (
        select
            t1.store_id
            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.formal = 1  and t1.job_title in (13,110,1199), t1.staff_info_id, null))  self_staff_num
            ,count(distinct if(t1.job_title in (13,110,1199) and ( t1.hr_store_id != t1.store_id or t1.formal != 1  ), t1.staff_info_id, null )) other_staff_num
            ,count(distinct if(t1.job_title in (13,110,1199), t1.pno, null))/count(distinct if(t1.job_title in (13,110,1199),  t1.staff_info_id, null)) avg_scan_num
            ,count(distinct if(t1.job_title in (13,110,1199) and t1.state = 5, t1.pno, null))/count(distinct if(t1.job_title in (13,110,1199) and t1.state = 5,  t1.staff_info_id, null)) avg_del_num

            ,count(distinct if(t1.job_title in (37,16), t1.staff_info_id, null)) dco_dcs_num
            ,count(distinct if(t1.job_title in (37,16), t1.pno, null))/count(distinct if(t1.job_title in (37,16), t1.staff_info_id, null)) dco_dcs_avg_scan
        from t t1
        group by 1
    ) a3  on a3.store_id = a2.store_id
left join
    (
        select
            gl.store_id
            ,count(distinct gl.grid_code) code_num
        from `my-amp`.grid_lib gl
        group by 1
    ) sdb on sdb.store_id = a2.store_id
where
    ss.category in (1,10)
    and sdb.store_id is not null;
;-- -. . -..- - / . -. - .-. -.--
select
        ds.dst_store_id as store_id
        ,pr.pno
        ,hst.sys_store_id hr_store_id
        ,hst.formal
        ,pr.staff_info_id
        ,pi.state
        ,hst.job_title
    from dwm.dwd_my_dc_should_be_delivery ds
    left join my_staging.parcel_route pr on pr.pno = ds.pno and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    left join my_staging.parcel_info pi on pi.pno = pr.pno
    left join my_bi.hr_staff_info hst on hst.staff_info_id = pr.staff_info_id
#     left join ph_bi.hr_staff_transfer hst  on hst.staff_info_id = pr.staff_info_id
    where
        ds.p_date = '2023-08-05'
        and pr.routed_at >= date_sub('2023-08-05', interval 8 hour )
        and pr.routed_at < date_add('2023-08-05', interval 16 hour)
        and ds.should_delevry_type != '非当日应派';
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ds.dst_store_id as store_id
        ,pr.pno
        ,hst.sys_store_id hr_store_id
        ,hst.formal
        ,pr.staff_info_id
        ,pi.state
        ,hst.job_title
    from dwm.dwd_my_dc_should_be_delivery ds
    left join my_staging.parcel_route pr on pr.pno = ds.pno and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    left join my_staging.parcel_info pi on pi.pno = pr.pno
    left join my_bi.hr_staff_info hst on hst.staff_info_id = pr.staff_info_id
#     left join ph_bi.hr_staff_transfer hst  on hst.staff_info_id = pr.staff_info_id
    where
        ds.p_date = '2023-08-05'
        and pr.routed_at >= date_sub('2023-08-05', interval 8 hour )
        and pr.routed_at < date_add('2023-08-05', interval 16 hour)
        and ds.should_delevry_type != '非当日应派'
)
    select
        dr.store_id 网点ID
        ,dr.store_name 网点
        ,coalesce(dr.opening_at, '未记录') 开业时间
        ,case ss.category
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
        end 网点类型
        ,smp.name 片区
        ,smr.name 大区
        ,coalesce(emp_cnt.staf_num, 0) 总快递员人数_在职
        ,coalesce(a3.self_staff_num, 0) 自有快递员出勤数
        ,coalesce(a3.other_staff_num, 0) '外协+支援快递员出勤数'
        ,coalesce(a3.dco_dcs_num, 0) 仓管主管_出勤数

        ,coalesce(a3.avg_scan_num, 0) 快递员平均交接量
        ,coalesce(a3.avg_del_num, 0) 快递员平均妥投量
        ,coalesce(a3.dco_dcs_avg_scan, 0) 仓管主管_平均交接量

        ,coalesce(sdb.code_num, 0) 网点三段码数量
        ,coalesce(a2.self_avg_staff_code, 0) 自有快递员三段码平均交接量
        ,coalesce(a2.other_avg_staff_code, 0) '外协+支援快递员三段码平均交接量'
        ,coalesce(a2.self_avg_staff_del_code, 0) 自有快递员三段码平均妥投量
        ,coalesce(a2.other_avg_staff_del_code, 0) '外协+支援快递员三段码平均妥投量'
        ,coalesce(a2.avg_code_staff, 0) 三段码平均交接快递员数
        ,case
            when a2.avg_code_staff < 2 then 'A'
            when a2.avg_code_staff >= 2 and a2.avg_code_staff < 3 then 'B'
            when a2.avg_code_staff >= 3 and a2.avg_code_staff < 4 then 'C'
            when a2.avg_code_staff >= 4 then 'D'
        end 评级
        ,a2.code_num
        ,a2.staff_code_num
        ,a2.staff_num
        ,a2.fin_staff_code_num
    from
        (
            select
                a1.store_id
                ,count(distinct if(a1.job_title in (13,110,1 ), a1.staff_code, null)) staff_code_num
                ,count(distinct if(a1.job_title in (13,110,1199), a1.third_sorting_code, null)) code_num
                ,count(distinct if(a1.job_title in (13,110,1199), a1.staff_info_id, null)) staff_num
                ,count(distinct if(a1.job_title in (13,110,1199), a1.staff_code, null)) fin_staff_code_num
                ,count(distinct if(a1.job_title in (13,110,1199), a1.staff_code, null))/ count(distinct if(a1.job_title in (13,110,1199), a1.third_sorting_code, null)) avg_code_staff
                ,count(distinct if(a1.is_self = 'y' and a1.job_title in (13,110,1199), a1.staff_code, null))/count(distinct if(a1.is_self = 'y' and a1.job_title in (13,110,1199), a1.staff_info_id, null)) self_avg_staff_code
                ,count(distinct if(a1.is_self = 'n' and a1.job_title in (13,110,1199), a1.staff_code, null))/count(distinct if(a1.is_self = 'n' and a1.job_title in (13,110,1199), a1.staff_info_id, null)) other_avg_staff_code
                ,count(distinct if(a1.state = 5 and a1.is_self = 'y' and a1.job_title in (13,110,1199), a1.staff_code, null))/count(distinct if(a1.is_self = 'y' and a1.job_title in (13,110,1199), a1.staff_info_id, null)) self_avg_staff_del_code
                ,count(distinct if(a1.state = 5 and a1.is_self = 'n' and a1.job_title in (13,110,1199), a1.staff_code, null))/count(distinct if(a1.is_self = 'n' and a1.job_title in (13,110,1199), a1.staff_info_id, null)) other_avg_staff_del_code
            from
                (
                select
                    a1.*
                    ,concat(a1.staff_info_id, a1.third_sorting_code) staff_code
                from
                    (
                        select
                            t1.store_id
                            ,t1.pno
                            ,t1.staff_info_id
                            ,if(t1.formal = 1 and t1.store_id = t1.hr_store_id, 'y', 'n') is_self
                            ,t1.state
                            ,t1.job_title
                            ,ps.third_sorting_code
                            ,rank() over (partition by t1.pno order by ps.created_at desc) rk
                        from t t1
                        join my_drds_pro.parcel_sorting_code_info ps on  ps.pno = t1.pno and ps.dst_store_id = t1.store_id and ps.third_sorting_code not in  ('XX', 'YY', 'ZZ', '00')
                    ) a1
                where
                    a1.rk = 1
            ) a1
        left join my_staging.parcel_info pi on pi.pno = a1.pno
        group by 1
    ) a2
left join
    (
        select
            hr.sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  my_bi.hr_staff_info  hr
        where
            hr.formal = 1
            and hr.is_sub_staff= 0
            and hr.state = 1
            and hr.job_title in (13,110,1199)
        group by 1
    ) emp_cnt on emp_cnt.sys_store_id = a2.store_id
# left join
#     (
#         select
#            ad.sys_store_id
#            ,count(distinct ad.staff_info_id) as atd_emp_cnt -- 出勤人数
#        from ph_bi.attendance_data_v2 ad
#        left join ph_bi.hr_staff_info hr on hr.staff_info_id =ad.staff_info_id
#        where
#            (ad.attendance_started_at is not null or ad.attendance_end_at is not null)
#             and hr.job_title in (13,110,1000)
# #             and ad.stat_date = curdate()
#             and ad.stat_date = '${date}'
#        group by 1
#     ) att on att.sys_store_id = a2.store_id
left join dwm.dim_my_sys_store_rd dr on dr.store_id = a2.store_id and dr.stat_date = date_sub(curdate(), interval 1 day)
left join my_staging.sys_store ss on ss.id = a2.store_id
left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
left join
    (
        select
            t1.store_id
            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.formal = 1  and t1.job_title in (13,110,1199), t1.staff_info_id, null))  self_staff_num
            ,count(distinct if(t1.job_title in (13,110,1199) and ( t1.hr_store_id != t1.store_id or t1.formal != 1  ), t1.staff_info_id, null )) other_staff_num
            ,count(distinct if(t1.job_title in (13,110,1199), t1.pno, null))/count(distinct if(t1.job_title in (13,110,1199),  t1.staff_info_id, null)) avg_scan_num
            ,count(distinct if(t1.job_title in (13,110,1199) and t1.state = 5, t1.pno, null))/count(distinct if(t1.job_title in (13,110,1199) and t1.state = 5,  t1.staff_info_id, null)) avg_del_num

            ,count(distinct if(t1.job_title in (37,16), t1.staff_info_id, null)) dco_dcs_num
            ,count(distinct if(t1.job_title in (37,16), t1.pno, null))/count(distinct if(t1.job_title in (37,16), t1.staff_info_id, null)) dco_dcs_avg_scan
        from t t1
        group by 1
    ) a3  on a3.store_id = a2.store_id
left join
    (
        select
            gl.store_id
            ,count(distinct gl.grid_code) code_num
        from `my-amp`.grid_lib gl
        group by 1
    ) sdb on sdb.store_id = a2.store_id
where
    ss.category in (1,10)
    and sdb.store_id is not null;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ds.dst_store_id as store_id
        ,pr.pno
        ,hst.sys_store_id hr_store_id
        ,hst.formal
        ,pr.staff_info_id
        ,pi.state
        ,hst.job_title
    from dwm.dwd_my_dc_should_be_delivery ds
    left join my_staging.parcel_route pr on pr.pno = ds.pno and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    left join my_staging.parcel_info pi on pi.pno = pr.pno
    left join my_bi.hr_staff_info hst on hst.staff_info_id = pr.staff_info_id
#     left join ph_bi.hr_staff_transfer hst  on hst.staff_info_id = pr.staff_info_id
    where
        ds.p_date = '2023-08-06'
        and pr.routed_at >= date_sub('2023-08-06', interval 8 hour )
        and pr.routed_at < date_add('2023-08-06', interval 16 hour)
        and ds.should_delevry_type != '非当日应派'
)
    select
        dr.store_id 网点ID
        ,dr.store_name 网点
        ,coalesce(dr.opening_at, '未记录') 开业时间
        ,case ss.category
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
        end 网点类型
        ,smp.name 片区
        ,smr.name 大区
        ,coalesce(emp_cnt.staf_num, 0) 总快递员人数_在职
        ,coalesce(a3.self_staff_num, 0) 自有快递员出勤数
        ,coalesce(a3.other_staff_num, 0) '外协+支援快递员出勤数'
        ,coalesce(a3.dco_dcs_num, 0) 仓管主管_出勤数

        ,coalesce(a3.avg_scan_num, 0) 快递员平均交接量
        ,coalesce(a3.avg_del_num, 0) 快递员平均妥投量
        ,coalesce(a3.dco_dcs_avg_scan, 0) 仓管主管_平均交接量

        ,coalesce(sdb.code_num, 0) 网点三段码数量
        ,coalesce(a2.self_avg_staff_code, 0) 自有快递员三段码平均交接量
        ,coalesce(a2.other_avg_staff_code, 0) '外协+支援快递员三段码平均交接量'
        ,coalesce(a2.self_avg_staff_del_code, 0) 自有快递员三段码平均妥投量
        ,coalesce(a2.other_avg_staff_del_code, 0) '外协+支援快递员三段码平均妥投量'
        ,coalesce(a2.avg_code_staff, 0) 三段码平均交接快递员数
        ,case
            when a2.avg_code_staff < 2 then 'A'
            when a2.avg_code_staff >= 2 and a2.avg_code_staff < 3 then 'B'
            when a2.avg_code_staff >= 3 and a2.avg_code_staff < 4 then 'C'
            when a2.avg_code_staff >= 4 then 'D'
        end 评级
        ,a2.code_num
        ,a2.staff_code_num
        ,a2.staff_num
        ,a2.fin_staff_code_num
    from
        (
            select
                a1.store_id
                ,count(distinct if(a1.job_title in (13,110,1 ), a1.staff_code, null)) staff_code_num
                ,count(distinct if(a1.job_title in (13,110,1199), a1.third_sorting_code, null)) code_num
                ,count(distinct if(a1.job_title in (13,110,1199), a1.staff_info_id, null)) staff_num
                ,count(distinct if(a1.job_title in (13,110,1199), a1.staff_code, null)) fin_staff_code_num
                ,count(distinct if(a1.job_title in (13,110,1199), a1.staff_code, null))/ count(distinct if(a1.job_title in (13,110,1199), a1.third_sorting_code, null)) avg_code_staff
                ,count(distinct if(a1.is_self = 'y' and a1.job_title in (13,110,1199), a1.staff_code, null))/count(distinct if(a1.is_self = 'y' and a1.job_title in (13,110,1199), a1.staff_info_id, null)) self_avg_staff_code
                ,count(distinct if(a1.is_self = 'n' and a1.job_title in (13,110,1199), a1.staff_code, null))/count(distinct if(a1.is_self = 'n' and a1.job_title in (13,110,1199), a1.staff_info_id, null)) other_avg_staff_code
                ,count(distinct if(a1.state = 5 and a1.is_self = 'y' and a1.job_title in (13,110,1199), a1.staff_code, null))/count(distinct if(a1.is_self = 'y' and a1.job_title in (13,110,1199), a1.staff_info_id, null)) self_avg_staff_del_code
                ,count(distinct if(a1.state = 5 and a1.is_self = 'n' and a1.job_title in (13,110,1199), a1.staff_code, null))/count(distinct if(a1.is_self = 'n' and a1.job_title in (13,110,1199), a1.staff_info_id, null)) other_avg_staff_del_code
            from
                (
                select
                    a1.*
                    ,concat(a1.staff_info_id, a1.third_sorting_code) staff_code
                from
                    (
                        select
                            t1.store_id
                            ,t1.pno
                            ,t1.staff_info_id
                            ,if(t1.formal = 1 and t1.store_id = t1.hr_store_id, 'y', 'n') is_self
                            ,t1.state
                            ,t1.job_title
                            ,ps.third_sorting_code
                            ,rank() over (partition by t1.pno order by ps.created_at desc) rk
                        from t t1
                        join my_drds_pro.parcel_sorting_code_info ps on  ps.pno = t1.pno and ps.dst_store_id = t1.store_id and ps.third_sorting_code not in  ('XX', 'YY', 'ZZ', '00')
                    ) a1
                where
                    a1.rk = 1
            ) a1
        left join my_staging.parcel_info pi on pi.pno = a1.pno
        group by 1
    ) a2
left join
    (
        select
            hr.sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  my_bi.hr_staff_info  hr
        where
            hr.formal = 1
            and hr.is_sub_staff= 0
            and hr.state = 1
            and hr.job_title in (13,110,1199)
        group by 1
    ) emp_cnt on emp_cnt.sys_store_id = a2.store_id
# left join
#     (
#         select
#            ad.sys_store_id
#            ,count(distinct ad.staff_info_id) as atd_emp_cnt -- 出勤人数
#        from ph_bi.attendance_data_v2 ad
#        left join ph_bi.hr_staff_info hr on hr.staff_info_id =ad.staff_info_id
#        where
#            (ad.attendance_started_at is not null or ad.attendance_end_at is not null)
#             and hr.job_title in (13,110,1000)
# #             and ad.stat_date = curdate()
#             and ad.stat_date = '${date}'
#        group by 1
#     ) att on att.sys_store_id = a2.store_id
left join dwm.dim_my_sys_store_rd dr on dr.store_id = a2.store_id and dr.stat_date = date_sub(curdate(), interval 1 day)
left join my_staging.sys_store ss on ss.id = a2.store_id
left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
left join
    (
        select
            t1.store_id
            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.formal = 1  and t1.job_title in (13,110,1199), t1.staff_info_id, null))  self_staff_num
            ,count(distinct if(t1.job_title in (13,110,1199) and ( t1.hr_store_id != t1.store_id or t1.formal != 1  ), t1.staff_info_id, null )) other_staff_num
            ,count(distinct if(t1.job_title in (13,110,1199), t1.pno, null))/count(distinct if(t1.job_title in (13,110,1199),  t1.staff_info_id, null)) avg_scan_num
            ,count(distinct if(t1.job_title in (13,110,1199) and t1.state = 5, t1.pno, null))/count(distinct if(t1.job_title in (13,110,1199) and t1.state = 5,  t1.staff_info_id, null)) avg_del_num

            ,count(distinct if(t1.job_title in (37,16), t1.staff_info_id, null)) dco_dcs_num
            ,count(distinct if(t1.job_title in (37,16), t1.pno, null))/count(distinct if(t1.job_title in (37,16), t1.staff_info_id, null)) dco_dcs_avg_scan
        from t t1
        group by 1
    ) a3  on a3.store_id = a2.store_id
left join
    (
        select
            gl.store_id
            ,count(distinct gl.grid_code) code_num
        from `my-amp`.grid_lib gl
        group by 1
    ) sdb on sdb.store_id = a2.store_id
where
    ss.category in (1,10)
    and sdb.store_id is not null;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ds.dst_store_id store_id
        ,ss.name
        ,ds.pno
        ,convert_tz(pi.finished_at, '+00:00', '+08:00') finished_time
        ,pi.ticket_delivery_staff_info_id
        ,pi.state
        ,hsi.store_id hr_store_id
        ,coalesce(hsi.job_title, hs.job_title) job_title
        ,coalesce(hsi.formal, hs.formal) formal
        ,row_number() over (partition by ds.dst_store_id, pi.ticket_delivery_staff_info_id order by pi.finished_at) rk1
        ,row_number() over (partition by ds.dst_store_id, pi.ticket_delivery_staff_info_id order by pi.finished_at desc) rk2
    from dwm.dwd_my_dc_should_be_delivery ds
    join my_staging.parcel_info pi on pi.pno = ds.pno
    left join my_staging.sys_store ss on ss.id = ds.dst_store_id
    left join my_bi.hr_staff_transfer hsi on hsi.staff_info_id = pi.ticket_delivery_staff_info_id and hsi.stat_date = '2023-08-06'
    left join my_bi.hr_staff_info hs on hs.staff_info_id = pi.ticket_delivery_staff_info_id and if(hs.leave_date is null, 1 = 1, hs.leave_date >= '2023-08-06')
#     left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pi.ticket_delivery_staff_info_id
    where
        pi.state = 5
#         and pi.finished_at >= '2023-08-01 16:00:00'
#         and pi.finished_at < '2023-08-02 16:00:00'
        and ds.p_date = '2023-08-06'
        and pi.finished_at >= date_sub('2023-08-06', interval 8 hour )
        and pi.finished_at < date_add('2023-08-06', interval 16 hour)
        and ds.should_delevry_type != '非当日应派'
#         and ds.dst_store_id = 'PH81180100'
)
select
    dp.store_id 网点ID
    ,dp.store_name 网点
    ,coalesce(dp.opening_at, '未记录') 开业时间
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,coalesce(cour.staf_num, 0) 本网点所属快递员数
    ,coalesce(ds.sd_num, 0) 应派件量
    ,coalesce(del.pno_num, 0) '妥投量(快递员+仓管+主管)'
    ,coalesce(del_cou.self_staff_num, 0) 参与妥投快递员_自有
    ,coalesce(del_cou.other_staff_num, 0) 参与妥投快递员_外协支援
    ,coalesce(del_cou.dco_dcs_num, 0) 参与妥投_仓管主管

    ,coalesce(del_cou.self_effect, 0) 当日人效_自有
    ,coalesce(del_cou.other_effect, 0) 当日人效_外协支援
    ,coalesce(del_cou.dco_dcs_effect, 0) 仓管主管人效
    ,coalesce(del_hour.avg_del_hour, 0) 派件小时数
from
    (
        select
            dp.store_id
            ,dp.store_name
            ,dp.opening_at
            ,dp.piece_name
            ,dp.region_name
        from dwm.dim_my_sys_store_rd dp
        left join my_staging.sys_store ss on ss.id = dp.store_id
        where
            dp.state_desc = '激活'
            and dp.stat_date = date_sub(curdate(), interval 1 day)
            and ss.category in (1,10)
    ) dp
left join
    (
        select
            hr.store_id sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  my_bi.hr_staff_transfer   hr
        where
            hr.formal = 1
            and hr.state = 1
            and hr.job_title in (13,110,1199)
            and hr.stat_date = '2023-08-06'
        group by 1
    ) cour on cour.sys_store_id = dp.store_id
left join
    (
        select
            ds.dst_store_id
            ,count(distinct ds.pno) sd_num
        from dwm.dwd_my_dc_should_be_delivery ds
        where
             ds.should_delevry_type != '非当日应派'
            and ds.p_date = '2023-08-06'
        group by 1
    ) ds on ds.dst_store_id = dp.store_id
left join
    (
        select
            t1.store_id
            ,count(distinct t1.pno) pno_num
        from t t1
        group by 1
    ) del on del.store_id = dp.store_id
left join
    (
        select
            t1.store_id
            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (13,110,1199) and t1.formal = 1, t1.ticket_delivery_staff_info_id, null)) self_staff_num
            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (13,110,1199) and t1.formal = 1, t1.pno, null))/count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (13,110,1199) and t1.formal = 1, t1.ticket_delivery_staff_info_id, null)) self_effect
            ,count(distinct if((t1.hr_store_id != t1.store_id or t1.formal != 1) and t1.job_title in (13,110,1199), t1.ticket_delivery_staff_info_id, null)) other_staff_num
            ,count(distinct if((t1.hr_store_id != t1.store_id or t1.formal != 1) and t1.job_title in (13,110,1199), t1.pno, null))/count(distinct if((t1.hr_store_id != t1.store_id or t1.formal != 1) and t1.job_title in (13,110,1199), t1.ticket_delivery_staff_info_id, null)) other_effect

            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (16,37), t1.ticket_delivery_staff_info_id, null)) dco_dcs_num
            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (16,37), t1.pno, null))/count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (16,37), t1.ticket_delivery_staff_info_id, null)) dco_dcs_effect
        from t t1
        group by 1
    ) del_cou on del_cou.store_id = dp.store_id
left join
    (
        select
            a.store_id
            ,a.name
            ,sum(diff_hour)/count(distinct a.ticket_delivery_staff_info_id) avg_del_hour
        from
            (
                select
                    t1.store_id
                    ,t1.name
                    ,t1.ticket_delivery_staff_info_id
                    ,t1.finished_time
                    ,t2.finished_time finished_at_2
                    ,timestampdiff(second, t1.finished_time, t2.finished_time)/3600 diff_hour
                from
                    (
                        select * from t t1 where t1.rk1 = 1
                    ) t1
                join
                    (
                        select * from t t2 where t2.rk2 = 2
                    ) t2 on t2.store_id = t1.store_id and t2.ticket_delivery_staff_info_id = t1.ticket_delivery_staff_info_id
            ) a
        group by 1,2
    ) del_hour on del_hour.store_id = dp.store_id;
;-- -. . -..- - / . -. - .-. -.--
select
        ds.dst_store_id store_id
        ,ss.name
        ,ds.pno
        ,convert_tz(pi.finished_at, '+00:00', '+08:00') finished_time
        ,pi.ticket_delivery_staff_info_id
        ,pi.state
        ,hsi.store_id hr_store_id
        ,coalesce(hsi.job_title, hs.job_title) job_title
        ,coalesce(hsi.formal, hs.formal) formal
        ,row_number() over (partition by ds.dst_store_id, pi.ticket_delivery_staff_info_id order by pi.finished_at) rk1
        ,row_number() over (partition by ds.dst_store_id, pi.ticket_delivery_staff_info_id order by pi.finished_at desc) rk2
    from dwm.dwd_my_dc_should_be_delivery ds
    join my_staging.parcel_info pi on pi.pno = ds.pno
    left join my_staging.sys_store ss on ss.id = ds.dst_store_id
    left join my_bi.hr_staff_transfer hsi on hsi.staff_info_id = pi.ticket_delivery_staff_info_id and hsi.stat_date = '2023-08-06'
    left join my_bi.hr_staff_info hs on hs.staff_info_id = pi.ticket_delivery_staff_info_id and if(hs.leave_date is null, 1 = 1, hs.leave_date >= '2023-08-06')
#     left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pi.ticket_delivery_staff_info_id
    where
        pi.state = 5
#         and pi.finished_at >= '2023-08-01 16:00:00'
#         and pi.finished_at < '2023-08-02 16:00:00'
        and ds.p_date = '2023-08-06'
        and pi.finished_at >= date_sub('2023-08-06', interval 8 hour )
        and pi.finished_at < date_add('2023-08-06', interval 16 hour)
        and ds.should_delevry_type != '非当日应派';
;-- -. . -..- - / . -. - .-. -.--
select
        ds.dst_store_id store_id
        ,ss.name
        ,ds.pno
        ,convert_tz(pi.finished_at, '+00:00', '+08:00') finished_time
        ,pi.ticket_delivery_staff_info_id
        ,pi.state
        ,coalesce(hsi.store_id, hs.sys_store_id) hr_store_id
        ,coalesce(hsi.job_title, hs.job_title) job_title
        ,coalesce(hsi.formal, hs.formal) formal
        ,row_number() over (partition by ds.dst_store_id, pi.ticket_delivery_staff_info_id order by pi.finished_at) rk1
        ,row_number() over (partition by ds.dst_store_id, pi.ticket_delivery_staff_info_id order by pi.finished_at desc) rk2
    from dwm.dwd_my_dc_should_be_delivery ds
    join my_staging.parcel_info pi on pi.pno = ds.pno
    left join my_staging.sys_store ss on ss.id = ds.dst_store_id
    left join my_bi.hr_staff_transfer hsi on hsi.staff_info_id = pi.ticket_delivery_staff_info_id and hsi.stat_date = '2023-08-06'
    left join my_bi.hr_staff_info hs on hs.staff_info_id = pi.ticket_delivery_staff_info_id and if(hs.leave_date is null, 1 = 1, hs.leave_date >= '2023-08-06')
#     left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pi.ticket_delivery_staff_info_id
    where
        pi.state = 5
#         and pi.finished_at >= '2023-08-01 16:00:00'
#         and pi.finished_at < '2023-08-02 16:00:00'
        and ds.p_date = '2023-08-06'
        and pi.finished_at >= date_sub('2023-08-06', interval 8 hour )
        and pi.finished_at < date_add('2023-08-06', interval 16 hour)
        and ds.should_delevry_type != '非当日应派';
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ds.dst_store_id store_id
        ,ss.name
        ,ds.pno
        ,convert_tz(pi.finished_at, '+00:00', '+08:00') finished_time
        ,pi.ticket_delivery_staff_info_id
        ,pi.state
        ,coalesce(hsi.store_id, hs.sys_store_id) hr_store_id
        ,coalesce(hsi.job_title, hs.job_title) job_title
        ,coalesce(hsi.formal, hs.formal) formal
        ,row_number() over (partition by ds.dst_store_id, pi.ticket_delivery_staff_info_id order by pi.finished_at) rk1
        ,row_number() over (partition by ds.dst_store_id, pi.ticket_delivery_staff_info_id order by pi.finished_at desc) rk2
    from dwm.dwd_my_dc_should_be_delivery ds
    join my_staging.parcel_info pi on pi.pno = ds.pno
    left join my_staging.sys_store ss on ss.id = ds.dst_store_id
    left join my_bi.hr_staff_transfer hsi on hsi.staff_info_id = pi.ticket_delivery_staff_info_id and hsi.stat_date = '2023-08-06'
    left join my_bi.hr_staff_info hs on hs.staff_info_id = pi.ticket_delivery_staff_info_id and if(hs.leave_date is null, 1 = 1, hs.leave_date >= '2023-08-06')
#     left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pi.ticket_delivery_staff_info_id
    where
        pi.state = 5
#         and pi.finished_at >= '2023-08-01 16:00:00'
#         and pi.finished_at < '2023-08-02 16:00:00'
        and ds.p_date = '2023-08-06'
        and pi.finished_at >= date_sub('2023-08-06', interval 8 hour )
        and pi.finished_at < date_add('2023-08-06', interval 16 hour)
        and ds.should_delevry_type != '非当日应派'
)
select
    dp.store_id 网点ID
    ,dp.store_name 网点
    ,coalesce(dp.opening_at, '未记录') 开业时间
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,coalesce(cour.staf_num, 0) 本网点所属快递员数
    ,coalesce(ds.sd_num, 0) 应派件量
    ,coalesce(del.pno_num, 0) '妥投量(快递员+仓管+主管)'
    ,coalesce(del_cou.self_staff_num, 0) 参与妥投快递员_自有
    ,coalesce(del_cou.other_staff_num, 0) 参与妥投快递员_外协支援
    ,coalesce(del_cou.dco_dcs_num, 0) 参与妥投_仓管主管

    ,coalesce(del_cou.self_effect, 0) 当日人效_自有
    ,coalesce(del_cou.other_effect, 0) 当日人效_外协支援
    ,coalesce(del_cou.dco_dcs_effect, 0) 仓管主管人效
    ,coalesce(del_hour.avg_del_hour, 0) 派件小时数
from
    (
        select
            dp.store_id
            ,dp.store_name
            ,dp.opening_at
            ,dp.piece_name
            ,dp.region_name
        from dwm.dim_my_sys_store_rd dp
        left join my_staging.sys_store ss on ss.id = dp.store_id
        where
            dp.state_desc = '激活'
            and dp.stat_date = date_sub(curdate(), interval 1 day)
            and ss.category in (1,10)
    ) dp
left join
    (
        select
            hr.store_id sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  my_bi.hr_staff_transfer   hr
        where
            hr.formal = 1
            and hr.state = 1
            and hr.job_title in (13,110,1199)
            and hr.stat_date = '2023-08-06'
        group by 1
    ) cour on cour.sys_store_id = dp.store_id
left join
    (
        select
            ds.dst_store_id
            ,count(distinct ds.pno) sd_num
        from dwm.dwd_my_dc_should_be_delivery ds
        where
             ds.should_delevry_type != '非当日应派'
            and ds.p_date = '2023-08-06'
        group by 1
    ) ds on ds.dst_store_id = dp.store_id
left join
    (
        select
            t1.store_id
            ,count(distinct t1.pno) pno_num
        from t t1
        group by 1
    ) del on del.store_id = dp.store_id
left join
    (
        select
            t1.store_id
            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (13,110,1199) and t1.formal = 1, t1.ticket_delivery_staff_info_id, null)) self_staff_num
            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (13,110,1199) and t1.formal = 1, t1.pno, null))/count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (13,110,1199) and t1.formal = 1, t1.ticket_delivery_staff_info_id, null)) self_effect
            ,count(distinct if((t1.hr_store_id != t1.store_id or t1.formal != 1) and t1.job_title in (13,110,1199), t1.ticket_delivery_staff_info_id, null)) other_staff_num
            ,count(distinct if((t1.hr_store_id != t1.store_id or t1.formal != 1) and t1.job_title in (13,110,1199), t1.pno, null))/count(distinct if((t1.hr_store_id != t1.store_id or t1.formal != 1) and t1.job_title in (13,110,1199), t1.ticket_delivery_staff_info_id, null)) other_effect

            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (16,37), t1.ticket_delivery_staff_info_id, null)) dco_dcs_num
            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (16,37), t1.pno, null))/count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (16,37), t1.ticket_delivery_staff_info_id, null)) dco_dcs_effect
        from t t1
        group by 1
    ) del_cou on del_cou.store_id = dp.store_id
left join
    (
        select
            a.store_id
            ,a.name
            ,sum(diff_hour)/count(distinct a.ticket_delivery_staff_info_id) avg_del_hour
        from
            (
                select
                    t1.store_id
                    ,t1.name
                    ,t1.ticket_delivery_staff_info_id
                    ,t1.finished_time
                    ,t2.finished_time finished_at_2
                    ,timestampdiff(second, t1.finished_time, t2.finished_time)/3600 diff_hour
                from
                    (
                        select * from t t1 where t1.rk1 = 1
                    ) t1
                join
                    (
                        select * from t t2 where t2.rk2 = 2
                    ) t2 on t2.store_id = t1.store_id and t2.ticket_delivery_staff_info_id = t1.ticket_delivery_staff_info_id
            ) a
        group by 1,2
    ) del_hour on del_hour.store_id = dp.store_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ds.dst_store_id store_id
        ,ss.name
        ,ds.pno
        ,convert_tz(pi.finished_at, '+00:00', '+08:00') finished_time
        ,pi.ticket_delivery_staff_info_id
        ,pi.state
        ,coalesce(hsi.store_id, hs.sys_store_id) hr_store_id
        ,coalesce(hsi.job_title, hs.job_title) job_title
        ,coalesce(hsi.formal, hs.formal) formal
        ,row_number() over (partition by ds.dst_store_id, pi.ticket_delivery_staff_info_id order by pi.finished_at) rk1
        ,row_number() over (partition by ds.dst_store_id, pi.ticket_delivery_staff_info_id order by pi.finished_at desc) rk2
    from dwm.dwd_my_dc_should_be_delivery ds
    join my_staging.parcel_info pi on pi.pno = ds.pno
    left join my_staging.sys_store ss on ss.id = ds.dst_store_id
    left join my_bi.hr_staff_transfer hsi on hsi.staff_info_id = pi.ticket_delivery_staff_info_id and hsi.stat_date = '2023-08-06'
    left join my_bi.hr_staff_info hs on hs.staff_info_id = pi.ticket_delivery_staff_info_id and if(hs.leave_date is null, 1 = 1, hs.leave_date >= '2023-08-06')
#     left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pi.ticket_delivery_staff_info_id
    where
        pi.state = 5
#         and pi.finished_at >= '2023-08-01 16:00:00'
#         and pi.finished_at < '2023-08-02 16:00:00'
        and ds.p_date = '2023-08-06'
        and pi.finished_at >= date_sub('2023-08-06', interval 8 hour )
        and pi.finished_at < date_add('2023-08-06', interval 16 hour)
        and ds.should_delevry_type != '非当日应派'
)
select
    dp.store_id 网点ID
    ,dp.store_name 网点
    ,coalesce(dp.opening_at, '未记录') 开业时间
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,coalesce(cour.staf_num, 0) 本网点所属快递员数
    ,coalesce(ds.sd_num, 0) 应派件量
    ,coalesce(del.pno_num, 0) '妥投量(快递员+仓管+主管)'
    ,coalesce(del_cou.self_staff_num, 0) 参与妥投快递员_自有
    ,coalesce(del_cou.other_staff_num, 0) 参与妥投快递员_外协支援
    ,coalesce(del_cou.dco_dcs_num, 0) 参与妥投_仓管主管

    ,coalesce(del_cou.self_effect, 0) 当日人效_自有
    ,coalesce(del_cou.other_effect, 0) 当日人效_外协支援
    ,coalesce(del_cou.dco_dcs_effect, 0) 仓管主管人效
    ,coalesce(del_hour.avg_del_hour, 0) 派件小时数
from
    (
        select
            dp.store_id
            ,dp.store_name
            ,dp.opening_at
            ,dp.piece_name
            ,dp.region_name
        from dwm.dim_my_sys_store_rd dp
        left join my_staging.sys_store ss on ss.id = dp.store_id
        where
            dp.state_desc = '激活'
            and dp.stat_date = date_sub(curdate(), interval 1 day)
            and ss.category in (1,10)
    ) dp
left join
    (
        select
            hr.store_id sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  my_bi.hr_staff_info hr
        where
            hr.formal = 1
            and hr.state = 1
            and hr.job_title in (13,110,1199)
#             and hr.stat_date = '${date}'
        group by 1
    ) cour on cour.sys_store_id = dp.store_id
left join
    (
        select
            ds.dst_store_id
            ,count(distinct ds.pno) sd_num
        from dwm.dwd_my_dc_should_be_delivery ds
        where
             ds.should_delevry_type != '非当日应派'
            and ds.p_date = '2023-08-06'
        group by 1
    ) ds on ds.dst_store_id = dp.store_id
left join
    (
        select
            t1.store_id
            ,count(distinct t1.pno) pno_num
        from t t1
        group by 1
    ) del on del.store_id = dp.store_id
left join
    (
        select
            t1.store_id
            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (13,110,1199) and t1.formal = 1, t1.ticket_delivery_staff_info_id, null)) self_staff_num
            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (13,110,1199) and t1.formal = 1, t1.pno, null))/count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (13,110,1199) and t1.formal = 1, t1.ticket_delivery_staff_info_id, null)) self_effect
            ,count(distinct if((t1.hr_store_id != t1.store_id or t1.formal != 1) and t1.job_title in (13,110,1199), t1.ticket_delivery_staff_info_id, null)) other_staff_num
            ,count(distinct if((t1.hr_store_id != t1.store_id or t1.formal != 1) and t1.job_title in (13,110,1199), t1.pno, null))/count(distinct if((t1.hr_store_id != t1.store_id or t1.formal != 1) and t1.job_title in (13,110,1199), t1.ticket_delivery_staff_info_id, null)) other_effect

            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (16,37), t1.ticket_delivery_staff_info_id, null)) dco_dcs_num
            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (16,37), t1.pno, null))/count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (16,37), t1.ticket_delivery_staff_info_id, null)) dco_dcs_effect
        from t t1
        group by 1
    ) del_cou on del_cou.store_id = dp.store_id
left join
    (
        select
            a.store_id
            ,a.name
            ,sum(diff_hour)/count(distinct a.ticket_delivery_staff_info_id) avg_del_hour
        from
            (
                select
                    t1.store_id
                    ,t1.name
                    ,t1.ticket_delivery_staff_info_id
                    ,t1.finished_time
                    ,t2.finished_time finished_at_2
                    ,timestampdiff(second, t1.finished_time, t2.finished_time)/3600 diff_hour
                from
                    (
                        select * from t t1 where t1.rk1 = 1
                    ) t1
                join
                    (
                        select * from t t2 where t2.rk2 = 2
                    ) t2 on t2.store_id = t1.store_id and t2.ticket_delivery_staff_info_id = t1.ticket_delivery_staff_info_id
            ) a
        group by 1,2
    ) del_hour on del_hour.store_id = dp.store_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ds.dst_store_id store_id
        ,ss.name
        ,ds.pno
        ,convert_tz(pi.finished_at, '+00:00', '+08:00') finished_time
        ,pi.ticket_delivery_staff_info_id
        ,pi.state
        ,coalesce(hsi.store_id, hs.sys_store_id) hr_store_id
        ,coalesce(hsi.job_title, hs.job_title) job_title
        ,coalesce(hsi.formal, hs.formal) formal
        ,row_number() over (partition by ds.dst_store_id, pi.ticket_delivery_staff_info_id order by pi.finished_at) rk1
        ,row_number() over (partition by ds.dst_store_id, pi.ticket_delivery_staff_info_id order by pi.finished_at desc) rk2
    from dwm.dwd_my_dc_should_be_delivery ds
    join my_staging.parcel_info pi on pi.pno = ds.pno
    left join my_staging.sys_store ss on ss.id = ds.dst_store_id
    left join my_bi.hr_staff_transfer hsi on hsi.staff_info_id = pi.ticket_delivery_staff_info_id and hsi.stat_date = '2023-08-06'
    left join my_bi.hr_staff_info hs on hs.staff_info_id = pi.ticket_delivery_staff_info_id and if(hs.leave_date is null, 1 = 1, hs.leave_date >= '2023-08-06')
#     left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pi.ticket_delivery_staff_info_id
    where
        pi.state = 5
#         and pi.finished_at >= '2023-08-01 16:00:00'
#         and pi.finished_at < '2023-08-02 16:00:00'
        and ds.p_date = '2023-08-06'
        and pi.finished_at >= date_sub('2023-08-06', interval 8 hour )
        and pi.finished_at < date_add('2023-08-06', interval 16 hour)
        and ds.should_delevry_type != '非当日应派'
)
select
    dp.store_id 网点ID
    ,dp.store_name 网点
    ,coalesce(dp.opening_at, '未记录') 开业时间
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,coalesce(cour.staf_num, 0) 本网点所属快递员数
    ,coalesce(ds.sd_num, 0) 应派件量
    ,coalesce(del.pno_num, 0) '妥投量(快递员+仓管+主管)'
    ,coalesce(del_cou.self_staff_num, 0) 参与妥投快递员_自有
    ,coalesce(del_cou.other_staff_num, 0) 参与妥投快递员_外协支援
    ,coalesce(del_cou.dco_dcs_num, 0) 参与妥投_仓管主管

    ,coalesce(del_cou.self_effect, 0) 当日人效_自有
    ,coalesce(del_cou.other_effect, 0) 当日人效_外协支援
    ,coalesce(del_cou.dco_dcs_effect, 0) 仓管主管人效
    ,coalesce(del_hour.avg_del_hour, 0) 派件小时数
from
    (
        select
            dp.store_id
            ,dp.store_name
            ,dp.opening_at
            ,dp.piece_name
            ,dp.region_name
        from dwm.dim_my_sys_store_rd dp
        left join my_staging.sys_store ss on ss.id = dp.store_id
        where
            dp.state_desc = '激活'
            and dp.stat_date = date_sub(curdate(), interval 1 day)
            and ss.category in (1,10)
    ) dp
left join
    (
        select
            hr.sys_store_id sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  my_bi.hr_staff_info hr
        where
            hr.formal = 1
            and hr.state = 1
            and hr.job_title in (13,110,1199)
#             and hr.stat_date = '${date}'
        group by 1
    ) cour on cour.sys_store_id = dp.store_id
left join
    (
        select
            ds.dst_store_id
            ,count(distinct ds.pno) sd_num
        from dwm.dwd_my_dc_should_be_delivery ds
        where
             ds.should_delevry_type != '非当日应派'
            and ds.p_date = '2023-08-06'
        group by 1
    ) ds on ds.dst_store_id = dp.store_id
left join
    (
        select
            t1.store_id
            ,count(distinct t1.pno) pno_num
        from t t1
        group by 1
    ) del on del.store_id = dp.store_id
left join
    (
        select
            t1.store_id
            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (13,110,1199) and t1.formal = 1, t1.ticket_delivery_staff_info_id, null)) self_staff_num
            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (13,110,1199) and t1.formal = 1, t1.pno, null))/count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (13,110,1199) and t1.formal = 1, t1.ticket_delivery_staff_info_id, null)) self_effect
            ,count(distinct if((t1.hr_store_id != t1.store_id or t1.formal != 1) and t1.job_title in (13,110,1199), t1.ticket_delivery_staff_info_id, null)) other_staff_num
            ,count(distinct if((t1.hr_store_id != t1.store_id or t1.formal != 1) and t1.job_title in (13,110,1199), t1.pno, null))/count(distinct if((t1.hr_store_id != t1.store_id or t1.formal != 1) and t1.job_title in (13,110,1199), t1.ticket_delivery_staff_info_id, null)) other_effect

            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (16,37), t1.ticket_delivery_staff_info_id, null)) dco_dcs_num
            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (16,37), t1.pno, null))/count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (16,37), t1.ticket_delivery_staff_info_id, null)) dco_dcs_effect
        from t t1
        group by 1
    ) del_cou on del_cou.store_id = dp.store_id
left join
    (
        select
            a.store_id
            ,a.name
            ,sum(diff_hour)/count(distinct a.ticket_delivery_staff_info_id) avg_del_hour
        from
            (
                select
                    t1.store_id
                    ,t1.name
                    ,t1.ticket_delivery_staff_info_id
                    ,t1.finished_time
                    ,t2.finished_time finished_at_2
                    ,timestampdiff(second, t1.finished_time, t2.finished_time)/3600 diff_hour
                from
                    (
                        select * from t t1 where t1.rk1 = 1
                    ) t1
                join
                    (
                        select * from t t2 where t2.rk2 = 2
                    ) t2 on t2.store_id = t1.store_id and t2.ticket_delivery_staff_info_id = t1.ticket_delivery_staff_info_id
            ) a
        group by 1,2
    ) del_hour on del_hour.store_id = dp.store_id;
;-- -. . -..- - / . -. - .-. -.--
with d as
(
    select
         ds.dst_store_id store_id
        ,ds.pno
        ,ds.p_date stat_date
    from dwm.dwd_my_dc_should_be_delivery ds
    where
        ds.should_delevry_type = '1派应派包裹'
        and ds.p_date = '2023-08-06'
)
, t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
    from d ds
    left join
        (
            select
                pr.pno
                ,ds.stat_date
                ,max(convert_tz(pr.routed_at,'+00:00','+08:00')) remote_marker_time
            from my_staging.parcel_route pr
            join d ds on pr.pno = ds.pno
            where 1=1
                and pr.routed_at >= date_sub(ds.stat_date, interval 8 hour)
                and pr.routed_at < date_add(ds.stat_date, interval 16 hour)
                and pr.route_action = 'DETAIN_WAREHOUSE'
                and pr.marker_category in (42,43) ##岛屿,偏远地区
            group by 1,2
        ) pr1  on ds.pno = pr1.pno and ds.stat_date = pr1.stat_date  #当日留仓标记为偏远地区留待次日派送
    left join
        (
            select
               pr.pno
                ,ds.stat_date
               ,convert_tz(pr.routed_at,'+00:00','+08:00') reschedule_marker_time
               ,row_number() over(partition by ds.stat_date, pr.pno order by pr.routed_at desc) rk
            from my_staging.parcel_route pr
            join d ds on ds.pno = pr.pno
            where 1=1
                and pr.routed_at >= date_sub(ds.stat_date ,interval 15 day)
                and pr.routed_at <  date_sub(ds.stat_date ,interval 8 hour) #限定当日之前的改约
                and pr.route_action = 'DETAIN_WAREHOUSE'
                and from_unixtime(json_extract(pr.extra_value,'$.desiredat')) > date_add(ds.stat_date, interval 16 hour)
                and pr.marker_category in (9,14,70) ##客户改约时间
        ) pr2 on ds.pno = pr2.pno and pr2.stat_date = ds.stat_date and  pr2.rk = 1 #当日之前客户改约时间
    left join my_bi .dc_should_delivery_today ds1 on ds.pno = ds1.pno and ds1.state = 6 and ds1.stat_date = date_sub(ds.stat_date,interval 1 day)
    where
        case
            when pr1.pno is not null then 'N'
            when pr2.pno is not null then 'N'
            when ds1.pno is not null  then 'N'  else 'Y'
        end = 'Y'
)
select
    a2.*
from
    (
        select
            a.stat_date 日期
            ,a.store_id 网点ID
            ,ss.name 网点名称
            ,ss.opening_at 开业日期
            ,smr.name 大区
            ,smp.name 片区
            ,a.应交接
            ,a.已交接
            ,date_format(ft.plan_arrive_time, '%Y-%m-%d %H:%i:%s') 计划到达时间
            ,date_format(ft.real_arrive_time, '%Y-%m-%d %H:%i:%s') Kit到港考勤
            ,date_format(ft.sign_time, '%Y-%m-%d %H:%i:%s') fleet签到时间
            ,concat(round(a.交接率*100,2),'%') as 交接率
            ,concat(ifnull(a.a_check,''), ifnull(a.b_check,''), ifnull(a.d_check,''), ifnull(a.e_check,''),if(a.a_check is null  and a.d_check is null and a.b_check is null and a.e_check is null, 'C', '')) 交接评级
            ,concat(round(a.A_rate * 100,2),'%')  'A时段（<0930 ）'
            ,concat(round(a.B_rate * 100,2),'%') 'B时段（0930<=X<1200）'
            ,concat(round(a.C_rate * 100,2),'%')'C时段（1200<=X<1600 ）'
            ,concat(round(a.D_rate * 100,2),'%')'D时段（>=1600）'
            ,row_number() over (partition by date(ft.real_arrive_time), ft.next_store_id order by ft.real_arrive_time) rk
        from
            (
                select
                    t1.store_id
                    ,t1.stat_date
                    ,count(t1.pno) 应交接
                    ,count(if(sc.pno is not null , t1.pno, null)) 已交接
                    ,count(if(sc.pno is not null , t1.pno, null))/count(t1.pno) 交接率

                    ,count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as A_rate
                    ,count(if(time(sc.route_time) >= '09:30:00' and time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as B_rate
                    ,count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as C_rate
                    ,count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as D_rate

                    ,if(count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.95, 'A', null ) a_check
                    ,if(count(if(time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.98 and count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) <= 0.95, 'B', null ) b_check
                    ,if(count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03, 'D', null ) d_check
                    ,if(count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03 , 'E', null ) e_check
                from t t1
                left join
                    (
                        select
                            sc.*
                        from
                            (
                                select
                                    pr.pno
                                    ,pr.store_id
                                    ,pr.store_name
                                    ,t1.stat_date
                                    ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                                    ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                                    ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
                                from my_staging.parcel_route pr
                                join t t1 on t1.pno = pr.pno
                                where
                                    pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                                   and pr.routed_at >= date_sub(t1.stat_date, interval 8 hour)
                                  and pr.routed_at < date_add(t1.stat_date, interval 16 hour )
                            ) sc
                        where
                            sc.rk = 1
                    ) sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
                group by 1,2
            ) a
        left join my_staging.sys_store ss on ss.id = a.store_id
        left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
        left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
        left join my_bi.fleet_time ft on ft.next_store_id = ss.id and ft.arrive_type in (3,5) and date(ft.real_arrive_time) = a.stat_date
        where
            ss.category in (1,10)
            and ss.id not in ('MY04040316','MY04040315','MY04070217')
    ) a2
where
    a2.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        *
    from
        (
            select
                ad.*
                ,row_number() over (partition by ad.staff_info_id order by ad.stat_date desc) rk
            from
                (
                    select
                        ad.*
                        ,ad.attendance_time + ad.BT + ad.CT + ad.BT_Y + ad.AB total
                    from my_bi.attendance_data_v2 ad
                    join my_bi.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,1199,37,16) -- 在职且非待离职
                    where
                        ad.stat_date < curdate()

                ) ad
            where
                ad.total = 10
        ) ad
    where
        ad.rk < 8
)
select
    st.staff_info_id 工号
    ,if(hsi2.sys_store_id = '-1', 'Head office', dp.store_name) 网点
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,case
        when hsi2.job_title in (13,110,1199) then '快递员'
        when hsi2.job_title in (37) then '仓管员'
        when hsi2.job_title in (16) then '主管'
    end 角色
    ,hsi2.job_title
    ,st.late_num 迟到次数
    ,st.absence_sum 缺勤数据
    ,st.late_time_sum 迟到时长
    ,case
        when st.absence_sum = 0 and st.late_num <= 1 and st.late_time_sum < 30 then 'A'
        when st.absence_sum >= 2 or st.late_num >= 3  then 'C'
        else 'B'
    end 出勤评级
from
    (
        select
            a.staff_info_id
            ,count(if(a.late_or_not = 'y' ,a.stat_date, null)) late_num
            ,sum(if(a.late_or_not = 'y', a.late_time, 0)) late_time_sum
            ,sum(a.absence_time) absence_sum
        from
            (
                select
                    t1.*
                    ,if(t1.attendance_started_at > date_add(concat(t1.stat_date, ' ', t1.shift_start), interval 1 minute ) , 'y', 'n') late_or_not
                    ,if(t1.attendance_started_at > date_add(concat(t1.stat_date, ' ', t1.shift_start), interval 1 minute ) , timestampdiff(minute , concat(t1.stat_date, ' ', t1.shift_start), t1.attendance_started_at), 0) late_time
                    ,t1.AB/10 absence_time
                from t t1
            ) a
        group by 1
    ) st
left join my_bi.hr_staff_info hsi2 on hsi2.staff_info_id = st.staff_info_id
left join dwm.dim_my_sys_store_rd dp on dp.store_id = hsi2.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
order by 2,1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        *
    from
        (
            select
                ad.*
                ,row_number() over (partition by ad.staff_info_id order by ad.stat_date desc) rk
            from
                (
                    select
                        ad.*
                        ,ad.attendance_time + ad.BT + ad.CT + ad.BT_Y + ad.AB total
                    from my_bi.attendance_data_v2 ad
                    join my_bi.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,1199,37,16) -- 在职且非待离职
                    where
                        ad.stat_date < curdate()

                ) ad
            where
                ad.total = 10
        ) ad
    where
        ad.rk < 8
)
select
    st.staff_info_id 工号
    ,if(hsi2.sys_store_id = '-1', 'Head office', dp.store_name) 网点
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,case
        when hsi2.job_title in (13,110,1199) then '快递员'
        when hsi2.job_title in (37) then '仓管员'
        when hsi2.job_title in (16) then '主管'
    end 角色
    ,st.late_num 迟到次数
    ,st.absence_sum 缺勤数据
    ,st.late_time_sum 迟到时长
    ,case
        when st.absence_sum = 0 and st.late_num <= 1 and st.late_time_sum < 30 then 'A'
        when st.absence_sum >= 2 or st.late_num >= 3  then 'C'
        else 'B'
    end 出勤评级
from
    (
        select
            a.staff_info_id
            ,count(if(a.late_or_not = 'y' ,a.stat_date, null)) late_num
            ,sum(if(a.late_or_not = 'y', a.late_time, 0)) late_time_sum
            ,sum(a.absence_time) absence_sum
        from
            (
                select
                    t1.*
                    ,if(t1.attendance_started_at > date_add(concat(t1.stat_date, ' ', t1.shift_start), interval 1 minute ) , 'y', 'n') late_or_not
                    ,if(t1.attendance_started_at > date_add(concat(t1.stat_date, ' ', t1.shift_start), interval 1 minute ) , timestampdiff(minute , concat(t1.stat_date, ' ', t1.shift_start), t1.attendance_started_at), 0) late_time
                    ,t1.AB/10 absence_time
                from t t1
            ) a
        group by 1
    ) st
left join my_bi.hr_staff_info hsi2 on hsi2.staff_info_id = st.staff_info_id
left join dwm.dim_my_sys_store_rd dp on dp.store_id = hsi2.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
order by 2,1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        *
    from
        (
            select
                ad.*
                ,row_number() over (partition by ad.staff_info_id order by ad.stat_date desc) rk
            from
                (
                    select
                        ad.*
                        ,ad.attendance_time + ad.BT + ad.CT + ad.BT_Y + ad.AB total
                    from my_bi.attendance_data_v2 ad
                    join my_bi.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,1199,37,16) -- 在职且非待离职
                    where
                        ad.stat_date < curdate()
#                         and hsi.hire_date <= date_sub(curdate(), interval 7 day )
#                         and ad.stat_date >= date_sub(curdate(), interval 30 day )
                ) ad
            where
                ad.total = 10
        ) ad
    where
        ad.rk < 8
)
select
    ss.store_id 网点ID
    ,dp.store_name 网点
    ,coalesce(dp.opening_at, '未记录') 开业时间
    ,case dp.store_category
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
    end 网点类型
    ,dp.region_name 大区
    ,dp.piece_name 片区
    ,case
        when ss.num/dp.on_emp_cnt < 0.05 then 'A'
        when ss.num/dp.on_emp_cnt >= 0.05 and ss.num/dp.on_emp_cnt < 0.1 then 'B'
        when ss.num/dp.on_emp_cnt >= 0.1 then 'C'
    end 出勤评级
    ,ss.num/dp.on_emp_cnt C级员工占比
    ,ss.num C级员工数
    ,dp.on_emp_cnt 在职员工数
    ,dp.on_dcs_cnt 主管数
    ,dp.on_dco_cnt 仓管数
    ,dp.on_dri_cnt 快递员数

    ,ss.avg_absence_num 近7天缺勤人次
    ,ss.avg_absence_num/7 近7天平均每天缺勤人次
    ,ss.avg_late_num 近7天迟到人次
    ,ss.avg_late_num/7 近7天平均每天迟到人次
from
    (
        select
            s.store_id
            ,count(if(s.ss_level = 'C', s.staff_info_id, null)) num
            ,sum(s.late_num) avg_late_num
            ,sum(s.absence_sum) avg_absence_num
        from
            (
                select
                    st.staff_info_id
                    ,dp.store_id
                    ,dp.store_name
                    ,dp.piece_name
                    ,dp.region_name
                    ,case
                        when hsi2.job_title in (13,110,1199) then '快递员'
                        when hsi2.job_title in (37) then '仓管员'
                        when hsi2.job_title in (16) then '主管'
                    end roles
                    ,st.late_num
                    ,st.absence_sum
                    ,case
                        when st.absence_sum = 0 and st.late_num <= 1 and st.late_time_sum < 30 then 'A'
                        when st.absence_sum >= 2 or st.late_num >= 3 then 'C'
                        else 'B'
                    end ss_level
                from
                    (
                        select
                            a.staff_info_id
                            ,count(if(a.late_or_not = 'y' ,a.stat_date, null)) late_num
#                             ,count(if(a.early_or_not = 'y', a.stat_date, null)) early_num
                            ,sum(if(a.late_or_not = 'y', a.late_time, 0)) late_time_sum
#                             ,sum(if(a.early_or_not = 'y', a.early_yime, 0)) early_time_sum
                            ,sum(a.absence_time) absence_sum
                        from
                            (
                                select
                                    t1.*
                                    ,if(t1.attendance_started_at > date_add(concat(t1.stat_date, ' ', t1.shift_start), interval 1 minute ) , 'y', 'n') late_or_not
                                    ,if(t1.attendance_started_at > date_add(concat(t1.stat_date, ' ', t1.shift_start), interval 1 minute ) , timestampdiff(minute , concat(t1.stat_date, ' ', t1.shift_start), t1.attendance_started_at), 0) late_time
#                                     ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, 'y', 'n' ) early_or_not
#                                     ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, timestampdiff(second, t1.attendance_end_at, t1.shift_end)/60, 0) early_yime
                                    ,t1.AB/10 absence_time
                                from t t1
                            ) a
                        group by 1
                    ) st
                left join my_bi.hr_staff_info hsi2 on hsi2.staff_info_id = st.staff_info_id
                left join dwm.dim_my_sys_store_rd dp on dp.store_id = hsi2.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
            ) s
        group by 1
    ) ss
left join
    (
        select
            hsi3.store_id store_id
            ,ss2.name store_name
            ,smp.name piece_name
            ,smr.name region_name
            ,ss2.category store_category
            ,ss2.opening_at
            ,count(if(hsi3.job_title in (13,110,1199,37,16), hsi3.staff_info_id, null)) on_emp_cnt
            ,count(if(hsi3.job_title in (13,110,1199), hsi3.staff_info_id, null)) on_dri_cnt
            ,count(if(hsi3.job_title in (37), hsi3.staff_info_id, null)) on_dco_cnt
            ,count(if(hsi3.job_title in (16), hsi3.staff_info_id, null)) on_dcs_cnt
        from my_bi.hr_staff_transfer  hsi3
        left join my_staging.sys_store ss2 on ss2.id = hsi3.store_id
        left join my_staging.sys_manage_piece smp on smp.id = ss2.manage_piece
        left join my_staging.sys_manage_region smr on smr.id = ss2.manage_region
        where
            hsi3.state = 1
            and hsi3.formal=1
            and hsi3.stat_date = date_sub(curdate(), interval 1 day)
        group by 1,2,3,4,5,6
    )dp on dp.store_id = ss.store_id
where
    dp.store_category in (1,10);
;-- -. . -..- - / . -. - .-. -.--
with d as
(
    select
         ds.dst_store_id store_id
        ,ds.pno
        ,ds.p_date stat_date
    from dwm.dwd_my_dc_should_be_delivery ds
    where
        ds.should_delevry_type = '1派应派包裹'
        and ds.p_date = '2023-08-07'
)
, t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
    from d ds
    left join
        (
            select
                pr.pno
                ,ds.stat_date
                ,max(convert_tz(pr.routed_at,'+00:00','+08:00')) remote_marker_time
            from my_staging.parcel_route pr
            join d ds on pr.pno = ds.pno
            where 1=1
                and pr.routed_at >= date_sub(ds.stat_date, interval 8 hour)
                and pr.routed_at < date_add(ds.stat_date, interval 16 hour)
                and pr.route_action = 'DETAIN_WAREHOUSE'
                and pr.marker_category in (42,43) ##岛屿,偏远地区
            group by 1,2
        ) pr1  on ds.pno = pr1.pno and ds.stat_date = pr1.stat_date  #当日留仓标记为偏远地区留待次日派送
    left join
        (
            select
               pr.pno
                ,ds.stat_date
               ,convert_tz(pr.routed_at,'+00:00','+08:00') reschedule_marker_time
               ,row_number() over(partition by ds.stat_date, pr.pno order by pr.routed_at desc) rk
            from my_staging.parcel_route pr
            join d ds on ds.pno = pr.pno
            where 1=1
                and pr.routed_at >= date_sub(ds.stat_date ,interval 15 day)
                and pr.routed_at <  date_sub(ds.stat_date ,interval 8 hour) #限定当日之前的改约
                and pr.route_action = 'DETAIN_WAREHOUSE'
                and from_unixtime(json_extract(pr.extra_value,'$.desiredat')) > date_add(ds.stat_date, interval 16 hour)
                and pr.marker_category in (9,14,70) ##客户改约时间
        ) pr2 on ds.pno = pr2.pno and pr2.stat_date = ds.stat_date and  pr2.rk = 1 #当日之前客户改约时间
    left join my_bi .dc_should_delivery_today ds1 on ds.pno = ds1.pno and ds1.state = 6 and ds1.stat_date = date_sub(ds.stat_date,interval 1 day)
    where
        case
            when pr1.pno is not null then 'N'
            when pr2.pno is not null then 'N'
            when ds1.pno is not null  then 'N'  else 'Y'
        end = 'Y'
)
select
    a2.*
from
    (
        select
            a.stat_date 日期
            ,a.store_id 网点ID
            ,ss.name 网点名称
            ,ss.opening_at 开业日期
            ,smr.name 大区
            ,smp.name 片区
            ,a.应交接
            ,a.已交接
            ,date_format(ft.plan_arrive_time, '%Y-%m-%d %H:%i:%s') 计划到达时间
            ,date_format(ft.real_arrive_time, '%Y-%m-%d %H:%i:%s') Kit到港考勤
            ,date_format(ft.sign_time, '%Y-%m-%d %H:%i:%s') fleet签到时间
            ,concat(round(a.交接率*100,2),'%') as 交接率
            ,concat(ifnull(a.a_check,''), ifnull(a.b_check,''), ifnull(a.d_check,''), ifnull(a.e_check,''),if(a.a_check is null  and a.d_check is null and a.b_check is null and a.e_check is null, 'C', '')) 交接评级
            ,concat(round(a.A_rate * 100,2),'%')  'A时段（<0930 ）'
            ,concat(round(a.B_rate * 100,2),'%') 'B时段（0930<=X<1200）'
            ,concat(round(a.C_rate * 100,2),'%')'C时段（1200<=X<1600 ）'
            ,concat(round(a.D_rate * 100,2),'%')'D时段（>=1600）'
            ,row_number() over (partition by date(ft.real_arrive_time), ft.next_store_id order by ft.real_arrive_time) rk
        from
            (
                select
                    t1.store_id
                    ,t1.stat_date
                    ,count(t1.pno) 应交接
                    ,count(if(sc.pno is not null , t1.pno, null)) 已交接
                    ,count(if(sc.pno is not null , t1.pno, null))/count(t1.pno) 交接率

                    ,count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as A_rate
                    ,count(if(time(sc.route_time) >= '09:30:00' and time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as B_rate
                    ,count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as C_rate
                    ,count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as D_rate

                    ,if(count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.95, 'A', null ) a_check
                    ,if(count(if(time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.98 and count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) <= 0.95, 'B', null ) b_check
                    ,if(count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03, 'D', null ) d_check
                    ,if(count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03 , 'E', null ) e_check
                from t t1
                left join
                    (
                        select
                            sc.*
                        from
                            (
                                select
                                    pr.pno
                                    ,pr.store_id
                                    ,pr.store_name
                                    ,t1.stat_date
                                    ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                                    ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                                    ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
                                from my_staging.parcel_route pr
                                join t t1 on t1.pno = pr.pno
                                where
                                    pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                                   and pr.routed_at >= date_sub(t1.stat_date, interval 8 hour)
                                  and pr.routed_at < date_add(t1.stat_date, interval 16 hour )
                            ) sc
                        where
                            sc.rk = 1
                    ) sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
                group by 1,2
            ) a
        left join my_staging.sys_store ss on ss.id = a.store_id
        left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
        left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
        left join my_bi.fleet_time ft on ft.next_store_id = ss.id and ft.arrive_type in (3,5) and date(ft.real_arrive_time) = a.stat_date
        where
            ss.category in (1,10)
            and ss.id not in ('MY04040316','MY04040315','MY04070217')
    ) a2
where
    a2.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ds.dst_store_id as store_id
        ,pr.pno
        ,hst.sys_store_id hr_store_id
        ,hst.formal
        ,pr.staff_info_id
        ,pi.state
        ,hst.job_title
    from dwm.dwd_my_dc_should_be_delivery ds
    left join my_staging.parcel_route pr on pr.pno = ds.pno and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    left join my_staging.parcel_info pi on pi.pno = pr.pno
    left join my_bi.hr_staff_info hst on hst.staff_info_id = pr.staff_info_id
#     left join ph_bi.hr_staff_transfer hst  on hst.staff_info_id = pr.staff_info_id
    where
        ds.p_date = '2023-08-07'
        and pr.routed_at >= date_sub('2023-08-07', interval 8 hour )
        and pr.routed_at < date_add('2023-08-07', interval 16 hour)
        and ds.should_delevry_type != '非当日应派'
)
    select
        dr.store_id 网点ID
        ,dr.store_name 网点
        ,coalesce(dr.opening_at, '未记录') 开业时间
        ,case ss.category
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
        end 网点类型
        ,smp.name 片区
        ,smr.name 大区
        ,coalesce(emp_cnt.staf_num, 0) 总快递员人数_在职
        ,coalesce(a3.self_staff_num, 0) 自有快递员出勤数
        ,coalesce(a3.other_staff_num, 0) '外协+支援快递员出勤数'
        ,coalesce(a3.dco_dcs_num, 0) 仓管主管_出勤数

        ,coalesce(a3.avg_scan_num, 0) 快递员平均交接量
        ,coalesce(a3.avg_del_num, 0) 快递员平均妥投量
        ,coalesce(a3.dco_dcs_avg_scan, 0) 仓管主管_平均交接量

        ,coalesce(sdb.code_num, 0) 网点三段码数量
        ,coalesce(a2.self_avg_staff_code, 0) 自有快递员三段码平均交接量
        ,coalesce(a2.other_avg_staff_code, 0) '外协+支援快递员三段码平均交接量'
        ,coalesce(a2.self_avg_staff_del_code, 0) 自有快递员三段码平均妥投量
        ,coalesce(a2.other_avg_staff_del_code, 0) '外协+支援快递员三段码平均妥投量'
        ,coalesce(a2.avg_code_staff, 0) 三段码平均交接快递员数
        ,case
            when a2.avg_code_staff < 2 then 'A'
            when a2.avg_code_staff >= 2 and a2.avg_code_staff < 3 then 'B'
            when a2.avg_code_staff >= 3 and a2.avg_code_staff < 4 then 'C'
            when a2.avg_code_staff >= 4 then 'D'
        end 评级
        ,a2.code_num
        ,a2.staff_code_num
        ,a2.staff_num
        ,a2.fin_staff_code_num
    from
        (
            select
                a1.store_id
                ,count(distinct if(a1.job_title in (13,110,1 ), a1.staff_code, null)) staff_code_num
                ,count(distinct if(a1.job_title in (13,110,1199), a1.third_sorting_code, null)) code_num
                ,count(distinct if(a1.job_title in (13,110,1199), a1.staff_info_id, null)) staff_num
                ,count(distinct if(a1.job_title in (13,110,1199), a1.staff_code, null)) fin_staff_code_num
                ,count(distinct if(a1.job_title in (13,110,1199), a1.staff_code, null))/ count(distinct if(a1.job_title in (13,110,1199), a1.third_sorting_code, null)) avg_code_staff
                ,count(distinct if(a1.is_self = 'y' and a1.job_title in (13,110,1199), a1.staff_code, null))/count(distinct if(a1.is_self = 'y' and a1.job_title in (13,110,1199), a1.staff_info_id, null)) self_avg_staff_code
                ,count(distinct if(a1.is_self = 'n' and a1.job_title in (13,110,1199), a1.staff_code, null))/count(distinct if(a1.is_self = 'n' and a1.job_title in (13,110,1199), a1.staff_info_id, null)) other_avg_staff_code
                ,count(distinct if(a1.state = 5 and a1.is_self = 'y' and a1.job_title in (13,110,1199), a1.staff_code, null))/count(distinct if(a1.is_self = 'y' and a1.job_title in (13,110,1199), a1.staff_info_id, null)) self_avg_staff_del_code
                ,count(distinct if(a1.state = 5 and a1.is_self = 'n' and a1.job_title in (13,110,1199), a1.staff_code, null))/count(distinct if(a1.is_self = 'n' and a1.job_title in (13,110,1199), a1.staff_info_id, null)) other_avg_staff_del_code
            from
                (
                select
                    a1.*
                    ,concat(a1.staff_info_id, a1.third_sorting_code) staff_code
                from
                    (
                        select
                            t1.store_id
                            ,t1.pno
                            ,t1.staff_info_id
                            ,if(t1.formal = 1 and t1.store_id = t1.hr_store_id, 'y', 'n') is_self
                            ,t1.state
                            ,t1.job_title
                            ,ps.third_sorting_code
                            ,rank() over (partition by t1.pno order by ps.created_at desc) rk
                        from t t1
                        join my_drds_pro.parcel_sorting_code_info ps on  ps.pno = t1.pno and ps.dst_store_id = t1.store_id and ps.third_sorting_code not in  ('XX', 'YY', 'ZZ', '00')
                    ) a1
                where
                    a1.rk = 1
            ) a1
        left join my_staging.parcel_info pi on pi.pno = a1.pno
        group by 1
    ) a2
left join
    (
        select
            hr.sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  my_bi.hr_staff_info  hr
        where
            hr.formal = 1
            and hr.is_sub_staff= 0
            and hr.state = 1
            and hr.job_title in (13,110,1199)
        group by 1
    ) emp_cnt on emp_cnt.sys_store_id = a2.store_id
# left join
#     (
#         select
#            ad.sys_store_id
#            ,count(distinct ad.staff_info_id) as atd_emp_cnt -- 出勤人数
#        from ph_bi.attendance_data_v2 ad
#        left join ph_bi.hr_staff_info hr on hr.staff_info_id =ad.staff_info_id
#        where
#            (ad.attendance_started_at is not null or ad.attendance_end_at is not null)
#             and hr.job_title in (13,110,1000)
# #             and ad.stat_date = curdate()
#             and ad.stat_date = '${date}'
#        group by 1
#     ) att on att.sys_store_id = a2.store_id
left join dwm.dim_my_sys_store_rd dr on dr.store_id = a2.store_id and dr.stat_date = date_sub(curdate(), interval 1 day)
left join my_staging.sys_store ss on ss.id = a2.store_id
left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
left join
    (
        select
            t1.store_id
            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.formal = 1  and t1.job_title in (13,110,1199), t1.staff_info_id, null))  self_staff_num
            ,count(distinct if(t1.job_title in (13,110,1199) and ( t1.hr_store_id != t1.store_id or t1.formal != 1  ), t1.staff_info_id, null )) other_staff_num
            ,count(distinct if(t1.job_title in (13,110,1199), t1.pno, null))/count(distinct if(t1.job_title in (13,110,1199),  t1.staff_info_id, null)) avg_scan_num
            ,count(distinct if(t1.job_title in (13,110,1199) and t1.state = 5, t1.pno, null))/count(distinct if(t1.job_title in (13,110,1199) and t1.state = 5,  t1.staff_info_id, null)) avg_del_num

            ,count(distinct if(t1.job_title in (37,16), t1.staff_info_id, null)) dco_dcs_num
            ,count(distinct if(t1.job_title in (37,16), t1.pno, null))/count(distinct if(t1.job_title in (37,16), t1.staff_info_id, null)) dco_dcs_avg_scan
        from t t1
        group by 1
    ) a3  on a3.store_id = a2.store_id
left join
    (
        select
            gl.store_id
            ,count(distinct gl.grid_code) code_num
        from `my-amp`.grid_lib gl
        group by 1
    ) sdb on sdb.store_id = a2.store_id
where
    ss.category in (1,10)
    and sdb.store_id is not null;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ds.dst_store_id store_id
        ,ss.name
        ,ds.pno
        ,convert_tz(pi.finished_at, '+00:00', '+08:00') finished_time
        ,pi.ticket_delivery_staff_info_id
        ,pi.state
        ,coalesce(hsi.store_id, hs.sys_store_id) hr_store_id
        ,coalesce(hsi.job_title, hs.job_title) job_title
        ,coalesce(hsi.formal, hs.formal) formal
        ,row_number() over (partition by ds.dst_store_id, pi.ticket_delivery_staff_info_id order by pi.finished_at) rk1
        ,row_number() over (partition by ds.dst_store_id, pi.ticket_delivery_staff_info_id order by pi.finished_at desc) rk2
    from dwm.dwd_my_dc_should_be_delivery ds
    join my_staging.parcel_info pi on pi.pno = ds.pno
    left join my_staging.sys_store ss on ss.id = ds.dst_store_id
    left join my_bi.hr_staff_transfer hsi on hsi.staff_info_id = pi.ticket_delivery_staff_info_id and hsi.stat_date = '2023-08-07'
    left join my_bi.hr_staff_info hs on hs.staff_info_id = pi.ticket_delivery_staff_info_id and if(hs.leave_date is null, 1 = 1, hs.leave_date >= '2023-08-07')
#     left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pi.ticket_delivery_staff_info_id
    where
        pi.state = 5
#         and pi.finished_at >= '2023-08-01 16:00:00'
#         and pi.finished_at < '2023-08-02 16:00:00'
        and ds.p_date = '2023-08-07'
        and pi.finished_at >= date_sub('2023-08-07', interval 8 hour )
        and pi.finished_at < date_add('2023-08-07', interval 16 hour)
        and ds.should_delevry_type != '非当日应派'
)
select
    dp.store_id 网点ID
    ,dp.store_name 网点
    ,coalesce(dp.opening_at, '未记录') 开业时间
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,coalesce(cour.staf_num, 0) 本网点所属快递员数
    ,coalesce(ds.sd_num, 0) 应派件量
    ,coalesce(del.pno_num, 0) '妥投量(快递员+仓管+主管)'
    ,coalesce(del_cou.self_staff_num, 0) 参与妥投快递员_自有
    ,coalesce(del_cou.other_staff_num, 0) 参与妥投快递员_外协支援
    ,coalesce(del_cou.dco_dcs_num, 0) 参与妥投_仓管主管

    ,coalesce(del_cou.self_effect, 0) 当日人效_自有
    ,coalesce(del_cou.other_effect, 0) 当日人效_外协支援
    ,coalesce(del_cou.dco_dcs_effect, 0) 仓管主管人效
    ,coalesce(del_hour.avg_del_hour, 0) 派件小时数
from
    (
        select
            dp.store_id
            ,dp.store_name
            ,dp.opening_at
            ,dp.piece_name
            ,dp.region_name
        from dwm.dim_my_sys_store_rd dp
        left join my_staging.sys_store ss on ss.id = dp.store_id
        where
            dp.state_desc = '激活'
            and dp.stat_date = date_sub(curdate(), interval 1 day)
            and ss.category in (1,10)
    ) dp
left join
    (
        select
            hr.sys_store_id sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  my_bi.hr_staff_info hr
        where
            hr.formal = 1
            and hr.state = 1
            and hr.job_title in (13,110,1199)
#             and hr.stat_date = '${date}'
        group by 1
    ) cour on cour.sys_store_id = dp.store_id
left join
    (
        select
            ds.dst_store_id
            ,count(distinct ds.pno) sd_num
        from dwm.dwd_my_dc_should_be_delivery ds
        where
             ds.should_delevry_type != '非当日应派'
            and ds.p_date = '2023-08-07'
        group by 1
    ) ds on ds.dst_store_id = dp.store_id
left join
    (
        select
            t1.store_id
            ,count(distinct t1.pno) pno_num
        from t t1
        group by 1
    ) del on del.store_id = dp.store_id
left join
    (
        select
            t1.store_id
            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (13,110,1199) and t1.formal = 1, t1.ticket_delivery_staff_info_id, null)) self_staff_num
            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (13,110,1199) and t1.formal = 1, t1.pno, null))/count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (13,110,1199) and t1.formal = 1, t1.ticket_delivery_staff_info_id, null)) self_effect
            ,count(distinct if((t1.hr_store_id != t1.store_id or t1.formal != 1) and t1.job_title in (13,110,1199), t1.ticket_delivery_staff_info_id, null)) other_staff_num
            ,count(distinct if((t1.hr_store_id != t1.store_id or t1.formal != 1) and t1.job_title in (13,110,1199), t1.pno, null))/count(distinct if((t1.hr_store_id != t1.store_id or t1.formal != 1) and t1.job_title in (13,110,1199), t1.ticket_delivery_staff_info_id, null)) other_effect

            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (16,37), t1.ticket_delivery_staff_info_id, null)) dco_dcs_num
            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (16,37), t1.pno, null))/count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (16,37), t1.ticket_delivery_staff_info_id, null)) dco_dcs_effect
        from t t1
        group by 1
    ) del_cou on del_cou.store_id = dp.store_id
left join
    (
        select
            a.store_id
            ,a.name
            ,sum(diff_hour)/count(distinct a.ticket_delivery_staff_info_id) avg_del_hour
        from
            (
                select
                    t1.store_id
                    ,t1.name
                    ,t1.ticket_delivery_staff_info_id
                    ,t1.finished_time
                    ,t2.finished_time finished_at_2
                    ,timestampdiff(second, t1.finished_time, t2.finished_time)/3600 diff_hour
                from
                    (
                        select * from t t1 where t1.rk1 = 1
                    ) t1
                join
                    (
                        select * from t t2 where t2.rk2 = 2
                    ) t2 on t2.store_id = t1.store_id and t2.ticket_delivery_staff_info_id = t1.ticket_delivery_staff_info_id
            ) a
        group by 1,2
    ) del_hour on del_hour.store_id = dp.store_id;
;-- -. . -..- - / . -. - .-. -.--
with d as
(
    select
         ds.dst_store_id store_id
        ,ds.pno
        ,ds.p_date stat_date
    from dwm.dwd_my_dc_should_be_delivery ds
    where
        ds.should_delevry_type = '1派应派包裹'
        and ds.p_date = '2023-08-07'
        and dst_store_id = 'MY09040318'
)
, t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
    from d ds
    left join
        (
            select
                pr.pno
                ,ds.stat_date
                ,max(convert_tz(pr.routed_at,'+00:00','+08:00')) remote_marker_time
            from my_staging.parcel_route pr
            join d ds on pr.pno = ds.pno
            where 1=1
                and pr.routed_at >= date_sub(ds.stat_date, interval 8 hour)
                and pr.routed_at < date_add(ds.stat_date, interval 16 hour)
                and pr.route_action = 'DETAIN_WAREHOUSE'
                and pr.marker_category in (42,43) ##岛屿,偏远地区
            group by 1,2
        ) pr1  on ds.pno = pr1.pno and ds.stat_date = pr1.stat_date  #当日留仓标记为偏远地区留待次日派送
    left join
        (
            select
               pr.pno
                ,ds.stat_date
               ,convert_tz(pr.routed_at,'+00:00','+08:00') reschedule_marker_time
               ,row_number() over(partition by ds.stat_date, pr.pno order by pr.routed_at desc) rk
            from my_staging.parcel_route pr
            join d ds on ds.pno = pr.pno
            where 1=1
                and pr.routed_at >= date_sub(ds.stat_date ,interval 15 day)
                and pr.routed_at <  date_sub(ds.stat_date ,interval 8 hour) #限定当日之前的改约
                and pr.route_action = 'DETAIN_WAREHOUSE'
                and from_unixtime(json_extract(pr.extra_value,'$.desiredat')) > date_add(ds.stat_date, interval 16 hour)
                and pr.marker_category in (9,14,70) ##客户改约时间
        ) pr2 on ds.pno = pr2.pno and pr2.stat_date = ds.stat_date and  pr2.rk = 1 #当日之前客户改约时间
    left join my_bi .dc_should_delivery_today ds1 on ds.pno = ds1.pno and ds1.state = 6 and ds1.stat_date = date_sub(ds.stat_date,interval 1 day)
    where
        case
            when pr1.pno is not null then 'N'
            when pr2.pno is not null then 'N'
            when ds1.pno is not null  then 'N'  else 'Y'
        end = 'Y'
)
select
    a2.*
from
    (
        select
            a.stat_date 日期
            ,a.store_id 网点ID
            ,ss.name 网点名称
            ,ss.opening_at 开业日期
            ,smr.name 大区
            ,smp.name 片区
            ,a.应交接
            ,a.已交接
            ,date_format(ft.plan_arrive_time, '%Y-%m-%d %H:%i:%s') 计划到达时间
            ,date_format(ft.real_arrive_time, '%Y-%m-%d %H:%i:%s') Kit到港考勤
            ,date_format(ft.sign_time, '%Y-%m-%d %H:%i:%s') fleet签到时间
            ,concat(round(a.交接率*100,2),'%') as 交接率
            ,concat(ifnull(a.a_check,''), ifnull(a.b_check,''), ifnull(a.d_check,''), ifnull(a.e_check,''),if(a.a_check is null  and a.d_check is null and a.b_check is null and a.e_check is null, 'C', '')) 交接评级
            ,concat(round(a.A_rate * 100,2),'%')  'A时段（<0930 ）'
            ,concat(round(a.B_rate * 100,2),'%') 'B时段（0930<=X<1200）'
            ,concat(round(a.C_rate * 100,2),'%')'C时段（1200<=X<1600 ）'
            ,concat(round(a.D_rate * 100,2),'%')'D时段（>=1600）'
            ,row_number() over (partition by date(ft.real_arrive_time), ft.next_store_id order by ft.real_arrive_time) rk
        from
            (
                select
                    t1.store_id
                    ,t1.stat_date
                    ,count(t1.pno) 应交接
                    ,count(if(sc.pno is not null , t1.pno, null)) 已交接
                    ,count(if(sc.pno is not null , t1.pno, null))/count(t1.pno) 交接率

                    ,count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as A_rate
                    ,count(if(time(sc.route_time) >= '09:30:00' and time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as B_rate
                    ,count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as C_rate
                    ,count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as D_rate

                    ,if(count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.95, 'A', null ) a_check
                    ,if(count(if(time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.98 and count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) <= 0.95, 'B', null ) b_check
                    ,if(count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03, 'D', null ) d_check
                    ,if(count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03 , 'E', null ) e_check
                from t t1
                left join
                    (
                        select
                            sc.*
                        from
                            (
                                select
                                    pr.pno
                                    ,pr.store_id
                                    ,pr.store_name
                                    ,t1.stat_date
                                    ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                                    ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                                    ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
                                from my_staging.parcel_route pr
                                join t t1 on t1.pno = pr.pno
                                where
                                    pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                                   and pr.routed_at >= date_sub(t1.stat_date, interval 8 hour)
                                  and pr.routed_at < date_add(t1.stat_date, interval 16 hour )
                            ) sc
                        where
                            sc.rk = 1
                    ) sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
                group by 1,2
            ) a
        left join my_staging.sys_store ss on ss.id = a.store_id
        left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
        left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
        left join my_bi.fleet_time ft on ft.next_store_id = ss.id and ft.arrive_type in (3,5) and date(ft.real_arrive_time) = a.stat_date
        where
            ss.category in (1,10)
            and ss.id not in ('MY04040316','MY04040315','MY04070217')
    ) a2;
;-- -. . -..- - / . -. - .-. -.--
with d as
(
    select
         ds.dst_store_id store_id
        ,ds.pno
        ,ds.p_date stat_date
    from dwm.dwd_my_dc_should_be_delivery ds
    where
        ds.should_delevry_type = '1派应派包裹'
        and ds.p_date = '2023-08-07'
#         and dst_store_id = 'MY09040318'
)
, t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
    from d ds
    left join
        (
            select
                pr.pno
                ,ds.stat_date
                ,max(convert_tz(pr.routed_at,'+00:00','+08:00')) remote_marker_time
            from my_staging.parcel_route pr
            join d ds on pr.pno = ds.pno
            where 1=1
                and pr.routed_at >= date_sub(ds.stat_date, interval 8 hour)
                and pr.routed_at < date_add(ds.stat_date, interval 16 hour)
                and pr.route_action = 'DETAIN_WAREHOUSE'
                and pr.marker_category in (42,43) ##岛屿,偏远地区
            group by 1,2
        ) pr1  on ds.pno = pr1.pno and ds.stat_date = pr1.stat_date  #当日留仓标记为偏远地区留待次日派送
    left join
        (
            select
               pr.pno
                ,ds.stat_date
               ,convert_tz(pr.routed_at,'+00:00','+08:00') reschedule_marker_time
               ,row_number() over(partition by ds.stat_date, pr.pno order by pr.routed_at desc) rk
            from my_staging.parcel_route pr
            join d ds on ds.pno = pr.pno
            where 1=1
                and pr.routed_at >= date_sub(ds.stat_date ,interval 15 day)
                and pr.routed_at <  date_sub(ds.stat_date ,interval 8 hour) #限定当日之前的改约
                and pr.route_action = 'DETAIN_WAREHOUSE'
                and from_unixtime(json_extract(pr.extra_value,'$.desiredat')) > date_add(ds.stat_date, interval 16 hour)
                and pr.marker_category in (9,14,70) ##客户改约时间
        ) pr2 on ds.pno = pr2.pno and pr2.stat_date = ds.stat_date and  pr2.rk = 1 #当日之前客户改约时间
    left join my_bi .dc_should_delivery_today ds1 on ds.pno = ds1.pno and ds1.state = 6 and ds1.stat_date = date_sub(ds.stat_date,interval 1 day)
    where
        case
            when pr1.pno is not null then 'N'
            when pr2.pno is not null then 'N'
            when ds1.pno is not null  then 'N'  else 'Y'
        end = 'Y'
)
select
    a2.*
from
    (
        select
            a.stat_date 日期
            ,a.store_id 网点ID
            ,ss.name 网点名称
            ,ss.opening_at 开业日期
            ,smr.name 大区
            ,smp.name 片区
            ,a.应交接
            ,a.已交接
            ,date_format(ft.plan_arrive_time, '%Y-%m-%d %H:%i:%s') 计划到达时间
            ,date_format(ft.real_arrive_time, '%Y-%m-%d %H:%i:%s') Kit到港考勤
            ,date_format(ft.sign_time, '%Y-%m-%d %H:%i:%s') fleet签到时间
            ,concat(round(a.交接率*100,2),'%') as 交接率
            ,concat(ifnull(a.a_check,''), ifnull(a.b_check,''), ifnull(a.d_check,''), ifnull(a.e_check,''),if(a.a_check is null  and a.d_check is null and a.b_check is null and a.e_check is null, 'C', '')) 交接评级
            ,concat(round(a.A_rate * 100,2),'%')  'A时段（<0930 ）'
            ,concat(round(a.B_rate * 100,2),'%') 'B时段（0930<=X<1200）'
            ,concat(round(a.C_rate * 100,2),'%')'C时段（1200<=X<1600 ）'
            ,concat(round(a.D_rate * 100,2),'%')'D时段（>=1600）'
            ,row_number() over (partition by date(ft.real_arrive_time), ft.next_store_id order by ft.real_arrive_time) rk
        from
            (
                select
                    t1.store_id
                    ,t1.stat_date
                    ,count(t1.pno) 应交接
                    ,count(if(sc.pno is not null , t1.pno, null)) 已交接
                    ,count(if(sc.pno is not null , t1.pno, null))/count(t1.pno) 交接率

                    ,count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as A_rate
                    ,count(if(time(sc.route_time) >= '09:30:00' and time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as B_rate
                    ,count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as C_rate
                    ,count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as D_rate

                    ,if(count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.95, 'A', null ) a_check
                    ,if(count(if(time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.98 and count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) <= 0.95, 'B', null ) b_check
                    ,if(count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03, 'D', null ) d_check
                    ,if(count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03 , 'E', null ) e_check
                from t t1
                left join
                    (
                        select
                            sc.*
                        from
                            (
                                select
                                    pr.pno
                                    ,pr.store_id
                                    ,pr.store_name
                                    ,t1.stat_date
                                    ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                                    ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                                    ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
                                from my_staging.parcel_route pr
                                join t t1 on t1.pno = pr.pno
                                where
                                    pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                                   and pr.routed_at >= date_sub(t1.stat_date, interval 8 hour)
                                  and pr.routed_at < date_add(t1.stat_date, interval 16 hour )
                            ) sc
                        where
                            sc.rk = 1
                    ) sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
                group by 1,2
            ) a
        left join my_staging.sys_store ss on ss.id = a.store_id
        left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
        left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
        left join my_bi.fleet_time ft on ft.next_store_id = ss.id and ft.arrive_type in (3,5) and date(ft.real_arrive_time) = a.stat_date
        where
            ss.category in (1,10)
            and ss.id not in ('MY04040316','MY04040315','MY04070217')
    ) a2
where
    a2.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
with d as
(
    select
         ds.dst_store_id store_id
        ,ds.pno
        ,ds.p_date stat_date
    from dwm.dwd_my_dc_should_be_delivery ds
    where
        ds.should_delevry_type = '1派应派包裹'
        and ds.p_date = '2023-08-07'
#         and dst_store_id = 'MY09040318'
)
, t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
    from d ds
    left join
        (
            select
                pr.pno
                ,ds.stat_date
                ,max(convert_tz(pr.routed_at,'+00:00','+08:00')) remote_marker_time
            from my_staging.parcel_route pr
            join d ds on pr.pno = ds.pno
            where 1=1
                and pr.routed_at >= date_sub(ds.stat_date, interval 8 hour)
                and pr.routed_at < date_add(ds.stat_date, interval 16 hour)
                and pr.route_action = 'DETAIN_WAREHOUSE'
                and pr.marker_category in (42,43) ##岛屿,偏远地区
            group by 1,2
        ) pr1  on ds.pno = pr1.pno and ds.stat_date = pr1.stat_date  #当日留仓标记为偏远地区留待次日派送
    left join
        (
            select
               pr.pno
                ,ds.stat_date
               ,convert_tz(pr.routed_at,'+00:00','+08:00') reschedule_marker_time
               ,row_number() over(partition by ds.stat_date, pr.pno order by pr.routed_at desc) rk
            from my_staging.parcel_route pr
            join d ds on ds.pno = pr.pno
            where 1=1
                and pr.routed_at >= date_sub(ds.stat_date ,interval 15 day)
                and pr.routed_at <  date_sub(ds.stat_date ,interval 8 hour) #限定当日之前的改约
                and pr.route_action = 'DETAIN_WAREHOUSE'
                and from_unixtime(json_extract(pr.extra_value,'$.desiredat')) > date_add(ds.stat_date, interval 16 hour)
                and pr.marker_category in (9,14,70) ##客户改约时间
        ) pr2 on ds.pno = pr2.pno and pr2.stat_date = ds.stat_date and  pr2.rk = 1 #当日之前客户改约时间
    left join my_bi .dc_should_delivery_today ds1 on ds.pno = ds1.pno and ds1.state = 6 and ds1.stat_date = date_sub(ds.stat_date,interval 1 day)
    where
        case
            when pr1.pno is not null then 'N'
            when pr2.pno is not null then 'N'
            when ds1.pno is not null  then 'N'  else 'Y'
        end = 'Y'
)
select
    a2.*
from
    (
        select
            a.stat_date 日期
            ,a.store_id 网点ID
            ,ss.name 网点名称
            ,ss.opening_at 开业日期
            ,smr.name 大区
            ,smp.name 片区
            ,a.应交接
            ,a.已交接
            ,date_format(ft.plan_arrive_time, '%Y-%m-%d %H:%i:%s') 计划到达时间
            ,date_format(ft.real_arrive_time, '%Y-%m-%d %H:%i:%s') Kit到港考勤
            ,date_format(ft.sign_time, '%Y-%m-%d %H:%i:%s') fleet签到时间
            ,concat(round(a.交接率*100,2),'%') as 交接率
            ,concat(ifnull(a.a_check,''), ifnull(a.b_check,''), ifnull(a.d_check,''), ifnull(a.e_check,''),if(a.a_check is null  and a.d_check is null and a.b_check is null and a.e_check is null, 'C', '')) 交接评级
            ,concat(round(a.A_rate * 100,2),'%')  'A时段（<0930 ）'
            ,concat(round(a.B_rate * 100,2),'%') 'B时段（0930<=X<1200）'
            ,concat(round(a.C_rate * 100,2),'%')'C时段（1200<=X<1600 ）'
            ,concat(round(a.D_rate * 100,2),'%')'D时段（>=1600）'
#             ,row_number() over (partition by date(ft.real_arrive_time), ft.next_store_id order by ft.real_arrive_time) rk
        from
            (
                select
                    t1.store_id
                    ,t1.stat_date
                    ,count(t1.pno) 应交接
                    ,count(if(sc.pno is not null , t1.pno, null)) 已交接
                    ,count(if(sc.pno is not null , t1.pno, null))/count(t1.pno) 交接率

                    ,count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as A_rate
                    ,count(if(time(sc.route_time) >= '09:30:00' and time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as B_rate
                    ,count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as C_rate
                    ,count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as D_rate

                    ,if(count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.95, 'A', null ) a_check
                    ,if(count(if(time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.98 and count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) <= 0.95, 'B', null ) b_check
                    ,if(count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03, 'D', null ) d_check
                    ,if(count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03 , 'E', null ) e_check
                from t t1
                left join
                    (
                        select
                            sc.*
                        from
                            (
                                select
                                    pr.pno
                                    ,pr.store_id
                                    ,pr.store_name
                                    ,t1.stat_date
                                    ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                                    ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                                    ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
                                from my_staging.parcel_route pr
                                join t t1 on t1.pno = pr.pno
                                where
                                    pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                                   and pr.routed_at >= date_sub(t1.stat_date, interval 8 hour)
                                  and pr.routed_at < date_add(t1.stat_date, interval 16 hour )
                            ) sc
                        where
                            sc.rk = 1
                    ) sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
                group by 1,2
            ) a
        left join my_staging.sys_store ss on ss.id = a.store_id
        left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
        left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
#         left join my_bi.fleet_time ft on ft.next_store_id = ss.id and ft.arrive_type in (3,5) and date(ft.real_arrive_time) = a.stat_date
        where
            ss.category in (1,10)
            and ss.id not in ('MY04040316','MY04040315','MY04070217')
    ) a2;
;-- -. . -..- - / . -. - .-. -.--
with d as
(
    select
         ds.dst_store_id store_id
        ,ds.pno
        ,ds.p_date stat_date
    from dwm.dwd_my_dc_should_be_delivery ds
    where
        ds.should_delevry_type = '1派应派包裹'
        and ds.p_date = '2023-08-07'
#         and dst_store_id = 'MY09040318'
)
, t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
    from d ds
    left join
        (
            select
                pr.pno
                ,ds.stat_date
                ,max(convert_tz(pr.routed_at,'+00:00','+08:00')) remote_marker_time
            from my_staging.parcel_route pr
            join d ds on pr.pno = ds.pno
            where 1=1
                and pr.routed_at >= date_sub(ds.stat_date, interval 8 hour)
                and pr.routed_at < date_add(ds.stat_date, interval 16 hour)
                and pr.route_action = 'DETAIN_WAREHOUSE'
                and pr.marker_category in (42,43) ##岛屿,偏远地区
            group by 1,2
        ) pr1  on ds.pno = pr1.pno and ds.stat_date = pr1.stat_date  #当日留仓标记为偏远地区留待次日派送
    left join
        (
            select
               pr.pno
                ,ds.stat_date
               ,convert_tz(pr.routed_at,'+00:00','+08:00') reschedule_marker_time
               ,row_number() over(partition by ds.stat_date, pr.pno order by pr.routed_at desc) rk
            from my_staging.parcel_route pr
            join d ds on ds.pno = pr.pno
            where 1=1
                and pr.routed_at >= date_sub(ds.stat_date ,interval 15 day)
                and pr.routed_at <  date_sub(ds.stat_date ,interval 8 hour) #限定当日之前的改约
                and pr.route_action = 'DETAIN_WAREHOUSE'
                and from_unixtime(json_extract(pr.extra_value,'$.desiredat')) > date_add(ds.stat_date, interval 16 hour)
                and pr.marker_category in (9,14,70) ##客户改约时间
        ) pr2 on ds.pno = pr2.pno and pr2.stat_date = ds.stat_date and  pr2.rk = 1 #当日之前客户改约时间
    left join my_bi .dc_should_delivery_today ds1 on ds.pno = ds1.pno and ds1.state = 6 and ds1.stat_date = date_sub(ds.stat_date,interval 1 day)
    where
        case
            when pr1.pno is not null then 'N'
            when pr2.pno is not null then 'N'
            when ds1.pno is not null  then 'N'  else 'Y'
        end = 'Y'
)
select
    a2.*
from
    (
        select
            a.stat_date 日期
            ,a.store_id 网点ID
            ,ss.name 网点名称
            ,ss.opening_at 开业日期
            ,smr.name 大区
            ,smp.name 片区
            ,a.应交接
            ,a.已交接
#             ,date_format(ft.plan_arrive_time, '%Y-%m-%d %H:%i:%s') 计划到达时间
#             ,date_format(ft.real_arrive_time, '%Y-%m-%d %H:%i:%s') Kit到港考勤
#             ,date_format(ft.sign_time, '%Y-%m-%d %H:%i:%s') fleet签到时间
            ,concat(round(a.交接率*100,2),'%') as 交接率
            ,concat(ifnull(a.a_check,''), ifnull(a.b_check,''), ifnull(a.d_check,''), ifnull(a.e_check,''),if(a.a_check is null  and a.d_check is null and a.b_check is null and a.e_check is null, 'C', '')) 交接评级
            ,concat(round(a.A_rate * 100,2),'%')  'A时段（<0930 ）'
            ,concat(round(a.B_rate * 100,2),'%') 'B时段（0930<=X<1200）'
            ,concat(round(a.C_rate * 100,2),'%')'C时段（1200<=X<1600 ）'
            ,concat(round(a.D_rate * 100,2),'%')'D时段（>=1600）'
#             ,row_number() over (partition by date(ft.real_arrive_time), ft.next_store_id order by ft.real_arrive_time) rk
        from
            (
                select
                    t1.store_id
                    ,t1.stat_date
                    ,count(t1.pno) 应交接
                    ,count(if(sc.pno is not null , t1.pno, null)) 已交接
                    ,count(if(sc.pno is not null , t1.pno, null))/count(t1.pno) 交接率

                    ,count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as A_rate
                    ,count(if(time(sc.route_time) >= '09:30:00' and time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as B_rate
                    ,count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as C_rate
                    ,count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as D_rate

                    ,if(count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.95, 'A', null ) a_check
                    ,if(count(if(time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.98 and count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) <= 0.95, 'B', null ) b_check
                    ,if(count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03, 'D', null ) d_check
                    ,if(count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03 , 'E', null ) e_check
                from t t1
                left join
                    (
                        select
                            sc.*
                        from
                            (
                                select
                                    pr.pno
                                    ,pr.store_id
                                    ,pr.store_name
                                    ,t1.stat_date
                                    ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                                    ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                                    ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
                                from my_staging.parcel_route pr
                                join t t1 on t1.pno = pr.pno
                                where
                                    pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                                   and pr.routed_at >= date_sub(t1.stat_date, interval 8 hour)
                                  and pr.routed_at < date_add(t1.stat_date, interval 16 hour )
                            ) sc
                        where
                            sc.rk = 1
                    ) sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
                group by 1,2
            ) a
        left join my_staging.sys_store ss on ss.id = a.store_id
        left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
        left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
#         left join my_bi.fleet_time ft on ft.next_store_id = ss.id and ft.arrive_type in (3,5) and date(ft.real_arrive_time) = a.stat_date
        where
            ss.category in (1,10)
            and ss.id not in ('MY04040316','MY04040315','MY04070217')
    ) a2;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        *
    from
        (
            select
                ad.*
                ,row_number() over (partition by ad.staff_info_id order by ad.stat_date desc) rk
            from
                (
                    select
                        ad.*
                        ,ad.attendance_time + ad.BT + ad.CT + ad.BT_Y + ad.AB total
                    from my_bi.attendance_data_v2 ad
                    join my_bi.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,1199,37,16) -- 在职且非待离职
                    where
                        ad.stat_date < '2023-08-08'

                ) ad
            where
                ad.total = 10
        ) ad
    where
        ad.rk < 8
)
select
    st.staff_info_id 工号
    ,if(hsi2.sys_store_id = '-1', 'Head office', dp.store_name) 网点
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,case
        when hsi2.job_title in (13,110,1199) then '快递员'
        when hsi2.job_title in (37) then '仓管员'
        when hsi2.job_title in (16) then '主管'
    end 角色
    ,st.late_num 迟到次数
    ,st.absence_sum 缺勤数据
    ,st.late_time_sum 迟到时长
    ,case
        when st.absence_sum = 0 and st.late_num <= 1 and st.late_time_sum < 30 then 'A'
        when st.absence_sum >= 2 or st.late_num >= 3  then 'C'
        else 'B'
    end 出勤评级
from
    (
        select
            a.staff_info_id
            ,count(if(a.late_or_not = 'y' ,a.stat_date, null)) late_num
            ,sum(if(a.late_or_not = 'y', a.late_time, 0)) late_time_sum
            ,sum(a.absence_time) absence_sum
        from
            (
                select
                    t1.*
                    ,if(t1.attendance_started_at > date_add(concat(t1.stat_date, ' ', t1.shift_start), interval 1 minute ) , 'y', 'n') late_or_not
                    ,if(t1.attendance_started_at > date_add(concat(t1.stat_date, ' ', t1.shift_start), interval 1 minute ) , timestampdiff(minute , concat(t1.stat_date, ' ', t1.shift_start), t1.attendance_started_at), 0) late_time
                    ,t1.AB/10 absence_time
                from t t1
            ) a
        group by 1
    ) st
left join my_bi.hr_staff_info hsi2 on hsi2.staff_info_id = st.staff_info_id
left join dwm.dim_my_sys_store_rd dp on dp.store_id = hsi2.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
order by 2,1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        *
    from
        (
            select
                ad.*
                ,row_number() over (partition by ad.staff_info_id order by ad.stat_date desc) rk
            from
                (
                    select
                        ad.*
                        ,ad.attendance_time + ad.BT + ad.CT + ad.BT_Y + ad.AB total
                    from my_bi.attendance_data_v2 ad
                    join my_bi.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,1199,37,16) -- 在职且非待离职
                    where
                        ad.stat_date < '2023-08-08'
#                         and hsi.hire_date <= date_sub(curdate(), interval 7 day )
#                         and ad.stat_date >= date_sub(curdate(), interval 30 day )
                ) ad
            where
                ad.total = 10
        ) ad
    where
        ad.rk < 8
)
select
    ss.store_id 网点ID
    ,dp.store_name 网点
    ,coalesce(dp.opening_at, '未记录') 开业时间
    ,case dp.store_category
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
    end 网点类型
    ,dp.region_name 大区
    ,dp.piece_name 片区
    ,case
        when ss.num/dp.on_emp_cnt < 0.05 then 'A'
        when ss.num/dp.on_emp_cnt >= 0.05 and ss.num/dp.on_emp_cnt < 0.1 then 'B'
        when ss.num/dp.on_emp_cnt >= 0.1 then 'C'
    end 出勤评级
    ,ss.num/dp.on_emp_cnt C级员工占比
    ,ss.num C级员工数
    ,dp.on_emp_cnt 在职员工数
    ,dp.on_dcs_cnt 主管数
    ,dp.on_dco_cnt 仓管数
    ,dp.on_dri_cnt 快递员数

    ,ss.avg_absence_num 近7天缺勤人次
    ,ss.avg_absence_num/7 近7天平均每天缺勤人次
    ,ss.avg_late_num 近7天迟到人次
    ,ss.avg_late_num/7 近7天平均每天迟到人次
from
    (
        select
            s.store_id
            ,count(if(s.ss_level = 'C', s.staff_info_id, null)) num
            ,sum(s.late_num) avg_late_num
            ,sum(s.absence_sum) avg_absence_num
        from
            (
                select
                    st.staff_info_id
                    ,dp.store_id
                    ,dp.store_name
                    ,dp.piece_name
                    ,dp.region_name
                    ,case
                        when hsi2.job_title in (13,110,1199) then '快递员'
                        when hsi2.job_title in (37) then '仓管员'
                        when hsi2.job_title in (16) then '主管'
                    end roles
                    ,st.late_num
                    ,st.absence_sum
                    ,case
                        when st.absence_sum = 0 and st.late_num <= 1 and st.late_time_sum < 30 then 'A'
                        when st.absence_sum >= 2 or st.late_num >= 3 then 'C'
                        else 'B'
                    end ss_level
                from
                    (
                        select
                            a.staff_info_id
                            ,count(if(a.late_or_not = 'y' ,a.stat_date, null)) late_num
#                             ,count(if(a.early_or_not = 'y', a.stat_date, null)) early_num
                            ,sum(if(a.late_or_not = 'y', a.late_time, 0)) late_time_sum
#                             ,sum(if(a.early_or_not = 'y', a.early_yime, 0)) early_time_sum
                            ,sum(a.absence_time) absence_sum
                        from
                            (
                                select
                                    t1.*
                                    ,if(t1.attendance_started_at > date_add(concat(t1.stat_date, ' ', t1.shift_start), interval 1 minute ) , 'y', 'n') late_or_not
                                    ,if(t1.attendance_started_at > date_add(concat(t1.stat_date, ' ', t1.shift_start), interval 1 minute ) , timestampdiff(minute , concat(t1.stat_date, ' ', t1.shift_start), t1.attendance_started_at), 0) late_time
#                                     ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, 'y', 'n' ) early_or_not
#                                     ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, timestampdiff(second, t1.attendance_end_at, t1.shift_end)/60, 0) early_yime
                                    ,t1.AB/10 absence_time
                                from t t1
                            ) a
                        group by 1
                    ) st
                left join my_bi.hr_staff_info hsi2 on hsi2.staff_info_id = st.staff_info_id
                left join dwm.dim_my_sys_store_rd dp on dp.store_id = hsi2.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
            ) s
        group by 1
    ) ss
left join
    (
        select
            hsi3.store_id store_id
            ,ss2.name store_name
            ,smp.name piece_name
            ,smr.name region_name
            ,ss2.category store_category
            ,ss2.opening_at
            ,count(if(hsi3.job_title in (13,110,1199,37,16), hsi3.staff_info_id, null)) on_emp_cnt
            ,count(if(hsi3.job_title in (13,110,1199), hsi3.staff_info_id, null)) on_dri_cnt
            ,count(if(hsi3.job_title in (37), hsi3.staff_info_id, null)) on_dco_cnt
            ,count(if(hsi3.job_title in (16), hsi3.staff_info_id, null)) on_dcs_cnt
        from my_bi.hr_staff_transfer  hsi3
        left join my_staging.sys_store ss2 on ss2.id = hsi3.store_id
        left join my_staging.sys_manage_piece smp on smp.id = ss2.manage_piece
        left join my_staging.sys_manage_region smr on smr.id = ss2.manage_region
        where
            hsi3.state = 1
            and hsi3.formal=1
            and hsi3.stat_date = date_sub(curdate(), interval 1 day)
        group by 1,2,3,4,5,6
    )dp on dp.store_id = ss.store_id
where
    dp.store_category in (1,10);
;-- -. . -..- - / . -. - .-. -.--
with d as
(
    select
         ds.dst_store_id store_id
        ,ds.pno
        ,ds.p_date stat_date
    from dwm.dwd_my_dc_should_be_delivery ds
    where
        ds.should_delevry_type = '1派应派包裹'
        and ds.p_date =  '2023-08-08'
#         and dst_store_id = 'MY09040318'
)
, t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
    from d ds
    left join
        (
            select
                pr.pno
                ,ds.stat_date
                ,max(convert_tz(pr.routed_at,'+00:00','+08:00')) remote_marker_time
            from my_staging.parcel_route pr
            join d ds on pr.pno = ds.pno
            where 1=1
                and pr.routed_at >= date_sub(ds.stat_date, interval 8 hour)
                and pr.routed_at < date_add(ds.stat_date, interval 16 hour)
                and pr.route_action = 'DETAIN_WAREHOUSE'
                and pr.marker_category in (42,43) ##岛屿,偏远地区
            group by 1,2
        ) pr1  on ds.pno = pr1.pno and ds.stat_date = pr1.stat_date  #当日留仓标记为偏远地区留待次日派送
    left join
        (
            select
               pr.pno
                ,ds.stat_date
               ,convert_tz(pr.routed_at,'+00:00','+08:00') reschedule_marker_time
               ,row_number() over(partition by ds.stat_date, pr.pno order by pr.routed_at desc) rk
            from my_staging.parcel_route pr
            join d ds on ds.pno = pr.pno
            where 1=1
                and pr.routed_at >= date_sub(ds.stat_date ,interval 15 day)
                and pr.routed_at <  date_sub(ds.stat_date ,interval 8 hour) #限定当日之前的改约
                and pr.route_action = 'DETAIN_WAREHOUSE'
                and from_unixtime(json_extract(pr.extra_value,'$.desiredat')) > date_add(ds.stat_date, interval 16 hour)
                and pr.marker_category in (9,14,70) ##客户改约时间
        ) pr2 on ds.pno = pr2.pno and pr2.stat_date = ds.stat_date and  pr2.rk = 1 #当日之前客户改约时间
    left join my_bi .dc_should_delivery_today ds1 on ds.pno = ds1.pno and ds1.state = 6 and ds1.stat_date = date_sub(ds.stat_date,interval 1 day)
    where
        case
            when pr1.pno is not null then 'N'
            when pr2.pno is not null then 'N'
            when ds1.pno is not null  then 'N'  else 'Y'
        end = 'Y'
)
select
    a2.*
from
    (
        select
            a.stat_date 日期
            ,a.store_id 网点ID
            ,ss.name 网点名称
            ,ss.opening_at 开业日期
            ,smr.name 大区
            ,smp.name 片区
            ,a.应交接
            ,a.已交接
#             ,date_format(ft.plan_arrive_time, '%Y-%m-%d %H:%i:%s') 计划到达时间
#             ,date_format(ft.real_arrive_time, '%Y-%m-%d %H:%i:%s') Kit到港考勤
#             ,date_format(ft.sign_time, '%Y-%m-%d %H:%i:%s') fleet签到时间
            ,concat(round(a.交接率*100,2),'%') as 交接率
            ,concat(ifnull(a.a_check,''), ifnull(a.b_check,''), ifnull(a.d_check,''), ifnull(a.e_check,''),if(a.a_check is null  and a.d_check is null and a.b_check is null and a.e_check is null, 'C', '')) 交接评级
            ,concat(round(a.A_rate * 100,2),'%')  'A时段（<0930 ）'
            ,concat(round(a.B_rate * 100,2),'%') 'B时段（0930<=X<1200）'
            ,concat(round(a.C_rate * 100,2),'%')'C时段（1200<=X<1600 ）'
            ,concat(round(a.D_rate * 100,2),'%')'D时段（>=1600）'
#             ,row_number() over (partition by date(ft.real_arrive_time), ft.next_store_id order by ft.real_arrive_time) rk
        from
            (
                select
                    t1.store_id
                    ,t1.stat_date
                    ,count(t1.pno) 应交接
                    ,count(if(sc.pno is not null , t1.pno, null)) 已交接
                    ,count(if(sc.pno is not null , t1.pno, null))/count(t1.pno) 交接率

                    ,count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as A_rate
                    ,count(if(time(sc.route_time) >= '09:30:00' and time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as B_rate
                    ,count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as C_rate
                    ,count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as D_rate

                    ,if(count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.95, 'A', null ) a_check
                    ,if(count(if(time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.98 and count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) <= 0.95, 'B', null ) b_check
                    ,if(count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03, 'D', null ) d_check
                    ,if(count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03 , 'E', null ) e_check
                from t t1
                left join
                    (
                        select
                            sc.*
                        from
                            (
                                select
                                    pr.pno
                                    ,pr.store_id
                                    ,pr.store_name
                                    ,t1.stat_date
                                    ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                                    ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                                    ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
                                from my_staging.parcel_route pr
                                join t t1 on t1.pno = pr.pno
                                where
                                    pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                                   and pr.routed_at >= date_sub(t1.stat_date, interval 8 hour)
                                  and pr.routed_at < date_add(t1.stat_date, interval 16 hour )
                            ) sc
                        where
                            sc.rk = 1
                    ) sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
                group by 1,2
            ) a
        left join my_staging.sys_store ss on ss.id = a.store_id
        left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
        left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
#         left join my_bi.fleet_time ft on ft.next_store_id = ss.id and ft.arrive_type in (3,5) and date(ft.real_arrive_time) = a.stat_date
        where
            ss.category in (1,10)
            and ss.id not in ('MY04040316','MY04040315','MY04070217')
    ) a2;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ds.dst_store_id as store_id
        ,pr.pno
        ,hst.sys_store_id hr_store_id
        ,hst.formal
        ,pr.staff_info_id
        ,pi.state
        ,hst.job_title
    from dwm.dwd_my_dc_should_be_delivery ds
    left join my_staging.parcel_route pr on pr.pno = ds.pno and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    left join my_staging.parcel_info pi on pi.pno = pr.pno
    left join my_bi.hr_staff_info hst on hst.staff_info_id = pr.staff_info_id
#     left join ph_bi.hr_staff_transfer hst  on hst.staff_info_id = pr.staff_info_id
    where
        ds.p_date = '2023-08-08'
        and pr.routed_at >= date_sub('2023-08-08', interval 8 hour )
        and pr.routed_at < date_add('2023-08-08', interval 16 hour)
        and ds.should_delevry_type != '非当日应派'
)
    select
        dr.store_id 网点ID
        ,dr.store_name 网点
        ,coalesce(dr.opening_at, '未记录') 开业时间
        ,case ss.category
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
        end 网点类型
        ,smp.name 片区
        ,smr.name 大区
        ,coalesce(emp_cnt.staf_num, 0) 总快递员人数_在职
        ,coalesce(a3.self_staff_num, 0) 自有快递员出勤数
        ,coalesce(a3.other_staff_num, 0) '外协+支援快递员出勤数'
        ,coalesce(a3.dco_dcs_num, 0) 仓管主管_出勤数

        ,coalesce(a3.avg_scan_num, 0) 快递员平均交接量
        ,coalesce(a3.avg_del_num, 0) 快递员平均妥投量
        ,coalesce(a3.dco_dcs_avg_scan, 0) 仓管主管_平均交接量

        ,coalesce(sdb.code_num, 0) 网点三段码数量
        ,coalesce(a2.self_avg_staff_code, 0) 自有快递员三段码平均交接量
        ,coalesce(a2.other_avg_staff_code, 0) '外协+支援快递员三段码平均交接量'
        ,coalesce(a2.self_avg_staff_del_code, 0) 自有快递员三段码平均妥投量
        ,coalesce(a2.other_avg_staff_del_code, 0) '外协+支援快递员三段码平均妥投量'
        ,coalesce(a2.avg_code_staff, 0) 三段码平均交接快递员数
        ,case
            when a2.avg_code_staff < 2 then 'A'
            when a2.avg_code_staff >= 2 and a2.avg_code_staff < 3 then 'B'
            when a2.avg_code_staff >= 3 and a2.avg_code_staff < 4 then 'C'
            when a2.avg_code_staff >= 4 then 'D'
        end 评级
        ,a2.code_num
        ,a2.staff_code_num
        ,a2.staff_num
        ,a2.fin_staff_code_num
    from
        (
            select
                a1.store_id
                ,count(distinct if(a1.job_title in (13,110,1 ), a1.staff_code, null)) staff_code_num
                ,count(distinct if(a1.job_title in (13,110,1199), a1.third_sorting_code, null)) code_num
                ,count(distinct if(a1.job_title in (13,110,1199), a1.staff_info_id, null)) staff_num
                ,count(distinct if(a1.job_title in (13,110,1199), a1.staff_code, null)) fin_staff_code_num
                ,count(distinct if(a1.job_title in (13,110,1199), a1.staff_code, null))/ count(distinct if(a1.job_title in (13,110,1199), a1.third_sorting_code, null)) avg_code_staff
                ,count(distinct if(a1.is_self = 'y' and a1.job_title in (13,110,1199), a1.staff_code, null))/count(distinct if(a1.is_self = 'y' and a1.job_title in (13,110,1199), a1.staff_info_id, null)) self_avg_staff_code
                ,count(distinct if(a1.is_self = 'n' and a1.job_title in (13,110,1199), a1.staff_code, null))/count(distinct if(a1.is_self = 'n' and a1.job_title in (13,110,1199), a1.staff_info_id, null)) other_avg_staff_code
                ,count(distinct if(a1.state = 5 and a1.is_self = 'y' and a1.job_title in (13,110,1199), a1.staff_code, null))/count(distinct if(a1.is_self = 'y' and a1.job_title in (13,110,1199), a1.staff_info_id, null)) self_avg_staff_del_code
                ,count(distinct if(a1.state = 5 and a1.is_self = 'n' and a1.job_title in (13,110,1199), a1.staff_code, null))/count(distinct if(a1.is_self = 'n' and a1.job_title in (13,110,1199), a1.staff_info_id, null)) other_avg_staff_del_code
            from
                (
                select
                    a1.*
                    ,concat(a1.staff_info_id, a1.third_sorting_code) staff_code
                from
                    (
                        select
                            t1.store_id
                            ,t1.pno
                            ,t1.staff_info_id
                            ,if(t1.formal = 1 and t1.store_id = t1.hr_store_id, 'y', 'n') is_self
                            ,t1.state
                            ,t1.job_title
                            ,ps.third_sorting_code
                            ,rank() over (partition by t1.pno order by ps.created_at desc) rk
                        from t t1
                        join my_drds_pro.parcel_sorting_code_info ps on  ps.pno = t1.pno and ps.dst_store_id = t1.store_id and ps.third_sorting_code not in  ('XX', 'YY', 'ZZ', '00')
                    ) a1
                where
                    a1.rk = 1
            ) a1
        left join my_staging.parcel_info pi on pi.pno = a1.pno
        group by 1
    ) a2
left join
    (
        select
            hr.sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  my_bi.hr_staff_info  hr
        where
            hr.formal = 1
            and hr.is_sub_staff= 0
            and hr.state = 1
            and hr.job_title in (13,110,1199)
        group by 1
    ) emp_cnt on emp_cnt.sys_store_id = a2.store_id
# left join
#     (
#         select
#            ad.sys_store_id
#            ,count(distinct ad.staff_info_id) as atd_emp_cnt -- 出勤人数
#        from ph_bi.attendance_data_v2 ad
#        left join ph_bi.hr_staff_info hr on hr.staff_info_id =ad.staff_info_id
#        where
#            (ad.attendance_started_at is not null or ad.attendance_end_at is not null)
#             and hr.job_title in (13,110,1000)
# #             and ad.stat_date = curdate()
#             and ad.stat_date = '${date}'
#        group by 1
#     ) att on att.sys_store_id = a2.store_id
left join dwm.dim_my_sys_store_rd dr on dr.store_id = a2.store_id and dr.stat_date = date_sub(curdate(), interval 1 day)
left join my_staging.sys_store ss on ss.id = a2.store_id
left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
left join
    (
        select
            t1.store_id
            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.formal = 1  and t1.job_title in (13,110,1199), t1.staff_info_id, null))  self_staff_num
            ,count(distinct if(t1.job_title in (13,110,1199) and ( t1.hr_store_id != t1.store_id or t1.formal != 1  ), t1.staff_info_id, null )) other_staff_num
            ,count(distinct if(t1.job_title in (13,110,1199), t1.pno, null))/count(distinct if(t1.job_title in (13,110,1199),  t1.staff_info_id, null)) avg_scan_num
            ,count(distinct if(t1.job_title in (13,110,1199) and t1.state = 5, t1.pno, null))/count(distinct if(t1.job_title in (13,110,1199) and t1.state = 5,  t1.staff_info_id, null)) avg_del_num

            ,count(distinct if(t1.job_title in (37,16), t1.staff_info_id, null)) dco_dcs_num
            ,count(distinct if(t1.job_title in (37,16), t1.pno, null))/count(distinct if(t1.job_title in (37,16), t1.staff_info_id, null)) dco_dcs_avg_scan
        from t t1
        group by 1
    ) a3  on a3.store_id = a2.store_id
left join
    (
        select
            gl.store_id
            ,count(distinct gl.grid_code) code_num
        from `my-amp`.grid_lib gl
        group by 1
    ) sdb on sdb.store_id = a2.store_id
where
    ss.category in (1,10)
    and sdb.store_id is not null;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ds.dst_store_id store_id
        ,ss.name
        ,ds.pno
        ,convert_tz(pi.finished_at, '+00:00', '+08:00') finished_time
        ,pi.ticket_delivery_staff_info_id
        ,pi.state
        ,coalesce(hsi.store_id, hs.sys_store_id) hr_store_id
        ,coalesce(hsi.job_title, hs.job_title) job_title
        ,coalesce(hsi.formal, hs.formal) formal
        ,row_number() over (partition by ds.dst_store_id, pi.ticket_delivery_staff_info_id order by pi.finished_at) rk1
        ,row_number() over (partition by ds.dst_store_id, pi.ticket_delivery_staff_info_id order by pi.finished_at desc) rk2
    from dwm.dwd_my_dc_should_be_delivery ds
    join my_staging.parcel_info pi on pi.pno = ds.pno
    left join my_staging.sys_store ss on ss.id = ds.dst_store_id
    left join my_bi.hr_staff_transfer hsi on hsi.staff_info_id = pi.ticket_delivery_staff_info_id and hsi.stat_date = '2023-08-08'
    left join my_bi.hr_staff_info hs on hs.staff_info_id = pi.ticket_delivery_staff_info_id and if(hs.leave_date is null, 1 = 1, hs.leave_date >= '2023-08-08')
#     left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pi.ticket_delivery_staff_info_id
    where
        pi.state = 5
#         and pi.finished_at >= '2023-08-01 16:00:00'
#         and pi.finished_at < '2023-08-02 16:00:00'
        and ds.p_date = '2023-08-08'
        and pi.finished_at >= date_sub('2023-08-08', interval 8 hour )
        and pi.finished_at < date_add('2023-08-08', interval 16 hour)
        and ds.should_delevry_type != '非当日应派'
)
select
    dp.store_id 网点ID
    ,dp.store_name 网点
    ,coalesce(dp.opening_at, '未记录') 开业时间
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,coalesce(cour.staf_num, 0) 本网点所属快递员数
    ,coalesce(ds.sd_num, 0) 应派件量
    ,coalesce(del.pno_num, 0) '妥投量(快递员+仓管+主管)'
    ,coalesce(del_cou.self_staff_num, 0) 参与妥投快递员_自有
    ,coalesce(del_cou.other_staff_num, 0) 参与妥投快递员_外协支援
    ,coalesce(del_cou.dco_dcs_num, 0) 参与妥投_仓管主管

    ,coalesce(del_cou.self_effect, 0) 当日人效_自有
    ,coalesce(del_cou.other_effect, 0) 当日人效_外协支援
    ,coalesce(del_cou.dco_dcs_effect, 0) 仓管主管人效
    ,coalesce(del_hour.avg_del_hour, 0) 派件小时数
from
    (
        select
            dp.store_id
            ,dp.store_name
            ,dp.opening_at
            ,dp.piece_name
            ,dp.region_name
        from dwm.dim_my_sys_store_rd dp
        left join my_staging.sys_store ss on ss.id = dp.store_id
        where
            dp.state_desc = '激活'
            and dp.stat_date = date_sub(curdate(), interval 1 day)
            and ss.category in (1,10)
    ) dp
left join
    (
        select
            hr.sys_store_id sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  my_bi.hr_staff_info hr
        where
            hr.formal = 1
            and hr.state = 1
            and hr.job_title in (13,110,1199)
#             and hr.stat_date = '${date}'
        group by 1
    ) cour on cour.sys_store_id = dp.store_id
left join
    (
        select
            ds.dst_store_id
            ,count(distinct ds.pno) sd_num
        from dwm.dwd_my_dc_should_be_delivery ds
        where
             ds.should_delevry_type != '非当日应派'
            and ds.p_date = '2023-08-08'
        group by 1
    ) ds on ds.dst_store_id = dp.store_id
left join
    (
        select
            t1.store_id
            ,count(distinct t1.pno) pno_num
        from t t1
        group by 1
    ) del on del.store_id = dp.store_id
left join
    (
        select
            t1.store_id
            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (13,110,1199) and t1.formal = 1, t1.ticket_delivery_staff_info_id, null)) self_staff_num
            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (13,110,1199) and t1.formal = 1, t1.pno, null))/count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (13,110,1199) and t1.formal = 1, t1.ticket_delivery_staff_info_id, null)) self_effect
            ,count(distinct if((t1.hr_store_id != t1.store_id or t1.formal != 1) and t1.job_title in (13,110,1199), t1.ticket_delivery_staff_info_id, null)) other_staff_num
            ,count(distinct if((t1.hr_store_id != t1.store_id or t1.formal != 1) and t1.job_title in (13,110,1199), t1.pno, null))/count(distinct if((t1.hr_store_id != t1.store_id or t1.formal != 1) and t1.job_title in (13,110,1199), t1.ticket_delivery_staff_info_id, null)) other_effect

            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (16,37), t1.ticket_delivery_staff_info_id, null)) dco_dcs_num
            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (16,37), t1.pno, null))/count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (16,37), t1.ticket_delivery_staff_info_id, null)) dco_dcs_effect
        from t t1
        group by 1
    ) del_cou on del_cou.store_id = dp.store_id
left join
    (
        select
            a.store_id
            ,a.name
            ,sum(diff_hour)/count(distinct a.ticket_delivery_staff_info_id) avg_del_hour
        from
            (
                select
                    t1.store_id
                    ,t1.name
                    ,t1.ticket_delivery_staff_info_id
                    ,t1.finished_time
                    ,t2.finished_time finished_at_2
                    ,timestampdiff(second, t1.finished_time, t2.finished_time)/3600 diff_hour
                from
                    (
                        select * from t t1 where t1.rk1 = 1
                    ) t1
                join
                    (
                        select * from t t2 where t2.rk2 = 2
                    ) t2 on t2.store_id = t1.store_id and t2.ticket_delivery_staff_info_id = t1.ticket_delivery_staff_info_id
            ) a
        group by 1,2
    ) del_hour on del_hour.store_id = dp.store_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        *
    from
        (
            select
                ad.*
                ,row_number() over (partition by ad.staff_info_id order by ad.stat_date desc) rk
            from
                (
                    select
                        ad.*
                        ,ad.attendance_time + ad.BT + ad.CT + ad.BT_Y + ad.AB total
                    from my_bi.attendance_data_v2 ad
                    join my_bi.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,1199,37,16) -- 在职且非待离职
                    where
                        ad.stat_date < '2023-08-09'

                ) ad
            where
                ad.total = 10
        ) ad
    where
        ad.rk < 8
)
select
    st.staff_info_id 工号
    ,if(hsi2.sys_store_id = '-1', 'Head office', dp.store_name) 网点
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,case
        when hsi2.job_title in (13,110,1199) then '快递员'
        when hsi2.job_title in (37) then '仓管员'
        when hsi2.job_title in (16) then '主管'
    end 角色
    ,st.late_num 迟到次数
    ,st.absence_sum 缺勤数据
    ,st.late_time_sum 迟到时长
    ,case
        when st.absence_sum = 0 and st.late_num <= 1 and st.late_time_sum < 30 then 'A'
        when st.absence_sum >= 2 or st.late_num >= 3  then 'C'
        else 'B'
    end 出勤评级
from
    (
        select
            a.staff_info_id
            ,count(if(a.late_or_not = 'y' ,a.stat_date, null)) late_num
            ,sum(if(a.late_or_not = 'y', a.late_time, 0)) late_time_sum
            ,sum(a.absence_time) absence_sum
        from
            (
                select
                    t1.*
                    ,if(t1.attendance_started_at > date_add(concat(t1.stat_date, ' ', t1.shift_start), interval 1 minute ) , 'y', 'n') late_or_not
                    ,if(t1.attendance_started_at > date_add(concat(t1.stat_date, ' ', t1.shift_start), interval 1 minute ) , timestampdiff(minute , concat(t1.stat_date, ' ', t1.shift_start), t1.attendance_started_at), 0) late_time
                    ,t1.AB/10 absence_time
                from t t1
            ) a
        group by 1
    ) st
left join my_bi.hr_staff_info hsi2 on hsi2.staff_info_id = st.staff_info_id
left join dwm.dim_my_sys_store_rd dp on dp.store_id = hsi2.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
order by 2,1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        *
    from
        (
            select
                ad.*
                ,row_number() over (partition by ad.staff_info_id order by ad.stat_date desc) rk
            from
                (
                    select
                        ad.*
                        ,ad.attendance_time + ad.BT + ad.CT + ad.BT_Y + ad.AB total
                    from my_bi.attendance_data_v2 ad
                    join my_bi.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,1199,37,16) -- 在职且非待离职
                    where
                        ad.stat_date < '2023-08-09'
#                         and hsi.hire_date <= date_sub(curdate(), interval 7 day )
#                         and ad.stat_date >= date_sub(curdate(), interval 30 day )
                ) ad
            where
                ad.total = 10
        ) ad
    where
        ad.rk < 8
)
select
    ss.store_id 网点ID
    ,dp.store_name 网点
    ,coalesce(dp.opening_at, '未记录') 开业时间
    ,case dp.store_category
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
    end 网点类型
    ,dp.region_name 大区
    ,dp.piece_name 片区
    ,case
        when ss.num/dp.on_emp_cnt < 0.05 then 'A'
        when ss.num/dp.on_emp_cnt >= 0.05 and ss.num/dp.on_emp_cnt < 0.1 then 'B'
        when ss.num/dp.on_emp_cnt >= 0.1 then 'C'
    end 出勤评级
    ,ss.num/dp.on_emp_cnt C级员工占比
    ,ss.num C级员工数
    ,dp.on_emp_cnt 在职员工数
    ,dp.on_dcs_cnt 主管数
    ,dp.on_dco_cnt 仓管数
    ,dp.on_dri_cnt 快递员数

    ,ss.avg_absence_num 近7天缺勤人次
    ,ss.avg_absence_num/7 近7天平均每天缺勤人次
    ,ss.avg_late_num 近7天迟到人次
    ,ss.avg_late_num/7 近7天平均每天迟到人次
from
    (
        select
            s.store_id
            ,count(if(s.ss_level = 'C', s.staff_info_id, null)) num
            ,sum(s.late_num) avg_late_num
            ,sum(s.absence_sum) avg_absence_num
        from
            (
                select
                    st.staff_info_id
                    ,dp.store_id
                    ,dp.store_name
                    ,dp.piece_name
                    ,dp.region_name
                    ,case
                        when hsi2.job_title in (13,110,1199) then '快递员'
                        when hsi2.job_title in (37) then '仓管员'
                        when hsi2.job_title in (16) then '主管'
                    end roles
                    ,st.late_num
                    ,st.absence_sum
                    ,case
                        when st.absence_sum = 0 and st.late_num <= 1 and st.late_time_sum < 30 then 'A'
                        when st.absence_sum >= 2 or st.late_num >= 3 then 'C'
                        else 'B'
                    end ss_level
                from
                    (
                        select
                            a.staff_info_id
                            ,count(if(a.late_or_not = 'y' ,a.stat_date, null)) late_num
#                             ,count(if(a.early_or_not = 'y', a.stat_date, null)) early_num
                            ,sum(if(a.late_or_not = 'y', a.late_time, 0)) late_time_sum
#                             ,sum(if(a.early_or_not = 'y', a.early_yime, 0)) early_time_sum
                            ,sum(a.absence_time) absence_sum
                        from
                            (
                                select
                                    t1.*
                                    ,if(t1.attendance_started_at > date_add(concat(t1.stat_date, ' ', t1.shift_start), interval 1 minute ) , 'y', 'n') late_or_not
                                    ,if(t1.attendance_started_at > date_add(concat(t1.stat_date, ' ', t1.shift_start), interval 1 minute ) , timestampdiff(minute , concat(t1.stat_date, ' ', t1.shift_start), t1.attendance_started_at), 0) late_time
#                                     ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, 'y', 'n' ) early_or_not
#                                     ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, timestampdiff(second, t1.attendance_end_at, t1.shift_end)/60, 0) early_yime
                                    ,t1.AB/10 absence_time
                                from t t1
                            ) a
                        group by 1
                    ) st
                left join my_bi.hr_staff_info hsi2 on hsi2.staff_info_id = st.staff_info_id
                left join dwm.dim_my_sys_store_rd dp on dp.store_id = hsi2.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
            ) s
        group by 1
    ) ss
left join
    (
        select
            hsi3.store_id store_id
            ,ss2.name store_name
            ,smp.name piece_name
            ,smr.name region_name
            ,ss2.category store_category
            ,ss2.opening_at
            ,count(if(hsi3.job_title in (13,110,1199,37,16), hsi3.staff_info_id, null)) on_emp_cnt
            ,count(if(hsi3.job_title in (13,110,1199), hsi3.staff_info_id, null)) on_dri_cnt
            ,count(if(hsi3.job_title in (37), hsi3.staff_info_id, null)) on_dco_cnt
            ,count(if(hsi3.job_title in (16), hsi3.staff_info_id, null)) on_dcs_cnt
        from my_bi.hr_staff_transfer  hsi3
        left join my_staging.sys_store ss2 on ss2.id = hsi3.store_id
        left join my_staging.sys_manage_piece smp on smp.id = ss2.manage_piece
        left join my_staging.sys_manage_region smr on smr.id = ss2.manage_region
        where
            hsi3.state = 1
            and hsi3.formal=1
            and hsi3.stat_date = date_sub(curdate(), interval 1 day)
        group by 1,2,3,4,5,6
    )dp on dp.store_id = ss.store_id
where
    dp.store_category in (1,10);
;-- -. . -..- - / . -. - .-. -.--
with d as
(
    select
         ds.dst_store_id store_id
        ,ds.pno
        ,ds.p_date stat_date
    from dwm.dwd_my_dc_should_be_delivery ds
    where
        ds.should_delevry_type = '1派应派包裹'
        and ds.p_date =  '2023-08-09'
#         and dst_store_id = 'MY09040318'
)
, t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
    from d ds
    left join
        (
            select
                pr.pno
                ,ds.stat_date
                ,max(convert_tz(pr.routed_at,'+00:00','+08:00')) remote_marker_time
            from my_staging.parcel_route pr
            join d ds on pr.pno = ds.pno
            where 1=1
                and pr.routed_at >= date_sub(ds.stat_date, interval 8 hour)
                and pr.routed_at < date_add(ds.stat_date, interval 16 hour)
                and pr.route_action = 'DETAIN_WAREHOUSE'
                and pr.marker_category in (42,43) ##岛屿,偏远地区
            group by 1,2
        ) pr1  on ds.pno = pr1.pno and ds.stat_date = pr1.stat_date  #当日留仓标记为偏远地区留待次日派送
    left join
        (
            select
               pr.pno
                ,ds.stat_date
               ,convert_tz(pr.routed_at,'+00:00','+08:00') reschedule_marker_time
               ,row_number() over(partition by ds.stat_date, pr.pno order by pr.routed_at desc) rk
            from my_staging.parcel_route pr
            join d ds on ds.pno = pr.pno
            where 1=1
                and pr.routed_at >= date_sub(ds.stat_date ,interval 15 day)
                and pr.routed_at <  date_sub(ds.stat_date ,interval 8 hour) #限定当日之前的改约
                and pr.route_action = 'DETAIN_WAREHOUSE'
                and from_unixtime(json_extract(pr.extra_value,'$.desiredat')) > date_add(ds.stat_date, interval 16 hour)
                and pr.marker_category in (9,14,70) ##客户改约时间
        ) pr2 on ds.pno = pr2.pno and pr2.stat_date = ds.stat_date and  pr2.rk = 1 #当日之前客户改约时间
    left join my_bi .dc_should_delivery_today ds1 on ds.pno = ds1.pno and ds1.state = 6 and ds1.stat_date = date_sub(ds.stat_date,interval 1 day)
    where
        case
            when pr1.pno is not null then 'N'
            when pr2.pno is not null then 'N'
            when ds1.pno is not null  then 'N'  else 'Y'
        end = 'Y'
)
select
    a2.*
from
    (
        select
            a.stat_date 日期
            ,a.store_id 网点ID
            ,ss.name 网点名称
            ,ss.opening_at 开业日期
            ,smr.name 大区
            ,smp.name 片区
            ,a.应交接
            ,a.已交接
#             ,date_format(ft.plan_arrive_time, '%Y-%m-%d %H:%i:%s') 计划到达时间
#             ,date_format(ft.real_arrive_time, '%Y-%m-%d %H:%i:%s') Kit到港考勤
#             ,date_format(ft.sign_time, '%Y-%m-%d %H:%i:%s') fleet签到时间
            ,concat(round(a.交接率*100,2),'%') as 交接率
            ,concat(ifnull(a.a_check,''), ifnull(a.b_check,''), ifnull(a.d_check,''), ifnull(a.e_check,''),if(a.a_check is null  and a.d_check is null and a.b_check is null and a.e_check is null, 'C', '')) 交接评级
            ,concat(round(a.A_rate * 100,2),'%')  'A时段（<0930 ）'
            ,concat(round(a.B_rate * 100,2),'%') 'B时段（0930<=X<1200）'
            ,concat(round(a.C_rate * 100,2),'%')'C时段（1200<=X<1600 ）'
            ,concat(round(a.D_rate * 100,2),'%')'D时段（>=1600）'
#             ,row_number() over (partition by date(ft.real_arrive_time), ft.next_store_id order by ft.real_arrive_time) rk
        from
            (
                select
                    t1.store_id
                    ,t1.stat_date
                    ,count(t1.pno) 应交接
                    ,count(if(sc.pno is not null , t1.pno, null)) 已交接
                    ,count(if(sc.pno is not null , t1.pno, null))/count(t1.pno) 交接率

                    ,count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as A_rate
                    ,count(if(time(sc.route_time) >= '09:30:00' and time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as B_rate
                    ,count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as C_rate
                    ,count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as D_rate

                    ,if(count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.95, 'A', null ) a_check
                    ,if(count(if(time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.98 and count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) <= 0.95, 'B', null ) b_check
                    ,if(count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03, 'D', null ) d_check
                    ,if(count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03 , 'E', null ) e_check
                from t t1
                left join
                    (
                        select
                            sc.*
                        from
                            (
                                select
                                    pr.pno
                                    ,pr.store_id
                                    ,pr.store_name
                                    ,t1.stat_date
                                    ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                                    ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                                    ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
                                from my_staging.parcel_route pr
                                join t t1 on t1.pno = pr.pno
                                where
                                    pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                                   and pr.routed_at >= date_sub(t1.stat_date, interval 8 hour)
                                  and pr.routed_at < date_add(t1.stat_date, interval 16 hour )
                            ) sc
                        where
                            sc.rk = 1
                    ) sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
                group by 1,2
            ) a
        left join my_staging.sys_store ss on ss.id = a.store_id
        left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
        left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
#         left join my_bi.fleet_time ft on ft.next_store_id = ss.id and ft.arrive_type in (3,5) and date(ft.real_arrive_time) = a.stat_date
        where
            ss.category in (1,10)
            and ss.id not in ('MY04040316','MY04040315','MY04070217')
    ) a2;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ds.dst_store_id as store_id
        ,pr.pno
        ,hst.sys_store_id hr_store_id
        ,hst.formal
        ,pr.staff_info_id
        ,pi.state
        ,hst.job_title
    from dwm.dwd_my_dc_should_be_delivery ds
    left join my_staging.parcel_route pr on pr.pno = ds.pno and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    left join my_staging.parcel_info pi on pi.pno = pr.pno
    left join my_bi.hr_staff_info hst on hst.staff_info_id = pr.staff_info_id
#     left join ph_bi.hr_staff_transfer hst  on hst.staff_info_id = pr.staff_info_id
    where
        ds.p_date = '2023-08-09'
        and pr.routed_at >= date_sub('2023-08-09', interval 8 hour )
        and pr.routed_at < date_add('2023-08-09', interval 16 hour)
        and ds.should_delevry_type != '非当日应派'
)
    select
        dr.store_id 网点ID
        ,dr.store_name 网点
        ,coalesce(dr.opening_at, '未记录') 开业时间
        ,case ss.category
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
        end 网点类型
        ,smp.name 片区
        ,smr.name 大区
        ,coalesce(emp_cnt.staf_num, 0) 总快递员人数_在职
        ,coalesce(a3.self_staff_num, 0) 自有快递员出勤数
        ,coalesce(a3.other_staff_num, 0) '外协+支援快递员出勤数'
        ,coalesce(a3.dco_dcs_num, 0) 仓管主管_出勤数

        ,coalesce(a3.avg_scan_num, 0) 快递员平均交接量
        ,coalesce(a3.avg_del_num, 0) 快递员平均妥投量
        ,coalesce(a3.dco_dcs_avg_scan, 0) 仓管主管_平均交接量

        ,coalesce(sdb.code_num, 0) 网点三段码数量
        ,coalesce(a2.self_avg_staff_code, 0) 自有快递员三段码平均交接量
        ,coalesce(a2.other_avg_staff_code, 0) '外协+支援快递员三段码平均交接量'
        ,coalesce(a2.self_avg_staff_del_code, 0) 自有快递员三段码平均妥投量
        ,coalesce(a2.other_avg_staff_del_code, 0) '外协+支援快递员三段码平均妥投量'
        ,coalesce(a2.avg_code_staff, 0) 三段码平均交接快递员数
        ,case
            when a2.avg_code_staff < 2 then 'A'
            when a2.avg_code_staff >= 2 and a2.avg_code_staff < 3 then 'B'
            when a2.avg_code_staff >= 3 and a2.avg_code_staff < 4 then 'C'
            when a2.avg_code_staff >= 4 then 'D'
        end 评级
        ,a2.code_num
        ,a2.staff_code_num
        ,a2.staff_num
        ,a2.fin_staff_code_num
    from
        (
            select
                a1.store_id
                ,count(distinct if(a1.job_title in (13,110,1 ), a1.staff_code, null)) staff_code_num
                ,count(distinct if(a1.job_title in (13,110,1199), a1.third_sorting_code, null)) code_num
                ,count(distinct if(a1.job_title in (13,110,1199), a1.staff_info_id, null)) staff_num
                ,count(distinct if(a1.job_title in (13,110,1199), a1.staff_code, null)) fin_staff_code_num
                ,count(distinct if(a1.job_title in (13,110,1199), a1.staff_code, null))/ count(distinct if(a1.job_title in (13,110,1199), a1.third_sorting_code, null)) avg_code_staff
                ,count(distinct if(a1.is_self = 'y' and a1.job_title in (13,110,1199), a1.staff_code, null))/count(distinct if(a1.is_self = 'y' and a1.job_title in (13,110,1199), a1.staff_info_id, null)) self_avg_staff_code
                ,count(distinct if(a1.is_self = 'n' and a1.job_title in (13,110,1199), a1.staff_code, null))/count(distinct if(a1.is_self = 'n' and a1.job_title in (13,110,1199), a1.staff_info_id, null)) other_avg_staff_code
                ,count(distinct if(a1.state = 5 and a1.is_self = 'y' and a1.job_title in (13,110,1199), a1.staff_code, null))/count(distinct if(a1.is_self = 'y' and a1.job_title in (13,110,1199), a1.staff_info_id, null)) self_avg_staff_del_code
                ,count(distinct if(a1.state = 5 and a1.is_self = 'n' and a1.job_title in (13,110,1199), a1.staff_code, null))/count(distinct if(a1.is_self = 'n' and a1.job_title in (13,110,1199), a1.staff_info_id, null)) other_avg_staff_del_code
            from
                (
                select
                    a1.*
                    ,concat(a1.staff_info_id, a1.third_sorting_code) staff_code
                from
                    (
                        select
                            t1.store_id
                            ,t1.pno
                            ,t1.staff_info_id
                            ,if(t1.formal = 1 and t1.store_id = t1.hr_store_id, 'y', 'n') is_self
                            ,t1.state
                            ,t1.job_title
                            ,ps.third_sorting_code
                            ,rank() over (partition by t1.pno order by ps.created_at desc) rk
                        from t t1
                        join my_drds_pro.parcel_sorting_code_info ps on  ps.pno = t1.pno and ps.dst_store_id = t1.store_id and ps.third_sorting_code not in  ('XX', 'YY', 'ZZ', '00')
                    ) a1
                where
                    a1.rk = 1
            ) a1
        left join my_staging.parcel_info pi on pi.pno = a1.pno
        group by 1
    ) a2
left join
    (
        select
            hr.sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  my_bi.hr_staff_info  hr
        where
            hr.formal = 1
            and hr.is_sub_staff= 0
            and hr.state = 1
            and hr.job_title in (13,110,1199)
        group by 1
    ) emp_cnt on emp_cnt.sys_store_id = a2.store_id
# left join
#     (
#         select
#            ad.sys_store_id
#            ,count(distinct ad.staff_info_id) as atd_emp_cnt -- 出勤人数
#        from ph_bi.attendance_data_v2 ad
#        left join ph_bi.hr_staff_info hr on hr.staff_info_id =ad.staff_info_id
#        where
#            (ad.attendance_started_at is not null or ad.attendance_end_at is not null)
#             and hr.job_title in (13,110,1000)
# #             and ad.stat_date = curdate()
#             and ad.stat_date = '${date}'
#        group by 1
#     ) att on att.sys_store_id = a2.store_id
left join dwm.dim_my_sys_store_rd dr on dr.store_id = a2.store_id and dr.stat_date = date_sub(curdate(), interval 1 day)
left join my_staging.sys_store ss on ss.id = a2.store_id
left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
left join
    (
        select
            t1.store_id
            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.formal = 1  and t1.job_title in (13,110,1199), t1.staff_info_id, null))  self_staff_num
            ,count(distinct if(t1.job_title in (13,110,1199) and ( t1.hr_store_id != t1.store_id or t1.formal != 1  ), t1.staff_info_id, null )) other_staff_num
            ,count(distinct if(t1.job_title in (13,110,1199), t1.pno, null))/count(distinct if(t1.job_title in (13,110,1199),  t1.staff_info_id, null)) avg_scan_num
            ,count(distinct if(t1.job_title in (13,110,1199) and t1.state = 5, t1.pno, null))/count(distinct if(t1.job_title in (13,110,1199) and t1.state = 5,  t1.staff_info_id, null)) avg_del_num

            ,count(distinct if(t1.job_title in (37,16), t1.staff_info_id, null)) dco_dcs_num
            ,count(distinct if(t1.job_title in (37,16), t1.pno, null))/count(distinct if(t1.job_title in (37,16), t1.staff_info_id, null)) dco_dcs_avg_scan
        from t t1
        group by 1
    ) a3  on a3.store_id = a2.store_id
left join
    (
        select
            gl.store_id
            ,count(distinct gl.grid_code) code_num
        from `my-amp`.grid_lib gl
        group by 1
    ) sdb on sdb.store_id = a2.store_id
where
    ss.category in (1,10)
    and sdb.store_id is not null;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ds.dst_store_id store_id
        ,ss.name
        ,ds.pno
        ,convert_tz(pi.finished_at, '+00:00', '+08:00') finished_time
        ,pi.ticket_delivery_staff_info_id
        ,pi.state
        ,coalesce(hsi.store_id, hs.sys_store_id) hr_store_id
        ,coalesce(hsi.job_title, hs.job_title) job_title
        ,coalesce(hsi.formal, hs.formal) formal
        ,row_number() over (partition by ds.dst_store_id, pi.ticket_delivery_staff_info_id order by pi.finished_at) rk1
        ,row_number() over (partition by ds.dst_store_id, pi.ticket_delivery_staff_info_id order by pi.finished_at desc) rk2
    from dwm.dwd_my_dc_should_be_delivery ds
    join my_staging.parcel_info pi on pi.pno = ds.pno
    left join my_staging.sys_store ss on ss.id = ds.dst_store_id
    left join my_bi.hr_staff_transfer hsi on hsi.staff_info_id = pi.ticket_delivery_staff_info_id and hsi.stat_date = '2023-08-09'
    left join my_bi.hr_staff_info hs on hs.staff_info_id = pi.ticket_delivery_staff_info_id and if(hs.leave_date is null, 1 = 1, hs.leave_date >= '2023-08-09')
#     left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pi.ticket_delivery_staff_info_id
    where
        pi.state = 5
#         and pi.finished_at >= '2023-08-01 16:00:00'
#         and pi.finished_at < '2023-08-02 16:00:00'
        and ds.p_date = '2023-08-09'
        and pi.finished_at >= date_sub('2023-08-09', interval 8 hour )
        and pi.finished_at < date_add('2023-08-09', interval 16 hour)
        and ds.should_delevry_type != '非当日应派'
)
select
    dp.store_id 网点ID
    ,dp.store_name 网点
    ,coalesce(dp.opening_at, '未记录') 开业时间
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,coalesce(cour.staf_num, 0) 本网点所属快递员数
    ,coalesce(ds.sd_num, 0) 应派件量
    ,coalesce(del.pno_num, 0) '妥投量(快递员+仓管+主管)'
    ,coalesce(del_cou.self_staff_num, 0) 参与妥投快递员_自有
    ,coalesce(del_cou.other_staff_num, 0) 参与妥投快递员_外协支援
    ,coalesce(del_cou.dco_dcs_num, 0) 参与妥投_仓管主管

    ,coalesce(del_cou.self_effect, 0) 当日人效_自有
    ,coalesce(del_cou.other_effect, 0) 当日人效_外协支援
    ,coalesce(del_cou.dco_dcs_effect, 0) 仓管主管人效
    ,coalesce(del_hour.avg_del_hour, 0) 派件小时数
from
    (
        select
            dp.store_id
            ,dp.store_name
            ,dp.opening_at
            ,dp.piece_name
            ,dp.region_name
        from dwm.dim_my_sys_store_rd dp
        left join my_staging.sys_store ss on ss.id = dp.store_id
        where
            dp.state_desc = '激活'
            and dp.stat_date = date_sub(curdate(), interval 1 day)
            and ss.category in (1,10)
    ) dp
left join
    (
        select
            hr.sys_store_id sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  my_bi.hr_staff_info hr
        where
            hr.formal = 1
            and hr.state = 1
            and hr.job_title in (13,110,1199)
#             and hr.stat_date = '${date}'
        group by 1
    ) cour on cour.sys_store_id = dp.store_id
left join
    (
        select
            ds.dst_store_id
            ,count(distinct ds.pno) sd_num
        from dwm.dwd_my_dc_should_be_delivery ds
        where
             ds.should_delevry_type != '非当日应派'
            and ds.p_date = '2023-08-09'
        group by 1
    ) ds on ds.dst_store_id = dp.store_id
left join
    (
        select
            t1.store_id
            ,count(distinct t1.pno) pno_num
        from t t1
        group by 1
    ) del on del.store_id = dp.store_id
left join
    (
        select
            t1.store_id
            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (13,110,1199) and t1.formal = 1, t1.ticket_delivery_staff_info_id, null)) self_staff_num
            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (13,110,1199) and t1.formal = 1, t1.pno, null))/count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (13,110,1199) and t1.formal = 1, t1.ticket_delivery_staff_info_id, null)) self_effect
            ,count(distinct if((t1.hr_store_id != t1.store_id or t1.formal != 1) and t1.job_title in (13,110,1199), t1.ticket_delivery_staff_info_id, null)) other_staff_num
            ,count(distinct if((t1.hr_store_id != t1.store_id or t1.formal != 1) and t1.job_title in (13,110,1199), t1.pno, null))/count(distinct if((t1.hr_store_id != t1.store_id or t1.formal != 1) and t1.job_title in (13,110,1199), t1.ticket_delivery_staff_info_id, null)) other_effect

            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (16,37), t1.ticket_delivery_staff_info_id, null)) dco_dcs_num
            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (16,37), t1.pno, null))/count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (16,37), t1.ticket_delivery_staff_info_id, null)) dco_dcs_effect
        from t t1
        group by 1
    ) del_cou on del_cou.store_id = dp.store_id
left join
    (
        select
            a.store_id
            ,a.name
            ,sum(diff_hour)/count(distinct a.ticket_delivery_staff_info_id) avg_del_hour
        from
            (
                select
                    t1.store_id
                    ,t1.name
                    ,t1.ticket_delivery_staff_info_id
                    ,t1.finished_time
                    ,t2.finished_time finished_at_2
                    ,timestampdiff(second, t1.finished_time, t2.finished_time)/3600 diff_hour
                from
                    (
                        select * from t t1 where t1.rk1 = 1
                    ) t1
                join
                    (
                        select * from t t2 where t2.rk2 = 2
                    ) t2 on t2.store_id = t1.store_id and t2.ticket_delivery_staff_info_id = t1.ticket_delivery_staff_info_id
            ) a
        group by 1,2
    ) del_hour on del_hour.store_id = dp.store_id;
;-- -. . -..- - / . -. - .-. -.--
select
    *
from `my-amp`.grid_lib gl
where
    gl.store_id in ('MY04070606','MY01010213','MY01020102','MY06010602','MY04010312','MY01020404','MY10030404','MY12020202','MY04010212','MY04070414','MY04070413','MY04040649','MY07050507','MY01020101','MY04010311','MY04070126','MY10070107','MY12030408','MY04040309','MY09090108','MY06011211','MY04050204','MY07050508','MY09040318','MY04040108','MY07110404','MY04040624');
;-- -. . -..- - / . -. - .-. -.--
select
    *
from `my-amp`.grid_lib gl
where
    gl.store_id in ('MY04020618','MY04070606','MY01010213','MY01020102','MY06010602','MY04010312','MY01020404','MY10030404','MY12020202','MY04010212','MY04070414','MY04070413','MY04040649','MY07050507','MY01020101','MY04010311','MY04070126','MY10070107','MY12030408','MY04040309','MY09090108','MY06011211','MY04050204','MY07050508','MY09040318','MY04040108','MY07110404','MY04040624');
;-- -. . -..- - / . -. - .-. -.--
select
    *
from `my-amp`.grid_lib gl
where
    gl.store_id in 'MY04020618','MY04070606','MY01010213','MY01020102','MY06010602','MY04010312','MY01020404','MY10030404','MY12020202','MY04010212','MY04070414','MY04070413','MY04040649','MY07050507','MY01020101','MY04010311','MY04070126','MY10070107','MY12030408','MY04040309','MY09090108','MY06011211','MY04050204','MY07050508','MY09040318','MY04040108','MY07110404','MY04040624'
);
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        *
    from
        (
            select
                ad.*
                ,row_number() over (partition by ad.staff_info_id order by ad.stat_date desc) rk
            from
                (
                    select
                        ad.*
                        ,ad.attendance_time + ad.BT + ad.CT + ad.BT_Y + ad.AB total
                    from my_bi.attendance_data_v2 ad
                    join my_bi.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,1199,37,16) -- 在职且非待离职
                    where
                        ad.stat_date < '2023-08-10'

                ) ad
            where
                ad.total = 10
        ) ad
    where
        ad.rk < 8
)
select
    st.staff_info_id 工号
    ,if(hsi2.sys_store_id = '-1', 'Head office', dp.store_name) 网点
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,case
        when hsi2.job_title in (13,110,1199) then '快递员'
        when hsi2.job_title in (37) then '仓管员'
        when hsi2.job_title in (16) then '主管'
    end 角色
    ,st.late_num 迟到次数
    ,st.absence_sum 缺勤数据
    ,st.late_time_sum 迟到时长
    ,case
        when st.absence_sum = 0 and st.late_num <= 1 and st.late_time_sum < 30 then 'A'
        when st.absence_sum >= 2 or st.late_num >= 3  then 'C'
        else 'B'
    end 出勤评级
from
    (
        select
            a.staff_info_id
            ,count(if(a.late_or_not = 'y' ,a.stat_date, null)) late_num
            ,sum(if(a.late_or_not = 'y', a.late_time, 0)) late_time_sum
            ,sum(a.absence_time) absence_sum
        from
            (
                select
                    t1.*
                    ,if(t1.attendance_started_at > date_add(concat(t1.stat_date, ' ', t1.shift_start), interval 1 minute ) , 'y', 'n') late_or_not
                    ,if(t1.attendance_started_at > date_add(concat(t1.stat_date, ' ', t1.shift_start), interval 1 minute ) , timestampdiff(minute , concat(t1.stat_date, ' ', t1.shift_start), t1.attendance_started_at), 0) late_time
                    ,t1.AB/10 absence_time
                from t t1
            ) a
        group by 1
    ) st
left join my_bi.hr_staff_info hsi2 on hsi2.staff_info_id = st.staff_info_id
left join dwm.dim_my_sys_store_rd dp on dp.store_id = hsi2.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
order by 2,1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        *
    from
        (
            select
                ad.*
                ,row_number() over (partition by ad.staff_info_id order by ad.stat_date desc) rk
            from
                (
                    select
                        ad.*
                        ,ad.attendance_time + ad.BT + ad.CT + ad.BT_Y + ad.AB total
                    from my_bi.attendance_data_v2 ad
                    join my_bi.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,1199,37,16) -- 在职且非待离职
                    where
                        ad.stat_date < '2023-08-10'
#                         and hsi.hire_date <= date_sub(curdate(), interval 7 day )
#                         and ad.stat_date >= date_sub(curdate(), interval 30 day )
                ) ad
            where
                ad.total = 10
        ) ad
    where
        ad.rk < 8
)
select
    ss.store_id 网点ID
    ,dp.store_name 网点
    ,coalesce(dp.opening_at, '未记录') 开业时间
    ,case dp.store_category
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
    end 网点类型
    ,dp.region_name 大区
    ,dp.piece_name 片区
    ,case
        when ss.num/dp.on_emp_cnt < 0.05 then 'A'
        when ss.num/dp.on_emp_cnt >= 0.05 and ss.num/dp.on_emp_cnt < 0.1 then 'B'
        when ss.num/dp.on_emp_cnt >= 0.1 then 'C'
    end 出勤评级
    ,ss.num/dp.on_emp_cnt C级员工占比
    ,ss.num C级员工数
    ,dp.on_emp_cnt 在职员工数
    ,dp.on_dcs_cnt 主管数
    ,dp.on_dco_cnt 仓管数
    ,dp.on_dri_cnt 快递员数

    ,ss.avg_absence_num 近7天缺勤人次
    ,ss.avg_absence_num/7 近7天平均每天缺勤人次
    ,ss.avg_late_num 近7天迟到人次
    ,ss.avg_late_num/7 近7天平均每天迟到人次
from
    (
        select
            s.store_id
            ,count(if(s.ss_level = 'C', s.staff_info_id, null)) num
            ,sum(s.late_num) avg_late_num
            ,sum(s.absence_sum) avg_absence_num
        from
            (
                select
                    st.staff_info_id
                    ,dp.store_id
                    ,dp.store_name
                    ,dp.piece_name
                    ,dp.region_name
                    ,case
                        when hsi2.job_title in (13,110,1199) then '快递员'
                        when hsi2.job_title in (37) then '仓管员'
                        when hsi2.job_title in (16) then '主管'
                    end roles
                    ,st.late_num
                    ,st.absence_sum
                    ,case
                        when st.absence_sum = 0 and st.late_num <= 1 and st.late_time_sum < 30 then 'A'
                        when st.absence_sum >= 2 or st.late_num >= 3 then 'C'
                        else 'B'
                    end ss_level
                from
                    (
                        select
                            a.staff_info_id
                            ,count(if(a.late_or_not = 'y' ,a.stat_date, null)) late_num
#                             ,count(if(a.early_or_not = 'y', a.stat_date, null)) early_num
                            ,sum(if(a.late_or_not = 'y', a.late_time, 0)) late_time_sum
#                             ,sum(if(a.early_or_not = 'y', a.early_yime, 0)) early_time_sum
                            ,sum(a.absence_time) absence_sum
                        from
                            (
                                select
                                    t1.*
                                    ,if(t1.attendance_started_at > date_add(concat(t1.stat_date, ' ', t1.shift_start), interval 1 minute ) , 'y', 'n') late_or_not
                                    ,if(t1.attendance_started_at > date_add(concat(t1.stat_date, ' ', t1.shift_start), interval 1 minute ) , timestampdiff(minute , concat(t1.stat_date, ' ', t1.shift_start), t1.attendance_started_at), 0) late_time
#                                     ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, 'y', 'n' ) early_or_not
#                                     ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, timestampdiff(second, t1.attendance_end_at, t1.shift_end)/60, 0) early_yime
                                    ,t1.AB/10 absence_time
                                from t t1
                            ) a
                        group by 1
                    ) st
                left join my_bi.hr_staff_info hsi2 on hsi2.staff_info_id = st.staff_info_id
                left join dwm.dim_my_sys_store_rd dp on dp.store_id = hsi2.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
            ) s
        group by 1
    ) ss
left join
    (
        select
            hsi3.store_id store_id
            ,ss2.name store_name
            ,smp.name piece_name
            ,smr.name region_name
            ,ss2.category store_category
            ,ss2.opening_at
            ,count(if(hsi3.job_title in (13,110,1199,37,16), hsi3.staff_info_id, null)) on_emp_cnt
            ,count(if(hsi3.job_title in (13,110,1199), hsi3.staff_info_id, null)) on_dri_cnt
            ,count(if(hsi3.job_title in (37), hsi3.staff_info_id, null)) on_dco_cnt
            ,count(if(hsi3.job_title in (16), hsi3.staff_info_id, null)) on_dcs_cnt
        from my_bi.hr_staff_transfer  hsi3
        left join my_staging.sys_store ss2 on ss2.id = hsi3.store_id
        left join my_staging.sys_manage_piece smp on smp.id = ss2.manage_piece
        left join my_staging.sys_manage_region smr on smr.id = ss2.manage_region
        where
            hsi3.state = 1
            and hsi3.formal=1
            and hsi3.stat_date = date_sub(curdate(), interval 1 day)
        group by 1,2,3,4,5,6
    )dp on dp.store_id = ss.store_id
where
    dp.store_category in (1,10);
;-- -. . -..- - / . -. - .-. -.--
with d as
(
    select
         ds.dst_store_id store_id
        ,ds.pno
        ,ds.p_date stat_date
    from dwm.dwd_my_dc_should_be_delivery ds
    where
        ds.should_delevry_type = '1派应派包裹'
        and ds.p_date =  '2023-08-10'
#         and dst_store_id = 'MY09040318'
)
, t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
    from d ds
    left join
        (
            select
                pr.pno
                ,ds.stat_date
                ,max(convert_tz(pr.routed_at,'+00:00','+08:00')) remote_marker_time
            from my_staging.parcel_route pr
            join d ds on pr.pno = ds.pno
            where 1=1
                and pr.routed_at >= date_sub(ds.stat_date, interval 8 hour)
                and pr.routed_at < date_add(ds.stat_date, interval 16 hour)
                and pr.route_action = 'DETAIN_WAREHOUSE'
                and pr.marker_category in (42,43) ##岛屿,偏远地区
            group by 1,2
        ) pr1  on ds.pno = pr1.pno and ds.stat_date = pr1.stat_date  #当日留仓标记为偏远地区留待次日派送
    left join
        (
            select
               pr.pno
                ,ds.stat_date
               ,convert_tz(pr.routed_at,'+00:00','+08:00') reschedule_marker_time
               ,row_number() over(partition by ds.stat_date, pr.pno order by pr.routed_at desc) rk
            from my_staging.parcel_route pr
            join d ds on ds.pno = pr.pno
            where 1=1
                and pr.routed_at >= date_sub(ds.stat_date ,interval 15 day)
                and pr.routed_at <  date_sub(ds.stat_date ,interval 8 hour) #限定当日之前的改约
                and pr.route_action = 'DETAIN_WAREHOUSE'
                and from_unixtime(json_extract(pr.extra_value,'$.desiredat')) > date_add(ds.stat_date, interval 16 hour)
                and pr.marker_category in (9,14,70) ##客户改约时间
        ) pr2 on ds.pno = pr2.pno and pr2.stat_date = ds.stat_date and  pr2.rk = 1 #当日之前客户改约时间
    left join my_bi .dc_should_delivery_today ds1 on ds.pno = ds1.pno and ds1.state = 6 and ds1.stat_date = date_sub(ds.stat_date,interval 1 day)
    where
        case
            when pr1.pno is not null then 'N'
            when pr2.pno is not null then 'N'
            when ds1.pno is not null  then 'N'  else 'Y'
        end = 'Y'
)
select
    a2.*
from
    (
        select
            a.stat_date 日期
            ,a.store_id 网点ID
            ,ss.name 网点名称
            ,ss.opening_at 开业日期
            ,smr.name 大区
            ,smp.name 片区
            ,a.应交接
            ,a.已交接
#             ,date_format(ft.plan_arrive_time, '%Y-%m-%d %H:%i:%s') 计划到达时间
#             ,date_format(ft.real_arrive_time, '%Y-%m-%d %H:%i:%s') Kit到港考勤
#             ,date_format(ft.sign_time, '%Y-%m-%d %H:%i:%s') fleet签到时间
            ,concat(round(a.交接率*100,2),'%') as 交接率
            ,concat(ifnull(a.a_check,''), ifnull(a.b_check,''), ifnull(a.d_check,''), ifnull(a.e_check,''),if(a.a_check is null  and a.d_check is null and a.b_check is null and a.e_check is null, 'C', '')) 交接评级
            ,concat(round(a.A_rate * 100,2),'%')  'A时段（<0930 ）'
            ,concat(round(a.B_rate * 100,2),'%') 'B时段（0930<=X<1200）'
            ,concat(round(a.C_rate * 100,2),'%')'C时段（1200<=X<1600 ）'
            ,concat(round(a.D_rate * 100,2),'%')'D时段（>=1600）'
#             ,row_number() over (partition by date(ft.real_arrive_time), ft.next_store_id order by ft.real_arrive_time) rk
        from
            (
                select
                    t1.store_id
                    ,t1.stat_date
                    ,count(t1.pno) 应交接
                    ,count(if(sc.pno is not null , t1.pno, null)) 已交接
                    ,count(if(sc.pno is not null , t1.pno, null))/count(t1.pno) 交接率

                    ,count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as A_rate
                    ,count(if(time(sc.route_time) >= '09:30:00' and time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as B_rate
                    ,count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as C_rate
                    ,count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as D_rate

                    ,if(count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.95, 'A', null ) a_check
                    ,if(count(if(time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.98 and count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) <= 0.95, 'B', null ) b_check
                    ,if(count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03, 'D', null ) d_check
                    ,if(count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03 , 'E', null ) e_check
                from t t1
                left join
                    (
                        select
                            sc.*
                        from
                            (
                                select
                                    pr.pno
                                    ,pr.store_id
                                    ,pr.store_name
                                    ,t1.stat_date
                                    ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                                    ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                                    ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
                                from my_staging.parcel_route pr
                                join t t1 on t1.pno = pr.pno
                                where
                                    pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                                   and pr.routed_at >= date_sub(t1.stat_date, interval 8 hour)
                                  and pr.routed_at < date_add(t1.stat_date, interval 16 hour )
                            ) sc
                        where
                            sc.rk = 1
                    ) sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
                group by 1,2
            ) a
        left join my_staging.sys_store ss on ss.id = a.store_id
        left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
        left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
#         left join my_bi.fleet_time ft on ft.next_store_id = ss.id and ft.arrive_type in (3,5) and date(ft.real_arrive_time) = a.stat_date
        where
            ss.category in (1,10)
            and ss.id not in ('MY04040316','MY04040315','MY04070217')
    ) a2;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ds.dst_store_id as store_id
        ,pr.pno
        ,hst.sys_store_id hr_store_id
        ,hst.formal
        ,pr.staff_info_id
        ,pi.state
        ,hst.job_title
    from dwm.dwd_my_dc_should_be_delivery ds
    left join my_staging.parcel_route pr on pr.pno = ds.pno and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    left join my_staging.parcel_info pi on pi.pno = pr.pno
    left join my_bi.hr_staff_info hst on hst.staff_info_id = pr.staff_info_id
#     left join ph_bi.hr_staff_transfer hst  on hst.staff_info_id = pr.staff_info_id
    where
        ds.p_date = '2023-08-10'
        and pr.routed_at >= date_sub('2023-08-10', interval 8 hour )
        and pr.routed_at < date_add('2023-08-10', interval 16 hour)
        and ds.should_delevry_type != '非当日应派'
)
    select
        dr.store_id 网点ID
        ,dr.store_name 网点
        ,coalesce(dr.opening_at, '未记录') 开业时间
        ,case ss.category
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
        end 网点类型
        ,smp.name 片区
        ,smr.name 大区
        ,coalesce(emp_cnt.staf_num, 0) 总快递员人数_在职
        ,coalesce(a3.self_staff_num, 0) 自有快递员出勤数
        ,coalesce(a3.other_staff_num, 0) '外协+支援快递员出勤数'
        ,coalesce(a3.dco_dcs_num, 0) 仓管主管_出勤数

        ,coalesce(a3.avg_scan_num, 0) 快递员平均交接量
        ,coalesce(a3.avg_del_num, 0) 快递员平均妥投量
        ,coalesce(a3.dco_dcs_avg_scan, 0) 仓管主管_平均交接量

        ,coalesce(sdb.code_num, 0) 网点三段码数量
        ,coalesce(a2.self_avg_staff_code, 0) 自有快递员三段码平均交接量
        ,coalesce(a2.other_avg_staff_code, 0) '外协+支援快递员三段码平均交接量'
        ,coalesce(a2.self_avg_staff_del_code, 0) 自有快递员三段码平均妥投量
        ,coalesce(a2.other_avg_staff_del_code, 0) '外协+支援快递员三段码平均妥投量'
        ,coalesce(a2.avg_code_staff, 0) 三段码平均交接快递员数
        ,case
            when a2.avg_code_staff < 2 then 'A'
            when a2.avg_code_staff >= 2 and a2.avg_code_staff < 3 then 'B'
            when a2.avg_code_staff >= 3 and a2.avg_code_staff < 4 then 'C'
            when a2.avg_code_staff >= 4 then 'D'
        end 评级
        ,a2.code_num
        ,a2.staff_code_num
        ,a2.staff_num
        ,a2.fin_staff_code_num
    from
        (
            select
                a1.store_id
                ,count(distinct if(a1.job_title in (13,110,1 ), a1.staff_code, null)) staff_code_num
                ,count(distinct if(a1.job_title in (13,110,1199), a1.third_sorting_code, null)) code_num
                ,count(distinct if(a1.job_title in (13,110,1199), a1.staff_info_id, null)) staff_num
                ,count(distinct if(a1.job_title in (13,110,1199), a1.staff_code, null)) fin_staff_code_num
                ,count(distinct if(a1.job_title in (13,110,1199), a1.staff_code, null))/ count(distinct if(a1.job_title in (13,110,1199), a1.third_sorting_code, null)) avg_code_staff
                ,count(distinct if(a1.is_self = 'y' and a1.job_title in (13,110,1199), a1.staff_code, null))/count(distinct if(a1.is_self = 'y' and a1.job_title in (13,110,1199), a1.staff_info_id, null)) self_avg_staff_code
                ,count(distinct if(a1.is_self = 'n' and a1.job_title in (13,110,1199), a1.staff_code, null))/count(distinct if(a1.is_self = 'n' and a1.job_title in (13,110,1199), a1.staff_info_id, null)) other_avg_staff_code
                ,count(distinct if(a1.state = 5 and a1.is_self = 'y' and a1.job_title in (13,110,1199), a1.staff_code, null))/count(distinct if(a1.is_self = 'y' and a1.job_title in (13,110,1199), a1.staff_info_id, null)) self_avg_staff_del_code
                ,count(distinct if(a1.state = 5 and a1.is_self = 'n' and a1.job_title in (13,110,1199), a1.staff_code, null))/count(distinct if(a1.is_self = 'n' and a1.job_title in (13,110,1199), a1.staff_info_id, null)) other_avg_staff_del_code
            from
                (
                select
                    a1.*
                    ,concat(a1.staff_info_id, a1.third_sorting_code) staff_code
                from
                    (
                        select
                            t1.store_id
                            ,t1.pno
                            ,t1.staff_info_id
                            ,if(t1.formal = 1 and t1.store_id = t1.hr_store_id, 'y', 'n') is_self
                            ,t1.state
                            ,t1.job_title
                            ,ps.third_sorting_code
                            ,rank() over (partition by t1.pno order by ps.created_at desc) rk
                        from t t1
                        join my_drds_pro.parcel_sorting_code_info ps on  ps.pno = t1.pno and ps.dst_store_id = t1.store_id and ps.third_sorting_code not in  ('XX', 'YY', 'ZZ', '00')
                    ) a1
                where
                    a1.rk = 1
            ) a1
        left join my_staging.parcel_info pi on pi.pno = a1.pno
        group by 1
    ) a2
left join
    (
        select
            hr.sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  my_bi.hr_staff_info  hr
        where
            hr.formal = 1
            and hr.is_sub_staff= 0
            and hr.state = 1
            and hr.job_title in (13,110,1199)
        group by 1
    ) emp_cnt on emp_cnt.sys_store_id = a2.store_id
# left join
#     (
#         select
#            ad.sys_store_id
#            ,count(distinct ad.staff_info_id) as atd_emp_cnt -- 出勤人数
#        from ph_bi.attendance_data_v2 ad
#        left join ph_bi.hr_staff_info hr on hr.staff_info_id =ad.staff_info_id
#        where
#            (ad.attendance_started_at is not null or ad.attendance_end_at is not null)
#             and hr.job_title in (13,110,1000)
# #             and ad.stat_date = curdate()
#             and ad.stat_date = '${date}'
#        group by 1
#     ) att on att.sys_store_id = a2.store_id
left join dwm.dim_my_sys_store_rd dr on dr.store_id = a2.store_id and dr.stat_date = date_sub(curdate(), interval 1 day)
left join my_staging.sys_store ss on ss.id = a2.store_id
left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
left join
    (
        select
            t1.store_id
            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.formal = 1  and t1.job_title in (13,110,1199), t1.staff_info_id, null))  self_staff_num
            ,count(distinct if(t1.job_title in (13,110,1199) and ( t1.hr_store_id != t1.store_id or t1.formal != 1  ), t1.staff_info_id, null )) other_staff_num
            ,count(distinct if(t1.job_title in (13,110,1199), t1.pno, null))/count(distinct if(t1.job_title in (13,110,1199),  t1.staff_info_id, null)) avg_scan_num
            ,count(distinct if(t1.job_title in (13,110,1199) and t1.state = 5, t1.pno, null))/count(distinct if(t1.job_title in (13,110,1199) and t1.state = 5,  t1.staff_info_id, null)) avg_del_num

            ,count(distinct if(t1.job_title in (37,16), t1.staff_info_id, null)) dco_dcs_num
            ,count(distinct if(t1.job_title in (37,16), t1.pno, null))/count(distinct if(t1.job_title in (37,16), t1.staff_info_id, null)) dco_dcs_avg_scan
        from t t1
        group by 1
    ) a3  on a3.store_id = a2.store_id
left join
    (
        select
            gl.store_id
            ,count(distinct gl.grid_code) code_num
        from `my-amp`.grid_lib gl
        group by 1
    ) sdb on sdb.store_id = a2.store_id
where
    ss.category in (1,10)
    and sdb.store_id is not null;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ds.dst_store_id store_id
        ,ss.name
        ,ds.pno
        ,convert_tz(pi.finished_at, '+00:00', '+08:00') finished_time
        ,pi.ticket_delivery_staff_info_id
        ,pi.state
        ,coalesce(hsi.store_id, hs.sys_store_id) hr_store_id
        ,coalesce(hsi.job_title, hs.job_title) job_title
        ,coalesce(hsi.formal, hs.formal) formal
        ,row_number() over (partition by ds.dst_store_id, pi.ticket_delivery_staff_info_id order by pi.finished_at) rk1
        ,row_number() over (partition by ds.dst_store_id, pi.ticket_delivery_staff_info_id order by pi.finished_at desc) rk2
    from dwm.dwd_my_dc_should_be_delivery ds
    join my_staging.parcel_info pi on pi.pno = ds.pno
    left join my_staging.sys_store ss on ss.id = ds.dst_store_id
    left join my_bi.hr_staff_transfer hsi on hsi.staff_info_id = pi.ticket_delivery_staff_info_id and hsi.stat_date = '2023-08-10'
    left join my_bi.hr_staff_info hs on hs.staff_info_id = pi.ticket_delivery_staff_info_id and if(hs.leave_date is null, 1 = 1, hs.leave_date >= '2023-08-10')
#     left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pi.ticket_delivery_staff_info_id
    where
        pi.state = 5
#         and pi.finished_at >= '2023-08-01 16:00:00'
#         and pi.finished_at < '2023-08-02 16:00:00'
        and ds.p_date = '2023-08-10'
        and pi.finished_at >= date_sub('2023-08-10', interval 8 hour )
        and pi.finished_at < date_add('2023-08-10', interval 16 hour)
        and ds.should_delevry_type != '非当日应派'
)
select
    dp.store_id 网点ID
    ,dp.store_name 网点
    ,coalesce(dp.opening_at, '未记录') 开业时间
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,coalesce(cour.staf_num, 0) 本网点所属快递员数
    ,coalesce(ds.sd_num, 0) 应派件量
    ,coalesce(del.pno_num, 0) '妥投量(快递员+仓管+主管)'
    ,coalesce(del_cou.self_staff_num, 0) 参与妥投快递员_自有
    ,coalesce(del_cou.other_staff_num, 0) 参与妥投快递员_外协支援
    ,coalesce(del_cou.dco_dcs_num, 0) 参与妥投_仓管主管

    ,coalesce(del_cou.self_effect, 0) 当日人效_自有
    ,coalesce(del_cou.other_effect, 0) 当日人效_外协支援
    ,coalesce(del_cou.dco_dcs_effect, 0) 仓管主管人效
    ,coalesce(del_hour.avg_del_hour, 0) 派件小时数
from
    (
        select
            dp.store_id
            ,dp.store_name
            ,dp.opening_at
            ,dp.piece_name
            ,dp.region_name
        from dwm.dim_my_sys_store_rd dp
        left join my_staging.sys_store ss on ss.id = dp.store_id
        where
            dp.state_desc = '激活'
            and dp.stat_date = date_sub(curdate(), interval 1 day)
            and ss.category in (1,10)
    ) dp
left join
    (
        select
            hr.sys_store_id sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  my_bi.hr_staff_info hr
        where
            hr.formal = 1
            and hr.state = 1
            and hr.job_title in (13,110,1199)
#             and hr.stat_date = '${date}'
        group by 1
    ) cour on cour.sys_store_id = dp.store_id
left join
    (
        select
            ds.dst_store_id
            ,count(distinct ds.pno) sd_num
        from dwm.dwd_my_dc_should_be_delivery ds
        where
             ds.should_delevry_type != '非当日应派'
            and ds.p_date = '2023-08-10'
        group by 1
    ) ds on ds.dst_store_id = dp.store_id
left join
    (
        select
            t1.store_id
            ,count(distinct t1.pno) pno_num
        from t t1
        group by 1
    ) del on del.store_id = dp.store_id
left join
    (
        select
            t1.store_id
            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (13,110,1199) and t1.formal = 1, t1.ticket_delivery_staff_info_id, null)) self_staff_num
            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (13,110,1199) and t1.formal = 1, t1.pno, null))/count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (13,110,1199) and t1.formal = 1, t1.ticket_delivery_staff_info_id, null)) self_effect
            ,count(distinct if((t1.hr_store_id != t1.store_id or t1.formal != 1) and t1.job_title in (13,110,1199), t1.ticket_delivery_staff_info_id, null)) other_staff_num
            ,count(distinct if((t1.hr_store_id != t1.store_id or t1.formal != 1) and t1.job_title in (13,110,1199), t1.pno, null))/count(distinct if((t1.hr_store_id != t1.store_id or t1.formal != 1) and t1.job_title in (13,110,1199), t1.ticket_delivery_staff_info_id, null)) other_effect

            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (16,37), t1.ticket_delivery_staff_info_id, null)) dco_dcs_num
            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (16,37), t1.pno, null))/count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (16,37), t1.ticket_delivery_staff_info_id, null)) dco_dcs_effect
        from t t1
        group by 1
    ) del_cou on del_cou.store_id = dp.store_id
left join
    (
        select
            a.store_id
            ,a.name
            ,sum(diff_hour)/count(distinct a.ticket_delivery_staff_info_id) avg_del_hour
        from
            (
                select
                    t1.store_id
                    ,t1.name
                    ,t1.ticket_delivery_staff_info_id
                    ,t1.finished_time
                    ,t2.finished_time finished_at_2
                    ,timestampdiff(second, t1.finished_time, t2.finished_time)/3600 diff_hour
                from
                    (
                        select * from t t1 where t1.rk1 = 1
                    ) t1
                join
                    (
                        select * from t t2 where t2.rk2 = 2
                    ) t2 on t2.store_id = t1.store_id and t2.ticket_delivery_staff_info_id = t1.ticket_delivery_staff_info_id
            ) a
        group by 1,2
    ) del_hour on del_hour.store_id = dp.store_id;
;-- -. . -..- - / . -. - .-. -.--
select
    *
from `my-amp`.grid_lib gl
where
    gl.store_id in ('MY04020618','MY04070606','MY01010213','MY01020102','MY06010602','MY04010312','MY01020404','MY10030404','MY12020202','MY04010212','MY04070414','MY04070413','MY04040649','MY07050507','MY01020101','MY04010311','MY04070126','MY10070107','MY12030408','MY04040309','MY09090108','MY06011211','MY04050204','MY07050508','MY09040318','MY04040108','MY07110404','MY04040624'
);
;-- -. . -..- - / . -. - .-. -.--
select
    *
from `my-amp`.grid_lib gl
where
    gl.store_id in ('MY07050508','MY06011211','MY10070107','MY04040624','MY09040318','MY04070413','MY04040649','MY04070414','MY04010312','MY04050204','MY01020101','MY01020404','MY06010602','MY04010311','MY04040309','MY04010212','MY04040108','MY12030408','MY01020102','MY07050507','MY04020618','MY04070126','MY09090108','MY04070606','MY12020202');
;-- -. . -..- - / . -. - .-. -.--
select
    *
from `my-amp`.grid_lib gl
where
    gl.store_id in ('MY07050508','MY06011211','MY10070107','MY04040624','MY09040318');
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ds.stat_date
        ,ds.pno
        ,ds.store_id
        ,ss.name
    from my_bi.dc_should_delivery_2023_07 ds
    left join my_staging.sys_store ss on ds.store_id = ss.id
    where
        ds.stat_date >= '2023-08-04'
        and ds.stat_date <= '2023-08-06'
)
select
    t1.stat_date 统计日期
    ,t1.store_id 网点ID
    ,t1.name 网点
    ,t1.pno 单号
    ,if(sc.pno is not null , '是', '否') 当日是否操作分拣扫描
    ,convert_tz(sc.routed_at, '+00:00', '+08:00') 当日第一次分拣扫描时间
    ,sc.staff_info_id 操作分拣扫描员工
    ,if(cf.pno is not null, '是', '否') 是否标记错分
    ,dmp.sorting_code 三段码
    ,dmp.third_sorting_code 第三段码
from t t1
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,pr.staff_info_id
            ,t1.stat_date
            ,row_number() over (partition by t1.stat_date,pr.pno order by pr.routed_at ) rk
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'SORTING_SCAN'
            and pr.routed_at >= date_sub(t1.stat_date,interval 8 hour)
            and pr.routed_at < date_add(t1.stat_date, interval 16 hour)
    ) sc on sc.pno = t1.pno and sc.rk = 1 and sc.stat_date = t1.stat_date
left join
    (
        select
            pr.pno
            ,t1.stat_date
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'DELIVERY_MARKER'
            and pr.marker_category = 31
            and pr.routed_at >= date_sub(t1.stat_date,interval 8 hour)
            and pr.routed_at < date_add(t1.stat_date, interval 16 hour)
        group by 1,2
    ) cf on cf.pno = t1.pno and cf.stat_date = t1.stat_date
left join
    (
        select
            dmp.pno
            ,dmp.sorting_code
            ,dmp.third_sorting_code
            ,row_number() over (partition by dmp.pno order by dmp.created_at desc) rk
        from dwm.drds_my_parcel_sorting_code_info dmp
        join t t1 on t1.pno = dmp.pno and dmp.dst_store_id = t1.store_id
    ) dmp on dmp.pno = t1.pno and dmp.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
select
        ds.stat_date
        ,ds.pno
        ,ds.store_id
        ,ss.name
    from my_bi.dc_should_delivery_2023_08 ds
    left join my_staging.sys_store ss on ds.store_id = ss.id
    where
        ds.stat_date >= '2023-08-04'
        and ds.stat_date <= '2023-08-06';
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ds.stat_date
        ,ds.pno
        ,ds.store_id
        ,ss.name
    from my_bi.dc_should_delivery_2023_08 ds
    left join my_staging.sys_store ss on ds.store_id = ss.id
    where
        ds.stat_date >= '2023-08-04'
        and ds.stat_date <= '2023-08-10'
)
select
    t1.stat_date 统计日期
    ,t1.store_id 网点ID
    ,t1.name 网点
    ,t1.pno 单号
    ,if(sc.pno is not null , '是', '否') 当日是否操作分拣扫描
    ,convert_tz(sc.routed_at, '+00:00', '+08:00') 当日第一次分拣扫描时间
    ,sc.staff_info_id 操作分拣扫描员工
    ,if(cf.pno is not null, '是', '否') 是否标记错分
    ,dmp.sorting_code 三段码
    ,dmp.third_sorting_code 第三段码
from t t1
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,pr.staff_info_id
            ,t1.stat_date
            ,row_number() over (partition by t1.stat_date,pr.pno order by pr.routed_at ) rk
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'SORTING_SCAN'
            and pr.routed_at >= date_sub(t1.stat_date,interval 8 hour)
            and pr.routed_at < date_add(t1.stat_date, interval 16 hour)
    ) sc on sc.pno = t1.pno and sc.rk = 1 and sc.stat_date = t1.stat_date
left join
    (
        select
            pr.pno
            ,t1.stat_date
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'DELIVERY_MARKER'
            and pr.marker_category = 31
            and pr.routed_at >= date_sub(t1.stat_date,interval 8 hour)
            and pr.routed_at < date_add(t1.stat_date, interval 16 hour)
        group by 1,2
    ) cf on cf.pno = t1.pno and cf.stat_date = t1.stat_date
left join
    (
        select
            dmp.pno
            ,dmp.sorting_code
            ,dmp.third_sorting_code
            ,row_number() over (partition by dmp.pno order by dmp.created_at desc) rk
        from dwm.drds_my_parcel_sorting_code_info dmp
        join t t1 on t1.pno = dmp.pno and dmp.dst_store_id = t1.store_id
    ) dmp on dmp.pno = t1.pno and dmp.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ds.stat_date
        ,ds.pno
        ,ds.store_id
        ,ss.name
    from my_bi.dc_should_delivery_today ds
    left join my_staging.sys_store ss on ds.store_id = ss.id
    where
        ds.stat_date >= '2023-08-07'
        and ds.stat_date <= '2023-08-10'
)
select
    t1.stat_date 统计日期
    ,t1.store_id 网点ID
    ,t1.name 网点
    ,t1.pno 单号
    ,if(sc.pno is not null , '是', '否') 当日是否操作分拣扫描
    ,convert_tz(sc.routed_at, '+00:00', '+08:00') 当日第一次分拣扫描时间
    ,sc.staff_info_id 操作分拣扫描员工
    ,if(cf.pno is not null, '是', '否') 是否标记错分
    ,dmp.sorting_code 三段码
    ,dmp.third_sorting_code 第三段码
from t t1
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,pr.staff_info_id
            ,t1.stat_date
            ,row_number() over (partition by t1.stat_date,pr.pno order by pr.routed_at ) rk
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'SORTING_SCAN'
            and pr.routed_at >= date_sub(t1.stat_date,interval 8 hour)
            and pr.routed_at < date_add(t1.stat_date, interval 16 hour)
    ) sc on sc.pno = t1.pno and sc.rk = 1 and sc.stat_date = t1.stat_date
left join
    (
        select
            pr.pno
            ,t1.stat_date
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'DELIVERY_MARKER'
            and pr.marker_category = 31
            and pr.routed_at >= date_sub(t1.stat_date,interval 8 hour)
            and pr.routed_at < date_add(t1.stat_date, interval 16 hour)
        group by 1,2
    ) cf on cf.pno = t1.pno and cf.stat_date = t1.stat_date
left join
    (
        select
            dmp.pno
            ,dmp.sorting_code
            ,dmp.third_sorting_code
            ,row_number() over (partition by dmp.pno order by dmp.created_at desc) rk
        from dwm.drds_my_parcel_sorting_code_info dmp
        join t t1 on t1.pno = dmp.pno and dmp.dst_store_id = t1.store_id
    ) dmp on dmp.pno = t1.pno and dmp.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ds.stat_date
        ,ds.pno
        ,ds.store_id
        ,ss.name
    from my_bi.dc_should_delivery_today ds
    left join my_staging.sys_store ss on ds.store_id = ss.id
    where
        ds.stat_date >= '2023-08-07'
        and ds.stat_date <= '2023-08-09'
)
select
    t1.stat_date 统计日期
    ,t1.store_id 网点ID
    ,t1.name 网点
    ,t1.pno 单号
    ,if(sc.pno is not null , '是', '否') 当日是否操作分拣扫描
    ,convert_tz(sc.routed_at, '+00:00', '+08:00') 当日第一次分拣扫描时间
    ,sc.staff_info_id 操作分拣扫描员工
    ,if(cf.pno is not null, '是', '否') 是否标记错分
    ,dmp.sorting_code 三段码
    ,dmp.third_sorting_code 第三段码
from t t1
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,pr.staff_info_id
            ,t1.stat_date
            ,row_number() over (partition by t1.stat_date,pr.pno order by pr.routed_at ) rk
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'SORTING_SCAN'
            and pr.routed_at >= date_sub(t1.stat_date,interval 8 hour)
            and pr.routed_at < date_add(t1.stat_date, interval 16 hour)
    ) sc on sc.pno = t1.pno and sc.rk = 1 and sc.stat_date = t1.stat_date
left join
    (
        select
            pr.pno
            ,t1.stat_date
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'DELIVERY_MARKER'
            and pr.marker_category = 31
            and pr.routed_at >= date_sub(t1.stat_date,interval 8 hour)
            and pr.routed_at < date_add(t1.stat_date, interval 16 hour)
        group by 1,2
    ) cf on cf.pno = t1.pno and cf.stat_date = t1.stat_date
left join
    (
        select
            dmp.pno
            ,dmp.sorting_code
            ,dmp.third_sorting_code
            ,row_number() over (partition by dmp.pno order by dmp.created_at desc) rk
        from dwm.drds_my_parcel_sorting_code_info dmp
        join t t1 on t1.pno = dmp.pno and dmp.dst_store_id = t1.store_id
    ) dmp on dmp.pno = t1.pno and dmp.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ds.stat_date
        ,ds.pno
        ,ds.store_id
        ,ss.name
    from my_bi.dc_should_delivery_today ds
    left join my_staging.sys_store ss on ds.store_id = ss.id
    where
        ds.stat_date >= '2023-08-10'
        and ds.stat_date <= '2023-08-10'
)
select
    t1.stat_date 统计日期
    ,t1.store_id 网点ID
    ,t1.name 网点
    ,t1.pno 单号
    ,if(sc.pno is not null , '是', '否') 当日是否操作分拣扫描
    ,convert_tz(sc.routed_at, '+00:00', '+08:00') 当日第一次分拣扫描时间
    ,sc.staff_info_id 操作分拣扫描员工
    ,if(cf.pno is not null, '是', '否') 是否标记错分
    ,dmp.sorting_code 三段码
    ,dmp.third_sorting_code 第三段码
from t t1
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,pr.staff_info_id
            ,t1.stat_date
            ,row_number() over (partition by t1.stat_date,pr.pno order by pr.routed_at ) rk
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'SORTING_SCAN'
            and pr.routed_at >= date_sub(t1.stat_date,interval 8 hour)
            and pr.routed_at < date_add(t1.stat_date, interval 16 hour)
    ) sc on sc.pno = t1.pno and sc.rk = 1 and sc.stat_date = t1.stat_date
left join
    (
        select
            pr.pno
            ,t1.stat_date
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'DELIVERY_MARKER'
            and pr.marker_category = 31
            and pr.routed_at >= date_sub(t1.stat_date,interval 8 hour)
            and pr.routed_at < date_add(t1.stat_date, interval 16 hour)
        group by 1,2
    ) cf on cf.pno = t1.pno and cf.stat_date = t1.stat_date
left join
    (
        select
            dmp.pno
            ,dmp.sorting_code
            ,dmp.third_sorting_code
            ,row_number() over (partition by dmp.pno order by dmp.created_at desc) rk
        from dwm.drds_my_parcel_sorting_code_info dmp
        join t t1 on t1.pno = dmp.pno and dmp.dst_store_id = t1.store_id
    ) dmp on dmp.pno = t1.pno and dmp.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ds.stat_date
        ,ds.pno
        ,ds.store_id
        ,ss.name
    from my_bi.dc_should_delivery_today ds
    left join my_staging.sys_store ss on ds.store_id = ss.id
    where
        ds.stat_date >= '2023-08-11'
        and ds.stat_date <= '2023-08-13'
)
select
    t1.stat_date 统计日期
    ,t1.store_id 网点ID
    ,t1.name 网点
    ,t1.pno 单号
    ,if(sc.pno is not null , '是', '否') 当日是否操作分拣扫描
    ,convert_tz(sc.routed_at, '+00:00', '+08:00') 当日第一次分拣扫描时间
    ,sc.staff_info_id 操作分拣扫描员工
    ,if(cf.pno is not null, '是', '否') 是否标记错分
    ,dmp.sorting_code 三段码
    ,dmp.third_sorting_code 第三段码
from t t1
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,pr.staff_info_id
            ,t1.stat_date
            ,row_number() over (partition by t1.stat_date,pr.pno order by pr.routed_at ) rk
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'SORTING_SCAN'
            and pr.routed_at >= date_sub(t1.stat_date,interval 8 hour)
            and pr.routed_at < date_add(t1.stat_date, interval 16 hour)
    ) sc on sc.pno = t1.pno and sc.rk = 1 and sc.stat_date = t1.stat_date
left join
    (
        select
            pr.pno
            ,t1.stat_date
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'DELIVERY_MARKER'
            and pr.marker_category = 31
            and pr.routed_at >= date_sub(t1.stat_date,interval 8 hour)
            and pr.routed_at < date_add(t1.stat_date, interval 16 hour)
        group by 1,2
    ) cf on cf.pno = t1.pno and cf.stat_date = t1.stat_date
left join
    (
        select
            dmp.pno
            ,dmp.sorting_code
            ,dmp.third_sorting_code
            ,row_number() over (partition by dmp.pno order by dmp.created_at desc) rk
        from dwm.drds_my_parcel_sorting_code_info dmp
        join t t1 on t1.pno = dmp.pno and dmp.dst_store_id = t1.store_id
    ) dmp on dmp.pno = t1.pno and dmp.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
with d as
(
    select
         ds.dst_store_id store_id
        ,ds.pno
        ,ds.p_date stat_date
    from dwm.dwd_my_dc_should_be_delivery ds
    where
        ds.should_delevry_type = '1派应派包裹'
        and ds.p_date =  '2023-08-21'
#         and dst_store_id = 'MY09040318'
)
, t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
    from d ds
    left join
        (
            select
                pr.pno
                ,ds.stat_date
                ,max(convert_tz(pr.routed_at,'+00:00','+08:00')) remote_marker_time
            from my_staging.parcel_route pr
            join d ds on pr.pno = ds.pno
            where 1=1
                and pr.routed_at >= date_sub(ds.stat_date, interval 8 hour)
                and pr.routed_at < date_add(ds.stat_date, interval 16 hour)
                and pr.route_action = 'DETAIN_WAREHOUSE'
                and pr.marker_category in (42,43) ##岛屿,偏远地区
            group by 1,2
        ) pr1  on ds.pno = pr1.pno and ds.stat_date = pr1.stat_date  #当日留仓标记为偏远地区留待次日派送
    left join
        (
            select
               pr.pno
                ,ds.stat_date
               ,convert_tz(pr.routed_at,'+00:00','+08:00') reschedule_marker_time
               ,row_number() over(partition by ds.stat_date, pr.pno order by pr.routed_at desc) rk
            from my_staging.parcel_route pr
            join d ds on ds.pno = pr.pno
            where 1=1
                and pr.routed_at >= date_sub(ds.stat_date ,interval 15 day)
                and pr.routed_at <  date_sub(ds.stat_date ,interval 8 hour) #限定当日之前的改约
                and pr.route_action = 'DETAIN_WAREHOUSE'
                and from_unixtime(json_extract(pr.extra_value,'$.desiredat')) > date_add(ds.stat_date, interval 16 hour)
                and pr.marker_category in (9,14,70) ##客户改约时间
        ) pr2 on ds.pno = pr2.pno and pr2.stat_date = ds.stat_date and  pr2.rk = 1 #当日之前客户改约时间
    left join my_bi .dc_should_delivery_today ds1 on ds.pno = ds1.pno and ds1.state = 6 and ds1.stat_date = date_sub(ds.stat_date,interval 1 day)
    where
        case
            when pr1.pno is not null then 'N'
            when pr2.pno is not null then 'N'
            when ds1.pno is not null  then 'N'  else 'Y'
        end = 'Y'
)
# select
#     a2.*
# from
#     (
#         select
#             a.stat_date 日期
#             ,a.store_id 网点ID
#             ,ss.name 网点名称
#             ,ss.opening_at 开业日期
#             ,smr.name 大区
#             ,smp.name 片区
#             ,a.应交接
#             ,a.已交接
# #             ,date_format(ft.plan_arrive_time, '%Y-%m-%d %H:%i:%s') 计划到达时间
# #             ,date_format(ft.real_arrive_time, '%Y-%m-%d %H:%i:%s') Kit到港考勤
# #             ,date_format(ft.sign_time, '%Y-%m-%d %H:%i:%s') fleet签到时间
#             ,concat(round(a.交接率*100,2),'%') as 交接率
#             ,concat(ifnull(a.a_check,''), ifnull(a.b_check,''), ifnull(a.d_check,''), ifnull(a.e_check,''),if(a.a_check is null  and a.d_check is null and a.b_check is null and a.e_check is null, 'C', '')) 交接评级
#             ,concat(round(a.A_rate * 100,2),'%')  'A时段（<0930 ）'
#             ,concat(round(a.B_rate * 100,2),'%') 'B时段（0930<=X<1200）'
#             ,concat(round(a.C_rate * 100,2),'%')'C时段（1200<=X<1600 ）'
#             ,concat(round(a.D_rate * 100,2),'%')'D时段（>=1600）'
# #             ,row_number() over (partition by date(ft.real_arrive_time), ft.next_store_id order by ft.real_arrive_time) rk
#         from
#             (
#                 select
#                     t1.store_id
#                     ,t1.stat_date
#                     ,count(t1.pno) 应交接
#                     ,count(if(sc.pno is not null , t1.pno, null)) 已交接
#                     ,count(if(sc.pno is not null , t1.pno, null))/count(t1.pno) 交接率
#
#                     ,count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as A_rate
#                     ,count(if(time(sc.route_time) >= '09:30:00' and time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as B_rate
#                     ,count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as C_rate
#                     ,count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as D_rate
#
#                     ,if(count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.95, 'A', null ) a_check
#                     ,if(count(if(time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.98 and count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) <= 0.95, 'B', null ) b_check
#                     ,if(count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03, 'D', null ) d_check
#                     ,if(count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03 , 'E', null ) e_check
#                 from t t1
#                 left join
#                     (
                        select
                            sc.*
                        from
                            (
                                select
                                    pr.pno
                                    ,pr.store_id
                                    ,pr.store_name
                                    ,t1.stat_date
                                    ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                                    ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                                    ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
                                from my_staging.parcel_route pr
                                join t t1 on t1.pno = pr.pno
                                where
                                    pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                                   and pr.routed_at >= date_sub(t1.stat_date, interval 8 hour)
                                  and pr.routed_at < date_add(t1.stat_date, interval 16 hour )
                            ) sc
                        where
                            sc.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        a.*
        ,row_number() over (partition by a.dst_store_id, a.third_sorting_code order by a.routed_at) rk1
        ,row_number() over (partition by a.dst_store_id, a.third_sorting_code order by a.routed_at desc ) rk2
    from
        (
            select
                a.*
                ,row_number() over (partition by a.pno order by a.routed_at) rk
            from
                (
                    select
                        ds.dst_store_id
                        ,dp.third_sorting_code
                        ,ds.pno
                        ,ds.should_delevry_type
                        ,pr.staff_info_id
                        ,pr.routed_at
                        ,rank() over (partition by ds.pno order by dp.created_at desc ) rn
                    from dwm.dwd_my_dc_should_be_delivery_d ds
                    left join dwm.drds_my_parcel_sorting_code_info dp on ds.pno = dp.pno and ds.dst_store_id = dp.dst_store_id
                    join my_staging.parcel_route pr on pr.pno = dp.pno and pr.route_action = 'SORTING_SCAN' and pr.routed_at >= '2023-08-23 16:00:00' and pr.routed_at < '2023-08-24 16:00:00'
                    where
                        ds.p_date = '2023-08-24'
#                         and ds.should_delevry_type = '1派应派包裹'
                ) a
            where
                a.rn = 1
        ) a
    where
        a.rk = 1
)
select
    t1.dst_store_id 网点id
    ,dt.store_name 网点
    ,dt.piece_name 片区
    ,dt.region_name 大区
    ,t1.third_sorting_code 三段码
    ,convert_tz(t1.routed_at, '+00:00', '+08:00') 第一次分拣扫描时间
    ,convert_tz(t2.routed_at, '+00:00', '+08:00') 最后一次分拣扫描时间
    ,count(distinct t3.pno) 该三段码第一次与最后一次分拣扫描时间之间扫描单量
    ,count(distinct if(t3.third_sorting_code = t1.third_sorting_code, t3.pno, null))/count(distinct t3.pno) 本三段码扫描占比
#     ,t3.pno
#     ,convert_tz(t3.routed_at, '+00:00', '+08:00') 分拣时间

from
    (
        select
            t1.*
        from t t1
        where
            t1.rk1 = 1
    ) t1
left join
    (
        select
            t1.*
        from t t1
        where
            t1.rk2 = 1
    ) t2 on t2.dst_store_id = t1.dst_store_id and t2.third_sorting_code = t1.third_sorting_code
left join t t3 on t3.dst_store_id = t1.dst_store_id and t3.routed_at >= t1.routed_at and t3.routed_at <= t2.routed_at
left join dwm.dim_my_sys_store_rd dt on dt.store_id = t1.dst_store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
# where
#     t1.dst_store_id = 'PH61205504'
group by 1,2,3,4,5,6,7;
;-- -. . -..- - / . -. - .-. -.--
select
    a.dst_store_id 网点ID
    ,dt.store_name 网点
    ,dt.piece_name 片区
    ,dt.region_name 大区
    ,a.third_sorting_code 三段码
    ,a.pno
    ,a.should_delevry_type
    ,a.staff_info_id
    ,convert_tz(a.routed_at, '+00:00', '+08:00') 分拣时间
#     ,row_number() over (partition by a.dst_store_id, a.third_sorting_code order by a.routed_at) 正向排序
#     ,row_number() over (partition by a.dst_store_id, a.third_sorting_code order by a.routed_at desc ) 逆向排序
from
    (
        select
            a.*
            ,row_number() over (partition by a.pno order by a.routed_at) rk
        from
            (
                select
                    ds.dst_store_id
                    ,dp.third_sorting_code
                    ,ds.pno
                    ,ds.should_delevry_type
                    ,pr.staff_info_id
                    ,pr.routed_at
                    ,rank() over (partition by ds.pno order by dp.created_at desc ) rn
                from dwm.dwd_my_dc_should_be_delivery_d ds
                left join dwm.drds_my_parcel_sorting_code_info  dp on ds.pno = dp.pno and ds.dst_store_id = dp.dst_store_id
                join my_staging.parcel_route pr on pr.pno = dp.pno and pr.route_action = 'SORTING_SCAN' and pr.routed_at >= '2023-08-23 16:00:00' and pr.routed_at < '2023-08-24 16:00:00'
                where
                    ds.p_date = '2023-08-24'
            ) a
        where
            a.rn = 1
    ) a
left join dwm.dim_ph_sys_store_rd dt on dt.store_id = a.dst_store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
where
    a.rk = 1
    and dt.store_name in ('BFT_SP-Beaufort','KEG_SP-Keningau','LBN_SP-Labuan','KKB_SP-Kota Kinabalu','SDK_SP-Sandakan');
;-- -. . -..- - / . -. - .-. -.--
select
    a.dst_store_id 网点ID
    ,dt.store_name 网点
    ,dt.piece_name 片区
    ,dt.region_name 大区
    ,a.third_sorting_code 三段码
    ,a.pno
    ,a.should_delevry_type
    ,a.staff_info_id
    ,convert_tz(a.routed_at, '+00:00', '+08:00') 分拣时间
#     ,row_number() over (partition by a.dst_store_id, a.third_sorting_code order by a.routed_at) 正向排序
#     ,row_number() over (partition by a.dst_store_id, a.third_sorting_code order by a.routed_at desc ) 逆向排序
from
    (
        select
            a.*
            ,row_number() over (partition by a.pno order by a.routed_at) rk
        from
            (
                select
                    ds.dst_store_id
                    ,dp.third_sorting_code
                    ,ds.pno
                    ,ds.should_delevry_type
                    ,pr.staff_info_id
                    ,pr.routed_at
                    ,rank() over (partition by ds.pno order by dp.created_at desc ) rn
                from dwm.dwd_my_dc_should_be_delivery_d ds
                left join dwm.drds_my_parcel_sorting_code_info  dp on ds.pno = dp.pno and ds.dst_store_id = dp.dst_store_id
                join my_staging.parcel_route pr on pr.pno = dp.pno and pr.route_action = 'SORTING_SCAN' and pr.routed_at >= '2023-08-23 16:00:00' and pr.routed_at < '2023-08-24 16:00:00'
                where
                    ds.p_date = '2023-08-24'
            ) a
        where
            a.rn = 1
    ) a
left join dwm.dim_my_sys_store_rd dt on dt.store_id = a.dst_store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
where
    a.rk = 1
    and dt.store_name in ('BFT_SP-Beaufort','KEG_SP-Keningau','LBN_SP-Labuan','KKB_SP-Kota Kinabalu','SDK_SP-Sandakan');
;-- -. . -..- - / . -. - .-. -.--
select
    *
from `my-amp`.grid_lib gl
where
    gl.store_id in ('MY15050301');
;-- -. . -..- - / . -. - .-. -.--
select
    a.dst_store_id 网点ID
    ,dt.store_name 网点
    ,dt.piece_name 片区
    ,dt.region_name 大区
    ,a.third_sorting_code 三段码
    ,a.pno
    ,a.should_delevry_type
    ,a.staff_info_id
    ,convert_tz(a.routed_at, '+00:00', '+08:00') 分拣时间
#     ,row_number() over (partition by a.dst_store_id, a.third_sorting_code order by a.routed_at) 正向排序
#     ,row_number() over (partition by a.dst_store_id, a.third_sorting_code order by a.routed_at desc ) 逆向排序
from
    (
        select
            a.*
            ,row_number() over (partition by a.pno order by a.routed_at) rk
        from
            (
                select
                    ds.dst_store_id
                    ,dp.third_sorting_code
                    ,ds.pno
                    ,ds.should_delevry_type
                    ,pr.staff_info_id
                    ,pr.routed_at
                    ,rank() over (partition by ds.pno order by dp.created_at desc ) rn
                from dwm.dwd_my_dc_should_be_delivery_d ds
                left join dwm.drds_my_parcel_sorting_code_info  dp on ds.pno = dp.pno and ds.dst_store_id = dp.dst_store_id
                join my_staging.parcel_route pr on pr.pno = dp.pno and pr.route_action = 'SORTING_SCAN' and pr.routed_at >= '2023-08-23 16:00:00' and pr.routed_at < '2023-08-24 16:00:00'
                where
                    ds.p_date = '2023-08-26'
            ) a
        where
            a.rn = 1
    ) a
left join dwm.dim_my_sys_store_rd dt on dt.store_id = a.dst_store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
where
    a.rk = 1
    and dt.store_id in ('MY10100400','MY13010100','MY12020100','MY11070100','MY10060100','MY10080200','MY11050400','MY11090100','MY13010101','MY10040300','MY10070309','MY10030300','MY11050300','MY10010100','MY10120500','MY10100600','MY12030400','MY07030100','MY10080201','MY12040101','MY04070401','MY06010101','MY04020200','MY06011200','MY06010103','MY04010200','MY04060400','MY04080400','MY04040101','MY04060500','MY04040605','MY04040100','MY06010205','MY04070600','MY06010700','MY06010704','MY04080100','MY04060200','MY04070205','MY06011100','MY04010300','MY14040310','MY15050315','MY15010100','MY14070400','MY16010100','MY15110100','MY15170100','MY15210100','MY15020100','MY14060400','MY14020200','MY14100300','MY15050301','MY14040200','MY01070200','MY02010101','MY01030100','MY01010200','MY02010100','MY03060100','MY01020504','MY03030200','MY02030300','MY03060617','MY09090100','MY09020100','MY07110100','MY07100300','MY09080200','MY08070200','MY07010100','MY09040300','MY07070101','MY08010300','MY04040600','MY04050200');
;-- -. . -..- - / . -. - .-. -.--
select
    a.dst_store_id 网点ID
    ,dt.store_name 网点
    ,dt.piece_name 片区
    ,dt.region_name 大区
    ,a.third_sorting_code 三段码
    ,a.pno
    ,a.should_delevry_type
    ,a.staff_info_id
    ,convert_tz(a.routed_at, '+00:00', '+08:00') 分拣时间
#     ,row_number() over (partition by a.dst_store_id, a.third_sorting_code order by a.routed_at) 正向排序
#     ,row_number() over (partition by a.dst_store_id, a.third_sorting_code order by a.routed_at desc ) 逆向排序
from
    (
        select
            a.*
            ,row_number() over (partition by a.pno order by a.routed_at) rk
        from
            (
                select
                    ds.dst_store_id
                    ,dp.third_sorting_code
                    ,ds.pno
                    ,ds.should_delevry_type
                    ,pr.staff_info_id
                    ,pr.routed_at
                    ,rank() over (partition by ds.pno order by dp.created_at desc ) rn
                from dwm.dwd_my_dc_should_be_delivery_d ds
                left join dwm.drds_my_parcel_sorting_code_info  dp on ds.pno = dp.pno and ds.dst_store_id = dp.dst_store_id
                join my_staging.parcel_route pr on pr.pno = dp.pno and pr.route_action = 'SORTING_SCAN' and pr.routed_at >= '2023-08-23 16:00:00' and pr.routed_at < '2023-08-24 16:00:00'
                where
                    ds.p_date = '2023-08-27'
            ) a
        where
            a.rn = 1
    ) a
left join dwm.dim_my_sys_store_rd dt on dt.store_id = a.dst_store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
where
    a.rk = 1
    and dt.store_id in ('MY10100400','MY13010100','MY12020100','MY11070100','MY10060100','MY10080200','MY11050400','MY11090100','MY13010101','MY10040300','MY10070309','MY10030300','MY11050300','MY10010100','MY10120500','MY10100600','MY12030400','MY07030100','MY10080201','MY12040101','MY04070401','MY06010101','MY04020200','MY06011200','MY06010103','MY04010200','MY04060400','MY04080400','MY04040101','MY04060500','MY04040605','MY04040100','MY06010205','MY04070600','MY06010700','MY06010704','MY04080100','MY04060200','MY04070205','MY06011100','MY04010300','MY14040310','MY15050315','MY15010100','MY14070400','MY16010100','MY15110100','MY15170100','MY15210100','MY15020100','MY14060400','MY14020200','MY14100300','MY15050301','MY14040200','MY01070200','MY02010101','MY01030100','MY01010200','MY02010100','MY03060100','MY01020504','MY03030200','MY02030300','MY03060617','MY09090100','MY09020100','MY07110100','MY07100300','MY09080200','MY08070200','MY07010100','MY09040300','MY07070101','MY08010300','MY04040600','MY04050200');
;-- -. . -..- - / . -. - .-. -.--
select
    a.dst_store_id 网点ID
    ,dt.store_name 网点
    ,dt.piece_name 片区
    ,dt.region_name 大区
    ,a.third_sorting_code 三段码
    ,a.pno
    ,a.should_delevry_type
    ,a.staff_info_id
    ,convert_tz(a.routed_at, '+00:00', '+08:00') 分拣时间
#     ,row_number() over (partition by a.dst_store_id, a.third_sorting_code order by a.routed_at) 正向排序
#     ,row_number() over (partition by a.dst_store_id, a.third_sorting_code order by a.routed_at desc ) 逆向排序
from
    (
        select
            a.*
            ,row_number() over (partition by a.pno order by a.routed_at) rk
        from
            (
                select
                    ds.dst_store_id
                    ,dp.third_sorting_code
                    ,ds.pno
                    ,ds.should_delevry_type
                    ,pr.staff_info_id
                    ,pr.routed_at
                    ,rank() over (partition by ds.pno order by dp.created_at desc ) rn
                from dwm.dwd_my_dc_should_be_delivery_d ds
                left join dwm.drds_my_parcel_sorting_code_info  dp on ds.pno = dp.pno and ds.dst_store_id = dp.dst_store_id
                join my_staging.parcel_route pr on pr.pno = dp.pno and pr.route_action = 'SORTING_SCAN' and pr.routed_at >= '2023-08-25 16:00:00' and pr.routed_at < '2023-08-26 16:00:00'
                where
                    ds.p_date = '2023-08-27'
            ) a
        where
            a.rn = 1
    ) a
left join dwm.dim_my_sys_store_rd dt on dt.store_id = a.dst_store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
where
    a.rk = 1
    and dt.store_id in ('MY10100400','MY13010100','MY12020100','MY11070100','MY10060100','MY10080200','MY11050400','MY11090100','MY13010101','MY10040300','MY10070309','MY10030300','MY11050300','MY10010100','MY10120500','MY10100600','MY12030400','MY07030100','MY10080201','MY12040101','MY04070401','MY06010101','MY04020200','MY06011200','MY06010103','MY04010200','MY04060400','MY04080400','MY04040101','MY04060500','MY04040605','MY04040100','MY06010205','MY04070600','MY06010700','MY06010704','MY04080100','MY04060200','MY04070205','MY06011100','MY04010300','MY14040310','MY15050315','MY15010100','MY14070400','MY16010100','MY15110100','MY15170100','MY15210100','MY15020100','MY14060400','MY14020200','MY14100300','MY15050301','MY14040200','MY01070200','MY02010101','MY01030100','MY01010200','MY02010100','MY03060100','MY01020504','MY03030200','MY02030300','MY03060617','MY09090100','MY09020100','MY07110100','MY07100300','MY09080200','MY08070200','MY07010100','MY09040300','MY07070101','MY08010300','MY04040600','MY04050200');
;-- -. . -..- - / . -. - .-. -.--
select
    a.dst_store_id 网点ID
    ,dt.store_name 网点
    ,dt.piece_name 片区
    ,dt.region_name 大区
    ,a.third_sorting_code 三段码
    ,a.pno
    ,a.should_delevry_type
    ,a.staff_info_id
    ,convert_tz(a.routed_at, '+00:00', '+08:00') 分拣时间
#     ,row_number() over (partition by a.dst_store_id, a.third_sorting_code order by a.routed_at) 正向排序
#     ,row_number() over (partition by a.dst_store_id, a.third_sorting_code order by a.routed_at desc ) 逆向排序
from
    (
        select
            a.*
            ,row_number() over (partition by a.pno order by a.routed_at) rk
        from
            (
                select
                    ds.dst_store_id
                    ,dp.third_sorting_code
                    ,ds.pno
                    ,ds.should_delevry_type
                    ,pr.staff_info_id
                    ,pr.routed_at
                    ,rank() over (partition by ds.pno order by dp.created_at desc ) rn
                from dwm.dwd_my_dc_should_be_delivery_d ds
                left join dwm.drds_my_parcel_sorting_code_info  dp on ds.pno = dp.pno and ds.dst_store_id = dp.dst_store_id
                join my_staging.parcel_route pr on pr.pno = dp.pno and pr.route_action = 'SORTING_SCAN' and pr.routed_at >= '2023-08-25 16:00:00' and pr.routed_at < '2023-08-26 16:00:00'
                where
                    ds.p_date = '2023-08-26'
            ) a
        where
            a.rn = 1
    ) a
left join dwm.dim_my_sys_store_rd dt on dt.store_id = a.dst_store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
where
    a.rk = 1
    and dt.store_id in ('MY10100400','MY13010100','MY12020100','MY11070100','MY10060100','MY10080200','MY11050400','MY11090100','MY13010101','MY10040300','MY10070309','MY10030300','MY11050300','MY10010100','MY10120500','MY10100600','MY12030400','MY07030100','MY10080201','MY12040101','MY04070401','MY06010101','MY04020200','MY06011200','MY06010103','MY04010200','MY04060400','MY04080400','MY04040101','MY04060500','MY04040605','MY04040100','MY06010205','MY04070600','MY06010700','MY06010704','MY04080100','MY04060200','MY04070205','MY06011100','MY04010300','MY14040310','MY15050315','MY15010100','MY14070400','MY16010100','MY15110100','MY15170100','MY15210100','MY15020100','MY14060400','MY14020200','MY14100300','MY15050301','MY14040200','MY01070200','MY02010101','MY01030100','MY01010200','MY02010100','MY03060100','MY01020504','MY03030200','MY02030300','MY03060617','MY09090100','MY09020100','MY07110100','MY07100300','MY09080200','MY08070200','MY07010100','MY09040300','MY07070101','MY08010300','MY04040600','MY04050200');
;-- -. . -..- - / . -. - .-. -.--
select
    a.dst_store_id 网点ID
    ,dt.store_name 网点
    ,dt.piece_name 片区
    ,dt.region_name 大区
    ,a.third_sorting_code 三段码
    ,a.pno
    ,a.should_delevry_type
    ,a.staff_info_id
    ,convert_tz(a.routed_at, '+00:00', '+08:00') 分拣时间
#     ,row_number() over (partition by a.dst_store_id, a.third_sorting_code order by a.routed_at) 正向排序
#     ,row_number() over (partition by a.dst_store_id, a.third_sorting_code order by a.routed_at desc ) 逆向排序
from
    (
        select
            a.*
            ,row_number() over (partition by a.pno order by a.routed_at) rk
        from
            (
                select
                    ds.dst_store_id
                    ,dp.third_sorting_code
                    ,ds.pno
                    ,ds.should_delevry_type
                    ,pr.staff_info_id
                    ,pr.routed_at
                    ,rank() over (partition by ds.pno order by dp.created_at desc ) rn
                from dwm.dwd_my_dc_should_be_delivery_d ds
                left join dwm.drds_my_parcel_sorting_code_info  dp on ds.pno = dp.pno and ds.dst_store_id = dp.dst_store_id
                join my_staging.parcel_route pr on pr.pno = dp.pno and pr.route_action = 'SORTING_SCAN' and pr.routed_at >= '2023-08-26 16:00:00' and pr.routed_at < '2023-08-27 16:00:00'
                where
                    ds.p_date = '2023-08-27'
            ) a
        where
            a.rn = 1
    ) a
left join dwm.dim_my_sys_store_rd dt on dt.store_id = a.dst_store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
where
    a.rk = 1
    and dt.store_id in ('MY10100400','MY13010100','MY12020100','MY11070100','MY10060100','MY10080200','MY11050400','MY11090100','MY13010101','MY10040300','MY10070309','MY10030300','MY11050300','MY10010100','MY10120500','MY10100600','MY12030400','MY07030100','MY10080201','MY12040101','MY04070401','MY06010101','MY04020200','MY06011200','MY06010103','MY04010200','MY04060400','MY04080400','MY04040101','MY04060500','MY04040605','MY04040100','MY06010205','MY04070600','MY06010700','MY06010704','MY04080100','MY04060200','MY04070205','MY06011100','MY04010300','MY14040310','MY15050315','MY15010100','MY14070400','MY16010100','MY15110100','MY15170100','MY15210100','MY15020100','MY14060400','MY14020200','MY14100300','MY15050301','MY14040200','MY01070200','MY02010101','MY01030100','MY01010200','MY02010100','MY03060100','MY01020504','MY03030200','MY02030300','MY03060617','MY09090100','MY09020100','MY07110100','MY07100300','MY09080200','MY08070200','MY07010100','MY09040300','MY07070101','MY08010300','MY04040600','MY04050200');
;-- -. . -..- - / . -. - .-. -.--
select
    fn.region_name as 大区
	,fn.piece_name as 片区
	,fn.store_name as 网点
    ,fn.staff_info_id as 员工ID
	,count(distinct fn.pno) as '今日交接量(最后一次交接人为准)'
    ,count(distinct if(fn.pi_state = 5, fn.pno, null)) 今日交接妥投量
	,count(distinct if(fn.handover_type='17点前交接' ,fn.pno, null)) as 17点前交接量
    ,count(distinct if(fn.handover_type='17点前交接' and fn.pi_state = 5,fn.pno,null)) 17点前交接包裹妥投量
    ,count(distinct if(fn.handover_type='17点前交接' and fn.pi_state = 7,fn.pno,null)) 17点前交接包裹退件量
    ,count(distinct if(fn.handover_type='17点前交接' and fn.pi_state = 8,fn.pno,null)) 17点前交接包裹异常关闭量

    ,count(distinct if(fn.handover_type='17点前交接' and fn.pi_state not in (5,7,8,9),fn.pno,null)) 17点前交接包裹未终态量

	,count(distinct case when fn.handover_type='17点前交接' and fn.pi_state not in (5,7,8,9) and fn.before_17_calltimes is null then fn.pno else null end) as 17点前交接包裹未妥投且未拨打电话量
	,count(distinct case when fn.handover_type='17点前交接'  and fn.pi_state not in (5,7,8,9) and fn.before_17_calltimes = 1 then fn.pno else null end) as 17点前交接包裹未妥投且拨打电话1次量
	,count(distinct case when fn.handover_type='17点前交接'  and fn.pi_state not in (5,7,8,9) and fn.before_17_calltimes = 2 then fn.pno else null end) as 17点前交接包裹未妥投且拨打电话2次量
	,count(distinct case when fn.handover_type='17点前交接'  and fn.pi_state not in (5,7,8,9) and fn.before_17_calltimes = 3 then fn.pno else null end) as 17点前交接包裹未妥投且拨打电话3次量
	,count(distinct case when fn.handover_type='17点前交接'  and fn.pi_state not in (5,7,8,9) and fn.before_17_calltimes > 3 then fn.pno else null end) as 17点前交接包裹未妥投且拨打电话3次以上量
from
    (
        select
            pr.pno
            ,pr.store_id
            ,pr.store_name
            ,pr.piece_name
            ,pr.region_name
            ,pr.routed_date
            ,pr.pi_state
            ,pr.staff_info_id
            ,pr.handover_type
            ,pr.finished_at
            ,pr2.before_17_calltimes
        from
            ( # 所有交接包裹
                select
                    pr.*
                    ,if(hour(pr.routed_at) < 17, '17点前交接', '17点后交接') handover_type
                from
                    (
                        select
                            pr.pno
                            ,pr.staff_info_id
                            ,pr.store_id
                            ,dp.store_name
                            ,dp.piece_name
                            ,dp.region_name
                            ,pi.state pi_state
                            ,convert_tz(pr.routed_at,'+00:00','+08:00') as routed_at
                            ,convert_tz(pi.finished_at,'+00:00','+08:00') as finished_at
                            ,date(convert_tz(pr.routed_at,'+00:00','+08:00'))  as routed_date
                            ,row_number() over(partition by pr.pno,date(convert_tz(pr.routed_at,'+00:00','+08:00')) order by convert_tz(pr.routed_at,'+00:00','+08:00') desc) as rnk
                        from my_staging.parcel_route pr
                        left join dwm.dim_my_sys_store_rd dp on dp.store_id = pr.store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
                        left join my_staging.parcel_info pi on pr.pno = pi.pno
                        where
                            pr.routed_at >= date_sub(curdate(), interval 8 hour)
                            and pr.routed_at < date_add(curdate(), interval 16 hour)
                            and pr.route_action in ('DELIVERY_TICKET_CREATION_SCAN')
                            and dp.store_category = 1 -- 限制SP
                    ) pr
                where
                    pr.rnk=1
            ) pr
        left join
            (
                select
                    pr.pno
                    ,count(pr.call_datetime) as before_17_calltimes
                from
                    (
                            select
                                pr.pno
                                ,pr.staff_info_id
                                ,convert_tz(pr.routed_at,'+00:00','+08:00')  as call_datetime
                         from my_staging.parcel_route pr
#                          left join my_staging.parcel_info pi on pr.pno=pi.pno
                         where
                            pr.routed_at >= date_sub(curdate(), interval 8 hour)
                            and pr.routed_at < date_add(curdate(), interval 9 hour)
                            and pr.route_action in ('PHONE')
                    )pr
                group by 1
            ) pr2 on pr.pno = pr2.pno
    ) fn
group by 1,2,3,4
order by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
select
    fn.region_name as 大区
	,fn.piece_name as 片区
	,fn.store_name as 网点
    ,fn.staff_info_id as 员工ID

	,count(distinct if(fn.handover_type='17点前交接' ,fn.pno, null)) as 17点前交接量
    ,count(distinct if(fn.handover_type='17点前交接' and fn.pi_state = 5,fn.pno,null)) 17点前交接包裹妥投量
    ,count(distinct if(fn.handover_type='17点前交接' and fn.pi_state = 7,fn.pno,null)) 17点前交接包裹退件量
    ,count(distinct if(fn.handover_type='17点前交接' and fn.pi_state = 8,fn.pno,null)) 17点前交接包裹异常关闭量

    ,count(distinct if(fn.handover_type='17点前交接' and fn.pi_state not in (5,7,8,9),fn.pno,null)) 17点前交接包裹未终态量

	,count(distinct case when fn.handover_type='17点前交接' and fn.pi_state not in (5,7,8,9) and fn.before_17_calltimes is null then fn.pno else null end) as 17点前交接包裹未妥投且未拨打电话量
	,count(distinct case when fn.handover_type='17点前交接'  and fn.pi_state not in (5,7,8,9) and fn.before_17_calltimes = 1 then fn.pno else null end) as 17点前交接包裹未妥投且拨打电话1次量
	,count(distinct case when fn.handover_type='17点前交接'  and fn.pi_state not in (5,7,8,9) and fn.before_17_calltimes = 2 then fn.pno else null end) as 17点前交接包裹未妥投且拨打电话2次量
	,count(distinct case when fn.handover_type='17点前交接'  and fn.pi_state not in (5,7,8,9) and fn.before_17_calltimes = 3 then fn.pno else null end) as 17点前交接包裹未妥投且拨打电话3次量
	,count(distinct case when fn.handover_type='17点前交接'  and fn.pi_state not in (5,7,8,9) and fn.before_17_calltimes > 3 then fn.pno else null end) as 17点前交接包裹未妥投且拨打电话3次以上量
from
    (
        select
            pr.pno
            ,pr.store_id
            ,pr.store_name
            ,pr.piece_name
            ,pr.region_name
            ,pr.routed_date
            ,pr.pi_state
            ,pr.staff_info_id
            ,pr.handover_type
            ,pr.finished_at
            ,pr2.before_17_calltimes
        from
            ( # 所有交接包裹
                select
                    pr.*
                    ,if(hour(pr.routed_at) < 17, '17点前交接', '17点后交接') handover_type
                from
                    (
                        select
                            pr.pno
                            ,pr.staff_info_id
                            ,pr.store_id
                            ,dp.store_name
                            ,dp.piece_name
                            ,dp.region_name
                            ,pi.state pi_state
                            ,convert_tz(pr.routed_at,'+00:00','+08:00') as routed_at
                            ,convert_tz(pi.finished_at,'+00:00','+08:00') as finished_at
                            ,date(convert_tz(pr.routed_at,'+00:00','+08:00'))  as routed_date
                            ,row_number() over(partition by pr.pno,date(convert_tz(pr.routed_at,'+00:00','+08:00')) order by convert_tz(pr.routed_at,'+00:00','+08:00') desc) as rnk
                        from my_staging.parcel_route pr
                        left join dwm.dim_my_sys_store_rd dp on dp.store_id = pr.store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
                        left join my_staging.parcel_info pi on pr.pno = pi.pno
                        where
                            pr.routed_at >= date_sub(curdate(), interval 8 hour)
                            and pr.routed_at < date_add(curdate(), interval 16 hour)
                            and pr.route_action in ('DELIVERY_TICKET_CREATION_SCAN')
                            and dp.store_category = 1 -- 限制SP
                    ) pr
                where
                    pr.rnk=1
            ) pr
        left join
            (
                select
                    pr.pno
                    ,count(pr.call_datetime) as before_17_calltimes
                from
                    (
                            select
                                pr.pno
                                ,pr.staff_info_id
                                ,convert_tz(pr.routed_at,'+00:00','+08:00')  as call_datetime
                         from my_staging.parcel_route pr
#                          left join my_staging.parcel_info pi on pr.pno=pi.pno
                         where
                            pr.routed_at >= date_sub(curdate(), interval 8 hour)
                            and pr.routed_at < date_add(curdate(), interval 9 hour)
                            and pr.route_action in ('PHONE')
                    )pr
                group by 1
            ) pr2 on pr.pno = pr2.pno
    ) fn
group by 1,2,3,4
order by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
with handover as
    (
        select
            fn.pno
            ,fn.pno_type
            ,fn.store_id
            ,fn.store_name
            ,fn.piece_name
            ,fn.region_name
            ,fn.staff_info_id
            ,fn.staff_name
            ,fn.finished_at
            ,fn.pi_state
			,fn.before_17_calltimes
        from
            (
	            select
		            pr.pno
		            ,pr.store_id
		            ,dp.store_name
		            ,dp.piece_name
		            ,dp.region_name
		            ,pr.staff_info_id
		            ,pi.state pi_state
	                ,convert_tz(pi.updated_at,'+00:00','+08:00') as pi_updated_at
		            ,if(pi.returned=1,'退件','正向件') as pno_type
		            ,convert_tz(pi.finished_at,'+00:00','+08:00') as finished_at
	                ,pr.staff_name
		            ,pr2.before_17_calltimes
		        from
		            ( # 所有17点前交接包裹找到最后一次交接的人
		                select
		                    pr.*
		                from
		                    (
		                        select
		                            pr.pno
		                            ,pr.staff_info_id
		                            ,hsi.name as staff_name
		                            ,pr.store_id
		                            ,row_number() over(partition by pr.pno order by convert_tz(pr.routed_at,'+00:00','+08:00') desc) as rnk
		                        from my_staging.parcel_route pr
		                        left join my_bi.hr_staff_info hsi on pr.staff_info_id=hsi.staff_info_id
		                        left join my_bi.hr_job_title hjt on hjt.id = hsi.job_title
		                        where
		                            pr.routed_at >= date_sub(curdate(), interval 8 hour)
		                            and pr.routed_at < date_add(curdate(), interval 9 hour)
		                            and pr.route_action in ('DELIVERY_TICKET_CREATION_SCAN')
		                            and hsi.job_title in(13,110,1000)
		                            and hsi.formal=1
		                    ) pr
		                    where  pr.rnk = 1
		            ) pr
		            join dwm.dim_my_sys_store_rd dp on dp.store_id = pr.store_id and dp.stat_date = date_sub(curdate(), interval 1 day) and dp.store_category=1
		            left join my_staging.parcel_info pi on pr.pno = pi.pno
		        left join # 17点前拨打电话次数
		            (
		                select
		                    pr.pno
		                    ,count(pr.call_datetime) as before_17_calltimes
		                from
		                    (
		                        select
		                                pr.pno
		                                ,pr.staff_info_id
		                                ,convert_tz(pr.routed_at,'+00:00','+08:00')  as call_datetime
		                         from my_staging.parcel_route pr
		                         where
		                            pr.routed_at >= date_sub(curdate(), interval 8 hour)
		                            and pr.routed_at < date_add(curdate(), interval 9 hour)
		                            and pr.route_action in ('PHONE')
		                    )pr
		                group by 1
		            )pr2 on pr.pno = pr2.pno
	        )fn
    )

select
    f1.网点
    ,f1.大区
    ,f1.片区
    ,f1.负责人
    ,f1.员工ID
    ,f1.快递员姓名
	,f1.交接量_非退件
	,f1.交接包裹妥投量_非退件妥投
    ,f1.交接包裹妥投量_退件妥投
    ,f1.交接包裹未拨打电话数
    ,case when f5.late_days>=3 and f5.late_times>=300 then '最近一周迟到三次且迟到时间5小时'
         when f5.absent_days>=2  then '最近一周缺勤2次' else null end as 员工出勤信息
    ,f6.finished_at as 18点前快递员结束派件时间
    ,concat(round(f1.交接包裹妥投量_非退件妥投/f1.交接量_非退件*100,2),'%') as 妥投率
    ,f1.交接包裹未拨打电话占比
    ,f5.absent_days as 缺勤天数
    ,f5.late_days as 迟到天数
    ,f5.late_times as 迟到时长_分钟
from
	(# 快递员交接包裹后拨打电话情况
	    select
		    fn.region_name as 大区
		    ,case
			    when fn.region_name in ('Area3', 'Area6') then '彭万松'
			    when fn.region_name in ('Area4', 'Area9') then '韩钥'
			    when fn.region_name in ('Area7','Area10', 'Area11','FHome','Area14') then '张可新'
			    when fn.region_name in ( 'Area8') then '黄勇'
			    when fn.region_name in ('Area1', 'Area2','Area5', 'Area12','Area13') then '李俊'
				end 负责人
		    ,fn.piece_name as 片区
		    ,fn.store_name as 网点
			,fn.store_id
		    ,fn.staff_info_id as 员工ID
	        ,fn.staff_name as 快递员姓名
	        ,count(distinct case when  fn.before_17_calltimes is null then fn.pno else null end) as 交接包裹未拨打电话数
	        ,concat(round(count(distinct case when  fn.before_17_calltimes is null then fn.pno else null end)/count(distinct fn.pno)*100,2),'%') as 交接包裹未拨打电话占比
	        ,count(distinct if(fn.pno_type='正向件', fn.pno ,null)) as 交接量_非退件
		    ,count(distinct if(fn.pi_state = 5 and fn.pno_type='正向件' ,fn.pno ,null)) 交接包裹妥投量_非退件妥投
		    ,count(distinct if(fn.pi_state = 5 and fn.pno_type='退件' ,fn.pno ,null)) 交接包裹妥投量_退件妥投
	    from  handover fn
	    group by 1,2,3,4,5,6,7
	)f1
left join
	( -- 最近一周出勤
	    select
	        ad.staff_info_id
	        ,sum(case
		        when ad.leave_type is not null and ad.leave_time_type=1 then 0.5
		        when ad.leave_type is not null and ad.leave_time_type=2 then 0.5
		        when ad.leave_type is not null and ad.leave_time_type=3 then 1
		        else 0  end) as leave_num
	        ,count(distinct if(ad.attendance_time = 0, ad.stat_date, null)) absent_days
	        ,count(distinct if(ad.attendance_started_at > date_add(concat(ad.stat_date, ' ', ad.shift_start), interval 1 minute), ad.stat_date, null)) late_days
	        ,sum(if(ad.attendance_started_at > date_add(concat(ad.stat_date, ' ', ad.shift_start), interval 1 minute), timestampdiff(minute , concat(ad.stat_date, ' ', ad.shift_start), ad.attendance_started_at), 0)) late_times
	    from my_bi.attendance_data_v2 ad
	    where ad.attendance_time + ad.BT+ ad.BT_Y + ad.AB >0
	        and ad.stat_date>date_sub(current_date,interval 8 day)
	        and ad.stat_date<=date_sub(current_date,interval 1 day)
	    group by 1
	) f5 on f5.staff_info_id = f1.员工ID
left join
	( -- 18点前最后一个妥投包裹时间
        select
             ha.ticket_delivery_staff_info_id
	        ,ha.finished_at
        from
        (
            select
                pi.ticket_delivery_staff_info_id
                ,convert_tz(pi.finished_at,'+00:00','+08:00') as finished_at
                ,row_number() over (partition by pi.ticket_delivery_staff_info_id order by pi.finished_at desc) as rk
	        from my_staging.parcel_info pi
	        where pi.state=5
	        and pi.finished_at>= date_sub(curdate(), interval 8 hour)
		    and pi.finished_at< date_add(curdate(), interval 10 hour)
        )ha
        where ha.rk=1
	) f6 on f6.ticket_delivery_staff_info_id = f1.员工ID;
;-- -. . -..- - / . -. - .-. -.--
with handover as
    (
        select
            fn.pno
            ,fn.pno_type
            ,fn.store_id
            ,fn.store_name
            ,fn.piece_name
            ,fn.region_name
            ,fn.staff_info_id
            ,fn.staff_name
            ,fn.finished_at
            ,fn.pi_state
			,fn.before_17_calltimes
        from
            (
	            select
		            pr.pno
		            ,pr.store_id
		            ,dp.store_name
		            ,dp.piece_name
		            ,dp.region_name
		            ,pr.staff_info_id
		            ,pi.state pi_state
	                ,convert_tz(pi.updated_at,'+00:00','+08:00') as pi_updated_at
		            ,if(pi.returned=1,'退件','正向件') as pno_type
		            ,convert_tz(pi.finished_at,'+00:00','+08:00') as finished_at
	                ,pr.staff_name
		            ,pr2.before_17_calltimes
		        from
		            ( # 所有17点前交接包裹找到最后一次交接的人
		                select
		                    pr.*
		                from
		                    (
		                        select
		                            pr.pno
		                            ,pr.staff_info_id
		                            ,hsi.name as staff_name
		                            ,pr.store_id
		                            ,row_number() over(partition by pr.pno order by convert_tz(pr.routed_at,'+00:00','+08:00') desc) as rnk
		                        from my_staging.parcel_route pr
		                        left join my_bi.hr_staff_info hsi on pr.staff_info_id=hsi.staff_info_id
		                        left join my_bi.hr_job_title hjt on hjt.id = hsi.job_title
		                        where
		                            pr.routed_at >= date_sub(curdate(), interval 8 hour)
		                            and pr.routed_at < date_add(curdate(), interval 9 hour)
		                            and pr.route_action in ('DELIVERY_TICKET_CREATION_SCAN')
		                            and hsi.job_title in(13,110,1199)
		                            and hsi.formal=1
		                    ) pr
		                    where  pr.rnk=1
		            ) pr
		            join dwm.dim_my_sys_store_rd dp on dp.store_id = pr.store_id and dp.stat_date = date_sub(curdate(), interval 1 day) and dp.store_category=1
		            left join my_staging.parcel_info pi on pr.pno = pi.pno
		        left join # 17点前拨打电话次数
		            (
		                select
		                    pr.pno
		                    ,count(pr.call_datetime) as before_17_calltimes
		                from
		                    (
		                        select
		                                pr.pno
		                                ,pr.staff_info_id
		                                ,convert_tz(pr.routed_at,'+00:00','+08:00')  as call_datetime
		                         from my_staging.parcel_route pr
		                         where
		                            pr.routed_at >= date_sub(curdate(), interval 8 hour)
		                            and pr.routed_at < date_add(curdate(), interval 9 hour)
		                            and pr.route_action in ('PHONE')
		                    )pr
		                group by 1
		            )pr2 on pr.pno = pr2.pno
	        )fn
    )




select
        fn.网点
	    ,fn.大区
	    ,fn.片区
	    ,fn.负责人
	    ,fn.员工ID
	    ,fn.快递员姓名
		,fn.交接量_非退件
		,fn.交接包裹妥投量_非退件妥投
	    ,fn.交接包裹妥投量_退件妥投
	    ,fn.交接包裹未拨打电话数
		,fn.员工出勤信息
		,fn.18点前快递员结束派件时间
		,fn.妥投率
		,case when fn.未按要求联系客户 is not null and fn.rk<=2 then '是' else null end as 违反A联系客户
		,fn.是否出勤不达标 as 违反B出勤
		,fn.是否低人效 as 违反C人效
    from
    (
        select
		    fk.*
			,row_number() over (partition by fk.网点,fk.未按要求联系客户 order by fk.交接包裹未拨打电话占比 desc) as rk
		    from
		    (
				select
				    f1.网点
				    ,f1.大区
				    ,f1.片区
				    ,f1.负责人
				    ,f1.员工ID
				    ,f1.快递员姓名
					,f1.交接量_非退件
					,f1.交接包裹妥投量_非退件妥投
				    ,f1.交接包裹妥投量_退件妥投
				    ,f1.交接包裹未拨打电话数
				    ,case when f5.late_days>=3 and f5.late_times>=300 then '最近一周迟到三次且迟到时间5小时'
				         when f5.absent_days>=2  then '最近一周缺勤2次' else null end as 员工出勤信息
				    ,f6.finished_at as 18点前快递员结束派件时间
				    ,concat(round(f1.交接包裹妥投量_非退件妥投/f1.交接量_非退件*100,2),'%') as 妥投率
				    ,f1.交接包裹未拨打电话占比


				    ,f5.absent_days as 缺勤天数
				    ,f5.late_days as 迟到天数
				    ,f5.late_times as 迟到时长_分钟
					,if(f1.交接包裹未拨打电话数>10 and f1.交接包裹未拨打电话占比>0.2,'未按要求联系客户',null) as 未按要求联系客户
					,case when f5.late_days>=3 and f5.late_times>=300 then '是' when f5.absent_days>=2  then '是' else null end as 是否出勤不达标
					,if(f1.交接包裹妥投量_非退件妥投/f1.交接量_非退件<0.7 and f1.交接包裹妥投量_非退件妥投<50 and hour(f6.finished_at)<15,'是',null) as 是否低人效

				from
					(# 快递员交接包裹后拨打电话情况
					    select
						    fn.region_name as 大区
						    ,case
							    when fn.region_name in ('Area3', 'Area6') then '彭万松'
							    when fn.region_name in ('Area4', 'Area9') then '韩钥'
							    when fn.region_name in ('Area7','Area10', 'Area11','FHome','Area14') then '张可新'
							    when fn.region_name in ( 'Area8') then '黄勇'
							    when fn.region_name in ('Area1', 'Area2','Area5', 'Area12','Area13') then '李俊'
								end 负责人
						    ,fn.piece_name as 片区
						    ,fn.store_name as 网点
							,fn.store_id
						    ,fn.staff_info_id as 员工ID
					        ,fn.staff_name as 快递员姓名
					        ,count(distinct case when  fn.before_17_calltimes is null then fn.pno else null end) as 交接包裹未拨打电话数
					        ,count(distinct case when  fn.before_17_calltimes is null then fn.pno else null end)/count(distinct fn.pno) as 交接包裹未拨打电话占比
					        ,count(distinct if(fn.pno_type='正向件', fn.pno ,null)) as 交接量_非退件
						    ,count(distinct if(fn.pi_state = 5 and fn.pno_type='正向件' ,fn.pno ,null)) 交接包裹妥投量_非退件妥投
						    ,count(distinct if(fn.pi_state = 5 and fn.pno_type='退件' ,fn.pno ,null)) 交接包裹妥投量_退件妥投
					    from  handover fn
					    group by 1,2,3,4,5,6,7
					)f1
				left join
					( -- 最近一周出勤
					    select
					        ad.staff_info_id
					        ,sum(case
						        when ad.leave_type is not null and ad.leave_time_type=1 then 0.5
						        when ad.leave_type is not null and ad.leave_time_type=2 then 0.5
						        when ad.leave_type is not null and ad.leave_time_type=3 then 1
						        else 0  end) as leave_num
					        ,count(distinct if(ad.attendance_time = 0, ad.stat_date, null)) absent_days
					        ,count(distinct if(ad.attendance_started_at > date_add(concat(ad.stat_date, ' ', ad.shift_start), interval 1 minute), ad.stat_date, null)) late_days
					        ,sum(if(ad.attendance_started_at > date_add(concat(ad.stat_date, ' ', ad.shift_start), interval 1 minute), timestampdiff(minute , concat(ad.stat_date, ' ', ad.shift_start), ad.attendance_started_at), 0)) late_times
					    from my_bi.attendance_data_v2 ad
					    where ad.attendance_time + ad.BT+ ad.BT_Y + ad.AB >0
					        and ad.stat_date>date_sub(current_date,interval 8 day)
					        and ad.stat_date<=date_sub(current_date,interval 1 day)
					    group by 1
					) f5 on f5.staff_info_id = f1.员工ID
				left join
					( -- 18点前最后一个妥投包裹时间
				        select
				             ha.ticket_delivery_staff_info_id
					        ,ha.finished_at
				        from
				        (
				            select
				                pi.ticket_delivery_staff_info_id
				                ,convert_tz(pi.finished_at,'+00:00','+08:00') as finished_at
				                ,row_number() over (partition by pi.ticket_delivery_staff_info_id order by pi.finished_at desc) as rk
					        from my_staging.parcel_info pi
					        where pi.state=5
					        and pi.finished_at>= date_sub(curdate(), interval 8 hour)
						    and pi.finished_at< date_add(curdate(), interval 10 hour)
				        )ha
				        where ha.rk=1
					) f6 on f6.ticket_delivery_staff_info_id = f1.员工ID
		    )fk
    )fn;
;-- -. . -..- - / . -. - .-. -.--
with handover as
    (
        select
            fn.pno
            ,fn.pno_type
            ,fn.store_id
            ,fn.store_name
            ,fn.piece_name
            ,fn.region_name
            ,fn.staff_info_id
            ,fn.staff_name
            ,fn.finished_at
            ,fn.pi_state
			,fn.before_17_calltimes
        from
            (
	            select
		            pr.pno
		            ,pr.store_id
		            ,dp.store_name
		            ,dp.piece_name
		            ,dp.region_name
		            ,pr.staff_info_id
		            ,pi.state pi_state
	                ,convert_tz(pi.updated_at,'+00:00','+08:00') as pi_updated_at
		            ,if(pi.returned=1,'退件','正向件') as pno_type
		            ,convert_tz(pi.finished_at,'+00:00','+08:00') as finished_at
	                ,pr.staff_name
		            ,pr2.before_17_calltimes
		        from
		            ( # 所有17点前交接包裹找到最后一次交接的人
		                select
		                    pr.*
		                from
		                    (
		                        select
		                            pr.pno
		                            ,pr.staff_info_id
		                            ,hsi.name as staff_name
		                            ,pr.store_id
		                            ,row_number() over(partition by pr.pno order by convert_tz(pr.routed_at,'+00:00','+08:00') desc) as rnk
		                        from my_staging.parcel_route pr
		                        left join my_bi.hr_staff_info hsi on pr.staff_info_id=hsi.staff_info_id
		                        left join my_bi.hr_job_title hjt on hjt.id = hsi.job_title
		                        where
		                            pr.routed_at >= date_sub(curdate(), interval 8 hour)
		                            and pr.routed_at < date_add(curdate(), interval 9 hour)
		                            and pr.route_action in ('DELIVERY_TICKET_CREATION_SCAN')
		                            and hsi.job_title in(13,110,1199)
		                            and hsi.formal=1
		                    ) pr
		                    where  pr.rnk=1
		            ) pr
		            join dwm.dim_my_sys_store_rd dp on dp.store_id = pr.store_id and dp.stat_date = date_sub(curdate(), interval 1 day) and dp.store_category=1
		            left join my_staging.parcel_info pi on pr.pno = pi.pno
		        left join # 17点前拨打电话次数
		            (
		                select
		                    pr.pno
		                    ,count(pr.call_datetime) as before_17_calltimes
		                from
		                    (
		                        select
		                                pr.pno
		                                ,pr.staff_info_id
		                                ,convert_tz(pr.routed_at,'+00:00','+08:00')  as call_datetime
		                         from my_staging.parcel_route pr
		                         where
		                            pr.routed_at >= date_sub(curdate(), interval 8 hour)
		                            and pr.routed_at < date_add(curdate(), interval 9 hour)
		                            and pr.route_action in ('PHONE')
		                    )pr
		                group by 1
		            )pr2 on pr.pno = pr2.pno
	        )fn
    )




select
        fn.网点
	    ,fn.大区
	    ,fn.片区
# 	    ,fn.负责人
	    ,fn.员工ID
	    ,fn.快递员姓名
		,fn.交接量_非退件
		,fn.交接包裹妥投量_非退件妥投
	    ,fn.交接包裹妥投量_退件妥投
	    ,fn.交接包裹未拨打电话数
		,fn.员工出勤信息
		,fn.18点前快递员结束派件时间
		,fn.妥投率
		,case when fn.未按要求联系客户 is not null and fn.rk<=2 then '是' else null end as 违反A联系客户
		,fn.是否出勤不达标 as 违反B出勤
		,fn.是否低人效 as 违反C人效
    from
    (
        select
		    fk.*
			,row_number() over (partition by fk.网点,fk.未按要求联系客户 order by fk.交接包裹未拨打电话占比 desc) as rk
		    from
		    (
				select
				    f1.网点
				    ,f1.大区
				    ,f1.片区
				    ,f1.负责人
				    ,f1.员工ID
				    ,f1.快递员姓名
					,f1.交接量_非退件
					,f1.交接包裹妥投量_非退件妥投
				    ,f1.交接包裹妥投量_退件妥投
				    ,f1.交接包裹未拨打电话数
				    ,case when f5.late_days>=3 and f5.late_times>=300 then '最近一周迟到三次且迟到时间5小时'
				         when f5.absent_days>=2  then '最近一周缺勤2次' else null end as 员工出勤信息
				    ,f6.finished_at as 18点前快递员结束派件时间
				    ,concat(round(f1.交接包裹妥投量_非退件妥投/f1.交接量_非退件*100,2),'%') as 妥投率
				    ,f1.交接包裹未拨打电话占比


				    ,f5.absent_days as 缺勤天数
				    ,f5.late_days as 迟到天数
				    ,f5.late_times as 迟到时长_分钟
					,if(f1.交接包裹未拨打电话数>10 and f1.交接包裹未拨打电话占比>0.2,'未按要求联系客户',null) as 未按要求联系客户
					,case when f5.late_days>=3 and f5.late_times>=300 then '是' when f5.absent_days>=2  then '是' else null end as 是否出勤不达标
					,if(f1.交接包裹妥投量_非退件妥投/f1.交接量_非退件<0.7 and f1.交接包裹妥投量_非退件妥投<50 and hour(f6.finished_at)<15,'是',null) as 是否低人效

				from
					(# 快递员交接包裹后拨打电话情况
					    select
						    fn.region_name as 大区
# 						    ,case
# 							    when fn.region_name in ('Area3', 'Area6') then '彭万松'
# 							    when fn.region_name in ('Area4', 'Area9') then '韩钥'
# 							    when fn.region_name in ('Area7','Area10', 'Area11','FHome','Area14') then '张可新'
# 							    when fn.region_name in ( 'Area8') then '黄勇'
# 							    when fn.region_name in ('Area1', 'Area2','Area5', 'Area12','Area13') then '李俊'
# 								end 负责人
						    ,fn.piece_name as 片区
						    ,fn.store_name as 网点
							,fn.store_id
						    ,fn.staff_info_id as 员工ID
					        ,fn.staff_name as 快递员姓名
					        ,count(distinct case when  fn.before_17_calltimes is null then fn.pno else null end) as 交接包裹未拨打电话数
					        ,count(distinct case when  fn.before_17_calltimes is null then fn.pno else null end)/count(distinct fn.pno) as 交接包裹未拨打电话占比
					        ,count(distinct if(fn.pno_type='正向件', fn.pno ,null)) as 交接量_非退件
						    ,count(distinct if(fn.pi_state = 5 and fn.pno_type='正向件' ,fn.pno ,null)) 交接包裹妥投量_非退件妥投
						    ,count(distinct if(fn.pi_state = 5 and fn.pno_type='退件' ,fn.pno ,null)) 交接包裹妥投量_退件妥投
					    from  handover fn
					    group by 1,2,3,4,5,6,7
					)f1
				left join
					( -- 最近一周出勤
					    select
					        ad.staff_info_id
					        ,sum(case
						        when ad.leave_type is not null and ad.leave_time_type=1 then 0.5
						        when ad.leave_type is not null and ad.leave_time_type=2 then 0.5
						        when ad.leave_type is not null and ad.leave_time_type=3 then 1
						        else 0  end) as leave_num
					        ,count(distinct if(ad.attendance_time = 0, ad.stat_date, null)) absent_days
					        ,count(distinct if(ad.attendance_started_at > date_add(concat(ad.stat_date, ' ', ad.shift_start), interval 1 minute), ad.stat_date, null)) late_days
					        ,sum(if(ad.attendance_started_at > date_add(concat(ad.stat_date, ' ', ad.shift_start), interval 1 minute), timestampdiff(minute , concat(ad.stat_date, ' ', ad.shift_start), ad.attendance_started_at), 0)) late_times
					    from my_bi.attendance_data_v2 ad
					    where ad.attendance_time + ad.BT+ ad.BT_Y + ad.AB >0
					        and ad.stat_date>date_sub(current_date,interval 8 day)
					        and ad.stat_date<=date_sub(current_date,interval 1 day)
					    group by 1
					) f5 on f5.staff_info_id = f1.员工ID
				left join
					( -- 18点前最后一个妥投包裹时间
				        select
				             ha.ticket_delivery_staff_info_id
					        ,ha.finished_at
				        from
				        (
				            select
				                pi.ticket_delivery_staff_info_id
				                ,convert_tz(pi.finished_at,'+00:00','+08:00') as finished_at
				                ,row_number() over (partition by pi.ticket_delivery_staff_info_id order by pi.finished_at desc) as rk
					        from my_staging.parcel_info pi
					        where pi.state=5
					        and pi.finished_at>= date_sub(curdate(), interval 8 hour)
						    and pi.finished_at< date_add(curdate(), interval 10 hour)
				        )ha
				        where ha.rk=1
					) f6 on f6.ticket_delivery_staff_info_id = f1.员工ID
		    )fk
    )fn;
;-- -. . -..- - / . -. - .-. -.--
with handover as
    (
        select
            fn.pno
            ,fn.pno_type
            ,fn.store_id
            ,fn.store_name
            ,fn.piece_name
            ,fn.region_name
            ,fn.staff_info_id
            ,fn.staff_name
            ,fn.finished_at
            ,fn.pi_state
			,fn.before_17_calltimes
        from
            (
	            select
		            pr.pno
		            ,pr.store_id
		            ,dp.store_name
		            ,dp.piece_name
		            ,dp.region_name
		            ,pr.staff_info_id
		            ,pi.state pi_state
	                ,convert_tz(pi.updated_at,'+00:00','+08:00') as pi_updated_at
		            ,if(pi.returned=1,'退件','正向件') as pno_type
		            ,convert_tz(pi.finished_at,'+00:00','+08:00') as finished_at
	                ,pr.staff_name
		            ,pr2.before_17_calltimes
		        from
		            ( # 所有17点前交接包裹找到最后一次交接的人
		                select
		                    pr.*
		                from
		                    (
		                        select
		                            pr.pno
		                            ,pr.staff_info_id
		                            ,hsi.name as staff_name
		                            ,pr.store_id
		                            ,row_number() over(partition by pr.pno order by convert_tz(pr.routed_at,'+00:00','+08:00') desc) as rnk
		                        from my_staging.parcel_route pr
		                        left join my_bi.hr_staff_info hsi on pr.staff_info_id=hsi.staff_info_id
		                        left join my_bi.hr_job_title hjt on hjt.id = hsi.job_title
		                        where
		                            pr.routed_at >= date_sub(curdate(), interval 8 hour)
		                            and pr.routed_at < date_add(curdate(), interval 9 hour)
		                            and pr.route_action in ('DELIVERY_TICKET_CREATION_SCAN')
		                            and hsi.job_title in(13,110,1199)
		                            and hsi.formal=1
		                    ) pr
		                    where  pr.rnk=1
		            ) pr
		            join dwm.dim_my_sys_store_rd dp on dp.store_id = pr.store_id and dp.stat_date = date_sub(curdate(), interval 1 day) and dp.store_category=1
		            left join my_staging.parcel_info pi on pr.pno = pi.pno
		        left join # 17点前拨打电话次数
		            (
		                select
		                    pr.pno
		                    ,count(pr.call_datetime) as before_17_calltimes
		                from
		                    (
		                        select
		                                pr.pno
		                                ,pr.staff_info_id
		                                ,convert_tz(pr.routed_at,'+00:00','+08:00')  as call_datetime
		                         from my_staging.parcel_route pr
		                         where
		                            pr.routed_at >= date_sub(curdate(), interval 8 hour)
		                            and pr.routed_at < date_add(curdate(), interval 9 hour)
		                            and pr.route_action in ('PHONE')
		                    )pr
		                group by 1
		            )pr2 on pr.pno = pr2.pno
	        )fn
    )




select
        fn.网点
	    ,fn.大区
	    ,fn.片区
# 	    ,fn.负责人
	    ,fn.员工ID
	    ,fn.快递员姓名
		,fn.交接量_非退件
		,fn.交接包裹妥投量_非退件妥投
	    ,fn.交接包裹妥投量_退件妥投
	    ,fn.交接包裹未拨打电话数
		,fn.员工出勤信息
		,fn.18点前快递员结束派件时间
		,fn.妥投率
		,case when fn.未按要求联系客户 is not null and fn.rk<=2 then '是' else null end as 违反A联系客户
		,fn.是否出勤不达标 as 违反B出勤
		,fn.是否低人效 as 违反C人效
    from
    (
        select
		    fk.*
			,row_number() over (partition by fk.网点,fk.未按要求联系客户 order by fk.交接包裹未拨打电话占比 desc) as rk
		    from
		    (
				select
				    f1.网点
				    ,f1.大区
				    ,f1.片区
				    ,f1.负责人
				    ,f1.员工ID
				    ,f1.快递员姓名
					,f1.交接量_非退件
					,f1.交接包裹妥投量_非退件妥投
				    ,f1.交接包裹妥投量_退件妥投
				    ,f1.交接包裹未拨打电话数
				    ,case when f5.late_days>=3 and f5.late_times>=300 then '最近一周迟到三次且迟到时间5小时'
				         when f5.absent_days>=2  then '最近一周缺勤2次' else null end as 员工出勤信息
				    ,f6.finished_at as 18点前快递员结束派件时间
				    ,concat(round(f1.交接包裹妥投量_非退件妥投/f1.交接量_非退件*100,2),'%') as 妥投率
				    ,f1.交接包裹未拨打电话占比


				    ,f5.absent_days as 缺勤天数
				    ,f5.late_days as 迟到天数
				    ,f5.late_times as 迟到时长_分钟
					,if(f1.交接包裹未拨打电话数>10 and f1.交接包裹未拨打电话占比>0.2,'未按要求联系客户',null) as 未按要求联系客户
					,case when f5.late_days>=3 and f5.late_times>=300 then '是' when f5.absent_days>=2  then '是' else null end as 是否出勤不达标
					,if(f1.交接包裹妥投量_非退件妥投/f1.交接量_非退件<0.7 and f1.交接包裹妥投量_非退件妥投<50 and hour(f6.finished_at)<15,'是',null) as 是否低人效

				from
					(# 快递员交接包裹后拨打电话情况
					    select
						    fn.region_name as 大区
# 						    ,case
# 							    when fn.region_name in ('Area3', 'Area6') then '彭万松'
# 							    when fn.region_name in ('Area4', 'Area9') then '韩钥'
# 							    when fn.region_name in ('Area7','Area10', 'Area11','FHome','Area14') then '张可新'
# 							    when fn.region_name in ( 'Area8') then '黄勇'
# 							    when fn.region_name in ('Area1', 'Area2','Area5', 'Area12','Area13') then '李俊'
# 								end 负责人
						    ,fn.piece_name as 片区
						    ,fn.store_name as 网点
							,fn.store_id
						    ,fn.staff_info_id as 员工ID
					        ,fn.staff_name as 快递员姓名
					        ,count(distinct case when  fn.before_17_calltimes is null then fn.pno else null end) as 交接包裹未拨打电话数
					        ,count(distinct case when  fn.before_17_calltimes is null then fn.pno else null end)/count(distinct fn.pno) as 交接包裹未拨打电话占比
					        ,count(distinct if(fn.pno_type='正向件', fn.pno ,null)) as 交接量_非退件
						    ,count(distinct if(fn.pi_state = 5 and fn.pno_type='正向件' ,fn.pno ,null)) 交接包裹妥投量_非退件妥投
						    ,count(distinct if(fn.pi_state = 5 and fn.pno_type='退件' ,fn.pno ,null)) 交接包裹妥投量_退件妥投
					    from  handover fn
					    group by 1,2,3,4,5,6
					)f1
				left join
					( -- 最近一周出勤
					    select
					        ad.staff_info_id
					        ,sum(case
						        when ad.leave_type is not null and ad.leave_time_type=1 then 0.5
						        when ad.leave_type is not null and ad.leave_time_type=2 then 0.5
						        when ad.leave_type is not null and ad.leave_time_type=3 then 1
						        else 0  end) as leave_num
					        ,count(distinct if(ad.attendance_time = 0, ad.stat_date, null)) absent_days
					        ,count(distinct if(ad.attendance_started_at > date_add(concat(ad.stat_date, ' ', ad.shift_start), interval 1 minute), ad.stat_date, null)) late_days
					        ,sum(if(ad.attendance_started_at > date_add(concat(ad.stat_date, ' ', ad.shift_start), interval 1 minute), timestampdiff(minute , concat(ad.stat_date, ' ', ad.shift_start), ad.attendance_started_at), 0)) late_times
					    from my_bi.attendance_data_v2 ad
					    where ad.attendance_time + ad.BT+ ad.BT_Y + ad.AB >0
					        and ad.stat_date>date_sub(current_date,interval 8 day)
					        and ad.stat_date<=date_sub(current_date,interval 1 day)
					    group by 1
					) f5 on f5.staff_info_id = f1.员工ID
				left join
					( -- 18点前最后一个妥投包裹时间
				        select
				             ha.ticket_delivery_staff_info_id
					        ,ha.finished_at
				        from
				        (
				            select
				                pi.ticket_delivery_staff_info_id
				                ,convert_tz(pi.finished_at,'+00:00','+08:00') as finished_at
				                ,row_number() over (partition by pi.ticket_delivery_staff_info_id order by pi.finished_at desc) as rk
					        from my_staging.parcel_info pi
					        where pi.state=5
					        and pi.finished_at>= date_sub(curdate(), interval 8 hour)
						    and pi.finished_at< date_add(curdate(), interval 10 hour)
				        )ha
				        where ha.rk=1
					) f6 on f6.ticket_delivery_staff_info_id = f1.员工ID
		    )fk
    )fn;
;-- -. . -..- - / . -. - .-. -.--
with handover as
    (
        select
            fn.pno
            ,fn.pno_type
            ,fn.store_id
            ,fn.store_name
            ,fn.piece_name
            ,fn.region_name
            ,fn.staff_info_id
            ,fn.staff_name
            ,fn.finished_at
            ,fn.pi_state
			,fn.before_17_calltimes
        from
            (
	            select
		            pr.pno
		            ,pr.store_id
		            ,dp.store_name
		            ,dp.piece_name
		            ,dp.region_name
		            ,pr.staff_info_id
		            ,pi.state pi_state
	                ,convert_tz(pi.updated_at,'+00:00','+08:00') as pi_updated_at
		            ,if(pi.returned=1,'退件','正向件') as pno_type
		            ,convert_tz(pi.finished_at,'+00:00','+08:00') as finished_at
	                ,pr.staff_name
		            ,pr2.before_17_calltimes
		        from
		            ( # 所有17点前交接包裹找到最后一次交接的人
		                select
		                    pr.*
		                from
		                    (
		                        select
		                            pr.pno
		                            ,pr.staff_info_id
		                            ,hsi.name as staff_name
		                            ,pr.store_id
		                            ,row_number() over(partition by pr.pno order by convert_tz(pr.routed_at,'+00:00','+08:00') desc) as rnk
		                        from my_staging.parcel_route pr
		                        left join my_bi.hr_staff_info hsi on pr.staff_info_id=hsi.staff_info_id
		                        left join my_bi.hr_job_title hjt on hjt.id = hsi.job_title
		                        where
		                            pr.routed_at >= date_sub(curdate(), interval 8 hour)
		                            and pr.routed_at < date_add(curdate(), interval 9 hour)
		                            and pr.route_action in ('DELIVERY_TICKET_CREATION_SCAN')
		                            and hsi.job_title in(13,110,1199)
		                            and hsi.formal=1
		                    ) pr
		                    where  pr.rnk=1
		            ) pr
		            join dwm.dim_my_sys_store_rd dp on dp.store_id = pr.store_id and dp.stat_date = date_sub(curdate(), interval 1 day) and dp.store_category=1
		            left join my_staging.parcel_info pi on pr.pno = pi.pno
		        left join # 17点前拨打电话次数
		            (
		                select
		                    pr.pno
		                    ,count(pr.call_datetime) as before_17_calltimes
		                from
		                    (
		                        select
		                                pr.pno
		                                ,pr.staff_info_id
		                                ,convert_tz(pr.routed_at,'+00:00','+08:00')  as call_datetime
		                         from my_staging.parcel_route pr
		                         where
		                            pr.routed_at >= date_sub(curdate(), interval 8 hour)
		                            and pr.routed_at < date_add(curdate(), interval 9 hour)
		                            and pr.route_action in ('PHONE')
		                    )pr
		                group by 1
		            )pr2 on pr.pno = pr2.pno
	        )fn
    )




select
        fn.网点
	    ,fn.大区
	    ,fn.片区
# 	    ,fn.负责人
	    ,fn.员工ID
	    ,fn.快递员姓名
		,fn.交接量_非退件
		,fn.交接包裹妥投量_非退件妥投
	    ,fn.交接包裹妥投量_退件妥投
	    ,fn.交接包裹未拨打电话数
		,fn.员工出勤信息
		,fn.18点前快递员结束派件时间
		,fn.妥投率
		,case when fn.未按要求联系客户 is not null and fn.rk<=2 then '是' else null end as 违反A联系客户
		,fn.是否出勤不达标 as 违反B出勤
		,fn.是否低人效 as 违反C人效
    from
    (
        select
		    fk.*
			,row_number() over (partition by fk.网点,fk.未按要求联系客户 order by fk.交接包裹未拨打电话占比 desc) as rk
		    from
		    (
				select
				    f1.网点
				    ,f1.大区
				    ,f1.片区
# 				    ,f1.负责人
				    ,f1.员工ID
				    ,f1.快递员姓名
					,f1.交接量_非退件
					,f1.交接包裹妥投量_非退件妥投
				    ,f1.交接包裹妥投量_退件妥投
				    ,f1.交接包裹未拨打电话数
				    ,case when f5.late_days>=3 and f5.late_times>=300 then '最近一周迟到三次且迟到时间5小时'
				         when f5.absent_days>=2  then '最近一周缺勤2次' else null end as 员工出勤信息
				    ,f6.finished_at as 18点前快递员结束派件时间
				    ,concat(round(f1.交接包裹妥投量_非退件妥投/f1.交接量_非退件*100,2),'%') as 妥投率
				    ,f1.交接包裹未拨打电话占比


				    ,f5.absent_days as 缺勤天数
				    ,f5.late_days as 迟到天数
				    ,f5.late_times as 迟到时长_分钟
					,if(f1.交接包裹未拨打电话数>10 and f1.交接包裹未拨打电话占比>0.2,'未按要求联系客户',null) as 未按要求联系客户
					,case when f5.late_days>=3 and f5.late_times>=300 then '是' when f5.absent_days>=2  then '是' else null end as 是否出勤不达标
					,if(f1.交接包裹妥投量_非退件妥投/f1.交接量_非退件<0.7 and f1.交接包裹妥投量_非退件妥投<50 and hour(f6.finished_at)<15,'是',null) as 是否低人效

				from
					(# 快递员交接包裹后拨打电话情况
					    select
						    fn.region_name as 大区
# 						    ,case
# 							    when fn.region_name in ('Area3', 'Area6') then '彭万松'
# 							    when fn.region_name in ('Area4', 'Area9') then '韩钥'
# 							    when fn.region_name in ('Area7','Area10', 'Area11','FHome','Area14') then '张可新'
# 							    when fn.region_name in ( 'Area8') then '黄勇'
# 							    when fn.region_name in ('Area1', 'Area2','Area5', 'Area12','Area13') then '李俊'
# 								end 负责人
						    ,fn.piece_name as 片区
						    ,fn.store_name as 网点
							,fn.store_id
						    ,fn.staff_info_id as 员工ID
					        ,fn.staff_name as 快递员姓名
					        ,count(distinct case when  fn.before_17_calltimes is null then fn.pno else null end) as 交接包裹未拨打电话数
					        ,count(distinct case when  fn.before_17_calltimes is null then fn.pno else null end)/count(distinct fn.pno) as 交接包裹未拨打电话占比
					        ,count(distinct if(fn.pno_type='正向件', fn.pno ,null)) as 交接量_非退件
						    ,count(distinct if(fn.pi_state = 5 and fn.pno_type='正向件' ,fn.pno ,null)) 交接包裹妥投量_非退件妥投
						    ,count(distinct if(fn.pi_state = 5 and fn.pno_type='退件' ,fn.pno ,null)) 交接包裹妥投量_退件妥投
					    from  handover fn
					    group by 1,2,3,4,5,6
					)f1
				left join
					( -- 最近一周出勤
					    select
					        ad.staff_info_id
					        ,sum(case
						        when ad.leave_type is not null and ad.leave_time_type=1 then 0.5
						        when ad.leave_type is not null and ad.leave_time_type=2 then 0.5
						        when ad.leave_type is not null and ad.leave_time_type=3 then 1
						        else 0  end) as leave_num
					        ,count(distinct if(ad.attendance_time = 0, ad.stat_date, null)) absent_days
					        ,count(distinct if(ad.attendance_started_at > date_add(concat(ad.stat_date, ' ', ad.shift_start), interval 1 minute), ad.stat_date, null)) late_days
					        ,sum(if(ad.attendance_started_at > date_add(concat(ad.stat_date, ' ', ad.shift_start), interval 1 minute), timestampdiff(minute , concat(ad.stat_date, ' ', ad.shift_start), ad.attendance_started_at), 0)) late_times
					    from my_bi.attendance_data_v2 ad
					    where ad.attendance_time + ad.BT+ ad.BT_Y + ad.AB >0
					        and ad.stat_date>date_sub(current_date,interval 8 day)
					        and ad.stat_date<=date_sub(current_date,interval 1 day)
					    group by 1
					) f5 on f5.staff_info_id = f1.员工ID
				left join
					( -- 18点前最后一个妥投包裹时间
				        select
				             ha.ticket_delivery_staff_info_id
					        ,ha.finished_at
				        from
				        (
				            select
				                pi.ticket_delivery_staff_info_id
				                ,convert_tz(pi.finished_at,'+00:00','+08:00') as finished_at
				                ,row_number() over (partition by pi.ticket_delivery_staff_info_id order by pi.finished_at desc) as rk
					        from my_staging.parcel_info pi
					        where pi.state=5
					        and pi.finished_at>= date_sub(curdate(), interval 8 hour)
						    and pi.finished_at< date_add(curdate(), interval 10 hour)
				        )ha
				        where ha.rk=1
					) f6 on f6.ticket_delivery_staff_info_id = f1.员工ID
		    )fk
    )fn;
;-- -. . -..- - / . -. - .-. -.--
with handover as
    (
        select
            fn.pno
            ,fn.pno_type
            ,fn.store_id
            ,fn.store_name
            ,fn.piece_name
            ,fn.region_name
            ,fn.staff_info_id
            ,fn.staff_name
            ,fn.finished_at
            ,fn.pi_state
			,fn.before_17_calltimes
        from
            (
	            select
		            pr.pno
		            ,pr.store_id
		            ,dp.store_name
		            ,dp.piece_name
		            ,dp.region_name
		            ,pr.staff_info_id
		            ,pi.state pi_state
	                ,convert_tz(pi.updated_at,'+00:00','+08:00') as pi_updated_at
		            ,if(pi.returned=1,'退件','正向件') as pno_type
		            ,convert_tz(pi.finished_at,'+00:00','+08:00') as finished_at
	                ,pr.staff_name
		            ,pr2.before_17_calltimes
		        from
		            ( # 所有17点前交接包裹找到最后一次交接的人
		                select
		                    pr.*
		                from
		                    (
		                        select
		                            pr.pno
		                            ,pr.staff_info_id
		                            ,hsi.name as staff_name
		                            ,pr.store_id
		                            ,row_number() over(partition by pr.pno order by convert_tz(pr.routed_at,'+00:00','+08:00') desc) as rnk
		                        from my_staging.parcel_route pr
		                        left join my_bi.hr_staff_info hsi on pr.staff_info_id=hsi.staff_info_id
		                        left join my_bi.hr_job_title hjt on hjt.id = hsi.job_title
		                        where
		                            pr.routed_at >= date_sub(curdate(), interval 8 hour)
		                            and pr.routed_at < date_add(curdate(), interval 9 hour)
		                            and pr.route_action in ('DELIVERY_TICKET_CREATION_SCAN')
		                            and hsi.job_title in(13,110,1000)
		                            and hsi.formal=1
		                    ) pr
		                    where  pr.rnk=1
		            ) pr
		            join dwm.dim_my_sys_store_rd dp on dp.store_id = pr.store_id and dp.stat_date = date_sub(curdate(), interval 1 day) and dp.store_category=1
		            left join my_staging.parcel_info pi on pr.pno = pi.pno
		        left join # 17点前拨打电话次数
		            (
		                select
		                    pr.pno
		                    ,count(pr.call_datetime) as before_17_calltimes
		                from
		                    (
		                        select
		                                pr.pno
		                                ,pr.staff_info_id
		                                ,convert_tz(pr.routed_at,'+00:00','+08:00')  as call_datetime
		                         from my_staging.parcel_route pr
		                         where
		                            pr.routed_at >= date_sub(curdate(), interval 8 hour)
		                            and pr.routed_at < date_add(curdate(), interval 9 hour)
		                            and pr.route_action in ('PHONE')
		                    )pr
		                group by 1
		            )pr2 on pr.pno = pr2.pno
	        )fn
    ),
 handover2 as
    (
        select
            fn.pno
            ,fn.pno_type
            ,fn.store_id
            ,fn.store_name
            ,fn.piece_name
            ,fn.region_name
            ,fn.staff_info_id
            ,fn.staff_name
            ,fn.finished_at
            ,fn.pi_state
			,fn.before_17_calltimes
        from
            (
	            select
		            pr.pno
		            ,pr.store_id
		            ,dp.store_name
		            ,dp.piece_name
		            ,dp.region_name
		            ,pr.staff_info_id
		            ,pi.state pi_state
	                ,convert_tz(pi.updated_at,'+00:00','+08:00') as pi_updated_at
		            ,if(pi.returned=1,'退件','正向件') as pno_type
		            ,convert_tz(pi.finished_at,'+00:00','+08:00') as finished_at
	                ,pr.staff_name
		            ,pr2.before_17_calltimes
		        from
		            ( # 所有17点前交接包裹找到最后一次交接的人
		                select
		                    pr.*
		                from
		                    (
		                        select
		                            pr.pno
		                            ,pr.staff_info_id
		                            ,hsi.name as staff_name
		                            ,pr.store_id
		                            ,row_number() over(partition by pr.pno order by convert_tz(pr.routed_at,'+00:00','+08:00') desc) as rnk
		                        from my_staging.parcel_route pr
		                        left join my_bi.hr_staff_info hsi on pr.staff_info_id=hsi.staff_info_id
		                        left join my_bi.hr_job_title hjt on hjt.id = hsi.job_title
		                        where
		                            pr.routed_at >= date_sub(curdate(), interval 8 hour)
		                            and pr.routed_at < date_add(curdate(), interval 9 hour)
		                            and pr.route_action in ('DELIVERY_TICKET_CREATION_SCAN')
		                            and hsi.job_title in(13,110,1000)
		                            and hsi.formal=1
		                    ) pr
		                    where  pr.rnk=1
		            ) pr
		            join dwm.dim_my_sys_store_rd dp on dp.store_id = pr.store_id and dp.stat_date = date_sub(curdate(), interval 1 day) and dp.store_category=1
		            left join my_staging.parcel_info pi on pr.pno = pi.pno
		        left join # 17点前拨打电话次数
		            (
		                select
		                    pr.pno
		                    ,count(pr.call_datetime) as before_17_calltimes
		                from
		                    (
		                        select
		                                pr.pno
		                                ,pr.staff_info_id
		                                ,convert_tz(pr.routed_at,'+00:00','+08:00')  as call_datetime
		                         from my_staging.parcel_route pr
		                         where
		                            pr.routed_at >= date_sub(curdate(), interval 8 hour)
		                            and pr.routed_at < date_add(curdate(), interval 10 hour)
		                            and pr.route_action in ('PHONE')
		                    )pr
		                group by 1
		            )pr2 on pr.pno = pr2.pno
	        )fn
    )




select
        fn.网点
	    ,fn.大区
	    ,fn.片区
	    ,fn.负责人
	    ,fn.员工ID
	    ,fn.快递员姓名
		,fn.交接量_非退件
		,fn.交接包裹妥投量_非退件妥投
	    ,fn.交接包裹妥投量_退件妥投
	    ,fn.交接包裹未拨打电话数 交接包裹未妥投未拨打电话数
		,fn.员工出勤信息
		,fn.18点前快递员结束派件时间
		,fn.妥投率
		,case when fn.未按要求联系客户 is not null and fn.rk<=2 then '是' else null end as 违反A联系客户
		,fn.是否出勤不达标 as 违反B出勤
		,fn.是否低人效 as 违反C人效
    from
    (
        select
		    fk.*
			,row_number() over (partition by fk.网点,fk.未按要求联系客户 order by fk.交接包裹未拨打电话占比 desc) as rk
		    from
		    (
				select
				    f1.网点
				    ,f1.大区
				    ,f1.片区
				    ,f1.负责人
				    ,f1.员工ID
				    ,f1.快递员姓名
					,f2.交接量_非退件
					,f2.交接包裹妥投量_非退件妥投
				    ,f2.交接包裹妥投量_退件妥投
				    ,f1.交接包裹未拨打电话数
				    ,case when f5.late_days>=3 and f5.late_times>=300 then '最近一周迟到至少三次且迟到时间至少5小时'
				         when f5.absent_days>=2  then '最近一周缺勤>=2次' else null end as 员工出勤信息
				    ,f6.finished_at as 18点前快递员结束派件时间
				    ,concat(round(f2.交接包裹妥投量_非退件妥投/f2.交接量_非退件*100,2),'%') as 妥投率
				    ,f1.交接包裹未拨打电话占比


				    ,f5.absent_days as 缺勤天数
				    ,f5.late_days as 迟到天数
				    ,f5.late_times as 迟到时长_分钟
					,if(f1.交接包裹未拨打电话数>10 and f1.交接包裹未拨打电话占比>0.2,'未按要求联系客户',null) as 未按要求联系客户
					,case when f5.late_days>=3 and f5.late_times>=300 then '是' when f5.absent_days>=2  then '是' else null end as 是否出勤不达标
					,if(f2.交接包裹妥投量_非退件妥投/f2.交接量_非退件<0.7 and f2.交接包裹妥投量_非退件妥投<70 and hour(f6.finished_at)<15,'是',null) as 是否低人效

				from
					(# 快递员交接包裹后拨打电话情况
					    select
						    fn.region_name as 大区
						    ,case
							    when fn.region_name in ('Area3', 'Area6') then '彭万松'
							    when fn.region_name in ('Area4', 'Area9') then '韩钥'
							    when fn.region_name in ('Area7','Area10', 'Area11','FHome','Area14') then '张可新'
							    when fn.region_name in ( 'Area8') then '黄勇'
							    when fn.region_name in ('Area1', 'Area2','Area5', 'Area12','Area13') then '李俊'
								end 负责人
						    ,fn.piece_name as 片区
						    ,fn.store_name as 网点
							,fn.store_id
						    ,fn.staff_info_id as 员工ID
					        ,fn.staff_name as 快递员姓名
					        ,count(distinct case when  fn.before_17_calltimes is null and fn.pi_state not in(5,7,8,9) then fn.pno else null end) as 交接包裹未拨打电话数
					        ,count(distinct case when  fn.before_17_calltimes is null and fn.pi_state not in(5,7,8,9) then fn.pno else null end)/count(distinct fn.pno) as 交接包裹未拨打电话占比
					    from  handover fn
					    group by 1,2,3,4,5,6,7
					)f1
				left join
					    (
						    select
							    fn.staff_info_id as 员工ID
						        ,fn.staff_name as 快递员姓名
						        ,count(distinct if(fn.pno_type='正向件', fn.pno ,null)) as 交接量_非退件
							    ,count(distinct if(fn.pi_state = 5 and fn.pno_type='正向件' ,fn.pno ,null)) 交接包裹妥投量_非退件妥投
							    ,count(distinct if(fn.pi_state = 5 and fn.pno_type='退件' ,fn.pno ,null)) 交接包裹妥投量_退件妥投
						    from  handover fn
						    group by 1,2
					    )f2 on f2.员工ID = f1.员工ID
				left join
					( -- 最近一周出勤
					    select
					        ad.staff_info_id
					        ,sum(case
						        when ad.leave_type is not null and ad.leave_time_type=1 then 0.5
						        when ad.leave_type is not null and ad.leave_time_type=2 then 0.5
						        when ad.leave_type is not null and ad.leave_time_type=3 then 1
						        else 0  end) as leave_num
					        ,count(distinct if(ad.attendance_time = 0, ad.stat_date, null)) absent_days
					        ,count(distinct if(ad.attendance_started_at > date_add(concat(ad.stat_date, ' ', ad.shift_start), interval 1 minute), ad.stat_date, null)) late_days
					        ,sum(if(ad.attendance_started_at > date_add(concat(ad.stat_date, ' ', ad.shift_start), interval 1 minute), timestampdiff(minute , concat(ad.stat_date, ' ', ad.shift_start), ad.attendance_started_at), 0)) late_times
					    from my_bi.attendance_data_v2 ad
					    where ad.attendance_time + ad.BT+ ad.BT_Y + ad.AB >0
					        and ad.stat_date>date_sub(current_date,interval 8 day)
					        and ad.stat_date<=date_sub(current_date,interval 1 day)
					    group by 1
					) f5 on f5.staff_info_id = f1.员工ID
				left join
					( -- 18点前最后一个妥投包裹时间
				        select
				             ha.ticket_delivery_staff_info_id
					        ,ha.finished_at
				        from
				        (
				            select
				                pi.ticket_delivery_staff_info_id
				                ,convert_tz(pi.finished_at,'+00:00','+08:00') as finished_at
				                ,row_number() over (partition by pi.ticket_delivery_staff_info_id order by pi.finished_at desc) as rk
					        from my_staging.parcel_info pi
					        where pi.state=5
					        and pi.finished_at>= date_sub(curdate(), interval 8 hour)
						    and pi.finished_at< date_add(curdate(), interval 10 hour)
				        )ha
				        where ha.rk=1
					) f6 on f6.ticket_delivery_staff_info_id = f1.员工ID
		    )fk
    )fn;
;-- -. . -..- - / . -. - .-. -.--
with handover as
    (
        select
            fn.pno
            ,fn.pno_type
            ,fn.store_id
            ,fn.store_name
            ,fn.piece_name
            ,fn.region_name
            ,fn.staff_info_id
            ,fn.staff_name
            ,fn.finished_at
            ,fn.pi_state
			,fn.before_17_calltimes
        from
            (
	            select
		            pr.pno
		            ,pr.store_id
		            ,dp.store_name
		            ,dp.piece_name
		            ,dp.region_name
		            ,pr.staff_info_id
		            ,pi.state pi_state
	                ,convert_tz(pi.updated_at,'+00:00','+08:00') as pi_updated_at
		            ,if(pi.returned=1,'退件','正向件') as pno_type
		            ,convert_tz(pi.finished_at,'+00:00','+08:00') as finished_at
	                ,pr.staff_name
		            ,pr2.before_17_calltimes
		        from
		            ( # 所有17点前交接包裹找到最后一次交接的人
		                select
		                    pr.*
		                from
		                    (
		                        select
		                            pr.pno
		                            ,pr.staff_info_id
		                            ,hsi.name as staff_name
		                            ,pr.store_id
		                            ,row_number() over(partition by pr.pno order by convert_tz(pr.routed_at,'+00:00','+08:00') desc) as rnk
		                        from my_staging.parcel_route pr
		                        left join my_bi.hr_staff_info hsi on pr.staff_info_id=hsi.staff_info_id
		                        left join my_bi.hr_job_title hjt on hjt.id = hsi.job_title
		                        where
		                            pr.routed_at >= date_sub(curdate(), interval 8 hour)
		                            and pr.routed_at < date_add(curdate(), interval 9 hour)
		                            and pr.route_action in ('DELIVERY_TICKET_CREATION_SCAN')
		                            and hsi.job_title in(13,110,1000)
		                            and hsi.formal=1
		                    ) pr
		                    where  pr.rnk=1
		            ) pr
		            join dwm.dim_my_sys_store_rd dp on dp.store_id = pr.store_id and dp.stat_date = date_sub(curdate(), interval 1 day) and dp.store_category=1
		            left join my_staging.parcel_info pi on pr.pno = pi.pno
		        left join # 17点前拨打电话次数
		            (
		                select
		                    pr.pno
		                    ,count(pr.call_datetime) as before_17_calltimes
		                from
		                    (
		                        select
		                                pr.pno
		                                ,pr.staff_info_id
		                                ,convert_tz(pr.routed_at,'+00:00','+08:00')  as call_datetime
		                         from my_staging.parcel_route pr
		                         where
		                            pr.routed_at >= date_sub(curdate(), interval 8 hour)
		                            and pr.routed_at < date_add(curdate(), interval 9 hour)
		                            and pr.route_action in ('PHONE')
		                    )pr
		                group by 1
		            )pr2 on pr.pno = pr2.pno
	        )fn
    ),
 handover2 as
    (
        select
            fn.pno
            ,fn.pno_type
            ,fn.store_id
            ,fn.store_name
            ,fn.piece_name
            ,fn.region_name
            ,fn.staff_info_id
            ,fn.staff_name
            ,fn.finished_at
            ,fn.pi_state
			,fn.before_17_calltimes
        from
            (
	            select
		            pr.pno
		            ,pr.store_id
		            ,dp.store_name
		            ,dp.piece_name
		            ,dp.region_name
		            ,pr.staff_info_id
		            ,pi.state pi_state
	                ,convert_tz(pi.updated_at,'+00:00','+08:00') as pi_updated_at
		            ,if(pi.returned=1,'退件','正向件') as pno_type
		            ,convert_tz(pi.finished_at,'+00:00','+08:00') as finished_at
	                ,pr.staff_name
		            ,pr2.before_17_calltimes
		        from
		            ( # 所有17点前交接包裹找到最后一次交接的人
		                select
		                    pr.*
		                from
		                    (
		                        select
		                            pr.pno
		                            ,pr.staff_info_id
		                            ,hsi.name as staff_name
		                            ,pr.store_id
		                            ,row_number() over(partition by pr.pno order by convert_tz(pr.routed_at,'+00:00','+08:00') desc) as rnk
		                        from my_staging.parcel_route pr
		                        left join my_bi.hr_staff_info hsi on pr.staff_info_id=hsi.staff_info_id
		                        left join my_bi.hr_job_title hjt on hjt.id = hsi.job_title
		                        where
		                            pr.routed_at >= date_sub(curdate(), interval 8 hour)
		                            and pr.routed_at < date_add(curdate(), interval 9 hour)
		                            and pr.route_action in ('DELIVERY_TICKET_CREATION_SCAN')
		                            and hsi.job_title in(13,110,1000)
		                            and hsi.formal=1
		                    ) pr
		                    where  pr.rnk=1
		            ) pr
		            join dwm.dim_my_sys_store_rd dp on dp.store_id = pr.store_id and dp.stat_date = date_sub(curdate(), interval 1 day) and dp.store_category=1
		            left join my_staging.parcel_info pi on pr.pno = pi.pno
		        left join # 17点前拨打电话次数
		            (
		                select
		                    pr.pno
		                    ,count(pr.call_datetime) as before_17_calltimes
		                from
		                    (
		                        select
		                                pr.pno
		                                ,pr.staff_info_id
		                                ,convert_tz(pr.routed_at,'+00:00','+08:00')  as call_datetime
		                         from my_staging.parcel_route pr
		                         where
		                            pr.routed_at >= date_sub(curdate(), interval 8 hour)
		                            and pr.routed_at < date_add(curdate(), interval 10 hour)
		                            and pr.route_action in ('PHONE')
		                    )pr
		                group by 1
		            )pr2 on pr.pno = pr2.pno
	        )fn
    )




select
        fn.网点
	    ,fn.大区
	    ,fn.片区
# 	    ,fn.负责人
	    ,fn.员工ID
	    ,fn.快递员姓名
		,fn.交接量_非退件
		,fn.交接包裹妥投量_非退件妥投
	    ,fn.交接包裹妥投量_退件妥投
	    ,fn.交接包裹未拨打电话数 交接包裹未妥投未拨打电话数
		,fn.员工出勤信息
		,fn.18点前快递员结束派件时间
		,fn.妥投率
		,case when fn.未按要求联系客户 is not null and fn.rk<=2 then '是' else null end as 违反A联系客户
		,fn.是否出勤不达标 as 违反B出勤
		,fn.是否低人效 as 违反C人效
    from
    (
        select
		    fk.*
			,row_number() over (partition by fk.网点,fk.未按要求联系客户 order by fk.交接包裹未拨打电话占比 desc) as rk
		    from
		    (
				select
				    f1.网点
				    ,f1.大区
				    ,f1.片区
				    ,f1.负责人
				    ,f1.员工ID
				    ,f1.快递员姓名
					,f2.交接量_非退件
					,f2.交接包裹妥投量_非退件妥投
				    ,f2.交接包裹妥投量_退件妥投
				    ,f1.交接包裹未拨打电话数
				    ,case when f5.late_days>=3 and f5.late_times>=300 then '最近一周迟到至少三次且迟到时间至少5小时'
				         when f5.absent_days>=2  then '最近一周缺勤>=2次' else null end as 员工出勤信息
				    ,f6.finished_at as 18点前快递员结束派件时间
				    ,concat(round(f2.交接包裹妥投量_非退件妥投/f2.交接量_非退件*100,2),'%') as 妥投率
				    ,f1.交接包裹未拨打电话占比


				    ,f5.absent_days as 缺勤天数
				    ,f5.late_days as 迟到天数
				    ,f5.late_times as 迟到时长_分钟
					,if(f1.交接包裹未拨打电话数>10 and f1.交接包裹未拨打电话占比>0.2,'未按要求联系客户',null) as 未按要求联系客户
					,case when f5.late_days>=3 and f5.late_times>=300 then '是' when f5.absent_days>=2  then '是' else null end as 是否出勤不达标
					,if(f2.交接包裹妥投量_非退件妥投/f2.交接量_非退件<0.7 and f2.交接包裹妥投量_非退件妥投<70 and hour(f6.finished_at)<15,'是',null) as 是否低人效

				from
					(# 快递员交接包裹后拨打电话情况
					    select
						    fn.region_name as 大区
						    ,case
							    when fn.region_name in ('Area3', 'Area6') then '彭万松'
							    when fn.region_name in ('Area4', 'Area9') then '韩钥'
							    when fn.region_name in ('Area7','Area10', 'Area11','FHome','Area14') then '张可新'
							    when fn.region_name in ( 'Area8') then '黄勇'
							    when fn.region_name in ('Area1', 'Area2','Area5', 'Area12','Area13') then '李俊'
								end 负责人
						    ,fn.piece_name as 片区
						    ,fn.store_name as 网点
							,fn.store_id
						    ,fn.staff_info_id as 员工ID
					        ,fn.staff_name as 快递员姓名
					        ,count(distinct case when  fn.before_17_calltimes is null and fn.pi_state not in(5,7,8,9) then fn.pno else null end) as 交接包裹未拨打电话数
					        ,count(distinct case when  fn.before_17_calltimes is null and fn.pi_state not in(5,7,8,9) then fn.pno else null end)/count(distinct fn.pno) as 交接包裹未拨打电话占比
					    from  handover fn
					    group by 1,2,3,4,5,6,7
					)f1
				left join
					    (
						    select
							    fn.staff_info_id as 员工ID
						        ,fn.staff_name as 快递员姓名
						        ,count(distinct if(fn.pno_type='正向件', fn.pno ,null)) as 交接量_非退件
							    ,count(distinct if(fn.pi_state = 5 and fn.pno_type='正向件' ,fn.pno ,null)) 交接包裹妥投量_非退件妥投
							    ,count(distinct if(fn.pi_state = 5 and fn.pno_type='退件' ,fn.pno ,null)) 交接包裹妥投量_退件妥投
						    from  handover fn
						    group by 1,2
					    )f2 on f2.员工ID = f1.员工ID
				left join
					( -- 最近一周出勤
					    select
					        ad.staff_info_id
					        ,sum(case
						        when ad.leave_type is not null and ad.leave_time_type=1 then 0.5
						        when ad.leave_type is not null and ad.leave_time_type=2 then 0.5
						        when ad.leave_type is not null and ad.leave_time_type=3 then 1
						        else 0  end) as leave_num
					        ,count(distinct if(ad.attendance_time = 0, ad.stat_date, null)) absent_days
					        ,count(distinct if(ad.attendance_started_at > date_add(concat(ad.stat_date, ' ', ad.shift_start), interval 1 minute), ad.stat_date, null)) late_days
					        ,sum(if(ad.attendance_started_at > date_add(concat(ad.stat_date, ' ', ad.shift_start), interval 1 minute), timestampdiff(minute , concat(ad.stat_date, ' ', ad.shift_start), ad.attendance_started_at), 0)) late_times
					    from my_bi.attendance_data_v2 ad
					    where ad.attendance_time + ad.BT+ ad.BT_Y + ad.AB >0
					        and ad.stat_date>date_sub(current_date,interval 8 day)
					        and ad.stat_date<=date_sub(current_date,interval 1 day)
					    group by 1
					) f5 on f5.staff_info_id = f1.员工ID
				left join
					( -- 18点前最后一个妥投包裹时间
				        select
				             ha.ticket_delivery_staff_info_id
					        ,ha.finished_at
				        from
				        (
				            select
				                pi.ticket_delivery_staff_info_id
				                ,convert_tz(pi.finished_at,'+00:00','+08:00') as finished_at
				                ,row_number() over (partition by pi.ticket_delivery_staff_info_id order by pi.finished_at desc) as rk
					        from my_staging.parcel_info pi
					        where pi.state=5
					        and pi.finished_at>= date_sub(curdate(), interval 8 hour)
						    and pi.finished_at< date_add(curdate(), interval 10 hour)
				        )ha
				        where ha.rk=1
					) f6 on f6.ticket_delivery_staff_info_id = f1.员工ID
		    )fk
    )fn;
;-- -. . -..- - / . -. - .-. -.--
with handover as
    (
        select
            fn.pno
            ,fn.pno_type
            ,fn.store_id
            ,fn.store_name
            ,fn.piece_name
            ,fn.region_name
            ,fn.staff_info_id
            ,fn.staff_name
            ,fn.finished_at
            ,fn.pi_state
			,fn.before_17_calltimes
        from
            (
	            select
		            pr.pno
		            ,pr.store_id
		            ,dp.store_name
		            ,dp.piece_name
		            ,dp.region_name
		            ,pr.staff_info_id
		            ,pi.state pi_state
	                ,convert_tz(pi.updated_at,'+00:00','+08:00') as pi_updated_at
		            ,if(pi.returned=1,'退件','正向件') as pno_type
		            ,convert_tz(pi.finished_at,'+00:00','+08:00') as finished_at
	                ,pr.staff_name
		            ,pr2.before_17_calltimes
		        from
		            ( # 所有17点前交接包裹找到最后一次交接的人
		                select
		                    pr.*
		                from
		                    (
		                        select
		                            pr.pno
		                            ,pr.staff_info_id
		                            ,hsi.name as staff_name
		                            ,pr.store_id
		                            ,row_number() over(partition by pr.pno order by convert_tz(pr.routed_at,'+00:00','+08:00') desc) as rnk
		                        from my_staging.parcel_route pr
		                        left join my_bi.hr_staff_info hsi on pr.staff_info_id=hsi.staff_info_id
		                        left join my_bi.hr_job_title hjt on hjt.id = hsi.job_title
		                        where
		                            pr.routed_at >= date_sub(curdate(), interval 8 hour)
		                            and pr.routed_at < date_add(curdate(), interval 9 hour)
		                            and pr.route_action in ('DELIVERY_TICKET_CREATION_SCAN')
		                            and hsi.job_title in(13,110,1199)
		                            and hsi.formal=1
		                    ) pr
		                    where  pr.rnk=1
		            ) pr
		            join dwm.dim_my_sys_store_rd dp on dp.store_id = pr.store_id and dp.stat_date = date_sub(curdate(), interval 1 day) and dp.store_category=1
		            left join my_staging.parcel_info pi on pr.pno = pi.pno
		        left join # 17点前拨打电话次数
		            (
		                select
		                    pr.pno
		                    ,count(pr.call_datetime) as before_17_calltimes
		                from
		                    (
		                        select
		                                pr.pno
		                                ,pr.staff_info_id
		                                ,convert_tz(pr.routed_at,'+00:00','+08:00')  as call_datetime
		                         from my_staging.parcel_route pr
		                         where
		                            pr.routed_at >= date_sub(curdate(), interval 8 hour)
		                            and pr.routed_at < date_add(curdate(), interval 9 hour)
		                            and pr.route_action in ('PHONE')
		                    )pr
		                group by 1
		            )pr2 on pr.pno = pr2.pno
	        )fn
    ),
 handover2 as
    (
        select
            fn.pno
            ,fn.pno_type
            ,fn.store_id
            ,fn.store_name
            ,fn.piece_name
            ,fn.region_name
            ,fn.staff_info_id
            ,fn.staff_name
            ,fn.finished_at
            ,fn.pi_state
			,fn.before_17_calltimes
        from
            (
	            select
		            pr.pno
		            ,pr.store_id
		            ,dp.store_name
		            ,dp.piece_name
		            ,dp.region_name
		            ,pr.staff_info_id
		            ,pi.state pi_state
	                ,convert_tz(pi.updated_at,'+00:00','+08:00') as pi_updated_at
		            ,if(pi.returned=1,'退件','正向件') as pno_type
		            ,convert_tz(pi.finished_at,'+00:00','+08:00') as finished_at
	                ,pr.staff_name
		            ,pr2.before_17_calltimes
		        from
		            ( # 所有17点前交接包裹找到最后一次交接的人
		                select
		                    pr.*
		                from
		                    (
		                        select
		                            pr.pno
		                            ,pr.staff_info_id
		                            ,hsi.name as staff_name
		                            ,pr.store_id
		                            ,row_number() over(partition by pr.pno order by convert_tz(pr.routed_at,'+00:00','+08:00') desc) as rnk
		                        from my_staging.parcel_route pr
		                        left join my_bi.hr_staff_info hsi on pr.staff_info_id=hsi.staff_info_id
		                        left join my_bi.hr_job_title hjt on hjt.id = hsi.job_title
		                        where
		                            pr.routed_at >= date_sub(curdate(), interval 8 hour)
		                            and pr.routed_at < date_add(curdate(), interval 10 hour)
		                            and pr.route_action in ('DELIVERY_TICKET_CREATION_SCAN')
		                            and hsi.job_title in(13,110,1199)
		                            and hsi.formal=1
		                    ) pr
		                    where  pr.rnk=1
		            ) pr
		            join dwm.dim_my_sys_store_rd dp on dp.store_id = pr.store_id and dp.stat_date = date_sub(curdate(), interval 1 day) and dp.store_category=1
		            left join my_staging.parcel_info pi on pr.pno = pi.pno
		        left join # 17点前拨打电话次数
		            (
		                select
		                    pr.pno
		                    ,count(pr.call_datetime) as before_17_calltimes
		                from
		                    (
		                        select
		                                pr.pno
		                                ,pr.staff_info_id
		                                ,convert_tz(pr.routed_at,'+00:00','+08:00')  as call_datetime
		                         from my_staging.parcel_route pr
		                         where
		                            pr.routed_at >= date_sub(curdate(), interval 8 hour)
		                            and pr.routed_at < date_add(curdate(), interval 10 hour)
		                            and pr.route_action in ('PHONE')
		                    )pr
		                group by 1
		            )pr2 on pr.pno = pr2.pno
	        )fn
    )




select
        fn.网点
	    ,fn.大区
	    ,fn.片区
# 	    ,fn.负责人
	    ,fn.员工ID
	    ,fn.快递员姓名
		,fn.交接量_非退件
		,fn.交接包裹妥投量_非退件妥投
	    ,fn.交接包裹妥投量_退件妥投
	    ,fn.交接包裹未拨打电话数 交接包裹未妥投未拨打电话数
		,fn.员工出勤信息
		,fn.18点前快递员结束派件时间
		,fn.妥投率
		,case when fn.未按要求联系客户 is not null and fn.rk<=2 then '是' else null end as 违反A联系客户
		,fn.是否出勤不达标 as 违反B出勤
		,fn.是否低人效 as 违反C人效
    from
    (
        select
		    fk.*
			,row_number() over (partition by fk.网点,fk.未按要求联系客户 order by fk.交接包裹未拨打电话占比 desc) as rk
		    from
		    (
				select
				    f1.网点
				    ,f1.大区
				    ,f1.片区
				    ,f1.负责人
				    ,f1.员工ID
				    ,f1.快递员姓名
					,f2.交接量_非退件
					,f2.交接包裹妥投量_非退件妥投
				    ,f2.交接包裹妥投量_退件妥投
				    ,f1.交接包裹未拨打电话数
				    ,case when f5.late_days>=3 and f5.late_times>=300 then '最近一周迟到至少三次且迟到时间至少5小时'
				         when f5.absent_days>=2  then '最近一周缺勤>=2次' else null end as 员工出勤信息
				    ,f6.finished_at as 18点前快递员结束派件时间
				    ,concat(round(f2.交接包裹妥投量_非退件妥投/f2.交接量_非退件*100,2),'%') as 妥投率
				    ,f1.交接包裹未拨打电话占比


				    ,f5.absent_days as 缺勤天数
				    ,f5.late_days as 迟到天数
				    ,f5.late_times as 迟到时长_分钟
					,if(f1.交接包裹未拨打电话数>10 and f1.交接包裹未拨打电话占比>0.2,'未按要求联系客户',null) as 未按要求联系客户
					,case when f5.late_days>=3 and f5.late_times>=300 then '是' when f5.absent_days>=2  then '是' else null end as 是否出勤不达标
					,if(f2.交接包裹妥投量_非退件妥投/f2.交接量_非退件<0.7 and f2.交接包裹妥投量_非退件妥投<70 and hour(f6.finished_at)<15,'是',null) as 是否低人效

				from
					(# 快递员交接包裹后拨打电话情况
					    select
						    fn.region_name as 大区
# 						    ,case
# 							    when fn.region_name in ('Area3', 'Area6') then '彭万松'
# 							    when fn.region_name in ('Area4', 'Area9') then '韩钥'
# 							    when fn.region_name in ('Area7','Area10', 'Area11','FHome','Area14') then '张可新'
# 							    when fn.region_name in ( 'Area8') then '黄勇'
# 							    when fn.region_name in ('Area1', 'Area2','Area5', 'Area12','Area13') then '李俊'
# 								end 负责人
						    ,fn.piece_name as 片区
						    ,fn.store_name as 网点
							,fn.store_id
						    ,fn.staff_info_id as 员工ID
					        ,fn.staff_name as 快递员姓名
					        ,count(distinct case when  fn.before_17_calltimes is null and fn.pi_state not in(5,7,8,9) then fn.pno else null end) as 交接包裹未拨打电话数
					        ,count(distinct case when  fn.before_17_calltimes is null and fn.pi_state not in(5,7,8,9) then fn.pno else null end)/count(distinct fn.pno) as 交接包裹未拨打电话占比
					    from  handover fn
					    group by 1,2,3,4,5,6
					)f1
				left join
					    (
						    select
							    fn.staff_info_id as 员工ID
						        ,fn.staff_name as 快递员姓名
						        ,count(distinct if(fn.pno_type='正向件', fn.pno ,null)) as 交接量_非退件
							    ,count(distinct if(fn.pi_state = 5 and fn.pno_type='正向件' ,fn.pno ,null)) 交接包裹妥投量_非退件妥投
							    ,count(distinct if(fn.pi_state = 5 and fn.pno_type='退件' ,fn.pno ,null)) 交接包裹妥投量_退件妥投
						    from  handover2 fn
						    group by 1,2
					    )f2 on f2.员工ID = f1.员工ID
				left join
					( -- 最近一周出勤
					    select
					        ad.staff_info_id
					        ,sum(case
						        when ad.leave_type is not null and ad.leave_time_type=1 then 0.5
						        when ad.leave_type is not null and ad.leave_time_type=2 then 0.5
						        when ad.leave_type is not null and ad.leave_time_type=3 then 1
						        else 0  end) as leave_num
					        ,count(distinct if(ad.attendance_time = 0, ad.stat_date, null)) absent_days
					        ,count(distinct if(ad.attendance_started_at > date_add(concat(ad.stat_date, ' ', ad.shift_start), interval 1 minute), ad.stat_date, null)) late_days
					        ,sum(if(ad.attendance_started_at > date_add(concat(ad.stat_date, ' ', ad.shift_start), interval 1 minute), timestampdiff(minute , concat(ad.stat_date, ' ', ad.shift_start), ad.attendance_started_at), 0)) late_times
					    from my_bi.attendance_data_v2 ad
					    where ad.attendance_time + ad.BT+ ad.BT_Y + ad.AB >0
					        and ad.stat_date>date_sub(current_date,interval 8 day)
					        and ad.stat_date<=date_sub(current_date,interval 1 day)
					    group by 1
					) f5 on f5.staff_info_id = f1.员工ID
				left join
					( -- 18点前最后一个妥投包裹时间
				        select
				             ha.ticket_delivery_staff_info_id
					        ,ha.finished_at
				        from
				        (
				            select
				                pi.ticket_delivery_staff_info_id
				                ,convert_tz(pi.finished_at,'+00:00','+08:00') as finished_at
				                ,row_number() over (partition by pi.ticket_delivery_staff_info_id order by pi.finished_at desc) as rk
					        from my_staging.parcel_info pi
					        where pi.state=5
					        and pi.finished_at>= date_sub(curdate(), interval 8 hour)
						    and pi.finished_at< date_add(curdate(), interval 10 hour)
				        )ha
				        where ha.rk=1
					) f6 on f6.ticket_delivery_staff_info_id = f1.员工ID
		    )fk
    )fn;
;-- -. . -..- - / . -. - .-. -.--
with handover as
    (
        select
            fn.pno
            ,fn.pno_type
            ,fn.store_id
            ,fn.store_name
            ,fn.piece_name
            ,fn.region_name
            ,fn.staff_info_id
            ,fn.staff_name
            ,fn.finished_at
            ,fn.pi_state
			,fn.before_17_calltimes
        from
            (
	            select
		            pr.pno
		            ,pr.store_id
		            ,dp.store_name
		            ,dp.piece_name
		            ,dp.region_name
		            ,pr.staff_info_id
		            ,pi.state pi_state
	                ,convert_tz(pi.updated_at,'+00:00','+08:00') as pi_updated_at
		            ,if(pi.returned=1,'退件','正向件') as pno_type
		            ,convert_tz(pi.finished_at,'+00:00','+08:00') as finished_at
	                ,pr.staff_name
		            ,pr2.before_17_calltimes
		        from
		            ( # 所有17点前交接包裹找到最后一次交接的人
		                select
		                    pr.*
		                from
		                    (
		                        select
		                            pr.pno
		                            ,pr.staff_info_id
		                            ,hsi.name as staff_name
		                            ,pr.store_id
		                            ,row_number() over(partition by pr.pno order by convert_tz(pr.routed_at,'+00:00','+08:00') desc) as rnk
		                        from my_staging.parcel_route pr
		                        left join my_bi.hr_staff_info hsi on pr.staff_info_id=hsi.staff_info_id
		                        left join my_bi.hr_job_title hjt on hjt.id = hsi.job_title
		                        where
		                            pr.routed_at >= date_sub(curdate(), interval 8 hour)
		                            and pr.routed_at < date_add(curdate(), interval 9 hour)
		                            and pr.route_action in ('DELIVERY_TICKET_CREATION_SCAN')
		                            and hsi.job_title in(13,110,1199)
		                            and hsi.formal=1
		                    ) pr
		                    where  pr.rnk=1
		            ) pr
		            join dwm.dim_my_sys_store_rd dp on dp.store_id = pr.store_id and dp.stat_date = date_sub(curdate(), interval 1 day) and dp.store_category=1
		            left join my_staging.parcel_info pi on pr.pno = pi.pno
		        left join # 17点前拨打电话次数
		            (
		                select
		                    pr.pno
		                    ,count(pr.call_datetime) as before_17_calltimes
		                from
		                    (
		                        select
		                                pr.pno
		                                ,pr.staff_info_id
		                                ,convert_tz(pr.routed_at,'+00:00','+08:00')  as call_datetime
		                         from my_staging.parcel_route pr
		                         where
		                            pr.routed_at >= date_sub(curdate(), interval 8 hour)
		                            and pr.routed_at < date_add(curdate(), interval 9 hour)
		                            and pr.route_action in ('PHONE')
		                    )pr
		                group by 1
		            )pr2 on pr.pno = pr2.pno
	        )fn
    ),
 handover2 as
    (
        select
            fn.pno
            ,fn.pno_type
            ,fn.store_id
            ,fn.store_name
            ,fn.piece_name
            ,fn.region_name
            ,fn.staff_info_id
            ,fn.staff_name
            ,fn.finished_at
            ,fn.pi_state
			,fn.before_17_calltimes
        from
            (
	            select
		            pr.pno
		            ,pr.store_id
		            ,dp.store_name
		            ,dp.piece_name
		            ,dp.region_name
		            ,pr.staff_info_id
		            ,pi.state pi_state
	                ,convert_tz(pi.updated_at,'+00:00','+08:00') as pi_updated_at
		            ,if(pi.returned=1,'退件','正向件') as pno_type
		            ,convert_tz(pi.finished_at,'+00:00','+08:00') as finished_at
	                ,pr.staff_name
		            ,pr2.before_17_calltimes
		        from
		            ( # 所有17点前交接包裹找到最后一次交接的人
		                select
		                    pr.*
		                from
		                    (
		                        select
		                            pr.pno
		                            ,pr.staff_info_id
		                            ,hsi.name as staff_name
		                            ,pr.store_id
		                            ,row_number() over(partition by pr.pno order by convert_tz(pr.routed_at,'+00:00','+08:00') desc) as rnk
		                        from my_staging.parcel_route pr
		                        left join my_bi.hr_staff_info hsi on pr.staff_info_id=hsi.staff_info_id
		                        left join my_bi.hr_job_title hjt on hjt.id = hsi.job_title
		                        where
		                            pr.routed_at >= date_sub(curdate(), interval 8 hour)
		                            and pr.routed_at < date_add(curdate(), interval 10 hour)
		                            and pr.route_action in ('DELIVERY_TICKET_CREATION_SCAN')
		                            and hsi.job_title in(13,110,1199)
		                            and hsi.formal=1
		                    ) pr
		                    where  pr.rnk=1
		            ) pr
		            join dwm.dim_my_sys_store_rd dp on dp.store_id = pr.store_id and dp.stat_date = date_sub(curdate(), interval 1 day) and dp.store_category=1
		            left join my_staging.parcel_info pi on pr.pno = pi.pno
		        left join # 17点前拨打电话次数
		            (
		                select
		                    pr.pno
		                    ,count(pr.call_datetime) as before_17_calltimes
		                from
		                    (
		                        select
		                                pr.pno
		                                ,pr.staff_info_id
		                                ,convert_tz(pr.routed_at,'+00:00','+08:00')  as call_datetime
		                         from my_staging.parcel_route pr
		                         where
		                            pr.routed_at >= date_sub(curdate(), interval 8 hour)
		                            and pr.routed_at < date_add(curdate(), interval 10 hour)
		                            and pr.route_action in ('PHONE')
		                    )pr
		                group by 1
		            )pr2 on pr.pno = pr2.pno
	        )fn
    )




select
        fn.网点
	    ,fn.大区
	    ,fn.片区
# 	    ,fn.负责人
	    ,fn.员工ID
	    ,fn.快递员姓名
		,fn.交接量_非退件
		,fn.交接包裹妥投量_非退件妥投
	    ,fn.交接包裹妥投量_退件妥投
	    ,fn.交接包裹未拨打电话数 交接包裹未妥投未拨打电话数
		,fn.员工出勤信息
		,fn.18点前快递员结束派件时间
		,fn.妥投率
		,case when fn.未按要求联系客户 is not null and fn.rk<=2 then '是' else null end as 违反A联系客户
		,fn.是否出勤不达标 as 违反B出勤
		,fn.是否低人效 as 违反C人效
    from
    (
        select
		    fk.*
			,row_number() over (partition by fk.网点,fk.未按要求联系客户 order by fk.交接包裹未拨打电话占比 desc) as rk
		    from
		    (
				select
				    f1.网点
				    ,f1.大区
				    ,f1.片区
# 				    ,f1.负责人
				    ,f1.员工ID
				    ,f1.快递员姓名
					,f2.交接量_非退件
					,f2.交接包裹妥投量_非退件妥投
				    ,f2.交接包裹妥投量_退件妥投
				    ,f1.交接包裹未拨打电话数
				    ,case when f5.late_days>=3 and f5.late_times>=300 then '最近一周迟到至少三次且迟到时间至少5小时'
				         when f5.absent_days>=2  then '最近一周缺勤>=2次' else null end as 员工出勤信息
				    ,f6.finished_at as 18点前快递员结束派件时间
				    ,concat(round(f2.交接包裹妥投量_非退件妥投/f2.交接量_非退件*100,2),'%') as 妥投率
				    ,f1.交接包裹未拨打电话占比


				    ,f5.absent_days as 缺勤天数
				    ,f5.late_days as 迟到天数
				    ,f5.late_times as 迟到时长_分钟
					,if(f1.交接包裹未拨打电话数>10 and f1.交接包裹未拨打电话占比>0.2,'未按要求联系客户',null) as 未按要求联系客户
					,case when f5.late_days>=3 and f5.late_times>=300 then '是' when f5.absent_days>=2  then '是' else null end as 是否出勤不达标
					,if(f2.交接包裹妥投量_非退件妥投/f2.交接量_非退件<0.7 and f2.交接包裹妥投量_非退件妥投<70 and hour(f6.finished_at)<15,'是',null) as 是否低人效

				from
					(# 快递员交接包裹后拨打电话情况
					    select
						    fn.region_name as 大区
# 						    ,case
# 							    when fn.region_name in ('Area3', 'Area6') then '彭万松'
# 							    when fn.region_name in ('Area4', 'Area9') then '韩钥'
# 							    when fn.region_name in ('Area7','Area10', 'Area11','FHome','Area14') then '张可新'
# 							    when fn.region_name in ( 'Area8') then '黄勇'
# 							    when fn.region_name in ('Area1', 'Area2','Area5', 'Area12','Area13') then '李俊'
# 								end 负责人
						    ,fn.piece_name as 片区
						    ,fn.store_name as 网点
							,fn.store_id
						    ,fn.staff_info_id as 员工ID
					        ,fn.staff_name as 快递员姓名
					        ,count(distinct case when  fn.before_17_calltimes is null and fn.pi_state not in(5,7,8,9) then fn.pno else null end) as 交接包裹未拨打电话数
					        ,count(distinct case when  fn.before_17_calltimes is null and fn.pi_state not in(5,7,8,9) then fn.pno else null end)/count(distinct fn.pno) as 交接包裹未拨打电话占比
					    from  handover fn
					    group by 1,2,3,4,5,6
					)f1
				left join
					    (
						    select
							    fn.staff_info_id as 员工ID
						        ,fn.staff_name as 快递员姓名
						        ,count(distinct if(fn.pno_type='正向件', fn.pno ,null)) as 交接量_非退件
							    ,count(distinct if(fn.pi_state = 5 and fn.pno_type='正向件' ,fn.pno ,null)) 交接包裹妥投量_非退件妥投
							    ,count(distinct if(fn.pi_state = 5 and fn.pno_type='退件' ,fn.pno ,null)) 交接包裹妥投量_退件妥投
						    from  handover2 fn
						    group by 1,2
					    )f2 on f2.员工ID = f1.员工ID
				left join
					( -- 最近一周出勤
					    select
					        ad.staff_info_id
					        ,sum(case
						        when ad.leave_type is not null and ad.leave_time_type=1 then 0.5
						        when ad.leave_type is not null and ad.leave_time_type=2 then 0.5
						        when ad.leave_type is not null and ad.leave_time_type=3 then 1
						        else 0  end) as leave_num
					        ,count(distinct if(ad.attendance_time = 0, ad.stat_date, null)) absent_days
					        ,count(distinct if(ad.attendance_started_at > date_add(concat(ad.stat_date, ' ', ad.shift_start), interval 1 minute), ad.stat_date, null)) late_days
					        ,sum(if(ad.attendance_started_at > date_add(concat(ad.stat_date, ' ', ad.shift_start), interval 1 minute), timestampdiff(minute , concat(ad.stat_date, ' ', ad.shift_start), ad.attendance_started_at), 0)) late_times
					    from my_bi.attendance_data_v2 ad
					    where ad.attendance_time + ad.BT+ ad.BT_Y + ad.AB >0
					        and ad.stat_date>date_sub(current_date,interval 8 day)
					        and ad.stat_date<=date_sub(current_date,interval 1 day)
					    group by 1
					) f5 on f5.staff_info_id = f1.员工ID
				left join
					( -- 18点前最后一个妥投包裹时间
				        select
				             ha.ticket_delivery_staff_info_id
					        ,ha.finished_at
				        from
				        (
				            select
				                pi.ticket_delivery_staff_info_id
				                ,convert_tz(pi.finished_at,'+00:00','+08:00') as finished_at
				                ,row_number() over (partition by pi.ticket_delivery_staff_info_id order by pi.finished_at desc) as rk
					        from my_staging.parcel_info pi
					        where pi.state=5
					        and pi.finished_at>= date_sub(curdate(), interval 8 hour)
						    and pi.finished_at< date_add(curdate(), interval 10 hour)
				        )ha
				        where ha.rk=1
					) f6 on f6.ticket_delivery_staff_info_id = f1.员工ID
		    )fk
    )fn;
;-- -. . -..- - / . -. - .-. -.--
select
            am.staff_info_id
            ,'投诉' type
            ,count(distinct if(acc.complaints_type = 2, acc.id, null)) 揽件虚假量
            ,count(distinct if(acc.complaints_type = 1, acc.id, null)) 妥投虚假量
            ,count(distinct if(acc.complaints_type = 3, acc.id, null)) 派件标记虚假量
        from my_bi.abnormal_customer_complaint acc
        left join my_bi.abnormal_message am on am.id = acc.abnormal_message_id
        where
            acc.state = 1
            and acc.updated_at >= date_sub(date_sub(curdate(), interval 1 day), interval 8 hour)
            and acc.updated_at < date_add(date_sub(curdate(), interval 1 day), interval 16 hour) -- 昨天
            and acc.complaints_type in (1,2,3)
            and acc.qaqc_callback_result in (3,4,5,6)
        group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
     case
        when a.del_rate < 0.4 then '<40%'
        when a.del_rate >= 0.4 and a.del_rate < 0.5 then '40%-50%'
        when a.del_rate >= 0.5 and a.del_rate < 0.6 then '50%-60%'
        when a.del_rate >= 0.6 and a.del_rate < 0.7 then '60%-70%'
        when a.del_rate >= 0.7 and a.del_rate < 0.8 then '70%-80%'
        when a.del_rate >= 0.8 and a.del_rate <= 1 then '80%-100%'
    end 妥投率
    ,count(distinct a.网点ID) 总数
    ,count(distinct if(a.一派有效分拣评级 = 'A', a.网点ID, null))/count(distinct a.网点ID) 评级A
    ,count(distinct if(a.一派有效分拣评级 = 'B', a.网点ID, null))/count(distinct a.网点ID) 评级B
    ,count(distinct if(a.一派有效分拣评级 = 'C', a.网点ID, null))/count(distinct a.网点ID) 评级C
    ,count(distinct if(a.一派有效分拣评级 = 'D', a.网点ID, null))/count(distinct a.网点ID) 评级D
    ,count(distinct if(a.一派有效分拣评级 = 'E', a.网点ID, null))/count(distinct a.网点ID) 评级E
    ,count(distinct if(a.一派有效分拣评级 = 'A', a.网点ID, null)) 评级A数量
    ,count(distinct if(a.一派有效分拣评级 = 'B', a.网点ID, null)) 评级B数量
    ,count(distinct if(a.一派有效分拣评级 = 'C', a.网点ID, null)) 评级C数量
    ,count(distinct if(a.一派有效分拣评级 = 'D', a.网点ID, null)) 评级D数量
    ,count(distinct if(a.一派有效分拣评级 = 'E', a.网点ID, null)) 评级E数量
from
    (
                select -- 基于当日应派取扫描率
            tt.store_id 网点ID
            ,tt.store_name 网点名称
            ,'一派网点' as  网点分类
            ,tt.piece_name 片区
            ,tt.region_name 大区
            ,tt.shoud_counts 应派数
            ,tt.scan_fished_counts 分拣扫描数
            ,ifnull(tt.scan_fished_counts/shoud_counts,0) 分拣扫描率

            ,tt.youxiao_counts 有效分拣扫描数
            ,ifnull(tt.youxiao_counts/tt.scan_fished_counts,0) 有效分拣扫描率

            ,tt.1pai_counts 一派应派数
            ,tt.1pai_scan_fished_counts 一派分拣扫描数
            ,ifnull(tt.1pai_scan_fished_counts/tt.1pai_counts,0) 一派分拣扫描率

            ,tt.1pai_youxiao_counts 一派有效分拣扫描数
            ,ifnull(tt.1pai_youxiao_counts/tt.1pai_scan_fished_counts,0) 一派有效分拣扫描率
            ,
            case
                when tt.1pai_youxiao_counts/tt.1pai_scan_fished_counts>=0.95 then 'A'
                when tt.1pai_youxiao_counts/tt.1pai_scan_fished_counts>=0.90 then 'B'
                when tt.1pai_youxiao_counts/tt.1pai_scan_fished_counts>=0.85 then 'C'
                when tt.1pai_youxiao_counts/tt.1pai_scan_fished_counts>=0.80 then 'D'
                else 'E'
             end 一派有效分拣评级 -- 一派有效分拣

             ,case
                when tt.1pai_hour_8_fished_counts/tt.1pai_counts>=0.95  then 'A'
                when tt.1pai_hour_8ban_fished_counts/tt.1pai_counts>=0.95  then 'B'
                when tt.1pai_hour_9_fished_counts/tt.1pai_counts>=0.95  then 'C'
                when tt.1pai_hour_9ban_fished_counts/tt.1pai_counts>=0.95  then 'D'
                else 'E'
               end 一派分拣评级

            ,ifnull(tt.1pai_hour_8_fished_counts/tt.1pai_counts,0) 一派8点前扫描占比
            ,ifnull(tt.1pai_hour_8ban_fished_counts/tt.1pai_counts,0) 一派8点半前扫描占比
            ,ifnull(tt.1pai_hour_9_fished_counts/tt.1pai_counts,0) 一派9点前扫描占比
            ,ifnull(tt.1pai_hour_9ban_fished_counts/tt.1pai_counts,0) 一派9点半前扫描占比

            ,tt2.max_real_arrive_time_normal 一派前常规车最晚实际到达时间
            ,tt2.max_real_arrive_proof_id 一派前常规车最晚实际到达车线
            ,tt2.max_real_arrive_vol 一派前常规车最晚实际到达车线包裹量
            ,tt2.line_1_latest_plan_arrive_time 一派前常规车最晚规划到达时间
            ,tt2.max_real_arrive_time_innormal 一派前加班车最晚实际到达时间
            ,tt2.max_real_arrive_innormal_proof_id 一派前加班车最晚实际到达车线
            ,tt2.max_real_arrive_innormal_vol 一派前加班车最晚实际到达车线包裹量
            ,tt2.max_actual_plan_arrive_time_innormal 一派前加班车最晚规划到达时间
            ,tt2.late_proof_counts 一派常规车线实际比计划时间晚20分钟车辆数
            ,del.del_rate
            ,del.del_pno_num
            ,del.pno_num
        from
            (
                select
                   base.store_id
                   ,base.store_name
                   ,base.store_type
                   ,base.piece_name
                   ,base.region_name
                   ,count(distinct base.pno) shoud_counts
                   ,count(distinct case when base.min_fenjian_scan_time is not null then base.pno else null end ) scan_fished_counts
                   ,count(distinct case when base.min_fenjian_scan_time is not null and base.min_fenjian_scan_time<tiaozheng_scan_deadline_time then base.pno else null end ) youxiao_counts

                   ,count(distinct case when base.type='一派' then  base.pno else null end ) 1pai_counts
                   ,count(distinct case when base.type='一派' and base.min_fenjian_scan_time is not null then  base.pno else null end ) 1pai_scan_fished_counts
                   ,count(distinct case when base.type='一派' and base.min_fenjian_scan_time is not null and base.min_fenjian_scan_time<tiaozheng_scan_deadline_time then  base.pno else null end ) 1pai_youxiao_counts

                   ,count(distinct case when base.type='一派' and date_format(base.min_fenjian_scan_time,'%H:%i:%s')<='08:00:00' then base.pno else null end) 1pai_hour_8_fished_counts
                   ,count(distinct case when base.type='一派' and date_format(base.min_fenjian_scan_time,'%H:%i:%s')<='08:30:00' then base.pno else null end) 1pai_hour_8ban_fished_counts
                   ,count(distinct case when base.type='一派' and date_format(base.min_fenjian_scan_time,'%H:%i:%s')<='09:00:00' then base.pno else null end) 1pai_hour_9_fished_counts
                   ,count(distinct case when base.type='一派' and date_format(base.min_fenjian_scan_time,'%H:%i:%s')<='09:30:00' then base.pno else null end) 1pai_hour_9ban_fished_counts

                from
                (
                   select
                   t.*,
                   case when t.should_delevry_type='1派应派包裹' then '一派' else null end 'type'
                   from dwm.dwd_my_dc_should_be_delivery_sort_scan t
                   join my_staging.sys_store ss
                   on t.store_id =ss.id and ss.category in (1,10)

                ) base
                group by base.store_id,base.store_name,base.store_type,base.piece_name,base.region_name
            ) tt
        left join
            (
                select
                   bl.store_id
                   ,bl.max_real_arrive_time_normal
                   ,bl.max_real_arrive_proof_id
                   ,bl.max_real_arrive_vol
                   ,bl.line_1_latest_plan_arrive_time
                   ,bl.max_actual_plan_arrive_time_innormal
                   ,bl.max_actual_plan_arrive_innormal_proof_id
                   ,bl.max_actual_plan_arrive_innormal_vol
                   ,bl.max_real_arrive_time_innormal
                   ,bl.max_real_arrive_innormal_proof_id
                   ,bl.max_real_arrive_innormal_vol
                   ,late_proof_counts
                from dwm.fleet_real_detail_today bl
                group by 1,2,3,4,5,6,7,8,9,10,11
            ) tt2 on tt.store_id=tt2.store_id
        left join
            (
                select
                    ds.dst_store_id
                    ,count(distinct ds.pno) pno_num
                    ,count(if(pi.pno is not null, ds.pno, null)) del_pno_num
                    ,count(if(pi.pno is not null, ds.pno, null))/count(distinct ds.pno) del_rate
                from dwm.dwd_my_dc_should_be_delivery ds
                left join my_staging.parcel_info pi on pi.pno = ds.pno and pi.state = 5 and pi.finished_at >= date_sub('2023-09-17', interval 8 hour ) and pi.finished_at < date_add('2023-09-17', interval 16 hour)
                where
                    ds.p_date = '2023-09-17'
                    and ds.should_delevry_type != '非当日应派'
                group by 1
            ) del on del.dst_store_id = tt.store_id
    ) a
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    case
        when a.一派9点半前扫描占比 < 0.4 then '<40%'
        when a.一派9点半前扫描占比 >= 0.4 and a.一派9点半前扫描占比 < 0.5 then '40%-50%'
        when a.一派9点半前扫描占比 >= 0.5 and a.一派9点半前扫描占比 < 0.6 then '50%-60%'
        when a.一派9点半前扫描占比 >= 0.6 and a.一派9点半前扫描占比 < 0.7 then '60%-70%'
        when a.一派9点半前扫描占比 >= 0.7 and a.一派9点半前扫描占比 < 0.8 then '70%-80%'
        when a.一派9点半前扫描占比 >= 0.8 and a.一派9点半前扫描占比 < 0.9 then '80%-90%'
        when a.一派9点半前扫描占比 >= 0.9 and a.一派9点半前扫描占比 <= 1 then '90%-100%'
#         else a.一派9点半前扫描占比
    end 0930前分拣扫描占比
    ,count(distinct a.网点ID) 总数
    ,sum(a.del_pno_num)/sum(a.pno_num) 妥投率
from
    (
                select -- 基于当日应派取扫描率
            tt.store_id 网点ID
            ,tt.store_name 网点名称
            ,'一派网点' as  网点分类
            ,tt.piece_name 片区
            ,tt.region_name 大区
            ,tt.shoud_counts 应派数
            ,tt.scan_fished_counts 分拣扫描数
            ,ifnull(tt.scan_fished_counts/shoud_counts,0) 分拣扫描率

            ,tt.youxiao_counts 有效分拣扫描数
            ,ifnull(tt.youxiao_counts/tt.scan_fished_counts,0) 有效分拣扫描率

            ,tt.1pai_counts 一派应派数
            ,tt.1pai_scan_fished_counts 一派分拣扫描数
            ,ifnull(tt.1pai_scan_fished_counts/tt.1pai_counts,0) 一派分拣扫描率

            ,tt.1pai_youxiao_counts 一派有效分拣扫描数
            ,ifnull(tt.1pai_youxiao_counts/tt.1pai_scan_fished_counts,0) 一派有效分拣扫描率
            ,
            case
                when tt.1pai_youxiao_counts/tt.1pai_scan_fished_counts>=0.95 then 'A'
                when tt.1pai_youxiao_counts/tt.1pai_scan_fished_counts>=0.90 then 'B'
                when tt.1pai_youxiao_counts/tt.1pai_scan_fished_counts>=0.85 then 'C'
                when tt.1pai_youxiao_counts/tt.1pai_scan_fished_counts>=0.80 then 'D'
                else 'E'
             end 一派有效分拣评级 -- 一派有效分拣

             ,case
                when tt.1pai_hour_8_fished_counts/tt.1pai_counts>=0.95  then 'A'
                when tt.1pai_hour_8ban_fished_counts/tt.1pai_counts>=0.95  then 'B'
                when tt.1pai_hour_9_fished_counts/tt.1pai_counts>=0.95  then 'C'
                when tt.1pai_hour_9ban_fished_counts/tt.1pai_counts>=0.95  then 'D'
                else 'E'
               end 一派分拣评级

            ,ifnull(tt.1pai_hour_8_fished_counts/tt.1pai_counts,0) 一派8点前扫描占比
            ,ifnull(tt.1pai_hour_8ban_fished_counts/tt.1pai_counts,0) 一派8点半前扫描占比
            ,ifnull(tt.1pai_hour_9_fished_counts/tt.1pai_counts,0) 一派9点前扫描占比
            ,ifnull(tt.1pai_hour_9ban_fished_counts/tt.1pai_counts,0) 一派9点半前扫描占比

            ,tt2.max_real_arrive_time_normal 一派前常规车最晚实际到达时间
            ,tt2.max_real_arrive_proof_id 一派前常规车最晚实际到达车线
            ,tt2.max_real_arrive_vol 一派前常规车最晚实际到达车线包裹量
            ,tt2.line_1_latest_plan_arrive_time 一派前常规车最晚规划到达时间
            ,tt2.max_real_arrive_time_innormal 一派前加班车最晚实际到达时间
            ,tt2.max_real_arrive_innormal_proof_id 一派前加班车最晚实际到达车线
            ,tt2.max_real_arrive_innormal_vol 一派前加班车最晚实际到达车线包裹量
            ,tt2.max_actual_plan_arrive_time_innormal 一派前加班车最晚规划到达时间
            ,tt2.late_proof_counts 一派常规车线实际比计划时间晚20分钟车辆数
            ,del.del_rate
            ,del.del_pno_num
            ,del.pno_num
        from
            (
                select
                   base.store_id
                   ,base.store_name
                   ,base.store_type
                   ,base.piece_name
                   ,base.region_name
                   ,count(distinct base.pno) shoud_counts
                   ,count(distinct case when base.min_fenjian_scan_time is not null then base.pno else null end ) scan_fished_counts
                   ,count(distinct case when base.min_fenjian_scan_time is not null and base.min_fenjian_scan_time<tiaozheng_scan_deadline_time then base.pno else null end ) youxiao_counts

                   ,count(distinct case when base.type='一派' then  base.pno else null end ) 1pai_counts
                   ,count(distinct case when base.type='一派' and base.min_fenjian_scan_time is not null then  base.pno else null end ) 1pai_scan_fished_counts
                   ,count(distinct case when base.type='一派' and base.min_fenjian_scan_time is not null and base.min_fenjian_scan_time<tiaozheng_scan_deadline_time then  base.pno else null end ) 1pai_youxiao_counts

                   ,count(distinct case when base.type='一派' and date_format(base.min_fenjian_scan_time,'%H:%i:%s')<='08:00:00' then base.pno else null end) 1pai_hour_8_fished_counts
                   ,count(distinct case when base.type='一派' and date_format(base.min_fenjian_scan_time,'%H:%i:%s')<='08:30:00' then base.pno else null end) 1pai_hour_8ban_fished_counts
                   ,count(distinct case when base.type='一派' and date_format(base.min_fenjian_scan_time,'%H:%i:%s')<='09:00:00' then base.pno else null end) 1pai_hour_9_fished_counts
                   ,count(distinct case when base.type='一派' and date_format(base.min_fenjian_scan_time,'%H:%i:%s')<='09:30:00' then base.pno else null end) 1pai_hour_9ban_fished_counts

                from
                (
                   select
                   t.*,
                   case when t.should_delevry_type='1派应派包裹' then '一派' else null end 'type'
                   from dwm.dwd_my_dc_should_be_delivery_sort_scan t
                   join my_staging.sys_store ss
                   on t.store_id =ss.id and ss.category in (1,10)

                ) base
                group by base.store_id,base.store_name,base.store_type,base.piece_name,base.region_name
            ) tt
        left join
            (
                select
                   bl.store_id
                   ,bl.max_real_arrive_time_normal
                   ,bl.max_real_arrive_proof_id
                   ,bl.max_real_arrive_vol
                   ,bl.line_1_latest_plan_arrive_time
                   ,bl.max_actual_plan_arrive_time_innormal
                   ,bl.max_actual_plan_arrive_innormal_proof_id
                   ,bl.max_actual_plan_arrive_innormal_vol
                   ,bl.max_real_arrive_time_innormal
                   ,bl.max_real_arrive_innormal_proof_id
                   ,bl.max_real_arrive_innormal_vol
                   ,late_proof_counts
                from dwm.fleet_real_detail_today bl
                group by 1,2,3,4,5,6,7,8,9,10,11
            ) tt2 on tt.store_id=tt2.store_id
        left join
            (
                select
                    ds.dst_store_id
                    ,count(distinct ds.pno) pno_num
                    ,count(if(pi.pno is not null, ds.pno, null)) del_pno_num
                    ,count(if(pi.pno is not null, ds.pno, null))/count(distinct ds.pno) del_rate
                from dwm.dwd_my_dc_should_be_delivery ds
                left join my_staging.parcel_info pi on pi.pno = ds.pno and pi.state = 5 and pi.finished_at >= date_sub('2023-09-17', interval 8 hour ) and pi.finished_at < date_add('2023-09-17', interval 16 hour)
                where
                    ds.p_date = '2023-09-17'
                    and ds.should_delevry_type != '非当日应派'
                group by 1
            ) del on del.dst_store_id = tt.store_id
    ) a
group by 1;
;-- -. . -..- - / . -. - .-. -.--
(
                select -- 基于当日应派取扫描率
            tt.store_id 网点ID
            ,tt.store_name 网点名称
            ,'一派网点' as  网点分类
            ,tt.piece_name 片区
            ,tt.region_name 大区
            ,tt.shoud_counts 应派数
            ,tt.scan_fished_counts 分拣扫描数
            ,ifnull(tt.scan_fished_counts/shoud_counts,0) 分拣扫描率

            ,tt.youxiao_counts 有效分拣扫描数
            ,ifnull(tt.youxiao_counts/tt.scan_fished_counts,0) 有效分拣扫描率

            ,tt.1pai_counts 一派应派数
            ,tt.1pai_scan_fished_counts 一派分拣扫描数
            ,ifnull(tt.1pai_scan_fished_counts/tt.1pai_counts,0) 一派分拣扫描率

            ,tt.1pai_youxiao_counts 一派有效分拣扫描数
            ,ifnull(tt.1pai_youxiao_counts/tt.1pai_scan_fished_counts,0) 一派有效分拣扫描率
            ,
            case
                when tt.1pai_youxiao_counts/tt.1pai_scan_fished_counts>=0.95 then 'A'
                when tt.1pai_youxiao_counts/tt.1pai_scan_fished_counts>=0.90 then 'B'
                when tt.1pai_youxiao_counts/tt.1pai_scan_fished_counts>=0.85 then 'C'
                when tt.1pai_youxiao_counts/tt.1pai_scan_fished_counts>=0.80 then 'D'
                else 'E'
             end 一派有效分拣评级 -- 一派有效分拣

             ,case
                when tt.1pai_hour_8_fished_counts/tt.1pai_counts>=0.95  then 'A'
                when tt.1pai_hour_8ban_fished_counts/tt.1pai_counts>=0.95  then 'B'
                when tt.1pai_hour_9_fished_counts/tt.1pai_counts>=0.95  then 'C'
                when tt.1pai_hour_9ban_fished_counts/tt.1pai_counts>=0.95  then 'D'
                else 'E'
               end 一派分拣评级

            ,ifnull(tt.1pai_hour_8_fished_counts/tt.1pai_counts,0) 一派8点前扫描占比
            ,ifnull(tt.1pai_hour_8ban_fished_counts/tt.1pai_counts,0) 一派8点半前扫描占比
            ,ifnull(tt.1pai_hour_9_fished_counts/tt.1pai_counts,0) 一派9点前扫描占比
            ,ifnull(tt.1pai_hour_9ban_fished_counts/tt.1pai_counts,0) 一派9点半前扫描占比

            ,tt2.max_real_arrive_time_normal 一派前常规车最晚实际到达时间
            ,tt2.max_real_arrive_proof_id 一派前常规车最晚实际到达车线
            ,tt2.max_real_arrive_vol 一派前常规车最晚实际到达车线包裹量
            ,tt2.line_1_latest_plan_arrive_time 一派前常规车最晚规划到达时间
            ,tt2.max_real_arrive_time_innormal 一派前加班车最晚实际到达时间
            ,tt2.max_real_arrive_innormal_proof_id 一派前加班车最晚实际到达车线
            ,tt2.max_real_arrive_innormal_vol 一派前加班车最晚实际到达车线包裹量
            ,tt2.max_actual_plan_arrive_time_innormal 一派前加班车最晚规划到达时间
            ,tt2.late_proof_counts 一派常规车线实际比计划时间晚20分钟车辆数
            ,del.del_rate
            ,del.del_pno_num
            ,del.pno_num
        from
            (
                select
                   base.store_id
                   ,base.store_name
                   ,base.store_type
                   ,base.piece_name
                   ,base.region_name
                   ,count(distinct base.pno) shoud_counts
                   ,count(distinct case when base.min_fenjian_scan_time is not null then base.pno else null end ) scan_fished_counts
                   ,count(distinct case when base.min_fenjian_scan_time is not null and base.min_fenjian_scan_time<tiaozheng_scan_deadline_time then base.pno else null end ) youxiao_counts

                   ,count(distinct case when base.type='一派' then  base.pno else null end ) 1pai_counts
                   ,count(distinct case when base.type='一派' and base.min_fenjian_scan_time is not null then  base.pno else null end ) 1pai_scan_fished_counts
                   ,count(distinct case when base.type='一派' and base.min_fenjian_scan_time is not null and base.min_fenjian_scan_time<tiaozheng_scan_deadline_time then  base.pno else null end ) 1pai_youxiao_counts

                   ,count(distinct case when base.type='一派' and date_format(base.min_fenjian_scan_time,'%H:%i:%s')<='08:00:00' then base.pno else null end) 1pai_hour_8_fished_counts
                   ,count(distinct case when base.type='一派' and date_format(base.min_fenjian_scan_time,'%H:%i:%s')<='08:30:00' then base.pno else null end) 1pai_hour_8ban_fished_counts
                   ,count(distinct case when base.type='一派' and date_format(base.min_fenjian_scan_time,'%H:%i:%s')<='09:00:00' then base.pno else null end) 1pai_hour_9_fished_counts
                   ,count(distinct case when base.type='一派' and date_format(base.min_fenjian_scan_time,'%H:%i:%s')<='09:30:00' then base.pno else null end) 1pai_hour_9ban_fished_counts

                from
                (
                   select
                   t.*,
                   case when t.should_delevry_type='1派应派包裹' then '一派' else null end 'type'
                   from dwm.dwd_my_dc_should_be_delivery_sort_scan t
                   join my_staging.sys_store ss
                   on t.store_id =ss.id and ss.category in (1,10)

                ) base
                group by base.store_id,base.store_name,base.store_type,base.piece_name,base.region_name
            ) tt
        left join
            (
                select
                   bl.store_id
                   ,bl.max_real_arrive_time_normal
                   ,bl.max_real_arrive_proof_id
                   ,bl.max_real_arrive_vol
                   ,bl.line_1_latest_plan_arrive_time
                   ,bl.max_actual_plan_arrive_time_innormal
                   ,bl.max_actual_plan_arrive_innormal_proof_id
                   ,bl.max_actual_plan_arrive_innormal_vol
                   ,bl.max_real_arrive_time_innormal
                   ,bl.max_real_arrive_innormal_proof_id
                   ,bl.max_real_arrive_innormal_vol
                   ,late_proof_counts
                from dwm.fleet_real_detail_today bl
                group by 1,2,3,4,5,6,7,8,9,10,11
            ) tt2 on tt.store_id=tt2.store_id
        left join
            (
                select
                    ds.dst_store_id
                    ,count(distinct ds.pno) pno_num
                    ,count(if(pi.pno is not null, ds.pno, null)) del_pno_num
                    ,count(if(pi.pno is not null, ds.pno, null))/count(distinct ds.pno) del_rate
                from dwm.dwd_my_dc_should_be_delivery ds
                left join my_staging.parcel_info pi on pi.pno = ds.pno and pi.state = 5 and pi.finished_at >= date_sub('2023-09-17', interval 8 hour ) and pi.finished_at < date_add('2023-09-17', interval 16 hour)
                where
                    ds.p_date = '2023-09-17'
                    and ds.should_delevry_type != '非当日应派'
                group by 1
            ) del on del.dst_store_id = tt.store_id
    ) a
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    a.大区
    ,count(distinct a.网点ID) 总网点数
    ,count(distinct if(a.一派9点半前扫描占比 < 0.8, a.网点ID, null)) 问题网点数
    ,count(distinct if(a.一派9点半前扫描占比 < 0.8, a.网点ID, null))/count(distinct a.网点ID)  问题比例
from
    (
                select -- 基于当日应派取扫描率
            tt.store_id 网点ID
            ,tt.store_name 网点名称
            ,'一派网点' as  网点分类
            ,tt.piece_name 片区
            ,tt.region_name 大区
            ,tt.shoud_counts 应派数
            ,tt.scan_fished_counts 分拣扫描数
            ,ifnull(tt.scan_fished_counts/shoud_counts,0) 分拣扫描率

            ,tt.youxiao_counts 有效分拣扫描数
            ,ifnull(tt.youxiao_counts/tt.scan_fished_counts,0) 有效分拣扫描率

            ,tt.1pai_counts 一派应派数
            ,tt.1pai_scan_fished_counts 一派分拣扫描数
            ,ifnull(tt.1pai_scan_fished_counts/tt.1pai_counts,0) 一派分拣扫描率

            ,tt.1pai_youxiao_counts 一派有效分拣扫描数
            ,ifnull(tt.1pai_youxiao_counts/tt.1pai_scan_fished_counts,0) 一派有效分拣扫描率
            ,
            case
                when tt.1pai_youxiao_counts/tt.1pai_scan_fished_counts>=0.95 then 'A'
                when tt.1pai_youxiao_counts/tt.1pai_scan_fished_counts>=0.90 then 'B'
                when tt.1pai_youxiao_counts/tt.1pai_scan_fished_counts>=0.85 then 'C'
                when tt.1pai_youxiao_counts/tt.1pai_scan_fished_counts>=0.80 then 'D'
                else 'E'
             end 一派有效分拣评级 -- 一派有效分拣

             ,case
                when tt.1pai_hour_8_fished_counts/tt.1pai_counts>=0.95  then 'A'
                when tt.1pai_hour_8ban_fished_counts/tt.1pai_counts>=0.95  then 'B'
                when tt.1pai_hour_9_fished_counts/tt.1pai_counts>=0.95  then 'C'
                when tt.1pai_hour_9ban_fished_counts/tt.1pai_counts>=0.95  then 'D'
                else 'E'
               end 一派分拣评级

            ,ifnull(tt.1pai_hour_8_fished_counts/tt.1pai_counts,0) 一派8点前扫描占比
            ,ifnull(tt.1pai_hour_8ban_fished_counts/tt.1pai_counts,0) 一派8点半前扫描占比
            ,ifnull(tt.1pai_hour_9_fished_counts/tt.1pai_counts,0) 一派9点前扫描占比
            ,ifnull(tt.1pai_hour_9ban_fished_counts/tt.1pai_counts,0) 一派9点半前扫描占比

            ,tt2.max_real_arrive_time_normal 一派前常规车最晚实际到达时间
            ,tt2.max_real_arrive_proof_id 一派前常规车最晚实际到达车线
            ,tt2.max_real_arrive_vol 一派前常规车最晚实际到达车线包裹量
            ,tt2.line_1_latest_plan_arrive_time 一派前常规车最晚规划到达时间
            ,tt2.max_real_arrive_time_innormal 一派前加班车最晚实际到达时间
            ,tt2.max_real_arrive_innormal_proof_id 一派前加班车最晚实际到达车线
            ,tt2.max_real_arrive_innormal_vol 一派前加班车最晚实际到达车线包裹量
            ,tt2.max_actual_plan_arrive_time_innormal 一派前加班车最晚规划到达时间
            ,tt2.late_proof_counts 一派常规车线实际比计划时间晚20分钟车辆数
            ,del.del_rate
            ,del.del_pno_num
            ,del.pno_num
        from
            (
                select
                   base.store_id
                   ,base.store_name
                   ,base.store_type
                   ,base.piece_name
                   ,base.region_name
                   ,count(distinct base.pno) shoud_counts
                   ,count(distinct case when base.min_fenjian_scan_time is not null then base.pno else null end ) scan_fished_counts
                   ,count(distinct case when base.min_fenjian_scan_time is not null and base.min_fenjian_scan_time<tiaozheng_scan_deadline_time then base.pno else null end ) youxiao_counts

                   ,count(distinct case when base.type='一派' then  base.pno else null end ) 1pai_counts
                   ,count(distinct case when base.type='一派' and base.min_fenjian_scan_time is not null then  base.pno else null end ) 1pai_scan_fished_counts
                   ,count(distinct case when base.type='一派' and base.min_fenjian_scan_time is not null and base.min_fenjian_scan_time<tiaozheng_scan_deadline_time then  base.pno else null end ) 1pai_youxiao_counts

                   ,count(distinct case when base.type='一派' and date_format(base.min_fenjian_scan_time,'%H:%i:%s')<='08:00:00' then base.pno else null end) 1pai_hour_8_fished_counts
                   ,count(distinct case when base.type='一派' and date_format(base.min_fenjian_scan_time,'%H:%i:%s')<='08:30:00' then base.pno else null end) 1pai_hour_8ban_fished_counts
                   ,count(distinct case when base.type='一派' and date_format(base.min_fenjian_scan_time,'%H:%i:%s')<='09:00:00' then base.pno else null end) 1pai_hour_9_fished_counts
                   ,count(distinct case when base.type='一派' and date_format(base.min_fenjian_scan_time,'%H:%i:%s')<='09:30:00' then base.pno else null end) 1pai_hour_9ban_fished_counts

                from
                (
                   select
                   t.*,
                   case when t.should_delevry_type='1派应派包裹' then '一派' else null end 'type'
                   from dwm.dwd_my_dc_should_be_delivery_sort_scan t
                   join my_staging.sys_store ss
                   on t.store_id =ss.id and ss.category in (1,10)

                ) base
                group by base.store_id,base.store_name,base.store_type,base.piece_name,base.region_name
            ) tt
        left join
            (
                select
                   bl.store_id
                   ,bl.max_real_arrive_time_normal
                   ,bl.max_real_arrive_proof_id
                   ,bl.max_real_arrive_vol
                   ,bl.line_1_latest_plan_arrive_time
                   ,bl.max_actual_plan_arrive_time_innormal
                   ,bl.max_actual_plan_arrive_innormal_proof_id
                   ,bl.max_actual_plan_arrive_innormal_vol
                   ,bl.max_real_arrive_time_innormal
                   ,bl.max_real_arrive_innormal_proof_id
                   ,bl.max_real_arrive_innormal_vol
                   ,late_proof_counts
                from dwm.fleet_real_detail_today bl
                group by 1,2,3,4,5,6,7,8,9,10,11
            ) tt2 on tt.store_id=tt2.store_id
        left join
            (
                select
                    ds.dst_store_id
                    ,count(distinct ds.pno) pno_num
                    ,count(if(pi.pno is not null, ds.pno, null)) del_pno_num
                    ,count(if(pi.pno is not null, ds.pno, null))/count(distinct ds.pno) del_rate
                from dwm.dwd_my_dc_should_be_delivery ds
                left join my_staging.parcel_info pi on pi.pno = ds.pno and pi.state = 5 and pi.finished_at >= date_sub('2023-09-17', interval 8 hour ) and pi.finished_at < date_add('2023-09-17', interval 16 hour)
                where
                    ds.p_date = '2023-09-17'
                    and ds.should_delevry_type != '非当日应派'
                group by 1
            ) del on del.dst_store_id = tt.store_id
    ) a
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    a.大区
    ,count(distinct a.网点ID) 总网点数
    ,count(distinct if(a.一派有效分拣评级 = 'E', a.网点ID, null)) 问题网点数
    ,count(distinct if(a.一派有效分拣评级 = 'E', a.网点ID, null))/count(distinct a.网点ID)  问题比例
from
    (
                select -- 基于当日应派取扫描率
            tt.store_id 网点ID
            ,tt.store_name 网点名称
            ,'一派网点' as  网点分类
            ,tt.piece_name 片区
            ,tt.region_name 大区
            ,tt.shoud_counts 应派数
            ,tt.scan_fished_counts 分拣扫描数
            ,ifnull(tt.scan_fished_counts/shoud_counts,0) 分拣扫描率

            ,tt.youxiao_counts 有效分拣扫描数
            ,ifnull(tt.youxiao_counts/tt.scan_fished_counts,0) 有效分拣扫描率

            ,tt.1pai_counts 一派应派数
            ,tt.1pai_scan_fished_counts 一派分拣扫描数
            ,ifnull(tt.1pai_scan_fished_counts/tt.1pai_counts,0) 一派分拣扫描率

            ,tt.1pai_youxiao_counts 一派有效分拣扫描数
            ,ifnull(tt.1pai_youxiao_counts/tt.1pai_scan_fished_counts,0) 一派有效分拣扫描率
            ,
            case
                when tt.1pai_youxiao_counts/tt.1pai_scan_fished_counts>=0.95 then 'A'
                when tt.1pai_youxiao_counts/tt.1pai_scan_fished_counts>=0.90 then 'B'
                when tt.1pai_youxiao_counts/tt.1pai_scan_fished_counts>=0.85 then 'C'
                when tt.1pai_youxiao_counts/tt.1pai_scan_fished_counts>=0.80 then 'D'
                else 'E'
             end 一派有效分拣评级 -- 一派有效分拣

             ,case
                when tt.1pai_hour_8_fished_counts/tt.1pai_counts>=0.95  then 'A'
                when tt.1pai_hour_8ban_fished_counts/tt.1pai_counts>=0.95  then 'B'
                when tt.1pai_hour_9_fished_counts/tt.1pai_counts>=0.95  then 'C'
                when tt.1pai_hour_9ban_fished_counts/tt.1pai_counts>=0.95  then 'D'
                else 'E'
               end 一派分拣评级

            ,ifnull(tt.1pai_hour_8_fished_counts/tt.1pai_counts,0) 一派8点前扫描占比
            ,ifnull(tt.1pai_hour_8ban_fished_counts/tt.1pai_counts,0) 一派8点半前扫描占比
            ,ifnull(tt.1pai_hour_9_fished_counts/tt.1pai_counts,0) 一派9点前扫描占比
            ,ifnull(tt.1pai_hour_9ban_fished_counts/tt.1pai_counts,0) 一派9点半前扫描占比

            ,tt2.max_real_arrive_time_normal 一派前常规车最晚实际到达时间
            ,tt2.max_real_arrive_proof_id 一派前常规车最晚实际到达车线
            ,tt2.max_real_arrive_vol 一派前常规车最晚实际到达车线包裹量
            ,tt2.line_1_latest_plan_arrive_time 一派前常规车最晚规划到达时间
            ,tt2.max_real_arrive_time_innormal 一派前加班车最晚实际到达时间
            ,tt2.max_real_arrive_innormal_proof_id 一派前加班车最晚实际到达车线
            ,tt2.max_real_arrive_innormal_vol 一派前加班车最晚实际到达车线包裹量
            ,tt2.max_actual_plan_arrive_time_innormal 一派前加班车最晚规划到达时间
            ,tt2.late_proof_counts 一派常规车线实际比计划时间晚20分钟车辆数
            ,del.del_rate
            ,del.del_pno_num
            ,del.pno_num
        from
            (
                select
                   base.store_id
                   ,base.store_name
                   ,base.store_type
                   ,base.piece_name
                   ,base.region_name
                   ,count(distinct base.pno) shoud_counts
                   ,count(distinct case when base.min_fenjian_scan_time is not null then base.pno else null end ) scan_fished_counts
                   ,count(distinct case when base.min_fenjian_scan_time is not null and base.min_fenjian_scan_time<tiaozheng_scan_deadline_time then base.pno else null end ) youxiao_counts

                   ,count(distinct case when base.type='一派' then  base.pno else null end ) 1pai_counts
                   ,count(distinct case when base.type='一派' and base.min_fenjian_scan_time is not null then  base.pno else null end ) 1pai_scan_fished_counts
                   ,count(distinct case when base.type='一派' and base.min_fenjian_scan_time is not null and base.min_fenjian_scan_time<tiaozheng_scan_deadline_time then  base.pno else null end ) 1pai_youxiao_counts

                   ,count(distinct case when base.type='一派' and date_format(base.min_fenjian_scan_time,'%H:%i:%s')<='08:00:00' then base.pno else null end) 1pai_hour_8_fished_counts
                   ,count(distinct case when base.type='一派' and date_format(base.min_fenjian_scan_time,'%H:%i:%s')<='08:30:00' then base.pno else null end) 1pai_hour_8ban_fished_counts
                   ,count(distinct case when base.type='一派' and date_format(base.min_fenjian_scan_time,'%H:%i:%s')<='09:00:00' then base.pno else null end) 1pai_hour_9_fished_counts
                   ,count(distinct case when base.type='一派' and date_format(base.min_fenjian_scan_time,'%H:%i:%s')<='09:30:00' then base.pno else null end) 1pai_hour_9ban_fished_counts

                from
                (
                   select
                   t.*,
                   case when t.should_delevry_type='1派应派包裹' then '一派' else null end 'type'
                   from dwm.dwd_my_dc_should_be_delivery_sort_scan t
                   join my_staging.sys_store ss
                   on t.store_id =ss.id and ss.category in (1,10)

                ) base
                group by base.store_id,base.store_name,base.store_type,base.piece_name,base.region_name
            ) tt
        left join
            (
                select
                   bl.store_id
                   ,bl.max_real_arrive_time_normal
                   ,bl.max_real_arrive_proof_id
                   ,bl.max_real_arrive_vol
                   ,bl.line_1_latest_plan_arrive_time
                   ,bl.max_actual_plan_arrive_time_innormal
                   ,bl.max_actual_plan_arrive_innormal_proof_id
                   ,bl.max_actual_plan_arrive_innormal_vol
                   ,bl.max_real_arrive_time_innormal
                   ,bl.max_real_arrive_innormal_proof_id
                   ,bl.max_real_arrive_innormal_vol
                   ,late_proof_counts
                from dwm.fleet_real_detail_today bl
                group by 1,2,3,4,5,6,7,8,9,10,11
            ) tt2 on tt.store_id=tt2.store_id
        left join
            (
                select
                    ds.dst_store_id
                    ,count(distinct ds.pno) pno_num
                    ,count(if(pi.pno is not null, ds.pno, null)) del_pno_num
                    ,count(if(pi.pno is not null, ds.pno, null))/count(distinct ds.pno) del_rate
                from dwm.dwd_my_dc_should_be_delivery ds
                left join my_staging.parcel_info pi on pi.pno = ds.pno and pi.state = 5 and pi.finished_at >= date_sub('2023-09-17', interval 8 hour ) and pi.finished_at < date_add('2023-09-17', interval 16 hour)
                where
                    ds.p_date = '2023-09-17'
                    and ds.should_delevry_type != '非当日应派'
                group by 1
            ) del on del.dst_store_id = tt.store_id
    ) a
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ds.dst_store_id store_id
        ,ss.name
        ,ds.pno
        ,convert_tz(pi.finished_at, '+00:00', '+08:00') finished_time
        ,pi.ticket_delivery_staff_info_id
        ,pi.state
        ,coalesce(hsi.store_id, hs.sys_store_id) hr_store_id
        ,coalesce(hsi.job_title, hs.job_title) job_title
        ,coalesce(hsi.formal, hs.formal) formal
        ,row_number() over (partition by ds.dst_store_id, pi.ticket_delivery_staff_info_id order by pi.finished_at) rk1
        ,row_number() over (partition by ds.dst_store_id, pi.ticket_delivery_staff_info_id order by pi.finished_at desc) rk2
    from dwm.dwd_my_dc_should_be_delivery ds
    join my_staging.parcel_info pi on pi.pno = ds.pno
    left join my_staging.sys_store ss on ss.id = ds.dst_store_id
    left join my_bi.hr_staff_transfer hsi on hsi.staff_info_id = pi.ticket_delivery_staff_info_id and hsi.stat_date = '2023-09-17'
    left join my_bi.hr_staff_info hs on hs.staff_info_id = pi.ticket_delivery_staff_info_id and if(hs.leave_date is null, 1 = 1, hs.leave_date >= '2023-09-17')
#     left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pi.ticket_delivery_staff_info_id
    where
        pi.state = 5
#         and pi.finished_at >= '2023-08-01 16:00:00'
#         and pi.finished_at < '2023-08-02 16:00:00'
        and ds.p_date = '2023-09-17'
        and pi.finished_at >= date_sub('2023-09-17', interval 8 hour )
        and pi.finished_at < date_add('2023-09-17', interval 16 hour)
        and ds.should_delevry_type != '非当日应派'
)
select
    dp.store_id 网点ID
    ,dp.store_name 网点
    ,coalesce(dp.opening_at, '未记录') 开业时间
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,coalesce(cour.staf_num, 0) 本网点所属快递员数
    ,coalesce(ds.sd_num, 0) 应派件量
    ,coalesce(del.pno_num, 0) '妥投量(快递员+仓管+主管)'
    ,coalesce(del_cou.self_staff_num, 0) 参与妥投快递员_自有
    ,coalesce(del_cou.other_staff_num, 0) 参与妥投快递员_外协支援
    ,coalesce(del_cou.dco_dcs_num, 0) 参与妥投_仓管主管

    ,coalesce(del_cou.self_effect, 0) 当日人效_自有
    ,coalesce(del_cou.other_effect, 0) 当日人效_外协支援
    ,coalesce(del_cou.dco_dcs_effect, 0) 仓管主管人效
    ,coalesce(del_hour.avg_del_hour, 0) 派件小时数
from
    (
        select
            dp.store_id
            ,dp.store_name
            ,dp.opening_at
            ,dp.piece_name
            ,dp.region_name
        from dwm.dim_my_sys_store_rd dp
        left join my_staging.sys_store ss on ss.id = dp.store_id
        where
            dp.state_desc = '激活'
            and dp.stat_date = date_sub(curdate(), interval 1 day)
            and ss.category in (1,10)
    ) dp
left join
    (
        select
            hr.sys_store_id sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  my_bi.hr_staff_info hr
        where
            hr.formal = 1
            and hr.state = 1
            and hr.job_title in (13,110,1199)
#             and hr.stat_date = '${date}'
        group by 1
    ) cour on cour.sys_store_id = dp.store_id
left join
    (
        select
            ds.dst_store_id
            ,count(distinct ds.pno) sd_num
        from dwm.dwd_my_dc_should_be_delivery ds
        where
             ds.should_delevry_type != '非当日应派'
            and ds.p_date = '2023-09-17'
        group by 1
    ) ds on ds.dst_store_id = dp.store_id
left join
    (
        select
            t1.store_id
            ,count(distinct t1.pno) pno_num
        from t t1
        group by 1
    ) del on del.store_id = dp.store_id
left join
    (
        select
            t1.store_id
            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (13,110,1199) and t1.formal = 1, t1.ticket_delivery_staff_info_id, null)) self_staff_num
            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (13,110,1199) and t1.formal = 1, t1.pno, null))/count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (13,110,1199) and t1.formal = 1, t1.ticket_delivery_staff_info_id, null)) self_effect
            ,count(distinct if((t1.hr_store_id != t1.store_id or t1.formal != 1) and t1.job_title in (13,110,1199), t1.ticket_delivery_staff_info_id, null)) other_staff_num
            ,count(distinct if((t1.hr_store_id != t1.store_id or t1.formal != 1) and t1.job_title in (13,110,1199), t1.pno, null))/count(distinct if((t1.hr_store_id != t1.store_id or t1.formal != 1) and t1.job_title in (13,110,1199), t1.ticket_delivery_staff_info_id, null)) other_effect

            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (16,37), t1.ticket_delivery_staff_info_id, null)) dco_dcs_num
            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (16,37), t1.pno, null))/count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (16,37), t1.ticket_delivery_staff_info_id, null)) dco_dcs_effect
        from t t1
        group by 1
    ) del_cou on del_cou.store_id = dp.store_id
left join
    (
        select
            a.store_id
            ,a.name
            ,sum(diff_hour)/count(distinct a.ticket_delivery_staff_info_id) avg_del_hour
        from
            (
                select
                    t1.store_id
                    ,t1.name
                    ,t1.ticket_delivery_staff_info_id
                    ,t1.finished_time
                    ,t2.finished_time finished_at_2
                    ,timestampdiff(second, t1.finished_time, t2.finished_time)/3600 diff_hour
                from
                    (
                        select * from t t1 where t1.rk1 = 1
                    ) t1
                join
                    (
                        select * from t t2 where t2.rk2 = 2
                    ) t2 on t2.store_id = t1.store_id and t2.ticket_delivery_staff_info_id = t1.ticket_delivery_staff_info_id
            ) a
        group by 1,2
    ) del_hour on del_hour.store_id = dp.store_id;
;-- -. . -..- - / . -. - .-. -.--
select
     case
        when a.del_rate < 0.4 then '<40%'
        when a.del_rate >= 0.4 and a.del_rate < 0.5 then '40%-50%'
        when a.del_rate >= 0.5 and a.del_rate < 0.6 then '50%-60%'
        when a.del_rate >= 0.6 and a.del_rate < 0.7 then '60%-70%'
        when a.del_rate >= 0.7 and a.del_rate < 0.8 then '70%-80%'
        when a.del_rate >= 0.8 and a.del_rate <= 1 then '80%-100%'
    end 妥投率
    ,count(distinct a.网点ID) 总数
    ,count(distinct if(a.一派分拣评级 = 'A', a.网点ID, null))/count(distinct a.网点ID) 评级A
    ,count(distinct if(a.一派分拣评级 = 'B', a.网点ID, null))/count(distinct a.网点ID) 评级B
    ,count(distinct if(a.一派分拣评级 = 'C', a.网点ID, null))/count(distinct a.网点ID) 评级C
    ,count(distinct if(a.一派分拣评级 = 'D', a.网点ID, null))/count(distinct a.网点ID) 评级D
    ,count(distinct if(a.一派分拣评级 = 'E', a.网点ID, null))/count(distinct a.网点ID) 评级E
    ,count(distinct if(a.一派分拣评级 = 'A', a.网点ID, null)) 评级A数量
    ,count(distinct if(a.一派分拣评级 = 'B', a.网点ID, null)) 评级B数量
    ,count(distinct if(a.一派分拣评级 = 'C', a.网点ID, null)) 评级C数量
    ,count(distinct if(a.一派分拣评级 = 'D', a.网点ID, null)) 评级D数量
    ,count(distinct if(a.一派分拣评级 = 'E', a.网点ID, null)) 评级E数量
from
    (
                select -- 基于当日应派取扫描率
            tt.store_id 网点ID
            ,tt.store_name 网点名称
            ,'一派网点' as  网点分类
            ,tt.piece_name 片区
            ,tt.region_name 大区
            ,tt.shoud_counts 应派数
            ,tt.scan_fished_counts 分拣扫描数
            ,ifnull(tt.scan_fished_counts/shoud_counts,0) 分拣扫描率

            ,tt.youxiao_counts 有效分拣扫描数
            ,ifnull(tt.youxiao_counts/tt.scan_fished_counts,0) 有效分拣扫描率

            ,tt.1pai_counts 一派应派数
            ,tt.1pai_scan_fished_counts 一派分拣扫描数
            ,ifnull(tt.1pai_scan_fished_counts/tt.1pai_counts,0) 一派分拣扫描率

            ,tt.1pai_youxiao_counts 一派有效分拣扫描数
            ,ifnull(tt.1pai_youxiao_counts/tt.1pai_scan_fished_counts,0) 一派有效分拣扫描率
            ,
            case
                when tt.1pai_youxiao_counts/tt.1pai_scan_fished_counts>=0.95 then 'A'
                when tt.1pai_youxiao_counts/tt.1pai_scan_fished_counts>=0.90 then 'B'
                when tt.1pai_youxiao_counts/tt.1pai_scan_fished_counts>=0.85 then 'C'
                when tt.1pai_youxiao_counts/tt.1pai_scan_fished_counts>=0.80 then 'D'
                else 'E'
             end 一派有效分拣评级 -- 一派有效分拣

             ,case
                when tt.1pai_hour_8_fished_counts/tt.1pai_counts>=0.95  then 'A'
                when tt.1pai_hour_8ban_fished_counts/tt.1pai_counts>=0.95  then 'B'
                when tt.1pai_hour_9_fished_counts/tt.1pai_counts>=0.95  then 'C'
                when tt.1pai_hour_9ban_fished_counts/tt.1pai_counts>=0.95  then 'D'
                else 'E'
               end 一派分拣评级

            ,ifnull(tt.1pai_hour_8_fished_counts/tt.1pai_counts,0) 一派8点前扫描占比
            ,ifnull(tt.1pai_hour_8ban_fished_counts/tt.1pai_counts,0) 一派8点半前扫描占比
            ,ifnull(tt.1pai_hour_9_fished_counts/tt.1pai_counts,0) 一派9点前扫描占比
            ,ifnull(tt.1pai_hour_9ban_fished_counts/tt.1pai_counts,0) 一派9点半前扫描占比

            ,tt2.max_real_arrive_time_normal 一派前常规车最晚实际到达时间
            ,tt2.max_real_arrive_proof_id 一派前常规车最晚实际到达车线
            ,tt2.max_real_arrive_vol 一派前常规车最晚实际到达车线包裹量
            ,tt2.line_1_latest_plan_arrive_time 一派前常规车最晚规划到达时间
            ,tt2.max_real_arrive_time_innormal 一派前加班车最晚实际到达时间
            ,tt2.max_real_arrive_innormal_proof_id 一派前加班车最晚实际到达车线
            ,tt2.max_real_arrive_innormal_vol 一派前加班车最晚实际到达车线包裹量
            ,tt2.max_actual_plan_arrive_time_innormal 一派前加班车最晚规划到达时间
            ,tt2.late_proof_counts 一派常规车线实际比计划时间晚20分钟车辆数
            ,del.del_rate
            ,del.del_pno_num
            ,del.pno_num
        from
            (
                select
                   base.store_id
                   ,base.store_name
                   ,base.store_type
                   ,base.piece_name
                   ,base.region_name
                   ,count(distinct base.pno) shoud_counts
                   ,count(distinct case when base.min_fenjian_scan_time is not null then base.pno else null end ) scan_fished_counts
                   ,count(distinct case when base.min_fenjian_scan_time is not null and base.min_fenjian_scan_time<tiaozheng_scan_deadline_time then base.pno else null end ) youxiao_counts

                   ,count(distinct case when base.type='一派' then  base.pno else null end ) 1pai_counts
                   ,count(distinct case when base.type='一派' and base.min_fenjian_scan_time is not null then  base.pno else null end ) 1pai_scan_fished_counts
                   ,count(distinct case when base.type='一派' and base.min_fenjian_scan_time is not null and base.min_fenjian_scan_time<tiaozheng_scan_deadline_time then  base.pno else null end ) 1pai_youxiao_counts

                   ,count(distinct case when base.type='一派' and date_format(base.min_fenjian_scan_time,'%H:%i:%s')<='08:00:00' then base.pno else null end) 1pai_hour_8_fished_counts
                   ,count(distinct case when base.type='一派' and date_format(base.min_fenjian_scan_time,'%H:%i:%s')<='08:30:00' then base.pno else null end) 1pai_hour_8ban_fished_counts
                   ,count(distinct case when base.type='一派' and date_format(base.min_fenjian_scan_time,'%H:%i:%s')<='09:00:00' then base.pno else null end) 1pai_hour_9_fished_counts
                   ,count(distinct case when base.type='一派' and date_format(base.min_fenjian_scan_time,'%H:%i:%s')<='09:30:00' then base.pno else null end) 1pai_hour_9ban_fished_counts

                from
                (
                   select
                   t.*,
                   case when t.should_delevry_type='1派应派包裹' then '一派' else null end 'type'
                   from dwm.dwd_my_dc_should_be_delivery_sort_scan t
                   join my_staging.sys_store ss
                   on t.store_id =ss.id and ss.category in (1,10)

                ) base
                group by base.store_id,base.store_name,base.store_type,base.piece_name,base.region_name
            ) tt
        left join
            (
                select
                   bl.store_id
                   ,bl.max_real_arrive_time_normal
                   ,bl.max_real_arrive_proof_id
                   ,bl.max_real_arrive_vol
                   ,bl.line_1_latest_plan_arrive_time
                   ,bl.max_actual_plan_arrive_time_innormal
                   ,bl.max_actual_plan_arrive_innormal_proof_id
                   ,bl.max_actual_plan_arrive_innormal_vol
                   ,bl.max_real_arrive_time_innormal
                   ,bl.max_real_arrive_innormal_proof_id
                   ,bl.max_real_arrive_innormal_vol
                   ,late_proof_counts
                from dwm.fleet_real_detail_today bl
                group by 1,2,3,4,5,6,7,8,9,10,11
            ) tt2 on tt.store_id=tt2.store_id
        left join
            (
                select
                    ds.dst_store_id
                    ,count(distinct ds.pno) pno_num
                    ,count(if(pi.pno is not null, ds.pno, null)) del_pno_num
                    ,count(if(pi.pno is not null, ds.pno, null))/count(distinct ds.pno) del_rate
                from dwm.dwd_my_dc_should_be_delivery ds
                left join my_staging.parcel_info pi on pi.pno = ds.pno and pi.state = 5 and pi.finished_at >= date_sub('2023-09-17', interval 8 hour ) and pi.finished_at < date_add('2023-09-17', interval 16 hour)
                where
                    ds.p_date = '2023-09-17'
                    and ds.should_delevry_type != '非当日应派'
                group by 1
            ) del on del.dst_store_id = tt.store_id
    ) a
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    a.大区
    ,count(distinct a.网点ID) 总网点数
    ,count(distinct if(a.一派分拣评级 = 'E', a.网点ID, null)) 问题网点数
    ,count(distinct if(a.一派分拣评级 = 'E', a.网点ID, null))/count(distinct a.网点ID)  问题比例
from
    (
                select -- 基于当日应派取扫描率
            tt.store_id 网点ID
            ,tt.store_name 网点名称
            ,'一派网点' as  网点分类
            ,tt.piece_name 片区
            ,tt.region_name 大区
            ,tt.shoud_counts 应派数
            ,tt.scan_fished_counts 分拣扫描数
            ,ifnull(tt.scan_fished_counts/shoud_counts,0) 分拣扫描率

            ,tt.youxiao_counts 有效分拣扫描数
            ,ifnull(tt.youxiao_counts/tt.scan_fished_counts,0) 有效分拣扫描率

            ,tt.1pai_counts 一派应派数
            ,tt.1pai_scan_fished_counts 一派分拣扫描数
            ,ifnull(tt.1pai_scan_fished_counts/tt.1pai_counts,0) 一派分拣扫描率

            ,tt.1pai_youxiao_counts 一派有效分拣扫描数
            ,ifnull(tt.1pai_youxiao_counts/tt.1pai_scan_fished_counts,0) 一派有效分拣扫描率
            ,
            case
                when tt.1pai_youxiao_counts/tt.1pai_scan_fished_counts>=0.95 then 'A'
                when tt.1pai_youxiao_counts/tt.1pai_scan_fished_counts>=0.90 then 'B'
                when tt.1pai_youxiao_counts/tt.1pai_scan_fished_counts>=0.85 then 'C'
                when tt.1pai_youxiao_counts/tt.1pai_scan_fished_counts>=0.80 then 'D'
                else 'E'
             end 一派有效分拣评级 -- 一派有效分拣

             ,case
                when tt.1pai_hour_8_fished_counts/tt.1pai_counts>=0.95  then 'A'
                when tt.1pai_hour_8ban_fished_counts/tt.1pai_counts>=0.95  then 'B'
                when tt.1pai_hour_9_fished_counts/tt.1pai_counts>=0.95  then 'C'
                when tt.1pai_hour_9ban_fished_counts/tt.1pai_counts>=0.95  then 'D'
                else 'E'
               end 一派分拣评级

            ,ifnull(tt.1pai_hour_8_fished_counts/tt.1pai_counts,0) 一派8点前扫描占比
            ,ifnull(tt.1pai_hour_8ban_fished_counts/tt.1pai_counts,0) 一派8点半前扫描占比
            ,ifnull(tt.1pai_hour_9_fished_counts/tt.1pai_counts,0) 一派9点前扫描占比
            ,ifnull(tt.1pai_hour_9ban_fished_counts/tt.1pai_counts,0) 一派9点半前扫描占比

            ,tt2.max_real_arrive_time_normal 一派前常规车最晚实际到达时间
            ,tt2.max_real_arrive_proof_id 一派前常规车最晚实际到达车线
            ,tt2.max_real_arrive_vol 一派前常规车最晚实际到达车线包裹量
            ,tt2.line_1_latest_plan_arrive_time 一派前常规车最晚规划到达时间
            ,tt2.max_real_arrive_time_innormal 一派前加班车最晚实际到达时间
            ,tt2.max_real_arrive_innormal_proof_id 一派前加班车最晚实际到达车线
            ,tt2.max_real_arrive_innormal_vol 一派前加班车最晚实际到达车线包裹量
            ,tt2.max_actual_plan_arrive_time_innormal 一派前加班车最晚规划到达时间
            ,tt2.late_proof_counts 一派常规车线实际比计划时间晚20分钟车辆数
            ,del.del_rate
            ,del.del_pno_num
            ,del.pno_num
        from
            (
                select
                   base.store_id
                   ,base.store_name
                   ,base.store_type
                   ,base.piece_name
                   ,base.region_name
                   ,count(distinct base.pno) shoud_counts
                   ,count(distinct case when base.min_fenjian_scan_time is not null then base.pno else null end ) scan_fished_counts
                   ,count(distinct case when base.min_fenjian_scan_time is not null and base.min_fenjian_scan_time<tiaozheng_scan_deadline_time then base.pno else null end ) youxiao_counts

                   ,count(distinct case when base.type='一派' then  base.pno else null end ) 1pai_counts
                   ,count(distinct case when base.type='一派' and base.min_fenjian_scan_time is not null then  base.pno else null end ) 1pai_scan_fished_counts
                   ,count(distinct case when base.type='一派' and base.min_fenjian_scan_time is not null and base.min_fenjian_scan_time<tiaozheng_scan_deadline_time then  base.pno else null end ) 1pai_youxiao_counts

                   ,count(distinct case when base.type='一派' and date_format(base.min_fenjian_scan_time,'%H:%i:%s')<='08:00:00' then base.pno else null end) 1pai_hour_8_fished_counts
                   ,count(distinct case when base.type='一派' and date_format(base.min_fenjian_scan_time,'%H:%i:%s')<='08:30:00' then base.pno else null end) 1pai_hour_8ban_fished_counts
                   ,count(distinct case when base.type='一派' and date_format(base.min_fenjian_scan_time,'%H:%i:%s')<='09:00:00' then base.pno else null end) 1pai_hour_9_fished_counts
                   ,count(distinct case when base.type='一派' and date_format(base.min_fenjian_scan_time,'%H:%i:%s')<='09:30:00' then base.pno else null end) 1pai_hour_9ban_fished_counts

                from
                (
                   select
                   t.*,
                   case when t.should_delevry_type='1派应派包裹' then '一派' else null end 'type'
                   from dwm.dwd_my_dc_should_be_delivery_sort_scan t
                   join my_staging.sys_store ss
                   on t.store_id =ss.id and ss.category in (1,10)

                ) base
                group by base.store_id,base.store_name,base.store_type,base.piece_name,base.region_name
            ) tt
        left join
            (
                select
                   bl.store_id
                   ,bl.max_real_arrive_time_normal
                   ,bl.max_real_arrive_proof_id
                   ,bl.max_real_arrive_vol
                   ,bl.line_1_latest_plan_arrive_time
                   ,bl.max_actual_plan_arrive_time_innormal
                   ,bl.max_actual_plan_arrive_innormal_proof_id
                   ,bl.max_actual_plan_arrive_innormal_vol
                   ,bl.max_real_arrive_time_innormal
                   ,bl.max_real_arrive_innormal_proof_id
                   ,bl.max_real_arrive_innormal_vol
                   ,late_proof_counts
                from dwm.fleet_real_detail_today bl
                group by 1,2,3,4,5,6,7,8,9,10,11
            ) tt2 on tt.store_id=tt2.store_id
        left join
            (
                select
                    ds.dst_store_id
                    ,count(distinct ds.pno) pno_num
                    ,count(if(pi.pno is not null, ds.pno, null)) del_pno_num
                    ,count(if(pi.pno is not null, ds.pno, null))/count(distinct ds.pno) del_rate
                from dwm.dwd_my_dc_should_be_delivery ds
                left join my_staging.parcel_info pi on pi.pno = ds.pno and pi.state = 5 and pi.finished_at >= date_sub('2023-09-17', interval 8 hour ) and pi.finished_at < date_add('2023-09-17', interval 16 hour)
                where
                    ds.p_date = '2023-09-17'
                    and ds.should_delevry_type != '非当日应派'
                group by 1
            ) del on del.dst_store_id = tt.store_id
    ) a
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
        hsa.staff_info_id
        ,hsa.sub_staff_info_id
        ,hsa.store_id
        ,hsa.store_name
        ,hsa.staff_store_id
        ,hsa.job_title_id
    from my_backyard.hr_staff_apply_support_store hsa
    left join my_backyard.staff_work_attendance swa on hsa.sub_staff_info_id = swa.staff_info_id and swa.attendance_date = '2023-09-18' and swa.organization_id = hsa.store_id and ( swa.started_at is not null  or swa.end_at is not null )
    where
        hsa.actual_begin_date <= '2023-09-18'
        and coalesce(hsa.actual_end_date, curdate()) >= '2023-09-18'
        and hsa.employment_begin_date <= '2023-09-18'
        and coalesce(hsa.employment_end_date, curdate()) >= '2023-09-18'
#         and hsa.store_name = 'PRG_SP-บางปรอก'
        and hsa.status = 2
        and swa.id is not null;
;-- -. . -..- - / . -. - .-. -.--
select
        hsa.staff_info_id
        ,hsa.sub_staff_info_id
        ,hsa.store_id
        ,hsa.store_name
        ,hsa.staff_store_id
        ,hsa.job_title_id
        ,hsa.employment_begin_date
        ,hsa.employment_end_date
    from my_backyard.hr_staff_apply_support_store hsa
    left join my_backyard.staff_work_attendance swa on hsa.sub_staff_info_id = swa.staff_info_id and swa.attendance_date = '2023-09-18' and swa.organization_id = hsa.store_id and ( swa.started_at is not null  or swa.end_at is not null )
    where
        hsa.actual_begin_date <= '2023-09-18'
        and coalesce(hsa.actual_end_date, curdate()) >= '2023-09-18'
        and hsa.employment_begin_date <= '2023-09-18'
        and coalesce(hsa.employment_end_date, curdate()) >= '2023-09-18'
#         and hsa.store_name = 'PRG_SP-บางปรอก'
        and hsa.status = 2
        and swa.id is not null;
;-- -. . -..- - / . -. - .-. -.--
with sup as
(
    select
        hsa.staff_info_id
        ,hsa.sub_staff_info_id
        ,hsa.store_id
        ,hsa.store_name
        ,hsa.staff_store_id
        ,hsa.job_title_id
        ,hsa.employment_begin_date
        ,hsa.employment_end_date
    from my_backyard.hr_staff_apply_support_store hsa
    left join my_backyard.staff_work_attendance swa on hsa.sub_staff_info_id = swa.staff_info_id and swa.attendance_date = '2023-09-18' and swa.organization_id = hsa.store_id and ( swa.started_at is not null  or swa.end_at is not null )
    where
        hsa.actual_begin_date <= '2023-09-18'
        and coalesce(hsa.actual_end_date, curdate()) >= '2023-09-18'
        and hsa.employment_begin_date <= '2023-09-18'
        and coalesce(hsa.employment_end_date, curdate()) >= '2023-09-18'
#         and hsa.store_name = 'PRG_SP-บางปรอก'
        and hsa.status = 2
        and swa.id is not null
)
select
    dt.region_name 大区
    ,dt.piece_name 片区
    ,dt.store_name 网点
    ,a1.today_should_del 当日应派
    ,a1.today_already_del 当日妥投
    ,a1.no_del_big_count 未妥投大件数量
    ,a2.courier_count 自有快递员人数（出勤）
    ,a3.sup_courier_count 支援快递员人数（出勤）
    ,a2.dco_count 自有仓管
    ,a3.sup_dco_count 支援仓管
    ,a4.sort_rate 分拣扫描率
    ,a5.self_effect 自有人效
    ,a5.other_effect 支援人效
from
    ( -- 应派妥投
        select
            ss.store_name
            ,ss.store_id
            ,count(distinct ds.pno) today_should_del
            ,count(distinct if(pi.state = 5 and pi.finished_at >= date_sub('2023-09-18', interval 8 hour) and pi.finished_at < date_add('2023-09-18', interval  16 hour), ds.pno, null)) today_already_del
            ,count(distinct if(pi.state != 5 and ( pi.exhibition_weight > 5000 or pi.exhibition_length + pi.exhibition_width + pi.exhibition_height > 80 ), ds.pno, null)) no_del_big_count
        from dwm.dwd_my_dc_should_be_delivery ds
        left join my_staging.parcel_info pi on ds.pno = pi.pno
        join
            (
                select
                    sup.store_id
                    ,sup.store_name
                from sup
                group by 1,2
            ) ss on ss.store_id = ds.dst_store_id
        where
            ds.p_date = '2023-09-18'
            and ds.should_delevry_type != '非当日应派'
        group by 1,2
    ) a1
left join
    (
        select
            hsi.sys_store_id
            ,count(distinct if(hsi.job_title in (13,110,1199) and sup1.staff_info_id is null, hsi.staff_info_id, null)) courier_count
            ,count(distinct if(hsi.job_title in (37) and sup1.staff_info_id is null, hsi.staff_info_id, null)) dco_count
        from my_bi.hr_staff_info hsi
        join my_backyard.staff_work_attendance swa on swa.staff_info_id = hsi.staff_info_id and swa.attendance_date = '2023-09-18' and ( swa.started_at is not null or swa.end_at is not null)
        left join sup sup1 on sup1.staff_info_id = hsi.staff_info_id
        group by 1
    ) a2 on a2.sys_store_id = a1.store_id
left join
    (
        select
            s1.store_id
            ,count(if(s1.job_title_id in (13,110,1199), s1.staff_info_id, null)) sup_courier_count
            ,count(if(s1.job_title_id in (37), s1.staff_info_id, null)) sup_dco_count
        from sup s1
        group by 1
    ) a3 on a3.store_id = a1.store_id
left join
    (
        select
            ds.dst_store_id
            ,count(distinct ds.pno) ds_count
            ,count(distinct if(pr.pno is not null , ds.pno, null)) sort_count
            ,count(distinct if(pr.pno is not null , ds.pno, null))/count(distinct ds.pno) sort_rate
        from dwm.dwd_my_dc_should_be_delivery ds
        left join my_staging.parcel_route pr on pr.pno = ds.pno and pr.route_action = 'SORTING_SCAN' and pr.routed_at >= date_sub('2023-09-18', interval 8 hour) and pr.routed_at < date_add('2023-09-18', interval 16 hour)
        group by 1
    ) a4 on a4.dst_store_id = a1.store_id
left join
    (
        select
            ds.dst_store_id
            ,count(distinct if(hsi.staff_info_id is not null, ds.pno, null))/count(distinct if(hsi.staff_info_id is not null, pi.ticket_delivery_staff_info_id, null)) self_effect
            ,count(distinct if(s1.sub_staff_info_id is not null, ds.pno, null))/count(distinct if(s1.sub_staff_info_id is not null, pi.ticket_delivery_staff_info_id, null)) other_effect
        from dwm.dwd_my_dc_should_be_delivery ds
        join my_staging.parcel_info pi on pi.pno = ds.pno
        left join sup s1 on s1.store_id = ds.dst_store_id and pi.ticket_delivery_staff_info_id = s1.sub_staff_info_id
        left join my_bi.hr_staff_info hsi on hsi.staff_info_id = pi.ticket_delivery_staff_info_id and hsi.formal = 1 and hsi.is_sub_staff = 0 and hsi.sys_store_id = ds.dst_store_id
        where
            pi.state = 5
            and pi.finished_at >= date_sub('2023-09-18', interval 8 hour)
            and pi.finished_at < date_add('2023-09-18', interval 16 hour)
            and pi.returned = 0
        group by 1
    ) a5 on a5.dst_store_id = a1.store_id
left join dwm.dim_my_sys_store_rd dt on dt.store_id = a1.store_id and dt.stat_date = date_sub(curdate(), interval 1 day);
;-- -. . -..- - / . -. - .-. -.--
with sup as
(
    select
        hsa.staff_info_id
        ,hsa.sub_staff_info_id
        ,hsa.store_id
        ,hsa.store_name
        ,hsa.staff_store_id
        ,hsa.job_title_id
    from my_backyard.hr_staff_apply_support_store hsa
    left join my_backyard.staff_work_attendance swa on hsa.sub_staff_info_id = swa.staff_info_id and swa.attendance_date = '2023-09-18' and swa.organization_id = hsa.store_id and ( swa.started_at is not null  or swa.end_at is not null )
    where
        hsa.actual_begin_date <= '2023-09-18'
        and coalesce(hsa.actual_end_date, curdate()) >= '2023-09-18'
        and hsa.employment_begin_date <= '2023-09-18'
        and coalesce(hsa.employment_end_date, curdate()) >= '2023-09-18'
#         and hsa.store_name = 'PRG_SP-บางปรอก'
        and hsa.status = 2
        and swa.id is not null
)
, total as
(
    select
        a.*
    from
        (
            select
                a1.dst_store_id
                ,a1.pno
                ,a1.sorting_code
                ,td.created_at td_time
                ,td.staff_info_id
                ,pi.state
                ,pi.finished_at
                ,pi.ticket_delivery_staff_info_id
                ,row_number() over (partition by td.pno order by td.created_at desc ) rn
            from
                (
                    select
                        a.*
                    from
                        (
                            select
                                ds.pno
                                ,ds.dst_store_id
                                ,ps.sorting_code
                                ,row_number() over (partition by ps.pno order by ps.created_at desc ) rk
                            from dwm.dwd_my_dc_should_be_delivery ds
                            join my_drds_pro.parcel_sorting_code_info ps on ds.pno =  ps.pno and ds.dst_store_id = ps.dst_store_id
                        ) a
                    where
                        a.rk = 1
                ) a1
            join my_staging.ticket_delivery td on td.pno = a1.pno and td.created_at >= date_sub('2023-09-18', interval 8 hour) and td.created_at < date_add('2023-09-18', interval 16 hour)
            left join my_staging.parcel_info pi on pi.pno = a1.pno
        ) a
    where
        a.rn = 1
)
select
    dt.region_name 大区
    ,dt.piece_name 片区
    ,dt.store_name 来源网点
    ,dt2.store_name 支援网点
    ,s1.staff_info_id 主账号
    ,s1.sub_staff_info_id 子账号
    ,hjt.job_name  'van/bike'
    ,swa.started_at 上班时间
    ,swa.end_at 下班时间
    ,s2.scan_count 交接量
    ,s2.del_count 妥投量
    ,timestampdiff(minute , fir.finished_at, las.finished_at )/60 派送时长
    ,code.scan_code_count 交接三段码数量
    ,code.del_code_num 妥投三段码数量
    ,pho.0_count 未妥投中打电话次数为0的数量
    ,pho.1_count 未妥投中打电话次数为1的数量
from sup s1
left join dwm.dim_my_sys_store_rd dt on dt.store_id = s1.staff_store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
left join dwm.dim_my_sys_store_rd dt2 on dt2.store_id = s1.store_id and dt2.stat_date = date_sub(curdate(), interval 1 day)
left join my_bi.hr_job_title hjt on hjt.id = s1.job_title_id
left join my_backyard.staff_work_attendance swa on swa.staff_info_id = s1.sub_staff_info_id and swa.attendance_date = '2023-09-18' and swa.organization_id = s1.store_id
left join
    (
        select
            t1.staff_info_id
            ,count(distinct t1.pno) scan_count
            ,count(if(t1.state = 5, t1.pno, null)) del_count
        from total t1
        group by 1
    ) s2 on s2.staff_info_id = s1.sub_staff_info_id
left join
    ( -- 第一次妥投时间
        select
            t1.*
            ,row_number() over (partition by t1.staff_info_id order by t1.finished_at ) rk
        from total t1
        where
            t1.state = 5
    ) fir on fir.staff_info_id = s1.sub_staff_info_id and fir.rk = 1
left join
    (
        select
            t1.*
            ,row_number() over (partition by t1.staff_info_id order by t1.finished_at desc ) rk
        from total t1
        where
            t1.state = 5
    ) las on las.staff_info_id = s1.sub_staff_info_id and las.rk = 2
left join
    (
        select
            t1.staff_info_id
            ,count(distinct t1.sorting_code) scan_code_count
            ,count(distinct if(t1.state = 5, t1.sorting_code, null)) del_code_num
        from total t1
        where
            t1.sorting_code not in ('XX', 'YY', 'ZZ', '00')
        group by 1
    ) code on code.staff_info_id = s1.sub_staff_info_id
left join
    (
        select
            a.staff_info_id
            ,count(if(a.call_times = 0, a.pno, null)) 0_count
            ,count(if(a.call_times = 1, a.pno, null)) 1_count
        from
            (
                select
                    t.staff_info_id
                    ,t.pno
                    ,count(pr.pno) call_times
                from total t
                left join my_staging.parcel_route pr on pr.pno = t.pno and pr.route_action = 'PHONE' and pr.routed_at >= date_sub('2023-09-18', interval 8 hour) and pr.routed_at < date_add('2023-09-18', interval 16 hour)
                where
                    t.state != 5
                group by 1,2
            ) a
        group by 1
    ) pho on pho.staff_info_id = s1.sub_staff_info_id;
;-- -. . -..- - / . -. - .-. -.--
select
     case
        when a.del_rate < 0.4 then '<40%'
        when a.del_rate >= 0.4 and a.del_rate < 0.5 then '40%-50%'
        when a.del_rate >= 0.5 and a.del_rate < 0.6 then '50%-60%'
        when a.del_rate >= 0.6 and a.del_rate < 0.7 then '60%-70%'
        when a.del_rate >= 0.7 and a.del_rate < 0.8 then '70%-80%'
        when a.del_rate >= 0.8 and a.del_rate <= 1 then '80%-100%'
    end 妥投率
    ,count(distinct a.网点ID) 总数
    ,count(distinct if(a.一派分拣评级 = 'A', a.网点ID, null))/count(distinct a.网点ID) 评级A
    ,count(distinct if(a.一派分拣评级 = 'B', a.网点ID, null))/count(distinct a.网点ID) 评级B
    ,count(distinct if(a.一派分拣评级 = 'C', a.网点ID, null))/count(distinct a.网点ID) 评级C
    ,count(distinct if(a.一派分拣评级 = 'D', a.网点ID, null))/count(distinct a.网点ID) 评级D
    ,count(distinct if(a.一派分拣评级 = 'E', a.网点ID, null))/count(distinct a.网点ID) 评级E
    ,count(distinct if(a.一派分拣评级 = 'A', a.网点ID, null)) 评级A数量
    ,count(distinct if(a.一派分拣评级 = 'B', a.网点ID, null)) 评级B数量
    ,count(distinct if(a.一派分拣评级 = 'C', a.网点ID, null)) 评级C数量
    ,count(distinct if(a.一派分拣评级 = 'D', a.网点ID, null)) 评级D数量
    ,count(distinct if(a.一派分拣评级 = 'E', a.网点ID, null)) 评级E数量
from
    (
                select -- 基于当日应派取扫描率
            tt.store_id 网点ID
            ,tt.store_name 网点名称
            ,'一派网点' as  网点分类
            ,tt.piece_name 片区
            ,tt.region_name 大区
            ,tt.shoud_counts 应派数
            ,tt.scan_fished_counts 分拣扫描数
            ,ifnull(tt.scan_fished_counts/shoud_counts,0) 分拣扫描率

            ,tt.youxiao_counts 有效分拣扫描数
            ,ifnull(tt.youxiao_counts/tt.scan_fished_counts,0) 有效分拣扫描率

            ,tt.1pai_counts 一派应派数
            ,tt.1pai_scan_fished_counts 一派分拣扫描数
            ,ifnull(tt.1pai_scan_fished_counts/tt.1pai_counts,0) 一派分拣扫描率

            ,tt.1pai_youxiao_counts 一派有效分拣扫描数
            ,ifnull(tt.1pai_youxiao_counts/tt.1pai_scan_fished_counts,0) 一派有效分拣扫描率
            ,
            case
                when tt.1pai_youxiao_counts/tt.1pai_scan_fished_counts>=0.95 then 'A'
                when tt.1pai_youxiao_counts/tt.1pai_scan_fished_counts>=0.90 then 'B'
                when tt.1pai_youxiao_counts/tt.1pai_scan_fished_counts>=0.85 then 'C'
                when tt.1pai_youxiao_counts/tt.1pai_scan_fished_counts>=0.80 then 'D'
                else 'E'
             end 一派有效分拣评级 -- 一派有效分拣

             ,case
                when tt.1pai_hour_8_fished_counts/tt.1pai_counts>=0.95  then 'A'
                when tt.1pai_hour_8ban_fished_counts/tt.1pai_counts>=0.95  then 'B'
                when tt.1pai_hour_9_fished_counts/tt.1pai_counts>=0.95  then 'C'
                when tt.1pai_hour_9ban_fished_counts/tt.1pai_counts>=0.95  then 'D'
                else 'E'
               end 一派分拣评级

            ,ifnull(tt.1pai_hour_8_fished_counts/tt.1pai_counts,0) 一派8点前扫描占比
            ,ifnull(tt.1pai_hour_8ban_fished_counts/tt.1pai_counts,0) 一派8点半前扫描占比
            ,ifnull(tt.1pai_hour_9_fished_counts/tt.1pai_counts,0) 一派9点前扫描占比
            ,ifnull(tt.1pai_hour_9ban_fished_counts/tt.1pai_counts,0) 一派9点半前扫描占比

            ,tt2.max_real_arrive_time_normal 一派前常规车最晚实际到达时间
            ,tt2.max_real_arrive_proof_id 一派前常规车最晚实际到达车线
            ,tt2.max_real_arrive_vol 一派前常规车最晚实际到达车线包裹量
            ,tt2.line_1_latest_plan_arrive_time 一派前常规车最晚规划到达时间
            ,tt2.max_real_arrive_time_innormal 一派前加班车最晚实际到达时间
            ,tt2.max_real_arrive_innormal_proof_id 一派前加班车最晚实际到达车线
            ,tt2.max_real_arrive_innormal_vol 一派前加班车最晚实际到达车线包裹量
            ,tt2.max_actual_plan_arrive_time_innormal 一派前加班车最晚规划到达时间
            ,tt2.late_proof_counts 一派常规车线实际比计划时间晚20分钟车辆数
            ,del.del_rate
            ,del.del_pno_num
            ,del.pno_num
        from
            (
                select
                   base.store_id
                   ,base.store_name
                   ,base.store_type
                   ,base.piece_name
                   ,base.region_name
                   ,count(distinct base.pno) shoud_counts
                   ,count(distinct case when base.min_fenjian_scan_time is not null then base.pno else null end ) scan_fished_counts
                   ,count(distinct case when base.min_fenjian_scan_time is not null and base.min_fenjian_scan_time<tiaozheng_scan_deadline_time then base.pno else null end ) youxiao_counts

                   ,count(distinct case when base.type='一派' then  base.pno else null end ) 1pai_counts
                   ,count(distinct case when base.type='一派' and base.min_fenjian_scan_time is not null then  base.pno else null end ) 1pai_scan_fished_counts
                   ,count(distinct case when base.type='一派' and base.min_fenjian_scan_time is not null and base.min_fenjian_scan_time<tiaozheng_scan_deadline_time then  base.pno else null end ) 1pai_youxiao_counts

                   ,count(distinct case when base.type='一派' and date_format(base.min_fenjian_scan_time,'%H:%i:%s')<='08:00:00' then base.pno else null end) 1pai_hour_8_fished_counts
                   ,count(distinct case when base.type='一派' and date_format(base.min_fenjian_scan_time,'%H:%i:%s')<='08:30:00' then base.pno else null end) 1pai_hour_8ban_fished_counts
                   ,count(distinct case when base.type='一派' and date_format(base.min_fenjian_scan_time,'%H:%i:%s')<='09:00:00' then base.pno else null end) 1pai_hour_9_fished_counts
                   ,count(distinct case when base.type='一派' and date_format(base.min_fenjian_scan_time,'%H:%i:%s')<='09:30:00' then base.pno else null end) 1pai_hour_9ban_fished_counts

                from
                (
                   select
                   t.*,
                   case when t.should_delevry_type='1派应派包裹' then '一派' else null end 'type'
                   from dwm.dwd_my_dc_should_be_delivery_sort_scan t
                   join my_staging.sys_store ss
                   on t.store_id =ss.id and ss.category in (1,10)

                ) base
                group by base.store_id,base.store_name,base.store_type,base.piece_name,base.region_name
            ) tt
        left join
            (
                select
                   bl.store_id
                   ,bl.max_real_arrive_time_normal
                   ,bl.max_real_arrive_proof_id
                   ,bl.max_real_arrive_vol
                   ,bl.line_1_latest_plan_arrive_time
                   ,bl.max_actual_plan_arrive_time_innormal
                   ,bl.max_actual_plan_arrive_innormal_proof_id
                   ,bl.max_actual_plan_arrive_innormal_vol
                   ,bl.max_real_arrive_time_innormal
                   ,bl.max_real_arrive_innormal_proof_id
                   ,bl.max_real_arrive_innormal_vol
                   ,late_proof_counts
                from dwm.fleet_real_detail_today bl
                group by 1,2,3,4,5,6,7,8,9,10,11
            ) tt2 on tt.store_id=tt2.store_id
        left join
            (
                select
                    ds.dst_store_id
                    ,count(distinct ds.pno) pno_num
                    ,count(if(pi.pno is not null, ds.pno, null)) del_pno_num
                    ,count(if(pi.pno is not null, ds.pno, null))/count(distinct ds.pno) del_rate
                from dwm.dwd_my_dc_should_be_delivery ds
                left join my_staging.parcel_info pi on pi.pno = ds.pno and pi.state = 5 and pi.finished_at >= date_sub('2023-09-19', interval 8 hour ) and pi.finished_at < date_add('2023-09-19', interval 16 hour)
                where
                    ds.p_date = '2023-09-19'
                    and ds.should_delevry_type != '非当日应派'
                group by 1
            ) del on del.dst_store_id = tt.store_id
    ) a
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            dm.p_date
            ,dm.pno
            ,pr.routed_at
            ,pr.staff_info_id
            ,row_number() over (partition by dm.p_date, pr.pno order by pr.routed_at desc ) rk
        from dwm.dwd_my_dc_should_be_delivery_d dm
        join my_staging.parcel_route pr on pr.pno = dm.pno and pr.routed_at > '2023-09-01' and pr.routed_at >= date_sub(dm.p_date, interval 8 hour) and pr.routed_at < date_add(dm.p_date, interval 16 hour)
        where
            pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
            and dm.p_date >= '2023-09-14'
            and dm.should_delevry_type not in ('非当日应派')
    )
select
    a1.p_date 日期
    ,a1.staff_info_id 快递员
    ,ss.name 网点
    ,smr.name 大区
    ,a4.should_count 当日应派
    ,a1.scan_count 交接总量
    ,convert_tz(a2.routed_at, '+00:00', '+08:00') 第一票交接时间
    ,convert_tz(a3.finished_at, '+00:00', '+08:00') 第一票妥投时间
from
    (
        select
            t1.p_date
            ,t1.staff_info_id
            ,count(distinct t1.pno) scan_count
        from t t1
        where
            t1.rk = 1
        group by 1,2
    ) a1
left join
    (
        select
            *
            ,row_number() over (partition by t2.p_date,t2.staff_info_id order by t2.routed_at) rn
        from t t2
    ) a2 on a2.p_date = a1.p_date and a2.staff_info_id = a1.staff_info_id and a2.rn = 1
left join
    (
        select
            date(convert_tz(pi.finished_at, '+00:00', '+08:00')) p_date
            ,pi.ticket_delivery_staff_info_id
            ,pi.finished_at
            ,row_number() over (partition by date(convert_tz(pi.finished_at, '+00:00', '+08:00')), pi.ticket_delivery_staff_info_id order by pi.finished_at) rk
        from my_staging.parcel_info pi
        where
            pi.state = 5
            and pi.finished_at >= '2023-09-13 16:00:00'
    ) a3 on a3.p_date = a1.p_date and a3.ticket_delivery_staff_info_id = a1.staff_info_id and a3.rk = 1
left join my_bi.hr_staff_info hsi on hsi.staff_info_id = a1.staff_info_id
left join my_staging.sys_store ss on ss.id = hsi.sys_store_id
left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
left join
    (
        select
            dm.p_date
            ,dm.dst_store_id
            ,count(distinct dm.pno) should_count
        from dwm.dwd_my_dc_should_be_delivery_d dm
        where
            dm.p_date >= '2023-09-14'
            and dm.should_delevry_type not in ('非当日应派')
        group by 1,2
    ) a4 on a4.dst_store_id = hsi.sys_store_id and a4.p_date = a1.p_date;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            a.*
        from
            (
                select
                    dm.p_date
                    ,dm.pno
                    ,ps.third_sorting_code
                    ,dm.dst_store_id
                    ,row_number() over (partition by ps.dst_store_id order by ps.created_at desc) rk
                from dwm.dwd_my_dc_should_be_delivery_d dm
                join my_drds_pro.parcel_sorting_code_info ps on  ps.pno = dm.pno and ps.dst_store_id = dm.dst_store_id
                where
                    ps.third_sorting_code not in  ('XX', 'YY', 'ZZ', '00')
                    and dm.p_date >= '2023-09-14'
            ) a
        where
            a.rk = 1
    )
, sort as
(
    select
        t1.p_date
        ,t1.third_sorting_code
        ,t1.dst_store_id
        ,t1.pno
        ,pr.routed_at
        ,row_number() over (partition by t1.p_date, t1.dst_store_id,t1.third_sorting_code order by pr.routed_at desc ) r1
        ,row_number() over (partition by t1.p_date, t1.dst_store_id,t1.third_sorting_code order by pr.routed_at ) r2
    from my_staging.parcel_route pr
    join t t1 on t1.pno = pr.pno
    where
        pr.route_action = 'SORTING_SCAN'
        and pr.routed_at >= date_sub(t1.p_date, interval 8 hour)
        and pr.routed_at < date_add(t1.p_date, interval 16 hour)
    )
select
    a1.p_date 日期
    ,a1.third_sorting_code 网格
    ,dm.store_name 网点
    ,dm.region_name 大区
    ,a1.pno_count 当日应派
    ,a2.sort_count 已分拣数
    ,convert_tz(s3.routed_at, '+00:00', '+08:00') 第一票分拣扫描
    ,convert_tz(s2.routed_at, '+00:00', '+08:00') 最后一票分拣扫描
from
    (
        select
            t1.p_date
            ,t1.dst_store_id
            ,t1.third_sorting_code
            ,count(distinct t1.pno) pno_count
        from  t t1
        group by 1,2,3
    ) a1
left join
    (
        select
            s1.p_date
            ,s1.dst_store_id
            ,s1.third_sorting_code
            ,count(distinct s1.pno) sort_count
        from  sort s1
        group by 1,2,3
    ) a2 on a2.p_date = a1.p_date and a2.dst_store_id = a1.dst_store_id and  a2.third_sorting_code = a1.third_sorting_code
left join sort s2 on s2.p_date = a1.p_date and s2.dst_store_id = a1.dst_store_id and s2.third_sorting_code = a1.third_sorting_code and s2.r1 = 1
left join sort s3 on s3.p_date = a1.p_date and s3.dst_store_id = a1.dst_store_id and s3.third_sorting_code = a1.third_sorting_code and s3.r2 = 1
left join dwm.dim_my_sys_store_rd dm on dm.store_id = a1.dst_store_id and dm.stat_date = date_sub(curdate(), interval 1 day);
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            a.*
        from
            (
                select
                    dm.p_date
                    ,dm.pno
                    ,ps.third_sorting_code
                    ,dm.dst_store_id
                    ,row_number() over (partition by ps.pno order by ps.created_at desc) rk
                from dwm.dwd_my_dc_should_be_delivery_d dm
                join my_drds_pro.parcel_sorting_code_info ps on  ps.pno = dm.pno and ps.dst_store_id = dm.dst_store_id
                where
                    ps.third_sorting_code not in  ('XX', 'YY', 'ZZ', '00')
                    and dm.p_date >= '2023-09-14'
            ) a
        where
            a.rk = 1
    )
, sort as
(
    select
        t1.p_date
        ,t1.third_sorting_code
        ,t1.dst_store_id
        ,t1.pno
        ,pr.routed_at
        ,row_number() over (partition by t1.p_date, t1.dst_store_id,t1.third_sorting_code order by pr.routed_at desc ) r1
        ,row_number() over (partition by t1.p_date, t1.dst_store_id,t1.third_sorting_code order by pr.routed_at ) r2
    from my_staging.parcel_route pr
    join t t1 on t1.pno = pr.pno
    where
        pr.route_action = 'SORTING_SCAN'
        and pr.routed_at >= date_sub(t1.p_date, interval 8 hour)
        and pr.routed_at < date_add(t1.p_date, interval 16 hour)
    )
select
    a1.p_date 日期
    ,a1.third_sorting_code 网格
    ,dm.store_name 网点
    ,dm.region_name 大区
    ,a1.pno_count 当日应派
    ,a2.sort_count 已分拣数
    ,convert_tz(s3.routed_at, '+00:00', '+08:00') 第一票分拣扫描
    ,convert_tz(s2.routed_at, '+00:00', '+08:00') 最后一票分拣扫描
from
    (
        select
            t1.p_date
            ,t1.dst_store_id
            ,t1.third_sorting_code
            ,count(distinct t1.pno) pno_count
        from  t t1
        group by 1,2,3
    ) a1
left join
    (
        select
            s1.p_date
            ,s1.dst_store_id
            ,s1.third_sorting_code
            ,count(distinct s1.pno) sort_count
        from  sort s1
        group by 1,2,3
    ) a2 on a2.p_date = a1.p_date and a2.dst_store_id = a1.dst_store_id and  a2.third_sorting_code = a1.third_sorting_code
left join sort s2 on s2.p_date = a1.p_date and s2.dst_store_id = a1.dst_store_id and s2.third_sorting_code = a1.third_sorting_code and s2.r1 = 1
left join sort s3 on s3.p_date = a1.p_date and s3.dst_store_id = a1.dst_store_id and s3.third_sorting_code = a1.third_sorting_code and s3.r2 = 1
left join dwm.dim_my_sys_store_rd dm on dm.store_id = a1.dst_store_id and dm.stat_date = date_sub(curdate(), interval 1 day);
;-- -. . -..- - / . -. - .-. -.--
with sup as
(
    select
        hsa.staff_info_id
        ,hsa.sub_staff_info_id
        ,hsa.store_id
        ,hsa.store_name
        ,hsa.staff_store_id
        ,hsa.job_title_id
    from my_backyard.hr_staff_apply_support_store hsa
    left join my_backyard.staff_work_attendance swa on hsa.sub_staff_info_id = swa.staff_info_id and swa.attendance_date = '2023-09-21' and swa.organization_id = hsa.store_id and ( swa.started_at is not null  or swa.end_at is not null )
    where
        hsa.actual_begin_date <= '2023-09-21'
        and coalesce(hsa.actual_end_date, curdate()) >= '2023-09-21'
        and hsa.employment_begin_date <= '2023-09-21'
        and coalesce(hsa.employment_end_date, curdate()) >= '2023-09-21'
#         and hsa.store_name = 'PRG_SP-บางปรอก'
        and hsa.status = 2
        and swa.id is not null
)
, total as
(
    select
        a.*
    from
        (
            select
                a1.dst_store_id
                ,a1.pno
                ,a1.sorting_code
                ,td.created_at td_time
                ,td.staff_info_id
                ,pi.state
                ,pi.finished_at
                ,pi.ticket_delivery_staff_info_id
                ,row_number() over (partition by td.pno order by td.created_at desc ) rn
            from
                (
                    select
                        a.*
                    from
                        (
                            select
                                ds.pno
                                ,ds.dst_store_id
                                ,ps.third_sorting_code sorting_code
                                ,row_number() over (partition by ps.pno order by ps.created_at desc ) rk
                            from dwm.dwd_my_dc_should_be_delivery ds
                            join my_drds_pro.parcel_sorting_code_info ps on ds.pno =  ps.pno and ds.dst_store_id = ps.dst_store_id
                        ) a
                    where
                        a.rk = 1
                ) a1
            join my_staging.ticket_delivery td on td.pno = a1.pno and td.created_at >= date_sub('2023-09-21', interval 8 hour) and td.created_at < date_add('2023-09-21', interval 16 hour)
            left join my_staging.parcel_info pi on pi.pno = a1.pno
        ) a
    where
        a.rn = 1
)
select
    dt.region_name 大区
    ,dt.piece_name 片区
    ,dt.store_name 来源网点
    ,dt2.store_name 支援网点
    ,s1.staff_info_id 主账号
    ,s1.sub_staff_info_id 子账号
    ,hjt.job_name  'van/bike'
    ,convert_tz(swa.started_at, '+00:00', '+08:00') 上班时间
    ,convert_tz(swa.end_at, '+00:00', '+08:00') 下班时间
    ,s3.pick_num 揽收量
    ,s2.scan_count 交接量
    ,s2.del_count 妥投量
    ,timestampdiff(minute , fir.finished_at, las.finished_at )/60 派送时长
    ,code.scan_code_count 交接三段码数量
    ,code.del_code_num 妥投三段码数量
    ,pho.0_count 未妥投中打电话次数为0的数量
    ,pho.1_count 未妥投中打电话次数为1的数量
from sup s1
left join dwm.dim_my_sys_store_rd dt on dt.store_id = s1.staff_store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
left join dwm.dim_my_sys_store_rd dt2 on dt2.store_id = s1.store_id and dt2.stat_date = date_sub(curdate(), interval 1 day)
left join my_bi.hr_job_title hjt on hjt.id = s1.job_title_id
left join my_backyard.staff_work_attendance swa on swa.staff_info_id = s1.sub_staff_info_id and swa.attendance_date = '2023-09-21' and swa.organization_id = s1.store_id
left join
    (
        select
            t1.staff_info_id
            ,count(distinct t1.pno) scan_count
            ,count(if(t1.state = 5, t1.pno, null)) del_count
        from total t1
        group by 1
    ) s2 on s2.staff_info_id = s1.sub_staff_info_id
left join
    (
        select
            s1.sub_staff_info_id
            ,count(distinct pi.pno) pick_num
        from my_staging.parcel_info pi
        join sup s1 on s1.sub_staff_info_id = pi.ticket_pickup_staff_info_id
        where
            pi.created_at >= date_sub('2023-09-21', interval 8 hour)
            and pi.created_at < date_add('2023-09-21', interval 16 hour)
        group by 1
    ) s3 on s3.sub_staff_info_id = s1.sub_staff_info_id
left join
    ( -- 第一次妥投时间
        select
            t1.*
            ,row_number() over (partition by t1.staff_info_id order by t1.finished_at ) rk
        from total t1
        where
            t1.state = 5
    ) fir on fir.staff_info_id = s1.sub_staff_info_id and fir.rk = 1
left join
    (
        select
            t1.*
            ,row_number() over (partition by t1.staff_info_id order by t1.finished_at desc ) rk
        from total t1
        where
            t1.state = 5
    ) las on las.staff_info_id = s1.sub_staff_info_id and las.rk = 2
left join
    (
        select
            t1.staff_info_id
            ,count(distinct t1.sorting_code) scan_code_count
            ,count(distinct if(t1.state = 5, t1.sorting_code, null)) del_code_num
        from total t1
        where
            t1.sorting_code not in ('XX', 'YY', 'ZZ', '00')
        group by 1
    ) code on code.staff_info_id = s1.sub_staff_info_id
left join
    (
        select
            a.staff_info_id
            ,count(if(a.call_times = 0, a.pno, null)) 0_count
            ,count(if(a.call_times = 1, a.pno, null)) 1_count
        from
            (
                select
                    t.staff_info_id
                    ,t.pno
                    ,count(pr.pno) call_times
                from total t
                left join my_staging.parcel_route pr on pr.pno = t.pno and pr.route_action = 'PHONE' and pr.routed_at >= date_sub('2023-09-21', interval 8 hour) and pr.routed_at < date_add('2023-09-21', interval 16 hour)
                where
                    t.state != 5
                group by 1,2
            ) a
        group by 1
    ) pho on pho.staff_info_id = s1.sub_staff_info_id;
;-- -. . -..- - / . -. - .-. -.--
with sup as
(
    select
        hsa.staff_info_id
        ,hsa.sub_staff_info_id
        ,hsa.store_id
        ,hsa.store_name
        ,hsa.staff_store_id
        ,hsa.job_title_id
        ,hsa.employment_begin_date
        ,hsa.employment_end_date
    from my_backyard.hr_staff_apply_support_store hsa
    left join my_backyard.staff_work_attendance swa on hsa.sub_staff_info_id = swa.staff_info_id and swa.attendance_date = '2023-09-21' and swa.organization_id = hsa.store_id and ( swa.started_at is not null  or swa.end_at is not null )
    where
        hsa.actual_begin_date <= '2023-09-21'
        and coalesce(hsa.actual_end_date, curdate()) >= '2023-09-21'
        and hsa.employment_begin_date <= '2023-09-21'
        and coalesce(hsa.employment_end_date, curdate()) >= '2023-09-21'
#         and hsa.store_name = 'PRG_SP-บางปรอก'
        and hsa.status = 2
        and swa.id is not null
)
select
    dt.region_name 大区
    ,dt.piece_name 片区
    ,dt.store_name 网点
    ,a1.today_should_del 当日应派
    ,a1.today_already_del 当日妥投
    ,a1.no_del_big_count 未妥投大件数量
    ,a2.courier_count 自有快递员人数（出勤）
    ,a3.sup_courier_count 支援快递员人数（出勤）
    ,a2.dco_count 自有仓管
    ,a3.sup_dco_count 支援仓管
    ,a4.sort_rate 分拣扫描率
    ,a5.self_effect 自有人效
    ,a5.other_effect 支援人效
from
    ( -- 应派妥投
        select
            ss.store_name
            ,ss.store_id
            ,count(distinct ds.pno) today_should_del
            ,count(distinct if(pi.state = 5 and pi.finished_at >= date_sub('2023-09-21', interval 8 hour) and pi.finished_at < date_add('2023-09-21', interval  16 hour), ds.pno, null)) today_already_del
            ,count(distinct if(pi.state != 5 and ( pi.exhibition_weight > 5000 or pi.exhibition_length + pi.exhibition_width + pi.exhibition_height > 80 ), ds.pno, null)) no_del_big_count
        from dwm.dwd_my_dc_should_be_delivery ds
        left join my_staging.parcel_info pi on ds.pno = pi.pno
        join
            (
                select
                    sup.store_id
                    ,sup.store_name
                from sup
                group by 1,2
            ) ss on ss.store_id = ds.dst_store_id
        where
            ds.p_date = '2023-09-21'
            and ds.should_delevry_type != '非当日应派'
        group by 1,2
    ) a1
left join
    (
        select
            hsi.sys_store_id
            ,count(distinct if(hsi.job_title in (13,110,1199) and sup1.staff_info_id is null, hsi.staff_info_id, null)) courier_count
            ,count(distinct if(hsi.job_title in (37) and sup1.staff_info_id is null, hsi.staff_info_id, null)) dco_count
        from my_bi.hr_staff_info hsi
        join my_backyard.staff_work_attendance swa on swa.staff_info_id = hsi.staff_info_id and swa.attendance_date = '2023-09-21' and ( swa.started_at is not null or swa.end_at is not null)
        left join sup sup1 on sup1.staff_info_id = hsi.staff_info_id
        group by 1
    ) a2 on a2.sys_store_id = a1.store_id
left join
    (
        select
            s1.store_id
            ,count(if(s1.job_title_id in (13,110,1199), s1.staff_info_id, null)) sup_courier_count
            ,count(if(s1.job_title_id in (37), s1.staff_info_id, null)) sup_dco_count
        from sup s1
        group by 1
    ) a3 on a3.store_id = a1.store_id
left join
    (
        select
            ds.dst_store_id
            ,count(distinct ds.pno) ds_count
            ,count(distinct if(pr.pno is not null , ds.pno, null)) sort_count
            ,count(distinct if(pr.pno is not null , ds.pno, null))/count(distinct ds.pno) sort_rate
        from dwm.dwd_my_dc_should_be_delivery ds
        left join my_staging.parcel_route pr on pr.pno = ds.pno and pr.route_action = 'SORTING_SCAN' and pr.routed_at >= date_sub('2023-09-21', interval 8 hour) and pr.routed_at < date_add('2023-09-21', interval 16 hour)
        group by 1
    ) a4 on a4.dst_store_id = a1.store_id
left join
    (
        select
            ds.dst_store_id
            ,count(distinct if(hsi.staff_info_id is not null, ds.pno, null))/count(distinct if(hsi.staff_info_id is not null, pi.ticket_delivery_staff_info_id, null)) self_effect
            ,count(distinct if(s1.sub_staff_info_id is not null, ds.pno, null))/count(distinct if(s1.sub_staff_info_id is not null, pi.ticket_delivery_staff_info_id, null)) other_effect
        from dwm.dwd_my_dc_should_be_delivery ds
        join my_staging.parcel_info pi on pi.pno = ds.pno
        left join sup s1 on s1.store_id = ds.dst_store_id and pi.ticket_delivery_staff_info_id = s1.sub_staff_info_id
        left join my_bi.hr_staff_info hsi on hsi.staff_info_id = pi.ticket_delivery_staff_info_id and hsi.formal = 1 and hsi.is_sub_staff = 0 and hsi.sys_store_id = ds.dst_store_id
        where
            pi.state = 5
            and pi.finished_at >= date_sub('2023-09-21', interval 8 hour)
            and pi.finished_at < date_add('2023-09-21', interval 16 hour)
            and pi.returned = 0
        group by 1
    ) a5 on a5.dst_store_id = a1.store_id
left join dwm.dim_my_sys_store_rd dt on dt.store_id = a1.store_id and dt.stat_date = date_sub(curdate(), interval 1 day);
;-- -. . -..- - / . -. - .-. -.--
with sup as
(
    select
        hsa.staff_info_id
        ,hsa.sub_staff_info_id
        ,hsa.store_id
        ,hsa.store_name
        ,hsa.staff_store_id
        ,hsa.job_title_id
    from my_backyard.hr_staff_apply_support_store hsa
    left join my_backyard.staff_work_attendance swa on hsa.sub_staff_info_id = swa.staff_info_id and swa.attendance_date = '2023-09-21' and swa.organization_id = hsa.store_id and ( swa.started_at is not null  or swa.end_at is not null )
    where
        hsa.actual_begin_date <= '2023-09-21'
        and coalesce(hsa.actual_end_date, curdate()) >= '2023-09-21'
        and hsa.employment_begin_date <= '2023-09-21'
        and coalesce(hsa.employment_end_date, curdate()) >= '2023-09-21'
#         and hsa.store_name = 'PRG_SP-บางปรอก'
        and hsa.status = 2
        and swa.id is not null
)
, total as
(
    select
        a.*
    from
        (
            select
                a1.dst_store_id
                ,a1.pno
                ,a1.sorting_code
                ,td.created_at td_time
                ,td.staff_info_id
                ,pi.state
                ,pi.finished_at
                ,pi.ticket_delivery_staff_info_id
                ,row_number() over (partition by td.pno order by td.created_at desc ) rn
            from
                (
                    select
                        a.*
                    from
                        (
                            select
                                ds.pno
                                ,ds.dst_store_id
                                ,ps.third_sorting_code sorting_code
                                ,row_number() over (partition by ps.pno order by ps.created_at desc ) rk
                            from dwm.dwd_my_dc_should_be_delivery ds
                            join my_drds_pro.parcel_sorting_code_info ps on ds.pno =  ps.pno and ds.dst_store_id = ps.dst_store_id
                        ) a
                    where
                        a.rk = 1
                ) a1
            join my_staging.ticket_delivery td on td.pno = a1.pno and td.created_at >= date_sub('2023-09-21', interval 8 hour) and td.created_at < date_add('2023-09-21', interval 16 hour)
            left join my_staging.parcel_info pi on pi.pno = a1.pno
        ) a
    where
        a.rn = 1
)
select
    dt.region_name 大区
    ,dt.piece_name 片区
    ,dt.store_name 来源网点
    ,dt2.store_name 支援网点
    ,s1.staff_info_id 主账号
    ,s1.sub_staff_info_id 子账号
    ,hjt.job_name  'van/bike'
    ,convert_tz(swa.started_at, '+00:00', '+08:00') 上班时间
    ,convert_tz(swa.end_at, '+00:00', '+08:00') 下班时间
    ,s3.pick_num 揽收量
    ,s2.scan_count 交接量
    ,s2.del_count 妥投量
    ,timestampdiff(minute , fir.finished_at, las.finished_at )/60 派送时长
    ,code.scan_code_count 交接三段码数量
    ,code.del_code_num 妥投三段码数量
    ,pho.0_count 未妥投中打电话次数为0的数量
    ,pho.1_count 未妥投中打电话次数为1的数量
from sup s1
left join dwm.dim_my_sys_store_rd dt on dt.store_id = s1.staff_store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
left join dwm.dim_my_sys_store_rd dt2 on dt2.store_id = s1.store_id and dt2.stat_date = date_sub(curdate(), interval 1 day)
left join my_bi.hr_job_title hjt on hjt.id = s1.job_title_id
left join my_backyard.staff_work_attendance swa on swa.staff_info_id = s1.sub_staff_info_id and swa.attendance_date = '2023-09-21' and swa.organization_id = s1.store_id
left join
    (
        select
            t1.staff_info_id
            ,count(distinct t1.pno) scan_count
            ,count(if(t1.state = 5, t1.pno, null)) del_count
        from total t1
        group by 1
    ) s2 on s2.staff_info_id = s1.sub_staff_info_id
left join
    (
        select
            s1.sub_staff_info_id
            ,count(distinct pi.pno) pick_num
        from my_staging.parcel_info pi
        join sup s1 on s1.sub_staff_info_id = pi.ticket_pickup_staff_info_id
        where
            pi.created_at >= date_sub('2023-09-21', interval 8 hour)
            and pi.created_at < date_add('2023-09-21', interval 16 hour)
        group by 1
    ) s3 on s3.sub_staff_info_id = s1.sub_staff_info_id
left join
    ( -- 第一次妥投时间
        select
            t1.*
            ,row_number() over (partition by t1.staff_info_id order by t1.finished_at ) rk
        from total t1
        where
            t1.state = 5
    ) fir on fir.staff_info_id = s1.sub_staff_info_id and fir.rk = 1
left join
    (
        select
            t1.*
            ,row_number() over (partition by t1.staff_info_id order by t1.finished_at desc ) rk
        from total t1
        where
            t1.state = 5
    ) las on las.staff_info_id = s1.sub_staff_info_id and las.rk = 2
left join
    (
        select
            t1.staff_info_id
            ,count(distinct t1.sorting_code) scan_code_count
            ,count(distinct if(t1.state = 5, t1.sorting_code, null)) del_code_num
        from total t1
        where
            t1.sorting_code not in ('XX', 'YY', 'ZZ', '00')
        group by 1
    ) code on code.staff_info_id = s1.sub_staff_info_id
left join
    (
        select
            a.staff_info_id
            ,count(if(a.call_times = 0, a.pno, null)) 0_count
            ,count(if(a.call_times = 1, a.pno, null)) 1_count
        from
            (
                select
                    t.staff_info_id
                    ,t.pno
                    ,count(pr.pno) call_times
                from total t
                join my_staging.parcel_route pr on pr.pno = t.pno and pr.route_action = 'PHONE' and pr.routed_at >= date_sub('2023-09-21', interval 8 hour) and pr.routed_at < date_add('2023-09-21', interval 16 hour)
                where
                    t.state != 5
                group by 1,2
            ) a
        group by 1
    ) pho on pho.staff_info_id = s1.sub_staff_info_id;
;-- -. . -..- - / . -. - .-. -.--
with sup as
(
    select
        hsa.staff_info_id
        ,hsa.sub_staff_info_id
        ,hsa.store_id
        ,hsa.store_name
        ,hsa.staff_store_id
        ,hsa.job_title_id
    from my_backyard.hr_staff_apply_support_store hsa
    left join my_backyard.staff_work_attendance swa on hsa.sub_staff_info_id = swa.staff_info_id and swa.attendance_date = '2023-09-26' and swa.organization_id = hsa.store_id and ( swa.started_at is not null  or swa.end_at is not null )
    where
#         hsa.actual_begin_date <= '${date}'
#         and coalesce(hsa.actual_end_date, curdate()) >= '${date}'
        hsa.employment_begin_date <= '2023-09-26'
        and coalesce(hsa.employment_end_date, curdate()) >= '2023-09-26'
#         and hsa.store_name = 'PRG_SP-บางปรอก'
        and hsa.status = 2
        and hsa.support_status between 2 and 3
#         and swa.id is not null
        and hsa.job_title_id in (13,110,1199,37)
)
, total as
(
    select
        a.*
    from
        (
            select
                a1.dst_store_id
                ,a1.pno
                ,a1.sorting_code
                ,td.created_at td_time
                ,td.staff_info_id
                ,pi.state
                ,pi.finished_at
                ,pi.ticket_delivery_staff_info_id
                ,row_number() over (partition by td.pno order by td.created_at desc ) rn
            from
                (
                    select
                        a.*
                    from
                        (
                            select
                                ds.pno
                                ,ds.dst_store_id
                                ,ps.third_sorting_code sorting_code
                                ,row_number() over (partition by ps.pno order by ps.created_at desc ) rk
                            from dwm.dwd_my_dc_should_be_delivery ds
                            join my_drds_pro.parcel_sorting_code_info ps on ds.pno =  ps.pno and ds.dst_store_id = ps.dst_store_id
                        ) a
                    where
                        a.rk = 1
                ) a1
            join my_staging.ticket_delivery td on td.pno = a1.pno and td.created_at >= date_sub('2023-09-26', interval 8 hour) and td.created_at < date_add('2023-09-26', interval 16 hour)
            left join my_staging.parcel_info pi on pi.pno = a1.pno
        ) a
    where
        a.rn = 1
)
select
    t1.大区, t1.片区, t1.网点, t1.当日应派, t1.当日妥投, t1.未妥投大件数量, t1.自有快递员人数（出勤）, t1.支援快递员人数（出勤）, t1.自有仓管, t1.支援仓管, t1.分拣扫描率, t1.自有人效, t1.支援人效
    ,t2.大区, t2.片区, t2.来源网点, t2.主账号, t2.子账号, t2.`van/bike`, t2.上班时间, t2.下班时间, t2.揽收量, t2.交接量, t2.妥投量, t2.派送时长, t2.交接三段码数量, t2.妥投三段码数量, t2.未妥投中打电话次数为0的数量, t2.未妥投中打电话次数为1的数量
from
    (
        select
            dt.region_name 大区
            ,dt.piece_name 片区
            ,dt.store_name 网点
            ,a1.today_should_del 当日应派
            ,a1.today_already_del 当日妥投
            ,a1.no_del_big_count 未妥投大件数量
            ,a2.courier_count 自有快递员人数（出勤）
            ,a3.sup_courier_count 支援快递员人数（出勤）
            ,a2.dco_count 自有仓管
            ,a3.sup_dco_count 支援仓管
            ,a4.sort_rate 分拣扫描率
            ,a5.self_effect 自有人效
            ,a5.other_effect 支援人效
        from
            ( -- 应派妥投
                select
                    ss.store_name
                    ,ss.store_id
                    ,count(distinct ds.pno) today_should_del
                    ,count(distinct if(pi.state = 5 and pi.finished_at >= date_sub('2023-09-26', interval 8 hour) and pi.finished_at < date_add('2023-09-26', interval  16 hour), ds.pno, null)) today_already_del
                    ,count(distinct if(pi.state != 5 and ( pi.exhibition_weight > 5000 or pi.exhibition_length + pi.exhibition_width + pi.exhibition_height > 80 ), ds.pno, null)) no_del_big_count
                from dwm.dwd_my_dc_should_be_delivery ds
                left join my_staging.parcel_info pi on ds.pno = pi.pno
                join
                    (
                        select
                            sup.store_id
                            ,sup.store_name
                        from sup
                        group by 1,2
                    ) ss on ss.store_id = ds.dst_store_id
                where
                    ds.p_date = '2023-09-26'
                    and ds.should_delevry_type != '非当日应派'
                group by 1,2
            ) a1
        left join
            (
                select
                    hsi.sys_store_id
                    ,count(distinct if(hsi.job_title in (13,110,1199) and sup1.staff_info_id is null, hsi.staff_info_id, null)) courier_count
                    ,count(distinct if(hsi.job_title in (37) and sup1.staff_info_id is null, hsi.staff_info_id, null)) dco_count
                from my_bi.hr_staff_info hsi
                join my_backyard.staff_work_attendance swa on swa.staff_info_id = hsi.staff_info_id and swa.attendance_date = '2023-09-26' and ( swa.started_at is not null or swa.end_at is not null)
                left join sup sup1 on sup1.sub_staff_info_id = hsi.staff_info_id
                group by 1
            ) a2 on a2.sys_store_id = a1.store_id
        left join
            (
                select
                    s1.store_id
                    ,count(if(s1.job_title_id in (13,110,1199), s1.staff_info_id, null)) sup_courier_count
                    ,count(if(s1.job_title_id in (37), s1.staff_info_id, null)) sup_dco_count
                from sup s1
                group by 1
            ) a3 on a3.store_id = a1.store_id
        left join
            (
                select
                    ds.dst_store_id
                    ,count(distinct ds.pno) ds_count
                    ,count(distinct if(pr.pno is not null , ds.pno, null)) sort_count
                    ,count(distinct if(pr.pno is not null , ds.pno, null))/count(distinct ds.pno) sort_rate
                from dwm.dwd_my_dc_should_be_delivery ds
                left join my_staging.parcel_route pr on pr.pno = ds.pno and pr.route_action = 'SORTING_SCAN' and pr.routed_at >= date_sub('2023-09-26', interval 8 hour) and pr.routed_at < date_add('2023-09-26', interval 16 hour)
                group by 1
            ) a4 on a4.dst_store_id = a1.store_id
        left join
            (
                select
                    ds.dst_store_id
                    ,count(distinct if(hsi.staff_info_id is not null and hsi.job_title in (13,110,1199), ds.pno, null))/count(distinct if(hsi.staff_info_id is not null and hsi.job_title in (13,110,1199), pi.ticket_delivery_staff_info_id, null)) self_effect
                    ,count(distinct if(s1.sub_staff_info_id is not null and s1.job_title_id in (13,110,1199), ds.pno, null))/count(distinct if(s1.sub_staff_info_id is not null and s1.job_title_id in (13,110,1199), pi.ticket_delivery_staff_info_id, null)) other_effect
                from dwm.dwd_my_dc_should_be_delivery ds
                join my_staging.parcel_info pi on pi.pno = ds.pno
                left join sup s1 on s1.store_id = ds.dst_store_id and pi.ticket_delivery_staff_info_id = s1.sub_staff_info_id
                left join my_bi.hr_staff_info hsi on hsi.staff_info_id = pi.ticket_delivery_staff_info_id and hsi.formal = 1 and hsi.is_sub_staff = 0 and hsi.sys_store_id = ds.dst_store_id
                where
                    pi.state = 5
                    and pi.finished_at >= date_sub('2023-09-26', interval 8 hour)
                    and pi.finished_at < date_add('2023-09-26', interval 16 hour)
                    and pi.returned = 0
                group by 1
            ) a5 on a5.dst_store_id = a1.store_id
        left join dwm.dim_my_sys_store_rd dt on dt.store_id = a1.store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
    ) t1
left join
    (
        select
            dt.region_name 大区
            ,dt.piece_name 片区
            ,dt.store_name 来源网点
            ,dt2.store_name 支援网点
            ,s1.staff_info_id 主账号
            ,s1.sub_staff_info_id 子账号
            ,hjt.job_name  'van/bike'
            ,convert_tz(swa.started_at, '+00:00', '+08:00') 上班时间
            ,convert_tz(swa.end_at, '+00:00', '+08:00') 下班时间
            ,s3.pick_num 揽收量
            ,s2.scan_count 交接量
            ,s2.del_count 妥投量
            ,timestampdiff(minute , fir.finished_at, las.finished_at )/60 派送时长
            ,code.scan_code_count 交接三段码数量
            ,code.del_code_num 妥投三段码数量
            ,pho.0_count 未妥投中打电话次数为0的数量
            ,pho.1_count 未妥投中打电话次数为1的数量
        from sup s1
        left join dwm.dim_my_sys_store_rd dt on dt.store_id = s1.staff_store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
        left join dwm.dim_my_sys_store_rd dt2 on dt2.store_id = s1.store_id and dt2.stat_date = date_sub(curdate(), interval 1 day)
        left join my_bi.hr_job_title hjt on hjt.id = s1.job_title_id
        left join my_backyard.staff_work_attendance swa on swa.staff_info_id = s1.sub_staff_info_id and swa.attendance_date = '2023-09-26' and swa.organization_id = s1.store_id
        left join
            (
                select
                    t1.staff_info_id
                    ,count(distinct t1.pno) scan_count
                    ,count(if(t1.state = 5, t1.pno, null)) del_count
                from total t1
                group by 1
            ) s2 on s2.staff_info_id = s1.sub_staff_info_id
        left join
            (
                select
                    s1.sub_staff_info_id
                    ,count(distinct pi.pno) pick_num
                from my_staging.parcel_info pi
                join sup s1 on s1.sub_staff_info_id = pi.ticket_pickup_staff_info_id
                where
                    pi.created_at >= date_sub('2023-09-26', interval 8 hour)
                    and pi.created_at < date_add('2023-09-26', interval 16 hour)
                group by 1
            ) s3 on s3.sub_staff_info_id = s1.sub_staff_info_id
        left join
            ( -- 第一次妥投时间
                select
                    t1.*
                    ,row_number() over (partition by t1.staff_info_id order by t1.finished_at ) rk
                from total t1
                where
                    t1.state = 5
            ) fir on fir.staff_info_id = s1.sub_staff_info_id and fir.rk = 1
        left join
            (
                select
                    t1.*
                    ,row_number() over (partition by t1.staff_info_id order by t1.finished_at desc ) rk
                from total t1
                where
                    t1.state = 5
            ) las on las.staff_info_id = s1.sub_staff_info_id and las.rk = 2
        left join
            (
                select
                    t1.staff_info_id
                    ,count(distinct t1.sorting_code) scan_code_count
                    ,count(distinct if(t1.state = 5, t1.sorting_code, null)) del_code_num
                from total t1
                where
                    t1.sorting_code not in ('XX', 'YY', 'ZZ', '00')
                group by 1
            ) code on code.staff_info_id = s1.sub_staff_info_id
        left join
            (
                select
                    a.staff_info_id
                    ,count(if(a.call_times = 0, a.pno, null)) 0_count
                    ,count(if(a.call_times = 1, a.pno, null)) 1_count
                from
                    (
                        select
                            t.staff_info_id
                            ,t.pno
                            ,count(pr.pno) call_times
                        from total t
                        join my_staging.parcel_route pr on pr.pno = t.pno and pr.route_action = 'PHONE' and pr.routed_at >= date_sub('2023-09-26', interval 8 hour) and pr.routed_at < date_add('2023-09-26', interval 16 hour)
                        where
                            t.state != 5
                        group by 1,2
                    ) a
                group by 1
            ) pho on pho.staff_info_id = s1.sub_staff_info_id
    ) t2 on t2.支援网点 = t1.网点;