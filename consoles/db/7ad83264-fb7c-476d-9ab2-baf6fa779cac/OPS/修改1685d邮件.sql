/*
        =====================================================================+
        表名称：1685d_ph_miss_scan_data
        功能描述：菲律宾揽收漏扫描数据

        需求来源：
        编写人员: jiangtong
        设计日期：2023-08-31
      	修改日期:
      	修改人员:
      	修改原因:
      -----------------------------------------------------------------------
      ---存在问题：
      -----------------------------------------------------------------------
      +=====================================================================
      */

select
    *
from
    (
        select
            distinct
            pi.pno
            ,if(pi.weight/1000<=3
                and (pi.length+pi.width+pi.height)<=60
                and(pi.length<=30 or pi.width<=30 or pi.weight<=30)
                and ss.category!=10
                and pi.article_category!=11
              ,'yes','no') 是否应集包
            ,if(pr.pno is null,'no','yes') 是否有发件出仓
            ,if(pr1.pno is null,'no','yes') 是否有收件入仓
            ,date(convert_tz(pi.created_at,'+00:00','+08:00')) 揽收时间
            ,dp.store_name DC
            --
            ,case
                when dp.store_type='SP' THEN dp.par_store_name
                when dp.store_type='HUB' THEN dp.store_name
                when dp.store_type='PDC' and dp.store_name in ('DMP_PDC','NUP_PDC') and dp.par_store_name in ('02 PN2-HUB_Pangasinan') then '11 PN5-HUB_Santa Rosa'
                when dp.store_type='PDC' and dp.store_name in ('MTP_PDC','BGN_PDC','TAP_PDC','ANP_PDC','HOP_PDC') and dp.par_store_name in ('02 PN2-HUB_Pangasinan') then '16 PN8-HUB_Bulacan'
                when dp.store_type='PDC' and dp.par_store_name in ('01 PN1-HUB_Maynila','04 PN4-HUB_Bicol','05 PC1-HUB_Cebu') then '01 PN1-HUB_Maynila'
                when dp.store_type='PDC' and dp.par_store_name in ('02 PN2-HUB_Pangasinan') then '02 PN2-HUB_Pangasinan'
                when dp.store_type='PDC' and dp.par_store_name in ('16 PN8-HUB_Bulacan') then '16 PN8-HUB_Bulacan'
                else '11 PN5-HUB_Santa Rosa'
            end as 始发分拨
            ,dp1.par_store_name 目的地分拨
            ,dp.piece_name 片区
            ,dp.region_name 大区
            ,if(pi.returned=0,'正向件','退件') 包裹方向
            ,pr3.routed_at 集包时间
            ,pr.routed_at 发件出仓时间
            ,pr1.routed_at 收件入仓时间
            ,pr2.routed_at 车货关联出港时间
            ,case
                when pi.state='1' then '已揽收'
                when pi.state='2' then '运输中'
                when pi.state='3' then '派送中'
                when pi.state='4' then '已滞留'
                when pi.state='5' then '已签收'
                when pi.state='6' then '疑难件处理中'
                when pi.state='7' then '已退件'
                when pi.state='8' then '异常关闭'
                when pi.state='9' then '已撤销'
                else null
            end as 包裹状态

        from ph_staging.parcel_info pi
        left join dwm.dim_ph_sys_store_rd dp on pi.ticket_pickup_store_id = dp.store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
        left join dwm.dim_ph_sys_store_rd dp1 on pi.dst_store_id = dp1.store_id and dp1.stat_date = date_sub(curdate(), interval 1 day)
        left join ph_staging.sys_store ss on ss.id=pi.dst_store_id
        left join
            (
                select
                distinct
                pr.pno
                ,min(convert_tz(pr.routed_at,'+00:00','+08:00')) routed_at
                from ph_staging.parcel_route pr
                left join ph_staging.parcel_info pi on pr.pno=pi.pno
                where pr.route_action='SHIPMENT_WAREHOUSE_SCAN'
                and pr.store_id=pi.ticket_pickup_store_id
                and pr.routed_at>=convert_tz(date_sub(curdate(),interval 1 day),'+08:00','+00:00')
                group by 1
            )pr on pi.pno=pr.pno

        left join
            (
                select
                 pr.pno
                ,min(convert_tz(pr.routed_at,'+00:00','+08:00')) routed_at
                from ph_staging.parcel_route pr
                left join ph_staging.parcel_info pi on pr.pno=pi.pno
                where pr.route_action in ('RECEIVE_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN')
                and pr.store_id=pi.ticket_pickup_store_id
                and pr.routed_at>=convert_tz(date_sub(curdate(),interval 1 day),'+08:00','+00:00')
                group by 1
            )pr1 on pi.pno=pr1.pno
        left join
            (
                select
                 pr.pno
                ,min(convert_tz(pr.routed_at,'+00:00','+08:00')) routed_at
                from ph_staging.parcel_route pr
                left join ph_staging.parcel_info pi on pr.pno=pi.pno
                where pr.route_action in ('DEPARTURE_GOODS_VAN_CK_SCAN')
                and pr.store_id=pi.ticket_pickup_store_id
                and pr.routed_at>=convert_tz(date_sub(curdate(),interval 1 day),'+08:00','+00:00')
                group by 1
            )pr2 on pi.pno=pr2.pno
        left join
            (
                select
                 pr.pno
                ,min(convert_tz(pr.routed_at,'+00:00','+08:00')) routed_at
                from ph_staging.parcel_route pr
                left join ph_staging.parcel_info pi on pr.pno=pi.pno
                where pr.store_id=pi.ticket_pickup_store_id
                and pr.route_action in ('SEAL')
                and pr.routed_at>=convert_tz(date_sub(curdate(),interval 1 day),'+08:00','+00:00')
                group by 1
            )pr3 on pi.pno=pr3.pno
        where pi.created_at>=convert_tz(date_sub(curdate(),interval 1 day),'+08:00','+00:00')
        and pi.created_at<convert_tz(curdate(),'+08:00','+00:00')
        and dp.store_name not like 'FH%'
    )a
where 发件出仓时间 is null
or 收件入仓时间 is null
or (是否应集包='yes' and 集包时间 is null)