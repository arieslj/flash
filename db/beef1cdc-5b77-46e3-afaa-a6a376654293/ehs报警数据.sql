-- 正向
select
    t1.created_at `揽收时间`
    ,t1.pno
    ,ss.name `揽收网点`
    ,smr.name `揽收大区`
    ,smp.name  `揽收片区`
    ,t1.ticket_pickup_staff_info_id `揽收员工工号`
    ,si.name  `揽收员工`
    ,sa.id `始发hub_id`
    ,sa.name `始发hub`
    ,t2.store_id `末端网点id`
    ,t2.store_name `末端网点`
    ,t2.staff_info_id `派件员工id`
    ,t2.staff_name `派件员工`
    ,t2.last_hub_id `末端hubid`
    ,t2.last_hub_name `末端hub`
    ,t2.piece_name `末端片区`
    ,t2.region_nmae `末端大区`
    ,pho.routed_at `第一次打电话时间`
    ,sc.routed_at `第一次扫描派送时间`
from
    (
        select
            pi.created_at
            ,pi.pno
            ,pi.ticket_pickup_store_id
            ,pi.ticket_pickup_staff_info_id
        from fle_dwd.dwd_fle_parcel_info_di pi
        join test.tmp_th_pno_0310 t on t.pno = pi.pno
        where pi.p_date >= '2022-06-01'
          and pi.p_date < '2022-12-01'
    ) t1
left join
    (
        select
            *
        from fle_dim.dim_fle_sys_store_da ss
        where
            ss.p_date = date_sub(current_date(), 1)
    ) ss on ss.id = t1.ticket_pickup_store_id
left join
    (
        select
            *
        from fle_dim.dim_fle_sys_manage_piece_da smp
        where
            smp.p_date = date_sub(current_date(), 1)
    ) smp on smp.id = ss.manage_piece
left join
    (
        select
            *
        from fle_dim.dim_fle_sys_manage_region_da smr
        where
            smr.p_date = date_sub(current_date(), 1)
    ) smr on smr.id = ss.manage_region
left join
    (
        select
            *
        from fle_dim.dim_fle_staff_info_da si
        where
            si.p_date = date_sub(current_date(), 1)
    ) si on si.id = t1.ticket_pickup_staff_info_id
left join
    (
        select
            *
        from fle_dim.dim_fle_sys_store_da sa
        where
            sa.p_date = date_sub(current_date(), 1)
    ) sa on sa.id = if(ss.category in ('8','12'), ss.id, split_part(ss.ancestry,'/',1))
left join
    (
        select
            t.pno
            ,mark.staff_info_id
            ,si.name staff_name
            ,mark.store_id
            ,sa.name store_name
            ,smp.name piece_name
            ,smr.name region_nmae
            ,ssa.id last_hub_id
            ,ssa.name last_hub_name
        from test.tmp_th_pno_0310 t
        left join
            (
                select
                    mark.*
                from
                    (
                        select
                            pr.pno
                            ,pr.staff_info_id
                            ,pr.store_id
                            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rn
                        from fle_dwd.dwd_rot_parcel_route_di pr
                        join test.tmp_th_pno_0310 t on t.pno = pr.pno
                        where
                            pr.p_date >= '2022-06-01'
                            and pr.p_date < '2023-01-01'
                            and pr.route_action = 'DELIVERY_MARKER'
                    ) mark
                where
                    mark.rn = 1
            ) mark on mark.pno = t.pno
        left join
            (
                select
                    *
                from fle_dim.dim_fle_staff_info_da si
                where
                    si.p_date = date_sub(current_date(), 1)
            ) si on si.id = mark.staff_info_id
        left join
            (
                select
                    *
                from fle_dim.dim_fle_sys_store_da sa
                where
                    sa.p_date = date_sub(current_date(), 1)
            ) sa on sa.id = mark.store_id
        left join
            (
                select
                    *
                from fle_dim.dim_fle_sys_manage_piece_da smp
                where
                    smp.p_date = date_sub(current_date(), 1)
            ) smp on smp.id = sa.manage_piece
        left join
            (
                select
                    *
                from fle_dim.dim_fle_sys_manage_region_da smr
                where
                    smr.p_date = date_sub(current_date(), 1)
            ) smr on smr.id = sa.manage_region
        left join
            (
                select
                    *
                from fle_dim.dim_fle_sys_store_da sa
                where
                    sa.p_date = date_sub(current_date(), 1)
            ) ssa on ssa.id = if(sa.category in ('8','12'), sa.id, split_part(sa.ancestry,'/',1))
    ) t2 on t2.pno = t1.pno
left join
    (
        select
            pho.*
        from
            (
                select
                    pr.pno
                    ,pr.routed_at
                    ,row_number() over (partition by pr.pno order by pr.routed_at ) rn
                from fle_dwd.dwd_rot_parcel_route_di pr
                join test.tmp_th_pno_0310 t on pr.pno = t.pno
                where
                    pr.p_date >= '2022-06-01'
                    and pr.p_date < '2023-01-01'
                    and pr.route_action = 'PHONE'
            ) pho
        where
            pho.rn = 1
    ) pho on pho.pno = t1.pno
