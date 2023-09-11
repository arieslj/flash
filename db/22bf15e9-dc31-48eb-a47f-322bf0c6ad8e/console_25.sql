with t as
(
    select
        t1.pno
        ,t1.client_id
        ,t1.ticket_pickup_store_id
        ,t1.cod_enabled
        ,t1.state
        ,t1.exhibition_weight
        ,t1.pick_time
        ,t1.pick_date
        ,t1.cod_amount
        ,t1.article_category
        ,max(t1.reject) reject_or_not
        ,max(t1.reject_not_purchased) not_purchased_or_not
    from
        (
            select
                pi.pno
                ,pi.client_id
                ,pi.ticket_pickup_store_id
                ,pi.cod_enabled
                ,pi.state
                ,pi.exhibition_weight
                ,pi.cod_amount
                ,pi.article_category
                ,convert_tz(pi.created_at, '+00:00', '+08:00') pick_time
                ,date(convert_tz(pi.created_at, '+00:00', '+08:00')) pick_date
                ,if(di.pno is not null , 1, 0) reject
                ,if(di.rejection_category = 1, 1, 0) reject_not_purchased
            from fle_staging.parcel_info pi
            left join fle_staging.diff_info di on di.pno = pi.pno and di.diff_marker_category in (2,17) and di.created_at >= '2023-06-01'
            where
                pi.created_at >= '2023-06-01'
                and pi.returned = 0
                and pi.state < 9
        ) t1
    group by 1,2,3,4,5,6,7,8,9,10
)
select
    a.*
