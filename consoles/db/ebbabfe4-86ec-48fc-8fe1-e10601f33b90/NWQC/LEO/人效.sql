-- 需求1
select
    a.p_month 月份
    ,case a.source
        when 1 then 'A-问题件-丢失'
        when 2 then 'B-记录本-丢失'
        when 3 then 'C-包裹状态未更新'
        when 4 then 'D-问题件-破损/短少'
        when 5 then 'E-记录本-索赔-丢失'
        when 6 then 'F-记录本-索赔-破损/短少'
        when 7 then 'G-记录本-索赔-其他'
        when 8 then 'H-包裹状态未更新-IPC计数'
        when 9 then 'I-问题件-外包装破损险'
        when 10 then 'J-问题记录本-外包装破损险'
        when 11 then 'K-超时效包裹'
        when 12 then 'L-高度疑似丢失'
    end 问题来源渠道
    ,count(a.id) 总量
    ,count(if(a.state in (5,6) and a.updated_at < a.sla, a.id, null)) 时效内处理量
    ,count(if(a.state in (5,6) and a.updated_at < a.sla, a.id, null)) / count(a.id) 达成率
from
    (
        select
            plt.id
            ,plt.pno
            ,plt.updated_at
            ,plt.source
            ,plt.created_at
            ,substr(plt.created_at, 1, 7) p_month
            ,case
                when plt.source = 1 then date(date_add(plt.created_at, interval 7 day))
                when plt.source = 2 then date(date_add(plt.created_at, interval 4 day))
                when plt.source = 4 then date(date_add(plt.created_at, interval 4 day))
                when plt.source = 5 then date(date_add(plt.created_at, interval 4 day))
                when plt.source = 6 then date(date_add(plt.created_at, interval 4 day))
                when plt.source = 7 then date(date_add(plt.created_at, interval 4 day))
                when plt.source = 8 then date(date_add(plt.created_at, interval 4 day))
                when plt.source = 12 then date(date_add(plt.created_at, interval 3 day))
            end sla
            ,plt.state
        from my_bi.parcel_lose_task plt
        where
            plt.created_at >= date_format(date_sub(curdate(), interval 1 month), '%y-%m-01')
            and plt.created_at < date_format(curdate(), '%Y-%m-01')
            and plt.source in (1,2,4,5,6,7,8,12)
    ) a
group by 1,2


;


select
    *
from my_bi.parcel_lose_task plt
where
    



