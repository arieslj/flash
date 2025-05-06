select
    distinct
    pci.merge_column 单号
    ,pci.id
    ,case  pci.client_type
        when 1 then 'lazada'
        when 2 then 'shopee'
        when 3 then 'tiktok'
        when 4 then 'shein'
        when 5 then 'otherKAM'
        when 6 then 'otherKA'
        when 7 then '小C'
    end 客户类型
    ,pci.staff_info_id 询问任务员工
    ,hjt.job_name 询问任务员工职位
    ,ss.name 询问任务网点
    ,case pci.source
        when 1 then '问题记录本'
        when 2 then '疑似违规回访'
        when 3 then 'APP'
        when 4 then '官网'
        when 5 then '短信'
    end 任务渠道
    ,pci.created_at 询问任务生成时间
    ,case pci.apology_type
        when 0 then '进行中'
        when 1 then '已超时关闭'
        when 2 then '道歉后自动关闭'
        when 3 then '无需处理自动关闭'
    end 询问任务处理状态
    ,case pci.qaqc_is_receive_parcel
        when 0 then '未处理'
        when 1 then '联系不上'
        when 2 then '已收到包裹'
        when 3 then '未收到包裹'
        when 4 then '未收到包裹,已有约定派送时间'
    end 回访结果
    ,convert_tz(am.created_at, '+00:00', '+08:00')  询问任务生成丢失处罚的时间
    ,if(plt.state = 6, plt.updated_at, null) 闪速认定qaqc判责丢失时间
    ,pct.created_at 闪速理赔生成时间
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
from bi_center.parcel_complaint_inquiry pci
left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = pci.staff_info_id
left join bi_pro.hr_job_title hjt on hjt.id = hsi.job_title
left join fle_staging.sys_store ss on ss.id = pci.store_id
left join bi_pro.abnormal_message am on json_extract(am.extra_info, '$.id') = pci.id and json_extract(am.extra_info, '$.src') = 'parcel_complaint_inquiry'
left join bi_pro.abnormal_customer_complaint acc on acc.pno = pci.merge_column and acc.channel_type = 16
left join bi_pro.parcel_lose_task plt on acc.abnormal_message_id = substring(plt.source_id, 16)
left join bi_pro.parcel_claim_task pct on pct.pno = pci.merge_column
where
    pci.created_at > '2024-05-01'
    and pci.created_at < '2024-06-01'



;


select
    t.pno
    ,pci.created_at 询问任务生成时间
    ,pci.apology_at 快递员上传时间
    ,pci.qaqc_created_at 进入回访时间
from tmpale.tmp_th_pno_lj_0912 t
left join  bi_center.parcel_complaint_inquiry pci on t.pno = pci.merge_column
