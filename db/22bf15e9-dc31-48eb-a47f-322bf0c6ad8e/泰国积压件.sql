-- 3月后揽收非问题件

with t as
(
    select
        pi.pno
        ,pi.returned
        ,pi.client_id
        ,convert_tz(pi.created_at, '+00:00', '+07:00') pick_date
        ,pi.state
        ,pi.agent_id
        ,pi.ticket_pickup_store_id
        ,pi.dst_store_id
    from fle_staging.parcel_info pi
#     left join dwm.dwd_ex_th_parcel_details detpd
    where
        pi.created_at > '2023-02-28 17:00:00'
        and pi.created_at < '2023-06-04 17:00:00'
        and pi.state not in (5,6,7,8,9)
)
select
    t1.pno
    ,t1.pick_date 揽收日期
    ,if(t1.returned = 1, '退件', '正向') 包裹类型
    ,t1.client_id 客户ID
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as 客户类型
    ,datediff(curdate(), t1.pick_date) 揽收至今滞留天数
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
    end as 包裹状态
    ,pr.store_name 当前滞留网点
    ,case pr.store_category
      when '1' then 'SP'
      when '2' then 'DC'
      when '4' then 'SHOP'
      when '5' then 'SHOP'
      when '6' then 'FH'
      when '7' then 'SHOP'
      when '8' then 'Hub'
      when '9' then 'Onsite'
      when '10' then 'BDC'
      when '11' then 'fulfillment'
      when '12' then 'B-HUB'
      when '13' then 'CDC'
      when '14' then 'PDC'
    end `当前网点类型`
    ,pr.CN_element 最新有效路由
    ,convert_tz(pr.routed_at, '+00:00', '+07:00')  最后有效路由时间
    ,datediff(curdate(),convert_tz(pr.routed_at, '+00:00', '+07:00')) 最后有效路由至今日期
    ,di.CN_element 问题件类型
    ,convert_tz(di.created_at, '+00:00', '+07:00') 最后一条问题件创建时间
    ,datediff(now(),convert_tz(di.created_at, '+00:00', '+07:00')) 问题件处理天数
    ,ppd.CN_element 最后一个留仓原因
    ,ss.name 揽收网点
    ,ss2.name 目的地网点
    ,cg.name 'KAM-VIP客服组'
    ,case
        when pr.store_category in (8,12) then 'HUB'
        when pr.store_category in (4,5,7) then 'SHOP'
        when pr.store_category in (1,10,14) then 'NW'
        when pr.store_category in (6) then 'FH'
    end 待处理部门
    ,CASE
          WHEN kp.id ='AA0622' THEN 'PMD-shein'
          WHEN if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '20001' THEN 'FFM'
          WHEN if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '388' AND if(kp.`account_type_category` = '3',kp.`agent_id`, kp.`id`) = 'BF5633' THEN 'KAM'
          WHEN if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '388' THEN 'KAM'
          WHEN if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '4' THEN 'retail-Network'
          WHEN if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '34' THEN 'retail-Bulky'
          WHEN if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '40' THEN 'retail-Sales'
          WHEN if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '13' and hs.`node_department_id` IN ('1098','1099','1100','1101') THEN 'retail-Sales'
          WHEN if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '13' THEN 'retail-shop'
          WHEN if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '3' THEN 'Customer Service'
          WHEN if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '545' THEN 'Bulky Business Development'
          when kp3.`agent_category`= '3'  AND kp3.department_id= '388' and kp.id is null THEN 'KAM'
          WHEN ss.`category` = '1' and kp.id is null THEN 'retail-Network-c'
          WHEN ss.`category` in ('10','13') and kp.id is null THEN 'retail-Bulky-c'
          WHEN ss.`category` = '6'  and kp.id is null THEN 'FH'
          WHEN ss.`category` IN ('4','5','7') and kp.id is null THEN 'retail-shop-c'
          when ss.`category` in ('11') and kp.id is null THEN 'FFM'
          else 'Other'
      end as '归属部门'
from t t1
left join
     (
         select
             pr.pno
            ,pr.store_id
            ,pr.store_name
            ,pr.store_category
            ,ddd.CN_element
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk

         from rot_pro.parcel_route pr
         join t t1 on t1.pno = pr.pno
         join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'rot_pro' and ddd.tablename = 'parcel_route' and ddd.remark = 'valid'
     ) pr on pr.pno = t1.pno and pr.rk = 1
left join
     (
         select
             di.pno
            ,di.diff_marker_category
            ,ddd.CN_element
            ,di.created_at
            ,row_number() over (partition by di.pno order by di.created_at desc ) rk
         from fle_staging.diff_info di
         join t t1 on t1.pno = di.pno
         left join dwm.dwd_dim_dict ddd on di.diff_marker_category = ddd.element and ddd.db = 'fle_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
         where
             di.state = 0
     ) di on di.pno = t1.pno and di.rk = 1
left join
     (
         select
             ppd.pno
            ,ppd.diff_marker_category
            ,ddd.CN_element
            ,row_number() over (partition by ppd.pno order by ppd.created_at desc ) rk
         from fle_staging.parcel_problem_detail ppd
         join t t1 on t1.pno = ppd.pno
         left join dwm.dwd_dim_dict ddd on ppd.diff_marker_category = ddd.element and ddd.db = 'fle_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
         where
             ppd.parcel_problem_type_category = 2
     ) ppd on ppd.pno = t1.pno and ppd.rk = 1
