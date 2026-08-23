with fct_shots as(

  select

    {{ dbt_utils.generate_surrogate_key(['shot_id_nk']) }} as shot_key,
    {{ dbt_utils.generate_surrogate_key(['game_id_nk']) }} as game_key,
    {{ dbt_utils.generate_surrogate_key(['team_id_nk']) }} as team_key,
    {{ dbt_utils.generate_surrogate_key(['team_id_nk', 'game_id_nk']) }} as team_game_key,
    {{ dbt_utils.generate_surrogate_key(['player_id_nk', 'team_id_nk']) }} as player_key,
    {{ dbt_utils.generate_surrogate_key(['season', 'season_segment']) }} as season_type_key,
    shot_id_nk,
    is_bucket,

    case
      when shot_type = '3PT Field Goal' then 1
      when shot_type = '2PT Field Goal' then 0
      else null
    end as is_three_pointer,

    shot_distance,
    loc_x,
    loc_y,
    period_no,
    min_left,
    sec_left

  from {{ ref('stg_nbaapi__player_shots') }}

),

final as (
  
  select * from fct_shots

)

select * from final;
