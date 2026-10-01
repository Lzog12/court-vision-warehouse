-- dbt build --select +dim_players

with player_history as (

    select

        -- Unique identifier for each SCD Type 2 version
        dbt_scd_id as player_version_key,

        -- Stable player/team key used throughout the constellation schema
        {{ dbt_utils.generate_surrogate_key(['player_id_nk', 'team_id_nk']) }} as player_key,

        -- Stable team key used throughout the constellation schema
        {{ dbt_utils.generate_surrogate_key(['team_id_nk']) }} as team_key,

        player_id_nk,
        team_id_nk,
        player_name,

        -- SCD Type 2 validity period
        dbt_valid_from as start_date,
        dbt_valid_to as end_date,

        case
            when dbt_valid_to is null then 1
            else 0
        end as is_current

    from {{ ref('snap_players') }}

),

final as (

    select

        player_version_key,
        player_key,
        team_key,

        player_id_nk,
        team_id_nk,
        player_name,

        start_date,
        end_date,
        is_current

    from player_history

)

select *
from final