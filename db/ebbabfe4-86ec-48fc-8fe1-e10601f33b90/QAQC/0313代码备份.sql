SELECT plt.问题来源渠道,
sum(plt.一类来源待处理)+sum(二类来源待处理) 待处理今天需完成任务量,
sum(plt.一类来源待回复)+sum(二类来源待回复) 待回复今天需完成任务量,
sum(plt.一类来源已回复)+sum(二类来源已回复) 已回复待判责今天需完成任务量,
sum(一类来源待处理完成)+sum(二类来源待处理完成) 待处理任务时效内完成量,
sum(一类来源待回复完成)+sum(二类来源待回复完成) 待回复任务时效内完成量,
sum(一类来源已回复完成)+sum(二类来源已回复完成) 已回复待判责任务时效内完成量,
sum(plt.一类来源待处理总)+sum(二类来源待处理总) 待处理任务量,
sum(plt.一类来源待回复总)+sum(二类来源待回复总) 待回复任务量,
sum(plt.一类来源已回复总)+sum(二类来源已回复总) 已回复待判责任务量
FROM (
SELECT *
,case when plt.问题来源渠道 in ('A','B','E','G') and ((plt.工单创建时间 is null and plt.判责时间 is null and date(plt.任务创建时间)<'${date}') or (plt.工单创建时间 is not null and date(plt.任务创建时间)<'${date}' and date(plt.工单创建时间)>='${date}') or (date(plt.任务创建时间)='${date}' and date(plt.工单创建时间)='${date}')) then 1 else 0 end as 一类来源待处理

,case when plt.问题来源渠道 in ('C','D','F','H') and ((plt.工单创建时间 is null and plt.判责时间 is null and date(plt.任务创建时间)<=date_sub('${date}',2)) or (plt.工单创建时间 is not null and date(plt.任务创建时间)<=date_sub('${date}',2) and date(plt.工单创建时间)>='${date}') or (date(plt.任务创建时间)>date_sub('${date}',2) and date(plt.任务创建时间)<='${date}' and date(plt.工单创建时间)='${date}')) then 1 else 0 end as 二类来源待处理

,case when plt.问题来源渠道 in ('A','B','E','G') and ((plt.第一次回复时间 is null and plt.判责时间 is null and date(plt.工单创建时间)<=date_sub('${date}',2)) or (plt.第一次回复时间 is not null and date(plt.工单创建时间)<=date_sub('${date}',2) and date(plt.第一次回复时间)>='${date}') or (date(plt.工单创建时间)>date_sub('${date}',2) and date(plt.工单创建时间)<='${date}' and date(plt.第一次回复时间)='${date}')) then 1 else 0 end as 一类来源待回复

,case when plt.问题来源渠道 in ('C','D','F','H') and ((plt.第一次回复时间 is null and plt.判责时间 is null and date(plt.工单创建时间)<=date_sub('${date}',3)) or (plt.第一次回复时间 is not null and date(plt.工单创建时间)<=date_sub('${date}',3) and date(plt.第一次回复时间)>='${date}') or (date(plt.工单创建时间)>date_sub('${date}',3) and date(plt.工单创建时间)<='${date}' and date(plt.第一次回复时间)='${date}')) then 1 else 0 end as 二类来源待回复

,case when plt.问题来源渠道 in ('A','B','E','G') and ((plt.判责时间 is null and date(plt.最新回复时间)<=date_sub('${date}',1)) or (date(plt.任务创建时间)<='${date}' and date(plt.判责时间)='${date}')) then 1 else 0 end as 一类来源已回复

,case when plt.问题来源渠道 in ('C','D','F','H') and ((plt.判责时间 is null and date(plt.最新回复时间)<=date_sub('${date}',2)) or (date(plt.任务创建时间)<='${date}' and date(plt.判责时间)='${date}')) then 1 else 0 end as 二类来源已回复

,case when plt.问题来源渠道 in ('A','B','E','G') and date(plt.任务创建时间)<='${date}' and date(plt.工单创建时间)='${date}' then 1 else 0 end as 一类来源待处理完成

,case when plt.问题来源渠道 in ('C','D','F','H') and date(plt.任务创建时间)<='${date}' and date(plt.工单创建时间)='${date}' then 1 else 0 end as 二类来源待处理完成

,case when plt.问题来源渠道 in ('A','B','E','G') and date(plt.工单创建时间)<='${date}' and date(plt.第一次回复时间)='${date}' then 1 else 0 end as 一类来源待回复完成

,case when plt.问题来源渠道 in ('C','D','F','H') and date(plt.工单创建时间)<='${date}' and date(plt.第一次回复时间)='${date}' then 1 else 0 end as 二类来源待回复完成

,case when plt.问题来源渠道 in ('A','B','E','G') and date(plt.任务创建时间)<='${date}' and date(plt.判责时间)='${date}' then 1 else 0 end as 一类来源已回复完成

,case when plt.问题来源渠道 in ('C','D','F','H') and date(plt.任务创建时间)<='${date}' and date(plt.判责时间)='${date}' then 1 else 0 end as 二类来源已回复完成

,case when plt.问题来源渠道 in ('A','B','E','G') and ((plt.工单创建时间 is null and plt.判责时间 is null) or (plt.工单创建时间 is not null and date(plt.工单创建时间)>='${date}')) then 1 else 0 end as 一类来源待处理总

,case when plt.问题来源渠道 in ('C','D','F','H') and ((plt.工单创建时间 is null and plt.判责时间 is null) or (plt.工单创建时间 is not null and date(plt.工单创建时间)>='${date}')) then 1 else 0 end as 二类来源待处理总

,case when plt.问题来源渠道 in ('A','B','E','G') and ((plt.第一次回复时间 is null and plt.判责时间 is null and plt.state=3) or (plt.第一次回复时间 is not null and date(plt.第一次回复时间)>='${date}')) then 1 else 0 end as 一类来源待回复总

,case when plt.问题来源渠道 in ('C','D','F','H') and ((plt.第一次回复时间 is null and plt.判责时间 is null and plt.state=3) or (plt.第一次回复时间 is not null and date(plt.第一次回复时间)>='${date}')) then 1 else 0 end as 二类来源待回复总

,case when plt.问题来源渠道 in ('A','B','E','G') and ((plt.判责时间 is null and plt.state=4) or (plt.判责时间 is not null and date(plt.判责时间)>='${date}')) then 1 else 0 end as 一类来源已回复总

,case when plt.问题来源渠道 in ('C','D','F','H') and ((plt.判责时间 is null and plt.state=4) or (plt.判责时间 is not null and date(plt.判责时间)>='${date}')) then 1 else 0 end as 二类来源已回复总

FROM (
SELECT plt.pno as 'pno'
,case when plt.source=1 then 'A'
when plt.source=2 then 'B'
when plt.source in (3,33) then 'C'
when plt.source=4 then 'D'
when plt.source=5 then 'E'
when plt.source=6 then 'F'
when plt.source=7 then 'G'
when plt.source=8 then 'H' end as '问题来源渠道'
,plt.`operator_id` as 'operator_id'
,plt.`state` as 'state'
,plt.created_at 任务创建时间
,wo.`created_at` 工单创建时间
,yy.created_at as 第一次回复时间
,yy1.created_at as 最新回复时间
,if(plt.`state` in (5,6),plt.`updated_at`,null) 判责时间
FROM
(
SELECT *
FROM
(
SELECT plt.*
,row_number() over(partition by plt.`pno` order by plt.`created_at` asc) rn
FROM `my_bi`.`parcel_lose_task` plt
) plt
WHERE rn=1
) plt
LEFT JOIN `my_bi`.`work_order` wo on plt.`id` =wo.`loseparcel_task_id` and wo.order_type IN(1,8,9,10)
LEFT JOIN (SELECT order_id, created_at
  from(-- 取第一次回复的时间
SELECT wr.order_id, wr.created_at, row_number() over(partition by wr.order_id
 order by created_at) rn
  from `my_bi`.work_order_reply wr)
 where rn= 1) yy
on yy.order_id = wo.id
LEFT JOIN (SELECT order_id, created_at, content
  from(-- 取最后一次回复的内容
SELECT wr.order_id,wr.content, wr.created_at, row_number() over(partition by wr.order_id
 order by created_at desc) rn
  from `my_bi`.work_order_reply wr)
 where rn= 1) yy1
on yy1.order_id = wo.id
WHERE (plt.state in (1,2,5) and plt.operator_id!=10000) or (plt.state in (3,4,6))
) plt
where (date(plt.判责时间)>='${date}' or plt.判责时间 is null)
and date(plt.任务创建时间)<='${date}'
) plt
GROUP BY 1
ORDER BY 1 asc
