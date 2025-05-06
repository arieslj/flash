select
    cis.stat_date 统计日期
    ,cis.client_id
    ,case cis.customer_type_category
        when 1 then '小c'
        when 2 then 'KA'
    end 客户类型
    ,cis.today_cod_handover_count COD包裹交接量
    ,cis.today_cod_refuse_count 当日交接的COD包裹拒收量
    ,cis.today_cod_refuse_count / cis.today_cod_handover_count 当日交接的COD包裹拒收率
    ,cis.today_cod_refuse_not_purchased_count 当日交接被拒收原因为未购买量
    ,cis.today_cod_refuse_not_purchased_count / cis.today_cod_refuse_count 当日交接被拒收原因为未购买率
    ,cis.today_delivered_count 当日交接的COD妥投量
    ,cis.today_delivered_count / cis.today_cod_handover_count 当日交接的COD妥投率
from my_bi.cod_info_stat_day_emr cis
where
    cis.stat_date >= '2024-07-01'
    and cis.stat_date < '2024-08-01'