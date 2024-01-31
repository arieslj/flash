select
    a.pno
    ,concat(t2.t_value, t3.t_value) 判责原因duty_reasons
    ,a.parcel_created_at 揽收时间receive_time
    ,concat(a.CN_element, a.route_action) 最后有效路由last_effective_route
    ,convert_tz(a.routed_at, '+00:00', '+08:00') 最后有效路由时间last_effective_route_time
    ,ss.name 最后有效路由操作网点operate_network_for_last_effective_route
    ,case a.source
        WHEN 1 THEN 'A-问题件-丢失'
        WHEN 2 THEN 'B-记录本-丢失'
        WHEN 3 THEN 'C-包裹状态未更新'
        WHEN 4 THEN 'D-问题件-破损/短少'
        WHEN 5 THEN 'E-记录本-索赔-丢失'
        WHEN 6 THEN 'F-记录本-索赔-破损/短少'
        WHEN 7 THEN 'G-记录本-索赔-其他'
        WHEN 8 THEN 'H-包裹状态未更新-IPC计数'
        WHEN 9 THEN 'I-问题件-外包装破损险'
        WHEN 10 THEN 'J-问题记录本-外包装破损险'
        when 11 then 'K-超时效包裹'
        when 12 then 'L-高度疑似丢失'
    end 问题来源渠道source_of_problem
    ,concat('(', hsi.staff_info_id, ')', hsi.name) 处理人handler
    ,a.updated_at 处理时间process_time
    ,group_concat(distinct ss2.name) 责任网点duty_branch
from
    (
        select
            plt.pno
            ,plt.id
            ,plt.duty_result
            ,plt.duty_reasons
            ,plt.parcel_created_at
            ,plt.source
            ,plt.operator_id
            ,plt.updated_at
            ,ddd.CN_element
            ,pr.route_action
            ,pr.store_id
            ,pr.routed_at
            ,row_number() over (partition by plt.pno order by pr.routed_at desc ) rk
        from ph_bi.parcel_lose_task plt
        left join `ph_bi`.`translations` t on plt.duty_reasons = t.t_key AND t.`lang` = 'zh-CN'
        left join ph_staging.parcel_route pr on pr.pno = plt.pno and pr.routed_at > date_sub(plt.updated_at, interval 8 hour)
        join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.remark = 'valid'
        where
            plt.state = 6
            and plt.duty_result = 1
            and plt.updated_at >= '2023-07-20'
            and plt.updated_at < '2023-07-30'
    ) a
3
left join ph_bi.translations t3 on t3.t_key = a.duty_reasons and  t3.lang ='en'
left join ph_staging.sys_store ss on ss.id = a.store_id
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = a.operator_id
left join ph_bi.parcel_lose_responsible plr on plr.lose_task_id = a.id
left join ph_staging.sys_store ss2 on ss2.id = plr.store_id
where
    a.rk = 1
group by 1



;


# select
#     *
# from dwm.dwd_ex_ph_parcel_details de
# where
#     de.src_store regexp 'FH'
#     and de.dst_routed_at is not null
#     and de.pickup_time >= '2023-08-01'

;


select
    pi.pno
    ,pi.cod_amount/100 cod金额
from ph_staging.parcel_info pi
where
    pi.pno in ('P14112464VVAK','P14162493WGAD','P141624YSXJAD','P1416254G67AI','PT1416235EX42AB','P1416272HV1AB','P14162695TQBI','P140125RKK5BC','P110725ES5MAG','P110724SN7NAQ','P6118265EERFL','PT6118233YBG8CC','P611825P91MDG','P611824DNRVEV','P612325JSZ9AG','P612325JANVAW','P612324J7F0AW','P612324J7CBAW','P612324HFB4AW','P61232468SFAG','P612025KGJRGI','P612025JN6ZGW','P612025HV4TGI','P612025HBUMGI','P612024SQK0GJ','P612024J9Q0GW','P612024BGUGGI','P612024A45HGO','P61202468BFGW','P6120269131CX','P6120264UM4CX','P612026914GDB','P612026H7W2CY','P6120269KC2GF','P612026FZKQDA','P6120265K02CZ','P61202698ZKGF','P612026WTBTFE','P61202738K5FT','PT6121236F475AO','PT6120236R4X1GC','P612026VEXJGG','PD612026RPACDB','P612026KKRPFB','P612026U2SSGD','P612026TQ47DC','P612026NBCUGD','P612026WCGKGA','P612026VE0GGH','P612026JGV5GE','P140124PC6QAR','PT14012314TQ4BF','P140125PC1SAD','P140125PGJ4AK','P140126H02FAP','PT1401235XMT4BD','P140625GQ95AN','P120825BE4CAF','P120826N5D9AL','PT6118233S250DS','PT6118233VMM7BQ','PT611822ZVQ69AV','P611824QF7MAV','PT611823190S0AV','PT1210230YE14BS','PT61182341NK1BO','P6118264HBZDA','PT61182342888DA','PT6118233SXW9DA','PT6118233AGR4BT','PT611823349H7BT','PT61182333217DA','PT61182332VA5CR','P611825SZ65BT','P611825BBC1BT','P6118269GXGBT','P611826912GBT','PT611823608X9DA','P611826A45WDA','P611824NNP1CP','P611826TD1PCP','P611826KG3WCP','P611826SY8YCP','P611826KG3CCP','P6118268A6WCP','P611826SPX7CP','P611826K27XDA','P6118269436CP','P611826RP8FCP','P611826MMJGCR','P611826A1WACP','P6118269K8MDQ','P611826SY9JCP','P611826SYE8CP','P611826VYH6CP','P6118268DWKCP','P6121250ZZGAS','P611726BV5SAO','P140126JFCYBF','PT1401234EVN5AO','P452124WJ24DQ','P140223QSF5AE','P140224BDMEAD','P141824H16HAJ','P15162710RDBM','P6101250RZBEY','P610624SPX8GE','P610124HM95IV','P610124ZM9KHG','P611825B15RAT','P61182594CQBY','P611825K2RJDD','P612326XK8JAT','PT61182334UZ2CX','PT6118232X8A0DR','P611825R7T9DR','P6118254R98EZ')


