-- 文档：https://flashexpress.feishu.cn/docx/ViYIdcAkJoSZR3xlfSvch8Hvneg
select
    count(distinct if(plt.pno is not null, pr.pno, null))/count(distinct pr.pno) as pno_rate
#     ,if(am.isappeal in (2,3,4,5), 'y', 'n') 是否存在申诉
#     ,if(plt2.pno is null, 'n', 'y') 是否进入过c
#     ,if(plt3.pno is null, 'n', 'y') 是否进入过l
from rot_pro.parcel_route pr
left join bi_pro.parcel_lose_task plt on plt.pno = pr.pno and plt.state = 6 and plt.duty_result = 1 and plt.created_at > date_sub(curdate(), interval 32 day) and plt.penalties > 0
# left join bi_pro.abnormal_message am on json_extract(am.extra_info, '$.losr_task_id') = plt.id and am.created_at > date_sub(curdate(), interval 32 day)
# left join bi_pro.parcel_lose_task plt2 on plt2.pno = pr.pno and plt2.source = 3
# left join bi_pro.parcel_lose_task plt3 on plt3.pno = pr.pno and plt3.source = 12
where
     -- pr.route_action = 'DELIVERY_TRANSFER'
     pr.route_action = 'DETAIN_WAREHOUSE'
    -- pr.route_action = 'DELIVERY_MARKER'
    and pr.routed_at >= date_sub(date_sub(curdate(), interval 30 day), interval 7 hour)
# group by 1,2,3,4,5