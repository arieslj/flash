select
    t.pno
   ,a1.拒收回访
   ,a1.改约回访
    ,if(a2.id is null, '否', '是') 是否有历史贪污记录
from tmpale.tmp_th_pno_lj_1220 t
left join
    (
        select
            a.pno
            ,group_concat(distinct a.拒收回复结果) as 拒收回访
            ,group_concat(distinct a.改约回访结果) as 改约回访
        from
            (
                select
                    t.pno
                    ,case vrv.visit_result
                            when 1 then '联系不上'
                            when 2 then '取消原因属实、合理'
                            when 3 then '快递员虚假标记/违背客户意愿要求取消'
                            when 4 then '多次联系不上客户'
                            when 5 then '收件人已签收包裹'
                            when 6 then '收件人未收到包裹'
                            when 7 then '未经收件人允许投放他处/让他人代收'
                            when 8 then '快递员没有联系客户，直接标记收件人拒收'
                            when 9 then '收件人拒收情况属实'
                            when 10 then '快递员服务态度差'
                            when 11 then '因快递员未按照收件人地址送货，客户不方便去取货'
                            when 12 then '网点派送速度慢，客户不想等'
                            when 13 then '非快递员问题，个人原因拒收'
                            when 14 then '其它'
                            when 15 then '未经客户同意改约派件时间'
                            when 16 then '未按约定时间派送'
                            when 17 then '派件前未提前联系客户'
                            when 18 then '收件人拒收情况不属实'
                            when 19 then '快递员联系客户，但未经客户同意标记收件人拒收'
                            when 20 then '快递员要求/威胁客户拒收'
                            when 21 then '快递员引导客户拒收'
                            when 22 then '其他'
                            when 23 then '情况不属实，快递员虚假标记'
                            when 24 then '情况不属实，快递员诱导客户改约时间'
                            when 25 then '情况属实，客户原因改约时间'
                            when 26 then '客户退货，不想购买该商品'
                            when 27 then '客户未购买商品'
                            when 28 then '客户本人/家人对包裹不知情而拒收'
                            when 29 then '商家发错商品'
                            when 30 then '包裹物流派送慢超时效'
                            when 31 then '快递员服务态度差'
                            when 32 then '因快递员未按照收件人地址送货，客户不方便去取货'
                            when 33 then '货物验收破损'
                            when 34 then '无人在家不便签收'
                            when 35 then '客户错误拒收包裹'
                            when 36 then '快递员按照要求当场扫描揽收'
                            when 37 then '快递员未按照要求当场扫描揽收'
                            when 38 then '无所谓，客户无要求'
                            when 39 then '包裹未准备好 - 情况不属实，快递员虚假标记'
                            when 40 then '包裹未准备好 - 情况属实，客户存在未准备好的包裹'
                            when 41 then '虚假修改包裹信息'
                            when 42 then '修改包裹信息属实'
                        end as 拒收回复结果
                        ,case vrv3.visit_result
                            when 1 then '联系不上'
                            when 2 then '取消原因属实、合理'
                            when 3 then '快递员虚假标记/违背客户意愿要求取消'
                            when 4 then '多次联系不上客户'
                            when 5 then '收件人已签收包裹'
                            when 6 then '收件人未收到包裹'
                            when 7 then '未经收件人允许投放他处/让他人代收'
                            when 8 then '快递员没有联系客户，直接标记收件人拒收'
                            when 9 then '收件人拒收情况属实'
                            when 10 then '快递员服务态度差'
                            when 11 then '因快递员未按照收件人地址送货，客户不方便去取货'
                            when 12 then '网点派送速度慢，客户不想等'
                            when 13 then '非快递员问题，个人原因拒收'
                            when 14 then '其它'
                            when 15 then '未经客户同意改约派件时间'
                            when 16 then '未按约定时间派送'
                            when 17 then '派件前未提前联系客户'
                            when 18 then '收件人拒收情况不属实'
                            when 19 then '快递员联系客户，但未经客户同意标记收件人拒收'
                            when 20 then '快递员要求/威胁客户拒收'
                            when 21 then '快递员引导客户拒收'
                            when 22 then '其他'
                            when 23 then '情况不属实，快递员虚假标记'
                            when 24 then '情况不属实，快递员诱导客户改约时间'
                            when 25 then '情况属实，客户原因改约时间'
                            when 26 then '客户退货，不想购买该商品'
                            when 27 then '客户未购买商品'
                            when 28 then '客户本人/家人对包裹不知情而拒收'
                            when 29 then '商家发错商品'
                            when 30 then '包裹物流派送慢超时效'
                            when 31 then '快递员服务态度差'
                            when 32 then '因快递员未按照收件人地址送货，客户不方便去取货'
                            when 33 then '货物验收破损'
                            when 34 then '无人在家不便签收'
                            when 35 then '客户错误拒收包裹'
                            when 36 then '快递员按照要求当场扫描揽收'
                            when 37 then '快递员未按照要求当场扫描揽收'
                            when 38 then '无所谓，客户无要求'
                            when 39 then '包裹未准备好 - 情况不属实，快递员虚假标记'
                            when 40 then '包裹未准备好 - 情况属实，客户存在未准备好的包裹'
                            when 41 then '虚假修改包裹信息'
                            when 42 then '修改包裹信息属实'
                        end as 改约回访结果
                from tmpale.tmp_th_pno_lj_1220 t
                left join nl_production.violation_return_visit vrv on t.pno = vrv.link_id and vrv.type = 3 and vrv.visit_state in (3,4)
                left join nl_production.violation_return_visit vrv3 on t.pno = vrv3.link_id and vrv3.type = 4 and vrv3.visit_state in (3,4)
            ) a
        group by 1
    ) a1 on a1.pno = t.pno
