
#分拨综合操作及时率底表建设 th_hub_kpi_base

#delete from tmpale.hub_no_unloading_timetable

#CREATE TABLE tmpale.th_hub_kpi_base_1
delete from tmpale.th_hub_kpi_base_1 where pt = date_sub(CURDATE(),interval 1 day);
insert into tmpale.th_hub_kpi_base_1
SELECT
*
,case
when 始发站实际发出时间 <= date_add(始发站计划发出时间,interval 1 minute)
then '准时发出'
when 始发站实际靠港时间 > 始发站计划靠港时间 and 线路属性 ='临时รถเสริม'
and  始发站实际发出时间 <= date_add(始发站计划发出时间,interval TIMESTAMPDIFF(minute,始发站计划靠港时间,始发站实际靠港时间)+无人值守时期等位时长+1 minute)
then '准时发出'
when 始发站实际靠港时间 > 始发站计划靠港时间
and  始发站实际发出时间 <= date_add(始发站计划发出时间,interval TIMESTAMPDIFF(minute,始发站计划靠港时间,始发站实际靠港时间)+1 minute)
then '准时发出'
when 线路属性 ='临时รถเสริม' and 始发站实际发出时间 <= date_add(始发站计划发出时间,interval 无人值守时期等位时长+1 minute)
then '准时发出'
else '延误发出'
end 是否准点发车
,始发站计划发车日期 as pt
from （
select
tt.*
,rt.全国分拨没有人卸车的时间
,case when 线路属性 ='临时รถเสริม' then COALESCE((
							CASE
									WHEN date(tt.始发站实际靠港时间) < date(tt.始发站实际发出时间) and TIME(tt.始发站实际靠港时间) <= rt.`开始时间1` AND TIME('23:59:59') >= rt.`结束时间1`
									THEN TIME_TO_SEC(rt.`结束时间1`) - TIME_TO_SEC(rt.`开始时间1`)
									WHEN date(tt.始发站实际靠港时间) < date(tt.始发站实际发出时间) and TIME(tt.始发站实际靠港时间) >= rt.`开始时间1` AND TIME('23:59:59') <= rt.`结束时间1`
									THEN TIME_TO_SEC('23:59:59') - TIME_TO_SEC(tt.始发站实际靠港时间)
									WHEN date(tt.始发站实际靠港时间) < date(tt.始发站实际发出时间) and TIME(tt.始发站实际靠港时间) <= rt.`开始时间1` AND TIME('23:59:59')> rt.`开始时间1`  AND TIME('23:59:59') < rt.`结束时间1`
									THEN TIME_TO_SEC('23:59:59') - TIME_TO_SEC(rt.`开始时间1`)
									WHEN date(tt.始发站实际靠港时间) < date(tt.始发站实际发出时间) and TIME(tt.始发站实际靠港时间) > rt.`开始时间1`AND TIME(tt.始发站实际靠港时间) < rt.`结束时间1` AND TIME('23:59:59') >= rt.`结束时间1`
									THEN TIME_TO_SEC(rt.`结束时间1`) - TIME_TO_SEC(tt.始发站实际靠港时间)

									WHEN date(tt.始发站实际靠港时间) < date(tt.始发站实际发出时间) and TIME('00:00:01') <= rt.`开始时间1` AND TIME(tt.始发站实际发出时间) >= rt.`结束时间1`
									THEN TIME_TO_SEC(rt.`结束时间1`) - TIME_TO_SEC(rt.`开始时间1`)
									WHEN date(tt.始发站实际靠港时间) < date(tt.始发站实际发出时间) and TIME('00:00:01') >= rt.`开始时间1` AND TIME(tt.始发站实际发出时间) <= rt.`结束时间1`
									THEN TIME_TO_SEC(tt.始发站实际发出时间) - TIME_TO_SEC('00:00:01')
									WHEN date(tt.始发站实际靠港时间) < date(tt.始发站实际发出时间) and TIME('00:00:01') <= rt.`开始时间1` AND TIME(tt.始发站实际发出时间)> rt.`开始时间1`  AND TIME(tt.始发站实际发出时间) < rt.`结束时间1`
									THEN TIME_TO_SEC(tt.始发站实际发出时间) - TIME_TO_SEC(rt.`开始时间1`)
									WHEN date(tt.始发站实际靠港时间) < date(tt.始发站实际发出时间) and TIME('00:00:01') > rt.`开始时间1`AND TIME('00:00:01') < rt.`结束时间1` AND TIME(tt.始发站实际发出时间) >= rt.`结束时间1`
									THEN TIME_TO_SEC(rt.`结束时间1`) - TIME_TO_SEC('00:00:01')

									WHEN date(tt.始发站实际靠港时间) = date(tt.始发站实际发出时间) and TIME(tt.始发站实际靠港时间) <= rt.`开始时间1` AND TIME(tt.始发站实际发出时间) >= rt.`结束时间1`
									THEN TIME_TO_SEC(rt.`结束时间1`) - TIME_TO_SEC(rt.`开始时间1`)
									WHEN date(tt.始发站实际靠港时间) = date(tt.始发站实际发出时间) and TIME(tt.始发站实际靠港时间) >= rt.`开始时间1` AND TIME(tt.始发站实际发出时间) <= rt.`结束时间1`
									THEN TIME_TO_SEC(tt.始发站实际发出时间) - TIME_TO_SEC(tt.始发站实际靠港时间)
									WHEN date(tt.始发站实际靠港时间) = date(tt.始发站实际发出时间) and TIME(tt.始发站实际靠港时间) <= rt.`开始时间1` AND TIME(tt.始发站实际发出时间)> rt.`开始时间1`  AND TIME(tt.始发站实际发出时间) < rt.`结束时间1`
									THEN TIME_TO_SEC(tt.始发站实际发出时间) - TIME_TO_SEC(rt.`开始时间1`)
									WHEN date(tt.始发站实际靠港时间) = date(tt.始发站实际发出时间) and TIME(tt.始发站实际靠港时间) > rt.`开始时间1`AND TIME(tt.始发站实际靠港时间) < rt.`结束时间1` AND TIME(tt.始发站实际发出时间) >= rt.`结束时间1`
									THEN TIME_TO_SEC(rt.`结束时间1`) - TIME_TO_SEC(tt.始发站实际靠港时间)

									ELSE 0 END

					) / 60, 0)
		+ (
							 CASE
									WHEN date(tt.始发站实际靠港时间) < date(tt.始发站实际发出时间) and TIME(tt.始发站实际靠港时间) <= rt.`开始时间2` AND TIME('23:59:59') >= rt.`结束时间2`
									THEN TIME_TO_SEC(rt.`结束时间2`) - TIME_TO_SEC(rt.`开始时间2`)
									WHEN date(tt.始发站实际靠港时间) < date(tt.始发站实际发出时间) and TIME(tt.始发站实际靠港时间) >= rt.`开始时间2` AND TIME('23:59:59') <= rt.`结束时间2`
									THEN TIME_TO_SEC('23:59:59') - TIME_TO_SEC(tt.始发站实际靠港时间)
									WHEN date(tt.始发站实际靠港时间) < date(tt.始发站实际发出时间) and TIME(tt.始发站实际靠港时间) <= rt.`开始时间2` AND TIME('23:59:59')> rt.`开始时间2`  AND TIME('23:59:59') < rt.`结束时间2`
									THEN TIME_TO_SEC('23:59:59') - TIME_TO_SEC(rt.`开始时间2`)
									WHEN date(tt.始发站实际靠港时间) < date(tt.始发站实际发出时间) and TIME(tt.始发站实际靠港时间) > rt.`开始时间2`AND TIME(tt.始发站实际靠港时间) < rt.`结束时间2` AND TIME('23:59:59') >= rt.`结束时间2`
									THEN TIME_TO_SEC(rt.`结束时间2`) - TIME_TO_SEC(tt.始发站实际靠港时间)

									WHEN date(tt.始发站实际靠港时间) < date(tt.始发站实际发出时间) and TIME('00:00:01') <= rt.`开始时间2` AND TIME(tt.始发站实际发出时间) >= rt.`结束时间2`
									THEN TIME_TO_SEC(rt.`结束时间2`) - TIME_TO_SEC(rt.`开始时间2`)
									WHEN date(tt.始发站实际靠港时间) < date(tt.始发站实际发出时间) and TIME('00:00:01') >= rt.`开始时间2` AND TIME(tt.始发站实际发出时间) <= rt.`结束时间2`
									THEN TIME_TO_SEC(tt.始发站实际发出时间) - TIME_TO_SEC('00:00:01')
									WHEN date(tt.始发站实际靠港时间) < date(tt.始发站实际发出时间) and TIME('00:00:01') <= rt.`开始时间2` AND TIME(tt.始发站实际发出时间)> rt.`开始时间2`  AND TIME(tt.始发站实际发出时间) < rt.`结束时间2`
									THEN TIME_TO_SEC(tt.始发站实际发出时间) - TIME_TO_SEC(rt.`开始时间2`)
									WHEN date(tt.始发站实际靠港时间) < date(tt.始发站实际发出时间) and TIME('00:00:01') > rt.`开始时间2`AND TIME('00:00:01') < rt.`结束时间2` AND TIME(tt.始发站实际发出时间) >= rt.`结束时间2`
									THEN TIME_TO_SEC(rt.`结束时间2`) - TIME_TO_SEC('00:00:01')

									WHEN date(tt.始发站实际靠港时间) = date(tt.始发站实际发出时间) and TIME(tt.始发站实际靠港时间) <= rt.`开始时间2` AND TIME(tt.始发站实际发出时间) >= rt.`结束时间2`
									THEN TIME_TO_SEC(rt.`结束时间2`) - TIME_TO_SEC(rt.`开始时间2`)
									WHEN date(tt.始发站实际靠港时间) = date(tt.始发站实际发出时间) and TIME(tt.始发站实际靠港时间) >= rt.`开始时间2` AND TIME(tt.始发站实际发出时间) <= rt.`结束时间2`
									THEN TIME_TO_SEC(tt.始发站实际发出时间) - TIME_TO_SEC(tt.始发站实际靠港时间)
									WHEN date(tt.始发站实际靠港时间) = date(tt.始发站实际发出时间) and TIME(tt.始发站实际靠港时间) <= rt.`开始时间2` AND TIME(tt.始发站实际发出时间)> rt.`开始时间2`  AND TIME(tt.始发站实际发出时间) < rt.`结束时间2`
									THEN TIME_TO_SEC(tt.始发站实际发出时间) - TIME_TO_SEC(rt.`开始时间2`)
									WHEN date(tt.始发站实际靠港时间) = date(tt.始发站实际发出时间) and TIME(tt.始发站实际靠港时间) > rt.`开始时间2`AND TIME(tt.始发站实际靠港时间) < rt.`结束时间2` AND TIME(tt.始发站实际发出时间) >= rt.`结束时间2`
									THEN TIME_TO_SEC(rt.`结束时间2`) - TIME_TO_SEC(tt.始发站实际靠港时间)

									ELSE 0 END

					) / 60
			+ (
							 CASE
									WHEN date(tt.始发站实际靠港时间) < date(tt.始发站实际发出时间) and TIME(tt.始发站实际靠港时间) <= rt.`开始时间3` AND TIME('23:59:59') >= rt.`结束时间3`
									THEN TIME_TO_SEC(rt.`结束时间3`) - TIME_TO_SEC(rt.`开始时间3`)
									WHEN date(tt.始发站实际靠港时间) < date(tt.始发站实际发出时间) and TIME(tt.始发站实际靠港时间) >= rt.`开始时间3` AND TIME('23:59:59') <= rt.`结束时间3`
									THEN TIME_TO_SEC('23:59:59') - TIME_TO_SEC(tt.始发站实际靠港时间)
									WHEN date(tt.始发站实际靠港时间) < date(tt.始发站实际发出时间) and TIME(tt.始发站实际靠港时间) <= rt.`开始时间3` AND TIME('23:59:59')> rt.`开始时间3`  AND TIME('23:59:59') < rt.`结束时间3`
									THEN TIME_TO_SEC('23:59:59') - TIME_TO_SEC(rt.`开始时间3`)
									WHEN date(tt.始发站实际靠港时间) < date(tt.始发站实际发出时间) and TIME(tt.始发站实际靠港时间) > rt.`开始时间3`AND TIME(tt.始发站实际靠港时间) < rt.`结束时间3` AND TIME('23:59:59') >= rt.`结束时间3`
									THEN TIME_TO_SEC(rt.`结束时间3`) - TIME_TO_SEC(tt.始发站实际靠港时间)

									WHEN date(tt.始发站实际靠港时间) < date(tt.始发站实际发出时间) and TIME('00:00:01') <= rt.`开始时间3` AND TIME(tt.始发站实际发出时间) >= rt.`结束时间3`
									THEN TIME_TO_SEC(rt.`结束时间3`) - TIME_TO_SEC(rt.`开始时间3`)
									WHEN date(tt.始发站实际靠港时间) < date(tt.始发站实际发出时间) and TIME('00:00:01') >= rt.`开始时间3` AND TIME(tt.始发站实际发出时间) <= rt.`结束时间3`
									THEN TIME_TO_SEC(tt.始发站实际发出时间) - TIME_TO_SEC('00:00:01')
									WHEN date(tt.始发站实际靠港时间) < date(tt.始发站实际发出时间) and TIME('00:00:01') <= rt.`开始时间3` AND TIME(tt.始发站实际发出时间)> rt.`开始时间3`  AND TIME(tt.始发站实际发出时间) < rt.`结束时间3`
									THEN TIME_TO_SEC(tt.始发站实际发出时间) - TIME_TO_SEC(rt.`开始时间3`)
									WHEN date(tt.始发站实际靠港时间) < date(tt.始发站实际发出时间) and TIME('00:00:01') > rt.`开始时间3`AND TIME('00:00:01') < rt.`结束时间3` AND TIME(tt.始发站实际发出时间) >= rt.`结束时间3`
									THEN TIME_TO_SEC(rt.`结束时间3`) - TIME_TO_SEC('00:00:01')

									WHEN date(tt.始发站实际靠港时间) = date(tt.始发站实际发出时间) and TIME(tt.始发站实际靠港时间) <= rt.`开始时间3` AND TIME(tt.始发站实际发出时间) >= rt.`结束时间3`
									THEN TIME_TO_SEC(rt.`结束时间3`) - TIME_TO_SEC(rt.`开始时间3`)
									WHEN date(tt.始发站实际靠港时间) = date(tt.始发站实际发出时间) and TIME(tt.始发站实际靠港时间) >= rt.`开始时间3` AND TIME(tt.始发站实际发出时间) <= rt.`结束时间3`
									THEN TIME_TO_SEC(tt.始发站实际发出时间) - TIME_TO_SEC(tt.始发站实际靠港时间)
									WHEN date(tt.始发站实际靠港时间) = date(tt.始发站实际发出时间) and TIME(tt.始发站实际靠港时间) <= rt.`开始时间3` AND TIME(tt.始发站实际发出时间)> rt.`开始时间3`  AND TIME(tt.始发站实际发出时间) < rt.`结束时间3`
									THEN TIME_TO_SEC(tt.始发站实际发出时间) - TIME_TO_SEC(rt.`开始时间3`)
									WHEN date(tt.始发站实际靠港时间) = date(tt.始发站实际发出时间) and TIME(tt.始发站实际靠港时间) > rt.`开始时间3`AND TIME(tt.始发站实际靠港时间) < rt.`结束时间3` AND TIME(tt.始发站实际发出时间) >= rt.`结束时间3`
									THEN TIME_TO_SEC(rt.`结束时间3`) - TIME_TO_SEC(tt.始发站实际靠港时间)

									ELSE 0 END

					) / 60
			+ (
							 CASE
									WHEN date(tt.始发站实际靠港时间) < date(tt.始发站实际发出时间) and TIME(tt.始发站实际靠港时间) <= rt.`开始时间4` AND TIME('23:59:59') >= rt.`结束时间4`
									THEN TIME_TO_SEC(rt.`结束时间4`) - TIME_TO_SEC(rt.`开始时间4`)
									WHEN date(tt.始发站实际靠港时间) < date(tt.始发站实际发出时间) and TIME(tt.始发站实际靠港时间) >= rt.`开始时间4` AND TIME('23:59:59') <= rt.`结束时间4`
									THEN TIME_TO_SEC('23:59:59') - TIME_TO_SEC(tt.始发站实际靠港时间)
									WHEN date(tt.始发站实际靠港时间) < date(tt.始发站实际发出时间) and TIME(tt.始发站实际靠港时间) <= rt.`开始时间4` AND TIME('23:59:59')> rt.`开始时间4`  AND TIME('23:59:59') < rt.`结束时间4`
									THEN TIME_TO_SEC('23:59:59') - TIME_TO_SEC(rt.`开始时间4`)
									WHEN date(tt.始发站实际靠港时间) < date(tt.始发站实际发出时间) and TIME(tt.始发站实际靠港时间) > rt.`开始时间4`AND TIME(tt.始发站实际靠港时间) < rt.`结束时间4` AND TIME('23:59:59') >= rt.`结束时间4`
									THEN TIME_TO_SEC(rt.`结束时间4`) - TIME_TO_SEC(tt.始发站实际靠港时间)

									WHEN date(tt.始发站实际靠港时间) < date(tt.始发站实际发出时间) and TIME('00:00:01') <= rt.`开始时间4` AND TIME(tt.始发站实际发出时间) >= rt.`结束时间4`
									THEN TIME_TO_SEC(rt.`结束时间4`) - TIME_TO_SEC(rt.`开始时间4`)
									WHEN date(tt.始发站实际靠港时间) < date(tt.始发站实际发出时间) and TIME('00:00:01') >= rt.`开始时间4` AND TIME(tt.始发站实际发出时间) <= rt.`结束时间4`
									THEN TIME_TO_SEC(tt.始发站实际发出时间) - TIME_TO_SEC('00:00:01')
									WHEN date(tt.始发站实际靠港时间) < date(tt.始发站实际发出时间) and TIME('00:00:01') <= rt.`开始时间4` AND TIME(tt.始发站实际发出时间)> rt.`开始时间4`  AND TIME(tt.始发站实际发出时间) < rt.`结束时间4`
									THEN TIME_TO_SEC(tt.始发站实际发出时间) - TIME_TO_SEC(rt.`开始时间4`)
									WHEN date(tt.始发站实际靠港时间) < date(tt.始发站实际发出时间) and TIME('00:00:01') > rt.`开始时间4`AND TIME('00:00:01') < rt.`结束时间4` AND TIME(tt.始发站实际发出时间) >= rt.`结束时间4`
									THEN TIME_TO_SEC(rt.`结束时间4`) - TIME_TO_SEC('00:00:01')

									WHEN date(tt.始发站实际靠港时间) = date(tt.始发站实际发出时间) and TIME(tt.始发站实际靠港时间) <= rt.`开始时间4` AND TIME(tt.始发站实际发出时间) >= rt.`结束时间4`
									THEN TIME_TO_SEC(rt.`结束时间4`) - TIME_TO_SEC(rt.`开始时间4`)
									WHEN date(tt.始发站实际靠港时间) = date(tt.始发站实际发出时间) and TIME(tt.始发站实际靠港时间) >= rt.`开始时间4` AND TIME(tt.始发站实际发出时间) <= rt.`结束时间4`
									THEN TIME_TO_SEC(tt.始发站实际发出时间) - TIME_TO_SEC(tt.始发站实际靠港时间)
									WHEN date(tt.始发站实际靠港时间) = date(tt.始发站实际发出时间) and TIME(tt.始发站实际靠港时间) <= rt.`开始时间4` AND TIME(tt.始发站实际发出时间)> rt.`开始时间4`  AND TIME(tt.始发站实际发出时间) < rt.`结束时间4`
									THEN TIME_TO_SEC(tt.始发站实际发出时间) - TIME_TO_SEC(rt.`开始时间4`)
									WHEN date(tt.始发站实际靠港时间) = date(tt.始发站实际发出时间) and TIME(tt.始发站实际靠港时间) > rt.`开始时间4`AND TIME(tt.始发站实际靠港时间) < rt.`结束时间4` AND TIME(tt.始发站实际发出时间) >= rt.`结束时间4`
									THEN TIME_TO_SEC(rt.`结束时间4`) - TIME_TO_SEC(tt.始发站实际靠港时间)

									ELSE 0 END

					) / 60
			+ (
							 CASE
									WHEN date(tt.始发站实际靠港时间) < date(tt.始发站实际发出时间) and TIME(tt.始发站实际靠港时间) <= rt.`开始时间5` AND TIME('23:59:59') >= rt.`结束时间5`
									THEN TIME_TO_SEC(rt.`结束时间5`) - TIME_TO_SEC(rt.`开始时间5`)
									WHEN date(tt.始发站实际靠港时间) < date(tt.始发站实际发出时间) and TIME(tt.始发站实际靠港时间) >= rt.`开始时间5` AND TIME('23:59:59') <= rt.`结束时间5`
									THEN TIME_TO_SEC('23:59:59') - TIME_TO_SEC(tt.始发站实际靠港时间)
									WHEN date(tt.始发站实际靠港时间) < date(tt.始发站实际发出时间) and TIME(tt.始发站实际靠港时间) <= rt.`开始时间5` AND TIME('23:59:59')> rt.`开始时间5`  AND TIME('23:59:59') < rt.`结束时间5`
									THEN TIME_TO_SEC('23:59:59') - TIME_TO_SEC(rt.`开始时间5`)
									WHEN date(tt.始发站实际靠港时间) < date(tt.始发站实际发出时间) and TIME(tt.始发站实际靠港时间) > rt.`开始时间5`AND TIME(tt.始发站实际靠港时间) < rt.`结束时间5` AND TIME('23:59:59') >= rt.`结束时间5`
									THEN TIME_TO_SEC(rt.`结束时间5`) - TIME_TO_SEC(tt.始发站实际靠港时间)

									WHEN date(tt.始发站实际靠港时间) < date(tt.始发站实际发出时间) and TIME('00:00:01') <= rt.`开始时间5` AND TIME(tt.始发站实际发出时间) >= rt.`结束时间5`
									THEN TIME_TO_SEC(rt.`结束时间5`) - TIME_TO_SEC(rt.`开始时间5`)
									WHEN date(tt.始发站实际靠港时间) < date(tt.始发站实际发出时间) and TIME('00:00:01') >= rt.`开始时间5` AND TIME(tt.始发站实际发出时间) <= rt.`结束时间5`
									THEN TIME_TO_SEC(tt.始发站实际发出时间) - TIME_TO_SEC('00:00:01')
									WHEN date(tt.始发站实际靠港时间) < date(tt.始发站实际发出时间) and TIME('00:00:01') <= rt.`开始时间5` AND TIME(tt.始发站实际发出时间)> rt.`开始时间5`  AND TIME(tt.始发站实际发出时间) < rt.`结束时间5`
									THEN TIME_TO_SEC(tt.始发站实际发出时间) - TIME_TO_SEC(rt.`开始时间5`)
									WHEN date(tt.始发站实际靠港时间) < date(tt.始发站实际发出时间) and TIME('00:00:01') > rt.`开始时间5`AND TIME('00:00:01') < rt.`结束时间5` AND TIME(tt.始发站实际发出时间) >= rt.`结束时间5`
									THEN TIME_TO_SEC(rt.`结束时间5`) - TIME_TO_SEC('00:00:01')

									WHEN date(tt.始发站实际靠港时间) = date(tt.始发站实际发出时间) and TIME(tt.始发站实际靠港时间) <= rt.`开始时间5` AND TIME(tt.始发站实际发出时间) >= rt.`结束时间5`
									THEN TIME_TO_SEC(rt.`结束时间5`) - TIME_TO_SEC(rt.`开始时间5`)
									WHEN date(tt.始发站实际靠港时间) = date(tt.始发站实际发出时间) and TIME(tt.始发站实际靠港时间) >= rt.`开始时间5` AND TIME(tt.始发站实际发出时间) <= rt.`结束时间5`
									THEN TIME_TO_SEC(tt.始发站实际发出时间) - TIME_TO_SEC(tt.始发站实际靠港时间)
									WHEN date(tt.始发站实际靠港时间) = date(tt.始发站实际发出时间) and TIME(tt.始发站实际靠港时间) <= rt.`开始时间5` AND TIME(tt.始发站实际发出时间)> rt.`开始时间5`  AND TIME(tt.始发站实际发出时间) < rt.`结束时间5`
									THEN TIME_TO_SEC(tt.始发站实际发出时间) - TIME_TO_SEC(rt.`开始时间5`)
									WHEN date(tt.始发站实际靠港时间) = date(tt.始发站实际发出时间) and TIME(tt.始发站实际靠港时间) > rt.`开始时间5`AND TIME(tt.始发站实际靠港时间) < rt.`结束时间5` AND TIME(tt.始发站实际发出时间) >= rt.`结束时间5`
									THEN TIME_TO_SEC(rt.`结束时间5`) - TIME_TO_SEC(tt.始发站实际靠港时间)

									ELSE 0 END

					) / 60


		else 0 end AS 无人值守时期等位时长
