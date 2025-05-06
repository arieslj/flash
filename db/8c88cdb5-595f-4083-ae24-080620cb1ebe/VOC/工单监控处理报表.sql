
with t as
    (
        select
            a.*
        from
            (
                select
                    wo.id
                    ,wo.order_no
                    ,wo.status
                    ,wo.client_id
                    ,wo.created_at
                    ,wor.created_at reply_at
                    ,row_number() over (partition by wo.id order by wor.created_at) rk
                from bi_pro.work_order wo
                left join bi_pro.work_order_reply wor on wor.order_id = wo.id
                join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = wo.client_id
                where
                    wo.store_id = 'vip_ka_handler' -- 受理网点KAM
                    and bc.client_name in ('lazada', 'shopee', 'tiktok')
                    and wo.created_at >= '${sdate}'
                    and wo.created_at < date_add('${edate}', interval 1 day)
            ) a
        where
            a.rk = 1
    )
select
    date (t1.created_at) 日期
     -- lazada
    ,count(distinct if( bc.client_name = 'lazada' and t1.status in (1,2), t1.id, null )) lazada待处理
    ,count(distinct if( bc.client_name = 'lazada' and t1.status in (3,4), t1.id, null )) lazada已处理
    ,count(distinct if( bc.client_name = 'lazada' and t1.status in (3,4) and timestampdiff(minute, t1.created_at, coalesce(t1.reply_at, now()))/60 < 24 , t1.id, null )) lazada及时
    ,count(distinct if( bc.client_name = 'lazada' and t1.status in (3,4) and timestampdiff(minute, t1.created_at, coalesce(t1.reply_at, now()))/60 >= 24 , t1.id, null )) lazada超时
    ,count(distinct if( bc.client_name = 'lazada' and t1.status in (3,4), t1.id, null )) / count(distinct if( bc.client_name = 'lazada', t1.id, null )) 完成率
    ,count(distinct if( bc.client_name = 'lazada' and t1.status in (3,4) and timestampdiff(minute, t1.created_at, coalesce(t1.reply_at, now()))/60 < 24 , t1.id, null )) / count(distinct if( bc.client_name = 'lazada', t1.id, null )) 及时率
    -- shopee
    ,count(distinct if( bc.client_name = 'shopee' and t1.status in (1,2), t1.id, null )) shopee待处理
    ,count(distinct if( bc.client_name = 'shopee' and t1.status in (3,4), t1.id, null )) shopee已处理
    ,count(distinct if( bc.client_name = 'shopee' and t1.status in (3,4) and timestampdiff(minute, t1.created_at, coalesce(t1.reply_at, now()))/60 < 24 , t1.id, null )) shopee及时
    ,count(distinct if( bc.client_name = 'shopee' and t1.status in (3,4) and timestampdiff(minute, t1.created_at, coalesce(t1.reply_at, now()))/60 >= 24 , t1.id, null )) shopee超时
    ,count(distinct if( bc.client_name = 'shopee' and t1.status in (3,4), t1.id, null )) / count(distinct if( bc.client_name = 'shopee', t1.id, null )) shopee完成率
    ,count(distinct if( bc.client_name = 'shopee' and t1.status in (3,4) and timestampdiff(minute, t1.created_at, coalesce(t1.reply_at, now()))/60 < 24 , t1.id, null )) / count(distinct if( bc.client_name = 'shopee', t1.id, null )) shopee及时率
    -- tiktok
    ,count(distinct if( bc.client_name = 'tiktok' and t1.status in (1,2), t1.id, null )) tiktok待处理
    ,count(distinct if( bc.client_name = 'tiktok' and t1.status in (3,4), t1.id, null )) tiktok已处理
    ,count(distinct if( bc.client_name = 'tiktok' and t1.status in (3,4) and timestampdiff(minute, t1.created_at, coalesce(t1.reply_at, now()))/60 < 24 , t1.id, null )) tiktok及时
    ,count(distinct if( bc.client_name = 'tiktok' and t1.status in (3,4) and timestampdiff(minute, t1.created_at, coalesce(t1.reply_at, now()))/60  >= 24, t1.id, null )) tiktok超时
    ,count(distinct if( bc.client_name = 'tiktok' and t1.status in (3,4), t1.id, null )) / count(distinct if( bc.client_name = 'tiktok', t1.id, null )) tiktok完成率
    ,count(distinct if( bc.client_name = 'tiktok' and t1.status in (3,4) and timestampdiff(minute, t1.created_at, coalesce(t1.reply_at, now()))/60 < 24 , t1.id, null ))  / count(distinct if( bc.client_name = 'tiktok', t1.id, null )) tiktok及时率
    -- 整体z
    ,count(distinct t1.id) 整体工单量
    ,count(distinct if(t1.status in (1,2), t1.id, null )) 整体待处理
    ,count(distinct if(t1.status in (3,4), t1.id, null )) 整体已处理
    ,count(distinct if(t1.status in (3,4) and timestampdiff(minute, t1.created_at, coalesce(t1.reply_at, now()))/60 < 24 , t1.id, null )) 整体及时
    ,count(distinct if( t1.status in (3,4) and timestampdiff(minute, t1.created_at, coalesce(t1.reply_at, now()))/60 >= 24, t1.id, null )) 整体超时
    ,count(distinct if(t1.status in (3,4), t1.id, null )) / count(distinct t1.id) 整体完成率
    ,count(distinct if(t1.status in (3,4) and timestampdiff(minute, t1.created_at, coalesce(t1.reply_at, now()))/60 < 24 , t1.id, null )) / count(distinct t1.id) 整体及时率

