-- select * from tmpale.dwd_th_store_basic basic

-- 片区--大区--近63日日均到件量--近63日日均揽件量--饱和人效--测算所需人数（饱和）
-- --在职--待入职--招聘中--转岗中--待转出-待离职--饱和可新增HC数（目标减总数大于0的）
-- --饱和可减少招聘中人数（总数-目标 与招聘中的较小值）
-- --增加最近5个工作日的日均到件和日均揽件量（）

select
    *
     ,case
          when dco_hc_res in ('否','待定') then substring_index(store_name,'_',1)||'日均件量'||`DCO测算包裹量`||',目标DCO:'||`目标dco_max_220w`||',网点总DCO:'||`总DCO`||',人员充足'
          else null
    end as 'dco_reject_reason_cn'
     ,case
          when dco_hc_res in('否','待定') then 'Daily parcels of '||substring_index(store_name,'_',1)||' is '||`DCO测算包裹量`||',the target DCO is '||`目标dco_max_220w`||',now has '||`总DCO`||',sufficient'
          else null
    end as 'dco_reject_reason_en'
from (select tbq1.*
           , case
                 when coalesce(`快递员超多少`, 0) - COALESCE(`快递员超员-待入职`, 0) -
                      COALESCE(`快递员超员-招聘中`, 0) > 0
                     then coalesce(`快递员超多少`, 0) - COALESCE(`快递员超员-待入职`, 0) -
                          COALESCE(`快递员超员-招聘中`, 0)
                 else null end as '快递员超员-在职'

           , case
                 when coalesce(`DCO超多少`, 0) - COALESCE(`DCO超员-待入职`, 0) - COALESCE(`DCO超员-招聘中`, 0) > 0
                     then coalesce(`DCO超多少`, 0) - COALESCE(`DCO超员-待入职`, 0) - COALESCE(`DCO超员-招聘中`, 0)
                 else null end as 'DCO超员-在职'

           , case
                 when coalesce(`目标快递员_max_220w`, 0) >
                      COALESCE(`总快递员`, 0) - COALESCE(`待入职快递员`, 0) - COALESCE(`招聘中快递员`, 0) and
                      COALESCE(`七日外协`, 0) / 7 >= 1 and COALESCE(`修正近7日均资源`, 0) > 0 and
                      COALESCE(`待入职快递员`, 0) + COALESCE(`招聘中快递员`, 0) > 0 then 'P1招聘/入职'
                 when coalesce(`目标快递员_max_220w`, 0) >
                      COALESCE(`总快递员`, 0) - COALESCE(`待入职快递员`, 0) - COALESCE(`招聘中快递员`, 0) and
                      COALESCE(`七日外协`, 0) / 7 >= 1 and COALESCE(`修正近7日均资源`, 0) > 0 and
                      COALESCE(`待入职快递员`, 0) + COALESCE(`招聘中快递员`, 0) = 0 then '可加HC使用外协但无HC'

                 when coalesce(`目标快递员_max_220w`, 0) >
                      COALESCE(`总快递员`, 0) - COALESCE(`待入职快递员`, 0) - COALESCE(`招聘中快递员`, 0) and
                      COALESCE(`七日外协`, 0) / 7 >= 1 and COALESCE(`修正近7日均资源`, 0) = 0 and
                      COALESCE(`待入职快递员`, 0) + COALESCE(`招聘中快递员`, 0) > 0 then 'P1招聘/入职'
                 when coalesce(`目标快递员_max_220w`, 0) >
                      COALESCE(`总快递员`, 0) - COALESCE(`待入职快递员`, 0) - COALESCE(`招聘中快递员`, 0) and
                      COALESCE(`七日外协`, 0) / 7 >= 1 and COALESCE(`修正近7日均资源`, 0) = 0 and
                      COALESCE(`待入职快递员`, 0) + COALESCE(`招聘中快递员`, 0) = 0 then '可加HC使用外协但无HC
'

                 when coalesce(`目标快递员_max_220w`, 0) >
                      COALESCE(`总快递员`, 0) - COALESCE(`待入职快递员`, 0) - COALESCE(`招聘中快递员`, 0) and
                      COALESCE(`七日外协`, 0) / 7 < 1 and COALESCE(`修正近7日均资源`, 0) > 0 and
                      COALESCE(`待入职快递员`, 0) + COALESCE(`招聘中快递员`, 0) > 0 then 'P1招聘/入职，需控制HC数量'
                 when coalesce(`目标快递员_max_220w`, 0) >
                      COALESCE(`总快递员`, 0) - COALESCE(`待入职快递员`, 0) - COALESCE(`招聘中快递员`, 0) and
                      COALESCE(`七日外协`, 0) / 7 < 1 and COALESCE(`修正近7日均资源`, 0) > 0 and
                      COALESCE(`待入职快递员`, 0) + COALESCE(`招聘中快递员`, 0) = 0 then '可加HC,使用支援但无HC'

                 when coalesce(`目标快递员_max_220w`, 0) >
                      COALESCE(`总快递员`, 0) - COALESCE(`待入职快递员`, 0) - COALESCE(`招聘中快递员`, 0) and
                      COALESCE(`七日外协`, 0) / 7 < 1 and COALESCE(`修正近7日均资源`, 0) = 0 and
                      COALESCE(`待入职快递员`, 0) + COALESCE(`招聘中快递员`, 0) > 0 then 'P1招聘/入职，需控制HC数量'
                 when coalesce(`目标快递员_max_220w`, 0) >
                      COALESCE(`总快递员`, 0) - COALESCE(`待入职快递员`, 0) - COALESCE(`招聘中快递员`, 0) and
                      COALESCE(`七日外协`, 0) / 7 < 1 and COALESCE(`修正近7日均资源`, 0) = 0 and
                      COALESCE(`待入职快递员`, 0) + COALESCE(`招聘中快递员`, 0) = 0 then '可加HC,无其他支持但无HC'
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                 when coalesce(`目标快递员_max_220w`, 0) <=
                      COALESCE(`总快递员`, 0) - COALESCE(`待入职快递员`, 0) - COALESCE(`招聘中快递员`, 0) and
                      COALESCE(`七日外协`, 0) / 7 >= 1 and COALESCE(`修正近7日均资源`, 0) > 0 and
                      COALESCE(`待入职快递员`, 0) + COALESCE(`招聘中快递员`, 0) > 0 then 'P1招聘/入职待确认近日人效是否合理'
                 when coalesce(`目标快递员_max_220w`, 0) <=
                      COALESCE(`总快递员`, 0) - COALESCE(`待入职快递员`, 0) - COALESCE(`招聘中快递员`, 0) and
                      COALESCE(`七日外协`, 0) / 7 >= 1 and COALESCE(`修正近7日均资源`, 0) > 0 and
                      COALESCE(`待入职快递员`, 0) + COALESCE(`招聘中快递员`, 0) = 0 then '不可加HC使用外协无HC'

                 when coalesce(`目标快递员_max_220w`, 0) <=
                      COALESCE(`总快递员`, 0) - COALESCE(`待入职快递员`, 0) - COALESCE(`招聘中快递员`, 0) and
                      COALESCE(`七日外协`, 0) / 7 >= 1 and COALESCE(`修正近7日均资源`, 0) = 0 and
                      COALESCE(`待入职快递员`, 0) + COALESCE(`招聘中快递员`, 0) > 0 then 'P1招聘/入职'
                 when coalesce(`目标快递员_max_220w`, 0) <=
                      COALESCE(`总快递员`, 0) - COALESCE(`待入职快递员`, 0) - COALESCE(`招聘中快递员`, 0) and
                      COALESCE(`七日外协`, 0) / 7 >= 1 and COALESCE(`修正近7日均资源`, 0) = 0 and
                      COALESCE(`待入职快递员`, 0) + COALESCE(`招聘中快递员`, 0) = 0 then '无可加HC使用外协无HC'

                 when coalesce(`目标快递员_max_220w`, 0) <=
                      COALESCE(`总快递员`, 0) - COALESCE(`待入职快递员`, 0) - COALESCE(`招聘中快递员`, 0) and
                      COALESCE(`七日外协`, 0) / 7 < 1 and
                      COALESCE(`待入职快递员`, 0) + COALESCE(`招聘中快递员`, 0) > 0
                     then '无可加HC无外协待减HC'
                 when coalesce(`目标快递员_max_220w`, 0) <=
                      COALESCE(`总快递员`, 0) - COALESCE(`待入职快递员`, 0) - COALESCE(`招聘中快递员`, 0) and
                      COALESCE(`七日外协`, 0) / 7 < 1 and
                      COALESCE(`待入职快递员`, 0) + COALESCE(`招聘中快递员`, 0) = 0 and
                      COALESCE(`昨日积压`, 0) >= 300
                     then '不可加HC昨日高积压无HC'
                 when coalesce(`目标快递员_max_220w`, 0) <=
                      COALESCE(`总快递员`, 0) - COALESCE(`待入职快递员`, 0) - COALESCE(`招聘中快递员`, 0) and
                      COALESCE(`七日外协`, 0) / 7 < 1 and
                      COALESCE(`待入职快递员`, 0) + COALESCE(`招聘中快递员`, 0) = 0 and
                      COALESCE(`昨日积压`, 0) < 300
                     then '正常'

                 else 'other'
        end                    as 'hc_marker'
           ,case
                when ifnull(`审批中快递员`, 0) > 0 and ifnull(`快递员可新增HC数`, 0) > 0 and ifnull(片区总快递员,0)>=ifnull(片区目标快递员,0) then 0
                when ifnull(`审批中快递员`, 0) > 0 and ifnull(`快递员可新增HC数`, 0) > 0 and ifnull(片区总快递员,0)< ifnull(片区目标快递员,0) then
                    least(ifnull(片区目标快递员,0)-ifnull(片区总快递员,0),ifnull(`快递员可新增HC数`, 0),ifnull(`审批中快递员`, 0))
                when ifnull(`审批中快递员`, 0) > 0 and ifnull(`快递员可新增HC数`, 0) = 0 and ifnull(`快递员超多少`, 0)>0 then 0
                when ifnull(`审批中快递员`, 0) > 0 and ifnull(`快递员可新增HC数`, 0) = 0 and ifnull(`快递员超多少`, 0)=0 and ifnull(`招聘中快递员`, 0)+ifnull(`待入职快递员`, 0)>0 then 0
                when ifnull(`审批中快递员`, 0) > 0 and ifnull(`快递员可新增HC数`, 0) = 0 and ifnull(`快递员超多少`, 0)=0 and ifnull(`招聘中快递员`, 0)+ifnull(`待入职快递员`, 0)=0 then 0
        end as 'crr_hc_num'
           ,case
                when ifnull(`审批中快递员`, 0) > 0 and ifnull(`快递员可新增HC数`, 0) > 0 and ifnull(片区总快递员,0)>=ifnull(片区目标快递员,0) then '片区人数超标'
                when ifnull(`审批中快递员`, 0) > 0 and ifnull(`快递员可新增HC数`, 0) > 0 and ifnull(片区总快递员,0)< ifnull(片区目标快递员,0) then
                    '按照人效测算可增加HC'
                when ifnull(`审批中快递员`, 0) > 0 and ifnull(`快递员可新增HC数`, 0) = 0 and ifnull(`快递员超多少`, 0)>0 then '已超员,人效待提升'
                when ifnull(`审批中快递员`, 0) > 0 and ifnull(`快递员可新增HC数`, 0) = 0 and ifnull(`快递员超多少`, 0)=0 and ifnull(`招聘中快递员`, 0)+ifnull(`待入职快递员`, 0)>0 then '有待入职/招聘中'
                when ifnull(`审批中快递员`, 0) > 0 and ifnull(`快递员可新增HC数`, 0) = 0 and ifnull(`快递员超多少`, 0)=0 and ifnull(`招聘中快递员`, 0)+ifnull(`待入职快递员`, 0)=0 then '网点管理待提升'
        end                    as 'crr_hc_marker'

           ,case
                when ifnull(`审批中快递员`, 0) > 0 and ifnull(`快递员可新增HC数`, 0) > 0 and ifnull(片区总快递员,0)>=ifnull(片区目标快递员,0) then '否'
                when ifnull(`审批中快递员`, 0) > 0 and ifnull(`快递员可新增HC数`, 0) > 0 and ifnull(片区总快递员,0)< ifnull(片区目标快递员,0) then
                    '是'
                when ifnull(`审批中快递员`, 0) > 0 and ifnull(`快递员可新增HC数`, 0) = 0 and ifnull(`快递员超多少`, 0)>0 then '否'
                when ifnull(`审批中快递员`, 0) > 0 and ifnull(`快递员可新增HC数`, 0) = 0 and ifnull(`快递员超多少`, 0)=0 and ifnull(`招聘中快递员`, 0)+ifnull(`待入职快递员`, 0)>0 then '否'
                when ifnull(`审批中快递员`, 0) > 0 and ifnull(`快递员可新增HC数`, 0) = 0 and ifnull(`快递员超多少`, 0)=0 and ifnull(`招聘中快递员`, 0)+ifnull(`待入职快递员`, 0)=0 then '否'
        end                    as 'crr_hc_res'
           ,case
                when ifnull(`审批中快递员`, 0) > 0 and ifnull(`快递员可新增HC数`, 0) > 0 and ifnull(片区总快递员,0)>=ifnull(片区目标快递员,0)
                    then substring_index(store_name,'_',1)||'网点所在片区人数超标，请让DM安排从同片区其他网点或者CDC转岗'
                when ifnull(`审批中快递员`, 0) > 0 and ifnull(`快递员可新增HC数`, 0) > 0 and ifnull(片区总快递员,0)< ifnull(片区目标快递员,0) then null
                when ifnull(`审批中快递员`, 0) > 0 and ifnull(`快递员可新增HC数`, 0) = 0 and ifnull(`快递员超多少`, 0)>0
                    then substring_index(store_name,'_',1)||'按照人效测算网点目标人数为'||ifnull(cast(`目标快递员_max_220w` as decimal), 0)||','||ifnull('近7日出现3次低效（Van<70,Bike<90）员工'||nullif(`近7日严重低效员工数量`,0)||
                                                                                                                                                         '个,','')||ifnull('近7日3次出门晚（12点前妥投<10%当日妥投）员工'||nullif(`近7日严重出门晚员工数量`,0)||'个,','')||ifnull('近7天出勤小于4天员工有'||nullif(`近7天出勤小于4天员工数量`,0)||'个,','')||'请加强管理,提高人效.'
                when ifnull(`审批中快递员`, 0) > 0 and ifnull(`快递员可新增HC数`, 0) = 0 and ifnull(`快递员超多少`, 0)=0 and ifnull(`招聘中快递员`, 0)+ifnull(`待入职快递员`, 0)>0
                    then substring_index(store_name,'_',1)||'网点按照人效测算网点目标人数为'||ifnull(cast(`目标快递员_max_220w` as decimal), 0)||','||ifnull('待入职'||nullif(`待入职快递员`, 0)||',','')||ifnull('招聘中'||nullif(`招聘中快递员`, 0)||',','')||'人员充足.'
                when ifnull(`审批中快递员`, 0) > 0 and ifnull(`快递员可新增HC数`, 0) = 0 and ifnull(`快递员超多少`, 0)=0 and ifnull(`招聘中快递员`, 0)+ifnull(`待入职快递员`, 0)=0
                    then substring_index(store_name,'_',1)||'按照人效测算网点目标人数为'||ifnull(cast(`目标快递员_max_220w` as decimal), 0)||','||ifnull('近7日出现3次低效（Van<70,Bike<90）员工'||nullif(`近7日严重低效员工数量`,0)||
                                                                                                                                                         '个,','')||ifnull('近7日3次出门晚（12点前妥投<10%当日妥投）员工'||nullif(`近7日严重出门晚员工数量`,0)||'个,','')||ifnull('近7天出勤小于4天员工有'||nullif(`近7天出勤小于4天员工数量`,0)||'个,','')||'请加强管理,提高人效.'
        end                    as 'crr_reject_reason_cn'

           ,case
                when ifnull(`审批中快递员`, 0) > 0 and ifnull(`快递员可新增HC数`, 0) > 0 and ifnull(片区总快递员,0)>=ifnull(片区目标快递员,0)
                    then 'the manage piece of '||substring_index(store_name,'_',1)||' is overstaffed,please ask your DM to transfer staff from another SP in the same manage piece or CDC'
                when ifnull(`审批中快递员`, 0) > 0 and ifnull(`快递员可新增HC数`, 0) > 0 and ifnull(片区总快递员,0)< ifnull(片区目标快递员,0) then null
                when ifnull(`审批中快递员`, 0) > 0 and ifnull(`快递员可新增HC数`, 0) = 0 and ifnull(`快递员超多少`, 0)>0
                    then 'the target courier of '||substring_index(store_name,'_',1)||' is '||ifnull(cast(`目标快递员_max_220w` as decimal), 0)||
                         if(ifnull(`近7日严重低效员工数量`,0)+ifnull(`近7日严重出门晚员工数量`,0)+ifnull(`近7天出勤小于4天员工数量`,0)>0,',In the past 7 days,there were ','')||
                         ifnull( nullif(`近7日严重低效员工数量`,0)||' inefficient(Van<70,Bike<90) couriers,','')||ifnull(nullif(`近7日严重出门晚员工数量`,0)||' late(before 12:00,POD rate <10% ) couriers,','')||
                         ifnull(nullif(`近7天出勤小于4天员工数量`,0)||' courier work less than 4 days,','')||
                         if(ifnull(`近7日严重低效员工数量`,0)+ifnull(`近7日严重出门晚员工数量`,0)+ifnull(`近7天出勤小于4天员工数量`,0),'which needs to be improved','')||'.'
                when ifnull(`审批中快递员`, 0) > 0 and ifnull(`快递员可新增HC数`, 0) = 0 and ifnull(`快递员超多少`, 0)=0 and ifnull(`招聘中快递员`, 0)+ifnull(`待入职快递员`, 0)>0
                    then 'the target courier of '||substring_index(store_name,'_',1)||' is '||ifnull(cast(`目标快递员_max_220w` as decimal), 0)||
                         ','||ifnull(nullif(`待入职快递员`, 0)||' couriers ready to join,','')||ifnull(nullif(`招聘中快递员`, 0)||'courier HC on going,','')||'enough staff.'
                when ifnull(`审批中快递员`, 0) > 0 and ifnull(`快递员可新增HC数`, 0) = 0 and ifnull(`快递员超多少`, 0)=0 and ifnull(`招聘中快递员`, 0)+ifnull(`待入职快递员`, 0)=0
                    then 'the target courier of '||substring_index(store_name,'_',1)||' is '||ifnull(cast(`目标快递员_max_220w` as decimal), 0)||
                         if(ifnull(`近7日严重低效员工数量`,0)+ifnull(`近7日严重出门晚员工数量`,0)+ifnull(`近7天出勤小于4天员工数量`,0)>0,',In the past 7 days,there were ','')||
                         ifnull( nullif(`近7日严重低效员工数量`,0)||' inefficient(Van<70,Bike<90) couriers,','')||ifnull(nullif(`近7日严重出门晚员工数量`,0)||' late(before 12:00,POD rate <10% ) couriers,','')||
                         ifnull(nullif(`近7天出勤小于4天员工数量`,0)||' courier work less than 4 days,','')||
                         if(ifnull(`近7日严重低效员工数量`,0)+ifnull(`近7日严重出门晚员工数量`,0)+ifnull(`近7天出勤小于4天员工数量`,0),'which needs to be improved','')||'.'
        end                    as 'crr_reject_reason_en'

           , case
                 when ifnull(`审批中dco`, 0) > 0 and IFNULL(`DCO可新增HC数`, 0) > 0
                     then least(ifnull(`审批中dco`, 0), ifnull(`DCO可新增HC数`, 0))
                 when ifnull(`审批中dco`, 0) > 0 and IFNULL(`DCO可新增HC数`, 0) = 0 and ifnull(`DCO超多少`, 0) > 0
                     then 0

                 when ifnull(`审批中dco`, 0) > 0 and IFNULL(`DCO可新增HC数`, 0) = 0 and
                      ifnull(`DCO超多少`, 0) = 0 and
                      ifnull(`总计仓管HC`, 0) + ifnull(`待入职DCO`, 0) > 0 then 0
                 when ifnull(`审批中dco`, 0) > 0 and IFNULL(`DCO可新增HC数`, 0) = 0 and
                      ifnull(`DCO超多少`, 0) = 0 and
                      ifnull(`总计仓管HC`, 0) + ifnull(`待入职DCO`, 0) = 0 then null
        end                    as 'dco_hc_num'

           , case
                 when ifnull(`审批中dco`, 0) > 0 and IFNULL(`DCO可新增HC数`, 0) > 0 then '单量测算可增加HC'
                 when ifnull(`审批中dco`, 0) > 0 and IFNULL(`DCO可新增HC数`, 0) = 0 and ifnull(`DCO超多少`, 0) > 0
                     then '已超员'

                 when ifnull(`审批中dco`, 0) > 0 and IFNULL(`DCO可新增HC数`, 0) = 0 and
                      ifnull(`DCO超多少`, 0) = 0 and
                      ifnull(`总计仓管HC`, 0) + ifnull(`待入职DCO`, 0) > 0 then '有待入职/招聘中'
                 when ifnull(`审批中dco`, 0) > 0 and IFNULL(`DCO可新增HC数`, 0) = 0 and
                      ifnull(`DCO超多少`, 0) = 0 and
                      ifnull(`总计仓管HC`, 0) + ifnull(`待入职DCO`, 0) = 0 then '待定，离职可通过'
        end                    as 'dco_hc_marker'

           , case
                 when ifnull(`审批中dco`, 0) > 0 and IFNULL(`DCO可新增HC数`, 0) > 0 then '是'
                 when ifnull(`审批中dco`, 0) > 0 and IFNULL(`DCO可新增HC数`, 0) = 0 and ifnull(`DCO超多少`, 0) > 0
                     then '否'

                 when ifnull(`审批中dco`, 0) > 0 and IFNULL(`DCO可新增HC数`, 0) = 0 and
                      ifnull(`DCO超多少`, 0) = 0 and
                      ifnull(`总计仓管HC`, 0) + ifnull(`待入职DCO`, 0) > 0 then '否'
                 when ifnull(`审批中dco`, 0) > 0 and IFNULL(`DCO可新增HC数`, 0) = 0 and
                      ifnull(`DCO超多少`, 0) = 0 and
                      ifnull(`总计仓管HC`, 0) + ifnull(`待入职DCO`, 0) = 0 then '待定'
        end                    as 'dco_hc_res'

           ,IF(tgt_absv>`总ABSV`,'是','否') 'ABSV是否可加HC'
           ,greatest(tgt_absv-`总ABSV`,0) '可加ABSVHC数量'
           ,IF(tgt_bsv>`总BSV`,'是','否') 'BSV是否可加HC'
           ,greatest(tgt_bsv-`总BSV`,0) '可加BSVHC数量'
      from (select tb1.store_id
                 , tb1.store_name
                 , if(ssbb.bdc_id is not null, 'BSP', if(ss1.`category` = 1, 'SP', 'BDC'))               'ctgr'
                 , case
                       when tb1.`manage_region_name` in
                            ('Area2', 'Area4', 'Area5', 'Area7', 'Area8', 'Area9', 'Area11', 'Area12', 'Area13',
                             'Area15', 'Area16') then 'A网'
                       else 'B网'
              end                                                      as                                '分类'
                 , tb1.manage_piece_name                                                                 '片区'
                 , tb1.`manage_region_name`                                                              '大区'
                 , regexp_replace(TB1.manage_piece_name, '[^A-Z]', '') AS                                '区域' #zn,
                 , ss1.province_code
                 , case
                       when ss1.province_code in ('TH01', 'TH02', 'TH03', 'TH04') THEN 'GBKK'
                       else '非GBKK'
              end                                                      as                                '是否GBKK'
                 , sp.en_name
                 , sp.name                                                                               'province'
                 , ss1.city_code
                 , sc.name                                                                               'city'
                 , ss1.district_code
                 , sd.name                                                                               'district'
                 , tb1.`日均到件_基础`
                 , tb1.`日均揽件_基础`
                 , tb1.`日均到件_基础_wkd5`
                 , tb1.`日均揽件_基础_wkd5`
                 , tb1.`日均到件_220w`                                                                   '日均到件_220w'
                 , tb1.`日均揽件_220w`                                                                   '日均揽件_220w'
                 , tb1.`快递员220w单量`                                                                  '快递员测算包裹量_220w'
                 , tb1.`修正饱和人效`
                 , tb1.`饱和人效`
                 , tb1.`快递员基础单量`
                 , tb1.`快递员基础单量_wkd5`
                 , tb1.`基础快递员目标`                                                                  '基础快递员目标'
                 , tb1.`基础快递员目标_wkd5`
                 , tb1.`快递员目标220w`                                                                  '快递员目标220w'
-- ,tb2.`MA7EFF`
-- ,round((tb1.`63日日均揽件量` / 10 + tb1.`63日日均到港量`)/ tb2.`MA7EFF` * 1.4, 0) '目标快递员数_MA7'
                 , tb3.`在职Courier`                                                                     '在职快递员'
                 , COALESCE(tb3.`待入职总计Courier`, 0)                                                  '待入职快递员'
                 , tb3.`待离职快递员数`                                                                  '待离职快递员'
                 , tb3.`停职Courier`                                                                     '停职快递员'
                 , tb3.`总快递员`
                 , tb3.`在职Courier` * tb1.`饱和人效` * 6 / 7                                            '在职运力'
                 , tb3.`待入职总计Courier` * tb1.`饱和人效` * 6 / 7                                      '待入职运力'
                 , tb3.`总计快递员HC` * tb1.`饱和人效` * 6 / 7                                           '招聘中运力'
                 , tb3.`总快递员` * tb1.`饱和人效` * 6 / 7                                               '合计运力'
                 , COALESCE(tb3.`总计快递员HC`, 0)                                                       '招聘中快递员'
                 , tb3.`总计快递员HCp1`                                                                  '招聘中快递员p1'
                 , tb3.`总计快递员HCp2`                                                                  '招聘中快递员p2'
                 , tb3.`总VAN`
                 , tb3.`在职Van Courier`                                                                 '在职VAN'
                 , tb3.`待入职总计Van`                                                                   '待入职VAN'
                 , tb3.`待离职Van`                                                                       '待离职VAN'
                 , tb3.`停职Van Courier`                                                                 '停职VAN'
                 , tb3.`总计VANHC`                                                                       '招聘中VAN'
                 , tb3.`总BIKE`                                                                          '总BIKE'
                 , tb3.`总计BIKEHC`                                                                      '招聘中BIKE'
                 , case
                       when
                                   tb1.`目标快递员_max_220w` - tb3.`总快递员` > 0
                           then tb1.`目标快递员_max_220w` - tb3.`总快递员`
                       else null end                                   as                                '快递员可新增HC数'


                 , case
                       when COALESCE(tb3.`总快递员`, 0) > COALESCE(tb1.`目标快递员_max_220w`, 0)
                           then COALESCE(tb3.`总快递员`, 0) - COALESCE(tb1.`目标快递员_max_220w`, 0)
                       else null end                                   as                                '快递员超多少'

                 , case
                       when COALESCE(tb3.`总快递员`, 0) - COALESCE(tb1.`目标快递员_max_220w`, 0) > 0 and
                            tb3.`总计快递员HC` > 0
                           then least(tb3.`总快递员` - tb1.`目标快递员_max_220w`, tb3.`总计快递员HC`)
                       else null end                                   as                                '快递员超员-招聘中'

                 , case
                       when COALESCE(tb3.`总快递员`, 0) - COALESCE(tb1.`目标快递员_max_220w`, 0) -
                            COALESCE(tb3.`总计快递员HC`, 0) > 0 and tb3.`待入职总计Courier` > 0
                           then least(COALESCE(tb3.`总快递员`, 0) - COALESCE(tb1.`目标快递员_max_220w`, 0) -
                                      COALESCE(tb3.`总计快递员HC`, 0), tb3.`待入职总计Courier`)
                       else null end                                   as                                '快递员超员-待入职'


                 , ss1.opening_at                                                                        '开业日期'
                 , ss1.delivery_frequency                                                                '派次'
                 , sd.`upcountry`                                                                        '偏远区域'
                 , sd.island                                                                             '是否海岛'
                 , case
                       when tb1.manage_piece_name like '%BKK%' THEN 'BKK'
                       WHEN tb1.manage_piece_name LIKE '%CE%' THEN 'CE'
                       ELSE NULL END                                   AS                                'BKK和CE区'
                 , CASE
                       WHEN tb1.store_id IN ('TH20040302',
                                             'TH20040212',
                                             'TH20040248',
                                             'TH20040802',
                                             'TH20040246',
                                             'TH20040307',
                                             'TH20040301',
                                             'TH20040700',
                                             'TH20040103',
                                             'TH20040247',
                                             'TH20040401',
                                             'TH20040602'
                           ) THEN '芭提雅'
                       WHEN tb1.store_id IN (
                                             'TH67010300',
                                             'TH67010604',
                                             'TH67010401',
                                             'TH67010103',
                                             'TH67010405',
                                             'TH67010403',
                                             'TH67010201',
                                             'TH67030400',
                                             'TH67030202',
                                             'TH67030102',
                                             'TH67010700',
                                             'TH67020202',
                                             'TH67010506',
                                             'TH67030500',
                                             'TH67020103',
                                             'TH67030103'
                           ) THEN '普吉岛'
                       ELSE NULL END                                   AS                                '旅游区域'
                 , svo.ovrflw_ystd                                                                       '昨日爆仓'
                 , svo.ovrFlw14                                                                          '14日爆仓'
                 , svo.svrOvrFlw                                                                         '严重爆仓'
                 , svo.ovrFlw7                                                                           '7日爆仓'
                 , svo.`7日支援`
                 , svo.`昨日支援`
                 , svo.`昨日积压`
                 , svo.`昨日应派`
                 , svo.`昨日妥投`
                 , cast(round(svo.`近5个工作日日均积压`,0) as decimal ) '近5个工作日日均积压'
                 , dr.dlvrRt7                                                                            '7日妥投率'
                 , dr.dlvrRt_5wkds                                                                       '5个工作日妥投率'
                 , os.sumOtSrc                                                                           '七日外协'
                 , os.out_src_ystd                                                                       '昨日外协'
                 , drt.avgDrtn7                                                                          '7日妥投时长'

                 , TB3.`总VAN` / tb3.`总快递员`                                                          'VAN_PCT'
                 , COALESCE(tb4.本月入职快递员数, 0)                                                     '本月入职快递员数'
                 , COALESCE(tb4.上月入职快递员数, 0)                                                     '上月入职快递员数'
                 , COALESCE(tb4.前月入职快递员数, 0)                                                     '前月入职快递员数'

                 , COALESCE(tb4.本月入职DCO数, 0)                                                        '本月入职DCO数'
                 , COALESCE(tb4.上月入职DCO数, 0)                                                        '上月入职DCO数'
                 , COALESCE(tb4.前月入职DCO数, 0)                                                        '前月入职DCO数'

                 , COALESCE(tb5.本月离职快递员数, 0)                                                     '本月离职快递员数'
                 , COALESCE(tb5.上月离职快递员数, 0)                                                     '上月离职快递员数'
                 , COALESCE(tb5.前月离职快递员数, 0)                                                     '前月离职快递员数'

                 , COALESCE(tb5.本月离职DCO数, 0)                                                        '本月离职DCO数'
                 , COALESCE(tb5.上月离职DCO数, 0)                                                        '上月离职DCO数'
                 , COALESCE(tb5.前月离职DCO数, 0)                                                        '前月离职DCO数'
                 , cast(round(tb1.`arrive_cnt_avg_dco` + tb1.`pickup_cnt_avg_dco`,0) as decimal )                                  'DCO测算包裹量'
                 , tb3.`在职DC`                                                                          '在职DCO'
                 , tb3.`待入职总计DC`                                                                    '待入职DCO'
                 , tb3.`总计仓管HC`                                                                      '总计仓管HC'
                 , tb3.`总计仓管HC招聘`                                                                  '总计仓管HC招聘'
                 , tb3.`总计仓管HC离职`                                                                  '总计仓管HC离职'
                 , tb3.`待离职DCO数`                                                                     '待离职DCO'
                 , tb3.`停职DC`                                                                          '停职DC'
                 , tb3.`转岗中DCO`
                 , tb3.`待转出DCO`
                 , tb3.`转岗中快递员`
                 , tb3.`待转出快递员`
                 , tb3.`总DCO`
                 , `揽件5kg以上比例`
                 , `到件大件比例(5kg)`
                 , case
                       when
                                   tb1.`目标dco_max_220w` - tb3.`总DCO` > 0
                           then tb1.`目标dco_max_220w` - tb3.`总DCO`
                       else null end                                   as                                'DCO可新增HC数'

                 , case
                       when COALESCE(tb3.`总DCO`, 0) > COALESCE(tb1.`目标dco_max_220w`, 0)
                           then tb3.`总DCO` - tb1.`目标dco_max_220w`
                       else null end                                   as                                'DCO超多少'

                 , case
                       when COALESCE(tb3.`总DCO`, 0) - COALESCE(tb1.`目标dco_max_220w`, 0) > 0 and
                            tb3.`总计仓管HC` > 0
                           then least(tb3.`总DCO` - tb1.`目标dco_max_220w`, tb3.`总计仓管HC`)
                       else null end                                   as                                'DCO超员-招聘中'

                 , case
                       when COALESCE(tb3.`总DCO`, 0) - COALESCE(tb1.`目标dco_max_220w`, 0) -
                            COALESCE(tb3.`总计仓管HC`, 0) >
                            0 and COALESCE(tb3.`待入职总计DC`, 0) > 0
                           then least(COALESCE(tb3.`总DCO`, 0) - COALESCE(tb1.`目标dco_max_220w`, 0) -
                                      COALESCE(tb3.`总计仓管HC`, 0), COALESCE(tb3.`待入职总计DC`, 0))
                       else null end                                   as                                'DCO超员-待入职'
                 , dco人效
                 , 目标dco_基础
                 , 目标dco_220


                 , round(目标快递员_max_220w * 0.1)                                                      '目标VAN'
                 , greatest(tb3.`总VAN` - round(目标快递员_max_220w * 0.1), 0)                           '总VAN超目标VAN多少'
                 , `审批中快递员`
                 , `审批中dco`
                 , `近30天离职快递员数` / (COALESCE(tb3.`在职Courier`, 0) + COALESCE(tb3.`停职Courier`, 0) +
                                           COALESCE(`近30天离职快递员数`, 0))                            'leave_rate'
                 , floor((COALESCE(os.sumOtSrc, 0) + COALESCE(svo.`7日支援`, 0)) / 7)                    '近7日均资源'
                 , greatest(floor((COALESCE(os.sumOtSrc, 0) + COALESCE(svo.`7日支援`, 0)) / 7) -
                            round(tb3.`在职Courier` * (0.85 - least(att_rates.att_rates_7, 0.85))), 0)   '修正近7日均资源'
                 , dlv_length
                 , piece_length_30_min4
                 , 近7日日均到件
                 , 近7日目的地揽收
                 , tbxx.`双重预警`
                 , tbxx.今日应派
                 , tbxx.今日妥投
                 , tbxx.今日积压

                 , att_rates.att_rates_7
                 , att_rates.att_rates_wkds5
                 , att_rates.att_rates_1
                 , att_rates.att_rates_td
                 , stock_data.本月MA5
                 , stock_data.本月MA7
                 , stock_data.本月工作日平均人效
                 , stock_data.上月MA5
                 , stock_data.上月MA7
                 , stock_data.上月工作日平均人效
                 , stock_data.前月MA5
                 , stock_data.前月MA7
                 , stock_data.前月工作日平均人效
                 , stock_data.昨日低效员工数量
                 , stock_data.近7日严重低效员工数量
                 , stock_data.昨日出门晚员工数量
                 , stock_data.近7日严重出门晚员工数量
                 , stock_data.昨日只揽不派员工数量
                 , stock_data.近7日严重只揽不派晚员工数量
                 , stock_data.近7天出勤小于4天员工数量
                 ,stock_data.`昨日到网点最早一班车的预计到达时间`
                 ,stock_data.`昨日到网点最早一班车的实际到达时间`
                 ,stock_data.`昨日9点前到网点最后一趟车预计到达时间`
                 ,stock_data.`昨日9点前到网点最后一趟车实际到达时间`
                 , 目标快递员_max_220w
                 , cast(目标dco_max_220w as decimal ) '目标dco_max_220w'
                 , round(svo.`昨日应派` - svo.`昨日妥投` * greatest(0.85 / att_rates.att_rates_1, 1), 0) '修正昨日积压'
                 ,tb3.片区总快递员
                 ,data_825.最终目标快递员 '片区目标快递员'
                 ,(ifnull(tb3.片区总快递员,0)>ifnull(data_825.最终目标快递员,0)) '片区快递员是否超员'
                 ,greatest(ifnull(tb3.片区总快递员,0)-ifnull(data_825.最终目标快递员,0),0) '片区快递员超员人数'
                 #if(ssbb.bdc_id is not null, 'BSP', if(ss1.`category` = 1, 'SP', 'BDC'))               'ctgr'
                 ,总DCO_NON_ABSV
                 ,case
                      when  if(ssbb.bdc_id is not null, 'BSP', if(ss1.`category` = 1, 'SP', 'BDC'))='SP' and 总DCO_NON_ABSV>4
                          then CEILING((ifnull(arrive_cnt_avg_dco,0)+ifnull(pickup_cnt_avg_dco,0))/5000)
                      when  if(ssbb.bdc_id is not null, 'BSP', if(ss1.`category` = 1, 'SP', 'BDC'))='BSP' and 总DCO_NON_ABSV>4
                          then CEILING((ifnull(arrive_cnt_avg_dco,0)+ifnull(pickup_cnt_avg_dco,0))/4000)
                      when  if(ssbb.bdc_id is not null, 'BSP', if(ss1.`category` = 1, 'SP', 'BDC'))='BDC' and 总DCO_NON_ABSV>4
                          then CEILING((ifnull(arrive_cnt_avg_dco,0)+ifnull(pickup_cnt_avg_dco,0))/3000)
                      else 0
              end as 'tgt_absv'
                 ,`在职ABSV`
                 ,`停职ABSV`
                 ,`待离职ABSV数`
                 ,`总计ABSVHC`
                 ,`待入职总计ABSV`
                 ,`审批中ABSV`
                 , `总ABSV`
                 ,1 as 'tgt_bsv'
                 ,`在职BSV`
                 ,`停职BSV`
                 ,`待离职BSV数`
                 ,`总计BSVHC`
                 ,`待入职总计BSV`
                 ,`审批中BSV`
                 , `总BSV`
            from (select store_id
                       , store_name
                       , manage_piece_name
                       , manage_region_name
                       , ori_tpeffc             '饱和人效'
                       , tpeffc                 '修正饱和人效'
                       , arrive_cnt_avg         '日均到件_基础'
                       , pickup_cnt_avg         '日均揽件_基础'
                       , arrive_cnt_220         '日均到件_220w'
                       , pickup_cnt_220         '日均揽件_220w'
                       , basic_pcl_cnt          '快递员基础单量'
                       , pcl_cnt_220            '快递员220w单量'
                       , basic_pcl_cnt_crr      '基础快递员目标'
                       , pcl_cnt_220_crr        '快递员目标220w'
                       , 目标dco                '目标dco_基础'
                       , 目标dco_220
                       , arrive_cnt_avg_dco
                       , pickup_cnt_avg_dco
                       , case
                             when arrive_cnt_sum > 2200000 then pcl_cnt_220_crr
                             else basic_pcl_cnt_crr
                    end as                      '目标快递员_max_220w'
                       , case
                             when arrive_cnt_sum > 2200000 then 目标dco_220
                             else 目标dco
                    end as                      '目标dco_max_220w'
                       , 到件大件比例           '到件大件比例(5kg)'
                       , 揽件5kg以上比例        '揽件5kg以上比例'
                       , 目标DCO
                       , dco人效
                       , dlv_length
                       , piece_length_30_min4
                       , arrive_cnt_avg_wkd5    '日均到件_基础_wkd5'
                       , pickup_cnt_avg_wkd5    '日均揽件_基础_wkd5'
                       , basic_pcl_cnt_wkd5     '快递员基础单量_wkd5'
                       , basic_pcl_cnt_crr_wkd5 '基础快递员目标_wkd5'
                  from tmpale.tmp_th_tgt_pop tttp
                  where tttp.p_date=(select max(p_date) from tmpale.tmp_th_tgt_pop)
                 ) tb1

                     LEFT JOIN
                 (select 网点id,
                         名称1,
                         片区,
                         大区,
                         在职Courier                               '在职Courier',
                         待入职总计Courier                        '待入职总计Courier',
                         总计快递员HC                              '总计快递员HC',
                         总计快递员HCp1                            '总计快递员HCp1',
                         总计快递员HCp2                           '总计快递员HCp2',
                         总计快递员HC新增                          '总计快递员HC新增',
                         总计快递员HC离职                          '总计快递员HC离职',
                         待离职快递员数                            '待离职快递员数',
                         停职Courier                               '停职Courier',
                         ifnull(在职Courier, 0) + ifnull(待入职总计Courier, 0) +
                         ifnull(总计快递员HC, 0) - ifnull(待离职快递员数, 0) +
                         ifnull(停职Courier, 0)                  '在职+待入职+招聘中+停职-待离职快递员数',

                         `在职Van Courier`                        '在职Van Courier',
                         `待入职总计Van`                           '待入职总计Van',
                         `总计VANHC`                               '总计VANHC',
                         `待离职Van`                               '待离职Van',
                         `停职Van Courier`                         '停职Van Courier',
                         ifnull(`在职Van Courier`, 0) + ifnull(`待入职总计Van`, 0) +
                         ifnull(`总计VANHC`, 0) - ifnull(`待离职Van`, 0) +
                         ifnull(`停职Van Courier`, 0)            '在职+待入职+招聘中+停职-待离职Van',

                         `在职Bike Courier`                       '在职Bike Courier',
                         `待入职总计Bike`                         '待入职总计Bike',
                         `总计BIKEHC`                            '总计BIKEHC',
                         `待离职Bike`                            '待离职Bike',
                         `停职Bike Courier`                       '停职Bike Courier',
                         ifnull(`在职Bike Courier`, 0) + ifnull(`待入职总计Bike`, 0) +
                         ifnull(`总计BIKEHC`, 0) - ifnull(`待离职Bike`, 0) +
                         ifnull(`停职Bike Courier`, 0)           '在职+待入职+招聘中+停职-待离职Bike',

                         `在职Boat Courier`                        '在职Boat Courier',
                         `待入职总计Boat`                         '待入职总计Boat',
                         `总计BOATHC`                              '总计BOATHC',
                         `待离职Boat`                             '待离职Boat',
                         `停职Boat Courier`                        '停职Boat Courier',
                         ifnull(`在职Boat Courier`, 0) + ifnull(`待入职总计Boat`, 0) +
                         ifnull(`总计BOATHC`, 0) - ifnull(`待离职Boat`, 0) +
                         ifnull(`停职Boat Courier`, 0)           '在职+待入职+招聘中+停职-待离职Boat',

                         ifnull(`在职DC`,0)+ifnull(`在职ABSV`, 0)                        '在职DC',
                         ifnull(`待入职总计DC` ,0) +IFNULL(`待入职总计ABSV`,0)              '待入职总计DC',
                         ifnull(`总计仓管HC`,0) +IFNULL(`总计ABSVHC`,0)                    '总计仓管HC',
                         ifnull(`总计仓管HC招聘`,0)+ifnull(`总计ABSVHC招聘`,0)             '总计仓管HC招聘',
                         ifnull(`总计仓管HC离职`,0)+ifnull(`总计ABSVHC离职`,0)               '总计仓管HC离职',

                         `待离职DCO数`                             '待离职DCO数',
                         `停职DC`                                  '停职DC',
                         ifnull(`在职DC`, 0) + ifnull(`待入职总计DC`, 0) +
                         ifnull(`总计仓管HC`, 0) - ifnull(`待离职DCO数`, 0) +
                         ifnull(`停职DC`, 0)                     '在职+待入职+招聘中+停职-待离职DC',
                         `转岗中快递员`                            '转岗中快递员'
                          ,`待转出快递员`                            '待转出快递员'
                          ,`转岗中dco`                               '转岗中dco'
                          ,`待转出dco`                               '待转出dco'
                          ,ifnull(在职Courier, 0) + ifnull(待入职总计Courier, 0) +
                           ifnull(总计快递员HC, 0) + ifnull(停职Courier, 0) -
                           ifnull(待离职快递员数, 0)+IFNULL(`转岗中快递员`,0) as            '总快递员'
                          ,ifnull(`在职Van Courier`, 0) + ifnull(`待入职总计Van`, 0) +
                           ifnull(`总计VANHC`, 0) + ifnull(`停职Van Courier`, 0) -
                           ifnull(`待离职Van`, 0)                  '总VAN'
                          ,ifnull(`在职Bike Courier`, 0) + ifnull(`待入职总计Bike`, 0) +
                           ifnull(`总计BIKEHC`, 0) + ifnull(`停职Bike Courier`, 0) -
                           ifnull(`待离职Bike`, 0)                 '总Bike'

                          ,ifnull(在职DC, 0) + ifnull(待入职总计DC, 0) + ifnull(总计仓管HC, 0) +
                           ifnull(停职DC, 0) - ifnull(待离职DCO数, 0)+IFNULL(`转岗中dco`,0) '总DCO_NON_ABSV'
                          ,ifnull(在职DC, 0) + ifnull(待入职总计DC, 0) + ifnull(总计仓管HC, 0) +
                           ifnull(停职DC, 0) - ifnull(待离职DCO数, 0)+IFNULL(`转岗中dco`,0)+
                           ifnull(在职ABSV, 0) + ifnull(待入职总计ABSV, 0) + ifnull(总计ABSVHC, 0) +
                           ifnull(停职ABSV, 0) - ifnull(待离职ABSV数, 0)+IFNULL(`ABSVTrsf`,0) '总DCO'
                          ,ifnull(`在职BSV`, 0)                      '在职BSV'
                          ,IFNULL(`停职BSV`,0)                         '停职BSV'
                          ,IFNULL(`待离职BSV数`)                             '待离职BSV数'
                          ,IFNULL(`总计BSVHC`)                              '总计BSVHC'
                          ,IFNULL(`待入职总计BSV`)                                      '待入职总计BSV'
                          ,IFNULL(`离职BSV数`)             '离职BSV数'
                          ,ifnull(在职BSV, 0) + ifnull(待入职总计BSV, 0) + ifnull(总计BSVHC, 0) +
                           ifnull(停职BSV, 0) - ifnull(待离职BSV数, 0) '总BSV'

                          ,ifnull(`在职ABSV`, 0)                   '在职ABSV'
                          ,IFNULL(`停职ABSV`,0)                     '停职ABSV'
                          ,IFNULL(`待离职ABSV数`,0)                 '待离职ABSV数'
                          ,IFNULL(`总计ABSVHC`,0)                '总计ABSVHC'
                          ,IFNULL(`待入职总计ABSV`,0)            '待入职总计ABSV'
                          ,IFNULL(`离职ABSV数`,0)             '离职ABSV数'
                          ,ifnull(在职ABSV, 0) + ifnull(待入职总计ABSV, 0) + ifnull(总计ABSVHC, 0) +
                           ifnull(停职ABSV, 0) - ifnull(待离职ABSV数, 0) '总ABSV'

                          ,crr_Approvaling                                '审批中快递员'
                          ,bike_Approvaling                               '审批中bike'
                          ,van_Approvaling                                '审批中van'
                          ,car_Approvaling                                '审批中car'
                          ,dco_Approvaling                                '审批中dco'
                          ,BSV_Approvaling                                      '审批中BSV'
                          ,ABSV_Approvaling                                  '审批中ABSV'
                          ,`近30天离职快递员数`                     '近30天离职快递员数'
                          ,sum(ifnull(在职Courier, 0) + ifnull(待入职总计Courier, 0) +ifnull(总计快递员HC, 0) - ifnull(待离职快递员数, 0) +ifnull(停职Courier, 0)) over(partition by 片区) '片区总快递员'
                  from (SELECT distinct tb0.名称       '名称1'
                                      , tb0.片区
                                      , tb0.大区
                                      , tb0.分类
                                      , tb0.网点id
                                      , tb1.总在职人数
                                      , tb1.在职Courier
                                      , tb1.`在职Bike Courier`, tb1.`在职Van Courier` , tb1.`在职Boat Courier`, tb1.在职DC, tb1.在职BSV,tb1.在职ABSV
                                      , tb2.总停职人数, tb2.停职Courier, tb2.`停职Bike Courier`, tb2.`停职Van Courier`, tb2.`停职Boat Courier`, tb2.停职DC,tb2.停职BSV,tb2.停职ABSV
                                      , tb3.网点离职总人数, tb3.离职快递员数, tb3.离职Van, tb3.离职Bike, tb3.离职Boat, tb3.离职DCO数,tb3.离职ABSV数,tb3.离职BSV数
                                      , tb4.待入职总计, tb4.待入职总计Courier, tb4.待入职总计Van, tb4.待入职总计Bike, tb4.待入职总计Boat, tb4.待入职总计DC,tb4.待入职总计ABSV,tb4.待入职总计BSV
                                      , tb5.总计HC, tb5.总计快递员HC, tb5.总计快递员HCp1, tb5.总计快递员HCp2, tb5.总计快递员HC新增, tb5.总计快递员HC离职, tb5.总计VANHC,tb5.总计ABSVHC,tb5.总计BSVHC
                                      , tb5.总计BOATHC, tb5.总计BIKEHC, tb5.总计仓管HC, tb5.总计仓管HC招聘, tb5.总计仓管HC离职,tb5.总计BSVHC招聘,TB5.总计BSVHC离职,TB5.总计ABSVHC招聘,TB5.总计ABSVHC离职
                                      , tb6.网点待离职总人数, tb6.待离职快递员数, tb6.待离职Van, tb6.待离职Bike, tb6.待离职Boat, tb6.待离职DCO数,TB6.待离职ABSV数,TB6.待离职BSV数
                                      , tb7.crrTrsf    '转岗中快递员'
                                      , tb8.trnsOtCrr  '待转出快递员'
                                      , tb7.VanTrsf    '转岗中VAN'
                                      , tb8.trnsOtVan  '待转出VAN'
                                      , tb7.BikeTrsf   '转岗中Bike'
                                      , tb8.trnsOtBike '待转出Bike'
                                      , tb7.offcTrsf   '转岗中dco'
                                      , tb8.trnsOtoffc '待转出dco'
                                      ,TB7.ABSVTrsf
                                      ,TB7.BSVTrsf
                                      , tb9.crr_Approvaling
                                      , tb9.bike_Approvaling
                                      , tb9.van_Approvaling
                                      , tb9.car_Approvaling
                                      , tb9.dco_Approvaling
                                      ,TB9.ABSV_Approvaling
                                      ,tb9.BSV_Approvaling
                                      , tb10.`近30天离职快递员数`
                        from (select ss.id                 '网点id',
                                     ss.name               '名称',
                                     mp.`name`             '片区',
                                     mr.`name`             '大区',
                                     case
                                         when mr.`name`  in
                                              ('Area2', 'Area4', 'Area5', 'Area7', 'Area8', 'Area9', 'Area11', 'Area12', 'Area13',
                                               'Area15', 'Area16') then 'A网'
                                         else 'B网'
                                         end                                                      as  '分类',
                                     case ss.category
                                         when 1 then '收派件网点'
                                         when 2 then '分拨中心'
                                         when 4 then '揽件网点(市场)'
                                         when 5 then '收派件网点(shop)'
                                         when 6 then '加盟商网点'
                                         when 7 then '大学门店'
                                         when 8 then 'Hub'
                                         when 9 then 'OS=Onsite'
                                         when 10 then 'BigDC'
                                         when 11 then 'fulfillment'
                                         when 12 then 'B-HUB'
                                         when 13 then 'CDC'
                                         when 14 then 'PDC'
                                         end            as '网点类型',
                                     case
                                         when ss.name like '%BDC%' THEN 'BDC'
                                         WHEN SS.NAME LIKE '%SP%' THEN 'SP'
                                         ELSE 'OTHER'
                                         END            AS 'type'

                              from `fle_staging`.`sys_store` ss
                                       LEFT JOIN fle_staging.`sys_manage_region` mr on ss.`manage_region` = mr.`id`
                                       LEFT JOIN `fle_staging`.`sys_manage_piece` mp on ss.`manage_piece` = mp.`id`
                              where ss.category in (1, 10)) tb0
                                 left join
                             (select ss.id,
                                     ss.name                                                             '名称',
                                     count(distinct hr.`id`)                                             总在职人数,
                                     count(distinct if(hr.`job_title` in (13, 110, 452), hr.`id`, null)) 在职Courier,
                                     count(distinct if(hr.`job_title` in (13), hr.`id`, null))           '在职Bike Courier',
                                     count(distinct if(hr.`job_title` in (110), hr.`id`, null))          '在职Van Courier',
                                     count(distinct if(hr.`job_title` in (452), hr.`id`, null))          '在职Boat Courier',
                                     count(distinct if(hr.`job_title` in (37), hr.`id`, null))           在职DC,
                                     count(distinct if(hr.`job_title` in (16), hr.`id`, null))      在职BSV,
                                     count(distinct if(hr.`job_title` in (451), hr.`id`, null))      在职ABSV

                              FROM `fle_staging`.`staff_info` hr
                                       left join `fle_staging`.`sys_store` ss on hr.`organization_id` = ss.id
                              where hr.`job_title` in (13, 110, 37, 451, 16, 452) -- 主+仓+快递员
                                and hr.`formal` = 1
                                and hr.`state` = 1
                                and hr.`is_sub_staff` = 0
                                and ss.`category` in (1, 10)
-- and ss.`name` like 'BSP'
                              GROUP BY 1, 2) tb1 -- 在职
                             on tb1.id = tb0.`网点id`
                                 left JOIN
                             (select ss.id,
                                     ss.name                                                               '名称',
                                     count(distinct hr.`staff_info_id`)                                    总停职人数,
                                     count(distinct
                                           if(hr.`job_title` in (13, 110, 452), hr.`staff_info_id`, null)) 停职Courier,
                                     count(distinct
                                           if(hr.`job_title` in (13), hr.`staff_info_id`, null))           '停职Bike Courier',
                                     count(distinct
                                           if(hr.`job_title` in (110), hr.`staff_info_id`, null))          '停职Van Courier',
                                     count(distinct
                                           if(hr.`job_title` in (452), hr.`staff_info_id`, null))          '停职Boat Courier',
                                     count(distinct if(hr.`job_title` in (37), hr.`staff_info_id`, null))  停职DC,
                                     count(distinct if(hr.`job_title` in (16), hr.`staff_info_id`, null))  停职BSV,
                                     count(distinct if(hr.`job_title` in (451), hr.`staff_info_id`, null))  停职ABSV
                              FROM `bi_pro`.`hr_staff_info` hr
                                       left join `fle_staging`.`sys_store` ss on hr.`sys_store_id` = ss.id
                              where hr.`job_title` in (13, 110, 37, 451, 16, 452) -- 主+仓+快递员
                                and hr.`formal` = 1
                                and hr.`state` = 3
                                and hr.`is_sub_staff` = 0
                                and ss.id is not null
                                and ss.category in (1, 10)
-- and ss.`name` like 'BSP'
                              GROUP BY 1, 2
                              order by 1) tb2 -- 停职
                             on tb2.id = tb0.`网点id`

                                 left JOIN
                             (select id,
                                     名称,
                                     COUNT(DISTINCT (lz.`staff_info_id`))                                    网点离职总人数,
                                     COUNT(DISTINCT
                                           (if(lz.`job_title` in (13, 110, 452), lz.`staff_info_id`, null))) 离职快递员数,
                                     count(distinct
                                           (if(lz.`job_title` = 110, lz.`staff_info_id`, null)))          AS 离职Van,
                                     count(distinct (if(lz.`job_title` = 13, lz.`staff_info_id`, null)))  AS 离职Bike,
                                     count(distinct
                                           (if(lz.`job_title` = 452, lz.`staff_info_id`, null)))          AS 离职Boat,
                                     COUNT(DISTINCT (if(lz.`job_title` IN (37), lz.`staff_info_id`, null)))  离职DCO数,
                                     COUNT(DISTINCT (if(lz.`job_title` IN (16), lz.`staff_info_id`, null)))  离职BSV数,
                                     COUNT(DISTINCT (if(lz.`job_title` IN (451), lz.`staff_info_id`, null)))  离职ABSV数

                              from ( #离职明细
                                       select ss.id,
                                              ss.name         '名称',
                                              od.`一级部门`,
                                              od.`name`       直属部门,
                                              hr.`job_title`,
                                              jt.`job_name`   职位,
                                              hr.`leave_date` 离职日期,
                                              hr.`staff_info_id`
                                       FROM `bi_pro`.`hr_staff_info` hr
                                                LEFT JOIN `fle_staging`.`sys_store` ss on ss.`id` = hr.`sys_store_id`
                                                LEFT JOIN `bi_pro`.`hr_job_title` jt on jt.`id` = hr.`job_title`
                                                LEFT JOIN `fle_staging`.`sys_manage_piece` mp on mp.`id` = ss.`manage_piece`
                                                LEFT JOIN `fle_staging`.`sys_manage_region` mr on mr.id = ss.`manage_region`
                                                left join dwm.`dwd_hr_organizational_structure_detail` od
                                                          on cast(hr.sys_department_id AS CHAR) = cast(od.id AS CHAR)
                                                LEFT JOIN backyard_pro.hr_staff_items hri
                                                          on hri.staff_info_id = hr.staff_info_id and hri.item = 'WORKING_COUNTRY'
                                       where hr.`is_sub_staff` = 0
                                         -- and hri.value=3
                                         and hr.`sys_store_id` != -1
                                         and hr.`formal` in (1, 4)
                                         and hr.`state` = 2
                                         and ss.category in (1, 10)
                                         and hr.`leave_date` = current_date
                                         and od.`一级部门` in ('Network Management', 'Network Bulky')) lz

                              group by 1, 2
-- ORDER BY 1
                             ) tb3 -- 离职
                             on tb3.id = tb0.`网点id`
                                 left JOIN
                             (SELECT ss.id,
                                     ss.name                                                                      '名称',
                                     count(distinct (ho.`resume_id`))                                             待入职总计,
                                     count(distinct
                                           (if(hc.`job_title` in ('13', '452', '110'), ho.`resume_id`, null))) AS 待入职总计Courier,
                                     count(distinct (if(hc.`job_title` = '110', ho.`resume_id`, null)))        AS 待入职总计Van,
                                     count(distinct (if(hc.`job_title` = '13', ho.`resume_id`, null)))         AS 待入职总计Bike,
                                     count(distinct (if(hc.`job_title` = '452', ho.`resume_id`, null)))        AS 待入职总计Boat,
                                     count(distinct (if(hc.`job_title` IN (37), ho.`resume_id`, null)))        AS 待入职总计DC,
                                     count(distinct (if(hc.`job_title` IN (16), ho.`resume_id`, null)))        AS 待入职总计BSV,
                                     count(distinct (if(hc.`job_title` IN (451), ho.`resume_id`, null)))        AS 待入职总计ABSV
                              FROM `backyard_pro`.`hr_interview_offer` AS ho
                                       LEFT JOIN
                                   `backyard_pro`.`hr_hc` AS hc
                                   on ho.`hc_id` = hc.`hc_id`
                                       LEFT JOIN
                                   `backyard_pro`.`hr_entry` AS he
                                   on ho.`resume_id` = he.`resume_id`
                                       and he.`status` in ('1', '3') and he.`deleted` = 0
                                       JOIN
                                   `backyard_pro`.`sys_store` AS ss
                                   on hc.`worknode_id` = ss.`id`
                                       and ss.`category` in ('1', '10')
                                       and ho.`status` = '1'
                                       and hc.`job_title` in (13, 110, 452, 37, 451, 16)
                                       and he.`entry_id` is null
--   and hc.`priority_id` !=4
                              GROUP BY 1, 2) tb4 -- 待入职
                             on tb4.id = tb0.`网点id`
                                 left JOIN
                             (SELECT ss.id,
                                     ss.name                                                              '名称',
                                     sum(hc.surplusnumber)                                                总计HC,
                                     sum(if(jt.`id` in (13, 110, 452), hc.surplusnumber, 0))              总计快递员HC,
                                     sum(if(jt.`id` in (13, 110, 452) and hc.priority_id = 1, hc.surplusnumber,
                                            0))                                                           总计快递员HCp1,
                                     sum(if(jt.`id` in (13, 110, 452) and hc.priority_id = 2, hc.surplusnumber,
                                            0))                                                           总计快递员HCp2,
                                     sum(if(jt.`id` in (13, 110, 452) and hc.reason_type = 1, hc.surplusnumber,
                                            0))                                                           '总计快递员HC新增',
                                     sum(if(jt.`id` in (13, 110, 452) and hc.reason_type = 3, hc.surplusnumber,
                                            0))                                                           '总计快递员HC离职',
                                     sum(if(jt.`id` in (110), hc.surplusnumber, 0))                       总计VANHC,
                                     sum(if(jt.`id` in (452), hc.surplusnumber, 0))                       总计BOATHC,
                                     sum(if(jt.`id` in (13), hc.surplusnumber, 0))                        总计BIKEHC,
                                     sum(if(jt.`id` in (37), hc.surplusnumber, 0))                        总计仓管HC,
                                     sum(if(jt.`id` in (37) and hc.reason_type = 1, hc.surplusnumber, 0)) '总计仓管HC招聘',
                                     sum(if(jt.`id` in (37) and hc.reason_type = 3, hc.surplusnumber, 0)) '总计仓管HC离职',
                                     sum(if(jt.`id` in (16), hc.surplusnumber, 0))                        总计BSVHC,
                                     sum(if(jt.`id` in (16) and hc.reason_type = 1, hc.surplusnumber, 0)) '总计BSVHC招聘',
                                     sum(if(jt.`id` in (16) and hc.reason_type = 3, hc.surplusnumber, 0)) '总计BSVHC离职',
                                     sum(if(jt.`id` in (451), hc.surplusnumber, 0))                        总计ABSVHC,
                                     sum(if(jt.`id` in (451) and hc.reason_type = 1, hc.surplusnumber, 0)) '总计ABSVHC招聘',
                                     sum(if(jt.`id` in (451) and hc.reason_type = 3, hc.surplusnumber, 0)) '总计ABSVHC离职'
                              FROM `backyard_pro`.`hr_hc` hc
                                       LEFT JOIN `backyard_pro`.hr_jd jd on hc.`job_id` = jd.`job_id`
                                       LEFT JOIN fle_staging.`sys_department` sd on hc.department_id = sd.`id`
                                       left join bi_pro.hr_job_title jt on jt.id = hc.job_title
                                       left join `fle_staging`.sys_store ss on hc.worknode_id = ss.id
                              where hc.job_title in ( 16)
                                and hc.state_code = 2 -- 招聘中
                                and hc.deleted = 1    -- 未删除
                                and hc.reason_type <> 2
--   and hc.priority_id in(1,2,3)
                                and ss.`category` in (1, 10)
                              GROUP BY 1, 2) tb5 --  招聘中
                             on tb5.id = tb0.`网点id`
                                 left JOIN
                             (-- 待离职
                                 select ss.id,
                                        ss.name                                                                 '名称',
                                        COUNT(DISTINCT (hr.`staff_info_id`))                                    网点待离职总人数,
                                        COUNT(DISTINCT
                                              (if(hr.`job_title` in (13, 110, 452), hr.`staff_info_id`, null))) 待离职快递员数,
                                        count(distinct
                                              (if(hr.`job_title` = 110, hr.`staff_info_id`, null)))         AS  待离职Van,
                                        count(distinct (if(hr.`job_title` = 13, hr.`staff_info_id`, null))) AS  待离职Bike,
                                        count(distinct
                                              (if(hr.`job_title` = 452, hr.`staff_info_id`, null)))         AS  待离职Boat,
                                        COUNT(DISTINCT
                                              (if(hr.`job_title` IN (37), hr.`staff_info_id`, null)))           待离职DCO数,
                                        COUNT(DISTINCT
                                              (if(hr.`job_title` IN (16), hr.`staff_info_id`, null)))           待离职BSV数,
                                        COUNT(DISTINCT
                                              (if(hr.`job_title` IN (451), hr.`staff_info_id`, null)))           待离职ABSV数
                                 from `backyard_pro`.`staff_resign` sr
                                          left join `backyard_pro`.`audit_apply` aa
                                                    on biz_value = sr.resign_id and biz_type = 13 -- 离职申请
                                          left join backyard_pro.hr_staff_info hr
                                                    on aa.submitter_id = hr.staff_info_id -- 离职申请人信息
                                          LEFT JOIN `fle_staging`.`sys_store` ss
                                                    on ss.`id` = hr.`sys_store_id` -- 网点
                                          LEFT JOIN `fle_staging`.`sys_department` sd
                                                    on sd.`id` = hr.`node_department_id` -- 直属部门

                                 where 1
                                   and ss.`category` in (1, 10)
                                   and hr.state = 1
                                   and sr.status in (1, 2)
                                 group by 1, 2) tb6
                             on tb6.id = tb0.`网点id`
                                 LEFT JOIN
                             (SELECT hc.`worknode_id`                                                       AS strId,
                                     sum(if( hc.`reason_type` in ('2') and
                                             hc.`job_title` in ('13', '452', '110'), hc.`surplusnumber`,
                                             0))                                                             AS crrTrsf,
                                     sum(if(hc.`reason_type` in ('2') and
                                            hc.`job_title` in ('110'), hc.`surplusnumber`,
                                            0))                                                             AS vanTrsf,
                                     sum(if(hc.`reason_type` in ('2') and
                                            hc.`job_title` in ('13'), hc.`surplusnumber`,
                                            0))                                                             AS bikeTrsf,
                                     sum(if(hc.`reason_type` in ('2') and
                                            hc.`job_title` in ('37'), hc.`surplusnumber`,
                                            0))                                                             AS offcTrsf,
                                     sum(if(hc.`reason_type` in ('2') and
                                            hc.`job_title` in ('452'), hc.`surplusnumber`,
                                            0))                                                             AS ABSVTrsf,
                                     sum(if(hc.`reason_type` in ('2') and
                                            hc.`job_title` in ('16'), hc.`surplusnumber`,
                                            0))                                                             AS BSVTrsf
                              FROM `backyard_pro`.`hr_hc` AS hc
                              WHERE hc.`state_code` = '2'
                                and hc.`deleted` = '1'
--        and hc.`priority_id` in('1','2','4')
                                and hc.`job_title` in ('13', '452', '110', '37')
                              GROUP BY hc.`worknode_id`) AS tb7
                             on tb7.strId = tb0.`网点id`
                                 LEFT JOIN
                             (SELECT jt.`current_store_id`                                              AS strId,
                                     count(distinct
                                           (if(jt.`current_position_id` in ('13', '452', '110'), jt.`staff_id`,
                                               null)))                                                  AS trnsOtCrr,
                                     count(distinct
                                           (if(jt.`current_position_id` = '110', jt.`staff_id`, null))) AS trnsOtVan,
                                     count(distinct
                                           (if(jt.`current_position_id` = '13', jt.`staff_id`, null)))  AS trnsOtBike,
                                     count(distinct
                                           (if(jt.`current_position_id` in('37'), jt.`staff_id`, null)))  AS trnsOtOffc
                              FROM `backyard_pro`.`job_transfer` AS jt
                                       JOIN
                                   `fle_staging`.`staff_info` AS si
                                   on jt.`staff_id` = si.`id`
                                       and jt.`current_store_id` = si.`organization_id`
                                       and jt.`state` <> '3'
                                       and jt.`deleted` = '0'
                                       and jt.`approval_state` = '2'
                                       and jt.`current_position_id` in ('13', '452', '110', '37')
                                       and (jt.`current_store_id` <> jt.`after_store_id`
                                           or (jt.`current_position_id` in ('13', '452', '110') and
                                               jt.`after_position_id` not in ('13', '452', '110'))
                                           or (jt.`current_position_id` in ('37') and
                                               jt.`after_position_id` not in ('37')))
                              GROUP BY jt.`current_store_id`) AS tb8
                             on tb8.strId = tb0.`网点id`
                                 left join
                             (select worknode_id
                                   , sum(if(job_title in (13, 110, 1199), demandnumber, null)) 'crr_Approvaling'
                                   , sum(if(job_title in (13), demandnumber, null))            'bike_Approvaling'
                                   , sum(if(job_title in (110), demandnumber, null))           'van_Approvaling'
                                   , sum(if(job_title in (1199), demandnumber, null))          'car_Approvaling'
                                   , sum(if(job_title in (37), demandnumber, null))            'dco_Approvaling'
                                   , sum(if(job_title in (16), demandnumber, null))            'BSV_Approvaling'
                                   , sum(if(job_title in (451), demandnumber, null))            'ABSV_Approvaling'
                              from backyard_pro.hr_hc hh
                              where 1 = 1
                                and job_title in (13, 110, 1199, 37)
                                and state_code = 1
                                and reason_type in (1, 3)
                                and approval_state_code = 7
                              group by 1) tb9 on tb9.worknode_id = tb0.`网点id`
                                 left join
                             (select lz.网点名称,
                                     lz.网点id                                                                     '网点id1',
                                     COUNT(DISTINCT (if(lz.`job_title` in (13, 110, 452) and
                                                        timestampdiff(day, `离职日期`, current_date) < 30,
                                                        lz.`staff_info_id`,
                                                        null)))                                                    '近30天离职快递员数',
                                     COUNT(DISTINCT (if(lz.`job_title` = 37 and
                                                        timestampdiff(day, `离职日期`, current_date) < 30,
                                                        lz.`staff_info_id`,
                                                        null)))                                                    '近30天离职DCO数',

                                     COUNT(DISTINCT
                                           (if(lz.`job_title` in (13, 110, 452) and monthsdiff = 0,
                                               lz.`staff_info_id`,
                                               null)))                                                             '本月离职快递员',
                                     COUNT(DISTINCT
                                           (if(lz.`job_title` in (13, 110, 452) and monthsdiff = 1,
                                               lz.`staff_info_id`,
                                               null)))                                                             '上月离职快递员',

                                     COUNT(DISTINCT
                                           (if(lz.`job_title` = 37 and monthsdiff = 0, lz.`staff_info_id`, null))) '本月离职DCO数',
                                     COUNT(DISTINCT
                                           (if(lz.`job_title` = 37 and monthsdiff = 1, lz.`staff_info_id`, null))) '上月离职DCO数'

                              from ( #离职明细
                                       SELECT mr.`name`              大区,
                                              mp.`name`              片区,
                                              hr.`sys_store_id`      网点id,
                                              ss.`name`              网点名称,
                                              hr.`job_title`,
                                              jt.`job_name`          职位,
                                              year(CURDATE()) * 12 + month(CURDATE()) -
                                              year(hr.`leave_date`) * 12 -
                                              month(hr.`leave_date`) 'monthsdiff',
                                              hr.`leave_date`        离职日期,
                                              hr.`staff_info_id`
                                       FROM `bi_pro`.`hr_staff_info` hr
                                                LEFT JOIN `fle_staging`.`sys_store` ss on ss.`id` = hr.`sys_store_id`
                                                LEFT JOIN `bi_pro`.`hr_job_title` jt on jt.`id` = hr.`job_title`
                                                LEFT JOIN `fle_staging`.`sys_manage_piece` mp on mp.`id` = ss.`manage_piece`
                                                LEFT JOIN `fle_staging`.`sys_manage_region` mr on mr.id = ss.`manage_region`
                                       where hr.`is_sub_staff` = 0
                                         and hr.`sys_store_id` != -1
                                         and hr.`formal` in (1, 4)
                                         and hr.`state` = 2
                                         -- and year(CURDATE())*12+month(CURDATE())-year(hr.`leave_date`)*12-month(hr.`leave_date`)<2
                                         and timestampdiff(day, hr.`leave_date`, current_date) < 90) lz
                              group by 1, 2) tb10 on tb10.网点id1 = tb0.`网点id`
                        where COALESCE(tb1.名称, tb2.名称, tb3.名称, tb4.名称, tb5.名称, tb6.名称, tb7.strId,
                                       tb8.strId) is not NULL) tbx) tb3
                 on tb1.store_id = tb3.`网点id`
                     LEFT JOIN
                 (select 网点ID                 'id'
                       , `7日支援`
                       , `昨日积压`
                       , `昨日应派`
                       , `昨日妥投`
                       , `昨日支援`
                       , 近5个工作日日均积压
                       , if(exp_ystd = 1, 1, 0) 'ovrflw_ystd'
                       , if(exp_14d > 0, 1, 0)  'ovrFlw14'
                       , if(exp_7d > 0, 1, 0)   'ovrFlw7'
                       , if(exp_7d >= 3, 1, 0)  'svrOvrFlw'
                  from (select 网点ID
                             , count(distinct
                                     if(双重预警 = 'Alert' and 统计日期 = CURDATE() - interval 1 day, 统计日期, null))  'exp_ystd'
                             , count(distinct if(双重预警 = 'Alert', 统计日期, null))                                   'exp_14d'
                             , count(distinct
                                     if(双重预警 = 'Alert' and 统计日期 >= CURDATE() - interval 7 day, 统计日期, null)) 'exp_7d'
                             , sum(if(统计日期 >= CURDATE() - interval 7 day, 打卡的支援快递员, null))                  '7日支援'
                             , sum(if(统计日期 = CURDATE() - interval 1 day, 打卡的支援快递员, null))                   '昨日支援'
                             , avg(if(统计日期 = CURDATE() - interval 1 day, 未妥投, null))                             '昨日积压'
                             , avg(if(统计日期 >= CURDATE() - interval 7 day and
                                      dayofweek(统计日期) not in (1, 7), 未妥投, null))                                 '近5个工作日日均积压'
                             , avg(if(统计日期 = CURDATE() - interval 1 day, 当日应妥投, null))                         '昨日应派'
                             , avg(if(统计日期 = CURDATE() - interval 1 day, 当前已妥投, null))                         '昨日妥投'
                        from DWm.dwd_th_network_spill_detl_rd dtnspdr
                        where 1 = 1
                          and dtnspdr.统计日期 >= CURDATE() - interval 14 day
                        group by 1) tb1
-- ----------------------------------------------------------------------------------------------------------------------------
                 ) AS svo
                 on tb1.store_id = svo.id
                     LEFT JOIN
                 (select `网点id`                                                            'id'
                       , avg(if(`统计日期` = curdate() - interval 1 day, 绝对妥投率, null))  'dlvrRtYstr'
                       , avg(if(`统计日期` >= curdate() - interval 7 day, 绝对妥投率, null)) 'dlvrRt7'
                       , avg(if(`统计日期` >= curdate() - interval 7 day and dayofweek(`统计日期`) not in (1, 7),
                                绝对妥投率, null))                                           'dlvrRt_5wkds'
                  from DWm.dwd_th_network_spill_detl_rd dtnspdr
                  where `统计日期` >= curdate() - interval 7 day
                  group by 1) AS dr
                 on tb1.store_id = dr.id
                     LEFT JOIN
                 (SELECT sdc.strId,
                         count(distinct (sdc.attnDate)) AS                             cntDate,
                         sum(sdc.otSrcOn)               AS                             sumOtSrc,
                         sum(if(attnDate = CURDATE() - interval 1 day, otSrcOn, null)) 'out_src_ystd'
                  FROM (SELECT swa.`started_store_id`                          AS strId,
                               swa.`attendance_date`                           AS attnDate,
                               count(distinct (if(si.`formal` = '0' and si.`job_title` in ('13', '452', '110'),
                                                  swa.`staff_info_id`, null))) AS otSrcOn
                        FROM `backyard_pro`.`staff_work_attendance` AS swa
                                 JOIN
                             `fle_staging`.`staff_info` AS si
                             on swa.`staff_info_id` = si.`id`
                        WHERE swa.`attendance_date` >= date_add(current_date(), -7)
                          and swa.`attendance_date` < current_date()
                        GROUP BY swa.`started_store_id`,
                                 swa.`attendance_date`) AS sdc
                  GROUP BY sdc.strId) AS os
                 on tb1.store_id = os.strId
                     LEFT JOIN
                 (SELECT sdd.strId,
                         avg(sdd.avgDrtn) AS avgDrtn7,
                         avg(sdd.avgEffc) AS avgEffc7
                  FROM (SELECT dcs.`store_id`             AS strId,
                               dcs.`finished_at`,
                               avg(dcs.`duration`) / 3600 AS avgDrtn,
                               avg(dcs.`day_count`)       AS avgEffc
                        FROM bi_pro.`delivery_count_staff` AS dcs
                                 JOIN
                             `fle_staging`.`staff_info` AS si
                             on dcs.`staff_info_id` = si.`id`
                                 and si.`formal` = '1'
                        WHERE dcs.`finished_at` >= date_add(current_date(), -7)
                          and dcs.`finished_at` < current_date()
                          and dcs.`duration` >= 0 * 3600
                          and dcs.`duration` < 12 * 3600
                        GROUP BY dcs.`store_id`,
                                 dcs.`finished_at`) AS sdd
                  GROUP BY sdd.strId) AS drt
                 on tb1.store_id = drt.strId
                     LEFT JOIN
                 (SELECT sds.strId,
                         avg(sds.avgDstn) AS avgDstn7
                  FROM (SELECT si.`store_id`                         AS strId,
                               ccd.`coordinate_date`,
                               avg(ccd.`coordinate_distance`) / 1000 AS avgDstn
                        FROM `rev_pro`.`courier_coordinate_distance` AS ccd
                                 JOIN
                             dwm.`dwd_hr_staff_info_detail` AS si
                             on ccd.`staff_id` = si.`staff_info_id`
                                 and ccd.`coordinate_date` = si.`date_id`
                        WHERE ccd.`coordinate_date` >= date_add(current_date(), -7)
                          and ccd.`coordinate_date` < current_date()
                          and ccd.`coordinate_distance` >= 5000
                          and ccd.`coordinate_distance` <= 500000
                          and ccd.`upload_state` = '0'
                        GROUP BY si.`store_id`,
                                 ccd.`coordinate_date`) AS sds
                  GROUP BY sds.strId) AS dst
                 on tb1.store_id = dst.strId
                     left join fle_staging.sys_store ss1 on tb1.store_id = ss1.id

                     left join
                 fle_staging.sys_province sp
                 on sp.code = ss1.province_code
                     left join
                 fle_staging.sys_city sc
                 on sc.code = ss1.city_code
                     left join
                 fle_staging.sys_district sd
                 on sd.code = ss1.district_code

                     left join fle_staging.sys_store_bdc_bsp ssbb
                               on ssbb.bdc_id = ss1.id

                     left join
                 (select rz.网点id,
                         COUNT(DISTINCT (if(rz.`job_title` in (13, 110, 452) and months = 0, rz.`staff_info_id`,
                                            null)))                                                '本月入职快递员数',
                         COUNT(DISTINCT (if(rz.`job_title` in (13, 110, 452) and months = 1, rz.`staff_info_id`,
                                            null)))                                                '上月入职快递员数',
                         COUNT(DISTINCT (if(rz.`job_title` in (13, 110, 452) and months = 2, rz.`staff_info_id`,
                                            null)))                                                '前月入职快递员数',
                         COUNT(DISTINCT
                               (if(rz.`job_title` in (13), rz.`staff_info_id`, null)))             '入职Bike Courier',
                         COUNT(DISTINCT
                               (if(rz.`job_title` in (110), rz.`staff_info_id`, null)))            '入职Van Courier',
                         COUNT(DISTINCT
                               (if(rz.`job_title` in (452), rz.`staff_info_id`, null)))            '入职Boat Courier',
                         COUNT(DISTINCT
                               (if(rz.`job_title` = 37 and months = 0, rz.`staff_info_id`, null))) '本月入职DCO数',
                         COUNT(DISTINCT
                               (if(rz.`job_title` = 37 and months = 1, rz.`staff_info_id`, null))) '上月入职DCO数',
                         COUNT(DISTINCT
                               (if(rz.`job_title` = 37 and months = 2, rz.`staff_info_id`, null))) '前月入职DCO数'

                  from (SELECT mr.`name`                       大区,
                               mp.`name`                       片区,
                               12 * year(CURDATE()) + month(CURDATE()) - year(hr.hire_date) * 12 -
                               month(hr.hire_date)             'months',
                               hr.`sys_store_id`               网点id,
                               ss.`name`                       网点,
                               od.`一级部门`,
                               od.`name`                       直属部门,
                               case ss.category
                                   when 1 then 'SP'
                                   when 2 then 'DC'
                                   when 4 then 'SHOP'
                                   when 5 then 'SHOP'
                                   when 6 then 'FH'
                                   when 7 then 'SHOP'
                                   when 8 then 'Hub'
                                   when 9 then 'Onsite'
                                   when 10 then 'BDC'
                                   when 11 then 'fulfillment'
                                   when 12 then 'B-HUB' end as 网点类型,
                               hr.`job_title`,
                               jt.`job_name`                   职位,
                               hr.`hire_date`                  入职日期,
                               hr.`staff_info_id`
                        FROM `bi_pro`.`hr_staff_info` hr
                                 LEFT JOIN `fle_staging`.`sys_store` ss on ss.`id` = hr.`sys_store_id`
                                 LEFT JOIN `bi_pro`.`hr_job_title` jt on jt.`id` = hr.`job_title`
                                 LEFT JOIN `fle_staging`.`sys_manage_piece` mp on mp.`id` = ss.`manage_piece`
                                 LEFT JOIN `fle_staging`.`sys_manage_region` mr on mr.id = ss.`manage_region`
                                 left join dwm.`dwd_hr_organizational_structure_detail` od
                                           on cast(hr.sys_department_id AS CHAR) = cast(od.id AS CHAR)
                             --  LEFT JOIN  backyard_pro.hr_staff_items  hri on hri.staff_info_id =hr.staff_info_id  and hri.item ='WORKING_COUNTRY'
                        where hr.`is_sub_staff` = 0
                          -- and hri.value =3
                          and hr.`sys_store_id` != -1
                          and od.`一级部门` in ('Network Management', 'Network Bulky')
                          and hr.`formal` in (1)
                          and 12 * year(CURDATE()) + month(CURDATE()) - year(hr.hire_date) * 12 -
                              month(hr.hire_date) <=
                              2) rz
                  group by 1) tb4 on tb4.网点id = tb1.store_id
                     left join
                 (select 网点id,
                         网点,
                         网点类型,
-- COUNT(DISTINCT(lz.`staff_info_id`)) 网点离职总人数,
                         COUNT(DISTINCT (if(lz.`job_title` in (13, 110, 452) and months = 0, lz.`staff_info_id`,
                                            null)))                                                本月离职快递员数,
                         COUNT(DISTINCT
                               (if(lz.`job_title` = 37 and months = 0, lz.`staff_info_id`, null))) 本月离职DCO数,

                         COUNT(DISTINCT (if(lz.`job_title` in (13, 110, 452) and months = 1, lz.`staff_info_id`,
                                            null)))                                                上月离职快递员数,
                         COUNT(DISTINCT
                               (if(lz.`job_title` = 37 and months = 1, lz.`staff_info_id`, null))) 上月离职DCO数,

                         COUNT(DISTINCT (if(lz.`job_title` in (13, 110, 452) and months = 2, lz.`staff_info_id`,
                                            null)))                                                前月离职快递员数,
                         COUNT(DISTINCT
                               (if(lz.`job_title` = 37 and months = 2, lz.`staff_info_id`, null))) 前月离职DCO数

                  from ( #离职明细
                           SELECT mr.`name`                     大区,
                                  mp.`name`                     片区,
                                  hr.`sys_store_id`             网点id,
                                  ss.`name`                     网点,
                                  case ss.category
                                      when 1 then 'SP'
                                      when 2 then 'DC'
                                      when 4 then 'SHOP'
                                      when 5 then 'SHOP'
                                      when 6 then 'FH'
                                      when 7 then 'SHOP'
                                      when 8 then 'Hub'
                                      when 9 then 'Onsite'
                                      when 10 then 'BDC'
                                      when 11 then 'fulfillment'
                                      when 12 then 'B-HUB'
                                      when 13 then 'BDC' end as 网点类型,
                                  od.`一级部门`,
                                  od.`name`                     直属部门,
                                  12 * year(CURDATE()) + month(CURDATE()) - 12 * year(hr.`leave_date`) -
                                  month(hr.`leave_date`)        'months',
                                  hr.`job_title`,
                                  jt.`job_name`                 职位,
                                  hr.`leave_date`               离职日期,
                                  hr.`staff_info_id`
                           FROM `bi_pro`.`hr_staff_info` hr
                                    LEFT JOIN `fle_staging`.`sys_store` ss on ss.`id` = hr.`sys_store_id`
                                    LEFT JOIN `bi_pro`.`hr_job_title` jt on jt.`id` = hr.`job_title`
                                    LEFT JOIN `fle_staging`.`sys_manage_piece` mp on mp.`id` = ss.`manage_piece`
                                    LEFT JOIN `fle_staging`.`sys_manage_region` mr on mr.id = ss.`manage_region`
                                    left join dwm.`dwd_hr_organizational_structure_detail` od
                                              on cast(hr.sys_department_id AS CHAR) = cast(od.id AS CHAR)
                                    LEFT JOIN backyard_pro.hr_staff_items hri
                                              on hri.staff_info_id = hr.staff_info_id and hri.item = 'WORKING_COUNTRY'
                           where hr.`is_sub_staff` = 0
                             -- and hri.value=3
                             and hr.`sys_store_id` != -1
                             and hr.`formal` in (1, 4)
                             and hr.`state` = 2
                             and ss.category in (1, 10)
                             and 12 * year(CURDATE()) + month(CURDATE()) - 12 * year(hr.`leave_date`) -
                                 month(hr.`leave_date`) <= 2
                             and od.`一级部门` in ('Network Management', 'Network Bulky')) lz
                  group by 1, 2, 3
                  ORDER BY 1) tb5 on tb5.网点id = tb1.store_id
                     left join
                 (select tb_arr.*
                       , 近7日目的地揽收
                  from (select store_id
                             , avg(`arrive_cnt`) '近7日日均到件'
                        from tmpale.dwd_th_store_basic basic
                        where 1 = 1
                          and stat_date < CURDATE()
                          and stat_date >= CURDATE() - interval 7 day
                        group by 1) tb_arr
                           left join
                       (select pi2.dst_store_id
                             , count(distinct pi2.pno) / 7 '近7日目的地揽收'
                        from fle_staging.parcel_info pi2
                        where 1 = 1
                          and pi2.created_at > date_sub(CURDATE() - interval 7 day, interval 7 hour)
                          and pi2.created_at < date_sub(CURDATE(), interval 7 hour)
                        group by 1) tbdst on tbdst.dst_store_id = tb_arr.store_id) arr_pk
                 on arr_pk.store_id = tb1.store_id
                     left join
                 (SELECT
                      #D_昨日滞留件未交接>=100且在当日应妥投不为零的情况下的D_昨日滞留件未交接/当日应妥投>=0.05
                      if(snd.C_ovrBrdnPrcl + snd.D_ystrTskNoHndOvrTdyPrcl + snd.E_tdyTskYstrArrvNoHndOvrTdyPrcl +
                         snd.F_tdyTskTdyArrvNoHndOvrTdyPrcl >= 200
                             and if(ssd.shldDlvrTdy = 0, 0, (snd.C_ovrBrdnPrcl + snd.D_ystrTskNoHndOvrTdyPrcl +
                                                             snd.E_tdyTskYstrArrvNoHndOvrTdyPrcl +
                                                             snd.F_tdyTskTdyArrvNoHndOvrTdyPrcl) /
                                                            ssd.shldDlvrTdy) >=
                                 0.1
                             and snd.D_ystrTskNoHndOvrTdyPrcl >= 100
                             and
                         if(ssd.shldDlvrTdy = 0, 0, snd.D_ystrTskNoHndOvrTdyPrcl / ssd.shldDlvrTdy) >= 0.05,
                         1, null)                   AS 双重预警,
                      nsi.`strId`                   AS 网点ID,
                      ssd.shldDlvrTdy               AS 今日应派,
                      ssd.dlvrTdy                   AS 今日妥投,
                      ssd.shldDlvrTdy - ssd.dlvrTdy AS 今日积压
                  FROM (SELECT dc.`store_id`                                                          strid,
                               ss.`name`                                                              strNm,
                               if(ssbb.bdc_id is not null, 'BSP', if(ss.`category` = 1, 'SP', 'BDC')) ctgr,
                               smp.`name`                                                             pcNm,
                               smr.`name`                                                             rgnNm,
                               ss.date(`opening_at`)                                                  opnDate
                        FROM `bi_pro`.`dc_should_delivery_today` dc
                                 left join
                             `fle_staging`.`sys_store` ss
                             on ss.`id` = dc.`store_id`
                                 LEFT JOIN
                             `fle_staging`.`sys_manage_piece` AS smp
                             on ss.`manage_piece` = smp.`id`
                                 LEFT JOIN
                             `fle_staging`.`sys_manage_region` AS smr
                             on ss.`manage_region` = smr.`id`
                                 LEFT JOIN
                             `fle_staging`.`sys_district` AS sd
                             on ss.`district_code` = sd.`code`
                                 left join fle_staging.sys_store_bdc_bsp ssbb
                                           on ssbb.bdc_id = dc.store_id
                        where ss.`category` in (1, 10)
                          and dc.`stat_date` = CURRENT_DATE
                        GROUP BY dc.`store_id`) AS nsi
                           LEFT JOIN
                       (SELECT sdt.`dst_store_id`                                                     AS strId,
                               count(distinct (sdt.pno))                                              AS shldDlvrTdy,
                               count(distinct (if(pi.`state` = '5', sdt.pno, null)))                     dlvrTdy,
                               count(distinct (if(pi.`state` in ('7', '8'), sdt.pno, null)))             Outreason,
                               count(distinct
                                     (if(sdy1.pno is null and pi.`state` = '5', sdt.pno, null)))      AS incrTdyDlvr,
                               count(distinct
                                     (if(sdy1.pno is null and pi.`state` <> '5', sdt.pno, null)))     AS incrTdyUnDlvr,
                               count(distinct
                                     (if(sdy1.pno is not null and pi.`state` = '5', sdt.pno, null)))  AS ystrTskDlvr,
                               count(distinct
                                     (if(sdy1.pno is not null and pi.`state` <> '5', sdt.pno, null))) AS ystrTskUnDlvr
                        FROM (SELECT *
                              FROM dwm.dwd_th_non_end_pno_detl_rd
                              WHERE stat_date = current_date()) AS sdt #今日应派记录表
                                 LEFT JOIN
                             (SELECT *
                              FROM dwm.dwd_th_non_end_pno_detl_d
                              WHERE stat_date = date_add(current_date(), -1)) AS sdy1 #昨日应派记录表
                             on sdt.`pno` = sdy1.`pno`
                                 and sdy1.`stat_date` = date_add(sdt.`stat_date`, -1)
                                 LEFT JOIN
                             `fle_staging`.`parcel_info` AS pi
                             on sdt.pno = pi.`pno`
                        GROUP BY strId) AS ssd #各网点应妥投任务统计
                       on nsi.`strId` = ssd.strId
                           LEFT JOIN
                       (SELECT spc.strId,
                               sum(spc.cntPrcl)                           AS unDlvrPrcl,#未妥投
                               sum(if(spc.typ like 'B%', spc.cntPrcl, 0)) AS B_hltPrcl,#B_外部原因未妥投
                               sum(if(spc.typ like 'C%', spc.cntPrcl, 0)) AS C_ovrBrdnPrcl,#标记运力不足
                               sum(if(spc.typ like 'D%', spc.cntPrcl, 0)) AS D_ystrTskNoHndOvrTdyPrcl,#D_昨日滞留件未交接
                               sum(if(spc.typ like 'E%', spc.cntPrcl, 0)) AS E_tdyTskYstrArrvNoHndOvrTdyPrcl,#E_当日任务昨日到港未交接
                               sum(if(spc.typ like 'F%', spc.cntPrcl, 0)) AS F_tdyTskTdyArrvNoHndOvrTdyPrcl #F_当日任务昨日到港未交接
                        FROM (SELECT sdt.`store_id`              AS strId,
                                     case
                                         when di.pno is not null or sdt.state in ('6', '7', '8', '9') or
                                              date(sdt.detain_client_modify_date) > sdt.stat_date or
                                              tm.mrkrId <> '71'
                                             then 'B_hlt' #外部因素
                                         when tm.mrkrId = '71' then 'C_ovrBrdn'#运力不足
                                         when pr.pno is null and sdy1.pno is not null then 'D_ystrTskNoHndOvrTdy'#昨日滞留今日未妥投
                                         when pr.pno is null and
                                              date(sdt.vehicle_time) = date_add(sdt.stat_date, -1)
                                             then 'E_tdyTskYstrArrvNoHndOvrTdy' #当日任务昨日到港未妥投
                                         when pr.pno is null then 'F_tdyTskTdyArrvNoHndOvrTdy'#当日任务当日到达未妥投
                                         else 'ongoing' end      AS typ,    #未妥投原因分类
                                     count(distinct (sdt.`pno`)) AS cntPrcl #单量
                              FROM (SELECT sd.`stat_date`,
                                           sd.`store_id`,
                                           sd.`pno`,
                                           sd.`state`,
                                           sd.`vehicle_time`,
                                           sd.`detain_client_modify_date` #统计时间，网点ID，运单号，运单归类（处理中、疑难等），车辆入港时间，客户改约时间
                                    FROM `bi_pro`.`dc_should_delivery_today` AS sd
                                             join (select pno
                                                   from dwm.dwd_th_non_end_pno_detl_rd
                                                   where stat_date = curdate()) tbxx on tbxx.pno = sd.pno
                                             JOIN `fle_staging`.`parcel_info` AS pi
                                                  on sd.`pno` = pi.`pno` and sd.stat_date = current_date() and
                                                     pi.`state` <> '5'#取当前时间且未签收的运单
                                                      and pi.returned = 0) AS sdt
                                       LEFT JOIN
                                   `fle_staging`.`diff_info` AS di
                                   on sdt.`pno` = di.`pno`
                                       and di.`created_at` >= current_date() #今日凌晨以后生成的疑难订单
                                       LEFT JOIN
                                   (SELECT pr.`pno`,
                                           pr.`created_at`
                                    FROM `rot_pro`.`parcel_route` AS pr #运单当前状态详细信息表
                                    WHERE date(convert_tz(pr.`created_at`, '+00:00', '+07:00')) =
                                          current_date()                                      #取泰国当前时间
                                      and pr.`route_action` = 'DELIVERY_TICKET_CREATION_SCAN' #派送运单扫描
                                    GROUP BY pr.`pno`,
                                             pr.`created_at`) AS pr
                                   on sdt.`pno` = pr.`pno`
                                       LEFT JOIN
                                   (SELECT ptd.pno,
                                           ptd.marker_id AS mrkrId
                                    FROM (SELECT td.`pno`,
                                                 tdm.`marker_id`,
                                                 row_number() over (partition by td.`pno` order by tdm.`created_at` desc) AS rnTdm
                                          FROM `fle_staging`.`ticket_delivery` AS td
                                                   JOIN
                                               `fle_staging`.`ticket_delivery_marker` AS tdm
                                               on td.`id` = tdm.`delivery_id`
                                                   and
                                                  date(convert_tz(td.`created_at`, '+00:00', '+07:00')) =
                                                  current_date()
                                          GROUP BY td.`pno`,
                                                   tdm.`created_at`) AS ptd
                                    WHERE ptd.rnTdm = '1') AS tm
                                   on sdt.pno = tm.pno
                                       LEFT JOIN
                                   (SELECT *
                                    FROM `bi_pro`.`dc_should_delivery_today`
                                    WHERE stat_date >= date_add(current_date(), -1)) AS sdy1
                                   on sdt.`pno` = sdy1.`pno`
                                       and sdy1.`stat_date` = date_add(sdt.`stat_date`, -1)
                              GROUP BY sdt.`store_id`,
                                       typ) AS spc
                        GROUP BY spc.strId) AS snd #各网点的运单未妥投分类情况统计
                       on nsi.strId = snd.strId) tbxx on tbxx.`网点ID` = tb1.store_id
                     left join
                 (select adv.sys_store_id
                       , count(distinct
                               if(COALESCE(adv.attendance_started_at, adv.attendance_end_at) is not null and
                                  adv.stat_date < CURDATE(), adv.staff_info_id || adv.stat_date, null))
                         / count(distinct
                                 if(adv.stat_date < CURDATE(), adv.staff_info_id || adv.stat_date,
                                    null))                                                        'att_rates_7'
                       , count(distinct
                               if(COALESCE(adv.attendance_started_at, adv.attendance_end_at) is not null and
                                  adv.stat_date < CURDATE() and dayofweek(adv.stat_date) not in (1,7), adv.staff_info_id || adv.stat_date, null))
                         / count(distinct
                                 if(adv.stat_date < CURDATE() and dayofweek(adv.stat_date) not in (1,7), adv.staff_info_id || adv.stat_date,
                                    null))                                                        'att_rates_wkds5'
                       , count(distinct if(adv.stat_date = CURDATE() - interval 1 day and
                                           COALESCE(adv.attendance_started_at, adv.attendance_end_at) is not null,
                                           adv.staff_info_id, null))
                         / count(distinct
                                 if(adv.stat_date = CURDATE() - interval 1 day, adv.staff_info_id,
                                    null))                                                        'att_rates_1'
                       , count(distinct if(adv.stat_date = CURDATE() and
                                           COALESCE(adv.attendance_started_at, adv.attendance_end_at) is not null,
                                           adv.staff_info_id, null))
                         / count(distinct if(adv.stat_date = CURDATE(), adv.staff_info_id, null)) 'att_rates_td'
                  from bi_pro.attendance_data_v2 adv
                           left join fle_staging.staff_info si on si.id = adv.staff_info_id
                  where 1 = 1
                    and adv.job_title in (13, 110, 1199)

                    and adv.stat_date >= CURDATE() - interval 7 day
                    and si.formal = 1
                    and si.is_sub_staff = 0
                  group by 1) att_rates on att_rates.sys_store_id = tb1.store_id
                     left join tmpale.tmp_th_hc_approval_data_stock stock_data
                               on stock_data.id = tb1.store_id
                     left join tmpale.tmp_th_manage_piece_target_crr_23825 data_825 on data_825.片区=tb1.manage_piece_name
           ) tbq1
      where 1 = 1
        and (coalesce(`日均到件_220w`, 0) + COALESCE(`日均揽件_220w`, 0) > 0 or
             COALESCE(`在职快递员`, 0) > 0)) tbxx1
