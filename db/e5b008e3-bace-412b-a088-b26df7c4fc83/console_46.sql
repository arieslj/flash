
select
    coalesce(a2.vrv_type, '总计') 回访类型
    ,coalesce(a2.client_name, '总计') 客户
    ,a2.`昨日20-今日20单量`
    ,a2.`昨日20-今日20处理完成单量`
    ,a2.`昨日20-今日20处理及时完成单量`
from
    (
        select
            case a.type
                when 1 then '揽件任务异常取消'
                when 2 then '虚假妥投'
                when 3 then '收件人拒收'
                when 4 then '标记客户改约时间'
                when 5 then 'KA现场不揽收'
                when 6 then '包裹未准备好'
                when 7 then '上报错分未妥投'
                when 8 then '多次尝试派送失败'
            end vrv_type
            ,a.client_name
            ,count(a.id) '昨日20-今日20单量'
            ,count(if(a.visit_state in (3,4,5,6,7), a.id, null)) '昨日20-今日20处理完成单量'
            ,count(if(a.beyond_time = 'y', a.id, null)) '昨日20-今日20处理及时完成单量'
        from
            (
                select
                    vrv.link_id
                    ,bc.client_name
                    ,vrv.id
                    ,vrv.type
                    ,vrv.visit_state
                    ,vrv.created_at
                    ,vrv.updated_at
                    ,vrv.visit_num
                    ,case
                        when vrv.visit_state in (4,6) and vrv.visit_num = 1  and timestampdiff(minute , vrv.created_at, vrv.updated_at) < 120 then 'y'
                        when vrv.visit_state in (4,6) and vrv.visit_num = 1  and timestampdiff(minute , vrv.created_at, vrv.updated_at) >= 120 then 'n'
                        when vrv.visit_state in (4,6) and vrv.visit_num > 1 and timestampdiff(minute , vrv.created_at, vrv.updated_at) < 240 then 'y'
                        when vrv.visit_state in (4,6) and vrv.visit_num > 1 and timestampdiff(minute , vrv.created_at, vrv.updated_at) >= 240 then 'n'

                        when vrv.visit_state in (3,5) and timestampdiff(minute , vrv.created_at, vrv.updated_at) < 240 then 'y'
                        when vrv.visit_state in (3,5) and timestampdiff(minute , vrv.created_at, vrv.updated_at) >= 240 then 'n'
                        when vrv.visit_state in (7) then 'n'
                    end beyond_time
                from nl_production.violation_return_visit vrv
                join dwm.dwd_dim_bigClient bc on vrv.client_id = bc.client_id
                where
                    vrv.created_at >= date_sub('${date1}', interval 4 hour)
                    and vrv.created_at < date_add('${date1}', interval 20 hour)
                    and vrv.type in  (3,8)
            ) a
        group by 1,2
        with rollup
    ) a2
order by case  a2.vrv_type
            when '收件人拒收' then 1
            when '多次尝试派送失败' then 2
            when '总计' then 3
        end desc ,
        case  a2.client_name
            when 'lazada' then 1
            when 'tiktok' then 2
            when 'shopee' then 3
            when '总计' then 4
        end desc