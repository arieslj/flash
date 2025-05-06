select
    distinct
    ss.name 加盟商
    ,ss.id 加盟商ID
    ,am.merge_column
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.id is null then '普通ka'
        when kp.`id` is null then '小c'
    end 客户类型
    ,oi.cod_amount/100 COD金额
    ,oi.cogs_amount/100 cogs
    ,oi.insure_declare_value/100 保价金额
    ,case plt.duty_type
        when 1 then '快递员100%套餐'
        when 2 then '仓9主1套餐(仓管90%主管10%)'
        when 3 then '仓9主1套餐(仓管90%主管10%)'
        when 4 then '双黄套餐(A网点仓管40%主管10%B网点仓管40%主管10%)'
        when 5 then '快递员721套餐(快递员70%仓管20%主管10%)'
        when 6 then '仓管721套餐(仓管70%快递员20%主管10%)'
        when 8 then 'LH全责（LH100%）'
        when 7 then '其他(仅勾选“该运单的责任人需要特殊处理”时才能使用该项)'
        when 9 then '加盟商套餐'
        when 10 then '双黄套餐(计数网点仓管40%计数网点主管10%对接分拨仓管40%对接分拨主管10%)'
        when 19 then '双黄套餐(计数网点仓管40%计数网点主管10%对接分拨仓管40%对接分拨主管10%)'
        when 20 then  '加盟商双黄套餐（加盟商50%网点仓管45%主管5%）'
    end 套餐
    ,am.punish_money 处罚金额
    ,case
        when aq.abnormal_money is not null then aq.abnormal_money                -- 处罚金额这在申诉之后固化
        when am.isdel = 1 then 0.00
        else am.punish_money
    end 实际罚款金额
    ,am.abnormal_time 处罚日期
from bi_pro.abnormal_message am
left join bi_pro.parcel_lose_task plt on json_extract(am.extra_info, '$.losr_task_id') = plt.id
left join bi_pro.parcel_lose_responsible plr on plr.lose_task_id = plt.id
left join fle_staging.sys_store ss on ss.id = plr.store_id
left join fle_staging.order_info oi on oi.pno = am.merge_column
left join fle_staging.ka_profile kp on kp.id = oi.client_id
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = oi.client_id
left join bi_pro.abnormal_qaqc aq on aq.abnormal_message_id = am.id
where
    plt.parcel_created_at >= '2023-09-01'
    and plt.parcel_created_at < '2024-03-01'
    and ss.category = 6
    and am.punish_category = 7
