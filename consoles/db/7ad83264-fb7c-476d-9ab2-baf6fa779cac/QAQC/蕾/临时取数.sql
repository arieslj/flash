select
    pi.pno 单号
    ,'揽' 类型
    ,convert_tz(pi.created_at, '+00:00', '+08:00') 揽派时间
    ,if(bc.client_name = 'lazada', pi2.insure_declare_value/100, pi2.cod_amount/100)  COD金额
from ph_staging.parcel_info pi
left join ph_staging.parcel_info pi2 on if(pi.returned = 1, pi.customary_pno, pi.pno) = pi2.pno
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
where
    pi.ticket_pickup_staff_info_id = '153228'
    and pi.created_at >= '2023-10-31 16:00:00'
    and pi.created_at < '2023-11-30 16:00:00'
    and pi.state = 8

union all

select
    pi.pno 单号
    ,'派' 类型
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 揽派时间
    ,if(bc.client_name = 'lazada', pi2.insure_declare_value/100, pi2.cod_amount/100)  COD金额
from ph_staging.parcel_route pr
left join ph_staging.parcel_info pi on pi.pno = pr.pno
left join ph_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
where
    pr.routed_at >= '2023-10-31 16:00:00'
    and pr.routed_at < '2023-11-30 16:00:00'
    and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    and pr.staff_info_id = '153228'
    and pi.state = 8

;


with t as
    (
        select
            pi.pno
            ,pi.state
            ,ss.name pick_store
            ,ss2.name dst_store
            ,pi.cod_amount
            ,pi.client_id
            ,pi.insure_declare_value
            ,convert_tz(pi.created_at, '+00:00', '+08:00') pick_at
        from ph_staging.parcel_info pi
        left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
        left join ph_staging.sys_store ss2 on ss2.id = pi.dst_store_id
        where
            pi.created_at >= '2023-12-31 16:00:00'
            and pi.src_phone = '09218644470'
            and pi.state < 9
    )
select
    t1.pno
    ,t1.pick_at 揽收时间
    ,t1.pick_store 揽收网点
    ,t1.dst_store 目的地网点
    ,if(bc.client_name = 'lazada', t1.insure_declare_value/100, t1.cod_amount/100) cod
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
    ,if(t2.pno is not null, '是', '否') 是否有通话记录
from t t1
left join
    (
        select
            pr.pno
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at >= '2023-12-31 16:00:00'
            and pr.route_action = 'PHONE'
            and json_extract(pr.extra_value, '$.callDuration') > 0
        group by 1
    ) t2 on t1.pno = t2.pno
left join dwm.dwd_dim_bigClient bc on bc.client_id = t1.client_id

;

select
    pi.pno
    ,pi2.cod_amount/100 cod
    ,pai.cogs_amount/100 cogs
    ,convert_tz(pi.created_at, '+00:00', '+08:00') 揽件时间
    ,pi.src_name 卖家名称
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
from ph_staging.parcel_info pi
left join ph_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
left join ph_staging.parcel_additional_info pai on pai.pno = pi2.pno
where
    pi.state in (7,8)
    and pi.ticket_pickup_staff_info_id = 153228
    and pi.created_at >= '2023-10-31 16:00:00'

;

with t as
    (
        select
            pi.pnoå
            ,pi.cod_amount/100 cod
            ,pi.src_name
            ,convert_tz(pi.created_at, '+00:00', '+08:00') pick_time
            ,pi.dst_store_id
            ,pi.state
            ,pi2.state return_state
            ,pi.returned_pno
        from ph_staging.parcel_info pi
        left join ph_staging.parcel_info pi2 on pi2.pno = pi.returned_pno
        where
            pi.created_at >= '2023-12-31 16:00:00'
            and pi.created_at < '2024-01-31 16:00:00'
            and pi.src_phone in ('09274286755', '09274640291', '09156743971')
            and pi.src_name in ('infinixofficialstore', 'Tecno Mobile Official Store', 'itel Official Store PH')
    )

select
    t1.pno
    ,t1.returned_pno 退件单号
    ,t1.cod
    ,t1.src_name 卖家
    ,t1.pick_time 揽收时间
    ,ss.name 目的地网点
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
    end 正向包裹状态
    ,case t1.return_state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end 退件包裹状态
    ,if(di.returned_pno is not null, '是', '否') 是否提交过疑难件
    ,if(plt.pno is not null, '是', '否') 是否进入过闪速
from t t1
left join ph_staging.sys_store ss on ss.id = t1.dst_store_id
left join
    (
        select
            t1.returned_pno
        from ph_staging.diff_info di
        join t t1 on t1.returned_pno = di.pno
        where
            di.created_at > '2023-12-31 16:00:00'
        group by 1
    ) di on di.returned_pno = t1.returned_pno
