select
    t.pno
    ,if(pi.returned = 1, dai.returned_delivery_attempt_num, dai.delivery_attempt_num) 有效尝试派件次数
    ,if(ha.pno is not null, 'Y', 'N') 是否上报有发无到
    ,mis.pr_cnt 上报地址错分次数
    ,gy.gy_cnt  最近30天改约次数
    ,inv.inv_cnt 最近30天盘库次数
    ,sor.sor_cnt 最近30天分拣次数
    ,if(c.pno is not null, 'Y', 'N') 是否在C来源中未处理
    ,if(l.pno is not null, 'Y', 'N') 是否在L来源中未处理
    ,if(a.pno is not null, 'Y', 'N') 是否在A来源中未处理
    ,if(pcl.pno is not null, 'Y', 'N') 是否认定过责任人
    ,pcl.created_at 第一次认定责任人时间
    ,bkk.routed_at 换单并发往拍卖仓时间
    ,sct.task_state 闪速判案结果
   -- ,if(if(hsi.is_sub_staff = 1, hsi2.state, hsi.state) = 2, 'Y', 'N') 最后一次交接员工是否离职
    ,case if(hsi.is_sub_staff = 1, hsi2.state, hsi.state)
        when 1 then '在职'
        when 2 then '离职'
        when 3 then '停职'
    end 最后一次交接员工状态
from tmpale.tmp_th_pno_backlog_0130 t
left join fle_staging.parcel_info pi on pi.pno = t.pno
left join fle_staging.delivery_attempt_info dai on dai.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
left join
    (
        select
            pr.pno
        from rot_pro.parcel_route pr
        join tmpale.tmp_th_pno_backlog_0130 t on t.pno = pr.pno
        where
            pr.routed_at >= '2024-01-29 17:00:00'
            and pr.route_action = 'HAVE_HAIR_SCAN_NO_TO'
        group by 1
    ) ha on ha.pno = t.pno
left join
    (
        select
            pr.pno
            ,count(pr.id) pr_cnt
        from rot_pro.parcel_route pr
        join tmpale.tmp_th_pno_backlog_0130 t on t.pno = pr.pno
        where
            pr.routed_at >= date_sub(curdate(),interval 2 month)
            and pr.marker_category = 31
        group by 1
    ) mis on mis.pno = t.pno
left join
    (
        select
            pr.pno
            ,count(distinct pr.pd_date) gy_cnt
        from
            (
                select
                    ppd.pno
                    ,date(convert_tz(ppd.created_at, '+00:00','+07:00')) pd_date
                from fle_staging.parcel_problem_detail ppd
                join tmpale.tmp_th_pno_backlog_0130 t on t.pno = ppd.pno
                where
                    ppd.created_at > date_sub(date_sub(curdate(), interval 1 month), interval 7 hour)
                    and ppd.diff_marker_category = 14
                    and ppd.parcel_problem_type_category = 2
            ) pr
        group by 1
    ) gy on gy.pno = t.pno
left join
    (
        select
            pr.pno
            ,count(distinct pr.pd_date) inv_cnt
        from
            (
                select
                    pr.pno
                    ,date(convert_tz(pr.routed_at, '+00:00','+07:00')) pd_date
                from rot_pro.parcel_route pr
                join tmpale.tmp_th_pno_backlog_0130 t on t.pno = pr.pno
                where
                    pr.routed_at > date_sub(date_sub(curdate(), interval 1 month), interval 7 hour)
                    and pr.route_action = 'INVENTORY'
            ) pr
        group by 1
    ) inv on inv.pno = t.pno
left join
    (
        select
            pr.pno
            ,count(distinct pr.pd_date) sor_cnt
        from
            (
                select
                    pr.pno
                    ,date(convert_tz(pr.routed_at, '+00:00','+07:00')) pd_date
                from rot_pro.parcel_route pr
                join tmpale.tmp_th_pno_backlog_0130 t on t.pno = pr.pno
                where
                    pr.routed_at > date_sub(date_sub(curdate(), interval 1 month), interval 7 hour)
                    and pr.route_action = 'SORTING_SCAN'
            ) pr
        group by 1
    ) sor on sor.pno = t.pno
left join
    (
        select
            plt.pno
        from bi_pro.parcel_lose_task plt
        join tmpale.tmp_th_pno_backlog_0130 t on t.pno = plt.pno
        where
            plt.state in (1,2,3,4)
            and plt.source = 3
            and plt.created_at > date_sub(curdate(), interval 2 month)
        group by 1
    ) c on c.pno = t.pno
left join
    (
        select
            plt.pno
        from bi_pro.parcel_lose_task plt
        join tmpale.tmp_th_pno_backlog_0130 t on t.pno = plt.pno
        where
            plt.state in (1,2,3,4)
            and plt.source = 12
            and plt.created_at > date_sub(curdate(), interval 2 month)
        group by 1
    ) l on l.pno = t.pno
left join
    (
        select
            plt.pno
        from bi_pro.parcel_lose_task plt
        join tmpale.tmp_th_pno_backlog_0130 t on t.pno = plt.pno
        where
            plt.state in (1,2,3,4)
            and plt.source = 1
            and plt.created_at > date_sub(curdate(), interval 2 month)
        group by 1
    ) a on a.pno = t.pno
left join
    (
        select
            plt.pno
            ,pcol.created_at
            ,row_number() over (partition by plt.pno order by pcol.created_at ) rn
        from bi_pro.parcel_lose_task plt
        join tmpale.tmp_th_pno_backlog_0130 t on t.pno = plt.pno
        join bi_pro.parcel_cs_operation_log pcol on pcol.task_id = plt.id and pcol.action = 4
    ) pcl on pcl.pno = t.pno and pcl.rn = 1
left join
    (
        select
            pr.pno
            ,convert_tz(pr.routed_at, '+00:00','+07:00') routed_at
        from rot_pro.parcel_route pr
        join tmpale.tmp_th_pno_backlog_0130 t on t.pno = pr.pno
        where
            pr.routed_at >= date_sub(curdate(),interval 2 month)
            and pr.route_action = 'DISCARD_RETURN_BKK'
    ) bkk on bkk.pno = t.pno
left join
    (
        select
            sct.pno
            ,case sct.state
                when 1 then '待处理'
                when 2 then '不属实'
                when 3 then '属实'
                when 4 then '待处理-联系不到客户'
                when 5 then '已处理-联系不到客户'
            end task_state
        from bi_pro.ss_court_task sct
        join tmpale.tmp_th_pno_backlog_0130 t on t.pno = sct.pno
    ) sct on sct.pno = t.pno
left join
    (
        select
            pr.pno
            ,pr.staff_info_id
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rn
        from rot_pro.parcel_route pr
        join tmpale.tmp_th_pno_backlog_0130 t on t.pno = pr.pno
        where
            pr.routed_at >= date_sub(curdate(),interval 2 month)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    ) sc on sc.pno = t.pno and sc.rn = 1
left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = sc.staff_info_id
left join backyard_pro.hr_staff_apply_support_store hsa on hsa.sub_staff_info_id = sc.staff_info_id
left join bi_pro.hr_staff_info hsi2 on hsi2.staff_info_id = hsa.staff_info_id



