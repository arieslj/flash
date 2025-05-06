with t as
    (
        select
            plt.pno
            ,plt.id
            ,plt.created_at
            ,plt.duty_reasons
            ,plt.link_type
            ,plt.duty_type
            ,date_sub(plt.created_at, interval 7 hour) plt_created_at
        from bi_pro.parcel_lose_task plt
        where
            plt.created_at > '2024-11-01'
            and plt.created_at < '2024-12-01'
            and plt.last_valid_action = 'SHIPMENT_WAREHOUSE_SCAN'
            and plt.state = 6
            and plt.duty_result = 1
            and plt.penalties > 0
    )
select
    plr.duty_store 责任网点
    ,pr.next_store_name 下一站网点
    ,t.t_value 判责原因
    ,case t1.link_type
        when 0 then 'ipc计数后丢失'
        when 1 then '揽收网点已揽件，未收件入仓'
        when 2 then '揽收网点已收件入仓，未发件出仓'
        when 3 then '中转已到件入仓扫描，中转未发件出仓'
        when 4 then '揽收网点已发件出仓扫描，分拨未到件入仓(集包)'
        when 5 then '揽收网点已发件出仓扫描，分拨未到件入仓(单件)'
        when 6 then '分拨发件出仓扫描，目的地未到件入仓(集包)'
        when 7 then '分拨发件出仓扫描，目的地未到件入仓(单件)'
        when 8 then '目的地到件入仓扫描，目的地未交接,当日遗失'
        when 9 then '目的地到件入仓扫描，目的地未交接,次日遗失'
        when 10 then '目的地交接扫描，目的地未妥投'
        when 11 then '目的地妥投后丢失'
        when 12 then '途中破损/短少'
        when 13 then '妥投后破损/短少'
        when 14 then '揽收网点已揽件，未收件入仓'
        when 15 then '揽收网点已收件入仓，未发件出仓'
        when 16 then '揽收网点发件出仓到分拨了'
        when 17 then '目的地到件入仓扫描，目的地未交接'
        when 18 then '目的地交接扫描，目的地未妥投'
        when 19 then '目的地妥投后破损短少'
        when 20 then '分拨已发件出仓，下一站分拨未到件入仓(集包)'
        when 21 then '分拨已发件出仓，下一站分拨未到件入仓(单件)'
        when 22 then 'ipc计数后丢失'
        when 23 then '超时效sla'
        when 24 then '分拨发件出仓到下一站分拨了'
	end 判责环节
    ,case t1.duty_type
        when 1 then '快递员100%套餐'
        when 2 then '仓9主1套餐(仓管90%主管10%)'
        when 3 then '仓9主1套餐(仓管90%主管10%)'
        when 4 then '双黄套餐(A网点仓管40%主管10%B网点仓管40%主管10%)'
        when 5 then '快递员721套餐(快递员70%仓管20%主管10%)'
        when 6 then '仓管721套餐(仓管70%快递员20%主管10%)'
        when 8 then 'LH全责（LH100%）'
        when 7 then '其他(仅勾选“该运单的责任人需要特殊处理”时才能使用该项)'
        when 9 then '加盟商套餐'
        when 10 then '双黄套餐(计数网点仓管40%计数网点主管10%对接分拨仓管40%对接分拨主管10%)'
        when 19 then '双黄套餐(计数网点仓管40%计数网点主管10%对接分拨仓管40%对接分拨主管10%)'
        when 20 then  '加盟商双黄套餐（加盟商50%网点仓管45%主管5%）'
    end 套餐
    ,count(distinct t1.id) 判责量
    ,count(distinct if(am.id is not null, t1.id, null)) 申诉量
    ,count(distinct if(am.isappeal = 5 or am.isdel = 1, t1.id, null)) 申诉成功量
from t t1
left join bi_pro.translations t on t1.duty_reasons = t.t_key AND t.`lang` = 'zh-CN'
left join
    (
        select
            pr.pno
            ,pr.next_store_name
            ,row_number() over (partition by t1.pno order by pr.routed_at desc ) rk
        from rot_pro.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > '2024-08-01'
            and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
    ) pr on t1.pno = pr.pno and pr.rk = 1
left join
    (
        select
            t1.id
            ,group_concat(distinct ss.name) duty_store
        from bi_pro.parcel_lose_responsible plr
        join t t1 on t1.id = plr.lose_task_id
        left join fle_staging.sys_store ss on ss.id = plr.store_id
        where
            plr.created_at > '2024-08-01'
        group by 1
    ) plr on t1.id = plr.id
left join
    (
        select
            distinct
            t1.id
            ,am.isappeal
            ,am.isdel
        from bi_pro.abnormal_message am
        join t t1 on t1.id = json_extract(am.extra_info, '$."losr_task_id"')
        where
            am.abnormal_time > '2024-08-01'
            and (am.isdel = 1 or am.isappeal > 1)

    ) am on am.id = t1.id
group by 1,2,3,4,5


;

-- 明细


