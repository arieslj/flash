-- 文档链接： https://flashexpress.feishu.cn/docx/HRksdfXXvoYEWux77bCc8dzCnSX

select
    t.date 日期
    ,t.客户类型
    ,t.client_id
    ,t.归属部门
    ,t.归属网点
    ,t.销售代表
    ,t.项目经理
    ,t.运费结算方式
    ,t.目前下单状态
    ,t.账号创建日期
    ,10d.days_count 10月寄件天数
    ,11d.days_count 11月寄件天数
    ,pi.pick_count 当日揽收数量
    ,shd.should_count 当日揽收数量
    ,shd.handover_count 当日交接量
    ,rej.rej_count 当日标记拒收数量
    ,rej.reurn_reject_count 当日拒收且生成退件数量
    ,rej.no_buy_count '拒收原因为“未购买”量'
    ,rej2.other_reason_count 当日标记其他原因
    ,sign.sign_count 当日妥投数量
from
    (
        select
            c.*
            ,d.date
        from
            (
                select
                     t.client_id
                    ,'KA' 客户类型
                    ,if(kp.forbid_call_order = 0, '否', '是') 目前下单状态
                    ,sd.name 归属部门
                    ,ss2.name 归属网点
                    ,kp.staff_info_name 销售代表
                    ,si.name 项目经理
                    ,case kp.settlement_category
                        when 1 then '现结'
                        when 2 then '定结'
                    end  运费结算方式
                    ,date(convert_tz(kp.created_at, '+00:00', '+07:00')) 账号创建日期
                from fle_staging.ka_profile kp
                join tmpale.tmp_th_client_lj_1213 t on t.client_id = kp.id
                left join fle_staging.sys_department sd on sd.id = kp.department_id
                left join fle_staging.sys_store ss2 on ss2.id = kp.store_id
                left join fle_staging.staff_info si on si.id = kp.project_manager_id

                union all

                select
                   t.client_id
                    ,'小c' 客户类型
                    ,if(ui.forbid_call_order = 0, '否', '是') 目前下单状态
                    ,'' 归属部门
                    ,'' 归属网点
                    ,'' 销售代表
                    ,'' 项目经理
                    ,'现结' 运费结算方式
                    ,date(convert_tz(ui.created_at, '+00:00', '+07:00')) 账号创建日期
                from fle_staging.user_info ui
                join tmpale.tmp_th_client_lj_1213 t on t.client_id = ui.id
            ) c
        cross join
            (
                select
                    ot.date
                from tmpale.ods_th_dim_date ot
                where
                    ot.date >= '2023-10-01'
                    and ot.date < '2023-12-01'
            ) d
    ) t
left join
    ( -- 揽收
        select
            t.client_id
            ,date(convert_tz(pi.created_at, '+00:00', '+07:00')) pick_date
            ,count(distinct pi.pno) pick_count
        from fle_staging.parcel_info pi
        join tmpale.tmp_th_client_lj_1213 t on t.client_id = pi.client_id
        where
            pi.created_at > '2023-09-30 17:00:00'
            and pi.created_at < '2023-11-30 17:00:00'
            and pi.state < 9
        group by 1,2
    ) pi on pi.client_id = t.client_id and pi.pick_date = t.date
left join
    (
        select
            t.client_id
            ,10d.stat_date
            ,count(distinct 10d.pno) should_count
            ,count(if(10d.handover_scan_route_at is not null, 10d.pno, null)) handover_count
        from bi_pro.dc_should_delivery_2023_10 10d
        join tmpale.tmp_th_client_lj_1213 t on t.client_id = 10d.client_id
        group by 1,2

        union all

        select
            t.client_id
            ,11d.stat_date
            ,count(distinct 11d.pno) should_count
            ,count(distinct if(11d.handover_scan_route_at is not null, 11d.pno, null)) handover_count
        from bi_pro.dc_should_delivery_2023_11 11d
        join tmpale.tmp_th_client_lj_1213 t on t.client_id = 11d.client_id
        group by 1,2
    ) shd on shd.client_id = t.client_id and shd.stat_date = t.date
