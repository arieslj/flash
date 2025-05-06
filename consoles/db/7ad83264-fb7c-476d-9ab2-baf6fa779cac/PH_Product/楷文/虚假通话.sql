with staff_rnk as
(
    select
        pr.pno
        ,pr.staff_info_id
        ,pr.route_action
        ,pr.store_id
        ,db.client_id
        ,db.client_name
        ,date(convert_tz(pr.routed_at,'+00:00','+08:00')) routed_date
        ,convert_tz(pr.routed_at,'+00:00','+08:00')  as call_start_datetime
        ,date_add(convert_tz(pr.routed_at,'+00:00','+08:00'),interval (cast(json_extract(pr.extra_value, '$.callDuration') as int)+cast(json_extract(pr.extra_value, '$.diaboloDuration') as int)) second) call_end_datetime
        ,cast(json_extract(pr.extra_value, '$.callDuration') as int) call_num -- 通话
        ,cast(json_extract(pr.extra_value, '$.diaboloDuration') as int) diao_num -- 响铃
        ,json_extract(pr.extra_value, '$.callingChannel') callingChannel -- callingChannel
        ,json_extract(pr.extra_value, '$.carrierName') carrierName
        ,case when json_extract(pr.extra_value, '$.callType')=1 then 'INCOMING_CALL' else 'PHONE'  end  callType
        ,json_extract(pr.extra_value, '$.phone') phone
        ,td.cn_element as marker
        ,row_number() over (partition by pr.staff_info_id,date(convert_tz(pr.routed_at,'+00:00','+08:00')) order by convert_tz(pr.routed_at,'+00:00','+08:00')) rnk
 from ph_staging.parcel_route pr
 join ph_staging.parcel_info pi on pr.pno=pi.pno and pi.created_at>=concat(date_sub(current_date,interval 20 day),' 16:00:00')
 left join dwm.dwd_dim_bigClient db on pi.client_id=db.client_id
 left join
     (
         select
             td.staff_info_id
             ,td.id
             ,td.pno
             ,tdt2.CN_element
             ,row_number() over (partition by td.staff_info_id,td.pno,date(convert_tz(td.created_at,'+00:00','+08:00')) order by convert_tz(td.created_at,'+00:00','+08:00') desc) rnk
         from ph_staging.ticket_delivery td
         left join ph_staging.ticket_delivery_marker dm on td.id=dm.delivery_id
         left join dwm.dwd_dim_dict tdt2 on dm.marker_id= tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category'
         where
             td.created_at>= concat(date_sub(current_date,interval 2 day),' 16:00:00')
            and td.created_at<concat(date_sub(current_date,interval 1 day),' 16:00:00')
     )td on pr.staff_info_id=td.staff_info_id  and td.pno=pr.pno and td.rnk=1
 where
     pr.route_action in ('PHONE','INCOMING_CALL')
     and pr.routed_at >=concat(date_sub(current_date,interval 2 day),' 16:00:00')
     and pr.routed_at <concat(date_sub(current_date,interval 1 day),' 16:00:00')
     and (pi.finished_at>concat(date_sub(current_date,interval 1 day),' 16:00:00') or pi.finished_at is null)
 # and pr.staff_info_id=118689
 order by 2,7,8
)


select
    sr.*,dp.store_name
    ,dp.piece_name
    ,dp.region_name
from staff_rnk  sr
join
    (
        select
          sr.staff_info_id
          ,sr.call_num
          ,count(distinct sr.phone) call_times
        from staff_rnk  sr
        where sr.route_action='PHONE'
        group by 1,2
    )sr1 on sr.staff_info_id=sr1.staff_info_id and sr.call_num=sr1.call_num
join dwm.dim_ph_sys_store_rd dp on sr.store_id=dp.store_id and dp.stat_date=date_sub(current_date,interval 1 day)
where
    sr1.call_times>=7 and sr.call_num>0

;






with t as
    (
        select
            pr.pno
            ,pr.staff_info_id
            ,pr.route_action
            ,pr.store_id
            ,db.client_id
            ,db.client_name
            ,date(convert_tz(pr.routed_at,'+00:00','+08:00')) routed_date
            ,convert_tz(pr.routed_at,'+00:00','+08:00')  as call_start_datetime
            ,json_extract(pr.extra_value, '$.startTime') start_time
            ,date_add(json_extract(pr.extra_value, '$.startTime'),interval (cast(json_extract(pr.extra_value, '$.callDuration') as int)+cast(json_extract(pr.extra_value, '$.diaboloDuration') as int)) second) end_time
            ,cast(json_extract(pr.extra_value, '$.callDuration') as int) call_num -- 通话
            ,cast(json_extract(pr.extra_value, '$.diaboloDuration') as int) diao_num -- 响铃
            ,json_extract(pr.extra_value, '$.callingChannel') callingChannel -- callingChannel
            ,json_extract(pr.extra_value, '$.carrierName') carrierName
            ,case when json_extract(pr.extra_value, '$.callType')=1 then 'INCOMING_CALL' else 'PHONE'  end  callType
            ,json_extract(pr.extra_value, '$.phone') phone
#             ,row_number() over (partition by pr.staff_info_id,date(convert_tz(pr.routed_at,'+00:00','+08:00')) order by convert_tz(pr.routed_at,'+00:00','+08:00')) rnk
     from ph_staging.parcel_route pr
     join ph_staging.parcel_info pi on pr.pno=pi.pno and pi.created_at>=concat(date_sub(current_date,interval 20 day),' 16:00:00')
     left join dwm.dwd_dim_bigClient db on pi.client_id=db.client_id
     where
         pr.route_action in ('PHONE','INCOMING_CALL')
         and pr.routed_at >=concat(date_sub(current_date,interval 2 day),' 16:00:00')
         and pr.routed_at <concat(date_sub(current_date,interval 1 day),' 16:00:00')
        -- 昨日妥投
        and pi.finished_at >=concat(date_sub(current_date,interval 2 day),' 16:00:00')
        and pi.finished_at <concat(date_sub(current_date,interval 1 day),' 16:00:00')
        and pi.state = 5

    )
