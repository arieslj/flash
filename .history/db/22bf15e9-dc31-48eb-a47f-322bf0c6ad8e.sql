select
    t.pno
    ,ss.name 揽收网点
from fle_staging.parcel_info pi
join tmpale.tmp_th_pno_0308 t on pi.pno = t.pno
left join fle_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id;
;-- -. . -..- - / . -. - .-. -.--
select
        ppd.pno
        ,ppd.source_id
        ,ppd.created_at
        ,ppd.staff_info_id
        ,date(convert_tz(ppd.created_at, '+00:00', '+07:00')) date_d
    from fle_staging.parcel_problem_detail ppd
    where
        ppd.parcel_problem_type_category = 2 -- 留仓件
        and ppd.diff_marker_category in (9,14,70) -- 客户改约时间
        and ppd.created_at >= '2023-01-31 17:00:00'
        and ppd.created_at < '2023-02-28 17:00:00';
;-- -. . -..- - / . -. - .-. -.--
select
    acca.qaqc_callback_result
from nl_production.abnormal_customer_complaint_authentic acca
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    acca.qaqc_callback_result
    ,count(acca.id)
from nl_production.abnormal_customer_complaint_authentic acca
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ppd.pno
        ,ppd.store_id
        ,ss.name
        ,ppd.created_at
        ,ppd.staff_info_id
        ,date(convert_tz(ppd.created_at, '+00:00', '+07:00')) date_d
    from fle_staging.parcel_problem_detail ppd
    left join fle_staging.sys_store ss on ss.id = ppd.store_id
    where
        ppd.parcel_problem_type_category = 2 -- 留仓件
        and ppd.diff_marker_category in (9,14,70) -- 客户改约时间
        and ppd.created_at >= '2023-01-31 17:00:00'
        and ppd.created_at < '2023-02-28 17:00:00'
)
select
    pi.client_id 客户id
    ,t.pno 运单号
    ,'客户改约时间' 留仓件原因
    ,convert_tz(t.created_at, '+00:00', '+07：00') 留仓件提交时间
    ,t2.staff_info_id 标记快递员工号
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
left join fle_staging.parcel_info pi on pi.pno = t.pno
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
    ) t2 on t2.pno = t.pno and t2.date_d = t.date_d
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
    ) yl on yl.pno = t.pno;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ppd.pno
        ,ppd.store_id
        ,ss.name
        ,ppd.created_at
        ,ppd.staff_info_id
        ,date(convert_tz(ppd.created_at, '+00:00', '+07:00')) date_d
    from fle_staging.parcel_problem_detail ppd
    left join fle_staging.sys_store ss on ss.id = ppd.store_id
    where
        ppd.parcel_problem_type_category = 2 -- 留仓件
        and ppd.diff_marker_category in (9,14,70) -- 客户改约时间
        and ppd.created_at >= '2023-01-31 17:00:00'
        and ppd.created_at < '2023-02-28 17:00:00'
)
select
    pi.client_id 客户id
    ,t.pno 运单号
    ,'客户改约时间' 留仓件原因
    ,convert_tz(t.created_at, '+00:00', '+07:00') 留仓件提交时间
    ,t2.staff_info_id 标记快递员工号
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
left join fle_staging.parcel_info pi on pi.pno = t.pno
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
    ) t2 on t2.pno = t.pno and t2.date_d = t.date_d
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
    ) yl on yl.pno = t.pno;
;-- -. . -..- - / . -. - .-. -.--
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
)
select
    t.client_id 客户id
    ,t.pno 运单号
    ,'客户改约时间' 留仓件原因
    ,convert_tz(t.created_at, '+00:00', '+07:00') 留仓件提交时间
    ,t2.staff_info_id 标记快递员工号
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
    ) t2 on t2.pno = t.pno and t2.date_d = t.date_d
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
    ) yl on yl.pno = t.pno;
;-- -. . -..- - / . -. - .-. -.--
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
)
select  count(*) from  t;
;-- -. . -..- - / . -. - .-. -.--
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
)
select
    t.client_id 客户id
    ,t.pno 运单号
    ,'客户改约时间' 留仓件原因
    ,convert_tz(t.created_at, '+00:00', '+07:00') 留仓件提交时间
    ,t2.staff_info_id 标记快递员工号
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
    ) yl on yl.pno = t.pno;
;-- -. . -..- - / . -. - .-. -.--
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
)
select count(*) from t;
;-- -. . -..- - / . -. - .-. -.--
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
        and ppd.pno= 'TH01433TAS2K1A'
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
    ) yl on yl.pno = t.pno;
;-- -. . -..- - / . -. - .-. -.--
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
            and vrv.link_id = 'TH01433TAS2K1A';
;-- -. . -..- - / . -. - .-. -.--
select
            vrv.link_id
            ,vrv.visit_result
        from nl_production.violation_return_visit vrv
#         join
#             (
#                 select t.pno from t group by 1
#             ) pn on pn.pno = vrv.link_id
        where
            vrv.type = 4 -- 标记客户改约时间回访
            and vrv.link_id = 'TH01433TAS2K1A';
;-- -. . -..- - / . -. - .-. -.--
select
            acca.qaqc_callback_result  -- 2 真实投诉，对快递员/网点人员不满意 1 误投诉  3 真实投诉，对快递员/网点人员不满意
            ,acca.merge_column
        from nl_production.abnormal_customer_complaint_authentic acca
#         join
#             (
#                 select t.pno from t group by 1
#             ) pn on acca.merge_column = pn.pno
        where
            acca.callback_state = 2
            and acca.complaints_type = 3
            and acca.me;
;-- -. . -..- - / . -. - .-. -.--
select
            acca.qaqc_callback_result  -- 2 真实投诉，对快递员/网点人员不满意 1 误投诉  3 真实投诉，对快递员/网点人员不满意
            ,acca.merge_column
        from nl_production.abnormal_customer_complaint_authentic acca
#         join
#             (
#                 select t.pno from t group by 1
#             ) pn on acca.merge_column = pn.pno
        where
            acca.callback_state = 2
            and acca.complaints_type = 3
            and acca.merge_column = 'TH01433TAS2K1A';
;-- -. . -..- - / . -. - .-. -.--
select
    month(date_add(wo.created_at, interval 6 hour)) month_d
    ,wo.order_no
    ,wo.pnos
from bi_pro.work_order wo
left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id
join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name = 'Shopee'
where
    wo.store_id = 22
    and wo.created_at >= '2022-11-30 18:00:00'
    and wo.created_at < '2023-02-28 18:00:00';
;-- -. . -..- - / . -. - .-. -.--
select
    month(date_add(wo.created_at, interval 6 hour)) month_d
#     ,wo.order_no
#     ,wo.pnos
    ,count(distinct  wo.id) num
from bi_pro.work_order wo
left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id
join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name = 'Shopee'
left join fle_staging.sys_store ss on ss.id = wo.created_store_id
where
    wo.store_id = 22
    and wo.created_at >= '2022-11-30 18:00:00'
    and wo.created_at < '2023-02-28 18:00:00'
    and ss.id is not null
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    month(date_add(wo.created_at, interval 6 hour)) month_d
    ,wo.order_no
    ,wo.pnos
    ,count(distinct  wo.id) num
from bi_pro.work_order wo
left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id
join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name = 'Shopee'
left join fle_staging.sys_store ss on ss.id = wo.created_store_id
where
    wo.store_id = 22
    and wo.created_at >= '2022-11-30 18:00:00'
    and wo.created_at < '2023-02-28 18:00:00'
    and ss.id is not null;
;-- -. . -..- - / . -. - .-. -.--
select
    month(date_add(wo.created_at, interval 6 hour)) month_d
    ,wo.order_no
    ,wo.pnos
#     ,count(distinct  wo.id) num
from bi_pro.work_order wo
left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id
join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name = 'Shopee'
left join fle_staging.sys_store ss on ss.id = wo.created_store_id
where
    wo.store_id = 22
    and wo.created_at >= '2022-11-30 18:00:00'
    and wo.created_at < '2023-02-28 18:00:00'
    and ss.id is not null;
