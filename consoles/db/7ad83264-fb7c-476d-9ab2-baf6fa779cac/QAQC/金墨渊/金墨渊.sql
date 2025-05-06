select
#     date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
#     ,count(distinct pr.pno) 交接量
#     ,count(distinct if(ppd.pno is null and pi.state not in (5,7,8,9), pr.pno, null)) 未终态交接未留仓量

    pr.pno
from ph_staging.parcel_route pr
left join ph_staging.parcel_info pi on pi.pno = pr.pno
left join ph_staging.parcel_problem_detail ppd on ppd.pno = pr.pno and ppd.created_at > '2024-01-28 16:00:00' and ppd.created_at < '2024-01-29 20:00:00'
where
    pr.routed_at > '2024-01-28 16:00:00'
    and pr.routed_at < '2024-01-29 16:00:00'
    and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    and ppd.pno is null
    and pi.state not in (5,7,8,9)
group by 1

;

with t as
    (
        select
            date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
            ,pr.pno
        from ph_staging.parcel_route pr
        where
            pr.routed_at > date_sub(date_sub(curdate(),interval 31 day), interval 8 hour)
            and pr.routed_at < date_sub(curdate(), interval 8 hour)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        group by 1,2
    )
select
    *
from t t1
left join
    (
        select
            t1.pr_date
            ,pr.pno
        from ph_staging.parcel_route pr
        join t t2 on pr.pno = t2.pno
        where
            pr.route_action = 'DELIVERY_CONFIRM'
            and pr.routed_at > date_sub(date_sub(curdate(),interval 31 day), interval 8 hour)
            and pr.routed_at >= date_sub(t1.pr_date, interval 8 hour)
            and pr.routed_at < date_add(t1.pr_date, interval 16 hour)
        group by 1,2
    ) t2 on t2.pr_date = t1.pr_date and t2.pno = t1.pno

;



with t as
    (
        select
            a.*
        from
            (
                select
                    date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
                    ,pr.store_id
                    ,pr.store_name
                    ,pr.pno
                    ,pr.staff_info_id
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
                from ph_staging.parcel_route pr
                # left join ph_staging.parcel_info pi on pi.pno = pr.pno
                # left join ph_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
                # left join ph_staging.parcel_additional_info pai on pai.pno = pi2.pno
                where
                    pr.routed_at > date_sub(curdate(), interval 32 hour)
                    and pr.routed_at < date_sub(curdate(), interval 8 hour)
                    and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
            ) a
        where
            a.rk = 1
    )
select
    t1.pno 运单号
    ,t1.store_name DC
    ,dp.region_name 大区
    ,dp.piece_name 片区
    ,pi2.cod_amount/100 COD
    ,pai.cogs_amount/100 COGS
    ,pr.CN_element 最后有效路由
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 最后有效路由操作时间
    ,t1.staff_info_id 交接员工
from t t1
join ph_staging.parcel_info pi on pi.pno = t1.pno
left join ph_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
left join ph_staging.parcel_additional_info pai on pai.pno = pi2.pno
left join ph_staging.parcel_problem_detail ppd on ppd.pno = t1.pno and ppd.created_at > date_sub(curdate(), interval 32 hour) and ppd.created_at < date_sub(curdate(), interval 8 hour)
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = t1.store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
left join
    (
        select
            ddd.CN_element
            ,pr.pno
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
        from ph_staging.parcel_route pr
        left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
        where
            pr.routed_at > date_sub(curdate(), interval 32 hour)
            and pr.routed_at < date_sub(curdate(), interval 8 hour)
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
    ) pr on pr.pno = t1.pno and pr.rk = 1
where
    pi.state in (1,2,3,4,6)
    and ppd.pno is null


;


select
    oi.pno
    ,oi.cod_amount/100 cod
    ,ss.name 目的地网点
    ,oi.dst_phone
    ,oi.dst_detail_address
