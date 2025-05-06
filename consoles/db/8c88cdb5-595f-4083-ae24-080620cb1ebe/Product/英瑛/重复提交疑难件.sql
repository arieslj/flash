with t as
    (
        select
            di.pno
        from fle_staging.customer_diff_ticket cdt
        left join fle_staging.diff_info di on di.id = cdt.diff_info_id
        where
            cdt.state in (1,2)
            and di.diff_marker_category not in (5,6,7,20,21,22)
            and cdt.created_at > date_sub(curdate(), interval 3 month)
        group by di.pno
    )
select
    a.pno
    ,ddd.CN_element 问题件类型
    ,a.diff_count 提交问题件总次数
    ,case a.negotiation_result_category # 协商结果
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
        else a.negotiation_result_category
    end 协商结果
    ,convert_tz(pi.created_at, '+00:00', '+07:00') 揽收时间
    ,datediff(curdate(), convert_tz(pi.created_at, '+00:00', '+07:00')) 揽收至今天数
from
    (
        select
            di.pno
            ,di.diff_marker_category
            ,count(di.id) over (partition by di.pno) diff_count
            ,cdt2.negotiation_result_category
        from fle_staging.diff_info di
        join t t1 on t1.pno = di.pno
        left join fle_staging.customer_diff_ticket cdt2 on cdt2.diff_info_id = di.id
        where
            di.created_at > date_sub(curdate(), interval 3 month)
            and di.diff_marker_category not in (5,6,7,20,21,22)
    ) a
left join fle_staging.parcel_info pi on pi.pno = a.pno
left join dwm.dwd_dim_dict ddd on ddd.element = a.diff_marker_category and ddd.db = 'fle_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
where
    a.diff_count > 3
