select
    distinct
    prr.pno
    ,dp.store_name 上报网点
    ,dp.piece_name 上报片区
    ,dp.region_name 上报大区
    ,ss.name 揽收网点
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
    end 包裹状态
    ,ss2.name 最后有效路由网点
    ,if(vrv.id is not null, '是', '否') 是否进入IVR
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
    ,pi.returned_pno 退件单号
from ph_staging.parcel_reject_report_info prr
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = prr.store_id
left join ph_staging.parcel_info pi on pi.pno = upper(prr.pno)
left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
left join ph_bi.parcel_detail pd on pd.pno = pi.pno
left join ph_staging.sys_store ss2 on ss2.id = pd.last_valid_store_id
left join nl_production.violation_return_visit vrv on vrv.link_id = pi.pno and vrv.visit_staff_id in (10001,10000) and date_sub(vrv.created_at, interval 8 hour) > prr.created_at
where
    prr.created_at > '2024-01-12 16:00:00'
    and prr.created_at < '2024-01-29 16:00:00'