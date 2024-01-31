select
    pi.pno
from ph_staging.parcel_info pi
left join ph_staging.parcel_additional_info pai on pai.pno = pi.pno
left join ph_bi.parcel_detail pd on pd.pno = pi.pno
join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.store_id != 'PH19040F05'
where
    pi.state = 8
    and pai.parcel_miss_enabled = 0
    and pd.last_valid_store_id != 'PH19040F05'
    and pi.client_id not in ('512654','457804','602210','770621','457302')
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            pi.pno
            ,max(pr.routed_at) route_time
        from ph_staging.parcel_info pi
        left join ph_staging.parcel_additional_info pai on pai.pno = pi.pno
        left join ph_bi.parcel_detail pd on pd.pno = pi.pno
        join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.store_id != 'PH19040F05'
        where
            pi.state = 8
            and pai.parcel_miss_enabled = 0
            and pd.last_valid_store_id != 'PH19040F05'
            and pi.client_id not in ('512654','457804','602210','770621','457302')
        group by 1
    )
select
    t1.pno
    ,pc.operator_id
from t t1
left join
    (
        select
            plt.pno
            ,pcol.created_at
            ,pcol.operator_id
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        left join ph_bi.parcel_cs_operation_log pcol on pcol.task_id = plt.id
        where
            pcol.action = 3
    ) pc on pc.pno = t1.pno and t1.route_time < date_sub(pc.created_at, interval 8 hour);
;-- -. . -..- - / . -. - .-. -.--
select
            pi.pno
            ,max(pr.routed_at) route_time
        from ph_staging.parcel_info pi
        left join ph_staging.parcel_additional_info pai on pai.pno = pi.pno
        left join ph_bi.parcel_detail pd on pd.pno = pi.pno
        join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.store_id != 'PH19040F05'
        where
            pi.state = 8
            and pai.parcel_miss_enabled = 0
            and pd.last_valid_store_id != 'PH19040F05'
            and pi.client_id not in ('512654','457804','602210','770621','457302')
            and pi.pno = 'P21112ZFEB5AG'
        group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
            pi.pno
            ,max(pr.routed_at) route_time
        from ph_staging.parcel_info pi
        left join ph_staging.parcel_additional_info pai on pai.pno = pi.pno
        left join ph_bi.parcel_detail pd on pd.pno = pi.pno
        join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.store_id != 'PH19040F05' and pr.route_action = 'CHANGE_PARCEL_CLOSE'
        where
            pi.state = 8
            and pai.parcel_miss_enabled = 0
            and pd.last_valid_store_id != 'PH19040F05'
            and pi.client_id not in ('512654','457804','602210','770621','457302')
            and pi.pno = 'P21112ZFEB5AG'
        group by 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            pi.pno
            ,max(pr.routed_at) route_time
        from ph_staging.parcel_info pi
        left join ph_staging.parcel_additional_info pai on pai.pno = pi.pno
        left join ph_bi.parcel_detail pd on pd.pno = pi.pno
        join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.store_id != 'PH19040F05' and pr.route_action = 'CHANGE_PARCEL_CLOSE'
        where
            pi.state = 8
            and pai.parcel_miss_enabled = 0
            and pd.last_valid_store_id != 'PH19040F05'
            and pi.client_id not in ('512654','457804','602210','770621','457302')
            -- and pi.pno = 'P21112ZFEB5AG'
        group by 1
    )
select
    t1.pno
    ,pc.operator_id
from t t1
left join
    (
        select
            plt.pno
            ,pcol.created_at
            ,pcol.operator_id
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        left join ph_bi.parcel_cs_operation_log pcol on pcol.task_id = plt.id
        where
            pcol.action = 3
    ) pc on pc.pno = t1.pno and t1.route_time < date_sub(pc.created_at, interval 8 hour);
;-- -. . -..- - / . -. - .-. -.--
select count(1) from tmpale.tmp_ph_pno_lj_0129;
;-- -. . -..- - / . -. - .-. -.--
select
            pr.pno
            ,pr.store_name
            ,pr.store_id
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_lj_0129 t on t.pno = pr.pno and t.submitter = pr.staff_info_id and pr.routed_at = date_sub(t.sub_time, interval 8 hour);
;-- -. . -..- - / . -. - .-. -.--
select
            pr.pno
            ,pr.store_name
            ,pr.store_id
            ,pr.routed_at
            ,t.*
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_lj_0129 t on t.pno = pr.pno /*and t.submitter = pr.staff_info_id and pr.routed_at = date_sub(t.sub_time, interval 8 hour)*/
        where
            pr.routed_at > '2023-12-28'
            and t.pno = 'PT192525QQAF1AG';
;-- -. . -..- - / . -. - .-. -.--
select
            pr.pno
            ,pr.store_name
            ,pr.store_id
            ,pr.routed_at
            ,date_sub(t.sub_time, interval 8 hour)
            ,pr.staff_info_id
            ,t.*
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_lj_0129 t on t.pno = pr.pno /*and t.submitter = pr.staff_info_id and pr.routed_at = date_sub(t.sub_time, interval 8 hour)*/
        where
            pr.routed_at > '2023-12-28'
            and t.pno = 'PT192525QQAF1AG';
;-- -. . -..- - / . -. - .-. -.--
select
            pr.pno
            ,pr.store_name
            ,pr.store_id
            ,pr.routed_at
            ,date_sub(t.sub_time, interval 8 hour)
            ,pr.staff_info_id
            ,t.*
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_lj_0129 t on t.pno = pr.pno and t.submitter = pr.staff_info_id and pr.routed_at = date_sub(t.sub_time, interval 8 hour)
        where
            pr.routed_at > '2023-12-28'
            and t.pno = 'PT192525QQAF1AG';
;-- -. . -..- - / . -. - .-. -.--
select
            pr.pno
            ,pr.store_name
            ,pr.store_id
            ,pr.routed_at
            ,date_sub(t.sub_time, interval 8 hour)
            ,pr.staff_info_id
            ,t.*
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_lj_0129 t on t.pno = pr.pno and t.submitter = pr.staff_info_id /*and pr.routed_at = date_sub(t.sub_time, interval 8 hour)*/
        where
            pr.routed_at > '2023-12-28'
            and t.pno = 'PT192525QQAF1AG';