;-- -. . -..- - / . -. - .-. -.--
select
    month(date_add(wo.created_at, interval 6 hour)) 月份
    ,wo.order_no
    ,wo.pnos
    ,wo.created_at 工单创建时间
#     ,count(distinct  wo.id) num
from bi_pro.work_order wo
left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id
join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name = 'Shopee'
left join fle_staging.sys_store ss on ss.id = wo.created_store_id
where
    wo.store_id = 22
    and wo.created_at >= '2022-11-30 18:00:00'
    and wo.created_at < '2023-02-28 18:00:00'
    and ss.id is not null;
;-- -. . -..- - / . -. - .-. -.--
with t1 as
(
    select
        plt.pno
        ,plt.id
        ,plt.client_id
        ,plt.created_at
    from bi_pro.parcel_lose_task plt
    where
        plt.state < 5
        and plt.source = 2
)
,t as
(
    select
        wo.id
        ,wo.loseparcel_task_id
        ,wo.created_at order_creat_at
        ,wor.content wor_content
        ,woi.object_key
        ,row_number() over (partition by wo.loseparcel_task_id order by wo.created_at) r1
        ,row_number() over (partition by wo.id order by wor.created_at desc ) r2
    from bi_pro.work_order wo
    left join bi_pro.work_order_reply wor on wor.order_id = wo.id
    left join bi_pro.work_order_img woi on woi.origin_id = wor.id
    join t1 on t1.id = wo.loseparcel_task_id
)
select
    t1.created_at 任务生成时间
    ,t1.id 任务ID
    ,t1.pno 运单号
    ,t1.client_id 客户ID
    ,las.route_action
    ,las.staff_info_id 最后有效路由操作人
    ,las_ss.name 最后有效路由网点
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
    ,dst_ss.name 目的地网点
    ,del_ss.name 妥投网点
    ,pi.ticket_delivery_staff_info_id 妥投快递员ID
    ,if(pi.state = 5 ,convert_tz(pi.finished_at, '+00:00', '+07:00'), null) 包裹妥投时间
    ,if(st_distance_sphere(point(pi.`ticket_delivery_staff_lng`, pi.`ticket_delivery_staff_lat`), point(del_ss.`lng`, del_ss.`lat`)) <= 100, '是', '否') 是否在网点妥投
    ,if(pi.state = 5 and pho.routed_at < pi.finished_at , '是', '否') 妥投前是否给客户打电话
    ,pi.dst_phone  收件人电话
    ,num.num 创建工单次数
    ,1st.order_creat_at 第一次创建工单时间
    ,1st.wor_content 第一次回复内容
    ,concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/',1st.object_key) 第一次回复附件
    ,2nd.wor_content 第二次回复内容
    ,concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/',2nd.object_key) 第二次回复附件
    ,3rd.wor_content 第三次回复内容
    ,concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/',3rd.object_key) 第三次回复附件
    ,concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/',sa1.object_key) 签收凭证
    ,concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/',sa2.object_key) 其他凭证
from t1
left join fle_staging.parcel_info pi on pi.pno = t1.pno
left join fle_staging.sys_store dst_ss on dst_ss.id = pi.dst_store_id
left join fle_staging.sys_store del_ss on del_ss.id = pi.ticket_delivery_store_id
left join
    (
        select
            *
        from
            (
                select
                    pr.route_action
                    ,pr.pno
                    ,pr.staff_info_id
                    ,pr.routed_at
                    ,pr.store_id
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
                 from rot_pro.parcel_route pr
                 join t1 on t1.pno = pr.pno
                where  pr.route_action in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','seal.ARRIVAL_WAREHOUSE_SCAN','INVENTORY','SORTING_SCAN')
                    and pr.routed_at > curdate() - interval 30 day
            ) pr
        where pr.rn = 1
    ) las on las.pno = t1.pno
left join fle_staging.sys_store las_ss on las_ss.id = las.store_id
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at) rn
        from rot_pro.parcel_route pr
        where pr.route_action = 'PHONE'
            and json_extract(pr.extra_value, '$.callDuration') > 7
            and pr.routed_at > curdate() - interval 30 day
    ) pho on pho.pno = t1.pno and pho.rn = 1
left join
    (
        select
            t.loseparcel_task_id
            ,count(distinct t.id) num
        from t
        group by 1
    ) num on num.loseparcel_task_id = t1.id
left join
    (
        select
            *
        from t
        where
            t.r1 = 1
            and t.r2 = 1
    ) 1st on 1st.loseparcel_task_id = t1.id
left join
    (
        select
            *
        from t
        where
            t.r2 = 1
            and t.r1 = 2
    ) 2nd on 2nd.loseparcel_task_id = t1.id
left join
    (
        select
            *
        from t
        where
            t.r2 = 1
            and t.r1 = 3
    ) 3rd on 3rd.loseparcel_task_id = t1.id
left join fle_staging.sys_attachment sa1 on sa1.oss_bucket_key = t1.pno and sa1.oss_bucket_type = 'DELIVERY_CONFIRM'
left join fle_staging.sys_attachment sa2 on sa2.oss_bucket_key = t1.pno and sa2.oss_bucket_type = 'DELIVERY_CONFIRM_OTHER';
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pss2.pno
        ,pss2.store_id
        ,pss2.van_arrived_at
        ,pss2.arrived_at
    from dw_dmd.parcel_store_stage_20230105 pss2
    join tmpale.tmp_th_0310_forward t on pss2.pno = t.pno

    union all

    select
        pss.pno
        ,pss.store_id
        ,pss.van_arrived_at
        ,pss.arrived_at
    from dw_dmd.parcel_store_stage_new pss
    join tmpale.tmp_th_0310_forward t on pss.pno = t.pno
)
select
    tt.*
    ,t1.到件入仓时间
    ,t1.到达时间
    ,t2.到达时间 到达始发hub时间
    ,t3.到达时间 到达末端hub时间
from tmpale.tmp_th_0310_forward tt
left join
    (
        select
            tt.末端网点id
            ,tt.pno
            ,min(t.van_arrived_at) 到达时间
            ,min(t.arrived_at ) 到件入仓时间
        from tmpale.tmp_th_0310_forward tt
        join t on tt.pno = t.pno and tt.末端网点id = t.store_id
        group by 1,2
    ) t1 on t1.pno = tt.pno and t1.末端网点id = tt.末端网点id
left join
    (
        select
            tt.pno
            ,tt.始发hub_id
            ,min(t.van_arrived_at) 到达时间
        from tmpale.tmp_th_0310_forward tt
        join t on tt.pno = t.pno and tt.始发hub_id = t.store_id
        group by 1,2
    ) t2 on t2.pno = tt.pno and t2.始发hub_id = tt.始发hub_id
left join
    (
        select 
            tt.pno
            ,tt.末端hubid
            ,min(t.van_arrived_at) 到达时间
        from tmpale.tmp_th_0310_forward tt
        join t on tt.pno = t.pno and tt.末端hubid = t.store_id
        group by 1,2
    ) t3 on t3.pno = tt.pno and t3.末端hubid = tt.末端hubid;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pss2.pno
        ,pss2.store_id
        ,pss2.van_arrived_at
        ,pss2.arrived_at
    from dw_dmd.parcel_store_stage_20230105 pss2
    join tmpale.tmp_th_0310_forward t on pss2.pno = t.pno

    union all

    select
        pss.pno
        ,pss.store_id
        ,pss.van_arrived_at
        ,pss.arrived_at
    from dw_dmd.parcel_store_stage_new pss
    join tmpale.tmp_th_0310_forward t on pss.pno = t.pno
)
select
    *
from tmpale.tmp_th_0310_forward tt
where
    tt.pno = 'TH100234G5VS3J';
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pss2.pno
        ,pss2.store_id
        ,pss2.van_arrived_at
        ,pss2.arrived_at
    from dw_dmd.parcel_store_stage_20230105 pss2
    join tmpale.tmp_th_0310_forward t on pss2.pno = t.pno

    union all

    select
        pss.pno
        ,pss.store_id
        ,pss.van_arrived_at
        ,pss.arrived_at
    from dw_dmd.parcel_store_stage_new pss
    join tmpale.tmp_th_0310_forward t on pss.pno = t.pno
)
select
    *
