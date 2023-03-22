SELECT
    t.pno,
    DATE_FORMAT(t.created_at, '%Y-%m-%d') as created_date,
    1 AS flag -- 疑似丢失
FROM bi_pro.parcel_lose_task  t
LEFT JOIN bi_pro.parcel_detail  pd ON pd.pno = t.pno
left join fle_staging.sys_store ss on ss.id = pd.resp_store_id
WHERE
    t.source IN (3, 33)
    AND t.state IN (1,2,3,4)
#     AND pd.resp_store_id = '{$storeId}'
    and ss.name = 'PYI_SP-พัทยาใต้'
;

select
    hsi.staff_info_id
    ,hsi.hire_date
from bi_pro.hr_staff_info hsi
where
    hsi.staff_info_id in ('119999', '121776', '125595', '127320', '144914', '126471', '129577', '143552', '128544', '130629', '139340', '142684', '121517', '124245', '122849', '147026', '129478', '139564', '138995', '132638', '142468', '142398', '121959', '147204', '140513', '141731', '119363', '143365', '146200', '131902', '146662', '136717', '141425', '147700', '123315', '143644', '146887', '146301', '146973', '147313', '132704', '119263', '129450', '143836', '138168', '126277', '126820', '132318', '127738', '143159', '142878', '120650', '142461', '145659', '137498', '137552', '138000', '123831', '138684', '146078', '147338', '136411', '138850', '148502', '147271', '121614', '137223', '141200', '144392', '146816', '147626', '146985', '147117', '145885', '147910', '126985', '138674', '145092', '147716', '141582', '143109', '144085', '146844', '120671', '132576', '131210', '141791', '145706', '146910', '148060', '148693', '143813', '144606', '144713', '147202', '121549', '136363', '141386', '141151', '143837', '145412', '146858', '135396', '136414', '136979', '146185', '141935', '146629', '135674', '124103', '137645', '141549', '146865', '133938', '139445', '142106', '142674', '145900', '137230', '145800', '146031', '147246', '121500', '124751', '139759', '144557', '145803', '146810', '146970', '147001', '144886', '146472', '123868', '143519', '146076', '146737', '147083', '148413', '133321', '138572', '139911', '143055', '143674', '147333', '147929', '120718', '128919', '147316', '147780', '147828', '148073')
;

select
    t.运单号
    ,pct.claims_amount/100 网点理赔
    ,b.claim_money 闪速理赔
from tmpale.tmp_th_pno_zjq_0319 t
left join  fle_staging.pickup_claims_ticket pct on pct.pno = t.运单号 and pct.state = 5 and pct.claims_type_category = 1 -- 理赔
left join
    (
        select
            a.*
        from
            (
                select
                    pct.`pno`
                    ,pct.`id`
                    ,row_number() over (partition by pct.`pno` order by pct.`id`  DESC ) row_num
                from bi_pro.parcel_claim_task pct
                where
                    pct.state= 6
            ) a
        where
            a.row_num = 1
    ) a on a.pno = t.运单号
left join
    (
        select
            *
        from
            (
                select
                    pcn.`task_id`
                    ,replace(json_extract(pcn.`neg_result`,'$.money'),'\"','') claim_money
                    ,row_number() over (partition by pcn.`task_id` order by pcn.`created_at` DESC ) row_num
                from bi_pro.parcel_claim_negotiation pcn
            ) b
        where
            b.row_num = 1
    ) b on b.task_id = a.id
;

-- TH05110303 AAA_SP;  TH02030204 --05 LAS_HUB-ลาซาล

select
    pi.pno
    ,ss.name 妥投网点
    ,convert_tz(pi.created_at, '+00:00', '+07:00') 揽收时间
    ,case pi.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
    ,convert_tz(pi.finished_at, '+00:00', '+07:00') 异常时间
    ,bc.client_name 客户
    ,pi.cod_amount/100 COD金额
from fle_staging.parcel_info pi
left join fle_staging.parcel_info pi2 on pi2.pno = pi.recent_pno
left join fle_staging.sys_store ss on ss.id = pi.ticket_delivery_store_id
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id
where

    pi.dst_store_id = 'TH05110303'
    and pi.state
    and pi.ticket_delivery_store_id not in ('TH05110303','TH02030204')
    and
        (
             (pi.state = 8 and  pi.finished_at >= '2022-12-31 17:00:00' and pi.finished_at < '2023-02-28 17:00:00')
            or ( pi.state = 7 and pi2.created_at >= '2022-12-31 17:00:00' and pi2.created_at < '2023-02-28 17:00:00')
        )
;