left join fle_staging.sys_store ss on ss.id = t1.ticket_pickup_store_id
left join fle_staging.sys_store ss2 on ss2.id = t1.dst_store_id
left join fle_staging.ka_profile  AS kp on kp.id = t1.client_id
left join fle_staging.ka_profile as kp2 on  kp.`agent_id` = kp2.`id` and (kp2.`agent_category` <>'3' or kp2.`agent_category` is null)
left join fle_staging.ka_profile kp3 on t1.`agent_id`  = kp3.`id`
left join bi_pro.hr_staff_info AS hs on kp.`staff_info_id` = hs.`staff_info_id` AND hs.`node_department_id` IN ('1098','1099','1100','1101')
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = t1.client_id
left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = t1.client_id
left join fle_staging.customer_group cg on cg.id = cgkr.customer_group_id
;


-- 问题件

with  a as
(
    select
        di.pno
        ,di.id
        ,ddd.CN_element
        ,convert_tz(di.created_at, '+00:00', '+07:00') di_time
        ,convert_tz(pi.created_at, '+00:00', '+07:00') pick_time
        ,pi.client_id
        ,ss2.name pick_store
    from fle_staging.diff_info di
    left join fle_staging.parcel_info pi on pi.pno = di.pno
    left join dwm.dwd_dim_dict ddd on di.diff_marker_category = ddd.element and ddd.db = 'fle_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
    left join fle_staging.sys_store ss2 on ss2.id = pi.ticket_pickup_store_id
    where
        di.state = 0
        and pi.created_at < '2023-06-04 17:00:00'
        and pi.state = 6
)
select
    t.pno
    ,t.pick_time 揽收时间
    ,t.di_time 疑难件提交时间
    ,datediff(now(), t.pick_time) 揽收至今天数
    ,pr.store_name 当前滞留网点
    ,case pr.store_category
      when '1' then 'SP'
      when '2' then 'DC'
      when '4' then 'SHOP'
      when '5' then 'SHOP'
      when '6' then 'FH'
      when '7' then 'SHOP'
      when '8' then 'Hub'
      when '9' then 'Onsite'
      when '10' then 'BDC'
      when '11' then 'fulfillment'
      when '12' then 'B-HUB'
      when '13' then 'CDC'
      when '14' then 'PDC'
    end `当前网点类型`
    ,t.CN_element 疑难原因
    ,datediff(now(), t.di_time) 问题件处理天数
    ,case sdt.pending_handle_category
        when 1 then '待揽收网点协商'
        when 2 then '待KAM问题件处理'
        when 3 then '待QAQC判责'
        when 4 then '待客户决定'
    end 待处理人
    ,case
        when sdt.pending_handle_category =  1 and ss.category = 6 then 'FH'
        when sdt.pending_handle_category =  1 and ss.category in (8,12) then 'HUB'
        when sdt.pending_handle_category =  1 and ss.category in (7,5,4) then 'SHOP'
        when sdt.pending_handle_category =  1 and ss.category in (1,10,14) then 'NW'
        when sdt.pending_handle_category =  2 then cg.name
        when sdt.pending_handle_category =  3 then 'QAQC'
        when sdt.pending_handle_category =  4 then 'Retail'
    end 待处理部门
    ,ss.name 待处理网点
    ,case ss.category
      when '1' then 'SP'
      when '2' then 'DC'
      when '4' then 'SHOP'
      when '5' then 'SHOP'
      when '6' then 'FH'
      when '7' then 'SHOP'
      when '8' then 'Hub'
      when '9' then 'Onsite'
      when '10' then 'BDC'
      when '11' then 'fulfillment'
      when '12' then 'B-HUB'
      when '13' then 'CDC'
      when '14' then 'PDC'
    end `待处理网点类型`
    ,t.client_id
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.id is null then '普通ka'
        when kp.`id` is null then '小c'
    end 客户类型
    ,cg.name 客服组
    ,case sdt.state
        when 0 then '处理中'
        when 1 then '未处理'
        when 2 then '已处理'
    end 处理状态
    ,datediff(now(), convert_tz(sdt.updated_at, '+00:00', '+07:00')) 当前状态至今天数
from a t
left join
     (
         select
             pr.pno
            ,pr.store_id
            ,pr.store_name
            ,pr.store_category
            ,ddd.CN_element
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
         from rot_pro.parcel_route pr
         join a t1 on t1.pno = pr.pno
         join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'rot_pro' and ddd.tablename = 'parcel_route' and ddd.remark = 'valid'
     ) pr on pr.pno = t.pno and pr.rk = 1
left join fle_staging.store_diff_ticket sdt on sdt.diff_info_id = t.id
left join fle_staging.customer_diff_ticket cdt on cdt.diff_info_id = t.id
left join fle_staging.ka_profile kp on t.client_id = kp.id
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = t.client_id
left join fle_staging.sys_store ss on ss.id = cdt.organization_id
left join fle_staging.customer_group cg on cg.id = cdt.group_id
