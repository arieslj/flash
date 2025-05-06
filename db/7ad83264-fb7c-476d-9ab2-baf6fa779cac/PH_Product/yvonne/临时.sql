
select
    t.*
    ,vrv.link_id
from tmpale.tmp_ph_ivr_datail_1205 t
left join nl_production.violation_return_visit vrv on vrv.id = t.taskid
;


select
    vrv.link_id
    ,vrv.id
    ,vrv.visit_state
    ,vrv.created_at
from nl_production.violation_return_visit vrv
where
    vrv.link_id in ('PT210224ZQFY0AD','PT261724ZHWJ2BE','PT422124ZARH5AU','PT261024YKJE5AO','PT421024XPA69AD','PT430624YUAD5AK','PT182224YMN10AK','PT420224ZHTX7BD','PT790624XWFC9AN','PT411324XSV66AV','PT400124ZJ4K2AW','PT0221250WBJ0AE','PT430924X2JV4AE','PT090324YMM86AB','PT770324X2PQ1AH','PT261224YCQR4AY','PT400324WTUE4AK','PT401624YDW62AT','PT09032513UY1AK','PT023424ZDFW9AF','PT22012502NT2AD','PT070824YZE52BZ','PT070724X74J5AN')
     and vrv.visit_staff_id  = 10001 OR ( vrv.visit_staff_id = 0 AND vrv.visit_state = 2 )
    and vrv.type  = 3
;

select
    t.pno
    ,case pi.state
        when 1 then 'RECEIVED'
        when 2 then 'IN_TRANSIT'
        when 3 then 'DELIVERING'
        when 4 then 'STRANDED'
        when 5 then 'SIGNED'
        when 6 then 'IN_DIFFICULTY'
        when 7 then 'RETURNED'
        when 8 then 'ABNORMAL_CLOSED'
        when 9 then 'CANCEL'
    end as parcel_tatus
from ph_staging.parcel_info pi
join tmpale.tmp_ph_pno_lj_1212  t on t.pno = pi.pno

;

select
    a1.pno
    ,a1.sub_time
    ,a1.store_name
    ,a2.di_cnt
    ,pi.dst_detail_address
from
    (
        select
            pr.pno
            ,pr.store_name
            ,pr.store_id
            ,pr.routed_at
            ,pr.staff_info_id
            ,t.sub_time
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_lj_0129 t on t.pno = pr.pno and t.satff = pr.staff_info_id and date_format(pr.routed_at, '%Y-%m-%d %H:%i') = date_format(date_sub(t.sub_time, interval 8 hour), '%Y-%m-%d %H:%i')
        where
            pr.routed_at > '2023-12-28'
           -- and t.pno = 'PT351725YGUU0BP'
    ) a1
left join
    (
        select
            di.pno
            ,count(distinct di.id) di_cnt
        from  ph_staging.diff_info di
        join tmpale.tmp_ph_pno_lj_0129 t on t.pno = di.pno
        where
            di.diff_marker_category = 31
            and di.created_at > '2023-09-01'
        group by  1
    ) a2 on a2.pno = a1.pno
left join ph_staging.parcel_info pi on pi.pno = a1.pno




;
select
    max(id)
from nl_production.violation_return_visit vrv


;


select
    pr.pno Waybill_number
    ,pr.staff_info_id Staff
    ,oi.cogs_amount/100 COGS
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') Mark_time
from ph_staging.parcel_route pr
left join ph_staging.parcel_info pi on pi.pno = pr.pno
left join ph_staging.order_info oi on oi.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
where
    pr.pno in ('${SUBSTITUTE(SUBSTITUTE(p2,"\n",","),",","','")}')
    and pr.route_action in ( 'DELIVERY_MARKER', 'DELIVERY_TICKET_CREATION_SCAN')
    and pr.routed_at >date_sub(curdate(), interval 4 month )

;
select
    pr.pno
    ,pr.staff_info_id Staff
    ,oi.cogs_amount/100 cogs
    ,ss.name
from ph_staging.parcel_route pr
left join ph_staging.parcel_info pi on pi.pno = pr.pno
left join ph_staging.sys_store ss on ss.id = pi.dst_store_id
left join ph_staging.order_info oi on oi.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
where
    pr.routed_at > date_sub(curdate(), interval 4 month )
    and pr.route_action = 'DELIVERY_CONFIRM'
    and pr.pno in ('${SUBSTITUTE(SUBSTITUTE(p1,"\n",","),",","','")}')



