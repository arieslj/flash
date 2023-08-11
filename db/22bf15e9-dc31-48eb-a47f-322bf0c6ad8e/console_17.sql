select
            a.store_id
            ,count(distinct a.code) code_num
        from
            (
                select
                    sts.store_id
                    ,sts.sorting_code code
                from fle_staging.sys_three_sorting sts
                where
                    sts.deleted = 0

                union all

                select
                    stf.store_id
                    ,stf.sorting_fence_code code
                from fle_staging.sys_three_fence_sorting stf
                where
                    stf.deleted = 0
            ) a

where
    a.store_id in ('TH01470132','TH01080144','TH01420113','TH04060232','TH02030523','TH01010127','TH01390232','TH02010234','TH02030329','TH02030432','TH65010808','TH01180135','TH01050214','TH20070230','TH01410223','TH01430144','TH02030132','TH19070136','TH68040618','TH04060162','TH67010525','TH67010432','TH01220311','TH02010631')
        group by 1

;
















select
    pcr.operator_id 操作员工工号
    ,pcr.operator_name 操作员工姓名
    ,pcd.new_value 修改后的号码
    ,pr.store_id 网点ID
    ,pr.store_name 网点名称
    ,count(distinct pcd.pno) 修改数量
    ,group_concat(distinct pcd.pno) 修改号码运单号
from fle_staging.parcel_change_detail pcd
left join fle_staging.parcel_change_record pcr on pcd.record_id = pcr.id
left join rot_pro.parcel_route pr on pr.pno = pcr.pno and json_extract(pr.extra_value, '$.parcelChangeId') = pcr.id and pr.route_action = 'CHANGE_PARCEL_INFO'
where
    pcd.field_name in ('dst_phone')
    and pcd.created_at > '2023-06-30 16:00:00'
    and pcd.created_at < '2023-07-31 16:00:00'
group by 1,2,3,4,5

;


select
    count(1) c
     , pr.`operator_id`
     ,pd.`new_value`
     , group_concat(pr.`pno`)
     ,si.`name`
     ,ss.id
     ,ss.`name`
from fle_staging. `parcel_change_record` pr
left join fle_staging.`parcel_change_detail` pd on pd.`record_id` = pr.`id`
left join fle_staging.`staff_info` si on si.`id` = pr.`operator_id`
left join fle_staging.`sys_store` ss on ss.`id` = si.`organization_id`
left join fle_staging.`parcel_info` pi on pi.`pno` = pr.pno
where
    pd.`field_name` = 'dst_phone'
    and pr.`created_at` > '2023-06-30 17:00:00'
    and pi.`dst_store_id` = ss.`id`
group by pr.`operator_id` ,pd.`new_value`
having c > 2

;
























