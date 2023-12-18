select
    convert_tz(di.created_at, '+00:00', '+07:00') 疑难件提交时间
    ,convert_tz(pi.created_at, '+00:00', '+07:00') 揽收完成时间
    ,if(cdt.first_operated_at is not null, concat(timestampdiff(day ,convert_tz(di.created_at, '+00:00', '+08:00') ,convert_tz(cdt.first_operated_at, '+00:00', '+08:00')), 'd', timestampdiff(hour ,convert_tz(di.created_at, '+00:00', '+08:00') ,convert_tz(cdt.first_operated_at, '+00:00', '+08:00'))%24, 'h',timestampdiff(minute ,convert_tz(di.created_at, '+00:00', '+08:00') ,convert_tz(cdt.first_operated_at, '+00:00', '+08:00'))%60, 'm' ), null ) '从提交到第一次处理时长'
    ,if(cdt.first_operated_at is null, concat(timestampdiff(day ,convert_tz(di.created_at, '+00:00', '+08:00') ,now()), 'd', timestampdiff(hour ,convert_tz(di.created_at, '+00:00', '+08:00') ,now())%24, 'h',timestampdiff(minute ,convert_tz(di.created_at, '+00:00', '+08:00') ,now())%60, 'm' ), null ) 至今未处理时长
    ,concat('(', di.staff_info_id, ')', hsi.name) 提交人
    ,cdt.client_id 客户ID
    ,di.order_info_id  订单号
    ,oi.remark 订单备注
    ,di.pno 运单号
    ,ddd.CN_element 疑难原因
    ,ddd2.CN_element 二级类型
    ,concat('(', ss.id, ')', ss.name) 提交疑难件网点
    ,case pi.insured
        when 1 then '保价'
        when 0 then '不保价'
    end 保价情况
    ,convert_tz(cdt.first_operated_at, '+00:00', '+07:00') 首次处理时间
    ,concat('(', cdt.first_operator_id, ')', hsi2.name) 首次处理人
    ,convert_tz(cdt.first_operated_at, '+00:00', '+07:00') 最后处理时间
    ,concat('(', cdt.operator_id, ')', hsi4.name) 最后处理人
    ,case cdt.state
        when 0 then '未处理'
        when 1 then '已处理'
        when 2 then '沟通中'
        when 3 then '支付驳回'
        when 4 then '客户未处理'
        when 5 then '转交闪速系统'
        when 6 then '转交QAQC'
    end 处理状态
    ,case fdt.state
        when 0 then '未支付'
        when 1 then '已支付'
        when 2 then '驳回'
        when 3 then '取消'
        when 4 then '支付中'
        when 5 then '无需支付'
    end 财务支付状态
    ,cdt.remark 备注
    ,t.ProjectTeam
    ,t.Sub_ProjectTeam
    ,datediff(curdate(), convert_tz(di.created_at, '+00:00', '+07:00')) 处理天数
from fle_staging.customer_diff_ticket cdt
join tmpale.tmp_th_client_id_cn_th t on cdt.client_id = t.client_id
join fle_staging.diff_info di on di.id = cdt.diff_info_id
left join fle_staging.parcel_info pi on pi.pno = di.pno
left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = di.staff_info_id
left join fle_staging.order_info oi on oi.pno = di.pno
left join dwm.dwd_dim_dict ddd on ddd.element = di.diff_marker_category and ddd.db = 'fle_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
left join dwm.dwd_dim_dict ddd2 on ddd2.element = di.rejection_category and ddd.db = 'fle_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'rejection_category'
left join fle_staging.sys_store ss on ss.id = di.store_id
left join bi_pro.hr_staff_info hsi2 on hsi2.staff_info_id = cdt.first_operator_id
left join bi_pro.hr_staff_info hsi4 on hsi4.staff_info_id = cdt.operator_id
left join fle_staging.finance_diff_ticket fdt on fdt.diff_info_id = cdt.diff_info_id
where
    cdt.created_at >= date_sub(date_sub(curdate(), interval 31 day ), interval 8 hour)
    and t.projectteam not in ('LZD', 'SPX', 'TikTok')