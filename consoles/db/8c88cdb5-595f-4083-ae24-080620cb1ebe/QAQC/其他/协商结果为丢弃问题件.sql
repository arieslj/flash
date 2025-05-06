select
    di.pno
    ,oi.cod_amount/100 COD
    ,s1.name 协商网点
    ,s2.name 目的地网点
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
        else cdt.negotiation_result_category
    end 协商结果
    ,cdt.operator_id 协商操作人工号
    ,convert_tz(cdt.updated_at, '+00:00', '+07:00') 协商时间
    ,cdt.client_id 客户ID
    ,if(cdt.vip_enable = 1, '是', '否') 是否KAM客户
from fle_staging.customer_diff_ticket cdt
join fle_staging.diff_info di on di.id = cdt.diff_info_id
left join fle_staging.parcel_info pi on pi.pno = di.pno
left join fle_staging.order_info oi on oi.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
left join fle_staging.sys_store s1 on s1.id = cdt.organization_id
left join fle_staging.sys_store s2 on s2.id = pi.dst_store_id
where
    cdt.negotiation_result_category in (2,8)
    and cdt.updated_at > date_sub(date_sub(curdate(), interval 7 day), interval 7 hour)