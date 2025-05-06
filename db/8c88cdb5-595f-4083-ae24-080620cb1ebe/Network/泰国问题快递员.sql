
with
 handover2 as
(
    select
        fn.pno
        ,fn.pno_type
        ,fn.store_id
        ,fn.staff_info_id
        ,fn.finished_at
        ,fn.pi_state
    from
        (
            select
                    pr.pno
                    ,pr.store_id
                    ,pr.staff_info_id
                    ,pr.sub_staff_info_id
                    ,pi.state pi_state
                    ,convert_tz(pi.updated_at,'+00:00','+08:00') as pi_updated_at
                    ,if(pi.returned=1,'退件','正向件') as pno_type
                    ,convert_tz(pi.finished_at,'+00:00','+08:00') as finished_at
                from
                    ( # 所有22点前交接包裹找到最后一次交接的人
                        select
                            pr.*
                        from
                            (
                                select
                                    pr.pno
                                    ,rid.staff_info_id
                                    ,pr.store_id
                                    ,rid.sub_staff_info_id
                                    ,row_number() over(partition by pr.pno order by convert_tz(pr.created_at,'+00:00','+08:00') desc) as rnk
                                from fle_staging.`ticket_delivery`  pr
                               join tmpale.staff_info_record_info_day rid on pr.staff_info_id=rid.sub_staff_info_id
                                where
                                pr.created_at >=concat(date_sub(current_date,interval 1 day), ' 16:00:00')
                                and pr.created_at <concat(date_sub(current_date,interval 0 day), ' 14:00:00')
                            ) pr
                            where  pr.rnk=1
                    ) pr
                    left join fle_staging.parcel_info pi on pr.pno = pi.pno and pi.created_at >=concat(date_sub(current_date,interval 60 day), ' 16:00:00') and pi.created_at <concat(date_sub(current_date,interval 0 day), ' 09:00:00')
        )fn
)
,
 al as
     (
         select
            t1.网点
            ,t1.大区
            ,t1.片区
            ,t1.员工ID
            ,t1.快递员姓名
            ,t1.work_days  在职时长
            ,t1.快递员类型
            ,ifnull(f2.交接量_非退件, 0)+ifnull(ff2.ct, 0) 交接量_非退件
            ,ifnull(f6.非退件妥投量, 0) 非退件妥投量
            ,ifnull(f6.退件妥投量_按地址转换, 0) 退件妥投量_按地址转换
            ,ifnull(f6.非退件妥投量_大件折算, 0 ) 非退件妥投量_大件折算
            ,ifnull(pk.ticket_pickup_cn,0) 揽收任务数
            ,ifnull(pk.pickup_pno_cn,0) 揽收包裹量
            ,f6.finished_at as 22点前快递员结束派件时间
            ,if((ifnull(f2.交接量_非退件,0)+ ifnull(ff2.ct,0))<>0 ,concat(round(f6.非退件妥投量/(ifnull(f2.交接量_非退件,0)+ ifnull(ff2.ct,0))*100,2),'%'),0) as 妥投率
            ,row_number() over (partition by t1.网点 order by ifnull(f6.非退件妥投量, 0)) rk
#                         ,if(f5.staff_info_id is not null, '是', null) 是否出勤不达标
            ,case
                when (ifnull(f6.非退件妥投量_大件折算,0)+ifnull(f6.退件妥投量_按地址转换,0))=0 then '是'
                when t1.网点类型=1 and sdt.total_should_delivery_pno/ss.attendance_staff_cn>=100 and (ifnull(f6.非退件妥投量_大件折算,0)+ifnull(f6.退件妥投量_按地址转换,0))<80  then '是'
                when t1.网点类型=1 and sdt.total_should_delivery_pno/ss.attendance_staff_cn<100 and (ifnull(f6.非退件妥投量_大件折算,0)+ifnull(f6.退件妥投量_按地址转换,0))<sdt.total_should_delivery_pno/ss.attendance_staff_cn*0.8  then '是'
                when t1.网点类型=10 and sdt.total_should_delivery_pno/ss.attendance_staff_cn>=80 and (ifnull(f6.非退件妥投量_大件折算,0)+ifnull(f6.退件妥投量_按地址转换,0))<65  then '是'
                when t1.网点类型=10 and sdt.total_should_delivery_pno/ss.attendance_staff_cn<80 and (ifnull(f6.非退件妥投量_大件折算,0)+ifnull(f6.退件妥投量_按地址转换,0))<sdt.total_should_delivery_pno/ss.attendance_staff_cn*0.8  then '是'
                else null
            end as 是否低人效
        from
            (
                select
                    dt.region_name 大区
                    ,dt.piece_name 片区
                    ,dt.store_name 网点
                    ,dt.store_category as 网点类型
                    ,rid.staff_info_id as 员工ID
                    ,rid.store_id
                    ,hsi.name as  快递员姓名
                    ,rid.work_days
                    ,case when rid.job_title=13 then 'bike' when rid.job_title=110 then 'van' when rid.job_title=452 then 'boat' when rid.job_title=1497 then 'Van Feeder'  else '' end as 快递员类型
                    #,datediff(curdate(), hsi.hire_date)  在职时长
                from tmpale.staff_info_record_info_day rid
                join bi_pro.hr_staff_info hsi on hsi.staff_info_id =rid.staff_info_id
                left join dwm.dim_th_sys_store_rd dt on dt.store_id =rid.store_id and dt.stat_date = current_date
                left join tmpale.staff_info_record_info_day rid1 on rid.staff_info_id=rid1.staff_info_id and rid1.if_support='Y'
                where rid.if_support='N' and rid1.staff_info_id is null
            ) t1
        left join
            (-- 非子母件交接量
                select
                    fn.staff_info_id as 员工ID
                    ,count(distinct if(fn.pno_type='正向件', fn.pno ,null)) as 交接量_非退件
                from  handover2 fn
                group by 1
            )f2 on f2.员工ID = t1.员工ID
        left join
            (-- 子母件交接量
                select
                    ff.staff_info_id
                    ,sum(ff.mps_count) ct
                from
                (
                    select
                        pr.pno
                        ,rid.staff_info_id
                        ,pim.mps_count
                        ,sum(pim.mps_count) as 1mps_count
                    from fle_staging.`ticket_delivery`  pr
                    join tmpale.staff_info_record_info_day rid on pr.staff_info_id=rid.sub_staff_info_id
                    left join fle_staging.parcel_info_mps_relation pim on pim.mother_pno =pr.pno -- 子母单关联
                    left join fle_staging.parcel_info pi on pr.pno=pi.pno
                    where
                        pr.created_at >=concat(date_sub(current_date,interval 1 day), ' 17:00:00')
                        and pr.created_at <concat(date_sub(current_date,interval 0 day), ' 10:00:00')
                        and pr.mps_delivery_category=1 -- 母件
                    #	and pr.pno='TH01124THEGB0A'
                        and pi.returned=0 -- 非退件
                    group by 1,2,3

                )ff
                group by 1
            )ff2 on ff2.staff_info_id= t1.员工ID
        left join
            (
                select
                    pi.ticket_pickup_staff_info_id
                    ,count(distinct pi.ticket_pickup_id) as ticket_pickup_cn
                    ,count(distinct pi.pno) as pickup_pno_cn
                from fle_staging.parcel_info pi
                where pi.state<9
                and pi.returned=0
                and pi.created_at >=concat(date_sub(curdate(), interval 1 day),' 17:00:00')
                and pi.created_at <=concat(curdate(),' 17:00:00')
                group by 1
            )pk on pk.ticket_pickup_staff_info_id = t1.员工ID
        left join
            ( -- 22点前最后一个妥投包裹时间
                select
                    rid.staff_info_id
                    ,max(convert_tz(pi.finished_at,'+00:00','+07:00')) as finished_at
                    ,count(distinct case when pi.returned=0  then pi.pno else null end) as 非退件妥投量
                    ,count(distinct case when pi.returned=1  then pi.dst_detail_address else null end) as 退件妥投量_按地址转换
                    ,sum(case when pi.returned=0 and if(floor(pi.weight/10000)=0,1,floor(pi.weight/10000))<if(floor((((pi.width+pi.height+pi.length) DIV 5)*5-5)/50)-1<1,1,floor((((pi.width+pi.height+pi.length) DIV 5)*5-5)/50)-1)
                                then if(floor((((pi.width+pi.height+pi.length) DIV 5)*5-5)/50)-1<1,1,floor((((pi.width+pi.height+pi.length) DIV 5)*5-5)/50)-1)
                               when pi.returned=0  then if(floor(pi.weight/10000)=0,1,floor(pi.weight/10000)) else null end) as 非退件妥投量_大件折算
                from fle_staging.parcel_info pi
                join tmpale.staff_info_record_info_day rid on pi.ticket_delivery_staff_info_id=rid.sub_staff_info_id
                left join fle_staging.parcel_info_mps_relation pimr on pimr.mother_pno =pi.pno
                where
                    pi.state=5
                    and pi.finished_at>=concat(date_sub(current_date,interval 1 day), ' 17:00:00')
                    and pi.finished_at<=concat(date_sub(current_date,interval 0 day), ' 15:00:00')
                    and pimr.id is null  -- 母件单号不算做妥投包裹，子件才算妥投包裹
                    #and pi.ticket_delivery_staff_info_id='637320'
                group by 1
             ) f6 on f6.staff_info_id = t1.员工ID
        left join
            (
                select
                    sdt.store_id
                    ,count(distinct sdt.pno) as total_should_delivery_pno
                from bi_pro.dc_should_delivery_today sdt
                where sdt.stat_date= current_date
                group by 1
            )sdt on t1.store_id=sdt.store_id
        left join
            (#网点今日出勤人数
                select
                    ss.store_id
                    ,count(distinct ss.staff_info_id) as attendance_staff_cn
                from
                    (
                        select
                            adv.staff_info_id
                            ,if(hsa.staff_info_id is null,adv.sys_store_id,hsa.store_id) as store_id
                            ,if(hsa.staff_info_id is null,hsi.job_title,hsa.job_title_id) as job_title_id
                        from bi_pro.attendance_data_v2 adv
                        join bi_pro.hr_staff_info hsi on hsi.staff_info_id =adv.staff_info_id
                        left join backyard_pro.hr_staff_apply_support_store hsa on adv.staff_info_id=hsa.staff_info_id
                            and hsa.status = 2 #支援审核通过
                            and hsa.actual_begin_date <=current_date
                            and coalesce(hsa.actual_end_date, curdate())>= current_date
                            and hsa.employment_begin_date<=current_date
                            and hsa.employment_end_date>=current_date
                        where  adv.stat_date=current_date and (adv.attendance_started_at is not null or adv.attendance_end_at is not null)
                    )ss
                where ss.job_title_id in(13,110,452,1497)
                group by 1
            )ss on t1.store_id =ss.store_id
     )
