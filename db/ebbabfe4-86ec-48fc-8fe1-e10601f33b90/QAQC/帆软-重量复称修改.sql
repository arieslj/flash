  /*=====================================================================+
        表名称：1186d_my_tt_dws_photo
        功能描述：TT妥投包裹重量图片数据
                               
        需求来源：
        编写人员: 于磊
        设计日期：2023/1/06
      	修改日期: 
      	修改人员:    	
      	修改原因: 
      -----------------------------------------------------------------------
      ---存在问题：
      -----------------------------------------------------------------------
      +=====================================================================*/ 
select
    coalesce(ttoi.shop_name,kw.out_client_id) as 'Seller',
    convert_tz(pi.finished_at,'+00:00','+08:00') as 'finish time'
    ,convert_tz(oi.created_at,'+00:00','+08:00') as 'Order Time'
    ,convert_tz(pi.created_at,'+00:00','+08:00') as 'Pickup Time'
    ,pi.client_id as 'KA ID'
    ,kp.name as 'KA Customer Name'
    ,pi.pno as 'Waybill Number'
    ,case pi.`state` 
        when 1 then 'Picked up'
        when 2 then 'In transit'
        when 3 then 'Delivering'
        when 4 then 'Detained'
        when 5 then 'Delivered'
        when 6 then 'Problematic shipment'
        when 7 then 'Returned'
        when 8 then 'Closed exceptionally'
        when 9 then 'Cancelled'
    end as 'Parcel Status'
    ,oi.weight /1000 as 'Weight from Customer(KG)'
    ,oi.length||'*'||oi.`width`||'*'||oi.`height` as 'Dimension from Customer(CM)'
    ,pi.exhibition_weight/1000 as 'Actual Weight(KG)'
    ,pi.exhibition_length||'*'||pi.exhibition_width||'*'||pi.exhibition_height as 'Actual Dimension(CM)'
    ,oi.weight/1000 -pi.store_weight/1000 as 'Differences between Customer given Weight and Chargeable Weight'
    ,pi.store_weight/1000 as 'Chargeable Weight(KG)'
    ,ss.name as 'Pick-up Branch'
    ,pi.ticket_pickup_staff_info_id as 'Pick-up Courier ID'  
    ,dws.url 'pickup photo' 
    ,dws1.url 'UPDATE_WEIGHT_01'
    ,pwr.name 'Last Weight Revise Store'
    ,fvp.pack_no as 'Pack No'
from my_staging.parcel_info pi
left join my_staging.order_info oi on pi.pno =oi.pno and oi.created_at>current_date()-interval 100 day 
left join my_staging.ka_profile kp on kp.id=pi.client_id 
left join my_staging.sys_store ss on ss.id =pi.ticket_pickup_store_id 
left join dwm.drds_tiktok_order_info ttoi on ttoi.pno =oi.pno
left join my_staging.ka_warehouse kw on kw.id =oi.ka_warehouse_id 
left join 
    (
        select
            dws.oss_bucket_key
            ,url
            ,row_number()over(partition by dws.oss_bucket_key order by dws.created_at asc) rk
        from dwm.drds_my_sorting_attachment dws
        where dws.created_at>=CURRENT_DATE()-interval 90 day
            and dws.oss_bucket_key in ('${SUBSTITUTE(SUBSTITUTE(p4,"\n",","),",","','")}')
            and dws.oss_bucket_type='DWS_PARCEL_WEIGHT_INFO'
    )dws on dws.oss_bucket_key=pi.pno and dws.rk = 1
left join 
    (
        select
            dws.oss_bucket_key
            ,url
            ,row_number()over(partition by dws.oss_bucket_key order by dws.created_at desc) rk
        from dwm.drds_my_sorting_attachment dws
        where dws.created_at>=CURRENT_DATE()-interval 90 day
            and dws.oss_bucket_key in ('${SUBSTITUTE(SUBSTITUTE(p4,"\n",","),",","','")}')
            and dws.oss_bucket_type in ('PARCEL_UPDATE_WEIGHT_INFO','SORT_PARCEL_INFO','DWS_PACK_WEIGHT_INFO')
    )dws1 on dws1.oss_bucket_key=pi.pno and dws1.rk=1
left join
    (
        select
            pwr.pno
            ,pwr.store_id
            ,ss.name
            ,row_number() over (partition by pwr.pno order by pwr.created_at desc) rk
        from dwm.drds_parcel_weight_revise_record_d pwr
        left join my_staging.sys_store ss on ss.id = pwr.store_id
        where
            pwr.created_at > date_sub(curdate(), interval 3 month )
            and pwr.pno in ('${SUBSTITUTE(SUBSTITUTE(p4,"\n",","),",","','")}')
    ) pwr on pwr.pno = pi.pno and pwr.rk = 1
left join
    (
        select
            fvp.relation_no
            ,fvp.pack_no
            ,row_number() over (partition by fvp.relation_no order by fvp.created_at) rk
        from my_staging.fleet_van_proof_parcel_detail fvp
        where
            fvp.created_at > date_sub(curdate(), interval 3 month )
            and fvp.relation_category in (1,3)
            and fvp.state < 3
            and fvp.relation_no in ('${SUBSTITUTE(SUBSTITUTE(p4,"\n",","),",","','")}')
    ) fvp on fvp.relation_no = pi.pno and fvp.rk = 1
where
    pi.created_at>=CURRENT_DATE()-interval 90 day
    and pi.pno in ('${SUBSTITUTE(SUBSTITUTE(p4,"\n",","),",","','")}')
