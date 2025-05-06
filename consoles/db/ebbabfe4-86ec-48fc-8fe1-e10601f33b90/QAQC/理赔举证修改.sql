with parcel_data as
(
    select
        pi2.pno
        ,pi2.returned_pno
        ,if(pi2.state=7,pi2.returned_pno ,pi2.pno) new_pno
    from my_staging.parcel_info pi2
    where
        pi2.created_at>=convert_tz(current_date()-interval 180 day,'+08:00','+00:00')
#         and pi2.pno in ('${SUBSTITUTE(SUBSTITUTE(p4,"\n",","),",","','")}')
        and pi2.pno in ('M14091M88U6AF')
)

select
    pi2.pno
    ,pi2.returned_pno
    ,lcr.status
    ,pi2.returned
    ,ifnull
        (
            case
                when pci.apology_type=0 then '进行中'
                when pci.apology_type=1 then '已超时关闭'
                when pci.apology_type=2 then '道歉后自动关闭'
                when pci.apology_type=3 then '无需处理自动关闭'
                else pci.apology_type
            end
            ,case
                when pci1.apology_type=0 then '进行中'
                    when pci1.apology_type=1 then '已超时关闭'
                    when pci1.apology_type=2 then '道歉后自动关闭'
                    when pci1.apology_type=3 then '无需处理自动关闭'
                    else pci1.apology_type
                end
         ) '道歉状态'
    ,ifnull(json_extract(replace(replace(pci.apology_evidence,'[',''),']',''),'$.url'),json_extract(replace(replace(pci1.apology_evidence,'[',''),']',''),'$.url')) url
    ,ifnull
        (
            case
                when pci.qaqc_is_receive_parcel=0 then '未处理'
                when pci.qaqc_is_receive_parcel=1 then '联系不上'
                when pci.qaqc_is_receive_parcel=2 then '已收到包裹'
                when pci.qaqc_is_receive_parcel=3 then '未收到包裹'
                when pci.qaqc_is_receive_parcel=4 then '未收到包裹,已有约定派送时间'
                else pci.qaqc_is_receive_parcel
            end
            ,case
                when pci.qaqc_is_receive_parcel=0 then '未处理'
                when pci1.qaqc_is_receive_parcel=1 then '联系不上'
                when pci1.qaqc_is_receive_parcel=2 then '已收到包裹'
                when pci1.qaqc_is_receive_parcel=3 then '未收到包裹'
                when pci1.qaqc_is_receive_parcel=4 then '未收到包裹,已有约定派送时间'
                else pci1.qaqc_is_receive_parcel
            end
        ) 'qaqc是否收到包裹'
    ,dm.url1
    ,dm.url2
    ,dd.gap_day
    ,case
        when plt.source=11 or plt1.source=11 then '超时效'
        when plt.duty_result=1 or plt1.duty_result=1 then '丢失'
        when plt.duty_result=2 or plt1.duty_result=2 then '破损'
    end '理赔类型'
    ,ifnull(plt.name,plt1.name) '责任网点-大区'
    ,if(pi2.state in (5,7,8), datediff(convert_tz(pi2.state_change_at,'+00:00','+07:00') , convert_tz(pi2.created_at,'+00:00','+07:00')),null) '整体时效天数'
from my_staging.parcel_info pi2
join parcel_data lo on lo.pno=pi2.pno
left join
    (
        select
            lcr.pno
            ,lcr.status
            ,row_number() over (partition by lcr.pno order by lcr.status_update_time desc) rk
        from my_drds_pro.lazada_callback_record lcr
        where
            lcr.status_update_time>=convert_tz(current_date()-interval 120 day,'+08:00','+00:00')
             and lcr.pno in  ('${SUBSTITUTE(SUBSTITUTE(p4,"\n",","),",","','")}')
            and lcr.status is not null

        union all


        select dm.tracking_no pno
        ,dm.action_code status
        ,row_number()over(partition by dm.tracking_no order by dm.operate_time desc) rk
        from dwm.dwd_my_tiktok_parcel_route_callback_record dm
        where dm.operate_time >=convert_tz(current_date()-interval 120 day,'+08:00','+00:00')
        and dm.tracking_no in ('${SUBSTITUTE(SUBSTITUTE(p4,"\n",","),",","','")}')

        union all

        select
            dm.pno
            ,dm.status_code status
            ,row_number()over(partition by dm.pno order by dm.status_update_time desc) rk
        from dwm.drds_my_shopee_callback_record dm
        where dm.status_update_time>=convert_tz(current_date()-interval 120 day,'+08:00','+00:00')
        and dm.pno in ('${SUBSTITUTE(SUBSTITUTE(p4,"\n",","),",","','")}')

    )lcr on lcr.pno=pi2.pno and lcr.rk=1