;






;
select
    a1.pno
    ,convert_tz(a1.routed_at, '+00:00', '+08:00') route_time
    ,a1.staff_info_id
    ,a1.route_action
    ,a1.remark
from·
    (
        select
            pr.pno
            ,pr.routed_at
            ,pr.route_action
            ,pr.staff_info_id
            ,pr.remark
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
        from ph_staging.parcel_route pr
        where
            pr.routed_at > '2024-01-01'
            and pr.pno in ('P230549HM71AO','P24164C4PGGAI','P64024CX8Y3BL','P64104CS3TCAP','FLPHX300002775433','FLPHX300002738830','FLPHX300002737843','FLPHX300002735033','P61184C38T5EP','P12154D7F8TAP','P79104CR909BC','P59084C9K9DAJ','P22044CEPKJAZ','P40304C24Z9DB','P121848ZQ07AN','PT6402900HT3Z','PT74068TN5T6Z','PT151693AZ28Z','PT64028PQ394Z','PT611892TYJ2Z','PT61258YH820Z','PT35178WD893Z','PT32218XSKP2Z','PT452127N7MW7Z','P12064DQSZZAJ','P07034CTK0AAB','P64024CVM5BBL','P14014D91V1AL','P210244BE6XAG','P61254C6802BD','P57134BK5Z8AW','P610643G228HJ','P18064D2WTHBU','P14054CWD14AY','PT61188Z5VW1Z','PT730227SS2G4Z','PT322190FZC7Z','PT14018TAEJ9Z','PT61268ZATG6Z','PT35148QPMG5Z','PT67048FT160Z','PT120391SBY8Z','PT61188KJFP3Z','P24104DCBEMAS','P04184E487BBA','P61214B7QBQAS','P12163RMBNKAN','P12163MM00VAN','P12163M7073AN','P12163M71KVAN','PT61218HWE81Z','PT35308VCQF7Z','PT612390YRT7Z','PT611791NMB8Z','PT6131958T26Z','PT40148RSX00Z','PT121026MS083Z','PT172294SS59Z','PT66068SJ231Z','PT35178XCE72Z','PT611594DT08Z','P6103414C0JAM','P59084ATVRQAK','P06054CXY6XAX','P07294D5KP7AG','P18184CZV7SBJ','P23034E9ZYKAU','FLPHX300002721098','P64054D722YAH','FLPHX300002753797','P36174DW053AK','P36174DSMCHAK','P36174DV927AK','P18184EAVF5AO','P27074EFMKNAS','P01124DZ9H6AQ','P321349JKRDBA','P77084BZGGEAH','P01194B546KAY','P53024C1HK6AR','P61184DV0U3AK','P61184A0BBWEL','P61184CZ545ET','P61204CHBZKCO','P61184CPA7JAI','P03194D6XUQAC','P12064DC505AF','P61304EAVY2AT','P22144AME42AM','P21124DYN08AC','P61184DX50TFH','P40304D2WXADX','P18204B5ZSBAE','P04474DEZBWAA','P61134D3CHWAA','P171448Q5ATAF','P32214CCATHCK','P61014CH11PAB','P12084CCSBKAJ','P21124DVQSSAC','P61184DJ5M2CP','P24054DHY61AX','P23034CCJFMAK','P18154D3TASAY','P611844C6ZUFK','P12164C37AFAN','P12164A6KQ0AN','PT182093Y3U4Z','PT611791EKN6Z','PT611892W2Y8Z','PT611892WZP4Z','PT74068TC440Z','PT170593EYJ4Z','PT132794VWT7Z','PT180894WXZ4Z','PT611797D698Z','PT6123973189Z','PT610196HPZ8Z','P61184C0B0PCD','P04184DTM9DAI','P121145VF2BAK','P21114EQABEAE','P611745BC2AAQ','P612146FUUTAO','P32414DVEW0AJ','P32414DUS90AJ','P61034A8H7UAE','P06294CFYRDAN','P83014D4T07AU','P27154EDA6GAC','P34084E4ZSYAJ','P610147CEBMJP','P612346D4PMAH','P610345CUAUAP','P611946BWR6AI','FLPHX300002791820','P24034D6UFKBA','PD6122490W40AK','P21114DEHBPAO','P18204DXGJAAT','P21084EJGXTAJ','P24224E2B6DAF','P64064A07TYAG','P61254DTD9FAB','P61314EAXFEAF','P35174B1RQWBE','P24244DFW6FAD','P61184D0DCUBX','P610445BPN5AD','P61184DVRHYAD','P23124CB74JAM','P12204DHVPQAI','P17224DB8FFAY','P612349V3N8AD','P61154E90J1AA','P120448ZV1PAL','PD61184EF7RHFJ','P61144F1E49CF','P61184EHERKFJ','PT6131947G89Z','PT611791DCG8Z','PT612591EVA2Z','PT211293NSV6Z','PT612694CR70Z','PT613194MHC4Z','PT1416975EX0Z','PT18098UB4H2Z','PT2427976Y85Z','PT271096WT89Z','PT6118998J34Z','P61204CNYGZFG','P36234DYXBKAU','P08054E6R0EAJ','P07034E6KWRAP','P23034EP82YAK','P61014CRAVAIR','P61204AM9ZYGJ','P07084E8J5CAZ','P18224FHU20AG','P12174F37DDAL','FLPHX300002788770','P61184BESD5EK','P61014ATYJKJG','P61014AVRPZJG','P20074EJHZ3AA','P61184DWNCXDT','P18064F0RZZBI','P03074DV84PAY','P26034EA5EJAS','P61174E971ZBC','P19244EXU2JCR','P32334D4BX3AK','P12114DQ0DTAF','P39064EDY0UAW','P24054EUJYBAS','P03144AV01BCF','P61104D6VE4AU','P36064BKRA2AG','P13034DXM24BB','PT171793ZHU6Z','PT6402942QP3Z','PT190595FJ94Z','PT61108XF7W1Z','P77194D8YW4AE','P23114D3H7VAI','P61234DCCDCAS','FLPHX800000309317','FLPHX300002805356','P61184FGM60CC','P61044E2B5RAA','P1808484N2DAX','P180845XK76AX','P180847DQJFAX','FLPHX300002874630','P35174DNYQ2BN','P24243YGQJ7AB','FLPHX300002848874','P07074EX6N8AK','P24344FAS85BM','P24344FJ59PBM','P83014DEE59AK','P11074FUN3WAF','P17064FHQ69AF','P32214FHH14DE','P6101476190IC','P611447XRMBAX','P24194E5YDABG','P61054F5U7CAJ','P210848K1KQAB','P53024EB433AU','P12234CRTSJAF','PT590295C7E5Z','PT6123944RE9Z','PT45218S8NW1Z','PT12039888Q3Z','PT1614919RC2Z','PT61189677T9')

    ) a1