from
    (
        select
            a1.pick_date 揽件日期
            ,a1.client_id 客户ID
            ,a4.客户名称
            ,a4.是否冻结过
            ,a4.当前账号开通状态
            ,a4.账号创建日期
            ,a4.归属部门
            ,a4.归属网点
            ,ss.name  正向揽件网点
            ,a1.当日总包裹
            ,a1.当日COD包裹
            ,a1.当日COD包裹率
            ,a1.拒收包裹量
            ,a1.拒收率
            ,a1.未购买量
            ,a1.未购买率
            ,a1.COD包裹退件量
            ,a1.COD包裹退件率
            ,a1.COD包裹重量1_2kg
            ,a1.COD包裹重量1_2kg占比
            ,a1.COD包裹重量3_5kg
            ,a1.COD包裹重量5以上
            ,a1.包裹最终状态_派送中
            ,a1.包裹最终状态_已滞留
            ,a1.包裹最终状态_已签收
            ,a1.包裹最终状态_疑难件处理中
            ,a1.包裹最终状态_已退件
            ,a1.平均COD金额
            ,a2.rate_d 占比最高的商品类型占比率
            ,case a2.article_category
                when 0 then '文件/document'
                when 1 then '干燥食品/dry food'
                when 2 then '日用品/daily necessities'
                when 3 then '数码产品/digital product'
                when 4 then '衣物/clothes'
                when 5 then '书刊/Books'
                when 6 then '汽车配件/auto parts'
                when 7 then '鞋包/shoe bag'
                when 8 then '体育器材/sports equipment'
                when 9 then '化妆品/cosmetics'
                when 10 then '家居用具/Houseware'
                when 11 then '水果/fruit'
                when 99 then '其它/other'
            end 占比最高的商品类型
        from
            (
                select
                    t1.pick_date
                    ,t1.client_id
                    ,t1.ticket_pickup_store_id
                    ,count(t1.pno) 当日总包裹
                    ,count(if(t1.cod_enabled = 1, t1.pno, null)) 当日COD包裹
                    ,count(if(t1.cod_enabled = 1, t1.pno, null))/count(t1.pno) 当日COD包裹率
                    ,count(if(t1.reject_or_not = 1, t1.pno, null)) 拒收包裹量
                    ,count(if(t1.reject_or_not = 1, t1.pno, null))/count(t1.pno) 拒收率
                    ,count(if(t1.not_purchased_or_not = 1, t1.pno, null)) 未购买量
                    ,count(if(t1.not_purchased_or_not = 1, t1.pno, null))/count(if(t1.reject_or_not = 1, t1.pno, null)) 未购买率
                    ,count(if(t1.cod_enabled = 1 and t1.state = 7, t1.pno, null)) COD包裹退件量
                    ,count(if(t1.cod_enabled = 1 and t1.state = 7, t1.pno, null))/count(if(t1.cod_enabled = 1, t1.pno, null)) COD包裹退件率
                    ,count(if(t1.cod_enabled = 1 and t1.exhibition_weight >= 1000 and t1.exhibition_weight < 2000, t1.pno, null)) COD包裹重量1_2kg
                    ,count(if(t1.cod_enabled = 1 and t1.exhibition_weight >= 1000 and t1.exhibition_weight < 2000, t1.pno, null))/count(if(t1.cod_enabled = 1, t1.pno, null)) COD包裹重量1_2kg占比
                    ,count(if(t1.cod_enabled = 1 and t1.exhibition_weight >= 3000 and t1.exhibition_weight < 5000, t1.pno, null)) COD包裹重量3_5kg
                    ,count(if(t1.cod_enabled = 1 and t1.exhibition_weight >= 5000, t1.pno, null)) COD包裹重量5以上
                    ,count(if(t1.cod_enabled = 1 and t1.state = 3, t1.pno, null)) 包裹最终状态_派送中
                    ,count(if(t1.cod_enabled = 1 and t1.state = 4, t1.pno, null)) 包裹最终状态_已滞留
                    ,count(if(t1.cod_enabled = 1 and t1.state = 5, t1.pno, null)) 包裹最终状态_已签收
                    ,count(if(t1.cod_enabled = 1 and t1.state = 6, t1.pno, null)) 包裹最终状态_疑难件处理中
                    ,count(if(t1.cod_enabled = 1 and t1.state = 7, t1.pno, null)) 包裹最终状态_已退件
                    ,sum(if(t1.cod_enabled = 1, t1.cod_amount/100, 0))/count(if(t1.cod_enabled = 1, t1.pno, null)) 平均COD金额
                from t  t1
                group by 1,2,3
            ) a1
        left join
            (
                select
                    a3.pick_date
                    ,a3.client_id
                    ,a3.article_category
                    ,a3.pno_num
                    ,a2.pno_num total
                    ,a3.pno_num/a2.pno_num rate_d
                    ,row_number() over (partition by a2.pick_date, a2.client_id order by a3.pno_num desc) rk
                from
                    (
                        select
                            t1.client_id
                            ,t1.pick_date
                            ,t1.article_category
                            ,count(t1.pno) pno_num
                        from t t1
                        where
                            t1.cod_enabled = 1
                        group by 1,2,3
                    ) a3
                left join
                    (
                        select
                            t1.client_id
                            ,t1.pick_date
                            ,count(t1.pno) pno_num
                        from t t1
                        where
                            t1.cod_enabled = 1
                        group by 1,2
                    ) a2 on a2.pick_date = a3.pick_date and a2.client_id = a3.client_id
            ) a2 on a2.pick_date = a1.pick_date and a2.client_id = a1.client_id and a2.rk = 1
        left join fle_staging.sys_store ss on ss.id = a1.ticket_pickup_store_id
        left join
            (
                select
                    cli.client_id
                    ,kp.name 客户名称
                    ,date(convert_tz(kp.created_at, '+00:00', '+08:00')) 账号创建日期
                    ,if(kp.state = 1, '开通', '未开通') 当前账号开通状态
                    ,sd.name 归属部门
                    ,ss2.name 归属网点
                    ,kp.staff_info_name 销售代表
                    ,si.name 项目经理
                    ,if(kaol.client_id is not null , '是', '否') 是否冻结过
                from fle_staging.ka_profile kp
                join
                    (
                        select
                            t1.client_id
                        from t t1
                        group by 1
                    ) cli on cli.client_id = kp.id
                left join fle_staging.sys_department sd on sd.id = kp.department_id
                left join fle_staging.sys_store ss2 on ss2.id = kp.store_id
                left join bi_pro.ka_cod_refuse_warning_mail  kaol on kaol.client_id = kp.id and kaol.forbid_status in (1,2,6)
                left join fle_staging.staff_info si on si.id = kp.project_manager_id
                group by 1

                union all

                select
                    ui.id client_id
                    ,ui.name 客户名称
                    ,date(convert_tz(ui.created_at, '+00:00', '+08:00')) 账号创建日期
                    ,if(ui.state = 1, '开通', '未开通') 当前账号开通状态
                    ,'' 归属部门
                    ,'' 归属网点
                    ,'' 销售代表
                    ,'' 项目经理
                    ,'' 是否冻结过
                from fle_staging.user_info ui
            ) a4 on a4.client_id = a1.client_id
    ) a
