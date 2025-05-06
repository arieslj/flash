-- C 和 L 来源的相似度
with t as
    (
        select
            plt.pno
            ,plt.parcel_created_at
            ,plt.client_id
        from bi_pro.parcel_lose_task plt
        join
            (
                select
                    plt.pno
                    ,plt.created_at
                    ,plt.state
                    ,plt.updated_at
                from bi_pro.parcel_lose_task plt
                where
                    plt.source = 12
                    and plt.created_at > '2023-10-18'
            ) pl on pl.pno = plt.pno
        where
            plt.source in (1,3)
            and
                (
                    case
                        when pl.state in (1,2,3,4) and plt.state in (1,2,3,4) then 1 = 1
                        when pl.state in (1,2,3,4) and plt.state in (5,6) then plt.updated_at > pl.created_at
                        when pl.state in (5,6) and plt.state in (1,2,3,4) then plt.created_at < pl.updated_at
                        when pl.state in (5,6) and plt.state in (5,6) then plt.created_at < plt.updated_at and plt.updated_at > plt.created_at
                    end
                )
        group by 1,2,3
    )
select
    pi.pno 单号
    ,t1.client_id 客户ID
    ,t1.parcel_created_at 揽收时间
    ,case pi.returned
        when 0 then '正向'
        when 1 then '逆向'
     else null end 是否正向
    ,pi.returned_pno 退件单号
    ,pc.pc_count 进C或A来源的次数
    ,pc.created_at 第一次进入C或A来源的时间
    ,pl.created_at 最后一次进入L来源的时间
    ,pcl.created_at 进入L来源前C来源的时间
    ,case fir.`duty_result`
        when 1 then '丢失'
        when 2 then '破损'
        when 3 then '超时效'
	end 第一次判责结果
    ,case las.`duty_result`
        when 1 then '丢失'
        when 2 then '破损'
        when 3 then '超时效'
	end 最后一次判责结果
    ,las.operator_id 判责处理人
    ,las.updated_at 判责时间
    ,pi.cod_amount/100 cod金额
    ,case pi.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end 包裹状态
from t t1
left join fle_staging.parcel_info pi on pi.pno = t1.pno and pi.created_at > '2023-05-18'
left join
    (
        select
            plt.pno
            ,plt.created_at
            ,count(plt.id) over(partition by plt.pno) pc_count
            ,row_number() over (partition by plt.pno order by plt.created_at) rk
        from bi_pro.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.source in (1,3)
    ) pc on pc.pno = t1.pno and pc.rk = 1
left join
    (
        select
            plt.pno
            ,plt.created_at
            ,row_number() over (partition by plt.pno order by plt.created_at desc) rk
        from bi_pro.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.source = 12
    ) pl on pl.pno = t1.pno and pl.rk = 1
left join
    (
        select
            t1.pno
            ,plt2.created_at
            ,row_number() over (partition by t1.pno order by plt2.created_at desc) rk
        from bi_pro.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        join bi_pro.parcel_lose_task plt2 on plt2.pno = t1.pno and plt2.source = 3
        where
            plt.source = 12
            and plt2.created_at < plt.created_at
    ) pcl on pcl.pno = t1.pno and pcl.rk = 1
left join
    (
        select
            plt.pno
            ,duty_result
            ,row_number() over (partition by plt.pno order by plt.updated_at) rk
        from bi_pro.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
    ) fir on fir.pno = t1.pno and fir.rk = 1
left join
    (
        select
            plt.pno
            ,plt.duty_result
            ,plt.operator_id
            ,plt.updated_at
            ,row_number() over (partition by plt.pno order by plt.updated_at) rk
        from bi_pro.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
    ) las on las.pno = t1.pno and las.rk = 1
;




-- 打印面单场景下强制拍照被抓进wrs的
with t as
    (
        select
            pr.pno
            ,pi.created_at
            ,pi.returned
            ,pr.routed_at
            ,convert_tz(pr.routed_at ,'+00:00', '+07:00') pr_time
            ,date(convert_tz(pr.routed_at ,'+00:00', '+07:00')) pr_date
        from rot_pro.parcel_route pr
        left join fle_staging.parcel_info pi on pi.pno = pr.pno
        where
            pr.route_action = 'TAKE_PHOTO'
            and pr.routed_at > '2023-10-17 17:00:00'
            and json_extract(pr.extra_value, '$.forceTakePhotoCategory') = 1
            and json_extract(pr.extra_value, '$.aiPhotoCheckReason') is not null
            and pr.routed_at > '2023-10-17 17:00:00'
    )
, rp as
    (
        select
            pr.pno
            ,pr.routed_at
            ,pr.staff_info_id
            ,count(pr.id) over(partition by pr.pno) rp_count
            ,row_number() over (partition by pr.pno order by pr.routed_at) rk
        from rot_pro.parcel_route pr
        join
            (
                select
                    t1.pno
                from t t1
                group by 1
            ) t1 on t1.pno = pr.pno
        where
            pr.route_action = 'REPLACE_PNO'
    )
