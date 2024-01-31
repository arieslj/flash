with t as
(
    select
        pr.pno
        ,pr.store_id
        ,pr.routed_at
        ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
    from ph_staging.parcel_info pi
    left join ph_staging.parcel_route  pr on pi.pno = pr.pno and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    where
        pr.routed_at is not null
        and pi.state not in (5,7,8,9)
        and pr.routed_at < '2023-08-13 16:00:00'
        and pi.dst_store_id in ('PH77190100','PH73090800','PH73020100','PH77030100','PH77050A00','PH76120H00','PH74060200','PH76090C00','PH74010100','PH76040A00','PH73030300','PH76190100','PH74120A00','PH75060200','PH51050301','PH47170100','PH51050500','PH49040100','PH51030400','PH51020J00','PH47140200','PH49040102','PH47210100','PH51100100','PH47080301','PH51080100','PH49040101','PH47070A00','PH47200600','PH47120100','PH47150100','PH51080101','PH51120B01','PH45210101','PH45212600','PH50100100','PH46020100','PH45130F00','PH46050101','PH45200H00','PH44020100','PH44180100','PH46150100','PH45210100','PH45010100','PH44010T00','PH50100200','PH45140300','PH14010F00','PH14010F00','PH22130500','PH23100300')
)
select
    t1.pno
    ,ss.name
    ,pi.state
from t t1
left join
    (
        select
            t1.pno
            ,ppd.created_at
            ,row_number() over (partition by ppd.pno order by ppd.created_at desc ) rk
        from ph_staging.parcel_problem_detail ppd
        join t t1 on t1.pno = ppd.pno
    ) t2 on t2.pno = t1.pno and t2.rk = 1
left join ph_staging.sys_store ss on ss.id = t1.store_id
left join ph_staging.parcel_info pi on pi.pno = t1.pno
where
    t1.routed_at > t2.created_at
    or t2.created_at is null

;


select
    pr.pno
    ,ss.name
#         ,pr.routed_at
#         ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
from ph_staging.parcel_info pi
left join ph_staging.parcel_route  pr on pi.pno = pr.pno and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
left join ph_staging.sys_store ss on ss.id = pi.dst_store_id
where
    pr.routed_at is not null
    and pi.state  = 3
#         and pr.routed_at < '2023-08-13 16:00:00'
    and pi.dst_store_id in ('PH77190100','PH73090800','PH73020100','PH77030100','PH77050A00','PH76120H00','PH74060200','PH76090C00','PH74010100','PH76040A00','PH73030300','PH76190100','PH74120A00','PH75060200','PH51050301','PH47170100','PH51050500','PH49040100','PH51030400','PH51020J00','PH47140200','PH49040102','PH47210100','PH51100100','PH47080301','PH51080100','PH49040101','PH47070A00','PH47200600','PH47120100','PH47150100','PH51080101','PH51120B01','PH45210101','PH45212600','PH50100100','PH46020100','PH45130F00','PH46050101','PH45200H00','PH44020100','PH44180100','PH46150100','PH45210100','PH45010100','PH44010T00','PH50100200','PH45140300','PH14010F00','PH14010F00','PH22130500','PH23100300')
group by 1,2