with t as
    (
        select
            distinct
            pi.pno
            ,pi.client_id
            ,case
                when bc.`client_id` is not null then bc.client_name
                when kp.id is not null and bc.client_id is null then '普通ka'
                when kp.`id` is null then '小c'
            end as  ka_type
            ,pi.src_name
            ,convert_tz(pi.created_at, '+00:00', '+07:00') pick_time
        from fle_staging.parcel_info pi
        join bi_pro.parcel_lose_task plt2 on plt2.pno = pi.pno
        left join fle_staging.ka_profile kp on kp.id = pi.client_id
        left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id
        where
            1 = 1
            and ${if(len(pno)>0," pi.pno in ('"+pno+"')",1=1)}
            and ${if(len(sec_name)>0," pi.sec_name in ('"+sec_name+"')",1=1)}
            and pi.created_at > date_sub(curdate(), interval 3 month)
            and plt2.state = 6
            and plt2.duty_result = 2
    )

select
    *
from t t1
left join
    (
        select
            t1.src_name

            ,count(distinct if(pi.created_at < date_sub(date_format(curdate() - interval 1 month, '%Y-%m-01'), interval 7 hour), pi.pno, null)) t_2_count
            ,count(distinct if(pi.created_at < date_sub(date_format(curdate() - interval 1 month, '%Y-%m-01'), interval 7 hour) and plt.id is not null, pi.pno, null)) / count(distinct if(pi.created_at < date_sub(date_format(curdate() - interval 1 month, '%Y-%m-01'), interval 7 hour), pi.pno, null))  t_2_count_danage_rate

            ,count(distinct if(pi.created_at < date_sub(date_format(curdate(), '%Y-%m-01'), interval 7 hour) and pi.created_at >= date_sub(date_format(curdate() - interval 1 month, '%Y-%m-01'), interval 7 hour), pi.pno, null)) t_1_count
            ,count(distinct if(pi.created_at < date_sub(date_format(curdate(), '%Y-%m-01'), interval 7 hour) and pi.created_at >= date_sub(date_format(curdate() - interval 1 month, '%Y-%m-01'), interval 7 hour) and plt.id is not null, pi.pno, null)) / count(distinct if(pi.created_at < date_sub(date_format(curdate(), '%Y-%m-01'), interval 7 hour) and pi.created_at >= date_sub(date_format(curdate() - interval 1 month, '%Y-%m-01'), interval 7 hour), pi.pno, null)) t_1_count_danage_rate

            ,count(distinct if(pi.created_at >= date_sub(date_format(curdate(), '%Y-%m-01'), interval 7 hour) , pi.pno, null)) t_0_count
            ,count(distinct if(pi.created_at >= date_sub(date_format(curdate(), '%Y-%m-01'), interval 7 hour) and plt.id is not null, pi.pno, null)) / count(distinct if(pi.created_at >= date_sub(date_format(curdate(), '%Y-%m-01'), interval 7 hour), pi.pno, null)) t_0_count_danage_rate
        from fle_staging.parcel_info pi
        join t t1 on t1.src_name = pi.src_name
        left join bi_pro.parcel_lose_task plt on plt.pno = pi.pno and plt.source in (4,6) and plt.state = 6 and plt.duty_result = 2 and plt.remark regexp '客户原因'
        where
            pi.created_at > date_sub(date_format(curdate() - interval 2 month, '%Y-%m-01'), interval 7 hour)
            and pi.returned = 0
            and pi.state < 9
        group by t1.src_name
    ) p2 on p2.src_name = t1.src_name


;


insert into dwm.dim_importExcelDB values ('tmp_th_w_ehs_phone','tmp_th_w_ehs_phone','21')