left join
    (
        select
            ss.id
        from bi_pro.receivables_issues ri
        left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = ri.staff_id
        left join fle_staging.sys_store ss on ss.id = hsi.sys_store_id
        where
            ri.updated_at >= '2023-01-01'
            and ri.state = 13
            and ri.issues_type = 3
        group by 1
    ) a2 on a2.id = t.dst_store_id


;

select
    t.pno
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as 客户类型
    ,pi2.cod_amount/100 cod
    ,pai.cogs_amount/100 cogs
    ,pci.created_at 询问任务提交时间
from tmpale.tmp_th_pno_lj_0115 t
left join fle_staging.parcel_info pi on t.pno = pi.pno
left join fle_staging.parcel_info pi2 on  pi2.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
left join fle_staging.parcel_additional_info pai on pai.pno = pi2.pno
left join fle_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id
left join bi_center.parcel_complaint_inquiry pci on pci.merge_column = t.pno
;

select
    pi.pno
    ,if(pi.state = 5, convert_tz(pi.finished_at, '+00:00', '+07:00'), null) 妥投时间
from fle_staging.parcel_info pi
where
    pi.pno in ('SSLT730019683513','TH680552357S1A','TH1906525YVB2C','TH160152923Q6M','SSLT730019605259','TH441650ZS470E','TH670150SFD89G','TH680551Z82D4A','TH02035252WY5A0','TH6703516VH46B','TH330651T18S7E','LEXPU0286239505','TH581051WGSF1C','LEXDO0086634037','TH013952GKK72D1','FEPU0000307071','TH014251NFQM2C','TH1906525YVC0C','TH010552594S2E','SSLT730019540612','TH680552188F4A','TH200452C6FJ6B2','TH68055241HD6B','TH6805527T2Z1A','TH01494YKY906D','TH200751BXZU2A','TH350651534H8D','SSLT730019637093','TH6805509YJM5A','TH350451GW680B','TH0112520H0T6B','TH49014ZR4S23F','TH39014X75YR1A','TH1906525YVB5C','TH6805522SYK8A','SSLT730019663957','SSLT730019858798','TH30164ZCYGY0C','TH060151Q6JR9B','TH680552CX2F1A','TH1906525YVA7C','SSLT730019553257','TH010652CHKR7C','SSLT730019784941','LEXPU0289295081','TH04034ZYBB28A2','TH16015225CG5Q','TH020151MFBJ3C','TH120152C8QP9U','TH0405522QBD9G','TH121051KFCS1D','TH6103505T558E','TH6701525NU86G','TH6207525MZB0C','TH200852D9V01D','TH040251WGAN0C1','SSLT730019709077','TH0302526K3N4F','TH70035259PW4C','TH570851R3KZ7A','TH720150BY973A','TH270150JS1Z7A','TH0126520J087A1','TH560551WHA40B','TH012350YSQV1D','TH570851R3KZ7A','TH310951D46Z7G','TH6703516VH46B','TH471552JR7S2H','TH200452C6FJ6B2','TH68055241HD6B','TH6805527T2Z1A','TH01494YKY906D','TH040352FU3W6A0','TH015052J94R4A','SSLT730019731779','TH0146523V2D6C','TH391052PPHW7A','SSLT730019540612','TH680552188F4A','TH6805529B918A','TH050352RPXN5G','TH680552CX2F1A','TH1906525YVA7C','SSLT730019553257','TH6804525F5J0F0','TH64115289TA9G','TH6805522SYK8A','TH380152WK145R','SSLT730020036981','SSLT730019839133','TH030253AZ903F','SSLT730019911390','TH1906525YVB5C','SSLT730019731866','TH0306538BC24F','TH441252FZZQ5A','TH670150SFD89G','TH680551Z82D4A','TH040452D40Y7E','TH68044ZJAEG4F0','TH680552357S1A','TH1906525YVB2C','TH030452SDRP7B','SSLT730020027140','TH200553603G8E','TH650751B3NF9A','TH020151MFBJ3C','TH012351QQZ67D','TH020152ZHHK4E0','TH38015255P30I','TH38195150FE9B','TH360151B3NE6J','TH040252WGUM5A0','TH01184ZVVA94B1','SSLT730019683513','TH014352QCW57A1','TH040251QWMC5C0','TH70035259PW4C','TH680552JQ020A','TH012351QFGD1D','TH68055214S57A','TH39014X75YR1A','TH012350YSQV1D','SSLT730019912792','TH190652TF7M8E','TH27154XDVHV5L','SSLT730019607490','TH6805519FV67A','TH590750XH168A','TH641350SCTR0F','TH012751XJ6R6C','TPLPU0001299328','TH30164ZCYGY0C','TH060151Q6JR9B','TH680451CMJT3F0','TH441650ZS470E','TH01425356N85A0','TH020352FJSS3D0','TH013453300Q4A1','TH680452CNBE8F0','TH220151KR168F','TH680550T3A45A','TH014650R6KN2C','TH010652CHKR7C','SSLT730019784941','TH260651BNM77A','TH31144ZTPTD3E','TH3003511FGS1G','TH200451XE1C6B1','SSLT730019725348','TH160152923Q6M','SSLT730019605259','TH014552Q7583A','TH012851YJ821C','TH011852KUWD8A','TH030252WRDA5E','TH121051KFCS1D','TH6103505T558E','TH6701525NU86G','TH6207525MZB0C','TH200852D9V01D','TH200450162P3B0','TH680552J57G4A','TH020152566N9B0','TH680452QEP94F0','TH43015326VY3G','SSLT730019709077','TH190152KHK30F','TH560851BVRN5F','TH330651T18S7E','TH70055160KR1C','TH370152X9G56A0','SSLT730019341577','TH67035376H43C','TH350651534H8D','SSLT730019637093','TH350451GW680B','SSLT730019316129','TH014151K4696B0','TH3701500K6Z6A0','TH470151WK510E','LEXDO0086634037','TH0302526K3N4F','TH710351G8766G','TH02015271V70C','TH020452J2MP8B','TH680551WU7M8A','TH680552HD7N5A','TH540451R90M7A','TH014251QV8C4A0','TH200751BXZU2A','TH4706527AJ15G','TH040251WGAN0C1','TH450552SH3E4C','TH2004532Q8M9B4','TH02035252WY5A0','TH680551X2QP3A','TH01385314WP6A','TH690150SP2B5F','TH120152C8QP9U','TH0405522QBD9G','TH7008528M2R9B','TH1402510EY26A','LEXPU0289295081','TH04034ZYBB28A2','TH2007516B9T4A','TH581051WGSF1C','TH680450MYZR1F0','TH1001538UCJ9A','TH013952GKK72D1','FEPU0000307071','TH010250CECP2A','TH010152Y6N28B0','TH6804524M344F0','SSLT730020115855','SSLT730019858798','TH550451US176A','TH013352J9SC5A','TH642152BQF25B','TH020452Z0679B','TH160250SKQA8B1','TH670152ZUQJ0F','TH010352MMNV1E','TH680452JWF44F0','LEXPU0286239505','TH0103520RC85C0','TH131150CF608C','TH051052FQ5G2F','TH380152QHM49D','TH680551GR8N6A','SSLT730019663957','TH040252SB2T6A4','SSLT730018943101','TH0112520H0T6B','TH49014ZR4S23F','TH680552JQ027A','TH05064ZVSUN6A','TH012352W5C73C','TH01055268HK4D1','TH190151C5MU9E','TH16015225CG5Q','TH015152QUFH8C0','TH270150JS1Z7A','TH0126520J087A1','TH560551WHA40B','TH270152CPEK1A0','TH271552ZAZG9F','TH014452CD5K6C','TH010552594S2E','TH2715526GKK1C','TH670152Q9H57G','TH0306509FP87G')


