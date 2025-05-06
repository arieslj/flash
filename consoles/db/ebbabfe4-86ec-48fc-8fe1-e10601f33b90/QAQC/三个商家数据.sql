select
    pick.client_name 客户
    ,pick.avg_date_pick 日均揽收量
    ,los.pno_cnt 丢失量
    ,dam.pno_cnt 破损量
from
    (
        select
            a1.client_name
            ,count(distinct a1.pno)/count(distinct a1.pick_date) avg_date_pick
        from
            (
                select
                    case
                        when pi.src_name = 'Allgoodthings' and pi.src_phone = '0182044409' then 'Allgoodthings'
                        when pi.src_name = 'Floofy' and pi.src_phone = '0182992741' then 'Floofy'
                        when pi.src_name = 'RedPanda' and pi.src_phone = '0182992741' then 'RedPanda'
                        else 'Unknown'
                    end client_name
                    ,date(convert_tz(pi.created_at, '+00:00', '+08:00')) pick_date
                    ,pi.pno
                from my_staging.parcel_info pi
                where
                    pi.created_at > '2023-12-31 16:00:00'
                    and pi.returned = 0
                    and pi.src_name in ('Allgoodthings', 'Floofy', 'RedPanda')
                    and pi.src_phone in ('0182044409', '0182992741', '0182992741')
            ) a1
        group by 1
    ) pick
left join
    (
        select
            case
                when pi.src_name = 'Allgoodthings' and pi.src_phone = '0182044409' then 'Allgoodthings'
                when pi.src_name = 'Floofy' and pi.src_phone = '0182992741' then 'Floofy'
                when pi.src_name = 'RedPanda' and pi.src_phone = '0182992741' then 'RedPanda'
                else 'Unknown'
            end client_name
            ,count(distinct plt.pno) pno_cnt
        from my_bi.parcel_lose_task plt
        join my_staging.parcel_info pi on pi.pno = plt.pno and pi.src_name in ('Allgoodthings', 'Floofy', 'RedPanda') and pi.src_phone in ('0182044409', '0182992741', '0182992741')
        where
            plt.updated_at >= '2023-12-31'
            and plt.state = 6
            and plt.duty_result = 1
        group by 1
    ) los on pick.client_name = los.client_name
left join
    (
        select
            case
                when pi.src_name = 'Allgoodthings' and pi.src_phone = '0182044409' then 'Allgoodthings'
                when pi.src_name = 'Floofy' and pi.src_phone = '0182992741' then 'Floofy'
                when pi.src_name = 'RedPanda' and pi.src_phone = '0182992741' then 'RedPanda'
                else 'Unknown'
            end client_name
            ,count(distinct plt.pno) pno_cnt
        from my_bi.parcel_lose_task plt
        join my_staging.parcel_info pi on pi.pno = plt.pno and pi.src_name in ('Allgoodthings', 'Floofy', 'RedPanda') and pi.src_phone in ('0182044409', '0182992741', '0182992741')
        where
            plt.updated_at >= '2023-12-31'
            and plt.state = 6
            and plt.duty_result = 2
        group by 1
    ) dam on pick.client_name = dam.client_name

;

select
    case
        when pi.src_name = 'Allgoodthings' and pi.src_phone = '0182044409' then 'Allgoodthings'
        when pi.src_name = 'Floofy' and pi.src_phone = '0182992741' then 'Floofy'
        when pi.src_name = 'RedPanda' and pi.src_phone = '0182992741' then 'RedPanda'
        else 'Unknown'
    end 客户
    ,plt.pno
    ,plt.updated_at 判责时间
from my_bi.parcel_lose_task plt
join my_staging.parcel_info pi on pi.pno = plt.pno and pi.src_name in ('Allgoodthings', 'Floofy', 'RedPanda') and pi.src_phone in ('0182044409', '0182992741', '0182992741')
where
    plt.updated_at >= '2023-12-31'
    and plt.state = 6
    and plt.duty_result = 1
group by 1,2,3