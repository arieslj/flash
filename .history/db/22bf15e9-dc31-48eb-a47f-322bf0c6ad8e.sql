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
;-- -. . -..- - / . -. - .-. -.--
select
    ds.store_name 网点名称
    ,ds.region_name 大区
    ,ds.piece_name 片区
    ,count(if(pls.state = 1, pls.id, null)) 待处理数量
    ,count(if(pls.state = 3 , pls.id, null)) 超时自动处理量
    ,count(if(pls.state = 2 , pls.id, null)) 网点处理量
from bi_center.parcel_lose_task_sub_c pls
left join dwm.dim_th_sys_store_rd ds on pls.store_id = ds.store_id and ds.stat_date = date_sub(curdate(), interval 1 day )
where
    pls.created_at > '2023-01-09 00:00:00'
group by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
select
    ds.store_name 网点名称
    ,ds.region_name 大区
    ,ds.piece_name 片区
    ,count(if(pls.state = 1, pls.id, null)) 待处理数量
    ,count(distinct if(pls.state = 1, pls.pno, null)) 待处理包裹量
    ,count(if(pls.state = 3 , pls.id, null)) 超时自动处理量
    ,count(distinct if(pls.state = 3, pls.pno, null)) 超时自动处理包裹量
    ,count(if(pls.state = 2 , pls.id, null)) 网点处理量
    ,count(distinct if(pls.state = 2, pls.pno, null)) 网点处理包裹量
from bi_center.parcel_lose_task_sub_c pls
left join dwm.dim_th_sys_store_rd ds on pls.store_id = ds.store_id and ds.stat_date = date_sub(curdate(), interval 1 day )
where
    pls.created_at > '2023-01-09 00:00:00'
group by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
SELECT
distinct pls.pno '运单号เลขพัสดุ'
,ds.store_name '网点名称'
,pls.created_at '任务生成时间เวลาที่จัดการสำเร็จ'
,if(
    TIMESTAMPDIFF(hour,pls.created_at,now())<48,
concat(cast(TIMESTAMPDIFF(minute,now(),date_add(pls.created_at,interval 2 day))/60 as int),'h ',cast(round(TIMESTAMPDIFF(minute,now(),date_add(pls.created_at,interval 2 day))%60,0)as int),'min'),
concat('已超时',concat(cast(TIMESTAMPDIFF(minute,date_add(pls.created_at,interval 2 day),now())/60 as int),'h ',cast(round(TIMESTAMPDIFF(minute,date_add(pls.created_at,interval 2 day),now())%60,0)as int),'min'))) '任务处理倒计时เวลาที่สะสม'
,pls.pack_no '集包号เลขแบ็กกิ้ง'
,pls.arrival_time '入仓时间เวลาที่เข้าคลัง'
,pls.parcel_created_at '揽件时间เวลาที่รับ'
,pls.proof_id '出车凭证ใบรับรองปล่อยรถ'
,case pls.state
when 1 then '待处理'
when 2 then '网点处理'
when 3 then '超时自动处理'
when 4 then 'QAQC处理'
when 5 then '已更新路由(无需处理)'
end  '状态สถานะ'
,case pls.speed
when 1 then '是'
when 2 then '否'
end  'SPEED件มีพัสดุSpeed'
,pls.last_valid_action '最后有效路由สถานะสุดท้าย'
,pls.last_valid_at '最后操作时间เวลาสุดท้ายที่ดำเนินการ'
,ds2.store_name '最后有效路由所在网点สาขาสุดท้ายที่ดำเนินการ'
,ds.piece_name '片区District'
,ds.region_name '大区Area'
from bi_center.parcel_lose_task_sub_c pls
left join dwm.dim_th_sys_store_rd ds on pls.store_id = ds.store_id and ds.stat_date = date_sub(curdate(), interval 1 day )
left join dwm.dim_th_sys_store_rd ds2 on pls.last_valid_store_id = ds2.store_id and ds2.stat_date = date_sub(curdate(), interval 1 day )
where
    pls.created_at > '2023-01-09 00:00:00'
    and pls.state=1
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    dt.region_name 大区
    ,dt.piece_name 片区
    ,dt.store_name 网点
    ,am.merge_column 关联信息
    ,am.abnormal_time 异常日期
    ,am.punish_money 处罚金额
    ,CASE am.`punish_category`
        When 1 then '虚假问题件/虚假留仓件'
        When 2 then '5天以内未妥投，且超24小时未更新'
        When 3 then '5天以上未妥投/未中转，且超24小时未更新'
        When 4 then '对问题件解决不及时'
        When 5 then '包裹配送时间超三天'
        When 6 then '未在客户要求的改约时间之前派送包裹'
        When 7 then '包裹丢失'
        When 8 then '包裹破损'
        When 9 then '其他'
        When 10 then '揽件时称量包裹不准确'
        When 11 then '出纳回款不及时'
        When 12 then '迟到罚款 每分钟10泰铢'
        When 13 then '揽收或中转包裹未及时发出'
        When 14 then '仓管对工单处理不及时'
        When 15 then '仓管未及时处理问题件包裹'
        When 16 then '客户投诉罚款 已废弃'
        When 17 then '故意不接公司电话 自定义'
        When 18 then '仓管未交接SPEED/优先包裹给快递员'
        When 19 then 'PRI或者speed包裹未妥投'
        When 20 then '虚假妥投'
        When 21 then '客户投诉'
        When 22 then '快递员公款超时未上缴'
        When 23 then 'miniCS工单处理不及时'
        When 24 then '客户投诉-虚假问题件/虚假留仓件'
        When 25 then '揽收禁运包裹'
        When 26 then '早退罚款'
        When 27 then '班车发车晚点'
        When 28 then '虚假回复工单'
        When 29 then '未妥投包裹没有标记'
        When 30 then '未妥投包裹没有入仓'
        When 31 then 'SPEED/PRI件派送中未及时联系客户'
        When 32 then '仓管未及时交接SPEED/PRI优先包裹'
        When 33 then '揽收不及时'
        When 34 then '网点应盘点包裹未清零'
        When 35 then '漏揽收'
        When 36 then '包裹外包装不合格'
        When 37 then '超大件'
        When 38 then '多面单'
        When 39 then '不称重包裹未入仓'
        When 40 then '上传虚假照片'
        When 41 then '网点到件漏扫描'
        When 42 then '虚假撤销'
        When 43 then '虚假揽件标记'
        When 44 then '外协员工日交接不满50件包裹'
        When 45 then '超大集包处罚'
        When 46 then '不集包'
        When 47 then '理赔处理不及时'
        When 48 then '面单粘贴不规范'
        When 49 then '未换单'
        When 50 then '集包标签不规范'
        When 51 then '未及时关闭揽件任务'
        When 52 then '虚假上报（虚假违规件上报）'
        When 53 then '虚假错分'
        When 54 then '物品类型错误（水果件）'
        When 55 then '虚假上报车辆里程'
        When 56 then '物品类型错误（文件）'
        When 57 then '旷工罚款'
        When 58 then '虚假取消揽件任务'
        When 59 then '72h未联系客户道歉'
        When 60 then '虚假标记拒收'
        When 61 then '外协投诉主管未及时道歉'
        When 62 then '外协投诉客户不接受道歉'
        When 63 then '揽派件照片不合格'
        When 64 then '揽件任务未及时分配'
        When 65 then '网点未及时上传回款凭证'
        When 66 then '网点上传虚假回款凭证'
    end as '处罚原因'
    ,case am.`punish_sub_category`
        when 1   then '超大件'
        when 2   then   '违禁品'
        when 3   then '寄件人电话号码是空号'
        when 4   then   '收件人电话号码是空号'
        when 5   then    '虛假上报车里程模糊'
        when 6   then    '虛假上报车里程'
        when 7   then '重量差（复秤-揽收）（0.5kg,2kg]'
        when 8   then    '重量差（复秤-揽收）（2kg,5kg]'
        when 9   then    '重量差（复秤-揽收）>5kg'
        when 10   then   '重量差（复秤-揽收）<-0.5kg'
        when 11   then   '重量差（复秤-揽收）（1kg,3kg]'
        when 12   then '重量差（复秤-揽收）（3kg,6kg]'
        when 13   then   '重量差（复秤-揽收）>6kg'
        when 14   then    '重量差（复秤-揽收）<-1kg'
        when 15   then   '尺寸差（复秤-揽收）(10cm,20cm]'
        when 16   then   '尺寸差（复秤-揽收）(20cm,30cm]'
        when 17   then    '尺寸差（复秤-揽收）>30cm'
        when 18   then   '尺寸差（复秤-揽收）<-10cm'
        when 22   then    '虛假上报车里程 虚假-图片与数字不符合'
        when 23   then    '虛假上报车里程 虚假-滥用油卡'
    end as '具体原因'
    ,case acc.`complaints_type`
        when 6 then '服务态度类投诉 1级'
        when 2 then '虚假揽件改约时间/取消揽件任务 2级'
        when 1 then '虚假妥投 3级'
        when 3 then '派件虚假留仓件/问题件 4级'
        when 7 then '操作规范类投诉 5级'
        when 5 then '其他 6级'
        when 4 then '普通客诉 已弃用，仅供展示历史'
    end as 投诉大类
    ,case acc.complaints_sub_type
        when 1 then '业务不熟练'
        when 2 then '虚假签收'
        when 3 then '以不礼貌的态度对待客户'
        when 4   then '揽/派件动作慢'
        when 5 then '未经客户同意投递他处'
        when 6   then '未经客户同意改约时间'
        when 7 then '不接客户电话'
        when 8   then '包裹丢失 没有数据'
        when 9 then '改约的时间和客户沟通的时间不一致'
        when 10   then '未提前电话联系客户'
        when 11   then '包裹破损 没有数据'
        when 12   then '未按照改约时间派件'
        when 13    then '未按订单带包装'
        when 14   then '不找零钱'
        when 15    then '客户通话记录内未看到员工电话'
        when 16    then '未经客户允许取消揽件任务'
        when 17   then '未给客户回执'
        when 18   then '拨打电话时间太短，客户来不及接电话'
        when 19   then '未经客户允许退件'
        when 20    then '没有上门'
        when 21    then '其他'
        when 22   then '未经客户同意改约揽件时间'
        when 23    then '改约的揽件时间和客户要求的时间不一致'
        when 24    then '没有按照改约时间揽件'
        when 25    then '揽件前未提前联系客户'
        when 26    then '答应客户揽件，但最终没有揽'
        when 27    then '很晚才打电话联系客户'
        when 28    then '货物多/体积大，因骑摩托而拒绝上门揽收'
        when 29    then '因为超过当日截单时间，要求客户取消'
        when 30    then '声称不是自己负责的区域，要求客户取消'
        when 31    then '拨打电话时间太短，客户来不及接电话'
        when 32    then '不接听客户回复的电话'
        when 33    then '答应客户今天上门，但最终没有揽收'
        when 34    then '没有上门揽件，也没有打电话联系客户'
        when 35    then '货物不属于超大件/违禁品'
        when 36    then '没有收到包裹，且快递员没有联系客户'
        when 37    then '快递员拒绝上门派送'
        when 38    then '快递员擅自将包裹放在门口或他处'
        when 39    then '快递员没有按约定的时间派送'
        when 40    then '代替客户签收包裹'
        when   41   then '快说话不礼貌/没有礼貌/不愿意服务'
        when 42    then '说话不礼貌/没有礼貌/不愿意服务'
        when   43    then '快递员抛包裹'
        when   44    then '报复/骚扰客户'
        when 45   then '快递员收错COD金额'
        when   46   then '虚假妥投'
        when   47    then '派件虚假留仓件/问题件'
        when 48   then '虚假揽件改约时间/取消揽件任务'
        when   49   then '抛客户包裹'
        when 50    then '录入客户信息不正确'
        when 51    then '送货前未电话联系'
        when 52    then '未在约定时间上门'
        when   53    then '上门前不电话联系'
        when   54    then '以不礼貌的态度对待客户'
        when   55    then '录入客户信息不正确'
        when   56    then '与客户发生肢体接触'
        when   57    then '辱骂客户'
        when   58    then '威胁客户'
        when   59    then '上门揽件慢'
        when   60    then '快递员拒绝上门揽件'
        when 61    then '未经客户同意标记收件人拒收'
        when 62    then '未按照系统地址送货导致收件人拒收'
        when 63 then '情况不属实，快递员虚假标记'
        when 64 then '情况不属实，快递员诱导客户改约时间'
        when 65 then '包裹长时间未派送'
        when 66 then '未经同意拒收包裹'
        when 67 then '已交费仍索要COD'
        when 68 then '投递时要求开箱'
        when 69 then '不当场扫描揽收'
        when 70 then '揽派件速度慢'
    end as '投诉原因'
    ,am.remark 备注
    ,am.staff_info_id 工号
    ,hsi.name 员工姓名
    ,hjt.job_name 员工职位
    ,case
        when coalesce(am.isappeal, aq.isappeal) = 1 then '未申诉'
        when coalesce(am.isappeal, aq.isappeal) = 2 then '申诉中'
        when coalesce(am.isappeal, aq.isappeal) = 3 then '保持原判'
        when coalesce(am.isappeal, aq.isappeal) = 4 then '已变更'
        when coalesce(am.isappeal, aq.isappeal) = 5 or am.isdel = 1 then '已删除'
    end 状态
    ,aq.abnormal_money 申诉后的金额
from bi_pro.abnormal_message am
left join bi_pro.abnormal_customer_complaint acc on acc.abnormal_message_id = am.id
left join dwm.dim_th_sys_store_rd dt on dt.store_id = am.store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = am.staff_info_id
left join bi_pro.hr_job_title hjt on hjt.id = hsi.job_title
left join bi_pro.abnormal_qaqc aq on aq.abnormal_message_id = am.id
where
    am.abnormal_object = 0
    and am.abnormal_time >= '2023-02-01'
    and am.abnormal_time < '2023-03-01';
;-- -. . -..- - / . -. - .-. -.--
select
    dt.region_name 大区
    ,dt.piece_name 片区
    ,dt.store_name 网点
    ,am.merge_column 关联信息
    ,am.abnormal_time 异常日期
    ,case
        when aq.abnormal_money is not null then aq.abnormal_money                -- 处罚金额这在申诉之后固化
        when am.isdel = 1 then 0.00
        else am.punish_money
    end 处罚金额
    ,CASE am.`punish_category`
        When 1 then '虚假问题件/虚假留仓件'
        When 2 then '5天以内未妥投，且超24小时未更新'
        When 3 then '5天以上未妥投/未中转，且超24小时未更新'
        When 4 then '对问题件解决不及时'
        When 5 then '包裹配送时间超三天'
        When 6 then '未在客户要求的改约时间之前派送包裹'
        When 7 then '包裹丢失'
        When 8 then '包裹破损'
        When 9 then '其他'
        When 10 then '揽件时称量包裹不准确'
        When 11 then '出纳回款不及时'
        When 12 then '迟到罚款 每分钟10泰铢'
        When 13 then '揽收或中转包裹未及时发出'
        When 14 then '仓管对工单处理不及时'
        When 15 then '仓管未及时处理问题件包裹'
        When 16 then '客户投诉罚款 已废弃'
        When 17 then '故意不接公司电话 自定义'
        When 18 then '仓管未交接SPEED/优先包裹给快递员'
        When 19 then 'PRI或者speed包裹未妥投'
        When 20 then '虚假妥投'
        When 21 then '客户投诉'
        When 22 then '快递员公款超时未上缴'
        When 23 then 'miniCS工单处理不及时'
        When 24 then '客户投诉-虚假问题件/虚假留仓件'
        When 25 then '揽收禁运包裹'
        When 26 then '早退罚款'
        When 27 then '班车发车晚点'
        When 28 then '虚假回复工单'
        When 29 then '未妥投包裹没有标记'
        When 30 then '未妥投包裹没有入仓'
        When 31 then 'SPEED/PRI件派送中未及时联系客户'
        When 32 then '仓管未及时交接SPEED/PRI优先包裹'
        When 33 then '揽收不及时'
        When 34 then '网点应盘点包裹未清零'
        When 35 then '漏揽收'
        When 36 then '包裹外包装不合格'
        When 37 then '超大件'
        When 38 then '多面单'
        When 39 then '不称重包裹未入仓'
        When 40 then '上传虚假照片'
        When 41 then '网点到件漏扫描'
        When 42 then '虚假撤销'
        When 43 then '虚假揽件标记'
        When 44 then '外协员工日交接不满50件包裹'
        When 45 then '超大集包处罚'
        When 46 then '不集包'
        When 47 then '理赔处理不及时'
        When 48 then '面单粘贴不规范'
        When 49 then '未换单'
        When 50 then '集包标签不规范'
        When 51 then '未及时关闭揽件任务'
        When 52 then '虚假上报（虚假违规件上报）'
        When 53 then '虚假错分'
        When 54 then '物品类型错误（水果件）'
        When 55 then '虚假上报车辆里程'
        When 56 then '物品类型错误（文件）'
        When 57 then '旷工罚款'
        When 58 then '虚假取消揽件任务'
        When 59 then '72h未联系客户道歉'
        When 60 then '虚假标记拒收'
        When 61 then '外协投诉主管未及时道歉'
        When 62 then '外协投诉客户不接受道歉'
        When 63 then '揽派件照片不合格'
        When 64 then '揽件任务未及时分配'
        When 65 then '网点未及时上传回款凭证'
        When 66 then '网点上传虚假回款凭证'
    end as '处罚原因'
    ,case am.`punish_sub_category`
        when 1   then '超大件'
        when 2   then   '违禁品'
        when 3   then '寄件人电话号码是空号'
        when 4   then   '收件人电话号码是空号'
        when 5   then    '虛假上报车里程模糊'
        when 6   then    '虛假上报车里程'
        when 7   then '重量差（复秤-揽收）（0.5kg,2kg]'
        when 8   then    '重量差（复秤-揽收）（2kg,5kg]'
        when 9   then    '重量差（复秤-揽收）>5kg'
        when 10   then   '重量差（复秤-揽收）<-0.5kg'
        when 11   then   '重量差（复秤-揽收）（1kg,3kg]'
        when 12   then '重量差（复秤-揽收）（3kg,6kg]'
        when 13   then   '重量差（复秤-揽收）>6kg'
        when 14   then    '重量差（复秤-揽收）<-1kg'
        when 15   then   '尺寸差（复秤-揽收）(10cm,20cm]'
        when 16   then   '尺寸差（复秤-揽收）(20cm,30cm]'
        when 17   then    '尺寸差（复秤-揽收）>30cm'
        when 18   then   '尺寸差（复秤-揽收）<-10cm'
        when 22   then    '虛假上报车里程 虚假-图片与数字不符合'
        when 23   then    '虛假上报车里程 虚假-滥用油卡'
    end as '具体原因'
    ,case acc.`complaints_type`
        when 6 then '服务态度类投诉 1级'
        when 2 then '虚假揽件改约时间/取消揽件任务 2级'
        when 1 then '虚假妥投 3级'
        when 3 then '派件虚假留仓件/问题件 4级'
        when 7 then '操作规范类投诉 5级'
        when 5 then '其他 6级'
        when 4 then '普通客诉 已弃用，仅供展示历史'
    end as 投诉大类
    ,case acc.complaints_sub_type
        when 1 then '业务不熟练'
        when 2 then '虚假签收'
        when 3 then '以不礼貌的态度对待客户'
        when 4   then '揽/派件动作慢'
        when 5 then '未经客户同意投递他处'
        when 6   then '未经客户同意改约时间'
        when 7 then '不接客户电话'
        when 8   then '包裹丢失 没有数据'
        when 9 then '改约的时间和客户沟通的时间不一致'
        when 10   then '未提前电话联系客户'
        when 11   then '包裹破损 没有数据'
        when 12   then '未按照改约时间派件'
        when 13    then '未按订单带包装'
        when 14   then '不找零钱'
        when 15    then '客户通话记录内未看到员工电话'
        when 16    then '未经客户允许取消揽件任务'
        when 17   then '未给客户回执'
        when 18   then '拨打电话时间太短，客户来不及接电话'
        when 19   then '未经客户允许退件'
        when 20    then '没有上门'
        when 21    then '其他'
        when 22   then '未经客户同意改约揽件时间'
        when 23    then '改约的揽件时间和客户要求的时间不一致'
        when 24    then '没有按照改约时间揽件'
        when 25    then '揽件前未提前联系客户'
        when 26    then '答应客户揽件，但最终没有揽'
        when 27    then '很晚才打电话联系客户'
        when 28    then '货物多/体积大，因骑摩托而拒绝上门揽收'
        when 29    then '因为超过当日截单时间，要求客户取消'
        when 30    then '声称不是自己负责的区域，要求客户取消'
        when 31    then '拨打电话时间太短，客户来不及接电话'
        when 32    then '不接听客户回复的电话'
        when 33    then '答应客户今天上门，但最终没有揽收'
        when 34    then '没有上门揽件，也没有打电话联系客户'
        when 35    then '货物不属于超大件/违禁品'
        when 36    then '没有收到包裹，且快递员没有联系客户'
        when 37    then '快递员拒绝上门派送'
        when 38    then '快递员擅自将包裹放在门口或他处'
        when 39    then '快递员没有按约定的时间派送'
        when 40    then '代替客户签收包裹'
        when   41   then '快说话不礼貌/没有礼貌/不愿意服务'
        when 42    then '说话不礼貌/没有礼貌/不愿意服务'
        when   43    then '快递员抛包裹'
        when   44    then '报复/骚扰客户'
        when 45   then '快递员收错COD金额'
        when   46   then '虚假妥投'
        when   47    then '派件虚假留仓件/问题件'
        when 48   then '虚假揽件改约时间/取消揽件任务'
        when   49   then '抛客户包裹'
        when 50    then '录入客户信息不正确'
        when 51    then '送货前未电话联系'
        when 52    then '未在约定时间上门'
        when   53    then '上门前不电话联系'
        when   54    then '以不礼貌的态度对待客户'
        when   55    then '录入客户信息不正确'
        when   56    then '与客户发生肢体接触'
        when   57    then '辱骂客户'
        when   58    then '威胁客户'
        when   59    then '上门揽件慢'
        when   60    then '快递员拒绝上门揽件'
        when 61    then '未经客户同意标记收件人拒收'
        when 62    then '未按照系统地址送货导致收件人拒收'
        when 63 then '情况不属实，快递员虚假标记'
        when 64 then '情况不属实，快递员诱导客户改约时间'
        when 65 then '包裹长时间未派送'
        when 66 then '未经同意拒收包裹'
        when 67 then '已交费仍索要COD'
        when 68 then '投递时要求开箱'
        when 69 then '不当场扫描揽收'
        when 70 then '揽派件速度慢'
    end as '投诉原因'
    ,am.edit_reason 备注
    ,am.staff_info_id 工号
    ,hsi.name 员工姓名
    ,hjt.job_name 员工职位
    ,case
        when coalesce(am.isappeal, aq.isappeal) = 1 then '未申诉'
        when coalesce(am.isappeal, aq.isappeal) = 2 then '申诉中'
        when coalesce(am.isappeal, aq.isappeal) = 3 then '保持原判'
        when coalesce(am.isappeal, aq.isappeal) = 4 then '已变更'
        when coalesce(am.isappeal, aq.isappeal) = 5 or am.isdel = 1 then '已删除'
    end 状态
    ,,case
        when am.isdel = 1 then 0.00
        when am.isappeal = 1 then '-'
        when am.isappeal = 2 then '-'
        when am.isdel = 0 then am.punish_money
    end 申诉后的金额
from bi_pro.abnormal_message am
left join bi_pro.abnormal_customer_complaint acc on acc.abnormal_message_id = am.id
left join dwm.dim_th_sys_store_rd dt on dt.store_id = am.store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = am.staff_info_id
left join bi_pro.hr_job_title hjt on hjt.id = hsi.job_title
left join bi_pro.abnormal_qaqc aq on aq.abnormal_message_id = am.id
where
    am.abnormal_object = 0
    and am.abnormal_time >= '2023-02-01'
    and am.abnormal_time < '2023-03-01';
;-- -. . -..- - / . -. - .-. -.--
select
    dt.region_name 大区
    ,dt.piece_name 片区
    ,dt.store_name 网点
    ,am.merge_column 关联信息
    ,am.abnormal_time 异常日期
    ,case
        when aq.abnormal_money is not null then aq.abnormal_money                -- 处罚金额这在申诉之后固化
        when am.isdel = 1 then 0.00
        else am.punish_money
    end 处罚金额
    ,CASE am.`punish_category`
        When 1 then '虚假问题件/虚假留仓件'
        When 2 then '5天以内未妥投，且超24小时未更新'
        When 3 then '5天以上未妥投/未中转，且超24小时未更新'
        When 4 then '对问题件解决不及时'
        When 5 then '包裹配送时间超三天'
        When 6 then '未在客户要求的改约时间之前派送包裹'
        When 7 then '包裹丢失'
        When 8 then '包裹破损'
        When 9 then '其他'
        When 10 then '揽件时称量包裹不准确'
        When 11 then '出纳回款不及时'
        When 12 then '迟到罚款 每分钟10泰铢'
        When 13 then '揽收或中转包裹未及时发出'
        When 14 then '仓管对工单处理不及时'
        When 15 then '仓管未及时处理问题件包裹'
        When 16 then '客户投诉罚款 已废弃'
        When 17 then '故意不接公司电话 自定义'
        When 18 then '仓管未交接SPEED/优先包裹给快递员'
        When 19 then 'PRI或者speed包裹未妥投'
        When 20 then '虚假妥投'
        When 21 then '客户投诉'
        When 22 then '快递员公款超时未上缴'
        When 23 then 'miniCS工单处理不及时'
        When 24 then '客户投诉-虚假问题件/虚假留仓件'
        When 25 then '揽收禁运包裹'
        When 26 then '早退罚款'
        When 27 then '班车发车晚点'
        When 28 then '虚假回复工单'
        When 29 then '未妥投包裹没有标记'
        When 30 then '未妥投包裹没有入仓'
        When 31 then 'SPEED/PRI件派送中未及时联系客户'
        When 32 then '仓管未及时交接SPEED/PRI优先包裹'
        When 33 then '揽收不及时'
        When 34 then '网点应盘点包裹未清零'
        When 35 then '漏揽收'
        When 36 then '包裹外包装不合格'
        When 37 then '超大件'
        When 38 then '多面单'
        When 39 then '不称重包裹未入仓'
        When 40 then '上传虚假照片'
        When 41 then '网点到件漏扫描'
        When 42 then '虚假撤销'
        When 43 then '虚假揽件标记'
        When 44 then '外协员工日交接不满50件包裹'
        When 45 then '超大集包处罚'
        When 46 then '不集包'
        When 47 then '理赔处理不及时'
        When 48 then '面单粘贴不规范'
        When 49 then '未换单'
        When 50 then '集包标签不规范'
        When 51 then '未及时关闭揽件任务'
        When 52 then '虚假上报（虚假违规件上报）'
        When 53 then '虚假错分'
        When 54 then '物品类型错误（水果件）'
        When 55 then '虚假上报车辆里程'
        When 56 then '物品类型错误（文件）'
        When 57 then '旷工罚款'
        When 58 then '虚假取消揽件任务'
        When 59 then '72h未联系客户道歉'
        When 60 then '虚假标记拒收'
        When 61 then '外协投诉主管未及时道歉'
        When 62 then '外协投诉客户不接受道歉'
        When 63 then '揽派件照片不合格'
        When 64 then '揽件任务未及时分配'
        When 65 then '网点未及时上传回款凭证'
        When 66 then '网点上传虚假回款凭证'
    end as '处罚原因'
    ,case am.`punish_sub_category`
        when 1   then '超大件'
        when 2   then   '违禁品'
        when 3   then '寄件人电话号码是空号'
        when 4   then   '收件人电话号码是空号'
        when 5   then    '虛假上报车里程模糊'
        when 6   then    '虛假上报车里程'
        when 7   then '重量差（复秤-揽收）（0.5kg,2kg]'
        when 8   then    '重量差（复秤-揽收）（2kg,5kg]'
        when 9   then    '重量差（复秤-揽收）>5kg'
        when 10   then   '重量差（复秤-揽收）<-0.5kg'
        when 11   then   '重量差（复秤-揽收）（1kg,3kg]'
        when 12   then '重量差（复秤-揽收）（3kg,6kg]'
        when 13   then   '重量差（复秤-揽收）>6kg'
        when 14   then    '重量差（复秤-揽收）<-1kg'
        when 15   then   '尺寸差（复秤-揽收）(10cm,20cm]'
        when 16   then   '尺寸差（复秤-揽收）(20cm,30cm]'
        when 17   then    '尺寸差（复秤-揽收）>30cm'
        when 18   then   '尺寸差（复秤-揽收）<-10cm'
        when 22   then    '虛假上报车里程 虚假-图片与数字不符合'
        when 23   then    '虛假上报车里程 虚假-滥用油卡'
    end as '具体原因'
    ,case acc.`complaints_type`
        when 6 then '服务态度类投诉 1级'
        when 2 then '虚假揽件改约时间/取消揽件任务 2级'
        when 1 then '虚假妥投 3级'
        when 3 then '派件虚假留仓件/问题件 4级'
        when 7 then '操作规范类投诉 5级'
        when 5 then '其他 6级'
        when 4 then '普通客诉 已弃用，仅供展示历史'
    end as 投诉大类
    ,case acc.complaints_sub_type
        when 1 then '业务不熟练'
        when 2 then '虚假签收'
        when 3 then '以不礼貌的态度对待客户'
        when 4   then '揽/派件动作慢'
        when 5 then '未经客户同意投递他处'
        when 6   then '未经客户同意改约时间'
        when 7 then '不接客户电话'
        when 8   then '包裹丢失 没有数据'
        when 9 then '改约的时间和客户沟通的时间不一致'
        when 10   then '未提前电话联系客户'
        when 11   then '包裹破损 没有数据'
        when 12   then '未按照改约时间派件'
        when 13    then '未按订单带包装'
        when 14   then '不找零钱'
        when 15    then '客户通话记录内未看到员工电话'
        when 16    then '未经客户允许取消揽件任务'
        when 17   then '未给客户回执'
        when 18   then '拨打电话时间太短，客户来不及接电话'
        when 19   then '未经客户允许退件'
        when 20    then '没有上门'
        when 21    then '其他'
        when 22   then '未经客户同意改约揽件时间'
        when 23    then '改约的揽件时间和客户要求的时间不一致'
        when 24    then '没有按照改约时间揽件'
        when 25    then '揽件前未提前联系客户'
        when 26    then '答应客户揽件，但最终没有揽'
        when 27    then '很晚才打电话联系客户'
        when 28    then '货物多/体积大，因骑摩托而拒绝上门揽收'
        when 29    then '因为超过当日截单时间，要求客户取消'
        when 30    then '声称不是自己负责的区域，要求客户取消'
        when 31    then '拨打电话时间太短，客户来不及接电话'
        when 32    then '不接听客户回复的电话'
        when 33    then '答应客户今天上门，但最终没有揽收'
        when 34    then '没有上门揽件，也没有打电话联系客户'
        when 35    then '货物不属于超大件/违禁品'
        when 36    then '没有收到包裹，且快递员没有联系客户'
        when 37    then '快递员拒绝上门派送'
        when 38    then '快递员擅自将包裹放在门口或他处'
        when 39    then '快递员没有按约定的时间派送'
        when 40    then '代替客户签收包裹'
        when   41   then '快说话不礼貌/没有礼貌/不愿意服务'
        when 42    then '说话不礼貌/没有礼貌/不愿意服务'
        when   43    then '快递员抛包裹'
        when   44    then '报复/骚扰客户'
        when 45   then '快递员收错COD金额'
        when   46   then '虚假妥投'
        when   47    then '派件虚假留仓件/问题件'
        when 48   then '虚假揽件改约时间/取消揽件任务'
        when   49   then '抛客户包裹'
        when 50    then '录入客户信息不正确'
        when 51    then '送货前未电话联系'
        when 52    then '未在约定时间上门'
        when   53    then '上门前不电话联系'
        when   54    then '以不礼貌的态度对待客户'
        when   55    then '录入客户信息不正确'
        when   56    then '与客户发生肢体接触'
        when   57    then '辱骂客户'
        when   58    then '威胁客户'
        when   59    then '上门揽件慢'
        when   60    then '快递员拒绝上门揽件'
        when 61    then '未经客户同意标记收件人拒收'
        when 62    then '未按照系统地址送货导致收件人拒收'
        when 63 then '情况不属实，快递员虚假标记'
        when 64 then '情况不属实，快递员诱导客户改约时间'
        when 65 then '包裹长时间未派送'
        when 66 then '未经同意拒收包裹'
        when 67 then '已交费仍索要COD'
        when 68 then '投递时要求开箱'
        when 69 then '不当场扫描揽收'
        when 70 then '揽派件速度慢'
    end as '投诉原因'
    ,am.edit_reason 备注
    ,am.staff_info_id 工号
    ,hsi.name 员工姓名
    ,hjt.job_name 员工职位
    ,case
        when coalesce(am.isappeal, aq.isappeal) = 1 then '未申诉'
        when coalesce(am.isappeal, aq.isappeal) = 2 then '申诉中'
        when coalesce(am.isappeal, aq.isappeal) = 3 then '保持原判'
        when coalesce(am.isappeal, aq.isappeal) = 4 then '已变更'
        when coalesce(am.isappeal, aq.isappeal) = 5 or am.isdel = 1 then '已删除'
    end 状态
    ,case
        when am.isdel = 1 then 0.00
        when am.isappeal = 1 then '-'
        when am.isappeal = 2 then '-'
        when am.isdel = 0 then am.punish_money
    end 申诉后的金额
from bi_pro.abnormal_message am
left join bi_pro.abnormal_customer_complaint acc on acc.abnormal_message_id = am.id
left join dwm.dim_th_sys_store_rd dt on dt.store_id = am.store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = am.staff_info_id
left join bi_pro.hr_job_title hjt on hjt.id = hsi.job_title
left join bi_pro.abnormal_qaqc aq on aq.abnormal_message_id = am.id
where
    am.abnormal_object = 0
    and am.abnormal_time >= '2023-02-01'
    and am.abnormal_time < '2023-03-01';
;-- -. . -..- - / . -. - .-. -.--
select
    dt.region_name 大区
    ,dt.piece_name 片区
    ,dt.store_name 网点
    ,am.merge_column 关联信息
    ,am.abnormal_time 异常日期
    ,case
        when aq.abnormal_money is not null then aq.abnormal_money                -- 处罚金额这在申诉之后固化
        when am.isdel = 1 then 0.00
        else am.punish_money
    end 处罚金额
    ,CASE am.`punish_category`
        When 1 then '虚假问题件/虚假留仓件'
        When 2 then '5天以内未妥投，且超24小时未更新'
        When 3 then '5天以上未妥投/未中转，且超24小时未更新'
        When 4 then '对问题件解决不及时'
        When 5 then '包裹配送时间超三天'
        When 6 then '未在客户要求的改约时间之前派送包裹'
        When 7 then '包裹丢失'
        When 8 then '包裹破损'
        When 9 then '其他'
        When 10 then '揽件时称量包裹不准确'
        When 11 then '出纳回款不及时'
        When 12 then '迟到罚款 每分钟10泰铢'
        When 13 then '揽收或中转包裹未及时发出'
        When 14 then '仓管对工单处理不及时'
        When 15 then '仓管未及时处理问题件包裹'
        When 16 then '客户投诉罚款 已废弃'
        When 17 then '故意不接公司电话 自定义'
        When 18 then '仓管未交接SPEED/优先包裹给快递员'
        When 19 then 'PRI或者speed包裹未妥投'
        When 20 then '虚假妥投'
        When 21 then '客户投诉'
        When 22 then '快递员公款超时未上缴'
        When 23 then 'miniCS工单处理不及时'
        When 24 then '客户投诉-虚假问题件/虚假留仓件'
        When 25 then '揽收禁运包裹'
        When 26 then '早退罚款'
        When 27 then '班车发车晚点'
        When 28 then '虚假回复工单'
        When 29 then '未妥投包裹没有标记'
        When 30 then '未妥投包裹没有入仓'
        When 31 then 'SPEED/PRI件派送中未及时联系客户'
        When 32 then '仓管未及时交接SPEED/PRI优先包裹'
        When 33 then '揽收不及时'
        When 34 then '网点应盘点包裹未清零'
        When 35 then '漏揽收'
        When 36 then '包裹外包装不合格'
        When 37 then '超大件'
        When 38 then '多面单'
        When 39 then '不称重包裹未入仓'
        When 40 then '上传虚假照片'
        When 41 then '网点到件漏扫描'
        When 42 then '虚假撤销'
        When 43 then '虚假揽件标记'
        When 44 then '外协员工日交接不满50件包裹'
        When 45 then '超大集包处罚'
        When 46 then '不集包'
        When 47 then '理赔处理不及时'
        When 48 then '面单粘贴不规范'
        When 49 then '未换单'
        When 50 then '集包标签不规范'
        When 51 then '未及时关闭揽件任务'
        When 52 then '虚假上报（虚假违规件上报）'
        When 53 then '虚假错分'
        When 54 then '物品类型错误（水果件）'
        When 55 then '虚假上报车辆里程'
        When 56 then '物品类型错误（文件）'
        When 57 then '旷工罚款'
        When 58 then '虚假取消揽件任务'
        When 59 then '72h未联系客户道歉'
        When 60 then '虚假标记拒收'
        When 61 then '外协投诉主管未及时道歉'
        When 62 then '外协投诉客户不接受道歉'
        When 63 then '揽派件照片不合格'
        When 64 then '揽件任务未及时分配'
        When 65 then '网点未及时上传回款凭证'
        When 66 then '网点上传虚假回款凭证'
    end as '处罚原因'
    ,case am.`punish_sub_category`
        when 1   then '超大件'
        when 2   then   '违禁品'
        when 3   then '寄件人电话号码是空号'
        when 4   then   '收件人电话号码是空号'
        when 5   then    '虛假上报车里程模糊'
        when 6   then    '虛假上报车里程'
        when 7   then '重量差（复秤-揽收）（0.5kg,2kg]'
        when 8   then    '重量差（复秤-揽收）（2kg,5kg]'
        when 9   then    '重量差（复秤-揽收）>5kg'
        when 10   then   '重量差（复秤-揽收）<-0.5kg'
        when 11   then   '重量差（复秤-揽收）（1kg,3kg]'
        when 12   then '重量差（复秤-揽收）（3kg,6kg]'
        when 13   then   '重量差（复秤-揽收）>6kg'
        when 14   then    '重量差（复秤-揽收）<-1kg'
        when 15   then   '尺寸差（复秤-揽收）(10cm,20cm]'
        when 16   then   '尺寸差（复秤-揽收）(20cm,30cm]'
        when 17   then    '尺寸差（复秤-揽收）>30cm'
        when 18   then   '尺寸差（复秤-揽收）<-10cm'
        when 22   then    '虛假上报车里程 虚假-图片与数字不符合'
        when 23   then    '虛假上报车里程 虚假-滥用油卡'
    end as '具体原因'
    ,case acc.`complaints_type`
        when 6 then '服务态度类投诉 1级'
        when 2 then '虚假揽件改约时间/取消揽件任务 2级'
        when 1 then '虚假妥投 3级'
        when 3 then '派件虚假留仓件/问题件 4级'
        when 7 then '操作规范类投诉 5级'
        when 5 then '其他 6级'
        when 4 then '普通客诉 已弃用，仅供展示历史'
    end as 投诉大类
    ,case acc.complaints_sub_type
        when 1 then '业务不熟练'
        when 2 then '虚假签收'
        when 3 then '以不礼貌的态度对待客户'
        when 4   then '揽/派件动作慢'
        when 5 then '未经客户同意投递他处'
        when 6   then '未经客户同意改约时间'
        when 7 then '不接客户电话'
        when 8   then '包裹丢失 没有数据'
        when 9 then '改约的时间和客户沟通的时间不一致'
        when 10   then '未提前电话联系客户'
        when 11   then '包裹破损 没有数据'
        when 12   then '未按照改约时间派件'
        when 13    then '未按订单带包装'
        when 14   then '不找零钱'
        when 15    then '客户通话记录内未看到员工电话'
        when 16    then '未经客户允许取消揽件任务'
        when 17   then '未给客户回执'
        when 18   then '拨打电话时间太短，客户来不及接电话'
        when 19   then '未经客户允许退件'
        when 20    then '没有上门'
        when 21    then '其他'
        when 22   then '未经客户同意改约揽件时间'
        when 23    then '改约的揽件时间和客户要求的时间不一致'
        when 24    then '没有按照改约时间揽件'
        when 25    then '揽件前未提前联系客户'
        when 26    then '答应客户揽件，但最终没有揽'
        when 27    then '很晚才打电话联系客户'
        when 28    then '货物多/体积大，因骑摩托而拒绝上门揽收'
        when 29    then '因为超过当日截单时间，要求客户取消'
        when 30    then '声称不是自己负责的区域，要求客户取消'
        when 31    then '拨打电话时间太短，客户来不及接电话'
        when 32    then '不接听客户回复的电话'
        when 33    then '答应客户今天上门，但最终没有揽收'
        when 34    then '没有上门揽件，也没有打电话联系客户'
        when 35    then '货物不属于超大件/违禁品'
        when 36    then '没有收到包裹，且快递员没有联系客户'
        when 37    then '快递员拒绝上门派送'
        when 38    then '快递员擅自将包裹放在门口或他处'
        when 39    then '快递员没有按约定的时间派送'
        when 40    then '代替客户签收包裹'
        when   41   then '快说话不礼貌/没有礼貌/不愿意服务'
        when 42    then '说话不礼貌/没有礼貌/不愿意服务'
        when   43    then '快递员抛包裹'
        when   44    then '报复/骚扰客户'
        when 45   then '快递员收错COD金额'
        when   46   then '虚假妥投'
        when   47    then '派件虚假留仓件/问题件'
        when 48   then '虚假揽件改约时间/取消揽件任务'
        when   49   then '抛客户包裹'
        when 50    then '录入客户信息不正确'
        when 51    then '送货前未电话联系'
        when 52    then '未在约定时间上门'
        when   53    then '上门前不电话联系'
        when   54    then '以不礼貌的态度对待客户'
        when   55    then '录入客户信息不正确'
        when   56    then '与客户发生肢体接触'
        when   57    then '辱骂客户'
        when   58    then '威胁客户'
        when   59    then '上门揽件慢'
        when   60    then '快递员拒绝上门揽件'
        when 61    then '未经客户同意标记收件人拒收'
        when 62    then '未按照系统地址送货导致收件人拒收'
        when 63 then '情况不属实，快递员虚假标记'
        when 64 then '情况不属实，快递员诱导客户改约时间'
        when 65 then '包裹长时间未派送'
        when 66 then '未经同意拒收包裹'
        when 67 then '已交费仍索要COD'
        when 68 then '投递时要求开箱'
        when 69 then '不当场扫描揽收'
        when 70 then '揽派件速度慢'
    end as '投诉原因'
    ,am.edit_reason 备注
    ,am.staff_info_id 工号
    ,hsi.name 员工姓名
    ,hjt.job_name 员工职位
    ,case
        when coalesce(am.isappeal, aq.isappeal) = 1 then '未申诉'
        when coalesce(am.isappeal, aq.isappeal) = 2 then '申诉中'
        when coalesce(am.isappeal, aq.isappeal) = 3 then '保持原判'
        when coalesce(am.isappeal, aq.isappeal) = 4 then '已变更'
        when coalesce(am.isappeal, aq.isappeal) = 5 or am.isdel = 1 then '已删除'
    end 状态
    ,case
        when am.isdel = 1 then 0.00
        when am.isappeal = 1 then '-'
        when am.isappeal = 2 then '-'
        when am.isdel = 0 then am.punish_money
    end 申诉后的金额
from bi_pro.abnormal_message am
left join bi_pro.abnormal_customer_complaint acc on acc.abnormal_message_id = am.id
left join dwm.dim_th_sys_store_rd dt on dt.store_id = am.store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = am.staff_info_id
left join bi_pro.hr_job_title hjt on hjt.id = hsi.job_title
left join bi_pro.abnormal_qaqc aq on aq.abnormal_message_id = am.id
where
    am.abnormal_object = 0
    and am.abnormal_time >= '2023-02-01'
    and am.abnormal_time < '2023-03-01'
    and am.state = 1
    and (am.isdel = 0 or (am.isdel = 1 and am.isappeal != 1));
;-- -. . -..- - / . -. - .-. -.--
select
    dt.region_name 大区
    ,dt.piece_name 片区
    ,dt.store_name 网点
    ,am.merge_column 关联信息
    ,am.abnormal_time 异常日期
    ,case
        when aq.abnormal_money is not null then aq.abnormal_money                -- 处罚金额这在申诉之后固化
        when am.isdel = 1 then 0.00
        else am.punish_money
    end 处罚金额
    ,CASE am.`punish_category`
        When 1 then '虚假问题件/虚假留仓件'
        When 2 then '5天以内未妥投，且超24小时未更新'
        When 3 then '5天以上未妥投/未中转，且超24小时未更新'
        When 4 then '对问题件解决不及时'
        When 5 then '包裹配送时间超三天'
        When 6 then '未在客户要求的改约时间之前派送包裹'
        When 7 then '包裹丢失'
        When 8 then '包裹破损'
        When 9 then '其他'
        When 10 then '揽件时称量包裹不准确'
        When 11 then '出纳回款不及时'
        When 12 then '迟到罚款 每分钟10泰铢'
        When 13 then '揽收或中转包裹未及时发出'
        When 14 then '仓管对工单处理不及时'
        When 15 then '仓管未及时处理问题件包裹'
        When 16 then '客户投诉罚款 已废弃'
        When 17 then '故意不接公司电话 自定义'
        When 18 then '仓管未交接SPEED/优先包裹给快递员'
        When 19 then 'PRI或者speed包裹未妥投'
        When 20 then '虚假妥投'
        When 21 then '客户投诉'
        When 22 then '快递员公款超时未上缴'
        When 23 then 'miniCS工单处理不及时'
        When 24 then '客户投诉-虚假问题件/虚假留仓件'
        When 25 then '揽收禁运包裹'
        When 26 then '早退罚款'
        When 27 then '班车发车晚点'
        When 28 then '虚假回复工单'
        When 29 then '未妥投包裹没有标记'
        When 30 then '未妥投包裹没有入仓'
        When 31 then 'SPEED/PRI件派送中未及时联系客户'
        When 32 then '仓管未及时交接SPEED/PRI优先包裹'
        When 33 then '揽收不及时'
        When 34 then '网点应盘点包裹未清零'
        When 35 then '漏揽收'
        When 36 then '包裹外包装不合格'
        When 37 then '超大件'
        When 38 then '多面单'
        When 39 then '不称重包裹未入仓'
        When 40 then '上传虚假照片'
        When 41 then '网点到件漏扫描'
        When 42 then '虚假撤销'
        When 43 then '虚假揽件标记'
        When 44 then '外协员工日交接不满50件包裹'
        When 45 then '超大集包处罚'
        When 46 then '不集包'
        When 47 then '理赔处理不及时'
        When 48 then '面单粘贴不规范'
        When 49 then '未换单'
        When 50 then '集包标签不规范'
        When 51 then '未及时关闭揽件任务'
        When 52 then '虚假上报（虚假违规件上报）'
        When 53 then '虚假错分'
        When 54 then '物品类型错误（水果件）'
        When 55 then '虚假上报车辆里程'
        When 56 then '物品类型错误（文件）'
        When 57 then '旷工罚款'
        When 58 then '虚假取消揽件任务'
        When 59 then '72h未联系客户道歉'
        When 60 then '虚假标记拒收'
        When 61 then '外协投诉主管未及时道歉'
        When 62 then '外协投诉客户不接受道歉'
        When 63 then '揽派件照片不合格'
        When 64 then '揽件任务未及时分配'
        When 65 then '网点未及时上传回款凭证'
        When 66 then '网点上传虚假回款凭证'
    end as '处罚原因'
    ,case am.`punish_sub_category`
        when 1   then '超大件'
        when 2   then   '违禁品'
        when 3   then '寄件人电话号码是空号'
        when 4   then   '收件人电话号码是空号'
        when 5   then    '虛假上报车里程模糊'
        when 6   then    '虛假上报车里程'
        when 7   then '重量差（复秤-揽收）（0.5kg,2kg]'
        when 8   then    '重量差（复秤-揽收）（2kg,5kg]'
        when 9   then    '重量差（复秤-揽收）>5kg'
        when 10   then   '重量差（复秤-揽收）<-0.5kg'
        when 11   then   '重量差（复秤-揽收）（1kg,3kg]'
        when 12   then '重量差（复秤-揽收）（3kg,6kg]'
        when 13   then   '重量差（复秤-揽收）>6kg'
        when 14   then    '重量差（复秤-揽收）<-1kg'
        when 15   then   '尺寸差（复秤-揽收）(10cm,20cm]'
        when 16   then   '尺寸差（复秤-揽收）(20cm,30cm]'
        when 17   then    '尺寸差（复秤-揽收）>30cm'
        when 18   then   '尺寸差（复秤-揽收）<-10cm'
        when 22   then    '虛假上报车里程 虚假-图片与数字不符合'
        when 23   then    '虛假上报车里程 虚假-滥用油卡'
    end as '具体原因'
    ,case acc.`complaints_type`
        when 6 then '服务态度类投诉 1级'
        when 2 then '虚假揽件改约时间/取消揽件任务 2级'
        when 1 then '虚假妥投 3级'
        when 3 then '派件虚假留仓件/问题件 4级'
        when 7 then '操作规范类投诉 5级'
        when 5 then '其他 6级'
        when 4 then '普通客诉 已弃用，仅供展示历史'
    end as 投诉大类
    ,case acc.complaints_sub_type
        when 1 then '业务不熟练'
        when 2 then '虚假签收'
        when 3 then '以不礼貌的态度对待客户'
        when 4   then '揽/派件动作慢'
        when 5 then '未经客户同意投递他处'
        when 6   then '未经客户同意改约时间'
        when 7 then '不接客户电话'
        when 8   then '包裹丢失 没有数据'
        when 9 then '改约的时间和客户沟通的时间不一致'
        when 10   then '未提前电话联系客户'
        when 11   then '包裹破损 没有数据'
        when 12   then '未按照改约时间派件'
        when 13    then '未按订单带包装'
        when 14   then '不找零钱'
        when 15    then '客户通话记录内未看到员工电话'
        when 16    then '未经客户允许取消揽件任务'
        when 17   then '未给客户回执'
        when 18   then '拨打电话时间太短，客户来不及接电话'
        when 19   then '未经客户允许退件'
        when 20    then '没有上门'
        when 21    then '其他'
        when 22   then '未经客户同意改约揽件时间'
        when 23    then '改约的揽件时间和客户要求的时间不一致'
        when 24    then '没有按照改约时间揽件'
        when 25    then '揽件前未提前联系客户'
        when 26    then '答应客户揽件，但最终没有揽'
        when 27    then '很晚才打电话联系客户'
        when 28    then '货物多/体积大，因骑摩托而拒绝上门揽收'
        when 29    then '因为超过当日截单时间，要求客户取消'
        when 30    then '声称不是自己负责的区域，要求客户取消'
        when 31    then '拨打电话时间太短，客户来不及接电话'
        when 32    then '不接听客户回复的电话'
        when 33    then '答应客户今天上门，但最终没有揽收'
        when 34    then '没有上门揽件，也没有打电话联系客户'
        when 35    then '货物不属于超大件/违禁品'
        when 36    then '没有收到包裹，且快递员没有联系客户'
        when 37    then '快递员拒绝上门派送'
        when 38    then '快递员擅自将包裹放在门口或他处'
        when 39    then '快递员没有按约定的时间派送'
        when 40    then '代替客户签收包裹'
        when   41   then '快说话不礼貌/没有礼貌/不愿意服务'
        when 42    then '说话不礼貌/没有礼貌/不愿意服务'
        when   43    then '快递员抛包裹'
        when   44    then '报复/骚扰客户'
        when 45   then '快递员收错COD金额'
        when   46   then '虚假妥投'
        when   47    then '派件虚假留仓件/问题件'
        when 48   then '虚假揽件改约时间/取消揽件任务'
        when   49   then '抛客户包裹'
        when 50    then '录入客户信息不正确'
        when 51    then '送货前未电话联系'
        when 52    then '未在约定时间上门'
        when   53    then '上门前不电话联系'
        when   54    then '以不礼貌的态度对待客户'
        when   55    then '录入客户信息不正确'
        when   56    then '与客户发生肢体接触'
        when   57    then '辱骂客户'
        when   58    then '威胁客户'
        when   59    then '上门揽件慢'
        when   60    then '快递员拒绝上门揽件'
        when 61    then '未经客户同意标记收件人拒收'
        when 62    then '未按照系统地址送货导致收件人拒收'
        when 63 then '情况不属实，快递员虚假标记'
        when 64 then '情况不属实，快递员诱导客户改约时间'
        when 65 then '包裹长时间未派送'
        when 66 then '未经同意拒收包裹'
        when 67 then '已交费仍索要COD'
        when 68 then '投递时要求开箱'
        when 69 then '不当场扫描揽收'
        when 70 then '揽派件速度慢'
    end as '投诉原因'
    ,am.edit_reason 备注
    ,am.staff_info_id 工号
    ,hsi.name 员工姓名
    ,hjt.job_name 员工职位
    ,case
        when coalesce(am.isappeal, aq.isappeal) = 1 then '未申诉'
        when coalesce(am.isappeal, aq.isappeal) = 2 then '申诉中'
        when coalesce(am.isappeal, aq.isappeal) = 3 then '保持原判'
        when coalesce(am.isappeal, aq.isappeal) = 4 then '已变更'
        when coalesce(am.isappeal, aq.isappeal) = 5 or am.isdel = 1 then '已删除'
    end 状态
    ,case
        when am.isdel = 1 then 0.00
        when am.isappeal = 1 then '-'
        when am.isappeal = 2 then '-'
        when am.isdel = 0 then am.punish_money
    end 申诉后的金额
from bi_pro.abnormal_message am
left join bi_pro.abnormal_customer_complaint acc on acc.abnormal_message_id = am.id
left join dwm.dim_th_sys_store_rd dt on dt.store_id = am.store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = am.staff_info_id
left join bi_pro.hr_job_title hjt on hjt.id = hsi.job_title
left join bi_pro.abnormal_qaqc aq on aq.abnormal_message_id = am.id
where
    am.abnormal_object = 0
    and am.abnormal_time >= '2023-02-01'
    and am.abnormal_time < '2023-03-01'
    and am.state = 1
    and (am.isdel = 0 or (am.isdel = 1 and am.isappeal != 1))
    and dt.region_name in ('Area14','Area3','Area6','Bulky Area 1','Bulky Area 2','Bulky Area 3','Bulky Area 4','Bulky Area 5','Bulky Area 6','Bulky Area 7','Bulky Area 8','Bulky Area 9','CDC Area 1','CDC Area 2');
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
    ,concat('https://fle-asset-internal.oss-ap-southeast-1.aliyuncs.com/',1st.object_key) 第一次回复附件
    ,2nd.wor_content 第二次回复内容
    ,concat('https://fle-asset-internal.oss-ap-southeast-1.aliyuncs.com/',2nd.object_key) 第二次回复附件
    ,3rd.wor_content 第三次回复内容
    ,concat('https://fle-asset-internal.oss-ap-southeast-1.aliyuncs.com/',3rd.object_key) 第三次回复附件
    ,concat('https://fle-asset-internal.oss-ap-southeast-1.aliyuncs.com/',sa1.object_key) 签收凭证
    ,concat('https://fle-asset-internal.oss-ap-southeast-1.aliyuncs.com/',sa2.object_key) 其他凭证
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
    join t1 on t1.id = wo.loseparcel_task_id
    left join bi_pro.work_order_reply wor on wor.order_id = wo.id
    left join bi_pro.work_order_img woi on woi.origin_id = wor.id
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
    ,concat('https://fle-asset-internal.oss-ap-southeast-1.aliyuncs.com/',1st.object_key) 第一次回复附件
    ,2nd.wor_content 第二次回复内容
    ,concat('https://fle-asset-internal.oss-ap-southeast-1.aliyuncs.com/',2nd.object_key) 第二次回复附件
    ,3rd.wor_content 第三次回复内容
    ,concat('https://fle-asset-internal.oss-ap-southeast-1.aliyuncs.com/',3rd.object_key) 第三次回复附件
    ,concat('https://fle-asset-internal.oss-ap-southeast-1.aliyuncs.com/',sa1.object_key) 签收凭证
    ,concat('https://fle-asset-internal.oss-ap-southeast-1.aliyuncs.com/',sa2.object_key) 其他凭证
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
;-- -. . -..- - / . -. - .-. -.--
select
        plt.pno
        ,plt.id
        ,plt.client_id
        ,plt.created_at
    from bi_pro.parcel_lose_task plt
    where
        plt.state < 5
        and plt.source = 2;
;-- -. . -..- - / . -. - .-. -.--
with rep as
(
    select
        wo.order_no
        ,wo.pnos
        ,wor.created_at
        ,row_number() over (partition by wo.order_no order by wor.created_at ) rn
    from bi_pro.work_order wo
    left join bi_pro.work_order_reply wor on wo.id = wor.order_id
    where
        wo.created_store_id = 3
        and wo.created_at >= '2023-03-14'
)
, pho as
(
    select
        pr.pno
        ,pr.routed_at
        ,row_number() over (partition by pr.pno order by pr.routed_at) rk
        ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk2
    from rot_pro.parcel_route pr
    join
        (
            select rep.pnos from rep group by 1
        ) r on pr.pno = r.pnos
    where
        pr.route_action = 'PHONE'
)
select
    date(wo.created_at) Date
    ,wo.order_no 'Ticket ID'
    ,wo.pnos 运单号
    ,wo.client_id 客户ID
    ,case
        when wo.client_id in ('AA0386','AA0425','AA0427','AA0569','AA0572','AA0574','AA0606','AA0612','AA0657','AA0707') then 'Shopee'
        when wo.client_id in ('AA0330','AA0415','AA0428','AA0442','AA0461','AA0477','AA0538','AA0601') then 'Lazada'
        when wo.client_id in ('AA0660','AA0661','AA0703') then 'Tiktok'
    end 平台客户
    ,case ci.requester_category
        when 0 then '托运人员'
        when 1 then '收货人员'
        when 2 then '操作人员'
        when 3 then '销售人员'
        when 4 then '客服人员'
    end 请求者角色
    ,case ci.channel_category # 渠道
         when 0 then '电话'
         when 1 then '电子邮件'
         when 2 then '网页'
         when 3 then '网点'
         when 4 then '自主投诉页面'
         when 5 then '网页（facebook）'
         when 6 then 'APPSTORE'
         when 7 then 'Lazada系统'
         when 8 then 'Shopee系统'
         when 9 then 'TikTok'
    end 请求渠道
    ,case wo.status
        when 1 then '未阅读'
        when 2 then '已经阅读'
        when 3 then '已回复'
        when 4 then '已关闭'
    end 工单状态
    ,wo.title 工单主题
    ,case wo.order_type
        when 1 then '查找运单'
        when 2 then '加快处理'
        when 3 then '调查员工'
        when 4 then '其他'
        when 5 then '网点信息维护提醒'
        when 6 then '培训指导'
        when 7 then '异常业务询问'
        when 8 then '包裹丢失'
        when 9 then '包裹破损'
        when 10 then '货物短少'
        when 11 then '催单'
        when 12 then '有发无到'
        when 13 then '上报包裹不在集包里'
        when 16 then '漏揽收'
        when 50 then '虚假撤销'
        when 17 then '已签收未收到'
        when 18 then '客户投诉'
        when 19 then '修改包裹信息'
        when 20 then '修改 COD 金额'
        when 21 then '解锁包裹'
        when 22 then '申请索赔'
        when 23 then 'MS 问题反馈'
        when 24 then 'FBI 问题反馈'
        when 25 then 'KA System 问题反馈'
        when 26 then 'App 问题反馈'
        when 27 then 'KIT 问题反馈'
        when 28 then 'Backyard 问题反馈'
        when 29 then 'BS/FH 问题反馈'
        when 30 then '系统建议'
        when 31 then '申诉罚款'
        else wo.order_type
    end  工单类型
    ,wo.created_at 工单创建时间
    ,rep.created_at 工单回复时间
    ,case wo.is_call
        when 0 then '不需要'
        when 1 then '需要'
    end 致电客户
    ,case wo.up_report
        when 0 then '否'
        when 1 then '是'
    end 是否上报虚假工单
    ,datediff(wo.updated_at, wo.created_at) 工单处理天数
    ,wo.store_id '受理网点ID/部门'
    ,case
        when ss.`category` in (1,2,10,13) then 'sp'
        when ss.`category` in (8,9,12) then 'HUB/BHUB/OS'
        when ss.`category` IN (4,5,7) then 'SHOP/ushop'
        when ss.`category` IN (6)  then 'FH'
        when wo.`store_id` = '22' then 'kam客服中心'
        when wo.`store_id`in (3,'customer_manger') then  '总部客服中心'
        when wo.`store_id`= '12' then 'QA&QC'
        when wo.`store_id`= '18' then 'Flash Home客服中心'
        when wo.`created_store_id` = '22' and wo.`client_id` IN ('AA0302','AA0413','AA0472','AA0545','BF9675','BF9690','CA5901' ) then 'FFM'
        else '其他网点'
    end 受理部门
    ,ss.sorting_no 区域
    ,smr.name Area
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
    end as 运单状态
    ,if(pi.state = 5, date(convert_tz(pi.finished_at, '+00:00', '+07:00')), null) 妥投日期
    ,if(pi.state = 5, convert_tz(pi.finished_at, '+00:00', '+07:00'), null ) 妥投时间
    ,convert_tz(p1.routed_at, '+00:00', '+07:00') 第一次联系客户
    ,convert_tz(p2.routed_at, '+00:00', '+07:00') 最后联系客户
    ,if(pi.state = 5, datediff(date(convert_tz(pi.finished_at, '+00:00', '+07:00')), date(convert_tz(pi.created_at, '+00:00', '+07:00'))), null) 揽收至妥投
    ,datediff(curdate(), date(convert_tz(pi.created_at, '+00:00', '+07:00'))) 揽收至今
from bi_pro.work_order wo
join fle_staging.customer_issue ci on wo.customer_issue_id = ci.id
left join rep on rep.order_no = wo.order_no and rep.rn = 1
left join fle_staging.sys_store ss on ss.id = wo.store_id
left join fle_staging.sys_manage_region smr on smr.id = ss.manage_region
left join fle_staging.parcel_info pi on wo.pnos = pi.pno
left join pho p1 on p1.pno = wo.pnos and p1.rk = 1
left join pho p2 on p2.pno = wo.pnos and p2.rk = 1

where
    wo.created_store_id = 3 -- 总部客服中心
    and wo.created_at >= '2023-03-13'
    and wo.client_id in ('AA0386','AA0425','AA0427','AA0569','AA0572','AA0574','AA0606','AA0612','AA0657','AA0707','AA0330','AA0415','AA0428','AA0442','AA0461','AA0477','AA0538','AA0601','AA0660','AA0661','AA0703');
;-- -. . -..- - / . -. - .-. -.--
with rep as
(
    select
        wo.order_no
        ,wo.pnos
        ,wor.created_at
        ,row_number() over (partition by wo.order_no order by wor.created_at ) rn
    from bi_pro.work_order wo
    left join bi_pro.work_order_reply wor on wo.id = wor.order_id
    where
        wo.created_store_id = 3
        and wo.created_at >= '2023-03-14'
)
, pho as
(
    select
        pr.pno
        ,pr.routed_at
        ,row_number() over (partition by pr.pno order by pr.routed_at) rk
        ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk2
    from rot_pro.parcel_route pr
    join
        (
            select rep.pnos from rep group by 1
        ) r on pr.pno = r.pnos
    where
        pr.route_action = 'PHONE'
)
select
    date(wo.created_at) Date
    ,wo.order_no 'Ticket ID'
    ,wo.pnos 运单号
    ,wo.client_id 客户ID
    ,case
        when wo.client_id in ('AA0386','AA0425','AA0427','AA0569','AA0572','AA0574','AA0606','AA0612','AA0657','AA0707') then 'Shopee'
        when wo.client_id in ('AA0330','AA0415','AA0428','AA0442','AA0461','AA0477','AA0538','AA0601') then 'Lazada'
        when wo.client_id in ('AA0660','AA0661','AA0703') then 'Tiktok'
    end 平台客户
    ,case ci.requester_category
        when 0 then '托运人员'
        when 1 then '收货人员'
        when 2 then '操作人员'
        when 3 then '销售人员'
        when 4 then '客服人员'
    end 请求者角色
    ,case ci.channel_category # 渠道
         when 0 then '电话'
         when 1 then '电子邮件'
         when 2 then '网页'
         when 3 then '网点'
         when 4 then '自主投诉页面'
         when 5 then '网页（facebook）'
         when 6 then 'APPSTORE'
         when 7 then 'Lazada系统'
         when 8 then 'Shopee系统'
         when 9 then 'TikTok'
    end 请求渠道
    ,case wo.status
        when 1 then '未阅读'
        when 2 then '已经阅读'
        when 3 then '已回复'
        when 4 then '已关闭'
    end 工单状态
    ,wo.title 工单主题
    ,case wo.order_type
        when 1 then '查找运单'
        when 2 then '加快处理'
        when 3 then '调查员工'
        when 4 then '其他'
        when 5 then '网点信息维护提醒'
        when 6 then '培训指导'
        when 7 then '异常业务询问'
        when 8 then '包裹丢失'
        when 9 then '包裹破损'
        when 10 then '货物短少'
        when 11 then '催单'
        when 12 then '有发无到'
        when 13 then '上报包裹不在集包里'
        when 16 then '漏揽收'
        when 50 then '虚假撤销'
        when 17 then '已签收未收到'
        when 18 then '客户投诉'
        when 19 then '修改包裹信息'
        when 20 then '修改 COD 金额'
        when 21 then '解锁包裹'
        when 22 then '申请索赔'
        when 23 then 'MS 问题反馈'
        when 24 then 'FBI 问题反馈'
        when 25 then 'KA System 问题反馈'
        when 26 then 'App 问题反馈'
        when 27 then 'KIT 问题反馈'
        when 28 then 'Backyard 问题反馈'
        when 29 then 'BS/FH 问题反馈'
        when 30 then '系统建议'
        when 31 then '申诉罚款'
        else wo.order_type
    end  工单类型
    ,wo.created_at 工单创建时间
    ,rep.created_at 工单回复时间
    ,case wo.is_call
        when 0 then '不需要'
        when 1 then '需要'
    end 致电客户
    ,if(timestampdiff(second, coalesce(rep.created_at, now()), wo.latest_deal_at) > 0, '否', '是') 是否超时
    ,case wo.up_report
        when 0 then '否'
        when 1 then '是'
    end 是否上报虚假工单
    ,datediff(wo.updated_at, wo.created_at) 工单处理天数
    ,wo.store_id '受理网点ID/部门'
    ,case
        when ss.`category` in (1,2,10,13) then 'sp'
        when ss.`category` in (8,9,12) then 'HUB/BHUB/OS'
        when ss.`category` IN (4,5,7) then 'SHOP/ushop'
        when ss.`category` IN (6)  then 'FH'
        when wo.`store_id` = '22' then 'kam客服中心'
        when wo.`store_id`in (3,'customer_manger') then  '总部客服中心'
        when wo.`store_id`= '12' then 'QA&QC'
        when wo.`store_id`= '18' then 'Flash Home客服中心'
        when wo.`created_store_id` = '22' and wo.`client_id` IN ('AA0302','AA0413','AA0472','AA0545','BF9675','BF9690','CA5901' ) then 'FFM'
        else '其他网点'
    end 受理部门
    ,ss.name 网点名称
    ,ss.sorting_no 区域
    ,smr.name Area
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
    end as 运单状态
    ,if(pi.state = 5, date(convert_tz(pi.finished_at, '+00:00', '+07:00')), null) 妥投日期
    ,if(pi.state = 5, convert_tz(pi.finished_at, '+00:00', '+07:00'), null ) 妥投时间
    ,convert_tz(p1.routed_at, '+00:00', '+07:00') 第一次联系客户
    ,convert_tz(p2.routed_at, '+00:00', '+07:00') 最后联系客户
    ,if(pi.state = 5, datediff(date(convert_tz(pi.finished_at, '+00:00', '+07:00')), date(convert_tz(pi.created_at, '+00:00', '+07:00'))), null) 揽收至妥投
    ,datediff(curdate(), date(convert_tz(pi.created_at, '+00:00', '+07:00'))) 揽收至今
from bi_pro.work_order wo
join fle_staging.customer_issue ci on wo.customer_issue_id = ci.id
left join rep on rep.order_no = wo.order_no and rep.rn = 1
left join fle_staging.sys_store ss on ss.id = wo.store_id
left join fle_staging.sys_manage_region smr on smr.id = ss.manage_region
left join fle_staging.parcel_info pi on wo.pnos = pi.pno
left join pho p1 on p1.pno = wo.pnos and p1.rk = 1
left join pho p2 on p2.pno = wo.pnos and p2.rk = 1

where
    wo.created_store_id = 3 -- 总部客服中心
    and wo.created_at >= '2023-03-13'
    and wo.client_id in ('AA0386','AA0425','AA0427','AA0569','AA0572','AA0574','AA0606','AA0612','AA0657','AA0707','AA0330','AA0415','AA0428','AA0442','AA0461','AA0477','AA0538','AA0601','AA0660','AA0661','AA0703');
;-- -. . -..- - / . -. - .-. -.--
with rep as
(
    select
        wo.order_no
        ,wo.pnos
        ,wor.created_at
        ,row_number() over (partition by wo.order_no order by wor.created_at ) rn
    from bi_pro.work_order wo
    left join bi_pro.work_order_reply wor on wo.id = wor.order_id
    where
        wo.created_store_id = 3
        and wo.created_at >= '2023-03-14'
)
, pho as
(
    select
        pr.pno
        ,pr.routed_at
        ,row_number() over (partition by pr.pno order by pr.routed_at) rk
        ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk2
    from rot_pro.parcel_route pr
    join
        (
            select rep.pnos from rep group by 1
        ) r on pr.pno = r.pnos
    where
        pr.route_action = 'PHONE'
)
select
    date(wo.created_at) Date
    ,wo.order_no 'Ticket ID'
    ,wo.pnos 运单号
    ,wo.client_id 客户ID
    ,case
        when wo.client_id in ('AA0386','AA0425','AA0427','AA0569','AA0572','AA0574','AA0606','AA0612','AA0657','AA0707') then 'Shopee'
        when wo.client_id in ('AA0330','AA0415','AA0428','AA0442','AA0461','AA0477','AA0538','AA0601') then 'Lazada'
        when wo.client_id in ('AA0660','AA0661','AA0703') then 'Tiktok'
    end 平台客户
    ,case ci.requester_category
        when 0 then '托运人员'
        when 1 then '收货人员'
        when 2 then '操作人员'
        when 3 then '销售人员'
        when 4 then '客服人员'
    end 请求者角色
    ,case ci.channel_category # 渠道
         when 0 then '电话'
         when 1 then '电子邮件'
         when 2 then '网页'
         when 3 then '网点'
         when 4 then '自主投诉页面'
         when 5 then '网页（facebook）'
         when 6 then 'APPSTORE'
         when 7 then 'Lazada系统'
         when 8 then 'Shopee系统'
         when 9 then 'TikTok'
    end 请求渠道
    ,case wo.status
        when 1 then '未阅读'
        when 2 then '已经阅读'
        when 3 then '已回复'
        when 4 then '已关闭'
    end 工单状态
    ,wo.title 工单主题
    ,case wo.order_type
        when 1 then '查找运单'
        when 2 then '加快处理'
        when 3 then '调查员工'
        when 4 then '其他'
        when 5 then '网点信息维护提醒'
        when 6 then '培训指导'
        when 7 then '异常业务询问'
        when 8 then '包裹丢失'
        when 9 then '包裹破损'
        when 10 then '货物短少'
        when 11 then '催单'
        when 12 then '有发无到'
        when 13 then '上报包裹不在集包里'
        when 16 then '漏揽收'
        when 50 then '虚假撤销'
        when 17 then '已签收未收到'
        when 18 then '客户投诉'
        when 19 then '修改包裹信息'
        when 20 then '修改 COD 金额'
        when 21 then '解锁包裹'
        when 22 then '申请索赔'
        when 23 then 'MS 问题反馈'
        when 24 then 'FBI 问题反馈'
        when 25 then 'KA System 问题反馈'
        when 26 then 'App 问题反馈'
        when 27 then 'KIT 问题反馈'
        when 28 then 'Backyard 问题反馈'
        when 29 then 'BS/FH 问题反馈'
        when 30 then '系统建议'
        when 31 then '申诉罚款'
        else wo.order_type
    end  工单类型
    ,wo.created_at 工单创建时间
    ,rep.created_at 工单回复时间
    ,case wo.is_call
        when 0 then '不需要'
        when 1 then '需要'
    end 致电客户
    ,if(timestampdiff(second, coalesce(rep.created_at, now()), wo.latest_deal_at) > 0, '否', '是') 是否超时
    ,case wo.up_report
        when 0 then '否'
        when 1 then '是'
    end 是否上报虚假工单
    ,datediff(wo.updated_at, wo.created_at) 工单处理天数
    ,wo.store_id '受理网点ID/部门'
    ,case
        when ss.`category` in (1,2,10,13) then 'sp'
        when ss.`category` in (8,9,12) then 'HUB/BHUB/OS'
        when ss.`category` IN (4,5,7) then 'SHOP/ushop'
        when ss.`category` IN (6)  then 'FH'
        when wo.`store_id` = '22' then 'kam客服中心'
        when wo.`store_id`in (3,'customer_manger') then  '总部客服中心'
        when wo.`store_id`= '12' then 'QA&QC'
        when wo.`store_id`= '18' then 'Flash Home客服中心'
        when wo.`created_store_id` = '22' and wo.`client_id` IN ('AA0302','AA0413','AA0472','AA0545','BF9675','BF9690','CA5901' ) then 'FFM'
        else '其他网点'
    end 受理部门
    ,ss.name 网点名称
    ,ss.sorting_no 区域
    ,smr.name Area
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
    end as 运单状态
    ,if(pi.state = 5, date(convert_tz(pi.finished_at, '+00:00', '+07:00')), null) 妥投日期
    ,if(pi.state = 5, convert_tz(pi.finished_at, '+00:00', '+07:00'), null ) 妥投时间
    ,convert_tz(p1.routed_at, '+00:00', '+07:00') 第一次联系客户
    ,convert_tz(p2.routed_at, '+00:00', '+07:00') 最后联系客户
    ,if(pi.state = 5, datediff(date(convert_tz(pi.finished_at, '+00:00', '+07:00')), date(convert_tz(pi.created_at, '+00:00', '+07:00'))), null) 揽收至妥投
    ,datediff(curdate(), date(convert_tz(pi.created_at, '+00:00', '+07:00'))) 揽收至今
from bi_pro.work_order wo
join fle_staging.customer_issue ci on wo.customer_issue_id = ci.id
left join rep on rep.order_no = wo.order_no and rep.rn = 1
left join fle_staging.sys_store ss on ss.id = wo.store_id
left join fle_staging.sys_manage_region smr on smr.id = ss.manage_region
left join fle_staging.parcel_info pi on wo.pnos = pi.pno
left join pho p1 on p1.pno = wo.pnos and p1.rk = 1
left join pho p2 on p2.pno = wo.pnos and p2.rk = 1

where
    wo.created_store_id = 3 -- 总部客服中心
    and wo.created_at >= '2023-03-14'
    and wo.client_id in ('AA0386','AA0425','AA0427','AA0569','AA0572','AA0574','AA0606','AA0612','AA0657','AA0707','AA0330','AA0415','AA0428','AA0442','AA0461','AA0477','AA0538','AA0601','AA0660','AA0661','AA0703');
;-- -. . -..- - / . -. - .-. -.--
with t1 as
(
    select
        plt.pno
        ,plt.id
        ,plt.client_id
        ,plt.created_at
        ,plt.last_valid_store_id
        ,plt.last_valid_staff_info_id
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
    join t1 on t1.id = wo.loseparcel_task_id
    left join bi_pro.work_order_reply wor on wor.order_id = wo.id
    left join bi_pro.work_order_img woi on woi.origin_id = wor.id
)
,t2 as
(
    select
        wo.pnos
        ,wo.created_at
        ,row_number() over (partition by wo.pnos order by wo.created_at ) rn
    from bi_pro.work_order wo
    join t1 on t1.pno = wo.pnos
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
    ,t1.last_valid_staff_info_id 最后有效路由操作人
    ,ss_valid.name 最后有效路由网点
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
    ,lst.content 最后一次全组织工单回复内容
    ,1st.wor_content 第一次回复内容
    ,concat('https://fle-asset-internal.oss-ap-southeast-1.aliyuncs.com/',1st.object_key) 第一次回复附件
    ,2nd.wor_content 第二次回复内容
    ,concat('https://fle-asset-internal.oss-ap-southeast-1.aliyuncs.com/',2nd.object_key) 第二次回复附件
    ,3rd.wor_content 第三次回复内容
    ,concat('https://fle-asset-internal.oss-ap-southeast-1.aliyuncs.com/',3rd.object_key) 第三次回复附件
    ,concat('https://fle-asset-internal.oss-ap-southeast-1.aliyuncs.com/',sa1.object_key) 签收凭证
    ,concat('https://fle-asset-internal.oss-ap-southeast-1.aliyuncs.com/',sa2.object_key) 其他凭证
from t1
left join fle_staging.parcel_info pi on pi.pno = t1.pno
left join fle_staging.sys_store dst_ss on dst_ss.id = pi.dst_store_id
left join fle_staging.sys_store del_ss on del_ss.id = pi.ticket_delivery_store_id
left join fle_staging.sys_store ss_valid on ss_valid.id = t1.last_valid_store_id
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
left join t2 fir on fir.pnos = t1.pno and fir.rn = 1
left join
    (
        select
            wo2.pnos
            ,wor.content
            ,row_number() over (partition by wo2.pnos order by wor.created_at desc) rn
        from bi_pro.work_order wo2
        join t1 on t1.pno = wo2.pnos
        left join bi_pro.work_order_reply wor on wor.order_id = wo2.id
        where
            wor.staff_info_id != wo2.created_staff_info_id
    ) lst on lst.pnos = t1.pno and lst.rn = 1
left join fle_staging.sys_attachment sa1 on sa1.oss_bucket_key = t1.pno and sa1.oss_bucket_type = 'DELIVERY_CONFIRM'
left join fle_staging.sys_attachment sa2 on sa2.oss_bucket_key = t1.pno and sa2.oss_bucket_type = 'DELIVERY_CONFIRM_OTHER';
;-- -. . -..- - / . -. - .-. -.--
select
    t.pno
    ,pi.returned
    ,pi2.cod_amount/100 cod金额
from fle_staging.parcel_info pi
join tmpale.tmp_th_pno_2023_03_14 t on t.pno = pi.pno
left join fle_staging.parcel_info pi2 on if(pi.returned = 1, pi.customary_pno, pi.pno) = pi2.pno;
;-- -. . -..- - / . -. - .-. -.--
with rep as
(
    select
        wo.order_no
        ,wo.pnos
        ,wor.created_at
        ,row_number() over (partition by wo.order_no order by wor.created_at ) rn
    from bi_pro.work_order wo
    left join bi_pro.work_order_reply wor on wo.id = wor.order_id
    where
        wo.created_store_id = 3
        and wo.created_at >= '2023-03-13'
)
, pho as
(
    select
        pr.pno
        ,pr.routed_at
        ,row_number() over (partition by pr.pno order by pr.routed_at) rk
        ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk2
    from rot_pro.parcel_route pr
    join
        (
            select rep.pnos from rep group by 1
        ) r on pr.pno = r.pnos
    where
        pr.route_action = 'PHONE'
)
select
    date(wo.created_at) Date
    ,wo.order_no 'Ticket ID'
    ,wo.pnos 运单号
    ,wo.client_id 客户ID
    ,case
        when wo.client_id in ('AA0386','AA0425','AA0427','AA0569','AA0572','AA0574','AA0606','AA0612','AA0657','AA0707') then 'Shopee'
        when wo.client_id in ('AA0330','AA0415','AA0428','AA0442','AA0461','AA0477','AA0538','AA0601') then 'Lazada'
        when wo.client_id in ('AA0660','AA0661','AA0703') then 'Tiktok'
    end 平台客户
    ,case ci.requester_category
        when 0 then '托运人员'
        when 1 then '收货人员'
        when 2 then '操作人员'
        when 3 then '销售人员'
        when 4 then '客服人员'
    end 请求者角色
    ,case ci.channel_category # 渠道
         when 0 then '电话'
         when 1 then '电子邮件'
         when 2 then '网页'
         when 3 then '网点'
         when 4 then '自主投诉页面'
         when 5 then '网页（facebook）'
         when 6 then 'APPSTORE'
         when 7 then 'Lazada系统'
         when 8 then 'Shopee系统'
         when 9 then 'TikTok'
    end 请求渠道
    ,case wo.status
        when 1 then '未阅读'
        when 2 then '已经阅读'
        when 3 then '已回复'
        when 4 then '已关闭'
    end 工单状态
    ,wo.title 工单主题
    ,case wo.order_type
        when 1 then '查找运单'
        when 2 then '加快处理'
        when 3 then '调查员工'
        when 4 then '其他'
        when 5 then '网点信息维护提醒'
        when 6 then '培训指导'
        when 7 then '异常业务询问'
        when 8 then '包裹丢失'
        when 9 then '包裹破损'
        when 10 then '货物短少'
        when 11 then '催单'
        when 12 then '有发无到'
        when 13 then '上报包裹不在集包里'
        when 16 then '漏揽收'
        when 50 then '虚假撤销'
        when 17 then '已签收未收到'
        when 18 then '客户投诉'
        when 19 then '修改包裹信息'
        when 20 then '修改 COD 金额'
        when 21 then '解锁包裹'
        when 22 then '申请索赔'
        when 23 then 'MS 问题反馈'
        when 24 then 'FBI 问题反馈'
        when 25 then 'KA System 问题反馈'
        when 26 then 'App 问题反馈'
        when 27 then 'KIT 问题反馈'
        when 28 then 'Backyard 问题反馈'
        when 29 then 'BS/FH 问题反馈'
        when 30 then '系统建议'
        when 31 then '申诉罚款'
        else wo.order_type
    end  工单类型
    ,wo.created_at 工单创建时间
    ,rep.created_at 工单回复时间
    ,case wo.is_call
        when 0 then '不需要'
        when 1 then '需要'
    end 致电客户
    ,if(timestampdiff(second, coalesce(rep.created_at, now()), wo.latest_deal_at) > 0, '否', '是') 是否超时
    ,case wo.up_report
        when 0 then '否'
        when 1 then '是'
    end 是否上报虚假工单
    ,datediff(wo.updated_at, wo.created_at) 工单处理天数
    ,wo.store_id '受理网点ID/部门'
    ,case
        when ss.`category` in (1,2,10,13) then 'sp'
        when ss.`category` in (8,9,12) then 'HUB/BHUB/OS'
        when ss.`category` IN (4,5,7) then 'SHOP/ushop'
        when ss.`category` IN (6)  then 'FH'
        when wo.`store_id` = '22' then 'kam客服中心'
        when wo.`store_id`in (3,'customer_manger') then  '总部客服中心'
        when wo.`store_id`= '12' then 'QA&QC'
        when wo.`store_id`= '18' then 'Flash Home客服中心'
        when wo.`created_store_id` = '22' and wo.`client_id` IN ('AA0302','AA0413','AA0472','AA0545','BF9675','BF9690','CA5901' ) then 'FFM'
        else '其他网点'
    end 受理部门
    ,ss.name 网点名称
    ,ss.sorting_no 区域
    ,smr.name Area
    ,smp.name 片区
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
    end as 运单状态
    ,if(pi.state = 5, date(convert_tz(pi.finished_at, '+00:00', '+07:00')), null) 妥投日期
    ,if(pi.state = 5, convert_tz(pi.finished_at, '+00:00', '+07:00'), null ) 妥投时间
    ,convert_tz(p1.routed_at, '+00:00', '+07:00') 第一次联系客户
    ,convert_tz(p2.routed_at, '+00:00', '+07:00') 最后联系客户
    ,if(pi.state = 5, datediff(date(convert_tz(pi.finished_at, '+00:00', '+07:00')), date(convert_tz(pi.created_at, '+00:00', '+07:00'))), null) 揽收至妥投
    ,datediff(curdate(), date(convert_tz(pi.created_at, '+00:00', '+07:00'))) 揽收至今
from bi_pro.work_order wo
join fle_staging.customer_issue ci on wo.customer_issue_id = ci.id
left join rep on rep.order_no = wo.order_no and rep.rn = 1
left join fle_staging.sys_store ss on ss.id = wo.store_id
left join fle_staging.sys_manage_region smr on smr.id = ss.manage_region
left join fle_staging.sys_manage_piece smp on smp.id = ss.manage_piece
left join fle_staging.parcel_info pi on wo.pnos = pi.pno
left join pho p1 on p1.pno = wo.pnos and p1.rk = 1
left join pho p2 on p2.pno = wo.pnos and p2.rk = 1

where
    wo.created_store_id = 3 -- 总部客服中心
    and wo.created_at >= '2023-03-13'
    and wo.client_id in ('AA0386','AA0425','AA0427','AA0569','AA0572','AA0574','AA0606','AA0612','AA0657','AA0707','AA0330','AA0415','AA0428','AA0442','AA0461','AA0477','AA0538','AA0601','AA0660','AA0661','AA0703');
;-- -. . -..- - / . -. - .-. -.--
with rep as
(
    select
        wo.order_no
        ,wo.pnos
        ,wor.created_at
        ,row_number() over (partition by wo.order_no order by wor.created_at ) rn
    from bi_pro.work_order wo
    left join bi_pro.work_order_reply wor on wo.id = wor.order_id
    where
        wo.created_store_id = 3
        and wo.created_at >= curdate()
        and wo.created_at < date_add(curdate(), interval 1 day)
)
, pho as
(
    select
        pr.pno
        ,pr.routed_at
        ,row_number() over (partition by pr.pno order by pr.routed_at) rk
        ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk2
    from rot_pro.parcel_route pr
    join
        (
            select rep.pnos from rep group by 1
        ) r on pr.pno = r.pnos
    where
        pr.route_action = 'PHONE'
)
select
    date(wo.created_at) Date
    ,wo.order_no 'Ticket ID'
    ,wo.pnos 运单号
    ,wo.client_id 客户ID
    ,case
        when wo.client_id in ('AA0386','AA0425','AA0427','AA0569','AA0572','AA0574','AA0606','AA0612','AA0657','AA0707') then 'Shopee'
        when wo.client_id in ('AA0330','AA0415','AA0428','AA0442','AA0461','AA0477','AA0538','AA0601') then 'Lazada'
        when wo.client_id in ('AA0660','AA0661','AA0703') then 'Tiktok'
    end 平台客户
    ,case ci.requester_category
        when 0 then '托运人员'
        when 1 then '收货人员'
        when 2 then '操作人员'
        when 3 then '销售人员'
        when 4 then '客服人员'
    end 请求者角色
    ,case ci.channel_category # 渠道
         when 0 then '电话'
         when 1 then '电子邮件'
         when 2 then '网页'
         when 3 then '网点'
         when 4 then '自主投诉页面'
         when 5 then '网页（facebook）'
         when 6 then 'APPSTORE'
         when 7 then 'Lazada系统'
         when 8 then 'Shopee系统'
         when 9 then 'TikTok'
    end 请求渠道
    ,case wo.status
        when 1 then '未阅读'
        when 2 then '已经阅读'
        when 3 then '已回复'
        when 4 then '已关闭'
    end 工单状态
    ,wo.title 工单主题
    ,case wo.order_type
        when 1 then '查找运单'
        when 2 then '加快处理'
        when 3 then '调查员工'
        when 4 then '其他'
        when 5 then '网点信息维护提醒'
        when 6 then '培训指导'
        when 7 then '异常业务询问'
        when 8 then '包裹丢失'
        when 9 then '包裹破损'
        when 10 then '货物短少'
        when 11 then '催单'
        when 12 then '有发无到'
        when 13 then '上报包裹不在集包里'
        when 16 then '漏揽收'
        when 50 then '虚假撤销'
        when 17 then '已签收未收到'
        when 18 then '客户投诉'
        when 19 then '修改包裹信息'
        when 20 then '修改 COD 金额'
        when 21 then '解锁包裹'
        when 22 then '申请索赔'
        when 23 then 'MS 问题反馈'
        when 24 then 'FBI 问题反馈'
        when 25 then 'KA System 问题反馈'
        when 26 then 'App 问题反馈'
        when 27 then 'KIT 问题反馈'
        when 28 then 'Backyard 问题反馈'
        when 29 then 'BS/FH 问题反馈'
        when 30 then '系统建议'
        when 31 then '申诉罚款'
        else wo.order_type
    end  工单类型
    ,wo.created_at 工单创建时间
    ,rep.created_at 工单回复时间
    ,case wo.is_call
        when 0 then '不需要'
        when 1 then '需要'
    end 致电客户
    ,if(timestampdiff(second, coalesce(rep.created_at, now()), wo.latest_deal_at) > 0, '否', '是') 是否超时
    ,case wo.up_report
        when 0 then '否'
        when 1 then '是'
    end 是否上报虚假工单
    ,datediff(wo.updated_at, wo.created_at) 工单处理天数
    ,wo.store_id '受理网点ID/部门'
    ,case
        when ss.`category` in (1,2,10,13) then 'sp'
        when ss.`category` in (8,9,12) then 'HUB/BHUB/OS'
        when ss.`category` IN (4,5,7) then 'SHOP/ushop'
        when ss.`category` IN (6)  then 'FH'
        when wo.`store_id` = '22' then 'kam客服中心'
        when wo.`store_id`in (3,'customer_manger') then  '总部客服中心'
        when wo.`store_id`= '12' then 'QA&QC'
        when wo.`store_id`= '18' then 'Flash Home客服中心'
        when wo.`created_store_id` = '22' and wo.`client_id` IN ('AA0302','AA0413','AA0472','AA0545','BF9675','BF9690','CA5901' ) then 'FFM'
        else '其他网点'
    end 受理部门
    ,ss.name 网点名称
    ,ss.sorting_no 区域
    ,smr.name Area
    ,smp.name 片区
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
    end as 运单状态
    ,if(pi.state = 5, date(convert_tz(pi.finished_at, '+00:00', '+07:00')), null) 妥投日期
    ,if(pi.state = 5, convert_tz(pi.finished_at, '+00:00', '+07:00'), null ) 妥投时间
    ,convert_tz(p1.routed_at, '+00:00', '+07:00') 第一次联系客户
    ,convert_tz(p2.routed_at, '+00:00', '+07:00') 最后联系客户
    ,if(pi.state = 5, datediff(date(convert_tz(pi.finished_at, '+00:00', '+07:00')), date(convert_tz(pi.created_at, '+00:00', '+07:00'))), null) 揽收至妥投
    ,datediff(curdate(), date(convert_tz(pi.created_at, '+00:00', '+07:00'))) 揽收至今
from bi_pro.work_order wo
join fle_staging.customer_issue ci on wo.customer_issue_id = ci.id
left join rep on rep.order_no = wo.order_no and rep.rn = 1
left join fle_staging.sys_store ss on ss.id = wo.store_id
left join fle_staging.sys_manage_region smr on smr.id = ss.manage_region
left join fle_staging.sys_manage_piece smp on smp.id = ss.manage_piece
left join fle_staging.parcel_info pi on wo.pnos = pi.pno
left join pho p1 on p1.pno = wo.pnos and p1.rk = 1
left join pho p2 on p2.pno = wo.pnos and p2.rk = 1

where
    wo.created_store_id = 3 -- 总部客服中心
    and wo.created_at >= curdate()
    and wo.created_at < date_add(curdate(), interval 1 day)
    and wo.client_id in ('AA0386','AA0425','AA0427','AA0569','AA0572','AA0574','AA0606','AA0612','AA0657','AA0707','AA0330','AA0415','AA0428','AA0442','AA0461','AA0477','AA0538','AA0601','AA0660','AA0661','AA0703');
;-- -. . -..- - / . -. - .-. -.--
with rep as
(
    select
        wo.order_no
        ,wo.pnos
        ,wor.created_at
        ,row_number() over (partition by wo.order_no order by wor.created_at ) rn
    from bi_pro.work_order wo
    left join bi_pro.work_order_reply wor on wo.id = wor.order_id
    where
        wo.created_store_id = 3
        and wo.created_at >= date_sub(curdate(), interval 1 day)
        and wo.created_at < curdate()
)
, pho as
(
    select
        pr.pno
        ,pr.routed_at
        ,row_number() over (partition by pr.pno order by pr.routed_at) rk
        ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk2
    from rot_pro.parcel_route pr
    join
        (
            select rep.pnos from rep group by 1
        ) r on pr.pno = r.pnos
    where
        pr.route_action = 'PHONE'
)
select
    date(wo.created_at) Date
    ,wo.order_no 'Ticket ID'
    ,wo.pnos 运单号
    ,wo.client_id 客户ID
    ,case
        when wo.client_id in ('AA0386','AA0425','AA0427','AA0569','AA0572','AA0574','AA0606','AA0612','AA0657','AA0707') then 'Shopee'
        when wo.client_id in ('AA0330','AA0415','AA0428','AA0442','AA0461','AA0477','AA0538','AA0601') then 'Lazada'
        when wo.client_id in ('AA0660','AA0661','AA0703') then 'Tiktok'
    end 平台客户
    ,case ci.requester_category
        when 0 then '托运人员'
        when 1 then '收货人员'
        when 2 then '操作人员'
        when 3 then '销售人员'
        when 4 then '客服人员'
    end 请求者角色
    ,case ci.channel_category # 渠道
         when 0 then '电话'
         when 1 then '电子邮件'
         when 2 then '网页'
         when 3 then '网点'
         when 4 then '自主投诉页面'
         when 5 then '网页（facebook）'
         when 6 then 'APPSTORE'
         when 7 then 'Lazada系统'
         when 8 then 'Shopee系统'
         when 9 then 'TikTok'
    end 请求渠道
    ,case wo.status
        when 1 then '未阅读'
        when 2 then '已经阅读'
        when 3 then '已回复'
        when 4 then '已关闭'
    end 工单状态
    ,wo.title 工单主题
    ,case wo.order_type
        when 1 then '查找运单'
        when 2 then '加快处理'
        when 3 then '调查员工'
        when 4 then '其他'
        when 5 then '网点信息维护提醒'
        when 6 then '培训指导'
        when 7 then '异常业务询问'
        when 8 then '包裹丢失'
        when 9 then '包裹破损'
        when 10 then '货物短少'
        when 11 then '催单'
        when 12 then '有发无到'
        when 13 then '上报包裹不在集包里'
        when 16 then '漏揽收'
        when 50 then '虚假撤销'
        when 17 then '已签收未收到'
        when 18 then '客户投诉'
        when 19 then '修改包裹信息'
        when 20 then '修改 COD 金额'
        when 21 then '解锁包裹'
        when 22 then '申请索赔'
        when 23 then 'MS 问题反馈'
        when 24 then 'FBI 问题反馈'
        when 25 then 'KA System 问题反馈'
        when 26 then 'App 问题反馈'
        when 27 then 'KIT 问题反馈'
        when 28 then 'Backyard 问题反馈'
        when 29 then 'BS/FH 问题反馈'
        when 30 then '系统建议'
        when 31 then '申诉罚款'
        else wo.order_type
    end  工单类型
    ,wo.created_at 工单创建时间
    ,rep.created_at 工单回复时间
    ,case wo.is_call
        when 0 then '不需要'
        when 1 then '需要'
    end 致电客户
    ,if(timestampdiff(second, coalesce(rep.created_at, now()), wo.latest_deal_at) > 0, '否', '是') 是否超时
    ,case wo.up_report
        when 0 then '否'
        when 1 then '是'
    end 是否上报虚假工单
    ,datediff(wo.updated_at, wo.created_at) 工单处理天数
    ,wo.store_id '受理网点ID/部门'
    ,case
        when ss.`category` in (1,2,10,13) then 'sp'
        when ss.`category` in (8,9,12) then 'HUB/BHUB/OS'
        when ss.`category` IN (4,5,7) then 'SHOP/ushop'
        when ss.`category` IN (6)  then 'FH'
        when wo.`store_id` = '22' then 'kam客服中心'
        when wo.`store_id`in (3,'customer_manger') then  '总部客服中心'
        when wo.`store_id`= '12' then 'QA&QC'
        when wo.`store_id`= '18' then 'Flash Home客服中心'
        when wo.`created_store_id` = '22' and wo.`client_id` IN ('AA0302','AA0413','AA0472','AA0545','BF9675','BF9690','CA5901' ) then 'FFM'
        else '其他网点'
    end 受理部门
    ,ss.name 网点名称
    ,ss.sorting_no 区域
    ,smr.name Area
    ,smp.name 片区
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
    end as 运单状态
    ,if(pi.state = 5, date(convert_tz(pi.finished_at, '+00:00', '+07:00')), null) 妥投日期
    ,if(pi.state = 5, convert_tz(pi.finished_at, '+00:00', '+07:00'), null ) 妥投时间
    ,convert_tz(p1.routed_at, '+00:00', '+07:00') 第一次联系客户
    ,convert_tz(p2.routed_at, '+00:00', '+07:00') 最后联系客户
    ,if(pi.state = 5, datediff(date(convert_tz(pi.finished_at, '+00:00', '+07:00')), date(convert_tz(pi.created_at, '+00:00', '+07:00'))), null) 揽收至妥投
    ,datediff(curdate(), date(convert_tz(pi.created_at, '+00:00', '+07:00'))) 揽收至今
from bi_pro.work_order wo
join fle_staging.customer_issue ci on wo.customer_issue_id = ci.id
left join rep on rep.order_no = wo.order_no and rep.rn = 1
left join fle_staging.sys_store ss on ss.id = wo.store_id
left join fle_staging.sys_manage_region smr on smr.id = ss.manage_region
left join fle_staging.sys_manage_piece smp on smp.id = ss.manage_piece
left join fle_staging.parcel_info pi on wo.pnos = pi.pno
left join pho p1 on p1.pno = wo.pnos and p1.rk = 1
left join pho p2 on p2.pno = wo.pnos and p2.rk = 1

where
    wo.created_store_id = 3 -- 总部客服中心
    and wo.created_at >= date_sub(curdate(), interval 1 day)
    and wo.created_at < curdate()
    and wo.client_id in ('AA0386','AA0425','AA0427','AA0569','AA0572','AA0574','AA0606','AA0612','AA0657','AA0707','AA0330','AA0415','AA0428','AA0442','AA0461','AA0477','AA0538','AA0601','AA0660','AA0661','AA0703');
;-- -. . -..- - / . -. - .-. -.--
select
            wo.id
            ,cg.name cg_name
            ,count(wo.id) over (partition by wo.pnos) pno_count
        from bi_pro.work_order wo
        left join fle_staging.sys_store ss on ss.id = wo.created_store_id
        left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id
        join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','KAM TH','KAM CN')
        where
            wo.created_at > '2022-11-30 18:00:00'
            and wo.created_at < '2022-12-01 18:00:00'
            and wo.store_id = 22
            and ss.id is not null;
;-- -. . -..- - / . -. - .-. -.--
select
            wo.id
            ,cg.name cg_name
            ,wo.pnos
            ,count(wo.id) over (partition by wo.pnos) pno_count
        from bi_pro.work_order wo
        left join fle_staging.sys_store ss on ss.id = wo.created_store_id
        left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id
        join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','KAM TH','KAM CN')
        where
            wo.created_at > '2022-11-30 18:00:00'
            and wo.created_at < '2022-12-01 18:00:00'
            and wo.store_id = 22
            and ss.id is not null;
;-- -. . -..- - / . -. - .-. -.--
select
            wo.id
            ,cg.name cg_name
            ,wo.pnos
            ,count(wo.id) over (partition by wo.pnos) pno_count
        from bi_pro.work_order wo
        left join fle_staging.sys_store ss on ss.id = wo.created_store_id
        left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
        join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','KAM TH','KAM CN')
        where
            wo.created_at > '2022-11-30 18:00:00'
            and wo.created_at < '2022-12-01 18:00:00'
            and wo.store_id = 22
            and ss.id is not null;
;-- -. . -..- - / . -. - .-. -.--
select * from bi_pro.parcel_lose_task plt where  plt.pno = 'TH07012YKWYK9F-2';
;-- -. . -..- - / . -. - .-. -.--
select * from bi_pro.parcel_lose_task plt where  plt.pno = 'TH07012YKWYK9F';
;-- -. . -..- - / . -. - .-. -.--
select * from bi_pro.parcel_lose_task plt where  plt.pno = 'TH02023V2GZB0H';
;-- -. . -..- - / . -. - .-. -.--
select
    t1.month_d 月份
    ,t1.cg_name 项目组
    ,t1.should_deal 应处理工单数
    ,t2.already_deal 完结工单数
    ,t1.not_already_deal 应处理工单当月未完成单数
    ,t1.deal_rate 当月工单完结率
    ,zl.zl_num 滞留工单单数
    ,t2.deal_avg_time 完结工单单均处理时长
    ,cf.repeat_num 工单重复包裹数
from
    ( -- 当月产生
         select
             month(date_add(wo.created_at, interval 6 hour))  month_d
             ,cg.name cg_name
             ,count(distinct wo.id) should_deal
             ,count(distinct if(wo.status in (1, 2) or (wo.status in (3, 4) and wo.latest_reply_at >= adddate(last_day(date_add(wo.created_at, interval 6 hour)), 1) +interval 18 hour), wo.id,  null)) not_already_deal                                                          should_not_deal
             ,count(distinct if(wo.status in (3, 4) and wo.latest_reply_at <= adddate(last_day(date_add(wo.created_at, interval 6 hour)), 1) + interval 18 hour)) / count(distinct wo.id) deal_rate
         from bi_pro.work_order wo
         left join fle_staging.sys_store ss on ss.id = wo.created_store_id
         left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
         join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','KAM TH','KAM CN')
         where
            wo.created_at > '2022-11-30 18:00:00'
            and wo.created_at < '2023-02-28 18:00:00'
            and wo.store_id = 22
            and ss.id is not null
         group by 1,2
    ) t1
left join
     (-- 当月完结，已回复和已关闭的工单按照最后一次回复时间认定为结束时间
         select
             month(wo.latest_reply_at) month_d
            ,,cg.name cg_name
            ,count(distinct wo.id)  already_deal
            ,sum(timestampdiff(second, wo.created_at, wo.latest_reply_at) / 3600) /count(distinct wo.id) deal_avg_time
         from bi_pro.work_order wo
         left join fle_staging.sys_store ss on ss.id = wo.created_store_id
         left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
         join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','KAM TH','KAM CN')
         where wo.latest_reply_at >= '2022-12-01 00:00:00'
            and wo.latest_reply_at < '2023-03-01 00:00:00'
            and wo.store_id = 22
            and ss.id is not null
            and wo.status in (3, 4)
         group by 1,2
    ) t2 on t2.month_d = t1.month_d and t2.cg_name = t1.cg_name
left join
    (
        select
            '12' month_d
            ,cg.name cg_name
            ,count(distinct wo.id) zl_num
        from bi_pro.work_order wo
        left join fle_staging.sys_store ss on ss.id = wo.created_store_id
        left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
        join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','KAM TH','KAM CN')
        where
            ss.id is not null
            and wo.created_at >= '2022-01-01'
            and wo.created_at < '2023-01-01'
            and wo.store_id = 22
            and
                (
                    wo.status in (1,2)
                    or (wo.status in (3,4) and wo.latest_reply_at >= '2022-12-31 18:00:00')
                )
        group by 1,2

        union all

        select
            '1' month_d
            ,cg.name cg_name
            ,count(distinct wo.id) zl_num
        from bi_pro.work_order wo
        left join fle_staging.sys_store ss on ss.id = wo.created_store_id
        left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
        join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','KAM TH','KAM CN')
        where
            ss.id is not null
            and wo.created_at >= '2022-01-01'
            and wo.created_at < '2023-02-01'
            and wo.store_id = 22
            and
                (
                    wo.status in (1,2)
                    or (wo.status in (3,4) and wo.latest_reply_at >= '2023-01-31 18:00:00')
                )
        group by 1,2

        union all

        select
            '2' month_d
            ,cg.name cg_name
            ,count(distinct wo.id) zl_num
        from bi_pro.work_order wo
        left join fle_staging.sys_store ss on ss.id = wo.created_store_id
        left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
        join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','KAM TH','KAM CN')
        where
            ss.id is not null
            and wo.created_at >= '2022-01-01'
            and wo.created_at < '2023-03-01'
            and wo.store_id = 22
            and
                (
                    wo.status in (1,2)
                    or (wo.status in (3,4) and wo.latest_reply_at >= '2023-02-28 18:00:00')
                )
        group by 1,2
    ) zl on zl.month_d = t1.month_d and zl.cg_name = t1.cg_name
left join
    (
        select
            t.month_d
            ,t.cg_name
            ,count(distinct t.pnos) repeat_num
        from
            (
                select
                    wo.id
                    ,cg.name cg_name
                    ,wo.pnos
                    ,month(date_add(wo.created_at, interval 6 hour))  month_d
                    ,count(wo.id) over (partition by month(date_add(wo.created_at, interval 6 hour)),wo.pnos) pno_count
                from bi_pro.work_order wo
                left join fle_staging.sys_store ss on ss.id = wo.created_store_id
                left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
                join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','KAM TH','KAM CN')
                where
                    wo.created_at > '2022-11-30 18:00:00'
                    and wo.created_at < '2023-02-28 18:00:00'
                    and wo.store_id = 22
                    and ss.id is not null
            ) t
        where
            t.pno_count >= 2
        group by 1,2
    ) cf on cf.month_d = t1.month_d and cf.cg_name = t1.cg_name;
;-- -. . -..- - / . -. - .-. -.--
select
    t1.month_d 月份
    ,t1.cg_name 项目组
    ,t1.should_deal 应处理工单数
    ,t2.already_deal 完结工单数
    ,t1.not_already_deal 应处理工单当月未完成单数
    ,t1.deal_rate 当月工单完结率
    ,zl.zl_num 滞留工单单数
    ,t2.deal_avg_time 完结工单单均处理时长
    ,cf.repeat_num 工单重复包裹数
from
    ( -- 当月产生
         select
             month(date_add(wo.created_at, interval 6 hour))  month_d
             ,cg.name cg_name
             ,count(distinct wo.id) should_deal
             ,count(distinct if(wo.status in (1, 2) or (wo.status in (3, 4) and wo.latest_reply_at >= adddate(last_day(date_add(wo.created_at, interval 6 hour)), 1) +interval 18 hour), wo.id,  null)) not_already_deal
             ,count(distinct if(wo.status in (3, 4) and wo.latest_reply_at <= adddate(last_day(date_add(wo.created_at, interval 6 hour)), 1) + interval 18 hour)) / count(distinct wo.id) deal_rate
         from bi_pro.work_order wo
         left join fle_staging.sys_store ss on ss.id = wo.created_store_id
         left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
         join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','KAM TH','KAM CN')
         where
            wo.created_at > '2022-11-30 18:00:00'
            and wo.created_at < '2023-02-28 18:00:00'
            and wo.store_id = 22
            and ss.id is not null
         group by 1,2
    ) t1
left join
     (-- 当月完结，已回复和已关闭的工单按照最后一次回复时间认定为结束时间
         select
             month(wo.latest_reply_at) month_d
            ,,cg.name cg_name
            ,count(distinct wo.id)  already_deal
            ,sum(timestampdiff(second, wo.created_at, wo.latest_reply_at) / 3600) /count(distinct wo.id) deal_avg_time
         from bi_pro.work_order wo
         left join fle_staging.sys_store ss on ss.id = wo.created_store_id
         left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
         join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','KAM TH','KAM CN')
         where wo.latest_reply_at >= '2022-12-01 00:00:00'
            and wo.latest_reply_at < '2023-03-01 00:00:00'
            and wo.store_id = 22
            and ss.id is not null
            and wo.status in (3, 4)
         group by 1,2
    ) t2 on t2.month_d = t1.month_d and t2.cg_name = t1.cg_name
left join
    (
        select
            '12' month_d
            ,cg.name cg_name
            ,count(distinct wo.id) zl_num
        from bi_pro.work_order wo
        left join fle_staging.sys_store ss on ss.id = wo.created_store_id
        left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
        join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','KAM TH','KAM CN')
        where
            ss.id is not null
            and wo.created_at >= '2022-01-01'
            and wo.created_at < '2023-01-01'
            and wo.store_id = 22
            and
                (
                    wo.status in (1,2)
                    or (wo.status in (3,4) and wo.latest_reply_at >= '2022-12-31 18:00:00')
                )
        group by 1,2

        union all

        select
            '1' month_d
            ,cg.name cg_name
            ,count(distinct wo.id) zl_num
        from bi_pro.work_order wo
        left join fle_staging.sys_store ss on ss.id = wo.created_store_id
        left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
        join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','KAM TH','KAM CN')
        where
            ss.id is not null
            and wo.created_at >= '2022-01-01'
            and wo.created_at < '2023-02-01'
            and wo.store_id = 22
            and
                (
                    wo.status in (1,2)
                    or (wo.status in (3,4) and wo.latest_reply_at >= '2023-01-31 18:00:00')
                )
        group by 1,2

        union all

        select
            '2' month_d
            ,cg.name cg_name
            ,count(distinct wo.id) zl_num
        from bi_pro.work_order wo
        left join fle_staging.sys_store ss on ss.id = wo.created_store_id
        left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
        join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','KAM TH','KAM CN')
        where
            ss.id is not null
            and wo.created_at >= '2022-01-01'
            and wo.created_at < '2023-03-01'
            and wo.store_id = 22
            and
                (
                    wo.status in (1,2)
                    or (wo.status in (3,4) and wo.latest_reply_at >= '2023-02-28 18:00:00')
                )
        group by 1,2
    ) zl on zl.month_d = t1.month_d and zl.cg_name = t1.cg_name
left join
    (
        select
            t.month_d
            ,t.cg_name
            ,count(distinct t.pnos) repeat_num
        from
            (
                select
                    wo.id
                    ,cg.name cg_name
                    ,wo.pnos
                    ,month(date_add(wo.created_at, interval 6 hour))  month_d
                    ,count(wo.id) over (partition by month(date_add(wo.created_at, interval 6 hour)),wo.pnos) pno_count
                from bi_pro.work_order wo
                left join fle_staging.sys_store ss on ss.id = wo.created_store_id
                left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
                join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','KAM TH','KAM CN')
                where
                    wo.created_at > '2022-11-30 18:00:00'
                    and wo.created_at < '2023-02-28 18:00:00'
                    and wo.store_id = 22
                    and ss.id is not null
            ) t
        where
            t.pno_count >= 2
        group by 1,2
    ) cf on cf.month_d = t1.month_d and cf.cg_name = t1.cg_name;
;-- -. . -..- - / . -. - .-. -.--
select
             month(date_add(wo.created_at, interval 6 hour))  month_d
             ,cg.name cg_name
             ,count(distinct wo.id) should_deal
             ,count(distinct if(wo.status in (1, 2) or (wo.status in (3, 4) and wo.latest_reply_at >= date_add(adddate(last_day(date_add(wo.created_at, interval 6 hour)), 1), interval 18 hour)), wo.id,  null)) not_already_deal
             ,count(distinct if(wo.status in (3, 4) and wo.latest_reply_at <= date_add(adddate(last_day(date_add(wo.created_at, interval 6 hour)), 1), interval 18 hour), wo.id, null)) / count(distinct wo.id) deal_rate
         from bi_pro.work_order wo
         left join fle_staging.sys_store ss on ss.id = wo.created_store_id
         left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
         join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','KAM TH','KAM CN')
         where
            wo.created_at > '2022-11-30 18:00:00'
            and wo.created_at < '2023-02-28 18:00:00'
            and wo.store_id = 22
            and ss.id is not null
         group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    t1.month_d 月份
    ,t1.cg_name 项目组
    ,t1.should_deal 应处理工单数
    ,t2.already_deal 完结工单数
    ,t1.not_already_deal 应处理工单当月未完成单数
    ,t1.deal_rate 当月工单完结率
    ,zl.zl_num 滞留工单单数
    ,t2.deal_avg_time 完结工单单均处理时长
    ,cf.repeat_num 工单重复包裹数
from
    ( -- 当月产生
         select
             month(date_add(wo.created_at, interval 6 hour))  month_d
             ,cg.name cg_name
             ,count(distinct wo.id) should_deal
             ,count(distinct if(wo.status in (1, 2) or (wo.status in (3, 4) and wo.latest_reply_at >= date_add(adddate(last_day(date_add(wo.created_at, interval 6 hour)), 1), interval 18 hour)), wo.id,  null)) not_already_deal
             ,count(distinct if(wo.status in (3, 4) and wo.latest_reply_at <= date_add(adddate(last_day(date_add(wo.created_at, interval 6 hour)), 1), interval 18 hour), wo.id, null)) / count(distinct wo.id) deal_rate
         from bi_pro.work_order wo
         left join fle_staging.sys_store ss on ss.id = wo.created_store_id
         left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
         join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','KAM TH','KAM CN')
         where
            wo.created_at > '2022-11-30 18:00:00'
            and wo.created_at < '2023-02-28 18:00:00'
            and wo.store_id = 22
            and ss.id is not null
         group by 1,2
    ) t1
left join
     (-- 当月完结，已回复和已关闭的工单按照最后一次回复时间认定为结束时间
         select
             month(wo.latest_reply_at) month_d
            ,,cg.name cg_name
            ,count(distinct wo.id)  already_deal
            ,sum(timestampdiff(second, wo.created_at, wo.latest_reply_at) / 3600) /count(distinct wo.id) deal_avg_time
         from bi_pro.work_order wo
         left join fle_staging.sys_store ss on ss.id = wo.created_store_id
         left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
         join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','KAM TH','KAM CN')
         where wo.latest_reply_at >= '2022-12-01 00:00:00'
            and wo.latest_reply_at < '2023-03-01 00:00:00'
            and wo.store_id = 22
            and ss.id is not null
            and wo.status in (3, 4)
         group by 1,2
    ) t2 on t2.month_d = t1.month_d and t2.cg_name = t1.cg_name
left join
    (
        select
            '12' month_d
            ,cg.name cg_name
            ,count(distinct wo.id) zl_num
        from bi_pro.work_order wo
        left join fle_staging.sys_store ss on ss.id = wo.created_store_id
        left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
        join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','KAM TH','KAM CN')
        where
            ss.id is not null
            and wo.created_at >= '2022-01-01'
            and wo.created_at < '2023-01-01'
            and wo.store_id = 22
            and
                (
                    wo.status in (1,2)
                    or (wo.status in (3,4) and wo.latest_reply_at >= '2022-12-31 18:00:00')
                )
        group by 1,2

        union all

        select
            '1' month_d
            ,cg.name cg_name
            ,count(distinct wo.id) zl_num
        from bi_pro.work_order wo
        left join fle_staging.sys_store ss on ss.id = wo.created_store_id
        left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
        join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','KAM TH','KAM CN')
        where
            ss.id is not null
            and wo.created_at >= '2022-01-01'
            and wo.created_at < '2023-02-01'
            and wo.store_id = 22
            and
                (
                    wo.status in (1,2)
                    or (wo.status in (3,4) and wo.latest_reply_at >= '2023-01-31 18:00:00')
                )
        group by 1,2

        union all

        select
            '2' month_d
            ,cg.name cg_name
            ,count(distinct wo.id) zl_num
        from bi_pro.work_order wo
        left join fle_staging.sys_store ss on ss.id = wo.created_store_id
        left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
        join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','KAM TH','KAM CN')
        where
            ss.id is not null
            and wo.created_at >= '2022-01-01'
            and wo.created_at < '2023-03-01'
            and wo.store_id = 22
            and
                (
                    wo.status in (1,2)
                    or (wo.status in (3,4) and wo.latest_reply_at >= '2023-02-28 18:00:00')
                )
        group by 1,2
    ) zl on zl.month_d = t1.month_d and zl.cg_name = t1.cg_name
left join
    (
        select
            t.month_d
            ,t.cg_name
            ,count(distinct t.pnos) repeat_num
        from
            (
                select
                    wo.id
                    ,cg.name cg_name
                    ,wo.pnos
                    ,month(date_add(wo.created_at, interval 6 hour))  month_d
                    ,count(wo.id) over (partition by month(date_add(wo.created_at, interval 6 hour)),wo.pnos) pno_count
                from bi_pro.work_order wo
                left join fle_staging.sys_store ss on ss.id = wo.created_store_id
                left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
                join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','KAM TH','KAM CN')
                where
                    wo.created_at > '2022-11-30 18:00:00'
                    and wo.created_at < '2023-02-28 18:00:00'
                    and wo.store_id = 22
                    and ss.id is not null
            ) t
        where
            t.pno_count >= 2
        group by 1,2
    ) cf on cf.month_d = t1.month_d and cf.cg_name = t1.cg_name;
;-- -. . -..- - / . -. - .-. -.--
select
             month(wo.latest_reply_at) month_d
            ,,cg.name cg_name
            ,count(distinct wo.id)  already_deal
            ,sum(timestampdiff(second, wo.created_at, wo.latest_reply_at) / 3600) /count(distinct wo.id) deal_avg_time
         from bi_pro.work_order wo
         left join fle_staging.sys_store ss on ss.id = wo.created_store_id
         left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
         join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','KAM TH','KAM CN')
         where wo.latest_reply_at >= '2022-12-01 00:00:00'
            and wo.latest_reply_at < '2023-03-01 00:00:00'
            and wo.store_id = 22
            and ss.id is not null
            and wo.status in (3, 4)
         group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
             month(wo.latest_reply_at) month_d
            ,cg.name cg_name
            ,count(distinct wo.id)  already_deal
            ,sum(timestampdiff(second, wo.created_at, wo.latest_reply_at) / 3600) /count(distinct wo.id) deal_avg_time
         from bi_pro.work_order wo
         left join fle_staging.sys_store ss on ss.id = wo.created_store_id
         left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
         join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','KAM TH','KAM CN')
         where wo.latest_reply_at >= '2022-12-01 00:00:00'
            and wo.latest_reply_at < '2023-03-01 00:00:00'
            and wo.store_id = 22
            and ss.id is not null
            and wo.status in (3, 4)
         group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
            t.month_d
            ,t.cg_name
            ,count(distinct t.pnos) repeat_num
        from
            (
                select
                    wo.id
                    ,cg.name cg_name
                    ,wo.pnos
                    ,month(date_add(wo.created_at, interval 6 hour))  month_d
                    ,count(wo.id) over (partition by month(date_add(wo.created_at, interval 6 hour)),wo.pnos) pno_count
                from bi_pro.work_order wo
                left join fle_staging.sys_store ss on ss.id = wo.created_store_id
                left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
                join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','KAM TH','KAM CN')
                where
                    wo.created_at > '2022-11-30 18:00:00'
                    and wo.created_at < '2023-02-28 18:00:00'
                    and wo.store_id = 22
                    and ss.id is not null
            ) t
        where
            t.pno_count >= 2
        group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    t1.month_d 月份
    ,t1.cg_name 项目组
    ,t1.should_deal 应处理工单数
    ,t2.already_deal 完结工单数
    ,t1.not_already_deal 应处理工单当月未完成单数
    ,t1.deal_rate 当月工单完结率
    ,zl.zl_num 滞留工单单数
    ,t2.deal_avg_time 完结工单单均处理时长
    ,cf.repeat_num 工单重复包裹数
from
    ( -- 当月产生
         select
             month(date_add(wo.created_at, interval 6 hour))  month_d
             ,cg.name cg_name
             ,count(distinct wo.id) should_deal
             ,count(distinct if(wo.status in (1, 2) or (wo.status in (3, 4) and wo.latest_reply_at >= date_add(adddate(last_day(date_add(wo.created_at, interval 6 hour)), 1), interval 18 hour)), wo.id,  null)) not_already_deal
             ,count(distinct if(wo.status in (3, 4) and wo.latest_reply_at <= date_add(adddate(last_day(date_add(wo.created_at, interval 6 hour)), 1), interval 18 hour), wo.id, null)) / count(distinct wo.id) deal_rate
         from bi_pro.work_order wo
         left join fle_staging.sys_store ss on ss.id = wo.created_store_id
         left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
         join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','KAM TH','KAM CN')
         where
            wo.created_at > '2022-11-30 18:00:00'
            and wo.created_at < '2023-02-28 18:00:00'
            and wo.store_id = 22
            and ss.id is not null
         group by 1,2
    ) t1
left join
     (-- 当月完结，已回复和已关闭的工单按照最后一次回复时间认定为结束时间
         select
             month(wo.latest_reply_at) month_d
            ,cg.name cg_name
            ,count(distinct wo.id)  already_deal
            ,sum(timestampdiff(second, wo.created_at, wo.latest_reply_at) / 3600) /count(distinct wo.id) deal_avg_time
         from bi_pro.work_order wo
         left join fle_staging.sys_store ss on ss.id = wo.created_store_id
         left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
         join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','KAM TH','KAM CN')
         where wo.latest_reply_at >= '2022-12-01 00:00:00'
            and wo.latest_reply_at < '2023-03-01 00:00:00'
            and wo.store_id = 22
            and ss.id is not null
            and wo.status in (3, 4)
         group by 1,2
    ) t2 on t2.month_d = t1.month_d and t2.cg_name = t1.cg_name
left join
    (
        select
            '12' month_d
            ,cg.name cg_name
            ,count(distinct wo.id) zl_num
        from bi_pro.work_order wo
        left join fle_staging.sys_store ss on ss.id = wo.created_store_id
        left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
        join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','KAM TH','KAM CN')
        where
            ss.id is not null
            and wo.created_at >= '2022-01-01'
            and wo.created_at < '2023-01-01'
            and wo.store_id = 22
            and
                (
                    wo.status in (1,2)
                    or (wo.status in (3,4) and wo.latest_reply_at >= '2022-12-31 18:00:00')
                )
        group by 1,2

        union all

        select
            '1' month_d
            ,cg.name cg_name
            ,count(distinct wo.id) zl_num
        from bi_pro.work_order wo
        left join fle_staging.sys_store ss on ss.id = wo.created_store_id
        left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
        join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','KAM TH','KAM CN')
        where
            ss.id is not null
            and wo.created_at >= '2022-01-01'
            and wo.created_at < '2023-02-01'
            and wo.store_id = 22
            and
                (
                    wo.status in (1,2)
                    or (wo.status in (3,4) and wo.latest_reply_at >= '2023-01-31 18:00:00')
                )
        group by 1,2

        union all

        select
            '2' month_d
            ,cg.name cg_name
            ,count(distinct wo.id) zl_num
        from bi_pro.work_order wo
        left join fle_staging.sys_store ss on ss.id = wo.created_store_id
        left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
        join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','KAM TH','KAM CN')
        where
            ss.id is not null
            and wo.created_at >= '2022-01-01'
            and wo.created_at < '2023-03-01'
            and wo.store_id = 22
            and
                (
                    wo.status in (1,2)
                    or (wo.status in (3,4) and wo.latest_reply_at >= '2023-02-28 18:00:00')
                )
        group by 1,2
    ) zl on zl.month_d = t1.month_d and zl.cg_name = t1.cg_name
left join
    (
        select
            t.month_d
            ,t.cg_name
            ,count(distinct t.pnos) repeat_num
        from
            (
                select
                    wo.id
                    ,cg.name cg_name
                    ,wo.pnos
                    ,month(date_add(wo.created_at, interval 6 hour))  month_d
                    ,count(wo.id) over (partition by month(date_add(wo.created_at, interval 6 hour)),wo.pnos) pno_count
                from bi_pro.work_order wo
                left join fle_staging.sys_store ss on ss.id = wo.created_store_id
                left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
                join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','KAM TH','KAM CN')
                where
                    wo.created_at > '2022-11-30 18:00:00'
                    and wo.created_at < '2023-02-28 18:00:00'
                    and wo.store_id = 22
                    and ss.id is not null
            ) t
        where
            t.pno_count >= 2
        group by 1,2
    ) cf on cf.month_d = t1.month_d and cf.cg_name = t1.cg_name;
;-- -. . -..- - / . -. - .-. -.--
select
    t1.month_d 月份
    ,t1.cg_name 项目组
    ,t1.should_deal 应处理工单数
    ,t2.already_deal 完结工单数
    ,t1.not_already_deal 应处理工单当月未完成单数
    ,t1.deal_rate 当月工单完结率
    ,zl.zl_num 滞留工单单数
    ,t2.deal_avg_time 完结工单单均处理时长
    ,cf.repeat_num 工单重复包裹数
from
    ( -- 当月产生
         select
             month(date_add(wo.created_at, interval 6 hour))  month_d
             ,cg.name cg_name
             ,count(distinct wo.id) should_deal
             ,count(distinct if(wo.status in (1, 2) or (wo.status in (3, 4) and wo.latest_reply_at >= date_add(adddate(last_day(date_add(wo.created_at, interval 6 hour)), 1), interval 18 hour)), wo.id,  null)) not_already_deal
             ,count(distinct if(wo.status in (3, 4) and wo.latest_reply_at <= date_add(adddate(last_day(date_add(wo.created_at, interval 6 hour)), 1), interval 18 hour), wo.id, null)) / count(distinct wo.id) deal_rate
         from bi_pro.work_order wo
         left join fle_staging.sys_store ss on ss.id = wo.created_store_id
         left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
         join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
         where
            wo.created_at > '2022-11-30 18:00:00'
            and wo.created_at < '2023-02-28 18:00:00'
            and wo.store_id = 22
            and ss.id is not null
         group by 1,2
    ) t1
left join
     (-- 当月完结，已回复和已关闭的工单按照最后一次回复时间认定为结束时间
         select
             month(wo.latest_reply_at) month_d
            ,cg.name cg_name
            ,count(distinct wo.id)  already_deal
            ,sum(timestampdiff(second, wo.created_at, wo.latest_reply_at) / 3600) /count(distinct wo.id) deal_avg_time
         from bi_pro.work_order wo
         left join fle_staging.sys_store ss on ss.id = wo.created_store_id
         left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
         join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
         where wo.latest_reply_at >= '2022-12-01 00:00:00'
            and wo.latest_reply_at < '2023-03-01 00:00:00'
            and wo.store_id = 22
            and ss.id is not null
            and wo.status in (3, 4)
         group by 1,2
    ) t2 on t2.month_d = t1.month_d and t2.cg_name = t1.cg_name
left join
    (
        select
            '12' month_d
            ,cg.name cg_name
            ,count(distinct wo.id) zl_num
        from bi_pro.work_order wo
        left join fle_staging.sys_store ss on ss.id = wo.created_store_id
        left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
        join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
        where
            ss.id is not null
            and wo.created_at >= '2022-01-01'
            and wo.created_at < '2023-01-01'
            and wo.store_id = 22
            and
                (
                    wo.status in (1,2)
                    or (wo.status in (3,4) and wo.latest_reply_at >= '2022-12-31 18:00:00')
                )
        group by 1,2

        union all

        select
            '1' month_d
            ,cg.name cg_name
            ,count(distinct wo.id) zl_num
        from bi_pro.work_order wo
        left join fle_staging.sys_store ss on ss.id = wo.created_store_id
        left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
        join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
        where
            ss.id is not null
            and wo.created_at >= '2022-01-01'
            and wo.created_at < '2023-02-01'
            and wo.store_id = 22
            and
                (
                    wo.status in (1,2)
                    or (wo.status in (3,4) and wo.latest_reply_at >= '2023-01-31 18:00:00')
                )
        group by 1,2

        union all

        select
            '2' month_d
            ,cg.name cg_name
            ,count(distinct wo.id) zl_num
        from bi_pro.work_order wo
        left join fle_staging.sys_store ss on ss.id = wo.created_store_id
        left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
        join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
        where
            ss.id is not null
            and wo.created_at >= '2022-01-01'
            and wo.created_at < '2023-03-01'
            and wo.store_id = 22
            and
                (
                    wo.status in (1,2)
                    or (wo.status in (3,4) and wo.latest_reply_at >= '2023-02-28 18:00:00')
                )
        group by 1,2
    ) zl on zl.month_d = t1.month_d and zl.cg_name = t1.cg_name
left join
    (
        select
            t.month_d
            ,t.cg_name
            ,count(distinct t.pnos) repeat_num
        from
            (
                select
                    wo.id
                    ,cg.name cg_name
                    ,wo.pnos
                    ,month(date_add(wo.created_at, interval 6 hour))  month_d
                    ,count(wo.id) over (partition by month(date_add(wo.created_at, interval 6 hour)),wo.pnos) pno_count
                from bi_pro.work_order wo
                left join fle_staging.sys_store ss on ss.id = wo.created_store_id
                left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
                join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
                where
                    wo.created_at > '2022-11-30 18:00:00'
                    and wo.created_at < '2023-02-28 18:00:00'
                    and wo.store_id = 22
                    and ss.id is not null
            ) t
        where
            t.pno_count >= 2
        group by 1,2
    ) cf on cf.month_d = t1.month_d and cf.cg_name = t1.cg_name;
;-- -. . -..- - / . -. - .-. -.--
select
     month(date_add(wo.created_at, interval 6 hour))  所属月份
     ,cg.name 项目组
#      ,count(distinct wo.id) should_deal
#      ,count(distinct if(wo.status in (1, 2) or (wo.status in (3, 4) and wo.latest_reply_at >= date_add(adddate(last_day(date_add(wo.created_at, interval 6 hour)), 1), interval 18 hour)), wo.id,  null)) not_already_deal
#      ,count(distinct if(wo.status in (3, 4) and wo.latest_reply_at <= date_add(adddate(last_day(date_add(wo.created_at, interval 6 hour)), 1), interval 18 hour), wo.id, null)) / count(distinct wo.id) deal_rate
    ,wo.order_no 工单号
    ,wo.created_at 工单创建时间
    ,wo.latest_reply_at 最后回复时间
    ,case wo.status
        when 1 then '未阅读'
        when 2 then '已经阅读'
        when 3 then '已回复'
        when 4 then '已关闭'
    end 工单状态
 from bi_pro.work_order wo
 left join fle_staging.sys_store ss on ss.id = wo.created_store_id
 left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
 join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
 where
    wo.created_at > '2022-11-28 18:00:00'
    and wo.created_at < '2023-03-01 18:00:00'
    and wo.store_id = 22
    and ss.id is not null;
;-- -. . -..- - / . -. - .-. -.--
select
     month(wo.latest_reply_at) 月份
    ,cg.name 项目组
#     ,count(distinct wo.id)  already_deal
#     ,sum(timestampdiff(second, wo.created_at, wo.latest_reply_at) / 3600) /count(distinct wo.id) deal_avg_time
    ,wo.created_at 工单创建时间
    ,wo.latest_reply_at 工单最后回复时间
    ,case wo.status
        when 1 then '未阅读'
        when 2 then '已经阅读'
        when 3 then '已回复'
        when 4 then '已关闭'
    end 工单状态
from bi_pro.work_order wo
left join fle_staging.sys_store ss on ss.id = wo.created_store_id
left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
where wo.latest_reply_at >= '2022-11-01 00:00:00'
and wo.latest_reply_at < '2023-03-11 00:00:00'
and wo.store_id = 22
and ss.id is not null
and wo.status in (3, 4);
;-- -. . -..- - / . -. - .-. -.--
select
#     cg.name cg_name
#     ,wo.created_at 工单创建时间
#     ,wo.latest_reply_at 工单最后回复时间
#     ,case wo.status
#         when 1 then '未阅读'
#         when 2 then '已经阅读'
#         when 3 then '已回复'
#         when 4 then '已关闭'
#     end 工单状态
count(*)
from bi_pro.work_order wo
left join fle_staging.sys_store ss on ss.id = wo.created_store_id
left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
where
    ss.id is not null
    and wo.created_at >= '2022-01-01'
    and wo.created_at < '2023-03-01'
    and wo.store_id = 22;
;-- -. . -..- - / . -. - .-. -.--
select
    cg.name cg_name
    ,wo.created_at 工单创建时间
    ,wo.latest_reply_at 工单最后回复时间
    ,case wo.status
        when 1 then '未阅读'
        when 2 then '已经阅读'
        when 3 then '已回复'
        when 4 then '已关闭'
    end 工单状态
from bi_pro.work_order wo
left join fle_staging.sys_store ss on ss.id = wo.created_store_id
left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
where
    ss.id is not null
    and wo.created_at >= '2022-01-01'
    and wo.created_at < '2023-03-01'
    and wo.store_id = 22;
;-- -. . -..- - / . -. - .-. -.--
elect
    cg.name cg_name
    ,wo.order_no
    ,wo.client_id
    ,wo.created_at 工单创建时间
    ,wo.latest_reply_at 工单最后回复时间
    ,case wo.status
        when 1 then '未阅读'
        when 2 then '已经阅读'
        when 3 then '已回复'
        when 4 then '已关闭'
    end 工单状态
from bi_pro.work_order wo
left join fle_staging.sys_store ss on ss.id = wo.created_store_id
left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
where
    ss.id is not null
    and wo.created_at >= '2022-01-01'
    and wo.created_at < '2023-03-01'
    and wo.store_id = 22;
;-- -. . -..- - / . -. - .-. -.--
select
    cg.name cg_name
    ,wo.order_no
    ,wo.client_id
    ,wo.created_at 工单创建时间
    ,wo.latest_reply_at 工单最后回复时间
    ,case wo.status
        when 1 then '未阅读'
        when 2 then '已经阅读'
        when 3 then '已回复'
        when 4 then '已关闭'
    end 工单状态
from bi_pro.work_order wo
left join fle_staging.sys_store ss on ss.id = wo.created_store_id
left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
where
    ss.id is not null
    and wo.created_at >= '2022-01-01'
    and wo.created_at < '2023-03-01'
    and wo.store_id = 22;
;-- -. . -..- - / . -. - .-. -.--
select
    cg.name cg_name
    ,wo.order_no
    ,wo.client_id
    ,wo.pnos
    ,wo.created_at 工单创建时间
    ,wo.latest_reply_at 工单最后回复时间
    ,case wo.status
        when 1 then '未阅读'
        when 2 then '已经阅读'
        when 3 then '已回复'
        when 4 then '已关闭'
    end 工单状态
from bi_pro.work_order wo
left join fle_staging.sys_store ss on ss.id = wo.created_store_id
left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
where
    ss.id is not null
    and wo.created_at >= '2022-01-01'
    and wo.created_at < '2023-03-01'
    and wo.store_id = 22;
;-- -. . -..- - / . -. - .-. -.--
select
             month(date_add(wo.created_at, interval 6 hour))  month_d
             ,cg.name cg_name
             ,count(distinct wo.id) should_deal
             ,count(distinct if(wo.status in (1, 2) or (wo.status in (3, 4) and wo.latest_reply_at >= date_add(adddate(last_day(date_add(wo.created_at, interval 6 hour)), 1), interval 18 hour)), wo.id,  null)) not_already_deal
             ,count(distinct if(wo.status in (3, 4) and wo.latest_reply_at < date_add(adddate(last_day(date_add(wo.created_at, interval 6 hour)), 1), interval 18 hour), wo.id, null)) / count(distinct wo.id) deal_rate
         from bi_pro.work_order wo
         left join fle_staging.sys_store ss on ss.id = wo.created_store_id
         left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
         join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
         where
            wo.created_at > '2022-11-30 18:00:00'
            and wo.created_at < '2023-02-28 18:00:00'
            and wo.store_id = 22
            and ss.id is not null
         group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
             month(date_add(wo.created_at, interval 6 hour))  month_d
             ,cg.name cg_name
             ,count(distinct wo.id) should_deal
             ,count(distinct if(wo.status in (1, 2) or (wo.status in (3, 4) and wo.latest_reply_at >= date_add(adddate(last_day(date_add(wo.created_at, interval 6 hour)), 1), interval 18 hour)), wo.id,  null)) not_already_deal
             ,count(distinct if(wo.status in (3, 4) and wo.latest_reply_at < date_add(adddate(last_day(date_add(wo.created_at, interval 6 hour)), 1), interval 18 hour), wo.id, null)) / count(distinct wo.id) deal_rate
             ,count(distinct if(wo.status in (3, 4) and wo.latest_reply_at < date_add(adddate(last_day(date_add(wo.created_at, interval 6 hour)), 1), interval 18 hour), wo.id, null)) dealnum
         from bi_pro.work_order wo
         left join fle_staging.sys_store ss on ss.id = wo.created_store_id
         left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
         join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
         where
            wo.created_at > '2022-11-30 18:00:00'
            and wo.created_at < '2023-02-28 18:00:00'
            and wo.store_id = 22
            and ss.id is not null
         group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
     month(date_add(wo.created_at, interval 6 hour))  month_d
     ,cg.name cg_name
#      ,count(distinct wo.id) should_deal
#      ,count(distinct if(wo.status in (1, 2) or (wo.status in (3, 4) and wo.latest_reply_at >= date_add(adddate(last_day(date_add(wo.created_at, interval 6 hour)), 1), interval 18 hour)), wo.id,  null)) not_already_deal
#      ,count(distinct if(wo.status in (3, 4) and wo.latest_reply_at < date_add(adddate(last_day(date_add(wo.created_at, interval 6 hour)), 1), interval 18 hour), wo.id, null)) / count(distinct wo.id) deal_rate
#      ,count(distinct if(wo.status in (3, 4) and wo.latest_reply_at < date_add(adddate(last_day(date_add(wo.created_at, interval 6 hour)), 1), interval 18 hour), wo.id, null)) dealnum
    ,wo.id
    ,if(wo.status in (1, 2) or (wo.status in (3, 4) and wo.latest_reply_at >= date_add(adddate(last_day(date_add(wo.created_at, interval 6 hour)), 1), interval 18 hour)), 1,  null) not_already_deal
    ,if(wo.status in (3, 4) and wo.latest_reply_at < date_add(adddate(last_day(date_add(wo.created_at, interval 6 hour)), 1), interval 18 hour), 1, null) dealnum
 from bi_pro.work_order wo
 left join fle_staging.sys_store ss on ss.id = wo.created_store_id
 left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
 join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
 where
    wo.created_at > '2022-11-30 18:00:00'
    and wo.created_at < '2023-02-28 18:00:00'
    and wo.store_id = 22
    and ss.id is not null
    and cg.name = 'Shopee'
    and month(date_add(wo.created_at, interval 6 hour)) = 2;
;-- -. . -..- - / . -. - .-. -.--
select
     month(date_add(wo.created_at, interval 6 hour))  month_d
     ,cg.name cg_name
#      ,count(distinct wo.id) should_deal
#      ,count(distinct if(wo.status in (1, 2) or (wo.status in (3, 4) and wo.latest_reply_at >= date_add(adddate(last_day(date_add(wo.created_at, interval 6 hour)), 1), interval 18 hour)), wo.id,  null)) not_already_deal
#      ,count(distinct if(wo.status in (3, 4) and wo.latest_reply_at < date_add(adddate(last_day(date_add(wo.created_at, interval 6 hour)), 1), interval 18 hour), wo.id, null)) / count(distinct wo.id) deal_rate
#      ,count(distinct if(wo.status in (3, 4) and wo.latest_reply_at < date_add(adddate(last_day(date_add(wo.created_at, interval 6 hour)), 1), interval 18 hour), wo.id, null)) dealnum
    ,wo.id
    ,wo.status
    ,wo.created_at
    ,wo.latest_reply_at
    ,if(wo.status in (1, 2) or (wo.status in (3, 4) and wo.latest_reply_at >= date_add(adddate(last_day(date_add(wo.created_at, interval 6 hour)), 1), interval 18 hour)), 1,  null) not_already_deal
    ,if(wo.status in (3, 4) and wo.latest_reply_at < date_add(adddate(last_day(date_add(wo.created_at, interval 6 hour)), 1), interval 18 hour), 1, null) dealnum
 from bi_pro.work_order wo
 left join fle_staging.sys_store ss on ss.id = wo.created_store_id
 left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
 join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
 where
    wo.created_at > '2022-11-30 18:00:00'
    and wo.created_at < '2023-02-28 18:00:00'
    and wo.store_id = 22
    and ss.id is not null
    and cg.name = 'Shopee'
    and month(date_add(wo.created_at, interval 6 hour)) = 2;
;-- -. . -..- - / . -. - .-. -.--
select
     month(date_add(wo.created_at, interval 6 hour))  month_d
     ,cg.name cg_name
#      ,count(distinct wo.id) should_deal
#      ,count(distinct if(wo.status in (1, 2) or (wo.status in (3, 4) and wo.latest_reply_at >= date_add(adddate(last_day(date_add(wo.created_at, interval 6 hour)), 1), interval 18 hour)), wo.id,  null)) not_already_deal
#      ,count(distinct if(wo.status in (3, 4) and wo.latest_reply_at < date_add(adddate(last_day(date_add(wo.created_at, interval 6 hour)), 1), interval 18 hour), wo.id, null)) / count(distinct wo.id) deal_rate
#      ,count(distinct if(wo.status in (3, 4) and wo.latest_reply_at < date_add(adddate(last_day(date_add(wo.created_at, interval 6 hour)), 1), interval 18 hour), wo.id, null)) dealnum
    ,wo.id
    ,wo.status
    ,wo.created_at
    ,wo.order_no
    ,wo.latest_reply_at
    ,if(wo.status in (1, 2) or (wo.status in (3, 4) and wo.latest_reply_at >= date_add(adddate(last_day(date_add(wo.created_at, interval 6 hour)), 1), interval 18 hour)), 1,  null) not_already_deal
    ,if(wo.status in (3, 4) and wo.latest_reply_at < date_add(adddate(last_day(date_add(wo.created_at, interval 6 hour)), 1), interval 18 hour), 1, null) dealnum
 from bi_pro.work_order wo
 left join fle_staging.sys_store ss on ss.id = wo.created_store_id
 left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
 join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
 where
    wo.created_at > '2022-11-30 18:00:00'
    and wo.created_at < '2023-02-28 18:00:00'
    and wo.store_id = 22
    and ss.id is not null
    and cg.name = 'Shopee'
    and month(date_add(wo.created_at, interval 6 hour)) = 2;
;-- -. . -..- - / . -. - .-. -.--
select
     month(date_add(wo.created_at, interval 6 hour))  month_d
     ,cg.name cg_name
#      ,count(distinct wo.id) should_deal
#      ,count(distinct if(wo.status in (1, 2) or (wo.status in (3, 4) and wo.latest_reply_at >= date_add(adddate(last_day(date_add(wo.created_at, interval 6 hour)), 1), interval 18 hour)), wo.id,  null)) not_already_deal
#      ,count(distinct if(wo.status in (3, 4) and wo.latest_reply_at < date_add(adddate(last_day(date_add(wo.created_at, interval 6 hour)), 1), interval 18 hour), wo.id, null)) / count(distinct wo.id) deal_rate
#      ,count(distinct if(wo.status in (3, 4) and wo.latest_reply_at < date_add(adddate(last_day(date_add(wo.created_at, interval 6 hour)), 1), interval 18 hour), wo.id, null)) dealnum
    ,wo.id
    ,wo.status
    ,wo.created_at
    ,wo.order_no
    ,wo.pnos
    ,wo.latest_reply_at
    ,if(wo.status in (1, 2) or (wo.status in (3, 4) and wo.latest_reply_at >= date_add(adddate(last_day(date_add(wo.created_at, interval 6 hour)), 1), interval 18 hour)), 1,  null) not_already_deal
    ,if(wo.status in (3, 4) and wo.latest_reply_at < date_add(adddate(last_day(date_add(wo.created_at, interval 6 hour)), 1), interval 18 hour), 1, null) dealnum
 from bi_pro.work_order wo
 left join fle_staging.sys_store ss on ss.id = wo.created_store_id
 left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
 join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
 where
    wo.created_at > '2022-11-30 18:00:00'
    and wo.created_at < '2023-02-28 18:00:00'
    and wo.store_id = 22
    and ss.id is not null
    and cg.name = 'Shopee'
    and month(date_add(wo.created_at, interval 6 hour)) = 2;
;-- -. . -..- - / . -. - .-. -.--
select
            month(date_add(cdt.created_at, interval 13 hour)) month_d
            ,case
                when cdt.client_id = 'AA0416' then 'Lazada Buyer Return'
                when cdt.client_id in ('AA0707','AA0657','AA0606') then 'Shopee Buyer Return'
                when cdt.client_id in ('AA0649','AA0650') then 'Shein Buyer Return'
                else cg.name
            end 项目组
            ,di.id
            ,pi.cod_enabled
#             ,count(distinct cdt.id ) should_deal
#             ,count(distinct if(di.state = 0 or ( di.state = 1 and di.updated_at > date_add(adddate(last_day(date_add(cdt.created_at, interval 6 hour)), 1),interval 11 hour)), cdt.id, null))  should_not
#             ,count(distinct if(di.diff_marker_category in (5,6,20,21), cdt.id, null))/count(distinct cdt.id ) dam_short_ratio
        from fle_staging.customer_diff_ticket cdt
        join fle_staging.customer_group cg on cdt.group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
        left join fle_staging.diff_info di on di.id = cdt.diff_info_id
        left join fle_staging.parcel_info pi on pi.pno = di.pno
        where
            di.diff_marker_category not in (7,22)
            and cdt.created_at >= '2022-11-30 11:00:00'
            and cdt.created_at < '2023-02-28 11:00:00';
;-- -. . -..- - / . -. - .-. -.--
select
            month(date_add(cdt.created_at, interval 13 hour)) month_d
            ,case
                when cdt.client_id = 'AA0416' then 'Lazada Buyer Return'
                when cdt.client_id in ('AA0707','AA0657','AA0606') then 'Shopee Buyer Return'
                when cdt.client_id in ('AA0649','AA0650') then 'Shein Buyer Return'
                else cg.name
            end 项目组
            ,di.id
            ,pi.cod_enabled
#             ,count(distinct cdt.id ) should_deal
#             ,count(distinct if(di.state = 0 or ( di.state = 1 and di.updated_at > date_add(adddate(last_day(date_add(cdt.created_at, interval 6 hour)), 1),interval 11 hour)), cdt.id, null))  should_not
#             ,count(distinct if(di.diff_marker_category in (5,6,20,21), cdt.id, null))/count(distinct cdt.id ) dam_short_ratio
        from fle_staging.customer_diff_ticket cdt
        join fle_staging.customer_group cg on cdt.group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
        left join fle_staging.diff_info di on di.id = cdt.diff_info_id
        left join fle_staging.parcel_info pi on pi.pno = di.pno
        where
            di.diff_marker_category not in (7,22)
            and cdt.created_at >= '2022-11-30 11:00:00'
            and cdt.created_at < '2023-02-28 11:00:00'
            and pi.cod_enabled is null;
;-- -. . -..- - / . -. - .-. -.--
select
    dr.route_action
    ,count(dr.id) num
from fle_staging.diff_route dr
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    dr.route_action
    ,count(dr.id) num
from fle_staging.diff_route dr
left join fle_staging.diff_info di on di.id = dr.diff_info_id
where
    di.state = 1
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    cdt.state
    ,count(cdt.id)
from fle_staging.customer_diff_ticket cdt
where
    cdt.first_operated_at is not null;
;-- -. . -..- - / . -. - .-. -.--
select
    t1.month_d 月份
    ,t1.cg_name 项目组
    ,t1.should_deal '应处理问题件数(剔除lost)'
    ,t2.deal_num 完结问题件数
    ,t1.should_not 应处理问题件数当月未完成
    ,t1.month_deal_ratio 当月问题件完结率
    ,zl.zl_num 滞留问题件单数
    ,t1.dam_short_ratio 破损短少问题件占比
    ,t1.cod_ratio COD金额问题件占比
    ,t1.other_ratio 其他问题件占比
    ,t2.avg_deal_time 完结问题件单均处理时长
    ,t2.dam_short_avg_time 破损短少问题件单均完结时长
    ,t2.cod_avg_time COD金额问题件单均完结时长
    ,t2.other_avg_time 其他问题件单均完结时长
    ,t1.jiedan_avg_time '问题件单均接单时长'
    ,t1.fin_avg_time '问题件单均接单-结单时长'
    ,cf.repeat_num 问题件重复包裹数
from
    ( -- 应处理
        select
            month(date_add(cdt.created_at, interval 13 hour)) month_d
            ,case
                when cdt.client_id = 'AA0416' then 'Lazada Buyer Return'
                when cdt.client_id in ('AA0707','AA0657','AA0606') then 'Shopee Buyer Return'
                when cdt.client_id in ('AA0649','AA0650') then 'Shein Buyer Return'
                else cg.name
            end cg_name
            ,count(distinct cdt.id ) should_deal
            ,count(distinct if(di.state != 1 or ( di.state = 1 and di.updated_at > date_add(adddate(last_day(date_add(cdt.created_at, interval 6 hour)), 1),interval 11 hour)), cdt.id, null))  should_not
            ,count(distinct if(di.state = 1 and date_add(adddate(last_day(date_add(cdt.created_at, interval 6 hour)), 1),interval 11 hour), cdt.id, null))/count(distinct cdt.id ) month_deal_ratio
            ,count(distinct if(di.diff_marker_category in (5,6,20,21), cdt.id, null))/count(distinct cdt.id ) dam_short_ratio
            ,count(distinct if(pi.cod_enabled = 1, cdt.id, null))/count(distinct cdt.id) cod_ratio
            ,count(distinct if(pi.cod_enabled = 0 and di.diff_marker_category not in (5,6,20,21), cdt.id, null))/count(distinct cdt.id ) other_ratio
            ,sum(if(cdt.state != 0, timestampdiff(second , cdt.created_at, cdt.first_operated_at)/3600, 0 ))/count(distinct if(cdt.state != 0 ,cdt.id, null)) jiedan_avg_time
            ,sum(if(cdt.state = 1, timestampdiff(second ,cdt.first_operated_at, cdt.updated_at)/3600, 0 )) fin_avg_time
        from fle_staging.customer_diff_ticket cdt
        join fle_staging.customer_group cg on cdt.group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
        left join fle_staging.diff_info di on di.id = cdt.diff_info_id
        left join fle_staging.parcel_info pi on pi.pno = di.pno
        where
            di.diff_marker_category not in (7,22)
            and cdt.created_at >= '2022-11-30 11:00:00'
            and cdt.created_at < '2023-02-28 11:00:00'
        group by 1,2
    ) t1
left join
    ( -- 已完结
        select
            month(date_add(cdt.created_at, interval 7 hour)) month_d
            ,case
                when cdt.client_id = 'AA0416' then 'Lazada Buyer Return'
                when cdt.client_id in ('AA0707','AA0657','AA0606') then 'Shopee Buyer Return'
                when cdt.client_id in ('AA0649','AA0650') then 'Shein Buyer Return'
                else cg.name
            end cg_name
            ,count(distinct cdt.id ) deal_num
            ,sum(timestampdiff(second, cdt.created_at, cdt.updated_at)/3600)/count(distinct cdt.id) avg_deal_time
            ,sum(if(di.diff_marker_category in (5,6,20,21), timestampdiff(second, cdt.created_at, cdt.updated_at)/3600, 0))/count(distinct if(di.diff_marker_category in (5,6,20,21), cdt.id, null)) dam_short_avg_time
            ,sum(if(pi.cod_enabled = 1, timestampdiff(second, cdt.created_at, cdt.updated_at)/3600, 0))/count(distinct if(pi.cod_enabled = 1, cdt.id, null)) cod_avg_time
            ,sum(if(pi.cod_enabled = 0 and di.diff_marker_category not in (5,6,20,21), timestampdiff(second, cdt.created_at, cdt.updated_at)/3600, 0))/count(distinct if(pi.cod_enabled = 0 and di.diff_marker_category not in (5,6,20,21), cdt.id, null))  other_avg_time
        from fle_staging.customer_diff_ticket cdt
        left join fle_staging.diff_info di on di.id = cdt.diff_info_id
        join fle_staging.customer_group cg on cdt.group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
        left join fle_staging.parcel_info pi on pi.pno = di.pno
        where
            di.diff_marker_category not in (7,22)
            and cdt.updated_at >= '2022-12-31 17:00:00'
            and cdt.updated_at < '2023-02-28 17:00:00'
            and di.state = 1 -- 已处理
    ) t2 on t2.month_d = t1.month_d and t2.cg_name = t1.cg_name
left join
    ( -- 滞留
        select
            '12' month_d
            ,case
                when cdt.client_id = 'AA0416' then 'Lazada Buyer Return'
                when cdt.client_id in ('AA0707','AA0657','AA0606') then 'Shopee Buyer Return'
                when cdt.client_id in ('AA0649','AA0650') then 'Shein Buyer Return'
                else cg.name
            end cg_name
            ,count(distinct cdt.id) zl_num
        from fle_staging.customer_diff_ticket cdt
        left join fle_staging.diff_info di on di.id = cdt.diff_info_id
        join fle_staging.customer_group cg on cdt.group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
        where
            di.diff_marker_category not in (7,22)
            and cdt.created_at >= '2021-12-31 17:00:00'
            and cdt.created_at < '2022-12-31 11:00:00'  -- 18点之前产生
            and
                (
                    di.state != 1 or
                    (di.state = 1 and di.updated_at > '2022-12-31 17:00:00')
                )
        group by 1,2

        union all

        select
            '1' month_d
            ,case
                when cdt.client_id = 'AA0416' then 'Lazada Buyer Return'
                when cdt.client_id in ('AA0707','AA0657','AA0606') then 'Shopee Buyer Return'
                when cdt.client_id in ('AA0649','AA0650') then 'Shein Buyer Return'
                else cg.name
            end cg_name
            ,count(distinct cdt.id) zl_num
        from fle_staging.customer_diff_ticket cdt
        left join fle_staging.diff_info di on di.id = cdt.diff_info_id
        join fle_staging.customer_group cg on cdt.group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
        where
            di.diff_marker_category not in (7,22)
            and cdt.created_at >= '2021-12-31 17:00:00'
            and cdt.created_at < '2023-01-31 11:00:00'  -- 18点之前产生
            and
                (
                    di.state != 1 or
                    (di.state = 1 and di.updated_at > '2023-01-31 11:00:00')
                )
        group by 1,2

        union all

        select
            '2' month_d
            ,case
                when cdt.client_id = 'AA0416' then 'Lazada Buyer Return'
                when cdt.client_id in ('AA0707','AA0657','AA0606') then 'Shopee Buyer Return'
                when cdt.client_id in ('AA0649','AA0650') then 'Shein Buyer Return'
                else cg.name
            end cg_name
            ,count(distinct cdt.id) zl_num
        from fle_staging.customer_diff_ticket cdt
        left join fle_staging.diff_info di on di.id = cdt.diff_info_id
        join fle_staging.customer_group cg on cdt.group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
        where
            di.diff_marker_category not in (7,22)
            and cdt.created_at >= '2021-12-31 17:00:00'
            and cdt.created_at < '2023-02-28 11:00:00' -- 18点之前产生
            and
                (
                    di.state != 1 or
                    (di.state = 1 and di.updated_at > '2023-02-28 17:00:00')
                )
        group by 1,2
    ) zl  on zl.month_d = t1.month_d and zl.cg_name = t1.cg_name
left join
    (
        select
            t.cg_name
            ,t.month_d
            ,count(distinct t.pno) repeat_num
        from
            (
                select
                    cdt.id
                    ,month(date_add(cdt.created_at, interval 13 hour)) month_d
                    ,case
                        when cdt.client_id = 'AA0416' then 'Lazada Buyer Return'
                        when cdt.client_id in ('AA0707','AA0657','AA0606') then 'Shopee Buyer Return'
                        when cdt.client_id in ('AA0649','AA0650') then 'Shein Buyer Return'
                        else cg.name
                    end cg_name
                    ,di.pno
                    ,count(cdt.id) over (partition by month(date_add(cdt.created_at, interval 13 hour)), di.pno) pno_count
                from fle_staging.customer_diff_ticket cdt
                left join fle_staging.diff_info di on di.id = cdt.diff_info_id
                join fle_staging.customer_group cg on cdt.group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
                where
                    di.diff_marker_category not in (7,22)
                    and cdt.created_at >= '2022-11-30 11:00:00'
                    and cdt.created_at < '2023-02-28 11:00:00'
            ) t
        where
            t.pno_count >= 2
        group by 1,2
    ) cf on cf.month_d = t1.month_d and cf.cg_name = t1.cg_name;
;-- -. . -..- - / . -. - .-. -.--
select
            month(date_add(cdt.created_at, interval 13 hour)) month_d
            ,case
                when cdt.client_id = 'AA0416' then 'Lazada Buyer Return'
                when cdt.client_id in ('AA0707','AA0657','AA0606') then 'Shopee Buyer Return'
                when cdt.client_id in ('AA0649','AA0650') then 'Shein Buyer Return'
                else cg.name
            end cg_name
            ,count(distinct cdt.id ) should_deal
            ,count(distinct if(di.state != 1 or ( di.state = 1 and di.updated_at > date_add(adddate(last_day(date_add(cdt.created_at, interval 6 hour)), 1),interval 11 hour)), cdt.id, null))  should_not
            ,count(distinct if(di.state = 1 and date_add(adddate(last_day(date_add(cdt.created_at, interval 6 hour)), 1),interval 11 hour), cdt.id, null))/count(distinct cdt.id ) month_deal_ratio
            ,count(distinct if(di.diff_marker_category in (5,6,20,21), cdt.id, null))/count(distinct cdt.id ) dam_short_ratio
            ,count(distinct if(pi.cod_enabled = 1, cdt.id, null))/count(distinct cdt.id) cod_ratio
            ,count(distinct if(pi.cod_enabled = 0 and di.diff_marker_category not in (5,6,20,21), cdt.id, null))/count(distinct cdt.id ) other_ratio
            ,sum(if(cdt.state != 0, timestampdiff(second , cdt.created_at, cdt.first_operated_at)/3600, 0 ))/count(distinct if(cdt.state != 0 ,cdt.id, null)) jiedan_avg_time
            ,sum(if(cdt.state = 1, timestampdiff(second ,cdt.first_operated_at, cdt.updated_at)/3600, 0 )) fin_avg_time
        from fle_staging.customer_diff_ticket cdt
        join fle_staging.customer_group cg on cdt.group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
        left join fle_staging.diff_info di on di.id = cdt.diff_info_id
        left join fle_staging.parcel_info pi on pi.pno = di.pno
        where
            di.diff_marker_category not in (7,22)
            and cdt.created_at >= '2022-11-30 11:00:00'
            and cdt.created_at < '2023-02-28 11:00:00'
        group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
            month(date_add(cdt.created_at, interval 13 hour)) month_d
            ,case
                when cdt.client_id = 'AA0416' then 'Lazada Buyer Return'
                when cdt.client_id in ('AA0707','AA0657','AA0606') then 'Shopee Buyer Return'
                when cdt.client_id in ('AA0649','AA0650') then 'Shein Buyer Return'
                else cg.name
            end cg_name
            ,count(distinct cdt.id ) should_deal
            ,count(distinct if(di.state != 1 or ( di.state = 1 and di.updated_at > date_add(adddate(last_day(date_add(cdt.created_at, interval 6 hour)), 1),interval 11 hour)), cdt.id, null))  should_not
            ,count(distinct if(di.state = 1 and di.updated_at < date_add(adddate(last_day(date_add(cdt.created_at, interval 6 hour)), 1),interval 11 hour), cdt.id, null))/count(distinct cdt.id ) month_deal_ratio
            ,count(distinct if(di.diff_marker_category in (5,6,20,21), cdt.id, null))/count(distinct cdt.id ) dam_short_ratio
            ,count(distinct if(pi.cod_enabled = 1, cdt.id, null))/count(distinct cdt.id) cod_ratio
            ,count(distinct if(pi.cod_enabled = 0 and di.diff_marker_category not in (5,6,20,21), cdt.id, null))/count(distinct cdt.id ) other_ratio
            ,sum(if(cdt.state != 0, timestampdiff(second , cdt.created_at, cdt.first_operated_at)/3600, 0 ))/count(distinct if(cdt.state != 0 ,cdt.id, null)) jiedan_avg_time
            ,sum(if(cdt.state = 1, timestampdiff(second ,cdt.first_operated_at, cdt.updated_at)/3600, 0 )) fin_avg_time
        from fle_staging.customer_diff_ticket cdt
        join fle_staging.customer_group cg on cdt.group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
        left join fle_staging.diff_info di on di.id = cdt.diff_info_id
        left join fle_staging.parcel_info pi on pi.pno = di.pno
        where
            di.diff_marker_category not in (7,22)
            and cdt.created_at >= '2022-11-30 11:00:00'
            and cdt.created_at < '2023-02-28 11:00:00'
        group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    t1.month_d 月份
    ,t1.cg_name 项目组
    ,t1.should_deal '应处理问题件数(剔除lost)'
    ,t2.deal_num 完结问题件数
    ,t1.should_not 应处理问题件数当月未完成
    ,t1.month_deal_ratio 当月问题件完结率
    ,zl.zl_num 滞留问题件单数
    ,t1.dam_short_ratio 破损短少问题件占比
    ,t1.cod_ratio COD金额问题件占比
    ,t1.other_ratio 其他问题件占比
    ,t2.avg_deal_time 完结问题件单均处理时长
    ,t2.dam_short_avg_time 破损短少问题件单均完结时长
    ,t2.cod_avg_time COD金额问题件单均完结时长
    ,t2.other_avg_time 其他问题件单均完结时长
    ,t1.jiedan_avg_time '问题件单均接单时长'
    ,t1.fin_avg_time '问题件单均接单-结单时长'
    ,cf.repeat_num 问题件重复包裹数
from
    ( -- 应处理
        select
            month(date_add(cdt.created_at, interval 13 hour)) month_d
            ,case
                when cdt.client_id = 'AA0416' then 'Lazada Buyer Return'
                when cdt.client_id in ('AA0707','AA0657','AA0606') then 'Shopee Buyer Return'
                when cdt.client_id in ('AA0649','AA0650') then 'Shein Buyer Return'
                else cg.name
            end cg_name
            ,count(distinct cdt.id ) should_deal
            ,count(distinct if(di.state != 1 or ( di.state = 1 and di.updated_at > date_add(adddate(last_day(date_add(cdt.created_at, interval 6 hour)), 1),interval 11 hour)), cdt.id, null))  should_not
            ,count(distinct if(di.state = 1 and di.updated_at < date_add(adddate(last_day(date_add(cdt.created_at, interval 6 hour)), 1),interval 11 hour), cdt.id, null))/count(distinct cdt.id ) month_deal_ratio
            ,count(distinct if(di.diff_marker_category in (5,6,20,21), cdt.id, null))/count(distinct cdt.id ) dam_short_ratio
            ,count(distinct if(pi.cod_enabled = 1, cdt.id, null))/count(distinct cdt.id) cod_ratio
            ,count(distinct if(pi.cod_enabled = 0 and di.diff_marker_category not in (5,6,20,21), cdt.id, null))/count(distinct cdt.id ) other_ratio
            ,sum(if(cdt.state != 0, timestampdiff(second , cdt.created_at, cdt.first_operated_at)/3600, 0 ))/count(distinct if(cdt.state != 0 ,cdt.id, null)) jiedan_avg_time
            ,sum(if(cdt.state = 1, timestampdiff(second ,cdt.first_operated_at, cdt.updated_at)/3600, 0 )) fin_avg_time
        from fle_staging.customer_diff_ticket cdt
        join fle_staging.customer_group cg on cdt.group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
        left join fle_staging.diff_info di on di.id = cdt.diff_info_id
        left join fle_staging.parcel_info pi on pi.pno = di.pno
        where
            di.diff_marker_category not in (7,22)
            and cdt.created_at >= '2022-11-30 11:00:00'
            and cdt.created_at < '2023-02-28 11:00:00'
        group by 1,2
    ) t1
left join
    ( -- 已完结
        select
            month(date_add(cdt.created_at, interval 7 hour)) month_d
            ,case
                when cdt.client_id = 'AA0416' then 'Lazada Buyer Return'
                when cdt.client_id in ('AA0707','AA0657','AA0606') then 'Shopee Buyer Return'
                when cdt.client_id in ('AA0649','AA0650') then 'Shein Buyer Return'
                else cg.name
            end cg_name
            ,count(distinct cdt.id ) deal_num
            ,sum(timestampdiff(second, cdt.created_at, cdt.updated_at)/3600)/count(distinct cdt.id) avg_deal_time
            ,sum(if(di.diff_marker_category in (5,6,20,21), timestampdiff(second, cdt.created_at, cdt.updated_at)/3600, 0))/count(distinct if(di.diff_marker_category in (5,6,20,21), cdt.id, null)) dam_short_avg_time
            ,sum(if(pi.cod_enabled = 1, timestampdiff(second, cdt.created_at, cdt.updated_at)/3600, 0))/count(distinct if(pi.cod_enabled = 1, cdt.id, null)) cod_avg_time
            ,sum(if(pi.cod_enabled = 0 and di.diff_marker_category not in (5,6,20,21), timestampdiff(second, cdt.created_at, cdt.updated_at)/3600, 0))/count(distinct if(pi.cod_enabled = 0 and di.diff_marker_category not in (5,6,20,21), cdt.id, null))  other_avg_time
        from fle_staging.customer_diff_ticket cdt
        left join fle_staging.diff_info di on di.id = cdt.diff_info_id
        join fle_staging.customer_group cg on cdt.group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
        left join fle_staging.parcel_info pi on pi.pno = di.pno
        where
            di.diff_marker_category not in (7,22)
            and cdt.updated_at >= '2022-12-31 17:00:00'
            and cdt.updated_at < '2023-02-28 17:00:00'
            and di.state = 1 -- 已处理
    ) t2 on t2.month_d = t1.month_d and t2.cg_name = t1.cg_name
left join
    ( -- 滞留
        select
            '12' month_d
            ,case
                when cdt.client_id = 'AA0416' then 'Lazada Buyer Return'
                when cdt.client_id in ('AA0707','AA0657','AA0606') then 'Shopee Buyer Return'
                when cdt.client_id in ('AA0649','AA0650') then 'Shein Buyer Return'
                else cg.name
            end cg_name
            ,count(distinct cdt.id) zl_num
        from fle_staging.customer_diff_ticket cdt
        left join fle_staging.diff_info di on di.id = cdt.diff_info_id
        join fle_staging.customer_group cg on cdt.group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
        where
            di.diff_marker_category not in (7,22)
            and cdt.created_at >= '2021-12-31 17:00:00'
            and cdt.created_at < '2022-12-31 11:00:00'  -- 18点之前产生
            and
                (
                    di.state != 1 or
                    (di.state = 1 and di.updated_at > '2022-12-31 17:00:00')
                )
        group by 1,2

        union all

        select
            '1' month_d
            ,case
                when cdt.client_id = 'AA0416' then 'Lazada Buyer Return'
                when cdt.client_id in ('AA0707','AA0657','AA0606') then 'Shopee Buyer Return'
                when cdt.client_id in ('AA0649','AA0650') then 'Shein Buyer Return'
                else cg.name
            end cg_name
            ,count(distinct cdt.id) zl_num
        from fle_staging.customer_diff_ticket cdt
        left join fle_staging.diff_info di on di.id = cdt.diff_info_id
        join fle_staging.customer_group cg on cdt.group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
        where
            di.diff_marker_category not in (7,22)
            and cdt.created_at >= '2021-12-31 17:00:00'
            and cdt.created_at < '2023-01-31 11:00:00'  -- 18点之前产生
            and
                (
                    di.state != 1 or
                    (di.state = 1 and di.updated_at > '2023-01-31 11:00:00')
                )
        group by 1,2

        union all

        select
            '2' month_d
            ,case
                when cdt.client_id = 'AA0416' then 'Lazada Buyer Return'
                when cdt.client_id in ('AA0707','AA0657','AA0606') then 'Shopee Buyer Return'
                when cdt.client_id in ('AA0649','AA0650') then 'Shein Buyer Return'
                else cg.name
            end cg_name
            ,count(distinct cdt.id) zl_num
        from fle_staging.customer_diff_ticket cdt
        left join fle_staging.diff_info di on di.id = cdt.diff_info_id
        join fle_staging.customer_group cg on cdt.group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
        where
            di.diff_marker_category not in (7,22)
            and cdt.created_at >= '2021-12-31 17:00:00'
            and cdt.created_at < '2023-02-28 11:00:00' -- 18点之前产生
            and
                (
                    di.state != 1 or
                    (di.state = 1 and di.updated_at > '2023-02-28 17:00:00')
                )
        group by 1,2
    ) zl  on zl.month_d = t1.month_d and zl.cg_name = t1.cg_name
left join
    (
        select
            t.cg_name
            ,t.month_d
            ,count(distinct t.pno) repeat_num
        from
            (
                select
                    cdt.id
                    ,month(date_add(cdt.created_at, interval 13 hour)) month_d
                    ,case
                        when cdt.client_id = 'AA0416' then 'Lazada Buyer Return'
                        when cdt.client_id in ('AA0707','AA0657','AA0606') then 'Shopee Buyer Return'
                        when cdt.client_id in ('AA0649','AA0650') then 'Shein Buyer Return'
                        else cg.name
                    end cg_name
                    ,di.pno
                    ,count(cdt.id) over (partition by month(date_add(cdt.created_at, interval 13 hour)), di.pno) pno_count
                from fle_staging.customer_diff_ticket cdt
                left join fle_staging.diff_info di on di.id = cdt.diff_info_id
                join fle_staging.customer_group cg on cdt.group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
                where
                    di.diff_marker_category not in (7,22)
                    and cdt.created_at >= '2022-11-30 11:00:00'
                    and cdt.created_at < '2023-02-28 11:00:00'
            ) t
        where
            t.pno_count >= 2
        group by 1,2
    ) cf on cf.month_d = t1.month_d and cf.cg_name = t1.cg_name;
;-- -. . -..- - / . -. - .-. -.--
select
            month(date_add(cdt.created_at, interval 7 hour)) month_d
            ,case
                when cdt.client_id = 'AA0416' then 'Lazada Buyer Return'
                when cdt.client_id in ('AA0707','AA0657','AA0606') then 'Shopee Buyer Return'
                when cdt.client_id in ('AA0649','AA0650') then 'Shein Buyer Return'
                else cg.name
            end cg_name
            ,count(distinct cdt.id ) deal_num
            ,sum(timestampdiff(second, cdt.created_at, cdt.updated_at)/3600)/count(distinct cdt.id) avg_deal_time
            ,sum(if(di.diff_marker_category in (5,6,20,21), timestampdiff(second, cdt.created_at, cdt.updated_at)/3600, 0))/count(distinct if(di.diff_marker_category in (5,6,20,21), cdt.id, null)) dam_short_avg_time
            ,sum(if(pi.cod_enabled = 1, timestampdiff(second, cdt.created_at, cdt.updated_at)/3600, 0))/count(distinct if(pi.cod_enabled = 1, cdt.id, null)) cod_avg_time
            ,sum(if(pi.cod_enabled = 0 and di.diff_marker_category not in (5,6,20,21), timestampdiff(second, cdt.created_at, cdt.updated_at)/3600, 0))/count(distinct if(pi.cod_enabled = 0 and di.diff_marker_category not in (5,6,20,21), cdt.id, null))  other_avg_time
        from fle_staging.customer_diff_ticket cdt
        left join fle_staging.diff_info di on di.id = cdt.diff_info_id
        join fle_staging.customer_group cg on cdt.group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
        left join fle_staging.parcel_info pi on pi.pno = di.pno
        where
            di.diff_marker_category not in (7,22)
            and cdt.updated_at >= '2022-11-30 17:00:00'
            and cdt.updated_at < '2023-02-28 17:00:00'
            and di.state = 1;
;-- -. . -..- - / . -. - .-. -.--
select
    t1.month_d 月份
    ,t1.cg_name 项目组
    ,t1.should_deal '应处理问题件数(剔除lost)'
    ,t2.deal_num 完结问题件数
    ,t1.should_not 应处理问题件数当月未完成
    ,t1.month_deal_ratio 当月问题件完结率
    ,zl.zl_num 滞留问题件单数
    ,t1.dam_short_ratio 破损短少问题件占比
    ,t1.cod_ratio COD金额问题件占比
    ,t1.other_ratio 其他问题件占比
    ,t2.avg_deal_time 完结问题件单均处理时长
    ,t2.dam_short_avg_time 破损短少问题件单均完结时长
    ,t2.cod_avg_time COD金额问题件单均完结时长
    ,t2.other_avg_time 其他问题件单均完结时长
    ,t1.jiedan_avg_time '问题件单均接单时长'
    ,t1.fin_avg_time '问题件单均接单-结单时长'
    ,cf.repeat_num 问题件重复包裹数
from
    ( -- 应处理
        select
            month(date_add(cdt.created_at, interval 13 hour)) month_d
            ,case
                when cdt.client_id = 'AA0416' then 'Lazada Buyer Return'
                when cdt.client_id in ('AA0707','AA0657','AA0606') then 'Shopee Buyer Return'
                when cdt.client_id in ('AA0649','AA0650') then 'Shein Buyer Return'
                else cg.name
            end cg_name
            ,count(distinct cdt.id ) should_deal
            ,count(distinct if(di.state != 1 or ( di.state = 1 and di.updated_at > date_add(adddate(last_day(date_add(cdt.created_at, interval 6 hour)), 1),interval 11 hour)), cdt.id, null))  should_not
            ,count(distinct if(di.state = 1 and di.updated_at < date_add(adddate(last_day(date_add(cdt.created_at, interval 6 hour)), 1),interval 11 hour), cdt.id, null))/count(distinct cdt.id ) month_deal_ratio
            ,count(distinct if(di.diff_marker_category in (5,6,20,21), cdt.id, null))/count(distinct cdt.id ) dam_short_ratio
            ,count(distinct if(pi.cod_enabled = 1, cdt.id, null))/count(distinct cdt.id) cod_ratio
            ,count(distinct if(pi.cod_enabled = 0 and di.diff_marker_category not in (5,6,20,21), cdt.id, null))/count(distinct cdt.id ) other_ratio
            ,sum(if(cdt.state != 0, timestampdiff(second , cdt.created_at, cdt.first_operated_at)/3600, 0 ))/count(distinct if(cdt.state != 0 ,cdt.id, null)) jiedan_avg_time
            ,sum(if(cdt.state = 1, timestampdiff(second ,cdt.first_operated_at, cdt.updated_at)/3600, 0 )) fin_avg_time
        from fle_staging.customer_diff_ticket cdt
        join fle_staging.customer_group cg on cdt.group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
        left join fle_staging.diff_info di on di.id = cdt.diff_info_id
        left join fle_staging.parcel_info pi on pi.pno = di.pno
        where
            di.diff_marker_category not in (7,22)
            and cdt.created_at >= '2022-11-30 11:00:00'
            and cdt.created_at < '2023-02-28 11:00:00'
        group by 1,2
    ) t1
left join
    ( -- 已完结
        select
            month(date_add(cdt.created_at, interval 7 hour)) month_d
            ,case
                when cdt.client_id = 'AA0416' then 'Lazada Buyer Return'
                when cdt.client_id in ('AA0707','AA0657','AA0606') then 'Shopee Buyer Return'
                when cdt.client_id in ('AA0649','AA0650') then 'Shein Buyer Return'
                else cg.name
            end cg_name
            ,count(distinct cdt.id ) deal_num
            ,sum(timestampdiff(second, cdt.created_at, cdt.updated_at)/3600)/count(distinct cdt.id) avg_deal_time
            ,sum(if(di.diff_marker_category in (5,6,20,21), timestampdiff(second, cdt.created_at, cdt.updated_at)/3600, 0))/count(distinct if(di.diff_marker_category in (5,6,20,21), cdt.id, null)) dam_short_avg_time
            ,sum(if(pi.cod_enabled = 1, timestampdiff(second, cdt.created_at, cdt.updated_at)/3600, 0))/count(distinct if(pi.cod_enabled = 1, cdt.id, null)) cod_avg_time
            ,sum(if(pi.cod_enabled = 0 and di.diff_marker_category not in (5,6,20,21), timestampdiff(second, cdt.created_at, cdt.updated_at)/3600, 0))/count(distinct if(pi.cod_enabled = 0 and di.diff_marker_category not in (5,6,20,21), cdt.id, null))  other_avg_time
        from fle_staging.customer_diff_ticket cdt
        left join fle_staging.diff_info di on di.id = cdt.diff_info_id
        join fle_staging.customer_group cg on cdt.group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
        left join fle_staging.parcel_info pi on pi.pno = di.pno
        where
            di.diff_marker_category not in (7,22)
            and cdt.updated_at >= '2022-11-30 17:00:00'
            and cdt.updated_at < '2023-02-28 17:00:00'
            and di.state = 1 -- 已处理
        group by 1,2
    ) t2 on t2.month_d = t1.month_d and t2.cg_name = t1.cg_name
left join
    ( -- 滞留
        select
            '12' month_d
            ,case
                when cdt.client_id = 'AA0416' then 'Lazada Buyer Return'
                when cdt.client_id in ('AA0707','AA0657','AA0606') then 'Shopee Buyer Return'
                when cdt.client_id in ('AA0649','AA0650') then 'Shein Buyer Return'
                else cg.name
            end cg_name
            ,count(distinct cdt.id) zl_num
        from fle_staging.customer_diff_ticket cdt
        left join fle_staging.diff_info di on di.id = cdt.diff_info_id
        join fle_staging.customer_group cg on cdt.group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
        where
            di.diff_marker_category not in (7,22)
            and cdt.created_at >= '2021-12-31 17:00:00'
            and cdt.created_at < '2022-12-31 11:00:00'  -- 18点之前产生
            and
                (
                    di.state != 1 or
                    (di.state = 1 and di.updated_at > '2022-12-31 17:00:00')
                )
        group by 1,2

        union all

        select
            '1' month_d
            ,case
                when cdt.client_id = 'AA0416' then 'Lazada Buyer Return'
                when cdt.client_id in ('AA0707','AA0657','AA0606') then 'Shopee Buyer Return'
                when cdt.client_id in ('AA0649','AA0650') then 'Shein Buyer Return'
                else cg.name
            end cg_name
            ,count(distinct cdt.id) zl_num
        from fle_staging.customer_diff_ticket cdt
        left join fle_staging.diff_info di on di.id = cdt.diff_info_id
        join fle_staging.customer_group cg on cdt.group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
        where
            di.diff_marker_category not in (7,22)
            and cdt.created_at >= '2021-12-31 17:00:00'
            and cdt.created_at < '2023-01-31 11:00:00'  -- 18点之前产生
            and
                (
                    di.state != 1 or
                    (di.state = 1 and di.updated_at > '2023-01-31 11:00:00')
                )
        group by 1,2

        union all

        select
            '2' month_d
            ,case
                when cdt.client_id = 'AA0416' then 'Lazada Buyer Return'
                when cdt.client_id in ('AA0707','AA0657','AA0606') then 'Shopee Buyer Return'
                when cdt.client_id in ('AA0649','AA0650') then 'Shein Buyer Return'
                else cg.name
            end cg_name
            ,count(distinct cdt.id) zl_num
        from fle_staging.customer_diff_ticket cdt
        left join fle_staging.diff_info di on di.id = cdt.diff_info_id
        join fle_staging.customer_group cg on cdt.group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
        where
            di.diff_marker_category not in (7,22)
            and cdt.created_at >= '2021-12-31 17:00:00'
            and cdt.created_at < '2023-02-28 11:00:00' -- 18点之前产生
            and
                (
                    di.state != 1 or
                    (di.state = 1 and di.updated_at > '2023-02-28 17:00:00')
                )
        group by 1,2
    ) zl  on zl.month_d = t1.month_d and zl.cg_name = t1.cg_name
left join
    (
        select
            t.cg_name
            ,t.month_d
            ,count(distinct t.pno) repeat_num
        from
            (
                select
                    cdt.id
                    ,month(date_add(cdt.created_at, interval 13 hour)) month_d
                    ,case
                        when cdt.client_id = 'AA0416' then 'Lazada Buyer Return'
                        when cdt.client_id in ('AA0707','AA0657','AA0606') then 'Shopee Buyer Return'
                        when cdt.client_id in ('AA0649','AA0650') then 'Shein Buyer Return'
                        else cg.name
                    end cg_name
                    ,di.pno
                    ,count(cdt.id) over (partition by month(date_add(cdt.created_at, interval 13 hour)), di.pno) pno_count
                from fle_staging.customer_diff_ticket cdt
                left join fle_staging.diff_info di on di.id = cdt.diff_info_id
                join fle_staging.customer_group cg on cdt.group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
                where
                    di.diff_marker_category not in (7,22)
                    and cdt.created_at >= '2022-11-30 11:00:00'
                    and cdt.created_at < '2023-02-28 11:00:00'
            ) t
        where
            t.pno_count >= 2
        group by 1,2
    ) cf on cf.month_d = t1.month_d and cf.cg_name = t1.cg_name;
;-- -. . -..- - / . -. - .-. -.--
select
    plt.pno
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
from bi_pro.parcel_lose_task plt
left join fle_staging.parcel_info pi on plt.pno = pi.pno
where
    plt.state = 6
    and plt.duty_result = 1
    and pi.state not in (5,7,8,9)
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    plt.pno
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
    ,convert_tz(pi.created_at, '+00:00', '+07:00') 揽收时间
from bi_pro.parcel_lose_task plt
left join fle_staging.parcel_info pi on plt.pno = pi.pno
where
    plt.state = 6
    and plt.duty_result = 1
    and pi.state not in (5,7,8,9)
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    t1.month_d 月份
    ,t1.cg_name 项目组
    ,t1.should_deal '应处理问题件数(剔除lost)'
    ,t2.deal_num 完结问题件数
    ,t1.should_not 应处理问题件数当月未完成
    ,t1.month_deal_ratio 当月问题件完结率
    ,zl.zl_num 滞留问题件单数
    ,t1.dam_short_ratio 破损短少问题件占比
    ,t1.cod_ratio COD金额问题件占比
    ,t1.other_ratio 其他问题件占比
    ,t2.avg_deal_time 完结问题件单均处理时长
    ,t2.dam_short_avg_time 破损短少问题件单均完结时长
    ,t2.cod_avg_time COD金额问题件单均完结时长
    ,t2.other_avg_time 其他问题件单均完结时长
    ,t1.jiedan_avg_time '问题件单均接单时长'
    ,t1.fin_avg_time '问题件单均接单-结单时长'
    ,cf.repeat_num 问题件重复包裹数
from
    ( -- 应处理
        select
            month(date_add(cdt.created_at, interval 13 hour)) month_d
            ,case
                when cdt.client_id = 'AA0416' then 'Lazada Buyer Return'
                when cdt.client_id in ('AA0707','AA0657','AA0606') then 'Shopee Buyer Return'
                when cdt.client_id in ('AA0649','AA0650') then 'Shein Buyer Return'
                else cg.name
            end cg_name
            ,count(distinct cdt.id ) should_deal
            ,count(distinct if(di.state != 1 or ( di.state = 1 and di.updated_at > date_add(adddate(last_day(date_add(cdt.created_at, interval 6 hour)), 1),interval 11 hour)), cdt.id, null))  should_not
            ,count(distinct if(di.state = 1 and di.updated_at < date_add(adddate(last_day(date_add(cdt.created_at, interval 6 hour)), 1),interval 11 hour), cdt.id, null))/count(distinct cdt.id ) month_deal_ratio
            ,count(distinct if(di.diff_marker_category in (5,6,20,21), cdt.id, null))/count(distinct cdt.id ) dam_short_ratio
            ,count(distinct if(pi.cod_enabled = 1, cdt.id, null))/count(distinct cdt.id) cod_ratio
            ,count(distinct if(pi.cod_enabled = 0 and di.diff_marker_category not in (5,6,20,21), cdt.id, null))/count(distinct cdt.id ) other_ratio
            ,sum(if(cdt.state != 0, timestampdiff(second , cdt.created_at, cdt.first_operated_at)/3600, 0 ))/count(distinct if(cdt.state != 0 ,cdt.id, null)) jiedan_avg_time
            ,sum(if(cdt.state = 1, timestampdiff(second ,cdt.first_operated_at, cdt.updated_at)/3600, 0 ))/count(distinct if(cdt.state = 1,cdt.id, null)) fin_avg_time
        from fle_staging.customer_diff_ticket cdt
        join fle_staging.customer_group cg on cdt.group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
        left join fle_staging.diff_info di on di.id = cdt.diff_info_id
        left join fle_staging.parcel_info pi on pi.pno = di.pno
        where
            di.diff_marker_category not in (7,22)
            and cdt.created_at >= '2022-11-30 11:00:00'
            and cdt.created_at < '2023-02-28 11:00:00'
        group by 1,2
    ) t1
left join
    ( -- 已完结
        select
            month(date_add(cdt.created_at, interval 7 hour)) month_d
            ,case
                when cdt.client_id = 'AA0416' then 'Lazada Buyer Return'
                when cdt.client_id in ('AA0707','AA0657','AA0606') then 'Shopee Buyer Return'
                when cdt.client_id in ('AA0649','AA0650') then 'Shein Buyer Return'
                else cg.name
            end cg_name
            ,count(distinct cdt.id ) deal_num
            ,sum(timestampdiff(second, cdt.created_at, cdt.updated_at)/3600)/count(distinct cdt.id) avg_deal_time
            ,sum(if(di.diff_marker_category in (5,6,20,21), timestampdiff(second, cdt.created_at, cdt.updated_at)/3600, 0))/count(distinct if(di.diff_marker_category in (5,6,20,21), cdt.id, null)) dam_short_avg_time
            ,sum(if(pi.cod_enabled = 1, timestampdiff(second, cdt.created_at, cdt.updated_at)/3600, 0))/count(distinct if(pi.cod_enabled = 1, cdt.id, null)) cod_avg_time
            ,sum(if(pi.cod_enabled = 0 and di.diff_marker_category not in (5,6,20,21), timestampdiff(second, cdt.created_at, cdt.updated_at)/3600, 0))/count(distinct if(pi.cod_enabled = 0 and di.diff_marker_category not in (5,6,20,21), cdt.id, null))  other_avg_time
        from fle_staging.customer_diff_ticket cdt
        left join fle_staging.diff_info di on di.id = cdt.diff_info_id
        join fle_staging.customer_group cg on cdt.group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
        left join fle_staging.parcel_info pi on pi.pno = di.pno
        where
            di.diff_marker_category not in (7,22)
            and cdt.updated_at >= '2022-11-30 17:00:00'
            and cdt.updated_at < '2023-02-28 17:00:00'
            and di.state = 1 -- 已处理
        group by 1,2
    ) t2 on t2.month_d = t1.month_d and t2.cg_name = t1.cg_name
left join
    ( -- 滞留
        select
            '12' month_d
            ,case
                when cdt.client_id = 'AA0416' then 'Lazada Buyer Return'
                when cdt.client_id in ('AA0707','AA0657','AA0606') then 'Shopee Buyer Return'
                when cdt.client_id in ('AA0649','AA0650') then 'Shein Buyer Return'
                else cg.name
            end cg_name
            ,count(distinct cdt.id) zl_num
        from fle_staging.customer_diff_ticket cdt
        left join fle_staging.diff_info di on di.id = cdt.diff_info_id
        join fle_staging.customer_group cg on cdt.group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
        where
            di.diff_marker_category not in (7,22)
            and cdt.created_at >= '2021-12-31 17:00:00'
            and cdt.created_at < '2022-12-31 11:00:00'  -- 18点之前产生
            and
                (
                    di.state != 1 or
                    (di.state = 1 and di.updated_at > '2022-12-31 17:00:00')
                )
        group by 1,2

        union all

        select
            '1' month_d
            ,case
                when cdt.client_id = 'AA0416' then 'Lazada Buyer Return'
                when cdt.client_id in ('AA0707','AA0657','AA0606') then 'Shopee Buyer Return'
                when cdt.client_id in ('AA0649','AA0650') then 'Shein Buyer Return'
                else cg.name
            end cg_name
            ,count(distinct cdt.id) zl_num
        from fle_staging.customer_diff_ticket cdt
        left join fle_staging.diff_info di on di.id = cdt.diff_info_id
        join fle_staging.customer_group cg on cdt.group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
        where
            di.diff_marker_category not in (7,22)
            and cdt.created_at >= '2021-12-31 17:00:00'
            and cdt.created_at < '2023-01-31 11:00:00'  -- 18点之前产生
            and
                (
                    di.state != 1 or
                    (di.state = 1 and di.updated_at > '2023-01-31 11:00:00')
                )
        group by 1,2

        union all

        select
            '2' month_d
            ,case
                when cdt.client_id = 'AA0416' then 'Lazada Buyer Return'
                when cdt.client_id in ('AA0707','AA0657','AA0606') then 'Shopee Buyer Return'
                when cdt.client_id in ('AA0649','AA0650') then 'Shein Buyer Return'
                else cg.name
            end cg_name
            ,count(distinct cdt.id) zl_num
        from fle_staging.customer_diff_ticket cdt
        left join fle_staging.diff_info di on di.id = cdt.diff_info_id
        join fle_staging.customer_group cg on cdt.group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
        where
            di.diff_marker_category not in (7,22)
            and cdt.created_at >= '2021-12-31 17:00:00'
            and cdt.created_at < '2023-02-28 11:00:00' -- 18点之前产生
            and
                (
                    di.state != 1 or
                    (di.state = 1 and di.updated_at > '2023-02-28 17:00:00')
                )
        group by 1,2
    ) zl  on zl.month_d = t1.month_d and zl.cg_name = t1.cg_name
left join
    (
        select
            t.cg_name
            ,t.month_d
            ,count(distinct t.pno) repeat_num
        from
            (
                select
                    cdt.id
                    ,month(date_add(cdt.created_at, interval 13 hour)) month_d
                    ,case
                        when cdt.client_id = 'AA0416' then 'Lazada Buyer Return'
                        when cdt.client_id in ('AA0707','AA0657','AA0606') then 'Shopee Buyer Return'
                        when cdt.client_id in ('AA0649','AA0650') then 'Shein Buyer Return'
                        else cg.name
                    end cg_name
                    ,di.pno
                    ,count(cdt.id) over (partition by month(date_add(cdt.created_at, interval 13 hour)), di.pno) pno_count
                from fle_staging.customer_diff_ticket cdt
                left join fle_staging.diff_info di on di.id = cdt.diff_info_id
                join fle_staging.customer_group cg on cdt.group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
                where
                    di.diff_marker_category not in (7,22)
                    and cdt.created_at >= '2022-11-30 11:00:00'
                    and cdt.created_at < '2023-02-28 11:00:00'
            ) t
        where
            t.pno_count >= 2
        group by 1,2
    ) cf on cf.month_d = t1.month_d and cf.cg_name = t1.cg_name;
;-- -. . -..- - / . -. - .-. -.--
select DATE_ADD(DATE_ADD(CURDATE(), INTERVAL 1 MONTH), INTERVAL 10 DAY);
;-- -. . -..- - / . -. - .-. -.--
SELECT DATE_FORMAT(DATE_ADD(NOW(), INTERVAL 1 MONTH), '%Y-%m-10');
;-- -. . -..- - / . -. - .-. -.--
select
    t1.month_d 月份
    ,t1.cg_name 项目组
    ,t1.should_deal '应处理问题件数(剔除lost)'
    ,t2.deal_num 完结问题件数
    ,t1.should_not 应处理问题件数当月未完成
    ,t1.month_deal_ratio 当月问题件完结率
    ,zl.zl_num 滞留问题件单数
    ,t1.dam_short_ratio 破损短少问题件占比
    ,t1.cod_ratio COD金额问题件占比
    ,t1.other_ratio 其他问题件占比
    ,t2.avg_deal_time 完结问题件单均处理时长
    ,t2.dam_short_avg_time 破损短少问题件单均完结时长
    ,t2.cod_avg_time COD金额问题件单均完结时长
    ,t2.other_avg_time 其他问题件单均完结时长
    ,t1.jiedan_avg_time '问题件单均接单时长'
    ,t1.fin_avg_time '问题件单均接单-结单时长'
    ,cf.repeat_num 问题件重复包裹数
from
    ( -- 应处理
        select
            month(date_add(cdt.created_at, interval 13 hour)) month_d
            ,case
                when cdt.client_id = 'AA0416' then 'Lazada Buyer Return'
                when cdt.client_id in ('AA0707','AA0657','AA0606') then 'Shopee Buyer Return'
                when cdt.client_id in ('AA0649','AA0650') then 'Shein Buyer Return'
                else cg.name
            end cg_name
            ,count(distinct cdt.id ) should_deal
            ,count(distinct if(di.state != 1 or ( di.state = 1 and di.updated_at > date_add(adddate(last_day(date_add(cdt.created_at, interval 6 hour)), 1),interval 11 hour)), cdt.id, null))  should_not
            ,count(distinct if(di.state = 1 and di.updated_at < date_add(adddate(last_day(date_add(cdt.created_at, interval 6 hour)), 1),interval 11 hour), cdt.id, null))/count(distinct cdt.id ) month_deal_ratio
            ,count(distinct if(di.diff_marker_category in (5,6,20,21), cdt.id, null))/count(distinct cdt.id ) dam_short_ratio
            ,count(distinct if(pi.cod_enabled = 1, cdt.id, null))/count(distinct cdt.id) cod_ratio
            ,count(distinct if(pi.cod_enabled = 0 and di.diff_marker_category not in (5,6,20,21), cdt.id, null))/count(distinct cdt.id ) other_ratio
            ,sum(if(cdt.state != 0, timestampdiff(second , cdt.created_at, cdt.first_operated_at)/3600, 0 ))/count(distinct if(cdt.state != 0 ,cdt.id, null)) jiedan_avg_time
            ,sum(if(cdt.state = 1, timestampdiff(second ,cdt.first_operated_at, cdt.updated_at)/3600, 0 ))/count(distinct if(cdt.state = 1,cdt.id, null)) fin_avg_time
        from fle_staging.customer_diff_ticket cdt
        join fle_staging.customer_group cg on cdt.group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
        left join fle_staging.diff_info di on di.id = cdt.diff_info_id
        left join fle_staging.parcel_info pi on pi.pno = di.pno
        where
            di.diff_marker_category not in (7,22)
            and cdt.created_at >= '2022-11-30 11:00:00'
            and cdt.created_at < '2023-02-28 11:00:00'
        group by 1,2
    ) t1
left join
    ( -- 已完结
        select
            month(cdt.updated_at) month_d
            ,case
                when cdt.client_id = 'AA0416' then 'Lazada Buyer Return'
                when cdt.client_id in ('AA0707','AA0657','AA0606') then 'Shopee Buyer Return'
                when cdt.client_id in ('AA0649','AA0650') then 'Shein Buyer Return'
                else cg.name
            end cg_name
            ,count(distinct cdt.id ) deal_num
            ,sum(timestampdiff(second, cdt.created_at, cdt.updated_at)/3600)/count(distinct cdt.id) avg_deal_time
            ,sum(if(di.diff_marker_category in (5,6,20,21), timestampdiff(second, cdt.created_at, cdt.updated_at)/3600, 0))/count(distinct if(di.diff_marker_category in (5,6,20,21), cdt.id, null)) dam_short_avg_time
            ,sum(if(pi.cod_enabled = 1, timestampdiff(second, cdt.created_at, cdt.updated_at)/3600, 0))/count(distinct if(pi.cod_enabled = 1, cdt.id, null)) cod_avg_time
            ,sum(if(pi.cod_enabled = 0 and di.diff_marker_category not in (5,6,20,21), timestampdiff(second, cdt.created_at, cdt.updated_at)/3600, 0))/count(distinct if(pi.cod_enabled = 0 and di.diff_marker_category not in (5,6,20,21), cdt.id, null))  other_avg_time
        from fle_staging.customer_diff_ticket cdt
        left join fle_staging.diff_info di on di.id = cdt.diff_info_id
        join fle_staging.customer_group cg on cdt.group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
        left join fle_staging.parcel_info pi on pi.pno = di.pno
        where
            di.diff_marker_category not in (7,22)
            and cdt.updated_at >= '2022-11-30 17:00:00'
            and cdt.updated_at < '2023-02-28 17:00:00'
            and di.state = 1 -- 已处理
        group by 1,2
    ) t2 on t2.month_d = t1.month_d and t2.cg_name = t1.cg_name
left join
    ( -- 滞留
        select
            '12' month_d
            ,case
                when cdt.client_id = 'AA0416' then 'Lazada Buyer Return'
                when cdt.client_id in ('AA0707','AA0657','AA0606') then 'Shopee Buyer Return'
                when cdt.client_id in ('AA0649','AA0650') then 'Shein Buyer Return'
                else cg.name
            end cg_name
            ,count(distinct cdt.id) zl_num
        from fle_staging.customer_diff_ticket cdt
        left join fle_staging.diff_info di on di.id = cdt.diff_info_id
        join fle_staging.customer_group cg on cdt.group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
        where
            di.diff_marker_category not in (7,22)
            and cdt.created_at >= '2021-12-31 17:00:00'
            and cdt.created_at < '2022-12-31 11:00:00'  -- 18点之前产生
            and
                (
                    di.state != 1 or
                    (di.state = 1 and di.updated_at > '2022-12-31 17:00:00')
                )
        group by 1,2

        union all

        select
            '1' month_d
            ,case
                when cdt.client_id = 'AA0416' then 'Lazada Buyer Return'
                when cdt.client_id in ('AA0707','AA0657','AA0606') then 'Shopee Buyer Return'
                when cdt.client_id in ('AA0649','AA0650') then 'Shein Buyer Return'
                else cg.name
            end cg_name
            ,count(distinct cdt.id) zl_num
        from fle_staging.customer_diff_ticket cdt
        left join fle_staging.diff_info di on di.id = cdt.diff_info_id
        join fle_staging.customer_group cg on cdt.group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
        where
            di.diff_marker_category not in (7,22)
            and cdt.created_at >= '2021-12-31 17:00:00'
            and cdt.created_at < '2023-01-31 11:00:00'  -- 18点之前产生
            and
                (
                    di.state != 1 or
                    (di.state = 1 and di.updated_at > '2023-01-31 11:00:00')
                )
        group by 1,2

        union all

        select
            '2' month_d
            ,case
                when cdt.client_id = 'AA0416' then 'Lazada Buyer Return'
                when cdt.client_id in ('AA0707','AA0657','AA0606') then 'Shopee Buyer Return'
                when cdt.client_id in ('AA0649','AA0650') then 'Shein Buyer Return'
                else cg.name
            end cg_name
            ,count(distinct cdt.id) zl_num
        from fle_staging.customer_diff_ticket cdt
        left join fle_staging.diff_info di on di.id = cdt.diff_info_id
        join fle_staging.customer_group cg on cdt.group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
        where
            di.diff_marker_category not in (7,22)
            and cdt.created_at >= '2021-12-31 17:00:00'
            and cdt.created_at < '2023-02-28 11:00:00' -- 18点之前产生
            and
                (
                    di.state != 1 or
                    (di.state = 1 and di.updated_at > '2023-02-28 17:00:00')
                )
        group by 1,2
    ) zl  on zl.month_d = t1.month_d and zl.cg_name = t1.cg_name
left join
    (
        select
            t.cg_name
            ,t.month_d
            ,count(distinct t.pno) repeat_num
        from
            (
                select
                    cdt.id
                    ,month(date_add(cdt.created_at, interval 13 hour)) month_d
                    ,case
                        when cdt.client_id = 'AA0416' then 'Lazada Buyer Return'
                        when cdt.client_id in ('AA0707','AA0657','AA0606') then 'Shopee Buyer Return'
                        when cdt.client_id in ('AA0649','AA0650') then 'Shein Buyer Return'
                        else cg.name
                    end cg_name
                    ,di.pno
                    ,count(cdt.id) over (partition by month(date_add(cdt.created_at, interval 13 hour)), di.pno) pno_count
                from fle_staging.customer_diff_ticket cdt
                left join fle_staging.diff_info di on di.id = cdt.diff_info_id
                join fle_staging.customer_group cg on cdt.group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
                where
                    di.diff_marker_category not in (7,22)
                    and cdt.created_at >= '2022-11-30 11:00:00'
                    and cdt.created_at < '2023-02-28 11:00:00'
            ) t
        where
            t.pno_count >= 2
        group by 1,2
    ) cf on cf.month_d = t1.month_d and cf.cg_name = t1.cg_name;
;-- -. . -..- - / . -. - .-. -.--
select
    plt.pno
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
    ,convert_tz(pi.created_at, '+00:00', '+07:00') 揽收时间
from bi_pro.parcel_lose_task plt
left join fle_staging.parcel_info pi on plt.pno = pi.pno
where
    plt.state = 6
    and plt.duty_result = 1
    and pi.state not in (5,7,8,9)
    and pi.interrupt_category = 3
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    plt.pno
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
    ,convert_tz(pi.created_at, '+00:00', '+07:00') 揽收时间
from bi_pro.parcel_lose_task plt
left join fle_staging.parcel_info pi on plt.pno = pi.pno
where
    plt.state = 6
    and plt.duty_result = 1
    and pi.state not in (5,7,8,9)
    and pi.discard_enabled = 1
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    t.t1
    ,t.t2
    ,t.t3
    ,t.t4
    ,t.t5
from tmpale.tmp_th_test_0316 t
where
    t.id = 1;
;-- -. . -..- - / . -. - .-. -.--
select
    t.t1
    ,t.t2
    ,t.t3
    ,t.t4
    ,t.t5
    ,avg(t1,t2,t3,t4,t5)
from tmpale.tmp_th_test_0316 t
where
    t.id = 1;
;-- -. . -..- - / . -. - .-. -.--
select
#     t.t1
#     ,t.t2
#     ,t.t3
#     ,t.t4
#     ,t.t5
    ,avg(t1,t2,t3,t4,t5)
from tmpale.tmp_th_test_0316 t
where
    t.id = 1;
;-- -. . -..- - / . -. - .-. -.--
select
#     t.t1
#     ,t.t2
#     ,t.t3
#     ,t.t4
#     ,t.t5
    avg(t1,t2,t3,t4,t5)
from tmpale.tmp_th_test_0316 t
where
    t.id = 1;
;-- -. . -..- - / . -. - .-. -.--
select
#     t.t1
#     ,t.t2
#     ,t.t3
#     ,t.t4
#     ,t.t5
    t0,
    avg(t1,t2,t3,t4,t5)
from tmpale.tmp_th_test_0316 t
where
    t.id = 1
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
#     t.t1
#     ,t.t2
#     ,t.t3
#     ,t.t4
#     ,t.t5
    t.id,
    avg(t1,t2,t3,t4,t5)
from tmpale.tmp_th_test_0316 t
where
    t.id = 1
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        wo.id
        ,wor.created_at
        ,row_number() over (partition by wo.id order by wor.created_at desc ) rn
    from bi_pro.work_order wo
    left join bi_pro.work_order_reply wor on wor.order_id = wo.id
    left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = wor.staff_info_id
    where
        wo.created_at >= date_sub(curdate(),interval 30 day)
        and wo.created_at < curdate()
        and hsi.state = 1
        and hsi.node_department_id = 86
)

SELECT
    concat('`',wo.order_no)  工单编号
    ,case wo.status when 1 then '未阅读' when 2 then '已经阅读' when 3 then '已回复' when 4 then '已关闭' end 状态
    ,wo.`client_id` 客户ID
    ,wo.`pnos`  运单号
    ,case wo.order_type
        when 1 then '查找运单'
        when 2 then '加快处理'
        when 3 then '调查员工'
        when 4 then '其他'
        when 5 then '网点信息维护提醒'
        when 6 then '培训指导'
        when 7 then '异常业务询问'
        when 8 then '包裹丢失'
        when 9 then '包裹破损'
        when 10 then '货物短少'
        when 11 then '催单'
        when 12 then '有发无到'
        when 13 then '上报包裹不在集包里'
        when 16 then '漏揽收'
        when 50 then '虚假撤销'
        when 17 then '已签收未收到'
        when 18 then '客户投诉'
        when 19 then '修改包裹信息'
        when 20 then '修改 COD 金额'
        when 21 then '解锁包裹'
        when 22 then '申请索赔'
        when 23 then 'MS 问题反馈'
        when 24 then 'FBI 问题反馈'
        when 25 then 'KA System 问题反馈'
        when 26 then 'App 问题反馈'
        when 27 then 'KIT 问题反馈'
        when 28 then 'Backyard 问题反馈'
        when 29 then 'BS/FH 问题反馈'
        when 30 then '系统建议'
        when 31 then '申诉罚款'
        else wo.order_type
    end  工单类型
    ,wo.title 工单标题
    ,wo.created_at 创建时间
    ,wor.`created_at` 第一次工单回复时间
    ,timestampdiff(second , wo.created_at, wor.created_at) '第一次回复时长（与创建工单的时间相比）'
    ,t2.created_at 第二次回复时间
    ,timestampdiff(second, wor.created_at, t2.created_at) '第二次回复时长（与第一次的时间对比）'
    ,t3.created_at 第三次回复时间
    ,timestampdiff(second, t2.created_at, t3.created_at) '第三次回复时长（与第二次回复时间对比）'
    ,(timestampdiff(second , wo.created_at, wor.created_at) + timestampdiff(second, wor.created_at, t2.created_at) + timestampdiff(second, t2.created_at, t3.created_at))/(1 + ifnull(t2.created_at,0) + ifnull(t3.created_at,0)) '平均响应时长（每个相差间隔的平均响应时间）'
    ,wo.`closed_at`  工单关闭时间
    ,timestampdiff(second, wo.created_at, wo.closed_at) '总用时长（关闭工单的时间-创建工单的时间）'
    ,wo.`created_staff_info_id`  发起人ID
    ,hi.`name`  发起人姓名
    ,wo.created_store_id 发起人网点ID
    ,ss.`short_name`  发起人所属部门网点code
    ,ss.`name`  发起人所属部门名称
    ,wor.`staff_info_id`  第一次回复人ID
    ,hi1.`name`  第一次回复人姓名
    ,case when ss1.`category` in (1,2,10,13) then 'sp'
        when ss1.`category` in (8,9,12) then 'HUB/BHUB/OS'
        when ss1.`category` IN (4,5,7) then 'SHOP/ushop'
        when ss1.`category` IN (6)  then 'FH'when wo.`store_id` = '22' then 'kam客服中心'
        when wo.`store_id`in (3,'customer_manger') then  '总部客服中心'
        when wo.`store_id`= '12' then 'QA&QC'
        when wo.`store_id`= '18' then 'Flash Home客服中心'
        when wo.`created_store_id` = '22' and wo.`client_id` IN ('AA0302','AA0413','AA0472','AA0545','BF9675','BF9690','CA5901' ) then 'FFM'
        else '其他网点'
    end 受理部门
    ,case
        when wo.`original_acceptance_info` is null and wor.created_at is not null and  TIMESTAMPDIFF(HOUR, wo.`created_at`,wor.`created_at` )<24  then '是'
        when wo.`original_acceptance_info` is not null and wor.created_at is not null and  TIMESTAMPDIFF(HOUR, wo.`created_at`,wor.`created_at` )<72  then '是'
        else '否'
    end  是否在24小时内回复
    ,if(wor.created_at is not null and wo.`original_acceptance_info` is not null  and TIMESTAMPDIFF(HOUR, wo.`created_at`,wor.`created_at` )>48,'是','否') 是否为FH48小时超时工单
    ,TIMESTAMPDIFF(MINUTE, wo.`created_at`,wor.`created_at`) 第一次回复时长
    ,if(wt.`created_at` is not null and nwt.`created_at` is null,'是','否') 是否为工作时间创建工单
    ,case
        when wo.`original_acceptance_info` is null and wor.created_at is not null and TIMESTAMPDIFF(MINUTE, wt.`created_at`,wor.`created_at`)<40 then '是'
        when wo.`original_acceptance_info` is not null and wor.created_at is not null and TIMESTAMPDIFF(MINUTE, wt.`created_at`,wor.`created_at`)<2920 then '是'
        else '否'
    end 工作时间内创建的工单是否在40分钟内回复
    ,case
        when wo.`original_acceptance_info` is null and wor.created_at is not null and TIMESTAMPDIFF(HOUR, nwt.`created_at`,wor.`created_at` )<24 then '是'
        when wo.`original_acceptance_info` is not null and wor.created_at is not null and TIMESTAMPDIFF(HOUR, nwt.`created_at`,wor.`created_at` )<72 then '是'
        else '否'
    end 非工作时间是否在24小时内回复
    ,case
        when nwt.`tg` in (1,3) and wor.`created_at` < concat(date_add(nwt.`created_at`, interval 1 day) , ' 10:00') then '是'
        when nwt.`tg` in (2,4) and wor.`created_at` < concat(date(nwt.`created_at`), ' 10:00') then '是'
        ELSE '否'
    end as '工作时间外创建的工单是否在次日10:00前回复'
from `bi_pro`.work_order wo
left join
    ( #第一次回复
        select
            *
        from
            (
                select
                    wor.`created_at`
                    ,wor.`order_id`
                    ,wor.`staff_info_id`
                    ,row_number() over(partition by wor.`order_id` order by wor.`created_at`) rn
                from `bi_pro`.work_order_reply wor
            )wor
        where wor.rn=1
    )wor on wo.id = wor.`order_id`
left join `bi_pro`.`hr_staff_info` hi on hi.`staff_info_id` = wo.`created_staff_info_id`
left join `bi_pro`.`sys_store` ss on ss.`id` = wo.`created_store_id`
left join `bi_pro`.`hr_staff_info` hi1 on hi1.`staff_info_id` =wor.`staff_info_id`
left join `bi_pro`.`sys_store` ss1 on ss1.`id` = wo.`store_id`
left join
    (   #工作时间
        SELECT
            wo.`id`
            ,wo.`created_at`
            ,date_format(wo.`created_at`,'%w') as weekNum
        FROM `bi_pro`.work_order wo
        where
            date_format(wo.`created_at`,'%w')  between 1 and 5
            and date_format(wo.`created_at`,'1%H%i') between 11000 and 11900
            or (date_format(wo.`created_at`,'%w') in (0,6) and date_format(wo.`created_at`,'1%H%i') between 11000 and 11700)
    ) wt on wt.id = wo.id
left join
    ( #非工作时间
        select  wo.`id`
            ,wo.`created_at`
            ,date_format(wo.`created_at`,'%w') as weeknum
            ,case
                when  date_format(wo.`created_at`,'%w')  between 1 and 5 and date_format(wo.`created_at`,'1%h%i')>11900 and date_format(wo.`created_at`,'1%h%i') <10000 then '1'
                when  date_format(wo.`created_at`,'%w')  between 1 and 5 and date_format(wo.`created_at`,'1%h%i')>=10000 and date_format(wo.`created_at`,'1%h%i') <11000 then '2'
                when  date_format(wo.`created_at`,'%w') in (0,6) and date_format(wo.`created_at`,'1%h%i')>11700 and date_format(wo.`created_at`,'1%h%i') <10000 then '3'
                when  date_format(wo.`created_at`,'%w') in (0,6) and date_format(wo.`created_at`,'1%h%i')>=10000 and date_format(wo.`created_at`,'1%h%i') <11000 then '4'
            end as 'tg'
        from `bi_pro`.work_order wo
        where
            date_format(wo.`created_at`,'%w')  between 1 and 5
            and (date_format(wo.`created_at`,'1%H%i') <11000
            or date_format(wo.`created_at`,'1%H%i')>11900)
            or (date_format(wo.`created_at`,'%w') in (0,6) and (date_format(wo.`created_at`,'1%H%i') <11000 or date_format(wo.`created_at`,'1%H%i')>11700))
    ) nwt on nwt.id = wo.id
left join t t2 on t2.id = wo.id and t2.rn = 2
left join t t3 on t3.id = wo.id and t3.rn = 3
where
    wo.created_at >= date_sub(curdate(),interval 30 day)
    and wo.created_at < curdate()
    -- and wo.status < 4
    -- and wo.`created_store_id` !=1 -- 自动创建的工单
    and hi1.`node_department_id` =86
    and hi1.`state` =1
order by 7;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        wo.id
        ,wor.created_at
        ,row_number() over (partition by wo.id order by wor.created_at desc ) rn
    from bi_pro.work_order wo
    left join bi_pro.work_order_reply wor on wor.order_id = wo.id
    left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = wor.staff_info_id
    where
        wo.created_at >= date_sub(curdate(),interval 30 day)
        and wo.created_at < curdate()
        and hsi.state = 1
        and hsi.node_department_id = 86
)

SELECT
    concat('`',wo.order_no)  工单编号
    ,case wo.status when 1 then '未阅读' when 2 then '已经阅读' when 3 then '已回复' when 4 then '已关闭' end 状态
    ,wo.`client_id` 客户ID
    ,wo.`pnos`  运单号
    ,case wo.order_type
        when 1 then '查找运单'
        when 2 then '加快处理'
        when 3 then '调查员工'
        when 4 then '其他'
        when 5 then '网点信息维护提醒'
        when 6 then '培训指导'
        when 7 then '异常业务询问'
        when 8 then '包裹丢失'
        when 9 then '包裹破损'
        when 10 then '货物短少'
        when 11 then '催单'
        when 12 then '有发无到'
        when 13 then '上报包裹不在集包里'
        when 16 then '漏揽收'
        when 50 then '虚假撤销'
        when 17 then '已签收未收到'
        when 18 then '客户投诉'
        when 19 then '修改包裹信息'
        when 20 then '修改 COD 金额'
        when 21 then '解锁包裹'
        when 22 then '申请索赔'
        when 23 then 'MS 问题反馈'
        when 24 then 'FBI 问题反馈'
        when 25 then 'KA System 问题反馈'
        when 26 then 'App 问题反馈'
        when 27 then 'KIT 问题反馈'
        when 28 then 'Backyard 问题反馈'
        when 29 then 'BS/FH 问题反馈'
        when 30 then '系统建议'
        when 31 then '申诉罚款'
        else wo.order_type
    end  工单类型
    ,wo.title 工单标题
    ,wo.created_at 创建时间
    ,wor.`created_at` 第一次工单回复时间
    ,timestampdiff(second , wo.created_at, wor.created_at) '第一次回复时长（与创建工单的时间相比）'
    ,t2.created_at 第二次回复时间
    ,timestampdiff(second, wor.created_at, t2.created_at) '第二次回复时长（与第一次的时间对比）'
    ,t3.created_at 第三次回复时间
    ,timestampdiff(second, t2.created_at, t3.created_at) '第三次回复时长（与第二次回复时间对比）'
    ,(timestampdiff(second , wo.created_at, wor.created_at) + timestampdiff(second, wor.created_at, t2.created_at) + timestampdiff(second, t2.created_at, t3.created_at))/(1 + if(t2.created_at is null ,0 ,1) + if(t3.created_at is null ,0 ,1)) '平均响应时长（每个相差间隔的平均响应时间）'
    ,wo.`closed_at`  工单关闭时间
    ,timestampdiff(second, wo.created_at, wo.closed_at) '总用时长（关闭工单的时间-创建工单的时间）'
    ,wo.`created_staff_info_id`  发起人ID
    ,hi.`name`  发起人姓名
    ,wo.created_store_id 发起人网点ID
    ,ss.`short_name`  发起人所属部门网点code
    ,ss.`name`  发起人所属部门名称
    ,wor.`staff_info_id`  第一次回复人ID
    ,hi1.`name`  第一次回复人姓名
    ,case when ss1.`category` in (1,2,10,13) then 'sp'
        when ss1.`category` in (8,9,12) then 'HUB/BHUB/OS'
        when ss1.`category` IN (4,5,7) then 'SHOP/ushop'
        when ss1.`category` IN (6)  then 'FH'when wo.`store_id` = '22' then 'kam客服中心'
        when wo.`store_id`in (3,'customer_manger') then  '总部客服中心'
        when wo.`store_id`= '12' then 'QA&QC'
        when wo.`store_id`= '18' then 'Flash Home客服中心'
        when wo.`created_store_id` = '22' and wo.`client_id` IN ('AA0302','AA0413','AA0472','AA0545','BF9675','BF9690','CA5901' ) then 'FFM'
        else '其他网点'
    end 受理部门
    ,case
        when wo.`original_acceptance_info` is null and wor.created_at is not null and  TIMESTAMPDIFF(HOUR, wo.`created_at`,wor.`created_at` )<24  then '是'
        when wo.`original_acceptance_info` is not null and wor.created_at is not null and  TIMESTAMPDIFF(HOUR, wo.`created_at`,wor.`created_at` )<72  then '是'
        else '否'
    end  是否在24小时内回复
    ,if(wor.created_at is not null and wo.`original_acceptance_info` is not null  and TIMESTAMPDIFF(HOUR, wo.`created_at`,wor.`created_at` )>48,'是','否') 是否为FH48小时超时工单
    ,TIMESTAMPDIFF(MINUTE, wo.`created_at`,wor.`created_at`) 第一次回复时长
    ,if(wt.`created_at` is not null and nwt.`created_at` is null,'是','否') 是否为工作时间创建工单
    ,case
        when wo.`original_acceptance_info` is null and wor.created_at is not null and TIMESTAMPDIFF(MINUTE, wt.`created_at`,wor.`created_at`)<40 then '是'
        when wo.`original_acceptance_info` is not null and wor.created_at is not null and TIMESTAMPDIFF(MINUTE, wt.`created_at`,wor.`created_at`)<2920 then '是'
        else '否'
    end 工作时间内创建的工单是否在40分钟内回复
    ,case
        when wo.`original_acceptance_info` is null and wor.created_at is not null and TIMESTAMPDIFF(HOUR, nwt.`created_at`,wor.`created_at` )<24 then '是'
        when wo.`original_acceptance_info` is not null and wor.created_at is not null and TIMESTAMPDIFF(HOUR, nwt.`created_at`,wor.`created_at` )<72 then '是'
        else '否'
    end 非工作时间是否在24小时内回复
    ,case
        when nwt.`tg` in (1,3) and wor.`created_at` < concat(date_add(nwt.`created_at`, interval 1 day) , ' 10:00') then '是'
        when nwt.`tg` in (2,4) and wor.`created_at` < concat(date(nwt.`created_at`), ' 10:00') then '是'
        ELSE '否'
    end as '工作时间外创建的工单是否在次日10:00前回复'
from `bi_pro`.work_order wo
left join
    ( #第一次回复
        select
            *
        from
            (
                select
                    wor.`created_at`
                    ,wor.`order_id`
                    ,wor.`staff_info_id`
                    ,row_number() over(partition by wor.`order_id` order by wor.`created_at`) rn
                from `bi_pro`.work_order_reply wor
            )wor
        where wor.rn=1
    )wor on wo.id = wor.`order_id`
left join `bi_pro`.`hr_staff_info` hi on hi.`staff_info_id` = wo.`created_staff_info_id`
left join `bi_pro`.`sys_store` ss on ss.`id` = wo.`created_store_id`
left join `bi_pro`.`hr_staff_info` hi1 on hi1.`staff_info_id` =wor.`staff_info_id`
left join `bi_pro`.`sys_store` ss1 on ss1.`id` = wo.`store_id`
left join
    (   #工作时间
        SELECT
            wo.`id`
            ,wo.`created_at`
            ,date_format(wo.`created_at`,'%w') as weekNum
        FROM `bi_pro`.work_order wo
        where
            date_format(wo.`created_at`,'%w')  between 1 and 5
            and date_format(wo.`created_at`,'1%H%i') between 11000 and 11900
            or (date_format(wo.`created_at`,'%w') in (0,6) and date_format(wo.`created_at`,'1%H%i') between 11000 and 11700)
    ) wt on wt.id = wo.id
left join
    ( #非工作时间
        select  wo.`id`
            ,wo.`created_at`
            ,date_format(wo.`created_at`,'%w') as weeknum
            ,case
                when  date_format(wo.`created_at`,'%w')  between 1 and 5 and date_format(wo.`created_at`,'1%h%i')>11900 and date_format(wo.`created_at`,'1%h%i') <10000 then '1'
                when  date_format(wo.`created_at`,'%w')  between 1 and 5 and date_format(wo.`created_at`,'1%h%i')>=10000 and date_format(wo.`created_at`,'1%h%i') <11000 then '2'
                when  date_format(wo.`created_at`,'%w') in (0,6) and date_format(wo.`created_at`,'1%h%i')>11700 and date_format(wo.`created_at`,'1%h%i') <10000 then '3'
                when  date_format(wo.`created_at`,'%w') in (0,6) and date_format(wo.`created_at`,'1%h%i')>=10000 and date_format(wo.`created_at`,'1%h%i') <11000 then '4'
            end as 'tg'
        from `bi_pro`.work_order wo
        where
            date_format(wo.`created_at`,'%w')  between 1 and 5
            and (date_format(wo.`created_at`,'1%H%i') <11000
            or date_format(wo.`created_at`,'1%H%i')>11900)
            or (date_format(wo.`created_at`,'%w') in (0,6) and (date_format(wo.`created_at`,'1%H%i') <11000 or date_format(wo.`created_at`,'1%H%i')>11700))
    ) nwt on nwt.id = wo.id
left join t t2 on t2.id = wo.id and t2.rn = 2
left join t t3 on t3.id = wo.id and t3.rn = 3
where
    wo.created_at >= date_sub(curdate(),interval 30 day)
    and wo.created_at < curdate()
    -- and wo.status < 4
    -- and wo.`created_store_id` !=1 -- 自动创建的工单
    and hi1.`node_department_id` =86
    and hi1.`state` =1
order by 7;
;-- -. . -..- - / . -. - .-. -.--
select
        wo.id
        ,wor.created_at
        ,row_number() over (partition by wo.id order by wor.created_at desc ) rn
    from bi_pro.work_order wo
    left join bi_pro.work_order_reply wor on wor.order_id = wo.id
    left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = wor.staff_info_id
    where
        wo.created_at >= date_sub(curdate(),interval 30 day)
        and wo.created_at < curdate()
        and hsi.state = 1
        and hsi.node_department_id = 86
        and wo.id = '0916763113890239';
;-- -. . -..- - / . -. - .-. -.--
select
        wo.id
        ,wor.created_at
        ,row_number() over (partition by wo.id order by wor.created_at desc ) rn
    from bi_pro.work_order wo
    left join bi_pro.work_order_reply wor on wor.order_id = wo.id
    left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = wor.staff_info_id
    where
        wo.created_at >= date_sub(curdate(),interval 30 day)
        and wo.created_at < curdate()
        and hsi.state = 1
        and hsi.node_department_id = 86
        and wo.order_no = '0916763113890239';
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        wo.id
        ,wor.created_at
        ,row_number() over (partition by wo.id order by wor.created_at) rn
    from bi_pro.work_order wo
    left join bi_pro.work_order_reply wor on wor.order_id = wo.id
    left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = wor.staff_info_id
    where
        wo.created_at >= date_sub(curdate(),interval 30 day)
        and wo.created_at < curdate()
        and hsi.state = 1
        and hsi.node_department_id = 86
        and wo.order_no = '0916763113890239'
)

SELECT
    concat('`',wo.order_no)  工单编号
    ,case wo.status when 1 then '未阅读' when 2 then '已经阅读' when 3 then '已回复' when 4 then '已关闭' end 状态
    ,wo.`client_id` 客户ID
    ,wo.`pnos`  运单号
    ,case wo.order_type
        when 1 then '查找运单'
        when 2 then '加快处理'
        when 3 then '调查员工'
        when 4 then '其他'
        when 5 then '网点信息维护提醒'
        when 6 then '培训指导'
        when 7 then '异常业务询问'
        when 8 then '包裹丢失'
        when 9 then '包裹破损'
        when 10 then '货物短少'
        when 11 then '催单'
        when 12 then '有发无到'
        when 13 then '上报包裹不在集包里'
        when 16 then '漏揽收'
        when 50 then '虚假撤销'
        when 17 then '已签收未收到'
        when 18 then '客户投诉'
        when 19 then '修改包裹信息'
        when 20 then '修改 COD 金额'
        when 21 then '解锁包裹'
        when 22 then '申请索赔'
        when 23 then 'MS 问题反馈'
        when 24 then 'FBI 问题反馈'
        when 25 then 'KA System 问题反馈'
        when 26 then 'App 问题反馈'
        when 27 then 'KIT 问题反馈'
        when 28 then 'Backyard 问题反馈'
        when 29 then 'BS/FH 问题反馈'
        when 30 then '系统建议'
        when 31 then '申诉罚款'
        else wo.order_type
    end  工单类型
    ,wo.title 工单标题
    ,wo.created_at 创建时间
    ,wor.`created_at` 第一次工单回复时间
    ,timestampdiff(second , wo.created_at, wor.created_at) '第一次回复时长（与创建工单的时间相比）'
    ,t2.created_at 第二次回复时间
    ,timestampdiff(second, wor.created_at, t2.created_at) '第二次回复时长（与第一次的时间对比）'
    ,t3.created_at 第三次回复时间
    ,timestampdiff(second, t2.created_at, t3.created_at) '第三次回复时长（与第二次回复时间对比）'
    ,(timestampdiff(second , wo.created_at, wor.created_at) + timestampdiff(second, wor.created_at, t2.created_at) + timestampdiff(second, t2.created_at, t3.created_at))/(1 + if(t2.created_at is null ,0 ,1) + if(t3.created_at is null ,0 ,1)) '平均响应时长（每个相差间隔的平均响应时间）'
    ,wo.`closed_at`  工单关闭时间
    ,timestampdiff(second, wo.created_at, wo.closed_at) '总用时长（关闭工单的时间-创建工单的时间）'
    ,wo.`created_staff_info_id`  发起人ID
    ,hi.`name`  发起人姓名
    ,wo.created_store_id 发起人网点ID
    ,ss.`short_name`  发起人所属部门网点code
    ,ss.`name`  发起人所属部门名称
    ,wor.`staff_info_id`  第一次回复人ID
    ,hi1.`name`  第一次回复人姓名
    ,case when ss1.`category` in (1,2,10,13) then 'sp'
        when ss1.`category` in (8,9,12) then 'HUB/BHUB/OS'
        when ss1.`category` IN (4,5,7) then 'SHOP/ushop'
        when ss1.`category` IN (6)  then 'FH'when wo.`store_id` = '22' then 'kam客服中心'
        when wo.`store_id`in (3,'customer_manger') then  '总部客服中心'
        when wo.`store_id`= '12' then 'QA&QC'
        when wo.`store_id`= '18' then 'Flash Home客服中心'
        when wo.`created_store_id` = '22' and wo.`client_id` IN ('AA0302','AA0413','AA0472','AA0545','BF9675','BF9690','CA5901' ) then 'FFM'
        else '其他网点'
    end 受理部门
    ,case
        when wo.`original_acceptance_info` is null and wor.created_at is not null and  TIMESTAMPDIFF(HOUR, wo.`created_at`,wor.`created_at` )<24  then '是'
        when wo.`original_acceptance_info` is not null and wor.created_at is not null and  TIMESTAMPDIFF(HOUR, wo.`created_at`,wor.`created_at` )<72  then '是'
        else '否'
    end  是否在24小时内回复
    ,if(wor.created_at is not null and wo.`original_acceptance_info` is not null  and TIMESTAMPDIFF(HOUR, wo.`created_at`,wor.`created_at` )>48,'是','否') 是否为FH48小时超时工单
    ,TIMESTAMPDIFF(MINUTE, wo.`created_at`,wor.`created_at`) 第一次回复时长
    ,if(wt.`created_at` is not null and nwt.`created_at` is null,'是','否') 是否为工作时间创建工单
    ,case
        when wo.`original_acceptance_info` is null and wor.created_at is not null and TIMESTAMPDIFF(MINUTE, wt.`created_at`,wor.`created_at`)<40 then '是'
        when wo.`original_acceptance_info` is not null and wor.created_at is not null and TIMESTAMPDIFF(MINUTE, wt.`created_at`,wor.`created_at`)<2920 then '是'
        else '否'
    end 工作时间内创建的工单是否在40分钟内回复
    ,case
        when wo.`original_acceptance_info` is null and wor.created_at is not null and TIMESTAMPDIFF(HOUR, nwt.`created_at`,wor.`created_at` )<24 then '是'
        when wo.`original_acceptance_info` is not null and wor.created_at is not null and TIMESTAMPDIFF(HOUR, nwt.`created_at`,wor.`created_at` )<72 then '是'
        else '否'
    end 非工作时间是否在24小时内回复
    ,case
        when nwt.`tg` in (1,3) and wor.`created_at` < concat(date_add(nwt.`created_at`, interval 1 day) , ' 10:00') then '是'
        when nwt.`tg` in (2,4) and wor.`created_at` < concat(date(nwt.`created_at`), ' 10:00') then '是'
        ELSE '否'
    end as '工作时间外创建的工单是否在次日10:00前回复'
from `bi_pro`.work_order wo
left join
    ( #第一次回复
        select
            *
        from
            (
                select
                    wor.`created_at`
                    ,wor.`order_id`
                    ,wor.`staff_info_id`
                    ,row_number() over(partition by wor.`order_id` order by wor.`created_at`) rn
                from `bi_pro`.work_order_reply wor
            )wor
        where wor.rn=1
    )wor on wo.id = wor.`order_id`
left join `bi_pro`.`hr_staff_info` hi on hi.`staff_info_id` = wo.`created_staff_info_id`
left join `bi_pro`.`sys_store` ss on ss.`id` = wo.`created_store_id`
left join `bi_pro`.`hr_staff_info` hi1 on hi1.`staff_info_id` =wor.`staff_info_id`
left join `bi_pro`.`sys_store` ss1 on ss1.`id` = wo.`store_id`
left join
    (   #工作时间
        SELECT
            wo.`id`
            ,wo.`created_at`
            ,date_format(wo.`created_at`,'%w') as weekNum
        FROM `bi_pro`.work_order wo
        where
            date_format(wo.`created_at`,'%w')  between 1 and 5
            and date_format(wo.`created_at`,'1%H%i') between 11000 and 11900
            or (date_format(wo.`created_at`,'%w') in (0,6) and date_format(wo.`created_at`,'1%H%i') between 11000 and 11700)
    ) wt on wt.id = wo.id
left join
    ( #非工作时间
        select  wo.`id`
            ,wo.`created_at`
            ,date_format(wo.`created_at`,'%w') as weeknum
            ,case
                when  date_format(wo.`created_at`,'%w')  between 1 and 5 and date_format(wo.`created_at`,'1%h%i')>11900 and date_format(wo.`created_at`,'1%h%i') <10000 then '1'
                when  date_format(wo.`created_at`,'%w')  between 1 and 5 and date_format(wo.`created_at`,'1%h%i')>=10000 and date_format(wo.`created_at`,'1%h%i') <11000 then '2'
                when  date_format(wo.`created_at`,'%w') in (0,6) and date_format(wo.`created_at`,'1%h%i')>11700 and date_format(wo.`created_at`,'1%h%i') <10000 then '3'
                when  date_format(wo.`created_at`,'%w') in (0,6) and date_format(wo.`created_at`,'1%h%i')>=10000 and date_format(wo.`created_at`,'1%h%i') <11000 then '4'
            end as 'tg'
        from `bi_pro`.work_order wo
        where
            date_format(wo.`created_at`,'%w')  between 1 and 5
            and (date_format(wo.`created_at`,'1%H%i') <11000
            or date_format(wo.`created_at`,'1%H%i')>11900)
            or (date_format(wo.`created_at`,'%w') in (0,6) and (date_format(wo.`created_at`,'1%H%i') <11000 or date_format(wo.`created_at`,'1%H%i')>11700))
    ) nwt on nwt.id = wo.id
left join t t2 on t2.id = wo.id and t2.rn = 2
left join t t3 on t3.id = wo.id and t3.rn = 3
where
    wo.created_at >= date_sub(curdate(),interval 30 day)
    and wo.created_at < curdate()
    -- and wo.status < 4
    -- and wo.`created_store_id` !=1 -- 自动创建的工单
    and hi1.`node_department_id` =86
    and hi1.`state` =1
order by 7;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        wo.id
        ,wor.created_at
        ,row_number() over (partition by wo.id order by wor.created_at) rn
    from bi_pro.work_order wo
    left join bi_pro.work_order_reply wor on wor.order_id = wo.id
    left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = wor.staff_info_id
    where
        wo.created_at >= date_sub(curdate(),interval 30 day)
        and wo.created_at < curdate()
        and hsi.state = 1
        and hsi.node_department_id = 86
        and wo.order_no = '0916763113890239'
)

SELECT
    concat('`',wo.order_no)  工单编号
    ,case wo.status when 1 then '未阅读' when 2 then '已经阅读' when 3 then '已回复' when 4 then '已关闭' end 状态
    ,wo.`client_id` 客户ID
    ,wo.`pnos`  运单号
    ,case wo.order_type
        when 1 then '查找运单'
        when 2 then '加快处理'
        when 3 then '调查员工'
        when 4 then '其他'
        when 5 then '网点信息维护提醒'
        when 6 then '培训指导'
        when 7 then '异常业务询问'
        when 8 then '包裹丢失'
        when 9 then '包裹破损'
        when 10 then '货物短少'
        when 11 then '催单'
        when 12 then '有发无到'
        when 13 then '上报包裹不在集包里'
        when 16 then '漏揽收'
        when 50 then '虚假撤销'
        when 17 then '已签收未收到'
        when 18 then '客户投诉'
        when 19 then '修改包裹信息'
        when 20 then '修改 COD 金额'
        when 21 then '解锁包裹'
        when 22 then '申请索赔'
        when 23 then 'MS 问题反馈'
        when 24 then 'FBI 问题反馈'
        when 25 then 'KA System 问题反馈'
        when 26 then 'App 问题反馈'
        when 27 then 'KIT 问题反馈'
        when 28 then 'Backyard 问题反馈'
        when 29 then 'BS/FH 问题反馈'
        when 30 then '系统建议'
        when 31 then '申诉罚款'
        else wo.order_type
    end  工单类型
    ,wo.title 工单标题
    ,wo.created_at 创建时间
    ,wor.`created_at` 第一次工单回复时间
    ,timestampdiff(second , wo.created_at, wor.created_at) '第一次回复时长（与创建工单的时间相比）'
    ,t2.created_at 第二次回复时间
    ,timestampdiff(second, wor.created_at, t2.created_at) '第二次回复时长（与第一次的时间对比）'
    ,t3.created_at 第三次回复时间
    ,timestampdiff(second, t2.created_at, t3.created_at) '第三次回复时长（与第二次回复时间对比）'
    ,(timestampdiff(second , wo.created_at, wor.created_at) + ifnull(timestampdiff(second, wor.created_at, t2.created_at), 0) + ifnull(timestampdiff(second, t2.created_at, t3.created_at), 0))/(1 + if(t2.created_at is null ,0 ,1) + if(t3.created_at is null ,0 ,1)) '平均响应时长（每个相差间隔的平均响应时间）'
    ,wo.`closed_at`  工单关闭时间
    ,timestampdiff(second, wo.created_at, wo.closed_at) '总用时长（关闭工单的时间-创建工单的时间）'
    ,wo.`created_staff_info_id`  发起人ID
    ,hi.`name`  发起人姓名
    ,wo.created_store_id 发起人网点ID
    ,ss.`short_name`  发起人所属部门网点code
    ,ss.`name`  发起人所属部门名称
    ,wor.`staff_info_id`  第一次回复人ID
    ,hi1.`name`  第一次回复人姓名
    ,case when ss1.`category` in (1,2,10,13) then 'sp'
        when ss1.`category` in (8,9,12) then 'HUB/BHUB/OS'
        when ss1.`category` IN (4,5,7) then 'SHOP/ushop'
        when ss1.`category` IN (6)  then 'FH'when wo.`store_id` = '22' then 'kam客服中心'
        when wo.`store_id`in (3,'customer_manger') then  '总部客服中心'
        when wo.`store_id`= '12' then 'QA&QC'
        when wo.`store_id`= '18' then 'Flash Home客服中心'
        when wo.`created_store_id` = '22' and wo.`client_id` IN ('AA0302','AA0413','AA0472','AA0545','BF9675','BF9690','CA5901' ) then 'FFM'
        else '其他网点'
    end 受理部门
    ,case
        when wo.`original_acceptance_info` is null and wor.created_at is not null and  TIMESTAMPDIFF(HOUR, wo.`created_at`,wor.`created_at` )<24  then '是'
        when wo.`original_acceptance_info` is not null and wor.created_at is not null and  TIMESTAMPDIFF(HOUR, wo.`created_at`,wor.`created_at` )<72  then '是'
        else '否'
    end  是否在24小时内回复
    ,if(wor.created_at is not null and wo.`original_acceptance_info` is not null  and TIMESTAMPDIFF(HOUR, wo.`created_at`,wor.`created_at` )>48,'是','否') 是否为FH48小时超时工单
    ,TIMESTAMPDIFF(MINUTE, wo.`created_at`,wor.`created_at`) 第一次回复时长
    ,if(wt.`created_at` is not null and nwt.`created_at` is null,'是','否') 是否为工作时间创建工单
    ,case
        when wo.`original_acceptance_info` is null and wor.created_at is not null and TIMESTAMPDIFF(MINUTE, wt.`created_at`,wor.`created_at`)<40 then '是'
        when wo.`original_acceptance_info` is not null and wor.created_at is not null and TIMESTAMPDIFF(MINUTE, wt.`created_at`,wor.`created_at`)<2920 then '是'
        else '否'
    end 工作时间内创建的工单是否在40分钟内回复
    ,case
        when wo.`original_acceptance_info` is null and wor.created_at is not null and TIMESTAMPDIFF(HOUR, nwt.`created_at`,wor.`created_at` )<24 then '是'
        when wo.`original_acceptance_info` is not null and wor.created_at is not null and TIMESTAMPDIFF(HOUR, nwt.`created_at`,wor.`created_at` )<72 then '是'
        else '否'
    end 非工作时间是否在24小时内回复
    ,case
        when nwt.`tg` in (1,3) and wor.`created_at` < concat(date_add(nwt.`created_at`, interval 1 day) , ' 10:00') then '是'
        when nwt.`tg` in (2,4) and wor.`created_at` < concat(date(nwt.`created_at`), ' 10:00') then '是'
        ELSE '否'
    end as '工作时间外创建的工单是否在次日10:00前回复'
from `bi_pro`.work_order wo
left join
    ( #第一次回复
        select
            *
        from
            (
                select
                    wor.`created_at`
                    ,wor.`order_id`
                    ,wor.`staff_info_id`
                    ,row_number() over(partition by wor.`order_id` order by wor.`created_at`) rn
                from `bi_pro`.work_order_reply wor
            )wor
        where wor.rn=1
    )wor on wo.id = wor.`order_id`
left join `bi_pro`.`hr_staff_info` hi on hi.`staff_info_id` = wo.`created_staff_info_id`
left join `bi_pro`.`sys_store` ss on ss.`id` = wo.`created_store_id`
left join `bi_pro`.`hr_staff_info` hi1 on hi1.`staff_info_id` =wor.`staff_info_id`
left join `bi_pro`.`sys_store` ss1 on ss1.`id` = wo.`store_id`
left join
    (   #工作时间
        SELECT
            wo.`id`
            ,wo.`created_at`
            ,date_format(wo.`created_at`,'%w') as weekNum
        FROM `bi_pro`.work_order wo
        where
            date_format(wo.`created_at`,'%w')  between 1 and 5
            and date_format(wo.`created_at`,'1%H%i') between 11000 and 11900
            or (date_format(wo.`created_at`,'%w') in (0,6) and date_format(wo.`created_at`,'1%H%i') between 11000 and 11700)
    ) wt on wt.id = wo.id
left join
    ( #非工作时间
        select  wo.`id`
            ,wo.`created_at`
            ,date_format(wo.`created_at`,'%w') as weeknum
            ,case
                when  date_format(wo.`created_at`,'%w')  between 1 and 5 and date_format(wo.`created_at`,'1%h%i')>11900 and date_format(wo.`created_at`,'1%h%i') <10000 then '1'
                when  date_format(wo.`created_at`,'%w')  between 1 and 5 and date_format(wo.`created_at`,'1%h%i')>=10000 and date_format(wo.`created_at`,'1%h%i') <11000 then '2'
                when  date_format(wo.`created_at`,'%w') in (0,6) and date_format(wo.`created_at`,'1%h%i')>11700 and date_format(wo.`created_at`,'1%h%i') <10000 then '3'
                when  date_format(wo.`created_at`,'%w') in (0,6) and date_format(wo.`created_at`,'1%h%i')>=10000 and date_format(wo.`created_at`,'1%h%i') <11000 then '4'
            end as 'tg'
        from `bi_pro`.work_order wo
        where
            date_format(wo.`created_at`,'%w')  between 1 and 5
            and (date_format(wo.`created_at`,'1%H%i') <11000
            or date_format(wo.`created_at`,'1%H%i')>11900)
            or (date_format(wo.`created_at`,'%w') in (0,6) and (date_format(wo.`created_at`,'1%H%i') <11000 or date_format(wo.`created_at`,'1%H%i')>11700))
    ) nwt on nwt.id = wo.id
left join t t2 on t2.id = wo.id and t2.rn = 2
left join t t3 on t3.id = wo.id and t3.rn = 3
where
    wo.created_at >= date_sub(curdate(),interval 30 day)
    and wo.created_at < curdate()
    -- and wo.status < 4
    -- and wo.`created_store_id` !=1 -- 自动创建的工单
    and hi1.`node_department_id` =86
    and hi1.`state` =1
order by 7;
;-- -. . -..- - / . -. - .-. -.--
select
    t.pno
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
    ,pd.last_route_action
from fle_staging.parcel_info pi
join tmpale.tmp_th_pno_0316 t on t.pno = pi.pno
left join bi_pro.parcel_detail pd on pd.pno = pi.pno;
;-- -. . -..- - / . -. - .-. -.--
select
    t.pno
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
#     ,pd.last_route_action
from fle_staging.parcel_info pi
join tmpale.tmp_th_pno_0316 t on t.pno = pi.pno;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
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
#     ,pd.last_route_action
from fle_staging.parcel_info pi
# join tmpale.tmp_th_pno_0316 t on t.pno = pi.pno
# left join bi_pro.parcel_detail pd on pd.pno = pi.pno
where
    pi.pno in ('TH01043PNDWZ1B', 'TH01273UK0EU8D', 'TH04033PW36Y7A1', 'TH04033RZ7668A1', 'TH10033SAVRJ7K', 'TH10033SUC0X2K', 'TH10033TXAD56K', 'TH10033U71897B', 'TH10033UFG3N5K', 'TH20083HC5138B', 'TH24103N8JDW1B', 'TH67023QZ3T32C', 'THT01052B5HB8Z', 'THT01052CNZY9Z', 'THT013413GF97Z', 'THT04032CC0K2Z', 'THT05062FRFC5Z', 'THT67012B7QC9Z', 'THT67012BSNV5Z', 'THT67012D6ZS7Z', 'TH10033U4XZ40A', 'TH20083UK3EZ5C', 'TH20073VC6FB0B', 'TH04033QUZ5V4A1', 'TH04073PWE6P8K', 'TH20073RSMND0D', 'TH04013GY3C64I', 'TH20043V98EG4B', 'TH20073JYJBK0B', 'THT650120NF71Z', 'TH68043RH64Y2F', 'THT56107V97H3Z', 'TH10033U2S8P9P', 'TH67013QENWT9G', 'THT24011NRU87Z', 'TH33023BBP1E3C', 'TH27013TZ6TA5K', 'TH75103W3HT99C', 'TH01213Q1MTZ4A', 'TH21013VDNK97F', 'TH67013R9Y5R7H', 'TH20073EDGWN5B', 'TH01392WH3Y51B', 'THT15011KGTN6Z', 'TH01403RBZ4R0B0', 'THT20047PEQV5Z', 'TH04073PGWAK2A', 'TH04073KDUAG8K', 'TH10113V8QYG1A', 'TH68043RC3SC6F', 'TH19033UZXT74E', 'TH67013SBFDW1E', 'TH24033B29S10A', 'TH10113VE2B37B', 'TH01053VJQJW6B', 'TH04033JM5CD0A1', 'THT71057SC549Z', 'TH16013MVTPU0L', 'TH04073RKWXH4K-3', 'TH67013S01764H', 'TH21063UYU0U8A', 'TH67013RTA7W9G', 'TH68043S5REX1F', 'THT66021EQRK7Z', 'TH01373V58QS1C', 'TH63083SYPJ90B', 'TH10043VBWR22C', 'TH04073MWHYG9J', 'TH20083S5PKJ5A', 'TH20043VEAQT1E', 'TH67033V05572F', 'THT05062HBHQ8Z', 'TH70043V92E25K', 'TH66023HTTY82C', 'TH04033RDGXM9A1', 'THT0131BVKG9Z', 'THT670126BE69Z', 'TH20083UZXEQ8B', 'TH15013QRRZQ1O', 'TH20073K2ZRE7A', 'TH01403UU4SC8B0', 'TH01293BGQRC4A', 'THT04037PNHT5Z', 'THT1501148ZE3Z', 'THT24021P92A8Z', 'TH44113TG15V3B', 'TH01303VBEWY7A', 'TH04033QHGVW9A1', 'TH01283S8VQT3B1', 'TH67023H02DF9C', 'TH48013VEKGV1I', 'TH67013RJVPA6G', 'TH01203T5GA33B', 'TH67013R20E90G', 'TH24113MFMC47E', 'TH04063T1FT27C', 'TH24113MKGAC4C', 'TH20013NXYCJ2F', 'TH01403TSSVG6B0', 'TH67013S6V0Q7H', 'TH01373TXWYE9B', 'TH68043RPYAK0F', 'TH67033V9BEA2D', 'TH20073PG9TU9C', 'TH67013N36E68G', 'TH66023TKXTG3C', 'TH01203N984F1C', 'TH47133SX04K8I', 'TH70083PYRGK4B', 'TH20053TS9VJ3B', 'TH22043B4DTK7D', 'THT20047XU831Z', 'TH10033VEZ3P2E', 'TH20043V84MX7A', 'TH01393V87RF4E', 'TH67013RSN591H', 'TH01393HRZWK9F', 'TH26073U6VA98D', 'TH67013RVEBQ8G', 'TH04033TF7D09A1', 'TH20043HCS5Z3B1', 'TH01153NH7921A', 'THT24011M7TK4Z', 'TH61023TVVA45C', 'TH67013RMVS53G', 'TH670132JD7Q7E', 'TH67013RF6KH8G', 'TH05033TPS9X9C', 'TH37013VZ99E1A', 'TH68043RB4GT6F', 'TH32013CAU8M7A', 'TH61083B18GD8H', 'TH68043RTRX38F', 'TH71033UVTUJ9M', 'TH68043REJAX8F', 'TH67033R54H76F', 'TH67033EPWJ62A', 'TH11013R98463A', 'TH01053VA3JN1B', 'TH01303VESAU3C', 'TH02063J4EF95A0', 'TH01233S2KZ84E', 'LEXDO0057480603', 'TH01473TB4BH5B', 'TH67023R47AN0A', 'TH20073J9STN5E0', 'TH01053J3CGZ0C', 'TH01413VJ2J70B', 'TH70033UTT9C4D', 'TH20043DJX794A', 'TH20043RYW746H', 'SSLT730005611450', 'TH20043DN7JD3C', 'TH20043UU8DM1A', 'TH67013RNH7U2H', 'TH03043VCWQZ9H', 'TH01403RME2H7B0', 'TH01473UYWWS3A', 'TH20043UG13X3D', 'TH04033SA8UM9A1', 'TH01413VCJ0B1B', 'TH01403RCG2Z8B0', 'TH01273TEMWW7D', 'TH01503RY1FM6B0', 'TH64013HS07V7L', 'THT20047RMPP8Z', 'TH26073UFH341D', 'THT05032JPU55Z', 'TH20073JUV2C1B', 'TH67013RVCHB5G', 'TH24023VBEX45H', 'TH67013TBU433G', 'TH67013SWKQ56G', 'TH02023TETZ56D', 'THT21017R76C8Z', 'TH67013RTBG03G', 'TH20073RWG952E', 'THT54111Y05S5Z', 'TH01373V3N4T2B', 'TH67013RWV669H', 'TH01203RGB9T4B', 'THT20047RFJA9Z', 'TH64013E35UV5N', 'TH05063UAA8V7D', 'TH03043VDRPD3H', 'TH67013RH96T3G', 'TH04033TQE5B2A0', 'TH68043REV5B2F', 'TH15013QS6KP7O', 'TH67023RN22C5B', 'TH20083VF0UN0B', 'TH09013RNABW5D', 'TH02063UA32D7A', 'TH01213TPZH03A', 'TH68043RMVUJ0F', 'TH33053UWG5Q1C', 'THT0403KYNR5Z', 'TH02063T0QV55A', 'TH20043VEBBY8A', 'TH67013QXE7A7H', 'THT030122HJK2Z', 'TH10113V4QZ57B', 'TH63053KMKF75J', 'THT21012462Z5Z', 'TH67013SK64G8E', 'TH65013TY1KY1H', 'TH01073TUT8A9A', 'TH70083R9YWY5C', 'FLACB02017460937', 'TH01473UFV758B', 'TH10113UVYV98B', 'TH56023BQBZM8H', 'TH67013RH7VC8H', 'TH01213SJDJG6A', 'TH66023KG2X04C', 'TH21013V23S27C', 'TH01373JKRJ54B', 'THT56027XXEN0Z', 'TH66023J06CX6C', 'TH24023N0S583F', 'TH68043R62UJ9F', 'TH24043V2QUQ7D', 'TH67013SU38Q9G', 'TH67013RWBXK7G', 'TH68043RFPHE5F', 'TH65013MKY0M5G', 'TH10033VEA2Z4I', 'TH04033S62PK5A0', 'TH10033VDZBU2E', 'TH67013QQUSD5G', 'TH10033UAHNR6P', 'TH013932659B4G', 'TH01163UWSH23A0', 'TH01183VDZTS6A0', 'THT03022HC7C4Z', 'TH21013UUG723F', 'TH05033VB0VS9C', 'TH68043RMT4M6F', 'TH01373V3NEC0B', 'TH67013RVGR36G', 'TH55033K9VAG8B', 'TH01423UPVN92A', 'THT01407R38E5Z', 'TH10033V3HKC0Q', 'TH01473VBCC06C', 'TH65013SKH3W4H', 'TH67013Q87KT5H', 'TH01183RVDKX7A1', 'TH66023KJ79Z8C', 'TH67023HRZHJ8C', 'TH02043T5RW63O', 'TH10113VASDZ8B', 'TH05033U23QE7B', 'TH21063Q8GYK3A', 'TH05033USZTC8I', 'TH67013RPBH03G', 'TH20073JSVJK6B', 'LEXPU0180148516', 'TH67013RSGT12H', 'TH01393VJFQZ4B', 'TH47013U4XUC1C', 'THT67022AU899Z', 'TH67013RV5G61G', 'THT21062BHSV7Z', 'TH05033UH8NQ3G', 'SSLT730006233687', 'TH26073UZ34E7A', 'THT01407QXC36Z', 'TH74043V9FJX5C', 'TH10043VGDEP0E', 'TH12033VA3MD1B', 'TH20073HW5T27B', 'TH01273GJFNC3D', 'TH67013K54Q24B', 'TH05033UQWPU5J', 'TH02063FA2E71A-1', 'TH04033RMX396A1', 'TH20043CPU6J9B0', 'TH20083U2QAV3B', 'TH13133TYY7Q9D', 'TH20043V95CS6G', 'THT21017U94Y0Z', 'TH40053NCX632D', 'TH02063CAA6C8A', 'TH13023RM3PV2A-1', 'THT21062BDX08Z', 'THT01407RXMJ4Z', 'TH20073JJQWU7B', 'TH01373VNA8B8B', 'TH20083W61SP1D', 'TH01423U1JGS6A', 'TH24013NB1705L', 'TH20043V3D3C0D', 'TH24023VBBN50H', 'TH10113UXGYB2D', 'TH68043U88W11E', 'TH67013P6RCW6E', 'TH10033R2TZE6E', 'TH15063SJVGM1H', 'TH68043R5JS62F', 'TH10033V87PV6A', 'THT20047RDFW5Z', 'TH62013TA49W5A', 'TH10033UUGHX4B', 'THT21017R6VD6Z', 'TH20043DWPDU5C', 'TH01373V3R8A4C', 'TH15063HW76U7J', 'TH66013U1W973H', 'THT66021EHQ63Z', 'TH20043U2DVU4C', 'TH01473U1G967B', 'TH65023Q1S356B', 'TH20073HTQW31A', 'TH67013RTBKY5G', 'TH70083TSXUF4B', 'TH01473UWFFM3B', 'TH20073RWG991E', 'TH01143S2H0A2E', 'TH65053Q78UG5E', 'TH04073S5UH49C', 'TH01303VE0S29A', 'TH01373UB3D82C', 'TH60033PV8G64B', 'TH04063MQU3G4A1', 'THT20087P7NW5Z', 'TH01303SDDTP2C', 'TH10033UHG168B', 'TH26073UY1ZM1A', 'SSLT730006651767', 'TH01303EJW0H8A', 'TH66023M0BQ69C', 'THT20042G8989Z', 'TH20043UQCNT9D', 'TH67033SWMKH7C', '7110015818354', 'TH01373E7VJ83A', 'TH01403UUJGZ3B0', 'TH67023U39PJ7C', 'TH01473VJW806A', 'TH10113V5SA56B', 'THT20042HTNU4Z', 'TH38013CVWVA6A0', 'TH16033BJJFT0C', 'TH67033QAHVX6F', 'TH68043RGX702F', 'TH10113UQSBM7B', 'TH01423TNP7F6A', 'TH26063BFXQ89A', 'TH05063VDKN39F', 'TH04063V87RJ2E', 'TH04033V8HM87A1');
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
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
    ,pd.last_route_action
from fle_staging.parcel_info pi
# join tmpale.tmp_th_pno_0316 t on t.pno = pi.pno
left join bi_pro.parcel_detail pd on pd.pno = pi.pno
where
    pi.pno in ('TH01043PNDWZ1B', 'TH01273UK0EU8D', 'TH04033PW36Y7A1', 'TH04033RZ7668A1', 'TH10033SAVRJ7K', 'TH10033SUC0X2K', 'TH10033TXAD56K', 'TH10033U71897B', 'TH10033UFG3N5K', 'TH20083HC5138B', 'TH24103N8JDW1B', 'TH67023QZ3T32C', 'THT01052B5HB8Z', 'THT01052CNZY9Z', 'THT013413GF97Z', 'THT04032CC0K2Z', 'THT05062FRFC5Z', 'THT67012B7QC9Z', 'THT67012BSNV5Z', 'THT67012D6ZS7Z', 'TH10033U4XZ40A', 'TH20083UK3EZ5C', 'TH20073VC6FB0B', 'TH04033QUZ5V4A1', 'TH04073PWE6P8K', 'TH20073RSMND0D', 'TH04013GY3C64I', 'TH20043V98EG4B', 'TH20073JYJBK0B', 'THT650120NF71Z', 'TH68043RH64Y2F', 'THT56107V97H3Z', 'TH10033U2S8P9P', 'TH67013QENWT9G', 'THT24011NRU87Z', 'TH33023BBP1E3C', 'TH27013TZ6TA5K', 'TH75103W3HT99C', 'TH01213Q1MTZ4A', 'TH21013VDNK97F', 'TH67013R9Y5R7H', 'TH20073EDGWN5B', 'TH01392WH3Y51B', 'THT15011KGTN6Z', 'TH01403RBZ4R0B0', 'THT20047PEQV5Z', 'TH04073PGWAK2A', 'TH04073KDUAG8K', 'TH10113V8QYG1A', 'TH68043RC3SC6F', 'TH19033UZXT74E', 'TH67013SBFDW1E', 'TH24033B29S10A', 'TH10113VE2B37B', 'TH01053VJQJW6B', 'TH04033JM5CD0A1', 'THT71057SC549Z', 'TH16013MVTPU0L', 'TH04073RKWXH4K-3', 'TH67013S01764H', 'TH21063UYU0U8A', 'TH67013RTA7W9G', 'TH68043S5REX1F', 'THT66021EQRK7Z', 'TH01373V58QS1C', 'TH63083SYPJ90B', 'TH10043VBWR22C', 'TH04073MWHYG9J', 'TH20083S5PKJ5A', 'TH20043VEAQT1E', 'TH67033V05572F', 'THT05062HBHQ8Z', 'TH70043V92E25K', 'TH66023HTTY82C', 'TH04033RDGXM9A1', 'THT0131BVKG9Z', 'THT670126BE69Z', 'TH20083UZXEQ8B', 'TH15013QRRZQ1O', 'TH20073K2ZRE7A', 'TH01403UU4SC8B0', 'TH01293BGQRC4A', 'THT04037PNHT5Z', 'THT1501148ZE3Z', 'THT24021P92A8Z', 'TH44113TG15V3B', 'TH01303VBEWY7A', 'TH04033QHGVW9A1', 'TH01283S8VQT3B1', 'TH67023H02DF9C', 'TH48013VEKGV1I', 'TH67013RJVPA6G', 'TH01203T5GA33B', 'TH67013R20E90G', 'TH24113MFMC47E', 'TH04063T1FT27C', 'TH24113MKGAC4C', 'TH20013NXYCJ2F', 'TH01403TSSVG6B0', 'TH67013S6V0Q7H', 'TH01373TXWYE9B', 'TH68043RPYAK0F', 'TH67033V9BEA2D', 'TH20073PG9TU9C', 'TH67013N36E68G', 'TH66023TKXTG3C', 'TH01203N984F1C', 'TH47133SX04K8I', 'TH70083PYRGK4B', 'TH20053TS9VJ3B', 'TH22043B4DTK7D', 'THT20047XU831Z', 'TH10033VEZ3P2E', 'TH20043V84MX7A', 'TH01393V87RF4E', 'TH67013RSN591H', 'TH01393HRZWK9F', 'TH26073U6VA98D', 'TH67013RVEBQ8G', 'TH04033TF7D09A1', 'TH20043HCS5Z3B1', 'TH01153NH7921A', 'THT24011M7TK4Z', 'TH61023TVVA45C', 'TH67013RMVS53G', 'TH670132JD7Q7E', 'TH67013RF6KH8G', 'TH05033TPS9X9C', 'TH37013VZ99E1A', 'TH68043RB4GT6F', 'TH32013CAU8M7A', 'TH61083B18GD8H', 'TH68043RTRX38F', 'TH71033UVTUJ9M', 'TH68043REJAX8F', 'TH67033R54H76F', 'TH67033EPWJ62A', 'TH11013R98463A', 'TH01053VA3JN1B', 'TH01303VESAU3C', 'TH02063J4EF95A0', 'TH01233S2KZ84E', 'LEXDO0057480603', 'TH01473TB4BH5B', 'TH67023R47AN0A', 'TH20073J9STN5E0', 'TH01053J3CGZ0C', 'TH01413VJ2J70B', 'TH70033UTT9C4D', 'TH20043DJX794A', 'TH20043RYW746H', 'SSLT730005611450', 'TH20043DN7JD3C', 'TH20043UU8DM1A', 'TH67013RNH7U2H', 'TH03043VCWQZ9H', 'TH01403RME2H7B0', 'TH01473UYWWS3A', 'TH20043UG13X3D', 'TH04033SA8UM9A1', 'TH01413VCJ0B1B', 'TH01403RCG2Z8B0', 'TH01273TEMWW7D', 'TH01503RY1FM6B0', 'TH64013HS07V7L', 'THT20047RMPP8Z', 'TH26073UFH341D', 'THT05032JPU55Z', 'TH20073JUV2C1B', 'TH67013RVCHB5G', 'TH24023VBEX45H', 'TH67013TBU433G', 'TH67013SWKQ56G', 'TH02023TETZ56D', 'THT21017R76C8Z', 'TH67013RTBG03G', 'TH20073RWG952E', 'THT54111Y05S5Z', 'TH01373V3N4T2B', 'TH67013RWV669H', 'TH01203RGB9T4B', 'THT20047RFJA9Z', 'TH64013E35UV5N', 'TH05063UAA8V7D', 'TH03043VDRPD3H', 'TH67013RH96T3G', 'TH04033TQE5B2A0', 'TH68043REV5B2F', 'TH15013QS6KP7O', 'TH67023RN22C5B', 'TH20083VF0UN0B', 'TH09013RNABW5D', 'TH02063UA32D7A', 'TH01213TPZH03A', 'TH68043RMVUJ0F', 'TH33053UWG5Q1C', 'THT0403KYNR5Z', 'TH02063T0QV55A', 'TH20043VEBBY8A', 'TH67013QXE7A7H', 'THT030122HJK2Z', 'TH10113V4QZ57B', 'TH63053KMKF75J', 'THT21012462Z5Z', 'TH67013SK64G8E', 'TH65013TY1KY1H', 'TH01073TUT8A9A', 'TH70083R9YWY5C', 'FLACB02017460937', 'TH01473UFV758B', 'TH10113UVYV98B', 'TH56023BQBZM8H', 'TH67013RH7VC8H', 'TH01213SJDJG6A', 'TH66023KG2X04C', 'TH21013V23S27C', 'TH01373JKRJ54B', 'THT56027XXEN0Z', 'TH66023J06CX6C', 'TH24023N0S583F', 'TH68043R62UJ9F', 'TH24043V2QUQ7D', 'TH67013SU38Q9G', 'TH67013RWBXK7G', 'TH68043RFPHE5F', 'TH65013MKY0M5G', 'TH10033VEA2Z4I', 'TH04033S62PK5A0', 'TH10033VDZBU2E', 'TH67013QQUSD5G', 'TH10033UAHNR6P', 'TH013932659B4G', 'TH01163UWSH23A0', 'TH01183VDZTS6A0', 'THT03022HC7C4Z', 'TH21013UUG723F', 'TH05033VB0VS9C', 'TH68043RMT4M6F', 'TH01373V3NEC0B', 'TH67013RVGR36G', 'TH55033K9VAG8B', 'TH01423UPVN92A', 'THT01407R38E5Z', 'TH10033V3HKC0Q', 'TH01473VBCC06C', 'TH65013SKH3W4H', 'TH67013Q87KT5H', 'TH01183RVDKX7A1', 'TH66023KJ79Z8C', 'TH67023HRZHJ8C', 'TH02043T5RW63O', 'TH10113VASDZ8B', 'TH05033U23QE7B', 'TH21063Q8GYK3A', 'TH05033USZTC8I', 'TH67013RPBH03G', 'TH20073JSVJK6B', 'LEXPU0180148516', 'TH67013RSGT12H', 'TH01393VJFQZ4B', 'TH47013U4XUC1C', 'THT67022AU899Z', 'TH67013RV5G61G', 'THT21062BHSV7Z', 'TH05033UH8NQ3G', 'SSLT730006233687', 'TH26073UZ34E7A', 'THT01407QXC36Z', 'TH74043V9FJX5C', 'TH10043VGDEP0E', 'TH12033VA3MD1B', 'TH20073HW5T27B', 'TH01273GJFNC3D', 'TH67013K54Q24B', 'TH05033UQWPU5J', 'TH02063FA2E71A-1', 'TH04033RMX396A1', 'TH20043CPU6J9B0', 'TH20083U2QAV3B', 'TH13133TYY7Q9D', 'TH20043V95CS6G', 'THT21017U94Y0Z', 'TH40053NCX632D', 'TH02063CAA6C8A', 'TH13023RM3PV2A-1', 'THT21062BDX08Z', 'THT01407RXMJ4Z', 'TH20073JJQWU7B', 'TH01373VNA8B8B', 'TH20083W61SP1D', 'TH01423U1JGS6A', 'TH24013NB1705L', 'TH20043V3D3C0D', 'TH24023VBBN50H', 'TH10113UXGYB2D', 'TH68043U88W11E', 'TH67013P6RCW6E', 'TH10033R2TZE6E', 'TH15063SJVGM1H', 'TH68043R5JS62F', 'TH10033V87PV6A', 'THT20047RDFW5Z', 'TH62013TA49W5A', 'TH10033UUGHX4B', 'THT21017R6VD6Z', 'TH20043DWPDU5C', 'TH01373V3R8A4C', 'TH15063HW76U7J', 'TH66013U1W973H', 'THT66021EHQ63Z', 'TH20043U2DVU4C', 'TH01473U1G967B', 'TH65023Q1S356B', 'TH20073HTQW31A', 'TH67013RTBKY5G', 'TH70083TSXUF4B', 'TH01473UWFFM3B', 'TH20073RWG991E', 'TH01143S2H0A2E', 'TH65053Q78UG5E', 'TH04073S5UH49C', 'TH01303VE0S29A', 'TH01373UB3D82C', 'TH60033PV8G64B', 'TH04063MQU3G4A1', 'THT20087P7NW5Z', 'TH01303SDDTP2C', 'TH10033UHG168B', 'TH26073UY1ZM1A', 'SSLT730006651767', 'TH01303EJW0H8A', 'TH66023M0BQ69C', 'THT20042G8989Z', 'TH20043UQCNT9D', 'TH67033SWMKH7C', '7110015818354', 'TH01373E7VJ83A', 'TH01403UUJGZ3B0', 'TH67023U39PJ7C', 'TH01473VJW806A', 'TH10113V5SA56B', 'THT20042HTNU4Z', 'TH38013CVWVA6A0', 'TH16033BJJFT0C', 'TH67033QAHVX6F', 'TH68043RGX702F', 'TH10113UQSBM7B', 'TH01423TNP7F6A', 'TH26063BFXQ89A', 'TH05063VDKN39F', 'TH04063V87RJ2E', 'TH04033V8HM87A1');
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
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
    ,case pd.last_route_action
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
from fle_staging.parcel_info pi
# join tmpale.tmp_th_pno_0316 t on t.pno = pi.pno
left join bi_pro.parcel_detail pd on pd.pno = pi.pno
where
    pi.pno in ('TH01043PNDWZ1B', 'TH01273UK0EU8D', 'TH04033PW36Y7A1', 'TH04033RZ7668A1', 'TH10033SAVRJ7K', 'TH10033SUC0X2K', 'TH10033TXAD56K', 'TH10033U71897B', 'TH10033UFG3N5K', 'TH20083HC5138B', 'TH24103N8JDW1B', 'TH67023QZ3T32C', 'THT01052B5HB8Z', 'THT01052CNZY9Z', 'THT013413GF97Z', 'THT04032CC0K2Z', 'THT05062FRFC5Z', 'THT67012B7QC9Z', 'THT67012BSNV5Z', 'THT67012D6ZS7Z', 'TH10033U4XZ40A', 'TH20083UK3EZ5C', 'TH20073VC6FB0B', 'TH04033QUZ5V4A1', 'TH04073PWE6P8K', 'TH20073RSMND0D', 'TH04013GY3C64I', 'TH20043V98EG4B', 'TH20073JYJBK0B', 'THT650120NF71Z', 'TH68043RH64Y2F', 'THT56107V97H3Z', 'TH10033U2S8P9P', 'TH67013QENWT9G', 'THT24011NRU87Z', 'TH33023BBP1E3C', 'TH27013TZ6TA5K', 'TH75103W3HT99C', 'TH01213Q1MTZ4A', 'TH21013VDNK97F', 'TH67013R9Y5R7H', 'TH20073EDGWN5B', 'TH01392WH3Y51B', 'THT15011KGTN6Z', 'TH01403RBZ4R0B0', 'THT20047PEQV5Z', 'TH04073PGWAK2A', 'TH04073KDUAG8K', 'TH10113V8QYG1A', 'TH68043RC3SC6F', 'TH19033UZXT74E', 'TH67013SBFDW1E', 'TH24033B29S10A', 'TH10113VE2B37B', 'TH01053VJQJW6B', 'TH04033JM5CD0A1', 'THT71057SC549Z', 'TH16013MVTPU0L', 'TH04073RKWXH4K-3', 'TH67013S01764H', 'TH21063UYU0U8A', 'TH67013RTA7W9G', 'TH68043S5REX1F', 'THT66021EQRK7Z', 'TH01373V58QS1C', 'TH63083SYPJ90B', 'TH10043VBWR22C', 'TH04073MWHYG9J', 'TH20083S5PKJ5A', 'TH20043VEAQT1E', 'TH67033V05572F', 'THT05062HBHQ8Z', 'TH70043V92E25K', 'TH66023HTTY82C', 'TH04033RDGXM9A1', 'THT0131BVKG9Z', 'THT670126BE69Z', 'TH20083UZXEQ8B', 'TH15013QRRZQ1O', 'TH20073K2ZRE7A', 'TH01403UU4SC8B0', 'TH01293BGQRC4A', 'THT04037PNHT5Z', 'THT1501148ZE3Z', 'THT24021P92A8Z', 'TH44113TG15V3B', 'TH01303VBEWY7A', 'TH04033QHGVW9A1', 'TH01283S8VQT3B1', 'TH67023H02DF9C', 'TH48013VEKGV1I', 'TH67013RJVPA6G', 'TH01203T5GA33B', 'TH67013R20E90G', 'TH24113MFMC47E', 'TH04063T1FT27C', 'TH24113MKGAC4C', 'TH20013NXYCJ2F', 'TH01403TSSVG6B0', 'TH67013S6V0Q7H', 'TH01373TXWYE9B', 'TH68043RPYAK0F', 'TH67033V9BEA2D', 'TH20073PG9TU9C', 'TH67013N36E68G', 'TH66023TKXTG3C', 'TH01203N984F1C', 'TH47133SX04K8I', 'TH70083PYRGK4B', 'TH20053TS9VJ3B', 'TH22043B4DTK7D', 'THT20047XU831Z', 'TH10033VEZ3P2E', 'TH20043V84MX7A', 'TH01393V87RF4E', 'TH67013RSN591H', 'TH01393HRZWK9F', 'TH26073U6VA98D', 'TH67013RVEBQ8G', 'TH04033TF7D09A1', 'TH20043HCS5Z3B1', 'TH01153NH7921A', 'THT24011M7TK4Z', 'TH61023TVVA45C', 'TH67013RMVS53G', 'TH670132JD7Q7E', 'TH67013RF6KH8G', 'TH05033TPS9X9C', 'TH37013VZ99E1A', 'TH68043RB4GT6F', 'TH32013CAU8M7A', 'TH61083B18GD8H', 'TH68043RTRX38F', 'TH71033UVTUJ9M', 'TH68043REJAX8F', 'TH67033R54H76F', 'TH67033EPWJ62A', 'TH11013R98463A', 'TH01053VA3JN1B', 'TH01303VESAU3C', 'TH02063J4EF95A0', 'TH01233S2KZ84E', 'LEXDO0057480603', 'TH01473TB4BH5B', 'TH67023R47AN0A', 'TH20073J9STN5E0', 'TH01053J3CGZ0C', 'TH01413VJ2J70B', 'TH70033UTT9C4D', 'TH20043DJX794A', 'TH20043RYW746H', 'SSLT730005611450', 'TH20043DN7JD3C', 'TH20043UU8DM1A', 'TH67013RNH7U2H', 'TH03043VCWQZ9H', 'TH01403RME2H7B0', 'TH01473UYWWS3A', 'TH20043UG13X3D', 'TH04033SA8UM9A1', 'TH01413VCJ0B1B', 'TH01403RCG2Z8B0', 'TH01273TEMWW7D', 'TH01503RY1FM6B0', 'TH64013HS07V7L', 'THT20047RMPP8Z', 'TH26073UFH341D', 'THT05032JPU55Z', 'TH20073JUV2C1B', 'TH67013RVCHB5G', 'TH24023VBEX45H', 'TH67013TBU433G', 'TH67013SWKQ56G', 'TH02023TETZ56D', 'THT21017R76C8Z', 'TH67013RTBG03G', 'TH20073RWG952E', 'THT54111Y05S5Z', 'TH01373V3N4T2B', 'TH67013RWV669H', 'TH01203RGB9T4B', 'THT20047RFJA9Z', 'TH64013E35UV5N', 'TH05063UAA8V7D', 'TH03043VDRPD3H', 'TH67013RH96T3G', 'TH04033TQE5B2A0', 'TH68043REV5B2F', 'TH15013QS6KP7O', 'TH67023RN22C5B', 'TH20083VF0UN0B', 'TH09013RNABW5D', 'TH02063UA32D7A', 'TH01213TPZH03A', 'TH68043RMVUJ0F', 'TH33053UWG5Q1C', 'THT0403KYNR5Z', 'TH02063T0QV55A', 'TH20043VEBBY8A', 'TH67013QXE7A7H', 'THT030122HJK2Z', 'TH10113V4QZ57B', 'TH63053KMKF75J', 'THT21012462Z5Z', 'TH67013SK64G8E', 'TH65013TY1KY1H', 'TH01073TUT8A9A', 'TH70083R9YWY5C', 'FLACB02017460937', 'TH01473UFV758B', 'TH10113UVYV98B', 'TH56023BQBZM8H', 'TH67013RH7VC8H', 'TH01213SJDJG6A', 'TH66023KG2X04C', 'TH21013V23S27C', 'TH01373JKRJ54B', 'THT56027XXEN0Z', 'TH66023J06CX6C', 'TH24023N0S583F', 'TH68043R62UJ9F', 'TH24043V2QUQ7D', 'TH67013SU38Q9G', 'TH67013RWBXK7G', 'TH68043RFPHE5F', 'TH65013MKY0M5G', 'TH10033VEA2Z4I', 'TH04033S62PK5A0', 'TH10033VDZBU2E', 'TH67013QQUSD5G', 'TH10033UAHNR6P', 'TH013932659B4G', 'TH01163UWSH23A0', 'TH01183VDZTS6A0', 'THT03022HC7C4Z', 'TH21013UUG723F', 'TH05033VB0VS9C', 'TH68043RMT4M6F', 'TH01373V3NEC0B', 'TH67013RVGR36G', 'TH55033K9VAG8B', 'TH01423UPVN92A', 'THT01407R38E5Z', 'TH10033V3HKC0Q', 'TH01473VBCC06C', 'TH65013SKH3W4H', 'TH67013Q87KT5H', 'TH01183RVDKX7A1', 'TH66023KJ79Z8C', 'TH67023HRZHJ8C', 'TH02043T5RW63O', 'TH10113VASDZ8B', 'TH05033U23QE7B', 'TH21063Q8GYK3A', 'TH05033USZTC8I', 'TH67013RPBH03G', 'TH20073JSVJK6B', 'LEXPU0180148516', 'TH67013RSGT12H', 'TH01393VJFQZ4B', 'TH47013U4XUC1C', 'THT67022AU899Z', 'TH67013RV5G61G', 'THT21062BHSV7Z', 'TH05033UH8NQ3G', 'SSLT730006233687', 'TH26073UZ34E7A', 'THT01407QXC36Z', 'TH74043V9FJX5C', 'TH10043VGDEP0E', 'TH12033VA3MD1B', 'TH20073HW5T27B', 'TH01273GJFNC3D', 'TH67013K54Q24B', 'TH05033UQWPU5J', 'TH02063FA2E71A-1', 'TH04033RMX396A1', 'TH20043CPU6J9B0', 'TH20083U2QAV3B', 'TH13133TYY7Q9D', 'TH20043V95CS6G', 'THT21017U94Y0Z', 'TH40053NCX632D', 'TH02063CAA6C8A', 'TH13023RM3PV2A-1', 'THT21062BDX08Z', 'THT01407RXMJ4Z', 'TH20073JJQWU7B', 'TH01373VNA8B8B', 'TH20083W61SP1D', 'TH01423U1JGS6A', 'TH24013NB1705L', 'TH20043V3D3C0D', 'TH24023VBBN50H', 'TH10113UXGYB2D', 'TH68043U88W11E', 'TH67013P6RCW6E', 'TH10033R2TZE6E', 'TH15063SJVGM1H', 'TH68043R5JS62F', 'TH10033V87PV6A', 'THT20047RDFW5Z', 'TH62013TA49W5A', 'TH10033UUGHX4B', 'THT21017R6VD6Z', 'TH20043DWPDU5C', 'TH01373V3R8A4C', 'TH15063HW76U7J', 'TH66013U1W973H', 'THT66021EHQ63Z', 'TH20043U2DVU4C', 'TH01473U1G967B', 'TH65023Q1S356B', 'TH20073HTQW31A', 'TH67013RTBKY5G', 'TH70083TSXUF4B', 'TH01473UWFFM3B', 'TH20073RWG991E', 'TH01143S2H0A2E', 'TH65053Q78UG5E', 'TH04073S5UH49C', 'TH01303VE0S29A', 'TH01373UB3D82C', 'TH60033PV8G64B', 'TH04063MQU3G4A1', 'THT20087P7NW5Z', 'TH01303SDDTP2C', 'TH10033UHG168B', 'TH26073UY1ZM1A', 'SSLT730006651767', 'TH01303EJW0H8A', 'TH66023M0BQ69C', 'THT20042G8989Z', 'TH20043UQCNT9D', 'TH67033SWMKH7C', '7110015818354', 'TH01373E7VJ83A', 'TH01403UUJGZ3B0', 'TH67023U39PJ7C', 'TH01473VJW806A', 'TH10113V5SA56B', 'THT20042HTNU4Z', 'TH38013CVWVA6A0', 'TH16033BJJFT0C', 'TH67033QAHVX6F', 'TH68043RGX702F', 'TH10113UQSBM7B', 'TH01423TNP7F6A', 'TH26063BFXQ89A', 'TH05063VDKN39F', 'TH04063V87RJ2E', 'TH04033V8HM87A1');
;-- -. . -..- - / . -. - .-. -.--
select
    pct.pno
from bi_pro.parcel_claim_task pct
where
    pct.source = 12 -- L来源
    and pct.state = 6;
;-- -. . -..- - / . -. - .-. -.--
select
    pct.pno
from bi_pro.parcel_claim_task pct
where
    pct.source = 12 -- L来源
    and pct.state = 7;
;-- -. . -..- - / . -. - .-. -.--
select
    pct.pno
    ,case pct.state
        when 6 then '理赔完成'
        when 7 then '理赔终止'
    end 理赔状态
    ,case plt.`source`
        when 1 then 'a-问题件-丢失'
        when 2 then 'b-记录本-丢失'
        when 3 then 'c-包裹状态未更新'
        when 4 then 'd-问题件-破损/短少'
        when 5 then 'e-记录本-索赔-丢失'
        when 6 then 'f-记录本-索赔-破损/短少'
        when 7 then 'g-记录本-索赔-其他'
        when 8 then 'h-包裹状态未更新-ipc计数'
        when 9 then 'i-问题件-外包装破损险'
        when 10 then 'j-问题记录本-外包装破损险'
        when 11 then 'k-超时效包裹'
        when 12 then 'l-高度疑似丢失'
    end '闪速认定问题来源'
    ,case plt.state
        when 1 then '丢失件待处理'
        when 2 then '疑似丢失件待处理'
        when 3 then '待工单回复'
        when 4 then '已工单回复'
        when 5 then '包裹未丢失'
        when 6 then '丢失件处理完成'
    end 闪人认定任务状态
from bi_pro.parcel_claim_task pct
left join bi_pro.parcel_lose_task plt on pct.pno and plt.pno
where
    pct.source = 12 -- L来源
    and pct.state in (7,8)
    and plt.state not in (5,6);
;-- -. . -..- - / . -. - .-. -.--
select
    pct.pno
    ,case pct.state
        when 6 then '理赔完成'
        when 7 then '理赔终止'
    end 理赔状态
    ,case plt.`source`
        when 1 then 'a-问题件-丢失'
        when 2 then 'b-记录本-丢失'
        when 3 then 'c-包裹状态未更新'
        when 4 then 'd-问题件-破损/短少'
        when 5 then 'e-记录本-索赔-丢失'
        when 6 then 'f-记录本-索赔-破损/短少'
        when 7 then 'g-记录本-索赔-其他'
        when 8 then 'h-包裹状态未更新-ipc计数'
        when 9 then 'i-问题件-外包装破损险'
        when 10 then 'j-问题记录本-外包装破损险'
        when 11 then 'k-超时效包裹'
        when 12 then 'l-高度疑似丢失'
    end '闪速认定问题来源'
    ,case plt.state
        when 1 then '丢失件待处理'
        when 2 then '疑似丢失件待处理'
        when 3 then '待工单回复'
        when 4 then '已工单回复'
        when 5 then '包裹未丢失'
        when 6 then '丢失件处理完成'
    end 闪人认定任务状态
from bi_pro.parcel_claim_task pct
left join bi_pro.parcel_lose_task plt on pct.pno = plt.pno
where
    pct.source = 12 -- L来源
    and pct.state in (7,8)
    and plt.state not in (5,6);
;-- -. . -..- - / . -. - .-. -.--
select
    pct.pno
    ,case pct.state
        when 6 then '理赔完成'
        when 7 then '理赔终止'
    end 理赔状态
    ,plt.id
    ,case plt.`source`
        when 1 then 'a-问题件-丢失'
        when 2 then 'b-记录本-丢失'
        when 3 then 'c-包裹状态未更新'
        when 4 then 'd-问题件-破损/短少'
        when 5 then 'e-记录本-索赔-丢失'
        when 6 then 'f-记录本-索赔-破损/短少'
        when 7 then 'g-记录本-索赔-其他'
        when 8 then 'h-包裹状态未更新-ipc计数'
        when 9 then 'i-问题件-外包装破损险'
        when 10 then 'j-问题记录本-外包装破损险'
        when 11 then 'k-超时效包裹'
        when 12 then 'l-高度疑似丢失'
    end '闪速认定问题来源'
    ,case plt.state
        when 1 then '丢失件待处理'
        when 2 then '疑似丢失件待处理'
        when 3 then '待工单回复'
        when 4 then '已工单回复'
        when 5 then '包裹未丢失'
        when 6 then '丢失件处理完成'
    end 闪人认定任务状态
from bi_pro.parcel_claim_task pct
left join bi_pro.parcel_lose_task plt on pct.pno = plt.pno
where
    pct.source = 12 -- L来源
    and pct.state in (7,8)
    and plt.state not in (5,6);
;-- -. . -..- - / . -. - .-. -.--
select
    wo.order_no
    ,wor.staff_info_id
    ,hsi.node_department_id
    ,wor.created_at
from bi_pro.work_order wo
left join bi_pro.work_order_reply wor on wor.order_id = wo.id
left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = wor.staff_info_id
where
    wo.order_no = '0416763084300226';
;-- -. . -..- - / . -. - .-. -.--
select
    wo.order_no
    ,wor.staff_info_id
    ,hsi.node_department_id
    ,wor.created_at
    ,hsi.state
from bi_pro.work_order wo
left join bi_pro.work_order_reply wor on wor.order_id = wo.id
left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = wor.staff_info_id
where
    wo.order_no = '0416763084300226';
;-- -. . -..- - / . -. - .-. -.--
select
        wo.id
        ,wor.created_at
        ,row_number() over (partition by wo.id order by wor.created_at) rn
    from bi_pro.work_order wo
    left join bi_pro.work_order_reply wor on wor.order_id = wo.id
    left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = wor.staff_info_id
    where
        wo.created_at >= date_sub(curdate(),interval 30 day)
        and wo.created_at < curdate()
        and hsi.state = 1
        and hsi.node_department_id = 86
        and wo.order_no = '0416763084300226';
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        wo.id
        ,wor.created_at
        ,row_number() over (partition by wo.id order by wor.created_at) rn
    from bi_pro.work_order wo
    left join bi_pro.work_order_reply wor on wor.order_id = wo.id
    left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = wor.staff_info_id
    where
        wo.created_at >= date_sub(curdate(),interval 30 day)
        and wo.created_at < curdate()
        and hsi.state = 1
        and hsi.node_department_id = 86

)

SELECT
    concat('`',wo.order_no)  工单编号
    ,case wo.status when 1 then '未阅读' when 2 then '已经阅读' when 3 then '已回复' when 4 then '已关闭' end 状态
    ,wo.`client_id` 客户ID
    ,wo.`pnos`  运单号
    ,case wo.order_type
        when 1 then '查找运单'
        when 2 then '加快处理'
        when 3 then '调查员工'
        when 4 then '其他'
        when 5 then '网点信息维护提醒'
        when 6 then '培训指导'
        when 7 then '异常业务询问'
        when 8 then '包裹丢失'
        when 9 then '包裹破损'
        when 10 then '货物短少'
        when 11 then '催单'
        when 12 then '有发无到'
        when 13 then '上报包裹不在集包里'
        when 16 then '漏揽收'
        when 50 then '虚假撤销'
        when 17 then '已签收未收到'
        when 18 then '客户投诉'
        when 19 then '修改包裹信息'
        when 20 then '修改 COD 金额'
        when 21 then '解锁包裹'
        when 22 then '申请索赔'
        when 23 then 'MS 问题反馈'
        when 24 then 'FBI 问题反馈'
        when 25 then 'KA System 问题反馈'
        when 26 then 'App 问题反馈'
        when 27 then 'KIT 问题反馈'
        when 28 then 'Backyard 问题反馈'
        when 29 then 'BS/FH 问题反馈'
        when 30 then '系统建议'
        when 31 then '申诉罚款'
        else wo.order_type
    end  工单类型
    ,wo.title 工单标题
    ,wo.created_at 创建时间
    ,wor.`created_at` 第一次工单回复时间
    ,timestampdiff(second , wo.created_at, wor.created_at) '第一次回复时长（与创建工单的时间相比）'
    ,t2.created_at 第二次回复时间
    ,timestampdiff(second, wor.created_at, t2.created_at) '第二次回复时长（与第一次的时间对比）'
    ,t3.created_at 第三次回复时间
    ,timestampdiff(second, t2.created_at, t3.created_at) '第三次回复时长（与第二次回复时间对比）'
    ,(timestampdiff(second , wo.created_at, wor.created_at) + ifnull(timestampdiff(second, wor.created_at, t2.created_at), 0) + ifnull(timestampdiff(second, t2.created_at, t3.created_at), 0))/(1 + if(t2.created_at is null ,0 ,1) + if(t3.created_at is null ,0 ,1)) '平均响应时长（每个相差间隔的平均响应时间）'
    ,wo.`closed_at`  工单关闭时间
    ,timestampdiff(second, wo.created_at, wo.closed_at) '总用时长（关闭工单的时间-创建工单的时间）'
    ,wo.`created_staff_info_id`  发起人ID
    ,hi.`name`  发起人姓名
    ,wo.created_store_id 发起人网点ID
    ,ss.`short_name`  发起人所属部门网点code
    ,ss.`name`  发起人所属部门名称
    ,wor.`staff_info_id`  第一次回复人ID
    ,hi1.`name`  第一次回复人姓名
    ,case when ss1.`category` in (1,2,10,13) then 'sp'
        when ss1.`category` in (8,9,12) then 'HUB/BHUB/OS'
        when ss1.`category` IN (4,5,7) then 'SHOP/ushop'
        when ss1.`category` IN (6)  then 'FH'when wo.`store_id` = '22' then 'kam客服中心'
        when wo.`store_id`in (3,'customer_manger') then  '总部客服中心'
        when wo.`store_id`= '12' then 'QA&QC'
        when wo.`store_id`= '18' then 'Flash Home客服中心'
        when wo.`created_store_id` = '22' and wo.`client_id` IN ('AA0302','AA0413','AA0472','AA0545','BF9675','BF9690','CA5901' ) then 'FFM'
        else '其他网点'
    end 受理部门
    ,case
        when wo.`original_acceptance_info` is null and wor.created_at is not null and  TIMESTAMPDIFF(HOUR, wo.`created_at`,wor.`created_at` )<24  then '是'
        when wo.`original_acceptance_info` is not null and wor.created_at is not null and  TIMESTAMPDIFF(HOUR, wo.`created_at`,wor.`created_at` )<72  then '是'
        else '否'
    end  是否在24小时内回复
    ,if(wor.created_at is not null and wo.`original_acceptance_info` is not null  and TIMESTAMPDIFF(HOUR, wo.`created_at`,wor.`created_at` )>48,'是','否') 是否为FH48小时超时工单
    ,TIMESTAMPDIFF(MINUTE, wo.`created_at`,wor.`created_at`) 第一次回复时长
    ,if(wt.`created_at` is not null and nwt.`created_at` is null,'是','否') 是否为工作时间创建工单
    ,case
        when wo.`original_acceptance_info` is null and wor.created_at is not null and TIMESTAMPDIFF(MINUTE, wt.`created_at`,wor.`created_at`)<40 then '是'
        when wo.`original_acceptance_info` is not null and wor.created_at is not null and TIMESTAMPDIFF(MINUTE, wt.`created_at`,wor.`created_at`)<2920 then '是'
        else '否'
    end 工作时间内创建的工单是否在40分钟内回复
    ,case
        when wo.`original_acceptance_info` is null and wor.created_at is not null and TIMESTAMPDIFF(HOUR, nwt.`created_at`,wor.`created_at` )<24 then '是'
        when wo.`original_acceptance_info` is not null and wor.created_at is not null and TIMESTAMPDIFF(HOUR, nwt.`created_at`,wor.`created_at` )<72 then '是'
        else '否'
    end 非工作时间是否在24小时内回复
    ,case
        when nwt.`tg` in (1,3) and wor.`created_at` < concat(date_add(nwt.`created_at`, interval 1 day) , ' 10:00') then '是'
        when nwt.`tg` in (2,4) and wor.`created_at` < concat(date(nwt.`created_at`), ' 10:00') then '是'
        ELSE '否'
    end as '工作时间外创建的工单是否在次日10:00前回复'
from `bi_pro`.work_order wo
left join
    ( #第一次回复
        select
            *
        from
            (
                select
                    wor.`created_at`
                    ,wor.`order_id`
                    ,wor.`staff_info_id`
                    ,row_number() over(partition by wor.`order_id` order by wor.`created_at`) rn
                from `bi_pro`.work_order_reply wor
            )wor
        where wor.rn=1
    )wor on wo.id = wor.`order_id`
left join `bi_pro`.`hr_staff_info` hi on hi.`staff_info_id` = wo.`created_staff_info_id`
left join `bi_pro`.`sys_store` ss on ss.`id` = wo.`created_store_id`
left join `bi_pro`.`hr_staff_info` hi1 on hi1.`staff_info_id` =wor.`staff_info_id`
left join `bi_pro`.`sys_store` ss1 on ss1.`id` = wo.`store_id`
left join
    (   #工作时间
        SELECT
            wo.`id`
            ,wo.`created_at`
            ,date_format(wo.`created_at`,'%w') as weekNum
        FROM `bi_pro`.work_order wo
        where
            date_format(wo.`created_at`,'%w')  between 1 and 5
            and date_format(wo.`created_at`,'1%H%i') between 11000 and 11900
            or (date_format(wo.`created_at`,'%w') in (0,6) and date_format(wo.`created_at`,'1%H%i') between 11000 and 11700)
    ) wt on wt.id = wo.id
left join
    ( #非工作时间
        select  wo.`id`
            ,wo.`created_at`
            ,date_format(wo.`created_at`,'%w') as weeknum
            ,case
                when  date_format(wo.`created_at`,'%w')  between 1 and 5 and date_format(wo.`created_at`,'1%h%i')>11900 and date_format(wo.`created_at`,'1%h%i') <10000 then '1'
                when  date_format(wo.`created_at`,'%w')  between 1 and 5 and date_format(wo.`created_at`,'1%h%i')>=10000 and date_format(wo.`created_at`,'1%h%i') <11000 then '2'
                when  date_format(wo.`created_at`,'%w') in (0,6) and date_format(wo.`created_at`,'1%h%i')>11700 and date_format(wo.`created_at`,'1%h%i') <10000 then '3'
                when  date_format(wo.`created_at`,'%w') in (0,6) and date_format(wo.`created_at`,'1%h%i')>=10000 and date_format(wo.`created_at`,'1%h%i') <11000 then '4'
            end as 'tg'
        from `bi_pro`.work_order wo
        where
            date_format(wo.`created_at`,'%w')  between 1 and 5
            and (date_format(wo.`created_at`,'1%H%i') <11000
            or date_format(wo.`created_at`,'1%H%i')>11900)
            or (date_format(wo.`created_at`,'%w') in (0,6) and (date_format(wo.`created_at`,'1%H%i') <11000 or date_format(wo.`created_at`,'1%H%i')>11700))
    ) nwt on nwt.id = wo.id
left join t t2 on t2.id = wo.id and t2.rn = 2
left join t t3 on t3.id = wo.id and t3.rn = 3
where
    wo.created_at >= date_sub(curdate(),interval 30 day)
    and wo.created_at < curdate()
    -- and wo.status < 4
    -- and wo.`created_store_id` !=1 -- 自动创建的工单
    and hi1.`node_department_id` =86
    and hi1.`state` =1
    and wo.order_no = '0416763084300226'
order by 7;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        wo.id
        ,wor.created_at
        ,row_number() over (partition by wo.id order by wor.created_at) rn
    from bi_pro.work_order wo
    left join bi_pro.work_order_reply wor on wor.order_id = wo.id
    left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = wor.staff_info_id
    where
        wo.created_at >= date_sub(curdate(),interval 30 day)
        and wo.created_at < curdate()
        and hsi.state = 1
        and hsi.node_department_id = 86

)

SELECT
    concat('`',wo.order_no)  工单编号
    ,case wo.status when 1 then '未阅读' when 2 then '已经阅读' when 3 then '已回复' when 4 then '已关闭' end 状态
    ,wo.`client_id` 客户ID
    ,wo.`pnos`  运单号
    ,case wo.order_type
        when 1 then '查找运单'
        when 2 then '加快处理'
        when 3 then '调查员工'
        when 4 then '其他'
        when 5 then '网点信息维护提醒'
        when 6 then '培训指导'
        when 7 then '异常业务询问'
        when 8 then '包裹丢失'
        when 9 then '包裹破损'
        when 10 then '货物短少'
        when 11 then '催单'
        when 12 then '有发无到'
        when 13 then '上报包裹不在集包里'
        when 16 then '漏揽收'
        when 50 then '虚假撤销'
        when 17 then '已签收未收到'
        when 18 then '客户投诉'
        when 19 then '修改包裹信息'
        when 20 then '修改 COD 金额'
        when 21 then '解锁包裹'
        when 22 then '申请索赔'
        when 23 then 'MS 问题反馈'
        when 24 then 'FBI 问题反馈'
        when 25 then 'KA System 问题反馈'
        when 26 then 'App 问题反馈'
        when 27 then 'KIT 问题反馈'
        when 28 then 'Backyard 问题反馈'
        when 29 then 'BS/FH 问题反馈'
        when 30 then '系统建议'
        when 31 then '申诉罚款'
        else wo.order_type
    end  工单类型
    ,wo.title 工单标题
    ,wo.created_at 创建时间
    ,wor.`created_at` 第一次工单回复时间
    ,timestampdiff(second , wo.created_at, wor.created_at) '第一次回复时长（与创建工单的时间相比）'
    ,t2.created_at 第二次回复时间
    ,timestampdiff(second, wor.created_at, t2.created_at) '第二次回复时长（与第一次的时间对比）'
    ,t3.created_at 第三次回复时间
    ,timestampdiff(second, t2.created_at, t3.created_at) '第三次回复时长（与第二次回复时间对比）'
    ,(timestampdiff(second , wo.created_at, wor.created_at) + ifnull(timestampdiff(second, wor.created_at, t2.created_at), 0) + ifnull(timestampdiff(second, t2.created_at, t3.created_at), 0))/(1 + if(t2.created_at is null ,0 ,1) + if(t3.created_at is null ,0 ,1)) '平均响应时长（每个相差间隔的平均响应时间）'
    ,wo.`closed_at`  工单关闭时间
    ,timestampdiff(second, wo.created_at, wo.closed_at) '总用时长（关闭工单的时间-创建工单的时间）'
    ,wo.`created_staff_info_id`  发起人ID
    ,hi.`name`  发起人姓名
    ,wo.created_store_id 发起人网点ID
    ,ss.`short_name`  发起人所属部门网点code
    ,ss.`name`  发起人所属部门名称
    ,wor.`staff_info_id`  第一次回复人ID
    ,hi1.`name`  第一次回复人姓名
    ,case when ss1.`category` in (1,2,10,13) then 'sp'
        when ss1.`category` in (8,9,12) then 'HUB/BHUB/OS'
        when ss1.`category` IN (4,5,7) then 'SHOP/ushop'
        when ss1.`category` IN (6)  then 'FH'when wo.`store_id` = '22' then 'kam客服中心'
        when wo.`store_id`in (3,'customer_manger') then  '总部客服中心'
        when wo.`store_id`= '12' then 'QA&QC'
        when wo.`store_id`= '18' then 'Flash Home客服中心'
        when wo.`created_store_id` = '22' and wo.`client_id` IN ('AA0302','AA0413','AA0472','AA0545','BF9675','BF9690','CA5901' ) then 'FFM'
        else '其他网点'
    end 受理部门
    ,case
        when wo.`original_acceptance_info` is null and wor.created_at is not null and  TIMESTAMPDIFF(HOUR, wo.`created_at`,wor.`created_at` )<24  then '是'
        when wo.`original_acceptance_info` is not null and wor.created_at is not null and  TIMESTAMPDIFF(HOUR, wo.`created_at`,wor.`created_at` )<72  then '是'
        else '否'
    end  是否在24小时内回复
    ,if(wor.created_at is not null and wo.`original_acceptance_info` is not null  and TIMESTAMPDIFF(HOUR, wo.`created_at`,wor.`created_at` )>48,'是','否') 是否为FH48小时超时工单
    ,TIMESTAMPDIFF(MINUTE, wo.`created_at`,wor.`created_at`) 第一次回复时长
    ,if(wt.`created_at` is not null and nwt.`created_at` is null,'是','否') 是否为工作时间创建工单
    ,case
        when wo.`original_acceptance_info` is null and wor.created_at is not null and TIMESTAMPDIFF(MINUTE, wt.`created_at`,wor.`created_at`)<40 then '是'
        when wo.`original_acceptance_info` is not null and wor.created_at is not null and TIMESTAMPDIFF(MINUTE, wt.`created_at`,wor.`created_at`)<2920 then '是'
        else '否'
    end 工作时间内创建的工单是否在40分钟内回复
    ,case
        when wo.`original_acceptance_info` is null and wor.created_at is not null and TIMESTAMPDIFF(HOUR, nwt.`created_at`,wor.`created_at` )<24 then '是'
        when wo.`original_acceptance_info` is not null and wor.created_at is not null and TIMESTAMPDIFF(HOUR, nwt.`created_at`,wor.`created_at` )<72 then '是'
        else '否'
    end 非工作时间是否在24小时内回复
    ,case
        when nwt.`tg` in (1,3) and wor.`created_at` < concat(date_add(nwt.`created_at`, interval 1 day) , ' 10:00') then '是'
        when nwt.`tg` in (2,4) and wor.`created_at` < concat(date(nwt.`created_at`), ' 10:00') then '是'
        ELSE '否'
    end as '工作时间外创建的工单是否在次日10:00前回复'
from `bi_pro`.work_order wo
left join
    ( #第一次回复
        select
            *
        from
            (
                select
                    wor.`created_at`
                    ,wor.`order_id`
                    ,wor.`staff_info_id`
                    ,row_number() over(partition by wor.`order_id` order by wor.`created_at`) rn
                from `bi_pro`.work_order_reply wor
            )wor
        where wor.rn=1
    )wor on wo.id = wor.`order_id`
left join `bi_pro`.`hr_staff_info` hi on hi.`staff_info_id` = wo.`created_staff_info_id`
left join `bi_pro`.`sys_store` ss on ss.`id` = wo.`created_store_id`
left join `bi_pro`.`hr_staff_info` hi1 on hi1.`staff_info_id` =wor.`staff_info_id`
left join `bi_pro`.`sys_store` ss1 on ss1.`id` = wo.`store_id`
left join
    (   #工作时间
        SELECT
            wo.`id`
            ,wo.`created_at`
            ,date_format(wo.`created_at`,'%w') as weekNum
        FROM `bi_pro`.work_order wo
        where
            date_format(wo.`created_at`,'%w')  between 1 and 5
            and date_format(wo.`created_at`,'1%H%i') between 11000 and 11900
            or (date_format(wo.`created_at`,'%w') in (0,6) and date_format(wo.`created_at`,'1%H%i') between 11000 and 11700)
    ) wt on wt.id = wo.id
left join
    ( #非工作时间
        select  wo.`id`
            ,wo.`created_at`
            ,date_format(wo.`created_at`,'%w') as weeknum
            ,case
                when  date_format(wo.`created_at`,'%w')  between 1 and 5 and date_format(wo.`created_at`,'1%h%i')>11900 and date_format(wo.`created_at`,'1%h%i') <10000 then '1'
                when  date_format(wo.`created_at`,'%w')  between 1 and 5 and date_format(wo.`created_at`,'1%h%i')>=10000 and date_format(wo.`created_at`,'1%h%i') <11000 then '2'
                when  date_format(wo.`created_at`,'%w') in (0,6) and date_format(wo.`created_at`,'1%h%i')>11700 and date_format(wo.`created_at`,'1%h%i') <10000 then '3'
                when  date_format(wo.`created_at`,'%w') in (0,6) and date_format(wo.`created_at`,'1%h%i')>=10000 and date_format(wo.`created_at`,'1%h%i') <11000 then '4'
            end as 'tg'
        from `bi_pro`.work_order wo
        where
            date_format(wo.`created_at`,'%w')  between 1 and 5
            and (date_format(wo.`created_at`,'1%H%i') <11000
            or date_format(wo.`created_at`,'1%H%i')>11900)
            or (date_format(wo.`created_at`,'%w') in (0,6) and (date_format(wo.`created_at`,'1%H%i') <11000 or date_format(wo.`created_at`,'1%H%i')>11700))
    ) nwt on nwt.id = wo.id
left join t t2 on t2.id = wo.id and t2.rn = 2
left join t t3 on t3.id = wo.id and t3.rn = 3
where
    wo.created_at >= date_sub(curdate(),interval 30 day)
    and wo.created_at < curdate()
    -- and wo.status < 4
    -- and wo.`created_store_id` !=1 -- 自动创建的工单
    and hi1.`node_department_id` =86
    and hi1.`state` =1;
;-- -. . -..- - / . -. - .-. -.--
select
        wo.id
        ,wor.created_at
        ,row_number() over (partition by wo.id order by wor.created_at) rn
        ,count(wor.id) over (partition by wo.id) hf_num
    from bi_pro.work_order wo
    left join bi_pro.work_order_reply wor on wor.order_id = wo.id
    left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = wor.staff_info_id
    where
        wo.created_at >= date_sub(curdate(),interval 30 day)
        and wo.created_at < curdate()
        and hsi.state = 1
        and hsi.node_department_id = 86
        and wo.order_no = '0416763084300226';
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        wo.id
        ,wor.created_at
        ,row_number() over (partition by wo.id order by wor.created_at) rn
        ,count(wor.id) over (partition by wo.id) hf_num
    from bi_pro.work_order wo
    left join bi_pro.work_order_reply wor on wor.order_id = wo.id
    left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = wor.staff_info_id
    where
        wo.created_at >= date_sub(curdate(),interval 30 day)
        and wo.created_at < curdate()
        and hsi.state = 1
        and hsi.node_department_id = 86
)

SELECT
    concat('`',wo.order_no)  工单编号
    ,case wo.status when 1 then '未阅读' when 2 then '已经阅读' when 3 then '已回复' when 4 then '已关闭' end 状态
    ,wo.`client_id` 客户ID
    ,wo.`pnos`  运单号
    ,case wo.order_type
        when 1 then '查找运单'
        when 2 then '加快处理'
        when 3 then '调查员工'
        when 4 then '其他'
        when 5 then '网点信息维护提醒'
        when 6 then '培训指导'
        when 7 then '异常业务询问'
        when 8 then '包裹丢失'
        when 9 then '包裹破损'
        when 10 then '货物短少'
        when 11 then '催单'
        when 12 then '有发无到'
        when 13 then '上报包裹不在集包里'
        when 16 then '漏揽收'
        when 50 then '虚假撤销'
        when 17 then '已签收未收到'
        when 18 then '客户投诉'
        when 19 then '修改包裹信息'
        when 20 then '修改 COD 金额'
        when 21 then '解锁包裹'
        when 22 then '申请索赔'
        when 23 then 'MS 问题反馈'
        when 24 then 'FBI 问题反馈'
        when 25 then 'KA System 问题反馈'
        when 26 then 'App 问题反馈'
        when 27 then 'KIT 问题反馈'
        when 28 then 'Backyard 问题反馈'
        when 29 then 'BS/FH 问题反馈'
        when 30 then '系统建议'
        when 31 then '申诉罚款'
        else wo.order_type
    end  工单类型
    ,wo.title 工单标题
    ,wo.created_at 创建时间
    ,t2.hf_num 回复总次数
    ,wor.`created_at` 第一次工单回复时间
    ,timestampdiff(second , wo.created_at, wor.created_at) '第一次回复时长（与创建工单的时间相比）'
    ,t2.created_at 第二次回复时间
    ,timestampdiff(second, wor.created_at, t2.created_at) '第二次回复时长（与第一次的时间对比）'
    ,t3.created_at 第三次回复时间
    ,timestampdiff(second, t2.created_at, t3.created_at) '第三次回复时长（与第二次回复时间对比）'
    ,(timestampdiff(second , wo.created_at, wor.created_at) + ifnull(timestampdiff(second, wor.created_at, t2.created_at), 0) + ifnull(timestampdiff(second, t2.created_at, t3.created_at), 0))/(1 + if(t2.created_at is null ,0 ,1) + if(t3.created_at is null ,0 ,1)) '平均响应时长（每个相差间隔的平均响应时间）'
    ,wo.`closed_at`  工单关闭时间
    ,timestampdiff(second, wo.created_at, wo.closed_at) '总用时长（关闭工单的时间-创建工单的时间）'
    ,wo.`created_staff_info_id`  发起人ID
    ,hi.`name`  发起人姓名
    ,wo.created_store_id 发起人网点ID
    ,ss.`short_name`  发起人所属部门网点code
    ,ss.`name`  发起人所属部门名称
    ,wor.`staff_info_id`  第一次回复人ID
    ,hi1.`name`  第一次回复人姓名
    ,case when ss1.`category` in (1,2,10,13) then 'sp'
        when ss1.`category` in (8,9,12) then 'HUB/BHUB/OS'
        when ss1.`category` IN (4,5,7) then 'SHOP/ushop'
        when ss1.`category` IN (6)  then 'FH'when wo.`store_id` = '22' then 'kam客服中心'
        when wo.`store_id`in (3,'customer_manger') then  '总部客服中心'
        when wo.`store_id`= '12' then 'QA&QC'
        when wo.`store_id`= '18' then 'Flash Home客服中心'
        when wo.`created_store_id` = '22' and wo.`client_id` IN ('AA0302','AA0413','AA0472','AA0545','BF9675','BF9690','CA5901' ) then 'FFM'
        else '其他网点'
    end 受理部门
    ,case
        when wo.`original_acceptance_info` is null and wor.created_at is not null and  TIMESTAMPDIFF(HOUR, wo.`created_at`,wor.`created_at` )<24  then '是'
        when wo.`original_acceptance_info` is not null and wor.created_at is not null and  TIMESTAMPDIFF(HOUR, wo.`created_at`,wor.`created_at` )<72  then '是'
        else '否'
    end  是否在24小时内回复
    ,if(wor.created_at is not null and wo.`original_acceptance_info` is not null  and TIMESTAMPDIFF(HOUR, wo.`created_at`,wor.`created_at` )>48,'是','否') 是否为FH48小时超时工单
    ,TIMESTAMPDIFF(MINUTE, wo.`created_at`,wor.`created_at`) 第一次回复时长
    ,if(wt.`created_at` is not null and nwt.`created_at` is null,'是','否') 是否为工作时间创建工单
    ,case
        when wo.`original_acceptance_info` is null and wor.created_at is not null and TIMESTAMPDIFF(MINUTE, wt.`created_at`,wor.`created_at`)<40 then '是'
        when wo.`original_acceptance_info` is not null and wor.created_at is not null and TIMESTAMPDIFF(MINUTE, wt.`created_at`,wor.`created_at`)<2920 then '是'
        else '否'
    end 工作时间内创建的工单是否在40分钟内回复
    ,case
        when wo.`original_acceptance_info` is null and wor.created_at is not null and TIMESTAMPDIFF(HOUR, nwt.`created_at`,wor.`created_at` )<24 then '是'
        when wo.`original_acceptance_info` is not null and wor.created_at is not null and TIMESTAMPDIFF(HOUR, nwt.`created_at`,wor.`created_at` )<72 then '是'
        else '否'
    end 非工作时间是否在24小时内回复
    ,case
        when nwt.`tg` in (1,3) and wor.`created_at` < concat(date_add(nwt.`created_at`, interval 1 day) , ' 10:00') then '是'
        when nwt.`tg` in (2,4) and wor.`created_at` < concat(date(nwt.`created_at`), ' 10:00') then '是'
        ELSE '否'
    end as '工作时间外创建的工单是否在次日10:00前回复'
from `bi_pro`.work_order wo
left join
    ( #第一次回复
        select
            *
        from
            (
                select
                    wor.`created_at`
                    ,wor.`order_id`
                    ,wor.`staff_info_id`
                    ,row_number() over(partition by wor.`order_id` order by wor.`created_at`) rn
                from `bi_pro`.work_order_reply wor
            )wor
        where wor.rn=1
    )wor on wo.id = wor.`order_id`
left join `bi_pro`.`hr_staff_info` hi on hi.`staff_info_id` = wo.`created_staff_info_id`
left join `bi_pro`.`sys_store` ss on ss.`id` = wo.`created_store_id`
left join `bi_pro`.`hr_staff_info` hi1 on hi1.`staff_info_id` =wor.`staff_info_id`
left join `bi_pro`.`sys_store` ss1 on ss1.`id` = wo.`store_id`
left join
    (   #工作时间
        SELECT
            wo.`id`
            ,wo.`created_at`
            ,date_format(wo.`created_at`,'%w') as weekNum
        FROM `bi_pro`.work_order wo
        where
            date_format(wo.`created_at`,'%w')  between 1 and 5
            and date_format(wo.`created_at`,'1%H%i') between 11000 and 11900
            or (date_format(wo.`created_at`,'%w') in (0,6) and date_format(wo.`created_at`,'1%H%i') between 11000 and 11700)
    ) wt on wt.id = wo.id
left join
    ( #非工作时间
        select  wo.`id`
            ,wo.`created_at`
            ,date_format(wo.`created_at`,'%w') as weeknum
            ,case
                when  date_format(wo.`created_at`,'%w')  between 1 and 5 and date_format(wo.`created_at`,'1%h%i')>11900 and date_format(wo.`created_at`,'1%h%i') <10000 then '1'
                when  date_format(wo.`created_at`,'%w')  between 1 and 5 and date_format(wo.`created_at`,'1%h%i')>=10000 and date_format(wo.`created_at`,'1%h%i') <11000 then '2'
                when  date_format(wo.`created_at`,'%w') in (0,6) and date_format(wo.`created_at`,'1%h%i')>11700 and date_format(wo.`created_at`,'1%h%i') <10000 then '3'
                when  date_format(wo.`created_at`,'%w') in (0,6) and date_format(wo.`created_at`,'1%h%i')>=10000 and date_format(wo.`created_at`,'1%h%i') <11000 then '4'
            end as 'tg'
        from `bi_pro`.work_order wo
        where
            date_format(wo.`created_at`,'%w')  between 1 and 5
            and (date_format(wo.`created_at`,'1%H%i') <11000
            or date_format(wo.`created_at`,'1%H%i')>11900)
            or (date_format(wo.`created_at`,'%w') in (0,6) and (date_format(wo.`created_at`,'1%H%i') <11000 or date_format(wo.`created_at`,'1%H%i')>11700))
    ) nwt on nwt.id = wo.id
left join t t2 on t2.id = wo.id and t2.rn = 2
left join t t3 on t3.id = wo.id and t3.rn = 3
where
    wo.created_at >= date_sub(curdate(),interval 30 day)
    and wo.created_at < curdate()
    -- and wo.status < 4
    -- and wo.`created_store_id` !=1 -- 自动创建的工单
    and hi1.`node_department_id` =86
    and hi1.`state` =1;
;-- -. . -..- - / . -. - .-. -.--
select
        wo.id
        ,wor.created_at
        ,row_number() over (partition by wo.id order by wor.created_at) rn
        ,count(wor.id) over (partition by wo.id) hf_num
    from bi_pro.work_order wo
    left join bi_pro.work_order_reply wor on wor.order_id = wo.id
    left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = wor.staff_info_id
    where
        wo.created_at >= date_sub(curdate(),interval 30 day)
        and wo.created_at < curdate()
        and hsi.state = 1
        and hsi.node_department_id = 86
        and wo.order_no = '0716771222555027';
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        wo.id
        ,wor.created_at
        ,row_number() over (partition by wo.id order by wor.created_at) rn
        ,count(wor.id) over (partition by wo.id) hf_num
    from bi_pro.work_order wo
    left join bi_pro.work_order_reply wor on wor.order_id = wo.id
    left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = wor.staff_info_id
    where
        wo.created_at >= date_sub(curdate(),interval 30 day)
        and wo.created_at < curdate()
        and hsi.state = 1
        and hsi.node_department_id = 86
#         and wo.order_no = '0716771222555027'
)

SELECT
    concat('`',wo.order_no)  工单编号
    ,case wo.status when 1 then '未阅读' when 2 then '已经阅读' when 3 then '已回复' when 4 then '已关闭' end 状态
    ,wo.`client_id` 客户ID
    ,wo.`pnos`  运单号
    ,case wo.order_type
        when 1 then '查找运单'
        when 2 then '加快处理'
        when 3 then '调查员工'
        when 4 then '其他'
        when 5 then '网点信息维护提醒'
        when 6 then '培训指导'
        when 7 then '异常业务询问'
        when 8 then '包裹丢失'
        when 9 then '包裹破损'
        when 10 then '货物短少'
        when 11 then '催单'
        when 12 then '有发无到'
        when 13 then '上报包裹不在集包里'
        when 16 then '漏揽收'
        when 50 then '虚假撤销'
        when 17 then '已签收未收到'
        when 18 then '客户投诉'
        when 19 then '修改包裹信息'
        when 20 then '修改 COD 金额'
        when 21 then '解锁包裹'
        when 22 then '申请索赔'
        when 23 then 'MS 问题反馈'
        when 24 then 'FBI 问题反馈'
        when 25 then 'KA System 问题反馈'
        when 26 then 'App 问题反馈'
        when 27 then 'KIT 问题反馈'
        when 28 then 'Backyard 问题反馈'
        when 29 then 'BS/FH 问题反馈'
        when 30 then '系统建议'
        when 31 then '申诉罚款'
        else wo.order_type
    end  工单类型
    ,wo.title 工单标题
    ,wo.created_at 创建时间
    ,t2.hf_num 回复总次数
    ,wor.`created_at` 第一次工单回复时间
    ,timestampdiff(second , wo.created_at, wor.created_at) '第一次回复时长（与创建工单的时间相比）'
    ,t2.created_at 第二次回复时间
    ,timestampdiff(second, wor.created_at, t2.created_at) '第二次回复时长（与第一次的时间对比）'
    ,t3.created_at 第三次回复时间
    ,timestampdiff(second, t2.created_at, t3.created_at) '第三次回复时长（与第二次回复时间对比）'
    ,(timestampdiff(second , wo.created_at, wor.created_at) + ifnull(timestampdiff(second, wor.created_at, t2.created_at), 0) + ifnull(timestampdiff(second, t2.created_at, t3.created_at), 0))/(1 + if(t2.created_at is null ,0 ,1) + if(t3.created_at is null ,0 ,1)) '平均响应时长（每个相差间隔的平均响应时间）'
    ,wo.`closed_at`  工单关闭时间
    ,timestampdiff(second, wo.created_at, wo.closed_at) '总用时长（关闭工单的时间-创建工单的时间）'
    ,wo.`created_staff_info_id`  发起人ID
    ,hi.`name`  发起人姓名
    ,wo.created_store_id 发起人网点ID
    ,ss.`short_name`  发起人所属部门网点code
    ,ss.`name`  发起人所属部门名称
    ,wor.`staff_info_id`  第一次回复人ID
    ,hi1.`name`  第一次回复人姓名
    ,case when ss1.`category` in (1,2,10,13) then 'sp'
        when ss1.`category` in (8,9,12) then 'HUB/BHUB/OS'
        when ss1.`category` IN (4,5,7) then 'SHOP/ushop'
        when ss1.`category` IN (6)  then 'FH'when wo.`store_id` = '22' then 'kam客服中心'
        when wo.`store_id`in (3,'customer_manger') then  '总部客服中心'
        when wo.`store_id`= '12' then 'QA&QC'
        when wo.`store_id`= '18' then 'Flash Home客服中心'
        when wo.`created_store_id` = '22' and wo.`client_id` IN ('AA0302','AA0413','AA0472','AA0545','BF9675','BF9690','CA5901' ) then 'FFM'
        else '其他网点'
    end 受理部门
    ,case
        when wo.`original_acceptance_info` is null and wor.created_at is not null and  TIMESTAMPDIFF(HOUR, wo.`created_at`,wor.`created_at` )<24  then '是'
        when wo.`original_acceptance_info` is not null and wor.created_at is not null and  TIMESTAMPDIFF(HOUR, wo.`created_at`,wor.`created_at` )<72  then '是'
        else '否'
    end  是否在24小时内回复
    ,if(wor.created_at is not null and wo.`original_acceptance_info` is not null  and TIMESTAMPDIFF(HOUR, wo.`created_at`,wor.`created_at` )>48,'是','否') 是否为FH48小时超时工单
    ,TIMESTAMPDIFF(MINUTE, wo.`created_at`,wor.`created_at`) 第一次回复时长
    ,if(wt.`created_at` is not null and nwt.`created_at` is null,'是','否') 是否为工作时间创建工单
    ,case
        when wo.`original_acceptance_info` is null and wor.created_at is not null and TIMESTAMPDIFF(MINUTE, wt.`created_at`,wor.`created_at`)<40 then '是'
        when wo.`original_acceptance_info` is not null and wor.created_at is not null and TIMESTAMPDIFF(MINUTE, wt.`created_at`,wor.`created_at`)<2920 then '是'
        else '否'
    end 工作时间内创建的工单是否在40分钟内回复
    ,case
        when wo.`original_acceptance_info` is null and wor.created_at is not null and TIMESTAMPDIFF(HOUR, nwt.`created_at`,wor.`created_at` )<24 then '是'
        when wo.`original_acceptance_info` is not null and wor.created_at is not null and TIMESTAMPDIFF(HOUR, nwt.`created_at`,wor.`created_at` )<72 then '是'
        else '否'
    end 非工作时间是否在24小时内回复
    ,case
        when nwt.`tg` in (1,3) and wor.`created_at` < concat(date_add(nwt.`created_at`, interval 1 day) , ' 10:00') then '是'
        when nwt.`tg` in (2,4) and wor.`created_at` < concat(date(nwt.`created_at`), ' 10:00') then '是'
        ELSE '否'
    end as '工作时间外创建的工单是否在次日10:00前回复'
from `bi_pro`.work_order wo
left join
    ( #第一次回复
        select
            *
        from
            (
                select
                    wor.`created_at`
                    ,wor.`order_id`
                    ,wor.`staff_info_id`
                    ,row_number() over(partition by wor.`order_id` order by wor.`created_at`) rn
                from `bi_pro`.work_order_reply wor
            )wor
        where wor.rn=1
    )wor on wo.id = wor.`order_id`
left join `bi_pro`.`hr_staff_info` hi on hi.`staff_info_id` = wo.`created_staff_info_id`
left join `bi_pro`.`sys_store` ss on ss.`id` = wo.`created_store_id`
left join `bi_pro`.`hr_staff_info` hi1 on hi1.`staff_info_id` =wor.`staff_info_id`
left join `bi_pro`.`sys_store` ss1 on ss1.`id` = wo.`store_id`
left join
    (   #工作时间
        SELECT
            wo.`id`
            ,wo.`created_at`
            ,date_format(wo.`created_at`,'%w') as weekNum
        FROM `bi_pro`.work_order wo
        where
            date_format(wo.`created_at`,'%w')  between 1 and 5
            and date_format(wo.`created_at`,'1%H%i') between 11000 and 11900
            or (date_format(wo.`created_at`,'%w') in (0,6) and date_format(wo.`created_at`,'1%H%i') between 11000 and 11700)
    ) wt on wt.id = wo.id
left join
    ( #非工作时间
        select  wo.`id`
            ,wo.`created_at`
            ,date_format(wo.`created_at`,'%w') as weeknum
            ,case
                when  date_format(wo.`created_at`,'%w')  between 1 and 5 and date_format(wo.`created_at`,'1%h%i')>11900 and date_format(wo.`created_at`,'1%h%i') <10000 then '1'
                when  date_format(wo.`created_at`,'%w')  between 1 and 5 and date_format(wo.`created_at`,'1%h%i')>=10000 and date_format(wo.`created_at`,'1%h%i') <11000 then '2'
                when  date_format(wo.`created_at`,'%w') in (0,6) and date_format(wo.`created_at`,'1%h%i')>11700 and date_format(wo.`created_at`,'1%h%i') <10000 then '3'
                when  date_format(wo.`created_at`,'%w') in (0,6) and date_format(wo.`created_at`,'1%h%i')>=10000 and date_format(wo.`created_at`,'1%h%i') <11000 then '4'
            end as 'tg'
        from `bi_pro`.work_order wo
        where
            date_format(wo.`created_at`,'%w')  between 1 and 5
            and (date_format(wo.`created_at`,'1%H%i') <11000
            or date_format(wo.`created_at`,'1%H%i')>11900)
            or (date_format(wo.`created_at`,'%w') in (0,6) and (date_format(wo.`created_at`,'1%H%i') <11000 or date_format(wo.`created_at`,'1%H%i')>11700))
    ) nwt on nwt.id = wo.id
left join t t2 on t2.id = wo.id and t2.rn = 2
left join t t3 on t3.id = wo.id and t3.rn = 3
where
    wo.created_at >= date_sub(curdate(),interval 30 day)
    and wo.created_at < curdate()
    -- and wo.status < 4
    -- and wo.`created_store_id` !=1 -- 自动创建的工单
    and hi1.`node_department_id` =86
    and hi1.`state` =1
    and wo.order_no = '0416763084300226';
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        wo.id
        ,wor.created_at
        ,row_number() over (partition by wo.id order by wor.created_at) rn
        ,count(wor.id) over (partition by wo.id) hf_num
    from bi_pro.work_order wo
    left join bi_pro.work_order_reply wor on wor.order_id = wo.id
    left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = wor.staff_info_id
    where
        wo.created_at >= date_sub(curdate(),interval 30 day)
        and wo.created_at < curdate()
        and hsi.state = 1
        and hsi.node_department_id = 86
#         and wo.order_no = '0716771222555027'
)

SELECT
    concat('`',wo.order_no)  工单编号
    ,case wo.status when 1 then '未阅读' when 2 then '已经阅读' when 3 then '已回复' when 4 then '已关闭' end 状态
    ,wo.`client_id` 客户ID
    ,wo.`pnos`  运单号
    ,case wo.order_type
        when 1 then '查找运单'
        when 2 then '加快处理'
        when 3 then '调查员工'
        when 4 then '其他'
        when 5 then '网点信息维护提醒'
        when 6 then '培训指导'
        when 7 then '异常业务询问'
        when 8 then '包裹丢失'
        when 9 then '包裹破损'
        when 10 then '货物短少'
        when 11 then '催单'
        when 12 then '有发无到'
        when 13 then '上报包裹不在集包里'
        when 16 then '漏揽收'
        when 50 then '虚假撤销'
        when 17 then '已签收未收到'
        when 18 then '客户投诉'
        when 19 then '修改包裹信息'
        when 20 then '修改 COD 金额'
        when 21 then '解锁包裹'
        when 22 then '申请索赔'
        when 23 then 'MS 问题反馈'
        when 24 then 'FBI 问题反馈'
        when 25 then 'KA System 问题反馈'
        when 26 then 'App 问题反馈'
        when 27 then 'KIT 问题反馈'
        when 28 then 'Backyard 问题反馈'
        when 29 then 'BS/FH 问题反馈'
        when 30 then '系统建议'
        when 31 then '申诉罚款'
        else wo.order_type
    end  工单类型
    ,wo.title 工单标题
    ,wo.created_at 创建时间
    ,t2.hf_num 回复总次数
    ,wor.`created_at` 第一次工单回复时间
    ,timestampdiff(second , wo.created_at, wor.created_at) '第一次回复时长（与创建工单的时间相比）'
    ,t2.created_at 第二次回复时间
    ,timestampdiff(second, wor.created_at, t2.created_at) '第二次回复时长（与第一次的时间对比）'
    ,t3.created_at 第三次回复时间
    ,timestampdiff(second, t2.created_at, t3.created_at) '第三次回复时长（与第二次回复时间对比）'
    ,(timestampdiff(second , wo.created_at, wor.created_at) + ifnull(timestampdiff(second, wor.created_at, t2.created_at), 0) + ifnull(timestampdiff(second, t2.created_at, t3.created_at), 0))/(1 + if(t2.created_at is null ,0 ,1) + if(t3.created_at is null ,0 ,1)) '平均响应时长（每个相差间隔的平均响应时间）'
    ,wo.`closed_at`  工单关闭时间
    ,timestampdiff(second, wo.created_at, wo.closed_at) '总用时长（关闭工单的时间-创建工单的时间）'
    ,wo.`created_staff_info_id`  发起人ID
    ,hi.`name`  发起人姓名
    ,wo.created_store_id 发起人网点ID
    ,ss.`short_name`  发起人所属部门网点code
    ,ss.`name`  发起人所属部门名称
    ,wor.`staff_info_id`  第一次回复人ID
    ,hi1.`name`  第一次回复人姓名
    ,case when ss1.`category` in (1,2,10,13) then 'sp'
        when ss1.`category` in (8,9,12) then 'HUB/BHUB/OS'
        when ss1.`category` IN (4,5,7) then 'SHOP/ushop'
        when ss1.`category` IN (6)  then 'FH'when wo.`store_id` = '22' then 'kam客服中心'
        when wo.`store_id`in (3,'customer_manger') then  '总部客服中心'
        when wo.`store_id`= '12' then 'QA&QC'
        when wo.`store_id`= '18' then 'Flash Home客服中心'
        when wo.`created_store_id` = '22' and wo.`client_id` IN ('AA0302','AA0413','AA0472','AA0545','BF9675','BF9690','CA5901' ) then 'FFM'
        else '其他网点'
    end 受理部门
    ,case
        when wo.`original_acceptance_info` is null and wor.created_at is not null and  TIMESTAMPDIFF(HOUR, wo.`created_at`,wor.`created_at` )<24  then '是'
        when wo.`original_acceptance_info` is not null and wor.created_at is not null and  TIMESTAMPDIFF(HOUR, wo.`created_at`,wor.`created_at` )<72  then '是'
        else '否'
    end  是否在24小时内回复
    ,if(wor.created_at is not null and wo.`original_acceptance_info` is not null  and TIMESTAMPDIFF(HOUR, wo.`created_at`,wor.`created_at` )>48,'是','否') 是否为FH48小时超时工单
    ,TIMESTAMPDIFF(MINUTE, wo.`created_at`,wor.`created_at`) 第一次回复时长
    ,if(wt.`created_at` is not null and nwt.`created_at` is null,'是','否') 是否为工作时间创建工单
    ,case
        when wo.`original_acceptance_info` is null and wor.created_at is not null and TIMESTAMPDIFF(MINUTE, wt.`created_at`,wor.`created_at`)<40 then '是'
        when wo.`original_acceptance_info` is not null and wor.created_at is not null and TIMESTAMPDIFF(MINUTE, wt.`created_at`,wor.`created_at`)<2920 then '是'
        else '否'
    end 工作时间内创建的工单是否在40分钟内回复
    ,case
        when wo.`original_acceptance_info` is null and wor.created_at is not null and TIMESTAMPDIFF(HOUR, nwt.`created_at`,wor.`created_at` )<24 then '是'
        when wo.`original_acceptance_info` is not null and wor.created_at is not null and TIMESTAMPDIFF(HOUR, nwt.`created_at`,wor.`created_at` )<72 then '是'
        else '否'
    end 非工作时间是否在24小时内回复
    ,case
        when nwt.`tg` in (1,3) and wor.`created_at` < concat(date_add(nwt.`created_at`, interval 1 day) , ' 10:00') then '是'
        when nwt.`tg` in (2,4) and wor.`created_at` < concat(date(nwt.`created_at`), ' 10:00') then '是'
        ELSE '否'
    end as '工作时间外创建的工单是否在次日10:00前回复'
from `bi_pro`.work_order wo
left join
    ( #第一次回复
        select
            *
        from
            (
                select
                    wor.`created_at`
                    ,wor.`order_id`
                    ,wor.`staff_info_id`
                    ,row_number() over(partition by wor.`order_id` order by wor.`created_at`) rn
                from `bi_pro`.work_order_reply wor
            )wor
        where wor.rn=1
    )wor on wo.id = wor.`order_id`
left join `bi_pro`.`hr_staff_info` hi on hi.`staff_info_id` = wo.`created_staff_info_id`
left join `bi_pro`.`sys_store` ss on ss.`id` = wo.`created_store_id`
left join `bi_pro`.`hr_staff_info` hi1 on hi1.`staff_info_id` =wor.`staff_info_id`
left join `bi_pro`.`sys_store` ss1 on ss1.`id` = wo.`store_id`
left join
    (   #工作时间
        SELECT
            wo.`id`
            ,wo.`created_at`
            ,date_format(wo.`created_at`,'%w') as weekNum
        FROM `bi_pro`.work_order wo
        where
            date_format(wo.`created_at`,'%w')  between 1 and 5
            and date_format(wo.`created_at`,'1%H%i') between 11000 and 11900
            or (date_format(wo.`created_at`,'%w') in (0,6) and date_format(wo.`created_at`,'1%H%i') between 11000 and 11700)
    ) wt on wt.id = wo.id
left join
    ( #非工作时间
        select  wo.`id`
            ,wo.`created_at`
            ,date_format(wo.`created_at`,'%w') as weeknum
            ,case
                when  date_format(wo.`created_at`,'%w')  between 1 and 5 and date_format(wo.`created_at`,'1%h%i')>11900 and date_format(wo.`created_at`,'1%h%i') <10000 then '1'
                when  date_format(wo.`created_at`,'%w')  between 1 and 5 and date_format(wo.`created_at`,'1%h%i')>=10000 and date_format(wo.`created_at`,'1%h%i') <11000 then '2'
                when  date_format(wo.`created_at`,'%w') in (0,6) and date_format(wo.`created_at`,'1%h%i')>11700 and date_format(wo.`created_at`,'1%h%i') <10000 then '3'
                when  date_format(wo.`created_at`,'%w') in (0,6) and date_format(wo.`created_at`,'1%h%i')>=10000 and date_format(wo.`created_at`,'1%h%i') <11000 then '4'
            end as 'tg'
        from `bi_pro`.work_order wo
        where
            date_format(wo.`created_at`,'%w')  between 1 and 5
            and (date_format(wo.`created_at`,'1%H%i') <11000
            or date_format(wo.`created_at`,'1%H%i')>11900)
            or (date_format(wo.`created_at`,'%w') in (0,6) and (date_format(wo.`created_at`,'1%H%i') <11000 or date_format(wo.`created_at`,'1%H%i')>11700))
    ) nwt on nwt.id = wo.id
left join t t2 on t2.id = wo.id and t2.rn = 2
left join t t3 on t3.id = wo.id and t3.rn = 3
where
    wo.created_at >= date_sub(curdate(),interval 30 day)
    and wo.created_at < curdate()
    -- and wo.status < 4
    -- and wo.`created_store_id` !=1 -- 自动创建的工单
    and hi1.`node_department_id` =86
    and hi1.`state` =1
    and wo.order_no = '0716771222555027';
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        wo.id
        ,wor.created_at
        ,row_number() over (partition by wo.id order by wor.created_at) rn
        ,count(wor.id) over (partition by wo.id) hf_num
    from bi_pro.work_order wo
    left join bi_pro.work_order_reply wor on wor.order_id = wo.id
    left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = wor.staff_info_id
    where
        wo.created_at >= date_sub(curdate(),interval 30 day)
        and wo.created_at < curdate()
        and hsi.state = 1
        and hsi.node_department_id = 86
#         and wo.order_no = '0716771222555027'
)

SELECT
    concat('`',wo.order_no)  工单编号
    ,case wo.status when 1 then '未阅读' when 2 then '已经阅读' when 3 then '已回复' when 4 then '已关闭' end 状态
    ,wo.`client_id` 客户ID
    ,wo.`pnos`  运单号
    ,case wo.order_type
        when 1 then '查找运单'
        when 2 then '加快处理'
        when 3 then '调查员工'
        when 4 then '其他'
        when 5 then '网点信息维护提醒'
        when 6 then '培训指导'
        when 7 then '异常业务询问'
        when 8 then '包裹丢失'
        when 9 then '包裹破损'
        when 10 then '货物短少'
        when 11 then '催单'
        when 12 then '有发无到'
        when 13 then '上报包裹不在集包里'
        when 16 then '漏揽收'
        when 50 then '虚假撤销'
        when 17 then '已签收未收到'
        when 18 then '客户投诉'
        when 19 then '修改包裹信息'
        when 20 then '修改 COD 金额'
        when 21 then '解锁包裹'
        when 22 then '申请索赔'
        when 23 then 'MS 问题反馈'
        when 24 then 'FBI 问题反馈'
        when 25 then 'KA System 问题反馈'
        when 26 then 'App 问题反馈'
        when 27 then 'KIT 问题反馈'
        when 28 then 'Backyard 问题反馈'
        when 29 then 'BS/FH 问题反馈'
        when 30 then '系统建议'
        when 31 then '申诉罚款'
        else wo.order_type
    end  工单类型
    ,wo.title 工单标题
    ,wo.created_at 创建时间
    ,t1.hf_num 回复总次数
    ,wor.`created_at` 第一次工单回复时间
    ,timestampdiff(second , wo.created_at, wor.created_at) '第一次回复时长（与创建工单的时间相比）'
    ,t2.created_at 第二次回复时间
    ,timestampdiff(second, wor.created_at, t2.created_at) '第二次回复时长（与第一次的时间对比）'
    ,t3.created_at 第三次回复时间
    ,timestampdiff(second, t2.created_at, t3.created_at) '第三次回复时长（与第二次回复时间对比）'
    ,(timestampdiff(second , wo.created_at, wor.created_at) + ifnull(timestampdiff(second, wor.created_at, t2.created_at), 0) + ifnull(timestampdiff(second, t2.created_at, t3.created_at), 0))/(1 + if(t2.created_at is null ,0 ,1) + if(t3.created_at is null ,0 ,1)) '平均响应时长（每个相差间隔的平均响应时间）'
    ,wo.`closed_at`  工单关闭时间
    ,timestampdiff(second, wo.created_at, wo.closed_at) '总用时长（关闭工单的时间-创建工单的时间）'
    ,wo.`created_staff_info_id`  发起人ID
    ,hi.`name`  发起人姓名
    ,wo.created_store_id 发起人网点ID
    ,ss.`short_name`  发起人所属部门网点code
    ,ss.`name`  发起人所属部门名称
    ,wor.`staff_info_id`  第一次回复人ID
    ,hi1.`name`  第一次回复人姓名
    ,case when ss1.`category` in (1,2,10,13) then 'sp'
        when ss1.`category` in (8,9,12) then 'HUB/BHUB/OS'
        when ss1.`category` IN (4,5,7) then 'SHOP/ushop'
        when ss1.`category` IN (6)  then 'FH'when wo.`store_id` = '22' then 'kam客服中心'
        when wo.`store_id`in (3,'customer_manger') then  '总部客服中心'
        when wo.`store_id`= '12' then 'QA&QC'
        when wo.`store_id`= '18' then 'Flash Home客服中心'
        when wo.`created_store_id` = '22' and wo.`client_id` IN ('AA0302','AA0413','AA0472','AA0545','BF9675','BF9690','CA5901' ) then 'FFM'
        else '其他网点'
    end 受理部门
    ,case
        when wo.`original_acceptance_info` is null and wor.created_at is not null and  TIMESTAMPDIFF(HOUR, wo.`created_at`,wor.`created_at` )<24  then '是'
        when wo.`original_acceptance_info` is not null and wor.created_at is not null and  TIMESTAMPDIFF(HOUR, wo.`created_at`,wor.`created_at` )<72  then '是'
        else '否'
    end  是否在24小时内回复
    ,if(wor.created_at is not null and wo.`original_acceptance_info` is not null  and TIMESTAMPDIFF(HOUR, wo.`created_at`,wor.`created_at` )>48,'是','否') 是否为FH48小时超时工单
    ,TIMESTAMPDIFF(MINUTE, wo.`created_at`,wor.`created_at`) 第一次回复时长
    ,if(wt.`created_at` is not null and nwt.`created_at` is null,'是','否') 是否为工作时间创建工单
    ,case
        when wo.`original_acceptance_info` is null and wor.created_at is not null and TIMESTAMPDIFF(MINUTE, wt.`created_at`,wor.`created_at`)<40 then '是'
        when wo.`original_acceptance_info` is not null and wor.created_at is not null and TIMESTAMPDIFF(MINUTE, wt.`created_at`,wor.`created_at`)<2920 then '是'
        else '否'
    end 工作时间内创建的工单是否在40分钟内回复
    ,case
        when wo.`original_acceptance_info` is null and wor.created_at is not null and TIMESTAMPDIFF(HOUR, nwt.`created_at`,wor.`created_at` )<24 then '是'
        when wo.`original_acceptance_info` is not null and wor.created_at is not null and TIMESTAMPDIFF(HOUR, nwt.`created_at`,wor.`created_at` )<72 then '是'
        else '否'
    end 非工作时间是否在24小时内回复
    ,case
        when nwt.`tg` in (1,3) and wor.`created_at` < concat(date_add(nwt.`created_at`, interval 1 day) , ' 10:00') then '是'
        when nwt.`tg` in (2,4) and wor.`created_at` < concat(date(nwt.`created_at`), ' 10:00') then '是'
        ELSE '否'
    end as '工作时间外创建的工单是否在次日10:00前回复'
from `bi_pro`.work_order wo
left join
    ( #第一次回复
        select
            *
        from
            (
                select
                    wor.`created_at`
                    ,wor.`order_id`
                    ,wor.`staff_info_id`
                    ,row_number() over(partition by wor.`order_id` order by wor.`created_at`) rn
                from `bi_pro`.work_order_reply wor
            )wor
        where wor.rn=1
    )wor on wo.id = wor.`order_id`
left join `bi_pro`.`hr_staff_info` hi on hi.`staff_info_id` = wo.`created_staff_info_id`
left join `bi_pro`.`sys_store` ss on ss.`id` = wo.`created_store_id`
left join `bi_pro`.`hr_staff_info` hi1 on hi1.`staff_info_id` =wor.`staff_info_id`
left join `bi_pro`.`sys_store` ss1 on ss1.`id` = wo.`store_id`
left join
    (   #工作时间
        SELECT
            wo.`id`
            ,wo.`created_at`
            ,date_format(wo.`created_at`,'%w') as weekNum
        FROM `bi_pro`.work_order wo
        where
            date_format(wo.`created_at`,'%w')  between 1 and 5
            and date_format(wo.`created_at`,'1%H%i') between 11000 and 11900
            or (date_format(wo.`created_at`,'%w') in (0,6) and date_format(wo.`created_at`,'1%H%i') between 11000 and 11700)
    ) wt on wt.id = wo.id
left join
    ( #非工作时间
        select  wo.`id`
            ,wo.`created_at`
            ,date_format(wo.`created_at`,'%w') as weeknum
            ,case
                when  date_format(wo.`created_at`,'%w')  between 1 and 5 and date_format(wo.`created_at`,'1%h%i')>11900 and date_format(wo.`created_at`,'1%h%i') <10000 then '1'
                when  date_format(wo.`created_at`,'%w')  between 1 and 5 and date_format(wo.`created_at`,'1%h%i')>=10000 and date_format(wo.`created_at`,'1%h%i') <11000 then '2'
                when  date_format(wo.`created_at`,'%w') in (0,6) and date_format(wo.`created_at`,'1%h%i')>11700 and date_format(wo.`created_at`,'1%h%i') <10000 then '3'
                when  date_format(wo.`created_at`,'%w') in (0,6) and date_format(wo.`created_at`,'1%h%i')>=10000 and date_format(wo.`created_at`,'1%h%i') <11000 then '4'
            end as 'tg'
        from `bi_pro`.work_order wo
        where
            date_format(wo.`created_at`,'%w')  between 1 and 5
            and (date_format(wo.`created_at`,'1%H%i') <11000
            or date_format(wo.`created_at`,'1%H%i')>11900)
            or (date_format(wo.`created_at`,'%w') in (0,6) and (date_format(wo.`created_at`,'1%H%i') <11000 or date_format(wo.`created_at`,'1%H%i')>11700))
    ) nwt on nwt.id = wo.id
left join t t1 on t1.id = wo.id and t1.rn = 1
left join t t2 on t2.id = wo.id and t2.rn = 2
left join t t3 on t3.id = wo.id and t3.rn = 3
where
    wo.created_at >= date_sub(curdate(),interval 30 day)
    and wo.created_at < curdate()
    -- and wo.status < 4
    -- and wo.`created_store_id` !=1 -- 自动创建的工单
    and hi1.`node_department_id` =86
    and hi1.`state` =1
    and wo.order_no = '0716771222555027';
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        wo.id
        ,wor.created_at
        ,row_number() over (partition by wo.id order by wor.created_at) rn
        ,count(wor.id) over (partition by wo.id) hf_num
    from bi_pro.work_order wo
    left join bi_pro.work_order_reply wor on wor.order_id = wo.id
    left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = wor.staff_info_id
    where
        wo.created_at >= date_sub(curdate(),interval 30 day)
        and wo.created_at < curdate()
        and hsi.state = 1
        and hsi.node_department_id = 86
#         and wo.order_no = '0716771222555027'
)

SELECT
    concat('`',wo.order_no)  工单编号
    ,case wo.status when 1 then '未阅读' when 2 then '已经阅读' when 3 then '已回复' when 4 then '已关闭' end 状态
    ,wo.`client_id` 客户ID
    ,wo.`pnos`  运单号
    ,case wo.order_type
        when 1 then '查找运单'
        when 2 then '加快处理'
        when 3 then '调查员工'
        when 4 then '其他'
        when 5 then '网点信息维护提醒'
        when 6 then '培训指导'
        when 7 then '异常业务询问'
        when 8 then '包裹丢失'
        when 9 then '包裹破损'
        when 10 then '货物短少'
        when 11 then '催单'
        when 12 then '有发无到'
        when 13 then '上报包裹不在集包里'
        when 16 then '漏揽收'
        when 50 then '虚假撤销'
        when 17 then '已签收未收到'
        when 18 then '客户投诉'
        when 19 then '修改包裹信息'
        when 20 then '修改 COD 金额'
        when 21 then '解锁包裹'
        when 22 then '申请索赔'
        when 23 then 'MS 问题反馈'
        when 24 then 'FBI 问题反馈'
        when 25 then 'KA System 问题反馈'
        when 26 then 'App 问题反馈'
        when 27 then 'KIT 问题反馈'
        when 28 then 'Backyard 问题反馈'
        when 29 then 'BS/FH 问题反馈'
        when 30 then '系统建议'
        when 31 then '申诉罚款'
        else wo.order_type
    end  工单类型
    ,wo.title 工单标题
    ,wo.created_at 创建时间
    ,t1.hf_num 回复总次数
    ,wor.`created_at` 第一次工单回复时间
    ,timestampdiff(second , wo.created_at, wor.created_at) '第一次回复时长（与创建工单的时间相比）'
    ,t2.created_at 第二次回复时间
    ,timestampdiff(second, wor.created_at, t2.created_at) '第二次回复时长（与第一次的时间对比）'
    ,t3.created_at 第三次回复时间
    ,timestampdiff(second, t2.created_at, t3.created_at) '第三次回复时长（与第二次回复时间对比）'
    ,(timestampdiff(second , wo.created_at, wor.created_at) + ifnull(timestampdiff(second, wor.created_at, t2.created_at), 0) + ifnull(timestampdiff(second, t2.created_at, t3.created_at), 0))/(1 + if(t2.created_at is null ,0 ,1) + if(t3.created_at is null ,0 ,1)) '平均响应时长（每个相差间隔的平均响应时间）'
    ,wo.`closed_at`  工单关闭时间
    ,timestampdiff(second, wo.created_at, wo.closed_at) '总用时长（关闭工单的时间-创建工单的时间）'
    ,wo.`created_staff_info_id`  发起人ID
    ,hi.`name`  发起人姓名
    ,wo.created_store_id 发起人网点ID
    ,ss.`short_name`  发起人所属部门网点code
    ,ss.`name`  发起人所属部门名称
    ,wor.`staff_info_id`  第一次回复人ID
    ,hi1.`name`  第一次回复人姓名
    ,case when ss1.`category` in (1,2,10,13) then 'sp'
        when ss1.`category` in (8,9,12) then 'HUB/BHUB/OS'
        when ss1.`category` IN (4,5,7) then 'SHOP/ushop'
        when ss1.`category` IN (6)  then 'FH'when wo.`store_id` = '22' then 'kam客服中心'
        when wo.`store_id`in (3,'customer_manger') then  '总部客服中心'
        when wo.`store_id`= '12' then 'QA&QC'
        when wo.`store_id`= '18' then 'Flash Home客服中心'
        when wo.`created_store_id` = '22' and wo.`client_id` IN ('AA0302','AA0413','AA0472','AA0545','BF9675','BF9690','CA5901' ) then 'FFM'
        else '其他网点'
    end 受理部门
    ,case
        when wo.`original_acceptance_info` is null and wor.created_at is not null and  TIMESTAMPDIFF(HOUR, wo.`created_at`,wor.`created_at` )<24  then '是'
        when wo.`original_acceptance_info` is not null and wor.created_at is not null and  TIMESTAMPDIFF(HOUR, wo.`created_at`,wor.`created_at` )<72  then '是'
        else '否'
    end  是否在24小时内回复
    ,if(wor.created_at is not null and wo.`original_acceptance_info` is not null  and TIMESTAMPDIFF(HOUR, wo.`created_at`,wor.`created_at` )>48,'是','否') 是否为FH48小时超时工单
    ,TIMESTAMPDIFF(MINUTE, wo.`created_at`,wor.`created_at`) 第一次回复时长
    ,if(wt.`created_at` is not null and nwt.`created_at` is null,'是','否') 是否为工作时间创建工单
    ,case
        when wo.`original_acceptance_info` is null and wor.created_at is not null and TIMESTAMPDIFF(MINUTE, wt.`created_at`,wor.`created_at`)<40 then '是'
        when wo.`original_acceptance_info` is not null and wor.created_at is not null and TIMESTAMPDIFF(MINUTE, wt.`created_at`,wor.`created_at`)<2920 then '是'
        else '否'
    end 工作时间内创建的工单是否在40分钟内回复
    ,case
        when wo.`original_acceptance_info` is null and wor.created_at is not null and TIMESTAMPDIFF(HOUR, nwt.`created_at`,wor.`created_at` )<24 then '是'
        when wo.`original_acceptance_info` is not null and wor.created_at is not null and TIMESTAMPDIFF(HOUR, nwt.`created_at`,wor.`created_at` )<72 then '是'
        else '否'
    end 非工作时间是否在24小时内回复
    ,case
        when nwt.`tg` in (1,3) and wor.`created_at` < concat(date_add(nwt.`created_at`, interval 1 day) , ' 10:00') then '是'
        when nwt.`tg` in (2,4) and wor.`created_at` < concat(date(nwt.`created_at`), ' 10:00') then '是'
        ELSE '否'
    end as '工作时间外创建的工单是否在次日10:00前回复'
from `bi_pro`.work_order wo
left join
    ( #第一次回复
        select
            *
        from
            (
                select
                    wor.`created_at`
                    ,wor.`order_id`
                    ,wor.`staff_info_id`
                    ,row_number() over(partition by wor.`order_id` order by wor.`created_at`) rn
                from `bi_pro`.work_order_reply wor
            )wor
        where wor.rn=1
    )wor on wo.id = wor.`order_id`
left join `bi_pro`.`hr_staff_info` hi on hi.`staff_info_id` = wo.`created_staff_info_id`
left join `bi_pro`.`sys_store` ss on ss.`id` = wo.`created_store_id`
left join `bi_pro`.`hr_staff_info` hi1 on hi1.`staff_info_id` =wor.`staff_info_id`
left join `bi_pro`.`sys_store` ss1 on ss1.`id` = wo.`store_id`
left join
    (   #工作时间
        SELECT
            wo.`id`
            ,wo.`created_at`
            ,date_format(wo.`created_at`,'%w') as weekNum
        FROM `bi_pro`.work_order wo
        where
            date_format(wo.`created_at`,'%w')  between 1 and 5
            and date_format(wo.`created_at`,'1%H%i') between 11000 and 11900
            or (date_format(wo.`created_at`,'%w') in (0,6) and date_format(wo.`created_at`,'1%H%i') between 11000 and 11700)
    ) wt on wt.id = wo.id
left join
    ( #非工作时间
        select  wo.`id`
            ,wo.`created_at`
            ,date_format(wo.`created_at`,'%w') as weeknum
            ,case
                when  date_format(wo.`created_at`,'%w')  between 1 and 5 and date_format(wo.`created_at`,'1%h%i')>11900 and date_format(wo.`created_at`,'1%h%i') <10000 then '1'
                when  date_format(wo.`created_at`,'%w')  between 1 and 5 and date_format(wo.`created_at`,'1%h%i')>=10000 and date_format(wo.`created_at`,'1%h%i') <11000 then '2'
                when  date_format(wo.`created_at`,'%w') in (0,6) and date_format(wo.`created_at`,'1%h%i')>11700 and date_format(wo.`created_at`,'1%h%i') <10000 then '3'
                when  date_format(wo.`created_at`,'%w') in (0,6) and date_format(wo.`created_at`,'1%h%i')>=10000 and date_format(wo.`created_at`,'1%h%i') <11000 then '4'
            end as 'tg'
        from `bi_pro`.work_order wo
        where
            date_format(wo.`created_at`,'%w')  between 1 and 5
            and (date_format(wo.`created_at`,'1%H%i') <11000
            or date_format(wo.`created_at`,'1%H%i')>11900)
            or (date_format(wo.`created_at`,'%w') in (0,6) and (date_format(wo.`created_at`,'1%H%i') <11000 or date_format(wo.`created_at`,'1%H%i')>11700))
    ) nwt on nwt.id = wo.id
left join t t1 on t1.id = wo.id and t1.rn = 1
left join t t2 on t2.id = wo.id and t2.rn = 2
left join t t3 on t3.id = wo.id and t3.rn = 3
where
    wo.created_at >= date_sub(curdate(),interval 30 day)
    and wo.created_at < curdate()
    -- and wo.status < 4
    -- and wo.`created_store_id` !=1 -- 自动创建的工单
    and hi1.`node_department_id` =86
    and hi1.`state` =1;
;-- -. . -..- - / . -. - .-. -.--
select
    t.pno
    ,ss.name 妥投网点
    ,wo.content '工单回复'
    ,pi.created_at
from fle_staging.parcel_info pi
join tmpale.tmp_th_pno_03166 t  on t.pno = pi.pno
left join fle_staging.sys_store ss on ss.id = pi.ticket_delivery_store_id
left join
    (
        select
            wo.pnos
            ,wor.content
            ,row_number() over (partition by wo.pnos order by wor.created_at desc) rn
        from bi_pro.work_order wo
        join t on wo.pnos = t.pno
        left join bi_pro.work_order_reply wor on wor.order_id = wo.id
    ) wo on wo.pnos = t.pno and wo.rn = 1;
;-- -. . -..- - / . -. - .-. -.--
select
    t.pno
    ,ss.name 妥投网点
    ,wo.content '工单回复'
    ,pi.created_at
from fle_staging.parcel_info pi
join tmpale.tmp_th_pno_03166 t  on t.pno = pi.pno
left join fle_staging.sys_store ss on ss.id = pi.ticket_delivery_store_id
left join
    (
        select
            wo.pnos
            ,wor.content
            ,row_number() over (partition by wo.pnos order by wor.created_at desc) rn
        from bi_pro.work_order wo
        join tmpale.tmp_th_pno_03166 t on wo.pnos = t.pno
        left join bi_pro.work_order_reply wor on wor.order_id = wo.id
    ) wo on wo.pnos = t.pno and wo.rn = 1;
;-- -. . -..- - / . -. - .-. -.--
select
    t.pno
    ,ss.name 妥投网点
    ,wo.content '工单回复'
    ,group_concat(concat('https://fle-asset-internal.oss-ap-southeast-1.aliyuncs.com/',sa1.object_key)) 签收凭证
    ,concat('https://fle-asset-internal.oss-ap-southeast-1.aliyuncs.com/',sa2.object_key) 其他凭证
from fle_staging.parcel_info pi
join tmpale.tmp_th_pno_03166 t  on t.pno = pi.pno
left join fle_staging.sys_store ss on ss.id = pi.ticket_delivery_store_id
left join
    (
        select
            wo.pnos
            ,wor.content
            ,row_number() over (partition by wo.pnos order by wor.created_at desc) rn
        from bi_pro.work_order wo
        join tmpale.tmp_th_pno_03166 t on wo.pnos = t.pno
        left join bi_pro.work_order_reply wor on wor.order_id = wo.id
    ) wo on wo.pnos = t.pno and wo.rn = 1
left join fle_staging.sys_attachment sa1 on sa1.oss_bucket_key = t.pno and sa1.oss_bucket_type = 'DELIVERY_CONFIRM'
left join fle_staging.sys_attachment sa2 on sa2.oss_bucket_key = t.pno and sa2.oss_bucket_type = 'DELIVERY_CONFIRM_OTHER'
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with rep as
(
    select
        wo.order_no
        ,wo.pnos
        ,wor.created_at
        ,row_number() over (partition by wo.order_no order by wor.created_at ) rn
    from bi_pro.work_order wo
    left join bi_pro.work_order_reply wor on wo.id = wor.order_id
    where
        wo.created_store_id = 3
        and wo.created_at >= date_sub(curdate(), interval 1 day)
        and wo.created_at < curdate()
)
, pho as
(
    select
        pr.pno
        ,pr.routed_at
        ,row_number() over (partition by pr.pno order by pr.routed_at) rk
        ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk2
    from rot_pro.parcel_route pr
    join
        (
            select rep.pnos from rep group by 1
        ) r on pr.pno = r.pnos
    where
        pr.route_action = 'PHONE'
)
select
    date(wo.created_at) Date
    ,wo.order_no 'Ticket ID'
    ,wo.pnos 运单号
    ,wo.client_id 客户ID
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.id is null then '普通ka'
        when kp.`id` is null then '小c'
    end 平台客户
    ,case ci.requester_category
        when 0 then '托运人员'
        when 1 then '收货人员'
        when 2 then '操作人员'
        when 3 then '销售人员'
        when 4 then '客服人员'
    end 请求者角色
    ,case ci.channel_category # 渠道
         when 0 then '电话'
         when 1 then '电子邮件'
         when 2 then '网页'
         when 3 then '网点'
         when 4 then '自主投诉页面'
         when 5 then '网页（facebook）'
         when 6 then 'APPSTORE'
         when 7 then 'Lazada系统'
         when 8 then 'Shopee系统'
         when 9 then 'TikTok'
    end 请求渠道
    ,case wo.status
        when 1 then '未阅读'
        when 2 then '已经阅读'
        when 3 then '已回复'
        when 4 then '已关闭'
    end 工单状态
    ,wo.title 工单主题
    ,case wo.order_type
        when 1 then '查找运单'
        when 2 then '加快处理'
        when 3 then '调查员工'
        when 4 then '其他'
        when 5 then '网点信息维护提醒'
        when 6 then '培训指导'
        when 7 then '异常业务询问'
        when 8 then '包裹丢失'
        when 9 then '包裹破损'
        when 10 then '货物短少'
        when 11 then '催单'
        when 12 then '有发无到'
        when 13 then '上报包裹不在集包里'
        when 16 then '漏揽收'
        when 50 then '虚假撤销'
        when 17 then '已签收未收到'
        when 18 then '客户投诉'
        when 19 then '修改包裹信息'
        when 20 then '修改 COD 金额'
        when 21 then '解锁包裹'
        when 22 then '申请索赔'
        when 23 then 'MS 问题反馈'
        when 24 then 'FBI 问题反馈'
        when 25 then 'KA System 问题反馈'
        when 26 then 'App 问题反馈'
        when 27 then 'KIT 问题反馈'
        when 28 then 'Backyard 问题反馈'
        when 29 then 'BS/FH 问题反馈'
        when 30 then '系统建议'
        when 31 then '申诉罚款'
        else wo.order_type
    end  工单类型
    ,wo.created_at 工单创建时间
    ,rep.created_at 工单回复时间
    ,case wo.is_call
        when 0 then '不需要'
        when 1 then '需要'
    end 致电客户
    ,if(timestampdiff(second, coalesce(rep.created_at, now()), wo.latest_deal_at) > 0, '否', '是') 是否超时
    ,case wo.up_report
        when 0 then '否'
        when 1 then '是'
    end 是否上报虚假工单
    ,datediff(wo.updated_at, wo.created_at) 工单处理天数
    ,wo.store_id '受理网点ID/部门'
    ,case
        when ss.`category` in (1,2,10,13) then 'sp'
        when ss.`category` in (8,9,12) then 'HUB/BHUB/OS'
        when ss.`category` IN (4,5,7) then 'SHOP/ushop'
        when ss.`category` IN (6)  then 'FH'
        when wo.`store_id` = '22' then 'kam客服中心'
        when wo.`store_id`in (3,'customer_manger') then  '总部客服中心'
        when wo.`store_id`= '12' then 'QA&QC'
        when wo.`store_id`= '18' then 'Flash Home客服中心'
        when wo.`created_store_id` = '22' and wo.`client_id` IN ('AA0302','AA0413','AA0472','AA0545','BF9675','BF9690','CA5901' ) then 'FFM'
        else '其他网点'
    end 受理部门
    ,ss.name 网点名称
    ,ss.sorting_no 区域
    ,smr.name Area
    ,smp.name 片区
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
    end as 运单状态
    ,if(pi.state = 5, date(convert_tz(pi.finished_at, '+00:00', '+07:00')), null) 妥投日期
    ,if(pi.state = 5, convert_tz(pi.finished_at, '+00:00', '+07:00'), null ) 妥投时间
    ,convert_tz(p1.routed_at, '+00:00', '+07:00') 第一次联系客户
    ,convert_tz(p2.routed_at, '+00:00', '+07:00') 最后联系客户
    ,if(pi.state = 5, datediff(date(convert_tz(pi.finished_at, '+00:00', '+07:00')), date(convert_tz(pi.created_at, '+00:00', '+07:00'))), null) 揽收至妥投
    ,datediff(curdate(), date(convert_tz(pi.created_at, '+00:00', '+07:00'))) 揽收至今
from bi_pro.work_order wo
join fle_staging.customer_issue ci on wo.customer_issue_id = ci.id
left join rep on rep.order_no = wo.order_no and rep.rn = 1
left join fle_staging.sys_store ss on ss.id = wo.store_id
left join fle_staging.sys_manage_region smr on smr.id = ss.manage_region
left join fle_staging.sys_manage_piece smp on smp.id = ss.manage_piece
left join fle_staging.parcel_info pi on wo.pnos = pi.pno
left join pho p1 on p1.pno = wo.pnos and p1.rk = 1
left join pho p2 on p2.pno = wo.pnos and p2.rk = 1
left join fle_staging.ka_profile kp on kp.id = wo.client_id
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = wo.client_id
where
    wo.created_store_id = 3 -- 总部客服中心
    and wo.created_at >= date_sub(curdate(), interval 1 day)
    and wo.created_at < curdate();
;-- -. . -..- - / . -. - .-. -.--
with t1 as
(
    select
        plt.pno
        ,plt.id
        ,plt.client_id
        ,plt.created_at
        ,plt.last_valid_store_id
        ,plt.last_valid_staff_info_id
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
    join t1 on t1.id = wo.loseparcel_task_id
    left join bi_pro.work_order_reply wor on wor.order_id = wo.id
    left join bi_pro.work_order_img woi on woi.origin_id = wor.id
)
,t2 as
(
    select
        wo.pnos
        ,wo.created_at
        ,row_number() over (partition by wo.pnos order by wo.created_at ) rn
    from bi_pro.work_order wo
    join t1 on t1.pno = wo.pnos
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
    ,t1.last_valid_staff_info_id 最后有效路由操作人
    ,ss_valid.name 最后有效路由网点
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
    ,lst.content 最后一次全组织工单回复内容
    ,1st.wor_content 第一次回复内容
    ,concat('https://fle-asset-internal.oss-ap-southeast-1.aliyuncs.com/',1st.object_key) 第一次回复附件
    ,2nd.wor_content 第二次回复内容
    ,concat('https://fle-asset-internal.oss-ap-southeast-1.aliyuncs.com/',2nd.object_key) 第二次回复附件
    ,3rd.wor_content 第三次回复内容
    ,concat('https://fle-asset-internal.oss-ap-southeast-1.aliyuncs.com/',3rd.object_key) 第三次回复附件
    ,concat('https://fle-asset-internal.oss-ap-southeast-1.aliyuncs.com/',sa1.object_key) 签收凭证
    ,concat('https://fle-asset-internal.oss-ap-southeast-1.aliyuncs.com/',sa2.object_key) 其他凭证
from t1
left join fle_staging.parcel_info pi on pi.pno = t1.pno
left join fle_staging.sys_store dst_ss on dst_ss.id = pi.dst_store_id
left join fle_staging.sys_store del_ss on del_ss.id = pi.ticket_delivery_store_id
left join fle_staging.sys_store ss_valid on ss_valid.id = t1.last_valid_store_id
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
left join t2 fir on fir.pnos = t1.pno and fir.rn = 1
left join
    (
        select
            wo2.pnos
            ,wor.content
            ,row_number() over (partition by wo2.pnos order by wor.created_at desc) rn
        from bi_pro.work_order wo2
        join t1 on t1.pno = wo2.pnos
        left join bi_pro.work_order_reply wor on wor.order_id = wo2.id
        where
            wor.staff_info_id != wo2.created_staff_info_id
    ) lst on lst.pnos = t1.pno and lst.rn = 1
left join fle_staging.sys_attachment sa1 on sa1.oss_bucket_key = t1.pno and sa1.oss_bucket_type = 'DELIVERY_CONFIRM'
left join fle_staging.sys_attachment sa2 on sa2.oss_bucket_key = t1.pno and sa2.oss_bucket_type = 'DELIVERY_CONFIRM_OTHER';
;-- -. . -..- - / . -. - .-. -.--
SELECT
    t.pno,
    DATE_FORMAT(t.created_at, '%Y-%m-%d') as created_date,
    1 AS flag -- 疑似丢失
FROM bi_pro.parcel_lose_task  t
LEFT JOIN bi_pro.parcel_detail  pd ON pd.pno = t.pno
left join fle_staging.sys_store ss on ss.id = pd.resp_store_id
WHERE
    t.source IN (3, 33)
    AND t.state IN (1,2,3,4)
#     AND pd.resp_store_id = '{$storeId}'
    and ss.name = 'PYI_SP-พัทยาใต้';
;-- -. . -..- - / . -. - .-. -.--
select
    hsi.staff_info_id
    ,hsi.hire_date
from bi_pro.hr_staff_info hsi
where
    hsi.staff_info_id in ('119999', '121776', '125595', '127320', '144914', '126471', '129577', '143552', '128544', '130629', '139340', '142684', '121517', '124245', '122849', '147026', '129478', '139564', '138995', '132638', '142468', '142398', '121959', '147204', '140513', '141731', '119363', '143365', '146200', '131902', '146662', '136717', '141425', '147700', '123315', '143644', '146887', '146301', '146973', '147313', '132704', '119263', '129450', '143836', '138168', '126277', '126820', '132318', '127738', '143159', '142878', '120650', '142461', '145659', '137498', '137552', '138000', '123831', '138684', '146078', '147338', '136411', '138850', '148502', '147271', '121614', '137223', '141200', '144392', '146816', '147626', '146985', '147117', '145885', '147910', '126985', '138674', '145092', '147716', '141582', '143109', '144085', '146844', '120671', '132576', '131210', '141791', '145706', '146910', '148060', '148693', '143813', '144606', '144713', '147202', '121549', '136363', '141386', '141151', '143837', '145412', '146858', '135396', '136414', '136979', '146185', '141935', '146629', '135674', '124103', '137645', '141549', '146865', '133938', '139445', '142106', '142674', '145900', '137230', '145800', '146031', '147246', '121500', '124751', '139759', '144557', '145803', '146810', '146970', '147001', '144886', '146472', '123868', '143519', '146076', '146737', '147083', '148413', '133321', '138572', '139911', '143055', '143674', '147333', '147929', '120718', '128919', '147316', '147780', '147828', '148073');
;-- -. . -..- - / . -. - .-. -.--
select
    t.pno
    ,if(de.cod_enabled = 1, '是', '否') 是否COD
    ,de.dst_store_in_time 到达目的地网点时间
from tmpale.tmp_th_pno_0318 t
left join dwm.dwd_ex_th_parcel_details de on de.pno = t.pno;
;-- -. . -..- - / . -. - .-. -.--
select
    t.pno
    ,if(de.cod_enabled = 1, '是', '否') 是否COD
    ,de.dst_store_in_time 到达目的地网点时间
from
    (
        select
            t.pno
        from tmpale.tmp_th_pno_0318 t
        group by 1
    ) t
left join dwm.dwd_ex_th_parcel_details de on de.pno = t.pno;
;-- -. . -..- - / . -. - .-. -.--
select
    t.pno
    ,if(de.cod_enabled = 1, '是', '否') 是否COD
    ,de.pickup_time 揽收时间
    ,de.dst_store_in_time 到达目的地网点时间
from
    (
        select
            t.pno
        from tmpale.tmp_th_pno_0318 t
        group by 1
    ) t
left join dwm.dwd_ex_th_parcel_details de on de.pno = t.pno;
;-- -. . -..- - / . -. - .-. -.--
select
    t.pno
    ,case de.cod_enabled
        when 0 then '否'
        when 1 then '是'
    end 是否COD
    ,de.pickup_time 揽收时间
    ,de.dst_store_in_time
from
    (
        select
            t.pno
        from tmpale.tmp_th_pno_0318 t
        group by 1
    ) t
join dwm.dwd_ex_th_parcel_details de on de.pno = t.pno;
;-- -. . -..- - / . -. - .-. -.--
select
    t.pno
    ,case pi.cod_enabled
        when 0 then '否'
        when 1 then '是'
    end 是否COD
    ,de.dst_store_in_time
from
    (
        select
            t.pno
        from tmpale.tmp_th_pno_0318 t
        group by 1
    ) t
join dwm.dwd_ex_th_parcel_details de on de.pno = t.pno
left join fle_staging.parcel_info pi on pi.pno = t.pno;
;-- -. . -..- - / . -. - .-. -.--
select
    t.pno
    ,pct.claims_amount/100 网点理赔
    ,b.claim_money 闪速理赔
from tmpale.tmp_th_pno_zjq_0319 t
left join  fle_staging.pickup_claims_ticket pct on pct.pno = t.pno and pct.state = 5 and pct.claims_type_category = 1 -- 理赔
left join
    (
        select
            a.*
        from
            (
                select
                    pct.`pno`
                    ,pct.`id`
                    ,row_number() over (partition by pct.`pno` order by pct.`id`  DESC ) row_num
                from bi_pro.parcel_claim_task pct
                where
                    pct.state= 6
            ) a
        where
            a.row_num = 1
    ) a on a.pno = t.pno
left join
    (
        select
            *
        from
            (
                select
                    pcn.`task_id`
                    ,replace(json_extract(pcn.`neg_result`,'$.money'),'\"','') claim_money
                    ,row_number() over (partition by pcn.`task_id` order by pcn.`created_at` DESC ) row_num
                from bi_pro.parcel_claim_negotiation pcn
            ) b
        where
            b.row_num = 1
    ) b on b.task_id = a.id;
;-- -. . -..- - / . -. - .-. -.--
select
    t.运单号
    ,pct.claims_amount/100 网点理赔
    ,b.claim_money 闪速理赔
from tmpale.tmp_th_pno_zjq_0319 t
left join  fle_staging.pickup_claims_ticket pct on pct.pno = t.运单号 and pct.state = 5 and pct.claims_type_category = 1 -- 理赔
left join
    (
        select
            a.*
        from
            (
                select
                    pct.`pno`
                    ,pct.`id`
                    ,row_number() over (partition by pct.`pno` order by pct.`id`  DESC ) row_num
                from bi_pro.parcel_claim_task pct
                where
                    pct.state= 6
            ) a
        where
            a.row_num = 1
    ) a on a.pno = t.运单号
left join
    (
        select
            *
        from
            (
                select
                    pcn.`task_id`
                    ,replace(json_extract(pcn.`neg_result`,'$.money'),'\"','') claim_money
                    ,row_number() over (partition by pcn.`task_id` order by pcn.`created_at` DESC ) row_num
                from bi_pro.parcel_claim_negotiation pcn
            ) b
        where
            b.row_num = 1
    ) b on b.task_id = a.id;
;-- -. . -..- - / . -. - .-. -.--
with rep as
(
    select
        wo.order_no
        ,wo.pnos
        ,wor.created_at
        ,row_number() over (partition by wo.order_no order by wor.created_at ) rn
    from bi_pro.work_order wo
    left join bi_pro.work_order_reply wor on wo.id = wor.order_id
    where
        wo.created_store_id = 3
#         and wo.created_at >= date_sub(curdate(), interval 1 day)
#         and wo.created_at < curdate()
        and wo.created_at >= '2023-03-17'
        and wo.created_at < '2023-03-20'
)
, pho as
(
    select
        pr.pno
        ,pr.routed_at
        ,row_number() over (partition by pr.pno order by pr.routed_at) rk
        ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk2
    from rot_pro.parcel_route pr
    join
        (
            select rep.pnos from rep group by 1
        ) r on pr.pno = r.pnos
    where
        pr.route_action = 'PHONE'
)
select
    date(wo.created_at) Date
    ,wo.order_no 'Ticket ID'
    ,wo.pnos 运单号
    ,wo.client_id 客户ID
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.id is null then '普通ka'
        when kp.`id` is null then '小c'
    end 平台客户
    ,case ci.requester_category
        when 0 then '托运人员'
        when 1 then '收货人员'
        when 2 then '操作人员'
        when 3 then '销售人员'
        when 4 then '客服人员'
    end 请求者角色
    ,case ci.channel_category # 渠道
         when 0 then '电话'
         when 1 then '电子邮件'
         when 2 then '网页'
         when 3 then '网点'
         when 4 then '自主投诉页面'
         when 5 then '网页（facebook）'
         when 6 then 'APPSTORE'
         when 7 then 'Lazada系统'
         when 8 then 'Shopee系统'
         when 9 then 'TikTok'
    end 请求渠道
    ,case wo.status
        when 1 then '未阅读'
        when 2 then '已经阅读'
        when 3 then '已回复'
        when 4 then '已关闭'
    end 工单状态
    ,wo.title 工单主题
    ,case wo.order_type
        when 1 then '查找运单'
        when 2 then '加快处理'
        when 3 then '调查员工'
        when 4 then '其他'
        when 5 then '网点信息维护提醒'
        when 6 then '培训指导'
        when 7 then '异常业务询问'
        when 8 then '包裹丢失'
        when 9 then '包裹破损'
        when 10 then '货物短少'
        when 11 then '催单'
        when 12 then '有发无到'
        when 13 then '上报包裹不在集包里'
        when 16 then '漏揽收'
        when 50 then '虚假撤销'
        when 17 then '已签收未收到'
        when 18 then '客户投诉'
        when 19 then '修改包裹信息'
        when 20 then '修改 COD 金额'
        when 21 then '解锁包裹'
        when 22 then '申请索赔'
        when 23 then 'MS 问题反馈'
        when 24 then 'FBI 问题反馈'
        when 25 then 'KA System 问题反馈'
        when 26 then 'App 问题反馈'
        when 27 then 'KIT 问题反馈'
        when 28 then 'Backyard 问题反馈'
        when 29 then 'BS/FH 问题反馈'
        when 30 then '系统建议'
        when 31 then '申诉罚款'
        else wo.order_type
    end  工单类型
    ,wo.created_at 工单创建时间
    ,rep.created_at 工单回复时间
    ,case wo.is_call
        when 0 then '不需要'
        when 1 then '需要'
    end 致电客户
    ,if(timestampdiff(second, coalesce(rep.created_at, now()), wo.latest_deal_at) > 0, '否', '是') 是否超时
    ,case wo.up_report
        when 0 then '否'
        when 1 then '是'
    end 是否上报虚假工单
    ,datediff(wo.updated_at, wo.created_at) 工单处理天数
    ,wo.store_id '受理网点ID/部门'
    ,case
        when ss.`category` in (1,2,10,13) then 'sp'
        when ss.`category` in (8,9,12) then 'HUB/BHUB/OS'
        when ss.`category` IN (4,5,7) then 'SHOP/ushop'
        when ss.`category` IN (6)  then 'FH'
        when wo.`store_id` = '22' then 'kam客服中心'
        when wo.`store_id`in (3,'customer_manger') then  '总部客服中心'
        when wo.`store_id`= '12' then 'QA&QC'
        when wo.`store_id`= '18' then 'Flash Home客服中心'
        when wo.`created_store_id` = '22' and wo.`client_id` IN ('AA0302','AA0413','AA0472','AA0545','BF9675','BF9690','CA5901' ) then 'FFM'
        else '其他网点'
    end 受理部门
    ,ss.name 网点名称
    ,ss.sorting_no 区域
    ,smr.name Area
    ,smp.name 片区
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
    end as 运单状态
    ,if(pi.state = 5, date(convert_tz(pi.finished_at, '+00:00', '+07:00')), null) 妥投日期
    ,if(pi.state = 5, convert_tz(pi.finished_at, '+00:00', '+07:00'), null ) 妥投时间
    ,convert_tz(p1.routed_at, '+00:00', '+07:00') 第一次联系客户
    ,convert_tz(p2.routed_at, '+00:00', '+07:00') 最后联系客户
    ,if(pi.state = 5, datediff(date(convert_tz(pi.finished_at, '+00:00', '+07:00')), date(convert_tz(pi.created_at, '+00:00', '+07:00'))), null) 揽收至妥投
    ,datediff(curdate(), date(convert_tz(pi.created_at, '+00:00', '+07:00'))) 揽收至今
from bi_pro.work_order wo
join fle_staging.customer_issue ci on wo.customer_issue_id = ci.id
left join rep on rep.order_no = wo.order_no and rep.rn = 1
left join fle_staging.sys_store ss on ss.id = wo.store_id
left join fle_staging.sys_manage_region smr on smr.id = ss.manage_region
left join fle_staging.sys_manage_piece smp on smp.id = ss.manage_piece
left join fle_staging.parcel_info pi on wo.pnos = pi.pno
left join pho p1 on p1.pno = wo.pnos and p1.rk = 1
left join pho p2 on p2.pno = wo.pnos and p2.rk = 1
left join fle_staging.ka_profile kp on kp.id = wo.client_id
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = wo.client_id
where
    wo.created_store_id = 3 -- 总部客服中心
#     and wo.created_at >= date_sub(curdate(), interval 1 day)
#     and wo.created_at < curdate()
    and wo.created_at >= '2023-03-17'
    and wo.created_at < '2023-03-20';
;-- -. . -..- - / . -. - .-. -.--
select
    pd.resp_store_id 网点
    ,plt.created_at 预警日期
    ,plt.pno 单号
    ,pi.cod_amount/100 COD金额
    ,bc.client_name 客户
    ,dt.piece_name 片区
    ,dt.region_name 大区
    ,if(di.pno is not null , '是', '否') 货物丢失
    ,if(di2.pno is not null , '是', '否') 已妥投未回COD
from bi_pro.parcel_lose_task plt
left join bi_pro.parcel_detail pd on pd.pno = plt.pno
left join fle_staging.parcel_info pi on pi.pno = plt.pno
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = plt.client_id
left join dwm.dim_th_sys_store_rd dt on dt.store_id = pd.resp_store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
left join fle_staging.diff_info di on di.pno = plt.pno and di.diff_marker_category in (7,22)
left join fle_staging.diff_info di2 on di2.pno = plt.pno and di2.diff_marker_category in (28)
where
    plt.source in (3,33)  -- c来源
    and plt.state in (1,2,3,4)
group by 3;
;-- -. . -..- - / . -. - .-. -.--
select
    plt.created_at 预警日期
    ,plt.pno 单号
    ,pi.cod_amount/100 COD金额
    ,bc.client_name 客户
    ,dt.store_name 网点
    ,dt.piece_name 片区
    ,dt.region_name 大区
    ,if(di.pno is not null , '是', '否') 货物丢失
    ,if(di2.pno is not null , '是', '否') 已妥投未回COD
from bi_pro.parcel_lose_task plt
left join bi_pro.parcel_detail pd on pd.pno = plt.pno
left join fle_staging.parcel_info pi on pi.pno = plt.pno
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = plt.client_id
left join dwm.dim_th_sys_store_rd dt on dt.store_id = pd.resp_store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
left join fle_staging.diff_info di on di.pno = plt.pno and di.diff_marker_category in (7,22)
left join fle_staging.diff_info di2 on di2.pno = plt.pno and di2.diff_marker_category in (28)
where
    plt.source in (3,33)  -- c来源
    and plt.state in (1,2,3,4)
group by 3;
;-- -. . -..- - / . -. - .-. -.--
select
    plt.created_at 预警日期
    ,plt.pno 单号
    ,pi.cod_amount/100 COD金额
    ,bc.client_name 客户
    ,dt.store_name 网点
    ,dt.piece_name 片区
    ,dt.region_name 大区
    ,if(di.pno is not null , '是', '否') 货物丢失
    ,if(di2.pno is not null , '是', '否') 已妥投未回COD
from bi_pro.parcel_lose_task plt
left join bi_pro.parcel_detail pd on pd.pno = plt.pno
left join fle_staging.parcel_info pi on pi.pno = plt.pno
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = plt.client_id
left join dwm.dim_th_sys_store_rd dt on dt.store_id = pd.resp_store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
left join fle_staging.diff_info di on di.pno = plt.pno and di.diff_marker_category in (7,22)
left join fle_staging.diff_info di2 on di2.pno = plt.pno and di2.diff_marker_category in (28)
where
    plt.source in (3,33)  -- c来源
    and plt.state in (1,2,3,4)
group by 2;
;-- -. . -..- - / . -. - .-. -.--
select
                    pl.pno
                from bi_pro.parcel_lose_task pl
                join fle_staging.parcel_info pi on pl.pno=pi.pno and pi.cod_enabled=0
                where  pl.created_at>='2023-02-01'
                and pl.created_at<'2023-03-01'
                and pl.source=12
                group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
from fle_staging.parcel_info pi
where
    pi.state = 5
    and pi.finished_at >= '2022-12-31 17:00:00'
    and pi.finished_at < '2023-02-28 17:00:00'
    and pi.dst_store_id = 'TH05110303'
    and pi.ticket_delivery_store_id not in ('TH05110303','TH02030204');
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
    ,pi.state
from fle_staging.parcel_info pi
where
     pi.finished_at >= '2022-12-31 17:00:00'
    and pi.finished_at < '2023-02-28 17:00:00'
    and pi.dst_store_id = 'TH05110303'
    and pi.ticket_delivery_store_id not in ('TH05110303','TH02030204');
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
    ,pi.state
from fle_staging.parcel_info pi
left join fle_staging.parcel_info pi2 on pi2.pno = pi.recent_pno
where

    pi.dst_store_id = 'TH05110303'
    and pi.state
    and pi.ticket_delivery_store_id not in ('TH05110303','TH02030204')
    and
        (
             (pi.state = 8 and  pi.finished_at >= '2022-12-31 17:00:00' and pi.finished_at < '2023-02-28 17:00:00')
            or ( pi.state = 7 and pi2.created_at >= '2022-12-31 17:00:00' and pi2.created_at < '2023-02-28 17:00:00')
        );
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
    ,ss.name 妥投网点
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
from fle_staging.parcel_info pi
left join fle_staging.parcel_info pi2 on pi2.pno = pi.recent_pno
left join fle_staging.sys_store ss on ss.id = pi.ticket_delivery_store_id
where

    pi.dst_store_id = 'TH05110303'
    and pi.state
    and pi.ticket_delivery_store_id not in ('TH05110303','TH02030204')
    and
        (
             (pi.state = 8 and  pi.finished_at >= '2022-12-31 17:00:00' and pi.finished_at < '2023-02-28 17:00:00')
            or ( pi.state = 7 and pi2.created_at >= '2022-12-31 17:00:00' and pi2.created_at < '2023-02-28 17:00:00')
        );
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
    ,ss.name 妥投网点
    ,convert_tz(pi.created_at, '+00:00', '+07:00') 揽收时间
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
    ,convert_tz(pi.finished_at, '+00:00', '+07:00') 异常时间
    ,bc.client_name 客户
    ,pi.cod_amount/100 COD金额
from fle_staging.parcel_info pi
left join fle_staging.parcel_info pi2 on pi2.pno = pi.recent_pno
left join fle_staging.sys_store ss on ss.id = pi.ticket_delivery_store_id
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id
where

    pi.dst_store_id = 'TH05110303'
    and pi.state
    and pi.ticket_delivery_store_id not in ('TH05110303','TH02030204')
    and
        (
             (pi.state = 8 and  pi.finished_at >= '2022-12-31 17:00:00' and pi.finished_at < '2023-02-28 17:00:00')
            or ( pi.state = 7 and pi2.created_at >= '2022-12-31 17:00:00' and pi2.created_at < '2023-02-28 17:00:00')
        );
;-- -. . -..- - / . -. - .-. -.--
SELECT
    operator_id,
    name,
    count(if(d.penalties > 0, d.idd, null)) 总处理合计,
    sum(case
       when `action`=1 then 1
       when `action`=3 and `source` in (1,2,3) and d.penalties > 0 then 1
       when `action`=3 and `source` in (5,8,11) and d.penalties > 0 then 3
       when `action`=3 and `source` in (4,6,7) and d.penalties > 0 then 5
       when `action`=4 and `source` in (3,8) and d.penalties > 0 then 3
       when `action`=4 and `source` in (1,4,11) and d.penalties > 0 then 5
       when `action`=4 and `source` in (2,5,6,7) and d.penalties > 0 then 7
       else 0
       end as '得分'
       ) 综合人效得分
FROM
    (
        SELECT
            d.idd
            ,operator_id
            ,name,source
            ,日期วันที่
            ,action
            ,d.penalties
        FROM
            (
                SELECT
                    a.id
                    ,a.operator_id
                    , b.name
                    , c.`source`
                    , DATE_FORMAT(a.created_at, '%Y-%m-%d') as '日期วันที่'
                    , a.action
                    ,CONCAT(c.pno, c.`source`, a.action) idd
                    ,c.penalties
                FROM bi_pro.parcel_cs_operation_log a
                LEFT JOIN bi_pro.hr_staff_info b ON a.operator_id= b.staff_info_id
                LEFT JOIN bi_pro.parcel_lose_task c ON a.task_id= c.id
                WHERE a.type= 1
                    AND a.action IN(1, 3, 4)
                    AND DATE_FORMAT(a.created_at, '%Y-%m-%d') >= '${date}'
                    and  DATE_FORMAT(a.created_at, '%Y-%m-%d') <= '${date1}'
                    and a.operator_id!='10000'
                GROUP BY a.id
            ) d
        GROUP BY d.idd
    )d
 GROUP BY 1,2
 ORDER BY 1;
;-- -. . -..- - / . -. - .-. -.--
with rep as
(
    select
        wo.order_no
        ,wo.pnos
        ,wor.created_at
        ,row_number() over (partition by wo.order_no order by wor.created_at ) rn
    from bi_pro.work_order wo
    left join bi_pro.work_order_reply wor on wo.id = wor.order_id
    where
        wo.created_store_id = 3
        and wo.created_at >= date_sub(curdate(), interval 1 day)
        and wo.created_at < curdate()
#         and wo.created_at >= '2023-03-17'
#         and wo.created_at < '2023-03-20'
)
, pho as
(
    select
        pr.pno
        ,pr.routed_at
        ,row_number() over (partition by pr.pno order by pr.routed_at) rk
        ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk2
    from rot_pro.parcel_route pr
    join
        (
            select rep.pnos from rep group by 1
        ) r on pr.pno = r.pnos
    where
        pr.route_action = 'PHONE'
)
select
    date(wo.created_at) Date
    ,wo.order_no 'Ticket ID'
    ,wo.pnos 运单号
    ,wo.client_id 客户ID
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.id is null then '普通ka'
        when kp.`id` is null then '小c'
    end 平台客户
    ,case ci.requester_category
        when 0 then '托运人员'
        when 1 then '收货人员'
        when 2 then '操作人员'
        when 3 then '销售人员'
        when 4 then '客服人员'
    end 请求者角色
    ,case ci.channel_category # 渠道
         when 0 then '电话'
         when 1 then '电子邮件'
         when 2 then '网页'
         when 3 then '网点'
         when 4 then '自主投诉页面'
         when 5 then '网页（facebook）'
         when 6 then 'APPSTORE'
         when 7 then 'Lazada系统'
         when 8 then 'Shopee系统'
         when 9 then 'TikTok'
    end 请求渠道
    ,case wo.status
        when 1 then '未阅读'
        when 2 then '已经阅读'
        when 3 then '已回复'
        when 4 then '已关闭'
    end 工单状态
    ,wo.title 工单主题
    ,case wo.order_type
        when 1 then '查找运单'
        when 2 then '加快处理'
        when 3 then '调查员工'
        when 4 then '其他'
        when 5 then '网点信息维护提醒'
        when 6 then '培训指导'
        when 7 then '异常业务询问'
        when 8 then '包裹丢失'
        when 9 then '包裹破损'
        when 10 then '货物短少'
        when 11 then '催单'
        when 12 then '有发无到'
        when 13 then '上报包裹不在集包里'
        when 16 then '漏揽收'
        when 50 then '虚假撤销'
        when 17 then '已签收未收到'
        when 18 then '客户投诉'
        when 19 then '修改包裹信息'
        when 20 then '修改 COD 金额'
        when 21 then '解锁包裹'
        when 22 then '申请索赔'
        when 23 then 'MS 问题反馈'
        when 24 then 'FBI 问题反馈'
        when 25 then 'KA System 问题反馈'
        when 26 then 'App 问题反馈'
        when 27 then 'KIT 问题反馈'
        when 28 then 'Backyard 问题反馈'
        when 29 then 'BS/FH 问题反馈'
        when 30 then '系统建议'
        when 31 then '申诉罚款'
        else wo.order_type
    end  工单类型
    ,wo.created_at 工单创建时间
    ,rep.created_at 工单回复时间
    ,case wo.is_call
        when 0 then '不需要'
        when 1 then '需要'
    end 致电客户
    ,if(timestampdiff(second, coalesce(rep.created_at, now()), wo.latest_deal_at) > 0, '否', '是') 是否超时
    ,case wo.up_report
        when 0 then '否'
        when 1 then '是'
    end 是否上报虚假工单
    ,datediff(wo.updated_at, wo.created_at) 工单处理天数
    ,wo.store_id '受理网点ID/部门'
    ,case
        when ss.`category` in (1,2,10,13) then 'sp'
        when ss.`category` in (8,9,12) then 'HUB/BHUB/OS'
        when ss.`category` IN (4,5,7) then 'SHOP/ushop'
        when ss.`category` IN (6)  then 'FH'
        when wo.`store_id` = '22' then 'kam客服中心'
        when wo.`store_id`in (3,'customer_manger') then  '总部客服中心'
        when wo.`store_id`= '12' then 'QA&QC'
        when wo.`store_id`= '18' then 'Flash Home客服中心'
        when wo.`created_store_id` = '22' and wo.`client_id` IN ('AA0302','AA0413','AA0472','AA0545','BF9675','BF9690','CA5901' ) then 'FFM'
        else '其他网点'
    end 受理部门
    ,ss.name 网点名称
    ,ss.sorting_no 区域
    ,smr.name Area
    ,smp.name 片区
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
    end as 运单状态
    ,if(pi.state = 5, date(convert_tz(pi.finished_at, '+00:00', '+07:00')), null) 妥投日期
    ,if(pi.state = 5, convert_tz(pi.finished_at, '+00:00', '+07:00'), null ) 妥投时间
    ,convert_tz(p1.routed_at, '+00:00', '+07:00') 第一次联系客户
    ,convert_tz(p2.routed_at, '+00:00', '+07:00') 最后联系客户
    ,if(pi.state = 5, datediff(date(convert_tz(pi.finished_at, '+00:00', '+07:00')), date(convert_tz(pi.created_at, '+00:00', '+07:00'))), null) 揽收至妥投
    ,datediff(curdate(), date(convert_tz(pi.created_at, '+00:00', '+07:00'))) 揽收至今
from bi_pro.work_order wo
join fle_staging.customer_issue ci on wo.customer_issue_id = ci.id
left join rep on rep.order_no = wo.order_no and rep.rn = 1
left join fle_staging.sys_store ss on ss.id = wo.store_id
left join fle_staging.sys_manage_region smr on smr.id = ss.manage_region
left join fle_staging.sys_manage_piece smp on smp.id = ss.manage_piece
left join fle_staging.parcel_info pi on wo.pnos = pi.pno
left join pho p1 on p1.pno = wo.pnos and p1.rk = 1
left join pho p2 on p2.pno = wo.pnos and p2.rk = 1
left join fle_staging.ka_profile kp on kp.id = wo.client_id
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = wo.client_id
where
    wo.created_store_id = 3 -- 总部客服中心
    and wo.created_at >= date_sub(curdate(), interval 1 day)
    and wo.created_at < curdate()
    and wo.created_at >= '2023-03-17';
;-- -. . -..- - / . -. - .-. -.--
SELECT
    t.pno
    ,pi.client_id 客户ID
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as  客户类型
    ,convert_tz(pi.finished_at,'+00:00','+07:00') 妥投时间
    ,ss.name 妥投网点
    ,convert_tz(pr.routed_at,'+00:00','+07:00') 第一次到件入仓扫描时间
    ,pr.name 第一次到件入仓扫描网点
    ,dpd.last_route_time 最后有效路由时间
    ,dpd.last_cn_route_action 最后有效路由
    ,ps.van_in_proof_id 出车凭证编码
    ,ss2.name 发车网点
    ,ps.next_store_name 下一站
    ,convert_tz(fvp.created_at,'+00:00','+07:00') 打印出车凭证时间
from tmpale.tmp_th_pno_322_1 t
left join fle_staging.parcel_info pi
on t.pno=pi.pno
left join dwm.tmp_ex_big_clients_id_detail bc
on pi.client_id=bc.client_id
left join fle_staging.ka_profile kp
on pi.client_id=kp.id
left join fle_staging.sys_store ss
on pi.ticket_delivery_store_id=ss.id
left join
(
    select pr.*
    from
    (
    SELECT
    pr.pno
    ,pr.routed_at
    ,ss.name
    ,row_number()over(PARTITION by pr.pno order by pr.routed_at) rn
    from rot_pro.parcel_route pr
    left join fle_staging.sys_store ss
    on pr.store_id=ss.id
    where pr.route_action='ARRIVAL_WAREHOUSE_SCAN'
    and pr.routed_at>='2023-02-27'
    )pr where pr.rn=1
)pr on pr.pno=t.pno
left join dwm.dwd_ex_th_parcel_details dpd
on dpd.pno=t.pno
left join
(
    select *
    from
    (
        select
        ps.pno
        ,ps.van_in_proof_id
        ,ps.next_store_name
        ,row_number()over(partition by ps.pno order by van_plan_arrived_at) rn
        from dw_dmd.parcel_store_stage_new ps
        where ps.van_in_proof_id is not null
    )ps where ps.rn=1
)ps on ps.pno=t.pno
left join fle_staging.fleet_van_proof fvp
on fvp.id=ps.van_in_proof_id
left join fle_staging.sys_store ss2
on fvp.store_id=ss2.id;
;-- -. . -..- - / . -. - .-. -.--
SELECT
    t.pno
    ,pi.client_id 客户ID
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as  客户类型
    ,convert_tz(pi.finished_at,'+00:00','+07:00') 妥投时间
    ,ss.name 妥投网点
    ,convert_tz(pr.routed_at,'+00:00','+07:00') 第一次到件入仓扫描时间
    ,pr.name 第一次到件入仓扫描网点
    ,dpd.last_route_time 最后有效路由时间
    ,dpd.last_cn_route_action 最后有效路由
    ,ps.van_in_proof_id 出车凭证编码
    ,ss2.name 发车网点
    ,ps.next_store_name 下一站
    ,convert_tz(fvp.created_at,'+00:00','+07:00') 打印出车凭证时间
from tmpale.tmp_th_pno_322_1 t
left join fle_staging.parcel_info pi
on t.pno=pi.pno
left join dwm.tmp_ex_big_clients_id_detail bc
on pi.client_id=bc.client_id
left join fle_staging.ka_profile kp
on pi.client_id=kp.id
left join fle_staging.sys_store ss
on pi.ticket_delivery_store_id=ss.id
left join
(
    select pr.*
    from
    (
    SELECT
    pr.pno
    ,pr.routed_at
    ,ss.name
    ,row_number()over(PARTITION by pr.pno order by pr.routed_at) rn
    from rot_pro.parcel_route pr
    left join fle_staging.sys_store ss
    on pr.store_id=ss.id
    where pr.route_action='ARRIVAL_WAREHOUSE_SCAN'
    and pr.routed_at>='2023-02-27'
    )pr where pr.rn=1
)pr on pr.pno=t.pno
left join dwm.dwd_ex_th_parcel_details dpd
on dpd.pno=t.pno
left join
(
    select *
    from
    (
        select
        ps.pno
        ,ps.van_in_proof_id
        ,ps.next_store_name
        ,row_number()over(partition by ps.pno order by van_plan_arrived_at) rn
        from dw_dmd.parcel_store_stage_new ps
        join tmpale.tmp_th_pno_322_1 t on ps.pno = t.pno
        where ps.van_in_proof_id is not null
    )ps where ps.rn=1
)ps on ps.pno=t.pno
left join fle_staging.fleet_van_proof fvp
on fvp.id=ps.van_in_proof_id
left join fle_staging.sys_store ss2
on fvp.store_id=ss2.id;
;-- -. . -..- - / . -. - .-. -.--
select date_format(now(), '1%h%i');
;-- -. . -..- - / . -. - .-. -.--
select
    *
from bi_pro.work_order wo
where
    date_format(wo.`created_at`,'1%h%i')>11900
limit 100;
;-- -. . -..- - / . -. - .-. -.--
select
    t.pno
    ,count(pct.id)
from fle_staging.pickup_claims_ticket pct
join tmpale.tmp_th_pno_0323 t on t.pno = pct.pno
group by 1;
;-- -. . -..- - / . -. - .-. -.--
SELECT
    distinct pls.pno '运单号เลขพัสดุ'
    ,c.created_at 首次预警时间
    ,ds.store_name '网点名称'
    ,pls.created_at '任务生成时间เวลาที่จัดการสำเร็จ'
    ,if(
        TIMESTAMPDIFF(hour,pls.created_at,now())<48,
    concat(cast(TIMESTAMPDIFF(minute,now(),date_add(pls.created_at,interval 2 day))/60 as int),'h ',cast(round(TIMESTAMPDIFF(minute,now(),date_add(pls.created_at,interval 2 day))%60,0)as int),'min'),
    concat('已超时',concat(cast(TIMESTAMPDIFF(minute,date_add(pls.created_at,interval 2 day),now())/60 as int),'h ',cast(round(TIMESTAMPDIFF(minute,date_add(pls.created_at,interval 2 day),now())%60,0)as int),'min'))) '任务处理倒计时เวลาที่สะสม'
    ,pls.pack_no '集包号เลขแบ็กกิ้ง'
    ,pls.arrival_time '入仓时间เวลาที่เข้าคลัง'
    ,pls.parcel_created_at '揽件时间เวลาที่รับ'
    ,pls.proof_id '出车凭证ใบรับรองปล่อยรถ'
    ,case pls.state
    when 1 then '待处理'
    when 2 then '网点处理'
    when 3 then '超时自动处理'
    when 4 then 'QAQC处理'
    when 5 then '已更新路由(无需处理)'
    end  '状态สถานะ'
    ,case pls.speed
    when 1 then '是'
    when 2 then '否'
    end  'SPEED件มีพัสดุSpeed'
    ,pls.last_valid_action '最后有效路由สถานะสุดท้าย'
    ,pls.last_valid_at '最后操作时间เวลาสุดท้ายที่ดำเนินการ'
    ,ds2.store_name '最后有效路由所在网点สาขาสุดท้ายที่ดำเนินการ'
    ,ds.piece_name '片区District'
    ,ds.region_name '大区Area'
    ,bc.client_name 客户名称
from bi_center.parcel_lose_task_sub_c pls
left join fle_staging.parcel_info pi on pi.pno = pls.pno
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id
left join dwm.dim_th_sys_store_rd ds on pls.store_id = ds.store_id and ds.stat_date = date_sub(curdate(), interval 1 day )
left join dwm.dim_th_sys_store_rd ds2 on pls.last_valid_store_id = ds2.store_id and ds2.stat_date = date_sub(curdate(), interval 1 day )
left join
    (
        select
            pls.pno
            ,plt.created_at
            ,row_number() over (partition by pls.pno order by plt.created_at) rn
        from bi_center.parcel_lose_task_sub_c pls
        left join bi_pro.parcel_lose_task plt on pls.pno = plt.pno and plt.source = 3
        where
             pls.created_at > '2023-01-09 00:00:00'
            and pls.state= 1
    ) c on c.pno = pls.pno and c.rn = 1
where
    pls.created_at > '2023-01-09 00:00:00'
    and pls.state=1
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    hsi.staff_info_id
    ,ss.name
from bi_pro.hr_staff_info hsi
left join fle_staging.sys_store ss on ss.id = hsi.sys_store_id
where
    hsi.staff_info_id in (52613,632192,3365244);
;-- -. . -..- - / . -. - .-. -.--
select
    plt.pno 运单号
    ,if(pi.returned = 1, pi.pno, pi.recent_pno) 退件单号
    ,ss.name 判定责任网点
    ,dst_ss.name 目的地网点
    ,ss2.name 揽件网点
    ,pi.cod_amount/100 COD金额
    ,plt.last_valid_action 最后有效路由
    ,plt.last_valid_staff_info_id 最后有效路由操作员工
    ,ss3.name 最后有效路由操作人所属网点
    ,plr.staff_id 责任人
    ,hsi2.name 责任人姓名
    ,ss4.name 责任人所属网点
from bi_pro.parcel_lose_task plt
left join fle_staging.parcel_info pi on pi.pno = plt.pno
left join bi_pro.parcel_lose_responsible plr on plr.lose_task_id = plt.id
left join fle_staging.sys_store ss on ss.id = plr.store_id
left join fle_staging.sys_store dst_ss on dst_ss.id = pi.dst_store_id
left join fle_staging.sys_store ss2 on ss2.id = pi.ticket_pickup_store_id
left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = plt.last_valid_staff_info_id
left join fle_staging.sys_store ss3 on ss3.id = hsi.sys_store_id
left join bi_pro.hr_staff_info hsi2 on hsi2.staff_info_id = plr.staff_id
left join fle_staging.sys_store ss4 on ss4.id = hsi2.sys_store_id
where
    plt.updated_at >= '2023-03-01'
    and plt.state = 6
    and plt.duty_result = 1
    and plt.source in (1,2,3,12)
    and plr.store_id = 'TH01400201';
;-- -. . -..- - / . -. - .-. -.--
select
    plt.pno 运单号
    ,plt.id
    ,if(pi.returned = 1, pi.pno, pi.recent_pno) 退件单号
    ,ss.name 判定责任网点
    ,dst_ss.name 目的地网点
    ,ss2.name 揽件网点
    ,pi.cod_amount/100 COD金额
    ,plt.last_valid_action 最后有效路由
    ,plt.last_valid_staff_info_id 最后有效路由操作员工
    ,ss3.name 最后有效路由操作人所属网点
    ,plr.staff_id 责任人
    ,hsi2.name 责任人姓名
    ,ss4.name 责任人所属网点
from bi_pro.parcel_lose_task plt
left join fle_staging.parcel_info pi on pi.pno = plt.pno
left join bi_pro.parcel_lose_responsible plr on plr.lose_task_id = plt.id
left join fle_staging.sys_store ss on ss.id = plr.store_id
left join fle_staging.sys_store dst_ss on dst_ss.id = pi.dst_store_id
left join fle_staging.sys_store ss2 on ss2.id = pi.ticket_pickup_store_id
left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = plt.last_valid_staff_info_id
left join fle_staging.sys_store ss3 on ss3.id = hsi.sys_store_id
left join bi_pro.hr_staff_info hsi2 on hsi2.staff_info_id = plr.staff_id
left join fle_staging.sys_store ss4 on ss4.id = hsi2.sys_store_id
where
    plt.updated_at >= '2023-03-01'
    and plt.state = 6
    and plt.duty_result = 1
    and plt.source in (1,2,3,12)
    and plr.store_id = 'TH01400201';
;-- -. . -..- - / . -. - .-. -.--
select
    plt.pno 运单号
    ,plt.id
    ,if(pi.returned = 1, pi.pno, pi.recent_pno) 退件单号
    ,ss.name 判定责任网点
    ,dst_ss.name 目的地网点
    ,ss2.name 揽件网点
    ,pi.cod_amount/100 COD金额
    ,plt.last_valid_action 最后有效路由
    ,plt.last_valid_staff_info_id 最后有效路由操作员工
    ,ss3.name 最后有效路由操作人所属网点
    ,plr.staff_id 责任人
    ,hsi2.is_sub_staff
    ,hsi2.name 责任人姓名
    ,ss4.name 责任人所属网点
from bi_pro.parcel_lose_task plt
left join fle_staging.parcel_info pi on pi.pno = plt.pno
left join bi_pro.parcel_lose_responsible plr on plr.lose_task_id = plt.id
left join fle_staging.sys_store ss on ss.id = plr.store_id
left join fle_staging.sys_store dst_ss on dst_ss.id = pi.dst_store_id
left join fle_staging.sys_store ss2 on ss2.id = pi.ticket_pickup_store_id
left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = plt.last_valid_staff_info_id
left join fle_staging.sys_store ss3 on ss3.id = hsi.sys_store_id
left join bi_pro.hr_staff_info hsi2 on hsi2.staff_info_id = plr.staff_id
left join fle_staging.sys_store ss4 on ss4.id = hsi2.sys_store_id
where
    plt.updated_at >= '2023-03-01'
    and plt.state = 6
    and plt.duty_result = 1
    and plt.source in (1,2,3,12)
    and plr.store_id = 'TH01400201';
;-- -. . -..- - / . -. - .-. -.--
with rep as
(
    select
        wo.order_no
        ,wo.pnos
        ,wor.created_at
        ,row_number() over (partition by wo.order_no order by wor.created_at ) rn
    from bi_pro.work_order wo
    left join bi_pro.work_order_reply wor on wo.id = wor.order_id
    where
        wo.created_store_id = 3
        and wo.created_at >= date_sub(curdate(), interval 1 day)
        and wo.created_at < curdate()
)
, pho as
(
    select
        pr.pno
        ,pr.routed_at
        ,row_number() over (partition by pr.pno order by pr.routed_at) rk
        ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk2
    from rot_pro.parcel_route pr
    join
        (
            select rep.pnos from rep group by 1
        ) r on pr.pno = r.pnos
    where
        pr.route_action = 'PHONE'
)
select
    date(wo.created_at) Date
    ,wo.order_no 'Ticket ID'
    ,wo.pnos 运单号
    ,wo.client_id 客户ID
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.id is null then 'ka'
        when kp.`id` is null then 'GE'
    end '平台客户ลูกค้าแพลตฟอร์ม'
    ,case ci.requester_category
        when 0 then '托运人员 ผู้ส่ง'
        when 1 then '收货人员 ผู้รับ'
        when 2 then '操作人员 ฝ่ายปฏิบัติการ(Operation)'
        when 3 then '销售人员 พนักงานขาย(Sales)'
        when 4 then '客服人员 ฝ่ายบริการลูกค้า(CS)'
    end '请求者角色ผู้ร้องขอ'
    ,case ci.channel_category
         when 0 then '电话 โทรศัพท์'
         when 1 then '电子邮件 อีเมล'
         when 2 then '网页 เว็บไซต์'
         when 3 then '网点 สาขา'
         when 4 then '自主投诉页面 การส่งคำร้องโดยลูกค้า'
         when 5 then '网页（facebook） facebook'
         when 6 then 'APPSTORE APPSTORE'
         when 7 then 'Lazada系统 X-Space（LZD）'
         when 8 then 'Shopee系统 In House(Shopee)'
         when 9 then 'TikTok TikTok'
    end '请求渠道ช่องทางการติดต่อ'
    ,case wo.status
        when 1 then '未阅读ไม่ได้อ่าน'
        when 2 then '已经阅读อ่านแล้ว'
        when 3 then '已回复ตอบกลับแล้ว'
        when 4 then '已关闭ปิดแล้ว'
    end '状态สถานะTicket'
    ,wo.title 工单主题
    ,case wo.order_type
        when 1 then '查找运单 ค้นหาพัสดุ'
        when 2 then '加快处理 เร่งจัดการ'
        when 3 then '调查员工 ตรวจสอบพนักงาน'
        when 4 then '其他 อื่นๆ'
        when 5 then '网点信息维护提醒 แจ้งเตือนดูแลข้อมูลสาขา'
        when 6 then '培训指导 แนะนำอบรม'
        when 7 then '异常业务询问 ตรวจสอบการทำงานผิดปกติ'
        when 8 then '包裹丢失 พัสดุสูญหาย'
        when 9 then '包裹破损 พัสดุเสียหาย'
        when 10 then '货物短少 พัสดุขาดหาย'
        when 11 then '催单 เร่งติดตามพัสดุ'
        when 12 then '有发无到 พัสดุตกหล่น'
        when 13 then '上报包裹不在集包里 รายงานพัสดุไม่อยู่ในถุงแบ๊คกิ้ง'
        when 16 then '漏揽收 รับพัสดุตกหล่น'
        when 50 then '虚假撤销 ยกเลิกเป็นเท็จ'
        when 17 then '已签收未收到 เซ็นรับไม่ได้รับ'
        when 18 then '客户投诉 ลูกค้าร้องเรียน'
        when 19 then '修改包裹信息 แก้ไขข้อมูลพัสดุ'
        when 20 then '修改 COD 金额 แก้ไขยอดCOD'
        when 21 then '解锁包裹 ปลดล็อกพัสดุ'
        when 22 then '申请索赔 เคลม'
        when 23 then 'MS 问题反馈 แจ้งปัญหาMS'
        when 24 then 'FBI 问题反馈 แจ้งปัญหาFBI'
        when 25 then 'KA System 问题反馈 แจ้งปัญหาKA System'
        when 26 then 'App 问题反馈 แจ้งปัญหาApp'
        when 27 then 'KIT 问题反馈 แจ้งปัญหาKIT'
        when 28 then 'Backyard 问题反馈 แจ้งปัญหาBackyard'
        when 29 then 'BS/FH 问题反馈 แจ้งปัญหาBS/FH'
        when 30 then '系统建议 คำแนะนำระบบ'
        when 31 then '申诉罚款 ยื่นขอคืนค่าปรับ'
        else wo.order_type
    end  '工单类型ประเภทTicket'
    ,wo.created_at 工单创建时间
    ,rep.created_at 工单回复时间
    ,case wo.is_call
        when 0 then '不需要 ไม่ต้องการ'
        when 1 then '需要 ต้องการ'
    end '致电客户ลูกค้าต้องการให้โทรหาหรือไม่'
    ,if(timestampdiff(second, coalesce(rep.created_at, now()), wo.latest_deal_at) > 0, 'NO', 'YES') 是否超时
    ,case wo.up_report
        when 0 then 'NO'
        when 1 then 'YES'
    end 是否上报虚假工单
    ,datediff(wo.updated_at, wo.created_at) 工单处理天数
    ,wo.store_id '受理网点ID/部门'
    ,case
        when ss.`category` in (1,2,10,13) then 'sp'
        when ss.`category` in (8,9,12) then 'HUB/BHUB/OS'
        when ss.`category` IN (4,5,7) then 'SHOP/ushop'
        when ss.`category` IN (6)  then 'FH'
        when wo.`store_id` = '22' then 'kam客服中心'
        when wo.`store_id`in (3,'customer_manger') then  '总部客服中心'
        when wo.`store_id`= '12' then 'QA&QC'
        when wo.`store_id`= '18' then 'Flash Home客服中心'
        when wo.`created_store_id` = '22' and wo.`client_id` IN ('AA0302','AA0413','AA0472','AA0545','BF9675','BF9690','CA5901' ) then 'FFM'
        else '其他网点'
    end 受理部门
    ,ss.name 网点名称
    ,ss.sorting_no 区域
    ,smr.name Area
    ,smp.name 片区
    ,case pi.state
        when 1 then '已揽收 รับพัสดุแล้ว'
        when 2 then '运输中 ระหว่างการขนส่ง'
        when 3 then '派送中 ระหว่างการจัดส่ง'
        when 4 then '已滞留 พัสดุคงคลัง'
        when 5 then '已签收 เซ็นรับแล้ว'
        when 6 then '疑难件处理中 ระหว่างจัดการพัสดุมีปัญหา'
        when 7 then '已退件 ตีกลับแล้ว'
        when 8 then '异常关闭 ปิดงานมีปัญหา'
        when 9 then '已撤销 ยกเลิกแล้ว'
    end as '运单状态สถานะพัสดุ'
    ,if(pi.state = 5, date(convert_tz(pi.finished_at, '+00:00', '+07:00')), null) 妥投日期
    ,if(pi.state = 5, convert_tz(pi.finished_at, '+00:00', '+07:00'), null ) 妥投时间
    ,convert_tz(p1.routed_at, '+00:00', '+07:00') 第一次联系客户
    ,convert_tz(p2.routed_at, '+00:00', '+07:00') 最后联系客户
    ,if(pi.state = 5, datediff(date(convert_tz(pi.finished_at, '+00:00', '+07:00')), date(convert_tz(pi.created_at, '+00:00', '+07:00'))), null) 揽收至妥投
    ,datediff(curdate(), date(convert_tz(pi.created_at, '+00:00', '+07:00'))) 揽收至今
from bi_pro.work_order wo
join fle_staging.customer_issue ci on wo.customer_issue_id = ci.id
left join rep on rep.order_no = wo.order_no and rep.rn = 1
left join fle_staging.sys_store ss on ss.id = wo.store_id
left join fle_staging.sys_manage_region smr on smr.id = ss.manage_region
left join fle_staging.sys_manage_piece smp on smp.id = ss.manage_piece
left join fle_staging.parcel_info pi on wo.pnos = pi.pno
left join pho p1 on p1.pno = wo.pnos and p1.rk = 1
left join pho p2 on p2.pno = wo.pnos and p2.rk = 1
left join fle_staging.ka_profile kp on kp.id = wo.client_id
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = wo.client_id
where
    wo.created_store_id = 3 -- 总部客服中心
    and wo.created_at >= date_sub(curdate(), interval 1 day)
    and wo.created_at < curdate();
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
from fle_staging.parcel_info pi
where
    pi.state = 5
    and pi.pno in ('THT200288BJ44Z', 'THT011889P7W1Z', 'THT08018AP9N6Z', 'THT01478BKPM6Z', 'THT12048AR8M6Z', 'THT04068B2XK9Z', 'THT04038ADZA4Z', 'THT471489CCW9Z', 'THT01018BHJR1Z', 'THT67028A0M37Z', 'THT30228AP4F0Z', 'THT10028D09C3Z', 'THT24038CYK40Z', 'THT380289QMR9Z', 'THT10038A9J99Z', 'THT21068C0B07Z', 'THT21068B1W23Z', 'THT31138967P7Z', 'THT19078A4UM3Z', 'THT04068AQTF9Z', 'THT03018AYVK2Z', 'THT01238CZX55Z', 'THT01178B6W16Z', 'THT01178B9WB7Z', 'THT01188ASP94Z', 'THT050689ZAY3Z', 'THT01218BMVE4Z', 'THT37018AMX53Z', 'THT040287D526Z', 'THT01268CPRY4Z', 'THT01038D3450Z', 'THT04028C6GT6Z', 'THT01188BKM48Z', 'THT04048BJM47Z', 'THT01178AYSM7Z', 'THT56127X9U11Z', 'THT03048C2F29Z', 'THT10108APCS8Z', 'THT02028BZRS5Z', 'THT61088ANS09Z', 'THT01058BQRP5Z', 'THT01188A81A1Z', 'THT14078AKYB5Z', 'THT272188P2X2Z', 'THT26058BN5Z3Z', 'THT0151860E02Z', 'THT01098ANHN3Z', 'THT37018BYJR8Z', 'THT24038BSJW1Z', 'THT21058CP7X9Z', 'THT240186SB89Z', 'THT0143895BU8Z', 'THT01398B8JK6Z', 'THT012789G282Z', 'THT012789KD63Z', 'THT012789KF13Z', 'THT3110886EY2Z', 'THT2604883Z53Z', 'THT15068A1QE8Z', 'THT0141890RQ1Z', 'THT20048A3QN0Z', 'THT320588APV6Z', 'THT0143891MP8Z', 'THT01138C7657Z', 'THT01038AX3D7Z', 'THT01068AZ5F4Z', 'THT01168AADM0Z', 'THT37178A3H77Z', 'THT02038C21K7Z', 'THT03018BT8B1Z', 'THT640286G729Z', 'THT640286G727Z', 'THT16038BFAU0Z', 'THT01438APXH8Z', 'THT150689MW63Z', 'THT20048BXBP4Z', 'THT0103886NR2Z', 'THT050389J3Q0Z', 'THT04048BN5Y9Z', 'THT013987NZ66Z', 'THT390989ZH26Z', 'THT01088AH0X2Z', 'THT160187JDV9Z', 'THT160187JDS9Z', 'THT014389WVC0Z', 'THT60017NNVX4Z', 'THT200488P641Z', 'THT1011893E69Z', 'THT02058A5E45Z', 'THT4401885RE4Z', 'THT14078AC5B6Z', 'THT16018AH797Z', 'THT100289Z333Z', 'THT01438A5267Z', 'THT01288AP1H2Z', 'THT070189GNQ4Z', 'THT01218839G7Z', 'THT040284MQU7Z', 'THT05118834Q7Z', 'THT04028AFEW5Z', 'THT01438A5HQ1Z', 'THT24058B0BG6Z', 'THT020389H6H8Z', 'THT200486WW90Z', 'THT02018929Y3Z', 'THT014282P7K5Z', 'THT0206889BE0Z', 'THT04028348C6Z', 'THT01088B6GV4Z', 'THT600788KRG8Z', 'THT0201871AA4Z', 'THT01398833X3Z', 'THT0130882MC4Z', 'THT301889V8Z0Z', 'THT53018536W5Z', 'THT05118A2VZ6Z', 'THT200584QBW3Z', 'THT050386RRH9Z', 'THT190787NZK0Z', 'THT72058901A6Z', 'THT200889EN35Z', 'THT01168A8452Z', 'THT014388QSV9Z', 'THT200184AD69Z', 'THT050682SW38Z', 'THT3304888MP7Z', 'THT20048A1556Z', 'THT011689H8J3Z', 'THT010989EB65Z', 'THT67037SCQG4Z', 'THT030187WW06Z', 'THT3706887E37Z', 'THT020286X0U4Z', 'THT020288Y928Z', 'THT0206871VX8Z', 'THT051189Z0Y7Z', 'THT200889BG00Z', 'THT030287MHS2Z', 'THT120488VCM2Z', 'THT013988QV36Z', 'THT040588MRZ5Z', 'THT471584CDW0Z', 'THT012686SZC1Z', 'THT370984E380Z', 'THT0121887GR9Z', 'THT260688FV02Z', 'THT020488BWZ3Z', 'THT260688FV00Z', 'THT271888NCU9Z', 'THT700486RN37Z', 'THT0110880J85Z', 'THT02018757T6Z', 'THT240185DWG4Z', 'THT040688TCS8Z', 'THT390185YSX3Z', 'THT210687MPM8Z', 'THT240485JXE4Z', 'THT6703873JQ7Z', 'THT520185FCJ8Z', 'THT02068271Q1Z', 'THT0123897MH3Z', 'THT160287GJ24Z', 'THT6101882BD7Z', 'THT2007838KF2Z', 'THT020288VUY1Z', 'THT310484A825Z', 'THT011680CGJ5Z', 'THT014084QXD9Z', 'THT012886G7Y0Z', 'THT01308723F2Z', 'THT160287GGT8Z', 'THT030187Y5M3Z', 'THT070387Q2G7Z', 'THT290688ANZ6Z', 'THT210687ZZ19Z', 'THT01058529R9Z', 'THT100187T9S3Z', 'THT010188NZY7Z', 'THT270188FFT7Z', 'THT16038699N6Z', 'THT013987YE98Z', 'THT020486WHJ6Z', 'THT0203845MT6Z', 'THT290386S0N4Z', 'THT450182MVV5Z', 'THT01018625A7Z', 'THT013986X202Z', 'THT01162FE549Z', 'THT0105861E53Z', 'THT70018515N0Z', 'THT70018515P0Z', 'THT520585GFY4Z', 'THT751083E6E0Z', 'THT311487F4S7Z', 'THT013986X200Z', 'THT011882SR73Z', 'THT1804818HF5Z', 'THT670383RAV5Z', 'THT200481R478Z', 'THT450185YAF0Z', 'THT200783YXV4Z', 'THT200783YXV4Z', 'THT030484PZY2Z', 'THT01068711N2Z', 'THT012185K5K0Z', 'THT0401873M61Z', 'THT0203857PC7Z', 'THT1104864B52Z', 'THT0139875CM9Z', 'THT1003867YA0Z', 'THT6703839PN1Z', 'THT013986Y848Z', 'THT470185BX35Z', 'THT2004849TM9Z', 'THT013684EQG8Z', 'THT0114875F68Z', 'THT71108473R1Z', 'THT01057Y2T94Z', 'THT180484ANW2Z', 'THT015185SAD2Z', 'THT013480UUS9Z', 'THT013985A969Z', 'THT300784QXN7Z', 'THT711184MU00Z', 'THT012285UGV9Z', 'THT20048230H0Z', 'THT302285DZG7Z', 'THT050785T8D0Z', 'THT2004861F84Z', 'THT66088559X7Z', 'THT270285ME43Z', 'THT200485P688Z', 'THT4719854HZ1Z', 'THT670285BJW6Z', 'THT01037ZKA34Z', 'THT0516855D14Z', 'THT580685UPR0Z', 'THT200485XK28Z', 'THT200586YT85Z', 'THT01428558S4Z', 'THT4509815GE2Z', 'THT020284KKR9Z', 'THT0406868012Z', 'THT0201856UR4Z', 'THT0104872421Z', 'THT020385YVZ5Z', 'THT1001862E01Z', 'THT0201861MR4Z', 'THT013183BSQ8Z', 'THT20047XSNS6Z', 'THT150685SC05Z', 'THT7111851AA2Z', 'THT020285R7N1Z', 'THT1011837405Z', 'THT020285YHN6Z', 'THT670383DJ27Z', 'THT83K8X7', 'THT012182HW21Z', 'THT01397Z0AA2Z', 'THT27087ZS6V2Z', 'THT180682KH04Z', 'THT011683KYN3Z', 'THT040185GPA0Z', 'THT01288597T6Z', 'THT014785QW71Z', 'THT160285MMA8Z', 'THT020282H9U4Z', 'THT013384SYA0Z', 'THT160384EPN8Z', 'THT010585T276Z', 'THT6501843MD6Z', 'THT160183Y3V7Z', 'THT011682FWS9Z', 'THT011685VHE3Z', 'THT45018536H5Z', 'THT015084EFB7Z', 'THT014785E3P2Z', 'THT5502857372Z', 'THT051380S7E2Z', 'THT100383GWP6Z', 'THT150682QQW5Z', 'THT210580Z9K8Z', 'THT1501851QU2Z', 'THT0122853U15Z', 'THT650182FAC9Z', 'THT013985TXP3Z', 'THT150685SBZ2Z', 'THT011680CG92Z', 'THT0402859CQ7Z', 'THT050384R009Z', 'THT020584WJG3Z', 'THT010383QCB6Z', 'THT0203845MT6Z', 'THT282284VZ33Z', 'THT610983Y172Z', 'THT660582EQN4Z', 'THT240382WVU6Z', 'THT010485RPK4Z', 'THT681783C933Z', 'THT150182P757Z', 'THT340284DZ05Z', 'THT0102841499Z', 'THT120682MHJ5Z', 'THT013983C1P7Z', 'THT020184EPA6Z', 'THT014783MS65Z', 'THT400484CC21Z', 'THT015180DYE8Z', 'THT030682X131Z', 'THT010383KHB2Z', 'THT0202817KG6Z', 'THT0201857V76Z', 'THT2409848B20Z', 'THT013984FDD3Z', 'THT011682AZT6Z', 'THT0402845TS1Z', 'THT400482USH9Z', 'THT010183R715Z', 'THT6804841ZW9Z', 'THT02037Z31J1Z', 'THT0134848HV7Z', 'THT2701855MX7Z', 'THT03027SG5E2Z', 'THT051184W5Z5Z', 'THT013983C231Z', 'THT0136847BU2Z', 'THT040685KBY3Z', 'THT03017ZGKY1Z', 'THT241182HB18Z', 'THT2404837SE3Z', 'THT4002838M22Z', 'THT6901842CN2Z', 'THT030281ZS17Z', 'THT040784D163Z', 'THT040182Z5E4Z', 'THT470182F1V3Z', 'THT01187Y3WH8Z', 'THT010680HBM8Z', 'THT24037ZYT75Z', 'THT56017Y7GB7Z', 'THT011582MTT9Z', 'THT020684Y6K3Z', 'THT011884BBD0Z', 'THT7410839Y27Z', 'THT01397ZWQR3Z', 'THT350181VUP0Z', 'THT0504848GC8Z', 'THT240183AH05Z', 'THT210483CF14Z', 'THT040282BHV4Z', 'THT3704814Y26Z', 'THT3302834M79Z', 'THT20078339T6Z', 'THT01037Q7WB9Z', 'THT051183VMT8Z', 'THT014381JKU4Z', 'THT6703839TE8Z', 'THT01148255G2Z', 'THT051380S7E2Z', 'THT20047RKU87Z', 'THT0116813T86Z', 'THT641582ZKA0Z', 'THT014783KC06Z', 'THT010183SN12Z', 'THT01487ZF9Q2Z', 'THT690182NU31Z', 'THT310184AMD9Z', 'THT1405834JK7Z', 'THT1405834JK7Z', 'THT013983HY32Z', 'THT04027X14Q9Z', 'THT01398319S5Z', 'THT012681W0U2Z', 'THT040381CEX5Z', 'THT013981YV98Z', 'THT020383CNB4Z', 'TH05063W091D2P', 'TH05063VYXCT8P', 'THT02037SH234Z', 'THT014282ZYP7Z', 'THT01397QMRU6Z', 'THT014282Q4V5Z', 'THT014480AHK2Z', 'THT250283BVC9Z', 'THT01288111B4Z', 'THT01028304A5Z', 'THT014080R8J7Z', 'THT0131814RK4Z', 'THT02017ZNA27Z', 'THT310180XT32Z', 'THT730582TR49Z', 'THT04068263G1Z', 'THT0105823AA9Z', 'THT0406827BC4Z', 'THT013983A431Z', 'THT0122813NF5Z', 'THT19077Z9ZY3Z', 'THT014980WDF5Z', 'THT01168018Y8Z', 'THT3909815041Z', 'THT2606839UT2Z', 'THT23037Q08M5Z', 'THT01438182B7Z', 'THT015180NB09Z', 'THT014381JKU4Z', 'THT0204823UB2Z', 'THT0139809980Z', 'THT01167YEN48Z', 'THT050682BUM7Z', 'THT2411802574Z', 'THT140780T493Z', 'THT030682KU86Z', 'THT0122821MA8Z', 'THT0103815073Z', 'THT013982USW4Z', 'THT700180V5P1Z', 'THT67037QB9S9Z', 'THT20047YS0V6Z', 'THT011982Y553Z', 'THT272081WH76Z', 'THT020682V5Q2Z', 'THT0139825E58Z', 'THT040582TRK1Z', 'THT0301804KZ5Z', 'THT68107VMYX0Z', 'THT030680TBA1Z', 'THT610481V8K9Z', 'THT10117XKGJ5Z', 'THT38017WHSR2Z', 'THT0139809980Z', 'THT76058157T7Z', 'THT68047SYAJ7Z', 'THT68047SYAJ9Z', 'THT20047YPNP2Z', 'THT55018159E8Z', 'THT02018142F7Z', 'THT38048012D1Z', 'THT37018030M2Z', 'THT0203814255Z', 'THT0306818E63Z', 'THT390180BCV9Z', 'THT01217X2B55Z', 'THT01348026X1Z', 'THT020281HTF2Z', 'THT01397Y4VV7Z', 'THT150381H9Z7Z', 'THT0122812A87Z', 'THT03068025T8Z', 'THT47157Y3B59Z', 'THT680180H5S2Z', 'THT61018145M4Z', 'THT290181Y253Z', 'THT0139809G28Z', 'THT04017ZG2B5Z', 'THT01017WQB75Z', 'THT0103821S67Z', 'THT140180TA61Z', 'THT040681H8V6Z', 'THT1601809FN8Z', 'THT271180Z0V7Z', 'THT47147YDH90Z', 'THT01177UW902Z', 'THT01517YX7M5Z', 'THT01397Y2K75Z', 'THT03067ZZJK1Z', 'THT020380WG88Z', 'THT013980T927Z', 'THT04027XRX95Z', 'THT700180NFC4Z', 'THT700180R115Z', 'THT0106818D15Z', 'THT49017Y7GU7Z', 'THT3811801XR9Z', 'THT0101801VK7Z', 'THT02017ZSHT4Z', 'THT03048226J0Z', 'THT03017YQUC8Z', 'THT20017ZM963Z', 'THT010180G9X2Z', 'THT25067VPRR2Z', 'THT015180RVY5Z', 'THT650181ND51Z', 'THT0116811PD5Z', 'TH05063W091D2P', 'TH05063VYXCT8P', 'THT63017ZSN52Z', 'THT56027XXEN0Z', 'THT670280UBD1Z', 'THT610180MBU6Z', 'THT015080A7E0Z', 'THT020181B9W3Z', 'THT180181CEV5Z', 'THT27267YEEP1Z', 'THT59067ZYV34Z', 'THT40047Z32U4Z', 'THT38107ZBMQ7Z', 'THT01087ZUND0Z', 'THT05067XDBA0Z', 'THT0139804W26Z', 'THT013981MGA5Z', 'THT01227ZN739Z', 'THT050480U4T6Z', 'THT0117817S62Z', 'THT150180T7D8Z', 'THT01037ZKA34Z', 'THT210580BJ29Z', 'THT210580BJ15Z', 'THT0111803SQ0Z', 'THT61017Z03D8Z', 'TH64093V5RN66I', 'THT02057YF9Q5Z', 'THT02047RNVD6Z', 'THT01207YXN38Z', 'THT0402800315Z', 'THT01207XZVF5Z', 'THT39097ZJ947Z', 'THT59067XXDK3Z', 'THT18047XQ617Z', 'THT01507Z8M19Z', 'THT015080NNA8Z', 'THT015080CV71Z', 'THT67037YUH25Z', 'THT36017YHS31Z', 'THT010380F5V8Z', 'THT20017ZYSM3Z', 'THT18027YKHV1Z', 'THT1601803EA6Z', 'THT67037YRU43Z', 'THT01177XB0R3Z', 'THT26017XZAQ5Z', 'THT02047YH0X3Z', 'THT11017VV3R5Z', 'THT2101801YG7Z', 'THT36057UPBZ8Z', 'THT19077Y2JG9Z', 'THT71117X5XJ4Z', 'THT01437S4CA0Z', 'THT04037UGXX2Z', 'THT21067W2211Z', 'THT56077YT126Z', 'THT01417YXKN8Z', 'THT67027WD1B4Z', 'THT01037ZDE29Z', 'THT02017XD7T8Z', 'THT01037ZAZU0Z', 'THT19077YXP83Z', 'THT21027Y5VS8Z', 'THT27017WNWX5Z', 'THT01177YQEV8Z', 'THT65017Y6NV5Z', 'THT01017TW2A0Z', 'THT01087W83T7Z', 'THT47097W0K24Z', 'THT18027YU0C1Z', 'THT01237W0QC2Z', 'THT56067YGWN1Z', 'THT01397ZDV40Z', 'THT05037Y10E3Z', 'THT02047Z03S3Z', 'THT44127YYAP2Z', 'THT01177XQHK7Z', 'THT01437ZNF80Z', 'THT01437ZQUT3Z', 'THT01397YA3Y1Z', 'THT01437X3JU9Z', 'THT27012JK5G3Z', 'THT05097XNYU8Z', 'THT04037U26G8Z', 'THT100828VYJ4Z', 'THT03047XN0N7Z', 'THT33017WDFZ1Z', 'THT26067X7K97Z', 'THT67037XG8C2Z', 'THT10037WV0K1Z', 'THT25027XSTB9Z', 'THT01317YDTJ4Z', 'THT01017X7NG9Z', 'THT01017X7NG9Z', 'THT16027X63E0Z', 'THT02017Z1684Z', 'THT02017Y75Q5Z', 'THT02017XQKQ8Z', 'THT03037UZFB8Z', 'THT11017VX982Z', 'THT11017VX994Z', 'THT02037XDR55Z', 'THT01347X6JT5Z', 'THT04037WMTS2Z', 'THT13067WSTU6Z', 'THT70037T77S8Z', 'THT02027TY5Z9Z', 'THT02057WZ0X3Z', 'THT01347X7K85Z', 'THT01017X2UW9Z', 'THT04037NWU00Z', 'THT29017W43R0Z', 'THT38067X9C26Z', 'THT15067XMHT5Z', 'THT27217WB6W8Z', 'THT16017VA136Z', 'THT67037VJU27Z', 'THT01017Y1AN2Z', 'THT02017W8231Z', 'THT04067X4RU9Z', 'THT01017X8M98Z', 'THT01397Y6VG6Z', 'TH21013SU6038C', 'TH21013SU63K6C', 'TH21013SAW9R9C', 'TH21013S6WH05C', 'THT04077WK1Z3Z', 'THT05067VRV08Z', 'THT04027WPDH9Z', 'THT39017W3315Z', 'THT01017WBAS4Z', 'THT25027W4J99Z', 'THT26067W0XB2Z', 'THT01307WA5B0Z', 'THT02017U4CW7Z', 'THT01367UGGV9Z', 'THT03027SG5E2Z', 'THT67037SXH72Z', 'THT01347USAZ7Z', 'THT01347USAZ9Z', 'THT01422KEZ71Z', 'THT02037WPGN4Z', 'THT71117VWRS4Z', 'THT71147UY7V6Z', 'THT04067Q56M4Z', 'THT01047VF5N3Z', 'THT11017WWBE3Z', 'THT20047TVP13Z', 'THT03017WGDR1Z', 'THT10037R7MB3Z', 'THT01417X4H63Z', 'THT15037WG4B6Z', 'THT01017TPAG4Z', 'THT07011XTNS5Z', 'THT01437US346Z', 'THT67017W3UT1Z', 'THT10037UZU09Z', 'THT01177UTWX7Z', 'THT02017U1T64Z', 'THT02047W1AN1Z', 'THT01397VACK6Z', 'THT03017QRFX6Z', 'THT67037VSKW3Z', 'THT01437TY2X8Z', 'THT26057XDF12Z', 'THT05147V8TZ4Z', 'THT20047TEE15Z', 'THT02037UW268Z', 'THT68087VUP40Z', 'THT040329R0A0Z', 'THT03017T0P75Z', 'THT20047T8R16Z', 'THT20047U8CB6Z', 'THT20017V3G94Z', 'THT20087VSJ84Z', 'THT02027STK16Z', 'TH16023URP7W7B', 'THT03022E1CC0Z', 'THT01397QST49Z', 'THT63077S3VY7Z', 'THT21067TCVT8Z', 'THT25067WH9Z9Z', 'THT03037U0YS5Z', 'THT01387VMT62Z', 'THT04077UR1T9Z', 'THT01397VHXD6Z', 'THT05047RJ631Z', 'THT20047REKS5Z', 'THT01127QQ8G9Z', 'THT01197V4EN7Z', 'THT20047T85J9Z', 'THT05047TAMY0Z', 'THT02017RU1N4Z', 'THT63017UEYN7Z', 'THT20077RSZ02Z', 'THT20017ST081Z', 'THT01167SCWK4Z', 'THT01137TYHD9Z', 'THT03017T0763Z', 'THT20047TEE37Z', 'THT01177UQKT6Z', 'THT68047SYAJ7Z', 'THT68047SYAJ9Z', 'THT01117V98Z5Z', 'THT20047UUTD6Z', 'THT20047TCPG9Z', 'THT13037WR4Q3Z', 'THT20087UNQ76Z', 'THT01397U0UA5Z', 'THT37047R0EE2Z', 'THT20067S91N7Z', 'THT01237SYG64Z', 'THT29017QPBX8Z', 'THT20047VKRY5Z', 'THT10017UUQV7Z', 'THT20047SE5D8Z', 'THT01517R3R43Z', 'THT01317UK648Z', 'THT01437V5KX3Z', 'THT25027TG7J5Z', 'THT01397PWM01Z', 'THT01037VRY87Z', 'THT01212JPQN7Z', 'THT04077T6DG9Z', 'THT01347V3JF7Z', 'THT02027UHEQ2Z', 'THT13067R2GW9Z', 'THT20087URUS6Z', 'THT01017UA1F2Z', 'THT21057TM9X2Z', 'THT24047V2KE3Z', 'THT02017WVFM2Z', 'THT20097SUVV3Z', 'THT01167UU0N4Z', 'THT69057TNRG4Z', 'TH30113VB6E34A', 'THT04017UU9R8Z', 'THT01047TXPA8Z', 'THT01477UJP17Z', 'THT04027PSZN6Z', 'THT65087TB808Z', 'THT14097VUQX5Z', 'THT01397UFZ10Z', 'THT02017SAAK7Z', 'THT05067U5U00Z', 'THT03027V5XU3Z', 'THT01417T6QJ3Z', 'THT01287RV659Z', 'THT33057UXMN3Z', 'THT38117QU6V9Z', 'THT40027T6U35Z', 'THT02017SUQ77Z', 'THT01037UDA73Z', 'THT02037RV653Z', 'THT02027U43P0Z', 'THT01447T1XG7Z', 'THT07102JX6A1Z', 'THT39137RXFS7Z', 'THT01397T9KH3Z', 'THT05047UBMM8Z', 'THT37017UHCV0Z', 'THT01397UF9W4Z', 'THT01037SQ4Z6Z', 'THT01397T2967Z', 'THT04077UGX11Z', 'THT01087TEXM9Z', 'THT01087TC3D2Z', 'THT67027NRUV9Z', 'THT01337U5XB4Z', 'THT76027RTY83Z', 'THT55017T8F30Z', 'THT01057SAG29Z', 'THT01392DBYQ3Z', 'THT20077TU9T2Z', 'THT47147TU9B4Z', 'THT01187SQG19Z', 'THT24017PFXT7Z', 'THT21027U5JR1Z', 'THT01337U5XC0Z', 'THT21017SQBD3Z', 'THT20027NW554Z', 'THT20087TRXH4Z', 'THT70037SYV09Z', 'THT01477RKKU9Z', 'THT02027Q25S4Z', 'THT16037SVQ01Z', 'THT28017RWMA8Z', 'THT01477RV5W0Z', 'THT02037SH234Z', 'THT20027NKQ80Z', 'THT62097U1MH1Z', 'THT01162FE549Z', 'THT02017T88X1Z', 'THT20017RSF72Z', 'THT20047R3139Z', 'THT20077PMYP7Z', 'THT01427RW1Z0Z', 'THT01397QTSA3Z', 'THT01397SWCY3Z', 'THT02017SJ9B1Z', 'THT01227SPW66Z', 'THT03047TB3G3Z', 'THT70017QPUF7Z', 'THT24037T0YW5Z', 'THT65017RYN18Z', 'THT04027QZ222Z', 'THT55017QVUQ6Z', 'THT01347SGBV4Z', 'THT01397RB5C7Z', 'THT02017RFQV8Z', 'THT01472HVTJ6Z', 'THT01162JS7E9Z', 'THT01267SRBU9Z', 'THT01167RXWX3Z', 'THT01397NPN58Z', 'THT01427SNXP7Z', 'THT02017SWKA8Z', 'THT01277R21Y0Z', 'THT01017RU300Z', 'THT02017SU636Z', 'THT02012C3H32Z', 'THT02017R6232Z', 'THT01447SMSZ6Z', 'THT02047PK6H8Z', 'THT03017T2EE7Z', 'THT01337R7EJ0Z', 'THT37057Q2E24Z', 'THT02037SN6Z3Z', 'THT02027RE810Z', 'THT26017S4CK3Z', 'THT67032JAKX3Z', 'THT25027NZ120Z', 'THT01407S43T3Z', 'THT02047R3VV3Z', 'THT56017P4BX4Z', 'THT01397PYSX0Z', 'THT01057RCKW8Z', 'THT01377QJ7J9Z', 'THT20047R3139Z', 'THT02047QC8U1Z', 'THT29017QBMX9Z', 'THT01077QDKD5Z', 'THT47017SHYW2Z', 'THT47152KD0N3Z', 'THT01397R8JH5Z', 'THT63032JJCE1Z', 'THT15067S9GE8Z', 'THT67017S6023Z', 'THT01437QCXH1Z', 'THT01127R8WT0Z', 'THT01057PK8B0Z', 'THT70047QM184Z', 'THT10037QJN81Z', 'THT10037NU2B5Z', 'THT01397QEJA2Z', 'THT01397QHHM3Z', 'THT04047PTVD3Z', 'THT21017PFJ36Z', 'THT03017QQQN7Z', 'THT01437PQ776Z', 'THT28052JHR59Z', 'THT20057Q6UT5Z', 'THT54017QTU00Z', 'THT02027P1F67Z', 'THT76042KFDA3Z', 'THT04037NWU00Z', 'THT02037NXCA7Z', 'THT27017PAK06Z', 'THT18022H6MQ2Z', 'THT15067QWPQ3Z', 'THT01467PV3V0Z', 'THT15067R8MN3Z', 'THT01272DKW89Z', 'THT01127QM433Z', 'THT66087PSS02Z', 'THT65012JXBN9Z', 'THT01127R5DF1Z', 'THT03017QQQN7Z');
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
    ,pi.returned
from fle_staging.parcel_info pi
where
    pi.state = 5
    and pi.pno in ('THT200288BJ44Z', 'THT011889P7W1Z', 'THT08018AP9N6Z', 'THT01478BKPM6Z', 'THT12048AR8M6Z', 'THT04068B2XK9Z', 'THT04038ADZA4Z', 'THT471489CCW9Z', 'THT01018BHJR1Z', 'THT67028A0M37Z', 'THT30228AP4F0Z', 'THT10028D09C3Z', 'THT24038CYK40Z', 'THT380289QMR9Z', 'THT10038A9J99Z', 'THT21068C0B07Z', 'THT21068B1W23Z', 'THT31138967P7Z', 'THT19078A4UM3Z', 'THT04068AQTF9Z', 'THT03018AYVK2Z', 'THT01238CZX55Z', 'THT01178B6W16Z', 'THT01178B9WB7Z', 'THT01188ASP94Z', 'THT050689ZAY3Z', 'THT01218BMVE4Z', 'THT37018AMX53Z', 'THT040287D526Z', 'THT01268CPRY4Z', 'THT01038D3450Z', 'THT04028C6GT6Z', 'THT01188BKM48Z', 'THT04048BJM47Z', 'THT01178AYSM7Z', 'THT56127X9U11Z', 'THT03048C2F29Z', 'THT10108APCS8Z', 'THT02028BZRS5Z', 'THT61088ANS09Z', 'THT01058BQRP5Z', 'THT01188A81A1Z', 'THT14078AKYB5Z', 'THT272188P2X2Z', 'THT26058BN5Z3Z', 'THT0151860E02Z', 'THT01098ANHN3Z', 'THT37018BYJR8Z', 'THT24038BSJW1Z', 'THT21058CP7X9Z', 'THT240186SB89Z', 'THT0143895BU8Z', 'THT01398B8JK6Z', 'THT012789G282Z', 'THT012789KD63Z', 'THT012789KF13Z', 'THT3110886EY2Z', 'THT2604883Z53Z', 'THT15068A1QE8Z', 'THT0141890RQ1Z', 'THT20048A3QN0Z', 'THT320588APV6Z', 'THT0143891MP8Z', 'THT01138C7657Z', 'THT01038AX3D7Z', 'THT01068AZ5F4Z', 'THT01168AADM0Z', 'THT37178A3H77Z', 'THT02038C21K7Z', 'THT03018BT8B1Z', 'THT640286G729Z', 'THT640286G727Z', 'THT16038BFAU0Z', 'THT01438APXH8Z', 'THT150689MW63Z', 'THT20048BXBP4Z', 'THT0103886NR2Z', 'THT050389J3Q0Z', 'THT04048BN5Y9Z', 'THT013987NZ66Z', 'THT390989ZH26Z', 'THT01088AH0X2Z', 'THT160187JDV9Z', 'THT160187JDS9Z', 'THT014389WVC0Z', 'THT60017NNVX4Z', 'THT200488P641Z', 'THT1011893E69Z', 'THT02058A5E45Z', 'THT4401885RE4Z', 'THT14078AC5B6Z', 'THT16018AH797Z', 'THT100289Z333Z', 'THT01438A5267Z', 'THT01288AP1H2Z', 'THT070189GNQ4Z', 'THT01218839G7Z', 'THT040284MQU7Z', 'THT05118834Q7Z', 'THT04028AFEW5Z', 'THT01438A5HQ1Z', 'THT24058B0BG6Z', 'THT020389H6H8Z', 'THT200486WW90Z', 'THT02018929Y3Z', 'THT014282P7K5Z', 'THT0206889BE0Z', 'THT04028348C6Z', 'THT01088B6GV4Z', 'THT600788KRG8Z', 'THT0201871AA4Z', 'THT01398833X3Z', 'THT0130882MC4Z', 'THT301889V8Z0Z', 'THT53018536W5Z', 'THT05118A2VZ6Z', 'THT200584QBW3Z', 'THT050386RRH9Z', 'THT190787NZK0Z', 'THT72058901A6Z', 'THT200889EN35Z', 'THT01168A8452Z', 'THT014388QSV9Z', 'THT200184AD69Z', 'THT050682SW38Z', 'THT3304888MP7Z', 'THT20048A1556Z', 'THT011689H8J3Z', 'THT010989EB65Z', 'THT67037SCQG4Z', 'THT030187WW06Z', 'THT3706887E37Z', 'THT020286X0U4Z', 'THT020288Y928Z', 'THT0206871VX8Z', 'THT051189Z0Y7Z', 'THT200889BG00Z', 'THT030287MHS2Z', 'THT120488VCM2Z', 'THT013988QV36Z', 'THT040588MRZ5Z', 'THT471584CDW0Z', 'THT012686SZC1Z', 'THT370984E380Z', 'THT0121887GR9Z', 'THT260688FV02Z', 'THT020488BWZ3Z', 'THT260688FV00Z', 'THT271888NCU9Z', 'THT700486RN37Z', 'THT0110880J85Z', 'THT02018757T6Z', 'THT240185DWG4Z', 'THT040688TCS8Z', 'THT390185YSX3Z', 'THT210687MPM8Z', 'THT240485JXE4Z', 'THT6703873JQ7Z', 'THT520185FCJ8Z', 'THT02068271Q1Z', 'THT0123897MH3Z', 'THT160287GJ24Z', 'THT6101882BD7Z', 'THT2007838KF2Z', 'THT020288VUY1Z', 'THT310484A825Z', 'THT011680CGJ5Z', 'THT014084QXD9Z', 'THT012886G7Y0Z', 'THT01308723F2Z', 'THT160287GGT8Z', 'THT030187Y5M3Z', 'THT070387Q2G7Z', 'THT290688ANZ6Z', 'THT210687ZZ19Z', 'THT01058529R9Z', 'THT100187T9S3Z', 'THT010188NZY7Z', 'THT270188FFT7Z', 'THT16038699N6Z', 'THT013987YE98Z', 'THT020486WHJ6Z', 'THT0203845MT6Z', 'THT290386S0N4Z', 'THT450182MVV5Z', 'THT01018625A7Z', 'THT013986X202Z', 'THT01162FE549Z', 'THT0105861E53Z', 'THT70018515N0Z', 'THT70018515P0Z', 'THT520585GFY4Z', 'THT751083E6E0Z', 'THT311487F4S7Z', 'THT013986X200Z', 'THT011882SR73Z', 'THT1804818HF5Z', 'THT670383RAV5Z', 'THT200481R478Z', 'THT450185YAF0Z', 'THT200783YXV4Z', 'THT200783YXV4Z', 'THT030484PZY2Z', 'THT01068711N2Z', 'THT012185K5K0Z', 'THT0401873M61Z', 'THT0203857PC7Z', 'THT1104864B52Z', 'THT0139875CM9Z', 'THT1003867YA0Z', 'THT6703839PN1Z', 'THT013986Y848Z', 'THT470185BX35Z', 'THT2004849TM9Z', 'THT013684EQG8Z', 'THT0114875F68Z', 'THT71108473R1Z', 'THT01057Y2T94Z', 'THT180484ANW2Z', 'THT015185SAD2Z', 'THT013480UUS9Z', 'THT013985A969Z', 'THT300784QXN7Z', 'THT711184MU00Z', 'THT012285UGV9Z', 'THT20048230H0Z', 'THT302285DZG7Z', 'THT050785T8D0Z', 'THT2004861F84Z', 'THT66088559X7Z', 'THT270285ME43Z', 'THT200485P688Z', 'THT4719854HZ1Z', 'THT670285BJW6Z', 'THT01037ZKA34Z', 'THT0516855D14Z', 'THT580685UPR0Z', 'THT200485XK28Z', 'THT200586YT85Z', 'THT01428558S4Z', 'THT4509815GE2Z', 'THT020284KKR9Z', 'THT0406868012Z', 'THT0201856UR4Z', 'THT0104872421Z', 'THT020385YVZ5Z', 'THT1001862E01Z', 'THT0201861MR4Z', 'THT013183BSQ8Z', 'THT20047XSNS6Z', 'THT150685SC05Z', 'THT7111851AA2Z', 'THT020285R7N1Z', 'THT1011837405Z', 'THT020285YHN6Z', 'THT670383DJ27Z', 'THT83K8X7', 'THT012182HW21Z', 'THT01397Z0AA2Z', 'THT27087ZS6V2Z', 'THT180682KH04Z', 'THT011683KYN3Z', 'THT040185GPA0Z', 'THT01288597T6Z', 'THT014785QW71Z', 'THT160285MMA8Z', 'THT020282H9U4Z', 'THT013384SYA0Z', 'THT160384EPN8Z', 'THT010585T276Z', 'THT6501843MD6Z', 'THT160183Y3V7Z', 'THT011682FWS9Z', 'THT011685VHE3Z', 'THT45018536H5Z', 'THT015084EFB7Z', 'THT014785E3P2Z', 'THT5502857372Z', 'THT051380S7E2Z', 'THT100383GWP6Z', 'THT150682QQW5Z', 'THT210580Z9K8Z', 'THT1501851QU2Z', 'THT0122853U15Z', 'THT650182FAC9Z', 'THT013985TXP3Z', 'THT150685SBZ2Z', 'THT011680CG92Z', 'THT0402859CQ7Z', 'THT050384R009Z', 'THT020584WJG3Z', 'THT010383QCB6Z', 'THT0203845MT6Z', 'THT282284VZ33Z', 'THT610983Y172Z', 'THT660582EQN4Z', 'THT240382WVU6Z', 'THT010485RPK4Z', 'THT681783C933Z', 'THT150182P757Z', 'THT340284DZ05Z', 'THT0102841499Z', 'THT120682MHJ5Z', 'THT013983C1P7Z', 'THT020184EPA6Z', 'THT014783MS65Z', 'THT400484CC21Z', 'THT015180DYE8Z', 'THT030682X131Z', 'THT010383KHB2Z', 'THT0202817KG6Z', 'THT0201857V76Z', 'THT2409848B20Z', 'THT013984FDD3Z', 'THT011682AZT6Z', 'THT0402845TS1Z', 'THT400482USH9Z', 'THT010183R715Z', 'THT6804841ZW9Z', 'THT02037Z31J1Z', 'THT0134848HV7Z', 'THT2701855MX7Z', 'THT03027SG5E2Z', 'THT051184W5Z5Z', 'THT013983C231Z', 'THT0136847BU2Z', 'THT040685KBY3Z', 'THT03017ZGKY1Z', 'THT241182HB18Z', 'THT2404837SE3Z', 'THT4002838M22Z', 'THT6901842CN2Z', 'THT030281ZS17Z', 'THT040784D163Z', 'THT040182Z5E4Z', 'THT470182F1V3Z', 'THT01187Y3WH8Z', 'THT010680HBM8Z', 'THT24037ZYT75Z', 'THT56017Y7GB7Z', 'THT011582MTT9Z', 'THT020684Y6K3Z', 'THT011884BBD0Z', 'THT7410839Y27Z', 'THT01397ZWQR3Z', 'THT350181VUP0Z', 'THT0504848GC8Z', 'THT240183AH05Z', 'THT210483CF14Z', 'THT040282BHV4Z', 'THT3704814Y26Z', 'THT3302834M79Z', 'THT20078339T6Z', 'THT01037Q7WB9Z', 'THT051183VMT8Z', 'THT014381JKU4Z', 'THT6703839TE8Z', 'THT01148255G2Z', 'THT051380S7E2Z', 'THT20047RKU87Z', 'THT0116813T86Z', 'THT641582ZKA0Z', 'THT014783KC06Z', 'THT010183SN12Z', 'THT01487ZF9Q2Z', 'THT690182NU31Z', 'THT310184AMD9Z', 'THT1405834JK7Z', 'THT1405834JK7Z', 'THT013983HY32Z', 'THT04027X14Q9Z', 'THT01398319S5Z', 'THT012681W0U2Z', 'THT040381CEX5Z', 'THT013981YV98Z', 'THT020383CNB4Z', 'TH05063W091D2P', 'TH05063VYXCT8P', 'THT02037SH234Z', 'THT014282ZYP7Z', 'THT01397QMRU6Z', 'THT014282Q4V5Z', 'THT014480AHK2Z', 'THT250283BVC9Z', 'THT01288111B4Z', 'THT01028304A5Z', 'THT014080R8J7Z', 'THT0131814RK4Z', 'THT02017ZNA27Z', 'THT310180XT32Z', 'THT730582TR49Z', 'THT04068263G1Z', 'THT0105823AA9Z', 'THT0406827BC4Z', 'THT013983A431Z', 'THT0122813NF5Z', 'THT19077Z9ZY3Z', 'THT014980WDF5Z', 'THT01168018Y8Z', 'THT3909815041Z', 'THT2606839UT2Z', 'THT23037Q08M5Z', 'THT01438182B7Z', 'THT015180NB09Z', 'THT014381JKU4Z', 'THT0204823UB2Z', 'THT0139809980Z', 'THT01167YEN48Z', 'THT050682BUM7Z', 'THT2411802574Z', 'THT140780T493Z', 'THT030682KU86Z', 'THT0122821MA8Z', 'THT0103815073Z', 'THT013982USW4Z', 'THT700180V5P1Z', 'THT67037QB9S9Z', 'THT20047YS0V6Z', 'THT011982Y553Z', 'THT272081WH76Z', 'THT020682V5Q2Z', 'THT0139825E58Z', 'THT040582TRK1Z', 'THT0301804KZ5Z', 'THT68107VMYX0Z', 'THT030680TBA1Z', 'THT610481V8K9Z', 'THT10117XKGJ5Z', 'THT38017WHSR2Z', 'THT0139809980Z', 'THT76058157T7Z', 'THT68047SYAJ7Z', 'THT68047SYAJ9Z', 'THT20047YPNP2Z', 'THT55018159E8Z', 'THT02018142F7Z', 'THT38048012D1Z', 'THT37018030M2Z', 'THT0203814255Z', 'THT0306818E63Z', 'THT390180BCV9Z', 'THT01217X2B55Z', 'THT01348026X1Z', 'THT020281HTF2Z', 'THT01397Y4VV7Z', 'THT150381H9Z7Z', 'THT0122812A87Z', 'THT03068025T8Z', 'THT47157Y3B59Z', 'THT680180H5S2Z', 'THT61018145M4Z', 'THT290181Y253Z', 'THT0139809G28Z', 'THT04017ZG2B5Z', 'THT01017WQB75Z', 'THT0103821S67Z', 'THT140180TA61Z', 'THT040681H8V6Z', 'THT1601809FN8Z', 'THT271180Z0V7Z', 'THT47147YDH90Z', 'THT01177UW902Z', 'THT01517YX7M5Z', 'THT01397Y2K75Z', 'THT03067ZZJK1Z', 'THT020380WG88Z', 'THT013980T927Z', 'THT04027XRX95Z', 'THT700180NFC4Z', 'THT700180R115Z', 'THT0106818D15Z', 'THT49017Y7GU7Z', 'THT3811801XR9Z', 'THT0101801VK7Z', 'THT02017ZSHT4Z', 'THT03048226J0Z', 'THT03017YQUC8Z', 'THT20017ZM963Z', 'THT010180G9X2Z', 'THT25067VPRR2Z', 'THT015180RVY5Z', 'THT650181ND51Z', 'THT0116811PD5Z', 'TH05063W091D2P', 'TH05063VYXCT8P', 'THT63017ZSN52Z', 'THT56027XXEN0Z', 'THT670280UBD1Z', 'THT610180MBU6Z', 'THT015080A7E0Z', 'THT020181B9W3Z', 'THT180181CEV5Z', 'THT27267YEEP1Z', 'THT59067ZYV34Z', 'THT40047Z32U4Z', 'THT38107ZBMQ7Z', 'THT01087ZUND0Z', 'THT05067XDBA0Z', 'THT0139804W26Z', 'THT013981MGA5Z', 'THT01227ZN739Z', 'THT050480U4T6Z', 'THT0117817S62Z', 'THT150180T7D8Z', 'THT01037ZKA34Z', 'THT210580BJ29Z', 'THT210580BJ15Z', 'THT0111803SQ0Z', 'THT61017Z03D8Z', 'TH64093V5RN66I', 'THT02057YF9Q5Z', 'THT02047RNVD6Z', 'THT01207YXN38Z', 'THT0402800315Z', 'THT01207XZVF5Z', 'THT39097ZJ947Z', 'THT59067XXDK3Z', 'THT18047XQ617Z', 'THT01507Z8M19Z', 'THT015080NNA8Z', 'THT015080CV71Z', 'THT67037YUH25Z', 'THT36017YHS31Z', 'THT010380F5V8Z', 'THT20017ZYSM3Z', 'THT18027YKHV1Z', 'THT1601803EA6Z', 'THT67037YRU43Z', 'THT01177XB0R3Z', 'THT26017XZAQ5Z', 'THT02047YH0X3Z', 'THT11017VV3R5Z', 'THT2101801YG7Z', 'THT36057UPBZ8Z', 'THT19077Y2JG9Z', 'THT71117X5XJ4Z', 'THT01437S4CA0Z', 'THT04037UGXX2Z', 'THT21067W2211Z', 'THT56077YT126Z', 'THT01417YXKN8Z', 'THT67027WD1B4Z', 'THT01037ZDE29Z', 'THT02017XD7T8Z', 'THT01037ZAZU0Z', 'THT19077YXP83Z', 'THT21027Y5VS8Z', 'THT27017WNWX5Z', 'THT01177YQEV8Z', 'THT65017Y6NV5Z', 'THT01017TW2A0Z', 'THT01087W83T7Z', 'THT47097W0K24Z', 'THT18027YU0C1Z', 'THT01237W0QC2Z', 'THT56067YGWN1Z', 'THT01397ZDV40Z', 'THT05037Y10E3Z', 'THT02047Z03S3Z', 'THT44127YYAP2Z', 'THT01177XQHK7Z', 'THT01437ZNF80Z', 'THT01437ZQUT3Z', 'THT01397YA3Y1Z', 'THT01437X3JU9Z', 'THT27012JK5G3Z', 'THT05097XNYU8Z', 'THT04037U26G8Z', 'THT100828VYJ4Z', 'THT03047XN0N7Z', 'THT33017WDFZ1Z', 'THT26067X7K97Z', 'THT67037XG8C2Z', 'THT10037WV0K1Z', 'THT25027XSTB9Z', 'THT01317YDTJ4Z', 'THT01017X7NG9Z', 'THT01017X7NG9Z', 'THT16027X63E0Z', 'THT02017Z1684Z', 'THT02017Y75Q5Z', 'THT02017XQKQ8Z', 'THT03037UZFB8Z', 'THT11017VX982Z', 'THT11017VX994Z', 'THT02037XDR55Z', 'THT01347X6JT5Z', 'THT04037WMTS2Z', 'THT13067WSTU6Z', 'THT70037T77S8Z', 'THT02027TY5Z9Z', 'THT02057WZ0X3Z', 'THT01347X7K85Z', 'THT01017X2UW9Z', 'THT04037NWU00Z', 'THT29017W43R0Z', 'THT38067X9C26Z', 'THT15067XMHT5Z', 'THT27217WB6W8Z', 'THT16017VA136Z', 'THT67037VJU27Z', 'THT01017Y1AN2Z', 'THT02017W8231Z', 'THT04067X4RU9Z', 'THT01017X8M98Z', 'THT01397Y6VG6Z', 'TH21013SU6038C', 'TH21013SU63K6C', 'TH21013SAW9R9C', 'TH21013S6WH05C', 'THT04077WK1Z3Z', 'THT05067VRV08Z', 'THT04027WPDH9Z', 'THT39017W3315Z', 'THT01017WBAS4Z', 'THT25027W4J99Z', 'THT26067W0XB2Z', 'THT01307WA5B0Z', 'THT02017U4CW7Z', 'THT01367UGGV9Z', 'THT03027SG5E2Z', 'THT67037SXH72Z', 'THT01347USAZ7Z', 'THT01347USAZ9Z', 'THT01422KEZ71Z', 'THT02037WPGN4Z', 'THT71117VWRS4Z', 'THT71147UY7V6Z', 'THT04067Q56M4Z', 'THT01047VF5N3Z', 'THT11017WWBE3Z', 'THT20047TVP13Z', 'THT03017WGDR1Z', 'THT10037R7MB3Z', 'THT01417X4H63Z', 'THT15037WG4B6Z', 'THT01017TPAG4Z', 'THT07011XTNS5Z', 'THT01437US346Z', 'THT67017W3UT1Z', 'THT10037UZU09Z', 'THT01177UTWX7Z', 'THT02017U1T64Z', 'THT02047W1AN1Z', 'THT01397VACK6Z', 'THT03017QRFX6Z', 'THT67037VSKW3Z', 'THT01437TY2X8Z', 'THT26057XDF12Z', 'THT05147V8TZ4Z', 'THT20047TEE15Z', 'THT02037UW268Z', 'THT68087VUP40Z', 'THT040329R0A0Z', 'THT03017T0P75Z', 'THT20047T8R16Z', 'THT20047U8CB6Z', 'THT20017V3G94Z', 'THT20087VSJ84Z', 'THT02027STK16Z', 'TH16023URP7W7B', 'THT03022E1CC0Z', 'THT01397QST49Z', 'THT63077S3VY7Z', 'THT21067TCVT8Z', 'THT25067WH9Z9Z', 'THT03037U0YS5Z', 'THT01387VMT62Z', 'THT04077UR1T9Z', 'THT01397VHXD6Z', 'THT05047RJ631Z', 'THT20047REKS5Z', 'THT01127QQ8G9Z', 'THT01197V4EN7Z', 'THT20047T85J9Z', 'THT05047TAMY0Z', 'THT02017RU1N4Z', 'THT63017UEYN7Z', 'THT20077RSZ02Z', 'THT20017ST081Z', 'THT01167SCWK4Z', 'THT01137TYHD9Z', 'THT03017T0763Z', 'THT20047TEE37Z', 'THT01177UQKT6Z', 'THT68047SYAJ7Z', 'THT68047SYAJ9Z', 'THT01117V98Z5Z', 'THT20047UUTD6Z', 'THT20047TCPG9Z', 'THT13037WR4Q3Z', 'THT20087UNQ76Z', 'THT01397U0UA5Z', 'THT37047R0EE2Z', 'THT20067S91N7Z', 'THT01237SYG64Z', 'THT29017QPBX8Z', 'THT20047VKRY5Z', 'THT10017UUQV7Z', 'THT20047SE5D8Z', 'THT01517R3R43Z', 'THT01317UK648Z', 'THT01437V5KX3Z', 'THT25027TG7J5Z', 'THT01397PWM01Z', 'THT01037VRY87Z', 'THT01212JPQN7Z', 'THT04077T6DG9Z', 'THT01347V3JF7Z', 'THT02027UHEQ2Z', 'THT13067R2GW9Z', 'THT20087URUS6Z', 'THT01017UA1F2Z', 'THT21057TM9X2Z', 'THT24047V2KE3Z', 'THT02017WVFM2Z', 'THT20097SUVV3Z', 'THT01167UU0N4Z', 'THT69057TNRG4Z', 'TH30113VB6E34A', 'THT04017UU9R8Z', 'THT01047TXPA8Z', 'THT01477UJP17Z', 'THT04027PSZN6Z', 'THT65087TB808Z', 'THT14097VUQX5Z', 'THT01397UFZ10Z', 'THT02017SAAK7Z', 'THT05067U5U00Z', 'THT03027V5XU3Z', 'THT01417T6QJ3Z', 'THT01287RV659Z', 'THT33057UXMN3Z', 'THT38117QU6V9Z', 'THT40027T6U35Z', 'THT02017SUQ77Z', 'THT01037UDA73Z', 'THT02037RV653Z', 'THT02027U43P0Z', 'THT01447T1XG7Z', 'THT07102JX6A1Z', 'THT39137RXFS7Z', 'THT01397T9KH3Z', 'THT05047UBMM8Z', 'THT37017UHCV0Z', 'THT01397UF9W4Z', 'THT01037SQ4Z6Z', 'THT01397T2967Z', 'THT04077UGX11Z', 'THT01087TEXM9Z', 'THT01087TC3D2Z', 'THT67027NRUV9Z', 'THT01337U5XB4Z', 'THT76027RTY83Z', 'THT55017T8F30Z', 'THT01057SAG29Z', 'THT01392DBYQ3Z', 'THT20077TU9T2Z', 'THT47147TU9B4Z', 'THT01187SQG19Z', 'THT24017PFXT7Z', 'THT21027U5JR1Z', 'THT01337U5XC0Z', 'THT21017SQBD3Z', 'THT20027NW554Z', 'THT20087TRXH4Z', 'THT70037SYV09Z', 'THT01477RKKU9Z', 'THT02027Q25S4Z', 'THT16037SVQ01Z', 'THT28017RWMA8Z', 'THT01477RV5W0Z', 'THT02037SH234Z', 'THT20027NKQ80Z', 'THT62097U1MH1Z', 'THT01162FE549Z', 'THT02017T88X1Z', 'THT20017RSF72Z', 'THT20047R3139Z', 'THT20077PMYP7Z', 'THT01427RW1Z0Z', 'THT01397QTSA3Z', 'THT01397SWCY3Z', 'THT02017SJ9B1Z', 'THT01227SPW66Z', 'THT03047TB3G3Z', 'THT70017QPUF7Z', 'THT24037T0YW5Z', 'THT65017RYN18Z', 'THT04027QZ222Z', 'THT55017QVUQ6Z', 'THT01347SGBV4Z', 'THT01397RB5C7Z', 'THT02017RFQV8Z', 'THT01472HVTJ6Z', 'THT01162JS7E9Z', 'THT01267SRBU9Z', 'THT01167RXWX3Z', 'THT01397NPN58Z', 'THT01427SNXP7Z', 'THT02017SWKA8Z', 'THT01277R21Y0Z', 'THT01017RU300Z', 'THT02017SU636Z', 'THT02012C3H32Z', 'THT02017R6232Z', 'THT01447SMSZ6Z', 'THT02047PK6H8Z', 'THT03017T2EE7Z', 'THT01337R7EJ0Z', 'THT37057Q2E24Z', 'THT02037SN6Z3Z', 'THT02027RE810Z', 'THT26017S4CK3Z', 'THT67032JAKX3Z', 'THT25027NZ120Z', 'THT01407S43T3Z', 'THT02047R3VV3Z', 'THT56017P4BX4Z', 'THT01397PYSX0Z', 'THT01057RCKW8Z', 'THT01377QJ7J9Z', 'THT20047R3139Z', 'THT02047QC8U1Z', 'THT29017QBMX9Z', 'THT01077QDKD5Z', 'THT47017SHYW2Z', 'THT47152KD0N3Z', 'THT01397R8JH5Z', 'THT63032JJCE1Z', 'THT15067S9GE8Z', 'THT67017S6023Z', 'THT01437QCXH1Z', 'THT01127R8WT0Z', 'THT01057PK8B0Z', 'THT70047QM184Z', 'THT10037QJN81Z', 'THT10037NU2B5Z', 'THT01397QEJA2Z', 'THT01397QHHM3Z', 'THT04047PTVD3Z', 'THT21017PFJ36Z', 'THT03017QQQN7Z', 'THT01437PQ776Z', 'THT28052JHR59Z', 'THT20057Q6UT5Z', 'THT54017QTU00Z', 'THT02027P1F67Z', 'THT76042KFDA3Z', 'THT04037NWU00Z', 'THT02037NXCA7Z', 'THT27017PAK06Z', 'THT18022H6MQ2Z', 'THT15067QWPQ3Z', 'THT01467PV3V0Z', 'THT15067R8MN3Z', 'THT01272DKW89Z', 'THT01127QM433Z', 'THT66087PSS02Z', 'THT65012JXBN9Z', 'THT01127R5DF1Z', 'THT03017QQQN7Z');
;-- -. . -..- - / . -. - .-. -.--
select
    min(pi.created_at)
from fle_staging.parcel_info pi
join tmpale.tmp_th_pno_0328 t on t.pno = pi.pno;
;-- -. . -..- - / . -. - .-. -.--
select * from tmpale.tmp_th_pno_0328;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
    ,pi.ticket_delivery_staff_info_id
    ,pi.ticket_delivery_store_id
    ,st_distance_sphere(point(pi.ticket_delivery_staff_lng, pi.ticket_delivery_staff_lat), point(ss.lng, ss.lat)) 妥投距离网点距离
    ,if(pr.pno is null, '否', '是') 是否妥投后盘库
from fle_staging.parcel_info pi
join tmpale.tmp_th_pno_0328 t on t.pno = pi.pno
left join fle_staging.sys_store ss on ss.id = pi.ticket_delivery_store_id
left join
    (
        select
            pr.pno
        from rot_pro.parcel_route pr
        join tmpale.tmp_th_pno_0328 t on t.pno = pr.pno
        left join fle_staging.parcel_info pi on pi.pno = t.pno
        where
            pr.route_action = 'INVENTORY'
            and pr.routed_at > pi.finished_at
        group by 1
    ) pr on pr.pno = t.pno;
;-- -. . -..- - / . -. - .-. -.--
select
    ss.name 网点
    ,date(convert_tz(di.created_at, '+00:00', '+07:00')) 日期
    ,count(distinct di.pno) 包裹数
from fle_staging.store_diff_ticket sdt
left join fle_staging.diff_info di on di.id = sdt.diff_info_id
left join fle_staging.sys_store ss on ss.id = di.store_id
where
    di.diff_marker_category in (19,20) -- 网点上报破损
    and di.created_at >= '2022-12-31 17:00:00'
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    ss.name 网点
    ,date(convert_tz(di.created_at, '+00:00', '+07:00')) 日期
    ,count(distinct di.pno) 包裹数
from fle_staging.store_diff_ticket sdt
left join fle_staging.diff_info di on di.id = sdt.diff_info_id
left join fle_staging.sys_store ss on ss.id = di.store_id
where
    di.diff_marker_category in (19,20) -- 网点上报破损,19 修复后直接继续派送，20会涉及到后续协商结果，以及是否进入闪速系统
    and di.created_at >= '2022-12-31 17:00:00'
    and di.store_id = 'TH01180105'
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
tp.id 揽件任务id
,convert_tz(oi.created_at,'+00:00','+07:00') 创建订单时间
,convert_tz(oi.confirm_at,'+00:00','+07:00') 确认下单时间
,oi.pno 运单号
,tp.client_id
,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as  客户类型
,convert_tz(tp.pickup_created_at,'+00:00','+07:00') 揽件任务生成时间
,tr.remark 取消原因备注
,concat( 'https://fle-asset-internal.oss-ap-southeast-1.aliyuncs.com/'  ,sa.object_key) 取消揽件任务照片
,convert_tz(tr.routed_at,'+00:00','+07:00') 取消任务时间
,tp.staff_info_id 标记快递员ID
,ss.name 标记快递员所属网点
,case oi.state
 when 0 then '已确认'
 when 1 then '待揽件'
 when 2 then '已揽收'
 when 3 then '已取消(已终止)'
 when 4 then '已删除(已作废)'
 when 5 then '预下单'
 when 6 then '被标记多次，限制揽收'
end as 订单状态
,convert_tz(pi.created_at,'+00:00','+07:00') 揽收时间
,pi.ticket_pickup_staff_info_id 揽收快递员
,ss2.name 揽收快递员网点
,if(oi.state=3,convert_tz(oi.aborted_at,'+00:00','+07:00'),null) 取消订单时间
,if(tcf.pickup_id is not null ,'是','否') '是否进入【FBI-QAQC-虚假标记审核-标记超大件、违禁物品审核】'
,case tcf.state
when 1 then '待处理'
when 2 then '责任人已认定'
when 3 then '无需判责'
end 判责结果
,tcf.process_time 审核时间
,tcf.staff_info_id 责任快递员ID
,tcf.store_name 责任快递员网点

from fle_staging.ticket_pickup tp

left join dwm.tmp_ex_big_clients_id_detail bc
on tp.client_id=bc.client_id

left join fle_staging.ka_profile kp
on tp.client_id=kp.id

left join fle_staging.ticket_pickup_order_relation tpo -- 转单前任务id
on if(tp.transfer_ancestry is not null,substring(tp.transfer_ancestry,1,9),tp.id)=tpo.ticket_pickup_id

left join bi_pro.ticket_cancel_fake_mark tcf -- 【FBI-QAQC-虚假标记审核-标记超大件、违禁物品审核】
on tp.id=tcf.pickup_id

left join fle_staging.order_info oi
on tpo.order_id=oi.id

left join fle_staging.parcel_info pi
on oi.pno=pi.pno
left join bi_pro.hr_staff_info hsi2
on pi.ticket_pickup_staff_info_id=hsi2.staff_info_id
left join fle_staging.sys_store ss2
on hsi2.sys_store_id=ss2.id

left join bi_pro.hr_staff_info hsi
on tp.staff_info_id=hsi.staff_info_id

left join fle_staging.sys_store ss
on hsi.sys_store_id=ss.id

left join m2_pro.ticket_route tr
on tp.id=tr.current_ticket_id

left join fle_staging.sys_attachment sa
on tp.id=sa.oss_bucket_key
and sa.oss_bucket_type in ('TICKET_CANCEL_PICKUP_MARK_UPLOAD','TICKET_CANCEL_CANCEL_ORDER_PHOTO_UPLOAD')

left join fle_staging.ticket_pickup_marker tpm
on tp.id=tpm.pickup_id

where 1=1
and tcf.process_time>='2023-03-01'
and tcf.process_time<'2023-03-29'
and tp.state=4 -- 取消任务
and tr.route_action=2
-- and tr.operator_type<>6
and tpm.marker_id in (87,100) -- 违禁品
-- and tp.id=417050585

group by 1,4;
;-- -. . -..- - / . -. - .-. -.--
select
        plt.pno
        ,plt.id
        ,plt.client_id
        ,plt.created_at
        ,plt.last_valid_store_id
        ,plt.last_valid_staff_info_id
    from bi_pro.parcel_lose_task plt
    where
        plt.state < 5
        and plt.source = 2;
;-- -. . -..- - / . -. - .-. -.--
with t1 as
(
    select
        plt.pno
        ,plt.id
        ,plt.client_id
        ,plt.created_at
        ,plt.last_valid_store_id
        ,plt.last_valid_staff_info_id
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
    join t1 on t1.id = wo.loseparcel_task_id
    left join bi_pro.work_order_reply wor on wor.order_id = wo.id
    left join bi_pro.work_order_img woi on woi.origin_id = wor.id
)
,t2 as
(
    select
        wo.pnos
        ,wo.created_at
        ,row_number() over (partition by wo.pnos order by wo.created_at ) rn
    from bi_pro.work_order wo
    join t1 on t1.pno = wo.pnos
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
    ,t1.last_valid_staff_info_id 最后有效路由操作人
    ,ss_valid.name 最后有效路由网点
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
    ,if(noduty.pno is null, '否', '是') 是否无需追责过
    ,pi.dst_phone  收件人电话
    ,num.num 创建工单次数
    ,1st.order_creat_at 第一次创建工单时间
    ,fir.created_at 第一次全组织发工单时间
    ,lst.content 最后一次全组织工单回复内容
    ,1st.wor_content 第一次回复内容
    ,concat('https://fle-asset-internal.oss-ap-southeast-1.aliyuncs.com/',1st.object_key) 第一次回复附件
    ,2nd.wor_content 第二次回复内容
    ,concat('https://fle-asset-internal.oss-ap-southeast-1.aliyuncs.com/',2nd.object_key) 第二次回复附件
    ,3rd.wor_content 第三次回复内容
    ,concat('https://fle-asset-internal.oss-ap-southeast-1.aliyuncs.com/',3rd.object_key) 第三次回复附件
    ,concat('https://fle-asset-internal.oss-ap-southeast-1.aliyuncs.com/',sa1.object_key) 签收凭证
    ,concat('https://fle-asset-internal.oss-ap-southeast-1.aliyuncs.com/',sa2.object_key) 其他凭证
from t1
left join fle_staging.parcel_info pi on pi.pno = t1.pno
left join fle_staging.sys_store dst_ss on dst_ss.id = pi.dst_store_id
left join fle_staging.sys_store del_ss on del_ss.id = pi.ticket_delivery_store_id
left join fle_staging.sys_store ss_valid on ss_valid.id = t1.last_valid_store_id
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
left join t2 fir on fir.pnos = t1.pno and fir.rn = 1
left join
    (
        select
            wo2.pnos
            ,wor.content
            ,row_number() over (partition by wo2.pnos order by wor.created_at desc) rn
        from bi_pro.work_order wo2
        join t1 on t1.pno = wo2.pnos
        left join bi_pro.work_order_reply wor on wor.order_id = wo2.id
        where
            wor.staff_info_id != wo2.created_staff_info_id
    ) lst on lst.pnos = t1.pno and lst.rn = 1
left join
    (
        select
            plt2.pno
        from bi_pro.parcel_lose_task plt2
        where
            plt2.state = 5
            and plt2.source = 2
        group by 1
    ) noduty on noduty.pno = t1.pno
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
        ,plt.last_valid_store_id
        ,plt.last_valid_staff_info_id
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
    join t1 on t1.id = wo.loseparcel_task_id
    left join bi_pro.work_order_reply wor on wor.order_id = wo.id
    left join bi_pro.work_order_img woi on woi.origin_id = wor.id
)
,t2 as
(
    select
        wo.pnos
        ,wo.created_at
        ,row_number() over (partition by wo.pnos order by wo.created_at ) rn
    from bi_pro.work_order wo
    join t1 on t1.pno = wo.pnos
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
    ,t1.last_valid_staff_info_id 最后有效路由操作人
    ,ss_valid.name 最后有效路由网点
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
    ,if(noduty.pno is null, '否', '是') 是否无需追责过
    ,pi.dst_phone  收件人电话
    ,num.num 创建工单次数
    ,1st.order_creat_at 第一次创建工单时间
    ,fir.created_at 第一次全组织发工单时间
    ,lst.content 最后一次全组织工单回复内容
    ,1st.wor_content 第一次回复内容
    ,concat('https://fle-asset-internal.oss-ap-southeast-1.aliyuncs.com/',1st.object_key) 第一次回复附件
    ,2nd.wor_content 第二次回复内容
    ,concat('https://fle-asset-internal.oss-ap-southeast-1.aliyuncs.com/',2nd.object_key) 第二次回复附件
    ,3rd.wor_content 第三次回复内容
    ,concat('https://fle-asset-internal.oss-ap-southeast-1.aliyuncs.com/',3rd.object_key) 第三次回复附件
    ,concat('https://fle-asset-internal.oss-ap-southeast-1.aliyuncs.com/',sa1.object_key) 签收凭证
    ,concat('https://fle-asset-internal.oss-ap-southeast-1.aliyuncs.com/',sa2.object_key) 其他凭证
from t1
left join fle_staging.parcel_info pi on pi.pno = t1.pno
left join fle_staging.sys_store dst_ss on dst_ss.id = pi.dst_store_id
left join fle_staging.sys_store del_ss on del_ss.id = pi.ticket_delivery_store_id
left join fle_staging.sys_store ss_valid on ss_valid.id = t1.last_valid_store_id
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
                    pr.routed_at > curdate() - interval 10 day
            ) pr
        where pr.rn = 1
    ) las2 on las2.pno = t1.pno
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at) rn
        from rot_pro.parcel_route pr
        where pr.route_action = 'PHONE'
            and json_extract(pr.extra_value, '$.callDuration') > 7
            and pr.routed_at > curdate() - interval 10 day
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
            and pr.routed_at > curdate() - interval 10 day
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
left join t2 fir on fir.pnos = t1.pno and fir.rn = 1
left join
    (
        select
            wo2.pnos
            ,wor.content
            ,row_number() over (partition by wo2.pnos order by wor.created_at desc) rn
        from bi_pro.work_order wo2
        join t1 on t1.pno = wo2.pnos
        left join bi_pro.work_order_reply wor on wor.order_id = wo2.id
        where
            wor.staff_info_id != wo2.created_staff_info_id
    ) lst on lst.pnos = t1.pno and lst.rn = 1
left join
    (
        select
            plt2.pno
        from bi_pro.parcel_lose_task plt2
        where
            plt2.state = 5
            and plt2.source = 2
        group by 1
    ) noduty on noduty.pno = t1.pno
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
        ,plt.last_valid_store_id
        ,plt.last_valid_staff_info_id
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
    join t1 on t1.id = wo.loseparcel_task_id
    left join bi_pro.work_order_reply wor on wor.order_id = wo.id
    left join bi_pro.work_order_img woi on woi.origin_id = wor.id
)
,t2 as
(
    select
        wo.pnos
        ,wo.created_at
        ,row_number() over (partition by wo.pnos order by wo.created_at ) rn
    from bi_pro.work_order wo
    join t1 on t1.pno = wo.pnos
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
    ,t1.last_valid_staff_info_id 最后有效路由操作人
    ,ss_valid.name 最后有效路由网点
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
    ,if(noduty.pno is null, '否', '是') 是否无需追责过
    ,pi.dst_phone  收件人电话
    ,num.num 创建工单次数
    ,1st.order_creat_at 第一次创建工单时间
    ,fir.created_at 第一次全组织发工单时间
    ,lst.content 最后一次全组织工单回复内容
    ,1st.wor_content 第一次回复内容
    ,concat('https://fle-asset-internal.oss-ap-southeast-1.aliyuncs.com/',1st.object_key) 第一次回复附件
    ,2nd.wor_content 第二次回复内容
    ,concat('https://fle-asset-internal.oss-ap-southeast-1.aliyuncs.com/',2nd.object_key) 第二次回复附件
    ,3rd.wor_content 第三次回复内容
    ,concat('https://fle-asset-internal.oss-ap-southeast-1.aliyuncs.com/',3rd.object_key) 第三次回复附件
    ,concat('https://fle-asset-internal.oss-ap-southeast-1.aliyuncs.com/',sa1.object_key) 签收凭证
    ,concat('https://fle-asset-internal.oss-ap-southeast-1.aliyuncs.com/',sa2.object_key) 其他凭证
from t1
left join fle_staging.parcel_info pi on pi.pno = t1.pno
left join fle_staging.sys_store dst_ss on dst_ss.id = pi.dst_store_id
left join fle_staging.sys_store del_ss on del_ss.id = pi.ticket_delivery_store_id
left join fle_staging.sys_store ss_valid on ss_valid.id = t1.last_valid_store_id
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
                    pr.routed_at > curdate() - interval 10 day
            ) pr
        where pr.rn = 1
    ) las2 on las2.pno = t1.pno
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at) rn
        from rot_pro.parcel_route pr
        join
            (
                select t1.pno from t1 group by 1
            ) t on pr.pno = t.pno
        where pr.route_action = 'PHONE'
            and json_extract(pr.extra_value, '$.callDuration') > 7
            and pr.routed_at > curdate() - interval 10 day
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
            and pr.routed_at > curdate() - interval 10 day
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
left join t2 fir on fir.pnos = t1.pno and fir.rn = 1
left join
    (
        select
            wo2.pnos
            ,wor.content
            ,row_number() over (partition by wo2.pnos order by wor.created_at desc) rn
        from bi_pro.work_order wo2
        join t1 on t1.pno = wo2.pnos
        left join bi_pro.work_order_reply wor on wor.order_id = wo2.id
        where
            wor.staff_info_id != wo2.created_staff_info_id
    ) lst on lst.pnos = t1.pno and lst.rn = 1
left join
    (
        select
            plt2.pno
        from bi_pro.parcel_lose_task plt2
        where
            plt2.state = 5
            and plt2.source = 2
        group by 1
    ) noduty on noduty.pno = t1.pno
left join fle_staging.sys_attachment sa1 on sa1.oss_bucket_key = t1.pno and sa1.oss_bucket_type = 'DELIVERY_CONFIRM'
left join fle_staging.sys_attachment sa2 on sa2.oss_bucket_key = t1.pno and sa2.oss_bucket_type = 'DELIVERY_CONFIRM_OTHER';
;-- -. . -..- - / . -. - .-. -.--
select
    ss.name
    ,count(distinct di.pno) 3月份上传虚假
#     ,count(distinct if(di.created_at > '2023-02-24 17:00:00', di.pno, null)) 上线后
from fle_staging.diff_info di
left join fle_staging.sys_store ss on ss.id = di.store_id
where
    di.diff_marker_category in (30,31)  -- 分错地址
    and di.created_at >= '2023-02-28 17:00:00'
    and di.created_at < '2023-03-31 17:00:00'
    and ss.name in ('BKS_SP-บางกระสอ', 'KTH_SP-คลองตันเหนือ', 'ONN_SP-อ่อนนุช', 'BKP_SP-บึงคำพร้อย', 'KTE_SP-คลองเตย', 'PCP_SP-ประชาธิปัตย์', 'BKH_SP-บึงคอไห', 'BPA_SP-บางปลา', 'KUK_SP-คูคต', 'ONG_SP-ออเงิน', '2WAT_BDC-วัฒนา', 'KOW_SP-คลองควาย', 'KPW_SP-คลองประเวศ', 'TAS_SP-ตาสิทธิ์', 'BHK_SP-บางคล้า', 'NYI_SP-หนองใหญ่')
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    a.*
    ,b.3月份虚假
    ,b.上线后虚假
    ,b.3月份虚假/a.3月份上传虚假 3月虚假错分占比
    ,b.上线后虚假/a.上线后上传虚假 上线后虚假错分占比
from
    (
        select
            ss.name
            ,count(distinct if(di.created_at < '2023-03-31 17:00:00', di.pno, null)) 3月份上传虚假
            ,count(distinct if(di.created_at > '2023-02-24 17:00:00', di.pno, null)) 上线后上传虚假
        from fle_staging.diff_info di
        left join fle_staging.sys_store ss on ss.id = di.store_id
        where
            di.diff_marker_category in (30,31)  -- 分错地址
            and di.created_at >= '2023-02-28 17:00:00'
            and di.created_at < '2023-04-01 17:00:00'
            and ss.name in ('BKS_SP-บางกระสอ', 'KTH_SP-คลองตันเหนือ', 'ONN_SP-อ่อนนุช', 'BKP_SP-บึงคำพร้อย', 'KTE_SP-คลองเตย', 'PCP_SP-ประชาธิปัตย์', 'BKH_SP-บึงคอไห', 'BPA_SP-บางปลา', 'KUK_SP-คูคต', 'ONG_SP-ออเงิน', '2WAT_BDC-วัฒนา', 'KOW_SP-คลองควาย', 'KPW_SP-คลองประเวศ', 'TAS_SP-ตาสิทธิ์', 'BHK_SP-บางคล้า', 'NYI_SP-หนองใหญ่')
        group by 1
    ) a
left join
    (
        select
            ss.name
            ,count(distinct if(am.abnormal_time < '2023-04-01', am.pno, null)) 3月份虚假
            ,count(distinct if(am.abnormal_time >= '2023-03-25', am.pno, null)) 上线后虚假
        from bi_pro.abnormal_message am
        left join fle_staging.sys_store ss on ss.id = am.store_id
        where
            am.abnormal_time >= '2023-03-01 00:00:00'
            and am.abnormal_time < '2023-04-02 00:00:00'
            and am.punish_category = 53 -- 虚假错分
            and  ( am.isappeal != 5 or am.isdel = 0)
            and ss.name in ('BKS_SP-บางกระสอ', 'KTH_SP-คลองตันเหนือ', 'ONN_SP-อ่อนนุช', 'BKP_SP-บึงคำพร้อย', 'KTE_SP-คลองเตย', 'PCP_SP-ประชาธิปัตย์', 'BKH_SP-บึงคอไห', 'BPA_SP-บางปลา', 'KUK_SP-คูคต', 'ONG_SP-ออเงิน', '2WAT_BDC-วัฒนา', 'KOW_SP-คลองควาย', 'KPW_SP-คลองประเวศ', 'TAS_SP-ตาสิทธิ์', 'BHK_SP-บางคล้า', 'NYI_SP-หนองใหญ่')
        group by 1
    ) b on b.name = a.name;
;-- -. . -..- - / . -. - .-. -.--
select
    a.*
    ,b.3月份虚假
    ,b.上线后虚假
    ,b.3月份虚假/a.3月份上传虚假 3月虚假错分占比
    ,b.上线后虚假/a.上线后上传虚假 上线后虚假错分占比
from
    (
        select
            ss.name
            ,count(distinct if(di.created_at < '2023-03-31 17:00:00', di.pno, null)) 3月份上传虚假
            ,count(distinct if(di.created_at > '2023-02-24 17:00:00', di.pno, null)) 上线后上传虚假
        from fle_staging.diff_info di
        left join fle_staging.parcel_info pi on pi.pno = di.pno
        join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id and bc.client_name = 'tiktok'
        left join fle_staging.sys_store ss on ss.id = di.store_id
        where
            di.diff_marker_category in (30,31)  -- 分错地址
            and di.created_at >= '2023-02-28 17:00:00'
            and di.created_at < '2023-04-01 17:00:00'
            and ss.name in ('BKS_SP-บางกระสอ', 'KTH_SP-คลองตันเหนือ', 'ONN_SP-อ่อนนุช', 'BKP_SP-บึงคำพร้อย', 'KTE_SP-คลองเตย', 'PCP_SP-ประชาธิปัตย์', 'BKH_SP-บึงคอไห', 'BPA_SP-บางปลา', 'KUK_SP-คูคต', 'ONG_SP-ออเงิน', '2WAT_BDC-วัฒนา', 'KOW_SP-คลองควาย', 'KPW_SP-คลองประเวศ', 'TAS_SP-ตาสิทธิ์', 'BHK_SP-บางคล้า', 'NYI_SP-หนองใหญ่')
        group by 1
    ) a
left join
    (
        select
            ss.name
            ,count(distinct if(am.abnormal_time < '2023-04-01', am.pno, null)) 3月份虚假
            ,count(distinct if(am.abnormal_time >= '2023-03-25', am.pno, null)) 上线后虚假
        from bi_pro.abnormal_message am
        left join fle_staging.parcel_info pi on pi.pno = am.merge_column
        join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id and bc.client_name = 'tiktok'
        left join fle_staging.sys_store ss on ss.id = am.store_id
        where
            am.abnormal_time >= '2023-03-01 00:00:00'
            and am.abnormal_time < '2023-04-02 00:00:00'
            and am.punish_category = 53 -- 虚假错分
            and  ( am.isappeal != 5 or am.isdel = 0)
            and ss.name in ('BKS_SP-บางกระสอ', 'KTH_SP-คลองตันเหนือ', 'ONN_SP-อ่อนนุช', 'BKP_SP-บึงคำพร้อย', 'KTE_SP-คลองเตย', 'PCP_SP-ประชาธิปัตย์', 'BKH_SP-บึงคอไห', 'BPA_SP-บางปลา', 'KUK_SP-คูคต', 'ONG_SP-ออเงิน', '2WAT_BDC-วัฒนา', 'KOW_SP-คลองควาย', 'KPW_SP-คลองประเวศ', 'TAS_SP-ตาสิทธิ์', 'BHK_SP-บางคล้า', 'NYI_SP-หนองใหญ่')
        group by 1
    ) b on b.name = a.name;
;-- -. . -..- - / . -. - .-. -.--
select
    a.*
    ,b.3月份虚假
    ,b.上线后虚假
    ,b.3月份虚假/a.3月份上传虚假 3月虚假错分占比
    ,b.上线后虚假/a.上线后上传虚假 上线后虚假错分占比
from
    (
        select
            ss.name
            ,count(distinct if(di.created_at < '2023-03-31 17:00:00', di.pno, null)) 3月份上传虚假
            ,count(distinct if(di.created_at > '2023-03-24 17:00:00', di.pno, null)) 上线后上传虚假
        from fle_staging.diff_info di
        left join fle_staging.parcel_info pi on pi.pno = di.pno
        join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id and bc.client_name = 'tiktok'
        left join fle_staging.sys_store ss on ss.id = di.store_id
        where
            di.diff_marker_category in (30,31)  -- 分错地址
            and di.created_at >= '2023-02-28 17:00:00'
            and di.created_at < '2023-04-01 17:00:00'
            and ss.name in ('BKS_SP-บางกระสอ', 'KTH_SP-คลองตันเหนือ', 'ONN_SP-อ่อนนุช', 'BKP_SP-บึงคำพร้อย', 'KTE_SP-คลองเตย', 'PCP_SP-ประชาธิปัตย์', 'BKH_SP-บึงคอไห', 'BPA_SP-บางปลา', 'KUK_SP-คูคต', 'ONG_SP-ออเงิน', '2WAT_BDC-วัฒนา', 'KOW_SP-คลองควาย', 'KPW_SP-คลองประเวศ', 'TAS_SP-ตาสิทธิ์', 'BHK_SP-บางคล้า', 'NYI_SP-หนองใหญ่')
        group by 1
    ) a
left join
    (
        select
            ss.name
            ,count(distinct if(am.abnormal_time < '2023-04-01', am.pno, null)) 3月份虚假
            ,count(distinct if(am.abnormal_time >= '2023-03-25', am.pno, null)) 上线后虚假
        from bi_pro.abnormal_message am
        left join fle_staging.parcel_info pi on pi.pno = am.merge_column
        join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id and bc.client_name = 'tiktok'
        left join fle_staging.sys_store ss on ss.id = am.store_id
        where
            am.abnormal_time >= '2023-03-01 00:00:00'
            and am.abnormal_time < '2023-04-02 00:00:00'
            and am.punish_category = 53 -- 虚假错分
            and  ( am.isappeal != 5 or am.isdel = 0)
            and ss.name in ('BKS_SP-บางกระสอ', 'KTH_SP-คลองตันเหนือ', 'ONN_SP-อ่อนนุช', 'BKP_SP-บึงคำพร้อย', 'KTE_SP-คลองเตย', 'PCP_SP-ประชาธิปัตย์', 'BKH_SP-บึงคอไห', 'BPA_SP-บางปลา', 'KUK_SP-คูคต', 'ONG_SP-ออเงิน', '2WAT_BDC-วัฒนา', 'KOW_SP-คลองควาย', 'KPW_SP-คลองประเวศ', 'TAS_SP-ตาสิทธิ์', 'BHK_SP-บางคล้า', 'NYI_SP-หนองใหญ่')
        group by 1
    ) b on b.name = a.name;
;-- -. . -..- - / . -. - .-. -.--
select
    a.*
    ,b.3月份虚假
    ,b.上线后虚假
    ,b.3月份虚假/a.3月份上传虚假 3月虚假错分占比
    ,b.上线后虚假/a.上线后上传虚假 上线后虚假错分占比
from
    (
        select
            ss.name
            ,count(distinct if(di.created_at < '2023-03-31 17:00:00', di.pno, null)) 3月份上传虚假
            ,count(distinct if(di.created_at > '2023-03-24 17:00:00', di.pno, null)) 上线后上传虚假
        from fle_staging.diff_info di
#         left join fle_staging.parcel_info pi on pi.pno = di.pno
#         join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id and bc.client_name = 'tiktok'
        left join fle_staging.sys_store ss on ss.id = di.store_id
        where
            di.diff_marker_category in (30,31)  -- 分错地址
            and di.created_at >= '2023-02-28 17:00:00'
            and di.created_at < '2023-04-01 17:00:00'
            and ss.name in ('BKS_SP-บางกระสอ', 'KTH_SP-คลองตันเหนือ', 'ONN_SP-อ่อนนุช', 'BKP_SP-บึงคำพร้อย', 'KTE_SP-คลองเตย', 'PCP_SP-ประชาธิปัตย์', 'BKH_SP-บึงคอไห', 'BPA_SP-บางปลา', 'KUK_SP-คูคต', 'ONG_SP-ออเงิน', '2WAT_BDC-วัฒนา', 'KOW_SP-คลองควาย', 'KPW_SP-คลองประเวศ', 'TAS_SP-ตาสิทธิ์', 'BHK_SP-บางคล้า', 'NYI_SP-หนองใหญ่')
        group by 1
    ) a
left join
    (
        select
            ss.name
            ,count(distinct if(am.abnormal_time < '2023-04-01', am.pno, null)) 3月份虚假
            ,count(distinct if(am.abnormal_time >= '2023-03-25', am.pno, null)) 上线后虚假
        from bi_pro.abnormal_message am
#         left join fle_staging.parcel_info pi on pi.pno = am.merge_column
#         join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id and bc.client_name = 'tiktok'
        left join fle_staging.sys_store ss on ss.id = am.store_id
        where
            am.abnormal_time >= '2023-03-01 00:00:00'
            and am.abnormal_time < '2023-04-02 00:00:00'
            and am.punish_category = 53 -- 虚假错分
            and  ( am.isappeal != 5 or am.isdel = 0)
            and ss.name in ('BKS_SP-บางกระสอ', 'KTH_SP-คลองตันเหนือ', 'ONN_SP-อ่อนนุช', 'BKP_SP-บึงคำพร้อย', 'KTE_SP-คลองเตย', 'PCP_SP-ประชาธิปัตย์', 'BKH_SP-บึงคอไห', 'BPA_SP-บางปลา', 'KUK_SP-คูคต', 'ONG_SP-ออเงิน', '2WAT_BDC-วัฒนา', 'KOW_SP-คลองควาย', 'KPW_SP-คลองประเวศ', 'TAS_SP-ตาสิทธิ์', 'BHK_SP-บางคล้า', 'NYI_SP-หนองใหญ่')
        group by 1
    ) b on b.name = a.name;
;-- -. . -..- - / . -. - .-. -.--
select
    a.*
    ,b.3月份虚假
    ,b.上线后虚假
    ,b.3月份虚假/a.3月份上传虚假 3月虚假错分占比
    ,b.上线后虚假/a.上线后上传虚假 上线后虚假错分占比
from
    (
        select
            ss.name
            ,count(distinct if(di.created_at < '2023-03-31 17:00:00', di.pno, null)) 3月份上传虚假
            ,count(distinct if(di.created_at > '2023-03-24 17:00:00', di.pno, null)) 上线后上传虚假
        from fle_staging.diff_info di
#         left join fle_staging.parcel_info pi on pi.pno = di.pno
#         join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id and bc.client_name = 'tiktok'
        left join fle_staging.sys_store ss on ss.id = di.store_id
        where
            di.diff_marker_category in (30,31)  -- 分错地址
            and di.created_at >= '2023-02-28 17:00:00'
            and di.created_at < '2023-03-31 17:00:00'
            and ss.name in ('BKS_SP-บางกระสอ', 'KTH_SP-คลองตันเหนือ', 'ONN_SP-อ่อนนุช', 'BKP_SP-บึงคำพร้อย', 'KTE_SP-คลองเตย', 'PCP_SP-ประชาธิปัตย์', 'BKH_SP-บึงคอไห', 'BPA_SP-บางปลา', 'KUK_SP-คูคต', 'ONG_SP-ออเงิน', '2WAT_BDC-วัฒนา', 'KOW_SP-คลองควาย', 'KPW_SP-คลองประเวศ', 'TAS_SP-ตาสิทธิ์', 'BHK_SP-บางคล้า', 'NYI_SP-หนองใหญ่')
        group by 1
    ) a
left join
    (
        select
            ss.name
            ,count(distinct if(am.abnormal_time < '2023-04-01', am.pno, null)) 3月份虚假
            ,count(distinct if(am.abnormal_time >= '2023-03-25', am.pno, null)) 上线后虚假
        from bi_pro.abnormal_message am
#         left join fle_staging.parcel_info pi on pi.pno = am.merge_column
#         join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id and bc.client_name = 'tiktok'
        left join fle_staging.sys_store ss on ss.id = am.store_id
        where
            am.abnormal_time >= '2023-03-01 00:00:00'
            and am.abnormal_time < '2023-04-01 00:00:00'
            and am.punish_category = 53 -- 虚假错分
            and  ( am.isappeal != 5 or am.isdel = 0)
            and ss.name in ('BKS_SP-บางกระสอ', 'KTH_SP-คลองตันเหนือ', 'ONN_SP-อ่อนนุช', 'BKP_SP-บึงคำพร้อย', 'KTE_SP-คลองเตย', 'PCP_SP-ประชาธิปัตย์', 'BKH_SP-บึงคอไห', 'BPA_SP-บางปลา', 'KUK_SP-คูคต', 'ONG_SP-ออเงิน', '2WAT_BDC-วัฒนา', 'KOW_SP-คลองควาย', 'KPW_SP-คลองประเวศ', 'TAS_SP-ตาสิทธิ์', 'BHK_SP-บางคล้า', 'NYI_SP-หนองใหญ่')
        group by 1
    ) b on b.name = a.name;
;-- -. . -..- - / . -. - .-. -.--
select
    a.*
    ,b.3月份虚假
    ,b.上线后虚假
    ,b.3月份虚假/a.3月份上传虚假 3月虚假错分占比
    ,b.上线后虚假/a.上线后上传虚假 上线后虚假错分占比
from
    (
        select
            ss.name
            ,count(distinct if(di.created_at < '2023-03-31 17:00:00', di.pno, null)) 3月份上传虚假
            ,count(distinct if(di.created_at > '2023-03-24 17:00:00', di.pno, null)) 上线后上传虚假
        from fle_staging.diff_info di
        left join fle_staging.parcel_info pi on pi.pno = di.pno
        join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id and bc.client_name = 'tiktok'
        left join fle_staging.sys_store ss on ss.id = di.store_id
        where
            di.diff_marker_category in (30,31)  -- 分错地址
            and di.created_at >= '2023-02-28 17:00:00'
            and di.created_at < '2023-03-31 17:00:00'
            and ss.name in ('BKS_SP-บางกระสอ', 'KTH_SP-คลองตันเหนือ', 'ONN_SP-อ่อนนุช', 'BKP_SP-บึงคำพร้อย', 'KTE_SP-คลองเตย', 'PCP_SP-ประชาธิปัตย์', 'BKH_SP-บึงคอไห', 'BPA_SP-บางปลา', 'KUK_SP-คูคต', 'ONG_SP-ออเงิน', '2WAT_BDC-วัฒนา', 'KOW_SP-คลองควาย', 'KPW_SP-คลองประเวศ', 'TAS_SP-ตาสิทธิ์', 'BHK_SP-บางคล้า', 'NYI_SP-หนองใหญ่')
        group by 1
    ) a
left join
    (
        select
            ss.name
            ,count(distinct if(am.abnormal_time < '2023-04-01', am.pno, null)) 3月份虚假
            ,count(distinct if(am.abnormal_time >= '2023-03-25', am.pno, null)) 上线后虚假
        from bi_pro.abnormal_message am
        left join fle_staging.parcel_info pi on pi.pno = am.merge_column
        join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id and bc.client_name = 'tiktok'
        left join fle_staging.sys_store ss on ss.id = am.store_id
        where
            am.abnormal_time >= '2023-03-01 00:00:00'
            and am.abnormal_time < '2023-04-01 00:00:00'
            and am.punish_category = 53 -- 虚假错分
            and  ( am.isappeal != 5 or am.isdel = 0)
            and ss.name in ('BKS_SP-บางกระสอ', 'KTH_SP-คลองตันเหนือ', 'ONN_SP-อ่อนนุช', 'BKP_SP-บึงคำพร้อย', 'KTE_SP-คลองเตย', 'PCP_SP-ประชาธิปัตย์', 'BKH_SP-บึงคอไห', 'BPA_SP-บางปลา', 'KUK_SP-คูคต', 'ONG_SP-ออเงิน', '2WAT_BDC-วัฒนา', 'KOW_SP-คลองควาย', 'KPW_SP-คลองประเวศ', 'TAS_SP-ตาสิทธิ์', 'BHK_SP-บางคล้า', 'NYI_SP-หนองใหญ่')
        group by 1
    ) b on b.name = a.name;
;-- -. . -..- - / . -. - .-. -.--
select
    sa.clientid
    ,sa.device_sn_code
from staff_account sa
where
    sa.clientid in ('16203385549921620338555013', '16620382663641662038266366', '865881042765039520032205919528', '869881014003803520044034632552', '16349150961421634915096143', '8621220493684661669995177774', '862122049207003520002018812517', '75b8018421cc5782', '16442814214101644281421411', '16632408955401663240895540', '16553450225111655345022514', '16487274914661648727491466', '16741961444741674196144475', '16775115495741677511549577', '16676588205731667658820575', '12623048393981262304839398', '16629931162381662993116238', '16731725772771673172577283', '16583677563401658367756341', '05cd31000d24ea1c', '16461346685831646134668584', '16611405558281661140555828', '16754329642911675432964298', '358145091489527520033402859409', '111fd3a2441d7851', '16497228350651649722835069', '16621306194021662130619402', '16753084578851675308457886', '16391913922471639191392252', '16712783574371671278357445', '16242808422771624280842283', '16564282304111656428230414', '16689909817651668990981765', '16343661090221634366109023', '16494623011981649462301204', '16665738190271666573819033', '16676583456821667658345682', '16303938607091630393860743', '16702921802831670292180283', '16735740451861673574045194', '860986041711333520002070492327', '16688596221151668859622121', '16592750563171659275056317', '867615049879510520050321942230', '869881013220036520002011471617', 'bed82a8b3181eb4a', '16579641489541657964148970', '21e3404e618968c0', '16768002206061676800220607', '865209047221214520002047159176', '16779385438051677938543805', '16543571638131654357163814', '16549097435811654909743582', '16680421921641668042192176', '869193044147026520050808895046', '16061253345481606125334549', '16487390024041648739002405', '2d1159d6aec3046f', '865209047036455520030506707919', '12623040514791262304051480', '16232856897361623285689737', '16335784299831633578429983', '16345268298841634526829884', '16468224008601646822400861', '16471319970771647131997095', '16784915326031678491532608', '16799228268361679922826836', '8658810443216821670155784809', '16233311342151623331134216', '16310299098651631029909866', '16395643835281639564383529', '16651919083121665191908322', '16760218133291676021813330', '1a3e484ab1a3b9a8', '862122049181042520002023950378', '865881043539326520002083793439', '869881013711307520002011788124', '9001b1bfe5253461', '12623041656351262304165636', '16657346796421665734679643', '16689949529461668994952947', '16707303572861670730357286', '16777172288611677717228871', '564ed869500ae935', '6ca52e01c5a857dc', '861244040631063520002093338135', '863818021418117460007492463416', '865881041046100520030506839236', '865881043083127520002006025693', '869167039774085520030309270420', '869881012276088520002051420875', '869881014205515520002012308236', 'e385f284a06cfff0')
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    *
from tmpale.tmp_th_staff_0404 t;
;-- -. . -..- - / . -. - .-. -.--
select
    t.staff_info_id
    ,pick.num '日均揽收量 pick up/day'
    ,scan.num '日均交接量 scan/day'
    ,del.num '日均妥投量 delivery/day'
from tmpale.tmp_th_staff_0404 t
left join
    (
        select
            pi.ticket_pickup_staff_info_id
            ,count(distinct pi.pno)/count(distinct date(convert_tz(pi.created_at, '+00:00', '+07:00'))) num
        from fle_staging.parcel_info pi
        join tmpale.tmp_th_staff_0404 t on t.staff_info_id = pi.ticket_pickup_staff_info_id
        where
            pi.created_at >= '2023-02-28 17:00:00'
            and pi.created_at < '2023-03-31 17:00:00'
        group by 1
    ) pick on pick.ticket_pickup_staff_info_id = t.staff_info_id
left join
    (
        select
            pr.staff_info_id
            ,count(distinct pr.pno)/count(distinct date(convert_tz(pr.routed_at, '+00:00', '+07:00'))) num
        from rot_pro.parcel_route pr
        join tmpale.tmp_th_staff_0404 t on t.staff_info_id = pr.staff_info_id
        where
            pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
            and pr.routed_at >= '2023-02-28 17:00:00'
            and pr.routed_at < '2023-03-31 17:00:00'
        group by 1
    ) scan on scan.staff_info_id = t.staff_info_id
left join
    (
        select
            pi.ticket_pickup_staff_info_id
            ,count(distinct pi.pno)/count(distinct date(convert_tz(pi.finished_at, '+00:00', '+07:00'))) num
        from fle_staging.parcel_info pi
        join tmpale.tmp_th_staff_0404 t on t.staff_info_id = pi.ticket_delivery_staff_info_id
        where
            pi.finished_at >= '2023-02-28 17:00:00'
            and pi.finished_at < '2023-03-31 17:00:00'
            and pi.state = 5
        group by 1
    ) del on del.ticket_pickup_staff_info_id = t.staff_info_id;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.ticket_pickup_staff_info_id
#             ,count(distinct pi.pno)/count(distinct date(convert_tz(pi.finished_at, '+00:00', '+07:00'))) num
    ,date(convert_tz(pi.finished_at, '+00:00', '+07:00')) date_d
    ,pi.pno
from fle_staging.parcel_info pi
join tmpale.tmp_th_staff_0404 t on t.staff_info_id = pi.ticket_delivery_staff_info_id
where
    pi.finished_at >= '2023-02-28 17:00:00'
    and pi.finished_at < '2023-03-31 17:00:00'
    and pi.state = 5;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.ticket_pickup_staff_info_id
#             ,count(distinct pi.pno)/count(distinct date(convert_tz(pi.finished_at, '+00:00', '+07:00'))) num
    ,date(convert_tz(pi.finished_at, '+00:00', '+07:00')) date_d
    ,pi.pno
from fle_staging.parcel_info pi
join tmpale.tmp_th_staff_0404 t on t.staff_info_id = pi.ticket_delivery_staff_info_id
where
    pi.finished_at >= '2023-02-28 17:00:00'
    and pi.finished_at < '2023-03-31 17:00:00'
    and pi.state = 5
    and pi.ticket_delivery_staff_info_id = '601489';
;-- -. . -..- - / . -. - .-. -.--
select
    pi.ticket_pickup_staff_info_id
#             ,count(distinct pi.pno)/count(distinct date(convert_tz(pi.finished_at, '+00:00', '+07:00'))) num
    ,date(convert_tz(pi.finished_at, '+00:00', '+07:00')) date_d
    ,pi.pno
from fle_staging.parcel_info pi
# join tmpale.tmp_th_staff_0404 t on t.staff_info_id = pi.ticket_delivery_staff_info_id
where
    pi.finished_at >= '2023-02-28 17:00:00'
    and pi.finished_at < '2023-03-31 17:00:00'
    and pi.state = 5
    and pi.ticket_delivery_staff_info_id = '619414';
;-- -. . -..- - / . -. - .-. -.--
select
    pi.ticket_pickup_staff_info_id
#             ,count(distinct pi.pno)/count(distinct date(convert_tz(pi.finished_at, '+00:00', '+07:00'))) num
    ,date(convert_tz(pi.finished_at, '+00:00', '+07:00')) date_d
    ,pi.pno
from fle_staging.parcel_info pi
# join tmpale.tmp_th_staff_0404 t on t.staff_info_id = pi.ticket_delivery_staff_info_id
where
    pi.finished_at >= '2023-02-28 17:00:00'
    and pi.finished_at < '2023-03-31 17:00:00'
    and pi.state = 5
    and pi.ticket_pickup_staff_info_id = '619414';
;-- -. . -..- - / . -. - .-. -.--
select
    pi.ticket_pickup_staff_info_id
#             ,count(distinct pi.pno)/count(distinct date(convert_tz(pi.finished_at, '+00:00', '+07:00'))) num
    ,date(convert_tz(pi.created_at, '+00:00', '+07:00')) date_d
    ,pi.pno
from fle_staging.parcel_info pi
# join tmpale.tmp_th_staff_0404 t on t.staff_info_id = pi.ticket_delivery_staff_info_id
where
    pi.created_at >= '2023-02-28 17:00:00'
    and pi.created_at < '2023-03-31 17:00:00'
#     and pi.state = 5
    and pi.ticket_pickup_staff_info_id = '619414';
;-- -. . -..- - / . -. - .-. -.--
select
    a.creat_month
    ,count(a.hno) 上报丢失量
    ,count(if(a.head_state = '未认领-待认领', a.hno, null)) '未认领-待认领'
    ,count(if(a.head_state = '认领成功', a.hno, null)) '认领成功'
    ,count(if(a.head_state = '未认领-已失效', a.hno, null)) '未认领-已失效'
    ,count(if(a.head_state = '认领成功-已失效', a.hno, null)) '认领成功-已失效'
    ,count(if(a.head_state = '认领失败-已失效', a.hno, null)) '认领失败-已失效'
    ,(count(if(a.head_state = '认领成功', a.hno, null)) + count(if(a.head_state = '认领成功-已失效', a.hno, null)))/count(a.hno) 匹配成功率
from
    (
        select
            ph.hno
            ,substr(ph.created_at, 1, 7) creat_month
            ,ph.pno
            ,case
                when ph.state = 0 then '未认领-待认领'
                when ph.state = 2 then '认领成功'
                when ph.state = 3 and ph.pno is null then '未认领-已失效'
                when ph.state = 3 and ph.pno is not null and ph.updated_at < coalesce(sx.claim_time,curdate()) then '认领成功-已失效'
                when ph.state = 3 and ph.pno is not null and ph.updated_at >= coalesce(sx.claim_time,curdate()) then '认领失败-已失效'
            end head_state
        from  fle_staging.parcel_headless ph
        left join
            (
                select
                    ph.pno
                    ,min(pct.created_at) claim_time
                from fle_staging.parcel_headless ph
                join bi_pro.parcel_claim_task pct on pct.pno = ph.pno
                where
                    ph.state = 3 -- 时效
                group by 1
            ) sx on sx.pno = ph.pno
        where
            ph.state < 4
    ) a
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    a.creat_month
    ,count(a.hno) 上报丢失量
    ,count(if(a.head_state = '未认领-待认领', a.hno, null)) '待认领'
    ,count(if(a.head_state = '未认领-已失效', a.hno, null)) '未认领-定时任务失效'
    ,count(if(a.head_state = '认领成功', a.hno, null)) '认领成功-未失效'
    ,count(if(a.head_state = '认领成功-已失效', a.hno, null)) '无理赔认领-定时任务失效'
    ,count(if(a.head_state = '认领失败-已失效', a.hno, null)) '有理赔认领-理赔失效'
    ,(count(if(a.head_state = '认领成功', a.hno, null)) + count(if(a.head_state = '认领成功-已失效', a.hno, null)))/count(a.hno) 匹配成功率1
    ,(count(if(a.head_state = '认领成功', a.hno, null)) + count(if(a.head_state = '认领成功-已失效', a.hno, null)) + count(if(a.head_state = '认领失败-已失效', a.hno, null))) 匹配成功率2
from
    (
        select
            ph.hno
            ,substr(ph.created_at, 1, 4) creat_month
            ,ph.pno
            ,case
                when ph.state = 0 then '未认领-待认领'
                when ph.state = 2 then '认领成功'
                when ph.state = 3 and ph.pno is null then '未认领-已失效'
                when ph.state = 3 and ph.pno is not null and ph.updated_at < coalesce(sx.claim_time,curdate()) then '认领成功-已失效'
                when ph.state = 3 and ph.pno is not null and ph.updated_at >= coalesce(sx.claim_time,curdate()) then '认领失败-已失效'
            end head_state
        from  fle_staging.parcel_headless ph
        left join
            (
                select
                    ph.pno
                    ,min(pct.created_at) claim_time
                from fle_staging.parcel_headless ph
                join bi_pro.parcel_claim_task pct on pct.pno = ph.pno
                where
                    ph.state = 3 -- 时效
                group by 1
            ) sx on sx.pno = ph.pno
        where
            ph.state < 4
            and ph.created_at < '2023-04-01'
    ) a
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    a.creat_month
    ,count(a.hno) 上报丢失量
    ,count(if(a.head_state = '未认领-待认领', a.hno, null)) '待认领'
    ,count(if(a.head_state = '未认领-已失效', a.hno, null)) '未认领-定时任务失效'
    ,count(if(a.head_state = '认领成功', a.hno, null)) '认领成功-未失效'
    ,count(if(a.head_state = '认领成功-已失效', a.hno, null)) '无理赔认领-定时任务失效'
    ,count(if(a.head_state = '认领失败-已失效', a.hno, null)) '有理赔认领-理赔失效'
    ,(count(if(a.head_state = '认领成功', a.hno, null)) + count(if(a.head_state = '认领成功-已失效', a.hno, null)))/count(a.hno) 匹配成功率1
    ,(count(if(a.head_state = '认领成功', a.hno, null)) + count(if(a.head_state = '认领成功-已失效', a.hno, null)) + count(if(a.head_state = '认领失败-已失效', a.hno, null)))/count(a.hno) 匹配成功率2
from
    (
        select
            ph.hno
            ,substr(ph.created_at, 1, 4) creat_month
            ,ph.pno
            ,case
                when ph.state = 0 then '未认领-待认领'
                when ph.state = 2 then '认领成功'
                when ph.state = 3 and ph.pno is null then '未认领-已失效'
                when ph.state = 3 and ph.pno is not null and ph.updated_at < coalesce(sx.claim_time,curdate()) then '认领成功-已失效'
                when ph.state = 3 and ph.pno is not null and ph.updated_at >= coalesce(sx.claim_time,curdate()) then '认领失败-已失效'
            end head_state
        from  fle_staging.parcel_headless ph
        left join
            (
                select
                    ph.pno
                    ,min(pct.created_at) claim_time
                from fle_staging.parcel_headless ph
                join bi_pro.parcel_claim_task pct on pct.pno = ph.pno
                where
                    ph.state = 3 -- 时效
                group by 1
            ) sx on sx.pno = ph.pno
        where
            ph.state < 4
            and ph.created_at < '2023-04-01'
    ) a
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
            *
        from
            (
                select
                    di.id
                    ,di.pno
                    ,pi.cod_amount
					,pi.state parcel_state
					,pi.client_id
                    ,row_number() over (partition by di.pno order by di.created_at asc) rn
                from fle_staging.diff_info di
                left join fle_staging.parcel_info pi on pi.pno = di.pno
                where
                    di.diff_marker_category = 28 -- 已妥投未交接
                    and pi.state = 6
            ) di
        where di.rn = 1;
;-- -. . -..- - / . -. - .-. -.--
with di as
(
    select
            *
        from
            (
                select
                    di.id
                    ,di.pno
                    ,pi.cod_amount
					,pi.state parcel_state
					,pi.client_id
                    ,row_number() over (partition by di.pno order by di.created_at asc) rn
                from fle_staging.diff_info di
                left join fle_staging.parcel_info pi on pi.pno = di.pno
                where
                    di.diff_marker_category = 28 -- 已妥投未交接
                    and pi.state = 6
            ) di
        where di.rn = 1
)
select
    di.pno '运单号 หมายเลขพัสดุ'
    ,'疑难件交接-已妥投未交接' '包裹状态 สถานะพัสดุ'
    ,convert_tz(sdt.created_at, '+00:00', '+07:00') '"上报时间 เวลาที่รายงานติดปัญหา"
'
    ,de.pickup_time '揽收时间 เวลาที่เข้ารับ'
    ,de.client_id '客户ID ID ลูกค้า'
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as '客户类型 ประเภทลูกค้า'
    ,de.last_store_name '目的地网点 สาขาปลายทาง'
    ,smp.name '目的地片区 Districtปลายทาง'
    ,smr.name '目的地大区 Areaปลายทาง'
    ,de.cod_enabled '是否cod เป็น COD ใช่หรือไม่'
    ,di.cod_amount/100 'cod 金额 ยอด COD'
    ,de.dst_routed_at '到仓时间 เวลาที่เข้าคลัง'
    ,datediff(curdate(), de.dst_routed_at) '在仓天数 จำนวนวันที่อยู่ในคลัง'
    ,scan.num '交接天数 จำนวนวันที่สแกนส่งมอบ'
    ,pk.num '盘库天数 จำนวนวันที่สแกนตรวจสอบ'
    ,gy.num '历史标记改约天数 จำนวนวันที่หมายเหตุเปลี่ยนแปลงเวลา'
    ,convert_tz(ljj.routed_at, '+00:00', '+07:00') '最后交接时间 เวลาที่สแกนส่งมอบล่าสุด'
    ,ljj.staff_info_id '最后交接员工 พนักงานที่สแกนส่งมอบล่าสุด'
    ,case
        when  hsi.`state`=1 and hsi.`wait_leave_state` =0 then '在职'
        when  hsi.`state`=1 and hsi.`wait_leave_state` =1 then '待离职'
        when hsi.`state` =2 then '离职'
        when hsi.`state` =3 then '停职'
    end as '最后交接员工是否在职 พนักงานที่สแกนส่งมอบล่าสุดยังเป็นพนักงานปัจจุบันอยู่ใช่หรือไม่'
    ,case de.last_marker_category
        when 1        then '客户不在家/电话无人接听'
        when 2        then '收件人拒收'
        when 3        then '快件分错网点'
        when 4        then '外包装破损'
        when 5        then '货物破损'
        when 6        then '货物短少'
        when 7        then '货物丢失'
        when 8        then '电话联系不上'
        when 9        then '客户改约时间'
        when 10        then '客户不在'
        when 11        then '客户取消任务'
        when 12        then '无人签收'
        when 13        then '客户周末或假期不收货'
        when 14        then '客户改约时间'
        when 15        then '当日运力不足，无法派送'
        when 16        then '联系不上收件人'
        when 17        then '收件人拒收'
        when 18        then '快件分错网点'
        when 19        then '外包装破损'
        when 20        then '货物破损'
        when 21        then '货物短少'
        when 22        then '货物丢失'
        when 23        then '收件人/地址不清晰或不正确'
        when 24        then '收件地址已废弃或不存在'
        when 25        then '收件人电话号码错误'
        when 26        then 'cod金额不正确'
        when 27        then '无实际包裹'
        when 28        then '已妥投未交接'
        when 29        then '收件人电话号码是空号'
        when 30        then '快件分错网点-地址正确'
        when 31        then '快件分错网点-地址错误'
        when 32        then '禁运品'
        when 33        then '严重破损（丢弃）'
        when 34        then '退件两次尝试派送失败'
        when 35        then '不能打开locker'
        when 36        then 'locker不能使用'
        when 37        then '该地址找不到lockerstation'
        when 39        then '多次尝试派件失败Multipleattemptstodeliverfailed'
        when 40        then '客户不在家/电话无人接听'
        when 41        then '错过班车时间'
        when 42        then '目的地是偏远地区,留仓待次日派送'
        when 43        then '目的地是岛屿,留仓待次日派送'
        when 44        then '企业/机构当天已下班'
        when 45        then '子母件包裹未全部到达网点'
        when 46        then '不可抗力原因留仓(台风)；目前只有在给客户回调时用到了这个原因项，后续如果复用请确定好场景'
        when 50        then '客户取消寄件'
        when 51        then '信息录入错误'
        when 52        then '客户取消寄件'
        when 69        then '禁运品'
        when 70        then '客户改约时间'
        when 71        then '当日运力不足,无法派送'
        when 72        then '客户周末或假期不收货'
        when 73        then '收件人/地址不清晰或不正确'
        when 74        then '收件地址已废弃或不存在'
        when 75        then '收件人电话号码错误'
        when 76        then 'cod金额不正确'
        when 77        then '企业/机构当天已下班'
        when 78        then '收件人电话号码是空号'
        when 79        then '快件分错网点-地址错误'
        when 80        then '客户取消任务'
        when 81        then '重复下单'
        when 82        then '已完成揽件'
        when 83        then '联系不上客户'
        when 84        then '包裹不符合揽收条件(超大件、违禁物品)'
        when 85        then '寄件人电话号码是空号'
        when 86        then '包裹不符合揽收条件超大件'
        when 87        then '包裹不符合揽收条件违禁品'
        when 88        then '寄件人地址为岛屿'
        when 90        then '包裹未准备好推迟揽收'
        when 91        then '包裹包装不符合运输标准'
        when 92        then '客户提供的清单里没有此包裹'
        when 93        then '包裹不符合揽收条件（超大件、违禁物品）'
        when 94        then '客户取消寄件/客户实际不想寄此包裹'
        when 95        then '车辆/人力短缺推迟揽收'
        when 96        then '遗漏揽收(已停用)'
        when 97        then '子母件(一个单号多个包裹)'
        when 98        then '地址错误addresserror'
        when 99        then '包裹不符合揽收条件：超大件'
        when 100        then '包裹不符合揽收条件：违禁品'
        when 101        then '包裹包装不符合运输标准'
        when 102        then '包裹未准备好'
        when 103        then '运力短缺，跟客户协商推迟揽收'
        when 104        then '子母件(一个单号多个包裹)'
        when 105        then '破损包裹'
        when 106        then '空包裹'
        when 107        then '不能打开locker(密码错误)'
        when 108        then 'locker不能使用'
        when 109        then 'locker找不到'
        when 110        then '运单号与实际包裹的单号不一致'
        when 111        then 'box客户取消任务'
        when 112        then '不能打开locker(密码错误)'
        when 113        then 'locker不能使用'
        when 114        then 'locker找不到'
        when 115        then '实际重量尺寸大于客户下单的重量尺寸'
        when 116        then '客户仓库关闭'
        when 117        then '客户仓库关闭'
        when 118        then 'SHOPEE订单系统自动关闭'
    end  as '最后派件标记原因 สาเหตุที่หมายเหตุพัสดุงานส่งวันนี้'
    ,convert_tz(lgy.created_at, '+00:00', '+07:00') '最后一次标记改约日期 วันที่เปลี่ยนแปลงเวลาครั้งสุดท้าย'
    ,convert_tz(lgy.desired_at, '+00:00', '+07:00') '最后一次标记改约到的日期 วันที่เปลี่ยนแปลงเวลาที่ต้องนำจัดส่ง'
    ,if(plt.updated_at > sdt.created_at , plt.updated_at, null) '定责时间 เวลาที่ตัดสิน'
    ,datediff(if(plt.updated_at > sdt.created_at , plt.updated_at, null), convert_tz(sdt.created_at, '+00:00', '+07:00')) '结案时长（天）ระยะเวลาในการจัดการหลังจากตัดสิน'
from  di
left join dwm.dwd_ex_th_parcel_details de on di.pno = de.pno
left join fle_staging.store_diff_ticket sdt on sdt.diff_info_id = di.id
left join fle_staging.ka_profile kp on di.client_id = kp.id
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = di.client_id
left join fle_staging.sys_store ss on de.last_store_id = ss.id
left join fle_staging.sys_manage_region smr on smr.id = ss.manage_region
left join fle_staging.sys_manage_piece smp on smp.id = ss.manage_piece
left join
    (
        select
            pr.store_id
            ,pr.pno
            ,count(distinct date(convert_tz(pr.routed_at, '+00:00', '+07:00'))) num
        from rot_pro.parcel_route pr
        join di on pr.pno = di.pno
        where
            pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        group by 1,2
    ) scan on scan.pno = de.pno and scan.store_id = de.last_store_id
left join
    (
        select
            pr.store_id
            ,pr.pno
            ,count(distinct date(convert_tz(pr.routed_at, '+00:00', '+07:00'))) num
        from rot_pro.parcel_route pr
        join di on di.pno = pr.pno
        where
            pr.route_action = 'INVENTORY'
        group by 1,2
    ) pk on pk.pno = de.pno and pk.store_id = de.last_store_id
left join
     (
        select
            td.store_id
            ,td.pno
            ,count(distinct date(convert_tz(tdm.created_at, '+00:00', '+07:00'))) num
        from fle_staging.ticket_delivery td
        left join fle_staging.ticket_delivery_marker tdm on tdm.delivery_id = td.id
        join di on td.pno = di.pno
        where
            tdm.marker_id in (9, 14, 70)
        group by 1,2
    ) gy on gy.pno = de.pno and gy.store_id = de.last_store_id
left join
    (
        select
            *
        from
            (
                select
                    pr.pno
                    ,pr.routed_at
                    ,pr.staff_info_id
                    ,pr.store_id
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
                from rot_pro.parcel_route pr
                join di on di.pno = pr.pno
                where
                    pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
            ) pr
        where pr.rn = 1
    ) ljj on ljj.pno = de.pno and ljj.store_id = de.last_store_id
left join bi_pro.hr_staff_info hsi on ljj.staff_info_id = hsi.staff_info_id
left join
    (
        select
            *
        from
            (
                select
                    td.pno
                    ,tdm.desired_at
                    ,tdm.created_at
                    ,row_number() over (partition by td.pno order by tdm.created_at desc ) rn
                 from fle_staging.ticket_delivery td
                left join fle_staging.ticket_delivery_marker tdm on tdm.delivery_id = td.id
                join di on di.pno = td.pno
                where
                    tdm.marker_id in (9, 14, 70)
            ) gy
        where gy.rn = 1
    ) lgy on lgy.pno = de.pno
left join bi_pro.parcel_lose_task plt on plt.pno = de.pno and plt.state = 6 and plt.duty_result = 1
where
     di.parcel_state = 6;