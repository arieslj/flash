select
    t.当前网点 name
    ,t.当前网点大区 大区
    ,t.当前网点片区 片区
    ,count(distinct (t.单号)) GrandTotal
    ,count(distinct if(t.今日最后交接扫描时间 is not null,t.单号,null)) 当天交接
    ,count(distinct if(t.今日最后交接扫描时间 is null,t.单号,null)) 当天还未交接
    ,count(distinct if(t.state='已签收' or t.退件状态= '已签收',t.单号,null)) 已妥投
    ,count(distinct if(t.昨日最后盘库时间 is not null or t.今日最后盘库时间 is not null,t.单号,null)) 有盘库
    ,count(distinct if(t.昨日最后盘库时间 is null and t.今日最后盘库时间 is null,t.单号,null)) 未盘库
    ,count(distinct if(今日最后交接扫描时间 is not null,t.单号,null))/count(distinct (t.单号)) 交接率
    ,count(distinct if(t.state='已签收' or t.退件状态= '已签收',t.单号,null))/count(distinct (t.单号)) 妥投率
from
    (
        SELECT
            if(pi.returned_pno is null, tt.pno, pi.`returned_pno`)  单号
            , pi.`client_id` 客户
            , tt.`screening_date`
            , pr.last_store_name 当前网点
            , sme.`name` 当前网点大区
            , smp.`name` 当前网点片区
            , tt.basis_type
            , case when pi.state= '1' then '已揽收'
                  when pi.state= '2' then '运输中'
                  when pi.state= '3' then '派送中'
                  when pi.state= '4' then '已滞留'
                  when pi.state= '5' then '已签收'
                  when pi.state= '6' then '疑难件处理中'
                  when pi.state= '7' then '已退件'
                  when pi.state= '8' then '异常关闭'
                  when pi.state= '9' then '已撤销' else null end as state
            , case when pin.state= '1' then '已揽收'
                  when pin.state= '2' then '运输中'
                  when pin.state= '3' then '派送中'
                  when pin.state= '4' then '已滞留'
                  when pin.state= '5' then '已签收'
                  when pin.state= '6' then '疑难件处理中'
                  when pin.state= '7' then '已退件'
                  when pin.state= '8' then '异常关闭'
                  when pin.state= '9' then '已撤销' else null end as 退件状态
            , case when pi.discard_enabled= '1' then '丢弃' when pi.discard_enabled= '0' then '未丢弃' end as '是否丢弃'
            , case when pin.discard_enabled= '1' then '丢弃' when pin.discard_enabled= '0' then '未丢弃' end as '退件是否丢弃'
            , pm.yesterday_distribution 昨日最后盘库时间
            , pm.today_distribution 今日最后盘库时间
            , pm.today_scan 今日最后交接扫描时间
            , pc.trytimes 尝试妥投次数
        FROM `ph_staging`.`parcel_priority_delivery_detail` tt
        left join `ph_staging`.`parcel_info` pi on pi.pno= tt.pno
        left join `ph_staging`.parcel_info pin on pi.`returned_pno`= pin.pno
        left join
            (
                select
                     pd.pno
                    ,pd.last_store_id
                    ,pd.last_store_name
                    ,pd.last_route_action
                from dwm.dwd_ex_ph_parcel_details pd
                where pd.pick_date>=date_sub(curdate(),interval 4 month)
            )  pr on pr.pno= if(pi.returned_pno is null, pi.pno, pi.returned_pno)
        left join
            (
                select
                  pr.pno
                  , max(if(pr.route_action in ('DISTRIBUTION_INVENTORY', 'INVENTORY')  and date(convert_tz(pr.`routed_at`, '+00:00', '+08:00')) =date_sub(curdate(), interval 1 day),
                    convert_tz(pr.`routed_at`, '+00:00', '+08:00'), null)) 'yesterday_distribution'
                  , max(if(pr.route_action in ('DISTRIBUTION_INVENTORY', 'INVENTORY')  and date(convert_tz(pr.`routed_at`, '+00:00', '+08:00')) =curdate(),
                    convert_tz(pr.`routed_at`, '+00:00', '+08:00'), null)) 'today_distribution'
                  , max(if(pr.route_action= 'DELIVERY_TICKET_CREATION_SCAN' and date(convert_tz(pr.`routed_at`, '+00:00', '+08:00')) =curdate(),
                    convert_tz(pr.`routed_at`, '+00:00', '+08:00'), null)) 'today_scan'
                from `ph_staging`.`parcel_route`as pr
                where pr.`routed_at`>= convert_tz(date_sub(CURRENT_DATE, interval 2 day), '+08:00', '+00:00')
                and pr.`route_action` in('DISTRIBUTION_INVENTORY', 'DELIVERY_TICKET_CREATION_SCAN', 'INVENTORY')
                group by 1
            ) pm on pm.pno= if(pi.returned_pno is null, pi.pno, pi.returned_pno)

        left join
            (
                select
                     pno
                     , rnk
                     , count(distinct p_date)  trytimes
                from
                (
                  select
                    pr.`pno`
                    , pr.marker_category
                    , pr.`route_action`
                    , date_format(convert_tz(pr.routed_at, '+00:00', '+08:00'), '%Y-%m-%d')  p_date
                    , convert_tz(pr.routed_at, '+00:00', '+08:00')  routed_at
                    , row_number() over(partition by pr.pno, substring(convert_tz(pr.routed_at, '+00:00', '+08:00'), 1, 10)  order by convert_tz(pr.routed_at, '+00:00', '+08:00'))  rnk
                  from ph_staging.parcel_route pr
                  where pr.`route_action` in('DELIVERY_MARKER', 'DELIVERY_CONFIRM')
                  and pr.`routed_at`>= convert_tz(date_sub(CURRENT_DATE, interval 60 day), '+08:00', '+00:00'))  t
                  WHERE rnk= 1
                  group by 1, 2
            ) pc on pc.pno= if(pi.returned_pno is null, pi.pno, pi.returned_pno)
        left join `ph_staging`.`sys_store` ss on pr.last_store_id= ss.id
        left join ph_staging.sys_manage_region sme on ss.manage_region= sme.id
        left join ph_staging.sys_manage_piece smp on ss.manage_piece= smp.id
        where tt.`screening_date`=curdate()

    )t
GROUP BY 1,2,3
order by 1,2,3
