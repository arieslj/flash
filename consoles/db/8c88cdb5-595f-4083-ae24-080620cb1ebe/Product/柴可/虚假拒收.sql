select
    t.pno
    ,if(acc.pno is not null, '是', '否') 是否被投诉虚假拒收
from tmpale.tmp_th_pno_lj_240103 t
left join bi_pro.abnormal_customer_complaint acc on t.pno = acc.pno and acc.complaints_sub_type in (61,62,66)
group by 1,2