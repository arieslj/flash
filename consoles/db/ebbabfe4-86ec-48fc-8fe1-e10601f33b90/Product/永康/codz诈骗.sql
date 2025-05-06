with t as
(
    select
        t1.pno
        ,t1.client_id
        ,t1.ticket_pickup_store_id
        ,t1.cod_enabled
        ,t1.state
        ,t1.pick_ss
        -- ,t1.exhibition_weight
        ,t1.pick_time
        ,t1.pick_date
        ,t1.di_time
        ,t1.di_date
        ,t1.fin_date
        ,t1.cod_amount
        ,t1.article_category
        ,t1.reject reject_or_not
        ,t1.reject_not_purchased not_purchased_or_not
    from
        (
            select
                distinct
                pi.pno
                ,pi.client_id
                ,pi.ticket_pickup_store_id
                ,pi.cod_enabled
                ,pi.state
                ,ss.name pick_ss
               -- ,pi.exhibition_weight
                ,pi.cod_amount
                ,pi.article_category
                ,convert_tz(di.created_at, '+00:00', '+08:00') di_time
                ,date(convert_tz(di.created_at, '+00:00', '+08:00')) di_date
                ,convert_tz(pi.created_at, '+00:00', '+08:00') pick_time
                ,date(convert_tz(pi.created_at, '+00:00', '+08:00')) pick_date
                ,if(di.pno is not null , 1, 0) reject
                ,if(di.rejection_category = 1, 1, 0) reject_not_purchased
                ,if(pi.state = 5, date(convert_tz(pi.finished_at, '+00:00', '+08:00')), null) fin_date
                ,row_number() over (partition by pi.pno order by di.created_at desc) rk
            from my_staging.parcel_info pi
            left join my_staging.diff_info di on di.pno = pi.pno and di.diff_marker_category in (2,17) and di.created_at >= '2024-01-01'
            left join my_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
            where
                pi.created_at >= '2024-04-30 16:00:00'
                and pi.created_at < '2024-05-31 16:00:00'
                and pi.returned = 0
                and pi.state < 9
        ) t1
    where
        t1.rk = 1
   -- group by 1,2,3,4,5,6,7,8,9,10
)

select
    a.*
