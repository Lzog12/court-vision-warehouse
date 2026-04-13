# Column Mapping Staging Table to Star Schema

## Overview
This document maps staging table fields to star schema tables.

## Tables mapped
- fct_shots
- dim_game
- dim_shots
- dim_players
- dim_teams


#### Mapping 
###### stg_nbaapi__player_shots -> dim_shots
* STAGING col -> STAR SCHEMA col
(Generated) IDENTITY -> shot_key
shot_id -> shot_id_nk
game_id -> game_id_nk
game_event_id -> game_event_id_nk
action_type -> action_type
shot_type -> shot_type
shot_zone_basic -> shot_zone_basic
shot_zone_area -> shot_zone_area
shot_zone_range -> shot_zone_range
event_type -> event_type

###### stg_nbaapi__player_shots -> dim_players
* STAGING col -> STAR SCHEMA col
(Generated) IDENTITY -> player_key
team_id_nk -> team_id
player_id_nk -> player_id
player_name -> player_name
position -> position

###### stg_nbaapi__player_shots -> dim_teams
* STAGING col -> STAR SCHEMA col
(Generated) IDENTITY -> team_key
team_id -> team_id
team_name -> team_name
team_abbrev -> team_abbrev

###### stg_nbaapi__player_shots -> dim_games
* STAGING col -> STAR SCHEMA col
(Generated) IDENTITY -> game_key
game_id_nk -> game_id_nk
matchup -> matchup
htm -> htm
vtm -> vtm
`stg_nbaapi__game_team_stats`.htm_starters -> htm starters
`stg_nbaapi__game_team_stats`.vtm_starters -> vtm starters
`stg_nbaapi__game_team_stats`.htm_result -> htm_result
`stg_nbaapi__game_team_stats`.vtm_result -> vtm_result
season -> season
season_segment -> season_segment
game_date -> game_date

###### stg_nbaapi__player_shots -> fct_shots
* STAGING col -> STAR SCHEMA col
FK lookup from dim_shots -> shot_key
FK lookup from dim_game -> game_key
FK lookup from dim_teams -> team_key
FK lookup from dim_players -> player_key
is_bucket -> is_bucket
shot_distance -> shot_distance
loc_x -> loc_x
loc_y -> loc_y
period_no -> period
min_left -> min_left
sec_left -> sec_left
shot_id_nk -> shot_id_nk


###### stg_nbaapi__play_by_play -> fct_pbp
* STAGING col -> STAR SCHEMA col
FK lookup from dim_games -> game_key
FK lookup from dim_shots -> shot_key
shot_id_nk -> shot_id_nk
game_id_nk -> game_id_nk
game_event_id_nk -> game_event_id_nk
home_pts -> home_pts
away_pts -> away_pts
is_fg_to_lead_or_tie -> is_fg_to_lead_or_tie
is_lead -> is_lead
is_tie -> is_tie
is_clutch -> is_clutch

###### stg_nbaapi__player_game -> fct_player_games
* STAGING col -> STAR SCHEMA col
FK lookup from dim_players -> player_key
FK lookup from dim_games -> game_key
FK lookup from dim_seasons -> season_type_key
game_id_nk -> game_id_nk
player_id_nk -> player_id_nk
season_id_nk -> season_id_nk
min -> min
fgm -> fgm
fga -> fga
fg3m -> fg3m
fg3a -> fg3a
pts -> pts
plus_minus -> plus_minus
q1_fgm -> q1_fgm
q2_fgm -> q2_fgm
q3_fgm -> q3_fgm
q4_fgm -> q4_fgm
h1_fgm -> h1_fgm
h2_fgm -> h2_fgm
ot_fgm -> ot_fgm
`stg_nbaapi__game_player_stats`.start_position -> start_position


###### stg_nbaapi__player_season -> fct_player_seasons
* STAGING col -> STAR SCHEMA col
FK lookup from dim_players -> season_type_key
FK lookup from dim_players -> player_key
`fct_player_games`.player_id_nk -> player_id_nk
`fct_player_games`.season_id_nk -> season_id_nk
`fct_player_games`.[incremental] -> season
`fct_player_games`.[incremental] -> season_segment
`fct_player_games`.[incremental] -> season_high_pts
`fct_player_games`.[incremental] -> season_high_pts_game_id
`fct_player_games`.[incremental] -> season_low_pts
`fct_player_games`.[incremental] -> season_low_pts_game_id
`fct_player_games`.[incremental] -> avg_pts
`fct_player_games`.[incremental] -> avg_min
`fct_player_games`.[incremental] -> avg_fga
`fct_player_games`.[incremental] -> avg_fgm
`fct_player_games`.[incremental] -> avg_fg_pct
`fct_player_games`.[incremental] -> avg_fg3a
`fct_player_games`.[incremental] -> avg_fg3m
`fct_player_games`.[incremental] -> plus_minus_ovr


###### stg_nbaapi__player_game -> dim_seasons
* STAGING col -> STAR SCHEMA col
(Generated) IDENTITY -> season_type_key
season_id_nk -> season_id_nk
season -> season
season_segment -> season_segment

