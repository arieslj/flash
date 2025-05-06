-- 客户反馈渠道渠道
select
    case pci.source
        when 1 then '问题记录本'
        when 2 then '疑似违规回访'
        when 3 then 'APP'
        when 4 then '官网'
        when 5 then '短信'
    end 任务渠道
    ,count(pci.id) 整体任务量
    ,count(pci.id)/count(distinct date(pci.created_at)) 整体日均
    ,count(distinct if(pci.client_type in (1,2,3,4), pci.id, null)) 平台
    ,count(distinct if(pci.client_type in (1,2,3,4), pci.id, null)) / count(distinct date(pci.created_at)) 平台日均
    ,count(distinct if(pci.client_type in (5,6,7), pci.id, null))  非平台
    ,count(distinct if(pci.client_type in (5,6,7), pci.id, null)) / count(distinct date(pci.created_at))  非平台日均
from bi_center.parcel_complaint_inquiry pci
where
    pci.created_at >= '${start_date}'
    and pci.created_at < date_add('${end_date}', interval 1 day)
    ${if(len(client)=0,"","and pci.client_type in ('"+SUBSTITUTE(client,",","','")+"')")}
group by 1

;


-- 快递员处理情况
select
    case
        when a.apology_type = 2 and a.apology_at <= a.short_sla then '短时效'
        when a.apology_type = 2 and a.apology_at > a.short_sla and a.apology_at < a.long_sla then '长时效'
        when a.apology_type = 1 then '超时效未处理'
        when a.apology_type = 0 then '处理中'
    end 处理情况
    ,count(a.id) 整体任务量
from
    (
        select
            pci.id
            ,pci.created_at
            ,pci.client_type
            ,pci.apology_type
            ,pci.apology_at
            ,if(pci.created_at < date_add(date(pci.created_at), interval 16 hour), date_add(date(pci.created_at), interval 24 hour), date_add(date(pci.created_at), interval 36 hour))
            ,case
                when pci.client_type = 1 and pci.created_at <= date_add(date(pci.created_at), interval 16 hour) then date_add(date(pci.created_at), interval 24 hour)
                when pci.client_type = 1 and pci.created_at > date_add(date(pci.created_at), interval 16 hour) then date_add(date(pci.created_at), interval 36 hour)
                when pci.client_type in (2,3,4) then date_add(pci.created_at, interval 48 hour)
                else date_add(pci.created_at, interval 72 hour)
            end short_sla
            ,case
                when pci.client_type = 1 then date_add(pci.created_at, interval 48 hour)
                else date_add(pci.created_at, interval 72 hour)
            end long_sla
        from bi_center.parcel_complaint_inquiry pci
        where
            pci.created_at >= '${start_date}'
            and pci.created_at < date_add('${end_date}', interval 1 day)
            ${if(len(client)=0,"","and pci.client_type in ('"+SUBSTITUTE(client,",","','")+"')")}
    ) a
group by 1

;

-- 回访结果分布

select
    '全部回访任务量' 结果分布
    ,count(pci.id) 整体任务量
from bi_center.parcel_complaint_inquiry pci
where
    pci.created_at >= '${start_date}'
    and pci.created_at < date_add('${end_date}', interval 1 day)
    and pci.callback_state > 0-- 有回访任务
    ${if(len(client)=0,"","and pci.client_type in ('"+SUBSTITUTE(client,",","','")+"')")}

union all

select
    '回访结果-已收到包裹' 结果分布
    ,count(pci.id) 整体任务量
from bi_center.parcel_complaint_inquiry pci
where
    pci.created_at >= '${start_date}'
    and pci.created_at < date_add('${end_date}', interval 1 day)
    and pci.callback_state > 0-- 有回访任务
    and pci.qaqc_is_receive_parcel = 2
    ${if(len(client)=0,"","and pci.client_type in ('"+SUBSTITUTE(client,",","','")+"')")}

union all

select
    '回访结果-未收到包裹，已有约定派送时间' 结果分布
    ,count(pci.id) 整体任务量
from bi_center.parcel_complaint_inquiry pci
where
    pci.created_at >= '${start_date}'
    and pci.created_at < date_add('${end_date}', interval 1 day)
    and pci.callback_state > 0-- 有回访任务
    and pci.qaqc_is_receive_parcel = 4
    ${if(len(client)=0,"","and pci.client_type in ('"+SUBSTITUTE(client,",","','")+"')")}

union all

select
    '回访结果-未收到包裹' 结果分布
    ,count(pci.id) 整体任务量
