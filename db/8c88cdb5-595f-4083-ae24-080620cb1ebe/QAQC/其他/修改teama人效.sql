SELECT
    operator_id,
    name,
    count(if(d.penalties > 0, d.idd, null)) 总处理合计,
    sum(case
       when `action`=1 then 1
       when `action`=3 and `source` in (1,2,3) and d.penalties > 0 then 1
       when `action`=3 and `source` in (5,8,11) and d.penalties > 0 then 3
       when `action`=3 and `source` in (4,6,7) and d.penalties > 0 then 5
       when `action`=4 and `source` in (3,8) and d.penalties > 0 then 3
       when `action`=4 and `source` in (1,4,11) and d.penalties > 0 then 5
       when `action`=4 and `source` in (2,5,6,7) and d.penalties > 0 then 7
       else 0
       end as '得分'
       ) 综合人效得分
FROM
    (
        SELECT
            d.idd
            ,operator_id
            ,name,source
            ,日期วันที่
            ,action
            ,d.penalties
        FROM
            (
                SELECT
                    a.id
                    ,a.operator_id
                    , b.name
                    , c.`source`
                    , DATE_FORMAT(a.created_at, '%Y-%m-%d') as '日期วันที่'
                    , a.action
                    ,CONCAT(c.pno, c.`source`, a.action) idd
                    ,c.penalties
                FROM bi_pro.parcel_cs_operation_log a
                LEFT JOIN bi_pro.hr_staff_info b ON a.operator_id= b.staff_info_id
                LEFT JOIN bi_pro.parcel_lose_task c ON a.task_id= c.id
                WHERE a.type= 1
                    AND a.action IN(1, 3, 4)
                    AND DATE_FORMAT(a.created_at, '%Y-%m-%d') >= '${date}'
                    and  DATE_FORMAT(a.created_at, '%Y-%m-%d') <= '${date1}'
                    and a.operator_id!='10000'
                GROUP BY a.id
            ) d
        GROUP BY d.idd
    )d
 GROUP BY 1,2
 ORDER BY 1;

SELECT
    a.日期วันที่
    ,a.operator_id
    ,a.name
    ,a.'动作'
    ,b.'A-问题件-丢失'
    ,b.'B-记录本-丢失'
    ,b.'C-包裹状态未更新'
    ,b.'D-问题件-破损/短少'
    ,b.'E-记录本-索赔-丢失'
    ,b.'F-记录本-索赔-破损/短少'
    ,b.'G-记录本-索赔-其他'
    ,b.'H-包裹状态未更新-IPC计数'
    ,b.'K-超时效包裹'
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
                    case a.`action`
                        WHEN 1 then '发工单数量จำนวนTicketที่สร้างไป'
                        when 4 then '已判责数量จำนวนเคสที่ตัดสินไป'
                        when 3 then '无需追责数量ตัดสิน【ยกเลิกการตัดสิน】จำนวนครั้ง'
                    end as '动作'
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
        SELECT
            日期วันที่,
            operator_id,
            name,
            case `action`
                WHEN 1 then '发工单数量จำนวนTicketที่สร้างไป'
                when 4 then '已判责数量จำนวนเคสที่ตัดสินไป'
                when 3 then '无需追责数量ตัดสิน【ยกเลิกการตัดสิน】จำนวนครั้ง'
            end as '动作',
            count(distinct(if(`source`=1,d.idd,null))) 'A-问题件-丢失',
            count(distinct(if(`source`=2,d.idd,null))) 'B-记录本-丢失',
            count(distinct(if(`source`=3,d.idd,null))) 'C-包裹状态未更新',
            count(distinct(if(`source`=4,d.idd,null))) 'D-问题件-破损/短少',
            count(distinct(if(`source`=5,d.idd,null))) 'E-记录本-索赔-丢失',
            count(distinct(if(`source`=6,d.idd,null))) 'F-记录本-索赔-破损/短少',
            count(distinct(if(`source`=7,d.idd,null))) 'G-记录本-索赔-其他',
            count(distinct(if(`source`=8,d.idd,null))) 'H-包裹状态未更新-IPC计数',
            count(distinct(if(`source`=11,d.idd,null))) 'K-超时效包裹'
        FROM
            (
                SELECT
                    DATE_FORMAT(a.created_at, '%Y-%m-%d') as '日期วันที่'
                     , a.id
                     ,a.operator_id
                     , b.name
                     , a.action
                     ,c.`source`
                     ,c.pno
                     ,CONCAT(c.pno, c.`source`, a.action) idd
                FROM bi_pro.parcel_cs_operation_log a
                LEFT JOIN bi_pro.hr_staff_info b ON a.operator_id= b.staff_info_id
                LEFT JOIN bi_pro.parcel_lose_task c ON a.task_id= c.id
                WHERE
                    a.type= 1
                    AND a.action IN(1, 3, 4)
                    AND DATE_FORMAT(a.created_at, '%Y-%m-%d') >= '${date}'
                    and  DATE_FORMAT(a.created_at, '%Y-%m-%d') <=
                    and a.operator_id!='10000'
                    and ${if(len(operator_id)>0," a.operator_id in ('"+operator_id+"')",1=1)}
                GROUP BY 8
            ) d
        GROUP BY 日期วันที่,operator_id, 动作
        ORDER BY 日期วันที่,operator_id,动作
     ) b on a.operator_id=b.operator_id and a.动作=b.动作 and a.日期วันที่ = b.日期วันที่
 where
 	 a.operator_id!='10000'
 ORDER BY 1,2,3,4;

-- 新代码

select
    pcol.pno
    ,pcol.id
    ,pcol.action
    ,plt.source
from bi_pro.parcel_cs_operation_log pcol
left join bi_pro.parcel_lose_task plt on plt.id = pcol.task_id
where
    pcol.type = 1 -- 闪速认定
    and pcol.created_at >= '${date}'
    and pcol.created_at < date_add('${date1}', interval 1 day)
    and pcol.action in (1,3,4)