from t
where
    t.pno = 'TH100234G5VS3J';
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pss2.pno
        ,pss2.store_order
        ,pss2.store_id
        ,pss2.van_arrived_at
        ,pss2.arrived_at
    from dw_dmd.parcel_store_stage_20230105 pss2
    join tmpale.tmp_th_0310_forward t on pss2.pno = t.pno

    union all

    select
        pss.pno
        ,pss.store_order
        ,pss.store_id
        ,pss.van_arrived_at
        ,pss.arrived_at
    from dw_dmd.parcel_store_stage_new pss
    join tmpale.tmp_th_0310_forward t on pss.pno = t.pno
)
select
    *
from t
where
    t.pno = 'TH100234G5VS3J';
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pss2.pno
        ,pss2.store_category
        ,pss2.store_order
        ,pss2.store_id
        ,pss2.van_arrived_at
        ,pss2.arrived_at
    from dw_dmd.parcel_store_stage_20230105 pss2
    join tmpale.tmp_th_0310_forward t on pss2.pno = t.pno

    union all

    select
        pss.pno
        ,pss.store_category
        ,pss.store_order
        ,pss.store_id
        ,pss.van_arrived_at
        ,pss.arrived_at
    from dw_dmd.parcel_store_stage_new pss
    join tmpale.tmp_th_0310_forward t on pss.pno = t.pno
)
select
    *
from t
where
    t.pno = 'TH100234G5VS3J';
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pss2.pno
        ,pss2.store_category
        ,pss2.store_order
        ,pss2.store_id
        ,pss2.van_arrived_at
        ,pss2.arrived_at
    from dw_dmd.parcel_store_stage_20230105 pss2
    join tmpale.tmp_th_0310_forward t on pss2.pno = t.pno

    union all

    select
        pss.pno
        ,pss.store_category
        ,pss.store_order
        ,pss.store_id
        ,pss.van_arrived_at
        ,pss.arrived_at
    from dw_dmd.parcel_store_stage_new pss
    join tmpale.tmp_th_0310_forward t on pss.pno = t.pno
)
select
    count(*)
from
    (
        select
            distinct
            t.*
        from tmpale.tmp_th_0310_forward t
    ) t1
left join
    ( -- 末端网点
        select
            t1.*
        from
            (
                select
                    t.*
                    ,row_number() over (partition by t.pno order by t.store_order desc ) rk
                from t
            ) t1
        where
            t1.rk = 1
    ) t2 on t2.pno = t1.pno
left join
    (
        select
            t1.*
        from
            (
                select
                    t.*
                    ,row_number() over (partition by t.pno order by t.store_order ) rk
                from t
                where
                    t.store_category in (8,12)
            ) t1
        where
            t1.rk = 1
    ) t3 on t3.pno = t1.pno
left join
    (
        select
            t1.*
        from
            (
                select
                    t.*
                    ,row_number() over (partition by t.pno order by t.store_order desc) rk
                from t
                where
                    t.store_category in (8,12)
            ) t1
        where
            t1.rk = 1
    ) t4 on t4.pno = t1.pno and t4.store_id != t3.store_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pss2.pno
        ,pss2.store_name
        ,pss2.store_category
        ,pss2.store_order
        ,pss2.store_id
        ,pss2.van_arrived_at
        ,pss2.arrived_at
    from dw_dmd.parcel_store_stage_20230105 pss2
    join tmpale.tmp_th_0310_forward t on pss2.pno = t.pno

    union all

    select
        pss.pno
        ,pss.store_name
        ,pss.store_category
        ,pss.store_order
        ,pss.store_id
        ,pss.van_arrived_at
        ,pss.arrived_at
    from dw_dmd.parcel_store_stage_new pss
    join tmpale.tmp_th_0310_forward t on pss.pno = t.pno
)
select
#     count(*)
    t1.揽收时间
    ,t1.揽收网点
    ,t1.揽收大区
    ,t1.揽收片区
    ,t1.揽收员工工号
    ,t1.揽收员工
    ,t1.pno
    ,t2.store_name 末端网点
    ,t2.region_name 末端大区
    ,t2.piece_name 末端片区
    ,t3.store_name 始发hub
    ,t3.van_arrived_at 到达始发hub时间
    ,t4.store_name 末端hub
    ,t4.van_arrived_at 到达末端hub时间
    ,t2.van_arrived_at 到达时间
    ,t2.arrived_at 到件入仓时间
    ,t1.派件员工 派件员工姓名
    ,t1.派件员工id
    ,t1.第一次扫描派送时间
    ,t1.第一次打电话时间
from
    (
        select
            distinct
            t.*
        from tmpale.tmp_th_0310_forward t
    ) t1
left join
    ( -- 末端网点
        select
            t1.*
        from
            (
                select
                    t.*
                    ,dt.piece_name
                    ,dt.region_name
                    ,row_number() over (partition by t.pno order by t.store_order desc ) rk
                from t
                left join dwm.dim_th_sys_store_rd dt on dt.store_id = t.store_id and dt.stat_date = date_sub(curdate(),interval  1 day )
            ) t1
        where
            t1.rk = 1
    ) t2 on t2.pno = t1.pno
left join
    ( -- 始发hub
        select
            t1.*
        from
            (
                select
                    t.*
                    ,row_number() over (partition by t.pno order by t.store_order ) rk
                from t
                where
                    t.store_category in (8,12)
            ) t1
        where
            t1.rk = 1
    ) t3 on t3.pno = t1.pno
left join
    ( -- 末端hub
        select
            t1.*
        from
            (
                select
                    t.*
                    ,row_number() over (partition by t.pno order by t.store_order desc) rk
                from t
                where
                    t.store_category in (8,12)
            ) t1
        where
            t1.rk = 1
    ) t4 on t4.pno = t1.pno and t4.store_id != t3.store_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pss2.pno
        ,pss2.store_name
        ,pss2.store_category
        ,pss2.store_order
        ,pss2.store_id
        ,pss2.van_arrived_at
        ,pss2.arrived_at
    from dw_dmd.parcel_store_stage_20230105 pss2
    join tmpale.tmp_th_0310_reverse  t on pss2.pno = t.pno

    union all

    select
        pss.pno
        ,pss.store_name
        ,pss.store_category
        ,pss.store_order
        ,pss.store_id
        ,pss.van_arrived_at
        ,pss.arrived_at
    from dw_dmd.parcel_store_stage_new pss
    join tmpale.tmp_th_0310_reverse t on pss.pno = t.pno
)
select
    t1.揽收网点
    ,t1.揽收大区
    ,t1.揽收片区
    ,t1.揽收员工工号
    ,t1.揽收员工
    ,t1.pno
    ,t1.末端网点
    ,t1.末端大区
    ,t1.末端片区
    ,t3.store_name 始发hub
    ,t3.van_arrived_at 到达始发hub时间
    ,t4.store_name 末端hub
    ,t4.van_arrived_at 到达末端hub时间
    ,t2.van_arrived_at 到达时间
    ,t2.arrived_at 到件入仓时间
from
    (
        select
            distinct
            t.*
        from tmpale.tmp_th_0310_reverse t
    ) t1
left join
    ( -- 末端网点
        select
            t.pno
            ,t.store_id
            ,min(t.van_arrived_at) van_arrived_at
            ,min(t.arrived_at) arrived_at
        from t
        join tmpale.tmp_th_0310_reverse tt on tt.末端网点id = t.store_id
        group by 1,2
    ) t2 on t2.pno = t1.pno
left join
    ( -- 始发hub
        select
            t1.*
        from
            (
                select
                    t.*
                    ,row_number() over (partition by t.pno order by t.store_order ) rk
                from t
                where
                    t.store_category in (8,12)
            ) t1
        where
            t1.rk = 1
    ) t3 on t3.pno = t1.pno
