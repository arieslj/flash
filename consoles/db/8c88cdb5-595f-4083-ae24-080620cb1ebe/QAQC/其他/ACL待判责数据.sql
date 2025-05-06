  /*=====================================================================+
        表名称：2196d_th_acl_lose_task_uncompleted_detail
        功能描述：

        需求来源：
        编写人员: Lvjie
        设计日期：2024/07/25
      	修改日期:
      	修改人员:
      	修改原因:
      -----------------------------------------------------------------------
      ---存在问题：
      -----------------------------------------------------------------------
      +=====================================================================*/

select
    plt.pno 运单号
    ,case
        when 0 then '正向'
        when 1 then '逆向'
    end 正逆向
    ,concat('SSRD', plt.id) 任务ID
    ,case plt.vip_enable
        when 0 then '普通客户'
        when 1 then 'KAM客户'
    end 客户类型
    ,plt.client_id 客户ID
    ,plt.created_at 任务生成时间
    ,case plt.source
        WHEN 1 THEN 'A-问题件-丢失'
        WHEN 2 THEN 'B-记录本-丢失'
        WHEN 3 THEN 'C-包裹状态未更新'
        WHEN 4 THEN 'D-问题件-破损/短少'
        WHEN 5 THEN 'E-记录本-索赔-丢失'
        WHEN 6 THEN 'F-记录本-索赔-破损/短少'
        WHEN 7 THEN 'G-记录本-索赔-其他'
        WHEN 8 THEN 'H-包裹状态未更新-IPC计数'
        WHEN 9 THEN 'I-问题件-外包装破损险'
        WHEN 10 THEN 'J-问题记录本-外包装破损险'
        when 11 then 'K-超时效包裹'
        when 12 then 'L-高度疑似丢失'
    end 问题来源渠道
    ,plt.client_id 客户ID
    ,pi.cod_amount/100 COD金额
    ,oi.cogs_amount/100 COGS
    ,concat('******', substring(pi.dst_phone, -4)) 收件人电话
    ,ss.short_name 始发地
    ,ss2.short_name  目的地
    ,convert_tz(pi.created_at , '+00:00', '+07:00') 揽件时间
    ,cast(pi.exhibition_weight as double)/1000 '重量'
    ,concat(pi.exhibition_length,'*',pi.exhibition_width,'*',pi.exhibition_height) '尺寸'
    ,case pi.parcel_category
        when '0' then '文件'
        when '1' then '干燥食品'
        when '10' then '家居用具'
        when '11' then '水果'
        when '2' then '日用品'
        when '3' then '数码产品'
        when '4' then '衣物'
        when '5' then '书刊'
        when '6' then '汽车配件'
        when '7' then '鞋包'
        when '8' then '体育器材'
        when '9' then '化妆品'
        when '99' then '其它'
    end  as 物品类型
    ,if(pr.pno is  not null, '是', '否') 是否有发无到
    ,ddd.CN_element 最后有效路由动作
    ,plt.last_valid_store_id 最后有效路由网点
    ,concat(hsi.name, '(', plt.last_valid_staff_info_id, ')') 最后有效路由操作人
    ,dp.store_name 最后有效路由网点
    ,plt.last_valid_routed_at  最后有效路由时间
    ,case plt.is_abnormal
        when 1 then '是'
        when 0 then '否'
     end 是否异常
    ,ne.next_store_name 下一站网点
    ,group_concat(wo.order_no) 工单编号
    ,case plt.state
        when 1 then '丢失件待处理'
        when 2 then '疑似丢失件待处理'
        when 3 then '待工单回复'
        when 4 then '已工单回复'
        when 5 then '无须追责'
        when 6 then '责任人已认定'
    end 状态
    ,if(plt.fleet_routeids is null, '一致', '不一致') 解封车是否异常
    ,plt.fleet_stores 异常区间
    ,fvp.van_line_name 异常车线
    ,if(ri.id is not null, '是', '否') 是否进入已妥投未回复COD待处理
from bi_pro.parcel_lose_task plt
left join fle_staging.parcel_info pi on pi.pno = plt.pno
left join fle_staging.order_info oi on oi.pno = pi.pno
left join fle_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
left join fle_staging.sys_store ss2 on ss2.id = pi.dst_store_id
left join fle_staging.fleet_van_proof fvp on fvp.id = substring_index(plt.fleet_routeids, '/', 1)
left join dwm.dim_th_sys_store_rd  dp on dp.store_id = plt.last_valid_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
left join bi_pro.work_order wo on wo.loseparcel_task_id = plt.id
left join dwm.dwd_dim_dict ddd on ddd.element = plt.last_valid_action and ddd.db = 'rot_pro' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
left join rot_pro.parcel_route pr on pr.pno = plt.pno and pr.route_action = 'HAVE_HAIR_SCAN_NO_TO' and pr.routed_at > date_sub(curdate(), interval 2 month)
left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = plt.last_valid_staff_info_id
    left join
    (
        select
            pr.pno
            ,pr.next_store_name
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
        from rot_pro.parcel_route pr
        join  bi_pro.parcel_lose_task plt on plt.pno = pr.pno
        where
            pr.routed_at > date_sub(curdate(), interval 2 month)
            and plt.state in (1,2,3,4)
            and plt.source in (1,3,12)
            and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
    ) ne on ne.pno = plt.pno and ne.rk = 1
left join bi_pro.receivables_issues ri on ri.ss_pno = plt.pno
where
    plt.source in (1,3,12)
    and plt.state in (1, 2, 3, 4)
    and plt.created_at > date_sub(curdate(), interval 6 month)
group by plt.id