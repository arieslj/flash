      /*
        =====================================================================+
        表名称：1218d_th_lose_task_deal_info
        功能描述：疑似丢失网店处理监控

        需求来源：
        编写人员: 吕杰
        设计日期：2023-01-18
      	修改日期:
      	修改人员:
      	修改原因:
      -----------------------------------------------------------------------
      ---存在问题：
      -----------------------------------------------------------------------
      +=====================================================================
      */

select
    distinct pls.pno '运单号เลขพัสดุ'
    ,c.created_at '首次预警时间'
    ,ds.store_name '网点名称'
    ,pls.created_at '任务生成时间เวลาที่จัดการสำเร็จ'
    ,if(
        TIMESTAMPDIFF(hour,pls.created_at,now())<48,
    concat(cast(TIMESTAMPDIFF(minute,now(),date_add(pls.created_at,interval 2 day))/60 as int),'h ',cast(round(TIMESTAMPDIFF(minute,now(),date_add(pls.created_at,interval 2 day))%60,0)as int),'min'),
    concat('已超时',concat(cast(TIMESTAMPDIFF(minute,date_add(pls.created_at,interval 2 day),now())/60 as int),'h ',cast(round(TIMESTAMPDIFF(minute,date_add(pls.created_at,interval 2 day),now())%60,0)as int),'min'))) '任务处理倒计时เวลาที่สะสม'
    ,pls.pack_no '集包号เลขแบ็กกิ้ง'
#     ,pls.arrival_time '入仓时间เวลาที่เข้าคลัง'
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
    ,ddd.CN_element '最后有效路由สถานะสุดท้าย'
    ,pls.last_valid_staff_id '最后一步有效路由操作员工ID ไอดีพนักงานที่สแกนล่าสุด'
    ,pls.last_valid_at '最后操作时间เวลาสุดท้ายที่ดำเนินการ'
    ,ds2.store_name '最后有效路由所在网点สาขาสุดท้ายที่ดำเนินการ'
    ,coalesce(ds2.piece_name,fp.piece_no) '片区District'
    ,coalesce(ds2.region_name,fp.region_no) '大区Area'
    ,bc.client_name '客户名称'
    ,if(pi.cod_enabled = 1, 'yes', 'no') '是否是cod เป็นพัสดุcodหรือไม่'
    ,pi.cod_amount/100 COD金额
    ,pls.arrival_time '到达网点时间 เวลาที่ถึงสาขา'
    ,datediff(curdate(), pls.arrival_time) '到达网点时长/day มาถึงสาขาแล้วกี่วัน'
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
    end as '包裹状态 สถานะพัสดุ'
from bi_center.parcel_lose_task_sub_c pls
left join dwm.dwd_dim_dict ddd on ddd.element = pls.last_valid_action and ddd.db = 'rot_pro' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
left join fle_staging.parcel_info pi on pi.pno = pls.pno
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id
left join dwm.dim_th_sys_store_rd ds on pls.store_id = ds.store_id and ds.stat_date = date_sub(curdate(), interval 1 day )
left join dwm.dim_th_sys_store_rd ds2 on pls.last_valid_store_id = ds2.store_id and ds2.stat_date = date_sub(curdate(), interval 1 day )
left join fle_Staging.sys_store ss on pls.last_valid_store_id =ss.id
left join fle_staging.franchisee_profile fp on ss.franchisee_id=fp.id
left join
    (
        select
            pls.pno
            ,plt.created_at
            ,row_number() over (partition by pls.pno order by plt.created_at) rn
        from bi_center.parcel_lose_task_sub_c pls
        left join bi_pro.parcel_lose_task plt on pls.pno = plt.pno and plt.source = 3
        where
             pls.created_at > date_sub(curdate(), interval 110 day)
            and pls.state= 1
    ) c on c.pno = pls.pno and c.rn = 1
where
    pls.created_at > date_sub(curdate(), interval 110 day)
    and pls.state = 1
