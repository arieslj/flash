with t as
    (
        select
            plt.pno
            ,plt.created_at
            ,plt.parcel_created_at
            ,pi.returned
            ,pi.cod_amount
            ,plt.state
            ,plt.link_type
            ,bc.client_name
            ,pi.dst_store_id
        from bi_pro.parcel_lose_task plt
        left join fle_staging.parcel_info pi on pi.pno = plt.pno
        left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = plt.client_id
        where
            plt.source = 12
            and plt.created_at > '2023-10-18'
    )
select
    t1.pno
    ,if(pc.pno is not null ,'y', 'n') 此单是否同时判责为疑似丢失
    ,if(t1.returned = 1, 'y','n') 正向还是逆向
    ,case t1.state
        when 1 then '丢失件待处理'
        when 2 then '疑似丢失件待处理'
        when 3 then '待工单回复'
        when 4 then '已工单回复'
        when 5 then '无须追责'
        when 6 then '责任人已认定'
    end 处理结果
    ,case t1.`link_type`
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
    ,t1.cod_amount/100 cod
    ,datediff(t1.created_at, t1.parcel_created_at) 积压天数
    ,datediff(t1.created_at, convert_tz(dst.routed_at, '+00:00', '+07:00')) 滞留天数
    ,t1.client_name 平台
    ,case
        when t1.client_name = 'lazada' and t1.created_at > laz.sla_end_date then 'y'
        when t1.client_name = 'shopee' and t1.created_at > sho.end_date then 'y'
        when t1.client_name = 'tiktok' and t1.created_at > tik.end_date then 'y'
        when t1.client_name = 'shein' and t1.created_at >date_add(t1.parcel_created_at, interval 72 hour) then 'y'
        else null
    end 是否超时效
from t t1
left join
    (
        select
            plt.pno
        from bi_pro.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.source = 3
            and plt.created_at > '2023-08-01'
            and if(plt.state in (1,2,3,4), plt.created_at < t1.created_at, plt.created_at < t1.created_at and plt.updated_at > t1.created_at)
        group by 1
    ) pc on pc.pno = t1.pno
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at) rk
        from rot_pro.parcel_route pr
        join t t1 on t1.pno = pr.pno and pr.store_id = t1.dst_store_id
        where
            pr.routed_at > '2023-08-01'
    ) dst on dst.pno = t1.pno and dst.rk = 1
left join dwm.dwd_ex_th_lazada_sla_detail laz on laz.pno = t1.pno
left join dwm.dwd_ex_th_shopee_sla_detail sho on sho.pno = t1.pno
left join dwm.dwd_ex_th_tiktok_sla_detail tik on tik.pno = t1.pno

