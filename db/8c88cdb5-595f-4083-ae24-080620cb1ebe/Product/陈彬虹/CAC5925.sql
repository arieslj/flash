-- 查下CAC5925客户底下 所有seller id、9.1到9.7妥投的包裹么，需要字段：
-- 运单号、运单生成时间、妥投日期、揽件网点、包裹状态、正/逆向、是否COD包裹、COD金额、是否拒收、拒收原因、客户ID、seller ID、seller 名称，寄件人名称、寄件人电话、寄件地址、收件人地址、收件人电话、包裹展示重量、展示尺寸
select
    pi.pno 运单号
    ,convert_tz(pi.created_at, '+00:00', '+07:00') 运单生成时间
    ,convert_tz(pi.finished_at, '+00:00', '+07:00') 妥投日期
    ,ss.name 揽件网点
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
    end as 运单状态
    ,case pi.returned
        when 1 then '退件'
        when 0 then '正向'
    end '正/逆向'
    ,case pi.cod_enabled
        when 1 then '是'
        when 0 then '否'
    end 是否COD包裹
    ,pi.cod_amount/100 COD金额
    ,if(di.pno is not null, '是', '否') 是否拒收
    ,ddd.CN_element 拒收原因
    ,pi.client_id 客户ID
    ,kw.out_client_id sellerid
    ,kw.src_name seller名称
    ,pi.src_name 寄件人名称
    ,pi.src_phone 寄件人电话
    ,pi.src_detail_address 寄件地址
    ,pi.dst_detail_address 收件人地址
    ,pi.dst_phone 收件人电话
    ,pi.exhibition_weight 包裹展示重量
    ,concat_ws('*', pi.exhibition_length, pi.exhibition_width, pi.exhibition_height) 展示尺寸
from fle_staging.parcel_info pi
left join fle_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
left join fle_staging.ka_warehouse kw on kw.id = pi.ka_warehouse_id
left join
    (
        select
            di2.pno
            ,di2.rejection_category
            ,row_number() over (partition by di2.pno order by di2.created_at desc ) rk
        from fle_staging.parcel_info pi
        join fle_staging.diff_info di2 on di2.pno = pi.pno
        where
             pi.state = 5
            and pi.finished_at > '2024-08-31 17:00:00'
            and pi.finished_at < '2024-09-07 17:00:00'
            and di2.created_at > '2024-08-31 17:00:00'
            and pi.client_id = 'CAC5925'
    ) di on di.pno = pi.pno and di.rk = 1
left join dwm.dwd_dim_dict ddd on ddd.element = di.rejection_category and ddd.db = 'fle_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'rejection_category'
where
    pi.state = 5
    and pi.finished_at > '2024-08-31 17:00:00'
    and pi.finished_at < '2024-09-07 17:00:00'
    and pi.client_id = 'CAC5925'