;


select
    a.handle_time 处理日期
    ,a.handle_staff_id 工号
    ,a.name 姓名
    ,count(if(a.type = 1 and a.punish_category not in (7,8,21), a.id, null)) 集体处罚个数
    ,count(if(a.type = 2 and a.punish_category not in (7,8,21,58,60), a.id, null)) 个人处罚个数
    ,count(if(a.punish_category = 8, a.id, null)) 包裹破损个数
    ,count(if(a.punish_category = 7, a.id, null)) 包裹丢失个数
    ,count(if(a.punish_category = 21, a.id, null)) 客户投诉个数
    ,count(if(a.punish_category = 58, a.id, null)) 虚假取消揽件任务个数
    ,count(if(a.punish_category = 60, a.id, null)) 虚假标记拒收个数
    ,count(a.id) 总处理合计
    ,sum(a.个人处罚得分) + sum(a.包裹丢失得分) + sum(a.包裹破损得分) + sum(a.客户投诉得分) + sum(a.虚假取消揽件任务得分) + sum(a.虚假标记拒收得分) + sum(a.集体处罚得分) 综合人效得分
    ,(sum(a.个人处罚得分) + sum(a.包裹丢失得分) + sum(a.包裹破损得分) + sum(a.客户投诉得分) + sum(a.虚假取消揽件任务得分) + sum(a.虚假标记拒收得分) + sum(a.集体处罚得分))/300 完成情况