;
 -- \



 -- 测算未打电话

with t as
(
    select
        a.*
    from
        (
            select
                pr.pno
                ,pr.staff_info_id
                ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
            from ph_staging.parcel_route pr
            left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = pr.staff_info_id
            where
                pr.routed_at >= date_sub(date_sub(curdate(), interval 1 day ), interval 8 hour)
                -- and pr.routed_at < date_sub(curdate(), interval 8 hour) -- 昨天
                and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' -- 交接扫描
                and pr.routed_at < date_sub(curdate(), interval 15 hour) -- 昨天17点
                and hsi2.job_title in (13,110,1000)
        ) a
    where
        a.rk = 1
)
select
    a1.归属大区
    ,count(if(a1.rk <= 3, a1.staff_info_id, null)) top3
    ,count(if(a1.rk <= 2, a1.staff_info_id, null)) top2
    ,count(if(a1.rk <= 1, a1.staff_info_id, null)) top1

from
    (
        select
            a.*
            ,row_number() over (partition by a.归属网点 order by a.17点前未打电话占比 desc ) rk
        from
            (
                select
                    t1.staff_info_id
                    ,dp.store_name 归属网点
                    ,dp.piece_name 归属片区
                    ,dp.region_name 归属大区
                    ,pick.pno_count  揽收量
                    ,del.pno_count 妥投量
                    ,del.forward_pno_count 正向包裹妥投量
                    ,count(distinct t1.pno) 交接扫描量
                    ,count(distinct if(ph.pno is null , t1.pno, null)) 17点前未打电话包裹量
                    ,count(distinct if(ph.pno is null , t1.pno, null))/count(distinct t1.pno) 17点前未打电话占比
                from t t1
                left join
                    (
                        select
                            pr.pno
                        from ph_staging.parcel_route pr
                        join t t1 on t1.pno = pr.pno
                        where
                            pr.routed_at >= date_sub(date_sub(curdate(), interval 1 day ), interval 8 hour)
                            and pr.routed_at < date_sub(curdate(), interval 15 hour)
                            and pr.route_action = 'PHONE'
                        group by 1
                    ) ph on ph.pno = t1.pno
                left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = t1.staff_info_id
                left join
                    (
                        select
                            t2.staff_info_id
                            ,count(pi.pno) pno_count
                        from ph_staging.parcel_info pi
                        join ( select t1.staff_info_id from t t1 group by 1) t2 on t2.staff_info_id = pi.ticket_pickup_staff_info_id
                        where
                            pi.created_at >= date_sub(date_sub(curdate(), interval 1 day ), interval 8 hour)
                            and pi.created_at < date_sub(curdate(), interval 8 hour) -- 昨天揽收
                        group by 1
                    ) pick on pick.staff_info_id = t1.staff_info_id
                left join
                    (
                        select
                            t2.staff_info_id
                            ,count(distinct pr.pno) pno_count
                            ,count(distinct if(pi.returned = 0, pr.pno, null)) forward_pno_count
                        from ph_staging.parcel_route pr
                        join ( select t1.staff_info_id from t t1 group by 1) t2 on t2.staff_info_id = pr.staff_info_id
                        left join ph_staging.parcel_info pi on pi.pno = pr.pno
                        where
                            pr.routed_at >= date_sub(date_sub(curdate(), interval 1 day ), interval 8 hour)
                            and pr.routed_at < date_sub(curdate(), interval 8 hour) -- 昨天签收
                            and pr.route_action = 'DELIVERY_CONFIRM'
                        group by 1
                    ) del on del.staff_info_id = t1.staff_info_id
                left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
                where
                    hsi.state = 1
                    and hsi.formal = 1
                    and dp.store_category = 1
                    and coalesce(pick.pno_count, 0) + coalesce(del.pno_count) < 50
                group by 1,2,3,4,5,6,7
                having count(distinct if(ph.pno is null , t1.pno, null))/count(distinct t1.pno) >= 0.6
            ) a
    ) a1
group by 1
with rollup