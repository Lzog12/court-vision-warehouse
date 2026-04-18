from nba_api.stats.endpoints.playergamelog import PlayerGameLog
from ..utils.decorators import endpoint_retry

@endpoint_retry #Decorator to apply retry/backoff and delay
def player_game_log(pl_id: str, season: str, season_type: str, date_from: str, date_to: str) -> dict:

    player_game_obj = PlayerGameLog(
        player_id=pl_id,
        season=season, 
        season_type_all_star=season_type,
        date_from_nullable=date_from,
        date_to_nullable=date_to
    )
    
    raw_player_game = player_game_obj.get_json() #Straight to JSON as it needs to be inserted into DB (NVARCHAR)
    
    return raw_player_game
