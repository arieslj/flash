with t as
    (
        select
            acc.pno
            ,am.staff_info_id
            ,acc.complaints_sub_type
            ,date(convert_tz(pi.finished_at, '+00:00', '+08:00')) fin_date
            ,pi.cod_amount
            ,pi.cod_enabled
            ,pi.dst_store_id
            ,acc.qaqc_callback_result
        from ph_bi.abnormal_customer_complaint acc
        left join ph_bi.abnormal_message am on am.id = acc.abnormal_message_id
        left join ph_staging.parcel_info pi on pi.pno = acc.pno and pi.created_at > date_sub(curdate(), interval 40 day)
        where
            acc.complaints_type = 1 -- 虚假妥投
            and acc.created_at >= curdate()
            and acc.created_at < date_add(curdate(), interval 1 day)
        group by 1,2,3,4,5,6,7,8
    )
select
    t1.staff_info_id 工号
    ,dp.store_name 网点
    ,dp.region_name 大区
    ,case
        when hsa.staff_info_id is null and hsi.formal = 1 then '自有'
        when hsa.staff_info_id is not null and hsi.formal = 1 then '支援'
        when hsi.formal = 0 and hsi.hire_type = 11 then '外协'
        when hsi.formal = 0 and hsi.hire_type = 12 then '众包'
    end 快递员分类
    ,if(mw.created_at is not null, '有', '无')  是否收到过警告信
    ,mw.created_at 最近一封警告信日期
    ,if(hsa.staff_info_id is not null, '是', '否') 是否在支援时虚假妥投
    ,hsa.store_name  支援网点
    ,hsa.region_name 支援大区
    ,t1.pno 运单号
    ,if(t1.cod_enabled = 1, '是', '否') 是否COD包裹
    ,case t1.complaints_sub_type
        when 1 then '业务不熟练'
        when 2 then '虚假签收'
        when 3 then '以不礼貌的态度对待客户'
        when 4 then '揽/派件动作慢'
        when 5 then '未经客户同意投递他处'
        when 6 then '未经客户同意改约时间'
        when 7 then '不接客户电话'
        when 8 then '包裹丢失 没有数据'
        when 9 then '改约的时间和客户沟通的时间不一致'
        when 10 then '未提前电话联系客户'
        when 11 then '包裹破损 没有数据'
        when 12 then '未按照改约时间派件'
        when 13 then '未按订单带包装'
        when 14 then '不找零钱'
        when 15 then '客户通话记录内未看到员工电话'
        when 16 then '未经客户允许取消揽件任务'
        when 17 then '未给客户回执'
        when 18 then '拨打电话时间太短，客户来不及接电话'
        when 19 then '未经客户允许退件'
        when 20 then '没有上门'
        when 21 then '其他'
        when 22 then '未经客户同意改约揽件时间'
        when 23 then '改约的揽件时间和客户要求的时间不一致'
        when 24 then '没有按照改约时间揽件'
        when 25 then '揽件前未提前联系客户'
        when 26 then '答应客户揽件，但最终没有揽'
        when 27 then '很晚才打电话联系客户'
        when 28 then '货物多/体积大，因骑摩托而拒绝上门揽收'
        when 29 then '因为超过当日截单时间，要求客户取消'
        when 30 then '声称不是自己负责的区域，要求客户取消'
        when 31 then '拨打电话时间太短，客户来不及接电话'
        when 32 then '不接听客户回复的电话'
        when 33 then '答应客户今天上门，但最终没有揽收'
        when 34 then '没有上门揽件，也没有打电话联系客户'
        when 35 then '货物不属于超大件/违禁品'
        when 36 then '没有收到包裹，且快递员没有联系客户'
        when 37 then '快递员拒绝上门派送'
        when 38 then '快递员擅自将包裹放在门口或他处'
        when 39 then '快递员没有按约定的时间派送'
        when 40 then '代替客户签收包裹'
        when 41 then '快说话不礼貌/没有礼貌/不愿意服务'
        when 42 then '说话不礼貌/没有礼貌/不愿意服务'
        when 43 then '快递员抛包裹'
        when 44 then '报复/骚扰客户'
        when 45 then '快递员收错COD金额'
        when 46 then '虚假妥投'
        when 47 then '派件虚假留仓件/问题件'
        when 48 then '虚假揽件改约时间/取消揽件任务'
        when 49 then '抛客户包裹'
        when 50 then '录入客户信息不正确'
        when 51 then '送货前未电话联系'
        when 52 then '未在约定时间上门'
        when 53 then '上门前不电话联系'
        when 54 then '以不礼貌的态度对待客户'
        when 55 then '录入客户信息不正确'
        when 56 then '与客户发生肢体接触'
        when 57 then '辱骂客户'
        when 58 then '威胁客户'
        when 59 then '上门揽件慢'
        when 60 then '快递员拒绝上门揽件'
        when 61 then '未经客户同意标记收件人拒收'
        when 62 then '未按照系统地址送货导致收件人拒收'
        when 63 then '情况不属实，快递员虚假标记'
        when 64 then '情况不属实，快递员诱导客户改约时间'
        when 65 then '包裹长时间未派送'
        when 66 then '未经同意拒收包裹'
        when 67 then '已交费仍索要COD'
        when 68 then '投递时要求开箱'
        when 69 then '不当场扫描揽收'
        when 70 then '揽派件速度慢'
    end as '虚假类型'
    ,case t1.qaqc_callback_result
        when 0 then '待回访'
        when 1 then '多次未联系上客户'
        when 2 then '误投诉'
        when 3 then '真实投诉，后接受道歉'
        when 4 then '真实投诉，后不接受道歉'
        when 5 then '真实投诉，后受到骚扰/威胁'
        when 6 then '没有快递员联系客户道歉'
        when 7 then '客户投诉回访结果'
        when 8 then '确认网点已联系客户道歉'
        when 20 then '联系不上'
    end '回访结果'
    ,t1.fin_date 违规日期
    ,today.pno_count 当天虚假妥投件数
    ,7st.pno_count 近7天虚假妥投件数
    ,30st.pno_count 近30天虚假妥投件数
    ,if(hsi.stop_duties_count > 0, '是', '否') 是否停过职
    ,if(30st.pno_count > 0, '是', '否') 是否近1个月被投诉过
    ,if(a1.pno is not null, '是', '否') 是否高价值
    ,if(at1.staff_info_id is not null and at2.staff_info_id is not null and hsi.state = 1, '是', '否') 是否连续旷工两天未被停职
