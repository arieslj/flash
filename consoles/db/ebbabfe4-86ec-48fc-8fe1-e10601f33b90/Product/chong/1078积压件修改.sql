-- 汇总



with t as
    (
        select
            pi.pno
            ,pi.created_at
            ,pi.client_id
            ,pi.returned
            ,pi.dst_store_id
            ,pi.state
            ,pi.cod_enabled
            ,pi.ticket_pickup_store_id
            ,pd.resp_store_updated
            ,pd.last_valid_action
            ,pd.last_valid_store_id
            ,case ss.category
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
            end last_valid_store_category
            ,case s2.category
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
            end pickup_store_category
        from my_staging.parcel_info pi
        left join my_bi.parcel_detail pd on pi.pno = pd.pno
        left join my_staging.sys_store ss on ss.id = pd.last_valid_store_id
        left join my_staging.sys_store s2 on s2.id = pi.ticket_pickup_store_id
        where
            1 = 1
            and pi.created_at > convert_tz('${sdate}', '+08:00', '+00:00')
            and pi.created_at <= date_add(convert_tz('${edate}', '+08:00', '+00:00'), interval 1 day)
            and pi.state in (1,2,3,4,6)
    )
, di as
    ( -- 当前疑难件原因
        select
            a.*
        from
            (
                select
                    di.pno
                    ,di.diff_marker_category
                    ,di.created_at
                    ,row_number() over (partition by di.pno order by di.created_at desc) rk -- 获取最新一条diff_info
                from my_staging.diff_info di
                join t t1 on t1.pno = di.pno
                where
                    di.created_at > convert_tz('${sdate}', '+08:00', '+00:00')
                    and di.state = 0
            ) a
        where
            a.rk = 1
    )
select
    a.pickup_date
    ,a.负责部门
    ,count(distinct a.pno) pnt
