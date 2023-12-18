select
    ss.name
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.id is null then '普通ka'
        when kp.`id` is null then '小c'
    end 客户类型
    ,count(distinct ppd.pno) 留仓件数
    ,count(distinct if(ppd.diff_marker_category in (9,14,70), ppd.pno, null)) 改约时间件数
    ,count(distinct if(ppd.diff_marker_category in (9,14,70), ppd.pno, null))/count(distinct ppd.pno) 改约占比
from ph_staging.parcel_problem_detail ppd
left join ph_staging.sys_store ss on ss.id = ppd.store_id
left join ph_staging.parcel_info pi on pi.pno = ppd.pno
left join ph_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
where
    ppd.parcel_problem_type_category = 2
    and ppd.created_at >= '2023-06-25 16:00:00'
    and ppd.created_at < '2023-06-26 16:00:00'
group by 1,2

;


with t as
(
        select
            dp.store_name
            ,dp.region_name
            ,dp.piece_name
            ,ds.pno
            ,pi.client_id
            ,pi.state
        from ph_bi.dc_should_delivery_today ds
        left join ph_staging.parcel_info pi on pi.pno = ds.pno
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = ds.store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
        where
            ds.stat_date = '2023-06-26'
)
select
    a.region_name 大区
    ,a.piece_name 片区
    ,a.store_name 网点
    ,a.应派量
    ,a.交接量
    ,a.应派交接占比
    ,a.留仓量
    ,a.应派留仓占比
    ,a.妥投量
    ,a.问题件量
    ,a.`未妥投&未问题件&未留仓`
    ,b.`客户不在家/电话无人接听`
    ,b.客户改约时间
    ,b.`当日运力不足，无法派送`
from
    (
        select
            t1.store_name
            ,t1.region_name
            ,t1.piece_name
#             ,case
#                 when bc.`client_id` is not null then bc.client_name
#                 when kp.id is not null and bc.client_id is null then '普通ka'
#                 when kp.`id` is null then '小c'
#             end 客户类型
            ,count(t1.pno) 应派量
            ,count(if(pr.pno is not null, t1.pno, null )) 交接量
            ,count(if(ppd.pno is not null, t1.pno , null )) 留仓量
            ,count(if(ppd2.pno is not null, t1.pno , null )) 问题件量
            ,count(if(t1.state = 5, t1.pno, null)) 妥投量
            ,count(if(t1.state != 5 and ppd2.pno is null and ppd.pno is null, t1.pno, null)) `未妥投&未问题件&未留仓`
            ,count(if(pr.pno is not null, t1.pno, null ))/count(t1.pno) 应派交接占比
            ,count(if(ppd.pno is not null, t1.pno , null ))/count(t1.pno) 应派留仓占比
        from t t1
        left join
            (
                select
                    pr.pno
                from ph_staging.parcel_route pr
                join t t1 on t1.pno = pr.pno
                where
                    pr.created_at >= '2023-06-25 16:00:00'
                    and pr.created_at < '2023-06-26 16:00:00'
                    and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                group by 1
            ) pr on pr.pno = t1.pno
        left join
            (
                select
                    ppd.pno
                    ,ppd.diff_marker_category
                    ,ddd.CN_element
                from ph_staging.parcel_problem_detail ppd
                left join dwd_dim_dict ddd on ddd.element = ppd.diff_marker_category and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category' and ddd.db = 'ph_staging'
                join t t1 on t1.pno = ppd.pno
                where
                    ppd.parcel_problem_type_category = 2
                    and ppd.created_at >= '2023-06-25 16:00:00'
                    and ppd.created_at < '2023-06-26 16:00:00'

            ) ppd on ppd.pno = t1.pno
        left join
            (
                select
                    ppd.pno
                    ,ppd.diff_marker_category
                    ,ddd.CN_element
                from ph_staging.parcel_problem_detail ppd
                left join dwd_dim_dict ddd on ddd.element = ppd.diff_marker_category and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category' and ddd.db = 'ph_staging'
                join t t1 on t1.pno = ppd.pno
                where
                    ppd.parcel_problem_type_category = 1
                    and ppd.created_at >= '2023-06-25 16:00:00'
                    and ppd.created_at < '2023-06-26 16:00:00'
            ) ppd2 on ppd2.pno = t1.pno
        left join ph_staging.ka_profile kp on kp.id = t1.client_id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = t1.client_id
        group by 1,2,3
    ) a
