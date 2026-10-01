
with shots as (

    select 
    
        * 
        
    from {{ ref('fct_shots') }}

    where fga_clutch = 1

), shot_type as (

    select

        *

    from {{ ref('dim_shots') }}

), players as (

    select

        *

    from {{ ref('dim_players') }}

    where is_current = 1

), player_games as (

    select

        *

    from {{ ref('fct_player_games') }}

), team_games as (

    select

        *

    from {{ ref('dim_team_games') }}

), final as (


select

    s.player_key,
    s.team_key,
    s.game_key,
    s.game_event_id_nk,

    p.player_name,

    tg.team_abbrev as player_team,
    tg.htm,
    tg.vtm,
    tg.points as team_game_points,
    tg.result as player_team_result,
    tg.matchup,
    tg.game_date,

    pg.points as player_game_points,
    pg.fga as player_game_fga,
    pg.fgm as player_game_fgm,
    pg.fg3a as player_game_fg3a,
    pg.fg3m as player_game_fg3m,
    pg.fta as player_game_fta,
    pg.ftm as player_game_ftm,
    pg.plus_minus as player_plus_minus,

    case
        when st.action_type is null then 'Free Throw'
        else st.action_type
    end as action_type,

    s.is_fg,
    s.is_ft,
    s.is_bucket,
    s.is_three_pointer,
    s.shot_value,
    s.points_scored,
    s.shot_distance,
    s.loc_x,
    s.loc_y,
    s.period_no,
    s.min_left,
    s.sec_left,
    s.home_pts,
    s.away_pts,
    s.fga_tie,
    s.fgm_tie,
    s.fga_lead,
    s.fgm_lead,
    s.fga_clutch,
    s.fgm_clutch

from shots as s

left join shot_type as st
    on s.shot_key = st.shot_key

left join players as p
    on s.player_key = p.player_key

left join player_games as pg
    on s.team_game_key = pg.team_game_key and s.player_key = pg.player_key

left join team_games as tg
    on s.team_game_key = tg.team_game_key and s.team_key = tg.team_key

)

select

    *

from final

;