from ph_staging.order_info oi
left join ph_staging.sys_store ss on ss.id = oi.dst_store_id
where
    oi.pno in ('PH246053762018U','PH2441227294354','PH2435351315986','PH244564075044G','PH2420845107068','PH2451556896535','PH241671150388S','PH2468095610569','PH2471335153557','PH2441786589706','PH245827253001W','PH242284981028S','PH2466676741955','PH2499821606108','PH244946366691Y','PH240431476339B','PH242503627909S','PH248855237957N','PH2407984042582','PH246181895522L','PH242018431646Q','PH240818415760I','PH241578629359K','PH249986008870Z','PH242159353412H','PH2437002284488','PH245066495642N','PH2451645006084','PH243181690924N','PH2433862454860','PH2441929059715','PH240325057217L','PH240160681697F','PH249858406924J','PH2467820142631','PH241369643620X','PH248509910865L','PH246443250006R','PH2480011762571','PH242314607177J','PH241248132023O','PH243429794378R','PH244795970341H','PH2433574992192','PH240332419535J','PH246481210010M','PH2485456049044','PH240343132241X','PH2437323228089','PH247989936548Q','PH2413058297508','PH241231174359B','PH248730152249U','PH240954819618F','PH2402791485247','PH2427093988103','PH2433420360492','PH244723344763R','PH2406739935098','PH241187878748X','PH249467250753U','PH244286207074G','PH243752423955J','PH2476820479038','PH2486531187535','PH248521402702G','PH242045317924C','PH247974062956U','PH2411518092966','PH2481260340509','PH2444518158355','PH2425477728722','PH2403148696658','PH247091970110B','PH2415139126965','PH2493665373881','PH246203520751U','PH248554586115Z','PH248134305706R','PH248800371633G','PH2428204733976','PH2465028316150','PH244858495165Y','PH2421123696546','PH2409406908386','PH2489107530311','PH245278605104Y','PH246492067482O','PH2494876724358','PH2408866183550','PH240194827444X','PH2464604810465','PH247924326591D','PH2479616580006','PH2433442503878','PH2469825934579','PH245686200068R','PH241655404991F','PH249593933643G','PH244705540863B','PH243336068785Q','PH2445313539735','PH2481598194554','PH247502058357Z','PH248023912166Z','PH241043105234W','PH240909428817F','PH2401808370305','PH246597238992P','PH240927022931B','PH2432232091683','PH240978963115L','PH249657520794Z','PH243964520910D','PH242337429163B','PH240338302189Z','PH2456092819940','PH245661552758F','PH2479345370076','PH244907520649R','PH244919787357I','PH2433343956698','PH247693296875H','PH246219403733D','PH242678332807X','PH2454441870174','PH245245289410N','PH244196042748Y','PH240910040299X','PH2439116771077','PH247442227885Y','PH2461735843238','PH249018582499C','PH241395312137H','PH245640711423V','PH246638700626U','PH249256245845B','PH246703635346Q','PH245315361809V','PH240751864116J','PH245036768911J','PH2429304741446','PH244166577682P','PH244306113640U','PH2408513199183','PH2429942428481','PH2450841158110','PH240167571435P','PH242704873955Y','PH246837122440E','PH2428911401289','PH243371701061O','PH242207567344J','PH248282906902V','PH246791045790V','PH2487693457858','PH246130523597X','PH243606654711F','PH249672792527A','PH2471599121395','PH2401853727028','PH248597274529O','PH248149734480R','PH248346063381X','PH247734936801I','PH244499640450A','PH242512556674D','PH249433221669Z','PH241013437391R','PH2435988447542','PH249575246599E','PH2472398665622','PH247420289530L','PH2447889151377','PH241011999073W','PH242919471026T','PH241870538471G','PH247352529258Y','PH2439306633241','PH246751255815X','PH242428023546M','PH248090700986Y','PH245599758281Y','PH2429198237585','PH249763424187E','PH2458929714257','PH243029786094P','PH240989055772H','PH242359598608O','PH2430767907637','PH241440881669D','PH2438550690197','PH246417771253Y','PH249053865088I','PH248288330419D','PH247711565989E','PH2463358321881','PH243514980412D','PH248176310631N','PH241722968627P','PH247782591540K','PH247257188896M','PH242298294253V','PH2456390575808','PH2436145176803','PH2405960496626','PH240767504040Y','PH243792832330R','PH240609094138Z','PH245373570828J','PH248018436605O','PH2400940395355','PH245456508800E','PH247716725790X','PH2483989894952','PH247196509086M','PH242959063400X','PH2486283387821','PH240782836169C','PH244692438952N','PH2485749181122','PH243768066675R','PH243489016257H','PH245855036530G','PH247360419999D','PH242505821552J')