from t t1
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = t1.client_id
left join
    (
        select
            t1.id
        from t t1
        left join
            (
                select
                    wor.id
                    ,wor.staff_info_id
                    ,row_number() over (partition by wor.id order by wor.created_at desc) rk
                from bi_pro.work_order_reply wor
                join t t1 on t1.id = wor.order_id
                where
                    wor.created_at > '${sdate}'
            ) wor on wor.id = t1.id and wor.rk = 1
        left join tmpale.tmp_th_voc_staff_work t on t.staff_id = wor.staff_info_id and t.work_order = 1
        where
            t1.status = 4
            and ( wor.staff_info_id is null or t.staff_id is null )
    ) t2 on t2.id = t1.id
where
    t2.id is null
    and bc.client_name in ('lazada', 'shopee', 'tiktok')
group by 1
order by 1

;

select working_days
;
/*
case cdt.state
    when 0 then '未处理'
    when 1 then '已处理'
    when 2 then '沟通中'
    when 3 then '支付驳回'
    when 4 then '客户未处理'
    when 5 then '转交闪速系统'
    when 6 then '转交QAQC'
end 处理状态
*/

select
    date (convert_tz(cdt.created_at, '+00:00', '+07:00')) 日期
    -- lazada
    ,count(distinct if( bc.client_name = 'lazada' and cdt.state in (0), cdt.diff_info_id, null )) lazada未处理
    ,count(distinct if( bc.client_name = 'lazada' and cdt.state in (1,2), cdt.diff_info_id, null)) lazada已处理
    ,count(distinct if( bc.client_name = 'lazada', cdt.diff_info_id, null)) lazada工单量

    ,count(distinct if( bc.client_name = 'lazada' and cdt.state in (0,1,2) and timestampdiff(minute, cdt.created_at, coalesce(cdt.first_operated_at, cdt.last_operated_at, dr.created_at))/60 < 24, cdt.diff_info_id, null )) lazada响应及时
    ,count(distinct if( bc.client_name = 'lazada' and cdt.state in (0,1,2) and timestampdiff(minute, cdt.created_at, coalesce(cdt.first_operated_at, cdt.last_operated_at, dr.created_at))/60 >= 24, cdt.diff_info_id, null )) lazada响应超时

    ,count(distinct if( bc.client_name = 'lazada' and cdt.state in (1) and timestampdiff(minute, cdt.created_at, dr.created_at)/60 < 72, cdt.diff_info_id, null )) lazada关闭及时
    ,count(distinct if( bc.client_name = 'lazada' and cdt.state in (1) and timestampdiff(minute, cdt.created_at, dr.created_at)/60 >= 72, cdt.diff_info_id, null )) lazada关闭超时

    ,count(distinct if( bc.client_name = 'lazada' and cdt.state in (1,2), cdt.diff_info_id, null)) / count(distinct if( bc.client_name = 'lazada', cdt.diff_info_id, null)) lazada完成率
    ,count(distinct if( bc.client_name = 'lazada' and cdt.state in (0,1,2) and timestampdiff(minute, cdt.created_at, coalesce(cdt.first_operated_at, cdt.last_operated_at, dr.created_at))/60 < 24, cdt.diff_info_id, null )) / count(distinct if( bc.client_name = 'lazada', cdt.diff_info_id, null)) lazada响应及时率
    ,count(distinct if( bc.client_name = 'lazada' and cdt.state in (1) and timestampdiff(minute, cdt.created_at, dr.created_at)/60 < 72, cdt.diff_info_id, null )) / count(distinct if( bc.client_name = 'lazada', cdt.diff_info_id, null)) lazada关闭及时率

    -- shopee
    ,count(distinct if( bc.client_name = 'shopee'and cdt.state in (0), cdt.diff_info_id, null )) shopee未处理
    ,count(distinct if( bc.client_name = 'shopee'and cdt.state in (1,2), cdt.diff_info_id, null)) shopee已处理
    ,count(distinct if( bc.client_name = 'shopee', cdt.diff_info_id, null)) shopee工单量

    ,count(distinct if( bc.client_name = 'shopee'and cdt.state in (0,1,2) and timestampdiff(minute, cdt.created_at, coalesce(cdt.first_operated_at, cdt.last_operated_at, dr.created_at))/60 < 24, cdt.diff_info_id, null )) shopee响应及时
    ,count(distinct if( bc.client_name = 'shopee'and cdt.state in (0,1,2) and timestampdiff(minute, cdt.created_at, coalesce(cdt.first_operated_at, cdt.last_operated_at, dr.created_at))/60 >= 24, cdt.diff_info_id, null )) shopee响应超时

    ,count(distinct if( bc.client_name = 'shopee'and cdt.state in (1) and timestampdiff(minute, cdt.created_at, dr.created_at)/60 < 72, cdt.diff_info_id, null )) shopee关闭及时
    ,count(distinct if( bc.client_name = 'shopee'and cdt.state in (1) and timestampdiff(minute, cdt.created_at, dr.created_at)/60 >= 72, cdt.diff_info_id, null )) shopee关闭超时

    ,count(distinct if( bc.client_name = 'shopee'and cdt.state in (1,2), cdt.diff_info_id, null)) / count(distinct if( bc.client_name = 'shopee', cdt.diff_info_id, null)) shopee完成率
    ,count(distinct if( bc.client_name = 'shopee'and cdt.state in (0,1,2) and timestampdiff(minute, cdt.created_at, coalesce(cdt.first_operated_at, cdt.last_operated_at, dr.created_at))/60 < 24, cdt.diff_info_id, null )) / count(distinct if(bc.client_name = 'shopee', cdt.diff_info_id, null)) shopee响应及时率
    ,count(distinct if( bc.client_name = 'shopee'and cdt.state in (1) and timestampdiff(minute, cdt.created_at, dr.created_at)/60 < 72, cdt.diff_info_id, null )) / count(distinct if(bc.client_name = 'shopee', cdt.diff_info_id, null)) shopee关闭及时率

    -- tiktok
    ,count(distinct if( bc.client_name = 'tiktok' and cdt.state in (0), cdt.diff_info_id, null )) tt未处理
    ,count(distinct if( bc.client_name = 'tiktok' and cdt.state in (1,2), cdt.diff_info_id, null)) tt已处理
    ,count(distinct if( bc.client_name = 'tiktok', cdt.diff_info_id, null)) tt工单量

    ,count(distinct if( bc.client_name = 'tiktok' and cdt.state in (0,1,2) and timestampdiff(minute, cdt.created_at, coalesce(cdt.first_operated_at, cdt.last_operated_at, dr.created_at))/60 < 24, cdt.diff_info_id, null )) tt响应及时
    ,count(distinct if( bc.client_name = 'tiktok' and cdt.state in (0,1,2) and timestampdiff(minute, cdt.created_at, coalesce(cdt.first_operated_at, cdt.last_operated_at,dr.created_at))/60 >= 24, cdt.diff_info_id, null )) tt响应超时

    ,count(distinct if( bc.client_name = 'tiktok' and cdt.state in (1) and timestampdiff(minute, cdt.created_at, dr.created_at)/60 < 72, cdt.diff_info_id, null )) tt关闭及时
    ,count(distinct if( bc.client_name = 'tiktok' and cdt.state in (1) and timestampdiff(minute, cdt.created_at, dr.created_at)/60 >= 72, cdt.diff_info_id, null )) tt关闭超时

    ,count(distinct if( bc.client_name = 'tiktok' and cdt.state in (1,2), cdt.diff_info_id, null)) / count(distinct if( bc.client_name = 'tiktok', cdt.diff_info_id, null)) tt完成率
    ,count(distinct if( bc.client_name = 'tiktok' and cdt.state in (0,1,2) and timestampdiff(minute, cdt.created_at, coalesce(cdt.first_operated_at, cdt.last_operated_at, dr.created_at))/60 < 24, cdt.diff_info_id, null )) / count(distinct if( bc.client_name = 'tiktok', cdt.diff_info_id, null)) tt响应及时率
    ,count(distinct if( bc.client_name = 'tiktok' and cdt.state in (1) and timestampdiff(minute, cdt.created_at, dr.created_at)/60 < 72, cdt.diff_info_id, null )) / count(distinct if( bc.client_name = 'tiktok', cdt.diff_info_id, null)) tt关闭及时率

    -- 整体
    ,count(distinct if(cdt.state in (0), cdt.diff_info_id, null )) 整体未处理
    ,count(distinct if(cdt.state in (1,2), cdt.diff_info_id, null)) 整体已处理
    ,count(distinct cdt.diff_info_id) 整体工单量

    ,count(distinct if(cdt.state in (0,1,2) and timestampdiff(minute, cdt.created_at, coalesce(cdt.first_operated_at, cdt.last_operated_at, dr.created_at))/60 < 24, cdt.diff_info_id, null )) 整体响应及时
    ,count(distinct if(cdt.state in (0,1,2) and timestampdiff(minute, cdt.created_at, coalesce(cdt.first_operated_at, cdt.last_operated_at, dr.created_at))/60 >= 24, cdt.diff_info_id, null )) 整体响应超时

    ,count(distinct if(cdt.state in (1) and timestampdiff(minute, cdt.created_at, dr.created_at)/60 < 72, cdt.diff_info_id, null )) 整体关闭及时
    ,count(distinct if(cdt.state in (1) and timestampdiff(minute, cdt.created_at, dr.created_at)/60 >= 72, cdt.diff_info_id, null )) 整体关闭超时

    ,count(distinct if(cdt.state in (1,2), cdt.diff_info_id, null)) / count(distinct cdt.diff_info_id) 整体完成率
    ,count(distinct if(cdt.state in (0,1,2) and timestampdiff(minute, cdt.created_at, coalesce(cdt.first_operated_at, cdt.last_operated_at, dr.created_at))/60 < 24, cdt.diff_info_id, null )) / count(distinct cdt.diff_info_id) 整体响应及时率
    ,count(distinct if(cdt.state in (1) and timestampdiff(minute, cdt.created_at, dr.created_at)/60 < 72, cdt.diff_info_id, null )) / count(distinct cdt.diff_info_id) 整体关闭及时率
