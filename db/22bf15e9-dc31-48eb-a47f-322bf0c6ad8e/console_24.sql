select
    ss.name
    ,smp.name 片区
    ,smr.name 大区
from fle_staging.sys_store ss
left join fle_staging.sys_manage_piece smp on smp.id = ss.manage_piece
left join fle_staging.sys_manage_region smr on smr.id = ss.manage_region
where
    ss.short_name in ('GOY', 'NKO', 'WTG')

;


select
    pct.client_id '客户ID  ID ลูกค้า'
    ,pct.pno '运单号 เลขพัสดุ'
    ,plt.created_at '进入闪速认定时间 เวลาที่เข้า SS ตัดสินผู้รับผิดชอบ'
    ,case plt.source
        when 1 then 'A-การเจรจาพัสดุมีปัญหา-สูญหาย'
        when 2 then 'B-สร้างรายการคำร้อง-สูญหา'
        when 3 then 'C-ไม่ได้อัพเดทสถานะ'
        when 4 then 'D-การเจรจาพัสดุมีปัญหา-เสียหาย/ขาดหาย'
        when 5 then 'E-สร้างรายการคำร้อง-เคลม-สูญหาย'
        when 6 then 'F-สร้างรายการคำร้อง-เคลม-เสียหาย/ขาดห'
        when 7 then 'G-สร้างรายการคำร้อง-เคลม-อื่น'
        when 8 then 'H-พัสดุสูญหายที่ไม่มีเลขพัสด'
        when 9 then 'I-问题件-外包装破损险'
        when 10 then 'J-问题记录本-外包装破损险'
        when 11 then 'K-พัสดุเกิน SLA'
        when 12 then 'L-พัสดุคาดว่าจะสูญหายระดับสูง'
    end '闪速认定问题来源 ที่มา'
    ,case plt.state
        when 1 then '待处理 รอจัดการ'
        when 2 then '待处理 รอจัดการ'
        when 3 then '待工单回复 รอตอบ Ticket'
        when 4 then '已工单回复 ตอบ Ticket แล้ว'
        when 5 then '无需追责 ยกเลิกตัดสิน'
        when 6 then '责任人已认定 ตัดสินผู้รับผิดชอบ'
    end 'SS认定判责结果 ผลการตัดสิน'
    ,pct.created_at '进入闪速理赔时间 เวลาที่เข้า SS เคลมค่าเสียหาย'
    ,case pct.state
        when 1 then '待协商 รอเจรจา'
        when 2 then '协商不一致'
        when 3 then '待财务核实'
        when 4 then '待财务支付'
        when 5 then '支付驳回'
        when 6 then '理赔完成'
        when 7 then '理赔终止 ยุติการเคลม'
        when 8 then '异常关闭'
    end '理赔状态 สถานะการเคลม'
    ,pct.id
from bi_pro.parcel_claim_task pct
left join bi_pro.parcel_lose_task plt on if(pct.lose_task_id is not null ,pct.lose_task_id = plt.id, pct.pno = plt.pno and plt.state in (5,6))
where
    pct.client_id in ('BA1022','BG1272','BA0263','BA0364','AA0214','AA0491','BG0948','AA0567','CS8798','CR9789','BG1688','BF9686','CAA5203','BA0271','CAC5925','CAH7135','CAD4344','CG3599','CAG4910','CAK3170','CU0432','AA0332','CY6085','CAG0052','CQ8204','BG1972','BG0189','AA0610','CJ8203','BG1756','BG1638','BG1855','BG1940','AA0529','AA0549','CP5844','AA0462','BG0893','AA0630','BG1822','CAJ4254','CAM6645','CAF0333','CY9089','CP4639','BG1220','AA0374','AA0658','CP9213','AA0339','AA0308','CT6589','CN3323','BG1077','BC1175','BC1176','BC1177','BE1109','CN2472','BG1755','CU9965','AA0312','AA0271','BG1751','AA0407','BA0842','AA0379','AA0400','CW7271','BG1776','BA0447','AA0233','AA0236','AA0237','AA0234','CB5780','BG1926','AA0495','AA0527','AA0537','AA0571','CAE8368','CH1710','BG1749','CH7225','AA0227','AA0303','CA8426','AA0204','AA0597','AA0598','AA0599','CD7300','BG1874','CAK9845','AA0539','BG1074','CH0379','AA0290','BD8171','AA0648','AA0443','AA0447','AA0467','CR9890','BF9775','BG1784','CAJ0624','AA0578','BA1268','BA1267','BG0082','BG0514','AA0336','AA0335','BG1214','BG0916','AA0530','BF9961','BG1712','AA0594','BA1704','BG0821','CC8375','BA7970','CB9731','BG1146','BG1924','BG1950','BG1978','BG1984','BG1983','BG1988','CAC3457')
    and
    ( pct.state = 1
    or (pct.created_at >= '2023-01-01 00:00:00' and pct.state = 7))