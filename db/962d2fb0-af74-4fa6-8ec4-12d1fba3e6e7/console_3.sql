select
    pi.client_id `客户ID`
    ,pi.pno `包裹`
    ,mr.name `大区`
    ,mp.name `片区`
    ,ss.name `网点`
    ,case pi.state
        when '1' then '已揽收'
        when '2' then '运输中'
        when '3' then '派送中'
        when '4' then '已滞留'
        when '5' then '已签收'
        when '6' then '疑难件处理中'
        when '7' then '已退件'
        when '8' then '异常关闭'
        when '9' then '已撤销'
    end as `包裹状态`
    ,`if`(pr.pno is null , '否', '是') `是否有拒收标记`
from
    (
        select
            pi.pno
            ,pi.client_id
            ,pi.p_date
            ,pi.dst_store_id
            ,pi.state
        from fle_dwd.dwd_fle_parcel_info_di pi
        where
            pi.p_date >= '2022-01-01'
            and pi.state in (1,2,3,4,6)
            and pi.client_id in ('AA0150','AA0151','BA0083','BA0184','BA0230','BA0236','BA0248','BA0255','BA0300','BA0323','BA0344','BA0348','BA0349','BA0379','BA0391','BA0441','BA0549','BA0560','BA0577','BA0581','BA0599','BA0616','BA0622','BA0635','BA0639','BA0652','CA0179','CA0218','CA0242','CA0314','CA0511','CA0548','CA0590','CA1026','CA1385','CA1728','CA3328','CA3347','CA3473','CA3478','BA0451','BA0496','BA0543','BA0546','BA0612','BA0617')
    ) pi
left join
    (
        select
            *
        from fle_dim.dim_fle_sys_store_da ss
        where
            ss.p_date = date_sub(`current_date`(), 1)
    ) ss on ss.id = pi.dst_store_id
left join
    (
        select
            *
        from fle_dim.dim_fle_sys_manage_piece_da  smp
        where
            smp.p_date = date_sub(`current_date`(), 1)
    ) mp on mp.id = ss.manage_piece
left join
    (
        select
            *
        from fle_dim.dim_fle_sys_manage_region_da  smr
        where
            smr.p_date = date_sub(`current_date`(), 1)
    ) mr on mr.id = ss.manage_region
left join
    (
        select
            pr.pno
        from fle_dwd.dwd_fle_parcel_route_di pr
        where
            pr.p_date >= '2022-03-28'
            and pr.route_action = 'DELIVERY_MARKER'
            and pr.marker_category in ('2', '17')
        group by 1
    ) pr on pr.pno = pi.pno