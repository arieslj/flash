-- https://flashexpress.feishu.cn/docx/AS1wdI7DZoBivHxANgJcxVHRnXd


-- 1. 配置前后各部门各问题件类型处理平均时效、中位数时效

select
    case cdt.state
        when 0 then '未处理'
        when 1 then '已处理'
        when 2 then '沟通中'
        when 3 then '支付驳回'
        when 4 then '客户未处理'
        when 5 then '转交闪速系统'
        when 6 then '转交QAQC'
    end 处理状态
    ,case
        when cdt.created_at > '2024-08-04 17:00:00' and cdt.created_at < '2024-09-05 17:00:00' then '0805-0905'
        when cdt.created_at > '2024-09-05 17:00:00' and cdt.created_at < '2024-10-05 17:00:00' then '0905-1005'
    end 时间段
    ,ddd.CN_element 问题件类型
    ,count(1) 任务量
from my_staging.customer_diff_ticket cdt
left join my_staging.diff_info di on di.id = cdt.diff_info_id
left join dwm.dwd_dim_dict ddd on ddd.element = di.diff_marker_category and ddd.db = 'my_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
where
    cdt.created_at > '2024-08-04 17:00:00'
    and cdt.created_at < '2024-10-05 17:00:00'
    and di.diff_marker_category in (17, 39, 23)
group by 1,2,3

;



-- 计算第一次处理时长

with cdt_data as
    (
        select
            cdt.id
            ,cdt.created_at
            ,cdt.client_id
            ,cdt.organization_type
            ,cdt.vip_enable
            ,ddd.CN_element
            ,case
                when cdt.created_at > '2024-08-04 17:00:00' and cdt.created_at < '2024-09-05 17:00:00' then '0805-0905'
                when cdt.created_at > '2024-09-05 17:00:00' and cdt.created_at < '2024-10-05 17:00:00' then '0905-1005'
            end diff_date
            ,case
                when cdt.organization_type = 1 and ( cdt.service_type != 3 or cdt.service_type is null ) and cdt.vip_enable = 0 then 'MiniCS'
                when cdt.organization_type = 2 and cdt.vip_enable = 1 then 'KAM'
                when cdt.organization_type = 2 and cdt.vip_enable = 0 and cdt.service_type != 4 then '总部客服'
                when cdt.organization_type = 2 and cdt.vip_enable = 0 and cdt.service_type = 4 then 'QAQC'
                when cdt.organization_type = 1 and cdt.vip_enable = 0 and cdt.service_type = 3 then 'FH'
            end department
            ,timestampdiff(hour, cdt.created_at, cdt.first_operated_at) as 处理时长
        from my_staging.customer_diff_ticket cdt
        left join my_staging.diff_info di on di.id = cdt.diff_info_id
        left join dwm.dwd_dim_dict ddd on ddd.element = di.diff_marker_category and ddd.db = 'my_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
        where
            cdt.created_at > '2024-08-04 17:00:00'
            and cdt.created_at < '2024-10-05 17:00:00'
            and di.diff_marker_category in (17, 39, 23)
            and cdt.state = 1
),
-- 为处理时长分配行号
rd as
    (
        select
            cd.*
            ,row_number() over (partition by cd.department, cd.CN_element, cd.diff_date order by 处理时长) as rn
            ,count(*) over (partition by cd.department, cd.CN_element, cd.diff_date) as cnt
        from cdt_data cd
    )
select
    a1.CN_element 问题件类型
    ,a1.diff_date 时间段
    ,a1.department 处理部门
    ,a1.平均数
    ,a2.中位数
from
    (
        select
            r1.department
            ,r1.CN_element
            ,r1.diff_date
            ,avg(r1.处理时长) 平均数
        from rd r1
        group by 1,2,3
    ) a1
left join
    (
        select
            r1.department
            ,r1.CN_element
            ,r1.diff_date
            ,avg(r1.处理时长) 中位数
        from rd r1
        where
            r1.rn in (floor((r1.cnt + 1) / 2), floor((r1.cnt + 2) / 2))
        group by 1,2,3
    ) a2 on a1.department = a2.department and a1.CN_element = a2.CN_element and a1.diff_date = a2.diff_date


;



