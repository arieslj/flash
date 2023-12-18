select
    m.uid_nickname
    ,sum(ba.amount)
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
            b.flow_source not in ('直播')
            and b.order_state not in ('订单退货退款')
    ) ba
cross join
    (
        select
            *
            ,concat(m.yy, if(length(m.mm) = 1, concat('0',m.mm), m.mm), if(length(m.dd) = 1, concat('0',m.dd), m.dd)) creat_date
        from marchdata m
        where
            m.sales_platform = '抖音'
    ) m
where
    ba.order_pay_time >= m.creat_date
    and ba.order_pay_time <= date_add(m.creat_date, interval 30 day)
    and  if(m.keyword2 is null ,
        ba.sku_name like concat('%',m.brand,'%') and ba.sku_name like concat('%',m.keyword1,'%')
        , ba.sku_name like concat('%',m.brand,'%') and ba.sku_name like concat('%',m.keyword1,'%') and ba.sku_name like concat('%',m.keyword2,'%'))
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
            *
            ,concat(m.yy, if(length(m.mm) = 1, concat('0',m.mm), m.mm), if(length(m.dd) = 1, concat('0',m.dd), m.dd)) creat_date
        from marchdata m
        where
            m.sales_platform = '抖音';
;-- -. . -..- - / . -. - .-. -.--
select
            *
            ,concat(m.yy, if(length(m.mm) = 1, '-',concat('0',m.mm), m.mm), '-', if(length(m.dd) = 1, concat('0',m.dd), m.dd)) creat_date
        from marchdata m
        where
            m.sales_platform = '抖音';
;-- -. . -..- - / . -. - .-. -.--
select
            *
            ,concat(m.yy,'-', if(length(m.mm) = 1, concat('0',m.mm), m.mm), '-', if(length(m.dd) = 1, concat('0',m.dd), m.dd)) creat_date
        from marchdata m
        where
            m.sales_platform = '抖音';
;-- -. . -..- - / . -. - .-. -.--
select
    m.uid_nickname
    ,sum(ba.amount)
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
            b.flow_source not in ('直播')
            and b.order_state not in ('订单退货退款')
    ) ba
cross join
    (
        select
            *
            ,concat(m.yy,'-', if(length(m.mm) = 1, concat('0',m.mm), m.mm), '-', if(length(m.dd) = 1, concat('0',m.dd), m.dd)) creat_date
        from marchdata m
        where
            m.sales_platform = '抖音'
    ) m
where
    ba.order_pay_time >= m.creat_date
    and ba.order_pay_time <= date_add(m.creat_date, interval 30 day)
    and  if(m.keyword2 is null ,
        ba.sku_name like concat('%',m.brand,'%') and ba.sku_name like concat('%',m.keyword1,'%')
        , ba.sku_name like concat('%',m.brand,'%') and ba.sku_name like concat('%',m.keyword1,'%') and ba.sku_name like concat('%',m.keyword2,'%'))
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    m.uid_nickname
    ,sum(ba.amount)
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
            b.flow_source not in ('直播')
            and b.order_state not in ('订单退货退款')
    ) ba
cross join
    (
        select
            *
            ,concat(m.yy,'-', if(length(m.mm) = 1, concat('0',m.mm), m.mm), '-', if(length(m.dd) = 1, concat('0',m.dd), m.dd)) creat_date
        from marchdata m
        where
            m.sales_platform = '抖音'
    ) m
where
    ba.order_pay_time >= m.creat_date
    and ba.order_pay_time <= date_add(m.creat_date, interval 30 day)
    and  if(m.keyword2 is null ,
        ba.sku_name like concat('%',m.brand,'%') and ba.sku_name like concat('%',m.keyword1,'%') and ba.sku_name like concat('%',m.uid_nickname,'%')
        , ba.sku_name like concat('%',m.brand,'%') and ba.sku_name like concat('%',m.keyword1,'%') and ba.sku_name like concat('%',m.keyword2,'%') and ba.sku_name like concat('%',m.uid_nickname,'%') )
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    m.uid_nickname
    ,sum(ba.amount)
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
            b.flow_source not in ('直播')
            and b.order_state not in ('订单退货退款')
    ) ba
