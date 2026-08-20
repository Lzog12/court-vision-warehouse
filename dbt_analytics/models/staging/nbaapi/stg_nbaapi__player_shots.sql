with player_shot_data as(

    select

        s.player_id as player_id_nk,
        CAST(JSON_VALUE(j.value, '$[4]') as varchar(50)) as player_name,
        CAST(JSON_VALUE(j.value, '$[5]') as int) as team_id_nk,
        CAST(JSON_VALUE(j.value, '$[6]') as varchar(40)) as team_name,
        s.game_id as game_id_nk,
        CAST(JSON_VALUE(j.value, '$[22]') as CHAR(3)) as htm,
        CAST(JSON_VALUE(j.value, '$[23]') as CHAR(3)) as vtm,
        s.game_date as game_date,
        s.season as season,
        CAST(CONCAT(s.game_id, JSON_VALUE(j.value, '$[2]')) as bigint) as shot_id_nk, -- game_id and game_event_id
        CAST(JSON_VALUE(j.value, '$[2]') as INT) as game_event_id_nk,
        CAST(JSON_VALUE(j.value, '$[10]') as varchar(30)) as event_type,
        CAST(JSON_VALUE(j.value, '$[11]') as varchar(30)) as action_type,
        CAST(JSON_VALUE(j.value, '$[12]') as varchar(30)) as shot_type,
        CAST(JSON_VALUE(j.value, '$[13]') as varchar(30)) as shot_zone_basic,
        CAST(JSON_VALUE(j.value, '$[14]') as varchar(30)) as shot_zone_area,
        CAST(JSON_VALUE(j.value, '$[15]') as varchar(30)) as shot_zone_range,
        CAST(JSON_VALUE(j.value, '$[16]') as tinyint) as shot_distance,
        CAST(JSON_VALUE(j.value, '$[17]') as smallint) as loc_x,
        CAST(JSON_VALUE(j.value, '$[18]') as smallint) as loc_y,
        CAST(JSON_VALUE(j.value, '$[20]') as bit) as is_bucket,
        CAST(JSON_VALUE(j.value, '$[7]') as tinyint) as period_no,
        CAST(JSON_VALUE(j.value, '$[8]') as tinyint) as min_left,
        CAST(JSON_VALUE(j.value, '$[9]') as tinyint) as sec_left

    from {{ source('nba_api', 'shot_chart_detail') }} as s

    cross apply OPENJSON(s.json_payload, '$.data') as j
),

final as (
    select * from player_shot_data
)

select * from final;
