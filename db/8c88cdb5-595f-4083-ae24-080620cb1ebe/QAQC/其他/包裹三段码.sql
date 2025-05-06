select
    ps.pno
    ,ps.sorting_code 三段码
    ,ss.name 当前目的地网点
    ,ps.created_at 创建时间
    ,row_number() over (partition by ps.pno order by ps.created_at desc) '排序(最新为1)'
from dwm.drds_parcel_sorting_code_info ps
left join fle_staging.sys_store ss on ss.id = ps.dst_store_id
where
    ps.pno in ('TH10125JUYUU8A','TH10125JA3QQ3C','TH07025KHKK71I','TH07025KPPQA1A','TH10125JUZ2Y7A','TH10125KE2C00C','TH07025JUYYY8H','TH10125KW27W6B','TH10115JYDXX5F','TH10125KHNRD5A','TH10125KHK1J3A','TH10125JA3NU3C','TH10125KPRDE5A','TH10125JA3ZA5A')