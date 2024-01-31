select
    a.p_month
    ,a.mw_num
    ,lz.staff_num
    ,kc.leave_num - lz.staff_num
from
    (
        select
            month(mw.created_at ) p_month
            ,count(mw.id) mw_num
        from ph_backyard.message_warning mw
        where
            mw.is_delete = 0
            and mw.created_at >= '2023-01-01'
        group by 1
    ) a
left join
    (
        select
            a.leave_month
            ,count(distinct a.staff_info_id) staff_num
        from
            (
                select
                    month(hsi.leave_date) leave_month
                    ,mw.staff_info_id
                    ,count(distinct mw.id) mw_num
                from ph_bi.hr_staff_info hsi
                left join ph_backyard.message_warning mw on mw.staff_info_id = hsi.staff_info_id and mw.is_delete = 0
                where
                    hsi.state = 2
                    and hsi.leave_date >= '2023-01-01'
                    and leave_type != 1
                group by 1,2
            ) a
        where
            a.mw_num >= 3
        group by 1
    ) lz on lz.leave_month = a.p_month
left join
    (
        select
            month(hsi2.leave_date) leave_month
            ,count(distinct hsi2.staff_info_id) leave_num
        from  ph_bi.hr_staff_info hsi2
        where
            hsi2.state = 2
            and hsi2.leave_type not in (1)
            and hsi2.leave_date >= '2023-01-01'
        group by 1
    ) kc on kc.leave_month = a.p_month
;