from t t1
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = t1.staff_info_id
left join  dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
left join
    (
        select
            mw.created_at
            ,mw.staff_info_id
            ,row_number() over (partition by t1.staff_info_id order by mw.created_at desc) rk
        from ph_backyard.message_warning mw
        join t t1 on t1.staff_info_id = mw.staff_info_id
        where
            mw.is_delete = 0
    ) mw on mw.staff_info_id = t1.staff_info_id and mw.rk = 1 and mw.rk = 1
left join
    (
        select
            hsa.store_name
            ,dp.region_name
            ,hsa.staff_info_id
        from ph_backyard.hr_staff_apply_support_store hsa
        join t t1 on t1.staff_info_id = hsa.staff_info_id
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsa.store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
        where
            hsa.created_at >= date_sub(curdate(), interval 60 day)
            and hsa.employment_begin_date <= t1.fin_date
            and hsa.employment_end_date >= t1.fin_date
            and hsa.status = 2
    ) hsa on hsa.staff_info_id = t1.staff_info_id
left join
    (
        select
            am.staff_info_id
            ,count(distinct acc.pno) pno_count
        from ph_bi.abnormal_customer_complaint acc
        left join ph_bi.abnormal_message am on am.id = acc.abnormal_message_id
        where
            acc.created_at >= curdate()
            and acc.created_at < date_add(curdate(), interval 1 day)
            and acc.complaints_type = 1 -- 虚假妥投
        group by 1
    ) today on today.staff_info_id = t1.staff_info_id
left join
    (
        select
            am.staff_info_id
            ,count(distinct acc.pno) pno_count
        from ph_bi.abnormal_customer_complaint acc
        left join ph_bi.abnormal_message am on am.id = acc.abnormal_message_id
        where
            acc.created_at >= date_sub(curdate(), interval 6 day)
            and acc.created_at < date_add(curdate(), interval 1 day)
            and acc.complaints_type = 1 -- 虚假妥投
        group by 1
    ) 7st on 7st.staff_info_id = t1.staff_info_id
left join
    (
        select
            am.staff_info_id
            ,count(distinct acc.pno) pno_count
        from ph_bi.abnormal_customer_complaint acc
        left join ph_bi.abnormal_message am on am.id = acc.abnormal_message_id
        where
            acc.created_at >= date_sub(curdate(), interval 29 day)
            and acc.created_at < date_add(curdate(), interval 1 day)
            and acc.complaints_type = 1 -- 虚假妥投
        group by 1
    ) 30st on 30st.staff_info_id = t1.staff_info_id