from （
			select
			ft.proof_id
			,ft.line_name
			,case ft.line_mode when 1 then '常规รถหลัก' when 2 then '临时รถเสริม' end 线路属性
			,sfvt.name 车型
			,ft.proof_driver '司机姓名'
			,ft.proof_driver_phone '电话'
			,ft.proof_plate_number '车牌号'
			,ft.store_name 始发站
			,ft.next_store_name 目的站
			,date(ft.plan_leave_time)  始发站计划发车日期
			,ftt.plan_arrive_time 始发站计划靠港时间
			,case when ftt.real_arrive_time is null then fd.operator_time
			when fd.operator_time  is null then ftt.real_arrive_time
			when TIMESTAMPDIFF(minute,fd.`operator_time`,ftt.real_arrive_time) >= 360 then ftt.real_arrive_time
			else least(ifnull(ftt.real_arrive_time,fd.operator_time),ifnull(fd.operator_time,ftt.real_arrive_time))
			end 始发站实际靠港时间
			,ftt.real_arrive_time 始发站kit到港打卡时间
			,fd.operator_time 始发站司机fleet打卡时间
			,ft.plan_leave_time 始发站计划发出时间
			,ft.real_leave_time 始发站实际发出时间

			FROM bi_center.fleet_time ft
			left join fle_staging.fleet_van_line fvl on ft.line_id = fvl.id
			left join fle_staging.sys_fleet_van_type sfvt on ft.line_plate_type = sfvt.code and sfvt.deleted = 0
			left join bi_center.fleet_time ftt on ft.proof_id = ftt.proof_id and ftt.next_store_id = ft.store_id

			LEFT JOIN (
					SELECT
					fd.proof_id
					,fd.store_id
					,DATE_ADD(max(fd.operator_time), INTERVAL 7 HOUR) AS operator_time
					FROM fle_staging.fleet_driver_route fd
					WHERE fd.event = 1
					AND fd.state < 2
					AND fd.operator_time >= date_sub(CURDATE(),interval 3 day)
					GROUP BY fd.proof_id, fd.store_id
			) fd
			ON fd.proof_id = ft.proof_id
			AND fd.store_id = ft.store_id

			join fle_staging.sys_store ssp on ssp.id = fvl.origin_id and ssp.category in (8,12)
			join fle_staging.sys_store ssd on ssd.id = fvl.target_id and ssd.category in (8,12)

			WHERE ft.store_id IS NOT NULL
			AND ft.plan_leave_time >= date_sub(CURDATE(),interval 1 day)
			AND ft.plan_leave_time < CURDATE()
			AND ft.deleted = 0
) tt
	left join
	(
			select
			分拨,
			全国分拨没有人卸车的时间,
			case when weekday(date_sub(CURDATE(),interval 1 day))+1 = 1 and 分拨 = '07 NO3_HUB เชียงใหม่' then time('7:00') else  `开始时间1` end as '开始时间1',
            case when weekday(date_sub(CURDATE(),interval 1 day))+1 = 1 and 分拨 = '07 NO3_HUB เชียงใหม่' then time('13:00') else  `结束时间1` end as '结束时间1',
            case when weekday(date_sub(CURDATE(),interval 1 day))+1 = 1 and 分拨 = '07 NO3_HUB เชียงใหม่' then time('16:00') else  `开始时间2` end as '开始时间2',
            case when weekday(date_sub(CURDATE(),interval 1 day))+1 = 1 and 分拨 = '07 NO3_HUB เชียงใหม่' then time('17:00') else  `结束时间2` end as '结束时间2',
            case when weekday(date_sub(CURDATE(),interval 1 day))+1 = 1 and 分拨 = '07 NO3_HUB เชียงใหม่' then time('2:00') else  `开始时间3` end as '开始时间3',
            case when weekday(date_sub(CURDATE(),interval 1 day))+1 = 1 and 分拨 = '07 NO3_HUB เชียงใหม่' then time('4:00') else  `结束时间3` end as '结束时间3',
			`开始时间4`,
			`结束时间4`,
			`开始时间5`,
			`结束时间5`
			from tmpale.hub_no_unloading_timetable
	) rt on tt.始发站 = rt.分拨
)
;