select
    t1.pno 运单号
    ,convert_tz(t1.created_at, '+00:00', '+07:00') 揽收时间
    ,r1.rp_count 换单次数
    ,case t1.returned
        when 0 then '正向'
        when 1 then '逆向'
     else null end 是否正向
    ,convert_tz(r1.routed_at, '+00:00', '+07:00') 第一次换单时间
    ,convert_tz(r2.routed_at, '+00:00', '+07:00') 第二次换单时间
    ,r2.staff_info_id 操作人
    ,qz.take_count 强制拍照次数
    ,t2.pr_time 强制拍照时间
    ,ddd.CN_element 疑难件类型
    ,if(val.pr_count > 0, '是', '否') 当天其他有效路由
from
    (
        select
            t1.pno
            ,t1.created_at
            ,t1.returned
        from t t1
        group by 1,2,3
    ) t1
left join rp r1 on r1.pno = t1.pno and r1.rk = 1
left join rp r2 on r2.pno = t1.pno and r2.rk = 1
left join
    (
        select
            pr.pno
            ,count(pr.id) take_count
        from rot_pro.parcel_route pr
        join (
                select
                    t1.pno
                from t t1
                group by 1
            ) t1 on t1.pno = pr.pno
        where
            pr.route_action = 'TAKE_PHOTO'
        group by 1
    ) qz on qz.pno = t1.pno
left join t t2 on t2.pno = t1.pno
left join fle_staging.diff_info di on di.pno = t1.pno and di.created_at > date_sub(t2.pr_date, interval 7 hour) and di.created_at < date_add(t2.pr_date, interval 17 hour )
left join dwm.dwd_dim_dict ddd on ddd.element = di.diff_marker_category and ddd.db = 'fle_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
left join
    (
        select
            pr.pno
            ,date(convert_tz(pr.routed_at, '+00:00', '+07:00')) pr_date
            ,count(pr.id) pr_count
        from rot_pro.parcel_route pr
        join (
            select
                t1.pno
            from t t1
            group by 1
        ) t1 on t1.pno = pr.pno
        where
            pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
        group by 1
    ) val on val.pno = t2.pno and val.pr_date = t2.pr_date


;

-- 滞留场景

with t as
    (
        select
            pr.pno
            ,convert_tz(pi.created_at, '+00:00', '+07:00') pi_time
            ,pi.cod_amount
            ,pr.store_id
            ,pi.state
            ,pi.returned
            ,pr.routed_at
            ,convert_tz(pr.routed_at ,'+00:00', '+07:00') pr_time
            ,date(convert_tz(pr.routed_at ,'+00:00', '+07:00')) pr_date
        from rot_pro.parcel_route pr
        left join fle_staging.parcel_info pi on pi.pno = pr.pno
        where
            pr.route_action = 'TAKE_PHOTO'
            and pr.routed_at > '2023-10-17 17:00:00'
            and json_extract(pr.extra_value, '$.forceTakePhotoCategory') = 3
            and json_extract(pr.extra_value, '$.aiPhotoCheckReason') is not null
            and pr.routed_at > '2023-10-17 17:00:00'
    )
select
    t1.pno 运单号
    ,t1.pi_time 揽收时间
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
    end 包裹状态
    ,pl.created_at 进入L来源时间
    ,if(pl.state in (5,6), datediff(pl.created_at, pl.updated_at), null) 滞留天数
    ,dy.dy_count 打印面单次数
    ,t1.cod_amount/100 是否cod包裹
    ,if(dt.双重预警 = 'Alert', '是', '否')  关联网点是否为爆仓网点
    ,qz.take_count 强制拍照次数
    ,t1.pr_time 强制拍照时间
    ,inv.inv_count 盘库次数
from t t1
left join
    (
        select
            plt.pno
            ,plt.created_at
            ,plt.updated_at
            ,plt.state
            ,row_number() over (partition by plt.pno order by plt.created_at desc ) rk
        from bi_pro.parcel_lose_task plt
        join
            (
                select t1.pno from t t1 group by 1
            ) t1 on t1.pno = plt.pno
        where
            plt.source = 12
    ) pl on pl.pno = t1.pno and  pl.rk = 1
left join
    (
        select
            pr.pno
            ,count(pr.pno) dy_count
        from rot_pro.parcel_route pr
        join
            (
                select t1.pno from t t1 group by 1
            ) t1 on t1.pno = pr.pno
        where
            pr.route_action = 'REPLACE_PNO'
        group by 1
    ) dy on dy.pno = t1.pno
left join dwm.dwd_th_network_spill_detl_rd dt on dt.统计日期 = t1.pr_date and dt.网点ID = t1.store_id
left join
    (
        select
            t1.pno
            ,count(t1.pno) take_count
        from t t1
        group by 1
    ) qz on qz.pno = t1.pno
left join
    (
        select
            pr.pno
            ,count(pr.pno) inv_count
        from rot_pro.parcel_route pr
        join
            (
                select t1.pno from t t1 group by 1
            ) t1 on t1.pno = pr.pno
        where
            pr.route_action = 'INVENTORY'
        group by 1
    ) inv on inv.pno = t1.pno

