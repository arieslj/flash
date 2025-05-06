

select
    t.pno
    ,t.client_id '客户ID Client ID'
    ,t.pick_at  '揽收时间 Pick up time'
    ,t.cod 'COD金额 COD'
    ,t.weight '重量 Weight'
    ,t.size '尺寸 Size'
    ,seal.pack_pno 集包号
    ,convert_tz(seal.routed_at, '+00:00', '+08:00') 集包时间
    ,seal.staff_info_id 集包人
    ,pi.src_name 卖家名称
    ,pi.src_phone 卖家电话
    ,pi.dst_name 收件人名称
    ,pi.dst_phone 收件人电话
    ,ss.name 目的地网点
    ,ship.proof_id 出车凭证
    ,ft.proof_at 打印出车凭证时间
    ,ft.line_name 线路名称
    ,case
        when ft.line_mode=1 then '常规车'
        when ft.line_mode=2 then '加班车'
        when ft.line_mode=3 then '虚拟车线'
        when ft.line_mode=4 then '常规车'
    end 线路属性
    ,case ft.transport_mode_category
        when 1 then '陆运'
        when 2 then '空运'
        when 3 then '海运'
    end 运输方式
    ,case fvl.belong_ccd
        when 1 then 'LUZON'
        when 2 then 'MINDANAO'
        when 3 then 'VISAYAS'
    end 所属ccd
    ,case fvl.line_sort
        when 1 then 'MINI HUB'
        when 2 then 'DIRECT INJECTION'
    end 类别
    ,case ft.fleet_status
        when 1 then '已完成'
        when 0 then '未完成'
    end 线路状态
    ,case fvl.region
        when 1 then 'GMA'
        when 2 then 'LUZON1'
        when 3 then 'LUZON2'
        when 4 then 'LUZON3'
        when 5 then 'LUZON4'
        when 6 then 'MIN1'
        when 7 then 'MIN2'
        when 8 then 'VIS1'
        when 9 then 'VIS2'
        when 10 then 'VIS3'
    end 区域
    ,sp.name 省份
    ,case ft.line_plate_type
            when 100 then '4W'
            when 101 then '4WJ'
            when 102 then 'PH4WFB'
            when 200 then '6W5.5'
            when 201 then '6W6.5'
            when 203 then '6W7.2'
            when 204 then 'PH6W'
            when 205 then 'PH6WF'
            when 210 then '6W8.8'
            when 300 then '10W'
            when 400 then '14W'
    end 车型
    ,ft.proof_plate_number '供应商/车牌号'
    ,ft.proof_driver 司机
    ,ft.proof_driver_phone 司机电话
    ,ft.store_name 发车网点
    ,case ft.leave_type
        when 2 then '始发出发考勤'
        when 4 then '经停出发考勤'
    end 考勤类型
    ,case
	   	  when ft.`plan_leave_time`>= ft.`real_leave_time`  then '准时'
	   	  when ft.`plan_leave_time`<  ft.`real_leave_time`  then '晚于计划'
	end 考勤状态
    ,ft.plan_leave_time 计划发车时间
    ,ft.real_leave_time 车辆出港实际时间
    ,ft.next_store_name 下一站
    ,case
        when ft.arrive_type=1 then '始发到港考勤'
        when ft.arrive_type=3 then '经停到达考勤'
        when ft.arrive_type=5 then '目的地到达考勤'
    end 到车考勤类型
    ,case
	   	  WHEN ft.`plan_arrive_time`>=ft.`real_arrive_time` THEN '准时'
	   	  WHEN ft.`plan_arrive_time`< ft.`real_arrive_time` THEN '晚于计划'
	END 考勤状态
    ,ft.plan_arrive_time 计划到达时间
    ,ft.real_arrive_time 车辆入港实际时间
    ,ft.real_arrive_time KIT签到时间
    ,ft.sign_time Fleet签到时间
    ,case ft.sign_state
        when 0 then '正常'
        when 1 then '迟到'
        when 2 then '位置异常'
    end Fleet签到状态
    ,ft.offset_distance '偏移距离（KM）'
    ,concat('http://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/', ft.arrival_img_object_key) '实际到达照片'
    ,concat('http://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/', ft.sealing_img_object_key) 封车照片
    ,ft.pack_count 装载集包数
    ,ft.parcel_count 装载包裹数
from ph_staging.parcel_info pi
join tmpale.tmp_ph_pno_lj_0307 t on t.pno = pi.pno
left join
     (
        select
            pr.pno
            ,pr.staff_info_id
            ,pr.routed_at
            ,json_extract(pr.extra_value, '$."packPno"') pack_pno
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_lj_0307 t1 on t1.pno = pr.pno
        where
            pr.routed_at > date_sub(curdate(), interval 3 month )
            and pr.route_action = 'SEAL'
    ) seal on seal.pno = pi.pno and seal.rk = 1
left join
    (
        select
            pr.pno
            ,json_extract(pr.extra_value, '$."proofId"') proof_id
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_lj_0307 t1 on t1.pno = pr.pno
        where
            pr.routed_at > date_sub(curdate(), interval 3 month )
            and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
    ) ship on ship.pno = pi.pno and ship.rk = 1
left join ph_bi.fleet_time ft on ft.proof_id = ship.proof_id and ft.leave_type = 2 and ft.store_id = 'PH61182U01'
left join ph_staging.fleet_van_line fvl on fvl.id = ft.line_id
left join ph_staging.sys_store ss on ss.id = pi.dst_store_id
left join ph_staging.sys_province sp on sp.code = fvl.province_code