  /*=====================================================================+
    表名称：  1199d_th_explosion_warning
    功能描述： 泰国网点爆仓预警

    需求来源：
    编写人员: lishuaijie
    设计日期：2023/1/13
      修改日期: 2023/4/19
      修改人员: lizhen
      修改原因: 将几个sheet合并
  -----------------------------------------------------------------------
  ---存在问题：
  -----------------------------------------------------------------------
  +=====================================================================*/

select
    tbq1.*
     ,tbq2.estmShldDlvrTmrr '预计明日应派'
     ,greatest(tbq2.estmShldDlvrTmrr-tbq3.crrtCpct,0) '预计明日溢出'
     ,COALESCE(greatest(tbq2.estmShldDlvrTmrr-tbq3.crrtCpct,0)/tbq2.estmShldDlvrTmrr ) '明日溢出比例'
     ,if(tbq1.`溢出件量`>=200 and tbq1.`溢出比例`>=0 and COALESCE(greatest(tbq2.estmShldDlvrTmrr-tbq3.crrtCpct,0)/tbq2.estmShldDlvrTmrr )>=0.1,'Alert',null) '明日爆仓预警'
     ,if(tbq1.`网点类型`='BDC' or tbq1.`大区` in ('Area3','Area6','Area14'),'B','A') 'AB网'
     ,tbq4.`今日揽收`
     ,tbq5.`上周同期揽收`
