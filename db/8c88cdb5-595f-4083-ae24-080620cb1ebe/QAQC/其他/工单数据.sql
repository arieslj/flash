select
    t.*
    ,if(pr.pno is not null, 'y', 'n') '是否有Customer Service备注/工单'
    ,if(pr.remark regexp 'ยกเลิก', 'y', 'n') '备注/工单是否含有ยกเลิก'
    ,pr.remark '备注/工单内容'
from tmpale.tmp_th_pno_lj_0528 t
left join rot_pro.parcel_route pr on t.pno = pr.pno and pr.route_action in ('MANUAL_REMARK', 'REPLY_WORK_ORDER', 'CREATE_WORK_ORDER')