select
    a.*
from
    (
        select
            current_date p_date
            ,fn.网点
            ,fn.大区
            ,fn.片区
            ,fn.员工ID
            ,fn.快递员姓名
            ,convert_tz(swa.started_at, '+00:00', '+07:00') 上班时间
            ,convert_tz(swa.end_at, '+00:00', '+07:00') 下班时间
            ,fn.快递员类型
            ,fn.在职时长
            ,fn.交接量_非退件
            ,fn.非退件妥投量
            ,fn.非退件妥投量_大件折算
            ,fn.退件妥投量_按地址转换
            ,fn.揽收任务数
            ,fn.揽收包裹量
            ,fn.22点前快递员结束派件时间
            ,fn.妥投率
            ,fn.是否出勤不达标
            ,fn.是否低人效v2 是否低人效
           ,if(fn.虚假行为>0,'是',null) as 是否虚假
        from
        (
            select
                a1.*
                ,a2.是否低人效 是否低人效v2
                ,fg.虚假行为
                ,if(f5.staff_info_id is not null, '是', null) 是否出勤不达标
            from al a1
            left join al a2 on a2.员工ID = a1.员工ID and a2.rk <= 2
            left join
                (
                    select
                        a.staff_info_id
                        ,sum(a.揽件虚假量) 虚假揽件量
                        ,sum(a.妥投虚假量) 虚假妥投量
                        ,sum(a.派件标记虚假量) 虚假派件标记量
                        ,sum(a.揽件虚假量)+sum(a.妥投虚假量)+sum(a.派件标记虚假量) as 虚假行为
                    from
                        (
                            select
                                vrv.staff_info_id
                                ,'回访' type
                                ,count(distinct if(vrv.visit_result  in (6), vrv.link_id, null)) 妥投虚假量
                                ,count(distinct if(vrv.visit_result in (18,8,19,20,21,31,32,22,23,24), vrv.link_id, null)) 派件标记虚假量
                                ,count(distinct if(vrv.visit_result in (37,39,3), vrv.link_id, null)) 揽件虚假量
                            from nl_production.violation_return_visit vrv
                            where
                                vrv.visit_state = 4
                                and vrv.updated_at >= date_sub(curdate(), interval 7 hour)
                                and vrv.updated_at < date_add(curdate(), interval 17 hour) -- 昨天
                                and vrv.visit_staff_id not in (10000,10001) -- 非ivr回访
                                and vrv.type in (1,2,3,4,5,6)
                            group by 1

                            union all
                            select
                                acca.staff_info_id
                                ,'投诉' type
                                ,count(distinct if(acca.complaints_type = 2, acca.merge_column, null)) 揽件虚假量
                                ,count(distinct if(acca.complaints_type = 1, acca.merge_column, null)) 妥投虚假量
                                ,count(distinct if(acca.complaints_type = 3, acca.merge_column, null)) 派件标记虚假量
                            from nl_production.abnormal_customer_complaint_authentic acca
                            where
                                acca.callback_state = 2
                                and acca.qaqc_callback_result in (2,3)
                                and acca.qaqc_callback_at >=date_sub(curdate(), interval 7 hour)
                                and acca.qaqc_callback_at <  date_add(curdate(), interval 17 hour)  -- 昨天
                                and acca.type = 1
                                and acca.complaints_type in (1,2,3)
                            group by 1
                        ) a
                    group by 1
                )fg on fg.staff_info_id = a1.员工ID
            left join
                ( --
                    select
                        a2.staff_info_id
                        ,a2.sys_store_id
                        ,a2.attendance_started_at
                        ,a2.shift_start
                        ,a2.attendance_end_at
                    from
                        (
                            select
                                ad.staff_info_id
                                ,hsi.sys_store_id
                                ,ad.shift_start
                                ,ad.attendance_started_at
                                ,ad.attendance_end_at
                                ,row_number() over (partition by hsi.sys_store_id order by timestampdiff(minute , concat(ad.stat_date, ' ', ad.shift_start), ad.attendance_started_at) desc) rk
                            from bi_pro.attendance_data_v2 ad
                            left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id
                            where
                                ad.stat_date = curdate()
                                and ad.attendance_started_at > concat(ad.stat_date, ' ', ad.shift_start)
                                and hsi.sys_store_id != -1
                                and hsi.is_sub_staff = 0
                                and hsi.job_title in (13,110,452)
                                and hsi.state = 1
                                and timestampdiff(minute , concat(ad.stat_date, ' ', ad.shift_start), ad.attendance_started_at) > 30

                        ) a2
                    where
                        a2.rk <= 2
                ) f5 on f5.staff_info_id = a1.员工ID
        )fn
        left join backyard_pro.staff_work_attendance swa on swa.staff_info_id = fn.员工ID and swa.attendance_date = curdate()
) a
where
a.是否虚假 is not null
or a.是否低人效 is not null
or a.是否出勤不达标 is not null

