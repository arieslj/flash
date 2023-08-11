select
    ss.pno
    ,ss.parcel_created_at
    ,ss.task_created_at
    ,case ss.source
        WHEN 1 THEN 'A-问题件-丢失'
        WHEN 2 THEN 'B-记录本-丢失'
        WHEN 3 THEN 'C-包裹状态未更新'
        WHEN 4 THEN 'D-问题件-破损/短少'
        WHEN 5 THEN 'E-记录本-索赔-丢失'
        WHEN 6 THEN 'F-记录本-索赔-破损/短少'
        WHEN 7 THEN 'G-记录本-索赔-其他'
        WHEN 8 THEN 'H-包裹状态未更新-IPC计数'
        WHEN 9 THEN 'I-问题件-外包装破损险'
        WHEN 10 THEN 'J-问题记录本-外包装破损险'
        when 11 then 'K-超时效包裹'
        when 12 then 'L-高度疑似丢失'
    end source
    ,ddd.CN_element last_valid_action
    ,ss.last_valid_action_store_id
    ,ss.last_valid_action_store_name
    ,case ss.last_valid_action_store_category
      when '1' then 'SP'
      when '2' then 'DC'
      when '4' then 'SHOP'
      when '5' then 'SHOP'
      when '6' then 'FH'
      when '7' then 'SHOP'
      when '8' then 'Hub'
      when '9' then 'Onsite'
      when '10' then 'BDC'
      when '11' then 'fulfillment'
      when '12' then 'B-HUB'
      when '13' then 'CDC'
      when '14' then 'PDC'
    end last_valid_action_store_category
    ,case ss.parcel_state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end  parcel_state
    ,ss.reality_duty_store_one_id
    ,ss.reality_duty_store_one_name
    ,ss.reality_duty_store_two_id
    ,ss.reality_duty_store_two_name
    ,case ss.reality_duty_result
        when 1 then '丢失'
        when 2 then '破损'
        when 3 then '超时效'
    end reality_duty_result
    ,t.t_value reality_duty_reasons
    ,case ss.reality_duty_type
        when 1 then '快递员100%套餐'
        when 2 then '仓9主1套餐(仓管90%主管10%)'
        when 3 then '仓9主1套餐(仓管90%主管10%)'
        when 4 then '双黄套餐(A网点仓管40%主管10%B网点仓管40%主管10%)'
        when 5 then '快递员721套餐(快递员70%仓管20%主管10%)'
        when 6 then '仓管721套餐(仓管70%快递员20%主管10%)'
        when 8 then 'LH全责（LH100%）'
        when 7 then '其他(仅勾选“该运单的责任人需要特殊处理”时才能使用该项)'
        when 9 then '加盟商套餐'
        when 10 then '双黄套餐(计数网点仓管40%计数网点主管10%对接分拨仓管40%对接分拨主管10%)'
        when 19 then '双黄套餐(计数网点仓管40%计数网点主管10%对接分拨仓管40%对接分拨主管10%)'
        when 20 then  '加盟商双黄套餐（加盟商50%网点仓管45%主管5%）'
    end reality_duty_type
    ,case ss.reality_link_type
        when 0 then 'ipc计数后丢失'
        when 1 then '揽收网点已揽件，未收件入仓'
        when 2 then '揽收网点已收件入仓，未发件出仓'
        when 3 then '中转已到件入仓扫描，中转未发件出仓'
        when 4 then '揽收网点已发件出仓扫描，分拨未到件入仓(集包)'
        when 5 then '揽收网点已发件出仓扫描，分拨未到件入仓(单件)'
        when 6 then '分拨发件出仓扫描，目的地未到件入仓(集包)'
        when 7 then '分拨发件出仓扫描，目的地未到件入仓(单件)'
        when 8 then '目的地到件入仓扫描，目的地未交接,当日遗失'
        when 9 then '目的地到件入仓扫描，目的地未交接,次日遗失'
        when 10 then '目的地交接扫描，目的地未妥投'
        when 11 then '目的地妥投后丢失'
        when 12 then '途中破损/短少'
        when 13 then '妥投后破损/短少'
        when 14 then '揽收网点已揽件，未收件入仓'
        when 15 then '揽收网点已收件入仓，未发件出仓'
        when 16 then '揽收网点发件出仓到分拨了'
        when 17 then '目的地到件入仓扫描，目的地未交接'
        when 18 then '目的地交接扫描，目的地未妥投'
        when 19 then '目的地妥投后破损短少'
        when 20 then '分拨已发件出仓，下一站分拨未到件入仓(集包)'
        when 21 then '分拨已发件出仓，下一站分拨未到件入仓(单件)'
        when 22 then 'ipc计数后丢失'
        when 23 then '超时效sla'
        when 24 then '分拨发件出仓到下一站分拨了'
	end reality_link_type
    ,ss.system_duty_store_one_id
    ,ss.system_duty_store_one_name
    ,ss.system_duty_store_two_id
    ,ss.system_duty_store_two_name
    ,case ss.system_duty_result
        when 1 then '丢失'
        when 2 then '破损'
        when 3 then '超时效'
    end system_duty_result
    ,t2.t_value system_duty_reasons
    ,case ss.system_duty_type
        when 1 then '快递员100%套餐'
        when 2 then '仓9主1套餐(仓管90%主管10%)'
        when 3 then '仓9主1套餐(仓管90%主管10%)'
        when 4 then '双黄套餐(A网点仓管40%主管10%B网点仓管40%主管10%)'
        when 5 then '快递员721套餐(快递员70%仓管20%主管10%)'
        when 6 then '仓管721套餐(仓管70%快递员20%主管10%)'
        when 8 then 'LH全责（LH100%）'
        when 7 then '其他(仅勾选“该运单的责任人需要特殊处理”时才能使用该项)'
        when 9 then '加盟商套餐'
        when 10 then '双黄套餐(计数网点仓管40%计数网点主管10%对接分拨仓管40%对接分拨主管10%)'
        when 19 then '双黄套餐(计数网点仓管40%计数网点主管10%对接分拨仓管40%对接分拨主管10%)'
        when 20 then  '加盟商双黄套餐（加盟商50%网点仓管45%主管5%）'
    end system_duty_type
    ,case ss.system_link_type
        when 0 then 'ipc计数后丢失'
        when 1 then '揽收网点已揽件，未收件入仓'
        when 2 then '揽收网点已收件入仓，未发件出仓'
        when 3 then '中转已到件入仓扫描，中转未发件出仓'
        when 4 then '揽收网点已发件出仓扫描，分拨未到件入仓(集包)'
        when 5 then '揽收网点已发件出仓扫描，分拨未到件入仓(单件)'
        when 6 then '分拨发件出仓扫描，目的地未到件入仓(集包)'
        when 7 then '分拨发件出仓扫描，目的地未到件入仓(单件)'
        when 8 then '目的地到件入仓扫描，目的地未交接,当日遗失'
        when 9 then '目的地到件入仓扫描，目的地未交接,次日遗失'
        when 10 then '目的地交接扫描，目的地未妥投'
        when 11 then '目的地妥投后丢失'
        when 12 then '途中破损/短少'
        when 13 then '妥投后破损/短少'
        when 14 then '揽收网点已揽件，未收件入仓'
        when 15 then '揽收网点已收件入仓，未发件出仓'
        when 16 then '揽收网点发件出仓到分拨了'
        when 17 then '目的地到件入仓扫描，目的地未交接'
        when 18 then '目的地交接扫描，目的地未妥投'
        when 19 then '目的地妥投后破损短少'
        when 20 then '分拨已发件出仓，下一站分拨未到件入仓(集包)'
        when 21 then '分拨已发件出仓，下一站分拨未到件入仓(单件)'
        when 22 then 'ipc计数后丢失'
        when 23 then '超时效sla'
        when 24 then '分拨发件出仓到下一站分拨了'
	end system_link_type
    ,case replace(json_extract(json_extract(ss.extra_value, '$.base'), '$.nextStoreCategory') ,'"', '')
        when '1' then 'SP'
        when '2' then 'DC'
        when '4' then 'SHOP'
        when '5' then 'SHOP'
        when '6' then 'FH'
        when '7' then 'SHOP'
        when '8' then 'Hub'
        when '9' then 'Onsite'
        when '10' then 'BDC'
        when '11' then 'fulfillment'
        when '12' then 'B-HUB'
        when '13' then 'CDC'
        when '14' then 'PDC'
    end nextstorecategory
    ,case replace(json_extract(json_extract(ss.extra_value, '$.base'), '$.previousStoreCategory') ,'"', '')
        when '1' then 'SP'
        when '2' then 'DC'
        when '4' then 'SHOP'
        when '5' then 'SHOP'
        when '6' then 'FH'
        when '7' then 'SHOP'
        when '8' then 'Hub'
        when '9' then 'Onsite'
        when '10' then 'BDC'
        when '11' then 'fulfillment'
        when '12' then 'B-HUB'
        when '13' then 'CDC'
        when '14' then 'PDC'
    end previousstorecategory
    ,case replace(json_extract(json_extract(ss.extra_value, '$.base'), '$.isPack') ,'"', '')
        when 1 then '是'
        when 0 then '否'
        when 'false' then '否'
    end isPack
    ,case replace(json_extract(json_extract(ss.extra_value, '$.base'), '$.isUnload') ,'"', '')
        when 1 then '是'
        when 0 then '否'
        when 'false' then '否'
    end isUnload
    ,case replace(json_extract(json_extract(ss.extra_value, '$.base'), '$.haveSendNotArrive') ,'"', '')
        when 1 then '是'
        when 0 then '否'
        when 'false' then '否'
    end haveSendNotArrive
    ,case replace(json_extract(json_extract(ss.extra_value, '$.base'), '$.isDirectorOrKeeper') ,'"', '')
        when 1 then '是'
        when 0 then '否'
        when 'false' then '否'
    end isDirectorOrKeeper
    ,case replace(json_extract(json_extract(ss.extra_value, '$.base'), '$.isCourier') ,'"', '')
        when 1 then '是'
        when 0 then '否'
        when 'false' then '否'
    end isCourier
    ,case replace(json_extract(json_extract(ss.extra_value, '$.base'), '$.haveKeeperSpecialRoute') ,'"', '')
        when 1 then '是'
        when 0 then '否'
        when 'false' then '否'
    end haveKeeperSpecialRoute
    ,case replace(json_extract(json_extract(ss.extra_value, '$.base'), '$.sameDayUnload') ,'"', '')
        when 1 then '是'
        when 0 then '否'
        when 'false' then '否'
    end sameDayUnload
    ,case replace(json_extract(json_extract(ss.extra_value, '$.base'), '$.haveReceiveWarehouse') ,'"', '')
        when 1 then '是'
        when 0 then '否'
        when 'false' then '否'
    end haveReceiveWarehouse