left join
    (
        select
            sc.*
        from
            (
                select
                    pr.pno
                    ,pr.routed_at
                    ,row_number() over (partition by pr.pno order by pr.routed_at ) rn
                from fle_dwd.dwd_rot_parcel_route_di pr
                join test.tmp_th_pno_0310 t on pr.pno = t.pno
                where
                    pr.p_date >= '2022-06-01'
                    and pr.p_date < '2023-01-01'
                    and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
            ) sc
        where
            sc.rn = 1
    ) sc on sc.pno = t1.pno
;

-- 逆向


select
    t1.created_at `揽收时间`
    ,t1.pno
    ,ss.name `揽收网点`
    ,smr.name `揽收大区`
    ,smp.name  `揽收片区`
    ,t1.ticket_pickup_staff_info_id `揽收员工工号`
    ,si.name  `揽收员工`
    ,sa.id `始发hub_id`
    ,sa.name `始发hub`
    ,sa2.id `末端网点id`
    ,sa.name `末端网点`
    ,t2.staff_info_id `派件员工id`
    ,t2.staff_name `派件员工`
    ,ssa2.id `末端hubid`
    ,ssa2.name `末端hub`
    ,smp2.name `末端片区`
    ,smr2.name `末端大区`
    ,pho.routed_at `第一次打电话时间`
    ,sc.routed_at `第一次扫描派送时间`
from
    (
        select
            pi.created_at
            ,pi.pno
            ,pi.ticket_pickup_store_id
            ,pi.ticket_pickup_staff_info_id
            ,pi.dst_store_id
        from fle_dwd.dwd_fle_parcel_info_di pi
        join test.tmp_th_pno_0310 t on t.return_pno = pi.pno
        where pi.p_date >= '2022-06-01'
          and pi.p_date < '2023-02-01'
    ) t1
left join
    (
        select
            *
        from fle_dim.dim_fle_sys_store_da ss
        where
            ss.p_date = date_sub(current_date(), 1)
    ) ss on ss.id = t1.ticket_pickup_store_id
left join
    (
        select
            *
        from fle_dim.dim_fle_sys_manage_piece_da smp
        where
            smp.p_date = date_sub(current_date(), 1)
    ) smp on smp.id = ss.manage_piece
left join
    (
        select
            *
        from fle_dim.dim_fle_sys_manage_region_da smr
        where
            smr.p_date = date_sub(current_date(), 1)
    ) smr on smr.id = ss.manage_region
left join
    (
        select
            *
        from fle_dim.dim_fle_staff_info_da si
        where
            si.p_date = date_sub(current_date(), 1)
    ) si on si.id = t1.ticket_pickup_staff_info_id
left join
    (
        select
            *
        from fle_dim.dim_fle_sys_store_da sa
        where
            sa.p_date = date_sub(current_date(), 1)
    ) sa on sa.id = if(ss.category in ('8','12'), ss.id, split_part(ss.ancestry,'/',1))
left join
    (
        select
            t.pno
            ,mark.staff_info_id
            ,si.name staff_name
            ,mark.store_id
            ,sa.name store_name
            ,smp.name piece_name
            ,smr.name region_nmae
            ,ssa.id last_hub_id
            ,ssa.name last_hub_name
        from test.tmp_th_pno_0310 t
        left join
            (
                select
                    mark.*
                from
                    (
                        select
                            pr.pno
                            ,pr.staff_info_id
                            ,pr.store_id
                            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rn
                        from fle_dwd.dwd_rot_parcel_route_di pr
                        join test.tmp_th_pno_0310 t on t.return_pno = pr.pno
                        where
                            pr.p_date >= '2022-06-01'
                            and pr.p_date < '2023-01-01'
                            and pr.route_action = 'DELIVERY_MARKER'
                    ) mark
                where
                    mark.rn = 1
            ) mark on mark.pno = t.return_pno
        left join
            (
                select
                    *
                from fle_dim.dim_fle_staff_info_da si
                where
                    si.p_date = date_sub(current_date(), 1)
            ) si on si.id = mark.staff_info_id
        left join
            (
                select
                    *
                from fle_dim.dim_fle_sys_store_da sa
                where
                    sa.p_date = date_sub(current_date(), 1)
            ) sa on sa.id = mark.store_id
        left join
            (
                select
                    *
                from fle_dim.dim_fle_sys_manage_piece_da smp
                where
                    smp.p_date = date_sub(current_date(), 1)
            ) smp on smp.id = sa.manage_piece
        left join
            (
                select
                    *
                from fle_dim.dim_fle_sys_manage_region_da smr
                where
                    smr.p_date = date_sub(current_date(), 1)
            ) smr on smr.id = sa.manage_region
        left join
            (
                select
                    *
                from fle_dim.dim_fle_sys_store_da sa
                where
                    sa.p_date = date_sub(current_date(), 1)
            ) ssa on ssa.id = if(sa.category in ('8','12'), sa.id, split_part(sa.ancestry,'/',1))
    ) t2 on t2.pno = t1.pno