where
    a.当日COD包裹 < 300
    and (a.拒收率 >= 0.3 or a.未购买率 >= 0.5 or a.COD包裹退件率 > 0.2)

;
with t as
(
    select
        t1.pno
        ,t1.client_id
        ,t1.ticket_pickup_store_id
        ,t1.cod_enabled
        ,t1.state
        ,t1.exhibition_weight
        ,t1.pick_time
        ,t1.pick_date
        ,t1.cod_amount
        ,t1.article_category
        ,max(t1.reject) reject_or_not
        ,max(t1.reject_not_purchased) not_purchased_or_not
    from
        (
            select
                pi.pno
                ,pi.client_id
                ,pi.ticket_pickup_store_id
                ,pi.cod_enabled
                ,pi.state
                ,pi.exhibition_weight
                ,pi.cod_amount
                ,pi.article_category
                ,convert_tz(pi.created_at, '+00:00', '+08:00') pick_time
                ,date(convert_tz(pi.created_at, '+00:00', '+08:00')) pick_date
                ,if(di.pno is not null , 1, 0) reject
                ,if(di.rejection_category = 1, 1, 0) reject_not_purchased
            from fle_staging.parcel_info pi
            left join fle_staging.diff_info di on di.pno = pi.pno and di.diff_marker_category in (2,17) and di.created_at >= '2023-06-01'
            where
                pi.created_at >= '2023-06-01'
                and pi.returned = 0
                and pi.state < 9
        ) t1
    group by 1,2,3,4,5,6,7,8,9,10
)
select
    a.*
