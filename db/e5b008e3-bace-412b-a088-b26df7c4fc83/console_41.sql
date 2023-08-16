select
    a2.pno
    ,case a2.`duty_result`
        when 1 then '丢失'
        when 2 then '破损'
        when 3 then '超时效'
	end as 判责类型
    ,a2.t_value 原因
    ,a2.parcel_created_at 揽件时间
    ,a2.CN_element 最新有效路由
    ,convert_tz(a2.routed_at, '+00:00', '+08:00') 最新有效路由时间
    ,ss2.name 最新有效路由网点
    ,case a2.source
        when 1 then 'A-问题件-丢失'
        when 2 then 'B-记录本-丢失'
        when 3 then 'C-包裹状态未更新'
        when 4 then 'D-问题件-破损/短少'
        when 5 then 'E-记录本-索赔-丢失'
        when 6 then 'F-记录本-索赔-破损/短少'
        when 7 then 'G-记录本-索赔-其他'
        when 8 then 'H-包裹状态未更新-IPC计数'
        when 9 then 'I-问题件-外包装破损险'
        when 10 then 'J-问题记录本-外包装破损险'
        when 11 then 'K-超时效包裹'
        when 12 then 'L-高度疑似丢失'
    end 问题来源渠道
    ,a2.operator_id 处理人工号
    ,a2.duty_dc 责任网点
from
    (
        select
            a1.*
            ,row_number() over (partition by a1.pno order by a1.routed_at desc) rk
        from
            (
                select
                    plt.pno
                    ,plt.duty_result
                    ,t.t_value
                    ,plt.parcel_created_at
                    ,plt.source
                    ,plt.operator_id
                    ,plt.updated_at
                    ,pr.routed_at
                    ,ddd.CN_element
                    ,pr.store_id
                    ,group_concat(distinct ss.name) duty_dc
                from ph_bi.parcel_lose_task plt
                join ph_staging.parcel_route pr on pr.pno = plt.pno and pr.routed_at > date_sub(curdate(), interval 180 day)
                join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.remark = 'valid'
                left join ph_bi.translations t on t.t_key = plt.duty_reasons and t.lang ='zh-CN'
                left join ph_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
                left join ph_staging.sys_store ss on ss.id = plr.store_id
                where
                    plt.state = 6
                    and plt.duty_result = 1
                    and plt.updated_at >= '${start_date}'
                    and plt.updated_at < date_add('${end_date}', interval 1 day)
                    and pr.routed_at > date_sub(plt.updated_at, interval 8 hour)
                group by 1,2,3,4,5,6,7,8,9,10
            ) a1
    ) a2
left join ph_staging.sys_store ss2 on ss2.id = a2.store_id
where
    a2.rk = 1


;

with t as
(
    select
        plt.pno
        ,plt.duty_result
        ,t.t_value
        ,plt.id
        ,plt.parcel_created_at
        ,plt.source
        ,plt.operator_id
        ,plt.updated_at
    from ph_bi.parcel_lose_task plt
    left join ph_bi.translations t on t.t_key = plt.duty_reasons and t.lang ='zh-CN'
    where
        plt.state = 6
        and plt.duty_result = 1
        and plt.updated_at >= '${start_date}'
        and plt.updated_at < date_add('${end_date}', interval 1 day)
        and plt.penalties > 0
)
select
    t1.pno
    ,'丢失' 判责类型
    ,t1.t_value 原因
    ,t1.parcel_created_at 揽收时间
    ,pr.CN_element 最新有效路由
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 最新有效路由时间
    ,pr.store_name 最新有效路由网点
    ,case t1.source
        when 1 then 'A-问题件-丢失'
        when 2 then 'B-记录本-丢失'
        when 3 then 'C-包裹状态未更新'
        when 4 then 'D-问题件-破损/短少'
        when 5 then 'E-记录本-索赔-丢失'
        when 6 then 'F-记录本-索赔-破损/短少'
        when 7 then 'G-记录本-索赔-其他'
        when 8 then 'H-包裹状态未更新-IPC计数'
        when 9 then 'I-问题件-外包装破损险'
        when 10 then 'J-问题记录本-外包装破损险'
        when 11 then 'K-超时效包裹'
        when 12 then 'L-高度疑似丢失'
    end 问题来源渠道
    ,t1.operator_id 处理人工号
    ,plr.duty_dc 责任网点
from t t1
left join
    (
        select
            a.*
        from
            (
                select
                    pr.pno
                    ,pr.store_name
                    ,pr.routed_at
                    ,ddd.CN_element
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
                from ph_staging.parcel_route pr
                join t t1 on t1.pno = pr.pno
                join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.remark = 'valid'
                where
                    pr.routed_at > date_sub('${start_date}', interval 8 hour )
#                     and pr.route_action in ()
            ) a
        where
            a.rk = 1
    ) pr on pr.pno = t1.pno
left join
    (
        select
            t1.id
            ,group_concat(distinct ss.name) duty_dc
        from t t1
        left join ph_bi.parcel_lose_responsible plr on plr.lose_task_id = t1.id
        left join ph_staging.sys_store ss on ss.id = plr.store_id
        group by 1
    ) plr on plr.id = t1.id
where
    pr.routed_at > date_sub(t1.updated_at, interval 8 hour)

