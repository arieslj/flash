
with di as
(
 SELECT
 	pi.client_id
 	,date(convert_tz(pi.created_at,'+00:00','+07:00')) dat
    ,count(distinct pi.pno) ct1
    ,count(distinct if(di.rejection_category=1,di.pno,null)) ct2
  from fle_staging.diff_info di
  join fle_staging.parcel_info pi on pi.pno=di.pno
  where di.diff_marker_category in (2,17)
  and pi.returned=0
  and pi.cod_enabled=1
  and pi.created_at >= date_sub(current_date,interval 3 month)
  group by 1,2
),
pi as
  (
  	select
  		pi.client_id
  		,date(convert_tz(pi.created_at,'+00:00','+07:00')) dat
  		,count(distinct pi.pno) ct
  	from fle_staging.parcel_info pi
  	where pi.created_at >= date_sub(current_date,interval 3 month)
  	and pi.returned=0
  	and pi.state=5
	and pi.cod_enabled=1
  	group by 1,2
  )

select
t.*
,di.ct1
,di.ct2
,pi.ct ct3
from
(
SELECT
    ki.created_at
	,ki.ka_id client_id
	,ki.cod_ok_count COD包裹揽收量
	,ki.cod_refuse_count COD包裹拒收量
	,ki.cod_refuse_count /cod_ok_count 拒收率
    ,ki.refuse_not_purchased_count 未购买商品的拒收量
    ,ki.refuse_not_purchased_count / ki.cod_refuse_count 未购买商品的拒收占比
FROM bi_pro.ka_cod_info ki

WHERE
ki.created_at >= date_sub(current_date,interval 3 month)
and ki.cod_ok_count>0
ORDER BY ka_id, created_at DESC

union all

SELECT
    ci.created_at
    ,ci.client_id
    ,ci.cod_ok_count COD包裹揽收量
    ,ci.cod_refuse_count COD包裹拒收量
    ,ci.cod_refuse_count /cod_ok_count 拒收率
    ,ci.refuse_not_purchased_count 未购买商品的拒收量
    ,ci.refuse_not_purchased_count / ci.cod_refuse_count 未购买商品的拒收占比
FROM bi_pro.cod_info ci
WHERE

   ci.customer_type_category = 1
    AND ci.created_at >= date_sub(current_date,interval 3 month)
ORDER BY client_id , created_at
)t
left join di on di.client_id=t.client_id and di.dat=t.created_at
left join pi on pi.client_id=t.client_id and pi.dat=t.created_at
where t.created_at>='${sdate}'
and t.created_at<='${edate}'
and t.client_id in('${SUBSTITUTE(SUBSTITUTE(p2,"\n",","),",","','")}')