from bi_center.parcel_complaint_inquiry pci
where
    pci.created_at >= '${start_date}'
    and pci.created_at < date_add('${end_date}', interval 1 day)
    and pci.callback_state > 0-- 有回访任务
    and pci.qaqc_is_receive_parcel = 3
    ${if(len(client)=0,"","and pci.client_type in ('"+SUBSTITUTE(client,",","','")+"')")}

union all

select
    '回访结果-未收到包裹' 结果分布
    ,count(pci.id) 整体任务量
from bi_center.parcel_complaint_inquiry pci
where
    pci.created_at >= '${start_date}'
    and pci.created_at < date_add('${end_date}', interval 1 day)
    and pci.callback_state > 0-- 有回访任务
    and pci.qaqc_is_receive_parcel = 1
    ${if(len(client)=0,"","and pci.client_type in ('"+SUBSTITUTE(client,",","','")+"')")}

union all

select
    '进入回访后-快递员上传证据' 结果分布
    ,count(pci.id) 整体任务量
from bi_center.parcel_complaint_inquiry pci
where
    pci.created_at >= '${start_date}'
    and pci.created_at < date_add('${end_date}', interval 1 day)
    and pci.callback_state > 0-- 有回访任务
    and pci.apology_at > pci.qaqc_created_at
    ${if(len(client)=0,"","and pci.client_type in ('"+SUBSTITUTE(client,",","','")+"')")}

;

-- 第二次反馈任务-客诉-虚假妥投
select
    '第二次反馈任务总量' 结果分布
    ,count(acc.id) 整体
from bi_pro.abnormal_customer_complaint acc
left join tmpale.tmp_th_client_type_lj t on t.client_id = acc.client_id
where
    acc.channel_type = 16 -- 询问任务
    and acc.created_at >= '${start_date}'
    and acc.created_at < date_add('${end_date}', interval 1 day)
    ${if(len(client)=0,"","and t.client_type in ('"+SUBSTITUTE(client,",","','")+"')")}

union all

select
    '第二次反馈结果未收到包裹' 结果分布
    ,count(acc.id) 整体
from bi_pro.abnormal_customer_complaint acc
left join tmpale.tmp_th_client_type_lj t on t.client_id = acc.client_id
where
    acc.channel_type = 16 -- 询问任务
    and acc.parcel_callback_state = 2 -- 1已收到2未收到
    and acc.created_at >= '${start_date}'
    and acc.created_at < date_add('${end_date}', interval 1 day)
    ${if(len(client)=0,"","and t.client_type in ('"+SUBSTITUTE(client,",","','")+"')")}

union all

select
    '第二次客诉后，此单号在第一次询问任务中已上传证据' 结果分布
    ,count(acc.id) 整体
from bi_pro.abnormal_customer_complaint acc
left join bi_center.parcel_complaint_inquiry pci on acc.pno = pci.merge_column
left join tmpale.tmp_th_client_type_lj t on t.client_id = acc.client_id
where
    acc.channel_type = 16 -- 询问任务
    and acc.created_at >= '${start_date}'
    and acc.created_at < date_add('${end_date}', interval 1 day)
    and pci.apology_evidence is not null -- 已上传证据道歉
    ${if(len(client)=0,"","and t.client_type in ('"+SUBSTITUTE(client,",","','")+"')")}
;
insert overwrite
-- 询问任务处罚申诉
select
    '全部判责丢失' 结果分布
    ,count(pci.id) 整体
from bi_center.parcel_complaint_inquiry pci
join bi_pro.abnormal_message am on json_extract(am.extra_info, '$.id') = pci.id
where
    pci.created_at >= '${start_date}'
    and pci.created_at < date_add('${end_date}', interval 1 day)
    and am.punish_category = 7 -- parcel lost
    ${if(len(client)=0,"","and pci.client_type in ('"+SUBSTITUTE(client,",","','")+"')")}

union all

select
    '不可申诉' 结果分布
    ,count(pci.id) 整体
from bi_center.parcel_complaint_inquiry pci
join bi_pro.abnormal_message am on json_extract(am.extra_info, '$.id') = pci.id
where
    pci.created_at >= '${start_date}'
    and pci.created_at < date_add('${end_date}', interval 1 day)
    and am.punish_category = 7 -- parcel lost
    and json_extract(am.extra_info, '$.is_appeal') = 'false'
    ${if(len(client)=0,"","and pci.client_type in ('"+SUBSTITUTE(client,",","','")+"')")}