from
    (
        select
            t1.pno
            ,date(convert_tz(t1.created_at, '+00:00', '+08:00')) pickup_date
            ,case
                when bc.client_id is not null then bc.client_name
                when bc.client_id is null and kp.id is not null then 'KA'
                else 'GE'
            end 客户类型
            ,coalesce(a1.duty_department, a2.duty_department, a3.duty_department, a4.duty_department, a6.duty_department, a7.duty_department, a8.duty_department, a9.duty_department, a10.duty_department, a11.duty_department, a12.duty_department, lv.store_category) 负责部门
        from t t1
        left join di d1 on d1.pno = t1.pno
        left join my_staging.ka_profile kp on kp.id = t1.client_id
        left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = t1.client_id
#         left join
#             (
#                 select
#                     pc.*
#                     ,client_id
#                 from
#                     (
#                         select
#                             *
#                         from my_staging.sys_configuration
#                         where cfg_key = 'diff.ticket.customer_service.ka_client_ids'
#                     ) pc
#                     lateral view explode(split(pc.cfg_value, ',')) id as client_id
#             ) kam on t1.client_id = kam.client_id
        left join
            ( -- 闪速判案
                select
                    sct.pno
                    ,'闪速判案待处理' duty_reason
                    ,'总部CS' duty_department
                from my_bi.ss_court_task sct
                join t t1 on t1.pno = sct.pno
                where
                    sct.created_at > convert_tz('${sdate}', '+08:00', '+00:00')
                    and sct.state  = 1
                group by 1,2,3
            ) a1 on t1.pno = a1.pno
        left join
            ( -- 包裹丢失待处理
                select
                    plt.pno
                    ,'包裹丢失待处理' duty_reason
                    ,'调度' duty_department
                from my_bi.parcel_lose_task plt
                join t t1 on t1.pno = plt.pno
                where
                    plt.parcel_created_at >= '${sdate}'
                    and plt.source = 1
                    and plt.state in (1,2,3,4)
                    and t1.state = 6
                group by 1,2,3
            ) a2 on t1.pno = a2.pno
        left join
            ( -- 收件人拒收回访
                select
                    d.pno
                    ,'待收件人拒收回访' duty_reason
                    ,'总部CS' duty_department
                from di d
                join t t1 on t1.pno = d.pno
                left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = t1.client_id
                where
                    d.diff_marker_category in (2,17)
                    and (bc.client_id is not null or t1.client_id = 'AA0107') -- AA0107 -- 吉客印
                group by 1,2,3
            ) a3 on t1.pno = a3.pno
        left  join
            ( -- KAM/揽件网点未协商
                select
                    t1.pno
                    ,'KAM/揽件网点未协商' duty_reason
                    ,case
                        when bc.client_name = 'lazada' then 'PMD_LAZ'
                        when bc.client_name = 'shopee' then 'PMD_SHOPEE'
                        when bc.client_name = 'tiktok' then 'PMD_TT'
                        when bc.client_name = 'shein' then 'KAM'
                        when kp.id is not null and kam.client_id is null then 'KAM'
                        when kam.client_id is not null then '总部CS'
                        else t1.pickup_store_category
                    end duty_department
                from t t1
                left join my_staging.ka_profile kp on kp.id = t1.client_id
                left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = t1.client_id
                left join
                    (
                        select
                            pc.*
                            ,client_id
                        from
                            (
                                select
                                    *
                                from my_staging.sys_configuration
                                where cfg_key = 'diff.ticket.customer_service.ka_client_ids'
                            ) pc
                            lateral view explode(split(pc.cfg_value, ',')) id as client_id
                    )  kam on t1.client_id = kam.client_id
                where
                    t1.state = 6
            ) a4 on t1.pno = a4.pno
#         left join
#             ( -- 有发无到后无路由包裹
#                 select
#                     pr.pno
#                     ,'有发无到后无路由包裹' duty_reason
#                     ,ss.name up_store
#                     ,pr.store_name down_store
#                     ,t1.last_valid_store_category duty_department
#                 from my_staging.parcel_route pr
#                 join t t1 on t1.pno = pr.pno
#                 left join my_staging.sys_store ss on ss.id  = t1.last_valid_store_id
#                 where
#                     pr.route_action = 'HAVE_HAIR_SCAN_NO_TO'
#                     and pr.routed_at > convert_tz('${sdate}', '+08:00', '+00:00')
#                     and pr.routed_at > date_sub(t1.resp_store_updated, interval 8 hour)
#                 group by 1
#             ) a5 on t1.pno = a5.pno
        left join
            ( -- QAQC无须追责后长期无有效路由
                select
                    a.pno
                    ,'QAQC无须追责后长期无有效路由' duty_reason
                    ,a.last_valid_store_category duty_department
                from
                    (
                        select
                            t1.pno
                            ,t1.last_valid_store_category
                            ,pcol.created_at
                            ,row_number() over (partition by t1.pno order by pcol.created_at desc) rk
                        from my_bi.parcel_lose_task plt
                        join t t1 on t1.pno = plt.pno
                        join my_bi.parcel_cs_operation_log pcol on pcol.task_id = plt.id and pcol.action = 3
                    ) a
                where
                    a.rk = 1
                    and timestampdiff(hour, a.created_at, now()) >= 24
            ) a6 on t1.pno = a6.pno
        left join
            ( -- 包裹多天无有效路由
                select
                    t1.pno
                    ,'包裹多天无有效路由' duty_reason
                    ,t1.last_valid_store_category duty_department
                from t t1
                where
                    t1.resp_store_updated < date_sub(now(), interval 24 hour)
            ) a7 on t1.pno = a7.pno
        left join
            ( -- 回拍卖仓包裹待处理
                select
                    t1.pno
                    ,'回拍卖仓包裹待处理' duty_reason
                    ,'HUB' duty_department
                from t t1
                where
                    t1.dst_store_id = 'MY04040319'
                    and t1.last_valid_store_id = 'MY04040319'
            ) a8 on t1.pno = a8.pno
        left join
            ( -- 包裹待发件至拍卖仓
                select
                    t1.pno
                    ,'包裹待发件至拍卖仓' duty_reason
                    ,t1.last_valid_store_category duty_department
                from t t1
                where
                    t1.dst_store_id = 'MY04040319'
                    and t1.last_valid_store_id != 'MY04040319'
            ) a9 on t1.pno = a9.pno
        left join
            ( -- 连续3天盘库无其他路由
                select
                    a1.pno
                    ,'连续2天盘库无其他路由' duty_reason
                    ,a1.last_valid_store_category duty_department
                from
                    (
                        select
                            pr.pno
                            ,t1.last_valid_store_category
                        from my_staging.parcel_route pr
                        join t t1 on t1.pno = pr.pno
                        where
                            pr.routed_at > date(date_sub(now(), interval 2 day))
                            and pr.route_action in ('INVENTORY', 'DISTRIBUTION_INVENTORY', 'SORTING_SCAN')
                            and t1.state = 4 -- 已滞留
                        group by 1,2
                    ) a1
                left join
                    (
                        select
                            pr.pno
                            ,count(distinct pr.route_action) action_rnt
                        from my_staging.parcel_route pr
                        join t t1 on t1.pno = pr.pno
                        where
                            pr.routed_at > date(date_sub(now(), interval 2 day))
                            and pr.route_action in ('DISCARD_RETURN_BKK','RECEIVED','RECEIVE_WAREHOUSE_SCAN','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','DELIVERY_TICKET_CREATION_SCAN','DELIVERY_PICKUP_STORE_SCAN','DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE','REFUND_CONFIRM','ACCEPT_PARCEL')
                    ) a2 on a1.pno = a2.pno
                where
                    a2.pno is null
            ) a10 on t1.pno = a10.pno
        left join
            ( -- 揽件未发出
                select
                    t1.pno
                    ,'揽件未发出' duty_reason
                    ,t1.last_valid_store_category duty_department
                from t t1
                where
                    t1.state = 1
                    and t1.last_valid_store_id = t1.ticket_pickup_store_id
            ) a11 on t1.pno = a11.pno
        left join
            ( -- 有尝试派送未终态
                select
                    a.pno
                    ,'有尝试派送未终态' duty_reason
                    ,a.last_valid_store_category duty_department
                from
                    (
                        select
                            t1.pno
                            ,t1.last_valid_store_category
                            ,count(distinct date(convert_tz(ppd.created_at, '+00:00', '+08:00'))) date_cnt
                        from my_staging.parcel_problem_detail ppd
                        join t t1 on t1.pno = ppd.pno
                        where
                            ppd.created_at > convert_tz('${sdate}', '+08:00', '+00:00')
                            and ppd.diff_marker_category in (17,23,25,26,14,40,32)
                        group by 1,2
                    ) a
                where
                    a.date_cnt > 0
            ) a12 on t1.pno = a12.pno
        left join
            (
                select
                    pr.pno
                    ,pr.store_name
                    ,case pr.store_category
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
                    end store_category
                    ,pr.route_action
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
                from my_staging.parcel_route pr
                join t t1 on t1.pno = pr.pno
                where
                    pr.routed_at > convert_tz('${sdate}', '+08:00', '+00:00')
                    and pr.route_action in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','DELIVERY_TICKET_CREATION_SCAN','SORTING_SCAN','DELIVERY_PICKUP_STORE_SCAN','DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE','REFUND_CONFIRM','ACCEPT_PARCEL')
            ) lv on lv.pno = t1.pno and lv.rk = 1
        left join
            (
                select
                    distinct
                    pr.pno
                    , convert_tz(pr.`routed_at`, '+00:00', '+08:00') routed_at
                    , pr.store_name
                from my_staging.parcel_route pr
                join t t1 on pr.pno = t1.pno
                where
                    pr.route_action = 'REFUND_CONFIRM'
                    and pr.routed_at >= convert_tz('${sdate}', '+08:00', '+00:00')
            ) pr_hold on t1.pno = pr_hold.pno
        where
            pr_hold.pno is null
    ) a
