select
    pi.pno 运单号
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as 客户类型
    ,pi.ticket_delivery_staff_info_id 妥投员工ID
    ,if(pi.state = 5, date_format(convert_tz(pi.finished_at, '+00:00', '+08:00'), '%Y-%m-%d'), null) 妥投日期
    ,dp.store_name 妥投网点
        ,dp.piece_name 所属片区
    ,dp.region_name 所属大区
        ,st_distance_sphere(point(pi.ticket_delivery_staff_lng, pi.ticket_delivery_staff_lat), point(ss.lng, ss.lat)) 妥投点距离网点坐标距离m
    ,if(pi.state = 5, date_format(convert_tz(pi.finished_at, '+00:00', '+08:00'), '%H:%i'), null) 妥投时间
    ,if(pi.state = 5, datediff(date(convert_tz(pi.finished_at, '+00:00', '+08:00')), case
        when bc.client_name = 'lazada' then lz.delievey_end_date
        when bc.client_name = 'shopee' then sp2.delievey_end_date
        when bc.client_name = 'tiktok' then tt.end_date
    end ), null) 妥投日期距离正向SLA时效天数
    ,if(pi.state = 5, datediff(date(convert_tz(pi.finished_at, '+00:00', '+08:00')), case
        when bc.client_name = 'lazada' then lz.whole_end_date
        when bc.client_name = 'shopee' then sp.end_date
        when bc.client_name = 'tiktok' then if(pi.returned = 0, tt.end_7_date, tt.end_7_plus_date)
    end), null) 妥投日期距离丢失SLA天数
    ,if(pi.returned = 1, dai.returned_delivery_attempt_num, delivery_attempt_num) 有效尝试派送次数
    ,p1.plt_cnt 妥投前进入过疑似丢失待处理次数
    ,p2.ps_days 妥投当天距离到件入仓天数
from ph_staging.parcel_info pi
left join ph_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
left join ph_staging.sys_store ss on ss.id = pi.ticket_delivery_store_id
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pi.ticket_delivery_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
left join dwm.dwd_ex_ph_lazada_pno_period lz on lz.pno = pi.pno
left join dwm.dwd_ex_shopee_lost_pno_period sh on sh.pno = pi.pno
left join dwm.dwd_ex_ph_tiktok_sla_detail tt on tt.pno = if(pi.returned = 0, pi.pno, pi.customary_pno)
left join dwm.dwd_ex_shopee_lost_pno_period sp on sp.pno = pi.pno
left join dwm.dwd_ex_ph_shopee_sla_detail sp2 on sp2.pno = pi.pno
left join ph_staging.delivery_attempt_info dai on dai.pno = if(pi.returned = 0, pi.pno, pi.customary_pno)
left join
    (
        select
            pi.pno
            ,count(distinct plt.id) plt_cnt
        from ph_staging.parcel_info pi
        join ph_bi.parcel_lose_task plt on plt.pno = pi.pno
        where
            pi.created_at > date_sub(curdate(), interval 3 month)
            and plt.created_at < date_add(pi.finished_at, interval 8 hour)
            and pi.pno in ('${SUBSTITUTE(SUBSTITUTE(p1,"\n",","),",","','")}')
        group by 1
    ) p1 on p1.pno = pi.pno
left join
    (
        select
            pi.pno
            ,datediff(date (convert_tz(pi.finished_at, '+00:00', '+08:00')), ps.arrive_dst_route_at) ps_days
        from ph_bi.parcel_sub ps
        join ph_staging.parcel_info pi on pi.pno = ps.pno
        where
            pi.created_at > date_sub(curdate(), interval 3 month)
            and pi.pno in ('${SUBSTITUTE(SUBSTITUTE(p1,"\n",","),",","','")}')
    ) p2 on p2.pno = pi.pno
where
    pi.created_at > date_sub(curdate(), interval 3 month)
    and pi.pno in ('${SUBSTITUTE(SUBSTITUTE(p1,"\n",","),",","','")}')
;

,case
        when bc.client_name = 'lazada' then la.delievey_end_date
        when bc.client_name = 'shopee' then sp2.delievey_end_date
        when bc.client_name = 'tiktok' then tt.end_date
    end SLA
    ,case
        when bc.client_name = 'lazada' then la.whole_end_date
        when bc.client_name = 'shopee' then sp.end_date
        when bc.client_name = 'tiktok' then if(t1.returned = 0, tt.end_7_date, tt.end_7_plus_date)
    end 丢失SLA

;

select
    min(pr.routed_at)
from ph_staging.parcel_route pr
join ph_staging.parcel_info pi on pi.pno = pr.pno and pi.state = 5