left join
    (
        select
            t1.store_name
#             ,case
#                 when bc.`client_id` is not null then bc.client_name
#                 when kp.id is not null and bc.client_id is null then '普通ka'
#                 when kp.`id` is null then '小c'
#             end 客户类型
            ,count(if(ppd.diff_marker_category in (1,40), ppd.pno, null)) '客户不在家/电话无人接听'
            ,count(if(ppd.diff_marker_category in (9,14,70), ppd.pno, null)) '客户改约时间'
            ,count(if(ppd.diff_marker_category in (15,71), ppd.pno, null))  '当日运力不足，无法派送'
        from t t1
        left join
            (
                select
                    ppd.pno
                    ,ppd.diff_marker_category
                    ,ddd.CN_element
                from ph_staging.parcel_problem_detail ppd
                left join dwd_dim_dict ddd on ddd.element = ppd.diff_marker_category and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category' and ddd.db = 'ph_staging'
                join t t1 on t1.pno = ppd.pno
                where
                    ppd.parcel_problem_type_category = 2
                    and ppd.created_at >= '2023-06-25 16:00:00'
                    and ppd.created_at < '2023-06-26 16:00:00'
            ) ppd on ppd.pno = t1.pno
        left join ph_staging.ka_profile kp on kp.id = t1.client_id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = t1.client_id
        group by 1
    ) b on a.store_name = b.store_name



;


select
    plt.pno
    ,plt.id
    ,case plt.state
        when 1 then '丢失件待处理'
        when 2 then '疑似丢失件待处理'
        when 3 then '待工单回复'
        when 4 then '已工单回复'
        when 5 then '包裹未丢失'
        when 6 then '丢失件处理完成'
    end 状态
