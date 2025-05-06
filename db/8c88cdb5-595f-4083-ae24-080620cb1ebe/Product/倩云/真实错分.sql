-- 错分包裹明细（虚假错分或不确定）
SELECT distinct pi.pno
    ,pi.client_id
    ,pi.p_date '揽收日期'
    ,pi.finished_at '妥投时间(泰国时间)'
    ,if(di.diff_marker_category ='31','是','否') '是否上报地址错分件'
    ,if(pi.ticket_delivery_store_id is null,'不确定',if(dif.store_id =pi.ticket_delivery_store_id or if(ex.ex_store is not null,ex.ex_store,pi.dst_store_id)=pi.ticket_delivery_store_id,'虚假错分','非虚假错分')) '是否虚假错分（首次上报错分网点或初始网点=最终派件网点）'
    ,if(ex.ex_store is not null,ex.ex_store,pi.dst_store_id) '初始网点id'
    ,dif.store_id '首次上报错分网点ID'
    , pi.ticket_delivery_store_id '最终派件网点ID'
    ,dif.staff_info_id '首次上报地址错分员工id'
    ,dif.created_at '首次上报错分时间(泰国时间)'
from
    (
        select
            *
        from fle_staging.parcel_info pi
        where p_date>='2024-04-01' and p_date<'2024-05-02'
        and finished_at>='2024-05-01' and finished_at<'2024-05-02' -- 限制发送自动邮件的前一天妥投
    )pi
join (select * from fle_dwd.dwd_fle_diff_info_di
where p_date>='2024-04-01'and diff_marker_category ='31'
)di on pi.pno=di.pno

left JOIN (SELECT * from (select pno, diff_marker_category ,store_id ,staff_info_id,created_at ,row_number() over(partition by pno,diff_marker_category order by created_at) as rnf
from fle_dwd.dwd_fle_diff_info_di
where p_date>='2024-04-01' and diff_marker_category ='31')tmp where rnf=1
) dif on pi.pno=dif.pno

left join
    (
        select
            pno,
            if(pre_store is not null,pre_store,get_json_object(complete_object,'$.dst_store_id')) as ex_store -- '首次换单前的网点'
        from
            (
                select
                    * ,
                    row_number() over(partition by pno order by created_at asc) as rnasc
                from
                    (
                        -- 获取近三天换单明细
                        select pno,
                            complete_object,
                            -- 换单前后地址信息
                            get_json_object(before_object,'$.dst_store_id') as pre_store,
                            created_at -- 换单时间
                        from fle_dwd.dwd_fle_parcel_info_version_di
                        where p_date >='2024-04-01'
                    ) as ert
            ) f where rnasc=1
    ) ex on ex.pno=pi.pno

;



with t as
    (
        select
            distinct
            di.pno
            ,pi.dst_store_id
            ,pi.ticket_delivery_store_id
            ,pi.finished_at
        from fle_staging.diff_info di
        join fle_staging.parcel_info pi on pi.pno = di.pno
        where
            di.created_at > '2024-06-17 17:00:00'
            and di.diff_marker_category = 31
    )
select
    count(distinct a1.pno) 错分总量
    ,count(distinct if(pssn.pno is not null, a1.pno, null)) 经过HUB量
    ,count(distinct if(pssn.pno is not null, a1.pno, null)) / count(distinct a1.pno) 占比