;-- -. . -..- - / . -. - .-. -.--
select
            pr.pno
            ,pr.store_name
            ,pr.store_id
            ,pr.routed_at
            ,date_sub(t.sub_time, interval 8 hour)
            ,pr.staff_info_id
            ,t.*
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_lj_0129 t on t.pno = pr.pno and t.submitter = pr.staff_info_id and date(t.sub_time) = date(date_add(pr.routed_at, interval 8 hour))
        where
            pr.routed_at > '2023-12-28'
            and t.pno = 'PT192525QQAF1AG';
;-- -. . -..- - / . -. - .-. -.--
select
    a1.store_name
    ,a2.di_cnt
    ,pi.dst_detail_address
from
    (
        select
            pr.pno
            ,pr.store_name
            ,pr.store_id
            ,pr.routed_at
            ,pr.staff_info_id
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_lj_0129 t on t.pno = pr.pno and t.submitter = pr.staff_info_id and date(t.sub_time) = date(date_add(pr.routed_at, interval 8 hour))
        where
            pr.routed_at > '2023-12-28'
            -- and t.pno = 'PT192525QQAF1AG'
    ) a1
left join
    (
        select
            di.pno
            ,count(distinct di.id) di_cnt
        from  ph_staging.diff_info di
        join tmpale.tmp_ph_pno_lj_0129 t on t.pno = di.pno
        where
            di.diff_marker_category = 31
            and di.created_at > '2023-09-01'
        group by  1
    ) a2 on a2.pno = a1.pno
left join ph_staging.parcel_info pi on pi.pno = a1.pno;
;-- -. . -..- - / . -. - .-. -.--
select
    a1.pno
    ,a1.sub_time
    ,a1.store_name
    ,a2.di_cnt
    ,pi.dst_detail_address
from
    (
        select
            pr.pno
            ,pr.store_name
            ,pr.store_id
            ,pr.routed_at
            ,pr.staff_info_id
            ,t.sub_time
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_lj_0129 t on t.pno = pr.pno and t.submitter = pr.staff_info_id and date(t.sub_time) = date(date_add(pr.routed_at, interval 8 hour))
        where
            pr.routed_at > '2023-12-28'
            -- and t.pno = 'PT192525QQAF1AG'
    ) a1
left join
    (
        select
            di.pno
            ,count(distinct di.id) di_cnt
        from  ph_staging.diff_info di
        join tmpale.tmp_ph_pno_lj_0129 t on t.pno = di.pno
        where
            di.diff_marker_category = 31
            and di.created_at > '2023-09-01'
        group by  1
    ) a2 on a2.pno = a1.pno
left join ph_staging.parcel_info pi on pi.pno = a1.pno;
;-- -. . -..- - / . -. - .-. -.--
select
            pr.pno
            ,pr.store_name
            ,pr.store_id
            ,pr.routed_at
            ,pr.staff_info_id
            ,t.sub_time
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_lj_0129 t on t.pno = pr.pno and t.submitter = pr.staff_info_id and date(t.sub_time) = date(date_add(pr.routed_at, interval 8 hour))
        where
            pr.routed_at > '2023-12-28'
            and t.pno = 'PT351725YGUU0BP';
;-- -. . -..- - / . -. - .-. -.--
select
            pr.pno
            ,pr.store_name
            ,pr.store_id
            ,pr.routed_at
            ,pr.staff_info_id
            ,t.sub_time
            ,date_format(pr.routed_at, '%Y-%m-%d %H:%i:%S')
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_lj_0129 t on t.pno = pr.pno and t.submitter = pr.staff_info_id and date(t.sub_time) = date(date_add(pr.routed_at, interval 8 hour))
        where
            pr.routed_at > '2023-12-28'
            and t.pno = 'PT351725YGUU0BP';
;-- -. . -..- - / . -. - .-. -.--
select
            pr.pno
            ,pr.store_name
            ,pr.store_id
            ,pr.routed_at
            ,pr.staff_info_id
            ,t.sub_time
            ,date_format(pr.routed_at, '%Y-%m-%d %H:%i:%S')
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_lj_0129 t on t.pno = pr.pno and t.submitter = pr.staff_info_id and date_format(pr.routed_at, '%Y-%m-%d %H:%i:%S') = pr.routed_at
        where
            pr.routed_at > '2023-12-28'
            and t.pno = 'PT351725YGUU0BP';
;-- -. . -..- - / . -. - .-. -.--
select
            pr.pno
            ,pr.store_name
            ,pr.store_id
            ,pr.routed_at
            ,pr.staff_info_id
            ,t.sub_time
            ,date_format(pr.routed_at, '%Y-%m-%d %H:%i:%S')
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_lj_0129 t on t.pno = pr.pno and t.submitter = pr.staff_info_id and date_format(pr.routed_at, '%Y-%m-%d %H:%i:%S') = date_sub(t.sub_time, interval 8 hour)
        where
            pr.routed_at > '2023-12-28'
            and t.pno = 'PT351725YGUU0BP';
;-- -. . -..- - / . -. - .-. -.--
select
    a1.pno
    ,a1.sub_time
    ,a1.store_name
    ,a2.di_cnt
    ,pi.dst_detail_address
from
    (
        select
            pr.pno
            ,pr.store_name
            ,pr.store_id
            ,pr.routed_at
            ,pr.staff_info_id
            ,t.sub_time
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_lj_0129 t on t.pno = pr.pno and t.submitter = pr.staff_info_id and date_format(pr.routed_at, '%Y-%m-%d %H:%i:%S') = date_sub(t.sub_time, interval 8 hour)
        where
            pr.routed_at > '2023-12-28'
            -- and t.pno = 'PT351725YGUU0BP'
    ) a1
