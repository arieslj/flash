select
    pci.merge_column '运单信息Related information'
    ,case  pci.client_type
        when 1 then 'lazada'
        when 2 then 'shopee'
        when 3 then 'tiktok'
        when 4 then 'shein'
        when 5 then 'otherKAM'
        when 6 then 'otherKA'
        when 7 then '小C'
    end '客户类型Customer Type'
    ,case pci.source
        when 1 then '问题记录本Problem Log'
        when 2 then '疑似违规回访Suspected Violation Callback'
        when 3 then 'APP'
        when 4 then '官网Official Website'
        when 5 then '短信SMS'
        when 6 then 'FBI'
    end '任务渠道Task Channel'
    ,pci.finished_at '妥投时间Delivery Time'
    ,pci.complaints_at '用户投诉时间User Response Time'
    ,pci.created_at '工单生成时间Inquiry Task Generation Time'
    ,pci.apology_at '询问任务完成时间Inquiry Task Completion Time'
    ,pci.staff_info_id '快递员ID Inquiry Task Employee'
    ,dt.store_name '网点Inquiry Task Branch'
    ,dt.piece_name '片区Inquiry Task District'
    ,dt.region_name '大区Inquiry Task Area'
    ,pci.qaqc_created_at '回访任务生成时间Callback Task Generation Time'
    ,pci.customer_phone '回访客户手机号Callback Phone Number'
    ,case pci.qaqc_is_receive_parcel
        when 0 then '未处理Not processed'
        when 1 then '联系不上Unable to Contact'
        when 2 then '已收到包裹Received Parcel'
        when 3 then '未收到包裹Did Not Received Parcel'
        when 4 then '未收到包裹,已有约定派送时间The parcel has not been received and the delivery time has been agreed upon.'
    end '回访结果customer_complaints_qaqc_callback_result'
    ,pci.remark '回访备注Callback Remark'
    ,concat(if( apology_evidence_qualified & 1 = 1 , '第一次证据不合格First evidence submitted is not valid' ,''),',',if( apology_evidence_qualified & 2 = 2 , '转交回访收件人Transfer to CS for call' ,'')) '证据是否合格Is the evidence qualified?'
from ph_bi.parcel_complaint_inquiry pci
left join dwm.dim_ph_sys_store_rd dt on dt.store_id = pci.store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
where
    pci.created_at > date_sub(curdate(), interval 1 day)
    and pci.created_at < curdate()


;

select
      *
  from ph_bi.translations t
  where
      t.t_key like '%source%'