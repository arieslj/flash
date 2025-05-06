select
    dai.pno
    ,dai.client_id 客户ID
    ,case pi.returned
        when 0 then '正向'
        when 1 then '退件'
    end 包裹流向
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
    end as 包裹当前状态
    ,dai.delivery_attempt_num 正向派件次数
    ,dai.returned_delivery_attempt_num 退件派件次数
from fle_staging.delivery_attempt_info dai
left join fle_staging.parcel_info pi on pi.pno = dai.pno
where
    dai.pno in ('${SUBSTITUTE(SUBSTITUTE(pnos,"\n",","),",","','")}')