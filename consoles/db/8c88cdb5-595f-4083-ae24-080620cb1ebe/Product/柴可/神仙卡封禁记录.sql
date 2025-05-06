select
    cprr.local_phone 电话号码
    ,cprr.device_card_id 设备_电话卡ID
    ,cpi.staff_info_id 最后使用快递员工号
    ,hsi.sys_store_id  网点ID
    ,if(cpr.rule_type in (1,2), convert_tz(cpr.created_at, '+00:00', '+07:00'), null) 封卡时间
    ,case cpr.rule_type
        when 1 then 'AI判责'
        when 2 then '定时器判责'
    end 封卡原因
    ,if(cpr.rule_type in (4,5), convert_tz(cpr.created_at, '+00:00', '+07:00'), null) 解封时间
    ,case cpr.rule_type
        when 4 then '短信解绑判责'
        when 5 then '人工解绑判责'
    end 解封原因
    ,if(cpr.rule_type in (4,5), cpr.staff_info_id, null) 操作人
from fle_staging.courier_phone_card_judgment_record cpr
left join fle_staging.courier_phone_card_report_record cprr on cprr.id = cpr.phone_card_report_id
left join fle_staging.courier_phone_card_info cpi on cpr.phone_card_info_id = cpi.id
join bi_pro.hr_staff_info hsi on hsi.staff_info_id = cpi.staff_info_id
left join fle_staging.sys_store ss on ss.id = hsi.sys_store_id
where
    cpr.created_at > '2025-01-05 17:00:00'
    and ss.name in ('SGH_SP-เสาธงหิน', 'SWC_SP-ไสวประชาราษฎร์', 'TSH_SP-ทุ่งสองห้อง', 'KLN_SP-คลองหนึ่ง' , 'BNA_SP-บางนา')
    and cpr.rule_type in (1,2,4,5)

;



select
    *
from fle_staging.courier_phone_card_judgment_record cpc

;


select
    cpr_2.local_phone 电话号码
    ,cpr_2.icc_id SIM卡ID
    ,cpr_2.device_id 设备ID
    ,cpr_2.last_report_staff_info_id 最后上报快递员
    ,ss.id 最后使用网点ID
    ,ss.name 最后使用网点
    ,case cpr_2.rule_type
        when 1 then 'AI判责'
        when 2 then '定时器判责'
        when 6 then '新卡'
    end 封卡原因
    ,convert_tz(cpr_2.created_at, '+00:00', '+07:00') 封卡时间
    ,cpr_2.ban_number 封卡次数
    ,max(convert_tz(cpr.created_at, '+00:00', '+07:00')) 识别晚于封卡时间的最后一条的时间
    ,count(cpr.id) 识别晚于封卡时间次数
from
    (
        select
            cpr.phone_card_info_id
            ,cpr.id
            ,cpr.created_at
        from fle_staging.courier_phone_card_judgment_record cpr
        where
            cpr.rule_type in (1,2,6) -- 当前是封禁状态
            and cpr.created_at > '2025-01-01 17:00:00'
    ) cpr
join
    (
        select
            cpr_1.*
        from
            (
                select
                    cpi.id
                    ,cpr.rule_type
                    ,cpi.ban_number
                    ,cprr.local_phone
                    ,cprr.icc_id
                    ,cprr.device_id
                    ,row_number() over (partition by cpi.id order by cpr.created_at ) rn
                    ,cpr.created_at
                    ,cpi.last_report_staff_info_id
                from fle_staging.courier_phone_card_info cpi
                join fle_staging.courier_phone_card_judgment_record cpr on cpr.phone_card_info_id = cpi.id
                left join fle_staging.courier_phone_card_report_record cprr on cprr.id = cpr.phone_card_report_id
                where
                    cpr.rule_type in (1,2,6) -- 当前是封禁状态
                    and cpr.created_at > '2025-01-01 17:00:00'
            ) cpr_1
        where
            cpr_1.rn = 1
            and cpr_1.created_at > '2025-02-26 17:00:00'
            and cpr_1.created_at < '2025-03-27 17:00:00'
    ) cpr_2 on cpr.phone_card_info_id = cpr_2.id
left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = cpr_2.last_report_staff_info_id
left join fle_staging.sys_store ss on ss.id = hsi.sys_store_id
where
    cpr.created_at > cpr_2.created_at
group by 1,2,3,4,5,6,7,8,9