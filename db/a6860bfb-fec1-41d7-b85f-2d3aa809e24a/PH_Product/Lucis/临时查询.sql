select
    t.pno
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
        ELSE '其他'
	end as '包裹状态'
    ,ss.name '目的网点'
from tmpale.tmp_ph_pno_1204_lj_zcy t
left join  ph_staging.parcel_info pi on pi.pno = t.pno
left join ph_staging.sys_store ss on ss.id = pi.dst_store_id