with t as
    (
        select
            cdt.id
            ,cdt.created_at
            ,cdt.client_id
            ,cdt.organization_type
            ,cdt.vip_enable
            ,ddd.CN_element
            ,cdt.state
            ,cdt.negotiation_result_category
            ,case
                when cdt.created_at > '2024-08-04 17:00:00' and cdt.created_at < '2024-09-05 17:00:00' then '0805-0905'
                when cdt.created_at > '2024-09-05 17:00:00' and cdt.created_at < '2024-10-05 17:00:00' then '0905-1005'
            end diff_date
            ,case
                when cdt.organization_type = 1 and ( cdt.service_type != 3 or cdt.service_type is null ) and cdt.vip_enable = 0 then 'MiniCS'
                when cdt.organization_type = 2 and cdt.vip_enable = 1 then 'KAM'
                when cdt.organization_type = 2 and cdt.vip_enable = 0 and cdt.service_type != 4 then '总部客服'
                when cdt.organization_type = 2 and cdt.vip_enable = 0 and cdt.service_type = 4 then 'QAQC'
                when cdt.organization_type = 1 and cdt.vip_enable = 0 and cdt.service_type = 3 then 'FH'
            end department
            ,timestampdiff(hour, cdt.created_at, cdt.updated_at) as 处理时长
        from my_staging.customer_diff_ticket cdt
        left join my_staging.diff_info di on di.id = cdt.diff_info_id
        left join dwm.dwd_dim_dict ddd on ddd.element = di.diff_marker_category and ddd.db = 'my_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
        where
            cdt.created_at > '2024-08-04 17:00:00'
            and cdt.created_at < '2024-10-05 17:00:00'
            and di.diff_marker_category in (17, 39, 23)
          --  and cdt.state = 1
    )
select
    a1.CN_element 问题件类型
    ,a1.diff_date 时间段
    ,a1.department 处理部门
    ,a1.协商结果
    ,a1.cdt_cnt 协商结果的数量
    ,a1.cdt_cnt / a2.cdt_cnt 占比
from
    (
        select
            t1.department
            ,t1.diff_date
            ,t1.CN_element
            ,case t1.negotiation_result_category # 协商结果
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
                else t1.negotiation_result_category
            end 协商结果
            ,count(t1.id) cdt_cnt
        from t t1
        where
            t1.state = 1
        group by 1,2,3,4
    ) a1
left join
    (
        select
            t1.department
            ,t1.diff_date
            ,t1.CN_element
            ,count(t1.id) cdt_cnt
        from t t1
        group by 1,2,3
    ) a2 on a1.department = a2.department and a1.CN_element = a2.CN_element and a1.diff_date = a2.diff_date

;


select
    di.pno
    ,cdt.created_at
from my_staging.customer_diff_ticket cdt
left join my_staging.diff_info di on di.id = cdt.diff_info_id
where
    cdt.state = 1
    and di.diff_marker_category in (17)
    and cdt.negotiation_result_category is null

;


with t as
    (
        select
            cdt.id
            ,cdt.created_at
            ,cdt.client_id
            ,cdt.organization_type
            ,cdt.vip_enable
            ,ddd.CN_element
            ,cdt.state
            ,cdt.negotiation_result_category
            ,case
                when cdt.created_at > '2024-08-04 17:00:00' and cdt.created_at < '2024-09-05 17:00:00' then '0805-0905'
                when cdt.created_at > '2024-09-05 17:00:00' and cdt.created_at < '2024-10-05 17:00:00' then '0905-1005'
            end diff_date
            ,case
                when cdt.organization_type = 1 and ( cdt.service_type != 3 or cdt.service_type is null ) and cdt.vip_enable = 0 then 'MiniCS'
                when cdt.organization_type = 2 and cdt.vip_enable = 1 then 'KAM'
                when cdt.organization_type = 2 and cdt.vip_enable = 0 and cdt.service_type != 4 then '总部客服'
                when cdt.organization_type = 2 and cdt.vip_enable = 0 and cdt.service_type = 4 then 'QAQC'
                when cdt.organization_type = 1 and cdt.vip_enable = 0 and cdt.service_type = 3 then 'FH'
            end department
            ,timestampdiff(hour, cdt.created_at, cdt.updated_at) as 处理时长
        from my_staging.customer_diff_ticket cdt
        left join my_staging.diff_info di on di.id = cdt.diff_info_id
        left join dwm.dwd_dim_dict ddd on ddd.element = di.diff_marker_category and ddd.db = 'my_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
        where
            cdt.created_at > '2024-08-04 17:00:00'
            and cdt.created_at < '2024-10-05 17:00:00'
            and di.diff_marker_category in (17, 39, 23)
          --  and cdt.state = 1
    )
select
    t1.CN_element as 问题件类型
    ,t1.diff_date as 时间段
    ,t1.department as 处理部门
    ,count(distinct t1.id) 上报虚假标记数量
from t t1
join my_staging.diff_ticket_complain_false_info dtc on dtc.customer_diff_id = t1.id
group by 1,2,3
