from nba_api.stats.endpoints.leaguegamelog import LeagueGameLog
from ..utils.decorators import endpoint_retry

@endpoint_retry #Decorator to apply retry/backoff and delay
def league_game_log(season: str, season_type: str, date_from: str, date_to: str) -> dict:
    
    league_game_obj = LeagueGameLog(
        season=season, 
        season_type_all_star=season_type,
        date_from_nullable=date_from,
        date_to_nullable=date_to
    )

    raw_league_game = league_game_obj.get_json() #Straight to JSON as it needs to be inserted into DB (NVARCHAR)

    return raw_league_game