left join
    ( -- 末端hub
        select
            t1.*
        from
            (
                select
                    t.*
                    ,row_number() over (partition by t.pno order by t.store_order desc) rk
                from t
                where
                    t.store_category in (8,12)
            ) t1
        where
            t1.rk = 1
    ) t4 on t4.pno = t1.pno and t4.store_id != t3.store_id;
;-- -. . -..- - / . -. - .-. -.--
select
    t1.*
    ,t2.*
from tmpale.tmp_th_0310_t1 t1
left join tmp_th_pno_0310 t on t1.pno = t.pno
left join tmpale.tmp_th_0310_t2 t2 on t2.pno = t.return_pno;
;-- -. . -..- - / . -. - .-. -.--
select
    t1.*
    ,t2.*
from tmpale.tmp_th_0310_t1 t1
left join
    (
        select
            distinct
            t.*
        from tmpale.tmp_th_pno_0310 t
    ) t on t1.pno = t.pno
left join tmpale.tmp_th_0310_t2 t2 on t2.pno = t.return_pno;
;-- -. . -..- - / . -. - .-. -.--
select
    *
from
    (
            select
                t.return_pno
                ,tdt.dst_staff_info_id
                ,row_number() over (partition by t.pno order by tdt.created_at desc) rn
            from fle_staging.ticket_delivery_transfer tdt
            left join fle_staging.ticket_delivery td on tdt.src_pickup_id = td.id
            join tmpale.tmp_th_pno_0310 t on td.pno = t.return_pno
    ) t
where
    t.rn = 1;
;-- -. . -..- - / . -. - .-. -.--
select
    *
from
    (
        select
            t.pno
            ,tdt.dst_staff_info_id
            ,row_number() over (partition by t.pno order by tdt.created_at) rn
        from fle_staging.ticket_delivery_transfer tdt
        join tmpale.tmp_th_delivery_0310 t on t.delivery_id = tdt.src_pickup_id
    ) t
where
    t.rn = 1;
;-- -. . -..- - / . -. - .-. -.--
select
    *
from
    (
        select
            t.return_pno
            ,tdt.dst_staff_info_id
            ,row_number() over (partition by t.return_pno order by tdt.created_at) rn
        from fle_staging.ticket_delivery_transfer tdt
        join tmpale.tmp_th_delivery_0310 t on t.delivery_id = tdt.src_pickup_id
    ) t
where
    t.rn = 1;
;-- -. . -..- - / . -. - .-. -.--
select
    *
from
    (
        select
            t.return_pno
            ,tdt.dst_staff_info_id
            ,row_number() over (partition by t.return_pno order by tdt.created_at desc) rn
        from fle_staging.ticket_delivery_transfer tdt
        join tmpale.tmp_th_delivery_0310 t on t.delivery_id = tdt.src_pickup_id
    ) t
where
    t.rn = 1;
;-- -. . -..- - / . -. - .-. -.--
select
    *
from
    (
        select
            t.return_pno
            ,tdt.dst_staff_info_id
            ,row_number() over (partition by t.return_pno order by tdt.created_at desc) rn
        from fle_staging.ticket_delivery_transfer tdt
        join tmpale.tmp_th_delivery_0310 t on t.delivery_id = tdt.src_pickup_id
    ) t
left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = t.dst_staff_info_id
where
    t.rn = 1;
;-- -. . -..- - / . -. - .-. -.--
with t1 as
(
    select
        plt.pno
        ,plt.id
        ,plt.client_id
        ,plt.created_at
    from bi_pro.parcel_lose_task plt
    where
        plt.state < 5
        and plt.source = 2
)
,t as
(
    select
        wo.id
        ,wo.loseparcel_task_id
        ,wo.created_at order_creat_at
        ,wor.content wor_content
        ,woi.object_key
        ,row_number() over (partition by wo.loseparcel_task_id order by wo.created_at) r1
        ,row_number() over (partition by wo.id order by wor.created_at desc ) r2
    from bi_pro.work_order wo
    left join bi_pro.work_order_reply wor on wor.order_id = wo.id
    left join bi_pro.work_order_img woi on woi.origin_id = wor.id
    join t1 on t1.id = wo.loseparcel_task_id
)
select
    t1.created_at 任务生成时间
    ,t1.id 任务ID
    ,t1.pno 运单号
    ,t1.client_id 客户ID
    ,las2.route_action
    ,case las2.route_action # 路由动作
         when 'ACCEPT_PARCEL' then '接件扫描'
         when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then '车货关联到港'
         when 'ARRIVAL_WAREHOUSE_SCAN' then '到件入仓扫描'
         when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then '取消到件入仓扫描'
         when 'CANCEL_PARCEL' then '撤销包裹'
         when 'CANCEL_SHIPMENT_WAREHOUSE' then '取消发件出仓'
         when 'CHANGE_PARCEL_CANCEL' then '修改包裹为撤销'
         when 'CHANGE_PARCEL_CLOSE' then '修改包裹为异常关闭'
         when 'CHANGE_PARCEL_IN_TRANSIT' then '修改包裹为运输中'
         when 'CHANGE_PARCEL_INFO' then '修改包裹信息'
         when 'CHANGE_PARCEL_SIGNED' then '修改包裹为签收'
         when 'CLAIMS_CLOSE' then '理赔关闭'
         when 'CLAIMS_COMPLETE' then '理赔完成'
         when 'CLAIMS_CONTACT' then '已联系客户'
         when 'CLAIMS_TRANSFER_CS' then '转交总部cs处理'
         when 'CLOSE_ORDER' then '关闭订单'
         when 'CONTINUE_TRANSPORT' then '疑难件继续配送'
         when 'CREATE_WORK_ORDER' then '创建工单'
         when 'CUSTOMER_CHANGE_PARCEL_INFO' then '客户修改包裹信息'
         when 'CUSTOMER_OPERATING_RETURN' then '客户操作退回寄件人'
         when 'DELIVERY_CONFIRM' then '确认妥投'
         when 'DELIVERY_MARKER' then '派件标记'
         when 'DELIVERY_PICKUP_STORE_SCAN' then '自提取件扫描'
         when 'DELIVERY_TICKET_CREATION_SCAN' then '交接扫描'
         when 'DELIVERY_TRANSFER' then '派件转单'
         when 'DEPARTURE_GOODS_VAN_CK_SCAN' then '车货关联出港'
         when 'DETAIN_WAREHOUSE' then '货件留仓'
         when 'DIFFICULTY_FINISH_INDEMNITY' then '疑难件支付赔偿'
         when 'DIFFICULTY_HANDOVER' then '疑难件交接'
         when 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE' then '疑难件交接货件留仓'
         when 'DIFFICULTY_RE_TRANSIT' then '疑难件退回区域总部/重启运送'
         when 'DIFFICULTY_RETURN' then '疑难件退回寄件人'
         when 'DIFFICULTY_SEAL' then '集包异常'
         when 'DISCARD_RETURN_BKK' then '丢弃包裹的，换单后寄回BKK'
         when 'DISTRIBUTION_INVENTORY' then '分拨盘库'
         when 'DWS_WEIGHT_IMAGE' then 'DWS复秤照片'
         when 'EXCHANGE_PARCEL' then '换货'
         when 'FAKE_CANCEL_HANDLE' then '虚假撤销判责'
         when 'FLASH_HOME_SCAN' then 'FH交接扫描'
         when 'FORCE_TAKE_PHOTO' then '强制拍照路由'
         when 'HAVE_HAIR_SCAN_NO_TO' then '有发无到'
         when 'HURRY_PARCEL' then '催单'
         when 'INCOMING_CALL' then '来电接听'
         when 'INTERRUPT_PARCEL_AND_RETURN' then '中断运输并退回'
         when 'INVENTORY' then '盘库'
         when 'LOSE_PARCEL_TEAM_OPERATION' then '丢失件团队处理'
         when 'MANUAL_REMARK' then '添加备注'
         when 'MISS_PICKUP_HANDLE' then '漏包裹揽收判责'
         when 'MISSING_PARCEL_SCAN' then '丢失件包裹操作'
         when 'NOTICE_LOST_PARTS_TEAM' then '已通知丢失件团队'
         when 'PARCEL_HEADLESS_CLAIMED' then '无头件包裹已认领'
         when 'PARCEL_HEADLESS_PRINTED' then '无头件包裹已打单'
         when 'PENDING_RETURN' then '待退件'
         when 'PHONE' then '电话联系'
         when 'PICK_UP_STORE' then '待自提取件'
         when 'PICKUP_RETURN_RECEIPT' then '签回单揽收'
         when 'PRINTING' then '打印面单'
         when 'QAQC_OPERATION' then 'QAQC判责'
         when 'RECEIVE_WAREHOUSE_SCAN' then '收件入仓'
         when 'RECEIVED' then '已揽收,初始化动作，实际情况并没有作用'
         when 'REFUND_CONFIRM' then '退件妥投'
         when 'REPAIRED' then '上报问题修复路由'
         when 'REPLACE_PNO' then '换单'
         when 'REPLY_WORK_ORDER' then '回复工单'
         when 'REVISION_TIME' then '改约时间'
         when 'SEAL' then '集包'
         when 'SEAL_NUMBER_CHANGE' then '集包件数变化'
         when 'SHIPMENT_WAREHOUSE_SCAN' then '发件出仓扫描'
         when 'SORTER_WEIGHT_IMAGE' then '分拣机复秤照片'
         when 'SORTING_SCAN' then '分拣扫描'
         when 'STAFF_INFO_UPDATE_WEIGHT' then '快递员修改重量'
         when 'STORE_KEEPER_UPDATE_WEIGHT' then '仓管员复秤'
         when 'STORE_SORTER_UPDATE_WEIGHT' then '分拣机复秤'
         when 'SYSTEM_AUTO_RETURN' then '系统自动退件'
         when 'TAKE_PHOTO' then '异常打单拍照'
         when 'THIRD_EXPRESS_ROUTE' then '第三方公司路由'
         when 'THIRD_PARTY_REASON_DETAIN' then '第三方原因滞留'
         when 'TICKET_WEIGHT_IMAGE' then '揽收称重照片'
         when 'TRANSFER_LOST_PARTS_TEAM' then '已转交丢失件团队'
         when 'TRANSFER_QAQC' then '转交QAQC处理'
         when 'UNSEAL' then '拆包'
         when 'UNSEAL_NO_PARCEL' then '上报包裹不在集包里'
         when 'UNSEAL_NOT_SCANNED' then '集包已拆包，本包裹未被扫描'
         when 'VEHICLE_ACCIDENT_REG' then '车辆车祸登记'
         when 'VEHICLE_ACCIDENT_REGISTRATION' then '车辆车祸登记'
         when 'VEHICLE_WET_DAMAGE_REG' then '车辆湿损登记'
         when 'VEHICLE_WET_DAMAGE_REGISTRATION' then '车辆湿损登记'
        end as 最后一条路由
    ,las2.remark 最后一条路由备注
    ,mark.remark 最后一条包裹备注
    ,las.staff_info_id 最后有效路由操作人
    ,las_ss.name 最后有效路由网点
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
    ,dst_ss.name 目的地网点
    ,del_ss.name 妥投网点
    ,pi.ticket_delivery_staff_info_id 妥投快递员ID
    ,if(pi.state = 5 ,convert_tz(pi.finished_at, '+00:00', '+07:00'), null) 包裹妥投时间
    ,if(st_distance_sphere(point(pi.`ticket_delivery_staff_lng`, pi.`ticket_delivery_staff_lat`), point(del_ss.`lng`, del_ss.`lat`)) <= 100, '是', '否') 是否在网点妥投
    ,if(pi.state = 5 and pho.routed_at < pi.finished_at , '是', '否') 妥投前是否给客户打电话
    ,pi.dst_phone  收件人电话
    ,num.num 创建工单次数
    ,1st.order_creat_at 第一次创建工单时间
    ,1st.wor_content 第一次回复内容
    ,concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/',1st.object_key) 第一次回复附件
    ,2nd.wor_content 第二次回复内容
    ,concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/',2nd.object_key) 第二次回复附件
    ,3rd.wor_content 第三次回复内容
    ,concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/',3rd.object_key) 第三次回复附件
    ,concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/',sa1.object_key) 签收凭证
    ,concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/',sa2.object_key) 其他凭证