from
    (
        select
            distinct
            t1.pno
            ,t1.finished_at
            ,dif.created_at
        from t t1
        left join
            (
                select
                    di.store_id
                    ,di.pno
                    ,di.staff_info_id
                    ,di.created_at
                    ,row_number() over (partition by di.pno order by di.created_at ) as rnf
                from fle_staging.diff_info di
                join t t1 on t1.pno = di.pno
                where
                    di.created_at > date_sub(curdate(), interval 2 month)
                    and di.diff_marker_category = 31
            ) dif on t1.pno = dif.pno and dif.rnf = 1
        left join
            (
                select
                    a.*
                    ,if(a.old_value is not null, a.old_value, a.new_value) as ex_store
                from
                    (
                        select
                            pcd.pno
                            ,pcd.old_value
                            ,pcd.new_value
                            ,pcd.created_at
                            ,row_number() over (partition by pcd.pno order by pcd.created_at) rk
                        from fle_staging.parcel_change_detail pcd
                        join t t1 on t1.pno = pcd.pno
                        where
                            pcd.created_at > date_sub(curdate(), interval 2 month)
                            and pcd.field_name = 'dst_store_id'
                    ) a
                where
                    a.rk = 1
            ) ex on t1.pno = ex.pno
        where
            dif.store_id != t1.ticket_delivery_store_id
            and  if(ex.ex_store is not null ,ex.ex_store ,t1.dst_store_id) != t1.ticket_delivery_store_id
    ) a1
left join dw_dmd.parcel_store_stage_new pssn on pssn.pno = a1.pno and pssn.valid_store_order is not null and pssn.first_valid_routed_at > a1.created_at and pssn.first_valid_routed_at <= a1.finished_at and pssn.store_category in (8,12)
;





with t as
    (
        select
            distinct
            di.pno
            ,pi.dst_store_id
            ,pi.ticket_delivery_store_id
            ,pi.finished_at
        from fle_staging.diff_info di
        join fle_staging.parcel_info pi on pi.pno = di.pno
        where
            di.created_at > '2024-06-17 17:00:00'
            and di.diff_marker_category = 31
            -- and di.pno = 'TH04065SEMEF5A0'
    )
select
    a1.pno
    ,group_concat(distinct pssn.store_name) 经过的HUB
from
    (
        select
            distinct
            t1.pno
            ,t1.finished_at
            ,dif.created_at
        from t t1
        left join
            (
                select
                    di.store_id
                    ,di.pno
                    ,di.staff_info_id
                    ,di.created_at
                    ,row_number() over (partition by di.pno order by di.created_at ) as rnf
                from fle_staging.diff_info di
                join t t1 on t1.pno = di.pno
                where
                    di.created_at > date_sub(curdate(), interval 2 month)
                    and di.diff_marker_category = 31
            ) dif on t1.pno = dif.pno and dif.rnf = 1
        left join
            (
                select
                    a.*
                    ,if(a.old_value is not null, a.old_value, a.new_value) as ex_store
                from
                    (
                        select
                            pcd.pno
                            ,pcd.old_value
                            ,pcd.new_value
                            ,pcd.created_at
                            ,row_number() over (partition by pcd.pno order by pcd.created_at) rk
                        from fle_staging.parcel_change_detail pcd
                        join t t1 on t1.pno = pcd.pno
                        where
                            pcd.created_at > date_sub(curdate(), interval 2 month)
                            and pcd.field_name = 'dst_store_id'
                    ) a
                where
                    a.rk = 1
            ) ex on t1.pno = ex.pno
        where
            dif.store_id != t1.ticket_delivery_store_id
            and  if(ex.ex_store is not null ,ex.ex_store ,t1.dst_store_id) != t1.ticket_delivery_store_id
    ) a1
left join dw_dmd.parcel_store_stage_new pssn on pssn.pno = a1.pno and pssn.valid_store_order is not null and pssn.first_valid_routed_at > a1.created_at and pssn.first_valid_routed_at <= a1.finished_at and pssn.store_category in (8,12)
group by a1.pno


;



select
    di.store_id
    ,di.pno
    ,di.staff_info_id
    ,di.created_at
    ,row_number() over (partition by di.pno order by di.created_at ) as rnf
from fle_staging.diff_info di
-- join t t1 on t1.pno = di.pno
where
    di.created_at > date_sub(curdate(), interval 2 month)
    and di.diff_marker_category = 31
    and di.pno = 'TH04065SEMEF5A0'
;


select
    *
from dw_dmd.parcel_store_stage_new pssn
where
    pssn.pno = 'TH04065SEMEF5A0'

;



select
    min(pi.created_at)
from fle_staging.parcel_info pi