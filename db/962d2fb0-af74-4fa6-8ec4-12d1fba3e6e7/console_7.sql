select
    pi.pno
    ,cast(pi.cod_amount as int)/100 cod
    ,`if`(pi.client_id in ('AA0139','AA0080','AA0050','AA0121','AA0051'), cast(oi.insure_declare_value as int)/100, cast(oi.cogs_amount as int)/100) cogs
from
    (
        select
            pi.pno
            ,pi.cod_amount
            ,pi.client_id
        from fle_dwd.dwd_fle_parcel_info_di pi
        where
            pi.p_date >= '2023-01-01'
            and pi.src_phone = '09610059387'
            or pi.dst_phone = '09610059387'
    ) pi
left join
    (
        select
             oi.pno
            ,oi.cogs_amount
            ,oi.insure_declare_value
        from fle_dwd.dwd_fle_order_info_di oi
        where
            oi.p_date >= '2022-12-01'
            and oi.src_phone = '09610059387'
            or oi.dst_phone = '09610059387'
    ) oi on oi.pno = pi.pno