from t1
left join fle_staging.parcel_info pi on pi.pno = t1.pno
left join fle_staging.sys_store dst_ss on dst_ss.id = pi.dst_store_id
left join fle_staging.sys_store del_ss on del_ss.id = pi.ticket_delivery_store_id
left join
    (
        select
            *
        from
            (
                select
                    pr.route_action
                    ,pr.pno
                    ,pr.staff_info_id
                    ,pr.routed_at
                    ,pr.store_id
                    ,pr.remark
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
                 from rot_pro.parcel_route pr
                 join t1 on t1.pno = pr.pno
                where  pr.route_action in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','seal.ARRIVAL_WAREHOUSE_SCAN','INVENTORY','SORTING_SCAN')
                    and pr.routed_at > curdate() - interval 30 day
            ) pr
        where pr.rn = 1
    ) las on las.pno = t1.pno
left join
    (
        select
            *
        from
            (
                select
                    pr.route_action
                    ,pr.pno
                    ,pr.staff_info_id
                    ,pr.routed_at
                    ,pr.store_id
                    ,pr.remark
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
                 from rot_pro.parcel_route pr
                 join
                     (
                        select t1.pno from t1 group by 1
                    )t1 on t1.pno = pr.pno
                where
                    pr.routed_at > curdate() - interval 30 day
            ) pr
        where pr.rn = 1
    ) las2 on las.pno = t1.pno
left join fle_staging.sys_store las_ss on las_ss.id = las.store_id
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at) rn
        from rot_pro.parcel_route pr
        where pr.route_action = 'PHONE'
            and json_extract(pr.extra_value, '$.callDuration') > 7
            and pr.routed_at > curdate() - interval 30 day
    ) pho on pho.pno = t1.pno and pho.rn = 1
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rn
            ,pr.remark
        from rot_pro.parcel_route pr
        join
            (
                select t1.pno from t1 group by 1
            ) t on pr.pno = t.pno
        where pr.route_action = 'MANUAL_REMARK'
            and pr.routed_at > curdate() - interval 30 day
    ) mark on mark.pno = t1.pno and mark.rn = 1
left join
    (
        select
            t.loseparcel_task_id
            ,count(distinct t.id) num
        from t
        group by 1
    ) num on num.loseparcel_task_id = t1.id
left join
    (
        select
            *
        from t
        where
            t.r1 = 1
            and t.r2 = 1
    ) 1st on 1st.loseparcel_task_id = t1.id
left join
    (
        select
            *
        from t
        where
            t.r2 = 1
            and t.r1 = 2
    ) 2nd on 2nd.loseparcel_task_id = t1.id
left join
    (
        select
            *
        from t
        where
            t.r2 = 1
            and t.r1 = 3
    ) 3rd on 3rd.loseparcel_task_id = t1.id