cross join
    (
        select
            *
            ,concat(m.yy,'-', if(length(m.mm) = 1, concat('0',m.mm), m.mm), '-', if(length(m.dd) = 1, concat('0',m.dd), m.dd)) creat_date
        from marchdata m
        where
            m.sales_platform = '抖音'
    ) m
where
    ba.order_pay_time >= m.creat_date
    and ba.order_pay_time <= date_add(m.creat_date, interval 30 day)
    and ba.sku_name like concat('%',m.brand,'%') and ba.sku_name like concat('%',m.keyword1,'%') and ba.sku_name like concat('%',m.uid_nickname,'%')
#     and  if(m.keyword2 is null ,
#         ba.sku_name like concat('%',m.brand,'%') and ba.sku_name like concat('%',m.keyword1,'%') and ba.sku_name like concat('%',m.uid_nickname,'%')
#         , ba.sku_name like concat('%',m.brand,'%') and ba.sku_name like concat('%',m.keyword1,'%') and ba.sku_name like concat('%',m.keyword2,'%') and ba.sku_name like concat('%',m.uid_nickname,'%') )
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    m.uid_nickname
    ,sum(ba.amount)
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
            b.flow_source not in ('直播')
            and b.order_state not in ('订单退货退款')
    ) ba
cross join
    (
        select
            *
            ,concat(m.yy,'-', if(length(m.mm) = 1, concat('0',m.mm), m.mm), '-', if(length(m.dd) = 1, concat('0',m.dd), m.dd)) creat_date
        from marchdata m
        where
            m.sales_platform = '抖音'
    ) m
where
    ba.order_pay_time >= m.creat_date
    and ba.order_pay_time <= date_add(m.creat_date, interval 30 day)
    and ba.sku_name like concat('%',m.brand,'%') and ba.sku_name like concat('%',m.keyword1,'%') /*and ba.sku_name like concat('%',m.uid_nickname,'%')*/
#     and  if(m.keyword2 is null ,
#         ba.sku_name like concat('%',m.brand,'%') and ba.sku_name like concat('%',m.keyword1,'%') and ba.sku_name like concat('%',m.uid_nickname,'%')
#         , ba.sku_name like concat('%',m.brand,'%') and ba.sku_name like concat('%',m.keyword1,'%') and ba.sku_name like concat('%',m.keyword2,'%') and ba.sku_name like concat('%',m.uid_nickname,'%') )
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    m.uid_nickname
    ,sum(ba.amount)
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
            b.flow_source not in ('直播')
            and b.order_state not in ('订单退货退款')
    ) ba
cross join
    (
        select
            *
            ,concat(m.yy,'-', if(length(m.mm) = 1, concat('0',m.mm), m.mm), '-', if(length(m.dd) = 1, concat('0',m.dd), m.dd)) creat_date
        from marchdata m
        where
            m.sales_platform = '抖音'
    ) m
where
    ba.order_pay_time >= m.creat_date
    and ba.order_pay_time <= date_add(m.creat_date, interval 30 day)
    and ba.sku_name like concat('%',m.brand,'%') and ba.sku_name like concat('%',m.keyword1,'%') and ba.uid_nickname like concat('%',m.uid_nickname,'%')
#     and  if(m.keyword2 is null ,
#         ba.sku_name like concat('%',m.brand,'%') and ba.sku_name like concat('%',m.keyword1,'%') and ba.sku_name like concat('%',m.uid_nickname,'%')
#         , ba.sku_name like concat('%',m.brand,'%') and ba.sku_name like concat('%',m.keyword1,'%') and ba.sku_name like concat('%',m.keyword2,'%') and ba.sku_name like concat('%',m.uid_nickname,'%') )
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    m.uid_nickname
    ,sum(ba.amount)
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
            b.flow_source not in ('直播')
            and b.order_state not in ('订单退货退款')
    ) ba
cross join
    (
        select
            *
            ,concat(m.yy,'-', if(length(m.mm) = 1, concat('0',m.mm), m.mm), '-', if(length(m.dd) = 1, concat('0',m.dd), m.dd)) creat_date
        from marchdata m
        where
            m.sales_platform = '抖音'
    ) m
