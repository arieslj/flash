select
--    pi.pickup_date
    pi.name DC
    ,pi.region_name region
    ,pi.piece_name piece
    ,sum(pi.pnt) 操作量
    ,sum(nvl(lt.pnt,0)) 丢失量
    ,(sum(nvl(lt.pnt,0))/sum(pi.pnt))*100000 丢失率_判责维度
from
    (
#         select
#             date(convert_tz(pr.routed_at,'+00:00','+08:00')) pickup_date
#             ,cast('HUB' as string) as kind
#             ,pr.store_name name
#             ,count(distinct pr.pno) pnt
#         from my_staging.parcel_route pr
#         where
#             pr.routed_at>=convert_tz('${sdate}','+08:00','+00:00')
#             and pr.routed_at<date_add(convert_tz('${edate}','+08:00','+00:00'),interval 1 day)
#             and pr.route_action='SHIPMENT_WAREHOUSE_SCAN'
#             and pr.store_name like '%HUB%'
#         group by 1,2,3

#         union all
#
#
#         select
#             pi.pickup_date
#             ,cast('FH' as string) as kind
#             ,pi.name
#             ,sum(pi.pnt+nvl(sd.sd_pnt,0)) pnt
#         from
#             (
#                 select
#                     date(convert_tz(pi.created_at,'+00:00','+08:00')) pickup_date
#                     ,sy.name
#                     ,count(distinct pi.pno) pnt
#                 from my_staging.parcel_info pi
#                 left join my_staging.sys_store sy on pi.ticket_pickup_store_id=sy.id
#                 where
#                     pi.returned=0
#                     and pi.state<9
#                     and pi.created_at>=convert_tz('${sdate}','+08:00','+00:00')
#                     and pi.created_at<date_add(convert_tz('${edate}','+08:00','+00:00'),interval 1 day)
#                     and sy.name like 'FH%'
#                 group by 1,2
#             )pi
#         left join
#             (
#                 select
#                     sd.stat_date
#                     ,sy.name
#                     ,count(distinct sd.pno) sd_pnt
#                 from dwm.dwd_my_dc_should_delivery_d sd
#                 left join my_staging.sys_store sy on sd.store_id=sy.id
#                 where
#                     sy.name like 'FH%'
#                     and sd.stat_date>='${sdate}'
#                 group by 1,2
#             )sd on pi.pickup_date=sd.stat_date and pi.name=sd.name
#         group by 1,2,3
#
#         union all
#
#
        select
            tmp.date pickup_date
            ,cast('SP' as string) as kind
            ,tmp.name
            ,dm.region_name
            ,dm.piece_name
            ,sum(coalesce(pi.pnt, 0) + coalesce(sd.sd_pnt,0)) pnt
        from
            (
                select
                    ss.name
                    ,om.date
                    ,ss.id
                from tmpale.ods_my_dim_date om
                cross join my_staging.sys_store ss
                where
                    om.date >= '${sdate}'
                    and om.date <= '${edate}'
                    and ss.category = 1 -- SP
                    and ss.name not like 'FH%'
                    and ss.name not like '%HUB%'
                    and ss.name not like 'OS%'
            ) tmp
        left join
            (
                select
                    date(convert_tz(pi.created_at,'+00:00','+08:00')) pickup_date
                    ,sy.name
                    ,count(distinct pi.pno) pnt
                from my_staging.parcel_info pi
                left join my_staging.sys_store sy on pi.ticket_pickup_store_id=sy.id
                where
                    pi.returned=0
                    and pi.state<9
                    and pi.created_at>=convert_tz('${sdate}','+08:00','+00:00')
                    and pi.created_at<date_add(convert_tz('${edate}','+08:00','+00:00'),interval 1 day)
                    and sy.name not like 'FH%'
                    and sy.name not like '%HUB%'
                    and sy.name <>'Autoqaqc'
                group by 1,2
            )pi on tmp.date = pi.pickup_date and tmp.name = pi.name
        left join
            (
                select
                    sd.stat_date
                    ,sy.name
                    ,count(distinct sd.pno) sd_pnt
                from dwm.dwd_my_dc_should_delivery_d sd
                left join my_staging.sys_store sy on sd.store_id=sy.id
                where
                    sy.name not like 'FH%'
                    and sy.name not like '%HUB%'
                    and sy.name <>'Autoqaqc'
                    and sd.stat_date>='${sdate}'
                group by 1,2
            )sd on tmp.date = sd.stat_date and tmp.name = sd.name
        left join dwm.dim_my_sys_store_rd dm on dm.store_id = tmp.id and dm.stat_date = date_sub(curdate(), interval 1 day)
        where
            pi.name is not null
            or sd.name is not null
        group by 1,2,3
#
#         union all
#
#
#         select
#             date(convert_tz(pc.`created_at`,'+00:00','+08:00')) pickup_date
#             ,cast('ONSITE' as string) as kind
#             ,ss.name
#             ,count(distinct pc.pno ) pnt
#             From my_staging.parcel_info pc
#         LEFT JOIN `my_staging`.sys_store ss on ss.id = pc.ticket_pickup_store_id
#         JOIN dwm.`tmp_ex_big_clients_id_detail` bi  on bi.`client_id` =pc.`client_id`
#         where
#             pc.created_at >=convert_tz('${sdate}','+08:00','+00:00')
#             and pc.created_at < date_add(convert_tz('${edate}','+08:00','+00:00'),interval 1 day)
#             and (ss.name like 'OS%' or ss.name='01 MS1_HUB Klang')
#             and bi.`client_id` in ('AA0006','AA0127','AA0056')
#         group by 1,2,3
#         order by 1,2,3

    )pi
