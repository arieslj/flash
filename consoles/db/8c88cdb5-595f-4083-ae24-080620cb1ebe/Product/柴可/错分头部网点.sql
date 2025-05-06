select
    dc.stat_date 应派日期
    ,ss.id  网点ID
    ,ss.name 网点
    ,dc.pno
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as  客户类型
    ,dc.arrival_scan_route_at 首次到达目的地网点时间
    ,if(ppd.pno is not null, '是', '否') 当日是否PRI
    ,pnp.near_period_day
    ,case pi.returned
        when 0 then '正向'
        when 1 then '退件'
    end  包裹流向
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
    ,if(pi.state = 5 ,date (convert_tz(pi.finished_at, '+00:00', '+07:00')), null)  包裹妥投日期
from
    (
        select
            dc.*
        from bi_pro.dc_should_delivery_2024_05 dc
        where
            dc.store_id in ('TH20070518', 'TH37010150', 'TH20080103', 'TH20070811', 'TH20080402')

        union all

        select
            dc.*
        from bi_pro.dc_should_delivery_today  dc
        where
            dc.store_id in ('TH20070518', 'TH37010150', 'TH20080103', 'TH20070811', 'TH20080402')
    ) dc
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = dc.client_id
left join fle_staging.ka_profile kp on kp.id = dc.client_id
left join fle_staging.parcel_priority_delivery_detail ppd on ppd.pno = dc.pno and ppd.screening_date = dc.stat_date
left join fle_staging.parcel_info pi on pi.pno = dc.pno
left join fle_staging.parcel_near_prescription_delivery_detail pnp on pnp.pno = dc.pno and pnp.screening_date = curdate()
left join fle_staging.sys_store ss on ss.id = dc.store_id



;


select * from fle_staging.parcel_info pi where pi.pno = 'TH20074B6G6R9H0'
;

select * from fle_staging.parcel_near_prescription_delivery_detail pnp where pnp.screening_date >= '2024-05-15'

