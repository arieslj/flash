select
    distinct
    pi.pno 运单号
    ,pi.client_id 客户ID
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
    end as 运单状态
    ,tt.end_date SLA
    ,pi.ticket_pickup_id 揽收任务ID
    ,convert_tz(pi.created_at, '+00:00', '+07:00') 揽收时间
    ,src_store 揽收网点
    ,pss.theoretical_finished_at 理论到达时间
    ,if(c.pno is not null, '是', '否') 是否为禁运品
from fle_staging.parcel_info pi
join dwm.dwd_ex_th_tiktok_sla_detail tt on tt.pno = pi.pno
left join fle_staging.parcel_speed_sla pss on pss.pno = pi.pno
left join bi_pro.contraband c on c.pno = pi.pno and c.duty_level in (1,2)
where
    pi.pno in ('${SUBSTITUTE(SUBSTITUTE(p1,"\n",","),",","','")}')