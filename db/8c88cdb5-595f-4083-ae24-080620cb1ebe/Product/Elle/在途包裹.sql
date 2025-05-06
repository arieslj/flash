-- 需求文档：https://flashexpress.feishu.cn/wiki/OGbLw0Yp4i8jjskT62gcs3N0nog

select
    pi.client_id 客户ID
    ,pi.pno 运单号
    ,if(pi.returned = 1, '逆向', '正向')  包裹类型
    ,convert_tz(pi.created_at, '+00:00', '+07:00') 揽收时间
    ,ss.name 揽收网点
    ,ss2.name 当前包裹所在网点
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
		  else pi.state
      end as 包裹状态
    ,if(pi.cod_enabled = 1, '是', '否') 是否COD包裹
from fle_staging.parcel_info pi
left join bi_pro.parcel_detail pd on pd.pno = pi.pno
left join fle_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
left join fle_staging.sys_store ss2 on ss2.id = pd.last_valid_store_id
where
    pi.state in (1,2,3,4,6)
    and pi.client_id in ('${SUBSTITUTE(SUBSTITUTE(client_id,"\n",","),",","','")}')
    and pi.created_at >= date_sub('${start_date}', interval 7 hour)
    and pi.created_at < date_add('${end_date}', interval 17 hour)