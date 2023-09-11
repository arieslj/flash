with t as
(
    select
        plt.id
        ,plt.pno
        ,case
            when bc.`client_id` is not null then bc.client_name
            when kp.id is not null and bc.client_id is null then '普通ka'
            when kp.`id` is null then 'GE'
        end client_type
        ,plt.source
        ,plt.state
        ,plt.updated_at
        ,plt.operator_id
        ,case
            when bc.client_name = 'tiktok' then date_add(date(plt.created_at), interval 3 day)
            when bc.client_name != 'tiktok' and plt.source in (3,12) then date_add(date(plt.created_at), interval 3 day)
            else date_add(date(plt.created_at), interval 4 day)
        end sla_date
    from ph_bi.parcel_lose_task plt
    left join dwm.dwd_dim_bigClient bc on bc.client_id = plt.client_id
    left join ph_staging.ka_profile kp on kp.id = plt.client_id
    where
        plt.created_at >= '${start_date}'
        and plt.created_at < date_add('${end_date}', interval 1 day)
)

select
    total.client_type 客户
    ,total.time_in_auto_count 时效内自动处理_总计
    ,total.time_in_manual_count 时效内人工处理_总计
    ,total.time_out_auto_count 时效外自动处理_总计
    ,total.time_out_manual_count 时效外人工处理_总计
    ,total.no_deal_count 未处理量_总计

    ,cl.time_in_auto_count 时效内自动处理_CL来源
    ,cl.time_in_manual_count 时效内人工处理_CL来源
    ,cl.time_out_auto_count 时效外自动处理_CL来源
    ,cl.time_out_manual_count 时效外人工处理_CL来源
    ,cl.no_deal_count 未处理量_CL来源

    ,other.time_in_auto_count 时效内自动处理_其他来源
    ,other.time_in_manual_count 时效内人工处理_其他来源
    ,other.time_out_auto_count 时效外自动处理_其他来源
    ,other.time_out_manual_count 时效外人工处理_其他来源
    ,other.no_deal_count 未处理量_其他来源
from
    (
        select
            t1.client_type
            ,count(if(t1.state in (5,6) and t1.updated_at <= t1.sla_date and t1.operator_id in (10000,10001), t1.id, null )) time_in_auto_count
            ,count(if(t1.state in (5,6) and t1.updated_at <= t1.sla_date and t1.operator_id not in (10000,10001), t1.id, null )) time_in_manual_count
            ,count(if(t1.state in (5,6) and t1.updated_at > t1.sla_date and t1.operator_id in (10000,10001), t1.id, null )) time_out_auto_count
            ,count(if(t1.state in (5,6) and t1.updated_at > t1.sla_date and t1.operator_id not in (10000,10001), t1.id, null )) time_out_manual_count
            ,count(if(t1.state in (1,2,3,4), t1.id, null)) no_deal_count
        from t t1
        group by 1
    ) total
left join
    (
        select
            t1.client_type
            ,count(if(t1.state in (5,6) and t1.updated_at <= t1.sla_date and t1.operator_id in (10000,10001), t1.id, null )) time_in_auto_count
            ,count(if(t1.state in (5,6) and t1.updated_at <= t1.sla_date and t1.operator_id not in (10000,10001), t1.id, null )) time_in_manual_count
            ,count(if(t1.state in (5,6) and t1.updated_at > t1.sla_date and t1.operator_id in (10000,10001), t1.id, null )) time_out_auto_count
            ,count(if(t1.state in (5,6) and t1.updated_at > t1.sla_date and t1.operator_id not in (10000,10001), t1.id, null )) time_out_manual_count
            ,count(if(t1.state in (1,2,3,4), t1.id, null)) no_deal_count
        from t t1
        where
            t1.source in (3,12)
        group by 1
    ) cl on cl.client_type = total.client_type
left join
    (
        select
            t1.client_type
            ,count(if(t1.state in (5,6) and t1.updated_at <= t1.sla_date and t1.operator_id in (10000,10001), t1.id, null )) time_in_auto_count
            ,count(if(t1.state in (5,6) and t1.updated_at <= t1.sla_date and t1.operator_id not in (10000,10001), t1.id, null )) time_in_manual_count
            ,count(if(t1.state in (5,6) and t1.updated_at > t1.sla_date and t1.operator_id in (10000,10001), t1.id, null )) time_out_auto_count
            ,count(if(t1.state in (5,6) and t1.updated_at > t1.sla_date and t1.operator_id not in (10000,10001), t1.id, null )) time_out_manual_count
            ,count(if(t1.state in (1,2,3,4), t1.id, null)) no_deal_count
        from t t1
        where
            t1.source not in (3,12)
        group by 1
    ) other on other.client_type = total.client_type

;






select
    plt.id 闪速任务ID
    ,plt.pno 单号
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then 'GE'
    end 客户类型
    ,case plt.source
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
    end 问题来源渠道
    ,case plt.state
        when 1 then '丢失件待处理'
        when 2 then '疑似丢失件待处理'
        when 3 then '待工单回复'
        when 4 then '已工单回复'
        when 5 then '包裹未丢失'
        when 6 then '丢失件处理完成'
    end 闪速认定任务状态
    ,plt.updated_at 处理时间
    ,plt.operator_id 操作人
    ,case
        when bc.client_name = 'tiktok' then date_add(date(plt.created_at), interval 3 day)
        when bc.client_name != 'tiktok' and plt.source in (3,12) then date_add(date(plt.created_at), interval 3 day)
        else date_add(date(plt.created_at), interval 4 day)
    end 处理时效
from ph_bi.parcel_lose_task plt
left join dwm.dwd_dim_bigClient bc on bc.client_id = plt.client_id
left join ph_staging.ka_profile kp on kp.id = plt.client_id
where
    plt.created_at >= '${start_date}'
    and plt.created_at < date_add('${end_date}', interval 1 day)