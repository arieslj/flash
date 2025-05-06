with t as
    (
        select
            td.pno
        from fle_staging.ticket_delivery td
        left join fle_staging.ticket_delivery_marker tdm on tdm.delivery_id = td.id
        where
            td.client_id = 'AA0703'
            and td.created_at > date_sub(date_sub(curdate(), interval 30 day), interval 8 hour)
            and tdm.marker_id = 2
        group by 1
    )
select
    t1.pno
    ,vrv.vrv_cnt 回访拒收次数
    ,if(prr.pno is not null, '是', '否') 是否提交拒收复核
    ,ra.audit_result 拒收复核wrs审核结果
    ,case vrv2.visit_result
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
        end  最后一次回访拒收结果
    ,case vrv2.rejection_delivery_again
        when 1 then '否'
        when 2 then '是'
    end 最后一次回访是否要求继续派送
    ,vrv2.visit_staff_id
    ,case
        when vrv2.visit_staff_id = 10001 then 'IVR'
        when vrv2.visit_staff_id is not null and vrv2.visit_staff_id != 10001 then '人工CS'
        else null
    end 回访方式
    ,v3.vrv_cnt 所有拒收回访中结果为不属实的次数
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
from t t1
left join fle_staging.parcel_info pi on pi.pno = t1.pno
left join
    (
        select
            vrv.link_id
            ,count(vrv.id) vrv_cnt
        from nl_production.violation_return_visit vrv
        join t t1 on t1.pno = vrv.link_id
        where
            vrv.type = 3
            and vrv.created_at > date_sub(curdate(), interval 2 month)
        group by 1
    ) vrv on vrv.link_id = t1.pno
left join
    (
        select
            t1.pno
        from fle_staging.parcel_reject_report_info prr
        join t t1 on t1.pno = prr.pno
        where
            prr.created_at > date_sub(curdate(), interval 2 month)
            and prr.state = 2
        group by 1
    ) prr on prr.pno = t1.pno
left join
    (
        select
            ra.pno
            ,case ra.audit_result
                when 0 then '未审核'
                when 1 then '审核通过'
                when 2 then '审核不通过'
            end audit_result
        from wrs_production.reject_audit ra
        join t t1 on t1.pno = ra.pno
        where
            ra.created_at > date_sub(curdate(), interval 2 month)
    ) ra on ra.pno = t1.pno
left join
    (
        select
            vrv.link_id
            ,vrv.visit_result
            ,vrv.visit_staff_id
            ,json_extract(vrv.extra_value, '$.rejection_delivery_again') rejection_delivery_again
            ,row_number() over (partition by vrv.link_id order by vrv.created_at desc) rk
        from nl_production.violation_return_visit vrv
        join t t1 on t1.pno = vrv.link_id
        where
            vrv.created_at > date_sub(curdate(), interval 2 month)
    ) vrv2 on vrv2.link_id = t1.pno and vrv2.rk = 1
left join
    (
        select
            vrv.link_id
            ,count(vrv.id) vrv_cnt
        from nl_production.violation_return_visit vrv
        join t t1 on t1.pno = vrv.link_id
        where
            vrv.created_at > date_sub(curdate(), interval 2 month)
            and vrv.visit_result = 18
        group by 1
    ) v3 on v3.link_id = t1.pno