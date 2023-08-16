select
    count(distinct pr.pno) 妥投量
    ,count(distinct if(cast(json_extract(pr.extra_value, '$.offlineDelivery') as string) = 1, pr.pno, null)) 离线妥投量
from ph_staging.parcel_route pr
left join ph_staging.parcel_info pi on pi.pno = pr.pno
where
    pr.route_action = 'DELIVERY_CONFIRM'
#     and cast(json_extract(pr.extra_value, '$.offlineDelivery') as string) = 1
    and pr.routed_at > '2023-07-31 16:00:00'
    and pi.dst_store_id in ('PH77190100','PH73090800','PH73020100','PH77030100','PH77050A00','PH76120H00','PH74060200','PH76090C00','PH74010100','PH76040A00','PH73030300','PH76190100','PH74120A00','PH75060200','PH51050301','PH47170100','PH51050500','PH49040100','PH51030400','PH51020J00','PH47140200','PH49040102','PH47210100','PH51100100','PH47080301','PH51080100','PH49040101','PH47070A00','PH47200600','PH47120100','PH47150100','PH51080101','PH51120B01','PH45210101','PH45212600','PH50100100','PH46020100','PH45130F00','PH46050101','PH45200H00','PH44020100','PH44180100','PH46150100','PH45210100','PH45010100','PH44010T00','PH50100200','PH45140300','PH14010F00','PH14010F00','PH22130500','PH23100300')
;


select
    pr.pno
    ,ss.name 网点
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 妥投时间
    ,pr.staff_info_id 妥投员工
from ph_staging.parcel_route pr
left join ph_staging.parcel_info pi on pi.pno = pr.pno
left join ph_staging.sys_store ss on ss.id = pi.dst_store_id
where
    pr.route_action = 'DELIVERY_CONFIRM'
    and cast(json_extract(pr.extra_value, '$.offlineDelivery') as string) = 1
    and pr.routed_at > '2023-07-31 16:00:00'
    and pi.dst_store_id in ('PH77190100','PH73090800','PH73020100','PH77030100','PH77050A00','PH76120H00','PH74060200','PH76090C00','PH74010100','PH76040A00','PH73030300','PH76190100','PH74120A00','PH75060200','PH51050301','PH47170100','PH51050500','PH49040100','PH51030400','PH51020J00','PH47140200','PH49040102','PH47210100','PH51100100','PH47080301','PH51080100','PH49040101','PH47070A00','PH47200600','PH47120100','PH47150100','PH51080101','PH51120B01','PH45210101','PH45212600','PH50100100','PH46020100','PH45130F00','PH46050101','PH45200H00','PH44020100','PH44180100','PH46150100','PH45210100','PH45010100','PH44010T00','PH50100200','PH45140300','PH14010F00','PH14010F00','PH22130500','PH23100300')

;
select
    cast(json_extract(pr.extra_value, '$.offlineDelivery') as string) a
from ph_staging.parcel_route pr
where
    pr.route_action = 'DELIVERY_CONFIRM'
    and pr.pno = 'P471421RSM2AE'

;

















select
    hsi.staff_info_id
    ,sp.name RESIDENCE_PROVINCE
    ,sc.name RESIDENCE_CITY
    ,sd.name RESIDENCE_DISTRICT
    ,h7.value RESIDENCE_POSTCODES
    ,h8.value RESIDENCE_HOUSE_NUM
    ,h9.value RESIDENCE_VILLAGE_NUM
    ,h10.value RESIDENCE_VILLAGE
    ,h11.value RESIDENCE_VILLAGE_NUM
    ,h12.value RESIDENCE_ALLEY
    ,h13.value RESIDENCE_STREET
    ,h14.value RESIDENCE_DETAIL_ADDRESS