union all

select
    curdate() p_date
    ,dt.store_name 网点
    ,dt.region_name 大区
    ,dt.piece_name 片区
    ,ad.staff_info_id 员工ID
    ,hsi.name 快递员姓名
    ,ad.attendance_started_at 上班时间
    ,ad.attendance_end_at 下班时间
    ,case hsi.job_title
        when 13 then  'bike'
        when 110 then 'van'
        when 452 then'boat'
    end 快递员类型
    ,datediff(curdate(), hsi.hire_date) 在职时长
    ,'' 交接量_非退件
    ,'' 非退件妥投量
    ,'' 非退件妥投量_大件折算
    ,'' 退件妥投量_按地址转换
    ,'' 揽收任务数
    ,'' 揽收包裹量
    ,'' 22点前快递员结束派件时间
    ,'' 妥投率
    ,'是' 是否出勤不达标
    ,'' 是否低人效
    ,'' 是否虚假
from bi_pro.attendance_data_v2 ad
left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id
left join dwm.dim_th_sys_store_rd dt on dt.store_id = hsi.sys_store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
where ad.attendance_time + ad.BT+ ad.BT_Y + ad.AB >0 -- 应出勤
    and ad.stat_date = curdate()
    and ad.attendance_started_at is null
    and ad.attendance_end_at is null
    and hsi.sys_store_id != -1
    and hsi.is_sub_staff = 0
    and hsi.job_title in (13,110,452)
    and hsi.state = 1

