-- 待处理
with t as
    (
        select
            plt.created_at
            ,plt.pno
            ,plt.client_id
            ,s1.name src_store_name
            ,s2.name dst_store_name
            ,plt.parcel_created_at
            ,plt.last_valid_action
            ,plt.last_valid_routed_at
            ,plt.last_valid_store_id
        from ph_bi.parcel_lose_task plt
        left join ph_staging.parcel_info pi on pi.pno = plt.pno
        left join ph_staging.sys_store s1 on s1.id = pi.ticket_pickup_store_id
        left join ph_staging.sys_store s2 on s2.id = pi.dst_store_id
        where
            plt.created_at > date_sub(date_sub(curdate(), interval 7 day), interval 8 hour)
            and plt.client_id in ('AA0131', 'AA0132', 'AA0166')
            and s1.name not in ('PLW_SP','PRC_SP','NAR_SP','NBC_SP','PUT_SP','BRZ_SP','TAY_SP','ARN_SP','BPT_SP','IHG_SP','SMI_SP')
            and s2.name not in ('PLW_SP','PRC_SP','NAR_SP','NBC_SP','PUT_SP','BRZ_SP','TAY_SP','ARN_SP','BPT_SP','IHG_SP','SMI_SP')
            and plt.state in (1,2,3,4)
    )
select
    t1.created_at 任务生成时间
    ,t1.pno 运单号
    ,t1.client_id 客户ID
    ,t1.src_store_name 揽收网点
    ,t1.dst_store_name 目的地网点
    ,t1.parcel_created_at 揽件时间
    ,ddd.CN_element 最后有效路由
    ,t1.last_valid_routed_at 最后有效路由时间
    ,ss.name 最后有效路由操作网点
    ,a1.next_store_name 下一站网点
    ,datediff(current_date(), t1.created_at) 进入闪速系统X天
    ,datediff(curdate(), dd.end_date) 超SLA天数
from t t1
left join dwm.dwd_dim_dict ddd on ddd.element = t1.last_valid_action and  ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
left join ph_staging.sys_store ss on ss.id = t1.last_valid_store_id
left join
    (
        select
            dt.pno
            ,dt.end_date
        from dwm.dwd_ex_ph_tiktok_sla_detail dt
        where
            dt.pick_date >= date_sub(curdate(), interval 3 month)
    ) dd on dd.pno = t1.pno
left join
    (
        select
            pr.pno
            ,pr.next_store_name
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
        from ph_staging.parcel_route pr
        join
            (
                select t.pno from t group by 1
            ) t2 on t2.pno = pr.pno
        left join
            (
                select
                    a.*
                from
                    (
                        select
                            pr2.pno
                            ,pr2.id
                            ,row_number() over (partition by pr2.pno order by pr2.routed_at desc) rk
                        from ph_staging.parcel_route pr2
                        join
                            (
                                select t.pno from t group by 1
                            ) t2 on t2.pno = pr2.pno
                        where
                            pr2.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
                            and pr2.routed_at > date_sub(current_date(), interval 2 month)
                    ) a
                where
                    a.rk = 1
            ) a1 on a1.pno = pr.pno
        where
            pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
            and pr.routed_at > date_sub(current_date(), interval 2 month)
            and pr.id > ifnull(a1.id, 0)
    ) a1 on a1.pno = t1.pno and a1.rk = 1


;


