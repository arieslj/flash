# '${end_date}';

select
    lo.pick_time 揽收时间
    ,lo.pick_month 揽收月份
    ,lo.handle_time 判责时间
    ,lo.client_id 客户ID
    ,lo.client_name 客户名称
    ,lo.pno 运单号
    ,lo.handle_type 判责类型
    ,lo.handle_reason 判责原因
    ,lo.submit_store 上报问题网点
    ,lo.remark 问题件备注
    ,lo.duty_store 责任网点
    ,lo.duty_staff 责任人
    ,lo.cod 是否cod
    ,lo.cogs cogs金额
    ,pi.cod_amount/100 cod
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
        ELSE '其他'
	end 包裹状态
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 妥投时间
    ,pr.store_name 妥投网点
    ,pr.staff_info_id 妥投快递员
    ,pr.staff_info_name 妥投快递员名称
from tmpale.tmp_ph_lost_pno lo
left join ph_staging.parcel_info pi on pi.pno = lo.pno
left join ph_staging.parcel_route pr on pr.pno = lo.pno and pr.route_action = 'DELIVERY_CONFIRM' and pr.routed_at > '2023-08-31 16:00:00'
where
    lo.pick_time >= '2023-09-01'
    and lo.pick_time < '2023-11-01'

union all

select
    lo.pick_time 揽收时间
    ,lo.pick_month 揽收月份
    ,lo.handle_time 判责时间
    ,lo.client_id 客户ID
    ,lo.client_name 客户名称
    ,lo.pno 运单号
    ,lo.handle_type 判责类型
    ,lo.handle_reason 判责原因
    ,lo.submit_store 上报问题网点
    ,lo.remark 问题件备注
    ,lo.duty_store 责任网点
    ,lo.duty_staff 责任人
    ,lo.cod 是否COD
    ,lo.cogs cogs金额
    ,pi.cod_amount/100 cod
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
        ELSE '其他'
	end 包裹状态
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 妥投时间
    ,pr.store_name 妥投网点
    ,pr.staff_info_id 妥投快递员
    ,pr.staff_info_name 妥投快递员名称
from tmpale.tmp_ph_damage_pno lo
left join ph_staging.parcel_info pi on pi.pno = lo.pno
left join ph_staging.parcel_route pr on pr.pno = lo.pno and pr.route_action = 'DELIVERY_CONFIRM' and pr.routed_at > '2023-08-31 16:00:00'
where
    lo.pick_time >= '2023-09-01'
    and lo.pick_time < '2023-11-01'

;

select
    t.pno
    ,if(pi.client_id in ('AA0051', 'AA0080', 'AA0050', 'AA0121', 'AA0139'), oi.insure_declare_value/100, oi.cogs_amount/100) cogs
    ,pi.cod_amount/100 cod
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
        ELSE '其他'
	end 包裹状态
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 妥投时间
    ,pr.store_name 妥投网点
    ,pr.staff_info_id 妥投快递员
    ,pr.staff_info_name 妥投快递员名称
from ph_staging.parcel_info pi
join tmpale.tmp_ph_pno_lj_1116 t on t.pno = pi.pno
left join ph_staging.order_info oi on oi.pno = t.pno
left join ph_staging.parcel_route pr on pr.pno = t.pno and pr.route_action = 'DELIVERY_CONFIRM' and pr.routed_at > '2023-08-31 16:00:00'
where
    pi.created_at > '2023-08-30'