from fle_staging.customer_diff_ticket cdt
left join fle_staging.diff_info di on di.id = cdt.diff_info_id
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = cdt.client_id
left join dwm.dwd_dim_dict ddd on ddd.element = di.diff_marker_category and ddd.db = 'fle_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
left join fle_staging.diff_route dr on dr.diff_info_id = cdt.diff_info_id and dr.route_action = 'CUSTOMER_NEGOTIATION' and dr.created_at > date_sub('${sdate}', interval 7 hour)
left join tmpale.tmp_th_voc_staff_work tt on tt.staff_id = cdt.operator_id
left join tmpale.tmp_th_voc_staff_work tt2 on tt2.staff_id = cdt.first_operator_id
# left join fle_staging.parcel_reject_report_info prr on prr.diff_info_id = di.id -- 剔除掉拒收复核
left join nl_production.violation_return_visit vrv on json_extract(vrv.extra_value, '$.diff_id') = di.id and vrv.created_at > date_sub('${sdate}', interval 1 day) and vrv.type = 8 -- 剔除多次尝试派送回访
where
    cdt.organization_type = 2
    and cdt.vip_enable = 1
  --  and cdt.show_enabled = 0
    and cdt.created_at >= date_sub('${sdate}', interval 7 hour)
    and cdt.created_at < date_add('${edate}', interval 17 hour)
    and cdt.state not in (5,6)
    and
        (
            di.diff_marker_category in (20,21)
            or ( di.diff_marker_category = 17 and tt.staff_id is not null  )
            or ( di.diff_marker_category = 17 and tt2.staff_id is not null )
        )
    and bc.client_name in ('lazada', 'shopee', 'tiktok')
