with games as (

  select
    {{ dbt_utils.generate_surrogate_key(['team_id_nk', 'game_id_nk']) }} as team_game_key,
    {{ dbt_utils.generate_surrogate_key(['game_id_nk']) }} as game_key,
    {{ dbt_utils.generate_surrogate_key(['team_id_nk']) }} as team_key,
    game_id_nk,
    team_id_nk,
    matchup,
    game_date,
    team_abbrev,
    points,
    result

  from {{ ref('stg_nbaapi__league_game') }}

), 

shots as (

  select 

    game_id_nk as game_id_nk_shots,
    team_id_nk as team_id_nk_shots,
    htm,
    vtm

  from {{ ref('stg_nbaapi__player_shots') }}

  group by game_id_nk, team_id_nk, htm, vtm


),

final as (
    
    select 
    
      g.*, s.htm, s.vtm
    
    from games as g
    
-- Join on team id not game id as there are two game results from stg_nbaapi__league_game
    inner join shots as s
      on g.game_id_nk = s.game_id_nk_shots
      and g.team_id_nk = s.team_id_nk_shots

)


select * from final;

