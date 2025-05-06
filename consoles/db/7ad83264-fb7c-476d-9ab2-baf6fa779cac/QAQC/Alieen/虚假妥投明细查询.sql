select
    pi.pno 运单号
    ,concat(pi.client_id, '(', kp.name, ')') 客户ID
    ,pi.cod_amount/100 包裹的COD金额
    ,if(bc.client_name = 'lazada', pi.insure_declare_value, pai.cogs_amount)/100 包裹的COGS金额
    ,pi.exhibition_weight/1000 重量
    ,concat_ws('*', pi.exhibition_length, pi.exhibition_width, pi.exhibition_height) 尺寸
    ,concat(pi.client_id, '(', kp.name, ')') 'Customer Name（客户ID+客户名称）'
    ,concat(pi.src_name, ' ', pi.src_phone)  正向单号的Sender
    ,concat(pi.dst_name, ' ', pi.dst_phone) 正向单号的Recipient
    ,pick_ss.name as  原单号揽收网点
    ,if(pick_ss.category = 6, coalesce(pr3.store_name, pr4.store_name), null) 真实揽收网点
    ,if(pick_ss.category = 6, coalesce(pr3.staff_info_id, pr4.staff_info_id), null) 真实揽收员工
    ,fin_ss.name as 标记妥投网点
    ,convert_tz(pi.created_at, '+00:00', '+08:00') 揽收时间
    ,convert_tz(td.delivery_at, '+00:00', '+08:00') 妥投包裹交接扫描时间
    ,if(pi.state = 5, convert_tz(pi.finished_at, '+00:00', '+08:00'), null) 包裹妥投时间
    ,pi.ticket_pickup_staff_info_id 揽收员工ID
    ,case
        when hsi.`state`=1 and hsi.`wait_leave_state`=0 then '在职'
        when hsi.`state`=1 and hsi.`wait_leave_state`=1 then '待离职'
        when hsi.`state`=2 then '离职'
        when hsi.`state`=3 then '停职'
    end as 在职状态
    ,hsi2.staff_info_id 标记妥投快递员ID
    ,case
        when hsi2.`state`=1 and hsi2.`wait_leave_state`=0 then '在职'
        when hsi2.`state`=1 and hsi2.`wait_leave_state`=1 then '待离职'
        when hsi2.`state`=2 then '离职'
        when hsi2.`state`=3 then '停职'
    end as 在职状态
    ,hsi2.name  标记妥投快递员姓名
    ,hsi2.hire_date 标记妥投快递员入职日期
    ,hsi2.leave_date 标记妥投快递员离职日期
    ,if(pho.call_cnt > 0 , '是', '否') 标记妥投当天妥投快递员是否联系过收件人
    ,pho.call_cnt 当天联系次数
    ,case
        when pho.min_xl > 9 then '是'
        when pho.min_xl <= 9 and pho.min_xl > 0 then '否'
        else null
    end '响铃时间是否全部没达到9秒（妥投当天）'
    ,case
        when pho.sum_th > 0 and pho.min_xl > 0 then '是'
        when pho.sum_th = 0 and pho.min_xl > 0 then '否'
        else null
    end '联系的状态（接通与否）'
    ,if(plt2.pno is not null, '是', '否' ) 包裹是否疑似丢失_C来源
    ,if(plt3.pno is not null, '是', '否' ) 包裹是否疑似丢失_L来源
    ,st_distance_sphere(point(pi.ticket_delivery_staff_lng, pi.ticket_delivery_staff_lat), point(fin_ss.lng, fin_ss.lat)) 包裹妥投地址距离我方网点距离
    ,case plt.duty_result
        when 1 then '丢失'
        when 2 then '破损'
        when 3 then '超时效'
	end 判责结果
    ,sc.sc_cnt 交接天数
    ,coalesce(loi.item_name, soi.item_name, toi.product_name) 包裹内务
    ,pcn.monkey 客户申请理赔金额
    ,pcn2.monkey 实际理赔金额