# left join
#     (
#         select
#             case
#                 when ss.name like '%HUB%' then 'HUB'
#                 when ss.name like 'FH%' then 'FH'
#                 when ss.name like 'OS%' then 'ONSITE'
#                 else 'SP'
#             end as kind
#             ,date(plt.updated_at) updated_at
#             ,ss.name
#             ,sum(plr.duty_ratio/100) pnt
#         from
#             (
#                 select
#                     plt.*
#                 from
#                     (
#                         select
#                             plt.pno
#                             ,plt.created_at
#                             ,plt.updated_at
#                             ,plt.id
#                             ,row_number() over (partition by plt.pno order by plt.created_at) rk
#                         from my_bi.parcel_lose_task plt
#                         where
#                             plt.updated_at >= '${sdate}'
#                             and plt.state = 6
#                             and plt.duty_result = 1
#                             and plt.penalties > 0
#                     ) plt
#                 where
#                     plt.rk = 1
#             ) plt
#         join my_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
#         left join my_staging.sys_store ss on ss.id = plr.store_id
#         where
#             ss.name != 'Autoqaqc'
#         group by 1,2,3
#     ) lt on pi.pickup_date=lt.updated_at and pi.kind=lt.kind and pi.name=lt.name
left join
    (
        select
            prn.kind
            ,prn.name
            ,lt.updated_at
            ,sum(1/pr.dcs) pnt
        from
            (
                select
                    lt.pno
                    ,max(date(lt.updated_at)) updated_at
                from my_bi.parcel_lose_task lt
                where
                    lt.duty_result=1
                    and lt.state = 6
                    and lt.updated_at>='${sdate}'
                    and lt.penalties > 0
                --  and lt.updated_at<date_add('${edate}',interval 1 day)
                group by 1
            )lt
        join
            (
                SELECT
                    distinct
                    lt.pno
                    ,sy.name
                    ,case when sy.name like '%HUB%' then 'HUB'
                        when sy.name like 'FH%' then 'FH'
                        when sy.name like 'OS%' then 'ONSITE'
                        else 'SP'
                    end as kind
                from my_bi.parcel_lose_responsible pr
                left join my_bi.parcel_lose_task lt on pr.lose_task_id =lt.id
                left join my_staging.sys_store sy on pr.store_id=sy.id
                where pr.created_at >='${sdate}'
                    and lt.duty_result = 1
                and sy.name <>'Autoqaqc'
                -- and sy.name like '%HUB%'
            )prn on lt.pno=prn.pno
        left join
            (
                SELECT
                    lt.pno
                    ,count(distinct sy.name) dcs
                from my_bi.parcel_lose_responsible pr
                left join my_bi.parcel_lose_task lt on pr.lose_task_id =lt.id
                left join my_staging.sys_store sy on pr.store_id=sy.id
                where
                    pr.created_at >='${sdate}'
                    and lt.duty_result = 1
                    -- and sy.name like '%HUB%'
                group by 1
                order by 1
            )pr on lt.pno=pr.pno
        group by 1,2,3
        order by 1,2,3
    )lt on pi.pickup_date=lt.updated_at and pi.kind=lt.kind and pi.name=lt.name
