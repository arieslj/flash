
select
    dmv.pno
    ,dmv.client_id 客户ID
    ,date(dmv.mark_at) 派送日期
    ,dmv.mark_at 标记派送失败的时间
    ,ddd.CN_element 标记原因
    ,case dmv.status
        when 0 then '失败'
        when 1 then '成功'
    end Viber发送消息是否成功
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
    ,if(pi.state = 5,convert_tz(pi.finished_at, '+00:00', '+08:00'), null) 妥投时间
from nl_production.delivery_mark_viber_msg dmv
left join dwm.dwd_dim_dict ddd on ddd.element = dmv.marker_category and ddd.db = 'ph_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
left join ph_staging.parcel_info pi on pi.pno = dmv.pno
where
    dmv.client_id in ('CA1385','BA0307','BA0609','BA0709','CA1281','AA0140','BA0344','CA1280','BA0300','BA0323','AA0142','BA0441','BA0391','AA0111','CA0548','CA0089','CA3478','AA0076','BA0056','BA0299','BA0258','BA0577','BA0599','BA0379','BA0478','BA0083','BA0184','AA0145','CA0218','CA0658','CA1646','CA0314','CA1644','CA0179','CA102')
    and dmv.created_at >= '2023-11-01'
    and dmv.created_at < '2024-01-01'