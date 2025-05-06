select
    t.pno
    ,del.delivery_attempt_num 尝试派送次数
    ,if(di.pno is not null, '有', '无') 是否有标记拒收问题件
    ,if(di2.link_id is not null, '有', '无') 是否有产生拒收回访
    ,di2.回访结果
    ,if(prr.pno is not null, '有', '无') 是否有上报拒收复核
    ,wrs.拒收审核结果
from tmpale.tmp_th_pno_lj_0521 t
left join
    (
        select
            t.pno
            ,dai.delivery_attempt_num
        from fle_staging.parcel_info pi
        join tmpale.tmp_th_pno_lj_0521 t on t.pno = pi.pno
        left join fle_staging.delivery_attempt_info dai on dai.pno = pi.pno
    ) del on del.pno = t.pno
left join
    (
        select
            di.pno
        from fle_staging.diff_info di
        join tmpale.tmp_th_pno_lj_0521 t on t.pno = di.pno
        where
            di.diff_marker_category = 17
        group by 1
    ) di on di.pno = t.pno
left join
    (
        select
            vrv.link_id
            ,case vrv.visit_result
                when 1 then '联系不上'
                when 2 then '取消原因属实、合理'
                when 3 then '快递员虚假标记/违背客户意愿要求取消'
                when 4 then '多次联系不上客户'
                when 5 then '收件人已签收包裹'
                when 6 then '收件人未收到包裹'
                when 7 then '未经收件人允许投放他处/让他人代收'
                when 8 then '快递员没有联系客户，直接标记收件人拒收'
                when 9 then '收件人拒收情况属实'
                when 10 then '快递员服务态度差'
                when 11 then '因快递员未按照收件人地址送货，客户不方便去取货'
                when 12 then '网点派送速度慢，客户不想等'
                when 13 then '非快递员问题，个人原因拒收'
                when 14 then '其它'
                when 15 then '未经客户同意改约派件时间'
                when 16 then '未按约定时间派送'
                when 17 then '派件前未提前联系客户'
                when 18 then '收件人拒收情况不属实'
                when 19 then '快递员联系客户，但未经客户同意标记收件人拒收'
                when 20 then '快递员要求/威胁客户拒收'
                when 21 then '快递员引导客户拒收'
                when 22 then '其他'
                when 23 then '情况不属实，快递员虚假标记'
                when 24 then '情况不属实，快递员诱导客户改约时间'
                when 25 then '情况属实，客户原因改约时间'
                when 26 then '客户退货，不想购买该商品'
                when 27 then '客户未购买商品'
                when 28 then '客户本人/家人对包裹不知情而拒收'
                when 29 then '商家发错商品'
                when 30 then '包裹物流派送慢超时效'
                when 31 then '快递员服务态度差'
                when 32 then '因快递员未按照收件人地址送货，客户不方便去取货'
                when 33 then '货物验收破损'
                when 34 then '无人在家不便签收'
                when 35 then '客户错误拒收包裹'
                when 36 then '快递员按照要求当场扫描揽收'
                when 37 then '快递员未按照要求当场扫描揽收'
                when 38 then '无所谓，客户无要求'
                when 39 then '包裹未准备好 - 情况不属实，快递员虚假标记'
                when 40 then '包裹未准备好 - 情况属实，客户存在未准备好的包裹'
                when 41 then '虚假修改包裹信息'
                when 42 then '修改包裹信息属实'
                when 43 then '客户需要包裹，继续派送'
                when 44 then '客户不需要包裹，操作退件'
                when 45 then '电话号码错误/电话号码是空号'
                else vrv.visit_result
            end as 回访结果
        from nl_production.violation_return_visit vrv
        join tmpale.tmp_th_pno_lj_0521 t on t.pno = vrv.link_id
        where
            vrv.type = 3
    ) di2 on di2.link_id = t.pno
left join
    (
        select
            prr.pno
        from fle_staging.parcel_reject_report_info prr
        join tmpale.tmp_th_pno_lj_0521 t on t.pno = prr.pno
        where
            prr.state = 2
        group by 1
    ) prr on prr.pno = t.pno
left join
    (
        select
            ra.pno
            ,case ra.audit_result
                when 0 then '未审核'
                when 1 then '审核通过'
                when 2 then '审核不通过'
            end 拒收审核结果
        from wrs_production.reject_audit ra
        join tmpale.tmp_th_pno_lj_0521 t on t.pno = ra.pno
    ) wrs on wrs.pno = t.pno