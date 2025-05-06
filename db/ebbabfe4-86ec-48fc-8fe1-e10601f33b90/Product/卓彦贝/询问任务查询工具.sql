select
    pi.pno
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
    end 包裹最终状态
    ,pi.ticket_delivery_staff_info_id 妥投快递员ID
    ,if(pci.merge_column is not null, '是', '否') 是否有询问任务
    ,pci.created_at 询问任务创建时间
    ,case pci.apology_type
        when 0 then '进行中'
        when 1 then '已超时关闭'
        when 2 then '道歉后自动关闭'
        when 3 then '无需处理自动关闭'
    end 询问任务处理状态
    ,pci.delivery_evidence 妥投证据
    ,pci.work_order_img '妥投证据-工单'
    , case pci.qaqc_is_receive_parcel
        when 0 then '未处理'
        when 1 then '联系不上'
        when 2 then '已收到包裹'
        when 3 then '未收到包裹'
        when 4 then '未收到包裹,已有约定派送时间'
    end 回访结果
from
    (
        select
            pi.pno
            ,pi.state
            ,pi.ticket_delivery_staff_info_id
        from my_staging.parcel_info pi
        where
            pi.created_at > date_sub(curdate(), interval 3 month)
            and pi.pno in ('${SUBSTITUTE(SUBSTITUTE(pno,"\n",","),",","','")}')
    ) pi
left join
    (
        select
            pci.merge_column
            ,pci.created_at
            ,pci.apology_type
            ,pci.qaqc_is_receive_parcel
            ,concat(json_extract(pci.apology_evidence, '$[0].url'), ',', ifnull(json_extract(pci.apology_evidence, '$[1].url'), ''), ',', ifnull(json_extract(pci.apology_evidence, '$[2].url'), '')) delivery_evidence
            ,group_concat(distinct concat('https://fex-my-asset-pro.oss-ap-southeast-3.aliyuncs.com/', woi.object_key)) work_order_img
        from my_bi.parcel_complaint_inquiry pci
        left join my_bi.parcel_complaint_inquiry_log pcil on pcil.inquiry_id = pci.id and pcil.created_at > date_sub(curdate(), interval 3 month)
        left join my_bi.work_order_img woi on woi.origin_id = json_extract(pcil.extra_info, '$.work_order_reply_id') and woi.oss_bucket_type = 2
        where
            pci.created_at > date_sub(curdate(), interval 3 month)
#             and pci.merge_column in ('${SUBSTITUTE(SUBSTITUTE(pno,"\n",","),",","','")}')
            and pci.merge_column = 'CNMYF0001309380'
        group by
            pci.merge_column
    ) pci on pi.pno = pci.merge_column
;


# case pci.apology_type
#         when 0 then '进行中'
#         when 1 then '已超时关闭'
#         when 2 then '道歉后自动关闭'
#         when 3 then '无需处理自动关闭'
#     end 询问任务处理状态

# case pci.qaqc_is_receive_parcel
#         when 0 then '未处理'
#         when 1 then '联系不上'
#         when 2 then '已收到包裹'
#         when 3 then '未收到包裹'
#         when 4 then '未收到包裹,已有约定派送时间'
#     end 回访结果


;

select
      json_extract(pci.apology_evidence, '$[1].url') delivery_evidence
      ,json_extract(pci.apology_evidence, '$[0].url') delivery_evidence
    ,concat(json_extract(pci.apology_evidence, '$[0].url'), ',', ifnull(json_extract(pci.apology_evidence, '$[1].url'), ''), ',', ifnull(json_extract(pci.apology_evidence, '$[2].url'), '')) delivery_evidence
  from my_bi.parcel_complaint_inquiry pci
  where pci.merge_column = 'CNMYF0001309380'
;