left join
    (
        select
            pho.*
        from
            (
                select
                    pr.pno
                    ,pr.routed_at
                    ,row_number() over (partition by pr.pno order by pr.routed_at ) rn
                from fle_dwd.dwd_rot_parcel_route_di pr
                join test.tmp_th_pno_0310 t on pr.pno = t.return_pno
                where
                    pr.p_date >= '2022-06-01'
                    and pr.p_date < '2023-01-01'
                    and pr.route_action = 'PHONE'
            ) pho
        where
            pho.rn = 1
    ) pho on pho.pno = t1.pno
left join
    (
        select
            sc.*
        from
            (
                select
                    pr.pno
                    ,pr.routed_at
                    ,row_number() over (partition by pr.pno order by pr.routed_at ) rn
                from fle_dwd.dwd_rot_parcel_route_di pr
                join test.tmp_th_pno_0310 t on pr.pno = t.return_pno
                where
                    pr.p_date >= '2022-06-01'
                    and pr.p_date < '2023-01-01'
                    and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
            ) sc
        where
            sc.rn = 1
    ) sc on sc.pno = t1.pno
left join
    (
        select
            *
        from fle_dim.dim_fle_sys_store_da sa
        where
            sa.p_date = date_sub(current_date(), 1)
    ) sa2 on sa2.id = t1.dst_store_id
left join
    (
        select
            *
        from fle_dim.dim_fle_sys_manage_piece_da smp
        where
            smp.p_date = date_sub(current_date(), 1)
    ) smp2 on smp2.id = sa2.manage_piece
left join
    (
        select
            *
        from fle_dim.dim_fle_sys_manage_region_da smr
        where
            smr.p_date = date_sub(current_date(), 1)
    ) smr2 on smr2.id = sa2.manage_region
left join
    (
        select
            *
        from fle_dim.dim_fle_sys_store_da sa
        where
            sa.p_date = date_sub(current_date(), 1)
    ) ssa2 on ssa2.id = if(sa2.category in ('8','12'), sa2.id, split_part(sa2.ancestry,'/',1))
;

-- 标记问题件

select
    t.pno
    ,case cast(t.diff_marker_category as int)
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
    end as `标记问题件`
    ,pi.cod_num
from
    (
        select
            di.pno
            ,di.diff_marker_category
            ,row_number() over (partition by di.pno order by di.created_at desc ) rn
        from fle_dwd.dwd_fle_diff_info_di di
        join test.tmp_th_pno_0310 t on di.pno = t.pno
        where
            di.p_date >= '2022-06-01'
    ) t
left join
    (
        select
            pi.pno
            ,cast(pi.cod_amount as int)/100 cod_num
        from fle_dwd.dwd_fle_parcel_info_di pi
        join test.tmp_th_pno_0310 t on pi.pno = t.pno
        where
            pi.p_date >= '2022-06-01'
    ) pi on pi.pno = t.pno
where
    t.rn = 1
;
select
    t.return_pno
    ,td.id delivery_id
from fle_dwd.dwd_fle_ticket_delivery_di td
join test.tmp_th_pno_0310 t on td.pno = t.return_pno
where
    td.p_date >= '2022-06-01'
    and td.p_date < '2023-01-01'
;

select
    t.return_pno
    ,CASE pi.`state`
        when '1' then '已揽收'
         when '2' then '运输中'
         when '3' then '派送中'
         when '4' then '已滞留'
         when '5' then '已签收'
         when '6' then '疑难件处理中'
         when '7' then '已退件'
         when '8' then '异常关闭'
         when '9' then '已撤销'
         ELSE '其他'
     end  `包裹状态`
from fle_dwd.dwd_fle_parcel_info_di pi
join test.tmp_th_pno_0310 t on t.return_pno = pi.pno
where
    pi.p_date >= '2022-06-01'
;

select
    t.pno
    ,t.staff_info
    ,si.name
from
    (
        select
            t1.pno
            ,coalesce(t1.ticket_delivery_staff_info_id, t2.staff_info_id) staff_info
        from
            (
                 select
                    pi.pno
                    ,pi.ticket_delivery_staff_info_id
                from fle_dwd.dwd_fle_parcel_info_di pi
                join test.tmp_th_pno_0310 t on t.return_pno = pi.pno
                where
                    pi.p_date >= '2022-06-01'
                    and pi.p_date < '2023-01-01'
            ) t1
        left join
            (
                select
                    t1.*
                from
                    (
                        select
                            pr.pno
                            ,pr.staff_info_id
                            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rn
                        from fle_dwd.dwd_rot_parcel_route_di pr
                        join test.tmp_th_pno_0310 t on t.return_pno = pr.pno
                        where
                            pr.p_date >= '2022-06-01'
                            and pr.p_date < '2023-01-01'
                            and pr.route_action in ('DELIVERY_TICKET_CREATION_SCAN','DELIVERY_MARKER')
                    ) t1
                where
                    t1.rn = 1
            )t2 on t2.pno = t1.pno
    ) t
left join
    (
        select
            *
        from fle_dim.dim_fle_staff_info_da si
        where
            si.p_date = '2023-03-09'
    ) si on t.staff_info = si.id