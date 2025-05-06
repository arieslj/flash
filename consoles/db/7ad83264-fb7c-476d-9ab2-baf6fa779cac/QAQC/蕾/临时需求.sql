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

select
    pi.pno
    ,pi2.pno 退件单号
    ,case pi2.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
from ph_staging.parcel_info pi
left join ph_staging.parcel_info pi2 on pi2.pno = pi.returned_pno
where
    pi.pno in ('P66023KHH5DAB','P66023KPKPAAB','P66023KHFGYAB','P66023KHFHBAB','P66023KHH4PAB','P66023KHH47AB','P66023KPKWNAB','P66023KHH51AB','P66023KPKP4AB','P66023KPKJZAB','P66023KHFGNAB','P66023KHJQ4AB','P66023KHH5FAB','P66023KPKJXAB','P66023KPKP8AB','P66023KHH5BAB','P66023KHFH5AB','P66023KHFGQAB','P66023KPKPBAB','P66023KHFGDAB','P66023KHH5EAB','P66023KPKP5AB','P66023KHFHGAB','P66023KHJQFAB','P66023KHFHNAB','P66023KHH53AB','P66023KHH59AB','P66023KHFGKAB','P66023KHH4UAB','P66023KHH4WAB','P66023KHJQ8AB','P66023KHH50AB','P66023KHFGMAB','P66023KHH4FAB','P66023KPKK4AB','P66023KPKPCAB','P66023KHH4KAB','P66023KPKK5AB','P66023KHFH7AB','P66023KPKNZAB','P66023KHH5HAB','P66023KHH57AB','P66023KHFH2AB','P66023KPKWKAB','P66023KHH49AB','P66023KHFHKAB','P66023KHH4RAB','P66023KHJQ5AB','P66023KHFGRAB','P66023KHH4SAB','P66023KHFH9AB','P66023KHJQAAB','P66023KHFH8AB','P66023KHH5GAB','P66023KHFH0AB','P66023KPKP3AB','P66023KPKP7AB','P66023KHH48AB','P66023KHH52AB','P66023KHH4CAB','P66023KPKWPAB','P66023KHFGJAB','P66023KHJQDAB','P66023KHFGGAB','P66023KHH4BAB','P66023KHH4DAB','P66023KHH56AB','P66023KPKK2AB','P66023KPKJYAB','P66023KHFHJAB','P66023KHH4EAB','P66023KPKK1AB','P66023KHFGEAB','P66023KHH5CAB','P66023KHFGBAB','P66023KHFGSAB','P66023KHH4GAB','P66023KHJQ6AB','P66023KPKP9AB','P66023KHH4JAB','P66023KHJQEAB','P66023KPKK3AB','P66023KHH4MAB','P66023KHH4NAB','P66023KHJQCAB','P66023KHFHCAB','P66023KHFGTAB','P66023KHH4ZAB','P66023KHFGZAB','P66023KHFHAAB','P66023KPKPEAB','P66023KPKWMAB','P66023KHFH4AB','P66023KHFGPAB','P66023KPKK0AB','P66023KHFGWAB','P66023KHH4VAB','P66023KHH4XAB','P66023KHFGUAB','P66023KHFH1AB','P66023KHFGHAB','P66023KPKW8AB','P66023KHJQ7AB','P66023KHFGVAB','P66023KHFGCAB','P66023KHFH3AB','P66023KHH4TAB','P66023KHH58AB','P66023KPKWJAB','P66023KHH4AAB','P66023KHH4QAB')
;


select
    pi.pno
    ,pi.cod_amount/100 cod
    ,pi.src_name
    ,convert_tz(pi.created_at, '+00:00', '+08:00')
    ,dst_ss.name
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
    end as 包裹状态
    ,case pi2.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 退件包裹状态
from ph_staging.parcel_info pi
left join ph_staging.sys_store dst_ss on dst_ss.id = pi.dst_store_id
left join ph_staging.parcel_info pi2 on pi2.pno = pi.returned_pno
where
    pi.created_at > '2023-12-31 16:00:00'
    and pi.src_phone in ('09274286755', '09274640291', '09156743971')


;