union all

select
    '可申诉' 结果分布
    ,count(pci.id) 整体
from bi_center.parcel_complaint_inquiry pci
join bi_pro.abnormal_message am on json_extract(am.extra_info, '$.id') = pci.id
where
    pci.created_at >= '${start_date}'
    and pci.created_at < date_add('${end_date}', interval 1 day)
    and am.punish_category = 7 -- parcel lost
    and json_extract(am.extra_info, '$.is_appeal') = 'true'
    ${if(len(client)=0,"","and pci.client_type in ('"+SUBSTITUTE(client,",","','")+"')")}

union all

select
    '发起申诉' 结果分布
    ,count(pci.id) 整体
from bi_center.parcel_complaint_inquiry pci
join bi_pro.abnormal_message am on json_extract(am.extra_info, '$.id') = pci.id
left join bi_pro.abnormal_qaqc aq on aq.abnormal_message_id = acc.abnormal_message_id
where
    pci.created_at >= '${start_date}'
    and pci.created_at < date_add('${end_date}', interval 1 day)
    and am.punish_category = 7 -- parcel lost
    and (coalesce(am.isappeal, aq.isappeal) in (2,3,4,5) or am.isdel = 1 )
    ${if(len(client)=0,"","and pci.client_type in ('"+SUBSTITUTE(client,",","','")+"')")}

union all

select
    '申诉通过' 结果分布
    ,count(pci.id) 整体
from bi_center.parcel_complaint_inquiry pci
join bi_pro.abnormal_message am on json_extract(am.extra_info, '$.id') = pci.id
left join bi_pro.abnormal_qaqc aq on aq.abnormal_message_id = acc.abnormal_message_id
where
    pci.created_at >= '${start_date}'
    and pci.created_at < date_add('${end_date}', interval 1 day)
    and am.punish_category = 7 -- parcel lost
    and (coalesce(am.isappeal, aq.isappeal) in (5) or am.isdel = 1 )
    ${if(len(client)=0,"","and pci.client_type in ('"+SUBSTITUTE(client,",","','")+"')")}

union all

select
    '保持原判' 结果分布
    ,count(pci.id) 整体
from bi_center.parcel_complaint_inquiry pci
join bi_pro.abnormal_message am on json_extract(am.extra_info, '$.id') = pci.id
left join bi_pro.abnormal_qaqc aq on aq.abnormal_message_id = acc.abnormal_message_id
where
    pci.created_at >= '${start_date}'
    and pci.created_at < date_add('${end_date}', interval 1 day)
    and am.punish_category = 7 -- parcel lost
    and coalesce(am.isappeal, aq.isappeal) = 3
    ${if(len(client)=0,"","and pci.client_type in ('"+SUBSTITUTE(client,",","','")+"')")}

;

-- 客诉申诉

select
    '全部判责丢失' 结果分布
    ,count(acc.id) 整体
from bi_pro.abnormal_customer_complaint acc
left join bi_pro.abnormal_message am on am.id = acc.abnormal_message_id
left join tmpale.tmp_th_client_type_lj t on t.client_id = acc.client_id
where
    acc.created_at >= '${start_date}'
    and acc.created_at < date_add('${end_date}', interval 1 day)
    and acc.channel_type = 16 -- 询问任务
    ${if(len(client)=0,"","and t.client_type in ('"+SUBSTITUTE(client,",","','")+"')")}

union all

select
    '不可申诉' 结果分布
    ,count(acc.id) 整体
from bi_pro.abnormal_customer_complaint acc
left join bi_pro.abnormal_message am on am.id = acc.abnormal_message_id
left join tmpale.tmp_th_client_type_lj t on t.client_id = acc.client_id
where
    acc.created_at >= '${start_date}'
    and acc.created_at < date_add('${end_date}', interval 1 day)
    and acc.channel_type = 16 -- 询问任务
    and json_extract(am.extra_info, '$.is_appeal') = 'false'
     ${if(len(client)=0,"","and t.client_type in ('"+SUBSTITUTE(client,",","','")+"')")}

union all

select
    '可申诉' 结果分布
    ,count(acc.id) 整体
from bi_pro.abnormal_customer_complaint acc
left join bi_pro.abnormal_message am on am.id = acc.abnormal_message_id
left join tmpale.tmp_th_client_type_lj t on t.client_id = acc.client_id
where
    acc.created_at >= '${start_date}'
    and acc.created_at < date_add('${end_date}', interval 1 day)
    and acc.channel_type = 16 -- 询问任务
    and json_extract(am.extra_info, '$.is_appeal') = 'true'
     ${if(len(client)=0,"","and t.client_type in ('"+SUBSTITUTE(client,",","','")+"')")}

