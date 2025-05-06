
with a1 as -- tmp_th_pno_lpf
        (
                select
                    pi.pno
        #             ,case
        #                 when pci.merge_column is not null then date(pci.complaints_at)
        #                 when pci.merge_column is null and ( (acc.complaints_type = 1 and am.punish_category = 21) or am.punish_category = 20 ) then date(am.abnormal_time)
        #                 else null
        #             end abnormal_time
                    ,case
                        when pci.merge_column is not null then '虚假妥投'
                        when pci.merge_column is null and ( (acc.complaints_type = 1 and am.punish_category = 21) or am.punish_category = 20 ) then '虚假妥投'
                        else '未投诉'
                    end type
                    ,pi.ticket_delivery_staff_info_id
                    ,pi.finished_at
                    ,date(convert_tz(pi.finished_at, '+00:00', '+07:00')) fin_date
                from  fle_staging.parcel_info pi
                left join
                    (
                        select
                            pi.pno
                        from fle_staging.parcel_info pi
                        join bi_center.parcel_complaint_inquiry pci on pci.merge_column = pi.pno and pci.created_at > '2023-11-01'
                        left join fle_staging.customer_issue ci on ci.id = pci.source_id and ci.created_at > '2023-12-01'
                        where
                            ci.request_sub_type in (221,300)
        #                     and pi.ticket_delivery_store_id in ('TH01270302','TH01080204','TH01290102','TH25060300','TH20040248','TH04060232','TH03040503','TH38010110','TH01080144','TH01080109','TH20040301','TH04050201','TH01050203','TH01470308','TH76050100','TH20040212','TH03020900','TH01030308','TH01210119','TH02050101','TH04060700','TH01180117','TH38130200','TH37040100','TH20040246','TH01050401','TH02060111','TH18040800','TH01050214','TH38011200','TH67010700','TH03020503','TH67010525','TH20040820','TH01080114','TH13050401','TH20040271','TH72070101','TH38011701','TH01180105')
                            and pi.finished_at >  date_sub('${date}', interval 7 hour)
                            and pi.finished_at < date_add('${date}', interval 17 hour)
                            and pi.state = 5
                        group by 1
                    ) t2 on t2.pno = pi.pno
                left join bi_center.parcel_complaint_inquiry pci on pci.merge_column = pi.pno and pci.created_at > '2023-11-01'
                left join fle_staging.customer_issue ci on ci.id = pci.source_id and ci.created_at > '2023-11-01'
                left join bi_pro.abnormal_customer_complaint acc on acc.pno = pi.pno and acc.created_at > '2023-11-01'
                left join bi_pro.abnormal_message am on am.id = acc.abnormal_message_id and am.abnormal_time > '2023-11-01'
        #         left join fle_staging.parcel_info pi on pi.pno = t.pno and pi.created_at > '2024-01-01'
                where
                    t2.pno is null
        #             and pi.ticket_delivery_store_id in ('TH01270302','TH01080204','TH01290102','TH25060300','TH20040248','TH04060232','TH03040503','TH38010110','TH01080144','TH01080109','TH20040301','TH04050201','TH01050203','TH01470308','TH76050100','TH20040212','TH03020900','TH01030308','TH01210119','TH02050101','TH04060700','TH01180117','TH38130200','TH37040100','TH20040246','TH01050401','TH02060111','TH18040800','TH01050214','TH38011200','TH67010700','TH03020503','TH67010525','TH20040820','TH01080114','TH13050401','TH20040271','TH72070101','TH38011701','TH01180105')
                    and pi.finished_at >  date_sub('${date}', interval 7 hour)
                    and pi.finished_at < date_add('${date}', interval 17 hour)
                    and pi.state = 5
            )


        select
            pi.pno