where
    ba.order_pay_time >= m.creat_date
    and ba.order_pay_time <= date_add(m.creat_date, interval 30 day)
#     and ba.sku_name like concat('%',m.brand,'%') and ba.sku_name like concat('%',m.keyword1,'%') and ba.uid_nickname like concat('%',m.uid_nickname,'%')
    and  if(m.keyword2 is null ,
        ba.sku_name like concat('%',m.brand,'%') and ba.sku_name like concat('%',m.keyword1,'%') and ba.uid_nickname like concat('%',m.uid_nickname,'%')
        , ba.sku_name like concat('%',m.brand,'%') and ba.sku_name like concat('%',m.keyword1,'%') and ba.sku_name like concat('%',m.keyword2,'%') and ba.uid_nickname like concat('%',m.uid_nickname,'%') )
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    m.uid_nickname
    ,m.creat_date
    ,m.brand
    ,m.keyword1
    ,m.keyword2
    ,sum(ba.amount)
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
            b.flow_source not in ('直播')
            and b.order_state not in ('订单退货退款')
    ) ba
cross join
    (
        select
            *
            ,concat(m.yy,'-', if(length(m.mm) = 1, concat('0',m.mm), m.mm), '-', if(length(m.dd) = 1, concat('0',m.dd), m.dd)) creat_date
        from marchdata m
        where
            m.sales_platform = '抖音'
    ) m
where
    ba.order_pay_time >= m.creat_date
    and ba.order_pay_time <= date_add(m.creat_date, interval 30 day)
#     and ba.sku_name like concat('%',m.brand,'%') and ba.sku_name like concat('%',m.keyword1,'%') and ba.uid_nickname like concat('%',m.uid_nickname,'%')
    and  if(m.keyword2 is null ,
        ba.sku_name like concat('%',m.brand,'%') and ba.sku_name like concat('%',m.keyword1,'%') and ba.uid_nickname like concat('%',m.uid_nickname,'%')
        , ba.sku_name like concat('%',m.brand,'%') and ba.sku_name like concat('%',m.keyword1,'%') and ba.sku_name like concat('%',m.keyword2,'%') and ba.uid_nickname like concat('%',m.uid_nickname,'%') )
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    m.uid_nickname
    ,m.creat_date
    ,m.brand
    ,m.keyword1
    ,m.keyword2
    ,sum(ba.amount)
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
            b.flow_source not in ('直播')
            and b.order_state not in ('订单退货退款')
    ) ba
cross join
    (
        select
            *
            ,concat(m.yy,'-', if(length(m.mm) = 1, concat('0',m.mm), m.mm), '-', if(length(m.dd) = 1, concat('0',m.dd), m.dd)) creat_date
        from marchdata m
        where
            m.sales_platform = '抖音'
    ) m
where
    ba.order_pay_time >= m.creat_date
    and ba.order_pay_time <= date_add(m.creat_date, interval 30 day)
#     and ba.sku_name like concat('%',m.brand,'%') and ba.sku_name like concat('%',m.keyword1,'%') and ba.uid_nickname like concat('%',m.uid_nickname,'%')
    and  if(m.keyword2 is null ,
        ba.sku_name like concat('%',m.brand,'%') and ba.sku_name like concat('%',m.keyword1,'%') and ba.uid_nickname like concat('%',m.uid_nickname,'%')
        , ba.sku_name like concat('%',m.brand,'%') and ba.sku_name like concat('%',m.keyword1,'%') and ba.sku_name like concat('%',m.keyword2,'%') and ba.uid_nickname like concat('%',m.uid_nickname,'%') )
