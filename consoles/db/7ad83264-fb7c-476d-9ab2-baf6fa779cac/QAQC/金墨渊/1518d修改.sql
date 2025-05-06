   /*
        =====================================================================+
        表名称：1518d_ph_pickup_abnormal_data
        功能描述：菲律宾揽收环节异常数据

        需求来源：
        编写人员: 吕杰
        设计日期：2023-05-30
      	修改日期:
      	修改人员:
      	修改原因:
      -----------------------------------------------------------------------
      ---存在问题：
      -----------------------------------------------------------------------
      +=====================================================================
      */


select
    de.pno 运单号
    ,de.src_store 揽件网点
    ,de.src_piece 片区
    ,de.src_region 大区
    ,de.client_id 客户ID
    ,de.pickup_time 揽件时间
    ,de.dst_store 目的网点
    ,case pi.article_category
        when '0' then '文件'
        when '1' then '干燥食品'
        when '10' then '家居用具'
        when '11' then '水果'
        when '2' then '日用品'
        when '3' then '数码产品'
        when '4' then '衣物'
        when '5' then '书刊'
        when '6' then '汽车配件'
        when '7' then '鞋包'
        when '8' then '体育器材'
        when '9' then '化妆品'
        when '99' then '其它'
    end  as 物品类型
    ,pi.exhibition_weight 物品重量
    ,pi.exhibition_length*pi.exhibition_width*pi.exhibition_height 物品体积
    ,if(de.returned = 0, '正向', '退件') 包裹流向
    ,if(de.returned = 0, pi.cod_amount/100, pi2.cod_amount/100) COD金额
    ,de.last_cn_route_action 最后一步有效路由
    ,de.last_route_time 操作时间
    ,de.last_staff_info_id 操作ID
#     ,'普通' type
from dwm.dwd_ex_ph_parcel_details de
left join ph_staging.parcel_info pi on pi.pno = de.pno
left join ph_staging.parcel_info pi2 on pi2.returned_pno = de.pno
left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.store_id = pi.ticket_pickup_store_id and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
left join ph_staging.sys_store ss on ss.id = de.src_store_id
where
    pr.routed_at is null
    and de.pickup_time < curdate()
    and de.dst_store != de.src_store -- 剔除自揽自派
    and pi.state not in (5,7,8,9)
    and de.client_id != 'AA0038' -- 物料仓
    and ss.category != 6
    and de.last_store_id = de.src_store_id

union
-- 物料仓
select
     de.pno 运单号
    ,de.src_store 揽件网点
    ,de.src_piece 片区
    ,de.src_region 大区
    ,de.client_id 客户ID
    ,de.pickup_time 揽件时间
    ,de.dst_store 目的网点
    ,case pi.article_category
        when '0' then '文件'
        when '1' then '干燥食品'
        when '10' then '家居用具'
        when '11' then '水果'
        when '2' then '日用品'
        when '3' then '数码产品'
        when '4' then '衣物'
        when '5' then '书刊'
        when '6' then '汽车配件'
        when '7' then '鞋包'
        when '8' then '体育器材'
        when '9' then '化妆品'
        when '99' then '其它'
    end  as 物品类型
    ,pi.exhibition_weight 物品重量
    ,pi.exhibition_length*pi.exhibition_width*pi.exhibition_height 物品体积
    ,if(de.returned = 0, '正向', '退件') 包裹流向
    ,if(de.returned = 0, pi.cod_amount/100, pi2.cod_amount/100) COD金额
    ,de.last_cn_route_action 最后一步有效路由
    ,de.last_route_time 操作时间
    ,de.last_staff_info_id 操作ID
#     ,'物料' type
from dwm.dwd_ex_ph_parcel_details de
left join ph_staging.parcel_info pi on pi.pno = de.pno
left join ph_staging.parcel_info pi2 on pi2.returned_pno = de.pno
# left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.store_id = pi.ticket_pickup_store_id and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
left join ph_staging.sys_store ss on ss.id = de.src_store_id
where
    de.src_hub_out_time is null
    and de.pickup_time < curdate()
    and de.dst_store != de.src_store -- 剔除自揽自派
    and pi.state not in (5,7,8,9)
    and de.client_id = 'AA0038' -- 物料仓
    and ss.category != 6 -- 非FH

union all

select
    de.pno 运单号
    ,de.src_store 揽件网点
    ,de.src_piece 片区
    ,de.src_region 大区
    ,de.client_id 客户ID
    ,de.pickup_time 揽件时间
    ,de.dst_store 目的网点
    ,case pi.article_category
        when '0' then '文件'
        when '1' then '干燥食品'
        when '10' then '家居用具'
        when '11' then '水果'
        when '2' then '日用品'
        when '3' then '数码产品'
        when '4' then '衣物'
        when '5' then '书刊'
        when '6' then '汽车配件'
        when '7' then '鞋包'
        when '8' then '体育器材'
        when '9' then '化妆品'
        when '99' then '其它'
    end  as 物品类型
    ,pi.exhibition_weight 物品重量
    ,pi.exhibition_length*pi.exhibition_width*pi.exhibition_height 物品体积
    ,if(de.returned = 0, '正向', '退件') 包裹流向
    ,if(de.returned = 0, pi.cod_amount/100, pi2.cod_amount/100) COD金额
    ,de.last_cn_route_action 最后一步有效路由
    ,de.last_route_time 操作时间
    ,de.last_staff_info_id 操作ID
#     ,'fh' type
from
    (
        select
            pno
            ,last_cn_route_action
            ,last_route_time
            ,last_staff_info_id
            ,src_store
            ,src_piece
            ,src_region
            ,client_id
            ,src_store_id
            ,last_store_id
            ,pickup_time
            ,dst_store
            ,pickup_out_time
            ,de.returned
         from dwm.dwd_ex_ph_parcel_details de
         where
            de.pickup_time < curdate()
            and de.dst_store != de.src_store -- 剔除自揽自派
            and de.client_id != 'AA0038' -- 物料仓
            and parcel_state not in (5,7,8,9)
    ) de
join
    (
        select
            pno
            ,ticket_pickup_store_id
            ,state
            ,article_category,exhibition_weight
            ,exhibition_length,exhibition_width
            ,exhibition_height
            ,cod_amount
        from ph_staging.parcel_info
        where
            state not in (5,7,8,9)
    ) pi on pi.pno = de.pno
left join ph_staging.parcel_info pi2 on pi2.returned_pno = pi.pno
left join
    (
        select
            pno
             ,min(routed_at) routed_at
        from ph_staging.parcel_route
        where
            route_action = 'FLASH_HOME_SCAN'
        group by pno
    ) pr2 on pr2.pno = pi.pno
left join ph_staging.sys_store ss on ss.id = de.src_store_id
where
    coalesce(de.pickup_out_time, pr2.routed_at) is null
    and de.last_store_id = pi.ticket_pickup_store_id
    and ss.category = 6 -- 非FH