left join
    (
        select
            di.pno
            ,count(distinct di.id) di_cnt
        from  ph_staging.diff_info di
        join tmpale.tmp_ph_pno_lj_0129 t on t.pno = di.pno
        where
            di.diff_marker_category = 31
            and di.created_at > '2023-09-01'
        group by  1
    ) a2 on a2.pno = a1.pno
left join ph_staging.parcel_info pi on pi.pno = a1.pno;
;-- -. . -..- - / . -. - .-. -.--
select
            pr.pno
            ,pr.store_name
            ,pr.store_id
            ,pr.routed_at
            ,pr.staff_info_id
            ,t.sub_time
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_lj_0129 t on t.pno = pr.pno and t.submitter = pr.staff_info_id and date_format(pr.routed_at, '%Y-%m-%d %H:%i:%S') = date_sub(t.sub_time, interval 8 hour)
        where
            pr.routed_at > '2023-12-28'
            and t.pno = 'PT351725YGUU0BP';
;-- -. . -..- - / . -. - .-. -.--
select
            pr.pno
            ,pr.store_name
            ,pr.store_id
            ,pr.routed_at
            ,pr.staff_info_id
            ,t.sub_time
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_lj_0129 t on t.pno = pr.pno and t.staff = pr.staff_info_id and date_format(pr.routed_at, '%Y-%m-%d %H:%i:%S') = date_sub(t.sub_time, interval 8 hour)
        where
            pr.routed_at > '2023-12-28'
            and t.pno = 'PT351725YGUU0BP';
;-- -. . -..- - / . -. - .-. -.--
select
            pr.pno
            ,pr.store_name
            ,pr.store_id
            ,pr.routed_at
            ,pr.staff_info_id
            ,t.sub_time
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_lj_0129 t on t.pno = pr.pno and t.satff = pr.staff_info_id and date_format(pr.routed_at, '%Y-%m-%d %H:%i:%S') = date_sub(t.sub_time, interval 8 hour)
        where
            pr.routed_at > '2023-12-28'
            and t.pno = 'PT351725YGUU0BP';
;-- -. . -..- - / . -. - .-. -.--
select
    a1.pno
    ,a1.sub_time
    ,a1.store_name
    ,a2.di_cnt
    ,pi.dst_detail_address
from
    (
        select
            pr.pno
            ,pr.store_name
            ,pr.store_id
            ,pr.routed_at
            ,pr.staff_info_id
            ,t.sub_time
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_lj_0129 t on t.pno = pr.pno and t.satff = pr.staff_info_id and date_format(pr.routed_at, '%Y-%m-%d %H:%i:%S') = date_sub(t.sub_time, interval 8 hour)
        where
            pr.routed_at > '2023-12-28'
           -- and t.pno = 'PT351725YGUU0BP'
    ) a1
left join
    (
        select
            di.pno
            ,count(distinct di.id) di_cnt
        from  ph_staging.diff_info di
        join tmpale.tmp_ph_pno_lj_0129 t on t.pno = di.pno
        where
            di.diff_marker_category = 31
            and di.created_at > '2023-09-01'
        group by  1
    ) a2 on a2.pno = a1.pno
left join ph_staging.parcel_info pi on pi.pno = a1.pno;
;-- -. . -..- - / . -. - .-. -.--
select
    a1.pno
    ,a1.sub_time
    ,a1.store_name
    ,a2.di_cnt
    ,pi.dst_detail_address
from
    (
        select
            pr.pno
            ,pr.store_name
            ,pr.store_id
            ,pr.routed_at
            ,pr.staff_info_id
            ,t.sub_time
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_lj_0129 t on t.pno = pr.pno and t.satff = pr.staff_info_id and date_format(pr.routed_at, '%Y-%m-%d %H:%i') = date_format(date_sub(t.sub_time, interval 8 hour), '%Y-%m-%d %H:%i')
        where
            pr.routed_at > '2023-12-28'
           -- and t.pno = 'PT351725YGUU0BP'
    ) a1
left join
    (
        select
            di.pno
            ,count(distinct di.id) di_cnt
        from  ph_staging.diff_info di
        join tmpale.tmp_ph_pno_lj_0129 t on t.pno = di.pno
        where
            di.diff_marker_category = 31
            and di.created_at > '2023-09-01'
        group by  1
    ) a2 on a2.pno = a1.pno
left join ph_staging.parcel_info pi on pi.pno = a1.pno;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
         select
            dp.store_name 网点Branch
            ,dp.piece_name 片区District
            ,dp.region_name 大区Area
            ,plt.pno 运单Tracking_Number
            ,pi.exhibition_weight 重量
            ,concat_ws('*', pi.exhibition_length, pi.exhibition_width, pi.exhibition_height) 尺寸
            ,pi2.cod_amount/100 COD
            ,plt.created_at 任务创建时间Task_Generation_time
            ,plt.parcel_created_at 包裹揽收时间Receive_time
            ,concat(ddd.element, ddd.CN_element) 最后有效路由Last_effective_route
            ,plt.last_valid_routed_at 最后有效路由操作时间Last_effective_routing_time
            ,plt.last_valid_staff_info_id 最后有效路由操作员工Last_effective_route_operate_id
            ,ss.name 最后有效路由操作网点Last_operate_branch
            ,case when pi.state = 1 then '已揽收'
                when pi.state = 2 then '运输中'
                when pi.state = 3 then '派送中'
                when pi.state = 4 then '已滞留'
                when pi.state = 5 then '已签收'
                when pi.state = 6 then '疑难件处理中'
                when pi.state = 7 then '已退件'
                when pi.state = 8 then '异常关闭'
                when pi.state = 9 then '已撤销'
                end as 包裹最新状态latest_parcel_status
        from ph_bi.parcel_lose_task plt
        left join ph_bi.parcel_detail pd on pd.pno = plt.pno
        left join ph_staging.parcel_info pi on pi.pno = plt.pno and pi.created_at > date_sub(curdate(), interval 3 month )
        left join  ph_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pd.resp_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
        left join dwm.dwd_dim_dict ddd on ddd.element = plt.last_valid_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
        left join dwm.dim_ph_sys_store_rd dp2 on dp2.store_id = plt.last_valid_store_id and dp2.stat_date = date_sub(curdate(), interval 1 day)
        left join ph_staging.sys_store ss on ss.id = plt.last_valid_store_id
        where
            plt.source in (3,33)
            and plt.state in (1,2,3,4)
    )
