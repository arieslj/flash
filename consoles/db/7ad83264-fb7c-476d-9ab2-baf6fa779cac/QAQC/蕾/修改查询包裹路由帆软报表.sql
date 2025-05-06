select
    distinct
     pi.pno
    ,pi.recent_pno
    ,convert_tz(pr2.last_valid_routed_at, '+00:00', '+08:00') 最后有效路由操作时间
    ,pr2.CN_element 最后有效路由动作
    ,pr2.last_valid_route_staff_id 最后有效路由操作人
    ,pr2.store_name 最后有效路由网点
    ,pr3.times 交接次数
    ,case
        when pi.state='1' then '已揽收'
        when pi.state='2' then '运输中'
        when pi.state='3' then '派送中'
        when pi.state='4' then '已滞留'
        when pi.state='5' then '已签收'
        when pi.state='6' then '疑难件处理中'
        when pi.state='7' then '已退件'
        when pi.state='8' then '异常关闭'
        when pi.state='9' then '已撤销'
        else null
    end as 包裹状态
from
    (
        select
            pi.pno
            ,pi.state
            ,pi.recent_pno
        from ph_staging.parcel_info pi
        where
            pi.recent_pno in ('${SUBSTITUTE(SUBSTITUTE(p2,"\n",","),",","','")}')

        union all

        select
        pi.pno
            ,pi.state
            ,pi.recent_pno
        from ph_staging.parcel_info pi
        where
            pi.pno in ('${SUBSTITUTE(SUBSTITUTE(p2,"\n",","),",","','")}')
    )pi
left join
    (
        select
            pssn.pno
            ,pssn.last_valid_route_action
            ,concat(ddd.CN_element, ddd.EN_element) CN_element
            ,pssn.last_valid_routed_at
            ,pssn.store_name
            ,pssn.last_valid_route_staff_id
            ,row_number() over(partition by pssn.pno order by pssn.last_valid_routed_at desc) rn
        from dw_dmd.parcel_store_stage_new pssn
        left join dwm.dwd_dim_dict ddd on ddd.element = pssn.last_valid_route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
        where
            pssn.pno in ('${SUBSTITUTE(SUBSTITUTE(p2,"\n",","),",","','")}')
            and pssn.created_at > date_sub(curdate(), interval 90 day)
#     and pno in ('${SUBSTITUTE(SUBSTITUTE(p2,"\n",","),",","','")}')
    ) pr2 on pi.pno = pr2.pno and pr2.rn = 1
left join
    (
          select
            pr.pno
            ,count(distinct date (convert_tz(pr.routed_at,'+00:00','+08:00'))) times
          from ph_staging.parcel_route pr
          where
              pr.route_action in ('DELIVERY_TICKET_CREATION_SCAN')
              and pno in ('${SUBSTITUTE(SUBSTITUTE(p2,"\n",","),",","','")}')
              and pr.routed_at >= date_sub(convert_tz(curdate(),'+08:00','+00:00'),interval 60 day)
            group by 1
    )pr3 on pi.pno = pr3.pno

