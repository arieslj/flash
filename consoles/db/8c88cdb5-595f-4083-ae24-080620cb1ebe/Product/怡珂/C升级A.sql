select
    distinct
    pr.pno
from rot_pro.parcel_route pr
where
    pr.route_action = 'DIFFICULTY_HANDOVER'
    and pr.remark = 'SS Judge Auto Created For Overtime'
    and pr.routed_at > '2024-03-31 17:00:00'
    and pr.routed_at < '2024-04-01 17:00:00'
;


select
    *
from
    (

        select
            a.*
            ,pr.staff_info_id
            s ,pr.store_name
            ,row_number() over (partition by a.pno order by pr.routed_at desc) as rn
        from
            (
                select
                    pr.pno
                    ,case pi.state
                          when 1 then '已揽收'
                          when 2 then '运输中'
                          when 3 then '派送中'
                          when 4 then '已滞留'
                          when 5 then '已签收'
                          when 6 then '疑难件处理中'
                          when 7 then '已退件'
                          when 8 then '异常关闭'
                          when 9 then '已撤销'
                          else pi.state
                      end as '包裹状态'
                    ,'无责解锁' type
                from rot_pro.parcel_route pr
                join bi_pro.parcel_lose_task plt on plt.pno = pr.pno and plt.source = 1
                left join fle_staging.parcel_info pi on pi.pno = pr.pno
                where
                    pr.route_action = 'DIFFICULTY_HANDOVER'
                    and pr.remark = 'SS Judge Auto Created For Overtime'
                    and pr.routed_at > '2024-03-31 17:00:00'
                    and pr.routed_at < '2024-04-01 17:00:00'
                    and plt.created_at > '2024-04-01'
                    and plt.created_at < '2024-04-02'
                    and plt.state = 5

                union

                select
                    pr.pno
                    ,case pi.state
                          when 1 then '已揽收'
                          when 2 then '运输中'
                          when 3 then '派送中'
                          when 4 then '已滞留'
                          when 5 then '已签收'
                          when 6 then '疑难件处理中'
                          when 7 then '已退件'
                          when 8 then '异常关闭'
                          when 9 then '已撤销'
                          else pi.state
                      end as '包裹状态'
                    ,'判责丢失解锁' type
                from rot_pro.parcel_route pr
                join bi_pro.parcel_lose_task plt on plt.pno = pr.pno and plt.source = 1
                left join bi_pro.parcel_detail pd on pd.pno = pr.pno
                left join fle_staging.parcel_info pi on pi.pno = pr.pno
                where
                    pr.route_action = 'DIFFICULTY_HANDOVER'
                    and pr.remark = 'SS Judge Auto Created For Overtime'
                    and pr.routed_at > '2024-03-31 17:00:00'
                    and pr.routed_at < '2024-04-01 17:00:00'
                    and plt.created_at > '2024-04-01'
                    and plt.created_at < '2024-04-02'
                    and plt.state = 6
                    and pd.resp_store_updated >= plt.updated_at
            ) a
        left join rot_pro.parcel_route pr on if(a.包裹状态 = '异常关闭', a.pno, null) = pr.pno and pr.route_action  = 'CHANGE_PARCEL_CLOSE' and pr.routed_at > '2024-03-31 17:00:00'
    ) a
where
    a.rn = 1

;


with t as
    (
        select
            plt.pno
            ,date(plt.created_at) as p_date
        from bi_pro.parcel_lose_task plt
        where
            plt.state in (1,2,3,4)
            and plt.source = 1
    )
select
    t1.pno
    ,if(a.pno is null, '否', '是') as '是否升级到A'
from t t1
left join
    (
        select
            pr.pno
        from rot_pro.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'DIFFICULTY_HANDOVER'
            and pr.remark = 'SS Judge Auto Created For Overtime'
            and pr.routed_at > date_sub(t1.p_date, interval 7 hour)
            and pr.routed_at < date_add(t1.p_date, interval 17 hour)
        group by 1
    ) a on t1.pno = a.pno