#     ,ddd2.CN_element 路由动作
#     ,convert_tz(pr.routed_at, '+00:00', '+07:00')   路由时间
from bi_center.ssjudge_system_duty_contrast ss
left join dwm.dwd_dim_dict ddd on ddd.element = ss.last_valid_action and ddd.db = 'rot_pro' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
left join bi_pro.translations t on t.t_key = ss.reality_duty_reasons and t.lang = 'zh-CN'
left join bi_pro.translations t2 on t2.t_key = ss.system_duty_reasons and t2.lang = 'zh-CN'
# left join rot_pro.parcel_route pr on pr.pno = ss.pno and pr.routed_at < date_sub(ss.task_created_at, interval  7 hour) and pr.routed_at > '2023-04-30 17:00:00'
# join dwm.dwd_dim_dict ddd2 on ddd2.element = pr.route_action and ddd2.db = 'rot_pro' and ddd2.tablename = 'parcel_route' and ddd2.fieldname = 'route_action' and ddd2.remark = 'valid'
where
    ss.parcel_created_at >= '2023-01-01'
    and

;

select
#     ss.*
#     ,ddd2.CN_element 路由动作
#     ,convert_tz(pr.routed_at, '+00:00', '+07:00') 路由时间
    count(ss.pno)
from tmpale.tmp_th_plt_pno_0728 ss
left join rot_pro.parcel_route pr on pr.pno = ss.pno and pr.routed_at < date_sub(ss.task_created_at, interval  7 hour) and pr.routed_at > '2023-04-30 17:00:00'
join dwm.dwd_dim_dict ddd2 on ddd2.element = pr.route_action and ddd2.db = 'rot_pro' and ddd2.tablename = 'parcel_route' and ddd2.fieldname = 'route_action' and ddd2.remark = 'valid'