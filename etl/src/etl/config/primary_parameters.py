"""
Provide primary parameters for all endpoints

Primary because we are 

Game ids retrieved from LeagueGameLog
Team ids retrieved from LeagueGameLog
Player ids retrieved from BoxScoreAdvancedV3
"""
from nba_api.stats.endpoints.leaguegamelog import LeagueGameLog
from nba_api.stats.endpoints import BoxScoreAdvancedV3
from tqdm import tqdm

# Initial parameters/ primary_parameters.py
# Runtime parameters: date, season, season type

# Game ids and game dates, add parameters
def game_ids(date_from, date_to, season, season_type) -> list[str]:

    try:
        # Begin from retrieving all game id's of a given day
        games = LeagueGameLog(
            # Should be today's date
            date_from_nullable=date_from,
            date_to_nullable=date_to,
            season=season,
            season_type_all_star=season_type
        )
        print('SUCCESS RETRIEVAL PRIMARY PARAMETER LeagueGameLog')

        raw_games = games.get_dict()
        # UNUSED
        # headers = raw_games['resultSets'][0]['headers']
        rowset = raw_games['resultSets'][0]['rowSet']

        # Retrieve unique game dates. UNUSED - potentially useful for historical data load
        # Retrieve to provide dates to other endpoints eg. ShotChartDetail
        # unique_game_dates = sorted(list(set(row[5] for row in rowset)), reverse=False)

        # Convert to set to create uniqueness.
        unique_game_ids = sorted(list(set([row[4] for row in rowset])), reverse=False)

        return unique_game_ids

    except Exception as e:
        raise RuntimeError(f'ERROR: {e}') from e


# player and game ids into a dictionary using BoxScoreAdvancedV3
def player_and_team_id(game_ids: list[str]) -> dict[str, str | int]:
    # Holds the final returned structure of all players
    all_players = {}

    for gid in tqdm(game_ids, desc=f"Loading game id's for BoxScoreAdvancedV3"):
        tqdm.write(gid)
        try:
            raw_game = BoxScoreAdvancedV3(game_id=gid)
        
            game_bxs = raw_game.player_stats.get_dict()
            # ['gameId', 'teamId', 'teamCity', 'teamName', 'teamTricode', 'teamSlug', 'personId', 'firstName', 'familyName', 'nameI', 'playerSlug', 'position', 'comment', 'jerseyNum' ...
            game_bxs_headers = game_bxs['headers']
            game_bxs_rowset = game_bxs['data']

            # Loop over each player that has played in the game
            for row in game_bxs_rowset:
                # Current player (cp) placed in dictionary with all info for easy access
                # Assign player values to headers
                cp = dict(zip(game_bxs_headers, row))
                all_players[f'{cp['firstName']} {cp['familyName']}'] = {
                    'player_id': f'{cp['personId']}',
                    'team_id': f'{cp['teamId']}',
                    'game_id': f'{cp['gameId']}'
                }

        except Exception as e:
            raise RuntimeError(f'ERR OCCURRED FOR ID {gid} --- ERROR: {e}') from e

    return all_players



"""FILE"""
# Contains runtime parameters
# Parameters retrieved from LeagueGameLog -> BoxScoreAdvancedV3



"""
Default season?
Default season_type (regular/playoffs)?
Endpoint parameter dicts (per endpoint)


eg.
DEFAULT_SEASON = "2009-10"
DEFAULT_SEASON_TYPE = "Regular Season"  # or your enum mapping

ENDPOINT_PARAMS = {
    "player_game_log": {
        "season_type": DEFAULT_SEASON_TYPE,
        "date_from": None,
        "date_to": None,
    },
    "shot_chart_detail": {
        "context_measure": "FGA",
        "season_type": DEFAULT_SEASON_TYPE,
    },
}
"""