group by 1
order by 1


;
#
# select
#     cdt.diff_info_id
#     ,di.pno
#     ,cdt.operator_id
#     ,if(cdt.state in (1,2) and timestampdiff(minute, cdt.created_at, cdt.last_operated_at)/60 < 24, '及时', '不及时' )是否及时
#     ,if((cdt.state in (1,2) and timestampdiff(minute, cdt.created_at, cdt.last_operated_at)/60 > 24) or (cdt.state in (0) and timestampdiff(minute, cdt.created_at, now())/60 > 24)  , '超时', '未超时' ) 是否超时
# from fle_staging.customer_diff_ticket cdt
# left join fle_staging.customer_diff_ticket cdt2 on cdt2.id = cdt.id and cdt2.state = 1 and cdt2.created_at > date_sub('${sdate}', interval 7 hour) and cdt2.operator_id not in ('608418','600536','646518','647195','635203','614691','684278','67671','31807','79895','648253','19793','648550','643247','77967')
# left join fle_staging.diff_info di on di.id = cdt.diff_info_id
# where
#     cdt.organization_type = 2
#     and cdt.vip_enable = 1
#     and cdt.created_at >= date_sub('${sdate}', interval 7 hour)
#     and cdt.created_at < date_add('${edate}', interval 17 hour)
#     and cdt2.id is null
#     and cdt.state not in (5,6)
#     and cdt.client_id in ('AA0330','AA0415','AA0428','AA0442','AA0461','AA0477','AA0601','AA0752','AA0792','AA0660','AA0661','AA0703','AA0823','AA0824','AA0386','AA0427','AA0569','AA0574','AA0612','AA0606','AA0657','AA0707','AA0731','AA0794','AA0838')

