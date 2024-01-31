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
    hsi.staff_info_id in ('120594','157311','158862','159982','161687','167221','168067','169693','150163','153248','159886','166001','166372','166444','166899','167828','168102','168481','171813','153485','161861','132475','157466','157468','157756','160313','160399','161154','150626','150830','157103','160084','161259','133733','172151','146931','148081','149506','124050','126728','139532','140043','140172','142856','143478','144623','145115','146055','148196','149123','154963','156932','157061','157657','158326','158755','172320','147745','148937','155458','156486','159650','169635','159481','159561','160802','161265','161446','171353','141825','149895','153683','158464','159043','159967','166915','166919','146815','150095','152178','161364','167795','168625','169188','172445','137390','147774','152245','164304','165037','165141','165384','165968','167297','167845','168683','169246','170659','170868','171746','172515','132052','162024','145070','156285','157035','157099','157443','158728','158899','159123','160311','162160','164831','165349','165351','165353','165658','165955','166292','166293','166386','166456','166747','166783','167253','167313','167414','168581','168759','170472','170711','171523','147895','151566','153397','155401','163150','164246','166628','170563','139634','143466','147809','154204','157036','169877','126514','134462','140702','146587','148521','149133','149134','149201','149645','149750','152235','153232','156491','157368','157591','157593','158149','158159','158228','158775','159261','160451','164947','165012','165455','167346','167878','168363','168532','170782','170783','170784','170920','171503','173062','387385','388457','388549','389433','152059','156926','163699','164955','147005','148306','152830','153463','154007','154115','154267','142112','157122','163594','164381','166908','168106','169091','125457','147806','152186','153882','124726','133819','144260','152154','156877','157642','159867','160129','166023','166308','171893','141186','142067','146088','146562','151001','151288','155047','157074','159824','160476','162062','162127','162687','162689','165387','372756','135772','143575','159086','161958','168328','142966','154025','154469','157293','157369','157837','161852','163884','166074','166340','166515','166569','167037','167359','167856','168392','169954','170516','172010','141094','143412','147282','150314','156263','159798','157982','158421','158642','163161','155687','162456','152975','150502','153806','154831','156699','158804','162380','162658','163443','163559','163560','164744','165307','171647','150508','150723','151025','163148','165024','166002','166081','166384','151265','163130','166935','143226','155203','163592','135208','154716','159456','159527','160480','161301','162733','162768','164131','164713','155777','155976','156582','157145','159187','160954','161165','162932','163972','164804','165368','165513','165691','171953','173485','158242','159434','162069','162861','163342','163889','164009','164652','164981','165166','165324','165560','165628','166065','166373','168525','153602','136016','147638','152037','158513','158994','159906','160692','163036','165443','372613','135990','151237','151579','160770','168794','155265','155712','159962','160005','161872','162065','162970','164189','165816','170488','171792','172833','122030','156377','159881','163299','150680','161024','161032','162952','150481','155172','162425','164171','169131','170015','172212','128694','146224','147302','147422','151368','155071','164549','165819','167378','167576','167733','167929','169998','171000','148175','157576','163566','167033','168004','168036','171300','171617','171968','381832','139504','139740','147902','154936','160807','162974','164348','167205','169633','172387')
