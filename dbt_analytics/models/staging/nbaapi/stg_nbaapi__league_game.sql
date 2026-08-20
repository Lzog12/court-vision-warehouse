with league_game as (

    select 
    
        CAST(JSON_VALUE(j.value, '$[1]') as int) as team_id_nk,
        CAST(JSON_VALUE(j.value, '$[4]') as int) as game_id_nk,
        lg.game_date as game_date,
        CAST(JSON_VALUE(j.value, '$[2]') as char(3)) as team_abbrev,
        CAST(JSON_VALUE(j.value, '$[0]') as varchar(10)) as season_id_nk,
        lg.season as season,
        lg.season_segment as season_segment,
        CAST(JSON_VALUE(j.value, '$[6]') as varchar(15)) as matchup,
        CAST(JSON_VALUE(j.value, '$[7]') as char(1)) as result,
        CAST(JSON_VALUE(j.value, '$[26]') as tinyint) as points

    from {{ source('nba_api', 'league_game_log') }} as lg

    cross apply OPENJSON(lg.json_payload, '$.resultSets[0].rowSet') as j

),

final as (
    select * from league_game
)

select * from final;
