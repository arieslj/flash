
-- lazada
select
    ss.name 始发网点
    ,pi.src_name 寄件人
    ,st_distance_sphere(point(ss.lng, ss.lat), point(ss2.lng, ss2.lat)) 始发网点妥投网点距离
    ,pi.dst_name 收件人
    ,sc.damage_cnt '12-1月合计破损判责量'
    ,date(convert_tz(pi.created_at, '+00:00', '+07:00')) 揽收日期
    ,cic.name 品类
    ,count(pi.pno) 包裹量
    ,sum(pi.exhibition_length * pi.exhibition_width * pi.exhibition_height / 1000000) 总体积
from fle_staging.parcel_info pi
join dwm.drds_th_lazada_order_item lz on lz.pno = pi.pno
left join fle_staging.customer_item_category cic on cic.category_id = lz.item_category
left join fle_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
left join fle_staging.sys_store ss2 on ss2.id = pi.ticket_delivery_store_id
left join
    (
        select
            pi2.src_name
            ,count(distinct pi2.pno) damage_cnt
        from bi_pro.parcel_lose_task plt
        left join fle_staging.parcel_info pi2 on pi2.pno = plt.pno
        where
            plt.state = 6
            and plt.duty_result = 2
        group by 1
    ) sc on sc.src_name = pi.src_name
where
    pi.created_at > '2024-11-30 17:00:00'
    and pi.created_at < '2025-01-22 17:00:00'
   -- and pi.created_at < '2024-12-31 17:00:00'
    and pi.state = 5
group by 1,2,3,4
having sum(pi.exhibition_length * pi.exhibition_width * pi.exhibition_height / 1000000) > 7

union

-- tiktok

select
    ss.name 始发网点
    ,pi.src_name 寄件人
    ,st_distance_sphere(point(ss.lng, ss.lat), point(ss2.lng, ss2.lat)) 始发网点妥投网点距离
    ,pi.dst_name 收件人
    ,sc.damage_cnt '12-1月合计破损判责量'
    ,date(convert_tz(pi.created_at, '+00:00', '+07:00')) 揽收日期
    ,cic.name 品类
    ,count(pi.pno) 包裹量
    ,sum(pi.exhibition_length * pi.exhibition_width * pi.exhibition_height / 1000000) 总体积
from fle_staging.parcel_info pi
join dwm.drds_tiktok_order_item tt on tt.pno = pi.pno
left join fle_staging.customer_item_category cic on cic.category_id = tt.category
left join fle_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
left join fle_staging.sys_store ss2 on ss2.id = pi.ticket_delivery_store_id
left join
    (
        select
            pi2.src_name
            ,count(distinct  pi2.pno) damage_cnt
        from bi_pro.parcel_lose_task plt
        left join fle_staging.parcel_info pi2 on pi2.pno = plt.pno
        where
            plt.state = 6
            and plt.duty_result = 2
        group by 1
    ) sc on sc.src_name = pi.src_name
where
    pi.created_at > '2024-11-30 17:00:00'
    and pi.created_at < '2025-01-22 17:00:00'
  --  and pi.created_at < '2024-12-31 17:00:00'
    and pi.state = 5
group by 1,2,3,4
having sum(pi.exhibition_length * pi.exhibition_width * pi.exhibition_height / 1000000) > 7

union

-- shopee
select
    ss.name 始发网点
    ,pi.src_name 寄件人
    ,st_distance_sphere(point(ss.lng, ss.lat), point(ss2.lng, ss2.lat)) 始发网点妥投网点距离
    ,pi.dst_name 收件人
    ,sc.damage_cnt '12-1月合计破损判责量'
    ,date(convert_tz(pi.created_at, '+00:00', '+07:00')) 揽收日期
    ,concat(sp.category, '-', sp.sub_category, '-', sp.sub_sub_category) 品类
    ,count(pi.pno) 包裹量
    ,sum(pi.exhibition_length * pi.exhibition_width * pi.exhibition_height / 1000000) 总体积
from fle_staging.parcel_info pi
join dwm.drds_th_shopee_item_info sp on sp.pno = pi.pno
left join fle_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
left join fle_staging.sys_store ss2 on ss2.id = pi.ticket_delivery_store_id
left join
    (
        select
            pi2.src_name
            ,count(distinct  pi2.pno) damage_cnt
        from bi_pro.parcel_lose_task plt
        left join fle_staging.parcel_info pi2 on pi2.pno = plt.pno
        where
            plt.state = 6
            and plt.duty_result = 2
        group by 1
    ) sc on sc.src_name = pi.src_name
where
    pi.created_at > '2024-11-30 17:00:00'
    and pi.created_at < '2025-01-22 17:00:00'
   -- and pi.created_at < '2024-12-31 17:00:00'
    and pi.state = 5
group by 1,2,3,4
having sum(pi.exhibition_length * pi.exhibition_width * pi.exhibition_height / 1000000) > 7


;


select
    date(plt.created_at) 日期
    ,count(plt.id) renwushu
from bi_pro.parcel_lose_task plt
where
    plt.source = 12
    and plt.created_at >= '2025-02-01'
group by    1