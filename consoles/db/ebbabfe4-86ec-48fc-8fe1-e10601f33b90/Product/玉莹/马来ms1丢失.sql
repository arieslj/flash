with t as
    (
        select
            plt.id
            ,plt.pno
            ,plt.client_id
            ,if(plt.client_id in ('AA0039','AA0063','AA0070','AA0084','AA0085','AA0107','AA0108','AA0109','AA0112','AA0114','AA0115','AA0116','AA0121','AA0125','AA0126','AA0132','AA0133','AA0138','AA0143','CA3001','AA0105','AA0112','AA0133','AA0055','AA0178'), 'y', 'n') cb
            ,plt.parcel_created_at
            ,plt.last_valid_routed_at
            ,plt.last_valid_store_id
            ,plt.last_valid_action
            ,plt.last_valid_staff_info_id
            ,plt.link_type
            ,plt.created_at
            ,group_concat(distinct s2.name) duty_store
        from my_bi.parcel_lose_responsible plr
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
                        from my_bi.parcel_lose_task plt
                        where
                            plt.state = 6
                            and plt.duty_result = 1
                            and plt.penalties > 0
                            and plt.created_at > '2024-04-01'
                            and plt.created_at < '2024-05-01'
                    ) a
                where
                    a.rk = 1
            ) plt on plt.id = plr.lose_task_id
        left join my_staging.sys_store s2 on s2.id = plr.store_id
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
    ,sms.device_id 分拣机编号
    ,sms.feeder_no 供件台号
    ,sms.part_off_at 下件时间
    ,sms.part_off_no 下件格口号
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
                    ,ft.store_name MS1上游网点
                    ,convert_tz(pssn.van_arrived_at, '+00:00', '+08:00') MS1入港时间
                    ,convert_tz(pssn.arrived_at, '+00:00', '+08:00') MS1到件入仓时间
                    ,pssn.arrival_pack_no 到件入仓集包号
                    ,convert_tz(pssn.first_valid_routed_at, '+00:00', '+08:00')  MS1第一条有效路由时间
                    ,pssn.van_in_line_name MS1入港车线
                    ,pssn.next_store_name MS1下游网点
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
                    ,convert_tz(pssn.shipped_at, '+00:00', '+08:00') 发件出仓时间
                    ,pssn.shipment_pack_no 发件出仓集包号
                    ,row_number() over (partition by t1.pno order by coalesce(pssn.van_arrived_at, pssn.arrived_at) desc) rk
                from t t1
                left join dwm.parcel_store_stage_new pssn on pssn.pno = t1.pno and pssn.store_id = 'MY04040300' and coalesce(pssn.van_arrived_at, pssn.arrived_at) is not null
                left join my_bi.fleet_time ft on ft.proof_id = pssn.van_in_proof_id and ft.arrive_type in (3,5) and ft.next_store_id = 'MY04040300'
                left join dwm.dwd_dim_dict ddd on ddd.element = t1.last_valid_action and ddd.db = 'my_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
                left join my_staging.parcel_info pi on pi.pno = t1.pno
                left join my_staging.order_info oi on oi.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
                left join my_staging.sys_store ss on ss.id = t1.last_valid_store_id
                left join my_staging.sys_store ss2 on ss2.id = pi.dst_store_id
                left join my_backyard.staff_info hsi on hsi.id = t1.last_valid_staff_info_id
            ) a
        where
            a.rk = 1
    ) a1
left join
    (
        select
            pct.pno
            ,replace(json_extract(pcn.`neg_result`,'$.money'),'\"','') claim_money
            ,row_number() over (partition by pct.pno  order by pcn.`created_at` DESC ) rn
        from my_bi.parcel_claim_task pct
        join t t1 on t1.pno = pct.pno
        left join my_bi.parcel_claim_negotiation pcn on pcn.task_id =  pct.id
        where
            pct.parcel_created_at > '2024-01-01'
            and pct.state = 6
    ) pct on pct.pno = a1.pno and pct.rn = 1
left join
    (
        select
            sms.pno
            ,sms.device_id
            ,sms.feeder_no
            ,sms.part_off_at
            ,sms.part_off_no
            ,row_number() over (partition by sms.pno order by sms.created_at desc) rk
        from dwm.sorting_machines_sort_log_d sms
        join t t1 on t1.pno = sms.pno
        where
            sms.created_at > '2023-12-01'
    ) sms on sms.pno = a1.pno and sms.rk = 1
left join my_staging.ka_profile kp on kp.id = a1.client_id
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = a1.client_id


;


