select
    pi.pno
    ,pi.ticket_delivery_staff_info_id 妥投员工
    ,pi.ticket_delivery_store_id 妥投网点ID
    ,ss.name 妥投网点
    ,st_distance_sphere(point(pi.ticket_delivery_staff_lng, pi.ticket_delivery_staff_lat), point(ss.lng, ss.lat)) 妥投距离网点距离
    ,if(pr.pno is null, '否', '是') 是否妥投后盘库
    ,convert_tz(pi.finished_at, '+00:00', '+07:00') 妥投时间
    ,if(hsi.is_sub_staff = 1, '是', '否') 妥投员工是否子账号（外协）
from fle_staging.parcel_info pi
join tmpale.tmp_th_pno_0328 t on t.pno = pi.pno
left join fle_staging.sys_store ss on ss.id = pi.ticket_delivery_store_id
left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = pi.ticket_delivery_staff_info_id
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
    ) pr on pr.pno = t.pno

;

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
    ) b on b.name = a.name
;





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
     di.parcel_state = 6 -- 疑难件处理中