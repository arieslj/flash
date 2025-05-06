select
    a.*
from
    (
                select
            ps.third_sorting_code
            ,ps.sorting_code
            ,ps.pno
            ,row_number() over (partition by ps.pno order by ps.created_at desc ) rk
        from ph_drds.parcel_sorting_code_info ps
        join tmpale.tmp_ph_pno_lj_0605 t on t.pno = ps.pno
    ) a
where
    a.rk = 1