from
    (
        select
            a1.pick_date 揽件日期
            ,a1.client_id 客户ID
            ,a4.客户名称
            ,a1.当日COD包裹
            ,a1.当日COD包裹率
            ,a1.拒收包裹量
            ,a1.拒收率
            ,a1.未购买量
            ,a1.未购买率
            ,a1.COD包裹退件量
            ,a1.包裹最终状态_派送中
            ,a1.包裹最终状态_已滞留
            ,a1.包裹最终状态_已签收
            ,a1.包裹最终状态_疑难件处理中
            ,a1.包裹最终状态_已退件
        from
            (
                select
                    t1.pick_date
                    ,t1.client_id
                    ,t1.ticket_pickup_store_id
                    ,count(t1.pno) 当日总包裹
                    ,count(if(t1.cod_enabled = 1, t1.pno, null)) 当日COD包裹
                    ,count(if(t1.cod_enabled = 1, t1.pno, null))/count(t1.pno) 当日COD包裹率
                    ,count(if(t1.reject_or_not = 1, t1.pno, null)) 拒收包裹量
                    ,count(if(t1.reject_or_not = 1, t1.pno, null))/count(t1.pno) 拒收率
                    ,count(if(t1.not_purchased_or_not = 1, t1.pno, null)) 未购买量
                    ,count(if(t1.not_purchased_or_not = 1, t1.pno, null))/count(if(t1.reject_or_not = 1, t1.pno, null)) 未购买率
                    ,count(if(t1.cod_enabled = 1 and t1.state = 7, t1.pno, null)) COD包裹退件量
                    ,count(if(t1.cod_enabled = 1 and t1.state = 7, t1.pno, null))/count(if(t1.cod_enabled = 1, t1.pno, null)) COD包裹退件率
                    ,count(if(t1.cod_enabled = 1 and t1.exhibition_weight >= 1000 and t1.exhibition_weight < 2000, t1.pno, null)) COD包裹重量1_2kg
                    ,count(if(t1.cod_enabled = 1 and t1.exhibition_weight >= 1000 and t1.exhibition_weight < 2000, t1.pno, null))/count(if(t1.cod_enabled = 1, t1.pno, null)) COD包裹重量1_2kg占比
                    ,count(if(t1.cod_enabled = 1 and t1.exhibition_weight >= 3000 and t1.exhibition_weight < 5000, t1.pno, null)) COD包裹重量3_5kg
                    ,count(if(t1.cod_enabled = 1 and t1.exhibition_weight >= 5000, t1.pno, null)) COD包裹重量5以上
                    ,count(if(t1.cod_enabled = 1 and t1.state = 3, t1.pno, null)) 包裹最终状态_派送中
                    ,count(if(t1.cod_enabled = 1 and t1.state = 4, t1.pno, null)) 包裹最终状态_已滞留
                    ,count(if(t1.cod_enabled = 1 and t1.state = 5, t1.pno, null)) 包裹最终状态_已签收
                    ,count(if(t1.cod_enabled = 1 and t1.state = 6, t1.pno, null)) 包裹最终状态_疑难件处理中
                    ,count(if(t1.cod_enabled = 1 and t1.state = 7, t1.pno, null)) 包裹最终状态_已退件
                    ,sum(if(t1.cod_enabled = 1, t1.cod_amount/100, 0))/count(if(t1.cod_enabled = 1, t1.pno, null)) 平均COD金额
                from t  t1
                group by 1,2,3
            ) a1
        left join
            (
                select
                    a3.pick_date
                    ,a3.client_id
                    ,a3.article_category
                    ,a3.pno_num
                    ,a2.pno_num total
                    ,a3.pno_num/a2.pno_num rate_d
                    ,row_number() over (partition by a2.pick_date, a2.client_id order by a3.pno_num desc) rk
                from
                    (
                        select
                            t1.client_id
                            ,t1.pick_date
                            ,t1.article_category
                            ,count(t1.pno) pno_num
                        from t t1
                        where
                            t1.cod_enabled = 1
                        group by 1,2,3
                    ) a3
                left join
                    (
                        select
                            t1.client_id
                            ,t1.pick_date
                            ,count(t1.pno) pno_num
                        from t t1
                        where
                            t1.cod_enabled = 1
                        group by 1,2
                    ) a2 on a2.pick_date = a3.pick_date and a2.client_id = a3.client_id
            ) a2 on a2.pick_date = a1.pick_date and a2.client_id = a1.client_id and a2.rk = 1
        left join fle_staging.sys_store ss on ss.id = a1.ticket_pickup_store_id
        left join
            (
                select
                    cli.client_id
                    ,kp.name 客户名称
                    ,date(convert_tz(kp.created_at, '+00:00', '+08:00')) 账号创建日期
                    ,if(kp.state = 1, '开通', '未开通') 当前账号开通状态
                    ,sd.name 归属部门
                    ,ss2.name 归属网点
                    ,kp.staff_info_name 销售代表
                    ,si.name 项目经理
                    ,if(kaol.client_id is not null , '是', '否') 是否冻结过
                from fle_staging.ka_profile kp
                join
                    (
                        select
                            t1.client_id
                        from t t1
                        group by 1
                    ) cli on cli.client_id = kp.id
                left join fle_staging.sys_department sd on sd.id = kp.department_id
                left join fle_staging.sys_store ss2 on ss2.id = kp.store_id
                left join bi_pro.ka_cod_refuse_warning_mail  kaol on kaol.client_id = kp.id and kaol.forbid_status in (1,2,6)
                left join fle_staging.staff_info si on si.id = kp.project_manager_id
                group by 1

                union all

                select
                    ui.id client_id
                    ,ui.name 客户名称
                    ,date(convert_tz(ui.created_at, '+00:00', '+08:00')) 账号创建日期
                    ,if(ui.state = 1, '开通', '未开通') 当前账号开通状态
                    ,'' 归属部门
                    ,'' 归属网点
                    ,'' 销售代表
                    ,'' 项目经理
                    ,'' 是否冻结过
                from fle_staging.user_info ui
            ) a4 on a4.client_id = a1.client_id
    ) a
where
    a.当日COD包裹 >= 300
    and a.拒收率 >= 0.3
    or a.未购买率 >= 0.5