select
    min(plt.created_at) min_cr
    ,max(plt.created_at) max_cr
    ,min(plt.parcel_created_at) min_pick
    ,max(plt.parcel_created_at) max_pick
from ph_bi.parcel_lose_task plt
where
    plt.state = 6
    and plt.duty_result = 1
    and plt.updated_at >= '2023-05-01'
    and plt.updated_at < '2023-06-01';

select

    date(plt.parcel_created_at) max_pick
    ,count(plt.pno)
from ph_bi.parcel_lose_task plt
where
    plt.state = 6
    and plt.duty_result = 1
    and plt.updated_at >= '2023-05-01'
    and plt.updated_at < '2023-06-01'
    and date(plt.parcel_created_at) is null
group by 1;



with t as
(
    select
        plt.pno
    from ph_bi.parcel_lose_task plt
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
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'INVENTORY'
        group by 1
    ) inv on inv.pno = t1.pno

;


with t as
(
    select
        plt.pno
    from ph_bi.parcel_lose_task plt
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
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'DELIVERY_MARKER'
            and pr.marker_category in (9,14,70)
        group by 1
    ) inv on inv.pno = t1.pno

;


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
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as  ka_type
from ph_bi.parcel_lose_task plt
left join ph_staging.ka_profile kp on plt.client_id = kp.id
left join dwm.dwd_dim_bigClient bc on bc.client_id = plt.client_id
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
                from ph_staging.parcel_route pr
                join t t1 on t1.pno = pr.pno
                join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action' and ddd.remark = 'valid'
                where
                    pr.routed_at > date_sub(t1.updated_at, interval 8 hour)
                    and pr.routed_at > '2023-04-30 16:00:00'
                group by 1
            ) pr on pr.pno = t2.pno
    ) b
group by 1



;