left join fle_staging.sys_attachment sa1 on sa1.oss_bucket_key = t1.pno and sa1.oss_bucket_type = 'DELIVERY_CONFIRM'
left join fle_staging.sys_attachment sa2 on sa2.oss_bucket_key = t1.pno and sa2.oss_bucket_type = 'DELIVERY_CONFIRM_OTHER';
;-- -. . -..- - / . -. - .-. -.--
with t1 as
(
    select
        plt.pno
        ,plt.id
        ,plt.client_id
        ,plt.created_at
    from bi_pro.parcel_lose_task plt
    where
        plt.state < 5
        and plt.source = 2
)
,t as
(
    select
        wo.id
        ,wo.loseparcel_task_id
        ,wo.created_at order_creat_at
        ,wor.content wor_content
        ,woi.object_key
        ,row_number() over (partition by wo.loseparcel_task_id order by wo.created_at) r1
        ,row_number() over (partition by wo.id order by wor.created_at desc ) r2
    from bi_pro.work_order wo
    left join bi_pro.work_order_reply wor on wor.order_id = wo.id
    left join bi_pro.work_order_img woi on woi.origin_id = wor.id
    join t1 on t1.id = wo.loseparcel_task_id
)
select
    t1.created_at 任务生成时间
    ,t1.id 任务ID
    ,t1.pno 运单号
    ,t1.client_id 客户ID
    ,las2.route_action
    ,case las2.route_action # 路由动作
         when 'ACCEPT_PARCEL' then '接件扫描'
         when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then '车货关联到港'
         when 'ARRIVAL_WAREHOUSE_SCAN' then '到件入仓扫描'
         when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then '取消到件入仓扫描'
         when 'CANCEL_PARCEL' then '撤销包裹'
         when 'CANCEL_SHIPMENT_WAREHOUSE' then '取消发件出仓'
         when 'CHANGE_PARCEL_CANCEL' then '修改包裹为撤销'
         when 'CHANGE_PARCEL_CLOSE' then '修改包裹为异常关闭'
         when 'CHANGE_PARCEL_IN_TRANSIT' then '修改包裹为运输中'
         when 'CHANGE_PARCEL_INFO' then '修改包裹信息'
         when 'CHANGE_PARCEL_SIGNED' then '修改包裹为签收'
         when 'CLAIMS_CLOSE' then '理赔关闭'
         when 'CLAIMS_COMPLETE' then '理赔完成'
         when 'CLAIMS_CONTACT' then '已联系客户'
         when 'CLAIMS_TRANSFER_CS' then '转交总部cs处理'
         when 'CLOSE_ORDER' then '关闭订单'
         when 'CONTINUE_TRANSPORT' then '疑难件继续配送'
         when 'CREATE_WORK_ORDER' then '创建工单'
         when 'CUSTOMER_CHANGE_PARCEL_INFO' then '客户修改包裹信息'
         when 'CUSTOMER_OPERATING_RETURN' then '客户操作退回寄件人'
         when 'DELIVERY_CONFIRM' then '确认妥投'
         when 'DELIVERY_MARKER' then '派件标记'
         when 'DELIVERY_PICKUP_STORE_SCAN' then '自提取件扫描'
         when 'DELIVERY_TICKET_CREATION_SCAN' then '交接扫描'
         when 'DELIVERY_TRANSFER' then '派件转单'
         when 'DEPARTURE_GOODS_VAN_CK_SCAN' then '车货关联出港'
         when 'DETAIN_WAREHOUSE' then '货件留仓'
         when 'DIFFICULTY_FINISH_INDEMNITY' then '疑难件支付赔偿'
         when 'DIFFICULTY_HANDOVER' then '疑难件交接'
         when 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE' then '疑难件交接货件留仓'
         when 'DIFFICULTY_RE_TRANSIT' then '疑难件退回区域总部/重启运送'
         when 'DIFFICULTY_RETURN' then '疑难件退回寄件人'
         when 'DIFFICULTY_SEAL' then '集包异常'
         when 'DISCARD_RETURN_BKK' then '丢弃包裹的，换单后寄回BKK'
         when 'DISTRIBUTION_INVENTORY' then '分拨盘库'
         when 'DWS_WEIGHT_IMAGE' then 'DWS复秤照片'
         when 'EXCHANGE_PARCEL' then '换货'
         when 'FAKE_CANCEL_HANDLE' then '虚假撤销判责'
         when 'FLASH_HOME_SCAN' then 'FH交接扫描'
         when 'FORCE_TAKE_PHOTO' then '强制拍照路由'
         when 'HAVE_HAIR_SCAN_NO_TO' then '有发无到'
         when 'HURRY_PARCEL' then '催单'
         when 'INCOMING_CALL' then '来电接听'
         when 'INTERRUPT_PARCEL_AND_RETURN' then '中断运输并退回'
         when 'INVENTORY' then '盘库'
         when 'LOSE_PARCEL_TEAM_OPERATION' then '丢失件团队处理'
         when 'MANUAL_REMARK' then '添加备注'
         when 'MISS_PICKUP_HANDLE' then '漏包裹揽收判责'
         when 'MISSING_PARCEL_SCAN' then '丢失件包裹操作'
         when 'NOTICE_LOST_PARTS_TEAM' then '已通知丢失件团队'
         when 'PARCEL_HEADLESS_CLAIMED' then '无头件包裹已认领'
         when 'PARCEL_HEADLESS_PRINTED' then '无头件包裹已打单'
         when 'PENDING_RETURN' then '待退件'
         when 'PHONE' then '电话联系'
         when 'PICK_UP_STORE' then '待自提取件'
         when 'PICKUP_RETURN_RECEIPT' then '签回单揽收'
         when 'PRINTING' then '打印面单'
         when 'QAQC_OPERATION' then 'QAQC判责'
         when 'RECEIVE_WAREHOUSE_SCAN' then '收件入仓'
         when 'RECEIVED' then '已揽收,初始化动作，实际情况并没有作用'
         when 'REFUND_CONFIRM' then '退件妥投'
         when 'REPAIRED' then '上报问题修复路由'
         when 'REPLACE_PNO' then '换单'
         when 'REPLY_WORK_ORDER' then '回复工单'
         when 'REVISION_TIME' then '改约时间'
         when 'SEAL' then '集包'
         when 'SEAL_NUMBER_CHANGE' then '集包件数变化'
         when 'SHIPMENT_WAREHOUSE_SCAN' then '发件出仓扫描'
         when 'SORTER_WEIGHT_IMAGE' then '分拣机复秤照片'
         when 'SORTING_SCAN' then '分拣扫描'
         when 'STAFF_INFO_UPDATE_WEIGHT' then '快递员修改重量'
         when 'STORE_KEEPER_UPDATE_WEIGHT' then '仓管员复秤'
         when 'STORE_SORTER_UPDATE_WEIGHT' then '分拣机复秤'
         when 'SYSTEM_AUTO_RETURN' then '系统自动退件'
         when 'TAKE_PHOTO' then '异常打单拍照'
         when 'THIRD_EXPRESS_ROUTE' then '第三方公司路由'
         when 'THIRD_PARTY_REASON_DETAIN' then '第三方原因滞留'
         when 'TICKET_WEIGHT_IMAGE' then '揽收称重照片'
         when 'TRANSFER_LOST_PARTS_TEAM' then '已转交丢失件团队'
         when 'TRANSFER_QAQC' then '转交QAQC处理'
         when 'UNSEAL' then '拆包'
         when 'UNSEAL_NO_PARCEL' then '上报包裹不在集包里'
         when 'UNSEAL_NOT_SCANNED' then '集包已拆包，本包裹未被扫描'
         when 'VEHICLE_ACCIDENT_REG' then '车辆车祸登记'
         when 'VEHICLE_ACCIDENT_REGISTRATION' then '车辆车祸登记'
         when 'VEHICLE_WET_DAMAGE_REG' then '车辆湿损登记'
         when 'VEHICLE_WET_DAMAGE_REGISTRATION' then '车辆湿损登记'
        end as 最后一条路由
    ,las2.remark 最后一条路由备注
    ,mark.remark 最后一条包裹备注
    ,las.staff_info_id 最后有效路由操作人
    ,las_ss.name 最后有效路由网点
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
    ,dst_ss.name 目的地网点
    ,del_ss.name 妥投网点
    ,pi.ticket_delivery_staff_info_id 妥投快递员ID
    ,if(pi.state = 5 ,convert_tz(pi.finished_at, '+00:00', '+07:00'), null) 包裹妥投时间
    ,if(st_distance_sphere(point(pi.`ticket_delivery_staff_lng`, pi.`ticket_delivery_staff_lat`), point(del_ss.`lng`, del_ss.`lat`)) <= 100, '是', '否') 是否在网点妥投
    ,if(pi.state = 5 and pho.routed_at < pi.finished_at , '是', '否') 妥投前是否给客户打电话
    ,pi.dst_phone  收件人电话
    ,num.num 创建工单次数
    ,1st.order_creat_at 第一次创建工单时间
    ,1st.wor_content 第一次回复内容
    ,concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/',1st.object_key) 第一次回复附件
    ,2nd.wor_content 第二次回复内容
    ,concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/',2nd.object_key) 第二次回复附件
    ,3rd.wor_content 第三次回复内容
    ,concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/',3rd.object_key) 第三次回复附件
    ,concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/',sa1.object_key) 签收凭证
    ,concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/',sa2.object_key) 其他凭证
