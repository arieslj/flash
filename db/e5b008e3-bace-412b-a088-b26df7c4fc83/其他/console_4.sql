
with t as
(
    select
        t.pno
        ,vrv.type
        ,vrv.visit_staff_id
    from tmpale.tmp_ph_pno_0814 t
    left join nl_production.violation_return_visit vrv on vrv.link_id = t.pno
)
select
    t1.pno
    ,if(t3.pno is not null, '是', '否') 是否进入拒收回访
    ,if(t4.pno is not null, '是', '否') 是否进入拒收ivr回访
    ,if(t5.pno is not null, '是', '否') 是否进入三次尝试派送回访
    ,if(t6.pno is not null, '是', '否') 是否进入三次尝试派送ivr回访
from
    (
        select
            t1.pno
        from t t1
        group by 1
    )t1
left join
    (
        select
            t1.pno
        from t t1
        where
            t1.type = 3
        group by 1
    ) t3 on t3.pno = t1.pno
left join
    (
        select
            t1.pno
        from t t1
        where
            t1.type = 3
            and t1.visit_staff_id = 10001
        group by 1
    ) t4 on t4.pno = t1.pno
left join
    (
        select
            t1.pno
        from t t1
        where
            t1.type = 8
        group by 1
    ) t5 on t5.pno = t1.pno
left join
    (
        select
            t1.pno
        from t t1
        where
            t1.type = 8
            and t1.visit_staff_id = 10001
        group by 1
    ) t6 on t6.pno = t1.pno