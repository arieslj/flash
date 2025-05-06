select
    a1.pno
    -- ,a1.client_id 客户ID
    ,a1.ticket_pickup_id 揽件任务ID
    ,a1.src_name 寄件人姓名
    ,a1.src_phone 寄件人电话
    ,a1.src_detail_address 寄件人地址
    ,ss.name 揽件任务分配网点
    ,case a1.state
        when 0	then'已确认'
        when 1	then'待揽件'
        when 2	then'已揽收'
        when 3	then'已取消(已终止)'
        when 4	then'已删除(已作废)'
        when 5	then'预下单'
        when 6	then'被标记多次，限制揽收'
    end as 订单状态
from
    (
        select
            a.*
        from
            (
                select
                    oi.pno
                    ,tpor.ticket_pickup_id
                    ,oi.src_name
                    ,oi.src_phone
                    ,oi.src_detail_address
                    ,oi.state
                    ,row_number() over (partition by oi.pno order by tpor.created_at desc) rk
                from fle_staging.order_info oi
               -- join tmpale.tmp_th_pno_lj_0426 t on t.pno = oi.pno
                left join fle_staging.ticket_pickup_order_relation tpor on tpor.order_id = oi.id
                where
                    oi.pno in ('TH01105JPFJY6F','TH13095JGVKD9D','TH61015JM8ZH6M','TH02055J181Q8B','TH24045JF24T8D','TH24045GPVGR8D','TH24045GW1QN0D','TH24045H2A0D9D','TH24045GVTGU6D','TH24045HKHEV7D','TH02065JC75U8A1','TH02015HRMAM4M0','TH02045JE6XJ3G','TH24045HBAKJ8D','TH24045JPAPF7D','TH15065HG30M9P','TH24045HH42N4D')
            ) a
        where
            a.rk = 1
    ) a1
left join fle_staging.ticket_pickup tp on tp.id = a1.ticket_pickup_id
left join fle_staging.sys_store ss on ss.id = tp.store_id