select
    pi.ticket_pickup_staff_info_id staff
    ,pi.pno
    ,pi.cod_amount/100 cod
    ,ss.name 目的地网点
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
    end as 包裹状态
from ph_staging.parcel_info pi
join ph_bi.parcel_lose_task plt on plt.pno = pi.pno
left join ph_staging.customer_issue ci on ci.id = plt.source_id
left join ph_staging.sys_store ss on ss.id = pi.dst_store_id
where
    pi.ticket_pickup_staff_info_id in (180562, 181116)
    and pi.created_at > '2024-01-31 16:00:00'
    and ci.id is not null


;

select
    pr.pno
    ,pr.staff_info_id 操作人员
    ,pr.store_name 网点
    ,pr.route_action 路由动作En
    ,ddd.CN_element 路由动作Cn
    ,convert_tz(pr.routed_at, '+00:00', '+08:00')  操作时间
#     ,pi.exhibition_weight/1000 重量
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
        ELSE '其他'
	end as '包裹状态'
from ph_staging.parcel_route pr
left join ph_staging.parcel_info pi on pi.pno = pr.pno
left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
where
    pr.staff_info_id = '609153'
    and pr.routed_at >= '2025-02-09 16:00:00'
    and pr.routed_at <= '2025-02-10 16:00:00'


;

;
select
    pcol.*
from ph_bi.parcel_lose_task plt
left join ph_bi.parcel_cs_operation_log pcol on pcol.task_id = plt.id
where
    plt.penalties > 0
    and plt.pno = 'P61184AKTA0CR'

;



with t as
  (
    select
      plt.id
      ,plt.pno
      ,pcol.action act
      ,pcol.created_at
      ,plt.duty_reasons
      ,pcol.remark
    from `ph_bi`.`parcel_lose_task` plt
    join `dwm`.`dwd_dim_bigClient` bc on bc.`client_id` = plt.`client_id`
    left join `ph_bi`.`parcel_cs_operation_log` pcol on pcol.`task_id` = plt.id
    where
      plt.`state` =  5
      and plt.`duty_result` = 1
      and bc.`client_name` = 'shein'
      and plt.`created_at` > '2023-06-01'
      and plt.`penalties` > 0
  )
select
  a.pno 单号
  ,c.created_at 第一次判责丢失时间
  ,b.created_at 改无责时间
  ,b.remark
    ,t.t_value 原因
from
  (
    select
      t1.*
    from t t1
    where
      t1.act = 4
      and t1.created_at > '2024-01-01'
  ) a
left join
  (
    select
      t1.*
      ,row_number() over (partition  by t1.id order by t1.created_at) rk
    from t t1
    where
      t1.act = 3
      and t1.created_at > '2024-01-01'
  ) b on b.id = a.id and b.rk = 1
left join
  (
    select
      t1.*
      ,row_number() over (partition by t1.id order by t1.created_at) rk
    from t t1
    where
      t1.act = 4
      and t1.created_at > '2024-01-01'
  ) c on c.id = a.id and c.rk = 1
left join ph_bi.`translations` t on a.duty_reasons = t.t_key AND t.`lang` = 'zh-CN'

;


select
    oi.pno
    ,case oi.state
        when 0	then'已确认'
        when 1	then'待揽件'
        when 2	then'已揽收'
        when 3	then'已取消(已终止)'
        when 4	then'已删除(已作废)'
        when 5	then'预下单'
        when 6	then'被标记多次，限制揽收'
    end as 订单状态
    ,ss.name 目的地网点
from ph_staging.order_info oi
left join ph_staging.sys_store ss on ss.id = oi.dst_store_id
where
    oi.pno in ('PH2450109665213','PH240446693264Y','PH246030789876F','PH2474089469510','PH2427998366621','PH249168667047Q','PH241820849032Q','PH245516365083D','PH246606767614J','PH2401645230664','PH245229844540V','PH249815974276P','PH245487559536Z','PH247261289899Y','PH240787675287U','PH240780259755N','PH246370076541G','PH240985117796O','PH245476809651S','PH242299133769F','PH244295705221U','PH241267687079P','PH240686332442O','PH245032294276O','PH245725728727O','PH2428528071803','PH240787966355G','PH245856112210W','PH240508065384W','PH240533853344O','PH2470699650822','PH248840314075H')