from
    (
        SELECT
            convert_tz(current_timestamp(),'+08:00','+07:00')AS 统计时间,
            if(snd.C_ovrBrdnPrcl+snd.D_ystrTskNoHndOvrTdyPrcl+snd.E_tdyTskYstrArrvNoHndOvrTdyPrcl+snd.F_tdyTskTdyArrvNoHndOvrTdyPrcl>=200
                   and if(ssd.shldDlvrTdy=0,0,(snd.C_ovrBrdnPrcl+snd.D_ystrTskNoHndOvrTdyPrcl+snd.E_tdyTskYstrArrvNoHndOvrTdyPrcl+snd.F_tdyTskTdyArrvNoHndOvrTdyPrcl)/ssd.shldDlvrTdy)>=0.1,
               'Alert','') AS 当日件量溢出预警,
            #标记运力不足+D_昨日滞留件未交接+E_当日任务昨日到港未交接+F_当日任务昨日到港未交接>200且在当日应妥投不小于0的情况下的由于（标记运力不足+D_昨日滞留件未交接+E_当日任务昨日到港未交接+F_当日任务昨日到港未交接）/（当日应妥投）>=0.1 的标记为当日件量溢出预警
            if(snd.D_ystrTskNoHndOvrTdyPrcl>=100
                   and if(ssd.shldDlvrTdy=0,0,snd.D_ystrTskNoHndOvrTdyPrcl/ssd.shldDlvrTdy)>=0.05,
               'Alert','') AS 滞留件积压预警,
            #D_昨日滞留件未交接>=100且在当日应妥投不为零的情况下的D_昨日滞留件未交接/当日应妥投>=0.05
            if(snd.C_ovrBrdnPrcl+snd.D_ystrTskNoHndOvrTdyPrcl+snd.E_tdyTskYstrArrvNoHndOvrTdyPrcl+snd.F_tdyTskTdyArrvNoHndOvrTdyPrcl>=200
                   and if(ssd.shldDlvrTdy=0,0,(snd.C_ovrBrdnPrcl+snd.D_ystrTskNoHndOvrTdyPrcl+snd.E_tdyTskYstrArrvNoHndOvrTdyPrcl+snd.F_tdyTskTdyArrvNoHndOvrTdyPrcl)/ssd.shldDlvrTdy)>=0.1
                   and snd.D_ystrTskNoHndOvrTdyPrcl>=100
                   and if(ssd.shldDlvrTdy=0,0,snd.D_ystrTskNoHndOvrTdyPrcl/ssd.shldDlvrTdy)>=0.05,
               'Alert','') AS 双重预警,
            nsi.`strId` AS 网点ID,
            nsi.`strNm` AS 网点名称,
            nsi.`ctgr` AS 网点类型,
            nsi.`pcNm` AS 片区,
            nsi.`rgnNm` AS 大区,
            regexp_replace(nsi.`pcNm`,'[^A-Z]','') AS 区域,
            nsi.`opnDate` AS 开业日期,
            ssd.shldDlvrTdy AS 当日应妥投,
            ssd.dlvrTdy AS 当前已妥投,
            if(ssd.shldDlvrTdy=0,0,ssd.dlvrTdy/ssd.shldDlvrTdy) AS 绝对妥投率,
            ssd.incrTdyDlvr+ssd.incrTdyUnDlvr AS 当日新任务,
            ssd.incrTdyDlvr AS 当日新任务已妥投,
            ssd.incrTdyUnDlvr AS 当日新任务未妥投,
            ssd.ystrTskDlvr+ssd.ystrTskUnDlvr AS 昨日滞留任务,
            ssd.ystrTskDlvr AS 滞留任务已妥投,
            ssd.ystrTskUnDlvr AS 滞留任务未妥投,
            ssd.shldDlvrTdy-ssd.dlvrTdy AS 未妥投,
            snd.B_hltPrcl AS B_外部原因未妥投,
            if(ssd.shldDlvrTdy=0,0,(ssd.shldDlvrTdy-snd.B_hltPrcl)/ssd.shldDlvrTdy) AS 理想妥投率,
            if(ssd.shldDlvrTdy-snd.B_hltPrcl=0,0,ssd.dlvrTdy/(ssd.shldDlvrTdy-snd.B_hltPrcl)) AS 理想妥投率进度,
            snd.C_ovrBrdnPrcl+snd.D_ystrTskNoHndOvrTdyPrcl+snd.E_tdyTskYstrArrvNoHndOvrTdyPrcl+snd.F_tdyTskTdyArrvNoHndOvrTdyPrcl AS 溢出件量,
            #标记运力不足+D_昨日滞留件未交接+E_当日任务昨日到港未交接+F_当日任务今日到港未交接
            if(ssd.shldDlvrTdy=0,0,(snd.C_ovrBrdnPrcl+snd.D_ystrTskNoHndOvrTdyPrcl+snd.E_tdyTskYstrArrvNoHndOvrTdyPrcl+snd.F_tdyTskTdyArrvNoHndOvrTdyPrcl)/ssd.shldDlvrTdy) AS 溢出比例,
            snd.C_ovrBrdnPrcl AS 标记运力不足,
            snd.D_ystrTskNoHndOvrTdyPrcl AS D_昨日滞留件未交接,
            if(ssd.shldDlvrTdy=0,0,snd.D_ystrTskNoHndOvrTdyPrcl/ssd.shldDlvrTdy) AS 未交接滞留件占比
        FROM
            (
                SELECT dc.`store_id` strid,
                       ss.`name` strNm,
                       if(ssbb.bdc_id is not null ,'BSP',if(ss.`category`=1,'SP','BDC')) ctgr,
                       smp.`name`  pcNm,
                       smr.`name`  rgnNm,
                       ss.date(`opening_at` ) opnDate
                FROM
                    `bi_pro`.`dc_should_delivery_today` dc
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
                    on ss.`district_code` =sd.`code`
                        left join fle_staging.sys_store_bdc_bsp ssbb
                                  on ssbb.bdc_id=dc.store_id and ssbb.deleted=0
                where ss.`category` in (1,10)
                  and  dc.`stat_date` =CURRENT_DATE
                GROUP BY  dc.`store_id`
            ) AS nsi
                LEFT JOIN
            (
                SELECT
                    sdt.`dst_store_id` AS strId,
                    count(distinct(sdt.pno)) AS shldDlvrTdy,
                    count(distinct(if(pi.`state`='5',sdt.pno,null))) dlvrTdy,
                    count(distinct(if(pi.`state`in('7','8'),sdt.pno,null))) Outreason,
                    count(distinct(if(sdy1.pno is null and pi.`state`='5',sdt.pno,null))) AS incrTdyDlvr,
                    count(distinct(if(sdy1.pno is null and pi.`state`<>'5',sdt.pno,null))) AS incrTdyUnDlvr,
                    count(distinct(if(sdy1.pno is not null and pi.`state`='5',sdt.pno,null))) AS ystrTskDlvr,
                    count(distinct(if(sdy1.pno is not null and pi.`state`<>'5',sdt.pno,null))) AS ystrTskUnDlvr
                FROM
                    (
                        SELECT pno,dst_store_id,stat_date
                        FROM dwm.dwd_th_non_end_pno_detl_rd
                        WHERE stat_date=current_date()
                        and is_should_delivery = 1
                    ) AS sdt #今日应派记录表
                        LEFT JOIN
                    (
                        SELECT pno,dst_store_id,stat_date
                        FROM dwm.dwd_th_non_end_pno_detl_d
                        WHERE stat_date=date_add(current_date(),-1)
                        and is_should_delivery = 1
                    ) AS sdy1 #昨日应派记录表
                    on sdt.`pno` =sdy1.`pno`
                        and sdy1.`stat_date` =date_add(sdt.`stat_date`,-1)
                        LEFT JOIN
                    `fle_staging`.`parcel_info` AS pi
                    on sdt.pno=pi.`pno`
                GROUP BY
                    strId
            ) AS ssd  #各网点应妥投任务统计
            on nsi.`strId` =ssd.strId
                LEFT JOIN
            (
                SELECT
                    spc.strId,
                    sum(spc.cntPrcl) AS unDlvrPrcl,#未妥投
                    sum(if(spc.typ like 'B%',spc.cntPrcl,0)) AS B_hltPrcl,#B_外部原因未妥投
                    sum(if(spc.typ like 'C%',spc.cntPrcl,0)) AS C_ovrBrdnPrcl,#标记运力不足
                    sum(if(spc.typ like 'D%',spc.cntPrcl,0)) AS D_ystrTskNoHndOvrTdyPrcl,#D_昨日滞留件未交接
                    sum(if(spc.typ like 'E%',spc.cntPrcl,0)) AS E_tdyTskYstrArrvNoHndOvrTdyPrcl,#E_当日任务昨日到港未交接
                    sum(if(spc.typ like 'F%',spc.cntPrcl,0)) AS F_tdyTskTdyArrvNoHndOvrTdyPrcl #F_当日任务昨日到港未交接
                FROM
                    (
                        SELECT
                            sdt.`store_id` AS strId,
                            case
                                when di.pno is not null or sdt.state in('6','7','8','9') or date(sdt.detain_client_modify_date) >sdt.stat_date or tm.mrkrId <>'71' then 'B_hlt' #外部因素
                                when tm.mrkrId ='71' then 'C_ovrBrdn'#运力不足
                                when pr.pno is null and sdy1.pno is not null then 'D_ystrTskNoHndOvrTdy'#昨日滞留今日未妥投
                                when pr.pno is null and date(sdt.vehicle_time) =date_add(sdt.stat_date,-1) then 'E_tdyTskYstrArrvNoHndOvrTdy' #当日任务昨日到港未妥投
                                when pr.pno is null then 'F_tdyTskTdyArrvNoHndOvrTdy'#当日任务当日到达未妥投
                                else 'ongoing' end AS typ, #未妥投原因分类
                            count(distinct(sdt.`pno`)) AS cntPrcl  #单量
                        FROM
                            (
                                SELECT sd.`stat_date` ,sd.`store_id` ,sd.`pno` ,sd.`state` ,sd.`vehicle_time` ,sd.`detain_client_modify_date` #统计时间，网点ID，运单号，运单归类（处理中、疑难等），车辆入港时间，客户改约时间
                                FROM `bi_pro`.`dc_should_delivery_today` AS sd
                                         join (select pno from dwm.dwd_th_non_end_pno_detl_rd where stat_date=curdate()) tbxx on tbxx.pno=sd.pno
                                         JOIN `fle_staging`.`parcel_info` AS pi on sd.`pno` =pi.`pno` and sd.stat_date=current_date() and pi.`state` <>'5'#取当前时间且未签收的运单
                                    and pi.returned=0
                            ) AS sdt
                                LEFT JOIN
                            `fle_staging`.`diff_info` AS di
                            on sdt.`pno` =di.`pno`
                                and di.`created_at` >=current_date() #今日凌晨以后生成的疑难订单
                                LEFT JOIN
                            (
                                SELECT
                                    pr.`pno` ,
                                    pr.`created_at`
                                FROM
                                    `rot_pro`.`parcel_route` AS pr #运单当前状态详细信息表
                                WHERE
                                        pr.`created_at`>=date_sub(current_date(),interval 7 hour) #取泰国当前时间
                                  and pr.`route_action` ='DELIVERY_TICKET_CREATION_SCAN' #派送运单扫描
                                GROUP BY
                                    pr.`pno` ,
                                    pr.`created_at`
                            ) AS pr
                            on sdt.`pno` =pr.`pno`
                                LEFT JOIN
                            (
                                SELECT
                                    ptd.pno,
                                    ptd.marker_id AS mrkrId
                                FROM
                                    (
                                        SELECT
                                            td.`pno` ,
                                            tdm.`marker_id` ,
                                            row_number() over(partition by td.`pno` order by tdm.`created_at` desc) AS rnTdm
                                        FROM
                                            `fle_staging`.`ticket_delivery` AS td
                                                JOIN
                                            `fle_staging`.`ticket_delivery_marker` AS tdm
                                            on td.`id` =tdm.`delivery_id`
                                                and td.`created_at`>=date_sub(current_date(),interval 7 hour)
                                        GROUP BY
                                            td.`pno`,
                                            tdm.`created_at`
                                    ) AS ptd
                                WHERE
                                        ptd.rnTdm='1'
                            ) AS tm
                            on sdt.pno=tm.pno
                                LEFT JOIN
                            (
                                SELECT pno,stat_date
                                FROM `bi_pro`.`dc_should_delivery_today`
                                WHERE stat_date>=date_add(current_date(),-1)
                            ) AS sdy1
                            on sdt.`pno` =sdy1.`pno`
                                and sdy1.`stat_date` =date_add(sdt.`stat_date`,-1)
                        GROUP BY
                            sdt.`store_id` ,
                            typ
                    ) AS spc
                GROUP BY
                    spc.strId
            ) AS snd  #各网点的运单未妥投分类情况统计
            on nsi.strId=snd.strId
    ) tbq1
        left join
    (
#次日应派预测
        SELECT
            convert_tz(CURRENT_TIMESTAMP,'+08:00','+07:00') AS sttTime,
            ss.`id` AS strId,
            ss.`name` AS strNm,
            if(time(convert_tz(CURRENT_TIMESTAMP,'+08:00','+07:00'))<'14:00:00',etm.estmShldDlvrTmrr,etm.shldDlvrTmrr+greatest(ceil(ssd.prclShld-coalesce(if((1-shr.avgRvrsTimePrgr)=0,ssd.prclDlvr,ssd.prclDlvr/(1-shr.avgRvrsTimePrgr)),ssd.prclDlvr)),0)-coalesce((etm.estmShldDlvrTdy-ssd.prclShld),0)) AS estmShldDlvrTmrr
            #两点之前  应配送
        FROM
            (
                SELECT
                    sdt.`store_id` AS strId,
                    count(distinct(sdt.`pno`)) AS prclShld,
                    count(distinct(if(pi.`state`='5',sdt.`pno`,null))) AS prclDlvr,
                    if(count(distinct(sdt.`pno`))=0,0,count(distinct(if(pi.`state`='5',sdt.`pno`,null)))/count(distinct(sdt.`pno`))) AS dlvrRt
                FROM
                    `bi_pro`.`dc_should_delivery_today` AS sdt
                        LEFT JOIN
                    `fle_staging`.`parcel_info` AS pi
                    on sdt.`pno`=pi.`pno`
                        and pi.`created_at`>=convert_tz(date_add(current_date(),-7),'+07:00','+00:00')
                        and pi.returned=0
                WHERE
                        sdt.`stat_date`=current_date()
                GROUP BY
                    sdt.`store_id`
            ) AS ssd
                JOIN
            `fle_staging`.`sys_store` AS ss
            on ssd.strId=ss.`id`
                and ss.`category` in('1','10')
                and ss.`state`='1'
                LEFT JOIN
            (
                SELECT
                    dht.strId,
                    min(dht.hourDlvr) AS hourDlvr,#最早的交接时间
                    max(dht.rvrsTimePrgr) AS avgRvrsTimePrgr#最早交接时间下的当天最大派件进度
                FROM
                    (
                        SELECT
                            sdh.strId,
                            sdh.dateDlvr,
                            sdh.hourDlvr,
                            if(sdc.cntPrcl=0,0,sum(dhc.cntPrcl)/sdc.cntPrcl) AS rvrsTimePrgr  #派件进度
                        FROM
                            (
                                SELECT
                                    pi.`ticket_delivery_store_id` AS strId,
                                    date(convert_tz(pi.`finished_at`,'+00:00','+07:00')) AS dateDlvr,
                                    time((convert_tz(pi.`finished_at`,'+00:00','+07:00'))) AS hourDlvr
                                FROM
                                    `fle_staging`.`parcel_info` AS pi
                                WHERE
                                        pi.`state`='5'
                                  and pi.`returned`='0'
                                  and pi.`finished_at`>=convert_tz(date_add(current_date(),-7),'+07:00','+00:00')
                                  and pi.`finished_at`<convert_tz(current_date(),'+07:00','+00:00')
                                GROUP BY
                                    pi.`ticket_delivery_store_id`,
                                    date(convert_tz(pi.`finished_at`,'+00:00','+07:00')),
                                    time((convert_tz(pi.`finished_at`,'+00:00','+07:00')))
                            ) AS sdh
                                LEFT JOIN
                            (
                                SELECT
                                    pi.`ticket_delivery_store_id` AS strId, #派件网点ID
                                    date(convert_tz(pi.`finished_at`,'+00:00','+07:00')) AS dateDlvr, #派件日期
                                    count(distinct(pi.`pno`)) AS cntPrcl #件量
                                FROM
                                    `fle_staging`.`parcel_info` AS pi
                                WHERE
                                        pi.`state`='5'
                                  and pi.`returned`='0'
                                  and pi.`finished_at`>=convert_tz(date_add(current_date(),-7),'+07:00','+00:00')
                                  and pi.`finished_at`<convert_tz(current_date(),'+07:00','+00:00')
                                GROUP BY
                                    pi.`ticket_delivery_store_id`,
                                    date(convert_tz(pi.`finished_at`,'+00:00','+07:00'))
                            ) AS sdc
                            on sdh.strId=sdc.strId
                                and sdh.dateDlvr=sdc.dateDlvr
                                LEFT JOIN
                            (
                                SELECT
                                    pi.`ticket_delivery_store_id` AS strId,#派件网点
                                    date(convert_tz(pi.`finished_at`,'+00:00','+07:00')) AS dateDlvr,#派件日期
                                    time((convert_tz(pi.`finished_at`,'+00:00','+07:00'))) AS hourDlvr,#派件时间
                                    count(distinct(pi.`pno`)) AS cntPrcl  #件量
                                FROM
                                    `fle_staging`.`parcel_info` AS pi
                                WHERE
                                        pi.`state`='5' #已派送
                                  and pi.`returned`='0' #
                                  and pi.`finished_at`>=convert_tz(date_add(current_date(),-7),'+07:00','+00:00')#过去7天
                                  and pi.`finished_at`<convert_tz(current_date(),'+07:00','+00:00')
                                GROUP BY
                                    pi.`ticket_delivery_store_id`,
                                    date(convert_tz(pi.`finished_at`,'+00:00','+07:00')),
                                    time((convert_tz(pi.`finished_at`,'+00:00','+07:00')))
                            ) AS dhc  #过去7天派件网点的派件日期时间下的件量
                            on sdh.strId=dhc.strId
                                and sdh.dateDlvr=dhc.dateDlvr
                                and sdh.hourDlvr<=dhc.hourDlvr
                        GROUP BY
                            sdh.strId,
                            sdh.dateDlvr,
                            sdh.hourDlvr,
                            sdc.cntPrcl
                    ) AS dht  #网点的派件进度
                WHERE
                        time(convert_tz(current_time(),'+08:00','+07:00'))<=dht.hourDlvr
                GROUP BY
                    dht.strId
            ) AS shr  #网点最早交接时间下的派送进度
            on ssd.strId=shr.strId
                LEFT JOIN
            (
                SELECT
                    est.strId,
                    sum(ceil(pu1bfr*rt1+pu2bfr*rt2+pu3bfr*rt3+pu4bfr*rt4-arrv1bfr+lftOvrYstr)) AS estmShldDlvrTdy,#
                    sum(ceil(estmTdy*rt1+pu1bfr*(rt2-rt1)+pu2bfr*(rt3-rt2)+pu3bfr*(rt4-rt3))) AS estmShldDlvrTmrr,#
                    sum(ceil(estmTdy*rt1+pu1bfr*rt2+pu2bfr*rt3+pu3bfr*rt4-arrvByTdy)) AS shldDlvrTmrr #明日应派
                    -- slo.cntLftOvrPrcl,
                    -- slo.avgDlyDay,
                    -- slo.cntPrclAg5
                FROM
                    (
                        SELECT
                            pi.`dst_store_id` AS strId,
                            COALESCE(substring_index(ss.`ancestry`, "/", 1), ss.`id`) AS ancs,
                            if(count(distinct(if(pmt.minSttDate<current_date(),pi.`pno`,null)))=0,0,count(distinct(if(datediff(pmt.minSttDate,date(convert_tz(pi.`created_at`,'+00:00','+07:00')))=1 and pmt.minSttDate<current_date(),pmt.`pno`,null)))/count(distinct(if(pmt.minSttDate<current_date(),pi.`pno`,null)))) AS rt1,
                            #派件日期和发件日期相差一天，
                            if(count(distinct(if(pmt.minSttDate<current_date(),pi.`pno`,null)))=0,0,count(distinct(if(datediff(pmt.minSttDate,date(convert_tz(pi.`created_at`,'+00:00','+07:00')))<=2 and pmt.minSttDate<current_date(),pmt.`pno`,null)))/count(distinct(if(pmt.minSttDate<current_date(),pi.`pno`,null)))) AS rt2,
                            if(count(distinct(if(pmt.minSttDate<current_date(),pi.`pno`,null)))=0,0,count(distinct(if(datediff(pmt.minSttDate,date(convert_tz(pi.`created_at`,'+00:00','+07:00')))<=3 and pmt.minSttDate<current_date(),pmt.`pno`,null)))/count(distinct(if(pmt.minSttDate<current_date(),pi.`pno`,null)))) AS rt3,
                            if(count(distinct(if(pmt.minSttDate<current_date(),pi.`pno`,null)))=0,0,count(distinct(if(datediff(pmt.minSttDate,date(convert_tz(pi.`created_at`,'+00:00','+07:00')))<=4 and pmt.minSttDate<current_date(),pmt.`pno`,null)))/count(distinct(if(pmt.minSttDate<current_date(),pi.`pno`,null)))) AS rt4,
                            estm.estmTdy,
                            count(distinct(if(date(convert_tz(pi.`created_at`,'+00:00','+07:00'))=date_add(current_date(),-1),pi.`pno`,null))) AS pu1bfr,
                            count(distinct(if(date(convert_tz(pi.`created_at`,'+00:00','+07:00'))=date_add(current_date(),-2),pi.`pno`,null))) AS pu2bfr,
                            count(distinct(if(date(convert_tz(pi.`created_at`,'+00:00','+07:00'))=date_add(current_date(),-3),pi.`pno`,null))) AS pu3bfr,
                            count(distinct(if(date(convert_tz(pi.`created_at`,'+00:00','+07:00'))=date_add(current_date(),-4),pi.`pno`,null))) AS pu4bfr,
                            count(distinct(if(pi.`created_at`>=convert_tz(date_add(current_date(),-4),'+07:00','+00:00') and pi.`created_at`<convert_tz(current_date(),'+07:00','+00:00') and pmt.minSttDate<current_date(),pmt.pno,null))) AS arrv1bfr,
                            count(distinct(if(pmt.minSttDate<current_date() and (pi.`finished_at`>=convert_tz(current_date(),'+07:00','+00:00') or pi.`state`<>'5'),pi.`pno`,null))) AS lftOvrYstr,
                            count(distinct(if(pi.`created_at`>=convert_tz(date_add(current_date(),-3),'+07:00','+00:00') and pi.`created_at`<convert_tz(current_date(),'+07:00','+00:00') and pmt.minSttDate<=current_date(),pmt.pno,null))) AS arrvByTdy
                        FROM
                            `fle_staging`.`parcel_info` AS pi
                                LEFT JOIN
                            `fle_staging`.`sys_store` AS ss
                            on pi.`ticket_pickup_store_id`=ss.`id`
                                LEFT JOIN
                            (
                                SELECT
                                    sdt.`store_id` AS strId, #派件网点
                                    sdt.`pno`,
                                    min(sdt.`stat_date`) AS minSttDate #派件日期
                                FROM
                                    (select dc9.dst_store_id store_id,dc9.pno,dc9.stat_date from `dwm`.`dwd_th_non_end_pno_detl_d` dc9 union select dct.store_id,dct.pno,dct.stat_date from `bi_pro`.`dc_should_delivery_today` dct) AS sdt
                                WHERE
                                        sdt.`stat_date`>=date_add(current_date(),-11)
                                GROUP BY
                                    sdt.`store_id`,
                                    sdt.`pno`
                            ) AS pmt  #过去11天的网点的运单及最早统计时间，且运单揽收到派送在1-4天之间的运单
                            on pmt.pno=pi.`pno`
                                and pmt.strId=pi.`dst_store_id`
                                and datediff(pmt.minSttDate,date(convert_tz(pi.`created_at`,'+00:00','+07:00')))<=4 #运单揽收时间在1-4天之间
                                and datediff(pmt.minSttDate,date(convert_tz(pi.`created_at`,'+00:00','+07:00')))>=1
                                and pmt.minSttDate>=date_add(current_date(),-7)
                                and pi.returned=0
                                LEFT JOIN
                            (
                                SELECT
                                    pi.`dst_store_id` AS dstStrId,#派件网点
                                    COALESCE(substring_index(ss.`ancestry`, "/", 1), ss.`id`) AS ancsId,#父节点
                                    count(if(date(convert_tz(pi.`created_at`,'+00:00','+07:00'))=date(convert_tz(now(),'+08:00','+07:00')),pi.`pno`,null))+count(if(pi.`created_at`>=date_add(convert_tz(date(convert_tz(now(),'+08:00','+07:00')),'+07:00','+00:00'),interval -7 day) AND pi.`created_at`<date_add(convert_tz(date(convert_tz(now(),'+08:00','+07:00')),'+07:00','+00:00'),interval -6 day)  and date_format(convert_tz(pi.`created_at`,'+00:00','+07:00'),'%H:%i:%s')>date_format(convert_tz(now(),'+08:00','+07:00'),'%H:%i:%s') and (pi.`client_id` in ('AA0415','AA0427','AA0461','AA0477') or (kp.`id` IS NULL and kp2.`id` is null)),pi.`pno`,null))*coalesce(if(count(if(pi.`created_at`>=date_add(convert_tz(date(convert_tz(now(),'+08:00','+07:00')),'+07:00','+00:00'),interval -7 day) AND pi.`created_at`<date_add(convert_tz(date(convert_tz(now(),'+08:00','+07:00')),'+07:00','+00:00'),interval -6 day) and date_format(convert_tz(pi.`created_at`,'+00:00','+07:00'),'%H:%i:%s')<=date_format(convert_tz(now(),'+08:00','+07:00'),'%H:%i:%s') and (pi.`client_id` in ('AA0415','AA0427','AA0461','AA0477') or (kp.`id` IS NULL and kp2.`id` is null)),pi.`pno`,null))=0,0,count(if(date(convert_tz(pi.`created_at`,'+00:00','+07:00'))=date(convert_tz(now(),'+08:00','+07:00')) and (pi.`client_id` in ('AA0415','AA0427','AA0461','AA0477') or (kp.`id` IS NULL and kp2.`id` is null)),pi.`pno`,null))/count(if(pi.`created_at`>=date_add(convert_tz(date(convert_tz(now(),'+08:00','+07:00')),'+07:00','+00:00'),interval -7 day) AND pi.`created_at`<date_add(convert_tz(date(convert_tz(now(),'+08:00','+07:00')),'+07:00','+00:00'),interval -6 day) and date_format(convert_tz(pi.`created_at`,'+00:00','+07:00'),'%H:%i:%s')<=date_format(convert_tz(now(),'+08:00','+07:00'),'%H:%i:%s') and (pi.`client_id` in ('AA0415','AA0427','AA0461','AA0477') or (kp.`id` IS NULL and kp2.`id` is null)),pi.`pno`,null))),1)+(count(if(date(convert_tz(pi.`created_at`,'+00:00','+07:00'))<date(convert_tz(now(),'+08:00','+07:00')) and date_format(convert_tz(pi.`created_at`,'+00:00','+07:00'),'%H:%i:%s')>date_format(convert_tz(now(),'+08:00','+07:00'),'%H:%i:%s') and (pi.`client_id` not in ('AA0415','AA0427','AA0461','AA0477') and (kp2.`department_id`='22' or kp.`department_id`='22')),pi.`pno`,null))/4) AS estmTdy
                                FROM
                                    `fle_staging`.`parcel_info` AS pi
                                        LEFT JOIN
                                    `fle_staging`.`sys_store` AS ss
                                    on pi.`ticket_pickup_store_id`=ss.`id`
                                        LEFT JOIN
                                    `fle_staging`.`ka_profile` AS kp
                                    on pi.`client_id`=kp.`id`
                                        and kp.`department_id`='22'
                                        LEFT JOIN
                                    `fle_staging`.`ka_profile` AS kp2
                                    on kp.`agent_id`=kp2.`id`
                                        and kp2.`department_id`='22'
                                WHERE
                                        pi.`state`<>'9'
                                  AND pi.`returned`='0'
                                  AND ((pi.`created_at`>=date_add(convert_tz(date(convert_tz(now(),'+08:00','+07:00')),'+07:00','+00:00'),interval -7 day) AND pi.`created_at`<date_add(convert_tz(date(convert_tz(now(),'+08:00','+07:00')),'+07:00','+00:00'),interval -6 day))
                                    OR (pi.`created_at`>=date_add(convert_tz(date(convert_tz(now(),'+08:00','+07:00')),'+07:00','+00:00'),interval -14 day) AND pi.`created_at`<date_add(convert_tz(date(convert_tz(now(),'+08:00','+07:00')),'+07:00','+00:00'),interval -13 day))
                                    OR (pi.`created_at`>=date_add(convert_tz(date(convert_tz(now(),'+08:00','+07:00')),'+07:00','+00:00'),interval -21 day) AND pi.`created_at`<date_add(convert_tz(date(convert_tz(now(),'+08:00','+07:00')),'+07:00','+00:00'),interval -20 day))
                                    OR (pi.`created_at`>=date_add(convert_tz(date(convert_tz(now(),'+08:00','+07:00')),'+07:00','+00:00'),interval -28 day) AND pi.`created_at`<date_add(convert_tz(date(convert_tz(now(),'+08:00','+07:00')),'+07:00','+00:00'),interval -27 day))
                                    OR pi.`created_at`>=convert_tz(date(convert_tz(now(),'+08:00','+07:00')),'+07:00','+00:00'))
                                GROUP BY
                                    pi.`dst_store_id`,
                                    COALESCE(substring_index(ss.`ancestry`, "/", 1), ss.`id`)
                            ) AS estm
                            on pi.`dst_store_id`= estm.dstStrId
                                and COALESCE(substring_index(ss.`ancestry`, "/", 1), ss.`id`) = estm.ancsId
                        WHERE
                                pi.`created_at`>=convert_tz(date_add(current_date(),-11),'+07:00','+00:00')
                          and pi.`state`<>'9'
                          and pi.`returned`='0'
                        GROUP BY
                            pi.`dst_store_id`,
                            COALESCE(substring_index(ss.`ancestry`, "/", 1), ss.`id`)
                    ) AS est
#                         LEFT JOIN
#                     (
#                         SELECT
#                             sdt.`store_id` AS strId,
#                             count(distinct(sdt.`pno`)) AS cntLftOvrPrcl,
#                             count(distinct(if(datediff(current_date(),date(convert_tz(pi.`created_at`,'+00:00','+07:00'))) >= 5,sdt.`pno`,null))) AS cntPrclAg5,
#                             avg(datediff(sdt.`stat_date`,pmt.minSttDate)) AS avgDlyDay
#                         FROM
#                             `bi_pro`.`dc_should_delivery_today` AS sdt
#                                 JOIN
#                             `fle_staging`.`parcel_info` AS pi
#                             on sdt.`pno`=pi.`pno`
#                                 and pi.`created_at`>=convert_tz(date_add(current_date(),-11),'+07:00','+00:00')
#                                 and (pi.`finished_at`>=convert_tz(current_date(),'+07:00','+00:00') or pi.`state`<>'5')
#                                 LEFT JOIN
#                             (
#                                 SELECT
#                                     sdt.`store_id` AS strId,
#                                     sdt.`pno`,
#                                     min(sdt.`stat_date`) AS minSttDate
#                                 FROM
#                                     (select dc9.store_id,dc9.pno,dc9.stat_date from `dwm`.`dwd_ex_nw_shld_dlvr_pno_90` dc9 union select dct.store_id,dct.pno,dct.stat_date from `bi_pro`.`dc_should_delivery_today` dct) AS sdt
#                                 WHERE
#                                         sdt.`stat_date`>=date_add(current_date(),-11)
#                                 GROUP BY
#                                     sdt.`store_id`,
#                                     sdt.`pno`
#                             ) AS pmt
#                             on sdt.`pno`=pmt.pno
#                         WHERE
#                                 sdt.`stat_date`=date_add(current_date(),-1)
#                           and pi.returned=0
#                         GROUP BY
#                             sdt.`store_id`
#                     ) AS slo
#                     on est.strId = slo.strId
                GROUP BY
                    est.strId
            ) AS etm
            on ssd.strId=etm.strId
    ) tbq2 on tbq1.`网点ID`=tbq2.strId
        left join
    (
#承载量
        SELECT
            distinct sti.strId,
                     sti.strNm,
                     (stc.cntCrr-stc.cntCrrWtLv)*eff.tpEffc*6/7 AS crrtCpct #当前承载件量
        FROM
            (
                SELECT
                    current_date() AS sttDate,
                    ss.`id` AS strId,
                    ss.`name` AS strNm,
                    if(ss.`category` = '1','SP','BDC') AS ctgr,
                    smp.`name`AS pcNm,
                    smr.`name`AS rgnNm,
                    ss.`lat` AS lttd,
                    ss.`lng` AS lngt,
                    ss.`opening_at` AS opnDate,
                    ss.`delivery_frequency` AS dlvrFrqn,
                    sd.`upcountry` AS upCntr
                FROM
                    `fle_staging`.`sys_store` AS ss
                        LEFT JOIN
                    `fle_staging`.`sys_manage_piece` AS smp
                    on ss.`manage_piece` = smp.`id`
                        LEFT JOIN
                    `fle_staging`.`sys_manage_region` AS smr
                    on ss.`manage_region` = smr.`id`
                        LEFT JOIN
                    `fle_staging`.`sys_district` AS sd
                    on ss.`district_code` =sd.`code`
                        left join
                    `fle_staging`.`sys_store_bdc_bsp`  bsp
                    on bsp.`bsp_id` = ss.`id`
                WHERE
                        ss.`category` in('1','10')
                  and ss.`state` = '1'
                  and bsp.`bsp_id` is null
            ) AS sti
                LEFT JOIN
            (
                SELECT
                    si.`sys_store_id` AS strId,
                    count(distinct(if(si.`job_title` in('13','452','110'),si.`staff_info_id`,null))) AS cntCrr,
                    count(distinct(if(si.`job_title` in('110'),si.`staff_info_id`,null))) AS cntVan,
                    count(distinct(if(si.`job_title` in('13'),si.`staff_info_id`,null))) AS cntBike,
                    count(distinct(if(si.`job_title` in('37'),si.`staff_info_id`,null))) AS cntOffc,
                    count(distinct(if(si.`wait_leave_state`='1' and si.`job_title` in('13','452','110'),si.`staff_info_id`,null))) AS cntCrrWtLv,
                    count(distinct(if(si.`wait_leave_state`='1' and si.`job_title` in('110'),si.`staff_info_id`,null))) AS cntVanWtLv,
                    count(distinct(if(si.`wait_leave_state`='1' and si.`job_title` in('13'),si.`staff_info_id`,null))) AS cntBikeWtLv,
                    count(distinct(if(si.`wait_leave_state`='1' and si.`job_title` in('37'),si.`staff_info_id`,null))) AS cntOffcWtLv
                FROM
                    `bi_pro`.`hr_staff_info` AS si
                WHERE
                        si.`formal` ='1'
                  and si.`state` ='1'
                  and si.`job_title` in('13','452','110','37')
                  and si.is_sub_staff = 0
                GROUP BY
                    si.`sys_store_id`
            ) AS stc
            on sti.strId=stc.strId
                LEFT JOIN
            (
                select store_id 'strId',ori_tpeffc 'tpeffc' from tmpale.tmp_th_tgt_pop
            ) AS eff
            on sti.strId=eff.strId
                    group by 1
    ) tbq3 on tbq1.`网点ID` =tbq3.strId
        left join
    (
        select count(distinct pi.`pno` ) '今日揽收' from `fle_staging`.`parcel_info`  pi
        where pi.`state` <>9
          and pi.`returned` =0
          and pi.`created_at`>=date_sub(CURRENT_DATE(),interval 7 hour)
    ) tbq4 on 1=1
        left join
    (
        select count(distinct pi.`pno` ) '上周同期揽收' from `fle_staging`.`parcel_info`  pi
        where pi.`state` <>9
          and pi.`returned` =0
          and pi.`created_at`>=date_sub(CURRENT_DATE,interval 7 hour) -interval 7 day
          and pi.created_at<date_sub(CURRENT_DATE,interval 7 hour) -interval 6 day
    ) tbq5 on 1=1