from
    (
        select
            if(am.isdel = 1 and aq.handle_staff_id is null,am.last_edit_staff_info_id, aq.handle_staff_id) handle_staff_id
            ,hsi.name
            ,coalesce(am.punish_category, amd.punish_category) punish_category
            ,if(am.isdel = 1 and aq.handle_time is null,date(am.del_date), date(aq.handle_time)) handle_time
            ,aq.type
            ,if(aq.type = 1 and coalesce(am.punish_category, amd.punish_category) not in (7,8,21), 1, 0) 集体处罚得分
            ,if(aq.type = 2 and coalesce(am.punish_category, amd.punish_category) not in (7,8,21,58,60), 1, 0) 个人处罚得分
            ,if(coalesce(am.punish_category, amd.punish_category) = 8, 8, 0) 包裹破损得分
            ,if(coalesce(am.punish_category, amd.punish_category) = 7, 8, 0) 包裹丢失得分
            ,if(coalesce(am.punish_category, amd.punish_category) = 21, 4, 0) 客户投诉得分
            ,if(coalesce(am.punish_category, amd.punish_category) = 58, 4, 0) 虚假取消揽件任务得分
            ,if(coalesce(am.punish_category, amd.punish_category) = 60, 4, 0) 虚假标记拒收得分
            ,aq.id
        from bi_pro.abnormal_qaqc aq
        left join bi_pro.abnormal_message am on aq.abnormal_message_id = am.id
        left join nl_production.abnormal_message_del amd on aq.abnormal_message_id = amd.id
        left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = coalesce(aq.handle_staff_id, am.last_edit_staff_info_id)
        join dwm.dwd_hr_organizational_structure_detail sd on sd.id=hsi.node_department_id and sd.一级部门='QAQC'
        where
            aq.type = 2
            and (
                    (date(aq.handle_time) >= '${处理开始时间}' and date(aq.handle_time) <= '${处理结束时间}' and aq.handle_time is not null) or
                    ( am.isdel = 1 and am.del_reason_desc = 'cs_change_duty' and aq.handle_time is null and date(am.del_date) >= '${处理开始时间}' and date(am.del_date) <= '${处理结束时间}' )
                )

        union

        select
            if(am.isdel = 1 and aq.handle_staff_id is null,am.last_edit_staff_info_id, aq.handle_staff_id) handle_staff_id
            ,hsi.name
            ,coalesce(am.punish_category, amd.punish_category) punish_category
            ,if(am.isdel = 1 and aq.handle_time is null,date(am.del_date), date(aq.handle_time)) handle_time
            ,aq.type
            ,if(aq.type = 1 and coalesce(am.punish_category, amd.punish_category) not in (7,8,21), 1, 0) 集体处罚得分
            ,if(aq.type = 2 and coalesce(am.punish_category, amd.punish_category) not in (7,8,21,58,60), 1, 0) 个人处罚得分
            ,if(coalesce(am.punish_category, amd.punish_category) = 8, 8, 0) 包裹破损得分
            ,if(coalesce(am.punish_category, amd.punish_category)= 7, 8, 0) 包裹丢失得分
            ,if(coalesce(am.punish_category, amd.punish_category) = 21, 4, 0) 客户投诉得分
            ,if(coalesce(am.punish_category, amd.punish_category) = 58, 4, 0) 虚假取消揽件任务得分
            ,if(coalesce(am.punish_category, amd.punish_category) = 60, 4, 0) 虚假标记拒收得分
            ,aq.id
        from bi_pro.abnormal_qaqc aq
        left join bi_pro.abnormal_message am on aq.qaqc_merge_key = am.average_merge_key
        left join nl_production.abnormal_message_del amd on aq.qaqc_merge_key = amd.average_merge_key
        left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = coalesce(aq.handle_staff_id, am.last_edit_staff_info_id)
        join dwm.dwd_hr_organizational_structure_detail sd on sd.id=hsi.node_department_id and sd.一级部门='QAQC'
        where
            aq.type = 1
            and (
                    (aq.handle_time is not null and date(aq.handle_time) >= '${处理开始时间}' and date(aq.handle_time) <= '${处理结束时间}') or
                     (am.isdel = 1 and am.del_reason_desc = 'cs_change_duty' and  aq.handle_time is null and date(am.del_date) >= '${处理开始时间}' and date(am.del_date) <= '${处理结束时间}' )
                )
        group by 1,2,3,4,5,6,7,8,9,10,11,12,13
    ) a
    where a.handle_staff_id is not null ${if(len(员工号)=0,"","and a.handle_staff_id in ('"+SUBSTITUTE(员工号,",","','")+"')")}
