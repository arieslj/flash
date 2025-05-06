select
    fn.job_name
    ,fn.id

#     ,count(distinct fn.staff_info_id) staff_count
    ,sum(if(month(fn.created_at) = 5, fn.kilo_km, 0) * if(month(fn.created_at) = 5, fn.price, 0)) / count(distinct if(month(fn.created_at) = 5, fn.staff_info_id, null))  5月人均
    ,sum(if(month(fn.created_at) = 6, fn.kilo_km, 0) * if(month(fn.created_at) = 6, fn.price, 0)) / count(distinct if(month(fn.created_at) = 6, fn.staff_info_id, null))  6月人均
    ,sum(if(month(fn.created_at) = 7, fn.kilo_km, 0) * if(month(fn.created_at) = 7, fn.price, 0)) / count(distinct if(month(fn.created_at) = 7, fn.staff_info_id, null))  7月人均
    ,sum(if(month(fn.created_at) = 8, fn.kilo_km, 0) * if(month(fn.created_at) = 8, fn.price, 0)) / count(distinct if(month(fn.created_at) = 8, fn.staff_info_id, null))  8月人均
    ,sum(if(month(fn.created_at) = 9, fn.kilo_km, 0) * if(month(fn.created_at) = 9, fn.price, 0)) / count(distinct if(month(fn.created_at) = 9, fn.staff_info_id, null))  9月人均
    ,sum(if(month(fn.created_at) = 10, fn.kilo_km, 0) * if(month(fn.created_at) = 10, fn.price, 0)) / count(distinct if(month(fn.created_at) = 10, fn.staff_info_id, null))  10月人均
from
    (
         select
            smr.staff_info_id
            ,smr.created_at
            ,hjt.job_name
            ,hjt.id
            ,smr.mileage_date
            ,smr.end_kilometres
            ,(smr.end_kilometres - smr.start_kilometres)/1000 kilo_km
            ,smr.start_kilometres
            ,if(smr.data_price = 0, a.oil_price, smr.data_price)/100 price
        from my_backyard.staff_mileage_record smr
        left join
            (
                select
                    smr.staff_info_id
                    ,vop.oil_price
                    ,row_number() over (partition by smr.staff_info_id order by vop.effective_date desc) rk
                from
                    (
                        select
                            smr.staff_info_id
                        from my_backyard.staff_mileage_record smr
                        where
                            smr.card_status = 1
                            and smr.data_price = 0
                        group by 1
                    ) smr
                left join my_backyard.vehicle_info vi on vi.uid = smr.staff_info_id
                left join my_backyard.vehicle_oil_price vop on vop.vehicle_category_item = vi.vehicle_type_category and vop.is_deleted = 0
            ) a on smr.staff_info_id = a.staff_info_id and a.rk = 1
        left join my_bi.hr_staff_transfer hst on hst.staff_info_id = smr.staff_info_id and smr.mileage_date = hst.stat_date
        left join my_bi.hr_job_title hjt on hjt.id = hst.job_title
        where
            smr.created_at >= '2023-05-01'
            and smr.card_status = 1
            -- and if(smr.data_price = 0, a.oil_price, smr.data_price)/100 is null
    ) fn
group by 1,2

;

select
    bi.p_month 月份
    ,bi.bike_count bike转岗人数
    ,m.staff_count 月初bike人数
    ,bi.bike_count/m.staff_count 转岗占比
from
    (
         select
            month(a.stat_date) p_month
            ,count(distinct a.staff_info_id) bike_count
        from
            (
                select
                    hst.staff_info_id
                    ,hst.job_title
                    ,hst.stat_date
                    ,lead(hst.job_title,1) over (partition by hst.staff_info_id order by hst.stat_date)  job_titl2
                from my_bi.hr_staff_transfer hst
                where
                    hst.stat_date >= '2023-07-01'
            ) a
        where
            a.job_title = 13
            and a.job_titl2 in (110,1199,1413)
        group by 1
    ) bi
left join
    (
        select
            '7' p_month
            ,count(hst2.staff_info_id) staff_count
        from my_bi.hr_staff_transfer hst2
        where
            hst2.stat_date = '2023-07-01'
            and hst2.job_title in (13)

        union all

        select
            '8' p_month
            ,count(hst2.staff_info_id) staff_count
        from my_bi.hr_staff_transfer hst2
        where
            hst2.stat_date = '2023-08-01'
            and hst2.job_title in (13)

          union all

        select
            '9' p_month
            ,count(hst2.staff_info_id) staff_count
        from my_bi.hr_staff_transfer hst2
        where
            hst2.stat_date = '2023-09-01'
            and hst2.job_title in (13)

        union all

        select
            '10' p_month
            ,count(hst2.staff_info_id) staff_count
        from my_bi.hr_staff_transfer hst2
        where
            hst2.stat_date = '2023-10-01'
            and hst2.job_title in (13)
    )  m on m.p_month = bi.p_month