select
    pr.pno
    ,pr.staff_info_id  快递员工号
    ,case pi.returned
        when 0 then '正向'
        when 1 then '退件'
    end 正向_退件
    ,case pi.cod_enabled
        when 0 then '否'
        when 1 then '是'
    end 是否COD
    ,date (convert_tz(pr.routed_at, '+00:00', '+07:00')) 强制拍照日期
    ,bc.client_name 平台_แพลตฟอร์ม
    ,pi.client_id 客户id_idลูกค้า
    ,dt.store_name 网点_สาขา
    ,dt.region_name 大区_area
    ,dt.piece_name 片区_district
    ,concat('https://fle-asset-internal.oss-ap-southeast-1.aliyuncs.com/' ,json_extract(dp.extra_value , '$.deliveryImageAiScore[0].objectKey')) 照片url
    ,if(json_extract(dp.extra_value, '$.deliveryImageAiScore[0].waybillNumberConsistency') = 0 or ( json_extract(dp.extra_value, '$.deliveryImageAiScore[0].noBill') = 0 and json_extract(dp.extra_value, '$.deliveryImageAiScore[0].billAreaRatio') > 0.1 ), 'y', null) 模型是否定义为合格
    ,if(json_extract(dp.extra_value, '$.deliveryImageAiScore[0].noBill') > 0.0 or json_extract(dp.extra_value, '$.deliveryImageAiScore[0].simpleColor') = true or json_extract(dp.extra_value, '$.deliveryImageAiScore[0].lowQuality') > 0.0 or ( json_extract(dp.extra_value, '$.deliveryImageAiScore[0].waybillNumberAvailability') = 0.0 and json_extract(dp.extra_value, '$.deliveryImageAiScore[0].waybillNumberConsistency') = 1.0 ), 'N', null) 模型是否定义为虚假
    ,case
        when json_extract(dp.extra_value, '$.deliveryImageAiScore[0].waybillNumberAvailability') = 1.0 then '否'
        when json_extract(dp.extra_value, '$.deliveryImageAiScore[0].waybillNumberAvailability') = 0.0 then '是'
    end 是否识别到单号
    ,case
        when json_extract(dp.extra_value, '$.deliveryImageAiScore[0].waybillNumberConsistency') = 1.0 then '否'
        when json_extract(dp.extra_value, '$.deliveryImageAiScore[0].waybillNumberConsistency') = 0.0 then '是'
    end 单号是否匹配
    ,case
        when json_extract(dp.extra_value, '$.deliveryImageAiScore[0].noBill') > 0.0 then '否'
        when json_extract(dp.extra_value, '$.deliveryImageAiScore[0].noBill') = 0.0 then '是'
    end 是否识别到面单
    ,concat(json_extract(dp.extra_value, '$.deliveryImageAiScore[0].billAreaRatio') * 100, '%') 识别到的面单面积占比
    ,concat(json_extract(dp.extra_value, '$.deliveryImageAiScore[0].parcelAreaRatio') * 100, '%') 包裹占照片的百分比
    ,case
        when json_extract(dp.extra_value, '$.deliveryImageAiScore[0].simpleColor') = true then '是'
        when json_extract(dp.extra_value, '$.deliveryImageAiScore[0].simpleColor') = false then '否'
    end 是否纯色
    ,case
        when json_extract(dp.extra_value, '$.deliveryImageAiScore[0].lowQuality') > 0.0 then '是'
        when json_extract(dp.extra_value, '$.deliveryImageAiScore[0].lowQuality') = 0.0 then '否'
    end  是否图像整体质量低
    ,case
        when json_extract(dp.extra_value, '$.deliveryImageAiScore[0].lowQualityBackground') > 0.0 then '是'
        when json_extract(dp.extra_value, '$.deliveryImageAiScore[0].lowQualityBackground') = 0.0 then '否'
    end 是否背景质量低
    ,case
        when json_extract(dp.extra_value, '$.deliveryImageAiScore[0].noBackground') > 0.0 then '是'
        when json_extract(dp.extra_value, '$.deliveryImageAiScore[0].noBackground') = 0.0 then '否'
    end 是否识别为无背景
    ,case
        when json_extract(dp.extra_value, '$.deliveryImageAiScore[0].screenShot') > 0.0 then '是'
        when json_extract(dp.extra_value, '$.deliveryImageAiScore[0].screenShot') = 0.0 then '否'
    end 是否识别为截图
from rot_pro.parcel_route pr
left join dwm.drds_parcel_route_extra dp on dp.route_extra_id = json_extract(pr.extra_value, '$.routeExtraId')
left join fle_staging.parcel_info pi on pi.pno = pr.pno
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id
left  join dwm.dim_th_sys_store_rd dt on dt.store_id = pr.store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
where
    pr.route_action = 'TAKE_PHOTO'
    and pr.routed_at > date_sub(curdate(), interval 31 hour)
    and pr.routed_at < date_sub(curdate(), interval 7 hour)
    and json_extract(pr.extra_value, '$.forceTakePhotoCategory') = 3
    and dp.created_at > date_sub(curdate(), interval 60 hour)
    and pi.created_at > date_sub(curdate(), interval 3 month)