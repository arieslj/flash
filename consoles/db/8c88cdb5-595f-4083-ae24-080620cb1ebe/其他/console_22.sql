#drop table if exists tmpale.tmp_th_tgt_pop;
delete from tmpale.tmp_th_tgt_pop where p_date=curdate();
insert into tmpale.tmp_th_tgt_pop
#create table tmpale.tmp_th_tgt_pop as

select
    curdate() as p_date
     ,now() as p_time
    ,tb1.store_id
     ,tb1.store_name
     ,tb1.manage_region_name
     ,tb1.manage_piece_name
     ,tb1.province_code
     ,case when tb1.store_name like '%_SP%' THEN 800 WHEN tb1.store_name LIKE '%_BDC%'  THEN 650 END AS 'dco人效'
     ,tb2.tpeffc 'tpeffc'
     ,tb2.ori_tpeffc
     ,tb2.dlv_length
     ,tb2.piece_length_30_min4
     ,tb3.`到件大件比例7` '到件大件比例'
     ,pk_bp_rt.`pickupwight5` '揽件5kg以上比例'
     ,arrive_cnt_avg 'arrive_cnt_avg_dco'
     ,pickup_cnt_avg 'pickup_cnt_avg_dco'
     ,tb1.arrive_cnt_avg
     ,tb1.pickup_cnt_avg
     ,tb1.basic_pcl_cnt
     ,tb1.pcl_cnt_220
     ,tb1.arrive_cnt_220
     ,tb1.pickup_cnt_220
     ,tb1.arrive_cnt_avg_wkd5
     ,tb1.pickup_cnt_avg_wkd5
     ,tb1.basic_pcl_cnt_wkd5
     ,round(tb1.basic_pcl_cnt_wkd5/tb2.ori_tpeffc*7/6,0) 'basic_pcl_cnt_crr_wkd5'
     ,round(tb1.basic_pcl_cnt/tb2.ori_tpeffc*7/6,0) 'basic_pcl_cnt_crr'
     ,round(tb1.pcl_cnt_220/tb2.ori_tpeffc*7/6,0) 'pcl_cnt_220_crr'

     ,case
          when manage_piece_name like '%BKK%' OR manage_piece_name like '%CE%' OR STORE_NAME like '%BDC%' OR pk_bp_rt.`pickupwight5` >0.3  OR tb3.`到件大件比例7`>0.3 or province_code in ('TH01','TH02','TH03','TH04')
              then greatest(COALESCE(ceiling((arrive_cnt_avg+pickup_cnt_avg)/if(tb1.store_name like '%_SP%',800,650)*7/6),0),2)
          else greatest(COALESCE(floor((arrive_cnt_avg+pickup_cnt_avg)/if(tb1.store_name like '%_SP%',800,650)*7/6),0),2)
    end as '目标DCO'

     ,case
          when manage_piece_name like '%BKK%' OR manage_piece_name like '%CE%' OR STORE_NAME like '%BDC%' OR pk_bp_rt.`pickupwight5` >0.3  OR tb3.`到件大件比例7`>0.3 or province_code in ('TH01','TH02','TH03','TH04')
              then greatest(COALESCE(ceiling((arrive_cnt_220+pickup_cnt_220)/if(tb1.store_name like '%_SP%',800,650)*7/6),0),2)
          else greatest(COALESCE(floor((arrive_cnt_220+pickup_cnt_220)/if(tb1.store_name like '%_SP%',800,650)*7/6),0),2)
    end as '目标DCO_220'
     ,arrive_cnt_sum


from
    (
        select
            *
        from
            (
                select
                    store_id
                     ,store_name
                     ,manage_region_name
                     ,manage_piece_name
                     ,province_code
                     ,tb1.arrive_cnt_avg
                     ,tb1.pickup_cnt_avg
                     ,tb1.arrive_cnt_avg+tb1.pickup_cnt_avg/10 as 'basic_pcl_cnt'
                     ,tb1.arrive_cnt_avg*(2200000/arrive_cnt_sum) 'arrive_cnt_220'
                     ,tb1.pickup_cnt_avg*(2200000/arrive_cnt_sum) 'pickup_cnt_220'
                     ,tb1.arrive_cnt_avg*(2200000/arrive_cnt_sum)+tb1.pickup_cnt_avg*(2200000/arrive_cnt_sum)/10 as 'pcl_cnt_220'
                     , tb1.arrive_cnt_avg_wkd5
                     ,tb1.pickup_cnt_avg_wkd5
                     ,tb1.arrive_cnt_avg_wkd5+tb1.pickup_cnt_avg_wkd5/10 as 'basic_pcl_cnt_wkd5'
                     ,arrive_cnt_sum
                from
                    (
                        select
                            store_id
                             ,store_name
                             ,manage_region_name
                             ,manage_piece_name
                             ,ss.province_code
                             ,avg(basic.arrive_cnt) 'arrive_cnt_avg'
                             ,avg(basic.pickup_cnt) 'pickup_cnt_avg'
                             ,avg(if(dayofweek(basic.stat_date) not in (1,7),basic.arrive_cnt,null)) 'arrive_cnt_avg_wkd5'
                             ,avg(if(dayofweek(basic.stat_date) not in (1,7),basic.pickup_cnt,null)) 'pickup_cnt_avg_wkd5'
                        from
                            tmpale.dwd_th_store_basic  basic
                                left join
                            fle_staging.sys_store ss on ss.id=basic.store_id
                        where 1=1
                          AND basic.stat_date  >=CURDATE()-interval 7 day
                          and basic.stat_date<CURDATE()
                        group by 1,2,3
                    ) tb1
                        left join
                    (
                        select
                            sum(arrive_cnt_avg) 'arrive_cnt_sum'
                             ,sum(arrive_cnt_avg_wkd5) 'arrive_cnt_sum_wkd5'
                        from
                            (
                                select
                                    store_id
                                     ,manage_region_name