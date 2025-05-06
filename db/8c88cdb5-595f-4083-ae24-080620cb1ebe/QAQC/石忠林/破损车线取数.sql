select
    t.*
    ,convert_tz(acs.routed_at, '+00:00', '+07:00') 责任网点车货关联到港时间
    ,json_extract(acs.extra_value, '$.vanLineName') 责任网点车货关联到港车线名称
    ,json_extract(acs.extra_value, '$.proofId') 责任网点车货关联到港出车凭证
    ,json_extract(acs.extra_value, '$.packPno') 责任网点车货关联到港集包号
    ,convert_tz(dcs.routed_at, '+00:00', '+07:00') 责任网点车货关联出港时间
    ,json_extract(dcs.extra_value, '$.vanLineName') 责任网点车货关联出港车线名称
    ,json_extract(dcs.extra_value, '$.proofId') 责任网点车货关联出港出车凭证
    ,json_extract(dcs.extra_value, '$.packPno') 责任网点车货关联出港集包号
    ,convert_tz(di.created_at, '+00:00', '+07:00') 第一次疑难件提交时间
    ,di.name 第一次疑难件提交网点
from tmpale.tmp_th_pno_lj_1113 t
left join
    ( -- 到港
        select
            pr.extra_value
            ,pr.pno
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
        from rot_pro.parcel_route pr
        join tmpale.tmp_th_pno_lj_1113 t2 on t2.pno = pr.pno and t2.duty_store = pr.store_name
        where
            pr.route_action = 'ARRIVAL_GOODS_VAN_CHECK_SCAN'
            and pr.routed_at > date_sub(curdate(), interval 2 month)
    ) acs on t.pno = acs.pno and acs.rk = 1
left join
    ( -- 出港
        select
            pr.extra_value
            ,pr.pno
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
        from rot_pro.parcel_route pr
        join tmpale.tmp_th_pno_lj_1113 t2 on t2.pno = pr.pno and t2.duty_store = pr.store_name
        where
            pr.route_action = 'DEPARTURE_GOODS_VAN_CK_SCAN'
            and pr.routed_at > date_sub(curdate(), interval 2 month)
    ) dcs on t.pno = dcs.pno and dcs.rk = 1
left join
    (
        select
            di.pno
            ,ss.name
            ,di.created_at
            ,row_number() over (partition by di.pno order by di.created_at) rk
        from fle_staging.diff_info di
        join tmpale.tmp_th_pno_lj_1113 t3 on t3.pno = di.pno
        left join fle_staging.sys_store ss on ss.id = di.store_id
        where
            di.created_at > date_sub(curdate(), interval 2 month)
    ) di on t.pno = di.pno and di.rk = 1