select
    count(distinct pr.pno) MS1到件入仓包裹数
    ,count(distinct if(pi.client_id in ('AA0039','AA0063','AA0070','AA0084','AA0085','AA0107','AA0108','AA0109','AA0112','AA0114','AA0115','AA0116','AA0121','AA0125','AA0126','AA0132','AA0133','AA0138','AA0143','CA3001','AA0105','AA0112','AA0133','AA0055','AA0178'), pr.pno, null)) MS1k跨境件
    ,count(distinct if(pi.client_id in ('AA0039','AA0063','AA0070','AA0084','AA0085','AA0107','AA0108','AA0109','AA0112','AA0114','AA0115','AA0116','AA0121','AA0125','AA0126','AA0132','AA0133','AA0138','AA0143','CA3001','AA0105','AA0112','AA0133','AA0055','AA0178'), pr.pno, null))/count(distinct pr.pno) 跨境占比
    ,count(distinct if(pi.returned = 0, pr.pno, null)) MS1正向件数
    ,count(distinct if(pi.client_id in ('AA0039','AA0063','AA0070','AA0084','AA0085','AA0107','AA0108','AA0109','AA0112','AA0114','AA0115','AA0116','AA0121','AA0125','AA0126','AA0132','AA0133','AA0138','AA0143','CA3001','AA0105','AA0112','AA0133','AA0055','AA0178') and pi.returned = 0, pr.pno, null)) 正向跨件
    ,count(distinct if(pi.client_id in ('AA0039','AA0063','AA0070','AA0084','AA0085','AA0107','AA0108','AA0109','AA0112','AA0114','AA0115','AA0116','AA0121','AA0125','AA0126','AA0132','AA0133','AA0138','AA0143','CA3001','AA0105','AA0112','AA0133','AA0055','AA0178') and pi.returned = 0, pr.pno, null))/count(distinct if(pi.returned = 0, pr.pno, null)) 正向跨境占比
from my_staging.parcel_route pr
left join my_staging.parcel_info pi on pi.pno = pr.pno
where
    pr.routed_at > '2024-02-29 16:00:00'
    and pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
    and pr.store_id = 'MY04040300'


;

with t as
    (
        select
            fvp.relation_no pno
        from my_staging.fleet_van_proof_parcel_detail  fvp
        where
            fvp.proof_id = 'MS1L2410EED'
            and fvp.relation_category in (1,3)
        group by 1
    )
select
    t1.pno
    ,a.pno lose
from t t1
left join
    (
        select
            plt.pno
        from my_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state = 6
            and plt.duty_result = 1
        group by 1
    ) a on a.pno = t1.pno
left

;

select
  case ss.category
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
        end 网点类型
    ,count(distinct sms.pno)
from dwm.sorting_machines_sort_log_d sms
left  join my_staging.parcel_info pi on pi.pno = sms.pno
left join my_staging.sys_store ss on ss.id = pi.dst_store_id
where
    sms.created_at > '2024-03-27'
    and sms.part_off_no in (187,367)
   -- and ss.category = 10
   group by 1

;

select
    count(distinct  pi.pno) all_data
    ,count(distinct if(plt.pno is not null, pi.pno, null)) lose_data
    ,count(distinct if(plt.pno is not null, pi.pno, null))/count(distinct  pi.pno) rate
from my_staging.parcel_info pi
left join my_bi.parcel_lose_task plt on plt.pno = pi.pno and plt.state = 6 and plt.duty_result = 1
where
    pi.src_phone = '0126114930'
    and pi.created_at > '2024-01-01'

;

select
    pi.pno
    ,if(plt.pno is not null, 'y', 'n') 是否丢失
