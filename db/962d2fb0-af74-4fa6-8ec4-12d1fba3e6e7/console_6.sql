
        select
            mp.*
        from fle_dim.dim_fle_sys_manage_piece_da mp
        where
            mp.p_date = '2023-07-31'
            and mp.deleted = '0'