select
   t1.*
    ,convert_tz(a.routed_at, '+00:00', '+08:00') 到达网点时间
    ,sor.sorting_code 三段码
from t t1
left join
    (
        select
            pr.routed_at
            ,pr.pno
            ,row_number() over (partition by pr.pno order by pr.routed_at) rn
        from ph_staging.parcel_route pr
        join t t1 on t1.运单Tracking_Number = pr.pno and t1.网点Branch = pr.store_name
        where
            pr.routed_at > date_sub(curdate(), interval 2 month)
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
    ) a on a.pno = t1.运单Tracking_Number and a.rn = 1
left join
    (
        select
            ps.pno
            ,ps.sorting_code
            ,row_number() over (partition by ps.pno order by ps.created_at desc) rn
        from ph_drds.parcel_sorting_code_info ps
        join t t1 on t1.运单Tracking_Number = ps.pno
        where
            ps.created_at > date_sub(curdate(), interval 3 month)
    ) sor on sor.pno = t1.运单Tracking_Number and sor.rn = 1;
;-- -. . -..- - / . -. - .-. -.--
select
    pr.pno 运单号
    ,pi.client_id 客户iD
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 标记时间
    ,ddd.CN_element 标记原因
    ,pr.staff_info_id 标记快递员
    ,dp.store_name 标记网点
    ,dp.piece_name 标记网点所属片区
    ,dp.region_name 标记网点所属大区
    ,pi.dst_name 收件人姓名
    ,pi.dst_phone 收件人电话
from ph_staging.parcel_route pr
left join ph_staging.parcel_info pi on pi.pno = pr.pno
left join dwm.dwd_dim_dict ddd on ddd.element = pr.marker_category and ddd.db = 'ph_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pr.store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
where
    pr.route_action = 'DELIVERY_MARKER'
    and pr.routed_at >= '2024-01-28 14:00:00'
    and pr.routed_at < '2024-01-28 23:00:00';
;-- -. . -..- - / . -. - .-. -.--
select
    pr.pno 运单号
    ,pi.client_id 客户iD
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 标记时间
    ,ddd.CN_element 标记原因
    ,pr.staff_info_id 标记快递员
    ,dp.store_name 标记网点
    ,dp.piece_name 标记网点所属片区
    ,dp.region_name 标记网点所属大区
    ,pi.dst_name 收件人姓名
    ,pi.dst_phone 收件人电话
from ph_staging.parcel_route pr
left join ph_staging.parcel_info pi on pi.pno = pr.pno
join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name = 'shopee'
left join dwm.dwd_dim_dict ddd on ddd.element = pr.marker_category and ddd.db = 'ph_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pr.store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
where
    pr.route_action = 'DELIVERY_MARKER'
    and pr.routed_at >= '2024-01-28 14:00:00'
    and pr.routed_at < '2024-01-28 23:00:00';
;-- -. . -..- - / . -. - .-. -.--
select
    pr.pno 运单号
    ,pi.client_id 客户iD
    ,bc.client_name 客户名称
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 标记时间
    ,ddd.CN_element 标记原因
    ,pr.staff_info_id 标记快递员
    ,dp.store_name 标记网点
    ,dp.piece_name 标记网点所属片区
    ,dp.region_name 标记网点所属大区
    ,pi.dst_name 收件人姓名
    ,pi.dst_phone 收件人电话
from ph_staging.parcel_route pr
left join ph_staging.parcel_info pi on pi.pno = pr.pno
join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id /*and bc.client_name = 'shopee'*/
left join dwm.dwd_dim_dict ddd on ddd.element = pr.marker_category and ddd.db = 'ph_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pr.store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
where
    pr.route_action = 'DELIVERY_MARKER'
    and pr.routed_at >= '2024-01-28 14:00:00'
    and pr.routed_at < '2024-01-28 23:00:00';
;-- -. . -..- - / . -. - .-. -.--
select
    pr.pno 运单号
    ,pi.client_id 客户iD
    ,bc.client_name 客户名称
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 标记时间
    ,ddd.CN_element 标记原因
    ,pr.staff_info_id 标记快递员
    ,dp.store_name 标记网点
    ,dp.piece_name 标记网点所属片区
    ,dp.region_name 标记网点所属大区
    ,pi.dst_name 收件人姓名
    ,pi.dst_phone 收件人电话
from ph_staging.parcel_route pr
left join ph_staging.parcel_info pi on pi.pno = pr.pno
join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id /*and bc.client_name = 'shopee'*/
left join dwm.dwd_dim_dict ddd on ddd.element = pr.marker_category and ddd.db = 'ph_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pr.store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
where
    pr.route_action = 'DELIVERY_MARKER'
    and pr.routed_at >= '2024-01-29 14:00:00'
    and pr.routed_at < '2024-01-29 23:00:00';
;-- -. . -..- - / . -. - .-. -.--
select
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
left join ph_staging.parcel_info pi on pi.pno = prr.pno
left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
left join ph_bi.parcel_detail pd on pd.pno = prr.pno
left join ph_staging.sys_store ss2 on ss2.id = pd.last_valid_store_id
left join nl_production.violation_return_visit vrv on vrv.link_id = prr.pno and vrv.visit_staff_id in (10001,10000) and date_sub(vrv.created_at, interval 8 hour) > prr.created_at
where
    prr.created_at > '2024-01-12 16:00:00'
    and prr.created_at < '2024-01-29 16:00:00';
