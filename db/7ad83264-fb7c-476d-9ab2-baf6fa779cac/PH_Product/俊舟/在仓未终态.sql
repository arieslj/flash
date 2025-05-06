with t as
    (
        select
            ps.pno
            ,pi.client_id
            ,ps.arrive_dst_route_at
            ,pi.state
            ,pi.dst_store_id
            ,pi.customary_pno
            ,pi.returned
        from ph_bi.parcel_sub ps
        join ph_staging.parcel_info pi on pi.pno = ps.pno and ps.arrive_dst_store_id = pi.dst_store_id
        where
            ps.arrive_dst_route_at != '1970-01-01 00:00:00'
            and pi.state in (1,2,3,4,6)
            and pi.returned = 0
    )
select
    t1.pno
     ,case t1.state
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
    ,dp.store_name 目的地网点
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as 客户类型
    ,date(t1.arrive_dst_route_at) 到仓时间
    ,pr.pr_cnt 总交接数
    ,if(t1.returned = 1, dai.returned_delivery_attempt_num, dai.delivery_attempt_num) 包裹有效尝试次数
    ,if(pp.pno is not null, '是', '否') 是否PRI
    ,case
        when bc.client_name = 'lazada' then la.whole_end_date
        when bc.client_name = 'shopee' then sh.end_date
        when bc.client_name = 'tiktok' then if( tt.end_7_date is null, tt.end_date, tt.end_7_date)
        when bc.client_name = 'shein' then ein.whole_end_date
        else null
    end 丢失时效
    ,datediff(curdate(), case
        when bc.client_name = 'lazada' then la.whole_end_date
        when bc.client_name = 's    hopee' then sh.end_date
        when bc.client_name = 'tiktok' then if( tt.end_7_date is null, tt.end_date, tt.end_7_date)
        when bc.client_name = 'shein' then ein.whole_end_date
        else null
    end ) 距离时效多少天
from t t1
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = t1.dst_store_id and dp.stat_date = date_sub(curdate(), 1)
left join ph_staging.ka_profile kp on kp.id = t1.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = t1.client_id
left join ph_staging.delivery_attempt_info dai on dai.pno = coalesce(t1.customary_pno, t1.pno)
left join ph_staging.parcel_priority_delivery_detail pp on pp.pno = t1.pno
left join dwm.dwd_ex_ph_lazada_pno_period la on la.pno = coalesce(t1.customary_pno, t1.pno)
left join dwm.dwd_ex_shopee_lost_pno_period sh on sh.pno = coalesce(t1.customary_pno, t1.pno)
left join dwm.dwd_ex_ph_tiktok_sla_detail tt on tt.pno = coalesce(t1.customary_pno, t1.pno)
left join dwm.dwd_ex_ph_shein_sla_detail ein on ein.pno = coalesce(t1.customary_pno, t1.pno)
left join
    (
        select
            t1.pno
            ,count(distinct date (convert_tz(pr.routed_at, '+00:00', '+08:00'))) pr_cnt
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > date_sub(curdate(), interval 2 month)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        group by 1
    ) pr on pr.pno = t1.pno
  ;
