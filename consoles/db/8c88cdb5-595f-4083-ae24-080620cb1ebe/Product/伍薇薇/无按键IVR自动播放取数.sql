select
    vrv.link_id
    ,case pi.article_category
         when 0 then '文件'
         when 1 then '干燥食品'
         when 2 then '日用品'
         when 3 then '数码产品'
         when 4 then '衣物'
         when 5 then '书刊'
         when 6 then '汽车配件'
         when 7 then '鞋包'
         when 8 then '体育器材'
         when 9 then '化妆品'
         when 10 then '家居用具'
         when 11 then '水果'
         when 99 then '其它'
    end as '物品类型'
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as 客户类型
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
left join fle_staging.parcel_info pi on pi.pno = vrv.link_id
left join fle_staging.ka_profile kp on kp.id = vrv.client_id
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = vrv.client_id
where
    vrv.type = 2 -- 疑似虚假妥投
    and vrv.updated_at > '2024-05-01'
    and vrv.updated_at < '2024-05-12'
    and vrv.visit_staff_id = 10001