group by 1,2,3
order by 1,2,3

;


with t as
    (
        select
            a.*
        from
            (
                select
                    pi.pno
                    ,pi.cod_amount
                    ,if(bc.client_name = 'lazada', pi.insure_declare_value, pai.cogs_amount) cogs
                    ,pai.cogs_amount
                    ,pi.client_id
                    ,bc.client_name
                from my_staging.parcel_info pi
                left join my_staging.parcel_additional_info pai on pai.pno = pi.pno
                left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id
                where
                    (pi.state in (1,2,3,4,6)
                    and pi.returned = 0
                    )
                    or (pi.client_id in ('AA0187','AA0188','AA0189','AA0181','AA0218') and pi.state not in (5,7,8,9))
            ) a
        where
            a.cod_amount > 30000 or a.client_id in ('AA0187','AA0188','AA0189','AA0181','AA0218','AA0211')
    )
select
    a.pno
    ,a.client_type 客户类型
    ,a.client_id 客户ID
    ,a.cogs/100 COGS
    ,a.cod_amount/100 COD
    ,a.cn_element 最后有效路由
    ,a.store_name 最后有效路由网点
    ,case a.store_category
          when 1 then 'SP'
          when 2 then 'DC'
          when 4 then 'SHOP'
          when 5 then 'SHOP'
          when 6 then 'FH'
          when 7 then 'SHOP'
          when 8 then 'Hub'
          when 9 then 'Onsite'
          when 10 then 'BDC'
          when 11 then 'fulfillment'
          when 12 then 'B-HUB'
          when 13 then 'CDC'
          when 14 then 'PDC'
    end 网点类型
    ,a.region_name 大区
    ,diff_hour - 8  最后路由状态停止时长
from
    (
        select
            t1.*
            ,case
                when t1.client_name is not null then t1.client_name
                when t1.client_name is null and kp.id is not null then '普通KA'
                when t1.client_name is null and kp.id is null then '小C'
            end client_type
            ,pr.cn_element
            ,pr.routed_at
            ,pr.store_category
            ,pr.store_name
            ,dm.region_name
            ,timestampdiff(hour, pr.routed_at, now()) diff_hour
        from t t1
        left join
            (
                select
                    pr.pno
                    ,pr.store_name
                    ,pr.store_id
                    ,pr.store_category
                    ,ddd.cn_element
                    ,pr.routed_at
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
                from my_staging.parcel_route pr
                join t t1 on t1.pno = pr.pno
                left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'my_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
                where
                    pr.routed_at > date_sub(curdate(), interval 2 month )
                    and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
            ) pr on pr.pno = t1.pno and pr.rk = 1
        left join my_staging.ka_profile kp on kp.id = t1.client_id
        left join dwm.dim_my_sys_store_rd dm on dm.store_id = pr.store_id and dm.stat_date = date_sub(curdate(), interval 1 day)
    ) a
where
    a.diff_hour >= 32
or a.client_id in ('AA0187','AA0188','AA0189','AA0181','AA0218','AA0211')

;


select
weekofyear(pi2.date) '揽收周'
,pi2.client_id '客户ID'
,case when pi2.client_id in ('AA0187','AA0188','AA0189') then 'VIVO'
when pi2.client_id in ('AA0181') then 'Skyworth'
when pi2.client_id in ('AA0218') then 'Xin Hwa Supply Chain'
when pi2.client_id='AA0211' then 'Louis Kaw'
end '客户类型'
,concat(min(pi2.date),'~',max(pi2.date)) '揽收日期区间'
,count(pi2.pno) '揽收包裹数'
,count(if(pi2.state in (5,8,9) or  pi3.state in (5,8,9),pi2.pno,null)) '终态包裹数'
,count(if(pi2.state not  in (5,7,8,9),pi2.pno,null)) '正向未终态包裹数'
,count(if(pi3.state not in (5,7,8,9),pi2.pno,null)) '逆向未终态包裹数'
,count(if(pi2.state=8 or  pi3.state=8,pi2.pno,null)) '异常关闭包裹数'
from
(select
pi2.pno
,date(convert_tz(pi2.created_at,'+00:00','+08:00')) date
,pi2.state
,pi2.client_id
,pi2.returned_pno
from my_staging.parcel_info pi2
where pi2.created_at>=convert_tz(current_date()-interval 35 day,'+08:00','+00:00')
and pi2.returned=0
and pi2.client_id in  ('AA0187','AA0188','AA0189','AA0181','AA0218','AA0211')
)pi2
left join
(select pi2.pno
,pi2.state
from my_staging.parcel_info pi2
where pi2.created_at>=convert_tz(current_date()-interval 35 day,'+08:00','+00:00')
and pi2.returned=1
and pi2.client_id in  ('AA0187','AA0188','AA0189','AA0181','AA0218','AA0211')
)pi3 on pi2.returned_pno=pi3.pno
group by 1,2
order by 1





