select
    convert_tz(di.created_at, '+00:00', '+08:00') 疑难件提交时间
    ,convert_tz(cdt.last_operated_at, '+00:00', '+08:00') 最后处理时间
    ,pi.client_id 客户ID
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as 客户类型
    ,if(pi.returned = 1, '退件', '正向') 包裹流向
    ,if(pi.returned = 1, pi.customary_pno, pi.pno) 正向运单号
    ,if(pi.returned = 1, pi.pno, null) 退件运单号
    ,ddd.cn_element 疑难原因
    ,s1.name 正向揽收网点
    ,s2.name 正向目的地网点
    ,s3.name 退件揽收网点
    ,s4.name 退件目的地网点
    ,s5.name 疑难件提交网点
    ,case cdt.negotiation_result_category # 协商结果
        when 1 then '赔偿' -- 丢弃并赔偿（关闭订单，网点自行处理包裹）
        when 2 then '关闭订单(不赔偿不退货)' -- 丢弃（关闭订单，网点自行处理包裹）
        when 3 then '退货'
        when 4 then '退货并赔偿'
        when 5 then '继续配送'
        when 6 then '继续配送并赔偿'
        when 7 then '正在沟通中'
        when 8 then '丢弃包裹的，换单后寄回BKK' -- 丢弃（包裹发到内部拍卖仓）
        when 9 then '货物找回，继续派送'
        when 10 then '改包裹状态'
        when 11 then '需客户修改信息'
        when 12 then '丢弃并赔偿（包裹发到内部拍卖仓）'
        when 13 then 'TT退件新增“holding（15天后丢弃）”协商结果'
        else cdt.negotiation_result_category
    end 协商结果
from my_staging.diff_info di
left join my_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
left join my_staging.parcel_info pi on pi.pno = di.pno
left join dwm.dwd_dim_dict ddd on ddd.element = di.diff_marker_category and ddd.db = 'my_staging' and ddd.tablename = 'diff_info' and  ddd.fieldname = 'diff_marker_category'
left join my_staging.parcel_info p1 on p1.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
left join my_staging.sys_store s1 on s1.id = p1.ticket_pickup_store_id
left join my_staging.sys_store s2 on s2.id = p1.dst_store_id
left join my_staging.parcel_info p2 on p2.pno = if(pi.returned = 1, pi.pno, null)
left join my_staging.sys_store s3 on s3.id = p2.ticket_pickup_store_id
left join my_staging.sys_store s4 on s4.id = p2.dst_store_id
left join my_staging.sys_store s5 on s5.id = di.store_id
left join my_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id
where
    di.created_at > '2024-03-31 16:00:00'
    and di.created_at < '2024-04-30 16:00:00'
