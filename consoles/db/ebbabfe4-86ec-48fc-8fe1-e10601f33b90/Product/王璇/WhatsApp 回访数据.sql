select
    tdp.stat_date 日期
    ,dayname(tdp.stat_date) 星期
    ,count(tdp.id) Flash发送消息总数
    ,count(distinct if(tdp.status = 0, tdp.id, null)) 未发送数量
    ,count(distinct if(tdp.status = 1, tdp.id, null)) Flash已发送未收到回执数量
    ,count(distinct if(tdp.status = 2, tdp.id, null)) 发送失败数量
    ,count(distinct if(tdp.status = 3, tdp.id, null)) 未取到照片数量
    ,count(distinct if(tdp.status = 4, tdp.id, null)) 已送达未读数量
    ,count(distinct if(tdp.status = 5, tdp.id, null)) 已读未回复数量
    ,count(distinct if(tdp.status = 6, tdp.id, null)) 已回复数量
    ,count(distinct if(tdp.status = 7, tdp.id, null)) 超24小时未回复数量
    ,count(distinct if(tdp.reply_result = 1, tdp.id, null)) 收到包裹数量
    ,count(distinct if(tdp.reply_result = 2, tdp.id, null)) 未收到包裹数量
    ,count(distinct if(tdp.reply_result = 3, tdp.id, null)) 未经允许放在其它地方数量
    ,count(distinct if(tdp.complaint = 1, tdp.id, null)) 投诉快递员数量
    ,count(distinct if(tdp.status in (4,5,6,7), tdp.id, null))/count(tdp.id) 发送成功率
    ,count(distinct if(tdp.status in (5,6,7), tdp.id, null))/count(distinct if(tdp.status in (4,5,6,7), tdp.id, null)) 已读率
    ,count(distinct if(tdp.status in (6), tdp.id, null))/count(distinct if(tdp.status in (5,6,7), tdp.id, null)) 已读回复率
    ,count(distinct if(tdp.status in (4,5,6,7) and tdp.reply_result in (2,3), tdp.id, null))/count(distinct if(tdp.status in (4,5,6,7), tdp.id, null)) 虚假妥投率
    ,count(distinct if(tdp.status in (4,5,6,7) and tdp.complaint = 1, tdp.id, null))/count(distinct if(tdp.status in (4,5,6,7), tdp.id, null)) 投诉率
from my_nl.tiktok_delivered_parcel_whatsapp_msg tdp
where
    tdp.stat_date < curdate()
    and tdp.stat_date >= date_sub(curdate(), interval 7 day )
group by 1,2
order by 1 desc
;

select
    a1.*
    ,a2.img_url 图片url
from
    (
        select
            t.id
            ,t.pno
            ,t.stat_date 日期
            ,dm.region_name 大区
            ,dm.store_name 网点名称
            ,t.store_id 网点ID
            ,case
                when bc.`client_id` is not null then bc.client_name
                when kp.id is not null and bc.id is null then '普通ka'
                when kp.`id` is null then '小c'
            end 客户类型
            ,t.client_id 客户ID
            ,t.delivered_at 妥投日期
            ,case t.status
                when 0 then '未发送'
                when 1 then '已发送'
                when 2 then '发送失败'
                when 3 then '无需发送'
                when 4 then '已送达'
                when 5 then '已读'
                when 6 then '已回复'
                when 7 then '超24小时未回复'
            end 状态
            ,case t.complaint
                when 0 then 'no'
                when 1 then 'yes'
            end 是否投诉
            ,t.staff_info_id 快递员ID
            ,t.staff_info_name 快递员名称
            ,t.staff_info_phone 快递员手机号
            ,t.dst_phone 收件人手机号
            ,t.dst_name 收件人名称
            ,t.distance_to_store 妥投时距离网点距离
            ,t.send_at 发送消息时间
            ,t.msg_delivered_at 消息送达时间
            ,t.read_at 阅读时间
            ,t.reply_at 回复时间
            ,case t.reply_result
                when 0 then '未回复'
                when 1 then '包裹已收到'
                when 2 then '包裹未收到'
                when 3 then '未经允许包裹放在别处'
            end 回复结果
            ,t.reply_content 回复内容
            ,t.created_at 创建时间
            ,t.updated_at 更新时间
        from my_nl.tiktok_delivered_parcel_whatsapp_msg t
        left join dwm.dim_my_sys_store_rd dm on dm.store_id = t.store_id and dm.stat_date = date_sub(curdate(), interval 1 day)
        left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = t.client_id
        left join my_staging.ka_profile kp on kp.id = t.client_id
        where
            t.stat_date < curdate()
            and t.stat_date >= date_sub(curdate(), interval 7 day )
    ) a1
left join
    (
        select
            a2.id
            ,group_concat(a2.url) img_url
        from
            (
                select
                    a1.id
                    ,concat('https://', json_extract(a1.img, '$.name'), '.oss-ap-southeast-3.aliyuncs.com/', json_extract(a1.img, '$.key')) url
                from
                    (
                        select
                            a.*
                            ,concat('{',replace(replace(c, '{', ''), '}', ''), '}') img
                        from
                            (
                                select
                                    t.id
                                    ,replace(replace(t.img_url, '[', ''), ']', '') img_url
                                from my_nl.tiktok_delivered_parcel_whatsapp_msg t
                                where
                                    t.stat_date < curdate()
                                    and t.stat_date >= date_sub(curdate(), interval 7 day )
                            ) a
                        lateral view explode(split(a.img_url, '},{')) id as c
                    )a1
            ) a2
        group by 1
    ) a2 on a2.id = a1.id

;