from my_staging.parcel_info pi
left join my_bi.parcel_lose_task plt on plt.pno = pi.pno and plt.state = 6 and plt.duty_result = 1
where
    pi.pno in ('MT10101WVSQT1Z','MT06011WP4JG4Z','MT06011WNWPH4Z','MT08061WW79Q3Z','MT03061WW14M5Z','MT11051WW5S21Z','MT01041WWH5S5Z','MT06011WNSKQ9Z','MT04051WWV3B5Z','MT04071WNGJ56Z','MT07061WV26J8Z','MT08061WU39R8Z','MT06011WKWH67Z','MT06011WKWH67Z','MT11061WTR5D0Z','MT06011WP44S2Z','MT06011WP44S2Z','MT06011WP44S2Z','mT06011WHZFK0Z','mT06011WHZFK0Z','MT04041WVQQ09Z','MT06011WNR4Z1Z','MT06011WNPDQ2Z','MT06011WNPDQ2Z','mT06011WTUu39z','MT06011WPG4C1Z','MT06011WDTE90Z','MT06011WDTE90Z','MT06011WNXHG6Z','MT06011WNXHG6Z','MT04031WVYMT1Z','MT06011WP30S9Z','MT02021WKKKS6Z','MT02021WKKKS6Z','MT02021WKKKS6Z','MT06011WNPFW2Z','MT06011WNK4F7Z','m0601Y6SH2CO','MT01021WJSZ93Z','M0102YE8NWDW1','MT08011WVQPM0Z','M0601XEJUGCG','MT06011WPGT09Z','MT02021WK0AX5Z','MT04071WHYV57Z','MT04071WHYV57Z','MT06011WNS2D0Z','MT06011WUAGP6z','M0404YE7XPBP1','MT04071WHF175Z','MT04071WHYV57Z','MT02021WK0AX5Z','MT01021WJSZ93Z','MT02021WKKKS6Z','MT03061WUHJX4Z','MT04021WVP886Z','MT10071WWHDR9Z','MT01091WVMC69Z','MT04051WV0069Z','MT01011WWK056Z','MT09031WVJFT2Z','MT04041WW2MR4Z','M0404YE9GQBM1','m1008YE2R0AM','MT01011WW1P00Z','MT01011WWR447Z','MT07051WWT3P6Z','MT09061WWYZT0Z','MT01031WWQGA7Z','MT13011WWYTZ6Z','MT04091WWZUA3Z','MT11041WWZ6N3Z','MT09041WWY0E1Z','MT08011WW9B34Z','MT11021WW7MW4Z','MT01021WWTF02Z','MT07101WWV8W9Z','MT07051WX0U43Z','MT08021WWNZ93Z','MT04071WWGEE7Z','MT09041WWQMC4Z','MT10021WWNBU8Z','MT07101WWNWU6Z','MT01031WWEDF4Z','MT04081WWV9M7Z','MT11041WWEKP2Z','MT09041WWM875Z','MT13011WWWHE3Z','MT10071WWM5Z1Z','MT11041WWA8K2Z','MT04051WX3369Z','MT11031WUX014Z','M0601XCNRTCC','MT01011WWDNU9Z','MT04071WHYV57Z','MT09091WWGDA5Z','MT04041WWU0G7Z','MT04021WWNJ11Z','MT12031WWV557Z','MT01101WWF2J2Z','MT12041WWJ5D9Z','MT10071WWUNH5Z','MT09061WWVT44Z','MT06011WWCP16Z','MT01031WWG5H6Z','MT01081WWJQR0Z','MT02021WK0AX5Z','MT02021WKKKS6Z','MT02021WKKKS6Z','ABC-abc-1234','M0601XDZJMCC','M0601XR4YEPE0','MT04091WNG4Z1Z','MT04091WNG4Z1Z','MT06011WD4402Z','MT06011WE31N2Z','MT06011WETJD8Z','M0102Y9BHAEA0','M0102YBXHCEA0','M0402Y8P3PAE1','M0402Y9BGDAH0','M0402Y9BGDAH0','M0107Y9BJMAB0','M0402Y9BGDAH0','M0404YCYUMBC','M0407YDDNRDC','M0601Y4EXTCC','M0601Y4KBWPE0','M0601Y9M9ECC','M0601YAGVHCC','M0601YEAAQAA1','M0806Y80A6AA','M0806YAWENEG','M0806YBXSAEE','M0904YAXM7DJ','MT06011WFQC34Z','MT06011WFUD68Z','MT06011WFUD68Z','MT06011WH4TF1Z','MT06011WHCG14Z','MT06011WJ4PJ4Z','MT06011WJA8B8Z','MT06011WK9164Z','MT06011WKC0S2Z','MT06011WKC0S2Z','MT06011WKE6T3Z','MT06011WKFDH3Z','MT06011WKFDH3Z','MT06011WKFDH3Z','MT06011WKFQ77Z','MT06011WKFQ77Z','MT06011WKT1A2Z','MT06011WKT1A2Z','MT06011WKVT24Z','MT06011WKVT24Z','MT06011WKWAJ1Z','MT06011WKWAJ1Z','MT06011WKZ5A5Z','MT06011WKZ5A5Z','MT06011WM7R66Z','MT06011WM7R66Z','MT06011WMB0U6Z','MT06011WMB0U6Z','MT06011WMDRB7Z','MT06011WMDRB7Z','MT06011WMM7S3Z','MT06011WMM7S3Z','MT06011WMN7H6Z','MT06011WMN7H6Z','MT06011WMP4Y6Z','MT06011WMP4Y6Z','MT06011WMSEZ9Z','MT06011WMSEZ9Z','MT06011WMT1Y7Z','MT06011WMT1Y7Z','MT06011WMTT12Z','MT06011WMTT12Z','MT06011WN0W46Z','MT06011WN0W46Z','MT06011WN7218Z','MT06011WN7218Z','MT06011WNF1J2Z','MT06011WNF1J2Z','MT06011WNGVC2Z','MT06011WNGVC2Z','MT06011WNQKY3Z','MT06011WNQKY3Z','MT06011WPFZX5Z','MT06011WPFZX5Z','MT06011WRGN81Z','MT10081WUSU08Z','M0402Y9BGDAH0','MT06011WG05M5Z','MT06011WG05M5Z','MT06011WHCG14Z','MT06011WJ4PJ4Z','MT0,6+%2FWJA8B8Z','MT06011WJA8B8Z','MT06011WK9164Z','MT06011WKE6T3Z','MT06011WRGN81Z','MT06011WRGN81Z','M0402Y9BGDAH0','M0402Y9BGDAH0','M0402Y9BGDAH0','M0402Y9BGDAH0','M0407XWNBKCZ','M0601WYWJACG','M0601X54DWCO','M0601X54DWCO','M0601X54DWCO','M0404XATD5Bn0','M0601XU7A8IH','M0601XZ727CJ','M0601XZ9S6BU','M0601Y2NMXBY','M0601Y2NMXBY','M0601YAWFZCE','M0601YAWFZCE','M0601YB0NCCJ','M1104YAWA1AN2','MT01021WQ5828Z','MT06011WHE5J2Z','MT06011WHE5J2Z','M0407XWNBKCZ','M0407XWNBKCZ','M0407YBJVKDC','M0407YBJX5DC','M0407YBJXNDC','M0407YBJZYDC','M0407YBK4WDC','M0407YBK5ADM','M0407XWNBKCZ','M0407YBK5NDM','M0407YBKAWDM','M0601YBXHZAU','MT08011WQ84E9Z','MT09081WPA3V5Z','MT10091WR2QA3Z','MT11031WR2PB1Z','MT14011WQZQB4Z','MT06011WMF897Z','MT06011WMF897Z','MT06011WMSJ57Z','MT06011WMSJ57Z','MT06011WN5V55Z','MT06011WN5V55Z'
              )
