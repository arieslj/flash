select
    plt.pno
    ,case pi.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
    ,convert_tz(pi.created_at, '+00:00', '+07:00') 揽收时间
from bi_pro.parcel_lose_task plt
left join fle_staging.parcel_info pi on plt.pno = pi.pno
where
    plt.state = 6
    and plt.duty_result = 1
    and pi.state not in (5,7,8,9)
    and pi.discard_enabled = 1
group by 1;

