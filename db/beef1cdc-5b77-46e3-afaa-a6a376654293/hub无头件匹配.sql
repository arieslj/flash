invalidate metadata fle_dwd.dwd_sls_pro_flash_point;
select
    fp.p_month 日期
    ,ss.name 网点
    ,ss.id 网点ID
    ,fp.view_num pv
    ,fp.view_staff_num uv
    ,fp.match_num 点击匹配量
    ,fp.search_num 点击搜索量
    ,fp.sucess_num 成功匹配量
from
    (
        select
            get_json_object(ext_info,'$.organization_id') store_id
            ,substr(fp.p_date, 1, 7) p_month
            ,count(if(fp.event_type = 'screenView', fp.user_id, null)) view_num
            ,count(distinct if(fp.event_type = 'screenView', fp.user_id, null)) view_staff_num
            ,count(if(fp.event_type = 'click' and fp.button_id = 'search', fp.user_id, null)) search_num
            ,count(if(fp.event_type = 'click' and fp.button_id = 'match', fp.user_id, null)) match_num
            ,count(if(get_json_object(ext_info,'$.matchResult') = 'true', fp.user_id, null)) sucess_num
        from fle_dwd.dwd_sls_pro_flash_point fp
        where
            fp.p_date >= '2022-09-01'
            and fp.page_id ='/package/packageMatch'
            and fp.p_app = 'FLE-MS-UI'
        group by 1,2
    ) fp
left join
    (
        select
            *
        from fle_dim.dim_fle_sys_store_da ss
        where
            ss.p_date = date_sub(`current_date`(), 1)
    ) ss on ss.id = fp.store_id
    ;

select
    *
from fle_dwd.dwd_sls_pro_flash_point fp
where
    fp.p_date = date_sub(`current_date`(), 1)
    and fp.page_id ='/package/packageMatch'
    and fp.p_app = 'FLE-MS-UI'