group by 1,2,3,4,5;
;-- -. . -..- - / . -. - .-. -.--
select
    total.uid_nickname
    , creat_date
    , total.brand
    , total.keyword1
    , total.keyword2
    , sum(total.amount) amount_total
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
                from aries.baiying02010430 b
                where
                    b.flow_source not in ('直播')
                    and b.order_state not in ('订单退货退款')
            ) ba
        cross join
            (
                select
                    m.*
                    ,concat(m.yy,'-', if(length(m.mm) = 1, concat('0',m.mm), m.mm), '-', if(length(m.dd) = 1, concat('0',m.dd), m.dd)) creat_date
                from marchdata m
                where
                    m.sales_platform = '抖音'
                    and m.category in ('挂链')
            ) m
        where
            ba.order_pay_time >= m.creat_date
            and ba.order_pay_time <= date_add(m.creat_date, interval 30 day)
        #     and ba.sku_name like concat('%',m.brand,'%') and ba.sku_name like concat('%',m.keyword1,'%') and ba.uid_nickname like concat('%',m.uid_nickname,'%')
            and  if(m.keyword2 is null ,
                ba.sku_name like concat('%',m.brand,'%') and ba.sku_name like concat('%',m.keyword1,'%') and ba.uid_nickname like concat('%',m.uid_nickname,'%')
                , ba.sku_name like concat('%',m.brand,'%') and ba.sku_name like concat('%',m.keyword1,'%') and ba.sku_name like concat('%',m.keyword2,'%') and ba.uid_nickname like concat('%',m.uid_nickname,'%') )

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
                from marchdata m
                where
                    m.sales_platform = '抖音'
                    and m.category in ('橱窗')
            ) m
        where
            ba.order_pay_time >= m.creat_date
            and ba.order_pay_time <= date_add(m.creat_date, interval 30 day)
        #     and ba.sku_name like concat('%',m.brand,'%') and ba.sku_name like concat('%',m.keyword1,'%') and ba.uid_nickname like concat('%',m.uid_nickname,'%')
            and  if(m.keyword2 is null ,
                ba.sku_name like concat('%',m.brand,'%') and ba.sku_name like concat('%',m.keyword1,'%') and ba.uid_nickname like concat('%',m.uid_nickname,'%')
                , ba.sku_name like concat('%',m.brand,'%') and ba.sku_name like concat('%',m.keyword1,'%') and ba.sku_name like concat('%',m.keyword2,'%') and ba.uid_nickname like concat('%',m.uid_nickname,'%') )
    ) total
group by 1,2,3,4,5;
;-- -. . -..- - / . -. - .-. -.--
select
    total.uid_nickname
    , creat_date
    , total.brand
    , total.keyword1
    , total.keyword2
    , sum(total.amount) amount_total
from
    (
        select
            m.uid_nickname
            ,m.creat_date
            ,m.brand
            ,m.keyword1
            ,m.keyword2
            ,ba.amount
            ,if(locate(ba.sku_name, m.brand) > 0, 1, 0 ) brand_se
            ,if(locate(ba.sku_name, m.keyword1) > 0, 1, 0 ) keyword1_se
            ,if(locate(ba.sku_name, m.keyword2) > 0, 1, 0 ) keyword2_se
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
                    b.flow_source not in ('直播')
                    and b.order_state not in ('订单退货退款')
            ) ba
        cross join
            (
                select
                    m.*
                    ,concat(m.yy,'-', if(length(m.mm) = 1, concat('0',m.mm), m.mm), '-', if(length(m.dd) = 1, concat('0',m.dd), m.dd)) creat_date
                from marchdata m
                where
                    m.sales_platform = '抖音'
                    and m.category in ('挂链')
            ) m
        where
            ba.order_pay_time >= m.creat_date
            and ba.order_pay_time <= date_add(m.creat_date, interval 30 day)

        union all

        select
            m.uid_nickname
            ,m.creat_date
            ,m.brand
            ,m.keyword1
            ,m.keyword2
            ,ba.amount
            ,if(locate(ba.sku_name, m.brand) > 0, 1, 0 ) brand_se
            ,if(locate(ba.sku_name, m.keyword1) > 0, 1, 0 ) keyword1_se
            ,if(locate(ba.sku_name, m.keyword2) > 0, 1, 0 ) keyword2_se
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
                from marchdata m
                where
                    m.sales_platform = '抖音'
                    and m.category in ('橱窗')
            ) m
        where
            ba.order_pay_time >= m.creat_date
            and ba.order_pay_time <= date_add(m.creat_date, interval 30 day)
    ) total
