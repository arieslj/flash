
with t as
    (
        select
            a.*
        from
            (
                select
                    distinct
                    pi.pno
                    ,case
                        when bc.`client_id` is not null then bc.client_name
                        when kp.id is not null and bc.client_id is null then '普通ka'
                        when kp.`id` is null then '小c'
                    end client_type
                    ,pi.client_id
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
                    end parcel_state
                    ,pi.exhibition_weight
                    ,concat_ws('*', pi.exhibition_length, pi.exhibition_width, pi.exhibition_height) size
                    ,oi.weight order_weight
                    ,concat_ws('*', oi.length, oi.width, oi.height) order_size
                from ph_staging.parcel_info pi
                left join ph_staging.order_info oi on oi.pno = pi.pno
                left join ph_staging.ka_profile kp on kp.id = pi.client_id
                left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
                join dwm.drds_ph_parcel_weight_revise_record_d dp on dp.pno = pi.pno
                where
                    pi.created_at > date_sub('${sdate}', interval 8 hour)
                    and pi.created_at < date_add('${edate}', interval 16 hour)
                    and pi.returned = 0
                    and pi.state in (1,2,3,4,6)
                    and pi.client_id = '${client}'
            ) a
        where
            1 = 1
    )
select
    t1.pno
    ,t1.client_type
    ,t1.client_id
    ,t1.cod
    ,t1.parcel_state
    ,pr.store_name
    ,t1.exhibition_weight
    ,t1.size
    ,t1.order_weight
    ,t1.order_size
from t t1
left join
    (
        select
            pr.pno
            ,pr.store_name
            ,row_number() over (partition by pr.pno order by pr.first_valid_routed_at desc) rk
        from dw_dmd.parcel_store_stage_new pr
        join t t1 on t1.pno = pr.pno
        where
            pr.first_valid_routed_at > date_sub('${sdate}', interval 8 hour)
            and pr.valid_store_order is not null
    ) pr on pr.pno = t1.pno and pr.rk = 1
order by rand()
limit 100


;


select
    ps.pno
    ,pi.client_id
    ,pi.created_at
from dwm.drds_ph_parcel_weight_revise_record_d ps
join ph_staging.parcel_info pi on pi.pno = ps.pno
where
    pi.state in (1,2,3,4,6)
    and pi.created_at > '2024-09-01'