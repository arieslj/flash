     /*
        =====================================================================+
        表名称：1590d_ph_ka_ge_3try_pending_return_pno
        功能描述：菲律宾非平台客户三次尝试派送待退件包裹

        需求来源：
        编写人员: 吕杰
        设计日期：2023-06-30
      	修改日期:
      	修改人员:
      	修改原因:
      -----------------------------------------------------------------------
      ---存在问题：
      -----------------------------------------------------------------------
      +=====================================================================
      */

 with t as
(
    select
        de.pno
        ,de.dst_store_id
        ,de.dst_store
        ,de.dst_region
        ,de.dst_piece
        ,pi.state
        ,pi.dst_phone
        ,pi.dst_home_phone
        ,if(pcd.pno is not null , 'y', 'n') change_store
        ,max(pcd.created_at) pcd_create_at
    from ph_staging.parcel_info pi
    left join dwm.dwd_ex_ph_parcel_details de on de.pno = pi.pno
    left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
    left join ph_staging.parcel_change_detail pcd on pcd.pno = pi.pno and pcd.field_name = 'dst_store_id' and pcd.new_value != pcd.old_value
    where
        pi.state not in (5,7,8,9)
        and bc.client_id is null
        and  ( pi.interrupt_category != 3 or pi.interrupt_category is null )
        and pi.created_at >= date_sub(date_sub(curdate(), interval 2 month), interval 8 hour) -- 10天内揽收
    group by 1
)
select
    t1.pno 'Tracking number'
    ,t1.dst_store 'Destination Branch'
    ,convert_tz(las.created_at, '+00:00', '+08:00') 'Last Attempts Failed Time'
    ,las.EN_element 'Last Marking Status'
#     ,t1.dst_store_id 目的网点ID
#     ,t1.dst_piece 目的地片区
#     ,t1.dst_region 目的地大区
#     ,case t1.state
#         when '1' then '已揽收'
#         when '2' then '运输中'
#         when '3' then '派送中'
#         when '4' then '已滞留'
#         when '5' then '已签收'
#         when '6' then '疑难件处理中'
#         when '7' then '已退件'
#         when '8' then '异常关闭'
#         when '9' then '已撤销'
#     end as `包裹状态`
    ,t1.dst_phone 'Customer phone number'
   -- ,t1.dst_home_phone 收件人家庭电话
    ,count(distinct mark.mark_date) 'Delivery Attempts made'
from t t1
left join
    (
        select
            td.pno
            ,date(convert_tz(tdm.created_at, '+00:00', '+08:00')) mark_date
        from ph_staging.ticket_delivery td
        join t t1 on t1.pno = td.pno
        left join ph_staging.ticket_delivery_marker tdm on tdm.delivery_id = td.id
        where
            if(t1.change_store = 'n', 1 = 1, tdm.created_at > t1.pcd_create_at)
            and td.created_at > date_sub(curdate(), interval 90 day)
            and tdm.marker_id not in (3,4,5,6,7,15,18,19,20,21,22,32,41,43,69,71)
        group by 1,2
    ) mark on mark.pno = t1.pno
left join
    (
        select
            ppd.pno
            ,ppd.diff_marker_category
            ,ddd.EN_element
            ,ppd.created_at
            ,row_number() over (partition by ppd.pno order by ppd.created_at desc ) rk
        from ph_staging.parcel_problem_detail ppd
        join t t1 on t1.pno = ppd.pno
        left join dwm.dwd_dim_dict ddd on ddd.element = ppd.diff_marker_category and ddd.db = 'ph_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
        where
            ppd.created_at > date_sub(curdate(), interval 90 day)
    ) las on las.pno = mark.pno and las.rk = 1
where
    mark.mark_date is not null
#     and las.diff_marker_category  in (1,40)
group by 1
having count(distinct mark.mark_date) >= 3