where
    total.brand_se + total.keyword1_se + total.keyword2_se >= 1
group by 1,2,3,4,5;
;-- -. . -..- - / . -. - .-. -.--
select
            m.uid_nickname
            ,m.creat_date
            ,m.brand
            ,m.keyword1
            ,m.keyword2
            ,ba.amount
            ,if(locate(ba.sku_name, m.brand) > 0, 1, 0 ) brand_se
            ,if(locate(ba.sku_name, m.keyword1) > 0, 1, 0 ) keyword1_se
            ,if(locate(ba.sku_name, m.keyword2) > 0, 1, 0 ) keyword2_se
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
                    b.flow_source not in ('直播')
                    and b.order_state not in ('订单退货退款')
            ) ba
        cross join
            (
                select
                    m.*
                    ,concat(m.yy,'-', if(length(m.mm) = 1, concat('0',m.mm), m.mm), '-', if(length(m.dd) = 1, concat('0',m.dd), m.dd)) creat_date
                from marchdata m
                where
                    m.sales_platform = '抖音'
                    and m.category in ('挂链')
            ) m
        where
            ba.order_pay_time >= m.creat_date
            and ba.order_pay_time <= date_add(m.creat_date, interval 30 day);
;-- -. . -..- - / . -. - .-. -.--
select
    total.uid_nickname
    , creat_date
    , total.brand
    , total.keyword1
    , total.keyword2
    , sum(total.amount) amount_total
from
    (
        select
            m.uid_nickname
            ,m.creat_date
            ,m.brand
            ,m.keyword1
            ,m.keyword2
            ,ba.amount
            ,if(locate(m.brand, ba.sku_name) > 0, 1, 0 ) brand_se
            ,if(locate(m.keyword1, ba.sku_name) > 0, 1, 0 ) keyword1_se
            ,if(locate(m.keyword2, ba.sku_name) > 0, 1, 0 ) keyword2_se
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
                    b.flow_source not in ('直播')
                    and b.order_state not in ('订单退货退款')
            ) ba
        cross join
            (
                select
                    m.*
                    ,concat(m.yy,'-', if(length(m.mm) = 1, concat('0',m.mm), m.mm), '-', if(length(m.dd) = 1, concat('0',m.dd), m.dd)) creat_date
                from marchdata m
                where
                    m.sales_platform = '抖音'
                    and m.category in ('挂链')
            ) m
        where
            ba.order_pay_time >= m.creat_date
            and ba.order_pay_time <= date_add(m.creat_date, interval 30 day)
            and ba.uid_nickname like concat('%',m.uid_nickname,'%')
        union all

        select
            m.uid_nickname
            ,m.creat_date
            ,m.brand
            ,m.keyword1
            ,m.keyword2
            ,ba.amount
            ,if(locate(m.brand, ba.sku_name) > 0, 1, 0 ) brand_se
            ,if(locate(m.keyword1, ba.sku_name) > 0, 1, 0 ) keyword1_se
            ,if(locate(m.keyword2, ba.sku_name) > 0, 1, 0 ) keyword2_se
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
                from marchdata m
                where
                    m.sales_platform = '抖音'
                    and m.category in ('橱窗')
            ) m
        where
            ba.order_pay_time >= m.creat_date
            and ba.order_pay_time <= date_add(m.creat_date, interval 30 day)
            and ba.uid_nickname like concat('%',m.uid_nickname,'%')
    ) total
where
    total.brand_se + total.keyword1_se + total.keyword2_se >= 1
group by 1,2,3,4,5;
;-- -. . -..- - / . -. - .-. -.--
select
                    m.*
                    ,concat(m.yy,'-', if(length(m.mm) = 1, concat('0',m.mm), m.mm), '-', if(length(m.dd) = 1, concat('0',m.dd), m.dd)) creat_date
                    ,concat(ifnull(m.brand,''), '.*', ifnull(m.keyword1, ''), '.*', ifnull(m.keyword2, '') ,'.*') pipei
                from marchdata m
                where
                    m.sales_platform = '抖音'
                    and m.category in ('橱窗');
