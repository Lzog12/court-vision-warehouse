with plays as (

    select 

        j.player_id as player_id_nk,
        CAST(CONCAT(JSON_VALUE(pbp.json_payload, '$.game.gameId'), j.actionNumber) as bigint) as shot_id_nk,
        CAST(JSON_VALUE(pbp.json_payload, '$.game.gameId') AS INT) as game_id_nk,
        j.actionNumber as game_event_id_nk,
        CAST(j.scoreHome as tinyint) as home_pts,
        CAST(j.scoreAway as tinyint) as away_pts
        -- j.is_field_goal as is_fg,
        -- j.action_type as action_type,
        -- j.shot_value as shot_value,
        -- j.shot_result as shot_result


    from {{ source('nba_api', 'play_by_play') }} as pbp

    cross apply OPENJSON(pbp.json_payload, '$.game.actions')

    with (
        player_id bigint '$.personId',
        actionNumber smallint '$.actionNumber',
        scoreHome varchar(4) '$.scoreHome',
        scoreAway varchar(4) '$.scoreAway',
        is_field_goal bit '$.isFieldGoal'
        -- action_type varchar(50) '$.actionType',
        -- shot_value tinyint '$.shotValue',
        -- shot_result varchar(10) '$.shotResult'
    ) as j

    WHERE j.is_field_goal = 1

),

final as (
    select * from plays
)

select * from final;
