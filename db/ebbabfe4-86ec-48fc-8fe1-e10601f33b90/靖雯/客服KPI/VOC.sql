with a as
    (
        select
            wo.created_staff_info_id 工号
            ,count(if(timestampdiff(hour, wo.created_at, wo.closed_at) < 72, wo.id, null)) / count(wo.id) 72H工单关闭率
        from my_bi.work_order wo
        where
            wo.created_staff_info_id in ('120072', '129113', '141135', '141258')
            and wo.created_at > date_format(date_sub(curdate(), interval 1 month), '%Y-%m-01')
            and wo.created_at < date_format(curdate(), '%Y-%m-01')
            and ( wo.status in (1,2,3) or ( wo.status = 4 and wo.closed_at is not null ))
        group by 1
    )
, b as
    (
        select
            a1.staff
            ,count(a1.clue_sn) 分配线索数
            ,count(if(a1.deal_time < a1.dead_line_time, a1.clue_sn, null)) 及时联系线索数
            ,count(if(a1.deal_time < a1.dead_line_time, a1.clue_sn, null)) / count(a1.clue_sn) 新客户回访率
        from
            (
                select
                    a.clue_sn
                    ,a.flash_user_id staff
                    ,convert_tz(a.created_at, '+00:00', '+08:00') task_created_at
                    ,convert_tz(a.shelve_time, '+00:00', '+08:00') deal_time
                    ,date_format(curdate(), '%Y-%m-01') dead_line_time
                from
                    (
                        select
                            sc.clue_sn
                            ,su.flash_user_id
                            ,scm.created_at
                            ,sc.shelve_time
                            ,row_number() over (partition by sc.clue_sn order by scm.created_at desc) rk
                        from my_spm.spm_clue sc
                        left join my_spm.spm_users su on su.id = sc.check_uid
                        left join my_spm.spm_clue_modify_records scm on scm.clue_sn = sc.clue_sn and scm.type = 2 and scm.new_value = sc.check_uid
                        where
                            1 = 1
                          --  and sc.department = 15008 -- voc
                            and su.flash_user_id in ('120072', '129113', '141135', '141258')
                            and sc.deleted = 0
                            and sc.created_at > date_sub(date_format(date_sub(curdate(), interval 2 year), '%Y-%m-01'), interval 8 hour)
                            and sc.created_at < date_sub(date_format(curdate(), '%Y-%m-01'), interval 8 hour)
                    ) a
                where
                    a.rk = 1
                    and a.created_at > date_sub(date_sub(date_format(date_sub(curdate(), interval 1 month), '%Y-%m-01'), interval 2 day), interval 8 hour)
                    and a.created_at < date_sub(date_sub(date_format(curdate(), '%Y-%m-01'), interval 2 day), interval 8 hour)
            ) a1
        group by 1
    )

select
    sta.staff
    ,a1.72H工单关闭率
    ,b1.新客户回访率
from
    (
        select a1.工号 staff from a a1 group by 1
        union
        select b1.staff from b b1 group by 1
    ) sta
left join a a1 on a1.工号 = sta.staff
left join b b1 on b1.staff = sta.staff


;

-- shopee
select
    count(sp.pno) 应揽收量
    ,count(if(sp.act_pk_time < date_add(sp.stat_date, interval 1 day), sp.pno, null)) 及时揽收量
    ,count(if(sp.act_pk_time < date_add(sp.stat_date, interval 1 day), sp.pno, null)) / count(sp.pno) 揽收及时率
from dwm.dws_my_should_pickup_shopee_detl_s sp
where
    sp.stat_date >= date_format(date_sub(curdate(), interval 1 month), '%Y-%m-01')
    and sp.stat_date < date_format(curdate(), '%Y-%m-01')

;


-- lazada

select
    count(la.pno) 应揽收量
    ,count(if(la.first_try_date <= la.should_pk_time_t0 OR la.act_pk_time <= la.should_pk_time_t0, la.pno, null))  及时揽收量
    ,count(if(la.first_try_date <= la.should_pk_time_t0 OR la.act_pk_time <= la.should_pk_time_t0, la.pno, null))  / count(la.pno) 揽收及时率
from dwm.dws_my_should_pickup_lazada_detl_s la
where
    la.stat_date >= date_format(date_sub(curdate(), interval 1 month), '%Y-%m-01')
    and la.stat_date < date_format(curdate(), '%Y-%m-01')


;

-- tiktok


select
    count(tt.pno) 应揽收量
    ,count(if(tt.state = 2, tt.pno, null))  及时揽收量
    , count(if(tt.state = 2, tt.pno, null)) / count(tt.pno) 揽收及时率
from dwm.dws_my_should_pickup_tiktok_detl_s tt
where
    tt.stat_date > date_format(date_sub(curdate(), interval 1 month), '%Y-%m-01')
    and tt.stat_date < date_format(curdate(), '%Y-%m-01')


;


select
    wo.created_staff_info_id 工号
    ,month(wo.created_at) 月份
    ,count(if(timestampdiff(hour, wo.created_at, wo.closed_at) < 72, wo.id, null)) / count(wo.id) 72H工单关闭率
from my_bi.work_order wo
where
    wo.created_staff_info_id in ('120072', '129113', '141135', '141258')
#     and wo.created_at > date_format(date_sub(curdate(), interval 1 month), '%Y-%m-01')
#     and wo.created_at < date_format(curdate(), '%Y-%m-01')
    and wo.created_at > '2024-12-01'
    and wo.created_at < '2024-12-06'
    and ( wo.status in (1,2,3) or ( wo.status = 4 and wo.closed_at is not null ))
group by 1,2



;



select
#     count(la.pno) 应揽收量
    la.pno
    ,la.first_try_date 首次尝试揽收时间
    ,la.act_pk_time      实际揽收时间
    ,la.should_pk_time_t0  应揽收时间t0
#     ,count(if(la.first_try_date <= la.should_pk_time_t0 OR la.act_pk_time <= la.should_pk_time_t0, la.pno, null))  及时揽收量
#     ,count(if(la.first_try_date <= la.should_pk_time_t0 OR la.act_pk_time <= la.should_pk_time_t0, la.pno, null))  / count(la.pno) 揽收及时率
from dwm.dws_my_should_pickup_lazada_detl_s la
where
    la.stat_date >= date_format(date_sub(curdate(), interval 1 month), '%Y-%m-01')
    and la.stat_date < date_format(curdate(), '%Y-%m-01')