from  ph_staging.parcel_info pi
left join ph_staging.parcel_additional_info pai on pai.pno = pi.pno
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
left join ph_staging.ka_profile kp on kp.id = pi.client_id
left join ph_staging.sys_store pick_ss on pick_ss.id = pi.ticket_pickup_store_id
left join ph_staging.sys_store fin_ss on fin_ss.id = pi.ticket_delivery_store_id
left join ph_staging.ticket_delivery td on td.id = pi.ticket_delivery_id
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pi.ticket_pickup_staff_info_id
left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = pi.ticket_delivery_staff_info_id
left join
    (
        select
            pr.pno
            ,count(pr.id) call_cnt
            ,min(ifnull(cast(json_extract(pr.extra_value, '$.diaboloDuration') as int), 0)) min_xl
            ,sum(ifnull(cast(json_extract(pr.extra_value, '$.callDuration') as int ), 0)) sum_th
        from ph_staging.parcel_route pr
        join ph_staging.parcel_route pr2 on pr2.pno = pr.pno and pr.route_action = 'PHONE'
        where
            pr.route_action = 'DELIVERY_CONFIRM'
            and pr2.routed_at > date_sub(curdate(), interval 2 month)
            and pr2.routed_at > date_sub(date(convert_tz(pr.routed_at, '+00:00', '+08:00')), interval 8 hour)
            and pr2.routed_at < date_add(date(convert_tz(pr.routed_at, '+00:00', '+08:00')), interval 16 hour)
            and pr.pno in ('${SUBSTITUTE(SUBSTITUTE(p2,"\n",","),",","','")}')
        group by 1
    ) pho on pho.pno = pi.pno
left join
    (
        select
            plt.pno
            ,plt.duty_result
        from ph_bi.parcel_lose_task plt
        where
            plt.state = 6
            and plt.penalties > 0
            and plt.pno in ('${SUBSTITUTE(SUBSTITUTE(p2,"\n",","),",","','")}')
    ) plt on plt.pno = pi.pno
left join
    (
        select
            pr.pno
            ,count(distinct date(convert_tz(pr.routed_at, '+00:00', '+08:00'))) sc_cnt
        from ph_staging.parcel_route pr
        where
            pr.pno in ('${SUBSTITUTE(SUBSTITUTE(p2,"\n",","),",","','")}')
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        group by 1
    ) sc on sc.pno = pi.pno
left join
    (
        select
            a1.*
        from
            (
                select
                    pct.pno
                    ,json_extract(pcn.neg_result,'$.money') monkey
                    ,row_number() over (partition by pcn.task_id order by pcn.created_at ) rk
                from ph_bi.parcel_claim_negotiation pcn
                left join ph_bi.parcel_claim_task pct on pcn.task_id = pct.id
                where
                    pct.parcel_created_at >= date_sub(curdate(), interval 3 month)
                    and pcn.neg_type in (5,6,7)
                    and pct.pno in ('${SUBSTITUTE(SUBSTITUTE(p2,"\n",","),",","','")}')
                    and json_extract(pcn.neg_result,'$.money') is not null
            ) a1
        where
            a1.rk = 1
    ) pcn on pcn.pno = pi.pno
left join
    (
        select
            a1.*
        from
            (
                select
                    pct.pno
                    ,json_extract(pcn.neg_result,'$.money') monkey
                    ,row_number() over (partition by pcn.task_id order by pcn.created_at ) rk
                from ph_bi.parcel_claim_negotiation pcn
                left join ph_bi.parcel_claim_task pct on pcn.task_id = pct.id
                where
                    pct.parcel_created_at >= date_sub(curdate(), interval 3 month)
                    and pct.state = 6
                   -- and pcn.neg_type in (5,6,7)
                    and pct.pno in ('${SUBSTITUTE(SUBSTITUTE(p2,"\n",","),",","','")}')
                    and json_extract(pcn.neg_result,'$.money') is not null
            ) a1
        where
            a1.rk = 1
    ) pcn2 on pcn2.pno = pi.pno