;-- -. . -..- - / . -. - .-. -.--
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
left join ph_staging.parcel_info pi on pi.pno = prr.pno
left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
left join ph_bi.parcel_detail pd on pd.pno = prr.pno
left join ph_staging.sys_store ss2 on ss2.id = pd.last_valid_store_id
left join nl_production.violation_return_visit vrv on vrv.link_id = prr.pno and vrv.visit_staff_id in (10001,10000) and date_sub(vrv.created_at, interval 8 hour) > prr.created_at
where
    prr.created_at > '2024-01-12 16:00:00'
    and prr.created_at < '2024-01-29 16:00:00';
;-- -. . -..- - / . -. - .-. -.--
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
    and prr.created_at < '2024-01-29 16:00:00';
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno 单号
    ,'揽' 类型
    ,convert_tz(pi.created_at, '+00:00', '+08:00') 揽派时间
    ,if(bc.client_name = 'lazada', pi2.insure_declare_value/100, pi2.cod_amount/100)  COD金额
from ph_staging.parcel_info pi
left join ph_staging.parcel_info pi2 on if(pi.returned = 1, pi.customary_pno, pi.pno)
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
where
    pi.ticket_pickup_staff_info_id = '153228'
    and pi.created_at >= '2023-10-31 16:00:00'
    and pi.created_at < '2023-11-30 16:00:00'
    and pi.state = 8

union all

select
    pi.pno 单号
    ,'派' 类型
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 揽派时间
    ,if(bc.client_name = 'lazada', pi2.insure_declare_value/100, pi2.cod_amount/100)  COD金额
from ph_staging.parcel_route pr
left join ph_staging.parcel_info pi on pi.pno = pr.pno
left join ph_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
where
    pr.routed_at >= '2023-10-31 16:00:00'
    and pr.routed_at < '2023-11-30 16:00:00'
    and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    and pr.staff_info_id = '153228';
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno 单号
    ,'派' 类型
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 揽派时间
    ,if(bc.client_name = 'lazada', pi2.insure_declare_value/100, pi2.cod_amount/100)  COD金额
from ph_staging.parcel_route pr
left join ph_staging.parcel_info pi on pi.pno = pr.pno
left join ph_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
where
    pr.routed_at >= '2023-10-31 16:00:00'
    and pr.routed_at < '2023-11-30 16:00:00'
    and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    and pr.staff_info_id = '153228';
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno 单号
    ,'揽' 类型
    ,convert_tz(pi.created_at, '+00:00', '+08:00') 揽派时间
    ,if(bc.client_name = 'lazada', pi2.insure_declare_value/100, pi2.cod_amount/100)  COD金额
from ph_staging.parcel_info pi
left join ph_staging.parcel_info pi2 on if(pi.returned = 1, pi.customary_pno, pi.pno)
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
where
    pi.ticket_pickup_staff_info_id = '153228'
    and pi.created_at >= '2023-10-31 16:00:00'
    and pi.created_at < '2023-11-30 16:00:00'
    and pi.state = 8;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno 单号
    ,'揽' 类型
    ,convert_tz(pi.created_at, '+00:00', '+08:00') 揽派时间
    ,if(bc.client_name = 'lazada', pi2.insure_declare_value/100, pi2.cod_amount/100)  COD金额
from ph_staging.parcel_info pi
left join ph_staging.parcel_info pi2 on if(pi.returned = 1, pi.customary_pno, pi.pno) = pi2.pno
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
where
    pi.ticket_pickup_staff_info_id = '153228'
    and pi.created_at >= '2023-10-31 16:00:00'
    and pi.created_at < '2023-11-30 16:00:00'
    and pi.state = 8

union all

select
    pi.pno 单号
    ,'派' 类型
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 揽派时间
    ,if(bc.client_name = 'lazada', pi2.insure_declare_value/100, pi2.cod_amount/100)  COD金额
from ph_staging.parcel_route pr
left join ph_staging.parcel_info pi on pi.pno = pr.pno
left join ph_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
where
    pr.routed_at >= '2023-10-31 16:00:00'
    and pr.routed_at < '2023-11-30 16:00:00'
    and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    and pr.staff_info_id = '153228';
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno 单号
    ,'揽' 类型
    ,convert_tz(pi.created_at, '+00:00', '+08:00') 揽派时间
    ,if(bc.client_name = 'lazada', pi2.insure_declare_value/100, pi2.cod_amount/100)  COD金额
from ph_staging.parcel_info pi
left join ph_staging.parcel_info pi2 on if(pi.returned = 1, pi.customary_pno, pi.pno) = pi2.pno
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
where
    pi.ticket_pickup_staff_info_id = '153228'
    and pi.created_at >= '2023-10-31 16:00:00'
    and pi.created_at < '2023-11-30 16:00:00'
    and pi.state = 8;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            pi.pno
            ,pi.state
            ,ss.name pick_store
            ,ss2.name dst_store
            ,pi.cod_amount
            ,pi.client_id
            ,pi.insure_declare_value
            ,convert_tz(pi.created_at, '+00:00', '+08:00') pick_at
        from ph_staging.parcel_info pi
        left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
        left join ph_staging.sys_store ss2 on ss2.id = pi.dst_store_id
        where
            pi.created_at >= '2023-12-31 16:00:00'
            and pi.src_phone = '09218644470'
            and pi.state < 9
    )
select
    t1.pno
    ,t1.pick_at 揽收时间
    ,t1.pick_store 揽收网点
    ,t1.dst_store 目的地网点
    ,if(bc.name = 'lazada', t1.insure_declare_value/100, t1.cod_amount/100) cod
    ,case t1.state
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
    ,if(t2.pno is not null, '是', '否') 是否有通话记录
from t t1
left join
    (
        select
            pr.pno
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at >= '2023-12-31 16:00:00'
            and pr.route_action = 'PHONE'
            and json_extract(pr.extra_value, '$.callDuration') > 0
        group by 1
    ) t2 on t1.pno = t2.pno
left join dwm.dwd_dim_bigClient bc on bc.client_id = t1.client_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            pi.pno
            ,pi.state
            ,ss.name pick_store
            ,ss2.name dst_store
            ,pi.cod_amount
            ,pi.client_id
            ,pi.insure_declare_value
            ,convert_tz(pi.created_at, '+00:00', '+08:00') pick_at
        from ph_staging.parcel_info pi
        left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
        left join ph_staging.sys_store ss2 on ss2.id = pi.dst_store_id
        where
            pi.created_at >= '2023-12-31 16:00:00'
            and pi.src_phone = '09218644470'
            and pi.state < 9
    )
