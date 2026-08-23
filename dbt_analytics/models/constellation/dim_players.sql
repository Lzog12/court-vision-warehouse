with players as (

  select

    distinct
    {{ dbt_utils.generate_surrogate_key(['player_id_nk', 'team_id_nk']) }} as player_key,
    {{ dbt_utils.generate_surrogate_key(['team_id_nk', 'team_id_nk']) }} as team_key,
    team_id_nk,
    player_id_nk,
    player_name

  from {{ ref('stg_nbaapi__player_shots') }}

),

final as (

  select

    *

  from players

)

select * from final;
