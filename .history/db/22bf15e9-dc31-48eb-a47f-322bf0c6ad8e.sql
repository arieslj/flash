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
select
    t.pno
    ,pi.returned
    ,pi2.cod_amount/100 cod金额
from fle_staging.parcel_info pi
join tmpale.tmp_th_pno_2023_03_14 t on t.pno = pi.pno
left join fle_staging.parcel_info pi2 on if(pi.returned = 1, pi.customary_pno, pi.pno) = pi2.pno;