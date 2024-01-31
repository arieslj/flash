select
    t.name
    , t.所属大区
    , t.所属片区
    , sum(if(t.是否应该集包 = '应该集包', 1, 0)) as '应集包数量'
    , sum(if(t.是否应该集包 = '不应该集包', 1, 0)) as '不应该集包数量'
    , sum(if(t.是否集包 = '集包' and t.是否应该集包 = '应该集包', 1, 0)) as '应集包且实际集包数量'
    , sum(if(t.是否集包 = '集包' and t.是否应该集包 = '应该集包', 1, 0)) / sum(if(t.是否应该集包 = '应该集包', 1, 0)) as '集包率'
    , sum(if(t.是否集包 = '集包' and t.是否应该集包 = '不应该集包', 1, 0)) as '不应集包且实际集包数量'
#     , max(coalesce(pkl.揽收包裹数,0)) as 揽收包裹数
#     , max(coalesce(pkl.未发出包裹数,0)) as 未发出包裹数
from
    (
        select
            distinct
            ss.`name`
            , date(ft.`real_leave_time`) real_date
            , mr.`name` as '所属大区'
            , mp.`name` as '所属片区'
            , pi.pno,
            if(pi.exhibition_weight <= 3000
            and pi.exhibition_length <= 30
            and pi.exhibition_width <= 30
            and pi.`article_category` <> 11
            and pi.exhibition_height <= 30
            and pi.exhibition_length + pi.exhibition_width + pi.exhibition_height <= 60
            and dst.category != 10
            , '应该集包', '不应该集包') as '是否应该集包'
            , fv.pack_no
            , if(fv.pack_no is null, '未集包', '集包') as '是否集包'
        from `ph_staging`.`fleet_van_proof_parcel_detail` fv
        join `ph_staging`.`parcel_info` pi on pi.`pno` = fv.`recent_pno`
        join ph_staging.sys_store dst on pi.dst_store_id = dst.id
        left join ph_bi.fleet_time ft on ft.proof_id = fv.proof_id and ft.store_id = fv.store_id
        join `ph_staging`.`sys_store` ss on ss.`id` = ft.`store_id`
        left join ph_staging.sys_manage_region mr on ss.manage_region = mr.`id`
        left join ph_staging.sys_manage_piece mp on ss.manage_piece = mp.`id`
        where pi.`state` <> 9
            and pi.`returned` = 0
#             and ft.`real_leave_time` >= date_add (current_date(), interval -24 hour)
#             and ft.`real_leave_time` < current_date()
            and ft.real_leave_time >= '2023-06-01'
            and ft.real_leave_time < '2023-07-01'
            and ss.category in (1, 4, 5, 7, 10,14)
            and ss.id = pi.ticket_pickup_store_id
    )t
# left join
#     (
#         select
#             store_name
#             ,stat_date
#             ,count(distinct pno) as 揽收包裹数
#             ,count(distinct if(leave_src_time is not null
#                                or dst_valid_route_time is not null
#                                or par_valid_route_time is not null
#                                or par_par_valid_route_time is not null
#                                ,null,pno)) as 未发出包裹数
#
#             from dwm.dwd_ph_pickup_leave_detl_rd
#             where
# #                 stat_date = date_sub(date(date_sub(now(), interval 1 hour)), 1)
#                 stat_date >= '2023-06-01'
#                 and stat_date < '2023-07-01'
#             group by 1
#     )pkl on t.name = pkl.store_name and t.real_date = pkl.stat_date
group by 1, 2, 3
order by 2, 3, 1
;