left join ph_bi.parcel_lose_task plt2 on plt2.pno = pi.pno and plt2.source = 3 and plt2.state < 5 and plt2.parcel_created_at > date_sub(curdate(), interval 3 month)
left join ph_bi.parcel_lose_task plt3 on plt3.pno = pi.pno and plt3.source = 11 and plt3.state < 5 and plt3.parcel_created_at > date_sub(curdate(), interval 3 month)
left join ph_staging.parcel_route pr3 on pr3.pno = pi.pno and pr3.route_action = 'FLASH_HOME_SCAN' and pr3.routed_at > date_sub(curdate(), interval 3 month)
left join ph_staging.parcel_route pr4 on pr4.pno = pi.pno and pr4.route_action = 'RECEIVE_WAREHOUSE_SCAN' and pr4.routed_at > date_sub(curdate(), interval 3 month)
left join dwm.drds_ph_lazada_order_info_d loi on loi.pno = pi.pno
left join dwm.drds_ph_shopee_item_info soi on soi.pno = pi.pno
left join dwm.dwd_ph_tiktok_order_item toi on toi.pno = pi.pno
where
    pi.returned = 0
    and pi.pno in ('${SUBSTITUTE(SUBSTITUTE(p2,"\n",","),",","','")}')


;


-- 退件包裹

select
    pi.pno 运单号
    ,ori_pi.pno 正向单号
    ,ori_pi.cod_amount/100 包裹的COD金额
    ,if(bc.client_name = 'lazada', pi.insure_declare_value, pai.cogs_amount)/100 包裹的COGS金额
    ,pi.exhibition_weight/1000 重量
    ,concat_ws('*', pi.exhibition_length, pi.exhibition_width, pi.exhibition_height) 尺寸
    ,concat(pi.client_id, '(', kp.name, ')') 'Customer Name（客户ID+客户名称）'
    ,ori_pi.src_name  正向单号的Sender
    ,ori_pi.dst_name 正向单号的Recipient
    ,pick_ss.name as  退件揽收网点
    ,fw_pick_ss.name 正向包裹揽收网点
    ,if(fw_pick_ss.category = 6, coalesce(pr3.store_name, pr4.store_name), null) 真实揽收网点
    ,if(fw_pick_ss.category = 6, coalesce(pr3.staff_info_id, pr4.staff_info_id), null) 真实揽收员工
    ,fin_ss.name as 退件标记妥投网点
    ,convert_tz(pi.created_at, '+00:00', '+08:00') 退件揽收时间
    ,convert_tz(ori_pi.created_at, '+00:00', '+08:00') 正向包裹揽收时间
    ,convert_tz(td.delivery_at, '+00:00', '+08:00') 退件妥投包裹交接扫描时间
    ,if(pi.state = 5, convert_tz(pi.finished_at, '+00:00', '+08:00'), null) 退件包裹妥投时间
    ,pi.ticket_pickup_staff_info_id 退件揽收员工ID
    ,case
        when hsi.`state`=1 and hsi.`wait_leave_state`=0 then '在职'
        when hsi.`state`=1 and hsi.`wait_leave_state`=1 then '待离职'
        when hsi.`state`=2 then '离职'
        when hsi.`state`=3 then '停职'
    end as 退件揽收员工在职状态
    ,hsi2.staff_info_id 退件标记妥投快递员ID
    ,case
        when hsi2.`state`=1 and hsi2.`wait_leave_state`=0 then '在职'
        when hsi2.`state`=1 and hsi2.`wait_leave_state`=1 then '待离职'
        when hsi2.`state`=2 then '离职'
        when hsi2.`state`=3 then '停职'
    end as 退件标记妥投快递员在职状态
    ,ori_pi.ticket_pickup_staff_info_id 正向揽收员工ID
    ,case
        when hsi3.`state`=1 and hsi3.`wait_leave_state`=0 then '在职'
        when hsi3.`state`=1 and hsi3.`wait_leave_state`=1 then '待离职'
        when hsi3.`state`=2 then '离职'
        when hsi3.`state`=3 then '停职'
    end  正向揽收员工在职状态
    ,hsi2.name  退件标记妥投快递员姓名
    ,hsi2.hire_date 退件标记妥投快递员入职日期
    ,hsi2.leave_date 退件标记妥投快递员离职日期
    ,if(pho.call_cnt > 0 , '是', '否') 标记妥投当天妥投快递员是否联系过收件人
    ,pho.call_cnt 当天联系次数
    ,case
        when pho.min_xl > 9 then '是'
        when pho.min_xl <= 9 and pho.min_xl > 0 then '否'
        else null
    end '响铃时间是否全部没达到9秒（妥投当天）'
    ,case
        when pho.sum_th > 0 and pho.min_xl > 0 then '是'
        when pho.sum_th = 0 and pho.min_xl > 0 then '否'
        else null
    end '联系的状态（接通与否）'
    ,if(plt2.pno is not null, '是', '否' ) 包裹是否疑似丢失_C来源
    ,if(plt3.pno is not null, '是', '否' ) 包裹是否疑似丢失_L来源
    ,st_distance_sphere(point(pi.ticket_delivery_staff_lng, pi.ticket_delivery_staff_lat), point(fin_ss.lng, fin_ss.lat)) 包裹妥投地址距离我方网点距离
    ,case plt.duty_result
        when 1 then '丢失'
        when 2 then '破损'
        when 3 then '超时效'
	end 判责结果
    ,sc.sc_cnt 交接天数
    ,coalesce(loi.item_name, soi.item_name, toi.product_name) 包裹内务
    ,pcn.monkey 客户申请理赔金额
    ,pcn2.monkey 实际理赔金额