from ph_bi.parcel_lose_task plt
where
    plt.pno in ('P231223238AAM','P612723PWTZAH','P330822WCSPAD','P590222T7B9AG','PT150222UHS49AG','PT190522UT749BW','PT611422VJ0H8CL','PT612722T3PU4AF','P612522GQNEAT','PT612522VFHA5AP','P121022DMW5AW','P192423D1FTBG','PT610622UNJZ8AB','P61111UDNZ0AN','P172023PC87AL','P613022D9KSAT ','P1401228D24AR','P210923VQTDAB','P210823Q6ZXAJ','P27152374B3AE','P072222NCE2AG','P611522GUGDAE','PT613022UDRN8AL','PT612522S35M2AU','P61111S6JAUAN','PT640222QJPJ1EJ','PT611822V3HW3FI','PT612822VN2R3AH','P800922Q3D7AW','P613022UX7CAO','P612322W1C2AK','P420321QSEGFI','P080522NC8XAX','P140922VHMHAB','P61181VAUSYDB','P201822UJ5QAS','PT060422U4FP0BI','P210823FG2BAJ','P130323EWNDDF','P61111S97EBAN','P611523CEZKAP','P6114239HJ7CK','P0101239FVUAA','P611822YEQNEF','P210822TU9NAK','PT612522W7VZ9AN','P611920ZENUAB','P6107232JTRAL','P612622NPJKAB','PD611523CNDWBA','P191123NH13AI','P122023M61KAB','P2018236XX2AS','P611822X61WCX','PT210222V0DB7AB','P612021HG2MGV','P181923DUHYAL','PT612622U6W02AD','P121422MRS7AH','PT612022RHE76GU','PT120322TU4G0AT','P151623S5ABBS','P150323Q0UFBE','P6123225XRDAE','P613022RCD7AT','P613022UZUYAV','P590222TJA9AK','PT611622V75H1AE','P611423YE3CDE','PT611822T3116FI','PT611822T3116FI','P1925233FUAAV','P180923HEB3DC','P590321HKSUAO','P122023HDGEBA','P610123HJMSCP','P612523VMYPAI','P612823MST0CX','P1911220NV8AD','P612123KHVVAO','P611723R2UBBD','P121121AX7WAA','P612023GVHWDS','PT490422RWPT0BR','P0418202H2CAH','P40391XKYSXAH','PT611422W8T96CQ','P180923BRUJBV','P044423SS14AG','P180823J4U9AV','P6128201FBHFV','P180323Z9UCAR','PT122022WV2D1BS','P1928233ZMHAH','PT612822T2JT0CX','P192823ADU9AH','PT612822Q5BK2HM','PT612922V29R9AG','PT611022UBQW3AN','PT121322X9XE8AD','PT131222V89W5AU','P192822QD3WAH','PT612022KG8U6GJ','PT611722UUBW5AN','PT150722V8W71AT','P210822UNRTAB','P613122XHX8BO','P612023KS8QAY','P210823PSVNAB','P590222TJA9AK','P6401232STFAE','P5902230QEQAK','P612423EQCKAK','P201323C4H5BJ','P21052377X5AC','P420522JKJQBC','P322123GQBKCO','P611621K89QAN','P611723T7CDBD','P192822QZ7UAH','P121721TECMAL','P192822VHVMAH','P611723J63NAE','P1928223K0HAH','PD613023M3W1AC','P242922TMN3AR','P323322GRNSAJ','P61041ZCEEHAA','P610123RKJTJH','P61041ZDD25AA','P613123KV2EAK','P61041ZH8RUAA','P61041Z6GK7AA','P611121YVYABN','P610420AXBRAA','P611121MMH6BN','P611121HWCXBN','P6201234T6UBD','P612023SFXZGT','P210521HF9CAG','P420522JY46BC','P612122CK8RAE','P64022344YQDM','P612623EQRRAH','P211323C58AAE','P6117239JYYAQ','P172222ZNQ7BF','P343323098GAB','P611523BMRMAX','P192523M49UAR','P043823H8U2AH','P610420MKP8AA','P5105222TXDBO','P610420BBC9AA','P610421BFHMAA','P6126241T77AB','P610123C3J1JC','P61041YRYZTAA','P070823R2MJBZ','P35172379MDAG','P6131235P0CBQ','P171923P58SBM','P612022V745EE','PT180822TRFB2AB','P321822SJCTAD','P042723ZAW7CU','P2001239XT1AK','PT220622VTEA3BY','PT612422RYE45AL','PT612422RW1K0AL','PT170522UXR84AJ','P122023MAFXCE','PT611422UK686CF','P141723S9DYAN','P180623U9M0BU','P61182301BBFH','P510522JRT9BS','P61041ZBCK7AA','P6107227SGJAL','P611623YMECAE','P151723MJDNAS','PT610822W65V0AI','PT411322T9FE0AF','PT180922XD653AL','P180623NRUWAB','P324123SKS0AB','P611822MBT8FL','PT613122XBAK4AF','P1328236JQ2BA','P130323AYWJAA','P61042134G7AA','PT613022UUW64AE','PT180322UX9H4AP','P611723K45TAE','P611723JAN6AE','P180923ZCT5AB','PT010522UEEJ2BH','PT611822WX129EA','PT611422R6XC4AX','PT040422VM1X4AR','PT610622JEXP4AD','P61041Z8VSUAA','P192822F6XRAH','PT611822HW271FJ','P6123231H7PAD','P640220A67PAA','P6114244R8VCP','P612323USRJAS','P611722GK1XAK','P61182409YCFJ','P0606232EWWAV','P210223A6EXAF','P611523J3X8AV','P2102248T8QAC','PT351722S3QH1AZ','PT191122WGZG8AD','PT211322TDQP4AC','PT611722TQS01AK','PT611722X06C7AK','P3530245H5UAL','P130323YDFNDB','P352621C8BWAR','P640623R8V8AD','PT611422R6XC4AX','P612222F8JTAH','PT613022XGP99AM','P042923WBPKAM','P22012405XVBW','P611923ZE94AI','P611820Y5V6FJ','P611822BR4VCN','P21042312QQAC','P61041ZG1DNAA','PT612822WWQ73DI','PT353022UE7M4AC','PT612322XCMM6AK','P610223JSMRAC','PT140422VD644AG','P061923J9PKAC','P0438235RUVBA','P61172147P5BA','P611522WG3AAB','PT180822W60E6BF','P182023B3T9AW','P2701227BT1AO','P613023270YAR','PT612522Y0UW0AI','P6110225UREAO','P150823WBVTAP','P3517221TEDAJ','P61152403F9AS','P610521MZ0EBA','P1220249T8QAF','P2401248P45AS','P172723V0JZAE','P6125232RJGAU','PT210222XM7Z7AB','PT422522UWW64AT','P192822H2FJAH','P613023B3C3AP','PT180622WREY5AA','PT611022U19K3AH','P192821WEDYAH','P19281ZCDY8AH','P343322XVVAAC','PT210222XDSY3AA','P19281XFHQ6AH','P19281XEAWVAH','P19281W5V2PAH','P19281SQXQKAH','P19281S2UE6AH','P19281VK5EYAH','P19281W3UWAAH','P19281S8TKEAH','P610423JSD1AJ','PT270522WUDJ6AM','PT062922WEKY0AF','PT613022YKVK3AM','P61171411YUAA','PT171922Y6EW6AW','P611713TUJ5AA','PT612822UMSJ4AA','P6117143BU9AA','PT073122XVW57AJ','PT610122U1S14GM','P192820ZZJ0AH','P192821BB2PAH','P1928216A8BAH','P192820KSMTAH','PT611622SSEH6AM','P19281ZWY09AH','P192820ZAP6AH','P19281W4EZVAH','P19281VH19TAH','P19281VJZKRAH','P19281S8TQ5AH','P180124DP6PAT','P19281QP6HEAH','PT610622TWSX2AD','PT611522WQ187AS','P6118225R7SDS','P180622HKFVAB','P342722ENFAAO','P6126246JATAH','P140922MY0FAL','P1210246AYSBM','PT770122VSUN3AL','PT611722ZAHC2AK','P353023AWUUAZ','P6118233ERUFI','PT150722ZHTR6AB','PT612422YS1K3AN','P611522VBRWAV','P80022405G6AK','P220324CVBUAJ','P61231ZHYX5AB','P612320ZG2JAB','P612320M8NWAB','P61211YVZZSAD','P61181YWBVJBX','P12081ZC0UBAL','P61181YAKNJCP','P61021YK9B7AC','P61021YVBYSAA','P61031Z4E47AA','P61031Z797AAN','P61201ZJE1PDR','P12231Z472EAT','P180424BTDYAA')


;

select
    pr.pno
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') scan_time
    ,if(coalesce(pi3.cod_enabled, pi.cod_enabled) = 1, 'COD', 'NO_COD') COD_OR_NOT
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
    end shipment_status
    ,pi.returned_pno
    ,case pi2.state
        when 1 then 'RECEIVED'
        when 2 then 'IN_TRANSIT'
        when 3 then 'DELIVERING'
        when 4 then 'STRANDED'
        when 5 then 'SIGNED'
        when 6 then 'IN_DIFFICULTY'
        when 7 then 'RETURNED'
        when 8 then 'ABNORMAL_CLOSED'
        when 9 then 'CANCEL'
    end returned_pno_shipment_status
from ph_staging.parcel_route pr
left join ph_staging.parcel_info pi on pi.pno = pr.pno
left join ph_staging.parcel_info pi2 on pi2.pno = pi.returned_pno
left join ph_staging.parcel_info pi3 on pi3.returned_pno = pi.pno
where
    pr.routed_at >= '2023-07-31 16:00:00'
    and pr.staff_info_id = 160732