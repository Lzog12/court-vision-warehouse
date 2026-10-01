with shots as (

    select 

        *

    from {{ ref('fct_shots') }}

    where

        fga_tie = 1 or
        fga_lead = 1

),

players as (

    select

        *

    from {{ ref('dim_players') }}

    where is_current = 1

),

teams as (

    select

        *

    from {{ ref('dim_teams') }}

),

shot_type as (

    select

        *

    from {{ ref('dim_shots') }}

),

team_games as (

    select

        *

    from {{ ref('dim_team_games') }}

),

final as (

select 

    s.player_key,
    s.team_key,
    s.game_key,
    s.game_event_id_nk,

    p.player_name,
    t.team_abbrev as player_team,

    tg.htm,
    tg.vtm,

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

left join players as p
    on s.player_key = p.player_key

left join teams as t
    on s.team_key = t.team_key

left join shot_type as st
    on s.shot_key = st.shot_key

left join team_games as tg
    on s.team_game_key = tg.team_game_key

)

select

    *

from final

;