select
    t1.*
    ,a1.call_times 相同次数
from t t1
join
    (
        select
            a.*
            ,count() over (partition by a.call_num, a.staff_info_id, a.diao_num) call_times
        from
            (
                select
                    distinct
                    t1.staff_info_id
                    ,t1.phone
                    ,t1.start_time
                    ,t1.end_time
                    ,t1.call_num
                    ,t1.diao_num
                from t t1
                where
                    t1.call_num > 0
            ) a
    ) a1 on a1.staff_info_id = t1.staff_info_id and a1.phone = t1.phone and a1.start_time = t1.start_time and a1.end_time = t1.end_time and a1.call_times > 6


;



with t as
    (
        select
            distinct
            pr.pno
            ,pr.staff_info_id
            ,pr.route_action
            ,pr.store_id
            ,db.client_id
            ,db.client_name
            ,pi.dst_store_id
            ,date(convert_tz(pr.routed_at,'+00:00','+08:00')) routed_date
            ,convert_tz(pr.routed_at,'+00:00','+08:00')  as call_start_datetime
            ,json_extract(pr.extra_value, '$.startTime') start_time
            ,date_add(json_extract(pr.extra_value, '$.startTime'),interval (cast(json_extract(pr.extra_value, '$.callDuration') as int)+cast(json_extract(pr.extra_value, '$.diaboloDuration') as int)) second) end_time
            ,json_extract(pr.extra_value, '$.callDuration') call_num -- 通话
            ,json_extract(pr.extra_value, '$.diaboloDuration') diao_num -- 响铃
            ,json_extract(pr.extra_value, '$.callingChannel') callingChannel -- callingChannel
            ,json_extract(pr.extra_value, '$.carrierName') carrierName
            ,case when json_extract(pr.extra_value, '$.callType')=1 then 'INCOMING_CALL' else 'PHONE'  end  callType
            ,json_extract(pr.extra_value, '$.phone') phone
#             ,row_number() over (partition by pr.staff_info_id,date(convert_tz(pr.routed_at,'+00:00','+08:00')) order by convert_tz(pr.routed_at,'+00:00','+08:00')) rnk
     from ph_staging.parcel_route pr
     join ph_staging.parcel_info pi on pr.pno=pi.pno and pi.created_at>=concat(date_sub(current_date,interval 20 day),' 16:00:00')
     left join dwm.dwd_dim_bigClient db on pi.client_id=db.client_id
     left join ph_staging.parcel_route pr1 on pr.pno = pr1.pno and pr1.route_action='DELIVERY_MARKER' and pr1.routed_at >= concat(date_sub(current_date,interval 2 day),' 16:00:00') and pr1.routed_at <concat(date_sub(current_date,interval 1 day),' 16:00:00')
     where
         pr.route_action in ('PHONE','INCOMING_CALL')
         and pr.routed_at >=concat(date_sub(current_date,interval 2 day),' 16:00:00')
         and pr.routed_at <concat(date_sub(current_date,interval 1 day),' 16:00:00')
        -- 昨日尝试pais
        and pr1.pno is not null
        and pi.state in (1,2,3,4,6)

    )
select
    t1.*
    ,a1.call_times 相同次数
    ,dp.store_name 目的地网点
    ,dp.region_name 目的地网点大区
    ,pr.CN_element 昨日最后标记
from t t1
join
    (
        select
            a.*
            ,count() over (partition by a.call_num, a.staff_info_id, a.diao_num) call_times
        from
            (
                select
                    distinct
                    t1.staff_info_id
                    ,t1.phone
                    ,t1.start_time
                    ,t1.end_time
                    ,t1.call_num
                    ,t1.diao_num
                from t t1
                where
                    t1.call_num > 0
            ) a
    ) a1 on a1.staff_info_id = t1.staff_info_id and a1.phone = t1.phone and a1.start_time = t1.start_time and a1.end_time = t1.end_time and a1.call_times > 6
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = t1.dst_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
left join
    (
        select
            pr.pno
            ,ddd.CN_element
            ,row_number() over (partition by t1.pno order by pr.routed_at desc) rk
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        left join dwm.dwd_dim_dict ddd on ddd.element = pr.marker_category and ddd.db = 'ph_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
        where
            pr.routed_at >=concat(date_sub(current_date,interval 2 day),' 16:00:00')
            and pr.routed_at <concat(date_sub(current_date,interval 1 day),' 16:00:00')
            and pr.route_action = 'DELIVERY_MARKER'
    ) pr on pr.pno = t1.pno and pr.rk = 1


;
SELECT
  store_id,
  SUM(`punish_money`),
  punish_category
FROM
  ph_bi.`abnormal_message`
WHERE
  `punish_category` in (15, 18, 85, 84, 72, 14)
  and `abnormal_time` in ('2024-07-24','2024-07-25','2024-07-26','2024-07-27','2024-07-28','2024-07-29','2024-07-30','2024-07-31','2024-08-01','2024-08-02','2024-08-03','2024-08-04','2024-08-05')
  and `state` = 1
  and `isdel` = 0
  and `punish_money` > 0
GROUP BY
  punish_category,
  `store_id`

;

select
    *
from ph_bi.msdashboard_pri_abnormal_data_save