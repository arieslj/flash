select
    pssn.pno
    ,pssn.van_in_proof_id
    ,pssn.arrival_pack_no
    ,pssn.van_arrived_at
from dw_dmd.parcel_store_stage_new pssn
join
    (
        select
            pr.pno
            ,pr.store_id
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_lj_0105 t on t.pno = pr.pno
        where
            pr.routed_at > date_sub(curdate(), interval 2 month )
            and pr.route_action = 'HAVE_HAIR_SCAN_NO_TO'
#             and pr.pno = 'P182039XS5ABM'
        group by 1,2
    ) ha on ha.store_id = pssn.store_id and ha.pno = pssn.pno
