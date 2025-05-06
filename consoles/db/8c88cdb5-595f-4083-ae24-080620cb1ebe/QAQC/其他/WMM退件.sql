with t as
    (
        select
            pi.pno
            ,pi.state
            ,pi.created_at
            ,pi.client_id
            ,pi.ticket_pickup_store_id
            ,pi2.cod_amount/100 cod
        from fle_staging.parcel_info pi
        left join fle_staging.parcel_info pi2 on pi2.returned_pno = pi.pno
        where
            pi.returned = 1
            and pi.created_at > date_sub(curdate(),interval 8 day)
          --   and pi.ticket_pickup_store_id = 'TH10120300'
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
    end 包裹状态
    ,convert_tz(t1.created_at, '+00:00', '+07:00') '揽收时间'
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as 客户类型
    ,t1.cod
    ,t2.next_store_name 下一网点
    ,if(di.pno is  not null, '是', '否') 是否上报破损
    ,case plt.duty_result
        when 1 then '丢失'
        when 2 then '破损'
        when 3 then '超时效'
    end 判责类型
from t t1
left join
    (
        select
            pr.pno
            ,pr.next_store_name
        from rot_pro.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
            and pr.store_id = t1.ticket_pickup_store_id
    ) t2 on t2.pno = t1.pno
left join
    (
        select
            di.pno
        from fle_staging.diff_info di
        join t t1 on t1.pno = di.pno
        where
            di.diff_marker_category in (5,20)
        group by 1
    ) di on di.pno = t1.pno
left join
    (
        select
            plt.pno
            ,plt.duty_result
        from bi_pro.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
       -- left join bi_pro.translations t3 on t3.t_key = plt.duty_reasons and t3.lang ='zh-CN'
        where
            plt.state = 6
            and plt.penalties > 0
        group by 1,2
    ) plt on plt.pno = t1.pno
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = t1.client_id
left join fle_staging.ka_profile kp on kp.id = t1.client_id