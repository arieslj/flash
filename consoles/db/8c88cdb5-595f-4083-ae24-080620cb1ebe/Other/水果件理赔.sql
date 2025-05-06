with t as
(
    select
        a.*
    from
        (
            select
                pct.id
                ,pct.pno
                ,pct.client_id
                ,pct.source
                ,pcn.neg_result
                ,pct.updated_at
                ,row_number() over (partition by pct.id order by pcn.created_at desc ) rk
            from bi_pro.parcel_claim_task pct
            left join bi_pro.parcel_claim_negotiation pcn on pcn.task_id = pct .id
            where
                pct.state = 6
                and pct.special_claim_category = 1 -- 水果件理赔
#                 and pct.updated_at >= date_sub(curdate(), interval 1 day )
#                 and pct.updated_at < curdate()
                and date(pct.updated_at) = '2023-04-28'
        ) a
    where
        a.rk = 1
)
select
    convert_tz(pi.created_at, '+00:00', '+07:00') 揽收时间
    ,t.pno 运单号
    ,case pi.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
    ,json_extract(t.neg_result,'$.money') 理赔金额
    ,case
        when t.source in (1,2,3,5,8,33,12) then '丢失'
        when t.source in (4,6,7,9,10) then '破损'
        when t.source in (11) then '超时效'
    end 理赔类型
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.id is null then '普通ka'
        when kp.`id` is null then '小c'
    end 客户类型
    ,group_concat(distinct plr.store_id) 责任网点
    ,t.client_id 客户ID
    ,coalesce(kp.name, ui.name) 客户名称
    ,pi.exhibition_length 长
    ,pi.exhibition_width 宽
    ,pi.exhibition_height 高
    ,pi.store_weight/1000 计费重量
    ,pi.store_total_amount 总运费
    ,dt.store_name 揽收网点
    ,dt.area_name 揽收区域
    ,dt.province_name 揽收省
    ,dt2.store_name 目的地网点
    ,dt2.area_name 目的地区域
    ,dt2.province_name 目的地省
    ,case bc.client_name
        when 'lazada' then dl.sla
        when 'shopee' then ds.sla_day
    else null
    end 理论运输时效
    ,datediff(t.updated_at, convert_tz(pi.created_at, '+00:00', '+07:00')) '实际运输时效（理赔完成时间-揽收）'
from t
left join fle_staging.parcel_info pi on pi.pno = t.pno
left join fle_staging.ka_profile kp on kp.id = t.client_id
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = t.client_id
left join bi_pro.parcel_lose_task plt on plt.pno = t.pno
left join bi_pro.parcel_lose_responsible plr on plr.lose_task_id = plt.id
left join fle_staging.user_info ui on ui.id = t.client_id
left join dwm.dim_th_sys_store_rd dt  on dt.store_id = pi.ticket_pickup_store_id
left join dwm.dim_th_sys_store_rd dt2 on dt2.store_id = pi.dst_store_id
left join dwm.dwd_ex_th_lazada_sla_detail dl on dl.pno = t.pno
left join dwm.dwd_ex_th_shopee_sla_detail ds on ds.pno = t.pno
left join dwm.dwd_ex_th_tiktok_sla_detail dtt on dtt.pno = t.pno
left join dwm.dwd_ex_th_shein_sla_detail dse on dse.pno = t.pno
group by 2