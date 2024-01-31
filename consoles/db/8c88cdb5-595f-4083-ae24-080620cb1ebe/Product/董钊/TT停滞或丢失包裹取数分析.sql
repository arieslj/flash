with t as
    (
        select
            t.return_pno
            ,t.pno
            ,pi.ticket_pickup_store_id return_ticket_pickup_store_id
            ,pi.dst_store_id renturn_dst_store_id
            ,pi.state return_state
            ,pi.dst_name return_dst_name
        from fle_staging.parcel_info pi
        join tmpale.tmp_th_pno_lj_1222 t on t.return_pno = pi.pno
        where
            pi.created_at > date_sub(curdate(), interval 2 month )
    )

select
    t1.pno
    ,t1.return_pno
    ,case cod.forward_state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end 正向包裹最后状态
    ,cod.cod cod金额
    ,pick_ss.name 退件包裹揽收网点
    ,convert_tz(ship.routed_at, '+00:00', '+08:00') 退件包裹发件出仓时间
    ,convert_tz(los.routed_at, '+00:00', '+08:00') 退件包裹上报丢失时间
    ,los.staff_info_id 上报丢失员工工号
    ,if(los.remark = 'SS Judge Auto Created For Overtime', '是', '否') 是否系统自动上报
    ,los.ss_name 退件包裹上报丢失员工所属网点
    ,dst_ss.name 退件包裹目的地网点
    ,coalesce(dst_time.van_arrived_at, dst_time.first_valid_routed_at) 退件包裹到达目的地网点时间
    ,sca.scan_count 退件包裹交接次数
    ,convert_tz(sca.routed_at, '+00:00', '+08:00') 退件包裹第一次交接时间
    ,sca.staff_info_id 退件包裹第一次交接员工工号
    ,sca.ss_name 退件包裹第一次交接员工所属网点
    ,case t1.return_state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end 退件包裹最后状态
    ,t1.return_dst_name  退件包裹收件人姓名
    ,dif.CN_element '退件包裹最后一次疑难件/留仓件提交原因'
    ,convert_tz(dif.created_at, '+00:00', '+08:00') '退件包裹最后一次疑难件/留仓件提交时间'
    ,dif.staff_info_id '退件包裹最后一次疑难件/留仓件提交员工'
    ,dif.ss_name '退件包裹最后一次疑难件/留仓件提交员工所属网点'
    ,if(clo.return_pno is not null, '是', '否')  退件包裹是否在LAS妥投
from t t1
left join
    (
        select
            t.pno
            ,pi.cod_amount/100 cod
            ,pi.state forward_state
        from fle_staging.parcel_info pi
        join tmpale.tmp_th_pno_lj_1222 t on t.pno = pi.pno
    ) cod on cod.pno = t1.pno
left join fle_staging.sys_store pick_ss on pick_ss.id = t1.return_ticket_pickup_store_id
left join
    (
        select
            t1.return_pno
            ,pr.routed_at
            ,row_number() over (partition by t1.return_pno order by pr.routed_at desc) rk
        from rot_pro.parcel_route pr
        join t t1 on t1.return_pno = pr.pno and pr.store_id = t1.return_ticket_pickup_store_id
        where
            pr.routed_at > date_sub(curdate(), interval 2 month )
            and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
    ) ship on ship.return_pno = t1.return_pno and ship.rk = 1
left join
    (
        select
            t1.return_pno
            ,pr.routed_at
            ,pr.remark
            ,pr.staff_info_id
            ,ss.name ss_name
            ,row_number() over (partition by t1.return_pno order by pr.routed_at ) rk
        from rot_pro.parcel_route pr
        join t t1 on t1.return_pno = pr.pno
        left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = pr.staff_info_id
        left join fle_staging.sys_store ss on ss.id = hsi.sys_store_id
        where
            pr.routed_at > date_sub(curdate(), interval 2 month )
            and pr.route_action = 'DIFFICULTY_HANDOVER'
            and pr.marker_category = 22
    ) los on los.return_pno = t1.return_pno and los.rk = 1
left join fle_staging.sys_store dst_ss on dst_ss.id = t1.renturn_dst_store_id
left join
    (
        select
            t1.return_pno
            ,pssn.first_valid_routed_at
            ,pssn.van_arrived_at
            ,row_number() over (partition by t1.return_pno order by pssn.first_valid_routed_at) rk
        from dw_dmd.parcel_store_stage_new pssn
        join t t1 on t1.return_pno = pssn.pno and t1.renturn_dst_store_id = pssn.store_id
        where
            pssn.created_at > date_sub(curdate(), interval 2 month )
    ) dst_time on dst_time.return_pno = t1.return_pno and dst_time.rk = 1
left join
    (
        select
            t1.return_pno
            ,pr.routed_at
            ,pr.staff_info_id
            ,ss.name ss_name
            ,count() over (partition by t1.return_pno) scan_count
            ,row_number() over (partition by t1.return_pno order by pr.routed_at) rk
        from rot_pro.parcel_route pr
        join t t1 on t1.return_pno = pr.pno
        left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = pr.staff_info_id
        left join fle_staging.sys_store ss on ss.id = hsi.sys_store_id
        where
            pr.routed_at > date_sub(curdate(), interval 2 month )
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    ) sca on sca.return_pno = t1.return_pno and sca.rk = 1
left join
    (
        select
            t1.return_pno
            ,pr.created_at
            ,pr.staff_info_id
            ,ss.name ss_name
            ,ddd.CN_element
            ,row_number() over (partition by t1.return_pno order by pr.created_at desc) rk
        from fle_staging.parcel_problem_detail pr
        join t t1 on t1.return_pno = pr.pno
        left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = pr.staff_info_id
        left join fle_staging.sys_store ss on ss.id = hsi.sys_store_id
        left join dwm.dwd_dim_dict ddd on ddd.db = 'fle_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
        where
            pr.created_at > date_sub(curdate(), interval 2 month )
    ) dif on dif.return_pno = t1.return_pno and dif.rk = 1
left join
    (
        select
            t1.return_pno
        from rot_pro.parcel_route pr
        join t t1 on t1.return_pno = pr.pno
        where
            pr.routed_at > date_sub(curdate(), interval 2 month )
            and pr.store_id = 'TH02030204'
            and pr.route_action = 'CHANGE_PARCEL_CLOSE'
        group by 1
    ) clo on clo.return_pno = t1.return_pno