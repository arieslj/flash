with t as
    (
        select
            cdt.diff_info_id
            ,cdt.organization_type
            ,cdt.created_at
            ,cdt.client_id
            ,cdt.organization_id
        from my_staging.customer_diff_ticket cdt
        where
            cdt.state <> 1
            and  (cdt.operator_id <>'10001' or cdt.operator_id is null)
            and cdt.created_at > date_sub('${sdate}', interval 8 hour)
            and cdt.created_at <date_add('${edate}', interval 16 hour)
    )
select
    case when cdt.organization_type = 1  and ss.category=1 then 'miniCS_SP'
          when cdt.organization_type = 1  and lower(ss.name) like '%fh%' then 'miniCS_FH'
          when cdt.organization_type = 1  and lower(ss.name) like '%hub%' then 'miniCS_HUB'
          when cdt.organization_type = 2  and bc.client_name='lazada' then 'PMD_Lazada'
          when cdt.organization_type = 2  and bc.client_name='tiktok' then 'PMD_Tiktok'
          when cdt.organization_type = 2  and bc.client_name is null and kp.department_id='388' then 'PMD_KA'
          when cdt.organization_type = 2  and cs.client_id is not null then '总部CS'
          else null end as 处理部门
    ,date(convert_tz(cdt.created_at, '+00:00', '+08:00')) 疑难件上报日期
    ,count(distinct di.pno) pnt
from t cdt
left join my_staging.diff_info di on di.id = cdt.diff_info_id
left join my_staging.parcel_info pi on pi.pno = di.pno
left join dwm.dwd_dim_dict ddd on ddd.element = di.diff_marker_category and ddd.db = 'my_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
left join my_staging.sys_store ss on ss.id = cdt.organization_id
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = cdt.client_id
left join my_staging.sys_store ss2 on ss2.id = pi.ticket_pickup_store_id
left join my_staging.ka_profile kp on kp.id = cdt.client_id
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
                where
                    cfg_key ='diff.ticket.customer_service.ka_client_ids'
            )pc
        lateral view explode(split(pc.cfg_value, ',')) id as client_id
    )cs on cdt.client_id=cs.client_id
where
    if(bc.client_name is not null,di.diff_marker_category not in (2,17),1)
    and if(cdt.client_id='AA0107',di.diff_marker_category not in (2,17),1)
    and di.diff_marker_category not in (32,69,7,22,28)
    and pi.state < 7
group by 1,2
order by 2,1

;










with t as
    (
        select
            cdt.diff_info_id
            ,cdt.organization_type
            ,cdt.created_at
            ,cdt.client_id
            ,cdt.organization_id
            ,cdt.state
            ,cdt.updated_at
            ,cdt.negotiation_result_category
        from my_staging.customer_diff_ticket cdt
        where
            cdt.state <> 1
            and  (cdt.operator_id <>'10001' or cdt.operator_id is null)
            and cdt.created_at > date_sub('${sdate}', interval 8 hour)
            and cdt.created_at <date_add('${edate}', interval 16 hour)
    )
