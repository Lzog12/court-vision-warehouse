# Stagger endpoint execution
import time

# Endpoint extractors
from ..extractors.shot_chart_detail import shot_chart_detail
from ..extractors.play_by_play_v3 import play_by_play_v3
from ..extractors.player_game_log import player_game_log
from ..extractors.box_score_player_track_v3 import box_score_player_track_v3

# Primary parameters: retrieve data for endpoint feeds (game_id, team_id, player_id)
from ..config.primary_parameters import game_ids, player_and_team_id

# Data model types
from ..utils.types import PlayerShots, PlayerGame, PlayByPlay, BoxScore

# Database
from ..config.settings import build_connection_string
from ..db.engine import SqlServerEngine

# INSERT queries
from ..db.insert_raw_query import (
    create_batch_id,
    insert_shot_chart_detail,
    insert_player_game_log,
    insert_play_by_play,
    insert_box_score_player_track
)

# Runtime parameters
from ..config.runtime_parameters import (
    get_date,
    regular_season,
    playoff_season,
    current_season
)

# Cursor object type
from pyodbc import Cursor

# Progress bar tracking loops
from tqdm import tqdm


"""Run database engine"""
# Retrieve connection string containing env variables
connection_string = build_connection_string()
sql_engine = SqlServerEngine(conn_string=connection_string)
sql_engine.connect()
# Run player_index: from parent 'etl' directory.
# Command: python3 -m src.etl.pipelines.run_daily

day = get_date(True, '04/04/2026')

# Retrieve unique game ids from today's games (LeagueGameLog)
uq_game_ids = game_ids(
    date_from=day,
    date_to=day,
    season='2025', 
    season_type=regular_season
)
# Returns dictionary of player information (player_id, team_id, game_id)
player_team_ids = player_and_team_id(
    game_ids=uq_game_ids
)

# Create batch id prior to endpoint calls, as it will need to be added to each record
with sql_engine.connect() as conn:
    cursor: Cursor = conn.cursor()
    batch_id = cursor.execute(create_batch_id).fetchone()[0]

"""ENDPOINT CALLS"""

'''Process players section - shot_chart_detail and player_game_log'''
def process_players() -> tuple[list[PlayerShots], list[PlayerGame]]:
    all_player_shots: list[tuple] = []
    all_player_games: list[tuple] = []

    for player_info in tqdm(player_team_ids.values(), desc='Looping over players for ShotChartDetail and PlayerGameLog endpoints'):
        current_player_id = player_info['player_id']
        current_team_id = player_info['team_id']
        current_game_id = player_info['game_id']

        player_shots = shot_chart_detail(
            tm_id=current_player_id,
            pl_id=current_team_id,
            season=current_season,
            season_type=regular_season,
            date_from=day,
            date_to=day,
        )

        player_game = player_game_log(
            pl_id=current_player_id,
            season=current_season,
            season_type=regular_season,
            date_from=day,
            date_to=day
        )

        # Final tuple that will be added as arguments in SQL INSERT
        all_player_shots.append(
            (
                current_player_id,
                current_game_id,
                day,
                current_season,
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
                current_season,
                player_game,
                batch_id
            )
        )

        time.sleep(2)

    print('SUCCESSFULLY LOADED PLAYERS')
    return all_player_shots, all_player_games


'''Process games section - play_by_play_v3 and box_score_player_track_v3'''
def process_games() -> tuple[list[PlayByPlay], list[BoxScore]]:
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
                current_season,
                pbp,
                batch_id
            )
        )
        
        # Final tuple that will be added as arguments in SQL INSERT
        all_bxs_games.append(
            (
                game_id,
                day,
                current_season,
                bxs,
                batch_id
            )
        )

        time.sleep(2)

    print('SUCCESSFULLY LOADED TEAMS')
    return all_pbp_games, all_bxs_games

p_shots, p_game = process_players()
pbp_game, bxs_track = process_games()


def convert_for_json(rows):
    new_rows = []
    for row in rows:
        new_rows.append(tuple(row))

    return new_rows


def to_database() -> None:
    # Activate connection
    with sql_engine.connect() as conn:
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
            # conn.commit()
            # print('COMMITTED')
            print('DONE')

        import json
        json_output_test = {}
        # TEST the insert, put in file pipeline_test.json, remove the commit, rollback at the end
        cursor.execute('SELECT * FROM raw.shot_chart_detail')
        shot_results = cursor.fetchall()
        # columns = [column[0] for column in cursor.description]
        json_output_test['shot_chart_detail'] = [tuple(row) for row in shot_results]
        # json_output_test['shot_chart_detail'] = shot_results

        cursor.execute('SELECT * FROM raw.player_game_log')
        player_results = cursor.fetchall()
        # columns = [column[0] for column in cursor.description]
        json_output_test['player_game_log'] = [tuple(row) for row in player_results]
        # json_output_test['player_game_log'] = player_results

        cursor.execute('SELECT * FROM raw.play_by_play')
        play_by_play_results = cursor.fetchall()
        # columns = [column[0] for column in cursor.description]
        json_output_test['play_by_play'] = [tuple(row) for row in play_by_play_results]
        # json_output_test['play_by_play'] = play_by_play_results

        cursor.execute('SELECT * FROM raw.box_score_player_track')
        box_score_results = cursor.fetchall()
        # columns = [column[0] for column in cursor.description]
        json_output_test['box_score_player_track'] = [tuple(row) for row in box_score_results]
        # json_output_test['box_score_player_track'] = box_score_results


        from datetime import datetime, date

        def serializer(obj):
            if isinstance(obj, (datetime, date)):
                return obj.isoformat()
            
            if isinstance(obj, bytes):
                return obj.decode("utf-8")  # convert bytes → string
            
            raise TypeError(f"Type {type(obj)} not serializable")

        with open('json_output_test.json', 'w', encoding='utf-8') as f:
            json.dump(json_output_test, f, indent=4, default=serializer)

        conn.rollback()

to_database()