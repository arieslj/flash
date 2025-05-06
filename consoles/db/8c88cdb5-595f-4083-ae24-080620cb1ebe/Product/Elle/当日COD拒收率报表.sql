-- 需求文档：https://flashexpress.feishu.cn/wiki/OGbLw0Yp4i8jjskT62gcs3N0nog

select
    cis.stat_date COD交接日期
    ,cis.client_id 客户ID
    ,sd.name 归属部门
    ,ss2.name 归属网点
    ,kp.staff_info_name 销售代表
    ,si.name 项目经理
    ,cis.today_cod_handover_count COD包裹交接量
    ,cis.today_cod_refuse_count 当日交接的COD包裹拒收量
    ,cis.today_cod_refuse_count / cis.today_cod_handover_count 当日交接的COD包裹拒收率
    ,cis.today_cod_refuse_not_purchased_count 当日交接被拒收原因为未购买量
    ,cis.today_cod_refuse_not_purchased_count / cis.today_cod_refuse_count 当日交接被拒收原因为未购买率
    ,cis.today_delivered_count 当日交接的COD妥投量
    ,cis.today_delivered_count / cis.today_cod_handover_count 当日交接的COD妥投率
from bi_pro.cod_info_stat_day_emr cis
left join fle_staging.ka_profile kp on kp.id = cis.client_id
left join fle_staging.sys_department sd on sd.id = kp.department_id
left join fle_staging.sys_store ss2 on ss2.id = kp.store_id
left join fle_staging.staff_info si on si.id = kp.project_manager_id
where
    cis.client_id in ('${SUBSTITUTE(SUBSTITUTE(client_id,"\n",","),",","','")}')
    and cis.stat_date >= '${start_date}'
    and cis.stat_date <= '${end_date}'
    and cis.customer_type_category = 2

union all

select
    cis.stat_date COD交接日期
    ,cis.client_id 客户ID
    ,'' 归属部门
    ,'' 归属网点
    ,'' 销售代表
    ,'' 项目经理
    ,cis.today_cod_handover_count COD包裹交接量
    ,cis.today_cod_refuse_count 当日交接的COD包裹拒收量
    ,cis.today_cod_refuse_count / cis.today_cod_handover_count 当日交接的COD包裹拒收率
    ,cis.today_cod_refuse_not_purchased_count 当日交接被拒收原因为未购买量
    ,cis.today_cod_refuse_not_purchased_count / cis.today_cod_refuse_count 当日交接被拒收原因为未购买率
    ,cis.today_delivered_count 当日交接的COD妥投量
    ,cis.today_delivered_count / cis.today_cod_handover_count 当日交接的COD妥投率
from bi_pro.cod_info_stat_day_emr cis
# left join fle_staging.user_info ui on ui.id = cis.client_id
where
    cis.client_id in ('${SUBSTITUTE(SUBSTITUTE(client_id,"\n",","),",","','")}')
    and cis.stat_date >= '${start_date}'
    and cis.stat_date <= '${end_date}'
    and cis.customer_type_category = 1