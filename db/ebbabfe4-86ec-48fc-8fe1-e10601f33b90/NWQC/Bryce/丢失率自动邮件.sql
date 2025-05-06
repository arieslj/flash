with t as
    (
        select
            pi2.pno
            ,plt.client_id
            ,pi2.src_name
        from my_bi.parcel_lose_task plt
        left join my_staging.parcel_info pi on pi.pno = plt.pno and pi.created_at >= date_sub(curdate(), interval 1 month )
        left join my_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
        where
            plt.state = 6
            and plt.duty_result = 1
            and plt.parcel_created_at >= date_sub(curdate(), interval 1 month )
            and pi.returned = 0
            and pi2.src_name = 'GG-Andy'
        group by 1
    )
select
    t2.src_name 寄件人
     ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end 客户名称
    ,count(distinct pi.pno) 近一月单量
    ,count(distinct if(t1.pno is not null, pi.pno,null)) 近一月丢失量
    ,count(distinct if(t1.pno is not null, pi.pno,null)) / count(distinct pi.pno) 近一月丢失率
from my_staging.parcel_info pi
join
    (
        select
            t1.src_name
        from t t1
        group by 1
    ) t2 on t2.src_name = pi.src_name
left join t t1 on t1.pno = pi.pno
left join my_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.tmp_ex_big_clients_id_detail  bc on bc.client_id = pi.client_id
where
    pi.returned = 0
group by 1,2

;

with t as
    (
        select
            plt.pno
            ,plt.id
            ,plt.updated_at
            ,pi2.src_name
            ,plt.duty_type
            ,plt.client_id
            ,pi.returned
        from my_bi.parcel_lose_task plt
        left join my_staging.parcel_info pi on pi.pno = plt.pno and pi.created_at >= date_sub(curdate(), interval 1 month )
        left join my_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
        where
            plt.parcel_created_at >= date_sub(curdate(), interval 1 month )
            and plt.state = 6
            and plt.duty_result = 1
            and pi2.src_name = 'GG-Andy'
    )
select
    t1.pno  丢失单号
    ,if(t1.returned = 1, '退件', '正向' ) 包裹流向
    ,date_format(t1.updated_at, '%Y-%m-%d %H:%i:%s') 判责时间
    ,t1.src_name 寄件人
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end 客户名称
    ,ss.name 判责单位
    ,case t1.duty_type
        when 1 then '快递员100%套餐'
        when 2 then '仓9主1套餐(仓管90%主管10%)'
        when 3 then '仓9主1套餐(仓管90%主管10%)'
        when 4 then '双黄套餐(A网点仓管40%主管10%B网点仓管40%主管10%)'
        when 5 then '快递员721套餐(快递员70%仓管20%主管10%)'
        when 6 then '仓管721套餐(仓管70%快递员20%主管10%)'
        when 8 then 'LH全责（LH100%）'
        when 7 then '其他(仅勾选“该运单的责任人需要特殊处理”时才能使用该项)'
        when 9 then '加盟商套餐'
        when 10 then '双黄套餐(计数网点仓管40%计数网点主管10%对接分拨仓管40%对接分拨主管10%)'
        when 19 then '双黄套餐(计数网点仓管40%计数网点主管10%对接分拨仓管40%对接分拨主管10%)'
        when 20 then  '加盟商双黄套餐（加盟商50%网点仓管45%主管5%）'
    end 套餐
    ,smr.name 大区
    ,plr.staff_id 责任人
from  t t1
left join my_bi.parcel_lose_responsible plr on t1.id = plr.lose_task_id
left join my_staging.sys_store ss on ss.id = plr.store_id
left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
left join my_staging.ka_profile kp on kp.id = t1.client_id
left join dwm.tmp_ex_big_clients_id_detail  bc on bc.client_id = t1.client_id

