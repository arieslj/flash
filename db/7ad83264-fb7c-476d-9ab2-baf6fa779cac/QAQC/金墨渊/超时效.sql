select
    *
from ph_bi.parcel_lose_task plt
where
    plt.source = 11
    and plt.created_at >

;


select
    plt.pno
    ,count(pr.id) 交接次数
from
    (
        select
            plt.pno
            ,plt.created_at
            ,date_sub(plt.created_at, interval 8 hour) plt_at
        from ph_bi.parcel_lose_task plt
        where
            plt.source = 11
            and plt.created_at > '2024-10-01'
            and plt.created_at < '2024-11-01'
    ) plt
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,pr.id
        from ph_staging.parcel_route pr
        where
            pr.routed_at > '2024-09-30 16:00:00'
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    ) pr on pr.pno = plt.pno
where
    pr.routed_at > plt.plt_at
group by plt.pno

;



select
    plt.pno
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
from ph_bi.parcel_lose_task plt
left join ph_staging.parcel_info pi on pi.pno = plt.pno
where
    plt.source = 11
    and plt.created_at > '2024-10-01'
    and plt.created_at < '2024-11-01'