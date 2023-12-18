select
    min(oi.created_at)
from my_staging.order_info oi
# where
#     oi.src_phone = '0123793152'

;

select
    t.pno
    ,t.cogs_amount/100 cogs
    ,t.client_id 客户ID
    ,t.src_phone 寄件人电话
    ,t.src_name 寄件人电话
    ,case t.state
        when 0 then '已确认'
        when 1 then '待揽件'
        when 2 then '已揽收'
        when 3 then '已取消(已终止)'
        when 4 then '已删除(已作废)'
        when 5 then '预下单'
        when 6 then '被标记多次，限制揽收'
    end as 订单状态
    ,case t.p_state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
        ELSE '其他'
	end as '包裹状态'
    ,t.created_at 下单时间
    ,t.pick_at 揽收时间
    ,CONCAT('SSRD',plt.`id`) 闪速任务ID
    ,case plt.duty_result
        when 1 then '丢失'
        when 2 then '破损'
        when 3 then '超时效'
    end 当前判责类型
    ,t2.t_value 判责原因
    ,group_concat(distinct ss.name) 责任网点
    ,group_concat(distinct plr.staff_id) 责任人
from tmpale.tmp_my_pno_lj_1110 t
left join my_bi.parcel_lose_task plt on t.pno = plt.pno and plt.state = 6
left join my_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
left join my_bi.translations t2 on t2.t_key = plt.duty_reasons and  t2.lang ='zh-CN'
left join my_staging.sys_store ss on ss.id = plr.store_id
group by 1,2,3,4,5,6,7,8,9,10,11,12

;


9