from t1
left join fle_staging.parcel_info pi on pi.pno = t1.pno
left join fle_staging.sys_store dst_ss on dst_ss.id = pi.dst_store_id
left join fle_staging.sys_store del_ss on del_ss.id = pi.ticket_delivery_store_id
left join
    (
        select
            *
        from
            (
                select
                    pr.route_action
                    ,pr.pno
                    ,pr.staff_info_id
                    ,pr.routed_at
                    ,pr.store_id
                    ,pr.remark
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
                 from rot_pro.parcel_route pr
                 join t1 on t1.pno = pr.pno
                where  pr.route_action in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','seal.ARRIVAL_WAREHOUSE_SCAN','INVENTORY','SORTING_SCAN')
                    and pr.routed_at > curdate() - interval 30 day
            ) pr
        where pr.rn = 1
    ) las on las.pno = t1.pno
left join
    (
        select
            *
        from
            (
                select
                    pr.route_action
                    ,pr.pno
                    ,pr.staff_info_id
                    ,pr.routed_at
                    ,pr.store_id
                    ,pr.remark
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
                 from rot_pro.parcel_route pr
                 join
                     (
                        select t1.pno from t1 group by 1
                    )t1 on t1.pno = pr.pno
                where
                    pr.routed_at > curdate() - interval 30 day
            ) pr
        where pr.rn = 1
    ) las2 on las2.pno = t1.pno
left join fle_staging.sys_store las_ss on las_ss.id = las.store_id
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at) rn
        from rot_pro.parcel_route pr
        where pr.route_action = 'PHONE'
            and json_extract(pr.extra_value, '$.callDuration') > 7
            and pr.routed_at > curdate() - interval 30 day
    ) pho on pho.pno = t1.pno and pho.rn = 1
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rn
            ,pr.remark
        from rot_pro.parcel_route pr
        join
            (
                select t1.pno from t1 group by 1
            ) t on pr.pno = t.pno
        where pr.route_action = 'MANUAL_REMARK'
            and pr.routed_at > curdate() - interval 30 day
    ) mark on mark.pno = t1.pno and mark.rn = 1
left join
    (
        select
            t.loseparcel_task_id
            ,count(distinct t.id) num
        from t
        group by 1
    ) num on num.loseparcel_task_id = t1.id
left join
    (
        select
            *
        from t
        where
            t.r1 = 1
            and t.r2 = 1
    ) 1st on 1st.loseparcel_task_id = t1.id
left join
    (
        select
            *
        from t
        where
            t.r2 = 1
            and t.r1 = 2
    ) 2nd on 2nd.loseparcel_task_id = t1.id
left join
    (
        select
            *
        from t
        where
            t.r2 = 1
            and t.r1 = 3
    ) 3rd on 3rd.loseparcel_task_id = t1.id
left join fle_staging.sys_attachment sa1 on sa1.oss_bucket_key = t1.pno and sa1.oss_bucket_type = 'DELIVERY_CONFIRM'
left join fle_staging.sys_attachment sa2 on sa2.oss_bucket_key = t1.pno and sa2.oss_bucket_type = 'DELIVERY_CONFIRM_OTHER';
;-- -. . -..- - / . -. - .-. -.--
select
    sa.oss_bucket_type