group by 1,2

;

select
    pssn.pno
    ,pssn.next_store_name
    ,p2.arrived_at
    ,p2.van_arrived_at
    ,p2.van_in_line_name
    ,p2.van_in_proof_id
from dwm.parcel_store_stage_new pssn
join my_staging.parcel_info pi on pi.pno = pssn.pno and pi.state = 5
left join dwm.parcel_store_stage_new p2 on p2.pno = pssn.pno and p2.van_in_proof_id = pssn.van_out_proof_id
where
    pssn.store_id = 'MY06010413'
    and date(convert_tz(pssn.shipped_at, '+00:00', '+08:00')) = '2024-02-12'
    and pssn.pno in ('pno','MT10071WWM5Z1Z','MT01091WVMC69Z','M0601XR4YEPE0','MT04041WW2MR4Z','MT03061WUHJX4Z','MT04091WWZUA3Z','MT09041WWQMC4Z','MT08021WWNZ93Z','MT04051WX3369Z','M0601Y4KBWPE0','MT11041WWA8K2Z','MT07061WV26J8Z','MT11041WWEKP2Z','MT01031WWG5H6Z','MT12031WWV557Z','MT10101WVSQT1Z','MT10021WWNBU8Z','MT11031WUX014Z','MT07101WWV8W9Z','MT11041WWZ6N3Z','MT04051WWV3B5Z','MT04021WWNJ11Z','MT09091WWGDA5Z','MT08061WU39R8Z','MT04031WVYMT1Z','MT07051WX0U43Z','MT09061WWVT44Z','MT04081WWV9M7Z','MT04051WV0069Z','MT01011WWDNU9Z','MT04021WVP886Z','M0102Y9BHAEA0','MT01011WWR447Z','MT12041WWJ5D9Z','MT01011WWK056Z','M0601Y4EXTCC','MT04041WVQQ09Z','MT08011WW9B34Z','MT04071WWGEE7Z','MT10071WWUNH5Z','MT09031WVJFT2Z','MT08061WW79Q3Z','MT01031WWEDF4Z','MT10081WUSU08Z','MT01021WWTF02Z','M0102YE8NWDW1','MT06011WWCP16Z','MT09041WWM875Z','MT13011WWWHE3Z','MT04041WWU0G7Z','MT10071WWHDR9Z','M0404YE7XPBP1','MT06011WRGN81Z','MT01011WW1P00Z','MT13011WWYTZ6Z','MT01081WWJQR0Z','MT11051WW5S21Z','MT11061WTR5D0Z','MT09061WWYZT0Z','MT08011WVQPM0Z','MT01031WWQGA7Z','MT09041WWY0E1Z','MT03061WW14M5Z','MT07051WWT3P6Z','MT01101WWF2J2Z','M0404YE9GQBM1','MT11021WW7MW4Z')