left join
    (
        select
            acc.pno
            ,acc.id
            ,row_number()over(partition by acc.pno order by acc.created_at asc) rk
        from my_bi.abnormal_customer_complaint acc
        where
            acc.channel_type=16
            and acc.created_at>=convert_tz(current_date()-interval 180 day,'+08:00','+00:00')
    )acc on acc.pno=pi2.returned_pno and acc.rk=1
left join my_bi.parcel_complaint_inquiry pci on pi2.returned_pno=pci.merge_column
left join
    (
        select
            acc.pno
            ,acc.id
            ,row_number()over(partition by acc.pno order by acc.created_at asc) rk
        from my_bi.abnormal_customer_complaint acc
        where
            acc.channel_type=16
            and acc.created_at>=convert_tz(current_date()-interval 180 day,'+08:00','+00:00')
    )acc1 on acc1.pno=pi2.pno and acc1.rk=1
left join my_bi.parcel_complaint_inquiry pci1 on pi2.pno=pci1.merge_column
left join
    (
        select
            dd.pno
            ,concat('https://fex-my-asset-pro.oss-ap-southeast-3.aliyuncs.com/',get_json_object(json_extract(json_extract(dm.extra_value,'$.deliveryImageAiScore'),'$[0]'),'$.objectKey')) url1
            ,concat('https://fex-my-asset-pro.oss-ap-southeast-3.aliyuncs.com/',get_json_object(json_extract(json_extract(dm.extra_value,'$.deliveryImageAiScore'),'$[1]'),'$.objectKey')) url2
        from dwm.drds_my_parcel_route_extra dm
        join parcel_data dd on dd.new_pno=dm.pno
        where
            dm.created_at>=convert_tz(current_date()-interval 180 day,'+08:00','+00:00')
            and dm.route_action='DELIVERY_CONFIRM'
    )dm on dm.pno=pi2.pno
left join
    (
        select
            dd.pno
            ,max(gap_time) gap_day
        from
            (
                select
                    dd.pno
                    ,date_diff(convert_tz(dd.status_update_time,'+00:00','+08:00'),convert_tz(dd.lag1,'+00:00','+08:00')) gap_time
                from
                    (
                        select
                            dm.pno
                            ,dm.status_update_time
                            ,lag(dm.status_update_time,1)over(partition by dm.pno order by dm.status_update_time ) lag1
                        from dwm.drds_my_shopee_callback_record dm
                        where dm.status_update_time >=convert_tz(current_date()-interval 180 day,'+08:00','+00:00')
                        and dm.pno in ('${SUBSTITUTE(SUBSTITUTE(p4,"\n",","),",","','")}')
                    )dd
            )dd
        group  by 1
    )dd on dd.pno=pi2.pno
left join
    (
        select
            plt.pno
            ,plt.source
            ,plr.name
            ,plt.duty_result
            ,row_number()over(partition by plt.pno order by plt.created_at desc) rk
        from my_bi.parcel_lose_task plt
        left join
            (
                select
                    plr.lose_task_id
                    ,group_concat(distinct concat(ss.name, '-', ifnull(smr.name, '无'))) name
                from my_bi.parcel_lose_responsible plr
                join my_staging.sys_store ss on ss.id=plr.store_id
                left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
                where
                    plr.created_at>current_date()-interval 180 day
                group by 1
            )plr on plr.lose_task_id=plt.id
        where
            plt.created_at>current_date()-interval 180 day
            and (plt.source=11 or plt.duty_result in (1,2))
          --  and plt.pno = 'M11051NZH1PAG'
    )plt on plt.pno=pi2.pno and plt.rk=1
left join
    (
        select
            plt.pno
            ,plt.source
            ,plr.name
            ,plt.duty_result
            ,row_number()over(partition by plt.pno order by plt.created_at desc) rk
        from my_bi.parcel_lose_task plt
        left join
            (
                select
                    plr.lose_task_id
                    ,group_concat(distinct concat(ss.name, '-', ifnull(smr.name, '无'))) name
                from my_bi.parcel_lose_responsible plr
                join my_staging.sys_store ss on ss.id=plr.store_id
                left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
                where
                    plr.created_at>current_date()-interval 180 day
                group by 1
            )plr on plr.lose_task_id=plt.id
        where
            plt.created_at>current_date()-interval 180 day
            and (plt.source=11
            or plt.duty_result in (1,2))
    )plt1 on plt1.pno=lo.returned_pno and plt1.rk=1



where pi2.created_at>=convert_tz(current_date()-interval 180 day,'+08:00','+00:00')
and pi2.pno in ('${SUBSTITUTE(SUBSTITUTE(p4,"\n",","),",","','")}')



