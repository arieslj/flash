select
    di.pno
    ,kdt.ka_id 客户ID
    ,ddd.CN_element 问题件类型
    ,convert_tz(di.created_at, '+00:00', '+08:00')  '问题件生成/转交时间'
    ,convert_tz(di.updated_at, '+00:00', '+08:00')  协商结果处理时间
    ,case kdt.negotiation_result_category # 协商结果
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
        else kdt.negotiation_result_category
    end 协商结果
    ,'' 客户处理状态
    ,'拒收策略-由商户决定' 类型
from ph_staging.ka_diff_ticket kdt
-- left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = kdt.diff_info_id
left join ph_staging.diff_info di on di.id = kdt.diff_info_id
left join dwm.dwd_dim_dict ddd on ddd.element = di.diff_marker_category and ddd.db = 'ph_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
where
    di.created_at > '2024-04-30 18:00:00'
    and di.created_at < '2024-05-31 18:00:00'

union all

select
    di.pno
    ,cdt.client_id 客户ID
    ,ddd.CN_element 问题件类型
    ,convert_tz(cdt.user_operated_start_at, '+00:00', '+08:00')  '问题件生成/转交时间'
    ,convert_tz(cdt.updated_at, '+00:00', '+08:00')  协商结果处理时间
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
    ,case cdt.user_ticket_state # 客户处理状态
        when 0 then '转交还未处理'
        when 1 then '交接超时客户没处理'
        when 2 then '转交客户处理'
    end 客户处理状态
    ,'交给客户处理' 类型
from ph_staging.customer_diff_ticket cdt
left join ph_staging.diff_info di on di.id = cdt.diff_info_id
left join dwm.dwd_dim_dict ddd on ddd.element = di.diff_marker_category and ddd.db = 'ph_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
where
    cdt.created_at > '2024-04-30 18:00:00'
    and cdt.created_at < '2024-05-31 18:00:00'
    and cdt.user_ticket_state in (1,2)

union all

select
    di.pno
    ,cdt.client_id 客户ID
    ,ddd.CN_element 问题件类型
    ,convert_tz(cdt.created_at, '+00:00', '+08:00')  '问题件生成/转交时间'
    ,convert_tz(cdt.updated_at, '+00:00', '+08:00')  协商结果处理时间
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
    ,'' 客户处理状态
    ,'特殊操作人55750' 类型
from ph_staging.customer_diff_ticket cdt
left join ph_staging.diff_info di on di.id = cdt.diff_info_id
left join dwm.dwd_dim_dict ddd on ddd.element = di.diff_marker_category and ddd.db = 'ph_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
where
    cdt.created_at > '2024-04-30 18:00:00'
    and cdt.created_at < '2024-05-31 18:00:00'
    and cdt.operator_id = 55750