#             ,date(pci.complaints_at) abnormal_time
            ,'已签收未收到' type
            ,pi.ticket_delivery_staff_info_id
            ,pi.finished_at
            ,date(convert_tz(pi.finished_at, '+00:00', '+07:00')) fin_date
        from fle_staging.parcel_info pi
        left join bi_center.parcel_complaint_inquiry pci on pci.merge_column = pi.pno and pci.created_at > '2023-11-01'
        left join fle_staging.customer_issue ci on ci.id = pci.source_id and ci.created_at > '2023-11-01'
#         left join fle_staging.parcel_info pi on pi.pno = t.pno and pi.created_at > '2023-12-30'
        where
            ci.request_sub_type in (221,300)
#             and pi.ticket_delivery_store_id in ('TH01270302','TH01080204','TH01290102','TH25060300','TH20040248','TH04060232','TH03040503','TH38010110','TH01080144','TH01080109','TH20040301','TH04050201','TH01050203','TH01470308','TH76050100','TH20040212','TH03020900','TH01030308','TH01210119','TH02050101','TH04060700','TH01180117','TH38130200','TH37040100','TH20040246','TH01050401','TH02060111','TH18040800','TH01050214','TH38011200','TH67010700','TH03020503','TH67010525','TH20040820','TH01080114','TH13050401','TH20040271','TH72070101','TH38011701','TH01180105')
            and pi.finished_at >  date_sub('${date}', interval 7 hour)
            and pi.finished_at < date_add('${date}', interval 17 hour)
            and pi.state = 5

        union all

        select
            a2.*
        from   a1 a2
        where
            a2.type = '虚假妥投'

        union all

        select
            c.*
        from
            ( -- 随机取1000个
                select
                    a3.*
                from   a1 a3
                where
                    a3.type = '未投诉'
                order by rand()
                limit 1000
            ) c



;

with  t  as -- 懒得改了
    (
        select
            t.*
        from tmpale.tmp_th_pno_lpf t
    )