from  ph_staging.parcel_info pi
left join ph_staging.parcel_info ori_pi on ori_pi.pno = pi.customary_pno and ori_pi.created_at > date_sub(current_date, interval 4 month)
left join ph_staging.parcel_additional_info pai on pai.pno = ori_pi.pno
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
left join ph_staging.ka_profile kp on kp.id = pi.client_id
left join ph_staging.sys_store pick_ss on pick_ss.id = pi.ticket_pickup_store_id
left join ph_staging.sys_store fin_ss on fin_ss.id = pi.ticket_delivery_store_id
-- 正向单号网点
left join ph_staging.sys_store fw_pick_ss on fw_pick_ss.id = ori_pi.ticket_pickup_store_id
left join ph_staging.sys_store fw_fin_ss on fw_fin_ss.id = ori_pi.ticket_delivery_store_id

left join ph_staging.parcel_route pr3 on pr3.pno = pi.pno and pr3.route_action = 'FLASH_HOME_SCAN' and pr3.routed_at > date_sub(curdate(), interval 3 month)
left join ph_staging.parcel_route pr4 on pr4.pno = pi.pno and pr4.route_action = 'RECEIVE_WAREHOUSE_SCAN' and pr4.routed_at > date_sub(curdate(), interval 3 month)

left join ph_staging.ticket_delivery td on td.id = pi.ticket_delivery_id
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pi.ticket_pickup_staff_info_id
left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = pi.ticket_delivery_staff_info_id
left join ph_bi.hr_staff_info hsi3 on hsi3.staff_info_id = ori_pi.ticket_pickup_staff_info_id
left join dwm.drds_ph_lazada_order_info_d loi on loi.pno = ori_pi.pno
left join dwm.drds_ph_shopee_item_info soi on soi.pno = ori_pi.pno
left join dwm.dwd_ph_tiktok_order_item toi on toi.pno = ori_pi.pno
left join ph_bi.parcel_lose_task plt2 on plt2.pno = pi.pno and plt2.source = 3 and plt2.state < 5 and plt2.parcel_created_at > date_sub(curdate(), interval 3 month)
left join ph_bi.parcel_lose_task plt3 on plt3.pno = pi.pno and plt3.source = 11 and plt3.state < 5 and plt3.parcel_created_at > date_sub(curdate(), interval 3 month)
left join
    (
        select
            pr.pno
            ,count(pr.id) call_cnt
            ,min(ifnull(cast(json_extract(pr.extra_value, '$.diaboloDuration') as int), 0)) min_xl
            ,sum(ifnull(cast(json_extract(pr.extra_value, '$.callDuration') as int ), 0)) sum_th
        from ph_staging.parcel_route pr
        join ph_staging.parcel_route pr2 on pr2.pno = pr.pno and pr.route_action = 'PHONE'
        where
            pr.route_action = 'DELIVERY_CONFIRM'
            and pr2.routed_at > date_sub(curdate(), interval 2 month)
            and pr2.routed_at > date_sub(date(convert_tz(pr.routed_at, '+00:00', '+08:00')), interval 8 hour)
            and pr2.routed_at < date_add(date(convert_tz(pr.routed_at, '+00:00', '+08:00')), interval 16 hour)
            and pr.pno in ('P1820434P2UAS')
            and pr.routed_at > date_sub(curdate(), interval 3 month)
        group by 1
    ) pho on pho.pno = pi.pno
