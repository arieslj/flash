select
    fv.proof_id
    ,pi.pno
    ,fv.proof_id
    ,pi.created_at
    ,pi.exhibition_weight/1000 as weight
            ,concat_ws('*', pi.exhibition_length, pi.exhibition_width, pi.exhibition_height) as size
from fle_staging.parcel_info pi
join fle_staging.fleet_van_proof_parcel_detail fv on fv.relation_no = pi.pno and fv.relation_category in (1,3)
where
    pi.created_at > '2024-08-17 11:00:00'
 --   and pi.created_at < '2024-08-17 12:00:00'
    and pi.client_id = 'CP4775'
    and fv.proof_id in ('BKK135XR72', 'BKK137HJ63', 'BKK138FQ54')