select
    m.uid_nickname
    ,m.creat_date
    ,m.brand
    ,sum(t1.pay_amount) total_amount
from
    (
        select
            t.sku_title
            ,t.pay_amount
            ,t.tuiguang_bit_name
            ,t.pay_time
        from aries.taobao01010430 t
        where
            t.order_state not in ('已失效')
    ) t1
cross join
    (
        select
            m.uid_nickname
            ,m.brand
            ,concat(m.yy,'-', if(length(m.mm) = 1, concat('0',m.mm), m.mm), '-', if(length(m.dd) = 1, concat('0',m.dd), m.dd)) creat_date
        from aries.marchdata m
        where
            m.sales_platform = '淘宝'
    ) m
where
    t1.pay_time >= m.creat_date
    and t1.pay_time <= date_add(m.creat_date, interval 30 day) -- 往后看30天
    and t1.sku_title like concat('%',m.brand,'%') -- 品牌匹配
    and t1.tuiguang_bit_name like concat('%',m.uid_nickname,'%') -- 昵称匹配
group by 1,2,3