, pho as
    (
        select
            pr.pno
            ,pr.routed_at
            ,cast(json_extract(pr.extra_value, '$.callDuration') as int) call_num -- 通话
            ,cast(json_extract(pr.extra_value, '$.diaboloDuration') as int) diao_num -- 响铃
            ,row_number() over (partition by t1.pno order by pr.routed_at desc ) rk
        from rot_pro.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'PHONE'
            and pr.routed_at > '2023-11-25'
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
            ,t1.type '判责类型'
            ,p1.call_num 最后一次电话通话
            ,p1.diao_num 最后一次电话响铃
            ,if(p2.pno is not null , 'y', 'n')  是否沟通
            ,if(p1.call_num >= 2 and p1.call_num <= 5 and p1.diao_num >= 15 and p1.diao_num <= 18, 'y', 'n') 是否疑似神仙卡
            ,convert_tz(p1.routed_at,  '+00:00', '+07:00') 最后一次打电话时间
            ,timestampdiff(minute, p1.routed_at, t1.finished_at) 最后一次打电话与妥投时间差
            ,ab.abnormal_count 近三月处罚次数
        from fle_staging.parcel_info pi
        join t t1 on t1.pno = pi.pno
        left join backyard_pro.staff_work_attendance swa on swa.staff_info_id = pi.ticket_delivery_staff_info_id and swa.attendance_date = t1.fin_date
        left join
            (
                select
                    t1.ticket_delivery_staff_info_id
                    ,t1.fin_date
                    ,count(distinct pr.pno) scan_count
                    ,count(distinct if(pi.state = 5 and pi.finished_at >= date_sub(t1.fin_date, interval 7 hour) and pi.finished_at < date_add(t1.fin_date, interval 17 hour), pr.pno, null)) del_count
                    ,count(distinct if(pi.state = 5 and pi.finished_at >= date_sub(t1.fin_date, interval 7 hour) and pi.finished_at < date_add(t1.fin_date, interval 17 hour), pr.pno, null))/count(distinct pr.pno) del_rate
                from rot_pro.parcel_route pr
                join t t1 on t1.ticket_delivery_staff_info_id = pr.staff_info_id
                left join fle_staging.parcel_info pi on pi.pno = pr.pno and pi.created_at > date_sub(curdate(), interval 2 month)
                where
                    pr.routed_at >  date_sub('${date}', interval 7 hour)
                    and pr.routed_at < date_add('${date}', interval 17 hour)
                    and pr.route_action  = 'DELIVERY_TICKET_CREATION_SCAN'
        #             and pr.routed_at >= date_sub(t1.fin_date, interval 7 hour)
        #             and pr.routed_at < date_add(t1.fin_date, interval 17 hour)
                    and pr.staff_info_id = t1.ticket_delivery_staff_info_id
                group by 1,2
            ) scan on scan.ticket_delivery_staff_info_id = t1.ticket_delivery_staff_info_id and scan.fin_date = t1.fin_date
        left join
            (
                select
                    t1.fin_date
                    ,t1.ticket_delivery_staff_info_id
                    ,max(ccd.coordinate_distance) distance
                from rev_pro.courier_coordinate_distance ccd
                join t t1 on t1.fin_date = ccd.coordinate_date and t1.ticket_delivery_staff_info_id = ccd.staff_id
                where
        #             ccd.created_at > '2024-01-01'
                    ccd.coordinate_date = '${date}'
                group by 1,2
            ) dis on dis.ticket_delivery_staff_info_id = t1.ticket_delivery_staff_info_id and dis.fin_date = t1.fin_date
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
            (-- 近3月处罚次数
                select
                    am.staff_info_id
                    ,count(distinct case when am.abnormal_object = 0 then am.id when am.abnormal_object = 1 then am.average_merge_key end ) abnormal_count
                from bi_pro.abnormal_message am
                join t t1 on t1.ticket_delivery_staff_info_id = am.staff_info_id
                where
                    am.created_at >= date_sub(curdate(), interval 3 month)
                    and am.isdel = 0 -- 未删除
                    and (am.isappeal < 5 or am.isappeal is null ) -- 未删除
                group by 1
            ) ab on ab.staff_info_id = t1.ticket_delivery_staff_info_id

; select date_sub(curdate(), interval 1 day)
;with t as
  (
    select
      a1.*
      ,case
        when ci.pno is not null then '1'
        when ci.pno is null and ac.pno is  not null then '2'
        when ci.pno is null and ac.pno is null then '3'
      end type
    from
      (
        select
          p.pno
          ,p.ticket_delivery_staff_info_id
          ,p.finished_at
          ,to_date(p.finished_at) fin_date
        from fle_dwd.dwd_fle_parcel_info_di p
        where
          p.p_date >= '2023-01-01'
          and p.state = '5'
          and p.finished_at > '2023-08-01'
          and p.finished_at < '2023-09-01'
      ) a1
    left join
      (
        select
          ci.pno
        from fle_dwd.dwd_fle_customer_issue_di ci
        where
          ci.p_date >= '2023-07-01'
          and ci.request_sub_type in ('221','300')
        group by ci.pno
      ) ci on ci.pno = a1.pno
    left join
      (
        select
          acc.pno
          ,acc.complaints_type
          ,am.punish_category
          -- count(1)
        from
          (
            select
              acc.pno
              ,acc.complaints_type
              ,acc.abnormal_message_id
            from fle_dwd.dwd_bi_abnormal_customer_complaint_di acc
            where
              acc.p_date >= '2023-07-01'
              and acc.p_date < '2024-01-01'
          ) acc
        left join
          (
            select
              am.id
              ,am.punish_category
            from fle_dim.dim_bi_abnormal_message_da am
            where
              am.p_date = '2023-10-27'
              and am.punish_category in ('20','21')
          ) am on acc.abnormal_message_id = am.id
        where
          (acc.complaints_type = '1' and am.punish_category = '21') or am.punish_category = '20'
      ) ac on ac.pno = a1.pno
  )
select
  *
from t t1
where
  t1.type in ('1','2')

union all

select
  a.*
from
  (
    select
      *
    from t t1
    where
      t1.type = '3'
    order by rand()
    limit 20000
  ) a

  ;



select
  a1.pno
  ,a1.dst_store_id `目的地网点ID`
  ,a1.ticket_delivery_staff_info_id `妥投快递员`
  ,if(a1.cod_enabled = '1', 'y', 'n') `是否cod`
  ,a1.cod_amount `cod金额`
  ,a1.finished_at `妥投时间`
  ,hour(a1.finished_at) `妥投时间点`
  ,a1.exhibition_weight `重量`
  ,a1.exhibition_length `长`
  ,a1.exhibition_width `宽`
  ,a1.exhibition_height `高`
  ,a1.dst_phone `收件人电话`
  ,a1.dst_province_code `收件省ID`
  ,a1.dst_city_code `收件城市ID`
  ,a1.dst_district_code `收件乡ID`
  ,a1.dst_postal_code `收件邮编`
  ,a1.src_phone `寄件人电话`
  ,a1.src_province_code `发件省ID`
  ,a1.src_city_code `发件城市ID`
  ,a1.src_district_code `发件乡ID`
  ,a1.src_postal_code `发件邮编`
  ,swa.started_at `当日上班打卡时间`
  ,swa.end_at `当日下班打卡时间`
  ,scan.scan_count `当日交接量`
  ,scan.del_count `当日妥投量`
  ,scan.del_rate `当日妥投率`
  ,cast(dis.distance as int)/1000 `当日行驶里程km`
  ,a1.client_id `客户ID`
  ,case
      when bc.`client_id` is not null then bc.client_name
      when kp.id is not null and bc.client_id is null then '普通ka'
      when kp.`id` is null then '小c'
    end as `客户类型`
  ,case a1.type
    when '1' then '已签收未收到'
    when '2' then '虚假妥投'
    when '3' then '未投诉'
  end `判责类型`
  ,p1.call_num `最后一次电话通话`
  ,p1.diao_num `最后一次电话响铃`
  ,if(p2.pno is not null , 'y', 'n')  `是否沟通`
  ,if(cast(p1.call_num as int) >= 2 and cast(p1.call_num as int) <= 5 and cast(p1.diao_num as int) >= 15 and cast(p1.diao_num as int) <= 18, 'y', 'n') `是否疑似神仙卡`
  ,p1.routed_at `最后一次打电话时间`
--  ,timestampdiff(minute, p1.routed_at, a1.finished_at) `最后一次打电话与妥投时间差`
  ,(unix_timestamp(finished_at) - unix_timestamp(p1.routed_at))/60  `最后一次打电话与妥投时间差`
  ,ab.abnormal_count `近三月处罚次数`
from
  (
    select
      p.*
      ,to_date(t.fin_date) fin_date
      --,t.finished_at
      ,t.ticket_delivery_staff_info_id
      ,t.type
    from
      (
        select
          p.pno
          ,p.dst_store_id
          --,p.ticket_delivery_staff_info_id
          ,p.cod_amount
          ,p.cod_enabled
          ,p.finished_at
          ,p.exhibition_length
          ,p.exhibition_width
          ,p.exhibition_height
          ,p.exhibition_weight
          ,p.dst_phone
          ,p.dst_province_code
          ,p.dst_city_code
          ,p.dst_district_code
          ,p.dst_postal_code
          ,p.src_phone
          ,p.src_province_code
          ,p.src_city_code
          ,p.src_district_code
          ,p.src_postal_code
          ,p.client_id
        from fle_dwd.dwd_fle_parcel_info_di p
        where
          p.p_date >= '2023-05-01'
          and p.finished_at >= '2024-01-01'
          and p.finished_at < '2024-02-01'
      ) p
    join test.tmp_th_m_202401 t on t.pno = p.pno
  ) a1
left join
  (
    select
      swa.*
      ,t.pno
    from
      (
        select
          swa.staff_info_id
          ,swa.attendance_date
          ,swa.started_at
          ,swa.end_at
        from fle_dwd.dwd_backyard_staff_work_attendance_di swa
        where
          swa.p_date >= '2024-01-01'
          and swa.p_date < '2024-02-01'
      ) swa
    join test.tmp_th_m_202401 t on t.ticket_delivery_staff_info_id = swa.staff_info_id and to_date(t.fin_date)= swa.attendance_date
  ) swa on swa.pno = a1.pno
left join
  (
    select
      to_date(s1.fin_date) fin_date
      ,s1.ticket_delivery_staff_info_id
      ,count(distinct s1.pno) scan_count
      ,count(distinct if(s2.state = '5' and s2.finished_at < date_add(s1.fin_date, 1), s1.pno, null)) del_count
      ,count(distinct if(s2.state = '5' and s2.finished_at < date_add(s1.fin_date, 1), s1.pno, null))/count(distinct s1.pno) del_rate
    from
      (
        select
          t.fin_date
          ,t.ticket_delivery_staff_info_id
          ,pr.pno
        from
          (
            select
              pr.staff_info_id
              ,pr.pno
              ,pr.p_date
            from fle_dwd.dwd_rot_parcel_route_di pr
            where
              pr.p_date >= '2024-01-01'
              and pr.p_date < '2024-02-01'
              and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
            group by 1,2,3
          ) pr
        join test.tmp_th_m_202401 t on t.ticket_delivery_staff_info_id = pr.staff_info_id and to_date(t.fin_date) = pr.p_date
      ) s1
    left join
      (
        select
          p.pno
          ,p.state
          ,p.finished_at
        from fle_dwd.dwd_fle_parcel_info_di p
        where
          p.p_date >= '2023-05-01'
          and p.p_date < '2024-02-01'   --  可修改，查几月的之后的单号没必要看
      ) s2 on s2.pno = s1.pno
    group by 1,2
  ) scan on scan.fin_date = a1.fin_date and scan.ticket_delivery_staff_info_id = a1.ticket_delivery_staff_info_id
left join
  (
    select
      to_date(t.fin_date) fin_date
      ,t.ticket_delivery_staff_info_id
      ,max(ccd.coordinate_distance) distance
    from
      (
        select
          ccd.coordinate_date
          ,ccd.staff_id
          ,ccd.coordinate_distance
        from fle_dwd.dwd_nbd_rev_courier_coordinate_distance_di ccd
        where
          ccd.p_date >= '2024-01-01'
          and ccd.p_date < '2024-02-01'
      ) ccd
    join test.tmp_th_m_202401 t on to_date(t.fin_date) = ccd.coordinate_date and ccd.staff_id = t.ticket_delivery_staff_info_id
    group by  1,2
  ) dis on dis.fin_date = a1.fin_date and dis.ticket_delivery_staff_info_id = a1.ticket_delivery_staff_info_id
left join
  (
    select
      bc.client_id
      ,bc.client_name
    from  test.tmp_tmp_ex_big_clients_id_detail bc
  ) bc on bc.client_id = a1.client_id
left join
  (
    select
      kp.id
      ,kp.name
    from fle_dim.dim_fle_ka_profile_da kp
    where
      kp.p_date = '2024-01-25'
  ) kp on kp.id = a1.client_id
left join
  (
    select
      am.staff_info_id
      ,count(distinct case when am.abnormal_object = '0' then am.id when am.abnormal_object = '1' then am.average_merge_key end ) abnormal_count
    from fle_dim.dim_bi_abnormal_message_da am
    where
      am.p_date = '2024-01-31'
      and am.isdel = '0'
      and (am.isappeal < '5' or am.isappeal is null)
      and am.created_at > date_add(CURRENT_DATE(), interval -2 month)
    group by 1
  ) ab on ab.staff_info_id = a1.ticket_delivery_staff_info_id
left join
  (
      select
          p1.pno
      from tmp_th_m_pho_202401 p1
      where
          p1.call_num > '0'
      group by 1
  ) p2 on p2.pno = a1.pno
left join
  (
    select
      *
    from tmp_th_m_pho_202401 p1
    where
      p1.rk = '1'
  ) p1 on p1.pno = a1.pno
  ;




