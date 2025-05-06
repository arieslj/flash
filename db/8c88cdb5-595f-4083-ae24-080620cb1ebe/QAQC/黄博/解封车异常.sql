select
    fvp.pno
    ,fvp.proof_id
from fle_staging.fleet_van_proof_sealing_abnormal fvs
join
    (
        select
            plt.pno
            ,fvp.proof_id
            ,row_number() over (partition by plt.pno order by fvp.created_at) rk
        from
            (
                select
                    distinct
                    plt.pno
                from bi_pro.parcel_lose_task plt
                where
                    plt.source in (1,3)
                    and plt.parcel_created_at > '2025-03-01'
                    and plt.state = 6
                    and plt.duty_result = 1
            ) plt
        left join fle_staging.fleet_van_proof_parcel_detail fvp on fvp.relation_no = plt.pno and fvp.relation_category in (1,3) and fvp.state < 3
        where
            fvp.created_at > '2025-02-01'
    ) fvp on fvp.proof_id = fvs.proof_id and fvp.rk = 1
where
    fvs.abnormal_type = 0
    and locate(fvs.abnormal_reasons, 1) > 0
    and fvs.created_at > '2025-01-01'