#     ,row_number() over (partition by a.客户ID,a.揽件日期 order by a.当日COD包裹 desc ) rk
from
    (
        select
            a1.pick_date 揽件日期
            ,a1.client_id 客户ID
            ,a4.客户名称
            ,a4.是否冻结过
            ,a4.当前账号开通状态
            ,a4.是否禁止下单
            ,a4.账号创建日期
            ,a4.归属部门
            ,a4.归属网点
            ,a1.pick_ss 揽件网点
            ,a4.销售代表
            ,a4.项目经理
            ,a1.当日总包裹
            ,a1.当日COD包裹
            ,a1.当日COD包裹率
            ,a1.COD拒收包裹量
            ,a1.COD包裹拒收率
            ,a1.COD未购买量
            ,a1.COD未购买率
            ,a1.COD未购买进入问题记录本量
            ,a1.客诉率
            ,a1.COD包裹退件量
            ,a1.COD包裹退件率
            ,a1.COD包裹妥投量
            ,a1.COD包裹妥投率
            ,a1.揽件当日COD拒收包裹数量
            ,a1.揽件当日COD拒收包裹率
            ,a1.揽件当日COD未购买裹数量
            ,a1.揽件当日COD未购买包裹率
            ,a1.揽件当日COD包裹妥投成功量
            ,a1.揽件当日COD包裹妥投成功率
            ,a1.平均COD金额
        from
            (
                select
                    t1.pick_date
                    ,t1.client_id
                    ,t1.pick_ss
#                     ,t1.ticket_pickup_store_id
                    ,count(distinct t1.pno) 当日总包裹
                    ,count(distinct if(t1.cod_enabled = 1, t1.pno, null)) 当日COD包裹
                    ,count(distinct if(t1.cod_enabled = 1, t1.pno, null))/count(distinct t1.pno) 当日COD包裹率
                    ,count(distinct if(t1.reject_or_not = 1 and t1.cod_enabled = 1, t1.pno, null)) COD拒收包裹量
                    ,count(distinct if(t1.reject_or_not = 1 and t1.cod_enabled = 1, t1.pno, null))/count(distinct if(t1.cod_enabled = 1, t1.pno, null)) COD包裹拒收率
                    ,count(distinct if(t1.not_purchased_or_not = 1 and t1.cod_enabled = 1, t1.pno, null)) COD未购买量
                    ,count(distinct if(t1.not_purchased_or_not = 1 and t1.cod_enabled = 1, t1.pno, null))/count(distinct if(t1.reject_or_not = 1 and t1.cod_enabled = 1, t1.pno, null)) COD未购买率
                    ,count(distinct if(t1.not_purchased_or_not = 1 and t1.cod_enabled = 1 and ci.pno is not null, t1.pno, null)) COD未购买进入问题记录本量
                    ,count(distinct if(t1.not_purchased_or_not = 1 and t1.cod_enabled = 1 and ci.pno is not null, t1.pno, null))/count(distinct if(t1.reject_or_not = 1 and t1.cod_enabled = 1, t1.pno, null)) 客诉率
                    ,count(distinct if(t1.cod_enabled = 1 and t1.state = 7, t1.pno, null)) COD包裹退件量
                    ,count(distinct if(t1.cod_enabled = 1 and t1.state = 7, t1.pno, null))/count(distinct if(t1.cod_enabled = 1, t1.pno, null)) COD包裹退件率
                    ,count(distinct if(t1.cod_enabled = 1 and t1.state = 5, t1.pno, null))  COD包裹妥投量
                    ,count(distinct if(t1.cod_enabled = 1 and t1.state = 5, t1.pno, null))/count(distinct if(t1.cod_enabled = 1, t1.pno, null)) COD包裹妥投率
                    ,sum(if(t1.cod_enabled = 1, t1.cod_amount/100, 0))/count(distinct if(t1.cod_enabled = 1, t1.pno, null)) 平均COD金额
                    ,count(distinct if(t1.reject_or_not = 1 and t1.cod_enabled = 1 and t1.di_date = t1.pick_date, t1.pno, null)) 揽件当日COD拒收包裹数量
                    ,count(distinct if(t1.reject_or_not = 1 and t1.cod_enabled = 1 and t1.di_date = t1.pick_date, t1.pno,null))/count(distinct if(t1.cod_enabled = 1, t1.pno, null))  揽件当日COD拒收包裹率
                    ,count(distinct if(t1.not_purchased_or_not = 1 and t1.cod_enabled = 1 and t1.di_date = t1.pick_date, t1.pno, null)) 揽件当日COD未购买裹数量
                    ,count(distinct if(t1.not_purchased_or_not = 1 and t1.cod_enabled = 1 and t1.di_date = t1.pick_date, t1.pno, null))/count(distinct if(t1.reject_or_not = 1 and t1.cod_enabled = 1, t1.pno, null)) 揽件当日COD未购买包裹率
                    ,count(distinct if(t1.cod_enabled = 1 and t1.state = 5 and t1.pick_date = t1.fin_date, t1.pno, null)) 揽件当日COD包裹妥投成功量
                    ,count(distinct if(t1.cod_enabled = 1 and t1.state = 5 and t1.pick_date = t1.fin_date, t1.pno, null))/count(distinct if(t1.cod_enabled = 1, t1.pno, null)) 揽件当日COD包裹妥投成功率
                from t  t1
                left join my_staging.customer_issue ci on ci.pno = t1.pno and ci.request_sup_type = 14 and ci.request_sub_type = 144
                group by 1,2,3
            ) a1
#         left join my_staging.sys_store ss on ss.id = a1.ticket_pickup_store_id
        left join
            (
                select
                    cli.client_id
                    ,kp.name 客户名称
                    ,date(convert_tz(kp.created_at, '+00:00', '+08:00')) 账号创建日期
                    ,if(kp.state = 1, '开通', '未开通') 当前账号开通状态
                    ,if(kp.forbid_call_order = 0, '否', '是') 是否禁止下单
                    ,sd.name 归属部门
                    ,ss2.name 归属网点
                    ,kp.staff_info_name 销售代表
                    ,si.name 项目经理
                    ,if(kaol.ka_id is not null , '是', '否') 是否冻结过
                from my_staging.ka_profile kp
                join
                    (
                        select
                            t1.client_id
                        from t t1
                        group by 1
                    ) cli on cli.client_id = kp.id
                left join my_staging.sys_department sd on sd.id = kp.department_id
                left join my_staging.sys_store ss2 on ss2.id = kp.store_id
                left join my_bi.ka_cod_refuse_warning_mail  kaol on kaol.ka_id = kp.id and kaol.forbid_status in (1,2,6)
                left join my_staging.staff_info si on si.id = kp.project_manager_id
                group by 1

                union all

                select
                    ui.id client_id
                    ,ui.name 客户名称
                    ,date(convert_tz(ui.created_at, '+00:00', '+08:00')) 账号创建日期
                    ,if(ui.state = 1, '开通', '未开通') 当前账号开通状态
                    ,if(ui.forbid_call_order = 0, '否', '是') 是否禁止下单
                    ,'' 归属部门
                    ,'' 归属网点
                    ,'' 销售代表
                    ,'' 项目经理
                    ,if(kaol.ka_id is not null , '是', '否') 是否冻结过
                from my_staging.user_info ui
                left join my_bi.ka_cod_refuse_warning_mail  kaol on kaol.ka_id = ui.id and kaol.forbid_status in (1,2,6)
            ) a4 on a4.client_id = a1.client_id
    ) a