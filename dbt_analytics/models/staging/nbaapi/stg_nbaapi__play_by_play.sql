with plays as (

    select 

        pbp.season,
        pbp.season_segment,
        j.player_id as player_id_nk,
        CAST(j.team_id as int) as team_id_nk,
        CAST(CONCAT(JSON_VALUE(pbp.json_payload, '$.game.gameId'), j.actionNumber) as bigint) as shot_id_nk,
        CAST(JSON_VALUE(pbp.json_payload, '$.game.gameId') as int) as game_id_nk,
        j.actionNumber as game_event_id_nk,
        j.period_no as period_no,
        j.clock as clock,
        CAST(SUBSTRING(j.clock, 3, 2) as int) as min_left,
        CAST(SUBSTRING(j.clock, 6, 2) as int) as sec_left,
        CAST(j.scoreHome as tinyint) as home_pts,
        CAST(j.scoreAway as tinyint) as away_pts,
        j.is_field_goal as is_fg,
        CAST(j.shot_value as tinyint) as shot_value_original, -- Value of the shot
        case
          when j.action_type = 'Free Throw' and j.descr not like 'MISS %' then 1
          when j.action_type = 'Missed Shot' then 0
          else j.shot_value -- Shot value always returns the potential points scored, so shot_value is given if the action type is not the above ['Missed shot', 'MISS %']
        end as points_scored,
        case
          when j.action_type = 'Free Throw' then 1
          else j.shot_value
        end as shot_value_new, -- Adds shot value for free throws
        CAST(j.team_location as CHAR(1)) as team_location,
        j.descr,
        j.action_type,
        j.sub_type


    from {{ source('nba_api', 'play_by_play') }} as pbp

    cross apply OPENJSON(pbp.json_payload, '$.game.actions')

    with (
        player_id bigint '$.personId',
        team_id bigint '$.teamId',
        clock varchar(20) '$.clock',
        actionNumber smallint '$.actionNumber',
        period_no smallint '$.period',
        scoreHome varchar(4) '$.scoreHome',
        scoreAway varchar(4) '$.scoreAway',
        team_location varchar(1) '$.location',
        is_field_goal bit '$.isFieldGoal',
        shot_value tinyint '$.shotValue',
        descr varchar(50) '$.description',
        action_type varchar(50) '$.actionType',
        sub_type varchar(50) '$.subType'

    ) as j
    -- Filter out unwanted general game plays
    where j.is_field_goal = 1 or action_type = 'Free Throw'

),

final as (
    select * from plays
)

select * from final;
