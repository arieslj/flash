select
    stat_date 统计日期
#     ,cod_ref_par_cnt/cod_pickup_par_cnt COD全网拒收率
#     ,sc_cod_ref_par_cnt/sc_cod_pickup_par_cnt 小cCOD拒收率
#     ,ka_cod_ref_par_cnt/ka_cod_pickup_par_cnt KACOD拒收率
#     ,plt_cod_ref_par_cnt/plt_cod_pickup_par_cnt 平台CDO拒收率
#     ,kap_cod_ref_par_cnt/kap_cod_pickup_par_cnt KAMVIP组COD拒收率
#     ,alo_cod_ref_par_cnt 'COD当日拒收单量(独立)'
#     ,alo_plt_cod_ref_par_cnt '平台cod拒收包裹数(独立)'
#     ,alo_kap_cod_ref_par_cnt 'KAPcod拒收包裹数(独立)'
#     ,alo_ka_cod_ref_par_cnt 'KAcod拒收包裹数(独立)'
#     ,alo_sc_cod_ref_par_cnt '小Ccod拒收包裹数(独立)'
#     ,alo_clm_par_amt/alo_clm_par_cnt '单票平均理赔金额'
#     ,clm_par_cnt/pickup_par_cnt 理赔票数占比
#     ,sc_clm_par_cnt/pickup_par_cnt '理赔票数占比（小C）'
#     ,ka_clm_par_cnt/pickup_par_cnt '理赔票数占比（KA）'
#     ,plt_clm_par_cnt/pickup_par_cnt '理赔票数占比（平台）'
#     ,kap_clm_par_cnt/pickup_par_cnt '理赔票数占比（KAM VIP组）'
#     ,alo_clm_par_amt '理赔金额(独立)'
#     ,alo_clm_par_cnt '理赔包裹数(独立)'
#     ,alo_plt_clm_par_cnt '平台理赔包裹数(独立)'
#     ,alo_kap_clm_par_cnt 'KAP理赔包裹数(独立)'
#     ,alo_ka_clm_par_cnt 'KA理赔包裹数(独立)'
#     ,alo_sc_clm_par_cnt '小C理赔包裹数(独立)'
    ,pickup_par_amt/pos_pickup_par_cnt '全网单均价格'
    ,retail_pickup_par_amt/retail_pickup_par_cnt 'Retail单均价格'
    ,fh_pickup_par_amt/fh_pickup_par_cnt 'FH单均价格'
    ,pos_pickup_par_cnt '全网单量'
    ,fh_pickup_par_cnt 'FH单量'
    ,retail_pickup_par_cnt 'Retail单量'
    ,plt_pickup_par_cnt '平台单量'
    ,kam_pickup_par_cnt 'KAM非平台单量'
#     ,lost_par_cnt/pos_pickup_par_cnt 遗失率
#     ,dam_par_cnt/pos_pickup_par_cnt 破损率
#     ,alo_lost_par_cnt '丢失包裹数(独立)'
#     ,alo_dam_par_cnt '破损包裹数(独立)'
#     ,over_sla_par_cnt/plt_pickup_par_cnt 超时效率
#     ,am_task_cnt/pickup_task_cnt 揽收客诉率
#     ,am_par_cnt/delivery_par_cnt 派送客诉率
#     ,alo_am_task_cnt '客诉生成处罚的任务数(独立)'
#     ,alo_am_par_cnt '客诉生成处罚的包裹数(独立)'

from dwm.dws_th_high_item_monitor_d
where stat_date >= '2023-10-01'
order by 1
;

select min(a.stat_date) from dwm.dws_th_high_item_monitor_d a