union all

select
    '发起申诉' 结果分布
    ,count(acc.id) 整体
from bi_pro.abnormal_customer_complaint acc
left join bi_pro.abnormal_message am on am.id = acc.abnormal_message_id
left join bi_pro.abnormal_qaqc aq on aq.abnormal_message_id = am.id
left join tmpale.tmp_th_client_type_lj t on t.client_id = acc.client_id
where
    acc.created_at >= '${start_date}'
    and acc.created_at < date_add('${end_date}', interval 1 day)
    and acc.channel_type = 16 -- 询问任务
    and (coalesce(am.isappeal, aq.isappeal) in (2,3,4,5) or am.isdel = 1 )
     ${if(len(client)=0,"","and t.client_type in ('"+SUBSTITUTE(client,",","','")+"')")}

union all

select
    '申诉通过' 结果分布
    ,count(acc.id) 整体
from bi_pro.abnormal_customer_complaint acc
left join bi_pro.abnormal_message am on am.id = acc.abnormal_message_id
left join bi_pro.abnormal_qaqc aq on aq.abnormal_message_id = am.id
left join tmpale.tmp_th_client_type_lj t on t.client_id = acc.client_id
where
    acc.created_at >= '${start_date}'
    and acc.created_at < date_add('${end_date}', interval 1 day)
    and acc.channel_type = 16 -- 询问任务
    and (coalesce(am.isappeal, aq.isappeal) in (5) or am.isdel = 1 )
     ${if(len(client)=0,"","and t.client_type in ('"+SUBSTITUTE(client,",","','")+"')")}

union all

select
    '保持原判' 结果分布
    ,count(acc.id) 整体
from bi_pro.abnormal_customer_complaint acc
left join bi_pro.abnormal_message am on am.id = acc.abnormal_message_id
left join bi_pro.abnormal_qaqc aq on aq.abnormal_message_id = am.id
left join tmpale.tmp_th_client_type_lj t on t.client_id = acc.client_id
where
    acc.created_at >= '${start_date}'
    and acc.created_at < date_add('${end_date}', interval 1 day)
    and acc.channel_type = 16 -- 询问任务
    and coalesce(am.isappeal, aq.isappeal) = 3
     ${if(len(client)=0,"","and t.client_type in ('"+SUBSTITUTE(client,",","','")+"')")}

;



select
    '已收到包裹' 结果分布
    ,count(pci.id) 整体
from bi_center.parcel_complaint_inquiry pci
where
    pci.created_at >= '${start_date}'
    and pci.created_at < date_add('${end_date}', interval 1 day)
    and (pci.qaqc_is_receive_parcel in (2,4) or pci.apology_type = 2 ) -- 未收到，安排配送算作已收到;已收到；上传证据算已收到
     ${if(len(client)=0,"","and pci.client_type in ('"+SUBSTITUTE(client,",","','")+"')")}

union all

select
    '未收到包裹' 结果分布
    ,count(pci.id) 整体
from bi_center.parcel_complaint_inquiry pci
where
    pci.created_at >= '${start_date}'
    and pci.created_at < date_add('${end_date}', interval 1 day)
    and pci.qaqc_is_receive_parcel in (3,1)
     ${if(len(client)=0,"","and pci.client_type in ('"+SUBSTITUTE(client,",","','")+"')")}

union all

select
    '理赔金额' 结果分布
    ,sum(a.claim_money) 整体
from
    (
        select
            pci.merge_column
            ,pct.id
            ,replace(json_extract(pcn.`neg_result`,'$.money'),'\"','') claim_money
            ,row_number() over (partition by pcn.`task_id` order by pcn.`created_at` DESC ) rn
        from bi_center.parcel_complaint_inquiry pci
        join bi_pro.parcel_claim_task pct on pct.pno = pci.merge_column
        left join bi_pro.parcel_claim_negotiation pcn on pcn.task_id = pct.id
        where
            pci.created_at >= '${start_date}'
            and pci.created_at < date_add('${end_date}', interval 1 day)
            and pct.state = 6
             ${if(len(client)=0,"","and pci.client_type in ('"+SUBSTITUTE(client,",","','")+"')")}
    ) a
where
    a.rn = 1



;
select * from tmpale.tmp_th_client_type_lj