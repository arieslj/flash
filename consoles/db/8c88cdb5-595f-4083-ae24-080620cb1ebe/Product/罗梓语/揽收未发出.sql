select
   min(plt.parcel_created_at)
from bi_pro.parcel_lose_task plt
left join fle_staging.parcel_info pi on pi.pno = plt.pno
where
    plt.state in (1,2)
;

select
    t.id
    ,plt.last_valid_routed_at
from bi_pro.parcel_lose_task plt
join tmpale.tmp_th_plt_lj_0628 t on t.id = plt.id

;



select
    date (convert_tz(di.created_at, '+00:00', '+07:00')) p_date
    ,count(distinct di.pno) pno_cnt
from
    (
        select
            di.pno
            ,di.created_at
            ,row_number() over (partition by di.pno order by di.created_at ) rk
        from
          fle_staging.diff_info di
        where
            di.diff_marker_category = 17
            and di.created_at > '2024-05-31 17:00:00'
    ) di
where
    di.rk = 1
group by 1