;







-- MS工单

with t as
    (
        select
            wo.id
            ,wo.order_no
            ,wo.created_at
            ,wo.speed_level
            ,case
                when wo.speed_level = 2 then date_add(wo.created_at, interval 24 hour)
                when wo.speed_level = 1 and wo.created_at <= date_add(date(wo.created_at), interval 8 hour) then date_add(date(wo.created_at), interval 12 hour)
                when wo.speed_level = 1 and wo.created_at > date_add(date(wo.created_at), interval 8 hour) and wo.created_at <= date_add(date(wo.created_at), interval 16 hour) then date_add(wo.created_at, interval 2 hour)
                when wo.speed_level = 1 and wo.created_at > date_add(date(wo.created_at), interval 16 hour) then date_add(date(date_add(wo.created_at, interval 1 day)), interval 12 hour)
            end dead_line_time
        from my_bi.work_order wo
        where
            wo.store_id = 'customer_manger' -- 客服中心受理
           -- and wo.speed_level = 2
            and wo.created_at > date_format(date_sub(curdate(), interval 1 month), '%Y-%m-01')
            and wo.created_at < date_format(curdate(), '%Y-%m-01')
    )

select
    t1.order_no 工单编号
    ,t1.created_at 工单创建时间
    ,t1.dead_line_time 时效时间
    ,wor.created_at 第一次回复时间
    ,case t1.speed_level
        when 2 then '一般'
        when 1 then '紧急'
    end 紧急程度
from t t1
left join
    (
        select
            t1.id
            ,wor.created_at
            ,row_number() over (partition by t1.id order by wor.created_at) rk
        from my_bi.work_order_reply wor
        join t t1 on t1.id = wor.order_id
        where
            wor.created_at > date_format(date_sub(curdate(), interval 1 month), '%Y-%m-01')
    ) wor on wor.id = t1.id and wor.rk = 1


;





with t as
    (
        select
            cdt.diff_info_id
            ,cdt.organization_type
            ,cdt.created_at
            ,cdt.client_id
            ,cdt.organization_id
        from my_staging.customer_diff_ticket cdt
        where
            cdt.state <> 1
            and  (cdt.operator_id <>'10001' or cdt.operator_id is null)
            and cdt.created_at > date_sub('${sdate}', interval 8 hour)
            and cdt.created_at <date_add('${edate}', interval 16 hour)
    )
select
    case when cdt.organization_type = 1  and ss.category=1 then 'miniCS_SP'
          when cdt.organization_type = 1  and lower(ss.name) like '%fh%' then 'miniCS_FH'
          when cdt.organization_type = 1  and lower(ss.name) like '%hub%' then 'miniCS_HUB'
          when cdt.organization_type = 2  and bc.client_name='lazada' then 'PMD_Lazada'
          when cdt.organization_type = 2  and bc.client_name='tiktok' then 'PMD_Tiktok'
          when cdt.organization_type = 2  and bc.client_name is null and kp.department_id='388' then 'PMD_KA'
          when cdt.organization_type = 2  and cs.client_id is not null then '总部CS'
          else null end as 处理部门
    ,date(convert_tz(cdt.created_at, '+00:00', '+08:00')) 疑难件上报日期
    ,count(distinct di.pno) pnt