;

select
    toi.pno
    ,toi.product_name
from dwm.dwd_my_tiktok_order_item toi
where
    toi.pno in ('MT04091WNG4Z1Z','M0407YDDNRDC','MT06011WKFQ77Z','M1104YAWA1AN2','MT01021WQ5828Z','MT06011WHE5J2Z','M0407YBJX5DC','M0407YBJXNDC','M0407YBJZYDC','M0407YBK4WDC','M0407YBK5NDM','M0407YBKAWDM','M0601YBXHZAU','MT08011WQ84E9Z','MT09081WPA3V5Z','MT10091WR2QA3Z','MT11031WR2PB1Z','MT14011WQZQB4Z','MT06011WMSJ57Z')
；
;

select
    count(distinct plt.pno )
from my_bi.parcel_lose_task plt
where
    plt.state = 6
    and plt.duty_result = 1
    and plt.parcel_created_at > '2024-02-01'

;

select
    month(convert_tz(pi.created_at, '+00:00', '+08:00')) p_month
    ,count(distinct pi.pno )
    ,count(distinct plt.pno )
    ,count(distinct plt.pno )/count(distinct pi.pno )
from my_staging.parcel_info pi
left join my_bi.parcel_lose_task plt on plt.pno = pi.pno and plt.state = 6 and plt.duty_result = 1
where
    pi.returned = 0
    and pi.created_at > '2023-12-31 16:00:00'
    and pi.created_at < '2024-02-29 16:00:00'
group by 1

;

select
    pr.pno
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') routed_at
from my_staging.parcel_route pr
where
    pr.routed_at > '2024-03-27 16:00:00'
    and pr.routed_at < '2024-03-28 16:00:00'
    and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
    and pr.store_id = 'MY06010413'
;

select
    pi.src_name
    ,pi.src_phone
    ,pi.client_id
    ,pi.dst_name
    ,pi.dst_phone
from my_staging.parcel_info pi
where
    pi.pno in ('M0710ZVGHQAE','M0402ZVYY6AA1','M1506ZW0NMAC','FWH000043801','M0702ZVHYNAD','M1301ZW149AE1','M0601ZTTMVHU','M0407ZUNFUDH','M1103ZVBQTAG','M1517ZRH3HAA')

;
select
    case a.duty_result
        when 1 then '丢失'
        when 2 then '破损'
        when 3 then '超时效'
    end 类型
    ,count(distinct a.pno) pno_cnt
    ,round(sum(a.claim_money),1) claimmpney
from
    (
        select
            pct.pno
            ,pct.duty_result
            ,replace(json_extract(pcn.`neg_result`,'$.money'),'\"','') claim_money
            ,row_number() over (partition by pcn.`task_id` order by pcn.`created_at` DESC ) rk
        from my_bi.parcel_claim_task pct
        left join my_bi.parcel_claim_negotiation pcn on pcn.task_id = pct.id
        where
            pct.updated_at > '2024-02-01'
            and pct.updated_at < '2024-03-01'
            and pct.state = 6
    )a
where
    a.rk = 1
group by 1

;

select
    case plt.duty_result
        when 1 then '丢失'
        when 2 then '破损'
        when 3 then '超时效'
    end 类型
    ,count(distinct plt.pno) pno_cnt
from my_bi.parcel_lose_task plt
where
    plt.updated_at > '2024-02-01'
    and plt.updated_at < '2024-03-01'
    and plt.state = 6
group by 1

;

select
    count(distinct fvp.relation_no) total
    ,count(distinct plt.pno) lose
#     fvp.relation_no
#     ,plt.pno
from my_staging.fleet_van_proof_parcel_detail fvp
left join my_bi.parcel_lose_task plt on plt.pno = fvp.relation_no and plt.state = 6 and plt.duty_result = 1
where
    fvp.pack_no = 'P92172718'
    and fvp.relation_category in( 1,3)
    -- and fvp.state < 3

;