;
# #                     left join
#                         ( --
#                             select
#                                 ad.staff_info_id
#                                 ,hsi.sys_store_id
#                                 ,ad.attendance_started_at
#                                 ,ad.attendance_end_at
#                             from bi_pro.attendance_data_v2 ad
#                             left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id
#                             where ad.attendance_time + ad.BT+ ad.BT_Y + ad.AB >0 -- 应出勤
#                                 and ad.stat_date = curdate()
#                                 and ad.attendance_started_at is null
#                                 and ad.attendance_end_at is null
#                                 and hsi.sys_store_id != -1
#                                 and hsi.is_sub_staff = 0
#                                 and hsi.job_title in (13,110,452)
#
#                             union all
#
#                             select
#                                 a2.staff_info_id
#                                 ,a2.sys_store_id
#                                 ,a2.attendance_started_at
#                                 ,a2.attendance_end_at
#                             from
#                                 (
#                                     select
#                                         ad.staff_info_id
#                                         ,hsi.sys_store_id
#                                         ,ad.attendance_started_at
#                                         ,ad.attendance_end_at
#                                         ,row_number() over (partition by hsi.sys_store_id order by ad.attendance_started_at desc) rk
#                                     from bi_pro.attendance_data_v2 ad
#                                     left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id
#                                     where
#                                         ad.stat_date = curdate()
#                                         and ad.attendance_started_at > concat(curdate(), ' ', ad.shift_start)
#                                         and hsi.sys_store_id != -1
#                                         and hsi.is_sub_staff = 0
#                                         and hsi.job_title in (13,110,452)
#                                 ) a2
#                             where
#                                 a2.rk <= 2
#                         ) f5 on f5.staff_info_id = t1.员工ID
# select
#     ad.staff_info_id
#     ,ad.attendance_started_at
#     ,concat('2023-11-10', ' ', ad.shift_start)
#     ,if(ad.attendance_started_at > concat('2023-11-10', ' ', ad.shift_start),1,0)
# from bi_pro.attendance_data_v2 ad
# where
#     ad.staff_info_id = '606757'
#     and ad.stat_date = '2023-11-10'
#                    select
#                         ad.staff_info_id
#                         ,hsi.sys_store_id
#                         ,ad.attendance_started_at
#                         ,ad.attendance_end_at
#                     from bi_pro.attendance_data_v2 ad
#                     left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id
#                     where ad.attendance_time + ad.BT+ ad.BT_Y + ad.AB >0 -- 应出勤
#                         and ad.stat_date = curdate()
#                         and ad.attendance_started_at is null
#                         and ad.attendance_end_at is null
#                         and hsi.sys_store_id != -1
#                         and hsi.is_sub_staff = 0
#                         and hsi.job_title in (13,110,452)
#                         and hsi.state = 1
#
#                     union all
