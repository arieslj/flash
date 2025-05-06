select
    a1.pno
    ,convert_tz(pi.created_at ,'+00:00' ,'+08:00')  揽收时间
    ,b.updated_at 判责时间
    ,pi.client_id 客户ID
    ,a1.client_name 客户名称
from
    (
        select
            plt.pno
            ,plt.updated_at
            ,bc.client_name
        from my_bi.parcel_lose_task plt
        join my_bi.parcel_claim_task pct on pct.lose_task_id = plt.id
        join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pct.client_id
        where
            plt.created_at > '2024-01-01'
            and plt.state = 6
            and plt.duty_result = 1
            and plt.penalties > 0
    ) a1
join
    (
        select
            plt.pno
            ,plt.updated_at
        from my_bi.parcel_lose_task plt
        where
            plt.created_at > '2024-01-01'
            and plt.state = 6
            and plt.duty_result = 1
            and plt.penalties > 0
    ) b on b.pno = a1.pno
left join my_staging.parcel_info pi on pi.pno = a1.pno
where
    a1.updated_at < b.updated_at
    and pi.state in (1,2,3,4,6)