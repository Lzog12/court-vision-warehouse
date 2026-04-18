# Endpoint extractors
from ..extractors.shot_chart_detail import shot_chart_detail
from ..extractors.play_by_play_v3 import play_by_play_v3
from ..extractors.player_game_log import player_game_log
from ..extractors.box_score_player_track_v3 import box_score_player_track_v3

# Primary parameters: retrieve data for endpoint feeds (game_id, team_id, player_id)
from ..config.primary_parameters import game_ids, player_and_team_id

# Data model types
from ..utils.types import PlayerShots, PlayerGame, PlayByPlay, BoxScoreTrack

# Database
from ..config.settings import build_connection_string
from ..db.engine import SqlServerEngine
from pyodbc import Connection

# INSERT queries
from ..db.insert_raw_query import (
    create_batch_id,
    insert_shot_chart_detail,
    insert_player_game_log,
    insert_play_by_play,
    insert_box_score_player_track
)

# Cursor object type
from pyodbc import Cursor

# Progress bar tracking loops
from tqdm import tqdm


"""Set up database engine"""
def database_engine() -> Connection:
    # Retrieve connection string containing env variables
    connection_string = build_connection_string()
    sql_engine = SqlServerEngine(conn_string=connection_string)

    return sql_engine.connect()

"""Only variable not passed in to main.py, created here in isolation"""
with database_engine() as conn:
    cursor: Cursor = conn.cursor()
    batch_id = cursor.execute(create_batch_id).fetchone()[0]

def retrieve_game_ids(day: str, season_type) -> list[str]:
    # Retrieve unique game ids from today's games (LeagueGameLog)
    unique_game_ids = game_ids(
        date_from=day,
        date_to=day,
        season='2025', 
        season_type=season_type
    )

    return unique_game_ids

def retrieve_player_and_team_ids(uq_game_ids: list[str]) -> dict[str, str | int]:
    # Returns dictionary of player information (player_id, team_id, game_id)
    player_and_team_ids = player_and_team_id(
        game_ids=uq_game_ids
    )

    return player_and_team_ids


"""ENDPOINT CALLS"""
'''Process players section - shot_chart_detail and player_game_log'''
def process_players(player_team_ids: dict[str, str | int], day: str, season: str, season_type: str) -> tuple[list[PlayerShots], list[PlayerGame]]:
    all_player_shots: list[tuple] = []
    all_player_games: list[tuple] = []

    for player_info in tqdm(player_team_ids.values(), desc='Looping over players for ShotChartDetail and PlayerGameLog endpoints'):
        current_player_id = player_info['player_id']
        current_team_id = player_info['team_id']
        current_game_id = player_info['game_id']
        
        player_shots = shot_chart_detail(
            tm_id=current_team_id,
            pl_id=current_player_id,
            season=season,
            season_type=season_type,
            date_from=day,
            date_to=day,
        )

        player_game = player_game_log(
            pl_id=current_player_id,
            season=season,
            season_type=season_type,
            date_from=day,
            date_to=day
        )

        # Final tuple that will be added as arguments in SQL INSERT
        all_player_shots.append(
            (
                current_player_id,
                current_game_id,
                day,
                season,
                player_shots,
                batch_id
            )
        )

        # Final tuple that will be added as arguments in SQL INSERT
        all_player_games.append(
            (
                current_player_id,
                current_game_id,
                day,
                season,
                player_game,
                batch_id
            )
        )

    print('SUCCESSFULLY LOADED PLAYERS')
    return all_player_shots, all_player_games


'''Process games section - play_by_play_v3 and box_score_player_track_v3'''
def process_games(uq_game_ids:list[str], day: str, season: str) -> tuple[list[PlayByPlay], list[BoxScoreTrack]]:
    all_pbp_games = []
    all_bxs_games = []
    
    for game_id in tqdm(uq_game_ids, desc='Looping over game ids for PlayByPlayV3 and BoxScoreAdvancedV3 endpoints'):

        pbp = play_by_play_v3(
            gm_id=game_id
        )

        bxs = box_score_player_track_v3(
            gm_id=game_id
        )

        # Final tuple that will be added as arguments in SQL INSERT
        all_pbp_games.append(
            (
                game_id,
                day,
                season,
                pbp,
                batch_id
            )
        )
        
        # Final tuple that will be added as arguments in SQL INSERT
        all_bxs_games.append(
            (
                game_id,
                day,
                season,
                bxs,
                batch_id
            )
        )

    print('SUCCESSFULLY LOADED TEAMS')
    return all_pbp_games, all_bxs_games


def to_database(p_shots: PlayerShots, 
                p_game: PlayerGame, 
                pbp_game: PlayByPlay, 
                bxs_track: BoxScoreTrack, 
                commit_toggle: bool = True) -> None:
    # Activate connection
    with database_engine() as conn:
        # Use a single transaction for all inserts
        conn.autocommit = False
        # Create cursor
        cursor: Cursor = conn.cursor()
        # Ensure fast execute remains off as it alters date types
        cursor.fast_executemany = False
        print('Connected to database')

        try:
            cursor.executemany(insert_shot_chart_detail, p_shots)
            print('SUCCESS INSERT: raw.shot_chart_detail')
            cursor.executemany(insert_player_game_log, p_game)
            print('SUCCESS INSERT: raw.player_game_log')
            cursor.executemany(insert_play_by_play, pbp_game)
            print('SUCCESS INSERT: raw.play_by_play')
            cursor.executemany(insert_box_score_player_track, bxs_track)
            print('SUCCESS INSERT: raw.box_score_player_track')
        except Exception as e:
            conn.rollback()
            print('ROLLBACK')
            raise RuntimeError(f'DATABASE INSERT FAILED: {e}') from e
        else:
            if commit_toggle:
                conn.commit()
                print('COMMITTED')
            elif not commit_toggle:
                conn.rollback()
                print('COMPLETED BUT ROLLED BACK')
