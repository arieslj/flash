SELECT
    *
FROM
    (
        SELECT
            a.日期วันที่
            , b.operator_id
            , b.name
            ,a.动作
        FROM
            (
                SELECT
                    DATE_FORMAT(a.created_at, '%Y-%m-%d') as '日期วันที่',
                    a.`action`
                FROM bi_pro.parcel_cs_operation_log a
                WHERE
                    a.type= 1
                    AND a.action IN(1, 3, 4)
                    AND DATE_FORMAT(a.created_at, '%Y-%m-%d') >= '${date}'
                    and  DATE_FORMAT(a.created_at, '%Y-%m-%d') <= '${date1}'
                    and ${if(len(operator_id)>0," a.operator_id in ('"+operator_id+"')",1=1)}
                    GROUP BY 1,2
            ) a
        left join
            (
                select
                    DATE_FORMAT(a.created_at, '%Y-%m-%d') as '日期วันที่'
                     , a.operator_id,b.name
                FROM bi_pro.parcel_cs_operation_log a
                LEFT JOIN bi_pro.hr_staff_info b ON a.operator_id= b.staff_info_id
                WHERE a.type= 1
                    AND a.action IN(1, 3, 4)
                    AND DATE_FORMAT(a.created_at, '%Y-%m-%d') >= '${date}'
                    and  DATE_FORMAT(a.created_at, '%Y-%m-%d') <= '${date1}'
                    and a.operator_id!='10000'
                    and ${if(len(operator_id)>0," a.operator_id in ('"+operator_id+"')",1=1)}
                    GROUP BY 1,2
            ) b on a.日期วันที่=b.日期วันที่
    ) a
left join
    (
        select
            date_format(pcol.created_at, '%y-%m-%d') date_d
            ,pcol.operator_id
            ,pcol.action
            ,pcol.id
        from bi_pro.parcel_cs_operation_log pcol
        left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = pcol.operator_id
        where
            pcol.type = 1 -- 闪速认定
            and pcol.action = 1 -- 创建工单
            and date_format(pcol.created_at, '%y-%m-%d') >= '${date}'
            and date_format(pcol.created_at, '%y-%m-%d') <= '${date1}'
            and pcol.operator_id != '10000'
            and ${if(len(operator_id)>0," a.operator_id in ('"+operator_id+"')",1=1)}

        union all

        select
            date_format(pcol.created_at, '%y-%m-%d') date_d
            ,pcol.operator_id
            ,pcol.action
            ,max(pcol.id) id
        from bi_pro.parcel_cs_operation_log pcol
        left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = pcol.operator_id
        where
            pcol.type = 1 -- 闪速认定
            and pcol.action in (3,4) -- 判责/无需追责
            and date_format(pcol.created_at, '%y-%m-%d') >= '${date}'
            and date_format(pcol.created_at, '%y-%m-%d') <= '${date1}'
            and pcol.operator_id != '10000'
            and ${if(len(operator_id)>0," a.operator_id in ('"+operator_id+"')",1=1)}
        group by 1,2,3
    ) b