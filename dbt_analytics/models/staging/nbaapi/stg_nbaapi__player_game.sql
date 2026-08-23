with player_game as (

    select 
    
        pg.player_id as player_id_nk,
        pg.game_id as game_id_nk,
        CAST(JSON_VALUE(pg.json_payload, '$.resultSets[0].rowSet[0][0]') as int) as season_id_nk,
        pg.season as season,
        pg.season_segment as season_segment,
        CAST(JSON_VALUE(pg.json_payload, '$.resultSets[0].rowSet[0][6]') as tinyint) as min,
        CAST(JSON_VALUE(pg.json_payload, '$.resultSets[0].rowSet[0][7]') as tinyint) as fgm,
        CAST(JSON_VALUE(pg.json_payload, '$.resultSets[0].rowSet[0][8]') as tinyint) as fga,
        CAST(JSON_VALUE(pg.json_payload, '$.resultSets[0].rowSet[0][10]') as tinyint) as fg3m,
        CAST(JSON_VALUE(pg.json_payload, '$.resultSets[0].rowSet[0][11]') as tinyint) as fg3a,
        CAST(JSON_VALUE(pg.json_payload, '$.resultSets[0].rowSet[0][13]') as tinyint) as ftm,
        CAST(JSON_VALUE(pg.json_payload, '$.resultSets[0].rowSet[0][14]') as tinyint) as fta,
        CAST(JSON_VALUE(pg.json_payload, '$.resultSets[0].rowSet[0][24]') as tinyint) as pts,
        CAST(JSON_VALUE(pg.json_payload, '$.resultSets[0].rowSet[0][9]') as decimal(4,3)) as fg_pct,
        CAST(JSON_VALUE(pg.json_payload, '$.resultSets[0].rowSet[0][12]') as decimal(4,3)) as fg3_pct,
        CAST(JSON_VALUE(pg.json_payload, '$.resultSets[0].rowSet[0][25]') as smallint) as plus_minus
  
    from {{ source('nba_api', 'player_game_log') }} as pg

),

final as (
    select * from player_game
)

select * from final;