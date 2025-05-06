
-- AI合格率
select
    concat(round(count(if(fpa.audit_type_ai = 5, fpa.id, null)) * 100 / count(fpa.id), 2), '%') 近三月AI合格率
from wrs_production.force_photo_audit fpa
where
    fpa.created_at > date_sub(curdate(), interval 3 month)

;


-- 人工审核虚假占比

select
    concat(round(count(if(fpa.audit_result = 2, fpa.id, null)) / count(fpa.id) * 100, 2) , '%')as 虚假占比
from wrs_production.force_photo_audit fpa
where
    fpa.created_at > date_sub(curdate(), interval 3 month)
    and fpa.audit_state_ai = 0
;


-- 兜底拍摄

-- 路由时间过长，去dataworks



