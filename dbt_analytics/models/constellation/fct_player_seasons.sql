{{ config(materialized='incremental', unique_key='player_season_key') }}

with player_seasons as (

    select

        player_key,
        team_key,
        season_type_key,
        -- add new player_key + season_type_key for 'player_season_key'
        {{ dbt_utils.generate_surrogate_key(['player_key', 'season_type_key']) }} as player_season_key,

        count(player_id_nk) as games_played,

        cast(max(points) as tinyint) as max_pts,
        
        cast(avg(cast(points as decimal(5,1))) as decimal(5,1)) as avg_pts,
        cast(avg(cast(min as decimal(5,1))) as decimal(5,1)) as avg_min,
        cast(avg(cast(fgm as decimal(5,1))) as decimal(5,1)) as avg_fgm,
        cast(avg(cast(fga as decimal(5,1))) as decimal(5,1)) as avg_fga,
        cast(avg(cast(fg3m as decimal(5,1))) as decimal(5,1)) as avg_fg3m,
        cast(avg(cast(fg3a as decimal(5,1))) as decimal(5,1)) as avg_fg3a,
        cast(avg(cast(ftm as decimal(5,1))) as decimal(5,1)) as avg_ftm,
        cast(avg(cast(fta as decimal(5,1))) as decimal(5,1)) as avg_fta,
        cast(avg(cast(fg_pct as decimal(5,1))) as decimal(4,3)) as avg_fg_pct,
        cast(avg(cast(plus_minus as decimal(5,1))) as decimal(5,1)) as avg_plus_minus,

        cast(sum(plus_minus) as smallint) as tot_plus_minus

    from {{ ref('fct_player_games') }}

    group by player_key, team_key, season_type_key

),

final as (

    select

        *

    from player_seasons

)

select * from final

;