where
    a1.rk = 1

;




/*
        =====================================================================+
        表名称：1213d_ph_shopee_wrong_address
        功能描述：菲律宾shopee地址错误数据

        需求来源：
        编写人员: jiangtong
        设计日期：2023-01-17
      	修改日期:
      	修改人员:
      	修改原因:
      -----------------------------------------------------------------------
      ---存在问题：
      -----------------------------------------------------------------------
      +=====================================================================
      */




select
distinct
oi.id
, oi.pno
, oi.src_name
, oi.client_id
, oi.sub_channel_category
, oi.dst_province_code
, oi.dst_city_code
, oi.dst_district_code
, pr.name as dst_province_name
, pc.name as dst_city_name
, pd.name as dst_district_name
, oi.dst_postal_code
, oi.dst_detail_address
, oi.dst_store_id
, cast(oi.cogs_amount as BIGINT) / 100 as insure_declare_value
, cast(oi.weight as BIGINT) / 1000 as weight
, oi.length
, oi.width
, oi.height
, oi.confirm_at as confirm_at
, ld.dst_province_code predict_province_code
, ld.dst_city_code predict_city_code
, ld.dst_district_code predict_district_code
, pr1.name as predict_province_name
, pc1.name as predict_city_name
, pd1.name as predict_district_name
,ld.dst_postal_code predict_postal_code
,case when oi.dst_province_code<>ld.dst_province_code then 'Different Province'
      when oi.dst_province_code=ld.dst_province_code and oi.dst_city_code<>ld.dst_city_code then 'Different City'
      when oi.dst_province_code=ld.dst_province_code and oi.dst_city_code=ld.dst_city_code and oi.dst_district_code<>ld.dst_district_code and ps.name=ps1.name then 'Same city different barangay same dc'
      when oi.dst_province_code=ld.dst_province_code and oi.dst_city_code=ld.dst_city_code and oi.dst_district_code<>ld.dst_district_code and ps.name<>ps1.name then 'Same city different barangay different dc'
      else null end as type
