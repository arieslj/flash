select
    t.pno
    ,if(pi.returned = 1, pi2.pno, pi.pno) 正向单号
    ,if(pi.returned = 1, pi.pno, null) 退件单号
    ,if(pi.returned = 1, ss3.name, ss.name)  正向单号揽件网点
    ,if(pi.returned = 1, ss4.name, ss2.name ) 正向单号派件网点
    ,if(pi.returned = 1, pi2.cod_amount/100, pi.cod_amount/100) COD
    ,plt.SS责任网点
    ,plt.套餐
from tmpale.tmp_ph_pno_1204_lj t
left join ph_staging.parcel_info pi on t.pno = pi.pno
left join  ph_staging.parcel_info pi2 on pi2.pno = pi.customary_pno
left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
left join ph_staging.sys_store ss2 on ss2.id = pi.ticket_delivery_store_id

left join ph_staging.sys_store ss3 on ss3.id = pi2.ticket_pickup_store_id
left join ph_staging.sys_store ss4 on ss4.id = pi2.ticket_delivery_store_id
left join
    (
        select
            plt.pno
            ,case plt.duty_type
                when 1 then '快递员100%套餐'
                when 2 then '仓7主3套餐(仓管70%主管30%)'
                when 4 then '双黄套餐(A网点仓管40%主管10%B网点仓管40%主管10%)'
                when 5 then  '快递员721套餐(快递员70%仓管20%主管10%)'
                when 6 then  '仓管721套餐(仓管70%快递员20%主管10%)'
                when 8 then  'LH全责（LH100%）'
                when 7 then  '其他(仅勾选“该运单的责任人需要特殊处理”时才能使用该项)'
                when 21 then  '仓7主3套餐(仓管70%主管30%)'
            end 套餐
            ,group_concat(distinct ss.name) SS责任网点
        from ph_bi.parcel_lose_task plt
        join tmpale.tmp_ph_pno_1204_lj t on t.pno = plt.pno
        left join ph_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
        left join ph_staging.sys_store ss on ss.id = plr.store_id
        where
            plt.penalties > 0
            and plt.state = 6
        group by 1,2
    ) plt on plt.pno = t.pno

;