select
    t.pno
    ,if(pi.returned = 1, dai.returned_delivery_attempt_num, dai.delivery_attempt_num) 尝派送次数
    ,plt.plt_cnt 判责丢失次数
    ,count(DISTINCT IF(di.diff_marker_category = 17, di.id, null)) 提交收件人拒收次数
    ,count(DISTINCT IF(di.diff_marker_category = 31, di.id, null)) 提交分错网点_地址错误次数
    ,count(DISTINCT IF(di.diff_marker_category = 31, di.id, null)) 提交收件人地址不正确次数
    ,count(DISTINCT IF(di.diff_marker_category = 25, di.id, null)) 提交收件人电话号码错误次数
    ,count(DISTINCT IF(di.diff_marker_category = 40, di.id, null)) 提交联系不上客户次数
    ,count(DISTINCT IF(di.diff_marker_category = 14, di.id, null)) 提交客户改约时间次数
    ,count(DISTINCT IF(di.diff_marker_category = 26, di.id, null)) cod金额不正确次数
from tmpale.tmp_th_pno_lj_0320 t
left join fle_staging.parcel_info pi on t.pno = pi.pno
left join fle_staging.delivery_attempt_info dai on dai.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
left join
    (
        select
            plt.pno
            ,count(pcol.created_at) plt_cnt
        from bi_pro.parcel_lose_task plt
        join tmpale.tmp_th_pno_lj_0320 t on t.pno = plt.pno
        left join bi_pro.parcel_cs_operation_log pcol on pcol.task_id = plt.id
        where
            pcol.action = 4
        group by 1
    ) plt on plt.pno = t.pno
left join fle_staging.parcel_problem_detail  di on di.pno = t.pno
group by 1,2,3