from
(
select
distinct
 oi.client_id
,oi.dst_province_code
,oi.dst_city_code
,oi.dst_district_code
,oi.id
,oi.pno
,oi.src_name
,oi.sub_channel_category
,oi.dst_postal_code
,oi.dst_detail_address
,oi.cogs_amount
,oi.weight
,oi.length
,oi.height
,oi.width
,oi.confirm_at
,oi.dst_store_id

from fle_dwd.dwd_fle_order_info_di oi
where oi.p_date>DATE_SUB(current_date(),INTERVAL 30 day)
and oi.opt='32'
and oi.sub_channel_category in ('17', '18')
)oi
join
(
select
 db.client_id
from fle_dim.dim_fle_dwm_bigclient_da db
where db.p_date=date_sub(current_date(),interval 1 day)
and db.client_name='shopee'
)db on oi.client_id=db.client_id
join
  (
   select
   distinct
     pi.pno
     ,pi.created_at
   from fle_dwd.dwd_fle_parcel_info_di pi
   where pi.p_date>=DATE_SUB(current_date(),INTERVAL 3 day)
   and pi.returned='0'
   and to_date(pi.created_at)=DATE_SUB(current_date(),INTERVAL 1 day)
  )pi on oi.pno=pi.pno
left join
(
  select
    sp.code,
    sp.name
  from fle_dim.dim_fle_sys_province_da sp
  where sp.p_date=date_sub(current_date(),interval 1 day)
)pr on pr.code=oi.dst_province_code

left join
(
  select
    sp.code,
    sp.name
  from fle_dim.dim_fle_sys_city_da sp
  where sp.p_date=date_sub(current_date(),interval 1 day)
)pc on pc.code=oi.dst_city_code
left join
(
  select
    sp.code,
    sp.name,
    sp.store_id
  from fle_dim.dim_fle_sys_district_da sp
  where sp.p_date=date_sub(current_date(),interval 1 day)
)pd on pd.code=oi.dst_district_code
left join
(
  select
    sp.id,
    sp.name
  from fle_dim.dim_fle_sys_store_da sp
  where sp.p_date=date_sub(current_date(),interval 1 day)
)ps on ps.id=pd.store_id


left join
(
select
ld.order_id
,ld.pno
,ld.dst_province_code
,ld.dst_city_code
,ld.dst_district_code
,ld.dst_postal_code

from fle_dwd.dwd_drds_order_address_analysis_log_d_di ld
where ld.p_date>=DATE_SUB(current_date(),INTERVAL 10 day)
and ld.p_date<=current_date()

)ld on if(ld.order_id is not null,ld.order_id,ld.pno)=if(ld.order_id is not null,oi.id,oi.pno)

left join
(
select
  sp.code,
  sp.name
from fle_dim.dim_fle_sys_province_da sp
where sp.p_date=date_sub(current_date(),interval 1 day)
)pr1 on pr1.code=ld.dst_province_code
left join
(
  select
    sp.code,
    sp.name
  from fle_dim.dim_fle_sys_city_da sp
  where sp.p_date=date_sub(current_date(),interval 1 day)
)pc1 on pc1.code=ld.dst_city_code
left join
(
  select
    sp.code,
    sp.name,
    sp.store_id
  from fle_dim.dim_fle_sys_district_da sp
  where sp.p_date=date_sub(current_date(),interval 1 day)
)pd1 on pd1.code=ld.dst_district_code

left join
(
  select
    sp.id,
    sp.name
  from fle_dim.dim_fle_sys_store_da sp
  where sp.p_date=date_sub(current_date(),interval 1 day)
)ps1 on ps1.id=pd1.store_id


;


select
    min(created_at)
from dw_dmd.parcel_store_stage_new