select
    t1.pno
    ,t1.pick_at 揽收时间
    ,t1.pick_store 揽收网点
    ,t1.dst_store 目的地网点
    ,if(bc.client_name = 'lazada', t1.insure_declare_value/100, t1.cod_amount/100) cod
    ,case t1.state
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
    ,if(t2.pno is not null, '是', '否') 是否有通话记录
from t t1
left join
    (
        select
            pr.pno
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at >= '2023-12-31 16:00:00'
            and pr.route_action = 'PHONE'
            and json_extract(pr.extra_value, '$.callDuration') > 0
        group by 1
    ) t2 on t1.pno = t2.pno
left join dwm.dwd_dim_bigClient bc on bc.client_id = t1.client_id;
;-- -. . -..- - / . -. - .-. -.--
select
    date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
    ,count(distinct pr.pno) 交接量
    ,count(distinct if(ppd.pno is null, pr.pno, null)) 交接未留仓量
from ph_staging.parcel_route pr
left join ph_staging.parcel_problem_detail ppd on ppd.pno = pr.pno and ppd.created_at > '2024-01-28 16:00:00' and ppd.created_at < '2024-01-29 16:00:00'
where
    pr.routed_at > '2024-01-28 16:00:00'
    and pr.routed_at < '2024-01-29 16:00:00'
    and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
    ,count(distinct pr.pno) 交接量
    ,count(distinct if(ppd.pno is null and pi.state not in (5,7,8,9), pr.pno, null)) 未终态交接未留仓量
from ph_staging.parcel_route pr
left join ph_staging.parcel_info pi on pi.pno = pr.pno
left join ph_staging.parcel_problem_detail ppd on ppd.pno = pr.pno and ppd.created_at > '2024-01-28 16:00:00' and ppd.created_at < '2024-01-29 16:00:00'
where
    pr.routed_at > '2024-01-28 16:00:00'
    and pr.routed_at < '2024-01-29 16:00:00'
    and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
    ,count(distinct pr.pno) 交接量
    ,count(distinct if(ppd.pno is null and pi.state not in (5,7,8,9), pr.pno, null)) 未终态交接未留仓量
from ph_staging.parcel_route pr
left join ph_staging.parcel_info pi on pi.pno = pr.pno
left join ph_staging.parcel_problem_detail ppd on ppd.pno = pr.pno and ppd.created_at > '2024-01-28 16:00:00' and ppd.created_at < '2024-01-29 18:00:00'
where
    pr.routed_at > '2024-01-28 16:00:00'
    and pr.routed_at < '2024-01-29 16:00:00'
    and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
    ,count(distinct pr.pno) 交接量
    ,count(distinct if(ppd.pno is null and pi.state not in (5,7,8,9), pr.pno, null)) 未终态交接未留仓量
from ph_staging.parcel_route pr
left join ph_staging.parcel_info pi on pi.pno = pr.pno
left join ph_staging.parcel_problem_detail ppd on ppd.pno = pr.pno and ppd.created_at > '2024-01-28 16:00:00' and ppd.created_at < '2024-01-29 20:00:00'
where
    pr.routed_at > '2024-01-28 16:00:00'
    and pr.routed_at < '2024-01-29 16:00:00'
    and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
#     date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
#     ,count(distinct pr.pno) 交接量
#     ,count(distinct if(ppd.pno is null and pi.state not in (5,7,8,9), pr.pno, null)) 未终态交接未留仓量

    pr.pno