from t cdt
left join my_staging.diff_info di on di.id = cdt.diff_info_id
left join my_staging.parcel_info pi on pi.pno = di.pno
left join dwm.dwd_dim_dict ddd on ddd.element = di.diff_marker_category and ddd.db = 'my_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
left join my_staging.sys_store ss on ss.id = cdt.organization_id
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = cdt.client_id
left join my_staging.sys_store ss2 on ss2.id = pi.ticket_pickup_store_id
left join my_staging.ka_profile kp on kp.id = cdt.client_id
left join
    (
        select
            pc.*
             ,client_id
        from
            (
                select
                    *
                from my_staging.sys_configuration
                where
                    cfg_key ='diff.ticket.customer_service.ka_client_ids'
            )pc
        lateral view explode(split(pc.cfg_value, ',')) id as client_id
    )cs on cdt.client_id=cs.client_id
where
    if(bc.client_name is not null,di.diff_marker_category not in (2,17),1)
    and if(cdt.client_id='AA0107',di.diff_marker_category not in (2,17),1)
    and di.diff_marker_category not in (32,69,7,22,28)
    and pi.state < 7
group by 1,2
order by 2,1



;



select
    date(pcol.created_at) p_date
    ,pcol.operator_id
    ,hsi.name
    ,case pcol.action
        when 1 then '已发工单数量/ Ticket Replied'
        when 4 then '已判责数量 / Resonsible person had been Judged'
        when 3 then '无需追责数量/ No need for accountability'
    end as p_action
    ,plt.id
#     ,count(distinct if(plt.source = 1, pcol.id, null)) A来源
#     ,count(distinct if(plt.source = 2, pcol.id, null)) B来源
#     ,count(distinct if(plt.source = 3, pcol.id, null)) C来源
#     ,count(distinct if(plt.source = 4, pcol.id, null)) D来源
#     ,count(distinct if(plt.source = 5, pcol.id, null)) E来源
#     ,count(distinct if(plt.source = 6, pcol.id, null)) F来源
#     ,count(distinct if(plt.source = 7, pcol.id, null)) G来源
#     ,count(distinct if(plt.source = 8, pcol.id, null)) H来源
#     ,count(distinct if(plt.source = 9, pcol.id, null)) I来源
#     ,count(distinct if(plt.source = 10, pcol.id, null)) J来源
#     ,count(distinct if(plt.source = 11, pcol.id, null)) K来源
#     ,count(distinct if(plt.source = 12, pcol.id, null)) L来源
from my_bi.parcel_lose_task plt
left join my_bi.parcel_cs_operation_log pcol on pcol.task_id = plt.id
left join my_bi.staff_info hsi on hsi.id = pcol.operator_id
where
    pcol.created_at > '${sdate}'
    and pcol.created_at < date_add('${edate}', interval 1 day)
    and pcol.operator_id not in (10000,10001)
    and pcol.action in (1,3,4)
    and pcol.operator_id = '123254'
group by 1,2,3,4
order by 1,2,3,4
;


select
    wo.created_staff_info_id 工号
    ,wo.order_no
    ,wo.created_at
    ,timestampdiff(hour, wo.created_at, wo.closed_at) 小时
#     ,count(if(timestampdiff(hour, wo.created_at, wo.closed_at) < 72, wo.id, null)) / count(wo.id) 72H工单关闭率
    ,if(timestampdiff(hour, wo.created_at, wo.closed_at) < 72, 1, 0) 72H工单关闭
from my_bi.work_order wo
where
    wo.created_staff_info_id in ('132191', '131422')
    and wo.created_at > date_format(date_sub(curdate(), interval 1 month), '%Y-%m-01')
    and wo.created_at < date_format(curdate(), '%Y-%m-01')
    and ( wo.status in (1,2,3) or ( wo.status = 4 and wo.closed_at is not null ))
    and wo.created_staff_info_id = '132191'




;


select
    oi.pno
    ,ss.name
    ,oi.dst_store_id
from my_staging.order_info oi
left join my_staging.sys_store ss on ss.id = oi.dst_store_id
where
    oi.pno = 'M01021J67TCDW0'
;


select
    pcd.pno
    ,pcd.created_at
    ,pcd.old_value
    ,pcd.new_value
    ,pcd.field_name
from my_staging.parcel_change_detail pcd
where
    pcd.pno = 'M01021J67TCDW0'
   -- and pcd.field_name = 'dst_store_id'
order by 2
;

select
    pi.pno
    ,pi.ticket_delivery_store_id
from my_staging.parcel_info pi
where
    pi.pno = 'M01021J67TCDW0'



;