left join
    (
        select
            t1.pno
        from t t1
        left join ph_staging.parcel_info pi on t1.pno = pi.pno
        left join ph_staging.order_info oi on oi.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
        left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
        where
            pi.created_at >= date_sub(curdate(), interval 60 day)
            and coalesce(if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100), pi.cod_amount/100) > 5000
        group by 1
    ) a1 on a1.pno = t1.pno
left join
    (
        select
            ad.staff_info_id
        from ph_bi.attendance_data_v2 ad
        join t t1 on t1.staff_info_id = ad.staff_info_id
        where
            ad.stat_date <= t1.fin_date
            and ad.stat_date >= date_sub(t1.fin_date, interval 1 day )
            and ad.attendance_time + ad.BT + ad.BT_Y + ad.AB > 0
            and ad.attendance_started_at is null
            and ad.attendance_end_at is null
        group by 1
    ) at1 on at1.staff_info_id = t1.staff_info_id
left join
    (
        select
            ad.staff_info_id
        from ph_bi.attendance_data_v2 ad
        join t t1 on t1.staff_info_id = ad.staff_info_id
        where
            ad.stat_date <= date_sub(t1.fin_date, interval 1 day )
            and ad.stat_date >= date_sub(t1.fin_date, interval 2 day )
            and ad.attendance_time + ad.BT + ad.BT_Y + ad.AB > 0
            and ad.attendance_started_at is null
            and ad.attendance_end_at is null
        group by 1
    ) at2 on at2.staff_info_id = t1.staff_info_id

;

with t as
    (
        select
            acc.pno
            ,am.staff_info_id
            ,acc.complaints_sub_type
            ,date(convert_tz(pi.finished_at, '+00:00', '+08:00')) fin_date
        from ph_bi.abnormal_customer_complaint acc
        left join ph_bi.abnormal_message am on am.id = acc.abnormal_message_id
        left join ph_staging.parcel_info pi on pi.pno = acc.pno
        where
            acc.created_at >= date_sub(curdate(), interval 29 day)
            and acc.complaints_type = 1 -- 虚假妥投
    )
select
    a1.网点
    ,a1.大区
    ,a1.网点自有员工违规人数
    ,a1.前往支援违规人数
    ,a1.虚假件数
    ,7st.pno_count 近7天虚假妥投件数
    ,30st.pno_count 近30天虚假妥投件数
from
    (
                select
            dp.store_id
            ,dp.store_name 网点
            ,dp.region_name 大区
            ,count(distinct if(hsa.staff_info_id is null, t1.staff_info_id, null)) 网点自有员工违规人数
            ,count(distinct if(hsa.staff_info_id is not null, t1.staff_info_id, null)) 前往支援违规人数
            ,count(distinct t1.pno) 虚假件数
        #     ,7st.pno_count 近7天虚假妥投件数
        #     ,30st.pno_count 近30天虚假妥投件数
        from t t1
        left join
            (
                select
                    hsa.store_name
                    ,dp.region_name
                    ,hsa.staff_info_id
                    ,t1.fin_date
                from ph_backyard.hr_staff_apply_support_store hsa
                join t t1 on t1.staff_info_id = hsa.staff_info_id
                left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsa.store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
                where
                    hsa.created_at >= date_sub(curdate(), interval 60 day)
                    and hsa.employment_begin_date <= t1.fin_date
                    and hsa.employment_end_date >= t1.fin_date
                    and hsa.status = 2
            ) hsa  on hsa.staff_info_id = t1.staff_info_id and hsa.fin_date = t1.fin_date
        left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = t1.staff_info_id
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
        group by 1,2
    ) a1
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct acc.pno) pno_count
        from ph_bi.abnormal_customer_complaint acc
        left join ph_bi.abnormal_message am on am.id = acc.abnormal_message_id
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = am.staff_info_id
        where
            acc.created_at >= date_sub(curdate(), interval 6 day)
            and acc.created_at < date_add(curdate(), interval 1 day)
            and acc.complaints_type = 1 -- 虚假妥投
        group by 1
    ) 7st on 7st.sys_store_id = a1.store_id
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct acc.pno) pno_count
        from ph_bi.abnormal_customer_complaint acc
        left join ph_bi.abnormal_message am on am.id = acc.abnormal_message_id
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = am.staff_info_id
        where
            acc.created_at >= date_sub(curdate(), interval 29 day)
            and acc.created_at < date_add(curdate(), interval 1 day)
            and acc.complaints_type = 1 -- 虚假妥投
        group by 1
    ) 30st on 30st.sys_store_id = a1.store_id
