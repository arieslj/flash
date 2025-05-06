#泰国SPBDC的表，需要加一个近7天每一天的外协人数，支援人数，妥投率，积压量，正式员工平均人效，到件量，揽收量
#网点	网点id	建议优先级	片区	类型	开业日期	分类	部门ID	大区	派次	区域	province_code	是否GBKK	province	city_code	city	district_code	district

select
*
from
(
select
ss.id
,ss.name
,mr.name 'mr_name'
,mp.name 'mp_name'
,if(ss.province_code in ('TH01','TH02','TH03','TH04'),'GBKK','NON-GBKK') 'IS_GBKK'
from
fle_staging.sys_store ss
LEFT JOIN fle_staging.`sys_manage_region` mr on ss.`manage_region`= mr.`id`
LEFT JOIN `fle_staging`.`sys_manage_piece` mp on ss.`manage_piece`= mp.`id`
where 1=1
and ss.category in (1,10)
AND SS.state =1
) tbq1
left join
(
SELECT
swa.`started_store_id` AS 'store_id_1'
,count(distinct(if(si.`formal`='0' and si.job_title in (13,110,452) and swa.attendance_date =CURDATE()-interval 1 day ,swa.`staff_info_id`,null))) AS 'out_src_1'
,count(distinct(if(si.`formal`='0' and si.job_title in (13,110,452) and swa.attendance_date =CURDATE()-interval 2 day ,swa.`staff_info_id`,null))) AS 'out_src_2'
,count(distinct(if(si.`formal`='0' and si.job_title in (13,110,452) and swa.attendance_date =CURDATE()-interval 3 day ,swa.`staff_info_id`,null))) AS 'out_src_3'
,count(distinct(if(si.`formal`='0' and si.job_title in (13,110,452) and swa.attendance_date =CURDATE()-interval 4 day ,swa.`staff_info_id`,null))) AS 'out_src_4'
,count(distinct(if(si.`formal`='0' and si.job_title in (13,110,452) and swa.attendance_date =CURDATE()-interval 5 day ,swa.`staff_info_id`,null))) AS 'out_src_5'
,count(distinct(if(si.`formal`='0' and si.job_title in (13,110,452) and swa.attendance_date =CURDATE()-interval 6 day ,swa.`staff_info_id`,null))) AS 'out_src_6'
,count(distinct(if(si.`formal`='0' and si.job_title in (13,110,452) and swa.attendance_date =CURDATE()-interval 7 day ,swa.`staff_info_id`,null))) AS 'out_src_7'
FROM backyard_pro.staff_work_attendance AS swa
JOIN `fle_staging`.`staff_info` AS si on swa.`staff_info_id`=si.`id`
WHERE
swa.`attendance_date`>=date_add(current_date(),-7)
and swa.`attendance_date`<current_date()
GROUP BY
swa.`started_store_id`
) tbq2 on tbq1.id=tbq2.store_id_1
left join
(
select
*
from
(
select
网点id 'store_id_2'
,统计日期
,打卡的支援快递员 'spt_crr_1'
,lag(打卡的支援快递员,1,null) over(partition by 网点id order by 统计日期) 'spt_crr_2'
,lag(打卡的支援快递员,2,null) over(partition by 网点id order by 统计日期) 'spt_crr_3'
,lag(打卡的支援快递员,3,null) over(partition by 网点id order by 统计日期) 'spt_crr_4'
,lag(打卡的支援快递员,4,null) over(partition by 网点id order by 统计日期) 'spt_crr_5'
,lag(打卡的支援快递员,5,null) over(partition by 网点id order by 统计日期) 'spt_crr_6'
,lag(打卡的支援快递员,6,null) over(partition by 网点id order by 统计日期) 'spt_crr_7'
,绝对妥投率 'dlv_rate_1'
,lag(绝对妥投率,1,null) over(partition by 网点id order by 统计日期) 'dlv_rate_2'
,lag(绝对妥投率,2,null) over(partition by 网点id order by 统计日期) 'dlv_rate_3'
,lag(绝对妥投率,3,null) over(partition by 网点id order by 统计日期) 'dlv_rate_4'
,lag(绝对妥投率,4,null) over(partition by 网点id order by 统计日期) 'dlv_rate_5'
,lag(绝对妥投率,5,null) over(partition by 网点id order by 统计日期) 'dlv_rate_6'
,lag(绝对妥投率,6,null) over(partition by 网点id order by 统计日期) 'dlv_rate_7'
,未妥投 'detained_1'
,lag(未妥投,1,null) over(partition by 网点id order by 统计日期) 'detained_2'
,lag(未妥投,2,null) over(partition by 网点id order by 统计日期) 'detained_3'
,lag(未妥投,3,null) over(partition by 网点id order by 统计日期) 'detained_4'
,lag(未妥投,4,null) over(partition by 网点id order by 统计日期) 'detained_5'
,lag(未妥投,5,null) over(partition by 网点id order by 统计日期) 'detained_6'
,lag(未妥投,6,null) over(partition by 网点id order by 统计日期) 'detained_7'
from
DWm.dwd_th_network_spill_detl_rd dtnspdr
order by 1,2
) tb1
where 统计日期=CURDATE() - interval 1 day
) tbq3 on tbq1.id=tbq3.store_id_2
left join
(
select
pi2.ticket_delivery_store_id 'store_id_3'
,count(distinct if(date(pi2.finished_at+interval 8 hour)=CURDATE()-interval 1 day,pi2.pno,null))/count(distinct if(date(pi2.finished_at+interval 8 hour)=CURDATE()-interval 1 day,pi2.ticket_delivery_staff_info_id ,null)) 'eff_fml_1'
,count(distinct if(date(pi2.finished_at+interval 8 hour)=CURDATE()-interval 2 day,pi2.pno,null))/count(distinct if(date(pi2.finished_at+interval 8 hour)=CURDATE()-interval 1 day,pi2.ticket_delivery_staff_info_id ,null)) 'eff_fml_2'
,count(distinct if(date(pi2.finished_at+interval 8 hour)=CURDATE()-interval 3 day,pi2.pno,null))/count(distinct if(date(pi2.finished_at+interval 8 hour)=CURDATE()-interval 1 day,pi2.ticket_delivery_staff_info_id ,null)) 'eff_fml_3'
,count(distinct if(date(pi2.finished_at+interval 8 hour)=CURDATE()-interval 4 day,pi2.pno,null))/count(distinct if(date(pi2.finished_at+interval 8 hour)=CURDATE()-interval 1 day,pi2.ticket_delivery_staff_info_id ,null)) 'eff_fml_4'
,count(distinct if(date(pi2.finished_at+interval 8 hour)=CURDATE()-interval 5 day,pi2.pno,null))/count(distinct if(date(pi2.finished_at+interval 8 hour)=CURDATE()-interval 1 day,pi2.ticket_delivery_staff_info_id ,null)) 'eff_fml_5'
,count(distinct if(date(pi2.finished_at+interval 8 hour)=CURDATE()-interval 6 day,pi2.pno,null))/count(distinct if(date(pi2.finished_at+interval 8 hour)=CURDATE()-interval 1 day,pi2.ticket_delivery_staff_info_id ,null)) 'eff_fml_6'
,count(distinct if(date(pi2.finished_at+interval 8 hour)=CURDATE()-interval 7 day,pi2.pno,null))/count(distinct if(date(pi2.finished_at+interval 8 hour)=CURDATE()-interval 1 day,pi2.ticket_delivery_staff_info_id ,null)) 'eff_fml_7'
from fle_staging.parcel_info pi2
left join fle_staging.staff_info si on pi2.ticket_delivery_staff_info_id =si.id
where 1=1
and si.formal =1
and si.job_title in (13,110,452)
and pi2.finished_at >CURDATE()-interval 10 day
group by 1
) tbq4 on tbq1.id=tbq4.store_id_3
left join
(
select
*
from
(
select
store_id 'store_id_4'
,stat_date
,arrive_cnt 'arr_1'
,lag(arrive_cnt,1,null) over(partition by store_id order by stat_date) 'arr_2'
,lag(arrive_cnt,2,null) over(partition by store_id order by stat_date) 'arr_3'
,lag(arrive_cnt,3,null) over(partition by store_id order by stat_date) 'arr_4'
,lag(arrive_cnt,4,null) over(partition by store_id order by stat_date) 'arr_5'
,lag(arrive_cnt,5,null) over(partition by store_id order by stat_date) 'arr_6'
,lag(arrive_cnt,6,null) over(partition by store_id order by stat_date) 'arr_7'

,pickup_cnt 'pick_1'
,lag(pickup_cnt,1,null) over(partition by store_id order by stat_date) 'pick_2'
,lag(pickup_cnt,2,null) over(partition by store_id order by stat_date) 'pick_3'
,lag(pickup_cnt,3,null) over(partition by store_id order by stat_date) 'pick_4'
,lag(pickup_cnt,4,null) over(partition by store_id order by stat_date) 'pick_5'
,lag(pickup_cnt,5,null) over(partition by store_id order by stat_date) 'pick_6'
,lag(pickup_cnt,6,null) over(partition by store_id order by stat_date) 'pick_7'

from tmpale.dwd_th_store_basic
) tb1
where tb1.stat_date =CURDATE()-interval 1 day
) tbq5 on tbq1.id=tbq5.store_id_4
left join
(
select
pi2.dst_store_id 'store_id_5'
,count(distinct if(date(pi2.created_at+interval 7 hour)=CURDATE()-interval 1 day,pi2.pno)) 'dst_pk_1'
,count(distinct if(date(pi2.created_at+interval 7 hour)=CURDATE()-interval 2 day,pi2.pno)) 'dst_pk_2'
,count(distinct if(date(pi2.created_at+interval 7 hour)=CURDATE()-interval 3 day,pi2.pno)) 'dst_pk_3'
,count(distinct if(date(pi2.created_at+interval 7 hour)=CURDATE()-interval 4 day,pi2.pno)) 'dst_pk_4'
,count(distinct if(date(pi2.created_at+interval 7 hour)=CURDATE()-interval 5 day,pi2.pno)) 'dst_pk_5'
,count(distinct if(date(pi2.created_at+interval 7 hour)=CURDATE()-interval 6 day,pi2.pno)) 'dst_pk_6'
,count(distinct if(date(pi2.created_at+interval 7 hour)=CURDATE()-interval 7 day,pi2.pno)) 'dst_pk_7'
from fle_staging.parcel_info pi2
where 1=1
and pi2.returned=0
and pi2.created_at>=date_sub(CURDATE()-interval 7 day,interval 7 hour)
and pi2.created_at< date_sub(CURDATE()-interval 0 day,interval 7 hour)
group by 1
) tbq6 on tbq1.id=tbq6.store_id_5
where name not like 'Virtual%'
and COALESCE(store_id_1,store_id_2,store_id_3,store_id_4,store_id_5) is not null