from ph_staging.parcel_route pr
left join ph_staging.parcel_info pi on pi.pno = pr.pno
left join ph_staging.parcel_problem_detail ppd on ppd.pno = pr.pno and ppd.created_at > '2024-01-28 16:00:00' and ppd.created_at < '2024-01-29 20:00:00'
where
    pr.routed_at > '2024-01-28 16:00:00'
    and pr.routed_at < '2024-01-29 16:00:00'
    and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    and ppd.pno is null
    and pi.state not in (5,7,8,9)
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    fn.date
 ,count(distinct fn.运单号)  应揽收量
 ,count(case when fn.揽收订单日期<=fn.date then fn.运单号 else null end) 实际揽收量
 ,count(case when fn.揽收订单日期<=fn.date then fn.运单号 else null end)/count(distinct fn.运单号) 当日揽收率
    from
 (
     select
      opdd.date
      ,oi.pno 运单号
      ,oi.ka_warehouse_id 仓库ID
      ,oi.src_name  seller名称
      ,date(if(hour(convert_tz(oi.confirm_at, '+00:00', '+08:00'))<12,concat(date_add(date(convert_tz(oi.confirm_at, '+00:00', '+08:00')), interval 0 day), ' 00:00:00'),date_add(convert_tz(oi.confirm_at, '+00:00', '+08:00'),interval 1 day))) 应揽收日期
     # ,convert_tz(oi.created_at, '+00:00', '+08:00') as 创建订单时间
      ,convert_tz(oi.confirm_at, '+00:00', '+08:00') 订单确认时间
      ,date(convert_tz(oi.confirm_at, '+00:00', '+08:00')) 订单确认日期
      ,convert_tz(pi.created_at, '+00:00', '+08:00') 揽收订单时间
      ,date(convert_tz(pi.created_at, '+00:00', '+08:00')) 揽收订单日期
      ,case oi.state
       when 0 then'已确认'
    when 1 then'待揽件'
    when 2 then'已揽收'
    when 3 then'已取消(已终止)'
    when 4 then'已删除(已作废)'
    when 5 then'预下单'
    when 6 then'被标记多次，限制揽收'
       end as 订单状态
   from  ph_staging.order_info oi
   join tmpale.ods_ph_dim_date opdd
   left join ph_staging.parcel_info pi on oi.pno=pi.pno
   where oi.client_id in('AA0131')
    and oi.state not in(3,4)
    and opdd.date<=date_sub(current_date,interval 0 day)
    and opdd.date>=date_sub(current_date,interval 60 day)
    and opdd.date>=date(convert_tz(oi.confirm_at, '+00:00', '+08:00'))
    and opdd.date<=date(convert_tz(pi.created_at, '+00:00', '+08:00'))
    -- and convert_tz(oi.confirm_at, '+00:00', '+08:00')<concat(opdd.date, ' 18:00:00')
     and oi.confirm_at < date_add(opdd.date,interval 10 hour)
 )fn
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    fn.date
 ,count(distinct fn.运单号)  应揽收量
 ,count(case when fn.揽收订单日期<=fn.date then fn.运单号 else null end) 实际揽收量
 ,count(case when fn.揽收订单日期<=fn.date then fn.运单号 else null end)/count(distinct fn.运单号) 当日揽收率
    from
 (
     select
      opdd.date
      ,oi.pno 运单号
      ,oi.ka_warehouse_id 仓库ID
      ,oi.src_name  seller名称
      ,date(if(hour(convert_tz(oi.confirm_at, '+00:00', '+08:00'))<12,concat(date_add(date(convert_tz(oi.confirm_at, '+00:00', '+08:00')), interval 0 day), ' 00:00:00'),date_add(convert_tz(oi.confirm_at, '+00:00', '+08:00'),interval 1 day))) 应揽收日期
     # ,convert_tz(oi.created_at, '+00:00', '+08:00') as 创建订单时间
      ,convert_tz(oi.confirm_at, '+00:00', '+08:00') 订单确认时间
      ,date(convert_tz(oi.confirm_at, '+00:00', '+08:00')) 订单确认日期
      ,convert_tz(pi.created_at, '+00:00', '+08:00') 揽收订单时间
      ,date(convert_tz(pi.created_at, '+00:00', '+08:00')) 揽收订单日期
      ,case oi.state
       when 0 then'已确认'
    when 1 then'待揽件'
    when 2 then'已揽收'
    when 3 then'已取消(已终止)'
    when 4 then'已删除(已作废)'
    when 5 then'预下单'
    when 6 then'被标记多次，限制揽收'
       end as 订单状态
   from  ph_staging.order_info oi
   cross join tmpale.ods_ph_dim_date opdd
   left join ph_staging.parcel_info pi on oi.pno=pi.pno
   where oi.client_id in('AA0131')
    and oi.state not in(3,4)
    and opdd.date<=date_sub(current_date,interval 0 day)
    and opdd.date>=date_sub(current_date,interval 60 day)
    and oi.confirm_at < date_sub(opdd.date,interval 8 hour)
    and pi.created_at > date_sub(opdd.date,interval 8 hour)
  --  and opdd.date>=date(convert_tz(oi.confirm_at, '+00:00', '+08:00'))
  --  and opdd.date<=date(convert_tz(pi.created_at, '+00:00', '+08:00'))
    -- and convert_tz(oi.confirm_at, '+00:00', '+08:00')<concat(opdd.date, ' 18:00:00')
     and oi.confirm_at < date_add(opdd.date,interval 10 hour)
 )fn
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno 单号
    ,'揽' 类型
    ,convert_tz(pi.created_at, '+00:00', '+08:00') 揽派时间
    ,if(bc.client_name = 'lazada', pi2.insure_declare_value/100, pi2.cod_amount/100)  COD金额
from ph_staging.parcel_info pi
left join ph_staging.parcel_info pi2 on if(pi.returned = 1, pi.customary_pno, pi.pno) = pi2.pno
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
where
    pi.ticket_pickup_staff_info_id = '153228'
    and pi.created_at >= '2023-10-31 16:00:00'
    and pi.created_at < '2023-11-30 16:00:00'
    and pi.state = 8

union all

select
    pi.pno 单号
    ,'派' 类型
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 揽派时间
    ,if(bc.client_name = 'lazada', pi2.insure_declare_value/100, pi2.cod_amount/100)  COD金额
from ph_staging.parcel_route pr
left join ph_staging.parcel_info pi on pi.pno = pr.pno
left join ph_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
where
    pr.routed_at >= '2023-10-31 16:00:00'
    and pr.routed_at < '2023-11-30 16:00:00'
    and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    and pr.staff_info_id = '153228'
    and pi.state = 8;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
    ,pi2.cod_amount/100
    ,pai.cogs_amount/100
    ,convert_tz(pi.created_at, '+00:00', '+08:00') 揽件时间
    ,pi.src_name
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
from ph_staging.parcel_info pi
left join ph_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
left join ph_staging.parcel_additional_info pai on pai.pno = pi2.pno
where
    pi.state in (7,8)
    and pi.ticket_pickup_staff_info_id = 153228
    and pi.created_at >= '2023-10-31 16:00:00';
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
    ,pi2.cod_amount/100 cod
    ,pai.cogs_amount/100 cogs
    ,convert_tz(pi.created_at, '+00:00', '+08:00') 揽件时间
    ,pi.src_name 卖家名称
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
from ph_staging.parcel_info pi
left join ph_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
left join ph_staging.parcel_additional_info pai on pai.pno = pi2.pno
where
    pi.state in (7,8)
    and pi.ticket_pickup_staff_info_id = 153228
    and pi.created_at >= '2023-10-31 16:00:00';
;-- -. . -..- - / . -. - .-. -.--
select
    pr.pno
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
    ,pi2.cod_amount/100 cod
    ,pai.cogs_amount/100 cogs
from ph_staging.parcel_route pr
left join ph_staging.parcel_info pi on pi.pno = pr.pno
left join ph_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
left join ph_staging.parcel_additional_info pai on pai.pno = pi2.pno
where
    pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    and pr.routed_at >='2024-01-07 16:00:00'
    and pr.routed_at < '2023-01-08 16:00:00'
    and pr.staff_info_id = '166605';