order by 1, 2
;
select
    *
from  tmpale.tmp_th_tgt_pop


;


#泰国SPBDC的表，需要加一个近7天每一天的外协人数，支援人数，妥投率，积压量，正式员工平均人效，到件量，揽收量
#网点	网点id	建议优先级	片区	类型	开业日期	分类	部门ID	大区	派次	区域	province_code	是否GBKK	province	city_code	city	district_code	district

select
*
from
(
select
ss.id
,ss.name
,mr.name 'mr_name'
,mp.name 'mp_name'
,if(ss.province_code in ('TH01','TH02','TH03','TH04'),'GBKK','NON-GBKK') 'IS_GBKK'
from
fle_staging.sys_store ss
LEFT JOIN fle_staging.`sys_manage_region` mr on ss.`manage_region`= mr.`id`
LEFT JOIN `fle_staging`.`sys_manage_piece` mp on ss.`manage_piece`= mp.`id`
where 1=1
and ss.category in (1,10)
AND SS.state =1
) tbq1
left join
(
SELECT
swa.`started_store_id` AS 'store_id_1'
,count(distinct(if(si.`formal`='0' and si.job_title in (13,110,452) and swa.attendance_date =CURDATE()-interval 1 day ,swa.`staff_info_id`,null))) AS 'out_src_1'
,count(distinct(if(si.`formal`='0' and si.job_title in (13,110,452) and swa.attendance_date =CURDATE()-interval 2 day ,swa.`staff_info_id`,null))) AS 'out_src_2'
,count(distinct(if(si.`formal`='0' and si.job_title in (13,110,452) and swa.attendance_date =CURDATE()-interval 3 day ,swa.`staff_info_id`,null))) AS 'out_src_3'
,count(distinct(if(si.`formal`='0' and si.job_title in (13,110,452) and swa.attendance_date =CURDATE()-interval 4 day ,swa.`staff_info_id`,null))) AS 'out_src_4'
,count(distinct(if(si.`formal`='0' and si.job_title in (13,110,452) and swa.attendance_date =CURDATE()-interval 5 day ,swa.`staff_info_id`,null))) AS 'out_src_5'
,count(distinct(if(si.`formal`='0' and si.job_title in (13,110,452) and swa.attendance_date =CURDATE()-interval 6 day ,swa.`staff_info_id`,null))) AS 'out_src_6'
,count(distinct(if(si.`formal`='0' and si.job_title in (13,110,452) and swa.attendance_date =CURDATE()-interval 7 day ,swa.`staff_info_id`,null))) AS 'out_src_7'
FROM backyard_pro.staff_work_attendance AS swa
JOIN `fle_staging`.`staff_info` AS si on swa.`staff_info_id`=si.`id`
WHERE
swa.`attendance_date`>=date_add(current_date(),-7)
and swa.`attendance_date`<current_date()
GROUP BY
swa.`started_store_id`
) tbq2 on tbq1.id=tbq2.store_id_1
left join
(
select
*
from
(
select
网点id 'store_id_2'
,统计日期
,打卡的支援快递员 'spt_crr_1'
,lag(打卡的支援快递员,1,null) over(partition by 网点id order by 统计日期) 'spt_crr_2'
,lag(打卡的支援快递员,2,null) over(partition by 网点id order by 统计日期) 'spt_crr_3'
,lag(打卡的支援快递员,3,null) over(partition by 网点id order by 统计日期) 'spt_crr_4'
,lag(打卡的支援快递员,4,null) over(partition by 网点id order by 统计日期) 'spt_crr_5'
,lag(打卡的支援快递员,5,null) over(partition by 网点id order by 统计日期) 'spt_crr_6'
,lag(打卡的支援快递员,6,null) over(partition by 网点id order by 统计日期) 'spt_crr_7'
,绝对妥投率 'dlv_rate_1'
,lag(绝对妥投率,1,null) over(partition by 网点id order by 统计日期) 'dlv_rate_2'
,lag(绝对妥投率,2,null) over(partition by 网点id order by 统计日期) 'dlv_rate_3'
,lag(绝对妥投率,3,null) over(partition by 网点id order by 统计日期) 'dlv_rate_4'
,lag(绝对妥投率,4,null) over(partition by 网点id order by 统计日期) 'dlv_rate_5'
,lag(绝对妥投率,5,null) over(partition by 网点id order by 统计日期) 'dlv_rate_6'
,lag(绝对妥投率,6,null) over(partition by 网点id order by 统计日期) 'dlv_rate_7'
,未妥投 'detained_1'
,lag(未妥投,1,null) over(partition by 网点id order by 统计日期) 'detained_2'
,lag(未妥投,2,null) over(partition by 网点id order by 统计日期) 'detained_3'
,lag(未妥投,3,null) over(partition by 网点id order by 统计日期) 'detained_4'
,lag(未妥投,4,null) over(partition by 网点id order by 统计日期) 'detained_5'
,lag(未妥投,5,null) over(partition by 网点id order by 统计日期) 'detained_6'
,lag(未妥投,6,null) over(partition by 网点id order by 统计日期) 'detained_7'
from
DWm.dwd_th_network_spill_detl_rd dtnspdr
order by 1,2
) tb1
where 统计日期=CURDATE() - interval 1 day
) tbq3 on tbq1.id=tbq3.store_id_2
left join
(
select
pi2.ticket_delivery_store_id 'store_id_3'
,count(distinct if(date(pi2.finished_at+interval 8 hour)=CURDATE()-interval 1 day,pi2.pno,null))/count(distinct if(date(pi2.finished_at+interval 8 hour)=CURDATE()-interval 1 day,pi2.ticket_delivery_staff_info_id ,null)) 'eff_fml_1'
,count(distinct if(date(pi2.finished_at+interval 8 hour)=CURDATE()-interval 2 day,pi2.pno,null))/count(distinct if(date(pi2.finished_at+interval 8 hour)=CURDATE()-interval 1 day,pi2.ticket_delivery_staff_info_id ,null)) 'eff_fml_2'
,count(distinct if(date(pi2.finished_at+interval 8 hour)=CURDATE()-interval 3 day,pi2.pno,null))/count(distinct if(date(pi2.finished_at+interval 8 hour)=CURDATE()-interval 1 day,pi2.ticket_delivery_staff_info_id ,null)) 'eff_fml_3'
,count(distinct if(date(pi2.finished_at+interval 8 hour)=CURDATE()-interval 4 day,pi2.pno,null))/count(distinct if(date(pi2.finished_at+interval 8 hour)=CURDATE()-interval 1 day,pi2.ticket_delivery_staff_info_id ,null)) 'eff_fml_4'
,count(distinct if(date(pi2.finished_at+interval 8 hour)=CURDATE()-interval 5 day,pi2.pno,null))/count(distinct if(date(pi2.finished_at+interval 8 hour)=CURDATE()-interval 1 day,pi2.ticket_delivery_staff_info_id ,null)) 'eff_fml_5'
,count(distinct if(date(pi2.finished_at+interval 8 hour)=CURDATE()-interval 6 day,pi2.pno,null))/count(distinct if(date(pi2.finished_at+interval 8 hour)=CURDATE()-interval 1 day,pi2.ticket_delivery_staff_info_id ,null)) 'eff_fml_6'
,count(distinct if(date(pi2.finished_at+interval 8 hour)=CURDATE()-interval 7 day,pi2.pno,null))/count(distinct if(date(pi2.finished_at+interval 8 hour)=CURDATE()-interval 1 day,pi2.ticket_delivery_staff_info_id ,null)) 'eff_fml_7'
from fle_staging.parcel_info pi2
left join fle_staging.staff_info si on pi2.ticket_delivery_staff_info_id =si.id
where 1=1
and si.formal =1
and si.job_title in (13,110,452)
and pi2.finished_at >CURDATE()-interval 10 day
group by 1
) tbq4 on tbq1.id=tbq4.store_id_3
left join
(
select
*
from
(
select
store_id 'store_id_4'
,stat_date
,arrive_cnt 'arr_1'
,lag(arrive_cnt,1,null) over(partition by store_id order by stat_date) 'arr_2'
,lag(arrive_cnt,2,null) over(partition by store_id order by stat_date) 'arr_3'
,lag(arrive_cnt,3,null) over(partition by store_id order by stat_date) 'arr_4'
,lag(arrive_cnt,4,null) over(partition by store_id order by stat_date) 'arr_5'
,lag(arrive_cnt,5,null) over(partition by store_id order by stat_date) 'arr_6'
,lag(arrive_cnt,6,null) over(partition by store_id order by stat_date) 'arr_7'

,pickup_cnt 'pick_1'
,lag(pickup_cnt,1,null) over(partition by store_id order by stat_date) 'pick_2'
,lag(pickup_cnt,2,null) over(partition by store_id order by stat_date) 'pick_3'
,lag(pickup_cnt,3,null) over(partition by store_id order by stat_date) 'pick_4'
,lag(pickup_cnt,4,null) over(partition by store_id order by stat_date) 'pick_5'
,lag(pickup_cnt,5,null) over(partition by store_id order by stat_date) 'pick_6'
,lag(pickup_cnt,6,null) over(partition by store_id order by stat_date) 'pick_7'

from tmpale.dwd_th_store_basic
) tb1
where tb1.stat_date =CURDATE()-interval 1 day
) tbq5 on tbq1.id=tbq5.store_id_4
left join
(
select
pi2.dst_store_id 'store_id_5'
,count(distinct if(date(pi2.created_at+interval 7 hour)=CURDATE()-interval 1 day,pi2.pno)) 'dst_pk_1'
,count(distinct if(date(pi2.created_at+interval 7 hour)=CURDATE()-interval 2 day,pi2.pno)) 'dst_pk_2'
,count(distinct if(date(pi2.created_at+interval 7 hour)=CURDATE()-interval 3 day,pi2.pno)) 'dst_pk_3'
,count(distinct if(date(pi2.created_at+interval 7 hour)=CURDATE()-interval 4 day,pi2.pno)) 'dst_pk_4'
,count(distinct if(date(pi2.created_at+interval 7 hour)=CURDATE()-interval 5 day,pi2.pno)) 'dst_pk_5'
,count(distinct if(date(pi2.created_at+interval 7 hour)=CURDATE()-interval 6 day,pi2.pno)) 'dst_pk_6'
,count(distinct if(date(pi2.created_at+interval 7 hour)=CURDATE()-interval 7 day,pi2.pno)) 'dst_pk_7'
from fle_staging.parcel_info pi2
where 1=1
and pi2.returned=0
and pi2.created_at>=date_sub(CURDATE()-interval 7 day,interval 7 hour)
and pi2.created_at< date_sub(CURDATE()-interval 0 day,interval 7 hour)
group by 1
) tbq6 on tbq1.id=tbq6.store_id_5
where name not like 'Virtual%'
and COALESCE(store_id_1,store_id_2,store_id_3,store_id_4,store_id_5) is not null











