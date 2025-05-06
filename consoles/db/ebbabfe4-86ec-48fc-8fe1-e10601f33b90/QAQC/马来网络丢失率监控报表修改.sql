select
  pi.pickup_date
  ,pi.name DC
  ,pi.pnt 操作量
  ,nvl(lt.pnt,0) 丢失量
  ,(nvl(lt.pnt,0)/pi.pnt)*100000 丢失率_判责维度

from
(
select
  date(convert_tz(pc.`created_at`,'+00:00','+08:00')) pickup_date
 ,case when pc.store_name like 'OS%' then pc.store_name
       when pc.store_name='01 MS1_HUB Klang' then 'OS-FFM'
       else null end as name
 ,count(distinct pc.pno ) pnt
From my_staging.ipc_order_counter_record pc
where pc.created_at >=convert_tz('${sdate}','+08:00','+00:00')
and pc.created_at < date_add(convert_tz('${edate}','+08:00','+00:00'),interval 1 day)
and (pc.store_name like 'OS%' or pc.store_name='01 MS1_HUB Klang')
group by 1,2
order by 1,2
)pi
left join
(
  select
    prn.name
   ,lt.updated_at
   ,sum(1/pr.dcs) pnt
   from
      (
        select
          lt.pno
         ,max(date(lt.updated_at)) updated_at
        from my_bi.parcel_lose_task lt
        where lt.duty_result=1
        and lt.state=6
        and lt.updated_at>='${sdate}'
        and lt.updated_at<='${edate}'
        group by 1
      )lt
    join
    (
       SELECT
        distinct
         pr.lose_task_id
         ,lt.pno
         ,sy.name
       from my_bi.parcel_lose_responsible pr
       left join my_bi.parcel_lose_task lt on pr.lose_task_id =lt.id
       left join my_staging.sys_store sy on pr.store_id=sy.id
       where pr.created_at >='${sdate}'
       and sy.name like 'OS%'
     )prn on lt.pno=prn.pno
   left join
     (
       SELECT
         lt.pno
         ,count(distinct sy.name) dcs
       from my_bi.parcel_lose_responsible pr
       left join my_bi.parcel_lose_task lt on pr.lose_task_id =lt.id
       left join my_staging.sys_store sy on pr.store_id=sy.id
       where pr.created_at >='${sdate}'
       and sy.name like 'OS%'
       group by 1
       order by 1
     )pr on lt.pno=pr.pno
  group by 1,2
  order by 1,2
)lt on pi.pickup_date=lt.updated_at and pi.name=lt.name

group by 1,2
order by 1,2