from fle_staging.sys_attachment sa
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with t1 as
(
    select
        plt.pno
        ,plt.id
        ,plt.client_id
        ,plt.created_at
    from bi_pro.parcel_lose_task plt
    where
        plt.state < 5
        and plt.source = 2
)
,t as
(
    select
        wo.id
        ,wo.loseparcel_task_id
        ,wo.created_at order_creat_at
        ,wor.content wor_content
        ,woi.object_key
        ,row_number() over (partition by wo.loseparcel_task_id order by wo.created_at) r1
        ,row_number() over (partition by wo.id order by wor.created_at desc ) r2
    from bi_pro.work_order wo
    left join bi_pro.work_order_reply wor on wor.order_id = wo.id
    left join bi_pro.work_order_img woi on woi.origin_id = wor.id
    join t1 on t1.id = wo.loseparcel_task_id
)
select
    t1.created_at 任务生成时间
    ,t1.id 任务ID
    ,t1.pno 运单号
    ,t1.client_id 客户ID
    ,las2.route_action
    ,case las2.route_action # 路由动作
         when 'ACCEPT_PARCEL' then '接件扫描'
         when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then '车货关联到港'
         when 'ARRIVAL_WAREHOUSE_SCAN' then '到件入仓扫描'
         when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then '取消到件入仓扫描'
         when 'CANCEL_PARCEL' then '撤销包裹'
         when 'CANCEL_SHIPMENT_WAREHOUSE' then '取消发件出仓'
         when 'CHANGE_PARCEL_CANCEL' then '修改包裹为撤销'
         when 'CHANGE_PARCEL_CLOSE' then '修改包裹为异常关闭'
         when 'CHANGE_PARCEL_IN_TRANSIT' then '修改包裹为运输中'
         when 'CHANGE_PARCEL_INFO' then '修改包裹信息'
         when 'CHANGE_PARCEL_SIGNED' then '修改包裹为签收'
         when 'CLAIMS_CLOSE' then '理赔关闭'
         when 'CLAIMS_COMPLETE' then '理赔完成'
         when 'CLAIMS_CONTACT' then '已联系客户'
         when 'CLAIMS_TRANSFER_CS' then '转交总部cs处理'
         when 'CLOSE_ORDER' then '关闭订单'
         when 'CONTINUE_TRANSPORT' then '疑难件继续配送'
         when 'CREATE_WORK_ORDER' then '创建工单'
         when 'CUSTOMER_CHANGE_PARCEL_INFO' then '客户修改包裹信息'
         when 'CUSTOMER_OPERATING_RETURN' then '客户操作退回寄件人'
         when 'DELIVERY_CONFIRM' then '确认妥投'
         when 'DELIVERY_MARKER' then '派件标记'
         when 'DELIVERY_PICKUP_STORE_SCAN' then '自提取件扫描'
         when 'DELIVERY_TICKET_CREATION_SCAN' then '交接扫描'
         when 'DELIVERY_TRANSFER' then '派件转单'
         when 'DEPARTURE_GOODS_VAN_CK_SCAN' then '车货关联出港'
         when 'DETAIN_WAREHOUSE' then '货件留仓'
         when 'DIFFICULTY_FINISH_INDEMNITY' then '疑难件支付赔偿'
         when 'DIFFICULTY_HANDOVER' then '疑难件交接'
         when 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE' then '疑难件交接货件留仓'
         when 'DIFFICULTY_RE_TRANSIT' then '疑难件退回区域总部/重启运送'
         when 'DIFFICULTY_RETURN' then '疑难件退回寄件人'
         when 'DIFFICULTY_SEAL' then '集包异常'
         when 'DISCARD_RETURN_BKK' then '丢弃包裹的，换单后寄回BKK'
         when 'DISTRIBUTION_INVENTORY' then '分拨盘库'
         when 'DWS_WEIGHT_IMAGE' then 'DWS复秤照片'
         when 'EXCHANGE_PARCEL' then '换货'
         when 'FAKE_CANCEL_HANDLE' then '虚假撤销判责'
         when 'FLASH_HOME_SCAN' then 'FH交接扫描'
         when 'FORCE_TAKE_PHOTO' then '强制拍照路由'
         when 'HAVE_HAIR_SCAN_NO_TO' then '有发无到'
         when 'HURRY_PARCEL' then '催单'
         when 'INCOMING_CALL' then '来电接听'
         when 'INTERRUPT_PARCEL_AND_RETURN' then '中断运输并退回'
         when 'INVENTORY' then '盘库'
         when 'LOSE_PARCEL_TEAM_OPERATION' then '丢失件团队处理'
         when 'MANUAL_REMARK' then '添加备注'
         when 'MISS_PICKUP_HANDLE' then '漏包裹揽收判责'
         when 'MISSING_PARCEL_SCAN' then '丢失件包裹操作'
         when 'NOTICE_LOST_PARTS_TEAM' then '已通知丢失件团队'
         when 'PARCEL_HEADLESS_CLAIMED' then '无头件包裹已认领'
         when 'PARCEL_HEADLESS_PRINTED' then '无头件包裹已打单'
         when 'PENDING_RETURN' then '待退件'
         when 'PHONE' then '电话联系'
         when 'PICK_UP_STORE' then '待自提取件'
         when 'PICKUP_RETURN_RECEIPT' then '签回单揽收'
         when 'PRINTING' then '打印面单'
         when 'QAQC_OPERATION' then 'QAQC判责'
         when 'RECEIVE_WAREHOUSE_SCAN' then '收件入仓'
         when 'RECEIVED' then '已揽收,初始化动作，实际情况并没有作用'
         when 'REFUND_CONFIRM' then '退件妥投'
         when 'REPAIRED' then '上报问题修复路由'
         when 'REPLACE_PNO' then '换单'
         when 'REPLY_WORK_ORDER' then '回复工单'
         when 'REVISION_TIME' then '改约时间'
         when 'SEAL' then '集包'
         when 'SEAL_NUMBER_CHANGE' then '集包件数变化'
         when 'SHIPMENT_WAREHOUSE_SCAN' then '发件出仓扫描'
         when 'SORTER_WEIGHT_IMAGE' then '分拣机复秤照片'
         when 'SORTING_SCAN' then '分拣扫描'
         when 'STAFF_INFO_UPDATE_WEIGHT' then '快递员修改重量'
         when 'STORE_KEEPER_UPDATE_WEIGHT' then '仓管员复秤'
         when 'STORE_SORTER_UPDATE_WEIGHT' then '分拣机复秤'
         when 'SYSTEM_AUTO_RETURN' then '系统自动退件'
         when 'TAKE_PHOTO' then '异常打单拍照'
         when 'THIRD_EXPRESS_ROUTE' then '第三方公司路由'
         when 'THIRD_PARTY_REASON_DETAIN' then '第三方原因滞留'
         when 'TICKET_WEIGHT_IMAGE' then '揽收称重照片'
         when 'TRANSFER_LOST_PARTS_TEAM' then '已转交丢失件团队'
         when 'TRANSFER_QAQC' then '转交QAQC处理'
         when 'UNSEAL' then '拆包'
         when 'UNSEAL_NO_PARCEL' then '上报包裹不在集包里'
         when 'UNSEAL_NOT_SCANNED' then '集包已拆包，本包裹未被扫描'
         when 'VEHICLE_ACCIDENT_REG' then '车辆车祸登记'
         when 'VEHICLE_ACCIDENT_REGISTRATION' then '车辆车祸登记'
         when 'VEHICLE_WET_DAMAGE_REG' then '车辆湿损登记'
         when 'VEHICLE_WET_DAMAGE_REGISTRATION' then '车辆湿损登记'
        end as 最后一条路由
    ,las2.remark 最后一条路由备注
    ,mark.remark 最后一条包裹备注
    ,las.staff_info_id 最后有效路由操作人
    ,las_ss.name 最后有效路由网点
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
    ,dst_ss.name 目的地网点
    ,del_ss.name 妥投网点
    ,pi.ticket_delivery_staff_info_id 妥投快递员ID
    ,if(pi.state = 5 ,convert_tz(pi.finished_at, '+00:00', '+07:00'), null) 包裹妥投时间
    ,if(st_distance_sphere(point(pi.`ticket_delivery_staff_lng`, pi.`ticket_delivery_staff_lat`), point(del_ss.`lng`, del_ss.`lat`)) <= 100, '是', '否') 是否在网点妥投
    ,if(pi.state = 5 and pho.routed_at < pi.finished_at , '是', '否') 妥投前是否给客户打电话
    ,pi.dst_phone  收件人电话
    ,num.num 创建工单次数
    ,1st.order_creat_at 第一次创建工单时间
    ,fir.created_at 第一次全组织发工单时间
    ,1st.wor_content 第一次回复内容
    ,concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/',1st.object_key) 第一次回复附件
    ,2nd.wor_content 第二次回复内容
    ,concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/',2nd.object_key) 第二次回复附件
    ,3rd.wor_content 第三次回复内容
    ,concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/',3rd.object_key) 第三次回复附件
    ,concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/',sa1.object_key) 签收凭证
    ,concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/',sa2.object_key) 其他凭证
from t1
left join fle_staging.parcel_info pi on pi.pno = t1.pno
left join fle_staging.sys_store dst_ss on dst_ss.id = pi.dst_store_id
left join fle_staging.sys_store del_ss on del_ss.id = pi.ticket_delivery_store_id
left join
    (
        select
            *
        from
            (
                select
                    pr.route_action
                    ,pr.pno
                    ,pr.staff_info_id
                    ,pr.routed_at
                    ,pr.store_id
                    ,pr.remark
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
                 from rot_pro.parcel_route pr
                 join t1 on t1.pno = pr.pno
                where  pr.route_action in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','seal.ARRIVAL_WAREHOUSE_SCAN','INVENTORY','SORTING_SCAN')
                    and pr.routed_at > curdate() - interval 30 day
            ) pr
        where pr.rn = 1
    ) las on las.pno = t1.pno
left join
    (
        select
            *
        from
            (
                select
                    pr.route_action
                    ,pr.pno
                    ,pr.staff_info_id
                    ,pr.routed_at
                    ,pr.store_id
                    ,pr.remark
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
                 from rot_pro.parcel_route pr
                 join
                     (
                        select t1.pno from t1 group by 1
                    )t1 on t1.pno = pr.pno
                where
                    pr.routed_at > curdate() - interval 30 day
            ) pr
        where pr.rn = 1
    ) las2 on las2.pno = t1.pno
left join fle_staging.sys_store las_ss on las_ss.id = las.store_id
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at) rn
        from rot_pro.parcel_route pr
        where pr.route_action = 'PHONE'
            and json_extract(pr.extra_value, '$.callDuration') > 7
            and pr.routed_at > curdate() - interval 30 day
    ) pho on pho.pno = t1.pno and pho.rn = 1
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rn
            ,pr.remark
        from rot_pro.parcel_route pr
        join
            (
                select t1.pno from t1 group by 1
            ) t on pr.pno = t.pno
        where pr.route_action = 'MANUAL_REMARK'
            and pr.routed_at > curdate() - interval 30 day
    ) mark on mark.pno = t1.pno and mark.rn = 1
left join
    (
        select
            t.loseparcel_task_id
            ,count(distinct t.id) num
        from t
        group by 1
    ) num on num.loseparcel_task_id = t1.id
left join
    (
        select
            *
        from t
        where
            t.r1 = 1
            and t.r2 = 1
    ) 1st on 1st.loseparcel_task_id = t1.id
left join
    (
        select
            *
        from t
        where
            t.r2 = 1
            and t.r1 = 2
    ) 2nd on 2nd.loseparcel_task_id = t1.id
left join
    (
        select
            *
        from t
        where
            t.r2 = 1
            and t.r1 = 3
    ) 3rd on 3rd.loseparcel_task_id = t1.id
left join
    (
        select
            wo.pnos
            ,wo.created_at
            ,row_number() over (partition by wo.pnos order by wo.created_at ) rn
        from bi_pro.work_order wo
        join t1 on t1.pno = wo.pnos
    ) fir on fir.pnos = t1.pno and fir.rn = 1
left join fle_staging.sys_attachment sa1 on sa1.oss_bucket_key = t1.pno and sa1.oss_bucket_type = 'DELIVERY_CONFIRM'
left join fle_staging.sys_attachment sa2 on sa2.oss_bucket_key = t1.pno and sa2.oss_bucket_type = 'DELIVERY_CONFIRM_OTHER';