from ph_bi.hr_staff_info hsi
# left join ph_bi.hr_staff_items h2 on h2.staff_info_id = hsi.staff_info_id and h2.item = 'RESIDENCE_COUNTRY'
left join ph_bi.hr_staff_items h3 on h3.staff_info_id = hsi.staff_info_id and h3.item = 'RESIDENCE_PROVINCE'
# left join ph_bi.hr_staff_items h4 on h4.staff_info_id = hsi.staff_info_id and h4.item = 'RESIDENCE_COUNTRY'
left join ph_bi.hr_staff_items h5 on h5.staff_info_id = hsi.staff_info_id and h5.item = 'RESIDENCE_CITY'
left join ph_bi.hr_staff_items h6 on h6.staff_info_id = hsi.staff_info_id and h6.item = 'RESIDENCE_DISTRICT'
left join ph_bi.hr_staff_items h7 on h7.staff_info_id = hsi.staff_info_id and h7.item = 'RESIDENCE_POSTCODES'
left join ph_bi.hr_staff_items h8 on h8.staff_info_id = hsi.staff_info_id and h8.item = 'RESIDENCE_HOUSE_NUM'
left join ph_bi.hr_staff_items h9 on h9.staff_info_id = hsi.staff_info_id and h9.item = 'RESIDENCE_VILLAGE_NUM'
left join ph_bi.hr_staff_items h10 on h10.staff_info_id = hsi.staff_info_id and h10.item = 'RESIDENCE_VILLAGE'
left join ph_bi.hr_staff_items h11 on h11.staff_info_id = hsi.staff_info_id and h11.item = 'RESIDENCE_VILLAGE_NUM'
left join ph_bi.hr_staff_items h12 on h12.staff_info_id = hsi.staff_info_id and h12.item = 'RESIDENCE_ALLEY'
left join ph_bi.hr_staff_items h13 on h13.staff_info_id = hsi.staff_info_id and h13.item = 'RESIDENCE_STREET'
left join ph_bi.hr_staff_items h14 on h14.staff_info_id = hsi.staff_info_id and h14.item = 'RESIDENCE_DETAIL_ADDRESS'
left join ph_staging.sys_province sp on sp.code = h3.value
left join ph_staging.sys_city sc on sc.code = h5.value
left join ph_staging.sys_district sd on sd.code = h6.id
where
    hsi.staff_info_id in ('121760','133871','144652','155094','148916','139303','133254','127779','134193','156306','143787','153886','146757','154346','146507','157690','154777','157717','154223','143081','139100','121659','131258','140976','154085','154448','148709','149051','136061','148349','144575','148946','157185','146323','143108','139258','122227','144343','137955','134845','152857','147847','148317','150769','155667','150347','158096','151317','151343','144641','129548','367544','139171','132084','145932','150606','149998','148268','142190','130896','126623','148566','145324','148384','142116','121392','154824','149245','137819','148864','130339','151756','145596','155748','138253','148720','150756','152025','146389','153836','152100','157393','149847','156827','148927','153624','150014','153054','155152','130649','153092','147561','149477','158697','151484','151309','150296','151307','148312','149610','143806','149863','155346','148619','142136','148765','147652','147432','154923','151738','360705','149160','149265','150007','151467','150642','149005','121732','156449','135266','139477','147707','143267','158123','146884','149984','148979','151672','137267','129368','150134','149623','148294','148729','152015','147960','124057','145116','152254','142058','151869','142939','141076','150187','149551','130589','149289','147550','132752','152156','144479','151804','151668','145894','146556','132906','145504','147006','152483','151260','150002','147318','146774','146775','147691','154511','135558','148325','135137','130728','151526','130290','123557','145193','155419','142069','153480','135428','148769','141220','144047','150210','134890','120890','141022','156353','148627','148895','157152','148099','152021','149932','149113','123024','151622','140839','135102','146179','148448','144016','145201','150387','149421','146703','149352','148831','156276','151027','147097','143986','145203','143686','159845','158577','143711','155096','152334','140766','150421','128053','140685','151164','151114','143706','145755','147539','150034','133912','140317','139555','141434','145488','149153','135323','122852','144719','139055','147776','149407','157956','138920','128073','147435','142149','143495','138797','135027','151353','120282','144492','134656','148602','147654','151595','147714','152319','149527','145273','147350','155182','371173','157118','159478','156378','159856')