#CREATE TABLE tmpale.th_hub_kpi_base_2
delete from tmpale.th_hub_kpi_base_2 where pt = date_sub(CURDATE(),interval 1 day);
insert into tmpale.th_hub_kpi_base_2
select
*
,if(修正等位时长_分钟 <= 120,'yes','no') 车辆到港120分钟内是否开始卸车
,if(卸车时长_分钟 <= `卸车标准时长/min`,'yes','no') 卸车时长是否小于对应车型的标准时长
,case when 修正等位时长_分钟 <= 120 and 卸车时长_分钟<=`卸车标准时长/min` then '及时卸车'
else '不及时卸车' end 判责
,date_sub(CURDATE(),interval 1 day) as pt
from
(
	SELECT tt.*,rt.全国分拨没有人卸车的时间 分拨无人卸车时段
	,TIMESTAMPDIFF(minute,tt.实际到达时间,tt.开始卸车时间) 等位时长_分钟
	,TIMESTAMPDIFF(second,tt.实际到达时间,tt.开始卸车时间)/60
	-    COALESCE((
							CASE
									WHEN date(tt.实际到达时间) < date(tt.开始卸车时间) and TIME(tt.实际到达时间) <= rt.`开始时间1` AND TIME('23:59:59') >= rt.`结束时间1`
									THEN TIME_TO_SEC(rt.`结束时间1`) - TIME_TO_SEC(rt.`开始时间1`)
									WHEN date(tt.实际到达时间) < date(tt.开始卸车时间) and TIME(tt.实际到达时间) >= rt.`开始时间1` AND TIME('23:59:59') <= rt.`结束时间1`
									THEN TIME_TO_SEC('23:59:59') - TIME_TO_SEC(tt.实际到达时间)
									WHEN date(tt.实际到达时间) < date(tt.开始卸车时间) and TIME(tt.实际到达时间) <= rt.`开始时间1` AND TIME('23:59:59')> rt.`开始时间1`  AND TIME('23:59:59') < rt.`结束时间1`
									THEN TIME_TO_SEC('23:59:59') - TIME_TO_SEC(rt.`开始时间1`)
									WHEN date(tt.实际到达时间) < date(tt.开始卸车时间) and TIME(tt.实际到达时间) > rt.`开始时间1`AND TIME(tt.实际到达时间) < rt.`结束时间1` AND TIME('23:59:59') >= rt.`结束时间1`
									THEN TIME_TO_SEC(rt.`结束时间1`) - TIME_TO_SEC(tt.实际到达时间)

									WHEN date(tt.实际到达时间) < date(tt.开始卸车时间) and TIME('00:00:01') <= rt.`开始时间1` AND TIME(tt.开始卸车时间) >= rt.`结束时间1`
									THEN TIME_TO_SEC(rt.`结束时间1`) - TIME_TO_SEC(rt.`开始时间1`)
									WHEN date(tt.实际到达时间) < date(tt.开始卸车时间) and TIME('00:00:01') >= rt.`开始时间1` AND TIME(tt.开始卸车时间) <= rt.`结束时间1`
									THEN TIME_TO_SEC(tt.开始卸车时间) - TIME_TO_SEC('00:00:01')
									WHEN date(tt.实际到达时间) < date(tt.开始卸车时间) and TIME('00:00:01') <= rt.`开始时间1` AND TIME(tt.开始卸车时间)> rt.`开始时间1`  AND TIME(tt.开始卸车时间) < rt.`结束时间1`
									THEN TIME_TO_SEC(tt.开始卸车时间) - TIME_TO_SEC(rt.`开始时间1`)
									WHEN date(tt.实际到达时间) < date(tt.开始卸车时间) and TIME('00:00:01') > rt.`开始时间1`AND TIME('00:00:01') < rt.`结束时间1` AND TIME(tt.开始卸车时间) >= rt.`结束时间1`
									THEN TIME_TO_SEC(rt.`结束时间1`) - TIME_TO_SEC('00:00:01')

									WHEN date(tt.实际到达时间) = date(tt.开始卸车时间) and TIME(tt.实际到达时间) <= rt.`开始时间1` AND TIME(tt.开始卸车时间) >= rt.`结束时间1`
									THEN TIME_TO_SEC(rt.`结束时间1`) - TIME_TO_SEC(rt.`开始时间1`)
									WHEN date(tt.实际到达时间) = date(tt.开始卸车时间) and TIME(tt.实际到达时间) >= rt.`开始时间1` AND TIME(tt.开始卸车时间) <= rt.`结束时间1`
									THEN TIME_TO_SEC(tt.开始卸车时间) - TIME_TO_SEC(tt.实际到达时间)
									WHEN date(tt.实际到达时间) = date(tt.开始卸车时间) and TIME(tt.实际到达时间) <= rt.`开始时间1` AND TIME(tt.开始卸车时间)> rt.`开始时间1`  AND TIME(tt.开始卸车时间) < rt.`结束时间1`
									THEN TIME_TO_SEC(tt.开始卸车时间) - TIME_TO_SEC(rt.`开始时间1`)
									WHEN date(tt.实际到达时间) = date(tt.开始卸车时间) and TIME(tt.实际到达时间) > rt.`开始时间1`AND TIME(tt.实际到达时间) < rt.`结束时间1` AND TIME(tt.开始卸车时间) >= rt.`结束时间1`
									THEN TIME_TO_SEC(rt.`结束时间1`) - TIME_TO_SEC(tt.实际到达时间)

									ELSE 0 END

					) / 60, 0)
		- (
							 CASE
									WHEN date(tt.实际到达时间) < date(tt.开始卸车时间) and TIME(tt.实际到达时间) <= rt.`开始时间2` AND TIME('23:59:59') >= rt.`结束时间2`
									THEN TIME_TO_SEC(rt.`结束时间2`) - TIME_TO_SEC(rt.`开始时间2`)
									WHEN date(tt.实际到达时间) < date(tt.开始卸车时间) and TIME(tt.实际到达时间) >= rt.`开始时间2` AND TIME('23:59:59') <= rt.`结束时间2`
									THEN TIME_TO_SEC('23:59:59') - TIME_TO_SEC(tt.实际到达时间)
									WHEN date(tt.实际到达时间) < date(tt.开始卸车时间) and TIME(tt.实际到达时间) <= rt.`开始时间2` AND TIME('23:59:59')> rt.`开始时间2`  AND TIME('23:59:59') < rt.`结束时间2`
									THEN TIME_TO_SEC('23:59:59') - TIME_TO_SEC(rt.`开始时间2`)
									WHEN date(tt.实际到达时间) < date(tt.开始卸车时间) and TIME(tt.实际到达时间) > rt.`开始时间2`AND TIME(tt.实际到达时间) < rt.`结束时间2` AND TIME('23:59:59') >= rt.`结束时间2`
									THEN TIME_TO_SEC(rt.`结束时间2`) - TIME_TO_SEC(tt.实际到达时间)

									WHEN date(tt.实际到达时间) < date(tt.开始卸车时间) and TIME('00:00:01') <= rt.`开始时间2` AND TIME(tt.开始卸车时间) >= rt.`结束时间2`
									THEN TIME_TO_SEC(rt.`结束时间2`) - TIME_TO_SEC(rt.`开始时间2`)
									WHEN date(tt.实际到达时间) < date(tt.开始卸车时间) and TIME('00:00:01') >= rt.`开始时间2` AND TIME(tt.开始卸车时间) <= rt.`结束时间2`
									THEN TIME_TO_SEC(tt.开始卸车时间) - TIME_TO_SEC('00:00:01')
									WHEN date(tt.实际到达时间) < date(tt.开始卸车时间) and TIME('00:00:01') <= rt.`开始时间2` AND TIME(tt.开始卸车时间)> rt.`开始时间2`  AND TIME(tt.开始卸车时间) < rt.`结束时间2`
									THEN TIME_TO_SEC(tt.开始卸车时间) - TIME_TO_SEC(rt.`开始时间2`)
									WHEN date(tt.实际到达时间) < date(tt.开始卸车时间) and TIME('00:00:01') > rt.`开始时间2`AND TIME('00:00:01') < rt.`结束时间2` AND TIME(tt.开始卸车时间) >= rt.`结束时间2`
									THEN TIME_TO_SEC(rt.`结束时间2`) - TIME_TO_SEC('00:00:01')

									WHEN date(tt.实际到达时间) = date(tt.开始卸车时间) and TIME(tt.实际到达时间) <= rt.`开始时间2` AND TIME(tt.开始卸车时间) >= rt.`结束时间2`
									THEN TIME_TO_SEC(rt.`结束时间2`) - TIME_TO_SEC(rt.`开始时间2`)
									WHEN date(tt.实际到达时间) = date(tt.开始卸车时间) and TIME(tt.实际到达时间) >= rt.`开始时间2` AND TIME(tt.开始卸车时间) <= rt.`结束时间2`
									THEN TIME_TO_SEC(tt.开始卸车时间) - TIME_TO_SEC(tt.实际到达时间)
									WHEN date(tt.实际到达时间) = date(tt.开始卸车时间) and TIME(tt.实际到达时间) <= rt.`开始时间2` AND TIME(tt.开始卸车时间)> rt.`开始时间2`  AND TIME(tt.开始卸车时间) < rt.`结束时间2`
									THEN TIME_TO_SEC(tt.开始卸车时间) - TIME_TO_SEC(rt.`开始时间2`)
									WHEN date(tt.实际到达时间) = date(tt.开始卸车时间) and TIME(tt.实际到达时间) > rt.`开始时间2`AND TIME(tt.实际到达时间) < rt.`结束时间2` AND TIME(tt.开始卸车时间) >= rt.`结束时间2`
									THEN TIME_TO_SEC(rt.`结束时间2`) - TIME_TO_SEC(tt.实际到达时间)

									ELSE 0 END

					) / 60
			- (
							 CASE
									WHEN date(tt.实际到达时间) < date(tt.开始卸车时间) and TIME(tt.实际到达时间) <= rt.`开始时间3` AND TIME('23:59:59') >= rt.`结束时间3`
									THEN TIME_TO_SEC(rt.`结束时间3`) - TIME_TO_SEC(rt.`开始时间3`)
									WHEN date(tt.实际到达时间) < date(tt.开始卸车时间) and TIME(tt.实际到达时间) >= rt.`开始时间3` AND TIME('23:59:59') <= rt.`结束时间3`
									THEN TIME_TO_SEC('23:59:59') - TIME_TO_SEC(tt.实际到达时间)
									WHEN date(tt.实际到达时间) < date(tt.开始卸车时间) and TIME(tt.实际到达时间) <= rt.`开始时间3` AND TIME('23:59:59')> rt.`开始时间3`  AND TIME('23:59:59') < rt.`结束时间3`
									THEN TIME_TO_SEC('23:59:59') - TIME_TO_SEC(rt.`开始时间3`)
									WHEN date(tt.实际到达时间) < date(tt.开始卸车时间) and TIME(tt.实际到达时间) > rt.`开始时间3`AND TIME(tt.实际到达时间) < rt.`结束时间3` AND TIME('23:59:59') >= rt.`结束时间3`
									THEN TIME_TO_SEC(rt.`结束时间3`) - TIME_TO_SEC(tt.实际到达时间)

									WHEN date(tt.实际到达时间) < date(tt.开始卸车时间) and TIME('00:00:01') <= rt.`开始时间3` AND TIME(tt.开始卸车时间) >= rt.`结束时间3`
									THEN TIME_TO_SEC(rt.`结束时间3`) - TIME_TO_SEC(rt.`开始时间3`)
									WHEN date(tt.实际到达时间) < date(tt.开始卸车时间) and TIME('00:00:01') >= rt.`开始时间3` AND TIME(tt.开始卸车时间) <= rt.`结束时间3`
									THEN TIME_TO_SEC(tt.开始卸车时间) - TIME_TO_SEC('00:00:01')
									WHEN date(tt.实际到达时间) < date(tt.开始卸车时间) and TIME('00:00:01') <= rt.`开始时间3` AND TIME(tt.开始卸车时间)> rt.`开始时间3`  AND TIME(tt.开始卸车时间) < rt.`结束时间3`
									THEN TIME_TO_SEC(tt.开始卸车时间) - TIME_TO_SEC(rt.`开始时间3`)
									WHEN date(tt.实际到达时间) < date(tt.开始卸车时间) and TIME('00:00:01') > rt.`开始时间3`AND TIME('00:00:01') < rt.`结束时间3` AND TIME(tt.开始卸车时间) >= rt.`结束时间3`
									THEN TIME_TO_SEC(rt.`结束时间3`) - TIME_TO_SEC('00:00:01')

									WHEN date(tt.实际到达时间) = date(tt.开始卸车时间) and TIME(tt.实际到达时间) <= rt.`开始时间3` AND TIME(tt.开始卸车时间) >= rt.`结束时间3`
									THEN TIME_TO_SEC(rt.`结束时间3`) - TIME_TO_SEC(rt.`开始时间3`)
									WHEN date(tt.实际到达时间) = date(tt.开始卸车时间) and TIME(tt.实际到达时间) >= rt.`开始时间3` AND TIME(tt.开始卸车时间) <= rt.`结束时间3`
									THEN TIME_TO_SEC(tt.开始卸车时间) - TIME_TO_SEC(tt.实际到达时间)
									WHEN date(tt.实际到达时间) = date(tt.开始卸车时间) and TIME(tt.实际到达时间) <= rt.`开始时间3` AND TIME(tt.开始卸车时间)> rt.`开始时间3`  AND TIME(tt.开始卸车时间) < rt.`结束时间3`
									THEN TIME_TO_SEC(tt.开始卸车时间) - TIME_TO_SEC(rt.`开始时间3`)
									WHEN date(tt.实际到达时间) = date(tt.开始卸车时间) and TIME(tt.实际到达时间) > rt.`开始时间3`AND TIME(tt.实际到达时间) < rt.`结束时间3` AND TIME(tt.开始卸车时间) >= rt.`结束时间3`
									THEN TIME_TO_SEC(rt.`结束时间3`) - TIME_TO_SEC(tt.实际到达时间)

									ELSE 0 END

					) / 60
			- (
							 CASE
									WHEN date(tt.实际到达时间) < date(tt.开始卸车时间) and TIME(tt.实际到达时间) <= rt.`开始时间4` AND TIME('23:59:59') >= rt.`结束时间4`
									THEN TIME_TO_SEC(rt.`结束时间4`) - TIME_TO_SEC(rt.`开始时间4`)
									WHEN date(tt.实际到达时间) < date(tt.开始卸车时间) and TIME(tt.实际到达时间) >= rt.`开始时间4` AND TIME('23:59:59') <= rt.`结束时间4`
									THEN TIME_TO_SEC('23:59:59') - TIME_TO_SEC(tt.实际到达时间)
									WHEN date(tt.实际到达时间) < date(tt.开始卸车时间) and TIME(tt.实际到达时间) <= rt.`开始时间4` AND TIME('23:59:59')> rt.`开始时间4`  AND TIME('23:59:59') < rt.`结束时间4`
									THEN TIME_TO_SEC('23:59:59') - TIME_TO_SEC(rt.`开始时间4`)
									WHEN date(tt.实际到达时间) < date(tt.开始卸车时间) and TIME(tt.实际到达时间) > rt.`开始时间4`AND TIME(tt.实际到达时间) < rt.`结束时间4` AND TIME('23:59:59') >= rt.`结束时间4`
									THEN TIME_TO_SEC(rt.`结束时间4`) - TIME_TO_SEC(tt.实际到达时间)

									WHEN date(tt.实际到达时间) < date(tt.开始卸车时间) and TIME('00:00:01') <= rt.`开始时间4` AND TIME(tt.开始卸车时间) >= rt.`结束时间4`
									THEN TIME_TO_SEC(rt.`结束时间4`) - TIME_TO_SEC(rt.`开始时间4`)
									WHEN date(tt.实际到达时间) < date(tt.开始卸车时间) and TIME('00:00:01') >= rt.`开始时间4` AND TIME(tt.开始卸车时间) <= rt.`结束时间4`
									THEN TIME_TO_SEC(tt.开始卸车时间) - TIME_TO_SEC('00:00:01')
									WHEN date(tt.实际到达时间) < date(tt.开始卸车时间) and TIME('00:00:01') <= rt.`开始时间4` AND TIME(tt.开始卸车时间)> rt.`开始时间4`  AND TIME(tt.开始卸车时间) < rt.`结束时间4`
									THEN TIME_TO_SEC(tt.开始卸车时间) - TIME_TO_SEC(rt.`开始时间4`)
									WHEN date(tt.实际到达时间) < date(tt.开始卸车时间) and TIME('00:00:01') > rt.`开始时间4`AND TIME('00:00:01') < rt.`结束时间4` AND TIME(tt.开始卸车时间) >= rt.`结束时间4`
									THEN TIME_TO_SEC(rt.`结束时间4`) - TIME_TO_SEC('00:00:01')

									WHEN date(tt.实际到达时间) = date(tt.开始卸车时间) and TIME(tt.实际到达时间) <= rt.`开始时间4` AND TIME(tt.开始卸车时间) >= rt.`结束时间4`
									THEN TIME_TO_SEC(rt.`结束时间4`) - TIME_TO_SEC(rt.`开始时间4`)
									WHEN date(tt.实际到达时间) = date(tt.开始卸车时间) and TIME(tt.实际到达时间) >= rt.`开始时间4` AND TIME(tt.开始卸车时间) <= rt.`结束时间4`
									THEN TIME_TO_SEC(tt.开始卸车时间) - TIME_TO_SEC(tt.实际到达时间)
									WHEN date(tt.实际到达时间) = date(tt.开始卸车时间) and TIME(tt.实际到达时间) <= rt.`开始时间4` AND TIME(tt.开始卸车时间)> rt.`开始时间4`  AND TIME(tt.开始卸车时间) < rt.`结束时间4`
									THEN TIME_TO_SEC(tt.开始卸车时间) - TIME_TO_SEC(rt.`开始时间4`)
									WHEN date(tt.实际到达时间) = date(tt.开始卸车时间) and TIME(tt.实际到达时间) > rt.`开始时间4`AND TIME(tt.实际到达时间) < rt.`结束时间4` AND TIME(tt.开始卸车时间) >= rt.`结束时间4`
									THEN TIME_TO_SEC(rt.`结束时间4`) - TIME_TO_SEC(tt.实际到达时间)

									ELSE 0 END

					) / 60
			- (
							 CASE
									WHEN date(tt.实际到达时间) < date(tt.开始卸车时间) and TIME(tt.实际到达时间) <= rt.`开始时间5` AND TIME('23:59:59') >= rt.`结束时间5`
									THEN TIME_TO_SEC(rt.`结束时间5`) - TIME_TO_SEC(rt.`开始时间5`)
									WHEN date(tt.实际到达时间) < date(tt.开始卸车时间) and TIME(tt.实际到达时间) >= rt.`开始时间5` AND TIME('23:59:59') <= rt.`结束时间5`
									THEN TIME_TO_SEC('23:59:59') - TIME_TO_SEC(tt.实际到达时间)
									WHEN date(tt.实际到达时间) < date(tt.开始卸车时间) and TIME(tt.实际到达时间) <= rt.`开始时间5` AND TIME('23:59:59')> rt.`开始时间5`  AND TIME('23:59:59') < rt.`结束时间5`
									THEN TIME_TO_SEC('23:59:59') - TIME_TO_SEC(rt.`开始时间5`)
									WHEN date(tt.实际到达时间) < date(tt.开始卸车时间) and TIME(tt.实际到达时间) > rt.`开始时间5`AND TIME(tt.实际到达时间) < rt.`结束时间5` AND TIME('23:59:59') >= rt.`结束时间5`
									THEN TIME_TO_SEC(rt.`结束时间5`) - TIME_TO_SEC(tt.实际到达时间)

									WHEN date(tt.实际到达时间) < date(tt.开始卸车时间) and TIME('00:00:01') <= rt.`开始时间5` AND TIME(tt.开始卸车时间) >= rt.`结束时间5`
									THEN TIME_TO_SEC(rt.`结束时间5`) - TIME_TO_SEC(rt.`开始时间5`)
									WHEN date(tt.实际到达时间) < date(tt.开始卸车时间) and TIME('00:00:01') >= rt.`开始时间5` AND TIME(tt.开始卸车时间) <= rt.`结束时间5`
									THEN TIME_TO_SEC(tt.开始卸车时间) - TIME_TO_SEC('00:00:01')
									WHEN date(tt.实际到达时间) < date(tt.开始卸车时间) and TIME('00:00:01') <= rt.`开始时间5` AND TIME(tt.开始卸车时间)> rt.`开始时间5`  AND TIME(tt.开始卸车时间) < rt.`结束时间5`
									THEN TIME_TO_SEC(tt.开始卸车时间) - TIME_TO_SEC(rt.`开始时间5`)
									WHEN date(tt.实际到达时间) < date(tt.开始卸车时间) and TIME('00:00:01') > rt.`开始时间5`AND TIME('00:00:01') < rt.`结束时间5` AND TIME(tt.开始卸车时间) >= rt.`结束时间5`
									THEN TIME_TO_SEC(rt.`结束时间5`) - TIME_TO_SEC('00:00:01')

									WHEN date(tt.实际到达时间) = date(tt.开始卸车时间) and TIME(tt.实际到达时间) <= rt.`开始时间5` AND TIME(tt.开始卸车时间) >= rt.`结束时间5`
									THEN TIME_TO_SEC(rt.`结束时间5`) - TIME_TO_SEC(rt.`开始时间5`)
									WHEN date(tt.实际到达时间) = date(tt.开始卸车时间) and TIME(tt.实际到达时间) >= rt.`开始时间5` AND TIME(tt.开始卸车时间) <= rt.`结束时间5`
									THEN TIME_TO_SEC(tt.开始卸车时间) - TIME_TO_SEC(tt.实际到达时间)
									WHEN date(tt.实际到达时间) = date(tt.开始卸车时间) and TIME(tt.实际到达时间) <= rt.`开始时间5` AND TIME(tt.开始卸车时间)> rt.`开始时间5`  AND TIME(tt.开始卸车时间) < rt.`结束时间5`
									THEN TIME_TO_SEC(tt.开始卸车时间) - TIME_TO_SEC(rt.`开始时间5`)
									WHEN date(tt.实际到达时间) = date(tt.开始卸车时间) and TIME(tt.实际到达时间) > rt.`开始时间5`AND TIME(tt.实际到达时间) < rt.`结束时间5` AND TIME(tt.开始卸车时间) >= rt.`结束时间5`
									THEN TIME_TO_SEC(rt.`结束时间5`) - TIME_TO_SEC(tt.实际到达时间)

									ELSE 0 END

					) / 60


			 AS 修正等位时长_分钟
	,TIMESTAMPDIFF(minute,开始卸车时间,结束卸车时间) 卸车时长_分钟


	from
	(
				SELECT
					slt.proof_id
					,line_name
					,case slt.line_mode when 1 then '常规รถหลัก' when 2 then '临时รถเสริม' end 线路属性
					,sst.name 上一站分拨
					,ss.name 当前分拨
					,case when ss.category = 1 then 'SP'
						when ss.category = 10 then 'BDC'
						when ss.category in (4,5,7) then 'SHOP'
						when ss.category = 6 then 'FH'
						when ss.category = 8 then 'HUB'
						when ss.category = 12 then 'BHUB'
						when ss.category = 11 then 'FFM'
						when ss.category = 9 then 'OS'
						when ss.category = 14 then 'PDC'
						when ss.category = 13 then 'CDC'
						end  当前分拨类型
					,case slt.line_type when 0 then '干线'
					when 1 then '支线'
					when 2 then '班车'
					when 3 then '加盟商'
					when 4 then 'BTS'
					end 线路类型
					,case slt.car_type
					when 100 then '4W'
					when 101 then '4WJ'
					when 200 then '6W5.5'
					when 201 then '6W6.5'
					when 203 then '6W7.2'
					when 210 then '6W8.8'
					when 300 then '10W'
					when 400 then '14W'
					else slt.car_type end '车型'
				 ,slt.driver '司机姓名'
				 ,slt.driver_phone '电话'
				 ,slt.plate_number '车牌号'
				 ,convert_tz(slt.previous_estimate_start_time,'+00:00','+07:00')  上一站计划出发时间
				 ,convert_tz(slt.previous_actual_start_time,'+00:00','+07:00')  上一站实际出发时间
				 ,date(convert_tz(slt.estimate_end_time,'+00:00','+07:00'))  计划到达日期
				 ,convert_tz(slt.estimate_end_time,'+00:00','+07:00')  计划到达时间
				 ,case when fdr.`operator_time` is null then convert_tz(slt.`actual_end_time`,'+00:00','+07:00')
				 when TIMESTAMPDIFF(minute,fdr.`operator_time`,slt.`actual_end_time`) >= 360 then convert_tz(slt.`actual_end_time`,'+00:00','+07:00')
				 else least(convert_tz(fdr.`operator_time`,'+00:00','+07:00') , convert_tz(slt.`actual_end_time`,'+00:00','+07:00') )
				 end 实际到达时间
				 ,convert_tz(fdr.`operator_time`,'+00:00','+07:00')  fleet司机打卡时间
				 ,convert_tz(slt.`actual_end_time`,'+00:00','+07:00')  KIT入港考勤时间
				 ,case when slt.begin_unloading_at < slt.`actual_end_time` then ppn.首个包裹入仓时间
				 else ifnull(convert_tz(slt.begin_unloading_at,'+00:00','+07:00'),首个包裹入仓时间) end 开始卸车时间
	-- 			 ,convert_tz(slt.end_unloading_at,'+00:00','+07:00') kit结束卸车时间
	-- 			 ,ppn.`90%包裹入仓时间`
				 ,ifnull( ppn.`90%包裹入仓时间`,convert_tz(slt.end_unloading_at,'+00:00','+07:00')) 结束卸车时间
				 ,ppn.入仓包裹数
				,case when slt.car_type = 100 then tc.4W卸车标准时长
				 when slt.car_type = 101 then tc.4WJ卸车标准时长
				 when slt.car_type in (200,201,203,210) then tc.6W卸车标准时长
                 when slt.car_type = 300 then tc.10W卸车标准时长
                 when slt.car_type = 400 then tc.14W卸车标准时长
                 when slt.car_type = 307 then tc.18W卸车标准时长
                 when slt.car_type = 401 then tc.22W卸车标准时长
				 end '卸车标准时长/min'

	from
	(
	 select
		proof_id
		,line_mode
		,line_type
		,slt.driver
		,slt.driver_phone
		,slt.plate_number
		,slt.previous_estimate_start_time
		,slt.previous_actual_start_time
		,slt.estimate_end_time
		,slt.`actual_end_time`
		,slt.begin_unloading_at
		,slt.end_unloading_at
		,slt.store_id
		,slt.previous_store_id
		,slt.origin_id
		,slt.target_id
	    ,line_name
	    ,car_type
	 from fle_staging.store_line_task slt
	where
	slt.`estimate_end_time` >=convert_tz(date_sub(CURDATE(),interval 1 day),'+07:00','+00:00')
	and slt.`estimate_end_time` < convert_tz(CURDATE(),'+07:00','+00:00')
	and slt.line_mode in (1,2,4)
	and slt.proof_state = 4
	and slt.deleted = 0
	and slt.type > 1
	) slt
	left join `fle_staging`.`sys_store` as ss on ss.`id` = slt.store_id
	left join `fle_staging`.`sys_store` as sst on sst.`id` = slt.previous_store_id
	join `fle_staging`.`sys_store` as ssp on ssp.`id` = slt.origin_id and ssp.category in (8,12)
	join `fle_staging`.`sys_store` as ssd on ssd.`id` = slt.target_id and ssd.category in (8,12)
	left join (
									select proof_id,store_id,operator_time,sign_in_lat,sign_in_lng,state,remark,sign_image
									,row_number()over(partition by proof_id,store_id order by operator_time desc) rk
									from `fle_staging`.fleet_driver_route fdr
									where  fdr.created_at >=CONVERT_TZ(date_sub(CURDATE(),interval 10 day),'+07:00','+00:00')
									and fdr.state < 2 and fdr.event = 1

				) fdr on slt.proof_id = fdr.proof_id  and  slt.store_id = fdr.store_id and fdr.rk=1
	left join (

			 select
				proof_id
				,next_store_id
				,count(distinct relation_no) 入仓包裹数
				,min(first_routed_at) 首个包裹入仓时间
				,max(first_routed_at) 最后一个包裹入仓时间
				,min(if(per_rank>=0.9,first_routed_at,null)) '90%包裹入仓时间'
			from
			(
						SELECT
						fvppd.proof_id
						,fvppd.next_store_id
						,fvppd.relation_no
						,if(slt.proof_id is not null ,convert_tz(fvppd.updated_at,'+00:00','+07:00'),null) first_routed_at
                        ,if(slt.proof_id is not null ,row_number ( ) OVER ( partition by fvppd.proof_id,fvppd.next_store_id  order by fvppd.updated_at ),null)/if(slt.proof_id is not null ,count ( ) OVER ( partition by fvppd.proof_id,fvppd.next_store_id ),null) per_rank
						#,if(slt.proof_id is not null ,percent_rank ( ) OVER ( partition by fvppd.proof_id,fvppd.next_store_id  order by fvppd.updated_at ),null) per_rank
						from  fle_staging.fleet_van_proof_parcel_detail fvppd
						left join fle_staging.store_line_task slt on fvppd.proof_id = slt.proof_id and fvppd.next_store_id = slt.store_id and fvppd.updated_at >= slt.actual_end_time
						where 1=1
						and fvppd.created_at >=convert_tz(date_sub(CURDATE(),interval 10 day),'+07:00','+00:00')
						and fvppd.relation_category in (1,3)
	--   				and fvppd.proof_id = 'AYUX6CU54'
						and fvppd.state = 2

		) group by 1,2

	) ppn on slt.proof_id = ppn.proof_id and slt.store_id	 = ppn.next_store_id
	left join tmpale.hub_unloading_standard_time_cost tc on ss.name = tc.分拨


	) tt
	left join
	(
			select
			分拨,
			全国分拨没有人卸车的时间,
			case when weekday(date_sub(CURDATE(),interval 1 day))+1 = 1 and 分拨 = '07 NO3_HUB เชียงใหม่' then time('7:00') else  `开始时间1` end as '开始时间1',
            case when weekday(date_sub(CURDATE(),interval 1 day))+1 = 1 and 分拨 = '07 NO3_HUB เชียงใหม่' then time('13:00') else  `结束时间1` end as '结束时间1',
            case when weekday(date_sub(CURDATE(),interval 1 day))+1 = 1 and 分拨 = '07 NO3_HUB เชียงใหม่' then time('16:00') else  `开始时间2` end as '开始时间2',
            case when weekday(date_sub(CURDATE(),interval 1 day))+1 = 1 and 分拨 = '07 NO3_HUB เชียงใหม่' then time('17:00') else  `结束时间2` end as '结束时间2',
            case when weekday(date_sub(CURDATE(),interval 1 day))+1 = 1 and 分拨 = '07 NO3_HUB เชียงใหม่' then time('2:00') else  `开始时间3` end as '开始时间3',
            case when weekday(date_sub(CURDATE(),interval 1 day))+1 = 1 and 分拨 = '07 NO3_HUB เชียงใหม่' then time('4:00') else  `结束时间3` end as '结束时间3',
			`开始时间4`,
			`结束时间4`,
			`开始时间5`,
			`结束时间5`
			from tmpale.hub_no_unloading_timetable
	) rt on tt.当前分拨 = rt.分拨
)

