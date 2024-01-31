select
    a.pno
    ,di.num '上报错分次数'
    ,ss.name '妥投网点'
    ,pcd. '初始目的地网点/修改信息网点1'
    ,pcd.'修改后目的地网点1' 第一次修改后网点
    ,pcd.'修改信息网点2' 第2次修改前网点
    ,pcd.'修改后目的地网点2' 第2次修改后网点
    ,pcd.'修改信息网点3' 第3次修改前网点
    ,pcd.'修改后目的地网点3' 第3次修改后网点
    ,pcd.'修改信息网点4' 第4次修改前网点
    ,pcd.'修改后目的地网点4' 第4次修改后网点
    ,pcd.'修改信息网点5' 第5次修改前网点
    ,pcd.'修改后目的地网点5' 第5次修改后网点
    ,pcd.'修改信息网点6' 第6次修改前网点
    ,pcd.'修改后目的地网点6' 第6次修改后网点
    ,pcd.'修改信息网点7' 第7次修改前网点
    ,pcd.'修改后目的地网点7' 第7次修改后网点
    ,ifnull(pcd1.old_value,'未修改邮编') '初始邮编'
    ,a.dst_postal_code '最终邮编'
#     ,if(pcd1.old_value is null or pcd1.old_value=pi1.dst_postal_code,'是','否')'初始邮编和最终邮编是否相同'
#     ,case when a.dst_postal_code<>pcd1.old_value and pcd1.old_value is not null then '客户原因-目的地邮编有误'
#     when pcd1.old_value is null then 'HUB错分'
#     when pcd1.old_value=a.dst_postal_code and pcd1.old_value is not null then 'flash原因'
#     end '责任归属'
    ,ifnull(pcd2.old_value,'未修改详细地址') '初始详细地址'
    ,a.dst_detail_address '最终详细地址'
from
    (
        select
            distinct
            dd.pno
        from ph_staging.diff_info dd
        where
            dd.created_at>='2023-03-01'
            and dd.diff_marker_category='31'
    )dd
join ph_staging.parcel_info a on dd.pno = a.pno
left join ph_bi.sys_store ss on a.ticket_delivery_store_id = ss.id
left join
    (
        select
            pcd.pno
            ,max(if(pcd.rank=1,pcd.name,null)) '初始目的地网点/修改信息网点1'
            ,max(if(pcd.rank=1,pcd.name1,null)) '修改后目的地网点1'
            ,max(if(pcd.rank=2,pcd.name,null)) '修改信息网点2'
            ,max(if(pcd.rank=2,pcd.name1,null)) '修改后目的地网点2'
            ,max(if(pcd.rank=3,pcd.name,null)) '修改信息网点3'
            ,max(if(pcd.rank=3,pcd.name1,null)) '修改后目的地网点3'
            ,max(if(pcd.rank=4,pcd.name,null)) '修改信息网点4'
            ,max(if(pcd.rank=4,pcd.name1,null)) '修改后目的地网点4'
            ,max(if(pcd.rank=5,pcd.name,null)) '修改信息网点5'
            ,max(if(pcd.rank=5,pcd.name1,null)) '修改后目的地网点5'
            ,max(if(pcd.rank=6,pcd.name,null)) '修改信息网点6'
            ,max(if(pcd.rank=6,pcd.name1,null)) '修改后目的地网点6'
            ,max(if(pcd.rank=7,pcd.name,null)) '修改信息网点7'
            ,max(if(pcd.rank=7,pcd.name1,null)) '修改后目的地网点7'
        from
            (
                select
                    pcd.pno
                    ,ss.name
                    ,ss1.name name1
                    ,row_number()over(partition by pcd.pno order by pcd.created_at asc) rank
                from ph_staging.parcel_change_detail pcd
                left join ph_bi.sys_store ss on ss.id=pcd.old_value
                left join ph_bi.sys_store ss1 on ss1.id=pcd.new_value
                where
                    pcd.created_at>=CURRENT_DATE()-interval 30 day
                    and pcd.field_name='dst_store_id'
            )pcd
        group by 1
    )pcd on pcd.pno = a.pno
left join
    (
        select
            di.pno
            ,count(di.pno) num
        from ph_staging.diff_info di
        where
            di.created_at>=CURRENT_DATE()-interval 30 day
            and di.diff_marker_category in (30,31)
        group by 1
    )di on di.pno=a.pno
left join
    (
        select
            pcd.pno
            ,pcd.old_value
            ,row_number()over(partition by pcd.pno order by pcd.created_at asc)rank
        from ph_staging.parcel_change_detail pcd
        where
            pcd.created_at>=CURRENT_DATE()-interval 30 day
            and pcd.field_name='dst_postal_code'
    )pcd1 on a.pno=pcd1.pno and pcd1.rank = 1
left join
    (
        select
            pi.pno
            ,pi.dst_postal_code
            ,pi.dst_detail_address
        from ph_staging.parcel_info pi
        where
            pi.created_at>=CURRENT_DATE()-interval 40 day
    )pi1 on pi1.pno = a.pno
left join
    (
        select
            pcd.pno
            ,pcd.old_value
            ,row_number()over(partition by pcd.pno order by pcd.created_at asc)rank
        from ph_staging.parcel_change_detail pcd
        where
            pcd.created_at>=CURRENT_DATE()-interval 30 day
            and pcd.field_name='dst_detail_address'
    )pcd2 on a.pno=pcd2.pno and pcd2.rank = 1
where
    ss.name =pcd.`初始目的地网点/修改信息网点1`

