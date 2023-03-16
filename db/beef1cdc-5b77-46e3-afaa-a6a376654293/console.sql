select
    t2.pno
    ,t2.created_at `揽收时间`
    ,case t2.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as `包裹状态`
from
    (
        select
            plt.pno
        from fle_dwd.dwd_bi_parcel_lose_task_di plt
        where
            plt.p_date >= '2022-01-01'
            and plt.state = 6
            and plt.duty_result = 1
        group by 1
    ) t1
left join
    (
        select
            pi.pno
            ,pi.created_at
            ,pi.state
        from fle_dwd.dwd_fle_parcel_info_di pi
        where
            pi.p_date >= '2022-01-01'
            and pi.state not in (5,7,8,9)
            and pi.interrupt_category = 3
    ) t2  on t1.pno = t2.pno