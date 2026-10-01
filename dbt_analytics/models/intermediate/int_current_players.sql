{{ config(materialized='view',
          schema='staging'
) }}

with player_observations as (

    select distinct

        player_id_nk,
        team_id_nk,
        player_name,
        game_date,
        game_id_nk

    from {{ ref('stg_nbaapi__player_shots') }}

),

ranked_players as (

    select

        player_id_nk,
        team_id_nk,
        player_name,

        row_number() over (
            partition by player_id_nk
            order by game_date desc, game_id_nk desc
        ) as row_num

    from player_observations

),

final as (

    select

        player_id_nk,
        team_id_nk,
        player_name

    from ranked_players

    where row_num = 1

)

select *
from final