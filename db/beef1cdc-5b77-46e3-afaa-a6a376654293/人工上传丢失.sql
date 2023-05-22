select
    plt.id
from
    (
        select
            plt.id
            ,plt.pno
            ,plt.source_id
        from fle_dwd.dwd_bi_parcel_lose_task_di plt
        where
            plt.p_date >= '2023-01-01'
            and plt.state in (1,2,3,4)
            and plt.source = 1
    ) plt
left join
    (
        select
            pr.pno
            ,cdt.id
        from
            (
                select
                    pr.pno
                    ,get_json_object(pr.extra_value, '$.diffInfoId') diff_info_id
                from fle_dwd.dwd_rot_parcel_route_di pr
                where
                    pr.p_date >= '2023-01-01'
                    and pr.remark = 'SS Judge Auto Created For Overtime'
            ) pr
        join
            (
                select
                    cdt.diff_info_id
                    ,cdt.id
                from fle_dwd.dwd_fle_customer_diff_ticket_di  cdt
                where
                    cdt.p_date >= '2023-01-01'
            ) cdt on cdt.diff_info_id = pr.diff_info_id
    ) a on plt.source_id = a.id
where
    a.id is null