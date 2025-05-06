
with t as
    (
        select
            a.*
        from
            (
                select
                    pi.pno
                    ,pi.cod_amount
                    ,if(bc.client_name = 'lazada', pi.insure_declare_value, pai.cogs_amount) cogs
                    ,pi.client_id
                    ,bc.client_name
                from my_staging.parcel_info pi
                left join my_staging.parcel_additional_info pai on pai.pno = pi.pno
                left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id
                where
                    pi.state in (1,2,3,4,6)
                    and pi.returned = 0
            ) a
        where
            a.cod_amount > 0
            and a.cod_amount < 3000
    )
select
    a.pno
    ,a.client_type 客户类型
    ,a.client_id 客户ID
    ,a.cogs/100 COGS
    ,a.cod_amount/100 COD
    ,a.cn_element 最后有效路由
    ,a.store_name 最后有效路由网点
    ,case a.store_category
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
    ,a.region_name 大区
    ,diff_hour - 8  最后路由状态停止时长
from
    (
        select
            t1.*
            ,case
                when t1.client_name is not null then t1.client_name
                when t1.client_name is null and kp.id is not null then '普通KA'
                when t1.client_name is null and kp.id is null then '小C'
            end client_type
            ,pr.cn_element
            ,pr.routed_at
            ,pr.store_category
            ,pr.store_name
            ,dm.region_name
            ,timestampdiff(hour, pr.routed_at, now()) diff_hour
        from t t1
        left join
            (
                select
                    pr.pno
                    ,pr.store_name
                    ,pr.store_id
                    ,pr.store_category
                    ,ddd.cn_element
                    ,pr.routed_at
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
                from my_staging.parcel_route pr
                join t t1 on t1.pno = pr.pno
                left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'my_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
                where
                    pr.routed_at > date_sub(curdate(), interval 2 month )
                    and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
            ) pr on pr.pno = t1.pno and pr.rk = 1
        left join my_staging.ka_profile kp on kp.id = t1.client_id
        left join dwm.dim_my_sys_store_rd dm on dm.store_id = pr.store_id and dm.stat_date = date_sub(curdate(), interval 1 day)
    ) a
where
    a.diff_hour >= 32