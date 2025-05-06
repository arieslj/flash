select
    a.pno 单号
    ,a.whole_end_date 丢失时效
    ,a.client_id 客户ID
    ,a.client 客户名称
    ,case a.state
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
    ,a.updated_at 多次联系不到客户的时间
from
    (
        select
            a1.*
            ,vrv.type
            ,vrv.created_at
            ,vrv.extra_value
            ,vrv.visit_state
            ,vrv.updated_at
            ,pi.state
            ,row_number() over (partition by a1.pno order by vrv.created_at desc) rk
        from
            (
                select
                    la.pno
                    ,la.whole_end_date
                    ,la.client_id
                    ,'lazada' client
                from dwm.dwd_ex_th_lazada_sla_detail la
                where
                    la.returned = 0
                    and la.parcel_state in (1,2,3,4,6)
                    and la.whole_end_date > curdate()

                union all

                select
                    sp.pno
                    ,sp.oversla whole_end_date
                    ,sp.client_id
                    ,'shopee' client
                from dwm.dwd_ex_th_shopee_pno_period sp
                join fle_staging.parcel_info pi on pi.pno = sp.pno
                where
                    sp.returned = 0
                    and pi.state in (1,2,3,4,6)
                    and sp.oversla > curdate()

                union all

                select
                    tt.pno
                    ,tt.end_7_date whole_end_date
                    ,tt.client_id
                    ,'tiktok' client
                from dwm.dwd_ex_th_tiktok_sla_detail tt
                where
                    tt.is_return = '正向件'
                    and tt.end_7_date > curdate()
                    and tt.parcel_state in ('已揽收', '运输中', '已滞留', '派送中', '疑难件处理中')
            ) a1
        left join fle_staging.parcel_info pi on pi.pno = a1.pno
        join nl_production.violation_return_visit vrv on vrv.link_id = a1.pno
        where
        #     vrv.type = 3
        #     and json_extract(vrv.extra_value, '$.diff_id') is not null
        #     and vrv.visit_state = 3
            pi.state in (1,2,3,4,6)
    ) a
where
    a.rk = 1
    and a.type = 3
    and json_extract(a.extra_value, '$.diff_id') is not null
    and a.visit_state = 3
