select
    pm.pno
    ,case
        when cdt.organization_type = 1 and (cdt.service_type != 3 or cdt.service_type is null) and cdt.vip_enable = 0 then 'MiniCS'
        when cdt.organization_type = 2 and cdt.vip_enable = 1 then 'KAM'
        when cdt.organization_type = 1 and cdt.vip_enable = 0 and service_type = 3 then 'FH'
        when cdt.organization_type = 2 and cdt.vip_enable = 0 and cdt.service_type != 4 then '总部客服'
        when cdt.organization_type = 2 and cdt.vip_enable = 0 and cdt.service_type = 4 then 'QAQC'
    end 问题件处理类型
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.id is null then '普通ka'
        when kp.`id` is null then '小c'
    end 客户类型
    ,cdt.client_id 客户ID
    ,ddd.cn_element 问题件类型
    ,td.staff_info_id 派件标记快递员
    ,dm.store_name 上报问题件网点
    ,dm.region_name 上报问题件网点大区
    ,case pm.state
        when 1 then '通过'
        when 2 then '虚假'
        when 3 then '不合规'
    end 聊天凭证审核结果
    ,if(pm.state is not null, convert_tz(pm.updated_at, '+00:00', '+08:00'), null) 审核时间
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
from my_staging.customer_diff_ticket cdt
left join my_staging.diff_info di on di.id = cdt.diff_info_id
left join dwm.dim_my_sys_store_rd dm on dm.store_id = di.store_id and dm.stat_date = date_sub(curdate(), 1)
join my_staging.parcel_marker_extend_info pm on pm.diff_info_id = cdt.diff_info_id
left join my_staging.ticket_delivery_marker tdm on tdm.id = pm.mark_info_id
left join my_staging.ticket_delivery td on tdm.delivery_id = td.id
left join my_staging.ka_profile kp on kp.id = cdt.client_id
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = cdt.client_id
left join dwm.dwd_dim_dict ddd on ddd.element = di.diff_marker_category and ddd.db = 'my_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
where
    cdt.updated_at > date_sub(curdate(), interval 32 hour)
    and cdt.updated_at < date_sub(curdate(), interval 8 hour)
  --  and di.created_at < '2024-10-20 16:00:00'
    and pm.extend_category = 1
    and cdt.state = 1