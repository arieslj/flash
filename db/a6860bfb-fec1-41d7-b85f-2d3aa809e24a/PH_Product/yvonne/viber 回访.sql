select
    a.stat_date
    ,count(distinct a.task_id) 总任务量
    ,count(distinct if(a.状态 in ('已读','已送达'),a.task_id,null)) 接收成功量
    ,count(distinct if(a.状态 in ('已读','已送达'),a.task_id,null))/count(distinct a.task_id) '触达率（接受成功量/总任务量）'

    ,count(distinct if(a.回复时间 is not null,a.task_id,null)) 已回复量
    ,count(distinct if(a.回复时间 is not null,a.task_id,null))/count(distinct a.task_id) '已回复率（已回复量/总任务量）'

    ,count(distinct if(a.回复内容='Y',a.task_id,null)) 回访结果属实量
    ,count(distinct if(a.回复内容='Y',a.task_id,null))/count(distinct if(a.回复时间 is not null,a.task_id,null)) '回访结果属实率（回访结果不属实量/已回复量）'
    ,count(distinct if(a.回复内容='N',a.task_id,null)) 回访结果不属实量
    ,count(distinct if(a.回复内容='N',a.task_id,null))/count(distinct if(a.回复时间 is not null,a.task_id,null)) '虚假率（回访结果不属实量/已回复量）'
    ,count(distinct if(a.回复内容 not in ('Y', 'N'),a.task_id,null)) 无效回复量
    ,count(distinct if(a.回复内容 not in ('Y', 'N'),a.task_id,null))/count(distinct if(a.回复时间 is not null,a.task_id,null)) 无效回复率

    ,count(distinct if(a.状态 in ('已读') and a.回复内容 is null,a.task_id,null)) 已读不回量
    ,count(distinct if(a.状态 in ('已读') and a.回复内容 is null,a.task_id,null))/count(distinct if(a.状态 in ('已读','已送达'),a.task_id,null)) '已读不回率(已读不回量/接受成功量)'

    ,count(distinct if(a.状态 in ('失败','已调用','拒绝或账号不存在'), a.task_id,null)) 未收到消息量
    ,count(distinct if(a.状态 in ('失败','已调用','拒绝或账号不存在'), a.task_id,null))/count(distinct a.task_id) 未收到消息占比

    ,count(distinct if(a.non_reply_num=3,a.task_id,null)) 联系不上量

    ,count(distinct if(a.状态 in ('已送达'),a.task_id,null)) 未读消息量
    ,count(distinct if(a.状态 in ('已送达'),a.task_id,null))/count(distinct if(a.状态 in ('已读','已送达'),a.task_id,null)) 未读消息占比
from
    (
        select
          om.phone
          ,vr.task_id
          ,vr.non_reply_num
          ,om.stat_date
          ,om.send_at 发送时间
          ,if(om.delivered_at='1970-01-01 00:00:00',null,om.delivered_at) 送达时间
          ,if(om.read_at='1970-01-01 00:00:00',null,om.read_at)  阅读时间
          ,if(om.reply_at='1970-01-01 00:00:00',null,om.reply_at)  回复时间
          ,REPLACE (json_extract(json_extract(json_extract(im.content, '$.payload'),'$.content'),'$.text'),'"','') 回复内容
          ,case om.status when 1 then '已调用'
                          when 0 then '失败'
                          when 2 then '拒绝或账号不存在'
                          when 3 then '已发送'
                          when 4 then '已送达'
                          when 5 then '已读'
                          else null end as 状态
          ,row_number() over(partition by om.stat_date,om.phone,vr.task_id order by om.send_at) as rn
        from nl_production.chat_outbound_messages om
        left join nl_production.chat_inbound_messages im on om.umid=im.reply_to_umid
        left join nl_production.viber_return_visit vr on om.stat_date=vr.stat_date and om.phone=vr.mobile
        where om.src='bi_viber_visit'
        and om.service_provider=9
        and om.send_at>='${sdate}'
        and om.send_at<date_add('${edate}',interval 1 day)
    )a
where
    a.rn=1
group by 1
order by 1

;


select
    vrv.mobile 客户电话
    ,vrv.link_id 单号
    ,vrv.created_at 回访任务创建时间
    ,case vrv.state
        when 0 then '正常'
        when 1 then '失败'
    end 回访状态
    ,if(vrv.non_reply_num = 3, 3, vrv.non_reply_num + 1) 回访次数
from nl_production.viber_return_visit vrv
where
    vrv.stat_date = '${sdate}'