where
    1 = 1
;

















with t as
    (
        select
            pi.pno
            ,pi.created_at
            ,pi.client_id
            ,pi.returned
            ,pi.dst_store_id
            ,pi.state
            ,pi.cod_enabled
            ,pi.ticket_pickup_store_id
            ,pd.resp_store_updated
            ,pd.last_valid_action
            ,pd.last_valid_store_id
            ,case ss.category
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
            end last_valid_store_category
            ,case s2.category
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
            end pickup_store_category
            ,if(pi.returned = 1, pi.customary_pno, pi.pno) ori_pno
        from my_staging.parcel_info pi
        left join my_bi.parcel_detail pd on pi.pno = pd.pno
        left join my_staging.sys_store ss on ss.id = pd.last_valid_store_id
        left join my_staging.sys_store s2 on s2.id = pi.ticket_pickup_store_id
        where
            1 = 1
            and pi.created_at > convert_tz('${sdate}', '+08:00', '+00:00')
            and pi.created_at <= date_add(convert_tz('${edate}', '+08:00', '+00:00'), interval 1 day)
            and pi.state in (1,2,3,4,6)
          --  and pi.pno = 'MT12031X9XE50Z'
    )
, di as
    ( -- 当前疑难件原因
        select
            a.*
        from
            (
                select
                    di.pno
                    ,di.diff_marker_category
                    ,di.created_at
                    ,row_number() over (partition by di.pno order by di.created_at desc) rk -- 获取最新一条diff_info
                from my_staging.diff_info di
                join t t1 on t1.pno = di.pno
                where
                    di.created_at > convert_tz('${sdate}', '+08:00', '+00:00')
                    and di.state = 0
            ) a
        where
            a.rk = 1
    )
