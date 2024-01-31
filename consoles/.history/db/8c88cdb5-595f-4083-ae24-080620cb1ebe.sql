SELECT DATE_SUB(CURDATE(), INTERVAL (DAYOFYEAR(CURDATE()) - 1) DAY) AS first_day_of_current_year;
;-- -. . -..- - / . -. - .-. -.--
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
    ,if(if(hsi.is_sub_staff = 1, hsi2.state, hsi.state) = 2, 'Y', 'N') 最后一次交接员工是否离职
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
left join bi_pro.hr_staff_info hsi2 on hsi2.staff_info_id = hsa.staff_info_id;
;-- -. . -..- - / . -. - .-. -.--
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
left join bi_pro.hr_staff_info hsi2 on hsi2.staff_info_id = hsa.staff_info_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            convert_tz(di.created_at, '+00:00', '+07:00') diff_time
            ,date( convert_tz(di.created_at, '+00:00', '+07:00')) diff_date
            ,di.pno
        from fle_staging.diff_info di
        left join fle_staging.parcel_info pi on pi.pno = di.pno
        where
            di.created_at > '2023-12-31 17:00:00'
            and di.diff_marker_category = 17
            and pi.client_id in ('AA0660', 'AA0661', 'AA0703', 'AA0823', 'AA0824')
    )
select
    t1.diff_date
    ,count(distinct t1.pno) as total
    ,count(distinct if(acc.pno is not null or vr.pno is not null, t1.pno, null))/count(distinct t1.pno) rate
from t t1
left join
    (
        select
            acc.pno
        from bi_pro.abnormal_customer_complaint acc
        join t t1 on t1.pno = acc.pno
        where
            acc.created_at > t1.diff_time
            and acc.complaints_sub_type = 61 -- 拒收投诉
            and acc.created_at > '2023-12-01'
        group by 1
    ) acc on acc.pno = t1.pno
left join
    (
        select
            t1.pno
        from nl_production.violation_return_visit vrv
        join t t1 on t1.pno = vrv.link_id
        where
            vrv.type = 3
            and vrv.created_at > '2023-12-31'
            and vrv.created_at > t1.diff_time
            and vrv.visit_result in (18,8,19,20,21,22,31,32)
        group by 1
    ) vr on vr.pno = t1.pno
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            convert_tz(di.created_at, '+00:00', '+07:00') diff_time
            ,date( convert_tz(di.created_at, '+00:00', '+07:00')) diff_date
            ,di.store_id
            ,di.pno
        from fle_staging.diff_info di
        left join fle_staging.parcel_info pi on pi.pno = di.pno
        where
            di.created_at > '2023-12-31 17:00:00'
            and di.diff_marker_category = 17
            and pi.client_id in ('AA0660', 'AA0661', 'AA0703', 'AA0823', 'AA0824')
    )
select
    t1.diff_time 上报问题件时间
    ,t1.pno 运单号
    ,dt.store_name 上报网点
    ,dt.piece_name 片区
    ,dt.region_name 大区
    ,if(acc.pno is not null, 'Y', 'N') 是否被投诉虚假拒收
    ,if(vr.pno is not null, 'Y', 'N') 是否回访确认虚假拒收
from t t1
left join dwm.dim_th_sys_store_rd dt on dt.store_id = t1.store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
left join
    (
        select
            acc.pno
        from bi_pro.abnormal_customer_complaint acc
        join t t1 on t1.pno = acc.pno
        where
            acc.created_at > t1.diff_time
            and acc.complaints_sub_type = 61 -- 拒收投诉
            and acc.created_at > '2023-12-01'
        group by 1
    ) acc on acc.pno = t1.pno
left join
    (
        select
            t1.pno
        from nl_production.violation_return_visit vrv
        join t t1 on t1.pno = vrv.link_id
        where
            vrv.type = 3
            and vrv.created_at > '2023-12-31'
            and vrv.created_at > t1.diff_time
            and vrv.visit_result in (18,8,19,20,21,22,31,32)
        group by 1
    ) vr on vr.pno = t1.pno
where
    acc.pno is not null
    or vr.pno is not null;
;-- -. . -..- - / . -. - .-. -.--
select
    min(plt.created_at)
from bi_pro.parcel_lose_task plt;
;-- -. . -..- - / . -. - .-. -.--
select
    t.id
    ,case ci.channel_category # 渠道
         when 0 then '电话'
         when 1 then '电子邮件'
         when 2 then '网页'
         when 3 then '网点'
         when 4 then '自主投诉页面'
         when 5 then '网页（facebook）'
         when 6 then 'APPSTORE'
         when 7 then 'Lazada系统'
         when 8 then 'Shopee系统'
         when 9 then 'TikTok'
    end  问题渠道
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as 客户类型
    ,case plt.state
        when 1 then '待处理'   -- 待处理
        when 2 then '待处理' -- 待处理
        when 3 then '待工单回复'  -- 待工单回复
        when 4 then '已工单回复' -- 已工单回复
        when 5 then '无须追责'  -- 无须追责
        when 6 then '责任人已认定' -- 责任人已认定
    end 闪速最终判责结果
    ,if(pct.pno is not null, 'Y', 'N' ) 最终是否丢失理赔
from bi_pro.parcel_lose_task plt
join tmpale.tmp_th_plt_task_id_0131 t on t.task_id = plt.id
left join fle_staging.customer_issue ci on ci.id = plt.source_id
left join fle_staging.ka_profile kp on kp.id = plt.client_id
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = plt.client_id
left join bi_pro.parcel_claim_task pct on pct.pno = plt.pno and pct.state = 6;
;-- -. . -..- - / . -. - .-. -.--
select
    concat('SSRD', t.task_id) id
    ,case ci.channel_category # 渠道
         when 0 then '电话'
         when 1 then '电子邮件'
         when 2 then '网页'
         when 3 then '网点'
         when 4 then '自主投诉页面'
         when 5 then '网页（facebook）'
         when 6 then 'APPSTORE'
         when 7 then 'Lazada系统'
         when 8 then 'Shopee系统'
         when 9 then 'TikTok'
    end  问题渠道
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as 客户类型
    ,case plt.state
        when 1 then '待处理'   -- 待处理
        when 2 then '待处理' -- 待处理
        when 3 then '待工单回复'  -- 待工单回复
        when 4 then '已工单回复' -- 已工单回复
        when 5 then '无须追责'  -- 无须追责
        when 6 then '责任人已认定' -- 责任人已认定
    end 闪速最终判责结果
    ,if(pct.pno is not null, 'Y', 'N' ) 最终是否丢失理赔
from bi_pro.parcel_lose_task plt
join tmpale.tmp_th_plt_task_id_0131 t on t.task_id = plt.id
left join fle_staging.customer_issue ci on ci.id = plt.source_id
left join fle_staging.ka_profile kp on kp.id = plt.client_id
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = plt.client_id
left join bi_pro.parcel_claim_task pct on pct.pno = plt.pno and pct.state = 6;