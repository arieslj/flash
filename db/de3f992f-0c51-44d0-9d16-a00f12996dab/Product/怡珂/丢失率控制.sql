-- 文档：https://flashexpress.feishu.cn/docx/HUKFdmxSyomHmxx8fYnc07Evnyb

with t as
    (
        select
            plt.pno
            ,plt.id
            ,plt.duty_type
            ,plt.link_type
        from bi_pro.parcel_lose_task plt
        where
            plt.state = 6
            and plt.duty_result = 1
            and plt.updated_at >= '2023-12-01'
            and plt.updated_at < '2023-12-08'
    )

select
    t1.pno
    ,plr.store_name 判责丢失网点
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
    ,if(sc.pno is null, 'n', 'y') 是否扫描
    ,if(pri.pno is null, 'n', 'y') 是否打印
    ,if(di.pno is null, 'n', 'y') 是否有过疑难件
    ,if(pi.cod_enabled = 0, 'n', 'y') 是否cod
    ,pi.cod_amount/100 cod金额
from t t1
left join fle_staging.parcel_info pi on pi.pno = t1.pno
left join
    (
        select
            t1.id
           ,group_concat(distinct ss.name) store_name
        from bi_pro.parcel_lose_responsible plr
        join t t1 on t1.id = plr.lose_task_id
        left join fle_staging.sys_store ss on ss.id = plr.store_id
        group by 1
    ) plr on plr.id = t1.id
left join
    (
        select
            pr.pno
        from rot_pro.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > date_sub(curdate(),interval 2 month)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        group by 1
    ) sc on sc.pno = t1.pno
left join
    (
        select
            pr.pno
        from rot_pro.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > date_sub(curdate(), interval 2 month)
            and pr.route_action = 'PRINTING'
        group by 1
    ) pri  on pri.pno = t1.pno
left join
    (
        select
            pr.pno
        from fle_staging.diff_info  pr
        join t t1 on t1.pno = pr.pno
        where
            pr.created_at > date_sub(curdate(),interval 2 month)
        group by 1
    ) di on di.pno = t1.pno