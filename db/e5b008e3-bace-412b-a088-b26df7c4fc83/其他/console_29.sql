select
    hsi.staff_info_id
    ,hsi.name 姓名
#     ,case
#         when  hsi.`state`=1 and hsi.`wait_leave_state` =0 then '在职'
#         when  hsi.`state`=1 and hsi.`wait_leave_state` =1 then '待离职'
#         when hsi.`state` =2 then '离职'
#         when hsi.`state` =3 then '停职'
#     end 员工状态
    ,date(hsi.hire_date)  入职时间
    ,hsi.company_name_ef 外协合作商名
    ,dp.store_name 网点
    ,dp.piece_name 片区
    ,dp.region_name 大区
from ph_bi.hr_staff_info hsi
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
where
    hsi.formal = 0
    and hsi.state != 2
    and hsi.hire_date < '2023-07-13'
;


select
    coalesce(a2.client_name, '总计') 客户
    ,'收件人拒收' 疑难件原因
    ,a2.`昨日20-今日20单量`
    ,a2.`昨日20-今日20处理完成单量`
    ,a2.`昨日20-今日20处理及时完成单量`
from
    (
        select
            a.client_name
            ,count(a.id) '昨日20-今日20单量'
            ,count(if(a.visit_state in (3,4), a.id, null)) '昨日20-今日20处理完成单量'
            ,count(if(a.beyond_time = 'y', a.id, null)) '昨日20-今日20处理及时完成单量'
        from
            (
                select
                    vrv.link_id
                    ,bc.client_name
                    ,vrv.id
                    ,vrv.visit_state
                    ,vrv.created_at
                    ,vrv.updated_at
                    ,vrv.visit_num
                    ,case
                        when vrv.visit_state in (4) and vrv.visit_num = 1  and timestampdiff(minute , vrv.created_at, vrv.updated_at) < 120 then 'y'
                        when vrv.visit_state in (4) and vrv.visit_num = 1  and timestampdiff(minute , vrv.created_at, vrv.updated_at) >= 120 then 'n'
                        when vrv.visit_state in (4) and vrv.visit_num > 1 and timestampdiff(minute , vrv.created_at, vrv.updated_at) < 240 then 'y'
                        when vrv.visit_state in (4) and vrv.visit_num > 1 and timestampdiff(minute , vrv.created_at, vrv.updated_at) >= 240 then 'n'

                        when vrv.visit_state in (3) and timestampdiff(minute , vrv.created_at, vrv.updated_at) < 240 then 'y'
                        when vrv.visit_state in (3) and timestampdiff(minute , vrv.created_at, vrv.updated_at) > 240 then 'n'
                    end beyond_time
                from nl_production.violation_return_visit vrv
                join dwm.dwd_dim_bigClient bc on vrv.client_id = bc.client_id
                where
                    vrv.created_at >= date_sub('${date1}', interval 4 hour)
                    and vrv.created_at < date_add('${date1}', interval 20 hour)
                    and vrv.type = 3
            ) a
        group by 1
        with rollup
    ) a2
order by 1

;


select
    vrv.link_id 运单号
    ,bc.client_name 客户明细
    ,case vrv.visit_state
        when 1 then '待回访'
        when 2 then '沟通中'
        when 3 then '多次未联系上客户'
        when 4 then '已回访'
    end 回访状态
    ,vrv.created_at 回访任务创建时间
    ,if(vrv.visit_state in (3,4), vrv.updated_at, null) 结束时间
    ,if(vrv.visit_state in (3,4), timestampdiff(second , vrv.created_at, vrv.updated_at)/3600, null ) '处理时长/小时'
    ,vrv.visit_num 回访次数
    ,case
        when vrv.visit_state in (4) and vrv.visit_num = 1  and timestampdiff(minute , vrv.created_at, vrv.updated_at) < 120 then 'y'
        when vrv.visit_state in (4) and vrv.visit_num = 1  and timestampdiff(minute , vrv.created_at, vrv.updated_at) >= 120 then 'n'
        when vrv.visit_state in (4) and vrv.visit_num > 1 and timestampdiff(minute , vrv.created_at, vrv.updated_at) < 240 then 'y'
        when vrv.visit_state in (4) and vrv.visit_num > 1 and timestampdiff(minute , vrv.created_at, vrv.updated_at) >= 240 then 'n'

        when vrv.visit_state in (3) and timestampdiff(minute , vrv.created_at, vrv.updated_at) < 240 then 'y'
        when vrv.visit_state in (3) and timestampdiff(minute , vrv.created_at, vrv.updated_at) >= 240 then 'n'
    end 是否超时
from nl_production.violation_return_visit vrv
join dwm.dwd_dim_bigClient bc on vrv.client_id = bc.client_id
where
    vrv.created_at >= date_sub('${date1}', interval 4 hour)
    and vrv.created_at < date_add('${date1}', interval 20 hour)
    and vrv.type = 3