select
    t.pno
    ,if(am.merge_column is not null, 'y', 'n') 是否因为询问任务生成了丢失处罚
    ,pct.created_at
    ,case pct.state
        when 1 then '待协商 รอเจรจา'
        when 2 then '协商不一致'
        when 3 then '待财务核实'
        when 4 then '待财务支付'
        when 5 then '支付驳回'
        when 6 then '理赔完成'
        when 7 then '理赔终止 ยุติการเคลม'
        when 8 then '异常关闭'
    end 理赔状态
from bi_center.parcel_complaint_inquiry pci
join tmpale.tmp_th_pno_lj_250225 t on t.pno = pci.merge_column
left join bi_pro.abnormal_message am on json_extract(am.extra_info, '$.id') = pci.id and json_extract(am.extra_info, '$.src') = 'parcel_complaint_inquiry'
left join bi_pro.parcel_claim_task pct on pct.pno = t.pno
where
    pci.created_at > '2025-01-01'