SELECT tot.update_time AS 更新时间, stat_date, client_name AS 客户类型
	, COALESCE(store_name, '任务未分配') AS 揽收分配网点, store_type
	, CASE
		WHEN ss.store_category = 8 THEN 'HUB'
		WHEN ss.store_category = 14 THEN 'Fleet'
		ELSE ss.region_name
	END AS 大区, piece_name AS 片区, 应揽收包裹数, 尝试揽收及时包裹数, 未尝试揽收包裹数
	, 揽收及时包裹数, 未揽收及时包裹数, 揽收及时包裹数N1, 未揽收及时包裹数N1
-- 	, shd_pickup_par_cnt AS 应揽收包裹, act_pickup_par_cnt AS 实际揽收包裹量
-- 	, try_pickup_par_cnt AS 尝试揽收包裹量, unpickup_par_cnt AS 未揽收包裹量
-- 	, untry_unpickup_par_cnt AS 未揽收未尝试揽收包裹量
FROM (
	SELECT stat_date, task_store_id, client_name, COUNT(DISTINCT pno) AS 应揽收包裹数
		, COUNT(DISTINCT IF(DATE(first_try_date) <= DATE(should_pk_time_t0)
			OR DATE(act_pk_time) <= DATE(should_pk_time_t0), pno, NULL)) AS 尝试揽收及时包裹数
		, COUNT(DISTINCT pno) - COUNT(DISTINCT IF(DATE(first_try_date) <= DATE(should_pk_time_t0)
			OR DATE(act_pk_time) <= DATE(should_pk_time_t0), pno, NULL)) AS 未尝试揽收包裹数
		, COUNT(DISTINCT IF(DATE(act_pk_time) <= DATE(should_pk_time_t0), pno, NULL)) AS 揽收及时包裹数
		, COUNT(DISTINCT pno) - COUNT(DISTINCT IF(DATE(act_pk_time) <= DATE(should_pk_time_t0), pno, NULL)) AS 未揽收及时包裹数
		, COUNT(DISTINCT IF(DATE(act_pk_time) <= DATE(should_pk_time_t1), pno, NULL)) AS 揽收及时包裹数N1
		, COUNT(DISTINCT pno) - COUNT(DISTINCT IF(DATE(act_pk_time) <= DATE(should_pk_time_t1), pno, NULL)) AS 未揽收及时包裹数N1
		, MAX(sh.update_time) AS update_time
-- 		, COUNT(DISTINCT pno) AS shd_pickup_par_cnt -- 应揽收包裹数
-- 		, COUNT(DISTINCT if(act_pk_time <= should_pk_time_t0, pno, NULL)) AS act_pickup_par_cnt -- 实际揽收包裹量
-- 		, COUNT(DISTINCT IF(first_try_date <= should_pk_time_t0
-- 			OR act_pk_time <= should_pk_time_t0, pno, NULL)) AS try_pickup_par_cnt -- 尝试揽收包裹量
-- 		, COUNT(DISTINCT if(act_pk_time IS NULL, pno, NULL)) AS unpickup_par_cnt -- 未揽收包裹量
-- 		, COUNT(DISTINCT if(act_pk_time IS NULL
-- 			AND first_try_date IS NULL, pno, NULL)) AS untry_unpickup_par_cnt -- 未揽收未尝试揽收包裹量
	FROM dwm.dws_my_should_pickup_lazada_detl_s sh
	WHERE sh.stat_date > DATE_SUB(CURRENT_DATE(), 60)
		AND sh.stat_date < DATE_ADD(CURRENT_DATE(), 1)
	GROUP BY stat_date, task_store_id
) tot
	LEFT JOIN (
		SELECT store_id, store_name, region_name, piece_name, store_category
			, store_type
		FROM dwm.dim_my_sys_store_rd
		WHERE stat_date = DATE_SUB(CURRENT_DATE(), 1)
	) ss
	ON tot.task_store_id = ss.store_id


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
from my_staging.parcel_route pr
left join my_staging.parcel_info pi on pi.pno = pr.pno
left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'my_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
where
    pr.staff_info_id = '123094'
    and pr.routed_at >= '2025-05-01 16:00:00'
    and pr.routed_at <= '2025-05-02 16:00:00'


;


select
    count(distinct plt.pno)
from my_bi.parcel_lose_task plt
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = plt.client_id
where
    plt.remark regexp 'Feishu'
;

select
    *
from my_staging.parcel_change_detail pcd