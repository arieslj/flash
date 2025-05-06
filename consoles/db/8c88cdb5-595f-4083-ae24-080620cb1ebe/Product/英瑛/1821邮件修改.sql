with t as
    (
        select
            di.id
            ,convert_tz(di.created_at,'+00:00','+07:00') created_at
            ,convert_tz(pi.created_at,'+00:00','+07:00') pi_created_at
            ,di.pno
            ,ddd.cn_element
            ,ddd2.CN_element rejection
            ,pi.ticket_pickup_store_id
            ,pi.client_id
            ,cdt.state
            ,cdt.organization_type
            ,cdt.organization_id
            ,cdt.vip_enable
            ,cdt.service_type
            ,pi.customary_pno
            ,pi.article_category
            ,pd.last_valid_store_id
            ,convert_tz(cdt.updated_at,'+00:00','+07:00') updated_at
            ,convert_tz(cdt.first_operated_at,'+00:00','+07:00') first_operated_at
        from fle_staging.diff_info di
        join fle_staging.parcel_info pi on di.pno=pi.pno
        left join fle_staging.customer_diff_ticket cdt on cdt.diff_info_id=di.id
        join dwm.dwd_dim_dict ddd on ddd.element=di.diff_marker_category and ddd.db='fle_staging' and ddd.tablename='diff_info' and ddd.fieldname='diff_marker_category'
        left join dwm.dwd_dim_dict ddd2 on di.rejection_category = ddd2.element and ddd2.db='fle_staging' and ddd2.tablename='diff_info' and ddd2.fieldname='rejection_category'
        left join bi_pro.parcel_detail pd on pd.pno = pi.pno
        left join nl_production.violation_return_visit vrv on vrv.link_id = di.pno and vrv.visit_state in (0,1,2) and vrv.type = 3
        where
            pi.created_at>=date_sub(current_date,interval 3 month)
            and di.created_at<=date_sub(current_date,interval 7 hour)
            and (pi.state=6 or (cdt.state=1 and date(convert_tz(cdt.updated_at,'+00:00','+07:00'))=date_sub(current_date,interval 1 day)))
            and cdt.state in (0,2,3,4)
            and (cdt.operator_id not in (10001,10000) or  cdt.operator_id is null)
            and vrv.link_id is null
    )

select
    case
      when di.organization_type=2 and di.vip_enable=1 and cg.name in ('Bulky BD') then 'Bulky Business Development'
      when di.organization_type=2 and di.vip_enable=1 and cg.name in ('Group VIP Customer') then 'Retail Management'
      when di.organization_type=2 and di.vip_enable=1 and cg.name in ('LAZADA','TikTok','Shopee','KAM CN','THAI KAM') then 'PMD'
      when di.organization_type=2 and di.vip_enable=1 and cg.name in ('FFM') then 'FFM'
      when di.organization_type=2 and di.vip_enable=0 then '总部cs'
      when ((di.organization_type=1 and (di.service_type != 3 or di.service_type is null) and di.vip_enable=0)
            or (di.organization_type=1 and di.vip_enable=0 and di.service_type = 3)) then 'Mini CS'
    end '部门แผนกที่จัดการ'
    ,case when di.organization_type=2 and di.vip_enable=1 then cg.name
      when di.organization_type=2 and di.vip_enable=0 then '总部cs'
      when coalesce(ss.category,ss2.category) in (11) then 'FFM'
      when coalesce(ss.category,ss2.category) in (4,5,7) then 'SHOP'
      when coalesce(ss.category,ss2.category) in (1,9,10,13,14) then 'NW'
      when coalesce(ss.category,ss2.category) = 6 or (di.organization_type=1 and di.vip_enable=0 and di.service_type = 3) then 'FH'
      when coalesce(ss.category,ss2.category) in (8,12) then 'HUB'
    end as '处理组织ทีมที่จัดการ'
    ,ss.name '问题件待处理网点สาขาที่จัดการ'
    ,di.pno '包裹号เลขพัสดุ'
    ,di.client_id
    ,di.pi_created_at '揽收时间เวลารับงาน'
    ,case di.article_category
        when 0 then '文件/document'
        when 1 then '干燥食品/dry food'
        when 2 then '日用品/daily necessities'
        when 3 then '数码产品/digital product'
        when 4 then '衣物/clothes'
        when 5 then '书刊/Books'
        when 6 then '汽车配件/auto parts'
        when 7 then '鞋包/shoe bag'
        when 8 then '体育器材/sports equipment'
        when 9 then '化妆品/cosmetics'
        when 10 then '家居用具/Houseware'
        when 11 then '水果/fruit'
        when 99 then '其它/other'
    end '包裹类型ประเภทพัสดุ'
    ,di.customary_pno '退件前单号'
    ,dt.store_name '当前所处网点'
    ,dt.piece_name '当前所处片区'
    ,dt.region_name '当前所处大区'
    ,di.CN_element  '问题件类型ประเภทคำร้อง'
    ,di.rejection 拒收原因
    ,di.created_at '问题件生成时间เวลาที่ติดปัญหาเข้าระบบ'
    ,case di.state
     when 0 then '客服未处理'
     when 1 then '已处理完毕'
     when 2 then '正在沟通中'
     when 3 then '财务驳回'
     when 4 then '客户未处理'
     when 5 then '转交闪速系统'
     when 6 then '转交QAQC'
     end as '处理状态สถานะจัดการปัจจุบัน'
    ,datediff(current_date,date(di.created_at)) '问题件生成天数'
    ,d2.di_count 问题件提交次数
    ,convert_tz(d3.created_at, '+00:00', '+07:00') 第一次提交问题件时间
    ,datediff(curdate(), di.pi_created_at) 揽收至今天数
from t di
left join
    (
        select
            t1.pno
            ,count(distinct di.id) di_count
        from fle_staging.diff_info di
        join t t1 on t1.pno = di.pno
        where
            di.created_at > date_sub(curdate(), interval 6 month )
        group by 1
    ) d2 on d2.pno = di.pno
left join
    (
        select
            t1.pno
            ,di.created_at
            ,row_number() over (partition by t1.pno order by di.created_at) rk
        from fle_staging.diff_info di
        join t t1 on t1.pno = di.pno
        where
            di.created_at > date_sub(curdate(), interval 6 month )
    ) d3 on d3.pno = di.pno and d3.rk = 1
left join fle_staging.sys_store ss on di.ticket_pickup_store_id=ss.id
left join fle_staging.sys_store ss2 on di.organization_id=ss2.id
left join fle_staging.customer_group_ka_relation cgk on cgk.ka_id=di.client_id and cgk.deleted=0
left join fle_staging.customer_group cg on cg.id=cgk.customer_group_id
left join dwm.dim_th_sys_store_rd dt on dt.store_id = di.last_valid_store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
group by 1,2,3,4,5