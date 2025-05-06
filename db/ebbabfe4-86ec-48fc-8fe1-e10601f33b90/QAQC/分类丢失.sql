select
    t.pno
    ,case
        when a1.pno is not null then '真实丢失'
        when a2.pno is not null then '真实破损'
        when a3.pno is not null then '超时效丢失'
        when pi.pno is null then '揽收前丢失'
        else null
    end fenlei
from tmpale.tmp_my_lj_pno_0222 t
left join
    (
        select
            plt.pno
        from my_bi.parcel_lose_task plt
        join tmpale.tmp_my_lj_pno_0222 t on t.pno = plt.pno
        where
            plt.state = 6
            and plt.duty_result = 1
        group by plt.pno
    ) a1 on t.pno = a1.pno
left join
    (
        select
            plt.pno
        from my_bi.parcel_lose_task plt
        join tmpale.tmp_my_lj_pno_0222 t on t.pno = plt.pno
        where
            plt.state = 6
            and plt.duty_result = 2
        group by plt.pno
    ) a2 on t.pno = a2.pno
left join
    (
        select
            plt.pno
        from my_bi.parcel_lose_task plt
        join tmpale.tmp_my_lj_pno_0222 t on t.pno = plt.pno
        where
            plt.state = 6
            and plt.duty_result = 3
        group by plt.pno
    ) a3 on t.pno = a3.pno
left join my_staging.parcel_info pi on pi.pno = t.pno

;