group by 1,2,3
order by 1,2


;


select
    pi.pno
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as 客户类型
from fle_staging.parcel_info pi
left join dwm.tmp_ex_big_clients_id_detail  bc on bc.client_id = pi.client_id
left join fle_staging.ka_profile kp on kp.id = pi.client_id
where
    pi.pno in ('TH0115519GU09A1','TH0203525BCM1A','TH020551VZYF9B','TH020551X9TA9B','TH0205517V5R3B','TH020551X9UV5B','TH020551VB4B1B','TH020551XAWA9B','TH020551V8XU4B','TH020551KH3U9B','TH020551F6H79B','TH0117523R650B','TH020551ZTVF8B','TH0205523U401B','TH0205520PXT8B','TH0205521H296B','TH020552072H6B','TH020551ZKMR4B','TH020551X3Z05B','TH0205521GSJ2B','TH020551ZBW42B','TH020551W9B69B','TH020551W2E70B','TH020551VY3E2B','TH020551V9F73B','TH020551V20H0B','THT0405NTSQJ3Z','THT1601PFKPW7Z','TH300351U9SN8B','TH0405520Y459G','TH311350Z0VW9K','THT5401NXYQ50Z','TH42044Z81Y44A','TH020551W4SX3E1','TH070451NVY44D','TH040551WN8T3G','TH0203527VS95A','THT0506PAH1H2Z','TH0205511ETV5B','TH16015225CG5Q','TH0511521DA86F','TH380151KH2A1R','TH020351UZT00A2','TH020351QD3E0A2','TH020351H43R8A','TH020351UZKX3A','TH24044WTMCZ0D','TH0405522QBD9G','TH02034YZJQG1A2','TH020350AHR24A','TH020350FRJC4A2','LEXPU0289295081','THT6417PD0QT8Z','TH180151W8BM0B','TH02035281ZR6A','TH02035252WY5A0','TH160151S1U67K','TH014351TWAP0A1','TH04055242G53G','TH700151MRFX8D','TH020550W1BF1B','TH0405523PF80G','TH370150GCFY9A','THT0506PDTTZ3Z','TH3712518E8N6A','TH020550NP3R3B','TH014451PUTA0B','TH020351WPKB1A2','TH020351U29W3A2','TH040551RSS98G','TH040551VYFF3G','TH0403509UVR3A0','THT0111NRBW26Z','TH03024V8HWK5H','TH012051VSHF4B','TH020551P1E32B','TH0147501N4J9C','TH014751B6K43B0','TH0306522XJ27A','TH040551ZFQ69G','TH0405520BE45G','TH011650DBTW8A1','TH0141516VPQ2A','TH02054YJ2V60B','TH013951ZCNW7B0','TH040551Y5JT1G','TH013351FD2A6F','TH020351EHG06A','TH020350QVW86A2','TH020351NFXM3A2','TH020352DR8B9B','THT0121NYNR53Z','TH0405520T3S9G','TH04055248B19G','TH040551ZYG16G','THT4705P9XPN7Z','TH380151VBRG0A','TH0203522BM08A','TH020351PJV98A2','TH020351U89A8A2','TH020351VFC95A2','TH020351PXSS1A2','TH020351NK8A4A2','TH020351NSAM9A2','TH020351UZM03A2','TH0405522FY05G','TH237420755167I','TH013352R2KX6F','TH430152NJZQ6C','TH013352QG4D3F','TH013352NC185F','TH0403501W6F3A0','THT0203PDZFU4Z','SSLT730019911390','TH0205528C505B','TH020552EKTJ3B','TH020552CJFU5B','TH020552BWK35B','TH02035116NK0D2','TH0203515UA88D2','TH040551TNN72G','TH16015185J86O','TH040551X5Y18G','TH013352QSET0F','TH02034VACH50B1','TH0201504RSA5M','TH0405521PQJ9G','TH05064ZMQ7D0E','TH0117518K3N7B1','TH300952H2M51E','THT2502P83Y79Z','THT0112NRQBG9Z','TH020552B7VD6B','TH011750U42Q2B','TH271250FWS72A','TH02034ZNECS3A','TH272151H8UP3H','TH0405521F8J9G','TH012352CEN84C','TH02055270HH0E0','TH610151PXWN4C','TH012350YW393C','TH47015111QA0D','TH013352HRJV7F','TH050651PX901L','TH020151SCS09K1','TH050650J9089E','TH0302530YQ98C','THT0133PFH208Z','TH040551BCR57G','TH0203514NQ24D2','TH0123513PGB6C','TH0123515R702C','TH012351JQ2W3C','TH0203507M5R1D2','TH19075257ME4B','TH02034VMTPK9D2','TH02034WSGPN6D2','THT0133PR1QV4Z','TH01014WKUH11B0','TH01014XBU2P1B0','TH01014WRC7H1B0','TH01014WVSQ25B0','TH030252R86N1C','TH030252QU482C','TH013351PGS79E','TH0205523RKP6E0','SSLT730019683513','TH441650ZS470E','TH330651T18S7E','TH581051WGSF1C','TH014251NFQM2C','TH01494YKY906D','TH350651534H8D','TH6805509YJM5A','TH49014ZR4S23F','TH30164ZCYGY0C','TH060151Q6JR9B','TH121051KFCS1D','TH6103505T558E','TH040251WGAN0C1','TH570851R3KZ7A','TH0126520J087A1','TH560551WHA40B','TH310951D46Z7G','TH040352FU3W6A0','TH650751B3NF9A','TH38195150FE9B','TH360151B3NE6J','TH01184ZVVA94B1','TH040251QWMC5C0','TH27154XDVHV5L','TH590750XH168A','TH641350SCTR0F','TH012751XJ6R6C','TH220151KR168F','TH260651BNM77A','TH31144ZTPTD3E','TH3003511FGS1G','TH012851YJ821C','TH030252WRDA5E','TH200450162P3B0','TH560851BVRN5F','TH70055160KR1C','TH014151K4696B0','TH470151WK510E','TH710351G8766G','TH540451R90M7A','TH690150SP2B5F','TH1402510EY26A','TH2007516B9T4A','TH010250CECP2A','TH550451US176A','TH160250SKQA8B1','TH0103520RC85C0','TH131150CF608C','TH05064ZVSUN6A','TH01055268HK4D1','TH014452CD5K6C','TH0306509FP87G','TH27014Z29Y04J0','TH01224ZTWR06B','TH1005505HFE3A','TH20014YKNCN1I','TH41044YMK905F','TH01514Z00PW2A','TH05064ZA9ZS1L','TH01054YV4XU6B0','TH44014YZB648A0','TH01014ZDSNA0B1','TH01174YWQKV0B2','TH77014YVKTA9A','TH02014ZG6YJ8J','TH03044ZX6D70H','TH0107501D0N6B','TH01254ZS0VV7E','TH01104ZJE5N5D','TH10014ZTCCA3A','TH01394Z1ED38E1','TH16024ZJAD38I','TH29104ZT2BV0D','TH01434ZEV022B','TH02014ZX97W8C','TH0114502K2Y6E','TH0203508CZ56B0','TH04034XYB353A0','TH01264YB5TY3B','TH41094Y1PNG6A','TH01184YAKWX1A1','TH01154Z0CRX9A1','TH02034ZW2KQ5D2','TH44124WUJRP1J','TH01284ZQNHX8B','TH01144ZZ23E8E','TH55034YE16U8G','TH01264YPQ0P6B','TH04024Z0QHZ1D','TH38014Z013K9A','TH01284Z6A7T8C','TH01424XMNKZ0A1','TH01174YRHS69A0','TH01164Y79D51A1','TH21064YN8YB4E0','TH01174Z65K47A','TH01394ZJA4A9F','TH01374Z1F1B6A','TH04014ZZV5C4B','TH01504ZJ7YC8A','TH01114ZJAMX0A','TH01394ZRBXH7F','TH04034ZYXTN8F','TH0131505HCP2A0','TH20074YRJF32E','TH0118500T1P4A0','TH67034ZHRKH6F','TH2103500W1J3F','TH2701500WUP7R','TH01504ZY3PM5B0','TH01014XQF0C8A','TH70014XPVH39K','TH24014XHJFZ9A','TH01434XSPZK5B','TH01334Y5QHU4F','TH01224XGD1Q8C0','TH19074XS3YQ1B','TH01214YA4237A0','TH20074XXXZR3H1','TH21014Y4ZCM2N','TH03064XTNKS8C1','TH47044Y2KZJ4B','TH21024Y93YY8A','TH01284Y8GHK5A0','TH24064YKDBG2C','TH02034YGZYH5B0','TH03014YSAM48E0','TH01054YNGPV4B0','TH56024YGWF60D','TH01324YV8FD0G','TH12064YQ9MV1I','TH04064YMHT72A1','TH01284YZH2R3A0','TH01174Y4SPG1B0','TH35044Y8WH24D','TH03064YBA907J','TH24084WH7C11A','TH04034YVJWA6D','TH28014Z7S9Z3M','TH01394XZBAR1B0','TH01514Y0RSW3A','TH18074XKPFR0E','TH01054YBQBP2A','TH67034Y181W6F','TH01204YG0GY7B','TH01394YGNNT7F','TH02034YNPR76D1','TH02034YGC7Q0D0','TH01054YWA0E8B0','TH30124YSHG44B','TH01424Z0UW92A0','TH03024YS01V7E','TH01054RWGTP7B0','TH01434YWPDN0B')
