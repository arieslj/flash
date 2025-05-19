with t as
    (
        select
            t.*
            ,hsi2.company_name_ef
            ,hsi2.identity
            ,hsi2.mobile
            ,hsi.`name`
            ,case hsi.`state`
                when 1 then '在职'
                when 2 then '离职'
            end as state
            ,hsi.hire_date
            ,hjt.job_name
            ,concat(t.sub_id, '_', date(t.sub_staff_clock_data)) p_key
            ,substring_index(substring_index(t.sub_clock_pic_id, '_', -1), '.', 1) clock_unix_time
        from tmpale.tmp_ph_fake_sub_lj t
        left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = t.staff_id
        left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = t.sub_id
    )
select
    t1.sub_id 外协id
    ,t1.company_name_ef 外协公司
    ,t1.identity 身份证ID
    ,t1.sub_clock_pic_id 外协打卡图片id
    ,t1.region 大区
    ,t1.sim_dsitince 相似距离
    ,t1.staff_id 正式员工id
    ,t1.job_name 正式员工职位
    ,t1.hire_date 入职时间
    ,t1.staff_store 正式员工所属网点
    ,t1.sub_staff_store 外协人员所属网点
    ,t1.staff_pic 正式员工筛选底片
    ,t1.sub_clock_pic 外协打卡图片
    ,t1.sub_staff_clock_data 外协打卡时间
    ,t1.staff_clock_date 正式员工打卡日期
    ,p1.p_count 正式员工使用外协账号打卡后妥投的包裹数量
    ,if(t1.sub_staff_clock_data > t1.hire_date, 'y', 'n') 是否入职后打卡
from t t1
left join
    (
        select
            t1.sub_id
            ,date(t1.sub_staff_clock_data) p_date
            ,concat(t1.sub_id, '_', date(t1.sub_staff_clock_data)) p_key
            ,count(distinct pi.pno) p_count
        from ph_staging.parcel_info pi
        join t t1 on t1.sub_id = pi.ticket_delivery_staff_info_id
        where
            pi.state = 5
            and pi.finished_at >= date_sub(from_unixtime(t1.clock_unix_time), interval 8 hour)
            and pi.finished_at <= date_sub(date_add(t1.sub_staff_clock_data,interval 1 day), interval 8 hour )
        group by 1,2,3
    ) p1 on p1.p_key = t1.p_key;
;-- -. . -..- - / . -. - .-. -.--
select
    date (convert_tz(pi.created_at, '+00:00', '+08:00')) 揽收日期
    ,pi.ticket_pickup_staff_info_id 快递员
    ,count(pi.pno) 揽收量
from ph_staging.parcel_info pi
where
    pi.created_at > '2025-04-27 17:00:00'
    and pi.created_at < '2025-04-29 17:00:00'
    and pi.returned = 0
    and pi.state < 9
    and pi.ticket_pickup_staff_info_id in ('228938','171867','216431','157799','122497','211723','121299','145120','166975','154050','152826','137727','120877','131532','208188','153881','217938','240903','253700','167320','174303','191675','152837','203810','167032','175269','161471','175273','199936','161456','212593','256856','256866','175638','212604','175288')
group by 1,2;