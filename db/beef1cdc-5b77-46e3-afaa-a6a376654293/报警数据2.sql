    select
        t.pno
        ,t.name
        ,a1.created_at
        ,a1.finished_at
        ,a1.client_id
        ,a1.src_name
        ,a1.src_phone
        ,a1.src_detail_address
        ,a1.dst_name
        ,a1.dst_phone
        ,a1.dst_detail_address
        ,case a1.article_category
            when '0' then '文件เอกสาร'
            when '1' then '干燥食品อาหารแห้ง'
            when '2' then '日用品ของใช้ประจำวัน'
            when '3' then '数码商品สินค้าดิจิตอล'
            when '4' then '衣物เสื้อผ้า'
            when '5' then '书刊หนังสือและวารสาร'
            when '6' then '汽车配件อะไหล่รถยนต์'
            when '7' then '鞋包ถุงใส่รองเท้า/กระเป๋าใส่รองเท้า'
            when '8' then '体育器材 อุปกรณ์กีฬา'
            when '9' then '化妆品เครื่องสำอาง'
            when '10' then '家具用具เครื่องใช้ภายในบ้าน'
            when '11' then '水果ผลไม้'
            when '99' then '其他อื่นๆ'
        end as `物品类型ประเภทสินค้า`
        ,cast(a1.cod_amount as int)/100 cod_total
        ,a1.exhibition_weight
        ,concat_ws('*', a1.exhibition_length, a1.exhibition_width, a1.exhibition_height) chicun
        ,s1.name s1_name
        ,s2.name s2_name
        ,case a1.state
            when '1' then '已揽收 รับพัสดุแล้ว'
            when '2' then '运输中 ระหว่างการขนส่ง'
            when '3' then '派送中 ระหว่างการจัดส่ง'
            when '4' then '已滞留 พัสดุคงคลัง'
            when '5' then '已签收 เซ็นรับแล้ว'
            when '6' then '疑难件处理中 ระหว่างจัดการพัสดุมีปัญหา'
            when '7' then '已退件 ตีกลับแล้ว'
            when '8' then '异常关闭 ปิดงานมีปัญหา'
            when '9' then '已撤销 ยกเลิกแล้ว'
        end `包裹状态`
        ,group_concat(concat('https://fle-asset-internal.oss-ap-southeast-1.aliyuncs.com/',a2.object_key)) `签名`
--     from test.tmp_th_m_pno_0703 t
    from
        (
            select
                fsr.staff_info_id
                ,fsr.staff_info_name name
                ,fsr.pno
            from fle_dwd.dwd_fle_store_receivable_bill_detail_di fsr
            where
                fsr.p_date >= '2023-01-01'
                and fsr.state = '0'
                and fsr.staff_info_id in ('606637','617640','603778','628753','610320','630598','638027','612048')
        ) t
    left join
        (
            select
                pi.*
            from
                (
                    select
                        pi.pno
                        ,pi.created_at
                        ,pi.state
                        ,pi.finished_at
                        ,pi.client_id
                        ,pi.src_name
                        ,pi.src_phone
                        ,pi.src_detail_address
                        ,pi.dst_name
                        ,pi.dst_phone
                        ,pi.dst_detail_address
                        ,pi.article_category
                        ,pi.cod_amount
                        ,pi.exhibition_weight
                        ,pi.exhibition_length
                        ,pi.exhibition_width
                        ,pi.exhibition_height
                        ,pi.ticket_pickup_store_id
                        ,pi.ticket_delivery_store_id
                    from fle_dwd.dwd_fle_parcel_info_di pi
                    where
                        pi.p_date >= '2023-01-01'
--                         and pi.p_date < '2023-06-01'
                ) pi
--             join test.tmp_th_m_pno_0724 t on t.pno = pi.pno
        ) a1 on a1.pno = t.pno
    left join
        (
            select
                sa.*
            from
                (
                    select
                        sa.oss_bucket_key
                        ,sa.oss_bucket_type
                        ,sa.bucket_name
                        ,sa.object_key
                    from fle_dwd.dwd_fle_sys_attachment_di sa
                    where
                        sa.p_date >= '2023-01-01'
--                         and sa.p_date < '2023-04-01'
                        and sa.oss_bucket_type = 'DELIVERY_CONFIRM'
                ) sa
--             join test.tmp_th_m_pno_0724 t on t.pno = sa.oss_bucket_key
        ) a2 on a2.oss_bucket_key = a1.pno
    left join
        (
            select
                *
            from fle_dim.dim_fle_sys_store_da ss
            where
                ss.p_date = date_sub(`current_date`(), 1)
        ) s1 on s1.id = a1.ticket_pickup_store_id
    left join
        (
            select
                *
            from fle_dim.dim_fle_sys_store_da ss
            where
                ss.p_date = date_sub(`current_date`(), 1)
        ) s2 on s2.id = a1.ticket_delivery_store_id
    group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18
    ;