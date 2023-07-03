-- 疑难件
with p as
(
    select
        pi.pno
        ,pi.returned
        ,pi.client_id
        ,pi.created_at
        ,pi.agent_id
        ,pi.state
        ,pi.ticket_pickup_store_id
        ,pi.dst_store_id
    from fle_dwd.dwd_fle_parcel_info_di pi
    where
        pi.p_date >= '2023-01-01'
        and pi.p_date < '2023-02-01'
        and pi.state ='6'
),
ss as
(
    select
        ss.id
        ,ss.category
        ,ss.name
    from fle_dim.dim_fle_sys_store_da ss
    where
        ss.p_date = date_sub(`current_date`(), 1)
),
pr as
(
    select
        pr.pno
        ,pr.store_category
        ,pr.store_name
        ,pr.routed_at
        ,pr.store_id
        ,pr.route_action
    from fle_dwd.dwd_wide_fle_route_and_parcel_created_at pr
    where
        pr.p_date >= '2023-01-01'
        and pr.p_date < '2023-02-01'
        and pr.route_action in ('DELIVERY_PICKUP_STORE_SCAN','SHIPMENT_WAREHOUSE_SCAN','RECEIVE_WAREHOUSE_SCAN','DIFFICULTY_HANDOVER','ARRIVAL_GOODS_VAN_CHECK_SCAN','FLASH_HOME_SCAN','RECEIVED','SEAL','UNSEAL','REFUND_CONFIRM','ARRIVAL_WAREHOUSE_SCAN','DELIVERY_TRANSFER','DELIVERY_CONFIRM','STORE_KEEPER_UPDATE_WEIGHT','REPLACE_PNO','PICKUP_RETURN_RECEIPT','DETAIN_WAREHOUSE','DELIVERY_MARKER','DISTRIBUTION_INVENTORY','PARCEL_HEADLESS_PRINTED','STORE_SORTER_UPDATE_WEIGHT','SORTING_SCAN','DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE','DELIVERY_TICKET_CREATION_SCAN','INVENTORY','STAFF_INFO_UPDATE_WEIGHT','ACCEPT_PARCEL')
                and pr.organization_type='1'
),
di as
(
  select di.*
  from
  (
    select
      di.pno
      ,di.id
      ,di.diff_marker_category
      ,di.created_at
      ,row_number()over(partition by di.pno order by di.created_at desc) rn
    from fle_dwd.dwd_fle_diff_info_di di
    where di.p_date>='2023-01-01'
    and di.p_date<'2023-02-01'
  )di where di.rn=1
)


