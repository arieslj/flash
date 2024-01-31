select
    pi.pno
    ,pi.returned_pno 退件单号
    ,pi.client_id 客户id
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.id is null then '普通ka'
        when kp.`id` is null then '小c'
    end 客户类型
    ,pi.src_name 寄件人
    ,pi.src_phone 寄件人电话
    ,pi.dst_name 收件人姓名
    ,pi.dst_detail_address 收件人详细地址
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
    ,pai.amount/100 退件运费险
    ,ss.name 揽件网点
    ,ss2.name 派件网点
    ,ss3.name 包裹当前网点
    ,ss4.name 目的地网点
    ,concat(pi.ticket_pickup_staff_lat, ',',pi.ticket_pickup_staff_lng) 揽收经纬度
    ,concat(json_extract(pr2.extra_value, '$.lat'), ',',  json_extract(pr2.extra_value, '$.lng')) 妥投经纬度
    ,st_distance_sphere(point(pi.ticket_pickup_staff_lng, pi.ticket_pickup_staff_lat), point(json_extract(pr2.extra_value, '$.lng'), json_extract(pr2.extra_value, '$.lat')))/1000 揽派件直线距离km
    ,if(pr.pno is not null , '是', '否')  是否有发件出仓
    ,concat_ws('*', oi.length, oi.width, oi.height) 客户尺寸
    ,if(cpi.pno is not null ,  '是', '否') 是否有修改包裹重量
    ,cpi.operator_id 操作人
    ,concat_ws('*', pi.exhibition_length, pi.exhibition_width, pi.exhibition_height) 揽收修改后尺寸
    ,oi.weight '客户重量/g'
    ,cpi.new_value '修改后重量/g'
    ,pi.exhibition_weight 展示重量
    ,cpi.pict 照片
    ,pai2.amount/100 实收运费
    ,pi.cod_amount/100 cod金额
    ,convert_tz(oi.created_at, '+00:00', '+07:00') 下单时间
    ,convert_tz(pi.created_at, '+00:00', '+07:00') 揽收时间
    ,convert_tz(pi.finished_at, '+00:00', '+07:00') 妥投时间
    ,pi.ticket_pickup_staff_info_id  揽件人
    ,pi.ticket_delivery_staff_info_id 派件人
    ,concat(timestampdiff(hour ,oi.created_at, pi.created_at)%24, 'H', timestampdiff(minute ,oi.created_at, pi.created_at)%60, 'm') 下单到揽件时长
    ,concat(timestampdiff(hour ,pi.created_at, pi.finished_at)%24, 'H', timestampdiff(minute ,pi.created_at, pi.finished_at)%60, 'm') 揽件到妥投时长
    ,case pi.settlement_category
        when 1 then '现结'
        when 2 then '定结'
    end  结算方式
    ,case pi.settlement_type
        when 1 then '寄付'
        when 2 then '到付'
    end 付款方式
from fle_staging.parcel_info pi
left join fle_staging.order_info oi on oi.pno = pi.pno
left join fle_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id
left join rot_pro.parcel_route pr on pr.pno = pi.pno and pr.store_id = pi.ticket_pickup_store_id and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
left join fle_staging.parcel_amount_info pai on pai.pno = pi.pno and pai.item = 'HAPPY_RETURN_AMOUNT'
left join fle_staging.parcel_amount_info pai2 on pai2.pno = pi.pno and pai2.item = 'STORE_PARCEL_AMOUNT'
left join fle_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
left join fle_staging.sys_store ss2 on ss2.id = pi.ticket_delivery_store_id
left join bi_pro.parcel_detail pd on pd.pno = pi.pno
left join fle_staging.sys_store ss3 on ss3.id = pd.last_valid_store_id
left join fle_staging.sys_store ss4 on ss4.id = pi.dst_store_id
left join rot_pro.parcel_route pr2 on pr2.pno = pi.pno and pr2.route_action = 'DELIVERY_CONFIRM'
left join
    (
        select
            pr.pno
            ,pcr.operator_id
            ,pcd.new_value
            ,concat('https://fle-asset-internal.oss-ap-southeast-1.aliyuncs.com//',sa.object_key) pict
        from rot_pro.parcel_route pr
        left join fle_staging.parcel_change_record pcr on pcr.id = json_extract(pr.extra_value, '$.parcelChangeId')
        left join fle_staging.parcel_change_detail pcd on pcd.record_id = pcr.id
        left join dwm.drds_parcel_route_extra dpr on dpr.route_extra_id = json_extract(pr.extra_value, '$.routeExtraId')
        left join fle_staging.sys_attachment sa on sa.id = replace(replace(replace(json_extract(dpr.extra_value, '$.images'), '"', ''),'[', ''),']', '')
        where
            pr.route_action = 'CHANGE_PARCEL_INFO'
            and pr.routed_at > '2023-11-17 17:00:00'
            and pcd.field_name in ('exhibition_weight', 'courier_weight')
        group by 1
    ) cpi on cpi.pno = pi.pno
where
    pi.ticket_delivery_store_id = pi.ticket_pickup_store_id
    and pi.created_at >= date_sub('2023-11-17', interval 7 hour)
    and pi.state = 5
    and pi.finished_at < date_add('2023-11-23', interval 17 hour)

;
