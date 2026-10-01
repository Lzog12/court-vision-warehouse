with player_games as (

    select

        *

    from {{ ref('fct_player_games') }}

), team_games as (

    select

        *

    from {{ ref('dim_team_games') }}

), seasons as (

    select

        *

    from {{ ref('dim_seasons') }}

), players as (

    select

        *

    from {{ ref('dim_players') }}

), player_seasons as (

    select

        *

    from {{ ref('fct_player_seasons') }}

), final as (

    select

        pg.player_key,
        pg.game_key,
        pg.season_type_key,

        p.player_name,
        
        tg.team_abbrev as team,
        tg.matchup,
        tg.htm,
        tg.vtm,
        tg.game_date,

        pg.points as game_points,
        pg.min as game_min,
        pg.fgm as game_fgm,
        pg.fga as game_fga,
        pg.fg3m as game_fg3m,
        pg.fg3a as game_fg3a,
        pg.ftm as game_ftm,
        pg.fta as game_fta,
        pg.fg_pct as game_fg_pct,
        pg.plus_minus as game_plus_minus,

        s.season,
        s.season_segment,


        ps.max_pts as season_high_pts,
        ps.avg_pts,

        ps.avg_min,
        ps.avg_fga,
        ps.avg_fgm,
        ps.avg_fg3a,
        ps.avg_fg3m,
        ps.avg_fta,
        ps.avg_ftm,
        ps.avg_fg_pct,
        ps.avg_plus_minus,
        ps.tot_plus_minus
        
    from player_games as pg

    join team_games as tg
        on pg.team_game_key = tg.team_game_key

    join seasons as s
        on pg.season_type_key = s.season_type_key

    join players as p
        on pg.player_key = p.player_key

    join player_seasons as ps
        on pg.player_key = ps.player_key
        and pg.season_type_key = ps.season_type_key

)

select

    *

from final

;