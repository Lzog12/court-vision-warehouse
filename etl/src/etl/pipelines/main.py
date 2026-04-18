from .run_daily import to_database, retrieve_game_ids, retrieve_player_and_team_ids, process_players, process_games
from ..config.runtime_parameters import (
    get_date,
    regular_season,
    playoff_season,
    current_season
)

# Run player_index: from parent 'etl' directory.
# Command: python3 -m src.etl.pipelines.main

# Add season_type toggle
def main(season_final: str, season_type_final: str, override_final: bool = False, date_final: str = '', commit_toggle_final: bool = False) -> None:
    # Automatically sets the date to today's date, unless override=True
    # Set the if different Date Format: mm-dd-yyyy
    day = get_date(
        override=override_final,
        alternate_date=date_final
    )

    # Retrieve the game ids for the given date
    uq_game_ids = retrieve_game_ids(
        day=day,
        season_type=season_type_final
    )
    
    # Retrieve player and team ids that played today
    player_team_ids = retrieve_player_and_team_ids(uq_game_ids=uq_game_ids)

    # Runs the endpoints and retrieves player shots and player-game stats data
    p_shots, p_game = process_players(
        player_team_ids=player_team_ids,
        day=day,
        season=season_final,
        season_type=season_type_final
    )

    # Runs the endpoints and retrieves game data
    pbp_game, bxs_track = process_games(
        uq_game_ids=uq_game_ids,
        day=day,
        season=season_final
    )

    # Takes all the gathered data and places it into database
    to_database(
        p_shots=p_shots,
        p_game=p_game,
        pbp_game=pbp_game,
        bxs_track=bxs_track,
        commit_toggle=commit_toggle_final
    )

if __name__ == '__main__':
    main(
        season_final=current_season, #2025-26
        season_type_final=regular_season, 
        override_final=True, #If true, set new date in date_final, otherwise can omit both override and date
        date_final='03-02-2026',
        commit_toggle_final= True #Commit to database option
    )