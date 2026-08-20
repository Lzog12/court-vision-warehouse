with dim_shots as (

    select

      {{ dbt_utils.generate_surrogate_key(['shot_id_nk']) }} as shot_key,
      shot_id_nk,
      game_id_nk,
      game_event_id_nk,
      action_type,
      shot_type,
      shot_zone_basic,
      shot_zone_area,
      shot_zone_range,
      event_type

    from {{ ref('stg_nbaapi__player_shots') }}

),

final as (
    select * from dim_shots
)

select * from final;

