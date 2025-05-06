with t as
    (
        select
            a.*
        from
            (
                select
                    di.pno
                    ,di.store_id
                    ,pi.dst_store_id
                    ,pi.client_id
                    ,cdt.examination_pass_enabled
                    ,di.created_at
                    ,row_number() over (partition by di.pno order by di.created_at desc) rk
                from ph_staging.diff_info di
                left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
                left join ph_staging.parcel_info pi on pi.pno = di.pno
                where
                    di.created_at > date_sub(curdate(), interval 32 hour )
                    and di.created_at < date_sub(curdate(), interval 8 hour )
                    and di.diff_marker_category = 31
            ) a
        where
            a.rk = 1
    )
select
    a1.pno  单号
    ,a1.client_id 客户ID
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end 客户类型
    ,ss.name 提交网点
    ,sp.name 提交网点省份
    ,sc.name 提交网点城市
    ,sd.name 提交网点乡
    ,s2.name 目的地网点
    ,smp.name 目的地片区
    ,smr.name 目的地大区
    ,sp2.name 目的地网点省份
    ,sc2.name 目的地网点城市
    ,sd2.name 目的地网点乡
    ,dp.store_name 包裹当前所在网点
    ,dp.piece_name 包裹当前所在片区
    ,dp.region_name 包裹当前所在大区
    ,st_distance_sphere(point(ss.lng, ss.lat), point(s2.lng, s2.lat)) 提交网点和目的地网点之间距离
    ,di.di_cnt 提交错分次数
    ,if(a1.examination_pass_enabled = 1, '是', '否') 最后一次提交问题件是否审核通过
from t a1
left join ph_staging.sys_store ss on ss.id = a1.store_id
left join ph_staging.sys_province sp on sp.code = ss.province_code
left join ph_staging.sys_city sc on sc.code = ss.city_code
left join ph_staging.sys_district sd on sd.code = ss.district_code

left join ph_staging.sys_store s2 on s2.id = a1.dst_store_id
left join ph_staging.sys_manage_piece smp on smp.id = s2.manage_piece
left join ph_staging.sys_manage_region smr on smr.id = s2.manage_region
left join ph_staging.sys_province sp2 on sp2.code = s2.province_code
left join ph_staging.sys_city sc2 on sc2.code = s2.city_code
left join ph_staging.sys_district sd2 on sd2.code = s2.district_code

left join ph_staging.ka_profile kp on kp.id = a1.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = a1.client_id
left join
    (
        select
            di.pno
            ,count(di.id) di_cnt
        from ph_staging.diff_info di
        join t t1 on t1.pno = di.pno
        where
            di.created_at > date_sub(curdate(), interval 2 month)
            and di.created_at <= t1.created_at
            and di.diff_marker_category = 31
        group by 1
    ) di on di.pno = a1.pno
left join
    (
        select
            pssn.store_id
            ,pssn.pno
            ,row_number() over (partition by pssn.pno order by pssn.first_valid_routed_at desc) rk
        from dw_dmd.parcel_store_stage_new pssn
        join t t1 on t1.pno = pssn.pno
        where
            pssn.created_at > date_sub(curdate(), interval 2 month)
            and pssn.valid_store_order is not null
    ) ps on ps.pno = a1.pno and ps.rk = 1
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = ps.store_id and dp.stat_date =date_sub(curdate(), interval 1 day)