select
    distinct
    di.pno 运单号
    ,case when cdt.organization_type = 1  and ss.category=1 then 'miniCS_SP'
          when cdt.organization_type = 1  and lower(ss.name) like '%fh%' then 'miniCS_FH'
          when cdt.organization_type = 1  and lower(ss.name) like '%hub%' then 'miniCS_HUB'
          when cdt.organization_type = 2  and bc.client_name='lazada' then 'PMD_Lazada'
          when cdt.organization_type = 2  and bc.client_name='tiktok' then 'PMD_Tiktok'
          when cdt.organization_type = 2  and bc.client_name is null and kp.department_id='388' then 'PMD_KA'
          when cdt.organization_type = 2  and cs.client_id is not null then '总部CS'
          else null end as 处理部门
    ,case when bc.client_name is not null then bc.client_name
           when kp.id is not null then 'KA'
           else '小C' end as  客户类型
    ,cdt.client_id
    ,date(convert_tz(cdt.created_at, '+00:00', '+08:00')) 疑难件上报日期
    ,convert_tz(cdt.created_at, '+00:00', '+08:00') 疑难件上报时间
    ,convert_tz(pi.created_at, '+00:00', '+08:00') 揽收时间
    ,if(cdt.state=2,'沟通中','未处理') 处理状态
    ,convert_tz(cdt.updated_at, '+00:00', '+08:00') 处理时间
    ,ddd.CN_element 疑难件原因
    ,ss.name miniCS处理网点
    ,ss2.name 揽收网点
    ,sy1.name 目的地网点
    ,sr1.name 目的地大区
    ,sp1.name 目的地片区
    ,pr.routed_at 最后有效路由时间
    ,pr.route_action 最后有效路由动作
    ,prd.times 进入问题件次数
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
        end as 包裹状态
    ,case cdt.negotiation_result_category # 协商结果
        when 1 then '赔偿' -- 丢弃并赔偿（关闭订单，网点自行处理包裹）
        when 2 then '关闭订单(不赔偿不退货)' -- 丢弃（关闭订单，网点自行处理包裹）
        when 3 then '退货'
        when 4 then '退货并赔偿'
        when 5 then '继续配送'
        when 6 then '继续配送并赔偿'
        when 7 then '正在沟通中'
        when 8 then '丢弃包裹的，换单后寄回BKK' -- 丢弃（包裹发到内部拍卖仓）
        when 9 then '货物找回，继续派送'
        when 10 then '改包裹状态'
        when 11 then '需客户修改信息'
        when 12 then '丢弃并赔偿（包裹发到内部拍卖仓）'
        when 13 then 'TT退件新增“holding（15天后丢弃）”协商结果'
        end as negotiation_result_category
  ,timestampdiff(hour,convert_tz(cdt.created_at, '+00:00', '+08:00'),CURRENT_TIMESTAMP)/24 diff_day
from t cdt
left join my_staging.diff_info di on di.id = cdt.diff_info_id
join my_staging.parcel_info pi on pi.pno = di.pno
left join dwm.dwd_dim_dict ddd on ddd.element = di.diff_marker_category and ddd.db = 'my_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
left join my_staging.sys_store ss on ss.id = cdt.organization_id
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = cdt.client_id
left join my_staging.sys_store ss2 on ss2.id = pi.ticket_pickup_store_id
left join my_staging.ka_profile kp on kp.id = cdt.client_id
left join my_staging.sys_store sy1 on pi.dst_store_id=sy1.id
left join my_staging.sys_manage_piece sp1 on sp1.id= sy1.manage_piece
left join my_staging.sys_manage_region sr1 on sr1.id = sy1.manage_region
left join
    (
        select
            distinct
            pr.pno
            ,convert_tz(pr.routed_at,'+00:00','+08:00') routed_at
            ,pr.route_action
            ,row_number()over(partition by pr.pno order by pr.routed_at desc) rnk
        from my_staging.parcel_route pr
        join my_staging.diff_info di on pr.pno = di.pno
        join t t1 on di.id = t1.diff_info_id
        where
            pr.route_action in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM'
                                ,'DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT'
                                ,'DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','seal.ARRIVAL_WAREHOUSE_SCAN','INVENTORY','SORTING_SCAN','DELIVERY_PICKUP_STORE_SCAN'
                                ,'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE','REFUND_CONFIRM','ACCEPT_PARCEL')
            and pr.routed_at > date_sub(curdate(), interval 4 month)
    )pr on pi.pno=pr.pno and pr.rnk=1
left join
    (
        select
            pr.pno
            ,count(distinct pr.routed_at) times
        from my_staging.parcel_route pr
        join my_staging.diff_info di on pr.pno=di.pno
        join t t1 on di.id = t1.diff_info_id
        where
            pr.route_action in ('DIFFICULTY_HANDOVER')
            and pr.routed_at > date_sub(curdate(), interval 4 month)
        group by 1
    )prd on pi.pno = prd.pno
left join
    (
        select
            pc.*
             ,client_id
        from
            (
                select * from my_staging.sys_configuration
                where cfg_key ='diff.ticket.customer_service.ka_client_ids'
            )pc
        lateral view explode(split(pc.cfg_value, ',')) id as client_id
    )cs on cdt.client_id=cs.client_id
where
    if(bc.client_name is not null,di.diff_marker_category not in (2,17),1)
    and if(cdt.client_id='AA0107',di.diff_marker_category not in (2,17),1)
    and di.diff_marker_category not in (32,69,7,22,28)
    and pi.state < 7
    and pi.created_at > date_sub(curdate(), interval 4 month)
order by 2,5