# Column Mapping Staging Table to Star Schema

## Overview
This document maps staging table fields to star schema tables.

## Tables mapped
- dim_shots
- dim_players
- dim_teams
- dim_games
- fct_shots
- fct_pbp
- fct_player_games
- fct_player_seasons
- dim_seasons


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
? -> position ------Leave blank for now. Can add later with .PlayerIndex
`CommonAllPlayers` -> start_date
`CommonAllPlayers` -> end_date
`CommonAllPlayers` -> is_current

###### stg_nbaapi__player_shots -> dim_teams
* STAGING col -> STAR SCHEMA col
(Generated) IDENTITY -> team_key
team_id -> team_id
team_name -> team_name
team_abbrev -> team_abbrev

###### stg_nbaapi__league_game_log -> dim_games
* STAGING col -> STAR SCHEMA col
(Generated) IDENTITY -> game_key
game_id_nk -> game_id_nk
game_date -> game_date
`stg_nbaapi__league_game_log`.matchup -> matchup
`stg_nbaapi__league_game_log`.htm -> htm
`stg_nbaapi__league_game_log`.vtm -> vtm
`stg_nbaapi__league_game_log`.htm_result -> htm_result
`stg_nbaapi__league_game_log`.vtm_result -> vtm_result
`stg_nbaapi__league_game_log`.htm_score -> htm_pts
`stg_nbaapi__league_game_log`.vtm_score -> vtm_pts

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
`player_shots JOIN play_by_play CM` -> is_fg_to_lead_or_tie
`player_shots JOIN play_by_play CM` -> is_lead
`player_shots JOIN play_by_play CM` -> is_tie
`player_shots JOIN play_by_play CM` -> is_clutch

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
ftm -> ftm
fta -> fta
pts -> pts
`player_shots JOIN play_by_play CM` -> q1_fgm
`player_shots JOIN play_by_play CM` -> q2_fgm
`player_shots JOIN play_by_play CM` -> q3_fgm
`player_shots JOIN play_by_play CM` -> q4_fgm
`player_shots JOIN play_by_play CM` -> h1_fgm
`player_shots JOIN play_by_play CM` -> h2_fgm
`player_shots JOIN play_by_play CM` -> ot_fgm


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
`fct_player_games`.[incremental] -> avg_points
`fct_player_games`.[incremental] -> avg_minutes
`fct_player_games`.[incremental] -> avg_fgm
`fct_player_games`.[incremental] -> avg_fga
`fct_player_games`.[incremental] -> avg_fg3m
`fct_player_games`.[incremental] -> avg_fg3a
`fct_player_games`.[incremental] -> avg_ftm
`fct_player_games`.[incremental] -> avg_fta
`fct_player_games`.[incremental] -> avg_fg_pct
`fct_player_games`.[incremental] -> plus_minus_ovr


###### stg_nbaapi__player_game -> dim_seasons
* STAGING col -> STAR SCHEMA col
(Generated) IDENTITY -> season_type_key
season_id_nk -> season_id_nk
season -> season
season_segment -> season_segment

