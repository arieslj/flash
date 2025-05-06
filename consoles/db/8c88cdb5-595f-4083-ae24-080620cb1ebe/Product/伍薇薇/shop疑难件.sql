select
    convert_tz(cdt.created_at, '+00:00', '+07:00') 疑难件提交时间
    ,di.pno 运单号
    ,smd.store_id 网点ID
    ,ss.name minics处理网点名称
    ,cdt.client_id 客户ID
    ,ddd.CN_element 疑难件原因
    ,case cdt.negotiation_result_category
        when 1 then '赔偿'
        when 2 then '关闭订单(不赔偿不退货)'
        when 3 then '退货'
        when 4 then '退货并赔偿'
        when 5 then '继续配送'
        when 6 then '继续配送并赔偿'
        when 7 then '正在沟通中'
        when 8 then '丢弃包裹的，换单后寄回BKK'
        when 9 then '货物找回，继续派送'
        when 10 then '改包裹状态'
        when 11 then '需客户修改信息'
        when 12 then '丢弃并赔偿（包裹发到内部拍卖仓）'
        when 13 then 'TT退件新增“holding（15天后丢弃）”协商结果'
        else cdt.negotiation_result_category
    end as 协商结果
from fle_staging.customer_diff_ticket cdt
join fle_staging.shop_maintain_diff_ticket smd on smd.client_id = cdt.client_id and smd.deleted = 0
left join fle_staging.diff_info di on di.id = cdt.diff_info_id
left join fle_staging.sys_store ss on ss.id = smd.store_id
left join dwm.dwd_dim_dict ddd on ddd.element = di.diff_marker_category and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category' and ddd.db = 'fle_staging'
where
    cdt.created_at > '2024-05-31 17:00:00'
    and cdt.created_at < '2024-06-10 17:00:00'
    and cdt.organization_type = 1
    and (cdt.service_type != 3 or cdt.service_type is null)
    and cdt.vip_enable = 0

;


select count(1) from bi_pro.parcel_lose_task plt
;
select
    concat_ws()