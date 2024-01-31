select
    case sfp.force_take_photos_type
        when 1 then '打印面单'
        when 2 then '收件人拒收'
        when 3 then '滞留强制拍照'
    end 拍照类型
    ,if(pi.cod_enabled = 1, 'COD包裹', '普通包裹') 包裹区分
    ,count(distinct if(sfp.parcel_enabled = 0, sfp.pno, null)) 无实体包裹
    ,count(distinct if(sfp.matching_enabled = 0, sfp.pno, null)) 单号不一致
from fle_staging.stranded_force_photo_ai_record sfp
left join fle_staging.parcel_info pi on pi.pno = sfp.pno
where
    sfp.created_at >= '2023-10-17 17:00:00'
group by 1,2