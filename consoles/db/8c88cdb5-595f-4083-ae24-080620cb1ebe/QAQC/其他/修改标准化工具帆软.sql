-- 面单粘贴不规范/多面单/未换单
with pr as
(
    select
        pr.pno
        ,convert_tz(pr.routed_at,'+00:00','+07:00') routed_at
        ,route_action
        ,pr.store_name
        ,pr.staff_info_id
        ,row_number()over(partition by pr.pno,pr.route_action order by pr.routed_at) rn
    from rot_pro.parcel_route pr
    where pr.routed_at>=date_sub(current_date,interval 31 day)
    and pr.route_action in('PRINTING')
),
ss as
(
    select
        ss.id
        ,ss.name
    from fle_staging.sys_store ss
)




select
    pi.pno
    ,pi.client_id
    ,case
            when bc.`client_id` is not null then bc.client_name
            when kp.id is not null and bc.id is null then '普通ka'
            when kp.`id` is null then '小c'
    end as  客户类型
    ,pi.cod_amount/100 cod金额
    ,ss1.name 目的地网点
    ,ss2.name 揽收网点
    ,convert_tz(pi.created_at,'+00:00','+07:00') created_at
    ,concat(pi.src_name,' (',pi.src_phone,') ',pi.src_detail_address) 发件人信息
    ,concat(pi.dst_name,' (',pi.dst_phone,') ',pi.dst_detail_address) 收件人信息
    ,pr1.routed_at 第一次打印面单时间
    ,pr1.store_name 第一次打印面单网点
    ,pr1.staff_info_id 第一次打印面单员工ID
    ,pr2.routed_at 第二次打印面单时间
    ,pr2.store_name 第二次打印面单网点
    ,pr2.staff_info_id 第二次打印面单员工ID
    ,pr3.routed_at 最后一次打印面单时间
    ,pr3.store_name 最后一次打印面单网点
    ,pr3.staff_info_id 最后一次打印面单员工ID
    ,convert_tz(pi.finished_at,'+00:00','+07:00') 妥投时间
    ,ss3.name 妥投网点
    ,pi.ticket_delivery_staff_info_id 妥投员工ID
    ,pr4.routed_at
    ,pr4.staff_info_id
    ,pr4.store_name
    ,pr5.routed_at 最后一次换单时间
    ,pr5.store_name 最后一次换单网点
    ,pr5.staff_info_id 最后一次换单员工ID
from fle_staging.parcel_info pi
left join dwm.tmp_ex_big_clients_id_detail bc on pi.client_id=bc.client_id
left join fle_staging.ka_profile kp on pi.client_id=kp.id
left join ss ss1 on ss1.id=pi.dst_store_id
left join ss ss2 on ss2.id=pi.ticket_pickup_store_id
left join ss ss3 on ss3.id=pi.ticket_delivery_store_id
left join pr pr1 on pi.pno=pr1.pno and pr1.rn=1
left join pr pr2 on pi.pno=pr2.pno and pr2.rn=2
left join
(
    select pr.*
    from
    (
        select
            pr.pno
            ,convert_tz(pr.routed_at,'+00:00','+07:00') routed_at
            ,route_action
            ,pr.store_name
            ,pr.staff_info_id
            ,row_number()over(partition by pr.pno,pr.route_action order by pr.routed_at desc) rn
        from rot_pro.parcel_route pr
        where pr.routed_at>=date_sub(current_date,interval 31 day)
        and pr.route_action in('PRINTING')
    )pr where pr.rn=1
)pr3 on pi.pno=pr3.pno
left join
    (
        select
            pr.pno
            ,convert_tz(pr.routed_at,'+00:00','+07:00') routed_at
            ,route_action
            ,pr.store_name
            ,pr.staff_info_id
            ,row_number()over(partition by pr.pno order by pr.routed_at) rn
        from rot_pro.parcel_route pr
        where pr.routed_at>=date_sub(current_date,interval 31 day)
        and pr.route_action in('REPLACE_PNO')
        and pr.pno in('${SUBSTITUTE(SUBSTITUTE(p3,"\n",","),",","','")}')
    )pr4 on pr4.pno=pi.pno and pr4.rn=1
left join
    (
        select
            pr.pno
            ,convert_tz(pr.routed_at,'+00:00','+07:00') routed_at
            ,route_action
            ,pr.store_name
            ,pr.staff_info_id
            ,row_number()over(partition by pr.pno order by pr.routed_at desc) rn
        from rot_pro.parcel_route pr
        where pr.routed_at>=date_sub(current_date,interval 31 day)
        and pr.route_action in('REPLACE_PNO')
        and pr.pno in('${SUBSTITUTE(SUBSTITUTE(p3,"\n",","),",","','")}')
    )pr5 on pr5.pno=pi.pno and pr5.rn=1


where pi.created_at>=date_sub(current_date,interval 31 day)
and pi.pno in('${SUBSTITUTE(SUBSTITUTE(p3,"\n",","),",","','")}')
group by 1
limit 5000;