select
    pi.pno
    ,pi.created_at `揽收日期`
    ,`if`(pi.returned = '1', '退件', '正向') `包裹类型`
    ,pi.client_id `客户id`
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as `客户类型`
    ,datediff(`current_date`(), pi.created_at) `揽收至今天数`
    ,pr2.store_name `当前滞留网点`
    ,case pr2.store_category
      when '1' then 'SP'
      when '2' then 'DC'
      when '4' then 'SHOP'
      when '5' then 'SHOP'
      when '6' then 'FH'
      when '7' then 'SHOP'
      when '8' then 'Hub'
      when '9' then 'Onsite'
      when '10' then 'BDC'
      when '11' then 'fulfillment'
      when '12' then 'B-HUB'
      when '13' then 'CDC'
      when '14' then 'PDC'
    end `当前网点类型`
    ,case cast (di.diff_marker_category as int)
     when 1 then '客户不在家/电话无人接听'
     when 2 then '收件人拒收'
     when 3 then '快件分错网点'
     when 4 then '外包装破损'
     when 5 then '货物破损'
     when 6 then '货物短少'
     when 7 then '货物丢失'
     when 8 then '电话联系不上'
     when 9 then '客户改约时间'
     when 10 then '客户不在'
     when 11 then '客户取消任务'
     when 12 then '无人签收'
     when 13 then '客户周末或假期不收货'
     when 14 then '客户改约时间'
     when 15 then '当日运力不足，无法派送'
     when 16 then '联系不上收件人'
     when 17 then '收件人拒收'
     when 18 then '快件分错网点'
     when 19 then '外包装破损'
     when 20 then '货物破损'
     when 21 then '货物短少'
     when 22 then '货物丢失'
     when 23 then '收件人/地址不清晰或不正确'
     when 24 then '收件地址已废弃或不存在'
     when 25 then '收件人电话号码错误'
     when 26 then 'cod金额不正确'
     when 27 then '无实际包裹'
     when 28 then '已妥投未交接'
     when 29 then '收件人电话号码是空号'
     when 30 then '快件分错网点-地址正确'
     when 31 then '快件分错网点-地址错误'
     when 32 then '禁运品'
     when 33 then '严重破损（丢弃）'
     when 34 then '退件两次尝试派送失败'
     when 35 then '不能打开locker'
     when 36 then 'locker不能使用'
     when 37 then '该地址找不到lockerstation'
     when 38 then '一票多件'
     when 39 then '多次尝试派件失败'
     when 40 then '客户不在家/电话无人接听'
     when 41 then '错过班车时间'
     when 42 then '目的地是偏远地区,留仓待次日派送'
     when 43 then '目的地是岛屿,留仓待次日派送'
     when 44 then '企业/机构当天已下班'
     when 45 then '子母件包裹未全部到达网点'
     when 46 then '不可抗力原因留仓(台风)'
     when 47 then '虚假包裹'
     when 50 then '客户取消寄件'
     when 51 then '信息录入错误'
     when 52 then '客户取消寄件'
     when 69 then '禁运品'
     when 70 then '客户改约时间'
     when 71 then '当日运力不足，无法派送'
     when 72 then '客户周末或假期不收货'
     when 73 then '收件人/地址不清晰或不正确'
     when 74 then '收件地址已废弃或不存在'
     when 75 then '收件人电话号码错误'
     when 76 then 'cod金额不正确'
     when 77 then '企业/机构当天已下班'
     when 78 then '收件人电话号码是空号'
     when 79 then '快件分错网点-地址错误'
     when 80 then '客户取消任务'
     when 81 then '重复下单'
     when 82 then '已完成揽件'
     when 83 then '联系不上客户'
     when 84 then '包裹不符合揽收条件（超大件、违禁物品）'
     when 85 then '寄件人电话号码是空号'
     when 86 then '包裹不符合揽收条件超大件'
     when 87 then '包裹不符合揽收条件违禁品'
     when 88 then '寄件人地址为岛屿'
     when 89 then '运力短缺，跟客户协商推迟揽收'
     when 90 then '包裹未准备好推迟揽收'
     when 91 then '包裹包装不符合运输标准'
     when 92 then '客户提供的清单里没有此包裹'
     when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
     when 94 then '客户取消寄件/客户实际不想寄此包裹'
     when 95 then '车辆/人力短缺推迟揽收'
     when 96 then '遗漏揽收(已停用)'
     when 97 then '子母件(一个单号多个包裹)'
     when 98 then '地址错误addresserror'
     when 99 then '包裹不符合揽收条件：超大件'
     when 100 then '包裹不符合揽收条件：违禁品'
     when 101 then '包裹包装不符合运输标准'
     when 102 then '包裹未准备好'
     when 103 then '运力短缺，跟客户协商推迟揽收'
     when 104 then '子母件(一个单号多个包裹)'
     when 105 then '破损包裹'
     when 106 then '空包裹'
     when 107 then '不能打开locker(密码错误)'
     when 108 then 'locker不能使用'
     when 109 then 'locker找不到'
     when 110 then '运单号与实际包裹的单号不一致'
     when 111 then 'box客户取消任务'
     when 112 then '不能打开locker(密码错误)'
     when 113 then 'locker不能使用'
     when 114 then 'locker找不到'
     when 115 then '实际重量尺寸大于客户下单的重量尺寸'
     when 116 then '客户仓库关闭'
     when 117 then '客户仓库关闭'
     when 118 then 'SHOPEE订单系统自动关闭'
     when 119 then '客户取消包裹'
     when 121 then '地址错误'
     when 122 then '当日运力不足，无法揽收'
     end as '疑难原因'
    ,datediff(current_date(),di.created_at) 问题件处理天数
    ,cgk.cgi `kamvip客服组`
    ,case cast(cdt.state as int)
     when 0 then '客服未处理'
     when 1 then '已处理完毕'
     when 2 then '正在沟通中'
     when 3 then '财务驳回'
     when 4 then '客户未处理'
     when 5 then '转交闪速系统'
     when 6 then '转交QAQC'
     end as 处理状态
     ,datediff(current_date(),cdt.updated_at) 当前状态至今天数
     ,case cast(sdt.pending_handle_category as int)
      when 1 then '待揽收网点协商'
      when 2 then '待KAM问题件处理'
      when 3 then '待QAQC判责'
      when 4 then '待客户决定'
      end 待处理人
     ,ss1.name 问题件待处理网点
     ,case ss1.category
      when '1' then 'SP'
      when '2' then 'DC'
      when '4' then 'SHOP'
      when '5' then 'SHOP'
      when '6' then 'FH'
      when '7' then 'SHOP'
      when '8' then 'Hub'
      when '9' then 'Onsite'
      when '10' then 'BDC'
      when '11' then 'fulfillment'
      when '12' then 'B-HUB'
      when '13' then 'CDC'
      when '14' then 'PDC'
      end as 待处理网点类型
    ,case
        when sdt.pending_handle_category='1' and pr2.store_category in ('8','12') then 'HUB'
        when sdt.pending_handle_category='1' and pr2.store_category in ('4','5','7') then 'SHOP'
        when sdt.pending_handle_category='1' and pr2.store_category in ('1','9','10','13','14') then 'NW'
        when sdt.pending_handle_category='1' and pr2.store_category in ('6') then 'FH'
        when sdt.pending_handle_category='1' and pr2.store_category in ('11') then 'FFM'
        when sdt.pending_handle_category='2' then cgk.cgi
        when sdt.pending_handle_category='3' and di.diff_marker_category='28' then 'CS'
        when sdt.pending_handle_category='3' and di.diff_marker_category='20' then 'QAQC'
        when sdt.pending_handle_category='4' then 'Retail'
    end `待处理部门`
