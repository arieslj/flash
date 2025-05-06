with t as
    (
        select
            plt.id
            ,plt.pno
            ,plt.client_id
            ,if(plt.client_id in ('AA0703','AA0838','AA0622','AA0428'), 'y', 'n') cb
            ,plt.parcel_created_at
            ,plt.last_valid_routed_at
            ,plt.last_valid_store_id
            ,plt.last_valid_action
            ,plt.last_valid_staff_info_id
            ,plt.link_type
            ,plt.created_at
            ,group_concat(distinct s2.name) duty_store
        from bi_pro.parcel_lose_responsible plr
        join
            (
                select
                    a.*
                from
                    (
                        select
                            plt.pno
                            ,plt.id
                            ,plt.client_id
                            ,plt.last_valid_action
                            ,plt.last_valid_routed_at
                            ,plt.last_valid_store_id
                            ,plt.last_valid_staff_info_id
                            ,plt.parcel_created_at
                            ,plt.created_at
                            ,plt.link_type
                            ,row_number() over (partition by plt.pno order by plt.created_at desc) rk
                        from bi_pro.parcel_lose_task plt
                        where
                            plt.state = 6
                            and plt.duty_result = 1
                            and plt.penalties > 0
                            and plt.created_at >= '2024-04-01'
                    ) a
                where
                    a.rk = 1
            ) plt on plt.id = plr.lose_task_id
        left join fle_staging.sys_store s2 on s2.id = plr.store_id
#         where
#             plr.store_id = 'MY04040300'
        group by 1,2,3,4,5

    )
select
    a1.*
    ,pct.claim_money 理赔金额
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as  客户类型
#     ,sms.device_id 分拣机编号
#     ,sms.feeder_no 供件台号
#     ,sms.part_off_at 下件时间
#     ,sms.part_off_no 下件格口号
from
    (
        select
            a.*
        from
            (
                select
                    t1.pno
                    ,t1.client_id
                    ,oi.cogs_amount/100 cogs
                    ,oi.cod_amount/100 cod
                    ,t1.cb 是否跨境
                    ,ss2.name 目的地网点
                    ,t1.duty_store 责任网点
                    ,t1.parcel_created_at 揽收时间
                    ,ddd.cn_element 进入闪速前最后一条有有效路由
                    ,ss.name 进入闪速前最后一条有有效路由网点
                    ,t1.last_valid_routed_at 进入闪速前最后一条有有效路由时间
                    ,t1.last_valid_staff_info_id 进入闪速前最后一条有有效路由操作员工
                    ,case
                        when hsi.state = 1  then '在职'
                        when hsi.state = 2 then '离职'
                        when hsi.state = 3 then '停职'
                    end 进入闪速前最后一条有有效路由操作员工在职状态
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
                    ,pi.store_weight/1000 包裹重量kg
                    ,concat_ws('*', pi.exhibition_length, pi.exhibition_width, pi.exhibition_height) 尺寸
                from t t1
                left join dwm.dwd_dim_dict ddd on ddd.element = t1.last_valid_action and ddd.db = 'rot_pro' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
                left join fle_staging.parcel_info pi on pi.pno = t1.pno
                left join fle_staging.order_info oi on oi.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
                left join fle_staging.sys_store ss on ss.id = t1.last_valid_store_id
                left join fle_staging.sys_store ss2 on ss2.id = pi.dst_store_id
                left join bi_pro.staff_info hsi on hsi.id = t1.last_valid_staff_info_id
            ) a
    ) a1
left join
    (
        select
            pct.pno
            ,replace(json_extract(pcn.`neg_result`,'$.money'),'\"','') claim_money
            ,row_number() over (partition by pct.pno  order by pcn.`created_at` DESC ) rn
        from bi_pro.parcel_claim_task pct
        join t t1 on t1.pno = pct.pno
        left join bi_pro.parcel_claim_negotiation pcn on pcn.task_id =  pct.id
        where
            pct.parcel_created_at > '2024-01-01'
            and pct.state = 6
    ) pct on pct.pno = a1.pno and pct.rn = 1
# left join
#     (
#         select
#             sms.pno
#             ,sms.device_id
#             ,sms.feeder_no
#             ,sms.part_off_at
#             ,sms.part_off_no
#             ,row_number() over (partition by sms.pno order by sms.created_at desc) rk
#         from fle_staging.sorting_machines_sort_log sms
#         join t t1 on t1.pno = sms.pno
#         where
#             sms.created_at > '2023-12-01'
#     ) sms on sms.pno = a1.pno and sms.rk = 1
left join fle_staging.ka_profile kp on kp.id = a1.client_id
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = a1.client_id