/* 需求文档：
Lazada 派件标记「客户改约时间」取数
https://flashexpress.feishu.cn/docx/RWE7dB6GooIlgrxlfagcdSF9nOc
*/

with t as
(
    select
        ppd.pno
        ,ppd.store_id
        ,ss.name
        ,ppd.created_at
        ,ppd.staff_info_id
        ,date(convert_tz(ppd.created_at, '+00:00', '+07:00')) date_d
        ,pi.client_id
    from fle_staging.parcel_problem_detail ppd
    join fle_staging.parcel_info pi on pi.pno = ppd.pno and pi.client_id in ('AA0415','AA0428','AA0477','AA0442','AA0601','AA0330','AA0461')
    left join fle_staging.sys_store ss on ss.id = ppd.store_id
    where
        ppd.parcel_problem_type_category = 2 -- 留仓件
        and ppd.diff_marker_category in (9,14,70) -- 客户改约时间
        and ppd.created_at >= '2023-01-31 17:00:00'
        and ppd.created_at < '2023-02-28 17:00:00'
#         and ppd.pno= 'TH01433TAS2K1A'
)
select
    t.client_id 客户id
    ,t.pno 运单号
    ,'客户改约时间' 留仓件原因
    ,convert_tz(t.created_at, '+00:00', '+07:00') 留仓件提交时间
    ,t2.staff_info_id 标记快递员工号
    ,t2.created_at 标记时间
    ,t.staff_info_id 提交仓管员工号
    ,t.name 提交仓管员所属网点名称
    ,if(t3.link_id is null, '否', '是') '是否进入疑似违规回访-标记客户改约时间'
    ,case t3.visit_result
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
    end as 疑似违规回访结果
    ,if(t4.pno is null, '否', '是') '是否进入回访客户投诉表-投诉大类 派件虚假留仓件/问题件'
    ,case zs.qaqc_callback_result
        when 1 then '误投诉'
        when 2 then '真实投诉，对快递员/网点人员不满意'
        when 3 then '真实投诉，对Flash公司服务不满意'
        when 4 then '未联系上'
    end  投诉是否真实
    ,case yl.qaqc_callback_result
        when 0 then 'init'
       when 1 then '多次未联系上客户'
       when 2 then '误投诉'
       when 3 then '真实投诉，后接受道歉'
       when 4 then '真实投诉，后不接受道歉'
       when 5 then '真实投诉，后受到骚扰/威胁'
       when 6 then '没有快递员联系客户道歉'
       when 7 then '客户投诉回访结果'
       when 8 then '确认网点已联系客户道歉'
    end 客户是否原谅道歉
from t
left join
    (
        select
            t1.date_d
            ,t1.pno
            ,tdm.created_at
            ,td.staff_info_id
            ,row_number() over (partition by t1.date_d,t1.pno order by tdm.created_at desc ) rn
        from fle_staging.ticket_delivery_marker tdm
        left join fle_staging.ticket_delivery td on tdm.delivery_id = td.id
        join
            (
                select
                    t.pno
                    ,date(convert_tz(t.created_at, '+00:00', '+07:00')) date_d
                from t
                group by 1,2
            ) t1 on td.pno = t1.pno and date(convert_tz(tdm.created_at, '+00:00', '+07:00')) = t1.date_d
        where
            tdm.marker_id in (9,14,70)
    ) t2 on t2.pno = t.pno and t2.date_d = t.date_d and t2.rn = 1
left join
    (
        select
            vrv.link_id
            ,vrv.visit_result
        from nl_production.violation_return_visit vrv
        join
            (
                select t.pno from t group by 1
            ) pn on pn.pno = vrv.link_id
        where
            vrv.type = 4 -- 标记客户改约时间回访
    ) t3 on t3.link_id = t.pno
left join
    (
        select
            acc.pno
        from bi_pro.abnormal_customer_complaint acc
        join
            (
                select t.pno from t group by 1
            ) pn on acc.pno = pn.pno
        where
            acc.complaints_type = 3 -- 派件虚假留仓件/问题件
        group by 1
    ) t4  on t4.pno = t.pno
left join
    ( -- 投诉是否真实
        select
            acca.qaqc_callback_result  -- 2 真实投诉，对快递员/网点人员不满意 1 误投诉  3 真实投诉，对快递员/网点人员不满意
            ,acca.merge_column
        from nl_production.abnormal_customer_complaint_authentic acca
        join
            (
                select t.pno from t group by 1
            ) pn on acca.merge_column = pn.pno
        where
            acca.callback_state = 2
            and acca.complaints_type = 3

    ) zs on zs.merge_column = t.pno
left join
    (
        select
            acc.pno
            ,acc.qaqc_callback_result
        from bi_pro.abnormal_customer_complaint acc
        join
            (
                select t.pno from t group by 1
            ) pn on acc.pno = pn.pno
        where
            acc.callback_state = 2
            and acc.complaints_type = 3
    ) yl on yl.pno = t.pno