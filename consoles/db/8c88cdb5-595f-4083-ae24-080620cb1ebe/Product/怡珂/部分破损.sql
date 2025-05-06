select
    dor.pno
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as 客户类型
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
    end 当前状态
    ,if(pct.pno is not null, '是', '否') as 是否有理赔任务
    ,case pct.state
        when 1 then '待协商'
        when 2 then '协商不一致，待重新协商'
        when 3 then '待财务核实'
        when 4 then '核实通过，待财务支付'
        when 5 then '财务驳回'
        when 6 then '理赔完成'
        when 7 then '理赔终止'
        when 8 then '异常关闭'
        when 9 then' 待协商（搁置）'
        when 10 then '等待再次联系'
    end 理赔状态
from fle_staging.diff_operation_record dor
left join fle_staging.parcel_info pi on pi.pno = dor.pno
left join rot_pro.parcel_route pr on pr.pno = dor.pno and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'  and pr.store_id = dor.store_id
left join bi_pro.parcel_claim_task pct on pct.pno = dor.pno
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id
left join fle_staging.ka_profile kp on kp.id = pi.client_id
where
    dor.state = 3
    and dor.parcel_report_category = 2
    and dor.created_at > '2024-05-31 17:00:00'
    and pr.routed_at > dor.created_at