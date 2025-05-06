select
    case ss2.category
        when 1 then 'SP'
        when 2 then 'DC'
        when 4 then 'SHOP'
        when 5 then 'SHOP'
        when 6 then 'FH'
        when 7 then 'SHOP'
        when 8 then 'Hub'
        when 9 then 'Onsite'
        when 10 then 'BDC'
        when 11 then 'fulfillment'
        when 12 then 'B-HUB'
        when 13 then 'CDC'
        when 14 then 'PDC'
    end 网点类型
    ,count(distinct pi.pno) 包裹数
#     ,pi2.pno
from ph_staging.parcel_info pi
left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
left join ph_staging.parcel_info pi2 on pi2.pno = pi.returned_pno
left join ph_staging.sys_store ss2 on ss2.id = pi2.dst_store_id
where
    pi.created_at > date_sub(date_sub(curdate(), interval 30 day ), interval 8 hour)
    and ss.category = 14
    and pi.returned_pno is not null
    and ss2.category = 9
group by 1

;


select
    a.store_name
    ,count(distinct if(a.stay_hour < 3, a.pno, null)) 3小时内
    ,count(distinct if(a.stay_hour >= 3 and a.stay_hour < 5, a.pno, null)) 3_5小时
    ,count(distinct if(a.stay_hour >= 5 and a.stay_hour < 12, a.pno, null)) 5_12小时
    ,count(distinct if(a.stay_hour >= 12 and a.stay_hour < 24, a.pno, null)) 12_24小时
    ,count(distinct if(a.stay_hour > 24, a.pno, null)) 24小时以上
from
    (
        select
            store_name
            ,pno
            ,timestampdiff(minute, pssn.arrived_at, pssn.shipped_at)/60 stay_hour
        from dw_dmd.parcel_store_stage_new pssn
        where
            pssn.created_at >= date_sub(curdate(), interval 7 day )
            and pssn.store_category = 8
    ) a
group by 1