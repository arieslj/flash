select
    rr.pno 运单号
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as  客户类型
    ,case
        when rr.reweight_type in (3,4,5,6) then '量方读数审核'
        when rr.reweight_type in (1) then '称重读数审核'
        when rr.reweight_type in (2) then '单号一致性审核'
    end 复称审核类型
    ,convert_tz(rr.created_at, '+00:00', '+07:00') 进入wrs时间
    ,if(rr.status = 2, convert_tz(rr.input_end, '+00:00', '+07:00'), null) 审核时间
    ,case rr.status
        when 0 then '待分配'
        when 1 then '已分配'
        when 2 then '审核完毕'
    end 审核状态
    ,case rr.reweight_result
        when 0 then '待判责'
        when 1 then '准确'
        when 2 then '不规范'
        when 3 then '虚假'
        when 4 then '待判-不规范'
        when 5 then '待判-虚假'
    end 审核结果
    ,rr.input_by 审核人
    ,case
        when timestampdiff(hour, rr.created_at, rr.input_end) >= 24 then '超时'
        when timestampdiff(hour, rr.created_at, rr.input_end) < 24 then '时效内'
        else null
    end 是否超时
from wrs_production.reweight_record rr
left join fle_staging.parcel_info pi on pi.pno = rr.pno and pi.created_at > date_sub(curdate(), interval 2 month)
left join fle_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id
where
    rr.created_at > date_sub(curdate(), interval 9 hour) -- 前一天22:00


;

select
    rr.input_id 审核员工编号
    ,rr.input_by 审核员工姓名
    ,count(if(rr.reweight_result = 1, rr.id, null)) 准确数量
    ,count(if(rr.reweight_result = 2, rr.id, null)) 不规范数量
    ,count(if(rr.reweight_result = 3, rr.id, null)) 虚假数量
    ,count(if(rr.reweight_result in (1,2,3), rr.id, null)) 合计
    ,count(if(timestampdiff(hour, rr.created_at, rr.input_end) < 24, rr.id, null)) 时效内数量
    ,count(if(timestampdiff(hour, rr.created_at, rr.input_end) >= 24, rr.id, null)) 超时数量
    ,count(if(timestampdiff(hour, rr.created_at, rr.input_end) < 24, rr.id, null)) / count(rr.id) 时效内占比
from wrs_production.reweight_record rr
where
    rr.created_at > date_sub(curdate(), interval 9 hour) -- 前一天22:00
    and rr.input_id not in ('1000000')
    and rr.status = 2
group by 1,2