left join
    (
        select
            plt.pno
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.returned_pno = plt.pno
        where
            plt.created_at > '2023-12-31 16:00:00'
        group by 1
    ) plt on plt.pno = t1.returned_pno

;

with t as
    (
        select
            t.pno
            ,pi.returned_pno
            ,pi2.state
        from ph_staging.parcel_info pi
        join tmpale.tmp_ph_pno_lj_0206 t on t.pno = pi.pno
        left join ph_staging.parcel_info pi2 on pi2.pno = pi.returned_pno
    )
select
     t1.pno
     ,t1.returned_pno 退件单号
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
    end 退件包裹状态
    ,if(di.returned_pno is not null, '是', '否') 是否提交过疑难件
    ,if(plt.pno is not null, '是', '否') 是否进入过闪速
from t t1
left join
    (
        select
            t1.returned_pno
        from ph_staging.diff_info di
        join t t1 on t1.returned_pno = di.pno
#         where
#             di.created_at > '2023-12-31 16:00:00'
        group by 1
    ) di on di.returned_pno = t1.returned_pno
left join
    (
        select
            plt.pno
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.returned_pno = plt.pno
#         where
#             plt.created_at > '2023-12-31 16:00:00'
        group by 1
    ) plt on plt.pno = t1.returned_pno


;

select
    pi.pno
    ,pi.returned_pno
from ph_staging.parcel_info pi
where
    pi.pno in ('P02073KEXYZAM','P07083JUQY4BT','P61153M0CZ3AI','P63023N6U7ZAJ','P18063MSMMDAH','P35173GABDDBC','P53023FSZFYBP','P53023FP229FF','P45223F920RAC','P73023NBDEMCJ','P35173GKR2PBK','P07343DJZ2FAK','P12213MBHFFAM','P35173GAUGNBK','P45143FAWZQAL','P12213KM09QBQ','P12213MB6FTBQ','P23063J4N7NAH','P12213M3361AB','P12213M46SBBW','P50073FJTDAAO','P61233KN0KPAS','P61203MAJSPAS','P21133HTMRYAE','P07223JJWUSAC','P61103KVXZWAP','P07223FGYWJAD','P07223GQ5KYAG','P07353KA3P2AF','P07353KA3P2AF','P07353KA3P2AF','P07353KA3P2AF','P07263GCB33AI','P07353KA3P2AF','P07263GCB4EAI','P07353KA3P2AF','P61153M0CZ4AI','P07223GUGKYAE','P07343H6JHRAT','P07223GBTSPAH','P27113GZQHUBE','P06143MQ2Y9AQ','P07193HEQCYAE','P61233N3ZBXAJ','P61233N3ZBXAJ','P61183KU8ZSEL','P61183KU8ZSEL','P14093MUWAMAG','P07223GT9WJAG','P07223GT9WJAG','P61153NGHB4AA','P02263H2J5QBC','P02263H2J5QBC','P07223HQ2CAAG','P07223HTNX2AC','P61203PFXJAGL','P61183PR51SBT','P04163PKY2VAE','P60053KX0XJAH','P45143MH1S5CB','P45213KZ8J3AY','P33023K131PAN','P33023K131PAN','P44103HP97EAQ','P45143H4BTPBQ','P12093PJ4AMAX','P45213HKCA9AC','P44023H92Y5AM','P12223PQBAJAR','P06163N6A35AW','P61233PJ24RAY','P61213PUKMJAJ','P18083NQTK1BF','P61193PSF91AD','P18083NQTH0AR','P12063MSP28AD','P17073MUN6VAR','P18083NKQZZAP','P15083MPVSCAL','P18083NKQZZAP','P49073JAUX7AD','P49073JAUX7AD','P26103JDYVNAX','P12063NEZV8AN','P62013MS1C1AL','P61183QKF3ZEL','P14163QECZSAQ','P21023Q700JAD','P61203NX4AKGV','P17283NFDCSAT','P12103QKP87AJ','P01153PNYJCAM','P12213NPM9VAP','P12193NNARYAC','P12103QKP87AJ','P61203QD86AGT','P07223KBZHQAG','P12223QBBVKBA','P51173JU786AN','P19183MVV3WAA','P61183QAURUFI','P14043Q3FEEAB','P61203M6QPRGO','P18063RVKNQBX','P61183RB046EP','P42173KDT1TBA','P78043N9GPQAM','P60053MH67TAO','P59023K7CXSAG','P47053HXYS6AK','P59023K7F0FAG','P81243356BFAF','P12213P5ZA7AP','P12213P0353AL','P24243J4Q46AZ','P12213PEKF0AM','P12213PCSHEBU','P16143NQ04UAO','P12213PDGMXBL','P35103NNX53AL','P53023KN17CBF','P53023KN17CBF','P07333MS8WPAF','P44023JYNKMAK','P44023JYNKMAK','P51053NH52CCH','P51053N6B77BR','P53023MG84ZCG','P45213QJ3BDDI','P11023PQ25EAG','P65033P6GWKAN','P53023MJ2J4AR','P53023MJ2J4AR','P67043N8JB9AE','P22033F2R8FBQ','P53023MRMPMER','P811531FD3BAD','P811531FD3BAD','P811531FD3BAD')