;-- -. . -..- - / . -. - .-. -.--
select
    total.uid_nickname
    , creat_date
    , total.brand
    , total.keyword1
    , total.keyword2
    , sum(total.amount) amount_total
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
                from aries.baiying02010430 b
                where
                    b.flow_source not in ('直播')
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
                    and m.category in ('挂链')
            ) m
        where
            ba.order_pay_time >= m.creat_date
            and ba.order_pay_time <= date_add(m.creat_date, interval 30 day)
            and ba.uid_nickname like concat('%',m.uid_nickname,'%')
            and ba.sku_name regexp m.pipei
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

group by 1,2,3,4,5;
;-- -. . -..- - / . -. - .-. -.--
select
    total.uid_nickname
    , creat_date
    , total.brand
    , total.keyword1
    , total.keyword2
    , round(sum(total.amount),2) amount_total
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
                from aries.baiying02010430 b
                where
                    b.flow_source not in ('直播')
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
                    and m.category in ('挂链')
            ) m
        where
            ba.order_pay_time >= m.creat_date
            and ba.order_pay_time <= date_add(m.creat_date, interval 30 day)
            and ba.uid_nickname like concat('%',m.uid_nickname,'%')
            and ba.sku_name regexp m.pipei
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

group by 1,2,3,4,5;
;-- -. . -..- - / . -. - .-. -.--
select
    total.uid_nickname
    , creat_date
    , total.brand
    , total.keyword1
    , total.keyword2
    , round(sum(total.amount),2) amount_total
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
                from aries.baiying02010430 b
                where
                    b.flow_source in ('视频','橱窗')
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
                    and m.category in ('挂链')
            ) m
        where
            ba.order_pay_time >= m.creat_date
            and ba.order_pay_time <= date_add(m.creat_date, interval 30 day)
            and ba.uid_nickname like concat('%',m.uid_nickname,'%')
            and ba.sku_name regexp m.pipei
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

group by 1,2,3,4,5;
;-- -. . -..- - / . -. - .-. -.--
select
    total.uid_nickname
    , creat_date
    , total.brand
    , total.keyword1
    , total.keyword2
    , round(sum(total.amount),2) amount_total
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
                    b.flow_source in ('视频','橱窗')
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
                    and m.category in ('挂链')
            ) m
        where
            ba.order_pay_time >= m.creat_date
            and ba.order_pay_time <= date_add(m.creat_date, interval 30 day)
            and ba.uid_nickname like concat('%',m.uid_nickname,'%')
            and ba.sku_name regexp m.pipei
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
    , creat_date
    , total.brand
    , total.keyword1
    , total.keyword2;
;-- -. . -..- - / . -. - .-. -.--
select
    total.uid_nickname
    , creat_date
    , total.brand
    , total.keyword1
    , total.keyword2
    , round(sum(total.amount),2) amount_total
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
                    b.flow_source in ('视频','橱窗')
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
                    and m.category in ('挂链')
            ) m
        where
            ba.order_pay_time >= m.creat_date
            and ba.order_pay_time <= date_add(m.creat_date, interval 30 day)
            and ba.uid_nickname like concat('%',m.uid_nickname,'%')
            and ba.sku_name regexp m.pipei
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
    , total.keyword2;
;-- -. . -..- - / . -. - .-. -.--
select
    total.uid_nickname
    , creat_date
    , total.brand
    , total.keyword1
    , total.keyword2
    , round(sum(total.amount),2) amount_total
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
                    b.flow_source in ('视频','橱窗')
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
                    and m.category in ('挂链')
            ) m
        where
            ba.order_pay_time >= m.creat_date
            and ba.order_pay_time <= date_add(m.creat_date, interval 30 day)
            and ba.uid_nickname like concat('%',m.uid_nickname,'%')
            and ba.sku_name regexp m.pipei
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
    , total.keyword2;
;-- -. . -..- - / . -. - .-. -.--
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
group by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
select
    *
    ,row_number() over (order by r.uid_nickname) rk
from aries..result_2 r;
;-- -. . -..- - / . -. - .-. -.--
select
    *
    ,row_number() over (order by r.uid_nickname) rk
from aries.result_2 r;