SELECT
    date(convert_tz(cdt.updated_at,'+00:00','+08:00')) 'DATE'
    ,pi.out_trade_no 'ORDER ID'
    ,dps.item_name 'Item Description'
    ,pr.pno 'Tracking number'
    ,pi.client_id 'Seller User ID'
    ,bc.client_name 'Seller username'
    ,case pi.article_category
        when 0 then '文件/document'
        when 1 then '干燥食品/dry food'
        when 2 then '日用品/daily necessities'
        when 3 then '数码产品/digital product'
        when 4 then '衣物/clothes'
        when 5 then '书刊/Books'
        when 6 then '汽车配件/auto parts'
        when 7 then '鞋包/shoe bag'
        when 8 then '体育器材/sports equipment'
        when 9 then '化妆品/cosmetics'
        when 10 then '家居用具/Houseware'
        when 11 then '水果/fruit'
        when 99 then '其它/other'
    end 'Goods name'
    ,cdt.remark 'Reason'
    ,if(cdt.negotiation_result_category=3,'YES','NO') 'PACKAGE STILL RETURNABLE, YES OR NO?'
    ,if(cdt.negotiation_result_category in (12),'Valid','Invalid') 'Valid/Invalid for Claims'
    ,group_concat(concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/',sa.object_key) order by sa.id separator ',') Proof
    ,pr.store_name 'Concerned hub'
    ,null 'PROOF OF DISPOSA'
    ,convert_tz(cdt.updated_at,'+00:00','+08:00') 'DISPOSAL DATE'
    ,di.ct 'times'
    ,cdt.operator_id 'Operation ID'
    ,count(pr.pno)over(partition by date(convert_tz(cdt.updated_at,'+00:00','+08:00'))) 'Processing quantity'
from
    (
        select pr.*
        from
        (
        select
            pr.pno
            ,pr.store_name
            ,json_extract(pr.extra_value,'$.diffInfoId') diffInfoId
            ,json_extract(pr.extra_value,'$.routeExtraId') routeExtraId
            ,row_number()over(partition by pr.pno order by pr.routed_at) rn
        from ph_staging.parcel_route pr
        where pr.route_action ='DIFFICULTY_HANDOVER'
        and pr.marker_category in (20,21)
        and pr.routed_at>=date_sub(curdate(),interval 10 day)

        )pr where pr.rn=1
    )pr
left join ph_staging.parcel_info pi on pi.pno=pr.pno
left join dwm.dwd_dim_bigClient bc on bc.client_id =pi.client_id
left join dwm.drds_ph_shopee_item_info dps on dps.pno = pr.pno
left JOIN
    (
        select
            di.pno
            ,count() ct
        from ph_staging.diff_info di
        where di.created_at>=date_sub(curdate(),interval 10 day)
        group by 1
    )di on pr.pno=di.pno
left join
    (
        select
            pre.pno
            ,pre.route_extra_id
            ,c
        from
        (
            select
                pre.pno
                ,pre.route_extra_id
                ,replace(replace(replace(json_extract(pre.extra_value, '$.images'), '"', ''),'[', ''),']', '') value
            from dwm.drds_ph_parcel_route_extra pre
            where pre.created_at>=date_sub(curdate(),interval 10 day)
        )pre
        lateral view explode(split(pre.value, ',')) id as c
    )pre on pr.routeExtraId=pre.route_extra_id
left join ph_staging.sys_attachment sa on sa.id=pre.c
left join ph_staging.customer_diff_ticket cdt on pr.diffInfoId=cdt.diff_info_id
where
    1=1
    -- pr.pno='PD10011QQYB1AJ'
    and cdt.updated_at>=date_sub(date_sub(curdate(),interval 1 day),interval 8 hour)
    and cdt.updated_at<date_sub(curdate(),interval 8 hour)
    -- and cdt.negotiation_result_category in (3,8,12)
    and cdt.organization_type=2 -- (KAM客服组)
    and cdt.vip_enable=0
    and cdt.service_type = 4
group by 1,2,3,4