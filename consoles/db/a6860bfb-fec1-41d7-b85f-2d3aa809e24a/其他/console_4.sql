
with t as
(
    select
        t.pno
        ,vrv.type
        ,case vrv.visit_state
            when 0 then '终态或变更派件标记等无须回访'
            when 1 then '待回访'
            when 2 then '沟通中'
            when 3 then '多次未联系上客户'
            when 4 then '已回访'
            when 5 then '因同包裹生成其他回访任务关闭'
            when 6 then 'VR回访结果=99关闭'
            when 7 then '超回访时效关闭'
        end visit_stat
        ,vrv.visit_staff_id
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
        end as result
    from tmpale.tmp_ph_pno_0814 t
    left join nl_production.violation_return_visit vrv on vrv.link_id = t.pno
)
select
    t1.pno
    ,if(t3.pno is not null, '是', '否') 是否进入拒收回访
    ,if(t3.visit_staff_id != 10001, t3.visit_stat, null) 拒收人工回访状态
    ,if(t3.visit_staff_id != 10001, t3.result, null) 拒收人工回访结果
    ,if(t4.pno is not null, '是', '否') 是否进入拒收ivr回访
    ,t4.visit_stat 拒收IVR回访状态
    ,t4.result 拒收IVR回访结果
    ,if(t5.pno is not null, '是', '否') 是否进入三次尝试派送回访
    ,if(t5.visit_staff_id != 10001, t5.visit_stat, null) 三次尝试派送人工回访状态
    ,if(t5.visit_staff_id != 10001, t5.result, null) 三次尝试派送人工回访结果
    ,if(t6.pno is not null, '是', '否') 是否进入三次尝试派送ivr回访
    ,t6.visit_stat 三次尝试派送IVR回访状态
    ,t6.result 三次尝试派送IVR回访结果
from
    (
        select
            t1.pno
        from t t1
        group by 1
    )t1
left join
    (
        select
            t1.pno
            ,t1.visit_stat
            ,t1.visit_staff_id
            ,t1.result
        from t t1
        where
            t1.type = 3
        group by 1,2,3
    ) t3 on t3.pno = t1.pno
left join
    (
        select
            t1.pno
            ,t1.visit_stat
            ,t1.visit_staff_id
            ,t1.result
        from t t1
        where
            t1.type = 3
            and t1.visit_staff_id = 10001
        group by 1,2,3
    ) t4 on t4.pno = t1.pno
left join
    (
        select
            t1.pno
            ,t1.visit_stat
            ,t1.visit_staff_id
            ,t1.result
        from t t1
        where
            t1.type = 8
        group by 1,2,3
    ) t5 on t5.pno = t1.pno
left join
    (
        select
            t1.pno
            ,t1.visit_stat
            ,t1.visit_staff_id
            ,t1.result
        from t t1
        where
            t1.type = 8
            and t1.visit_staff_id = 10001
        group by 1,2,3
    ) t6 on t6.pno = t1.pno


;



select
    t.pno
    ,vrv.created_at 回访创建时间
    ,case vrv.visit_state
            when 0 then '终态或变更派件标记等无须回访'
            when 1 then '待回访'
            when 2 then '沟通中'
            when 3 then '多次未联系上客户'
            when 4 then '已回访'
            when 5 then '因同包裹生成其他回访任务关闭'
            when 6 then 'VR回访结果=99关闭'
            when 7 then '超回访时效关闭'
        end  回访状态
    ,vrv.visit_staff_id 回访员工
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
    end as 回访结果
from tmpale.tmp_ph_pno_0814 t
left join nl_production.violation_return_visit vrv on vrv.link_id = t.pno