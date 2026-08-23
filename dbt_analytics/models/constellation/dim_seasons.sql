with seasons as(
  
  select

    distinct 
    {{ dbt_utils.generate_surrogate_key(['season', 'season_segment']) }} as season_type_key,
    season_id_nk, 
    season, 
    season_segment

  from {{ ref('stg_nbaapi__league_game') }}

),

final as (

  select

    *

  from seasons

)

select * from final;