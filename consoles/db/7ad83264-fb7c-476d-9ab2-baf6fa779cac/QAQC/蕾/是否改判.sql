with t as
    (
        select
            t.pno
            ,plt.state
            ,plt.duty_result
            ,pcol.action
            ,pcol.operator_id
            ,pcol.created_at
            ,row_number() over(partition by t.pno order by pcol.created_at ) as rk1
            ,row_number() over(partition by t.pno order by pcol.created_at desc) as rk2
        from ph_bi.parcel_lose_task plt
        join tmpale.tmp_ph_pno_lj_0506 t on t.pno = plt.pno
        join ph_bi.parcel_cs_operation_log pcol on pcol.task_id = plt.id and pcol.action in (3,4)
#         where
#             plt.pno = 'P81163EQVQUAH'
    )
select
    distinct
    t.pno
    ,case t2.state
        when 1 then '丢失件待处理'
        when 2 then '疑似丢失件待处理'
        when 3 then '待工单回复'
        when 4 then '已工单回复'
        when 5 then '无须追责'
        when 6 then '责任人已认定'
    end 目前内部判责
    ,case t2.duty_result
        when 1 then '丢失'
        when 2 then '破损'
        when 3 then '超时效'
	end 目前判责结果
    ,t1.created_at 第一次判责时间
    ,t2.created_at 最后判责时间
    ,t2.operator_id 最后判责操作人
from tmpale.tmp_ph_pno_lj_0506 t
left join t t1 on t.pno = t1.pno and t1.rk1 = 1
left join t t2 on t.pno = t2.pno and t2.rk2 = 1

;

select
    pi.pno
    ,pi.dst_name
    ,pi.dst_phone
    ,pi.dst_detail_address
from ph_staging.order_info pi
where
    pi.pno = 'P19064JAYPSAH'