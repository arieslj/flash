select
    a.pno
    ,concat(t2.t_value, t3.t_value) 判责原因duty_reasons
    ,a.parcel_created_at 揽收时间receive_time
    ,concat(a.CN_element, a.route_action) 最后有效路由last_effective_route
    ,convert_tz(a.routed_at, '+00:00', '+08:00') 最后有效路由时间last_effective_route_time
    ,ss.name 最后有效路由操作网点operate_network_for_last_effective_route
    ,case a.source
        WHEN 1 THEN 'A-问题件-丢失'
        WHEN 2 THEN 'B-记录本-丢失'
        WHEN 3 THEN 'C-包裹状态未更新'
        WHEN 4 THEN 'D-问题件-破损/短少'
        WHEN 5 THEN 'E-记录本-索赔-丢失'
        WHEN 6 THEN 'F-记录本-索赔-破损/短少'
        WHEN 7 THEN 'G-记录本-索赔-其他'
        WHEN 8 THEN 'H-包裹状态未更新-IPC计数'
        WHEN 9 THEN 'I-问题件-外包装破损险'
        WHEN 10 THEN 'J-问题记录本-外包装破损险'
        when 11 then 'K-超时效包裹'
        when 12 then 'L-高度疑似丢失'
    end 问题来源渠道source_of_problem
    ,concat('(', hsi.staff_info_id, ')', hsi.name) 处理人handler
    ,a.updated_at 处理时间process_time
    ,group_concat(distinct ss2.name) 责任网点duty_branch
from
    (
        select
            plt.pno
            ,plt.id
            ,plt.duty_result
            ,plt.duty_reasons
            ,plt.parcel_created_at
            ,plt.source
            ,plt.operator_id
            ,plt.updated_at
            ,ddd.CN_element
            ,pr.route_action
            ,pr.store_id
            ,pr.routed_at
            ,row_number() over (partition by plt.pno order by pr.routed_at desc ) rk
        from ph_bi.parcel_lose_task plt
        left join `ph_bi`.`translations` t on plt.duty_reasons = t.t_key AND t.`lang` = 'zh-CN'
        left join ph_staging.parcel_route pr on pr.pno = plt.pno and pr.routed_at > date_sub(plt.updated_at, interval 8 hour)
        join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.remark = 'valid'
        where
            plt.state = 6
            and plt.duty_result = 1
            and plt.updated_at >= '2023-07-20'
            and plt.updated_at < '2023-07-30'
    ) a
left join ph_bi.translations t2 on t2.t_key = a.duty_reasons and  t2.lang ='zh-CN'
left join ph_bi.translations t3 on t3.t_key = a.duty_reasons and  t3.lang ='en'
left join ph_staging.sys_store ss on ss.id = a.store_id
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = a.operator_id
left join ph_bi.parcel_lose_responsible plr on plr.lose_task_id = a.id
left join ph_staging.sys_store ss2 on ss2.id = plr.store_id
where
    a.rk = 1
group by 1



;


# select
#     *
# from dwm.dwd_ex_ph_parcel_details de
# where
#     de.src_store regexp 'FH'
#     and de.dst_routed_at is not null
#     and de.pickup_time >= '2023-08-01'