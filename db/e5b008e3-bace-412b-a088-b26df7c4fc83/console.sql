with t as
(
    select
        hsi.staff_info_id
        ,ss.name ss_name
        ,ss.id ss_id
    from ph_bi.hr_staff_info hsi
    left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
    where
        ss.name in ('ABL_SP', 'ABY_SP', 'AGN_SP', 'AGO_SP', 'AGS_SP', 'AMD_SP', 'ANG_SP', 'ART_SP', 'ATQ_SP', 'AUR_SP', 'BAG_SP', 'BAH_SP', 'BAI_SP', 'BAT_SP', 'BAU_SP', 'BAY_SP', 'BCE_SP', 'BCP_SP', 'BCR_SP', 'BGO_SP', 'BGS_SP', 'BLC_SP', 'BLM_SP', 'BLN_SP', 'BLR_SP', 'BMG_SP', 'BOG_SP', 'BOH_SP', 'BTC_SP', 'BTG_SP', 'BUG_SP', 'BUS_SP', 'BYB_SP', 'BYY_SP', 'CAB_SP', 'CAD_SP', 'CAS_SP', 'CBA_SP', 'CBL_SP', 'CBO_SP', 'CBT_SP', 'CBY_SP', 'CDS_SP', 'CLN_SP', 'CLO_SP', 'CLS_SP', 'CMD_SP', 'CPG_SP', 'CUP_SP', 'CYZ_SP', 'DAA_SP', 'DEN_SP', 'DET_SP', 'DLM_SP', 'DMB_SP', 'DMT_SP', 'DOL_SP', 'FLR_SP', 'GAN_SP', 'GAP_SP', 'GAT_SP', 'GBA_SP', 'GOA_SP', 'GUM_SP', 'HOL_SP', 'HOT_SP', 'IBC_SP', 'IFT_SP', 'ILA_SP', 'IRG_SP', 'JUA_SP', 'KAV_SP', 'KBL_SP', 'KLB_SP', 'KLM_SP', 'KLS_SP', 'LAG_SP', 'LAM_SP', 'LAR_SP', 'LAU_SP', 'LBN_SP', 'LBO_SP', 'LBS_SP', 'LEY_SP', 'LGA_SP', 'LGN_SP', 'LGP_SP', 'LLI_SP', 'LMA_SP', 'LPZ_SP', 'LSA_SP', 'LUN_SP', 'LUT_SP', 'MAO_SP', 'MAR_SP', 'MAS_SP', 'MBA_SP', 'MBL_SP', 'MBR_SP', 'MBS_SP', 'MBT_SP', 'MIL_SP', 'MLG_SP', 'MLO_SP', 'MON_SP', 'MOZ_SP', 'MRA_SP', 'MRD_SP', 'MRN_SP', 'MTI_SP', 'MTS_SP', 'MUS_SP', 'NAG_SP', 'NAR_SP', 'NAU_SP', 'NBC_SP', 'NJU_SP', 'NOA_SP', 'NOV_SP', 'NUE_SP', 'OLP_SP', 'OMC_SP', 'PAL_SP', 'PAS_SP', 'PDC_SP', 'PIL_SP', 'PLA_SP', 'PLW_SP', 'PLY_SP', 'PMY_SP', 'PPA_SP', 'PSC_SP', 'PSG_SP', 'PSK_SP', 'PSP_SP', 'PSS_SP', 'PST_SP', 'PUT_SP', 'QUN_SP', 'RBL_SP', 'RIZ_SP', 'ROS_SP', 'ROX_SP', 'RZZ_SP', 'SAN_SP', 'SAY_SP', 'SBG_SP', 'SCZ_SP', 'SDS_SP', 'SEL_SP', 'SJS_SP', 'SMB_SP', 'SML_SP', 'SMN_SP', 'SNA_SP', 'SOL_SP', 'SPB_SP', 'SSG_SP', 'SSP_SP', 'STC_SP', 'STG_SP', 'STS_SP', 'STZ_SP', 'SUB_SP', 'TAA_SP', 'TAB_SP', 'TAL_SP', 'TAN_SP', 'TAU_SP', 'TBC_SP', 'TBK_SP', 'TCL_SP', 'TJY_SP', 'TNA_SP', 'TOO_SP', 'TTB_SP', 'TUA_SP', 'TUG_SP', 'TUM_SP', 'TYZ_SP', 'UDA_SP', 'UDS_SP', 'VZA_SP', 'WAK_SP', 'WTB_SP', 'WTG_SP')
        and hsi.state = 1
        and hsi.job_title in (13,110,1000)  -- 快递员
#         and hsi.staff_info_id = '136400'
)
, total as
(
    select
            date(date_add(pr.routed_at , interval 8 hour)) date_d
            ,'scan' type
            ,t.ss_name
            ,pr.staff_info_id
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join t on pr.staff_info_id = t.staff_info_id
        where
            pr.routed_at >= date_sub(date_sub(curdate(), interval 30 day), interval 8 hour)
            and pr.routed_at < date_sub(curdate(), interval 8 hour)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' -- 交接扫描
#             and pr.staff_info_id = '136400'
        group by 1,2,3,4

        union all

        select
            date(date_add(pi.finished_at , interval 8 hour)) date_d
            ,'fin' type
            ,t.ss_name
            ,t.staff_info_id
            ,count(distinct pi.pno) num
        from ph_staging.parcel_info pi
        join t on pi.ticket_delivery_staff_info_id = t.staff_info_id
        where
            pi.state = 5
            and pi.finished_at >= date_sub(date_sub(curdate(), interval 30 day), interval 8 hour)
            and pi.finished_at < date_sub(curdate(), interval 8 hour)
        group by 1,2,3,4
)
select
    *
from total
select
    a.ss_name 网点
    ,a.staff_info_id 员工ID
    ,sum(scan.num)/count(distinct scan.date_d) 日均交接量
    ,count(distinct scan.date_d) 近30天交接天数
    ,sum(fin.num)/count(distinct fin.date_d) 日均妥投量
    ,count(distinct fin.date_d) 近30天妥投天数
from t a
left join
    (
        select
            total.staff_info_id
            ,total.date_d
            ,total.ss_name
        from total
        group by 1,2,3
    ) t on t.staff_info_id = a.staff_info_id and t.ss_name = a.ss_name
left join total scan on scan.staff_info_id = t.staff_info_id and scan.date_d = t.date_d and scan.type = 'scan'
left join total fin on fin.staff_info_id = t.staff_info_id and fin.date_d = t.date_d and fin.type = 'fin'
group by 1,2

;