;



select
    t.pno
    ,oi.cod_amount/100 cod
    ,oi.cogs_amount/100 cogs
    ,ss.name 目的地网点
from ph_staging.parcel_info pi
join tmpale.tmp_ph_pno_lj_0710 t on t.pno = pi.pno
left join ph_staging.order_info oi on oi.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
left join ph_staging.sys_store ss on ss.id = pi.dst_store_id


;


select
    pcd.pno
    ,pcd.field_name
    ,pcd.old_value
from ph_staging.parcel_change_detail pcd
join
    (
        select
            pcd.pno
            ,pcd.record_id
        from ph_staging.parcel_change_detail pcd
        where
            pcd.pno in ('P4521598JCWCD','P452158HEP1BO','P45215KZRAFCD','P45215JH6AXCE','P45215KYCXQCR','P45215EW9EHCF')
            and pcd.new_value = 'PH19040F05'
    ) a on a.record_id = pcd.record_id
where
    pcd.field_name in ('dst_name', 'dst_phone', 'dst_detail_address')


;

-- 8月判责丢失后有有效路由


with t as
    (
        select
            distinct
            plt.pno
            ,plt.updated_at
            ,date_sub(plt.updated_at, interval 8 hour) judge_time
            ,plr.store_id
        from ph_bi.parcel_lose_task plt
        left join ph_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
        where
            plt.duty_result = 1
            and plt.state = 6
            and plt.updated_at >= '2024-08-01'
    )
select
    a1.pno
    ,a1.updated_at 判丢失日期
    ,ddd.CN_element 判丢失后的第一个有效路由
    ,a1.store_name 操作网点
    ,convert_tz(a1.routed_at, '+00:00', '+08:00') 操作日期
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
    end as 运单状态
    ,if(pri.pno is not null, '是', '否') 责任网点是否判责后有换单打印_打印面单
from
    (
        select
            a.*
        from
            (
                select
                    t1.*
                    ,pr.route_action
                    ,pr.routed_at
                    ,pr.store_name
                    ,row_number() over (partition by t1.pno order by pr.routed_at) rk
                from ph_staging.parcel_route pr
                join t t1 on t1.pno = pr.pno
                where
                    pr.routed_at > '2024-07-31 16:00:00'
                    and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT', 'DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY', 'REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
                    and pr.routed_at > t1.judge_time
            ) a
        where
            a.rk = 1
    ) a1
left join dwm.dwd_dim_dict ddd on ddd.element = a1.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
left join
    (
        select
            pi.pno
            ,pi.state
        from ph_staging.parcel_info pi
        where
            pi.created_at > date_sub(curdate() , interval 3 month)
    ) pi on pi.pno = a1.pno
left join
    (
        select
            distinct
            pr.pno
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno and pr.store_id = t1.store_id
        where
            pr.route_action in ('REPLACE_PNO', 'PRINTING')
            and pr.routed_at > '2024-07-31 16:00:00'
            and pr.routed_at > t1.judge_time
    ) pri on pri.pno = a1.pno

;

select
    a1.pno
    ,a1.pack_no 集包号
    ,s1.name 集包网点
    ,s2.name 拆包网点
    ,convert_tz(a1.seal_at, '+00:00', '+08:00') 集包时间
    ,a1.proof_id 出车凭证
    ,count(distinct fvp.relation_no) 集包号总包裹数
from
    (
        select
            a1.pno
            ,a1.pack_no
            ,pi.seal_store_id
            ,pi.unseal_store_id
            ,pi.seal_at
            ,a1.proof_id
        from
            (
                select
                    t.pno
                    ,fvp.pack_no
                    ,fvp.proof_id
                from ph_staging.fleet_van_proof_parcel_detail fvp
                join tmpale.tmp_ph_pno_lj_0904 t on t.pno = fvp.relation_no
                where
                    fvp.state < 3
                    and fvp.created_at > '2024-07-01'
                    and ( fvp.store_id = 'PH61270906' or fvp.next_store_id = 'PH61270906' )
            ) a1
        join ph_staging.pack_info pi on pi.pack_no = a1.pack_no
    ) a1
left join ph_staging.sys_store s1 on s1.id = a1.seal_store_id
left join ph_staging.sys_store s2 on s2.id = a1.unseal_store_id
left join ph_staging.fleet_van_proof_parcel_detail fvp on fvp.pack_no = a1.pack_no and fvp.state < 3 and fvp.relation_category in (1,3) and fvp.created_at > '2024-07-01'
group by 1,2,3,4,5,6