from p pi
left join
    (
        select
            kp.id
            ,kp.name
        from fle_dim.dim_fle_ka_profile_da kp
        where
            kp.p_date = date_sub(`current_date`(), 1)
    )  kp  on kp.id = pi.client_id
left join
    (
        select
            bc.client_id
            ,bc.client_name
        from fle_dim.dim_dwm_big_clients_id_detail_da bc
        where
            bc.p_date = date_sub(`current_date`(), 1)
    ) bc on bc.client_id = pi.client_id
left join
    (
       /* select
            a.*
            ,b.routed_at store_arr_time
        from
            (*/
                select
                    pr1.*
                from
                    (
                        select
                            pr1.pno
                            ,pr1.store_name
                            ,pr1.store_id
                            ,pr1.store_category
                            ,pr1.route_action
                            ,pr1.routed_at
                            ,row_number() over (partition by pr1.pno order by pr1.routed_at desc ) rk
                        from pr pr1
                        join p p1 on pr1.pno = p1.pno
                    ) pr1
                where
                    pr1.rk = 1
        /*    ) a
        join
            (
                select
                    pr1.pno
                    ,pr1.store_name
                    ,pr1.store_id
                    ,pr1.store_category
                    ,pr1.route_action
                    ,pr1.routed_at
                    ,row_number() over (partition by pr1.pno,pr1.store_id order by pr1.routed_at ) rk
                from pr pr1
                join p p1 on pr1.pno = p1.pno
            ) b on a.pno = b.pno and a.store_id = b.store_id and b.rk = 1*/
    ) pr2 on pr2.pno = pi.pno
left join ss s1 on s1.id = pi.ticket_pickup_store_id
left join ss s2 on s2.id = pi.dst_store_id
left join di on pi.pno=di.pno
left join
(
  select
    cdt.diff_info_id
    ,cdt.state
    ,cdt.updated_at
  from fle_dwd.dwd_fle_customer_diff_ticket_di cdt
  where cdt.p_date>='2023-01-01'
)cdt on cdt.diff_info_id=di.id
left join
(
  select
    sdt.diff_info_id
    ,sdt.pending_handle_category
  from fle_dwd.dwd_fle_store_diff_ticket_di sdt
  where sdt.p_date>='2023-01-01'
)sdt on sdt.diff_info_id=di.id
left join
    (
        select
            cgk.ka_id
            ,case cgk.customer_group_id
            when '6335094827fa4a000728c862' then 'Team BD (Retail Management) Team B'
            when '5ebb8d10374d4f186461c17a' then '์Non-Shipment Thai customer'
            when '5e99c45f8b976a1e1d7d992f' then 'LAZADA'
            when '5cdd5ffcca86ca03b6c60db5' then 'KAM CN'
            when '5c77b2efca86ca58ab45ecbe' then 'FFM'
            when '5dd64b62a0abec422328f2ed' then 'Test Requirement No.3967'
            when '5dc90de5a0abec56702c3ce2' then 'KAM Chinese'
            when '5d3ab3efca86ca4d62134ad6' then 'CTT'
            when '5e44b3288b976a2afb6df05a' then 'KAM Team B'
            when '60b5f7ef4cd0ab0007c22a84' then 'Bulky Project'
            when '5e44b235a0abec725950c140' then 'KAM Team A'
            when '5c77b2a8ca86ca58ab45ea3d' then 'THAI KAM'
            when '632bd544a205600007dc687d' then 'Bulky BD'
            when '5d440a07ca86ca78586a9240' then 'kam testing'
            when '5c77b436ca86ca58ab45f583' then 'ALL '
            when '631b1f43392d5e00078d0e91' then 'Retail Management '
            when '62c5343748647000070736e0' then 'TikTok'
            when '5e44ae8f8b976a2afb6deda8' then 'Shopee'
            when '631ca3e56d6c470007e9cdab' then 'Team BD (Retail Management) Team A'
        end `cgi`
        from fle_dim.dim_fle_customer_group_ka_relation_da cgk
        where
            cgk.p_date = date_sub(`current_date`(), 1)
            and cgk.deleted = '0'
    ) cgk on cgk.ka_id = pi.client_id