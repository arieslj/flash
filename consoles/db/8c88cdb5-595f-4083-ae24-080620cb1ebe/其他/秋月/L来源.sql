with t as
    (
        select
            plt.pno
            ,plt.id
            ,plt.parcel_created_at
            ,plt.last_valid_store_id
            ,ss.name last_valid_store_name
            ,date_sub(plt.last_valid_routed_at, interval 7 hour) last_valid_routed_time
            ,date(plt.parcel_created_at) creat_date
            ,plt.created_at
        from bi_pro.parcel_lose_task plt
        left join fle_staging.sys_store ss on ss.id = plt.last_valid_store_id
        where
            plt.state in (1,2,3,4)
            and plt.source = 12
    )
select
    t1.pno 运单号
    ,t1.creat_date 揽收日期
    ,datediff(curdate(), t1.created_at) 进入L来源天数
    ,t1.last_valid_store_name 最后有效路由网点
    ,t2.chn_cnt 包裹改约天数
    ,t2.rej_cnt 包裹拒收天数
    ,t2.inv_cnt 包裹盘库天数
    ,t2.inv_no_chn_cnt 包裹无改约盘库天数
    ,wo.order_content 工单内容
    ,rej2.di_cnt 第一次协商继续派送后改约次数
    ,pre_ss.store_name 上游网点
from t t1
left join
    (
        select
            t1.pno
            ,count(distinct if(chn.pno is not null, t1.date, null)) chn_cnt
            ,count(distinct if(inv.pno is not null, t1.date, null)) inv_cnt
            ,count(distinct if(rej.pno is not null, t1.date, null)) rej_cnt
            ,count(distinct if(chn.pno is null and inv.pno is not null, t1.date, null)) inv_no_chn_cnt
        from
            (
                select
                    t1.pno
                    ,otd.date
                from t t1
                cross join tmpale.ods_th_dim_date otd
                where
                    otd.date >= t1.creat_date
                    and otd.date <= date(now())
                group by 1,2
            ) t1
        left join
            (
                select
                    t1.pno
                    ,date (convert_tz(di.created_at, '+00:00', '+07:00')) di_date
                from rot_pro.parcel_route  di
                join t t1 on di.pno = t1.pno
                where
                    di.created_at >= '2025-01-01'
                    and di.marker_category = 14 -- 客户改约时间
                group by 1,2
            ) chn on t1.pno = chn.pno and t1.date = chn.di_date
        left join
            (
                select
                    t1.pno
                    ,date(convert_tz(pr.routed_at, '+00:00', '+07:00')) pr_date
                from rot_pro.parcel_route pr
                join t t1 on t1.pno = pr.pno
                where
                    pr.routed_at > '2025-01-01'
                    and pr.route_action = 'INVENTORY'
                group by 1,2
            ) inv on t1.pno = inv.pno and t1.date = inv.pr_date
        left join
            (
                select
                    t1.pno
                    ,date (convert_tz(di.created_at, '+00:00', '+07:00')) di_date
                from rot_pro.parcel_route  di
                join t t1 on di.pno = t1.pno
                where
                    di.created_at >= '2025-01-01'
                    and di.marker_category = 17 -- 收件人拒收
                group by 1,2
            ) rej on t1.pno = rej.pno and t1.date = rej.di_date
        group by 1
    ) t2 on t1.pno = t2.pno
left join
    (
        select
            wo_1.pno
            ,group_concat(distinct concat(wo_1.order_type, ':', wo_1.title)) order_content
        from
            (
                select
                    t1.pno
                    ,t1.id
                    ,case wo.order_type
                        when 1 then '查找运单'
                        when 2 then '加快处理'
                        when 3 then '调查员工'
                        when 4 then '其他'
                        when 5 then '网点信息维护提醒'
                        when 6 then '培训指导'
                        when 7 then '异常业务询问'
                        when 8 then '包裹丢失'
                        when 9 then '包裹破损'
                        when 10 then '货物短少'
                        when 11 then '催单'
                        when 12 then '有发无到'
                        when 13 then '上报包裹不在集包里'
                        when 16 then '漏揽收'
                        when 50 then '虚假撤销'
                        when 17 then '已签收未收到'
                        when 18 then '客户投诉'
                        when 19 then '修改包裹信息'
                        when 20 then '修改 COD 金额'
                        when 21 then '解锁包裹'
                        when 22 then '申请索赔'
                        when 23 then 'MS 问题反馈'
                        when 24 then 'FBI 问题反馈'
                        when 25 then 'KA System 问题反馈'
                        when 26 then 'App 问题反馈'
                        when 27 then 'KIT 问题反馈'
                        when 28 then 'Backyard 问题反馈'
                        when 29 then 'BS/FH 问题反馈'
                        when 30 then '系统建议'
                        when 31 then '申诉罚款'
                        else wo.order_type
                    end order_type
                    ,wo.title
                from bi_pro.work_order wo
                join t t1 on wo.loseparcel_task_id = t1.id
                where
                    wo.created_at > '2025-01-01'
            ) wo_1
        group by 1
    ) wo on t1.pno = wo.pno
left join
    (
        select
            di.pno
            ,count(distinct date(convert_tz(di2.routed_at, '+00:00', '+07:00'))) di_cnt
        from rot_pro.parcel_route  di2
        join
            (
                select
                    t1.pno
                    ,cdt.updated_at
                    ,row_number() over (partition by t1.pno order by cdt.updated_at) rk
                from fle_staging.diff_info di
                join t t1 on t1.pno = di.pno
                join fle_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id and cdt.created_at > '2025-01-01'
                where
                    di.created_at > '2025-01-01'
                    and cdt.negotiation_result_category in (5,6) -- 继续派送
                    and di.diff_marker_category = 17
            ) di on di.pno = di2.pno and di.rk = 1
        where
            di2.routed_at > '2025-01-01'
            and di2.routed_at > di.updated_at
            and di2.marker_category = 14
        group by 1
    ) rej2 on t1.pno = rej2.pno
left join
    (
        select
            t1.pno
            ,pr.store_name
            ,row_number() over (partition by t1.pno order by pr.routed_at desc) rk
        from rot_pro.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > '2025-01-01'
            and pr.routed_at < t1.last_valid_routed_time
            and pr.store_id != t1.last_valid_store_id
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT', 'DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY', 'REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
    ) pre_ss on t1.pno = pre_ss.pno and pre_ss.rk = 1
;
