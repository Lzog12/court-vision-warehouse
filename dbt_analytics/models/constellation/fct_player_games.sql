with player_games as (

  select

    {{ dbt_utils.generate_surrogate_key(['game_id_nk']) }} as game_key,
    {{ dbt_utils.generate_surrogate_key(['season', 'season_segment']) }} as season_type_key,
    
    game_id_nk,
    player_id_nk,
    season_id_nk,
    pts as points,
    min as min,
    fgm,
    fga,
    fg3m,
    fg3a,
    ftm,
    fta,
    fg_pct,
    plus_minus


  from {{ ref('stg_nbaapi__player_game') }}

),

fg_by_period as (

  select

      player_name,
      player_id_nk,
      game_id_nk,

      SUM(case when period_no = 1 and is_bucket = 1 then 1 else 0 end) AS q1_fgm,
      SUM(case when period_no = 2 and is_bucket = 1 then 1 else 0 end) AS q2_fgm,
      SUM(case when period_no = 3 and is_bucket = 1 then 1 else 0 end) AS q3_fgm,
      SUM(case when period_no = 4 and is_bucket = 1 then 1 else 0 end) AS q4_fgm,
      SUM(case when (period_no = 1 OR period_no = 2) 
          and is_bucket = 1 then 1 else 0 end) AS h1_fgm,
      SUM(case when (period_no = 3 OR period_no = 4) 
          and is_bucket = 1 then 1 else 0 end) AS h2_fgm,
      SUM(
          case
              when period_no >= 5 and is_bucket = 1 then 1
              else 0
          end
      ) as ot_fgm

  from {{ ref('stg_nbaapi__player_shots') }}

  group by
      player_name,
      player_id_nk,
      game_id_nk

),

team_lookup as(

  select

    distinct game_id_nk, team_id_nk, player_id_nk

  from {{ ref('stg_nbaapi__player_shots') }}


),

final as (

  select

    {{ dbt_utils.generate_surrogate_key(['pg.player_id_nk', 'tl.team_id_nk']) }} as player_key,
    pg.game_key,
    pg.season_type_key,
    {{ dbt_utils.generate_surrogate_key(['tl.team_id_nk']) }} as team_key,
    {{ dbt_utils.generate_surrogate_key(['tl.team_id_nk', 'pg.game_id_nk']) }} as team_game_key,
    pg.player_id_nk,
    pg.game_id_nk,
    pg.season_id_nk,
    tl.team_id_nk,
    pg.points,
    pg.min,
    pg.fgm,
    pg.fga,
    pg.fg3m,
    pg.fg3a,
    pg.ftm,
    pg.fta,
    pg.fg_pct,
    pg.plus_minus,
    fg.q1_fgm,
    fg.q2_fgm,
    fg.q3_fgm,
    fg.q4_fgm,
    fg.h1_fgm,
    fg.h2_fgm,
    fg.ot_fgm

  from player_games as pg

  join fg_by_period as fg
    on pg.player_id_nk = fg.player_id_nk
    and pg.game_id_nk = fg.game_id_nk

  join team_lookup as tl
    on pg.player_id_nk = tl.player_id_nk
    and pg.game_id_nk = tl.game_id_nk

)

select * from final;