select
    a.p_date
    ,a.staff
    ,count(if(a.job_type = 'A', a.id, null)) A类
    ,count(if(a.job_type = 'B', a.id, null)) B类
from
    (
        select
            date(convert_tz(dr.created_at, '+00:00', '+07:00')) p_date
            ,dr.operator_id staff
            , 'A' job_type
            ,di.pno id
        from fle_staging.diff_route dr
        left join fle_staging.diff_info di on di.id = dr.diff_info_id
        left join fle_staging.customer_diff_ticket cdt on cdt.diff_info_id = dr.diff_info_id
        join tmpale.tmp_th_voc_staff_work tt on tt.staff_id = dr.operator_id
        # left join fle_staging.parcel_reject_report_info prr on prr.diff_info_id = di.id -- 剔除掉拒收复核
#         left join nl_production.violation_return_visit vrv on json_extract(vrv.extra_value, '$.diff_id') = di.id and vrv.created_at > date_sub('${sdate}', interval 1 day) and vrv.type = 8 -- 剔除多次尝试派送回访
        join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = cdt.client_id
        where
            dr.created_at >= date_sub('${sdate}', interval 7 hour)
            and dr.created_at < date_add('${edate}', interval 17 hour)
            and cdt.organization_type = 2
            and cdt.vip_enable = 1
          --  and cdt.show_enabled = 0
            and cdt.created_at >= date_sub('${sdate}', interval 7 day) -- 拉大时长范围
         --   and cdt.created_at < date_add('${edate}', interval 17 hour)
            and cdt.state not in (5,6)
            and
                (
                    di.diff_marker_category in (20,21,17)
                )
            and bc.client_name in ('lazada', 'shopee', 'tiktok')
        group by 1,2,3,4

        union all

        select
            date(wor.created_at) p_date
            ,wor.staff_info_id
            ,'B' job_type
            ,wor.id
        from bi_pro.work_order wo
        left join bi_pro.work_order_reply wor on wor.order_id = wo.id
        join tmpale.tmp_th_voc_staff_work tt on tt.staff_id = wor.staff_info_id
        join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = wo.client_id
        where
            wo.store_id = 'vip_ka_handler' -- 受理网点KAM
            and wor.created_at >= '${sdate}'
            and wor.created_at < date_add('${edate}', interval 1 day)
            and bc.client_name in ('lazada', 'shopee', 'tiktok')
    ) a
group by 1,2
order by 1,2



;

-- 工单明细

with t as
    (
        select
            a.*
        from
            (
                select
                    wo.id
                    ,wo.order_no
                    ,wo.status
                    ,wo.client_id
                    ,wo.created_at
                    ,wor.created_at reply_at
                    ,wor.staff_info_id
                    ,row_number() over (partition by wo.id order by wor.created_at) rk
                from bi_pro.work_order wo
                left join bi_pro.work_order_reply wor on wor.order_id = wo.id
                where
                    wo.store_id = 'vip_ka_handler' -- 受理网点KAM
                    and wo.client_id in ('AA0330','AA0415','AA0428','AA0442','AA0461','AA0477','AA0601','AA0752','AA0792','AA0660','AA0661','AA0703','AA0823','AA0824','AA0386','AA0427','AA0569','AA0574','AA0612','AA0606','AA0657','AA0707','AA0731','AA0771','AA0794','AA0838')
                    and wo.created_at >= '${sdate}'
                    and wo.created_at < date_add('${edate}', interval 1 day)
            ) a
        where
            a.rk = 1
    )