select
    a.*
from
    (
        select
            t1.pno
            ,if(t1.returned = 1, '退件', '正向') 方向
            ,t1.client_id 客户ID
            ,case
                when bc.client_id is not null then bc.client_name
                when bc.client_id is null and kp.id is not null then 'KA'
                else 'GE'
            end 客户类型
            ,case t1.state
                when 1 then '已揽收'
                when 2 then '运输中'
                when 3 then '派送中'
                when 4 then '已滞留'
                when 5 then '已签收'
                when 6 then '疑难件处理中'
                when 7 then '已退件'
                when 8 then '异常关闭'
                when 9 then '已撤销'
            end as 包裹状态
            ,coalesce(a1.duty_reason, a2.duty_reason, a3.duty_reason, a4.duty_reason, a6.duty_reason, a7.duty_reason, a8.duty_reason, a9.duty_reason, a10.duty_reason, a11.duty_reason, a12.duty_reason) 卡点原因
            ,coalesce(a1.duty_department, a2.duty_department, a3.duty_department, a4.duty_department,  a6.duty_department, a7.duty_department, a8.duty_department, a9.duty_department, a10.duty_department, a11.duty_department, a12.duty_department, lv.store_category) 负责部门
            ,if(uloc.pno is not null, '是', '否') 是否丢失件解锁
            ,datediff(now(), t1.resp_store_updated) '最后有效路由距今天时长/day'
            ,t1.resp_store_updated   最后有效路由时间
            ,ddd.cn_element 最后有效路由动作
            ,s1.store_name 最后有效路由网点
            ,s1.piece_name 最后有效路由网点片区
            ,s1.region_name 最后有效路由网点大区
            ,lv.store_name '剔除''换单发回拍卖仓''最后路由网点'
            ,s2.name 目的地网点
            ,s3.name 揽收网点
            ,convert_tz(t1.created_at, '+00:00', '+08:00') as 揽收时间
            ,datediff(curdate(), date (convert_tz(t1.created_at, '+00:00', '+08:00')))  揽收至今天数
            ,if(t1.cod_enabled = 1, '是', '否') 是否为COD
            ,try.sc_cnt '交接次数（有交接记录）'
            ,try.mark_cnt '快递员尝试派送次数（标记次数）'
            ,case
                when bc.client_name in ('lazada', 'tiktok') and t1.returned = 1 then dai.returned_delivery_attempt_num
                when bc.client_name in ('lazada', 'tiktok') and t1.returned = 0 then dai.delivery_attempt_num
                when bc.client_name = 'shopee' and t1.returned = 1 then scs.returned_delivery_failed_num
                when bc.client_name = 'shopee' and t1.returned = 0 then scs.delivery_failed_num
                else try.diff_cnt
            end '有效尝试派送次数（有上报问题件/留仓且剔除节假日）'
            ,convert_tz(d1.created_at, '+00:00', '+08:00') 最后一次疑难件提交日期
            ,case
                   when bc.client_name = 'lazada' then lp.whole_end_date
                   when bc.client_name = 'tiktok' then lp1.end_7_plus_date
                   when bc.client_name = 'shopee' then lp2.whole_end_date
                   else null
            end 大客户超时效截止日
            ,datediff(case when bc.client_name = 'lazada' then lp.whole_end_date when bc.client_name = 'tiktok' then lp1.end_7_plus_date when bc.client_name = 'shopee' then lp2.whole_end_date else null end, curdate())  超时至今天数
            ,wg.third_sorting_code 网格
            ,rj.di_cnt 提交收件人拒收的次数
#             ,a5.up_store 有发无到上游网点
#             ,a5.down_store 有发无到上报网点
        from t t1
        left join di d1 on d1.pno = t1.pno
        left join my_staging.shopee_callback_status scs on scs.pno = t1.ori_pno
        left join my_staging.delivery_attempt_info dai on dai.pno = t1.ori_pno
        left join my_staging.ka_profile kp on kp.id = t1.client_id
        left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = t1.client_id
        left join
          (
            select
              t1.pno
              ,count(distinct di.id) di_cnt
            from `my_staging`.`diff_info` di
            join t t1 on t1.pno = di.pno
            where
              di.`created_at` > date_sub(CURRENT_DATE, interval 3 month)
              and di.`diff_marker_category` = 17
            group by 1
          ) rj on rj.pno = t1.pno
#         left join
#             (
#                 select
#                     pc.*
#                     ,client_id
#                 from
#                     (
#                         select
#                             *
#                         from my_staging.sys_configuration
#                         where cfg_key = 'diff.ticket.customer_service.ka_client_ids'
#                     ) pc
#                     lateral view explode(split(pc.cfg_value, ',')) id as client_id
#             ) kam on t1.client_id = kam.client_id
        left join
            ( -- 闪速判案
                select
                    sct.pno
                    ,'闪速判案待处理' duty_reason
                    ,'总部CS' duty_department
                from my_bi.ss_court_task sct
                join t t1 on t1.pno = sct.pno
                where
                    sct.created_at > convert_tz('${sdate}', '+08:00', '+00:00')
                    and sct.state  = 1
                group by 1,2,3
            ) a1 on t1.pno = a1.pno
        left join
            ( -- 包裹丢失待处理
                select
                    plt.pno
                    ,'包裹丢失待处理' duty_reason
                    ,'调度' duty_department
                from my_bi.parcel_lose_task plt
                join t t1 on t1.pno = plt.pno
                where
                    plt.parcel_created_at >= '${sdate}'
                    and plt.source = 1
                    and plt.state in (1,2,3,4)
                    and t1.state = 6
                group by 1,2,3
            ) a2 on t1.pno = a2.pno
        left join
            ( -- 收件人拒收回访
                select
                    d.pno
                    ,'待收件人拒收回访' duty_reason
                    ,'总部CS' duty_department
                from di d
                join t t1 on t1.pno = d.pno
                left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = t1.client_id
                where
                    d.diff_marker_category in (2,17)
                    and (bc.client_id is not null or t1.client_id = 'AA0107') -- AA0107 -- 吉客印
                group by 1,2,3
            ) a3 on t1.pno = a3.pno
        left  join
            ( -- KAM/揽件网点未协商
                select
                    t1.pno
                    ,'KAM/揽件网点未协商' duty_reason
                    ,case
                        when bc.client_name = 'lazada' then 'PMD_LAZ'
                        when bc.client_name = 'shopee' then 'PMD_SHOPEE'
                        when bc.client_name = 'tiktok' then 'PMD_TT'
                        when bc.client_name = 'shein' then 'KAM'
                        when kp.id is not null and kam.client_id is null then 'KAM'
                        when kam.client_id is not null then '总部CS'
                        else t1.pickup_store_category
                    end duty_department
                from t t1
                left join my_staging.ka_profile kp on kp.id = t1.client_id
                left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = t1.client_id
                left join
                    (
                        select
                            pc.*
                            ,client_id
                        from
                            (
                                select
                                    *
                                from my_staging.sys_configuration
                                where cfg_key = 'diff.ticket.customer_service.ka_client_ids'
                            ) pc
                            lateral view explode(split(pc.cfg_value, ',')) id as client_id
                    )  kam on t1.client_id = kam.client_id
                where
                    t1.state = 6
            ) a4 on t1.pno = a4.pno
#         left join
#             ( -- 有发无到后无路由包裹
#                 select
#                     pr.pno
#                     ,'有发无到后无路由包裹' duty_reason
# #                     ,ss.name up_store
#                     ,pr.store_name down_store
#                     ,t1.last_valid_store_category duty_department
#                 from my_staging.parcel_route pr
#                 join t t1 on t1.pno = pr.pno
#                 left join my_staging.sys_store ss on ss.id  = t1.last_valid_store_id
#                 where
#                     pr.route_action = 'HAVE_HAIR_SCAN_NO_TO'
#                     and pr.routed_at > convert_tz('${sdate}', '+08:00', '+00:00')
#                     and pr.routed_at >= date_sub(t1.resp_store_updated, interval 8 hour)
#                 group by 1
#             ) a5 on t1.pno = a5.pno
        left join
            ( -- QAQC无须追责后长期无有效路由
                select
                    a.pno
                    ,'QAQC无须追责后长期无有效路由' duty_reason
                    ,a.last_valid_store_category duty_department
                from
                    (
                        select
                            t1.pno
                            ,t1.last_valid_store_category
                            ,pcol.created_at
                            ,row_number() over (partition by t1.pno order by pcol.created_at desc) rk
                        from my_bi.parcel_lose_task plt
                        join t t1 on t1.pno = plt.pno
                        join my_bi.parcel_cs_operation_log pcol on pcol.task_id = plt.id and pcol.action = 3
                    ) a
                where
                    a.rk = 1
                    and timestampdiff(hour, a.created_at, now()) >= 24
            ) a6 on t1.pno = a6.pno
        left join
            ( -- 包裹多天无有效路由
                select
                    t1.pno
                    ,'包裹多天无有效路由' duty_reason
                    ,t1.last_valid_store_category duty_department
                from t t1
                where
                    t1.resp_store_updated < date_sub(now(), interval 24 hour)
            ) a7 on t1.pno = a7.pno
        left join
            ( -- 回拍卖仓包裹待处理
                select
                    t1.pno
                    ,'回拍卖仓包裹待处理' duty_reason
                    ,'HUB' duty_department
                from t t1
                where
                    t1.dst_store_id = 'MY04040319'
                    and t1.last_valid_store_id = 'MY04040319'
            ) a8 on t1.pno = a8.pno
        left join
            ( -- 包裹待发件至拍卖仓
                select
                    t1.pno
                    ,'包裹待发件至拍卖仓' duty_reason
                    ,t1.last_valid_store_category duty_department
                from t t1
                where
                    t1.dst_store_id = 'MY04040319'
                    and t1.last_valid_store_id != 'MY04040319'
            ) a9 on t1.pno = a9.pno
        left join
            ( -- 连续3天盘库无其他路由
                select
                    a1.pno
                    ,'连续2天盘库无其他路由' duty_reason
                    ,a1.last_valid_store_category duty_department
                from
                    (
                        select
                            pr.pno
                            ,t1.last_valid_store_category
                        from my_staging.parcel_route pr
                        join t t1 on t1.pno = pr.pno
                        where
                            pr.routed_at > date(date_sub(now(), interval 2 day))
                            and pr.route_action in ('INVENTORY', 'DISTRIBUTION_INVENTORY', 'SORTING_SCAN')
                            and t1.state = 4 -- 已滞留
                        group by 1,2
                    ) a1
                left join
                    (
                        select
                            pr.pno
                            ,count(distinct pr.route_action) action_rnt
                        from my_staging.parcel_route pr
                        join t t1 on t1.pno = pr.pno
                        where
                            pr.routed_at > date(date_sub(now(), interval 2 day))
                            and pr.route_action in ('DISCARD_RETURN_BKK','RECEIVED','RECEIVE_WAREHOUSE_SCAN','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','DELIVERY_TICKET_CREATION_SCAN','DELIVERY_PICKUP_STORE_SCAN','DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE','REFUND_CONFIRM','ACCEPT_PARCEL')
                    ) a2 on a1.pno = a2.pno
                where
                    a2.pno is null
            ) a10 on t1.pno = a10.pno
        left join
            ( -- 揽件未发出
                select
                    t1.pno
                    ,'揽件未发出' duty_reason
                    ,t1.last_valid_store_category duty_department
                from t t1
                where
                    t1.state = 1
                    and t1.last_valid_store_id = t1.ticket_pickup_store_id
            ) a11 on t1.pno = a11.pno
        left join
            ( -- 有尝试派送未终态
                select
                    a.pno
                    ,'有尝试派送未终态' duty_reason
                    ,a.last_valid_store_category duty_department
                from
                    (
                        select
                            t1.pno
                            ,t1.last_valid_store_category
                            ,count(distinct date(convert_tz(ppd.created_at, '+00:00', '+08:00'))) date_cnt
                        from my_staging.parcel_problem_detail ppd
                        join t t1 on t1.pno = ppd.pno
                        where
                            ppd.created_at > convert_tz('${sdate}', '+08:00', '+00:00')
                            and ppd.diff_marker_category in (17,23,25,26,14,40,32)
                        group by 1,2
                    ) a
                where
                    a.date_cnt > 0
            ) a12 on t1.pno = a12.pno
        left join
            (
                select
                    t1.pno
                from my_bi.parcel_lose_task plt
                join t t1 on t1.pno = plt.pno
                left join my_bi.parcel_cs_operation_log pcol on pcol.task_id = plt.id
                where
                    plt.parcel_created_at >= '${sdate}'
                    and pcol.action = 4
                    and pcol.created_at < t1.resp_store_updated
                group by 1
            ) uloc on t1.pno = uloc.pno
        left join
            (
                select
                    pr.pno
                    ,pr.store_name
                    ,case pr.store_category
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
                    end store_category
                    ,pr.route_action
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
                from my_staging.parcel_route pr
                join t t1 on t1.pno = pr.pno
                where
                    pr.routed_at > convert_tz('${sdate}', '+08:00', '+00:00')
                    and pr.route_action in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','DELIVERY_TICKET_CREATION_SCAN','SORTING_SCAN','DELIVERY_PICKUP_STORE_SCAN','DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE','REFUND_CONFIRM','ACCEPT_PARCEL')
            ) lv on lv.pno = t1.pno and lv.rk = 1
        left join dwm.dwd_dim_dict ddd on ddd.element = t1.last_valid_action and ddd.db = 'my_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
        left join dwm.dim_my_sys_store_rd  s1 on s1.store_id = t1.last_valid_store_id and s1.stat_date = date_sub(curdate(), 1)
        left join my_staging.sys_store s2 on s2.id = t1.dst_store_id
        left join my_staging.sys_store s3 on s3.id = t1.ticket_pickup_store_id
        left join dwm.dwd_ex_my_lazada_pno_period lp on t1.pno = lp.pno
        left join dwm.dwd_ex_my_tiktok_sla_detail lp1 on t1.pno = lp1.pno
        left join dwm.dwd_ex_my_shopee_pno_period lp2 on lp2.pno = t1.pno
        left join
            (
                select
                    t1.pno
                    ,count(distinct if(a1.pno is not null, a1.pr_date, null)) sc_cnt
                    ,count(distinct if(a2.pno is not null and a1.pno is not null, a2.pr_date, null)) mark_cnt
                    ,count(distinct if(a3.pno is not null and a1.pno is not null, a3.pr_date, null)) diff_cnt
                from t t1
                left join
                    (
                        select
                            t1.pno
                            ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
                        from my_staging.parcel_route pr
                        join t t1 on t1.pno = pr.pno
                        where
                            pr.routed_at > convert_tz('${sdate}', '+08:00', '+00:00')
                            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                        group by 1,2
                    ) a1 on t1.pno = a1.pno
                left join
                    (
                        select
                            t1.pno
                            ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
                        from my_staging.parcel_route pr
                        join t t1 on t1.pno = pr.pno
                        where
                            pr.routed_at > convert_tz('${sdate}', '+08:00', '+00:00')
                            and pr.route_action = 'DELIVERY_MARKER'
                        group by 1,2
                    ) a2 on a2.pno = t1.pno and a2.pr_date = a1.pr_date
                left join
                    (
                        select
                            t1.pno
                            ,date(convert_tz(ppd.created_at, '+00:00', '+08:00')) pr_date
                        from my_staging.parcel_problem_detail ppd
                        join t t1 on t1.pno = ppd.pno
                        where
                            ppd.created_at > convert_tz('${sdate}', '+08:00', '+00:00')
                            and ppd.diff_marker_category in (17,23,25,26,14,40,32)
                        group by 1,2
                    ) a3 on a3.pno = t1.pno and a3.pr_date = a1.pr_date
                group by 1
            ) try on t1.pno = try.pno
        left join
            (
                select
                    distinct
                    pr.pno
                    , convert_tz(pr.`routed_at`, '+00:00', '+08:00') routed_at
                    , pr.store_name
                from my_staging.parcel_route pr
                join t t1 on pr.pno = t1.pno
                where
                    pr.route_action = 'REFUND_CONFIRM'
                    and pr.routed_at >= convert_tz('${sdate}', '+08:00', '+00:00')
            ) pr_hold on t1.pno = pr_hold.pno
        left join
            (
                select
                    t1.pno
                    ,ps.third_sorting_code
                    ,row_number() over (partition by ps.pno order by ps.created_at desc) rk
                from my_drds_pro.parcel_sorting_code_info ps
                join t t1 on t1.pno = ps.pno
                where
                    ps.created_at > date_sub('${sdate}', interval 10 day)
            ) wg on wg.pno = t1.pno and wg.rk = 1
        where
            pr_hold.pno is null
    ) a
where
    1 = 1