left join
    (
        select
            date(convert_tz(pr.routed_at, '+00:00', '+07:00')) pr_date
            ,t.client_id
            ,count(distinct pr.pno) rej_count
            ,count(distinct if(json_extract(pr.extra_value, '$.rejectionCategory') = 1, pr.pno, null)) no_buy_count
            ,count(distinct if(pi.state = 7 and pi2.created_at < date_add(date(convert_tz(pr.routed_at, '+00:00', '+07:00')), interval 17 hour) and pi2.created_at >= date_sub(date(convert_tz(pr.routed_at, '+00:00', '+07:00')), interval 7 hour), pi.pno, null)) reurn_reject_count
        from rot_pro.parcel_route pr
        left join fle_staging.parcel_info pi on pi.pno = pr.pno
        join tmpale.tmp_th_client_lj_1213 t on t.client_id = pi.client_id
        left join fle_staging.parcel_info pi2 on pi2.pno = pi.returned_pno
        where
            pr.routed_at > '2023-09-30 17:00:00'
            and pr.routed_at < '2023-11-30 17:00:00'
            and pr.marker_category = 2 -- 收件人拒收标记
        group by 1,2
    ) rej on rej.client_id = t.client_id and rej.pr_date = t.date
left join
    (
        select
           t1.client_id
            ,t1.pr_date
            ,count(distinct t1.pno) other_reason_count
        from
           (
                select
                    date(convert_tz(pr.routed_at, '+00:00', '+07:00')) pr_date
                    ,t.client_id
                    ,pr.pno
                from rot_pro.parcel_route pr
                left join fle_staging.parcel_info pi on pi.pno = pr.pno
                join tmpale.tmp_th_client_lj_1213 t on t.client_id = pi.client_id
                where
                    pr.routed_at > '2023-09-30 17:00:00'
                    and pr.routed_at < '2023-11-30 17:00:00'
                    and pr.marker_category = 2
                    and ( json_extract(pr.extra_value, '$.rejectionCategory') > 1  or json_extract(pr.extra_value, '$.rejectionCategory') is null )
                group by 1,2,3
           ) t1
        left join
            (
                select
                    date(convert_tz(pr.routed_at, '+00:00', '+07:00')) pr_date
                    ,t.client_id
                    ,pr.pno
                from rot_pro.parcel_route pr
                left join fle_staging.parcel_info pi on pi.pno = pr.pno
                join tmpale.tmp_th_client_lj_1213 t on t.client_id = pi.client_id
                where
                    pr.routed_at > '2023-09-30 17:00:00'
                    and pr.routed_at < '2023-11-30 17:00:00'
                    and pr.marker_category = 2
                    and json_extract(pr.extra_value, '$.rejectionCategory') = 1
                group by 1,2,3
            ) t2 on t1.client_id = t2.client_id and t1.pr_date = t2.pr_date and t1.pno = t2.pno
        where
            t2.pno is null
        group by 1,2
    ) rej2 on rej2.client_id = t.client_id and rej2.pr_date = t.date
left join
    (
        select
            t.client_id
            ,date(convert_tz(pi.finished_at, '+00:00', '+07:00')) fin_date
            ,count(distinct pi.pno) sign_count
        from fle_staging.parcel_info pi
        join tmpale.tmp_th_client_lj_1213 t on t.client_id = pi.client_id
        where
            pi.finished_at > '2023-09-30 17:00:00'
            and pi.finished_at < '2023-11-30 17:00:00'
            and pi.state = 5
        group by 1,2
    ) sign on sign.client_id = t.client_id and sign.fin_date = t.date
left join
    (
        select
            pi.client_id
            ,count(distinct date(convert_tz(pi.created_at, '+00:00', '+07:00'))) days_count
        from fle_staging.parcel_info pi
        join tmpale.tmp_th_client_lj_1213 t on t.client_id = pi.client_id
        where
            pi.created_at >= '2023-09-30 17:00:00'
            and pi.created_at < '2023-10-31 17:00:00'
            and pi.state < 9
        group by 1
    ) 10d on 10d.client_id = t.client_id
left join
    (
        select
            pi.client_id
            ,count(distinct date(convert_tz(pi.created_at, '+00:00', '+07:00'))) days_count
        from fle_staging.parcel_info pi
        join tmpale.tmp_th_client_lj_1213 t on t.client_id = pi.client_id
        where
            pi.created_at >= '2023-10-31 17:00:00'
            and pi.created_at < '2023-11-30 17:00:00'
            and pi.state < 9
        group by 1
    ) 11d on 11d.client_id = t.client_id


;

select
    pr.*
from rot_pro.parcel_route pr
left join fle_staging.parcel_info pi on pi.pno = pr.pno
where
    -- pr.marker_category = 2
    pr.routed_at > '2023-11-22 17:00:00'
    and pr.routed_at < '2023-11-23 17:00:00'
    and pi.client_id = 'CAY9826'