select
    date (t1.created_at) 日期
    ,case t1.status
        when 1 then '未阅读'
        when 2 then '已经阅读'
        when 3 then '已回复'
        when 4 then '已关闭'
    end 工单状态
    ,t1.created_at 工单创建时间
    ,t1.order_no 工单编号
    ,t1.client_id 客户ID
    ,t1.reply_at  第一次回复时间
    ,t1.staff_info_id 第一次回复人
    ,case
        when  bc.client_name = 'lazada' then 'lazada'
        when  bc.client_name = 'shopee' then 'shopee'
                when  bc.client_name = 'tiktok' then 'tiktok'
    end 客户类型     -- lazada

from t t1
left join
    (
        select
            t1.id
        from t t1
        left join
            (
                select
                    wor.id
                    ,wor.staff_info_id
                    ,row_number() over (partition by wor.id order by wor.created_at desc) rk
                from bi_pro.work_order_reply wor
                join t t1 on t1.id = wor.order_id
                where
                    wor.created_at > '${sdate}'
            ) wor on wor.id = t1.id and wor.rk = 1
        where
            t1.status = 4
            and ( wor.staff_info_id is null or wor.staff_info_id not in ('608418','600536','646518','647195','635203','614691','684278','67671','31807','79895','648253','19793','648550','643247','77967'))
    ) t2 on t2.id = t1.id
where
    t2.id is null

;
#
#
#
# select
#     di.pno
#     ,di.created_at
# from fle_staging.customer_diff_ticket cdt
# left join fle_staging.diff_info di on di.id = cdt.diff_info_id
# left join
#     (
#         select
#             cdt.id
#         from fle_staging.customer_diff_ticket cdt
#         where
#             cdt.organization_type = 2
#             and cdt.vip_enable = 1
#             and cdt.client_id in ('AA0330','AA0415','AA0428','AA0442','AA0461','AA0477','AA0601','AA0752','AA0792','AA0660','AA0661','AA0703','AA0823','AA0824','AA0386','AA0427','AA0569','AA0574','AA0612','AA0606','AA0657','AA0707','AA0731','AA0794','AA0838')
#             and (cdt.operator_id not in ('608418','600536','646518','647195','635203','614691','684278','67671','31807','79895','648253','19793','648550','643247','77967') or cdt.first_operator_id not in ('608418','600536','646518','647195','635203','614691','684278','67671','31807','79895','648253','19793','648550','643247','77967') )
#     ) c2 on c2.id = cdt.id
# where
#     cdt.organization_type = 2
#     and cdt.vip_enable = 1
#     and cdt.created_at >= date_sub('${sdate}', interval 7 hour)
#     and cdt.created_at < date_add('${edate}', interval 17 hour)
#     and cdt.state not in (5,6)
#     and (cdt.state = 0 or (cdt.state > 0 and c2.id is null))
#     and di.diff_marker_category not in (22, 32, 28) -- 货物丢失/禁运品/已妥投未回cod
#     and cdt.client_id in ('AA0386','AA0427','AA0569','AA0574','AA0612','AA0606','AA0657','AA0707','AA0731','AA0771','AA0794','AA0838')
#     and cdt.state in (1)
#     and timestampdiff(minute, cdt.created_at, cdt.last_operated_at)/60 >= 24

# ;
#
# select
#             date(convert_tz(dr.created_at, '+00:00', '+07:00')) p_date
#             ,dr.operator_id staff
#             ,if(di.diff_marker_category in (20, 21), 'A', 'B') job_type
#             ,di.pno id
#         from fle_staging.diff_route dr
#         left join fle_staging.diff_info di on di.id = dr.diff_info_id
#         left join fle_staging.customer_diff_ticket cdt on cdt.diff_info_id = dr.diff_info_id
#         where
#             dr.created_at >= date_sub('${sdate}', interval 7 hour)
#             and dr.created_at < date_add('${edate}', interval 17 hour)
#             and cdt.organization_type = 2
#             and cdt.vip_enable = 1
#             and di.diff_marker_category not in (22, 32, 28, 17, 23, 25, 29, 39, 26) -- 货物丢失/禁运品/已妥投未回cod
#             and dr.operator_id in ('77967')
#             and cdt.client_id in ('AA0330','AA0415','AA0428','AA0442','AA0461','AA0477','AA0601','AA0752','AA0792','AA0660','AA0661','AA0703','AA0823','AA0824','AA0386','AA0427','AA0569','AA0574','AA0612','AA0606','AA0657','AA0707','AA0731','AA0794','AA0838')
#         group by 1,2,3,4
#