with t as
    (
        select
            plt.pno
            ,plt.id
            ,plt.created_at
            ,plt.duty_reasons
            ,plt.link_type
            ,plt.duty_type
            ,date_sub(plt.created_at, interval 7 hour) plt_created_at
        from bi_pro.parcel_lose_task plt
        where
            plt.created_at > '2024-10-01'
            and plt.created_at < '2024-11-01'
            and plt.last_valid_action = 'SHIPMENT_WAREHOUSE_SCAN'
            and plt.state = 6
            and plt.duty_result = 1
            and plt.penalties > 0
    )
select
    distinct
    plr.duty_store 责任网点
    ,pr.next_store_name 下一站网点
    ,t.t_value 判责原因
    ,case t1.link_type
        when 0 then 'ipc计数后丢失'
        when 1 then '揽收网点已揽件，未收件入仓'
        when 2 then '揽收网点已收件入仓，未发件出仓'
        when 3 then '中转已到件入仓扫描，中转未发件出仓'
        when 4 then '揽收网点已发件出仓扫描，分拨未到件入仓(集包)'
        when 5 then '揽收网点已发件出仓扫描，分拨未到件入仓(单件)'
        when 6 then '分拨发件出仓扫描，目的地未到件入仓(集包)'
        when 7 then '分拨发件出仓扫描，目的地未到件入仓(单件)'
        when 8 then '目的地到件入仓扫描，目的地未交接,当日遗失'
        when 9 then '目的地到件入仓扫描，目的地未交接,次日遗失'
        when 10 then '目的地交接扫描，目的地未妥投'
        when 11 then '目的地妥投后丢失'
        when 12 then '途中破损/短少'
        when 13 then '妥投后破损/短少'
        when 14 then '揽收网点已揽件，未收件入仓'
        when 15 then '揽收网点已收件入仓，未发件出仓'
        when 16 then '揽收网点发件出仓到分拨了'
        when 17 then '目的地到件入仓扫描，目的地未交接'
        when 18 then '目的地交接扫描，目的地未妥投'
        when 19 then '目的地妥投后破损短少'
        when 20 then '分拨已发件出仓，下一站分拨未到件入仓(集包)'
        when 21 then '分拨已发件出仓，下一站分拨未到件入仓(单件)'
        when 22 then 'ipc计数后丢失'
        when 23 then '超时效sla'
        when 24 then '分拨发件出仓到下一站分拨了'
	end 判责环节
    ,case t1.duty_type
        when 1 then '快递员100%套餐'
        when 2 then '仓9主1套餐(仓管90%主管10%)'
        when 3 then '仓9主1套餐(仓管90%主管10%)'
        when 4 then '双黄套餐(A网点仓管40%主管10%B网点仓管40%主管10%)'
        when 5 then '快递员721套餐(快递员70%仓管20%主管10%)'
        when 6 then '仓管721套餐(仓管70%快递员20%主管10%)'
        when 8 then 'LH全责（LH100%）'
        when 7 then '其他(仅勾选“该运单的责任人需要特殊处理”时才能使用该项)'
        when 9 then '加盟商套餐'
        when 10 then '双黄套餐(计数网点仓管40%计数网点主管10%对接分拨仓管40%对接分拨主管10%)'
        when 19 then '双黄套餐(计数网点仓管40%计数网点主管10%对接分拨仓管40%对接分拨主管10%)'
        when 20 then  '加盟商双黄套餐（加盟商50%网点仓管45%主管5%）'
    end 套餐
#     ,count(distinct t1.id) 判责量
#     ,count(distinct if(am.id is not null, t1.id, null)) 申诉量
#     ,count(distinct if(am.isappeal = 5 or am.isdel = 1, t1.id, null)) 申诉成功量
    ,t1.pno
from t t1
left join bi_pro.translations t on t1.duty_reasons = t.t_key AND t.`lang` = 'zh-CN'
left join
    (
        select
            pr.pno
            ,pr.next_store_name
            ,row_number() over (partition by t1.pno order by pr.routed_at desc ) rk
        from rot_pro.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > '2024-08-01'
            and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
    ) pr on t1.pno = pr.pno and pr.rk = 1
left join
    (
        select
            t1.id
            ,group_concat(distinct ss.name) duty_store
        from bi_pro.parcel_lose_responsible plr
        join t t1 on t1.id = plr.lose_task_id
        left join fle_staging.sys_store ss on ss.id = plr.store_id
        where
            plr.created_at > '2024-08-01'
        group by 1
    ) plr on t1.id = plr.id
left join
    (
        select
            distinct
            t1.id
            ,am.isappeal
            ,am.isdel
        from bi_pro.abnormal_message am
        join t t1 on t1.id = json_extract(am.extra_info, '$."losr_task_id"')
        where
            am.abnormal_time > '2024-08-01'
            and (am.isdel = 1 or am.isappeal > 1)

    ) am on am.id = t1.id
where
    plr.duty_store = 'OS-BPL2-Return Warehouse'
    and pr.next_store_name = 'OS-BPL2-Return Warehouse'
-- group by 1,2,3,4,5
