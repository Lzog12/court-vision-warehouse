with teams as (
  
  select distinct

    {{ dbt_utils.generate_surrogate_key(['team_id_nk']) }} as team_key,
    team_id_nk,
    team_abbrev

  from {{ ref('stg_nbaapi__league_game') }}

),

team_name as (

  select

    distinct team_id_nk, team_name

  from {{ ref('stg_nbaapi__player_shots') }}

),

final as (

  select

    t.team_key,
    t.team_id_nk,
    tn.team_name,
    t.team_abbrev

  from teams as t

  inner join team_name as tn
    on t.team_id_nk = tn.team_id_nk

)

select * from final;