;

-- 疑难件子报表
select
    date (convert_tz(cdt.created_at, '+00:00', '+07:00')) 日期
    ,concat(ddd.CN_element, '-', ddd.EN_element) 疑难原因
    ,count(distinct if(cdt.state = 0 and bc.client_name = 'lazada', cdt.id, null)) lazada未处理
    ,count(distinct if(cdt.state = 2 and bc.client_name = 'lazada', cdt.id, null)) lazada沟通中
    ,count(distinct if(cdt.state = 1 and bc.client_name = 'lazada', cdt.id, null)) lazada已处理
    ,count(distinct if(cdt.state = 0 and bc.client_name = 'shopee', cdt.id, null)) shopee未处理
    ,count(distinct if(cdt.state = 2 and bc.client_name = 'shopee', cdt.id, null)) shopee沟通中
    ,count(distinct if(cdt.state = 1 and bc.client_name = 'shopee', cdt.id, null)) shopee已处理
    ,count(distinct if(cdt.state = 0 and bc.client_name = 'tiktok', cdt.id, null)) tiktok未处理
    ,count(distinct if(cdt.state = 2 and bc.client_name = 'tiktok', cdt.id, null)) tiktok沟通中
    ,count(distinct if(cdt.state = 1 and bc.client_name = 'tiktok', cdt.id, null)) tiktok已处理

    ,count(distinct if(cdt.state = 0 , cdt.id, null)) total未处理
    ,count(distinct if(cdt.state = 2 , cdt.id, null)) total沟通中
    ,count(distinct if(cdt.state = 1 , cdt.id, null)) total已处理
from fle_staging.customer_diff_ticket cdt
left join fle_staging.diff_info di on di.id = cdt.diff_info_id
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = cdt.client_id
left join dwm.dwd_dim_dict ddd on ddd.element = di.diff_marker_category and ddd.db = 'fle_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
left join tmpale.tmp_th_voc_staff_work tt on tt.staff_id = cdt.operator_id
left join tmpale.tmp_th_voc_staff_work tt2 on tt2.staff_id = cdt.first_operator_id
# left join fle_staging.parcel_reject_report_info prr on prr.diff_info_id = di.id -- 剔除掉拒收复核
left join nl_production.violation_return_visit vrv on json_extract(vrv.extra_value, '$.diff_id') = di.id and vrv.created_at > date_sub('${sdate}', interval 1 day) and vrv.type = 8 -- 剔除多次尝试派送回访
where
    cdt.organization_type = 2
    and cdt.vip_enable = 1
  --  and cdt.show_enabled = 0
    and cdt.created_at >= date_sub('${sdate}', interval 7 hour)
    and cdt.created_at < date_add('${edate}', interval 17 hour)
    and cdt.state not in (5,6)
    and
        (
            di.diff_marker_category in (20,21)
            or ( di.diff_marker_category = 17 and tt.staff_id is not null  )
            or ( di.diff_marker_category = 17 and tt2.staff_id is not null )
        )
    and bc.client_name in ('lazada', 'shopee', 'tiktok')
group by 1,2
order by 1,2
;

-- 疑难件操作统计

select
    di.p_date
    ,di.operator_id
    ,concat(di.CN_element, '-', di.en_element)  CN_element
    ,count(di.diff_info_id) cnt