;-- -. . -..- - / . -. - .-. -.--
select
    pr.pno
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
    ,pi2.cod_amount/100 cod
    ,pai.cogs_amount/100 cogs
from ph_staging.parcel_route pr
left join ph_staging.parcel_info pi on pi.pno = pr.pno
left join ph_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
left join ph_staging.parcel_additional_info pai on pai.pno = pi2.pno
where
    pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    and pr.routed_at >='2024-01-07 16:00:00'
    and pr.routed_at < '2023-01-08 16:00:00'
    and pr.staff_info_id = 166605;
;-- -. . -..- - / . -. - .-. -.--
select
    pr.pno
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
    ,pi2.cod_amount/100 cod
    ,pai.cogs_amount/100 cogs
from ph_staging.parcel_route pr
left join ph_staging.parcel_info pi on pi.pno = pr.pno
left join ph_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
left join ph_staging.parcel_additional_info pai on pai.pno = pi2.pno
where
    pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    and pr.routed_at >='2024-01-07 16:00:00'
    and pr.routed_at < '2024-01-08 16:00:00'
    and pr.staff_info_id = 166605;
;-- -. . -..- - / . -. - .-. -.--
select
    pr.pno
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
    ,pi2.cod_amount/100 cod
    ,pai.cogs_amount/100 cogs
from ph_staging.parcel_route pr
left join ph_staging.parcel_info pi on pi.pno = pr.pno
left join ph_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
left join ph_staging.parcel_additional_info pai on pai.pno = pi2.pno
where
    pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    and pr.routed_at >='2024-01-17 16:00:00'
    and pr.routed_at < '2024-01-18 16:00:00'
    and pr.staff_info_id = 166605;
;-- -. . -..- - / . -. - .-. -.--
select
    distinct 
    pr.pno
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
    ,pi2.cod_amount/100 cod
    ,pai.cogs_amount/100 cogs
from ph_staging.parcel_route pr
left join ph_staging.parcel_info pi on pi.pno = pr.pno
left join ph_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
left join ph_staging.parcel_additional_info pai on pai.pno = pi2.pno
where
    pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    and pr.routed_at >='2024-01-17 16:00:00'
    and pr.routed_at < '2024-01-18 16:00:00'
    and pr.staff_info_id = 166605;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
    ,pi2.pno 退件单号
    ,case pi2.state
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
from ph_staging.parcel_info pi
left join ph_staging.parcel_info pi2 on pi2.pno = pi.returned_pno
where
    pi.pno in ('P66023KHH5DAB','P66023KPKPAAB','P66023KHFGYAB','P66023KHFHBAB','P66023KHH4PAB','P66023KHH47AB','P66023KPKWNAB','P66023KHH51AB','P66023KPKP4AB','P66023KPKJZAB','P66023KHFGNAB','P66023KHJQ4AB','P66023KHH5FAB','P66023KPKJXAB','P66023KPKP8AB','P66023KHH5BAB','P66023KHFH5AB','P66023KHFGQAB','P66023KPKPBAB','P66023KHFGDAB','P66023KHH5EAB','P66023KPKP5AB','P66023KHFHGAB','P66023KHJQFAB','P66023KHFHNAB','P66023KHH53AB','P66023KHH59AB','P66023KHFGKAB','P66023KHH4UAB','P66023KHH4WAB','P66023KHJQ8AB','P66023KHH50AB','P66023KHFGMAB','P66023KHH4FAB','P66023KPKK4AB','P66023KPKPCAB','P66023KHH4KAB','P66023KPKK5AB','P66023KHFH7AB','P66023KPKNZAB','P66023KHH5HAB','P66023KHH57AB','P66023KHFH2AB','P66023KPKWKAB','P66023KHH49AB','P66023KHFHKAB','P66023KHH4RAB','P66023KHJQ5AB','P66023KHFGRAB','P66023KHH4SAB','P66023KHFH9AB','P66023KHJQAAB','P66023KHFH8AB','P66023KHH5GAB','P66023KHFH0AB','P66023KPKP3AB','P66023KPKP7AB','P66023KHH48AB','P66023KHH52AB','P66023KHH4CAB','P66023KPKWPAB','P66023KHFGJAB','P66023KHJQDAB','P66023KHFGGAB','P66023KHH4BAB','P66023KHH4DAB','P66023KHH56AB','P66023KPKK2AB','P66023KPKJYAB','P66023KHFHJAB','P66023KHH4EAB','P66023KPKK1AB','P66023KHFGEAB','P66023KHH5CAB','P66023KHFGBAB','P66023KHFGSAB','P66023KHH4GAB','P66023KHJQ6AB','P66023KPKP9AB','P66023KHH4JAB','P66023KHJQEAB','P66023KPKK3AB','P66023KHH4MAB','P66023KHH4NAB','P66023KHJQCAB','P66023KHFHCAB','P66023KHFGTAB','P66023KHH4ZAB','P66023KHFGZAB','P66023KHFHAAB','P66023KPKPEAB','P66023KPKWMAB','P66023KHFH4AB','P66023KHFGPAB','P66023KPKK0AB','P66023KHFGWAB','P66023KHH4VAB','P66023KHH4XAB','P66023KHFGUAB','P66023KHFH1AB','P66023KHFGHAB','P66023KPKW8AB','P66023KHJQ7AB','P66023KHFGVAB','P66023KHFGCAB','P66023KHFH3AB','P66023KHH4TAB','P66023KHH58AB','P66023KPKWJAB','P66023KHH4AAB','P66023KHH4QAB');
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
    ,pi.cod_amount/100 cod
    ,pi.src_name
    ,convert_tz(pi.created_at, '+00:00', '+08:00')
    ,dst_ss.name
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
    ,case pi2.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 退件包裹状态
from ph_staging.parcel_info pi
left join ph_staging.sys_store dst_ss on dst_ss.id = pi.dst_store_id
left join ph_staging.parcel_info pi2 on pi2.pno = pi.returned_pno
where
    pi.created_at > '2023-12-31 16:00:00'
    and pi.src_phone in ('09274286755', '09274640291', '09156743971');