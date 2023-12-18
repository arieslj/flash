select
    plt.pno
    ,case pi.returned
        when 0 then '正向'
        when 1 then '逆向'
        else null
    end  方向
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
    ,if(plt2.id is not null, '是', '否') 是否也在其他来源
from bi_pro.parcel_lose_task plt
left join rot_pro.parcel_route pr on pr.pno = plt.pno and pr.route_action = 'CHANGE_PARCEL_CLOSE' and pr.store_id = 'TH02030204'
left join fle_staging.parcel_info pi on pi.pno = plt.pno
left join bi_pro.parcel_lose_task plt2 on plt2.pno = plt.pno and plt2.source not in (11)
where
    plt.created_at >= '2023-10-01'
    and plt.created_at < '2023-11-01'
    and plt.source = 11
    and plt.state in (1,2,3,4)
    and pr.pno is null
group by 1,2,3,4