from
    (
        select
            date(convert_tz(dr.created_at, '+00:00', '+07:00')) p_date
            ,dr.diff_info_id
            ,dr.operator_id
            ,ddd.CN_element
            ,ddd.EN_element
        from fle_staging.diff_route dr
        left join fle_staging.diff_info di on di.id = dr.diff_info_id
        left join fle_staging.customer_diff_ticket cdt on cdt.diff_info_id = dr.diff_info_id
        join tmpale.tmp_th_voc_staff_work tt on tt.staff_id = dr.operator_id
        join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = cdt.client_id
        left join dwm.dwd_dim_dict ddd on ddd.element = di.diff_marker_category and ddd.db = 'fle_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
        left join nl_production.violation_return_visit vrv on json_extract(vrv.extra_value, '$.diff_id') = di.id and vrv.created_at > date_sub('${sdate}', interval 1 day) and vrv.type = 8 -- 剔除多次尝试派送回访
        where
            dr.created_at >= date_sub('${sdate}', interval 7 hour)
            and dr.created_at < date_add('${edate}', interval 17 hour)
            and cdt.organization_type = 2
            and cdt.vip_enable = 1
            and cdt.show_enabled = 0
            and cdt.state not in (5,6)
            and
                (
                    di.diff_marker_category in (20,21,17)
                 --   or ( di.diff_marker_category = 17 and tt.staff_id is not null  )
                 --   or ( di.diff_marker_category = 17 and tt2.staff_id is not null )
                )
        group by 1,2,3,4
    ) di
group by 1,2,3
order by 1,2,3

;

-- 问题件明细
select
    di.pno
    ,cdt.client_id
    ,bc.client_name
    ,ddd.CN_element
    ,case cdt.state
        when 0 then '未处理'
        when 1 then '已处理'
        when 2 then '沟通中'
        when 3 then '支付驳回'
        when 4 then '客户未处理'
        when 5 then '转交闪速系统'
        when 6 then '转交QAQC'
    end 状态
    ,convert_tz(di.created_at, '+00:00', '+07:00') 工单创建时间
    ,timestampdiff(minute, cdt.created_at, cdt.last_operated_at)/60 关闭时长
    ,cdt.first_operated_at
    ,cdt.last_operated_at
    ,cdt.updated_at
    ,dr.created_at
    ,cdt.operator_id
    ,tt.staff_id
    ,cdt.show_enabled
from fle_staging.customer_diff_ticket cdt
left join fle_staging.diff_info di on di.id = cdt.diff_info_id
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = cdt.client_id
left join dwm.dwd_dim_dict ddd on ddd.element = di.diff_marker_category and ddd.db = 'fle_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
left join fle_staging.diff_route dr on dr.diff_info_id = cdt.diff_info_id and dr.route_action = 'CUSTOMER_NEGOTIATION' and dr.created_at > date_sub('${sdate}', interval 7 hour)
left join tmpale.tmp_th_voc_staff_work tt on tt.staff_id = cdt.operator_id
left join tmpale.tmp_th_voc_staff_work tt2 on tt2.staff_id = cdt.first_operator_id
# left join fle_staging.parcel_reject_report_info prr on prr.diff_info_id = di.id -- 剔除掉拒收复核
left join nl_production.violation_return_visit vrv on json_extract(vrv.extra_value, '$.diff_id') = di.id and vrv.created_at > date_sub('${sdate}', interval 1 day) and vrv.type = 8 -- 剔除多次尝试派送回访
# left join
#     (
#         select
#             cdt.diff_info_id
#         from fle_staging.customer_diff_ticket cdt
#         left join fle_staging.diff_info di on di.id = cdt.diff_info_id
#         join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = cdt.client_id
#         where
#             cdt.organization_type = 2
#             and cdt.vip_enable = 1
#           --  and cdt.show_enabled = 0
#             and cdt.created_at >= date_sub('${sdate}', interval 7 hour)
#             and cdt.created_at < date_add('${edate}', interval 17 hour)
#             and cdt.state not in (5,6)
#             and bc.client_name = 'lazada'
#             and cdt.client_id not in ('AA0461')
#             and di.diff_marker_category in (26,25,29,23)
#     ) cd on cd.diff_info_id = cdt.diff_info_id
where
    cdt.organization_type = 2
    and cdt.vip_enable = 1
  --  and cdt.show_enabled = 0
    and cdt.created_at >= date_sub('${sdate}', interval 7 hour)
    and cdt.created_at < date_add('${edate}', interval 17 hour)
    and cdt.state not in (5,6)
    and
        (
            di.diff_marker_category in (20,21)
            or ( di.diff_marker_category = 17 and tt.staff_id is not null  )
            or ( di.diff_marker_category = 17 and tt2.staff_id is not null )
        )
    and bc.client_name in ('lazada', 'shopee', 'tiktok')
    and di.pno = 'TH240472YYW84D'
#     and cd.diff_info_id is null

# group by 1,2
# order by 1,2

-- 剔除AA0461拒收问题件，破损问题件默认voc处理，剔除拒收复核
