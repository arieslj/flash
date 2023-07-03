select
    total.uid_nickname
    , creat_date
    , total.brand
    , total.keyword1
    , total.keyword2
    , sum(total.amount) amount_total -- 求和
from
    (
        select
            m.uid_nickname
            ,m.creat_date
            ,m.brand
            ,m.keyword1
            ,m.keyword2
            ,ba.amount
        from
            (
                select
                    b.sku_id
                    ,b.sku_name
                    ,b.order_state
                    ,b.uid_nickname
                    ,b.amount
                    ,b.order_pay_time
                from baiying02010430 b
                where
                    b.flow_source in ('视频','橱窗') --
                    and b.order_state not in ('订单退货退款') -- 不要退款
            ) ba
        cross join
            (
                select
                    m.*
                    ,concat(m.yy,'-', if(length(m.mm) = 1, concat('0',m.mm), m.mm), '-', if(length(m.dd) = 1, concat('0',m.dd), m.dd)) creat_date
                    ,concat(ifnull(m.brand,''), '.*', ifnull(m.keyword1, ''), '.*', ifnull(m.keyword2, '') ,'.*') pipei
                from marchdata m
                where
                    m.sales_platform = '抖音' -- 选择行政表渠道抖音
                    and m.category in ('挂链') -- 选择行政表挂链
            ) m
        where
            ba.order_pay_time >= m.creat_date -- 支付时间大于等于发布时间
            and ba.order_pay_time <= date_add(m.creat_date, interval 30 day) -- 支付时间小于等于发布时间30天后
            and ba.uid_nickname like concat('%',m.uid_nickname,'%')  -- 昵称匹配
            and ba.sku_name regexp m.pipei  -- sku包含品牌、keyword1,keyword2中有的部分
        union all

        select
            m.uid_nickname
            ,m.creat_date
            ,m.brand
            ,m.keyword1
            ,m.keyword2
            ,ba.amount
        from
            (
                select
                    b.sku_id
                    ,b.sku_name
                    ,b.order_state
                    ,b.uid_nickname
                    ,b.amount
                    ,b.order_pay_time
                from aries.baiying02010430 b
                where
                    b.flow_source = '橱窗'
                    and b.order_state not in ('订单退货退款')
            ) ba
        cross join
            (
                select
                    m.*
                    ,concat(m.yy,'-', if(length(m.mm) = 1, concat('0',m.mm), m.mm), '-', if(length(m.dd) = 1, concat('0',m.dd), m.dd)) creat_date
                    ,concat(ifnull(m.brand,''), '.*', ifnull(m.keyword1, ''), '.*', ifnull(m.keyword2, '') ,'.*') pipei
                from marchdata m
                where
                    m.sales_platform = '抖音'
                    and m.category in ('橱窗')

            ) m
        where
            ba.order_pay_time >= m.creat_date
            and ba.order_pay_time <= date_add(m.creat_date, interval 30 day)
            and ba.uid_nickname like concat('%',m.uid_nickname,'%')
            and ba.sku_name regexp m.pipei
    ) total
group by
    total.uid_nickname
    , total.creat_date
    , total.brand
    , total.keyword1
    , total.keyword2