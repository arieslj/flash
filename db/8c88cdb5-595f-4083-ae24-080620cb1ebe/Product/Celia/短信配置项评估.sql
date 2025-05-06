with t as
    (
        select
            pi.pno
            ,pi.finished_at
            ,date(convert_tz(pi.finished_at, '+00:00', '+07:00')) fin_date
            ,pi.client_id
            ,pi.ticket_delivery_store_id
        from fle_staging.parcel_info pi
        left join fle_staging.sys_store ss2 on ss2.id = pi.ticket_delivery_store_id
        where
            pi.state = 5
            and ss2.name in ('KNT_SP-คลองเตยเหนือ','SBN_SP-สวนเบญจ์','SUN_SP-สวนหลวงเหนือ','KTH_SP-คลองตันเหนือ','KNE_SP-พระโขนงเหนือ','NWM_SP-นวมินทร์','PTT_SP-พัฒนาการ','RKH_SP-รามคำแหง','BKB_SP-บางกะปิ','ONB_SP-อ่อนนุชบน','SKV_SP-สุขุมวิท','BGK_SP-บางจาก','HMM_SP-หัวหมาก','KJN_SP-คลองจั่น','ONN_SP-อ่อนนุช','NBO_SP-หนองบอน','WAT_SP-วัฒนา','PRV_SP-ประเวศ','SUL_SP-สวนหลวง')
            and pi.client_id in ('AA0622', 'AA0649', 'AA0650')
            and pi.finished_at > '2024-07-21 17:00:00'
            and pi.finished_at < '2024-07-28 17:00:00'
    )
select
    t1.pno
    ,t1.client_id 客户ID
    ,ss.name 网点
    ,ss.id 网点ID
    ,sc.staff_info_id 交接快递员ID
    ,convert_tz(sc.routed_at, '+00:00', '+07:00') 第一次交接日期
    ,convert_tz(di.created_at, '+00:00', '+07:00') 标记问题件日期
    ,di.CN_element 标记问题件原因
    ,convert_tz(t1.finished_at, '+00:00', '+07:00') 妥投日期
    ,dc.shd_cnt 网点当日应派
from t t1
left join fle_staging.sys_store ss on ss.id = t1.ticket_delivery_store_id
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,pr.staff_info_id
            ,row_number() over (partition by pr.pno order by pr.routed_at) rk
        from rot_pro.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > '2024-07-01'
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    ) sc on t1.pno = sc.pno and sc.rk = 1
left join
    (
        select
            di.pno
            ,di.created_at
            ,ddd.CN_element
        from fle_staging.diff_info di
        join t t1 on t1.pno = di.pno
        left join dwm.dwd_dim_dict ddd on ddd.element = di.diff_marker_category and ddd.db = 'fle_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
        where
            di.created_at > '2024-07-01'
    ) di on t1.pno = di.pno
left join
    (
        select
            ds.stat_date
            ,ds.store_id
            ,count(ds.pno) shd_cnt
        from bi_center.dc_should_delivery_2024_07  ds
        where
            ds.stat_date >= '2024-07-22'
            and ds.stat_date < '2024-07-28'
        group by 1,2
    ) dc on dc.stat_date = t1.fin_date and dc.store_id = t1.ticket_delivery_store_id


;
