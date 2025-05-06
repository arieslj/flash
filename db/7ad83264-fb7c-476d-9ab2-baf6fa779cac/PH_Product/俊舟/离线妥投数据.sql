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
    hsi.staff_info_id in ('126705','127764','134157','137199','138861','140813','148150','149085','150744','150896','152309','153745','153991','155197','157126','160481','160741','161373','163307','164938','165536','166583','168964','169789','170297','171619','173409','178900','179153','180492','180795','181560','183759','185193','185250','185415','185531','185734','188034','192090','192152','192374','193088','194149','194217','194981','195218','195746','195960','196865','197145','197251','197413','198786','199062','199197','201783','2000230','122896','128014','131099','131101','132266','132676','133134','134060','134081','134457','134984','136571','136860','137252','137658','138481','140035','141077','141156','142038','145211','145429','145956','146036','147214','147727','147904','150221','150295','150887','151016','151061','151152','151268','152350','154592','155698','156738','156833','156949','157220','157379','157433','157704','157811','157967','158574','159113','159115','159141','159286','159849','159925','160000','160446','160584','160857','161302','161312','162064','162105','162391','163210','163500','164526','165554','165641','165771','166462','167138','167563','167877','168059','168442','168767','169051','169397','169483','169489','170139','170230','170967','171298','171342','171922','172018','173503','173638','173659','173662','174704','175109','176160','177153','177172','177228','177460','177728','177940','177946','178414','178677','178740','178898','179130','179414','179453','179536','180470','180572','180681','181175','181477','181718','181799','182060','182418','182471','182768','183262','183364','183408','183555','183682','183961','184048','184278','184280','184655','184983','185046','185217','185259','185507','185873','185979','186052','186543','186560','186579','187102','187248','187443','187487','187576','187867','187924','188066','188229','188253','188367','188400','188478','188674','188681','188897','189067','189667','189748','189797','189885','189962','190029','190101','190385','190546','190608','190765','190787','190841','190860','190970','191109','191127','191442','191551','191588','191880','191938','192079','192107','192145','192236','192254','192354','192368','192533','192563','192655','192660','193043','193394','193441','193570','193671','193735','194395','194426','194557','194824','194989','195037','195184','195312','195314','195434','195541','195561','195698','195734','195787','195788','196055','196079','196146','196170','196185','196206','196222','196369','196480','196871','196877','196903','196929','196969','197071','197430','197556','197598','197621','197800','198007','198085','198109','198163','198223','198243','198247','198455','198473','198542','198564','198682','198700','198867','198965','198972','199076','199206','199335','199336','199412','199421','199508','199556','199694','199698','199830','199868','199880','200116','200731','200972','201116','201554','201610','201667','201837','202446','412158','415497','416314','2000147','2000164')
