# Endpoint extractors
from ..extractors.shot_chart_detail import shot_chart_detail
from ..extractors.play_by_play_v3 import play_by_play_v3
from ..extractors.player_game_log import player_game_log
from ..extractors.box_score_player_track_v3 import box_score_player_track_v3

# Primary parameters to retrieve data for endpoint feeds (game_id, team_id, player_id)
from ..config.primary_parameters import game_ids, player_and_team_id

# Structured data representations
from ..utils.types import PlayerShots, PlayerGame, PlayByPlay, BoxScore

# Database usage and engine
from ..config.settings import build_connection_string
from ..db.engine import SqlServerEngine

# INSERT queries
from ..db.insert_raw_query import create_batch_id, insert_shot_chart_detail

# All runtime parameters
from ..config.runtime_parameters import day, regular_season, playoff_season, current_season

# Cursor object type
from pyodbc import Cursor

# Run player_index: from parent 'etl' directory.
# Command: python3 -m src.etl.pipelines.run_daily

# Retrieve unique game ids from today's games (LeagueGameLog)
uq_game_ids = game_ids(
    date_from=day,
    date_to=day,
    season='2025', 
    season_type=regular_season
)
# Returns dictionary 
player_team_ids = player_and_team_id(
    game_ids=uq_game_ids
)

"""ENDPOINT CALLS"""

'''Process players section - shot_chart_detail and player_game_log'''
def process_players() -> tuple[list[PlayerShots], list[PlayerGame]]:
    all_player_shots: list[tuple] = []
    all_player_games: list[tuple] = []

    for player in player_team_ids:

        current_player_id = player['player_id']
        current_team_id = player['team_id']
        current_game_id = player['game_id']

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
            )
        )

    return all_player_shots, all_player_games


'''Process games section - play_by_play_v3 and box_score_player_track_v3'''
def process_games() -> tuple[list[PlayByPlay], list[BoxScore]]:
    all_pbp_games = []
    all_bxs_games = []
    
    for game_id in uq_game_ids:

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
        )
    )
    
    # Final tuple that will be added as arguments in SQL INSERT
    all_bxs_games.append(
        (
            game_id,
            day,
            current_season,
            bxs,
        )
    )

    return all_pbp_games, all_bxs_games

p_shots, p_game = process_players()
pbp_games, bxs_games = process_games()




"""Run database engine"""
# Retrieve connection string containing env variables
connection_string = build_connection_string()
test_engine = SqlServerEngine(conn_string=connection_string)



# Activate connection
with test_engine.connect() as conn:
    # Turn autocommit off to run a transaction style
    conn.autocommit = False
    # Create cursor
    cursor: Cursor = conn.cursor()
    # Ensure fast execute remains off as it alters date types
    cursor.fast_executemany = False
    # Do i loop and store all the executions as variables (procedures), then execute all at once?
    # Can i store all the executions in variables then start a transaction, then execute all?

    try:
        # Current batch_id
        current_batch_id = cursor.execute(create_batch_id).fetchone[0]


        cursor.executemany(
            """
            INSERT INTO raw.shot_chart_detail (player_id, game_id, game_date, season, json_payload, payload_hash, batch_id)
            VALUES (@player_id, @game_id, @game_date, @season, @json_payload, HASHBYTES('SHA2_256', CONVERT(NVARCHAR(MAX), @json_payload)), @batch_id)
            """, p_shots
        )
        
        
        cursor.executemany(
            """
            EXEC InsertPeople @name = ?, @age = ?
            """, [('Mike', 31), ('Anna', 32), ('Florence', 27)])


    except Exception as e:
        print('Error')
        conn.rollback()
    else:
        print()
        conn.commit()
    finally:



        # cursor.execute('SELECT * FROM dbo.court WHERE age >= 30 AND age <= 40 ORDER BY age DESC')
        results = cursor.fetchall()
    for r in results:
        print(r)

