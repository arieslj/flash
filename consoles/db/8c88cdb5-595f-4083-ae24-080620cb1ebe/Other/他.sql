with t as
    (
        select
            pi.pno
            ,date_format(pi.finished_at,"%Y%m%d") abnormal_time
            ,pi.ticket_delivery_staff_info_id
            ,pi.finished_at
        from fle_staging.parcel_info pi
        left join bi_pro.abnormal_customer_complaint acc on pi.pno = acc.pno
        left join bi_pro.abnormal_message am on am.id = acc.abnormal_message_id
        where
        pi.finished_at >= '2023-11-20'
        and pi.finished_at <= '2023-11-21'
        and pi.state = 5
        -- and pi.pno='TH03054WMWGM5A'
        and (am.punish_category != 7 or am.punish_category is null)
        and (acc.complaints_type != 1 or am.punish_category is null)
        and pi.created_at > date_sub(curdate(), interval 3 month)
        -- and pi.pno = 'TH37014WKY469N'
        group by 1
    )
,pho as
    (
        select
            pr.pno
            ,pr.routed_at
            ,cast(json_extract(pr.extra_value, '$.callDuration') as int) call_num
            ,cast(json_extract(pr.extra_value, '$.diaboloDuration') as int) diao_num
            ,row_number() over (partition by t1.pno order by pr.routed_at desc ) rk
        from rot_pro.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'PHONE'
            and pr.routed_at > date_sub(curdate(), interval 2 month)
            and pr.routed_at < t1.finished_at
    )

select
    t1.pno
    ,pi.dst_store_id 目的地网点ID
    ,pi.ticket_delivery_staff_info_id 妥投快递员
    ,if(pi.cod_enabled = 1, 'y', 'n') 是否cod
    ,pi.cod_amount cod金额
    ,convert_tz(pi.finished_at, '+00:00', '+07:00') 妥投时间
    ,hour(convert_tz(pi.finished_at, '+00:00', '+07:00')) 妥投时间点
    ,pi.exhibition_weight 重量
    ,pi.exhibition_length 长
    ,pi.exhibition_width 宽
    ,pi.exhibition_height 高
    ,pi.dst_phone 收件人电话
    ,pi.dst_province_code 收件省ID
    ,pi.dst_city_code 收件城市ID
    ,pi.dst_district_code 收件乡ID
    ,pi.dst_postal_code 收件邮编
    ,pi.src_phone 寄件人电话
    ,pi.src_province_code 发件省ID
    ,pi.src_city_code 发件城市ID
    ,pi.src_district_code 发件乡ID
    ,pi.src_postal_code 发件邮编
    ,convert_tz(swa.started_at,  '+00:00', '+07:00') 当日上班打卡时间
    ,convert_tz(swa.end_at,  '+00:00', '+07:00') 当日下班打卡时间
    ,scan.scan_count 当日交接量
    ,scan.del_count 当日妥投量
    ,scan.del_rate 当日妥投率
    ,dis.distance/1000 当日行驶里程km
    ,pi.client_id 客户ID
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null
        and bc.id is null then '普通ka'
        when kp.`id` is null then '小c'
      end as 客户类型
    -- ,'未投诉' as '判责类型'
    ,p1.call_num 最后一次电话通话
    ,p1.diao_num 最后一次电话响铃
    ,if(p2.pno is not null , 'y', 'n')  是否沟通
    ,if(p1.call_num >= 2 and p1.call_num <= 5 and p1.diao_num >= 15 and p1.diao_num <= 18, 'y', 'n') 是否疑似神仙卡
    ,convert_tz(p1.routed_at,  '+00:00', '+07:00') 最后一次打电话时间
    ,timestampdiff(minute, p1.routed_at, t1.finished_at) 最后一次打电话与妥投时间差
    ,ab.abnormal_count 近三月处罚次数
from fle_staging.parcel_info pi
join t t1 on t1.pno = pi.pno
left join backyard_pro.staff_work_attendance swa on swa.staff_info_id = pi.ticket_delivery_staff_info_id and swa.attendance_date = t1.abnormal_time
left join
    (
        select
            t1.ticket_delivery_staff_info_id
            ,t1.abnormal_time
            ,count(distinct pr.pno) scan_count
            ,count(distinct if(pi.state = 5 and pi.finished_at >= date_sub(t1.abnormal_time, interval 7 hour) and pi.finished_at < date_add(t1.abnormal_time, interval 17 hour), pr.pno, null)) del_count
            ,count(distinct if(pi.state = 5 and pi.finished_at >= date_sub(t1.abnormal_time, interval 7 hour) and pi.finished_at < date_add(t1.abnormal_time, interval 17 hour), pr.pno, null))/count(distinct pr.pno) del_rate
        from rot_pro.parcel_route pr
        join t t1 on t1.ticket_delivery_staff_info_id = pr.staff_info_id
        left join fle_staging.parcel_info pi on pi.pno = pr.pno and pi.created_at > date_sub(curdate(), interval 3 month)
        where
            pr.routed_at > '2023-10-25'
            and pr.route_action  = 'DELIVERY_TICKET_CREATION_SCAN'
            and pr.routed_at >= date_sub(t1.abnormal_time, interval 7 hour)
            and pr.routed_at < date_add(t1.abnormal_time, interval 17 hour)
            and pr.staff_info_id = t1.ticket_delivery_staff_info_id
        group by 1,2
    ) scan on scan.ticket_delivery_staff_info_id = t1.ticket_delivery_staff_info_id and scan.abnormal_time = t1.abnormal_time
left join
    (
        select
            t1.abnormal_time
            ,t1.ticket_delivery_staff_info_id
            ,max(ccd.coordinate_distance) distance
        from rev_pro.courier_coordinate_distance ccd
        join t t1 on t1.abnormal_time = ccd.coordinate_date and t1.ticket_delivery_staff_info_id = ccd.staff_id
        where
            ccd.created_at > '2023-11-20'
        group by 1,2
    ) dis on dis.ticket_delivery_staff_info_id = t1.ticket_delivery_staff_info_id and dis.abnormal_time = t1.abnormal_time
left join dwm.tmp_ex_big_clients_id_detail bc on pi.client_id = bc.client_id
left join fle_staging.ka_profile kp on pi.client_id = kp.id
left join pho p1 on p1.pno = t1.pno and p1.rk = 1
left join
    (
        select
            p1.pno
        from pho p1
        where
            p1.call_num > 0
        group by 1
    ) p2 on p2.pno = t1.pno
left join
    (
        select
            am.staff_info_id
            ,count(distinct case when am.punish_category = 7 then am.id when acc.complaints_type = 1 then acc.abnormal_message_id end ) abnormal_count
        from bi_pro.abnormal_message am
        join t t1 on t1.ticket_delivery_staff_info_id = am.staff_info_id
        left join bi_pro.abnormal_customer_complaint acc on am.id = acc.abnormal_message_id
        where
            am.created_at >= date_sub(curdate(), interval 3 month)
            and am.isdel = 0
            and (am.isappeal < 5 or am.isappeal is null )
        group by 1
    ) ab on ab.staff_info_id = t1.ticket_delivery_staff_info_id