left join
    (
        select
            plt.pno
            ,plt.duty_result
        from ph_bi.parcel_lose_task plt
        where
            plt.state = 6
            and plt.penalties > 0
            and plt.parcel_created_at >= date_sub(current_date, interval 4 month)
            and plt.pno in ('P1820434P2UAS')
    ) plt on plt.pno = pi.pno
left join
    (
        select
            pr.pno
            ,count(distinct date(convert_tz(pr.routed_at, '+00:00', '+08:00'))) sc_cnt
        from ph_staging.parcel_route pr
        where
            pr.pno in ('P1820434P2UAS')
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
            and pr.routed_at > date_sub(curdate(), interval 3 month)
        group by 1
    ) sc on sc.pno = pi.pno
left join
    (
        select
            a1.*
        from
            (
                select
                    pct.pno
                    ,json_extract(pcn.neg_result,'$.money') monkey
                    ,row_number() over (partition by pcn.task_id order by pcn.created_at ) rk
                from ph_bi.parcel_claim_negotiation pcn
                left join ph_bi.parcel_claim_task pct on pcn.task_id = pct.id
                where
                    pct.parcel_created_at >= date_sub(curdate(), interval 3 month)
                    and pcn.neg_type in (5,6,7)
                    and pct.pno in ('P1820434P2UAS')
                    and json_extract(pcn.neg_result,'$.money') is not null
            ) a1
        where
            a1.rk = 1
    ) pcn on pcn.pno = pi.pno
left join
    (
        select
            a1.*
        from
            (
                select
                    pct.pno
                    ,json_extract(pcn.neg_result,'$.money') monkey
                    ,row_number() over (partition by pcn.task_id order by pcn.created_at ) rk
                from ph_bi.parcel_claim_negotiation pcn
                left join ph_bi.parcel_claim_task pct on pcn.task_id = pct.id
                where
                    pct.parcel_created_at >= date_sub(curdate(), interval 3 month)
                    and pct.state = 6
                   -- and pcn.neg_type in (5,6,7)
                    and pct.pno in ('P1820434P2UAS')
                    and json_extract(pcn.neg_result,'$.money') is not null
            ) a1
        where
            a1.rk = 1
    ) pcn2 on pcn2.pno = pi.pno
where
    pi.returned = 1
    and pi.pno in ('P1820434P2UAS')
    and pi.created_at > date_sub(curdate(), interval 3 month)


;


select
    pi.pno
    ,case pi.returned
        when 0 then '正向'
        when 1 then '退件'
    end as 方向
    ,if(pi.returned = 1, pi.customary_pno, pi.pno) 正向单号
    ,if(pi.returned = 1, pi.pno, pi.returned_pno) 退件单号
from ph_staging.parcel_info pi
where
    pi.pno in ('${SUBSTITUTE(SUBSTITUTE(p2,"\n",","),",","','")}')
    and pi.created_at > date_sub(curdate(), interval 4 month)


;


select
    count(1)
from ph_bi.parcel_lose_task  plt
where
    plt.parcel_created_at < '2024-06-01 00:00:00'
    and plt.parcel_created_at >= '2023-01-01 00:00:00'
    and plt.state = 5
    and plt.duty_result = 1
    and plt.penalties > 0
;

select
    plt.pno
    ,plt.state
    ,plt.duty_result
from ph_bi.parcel_lose_task  plt
where
    plt.pno = 'P19262PPACSAM'