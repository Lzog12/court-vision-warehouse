from nba_api.stats.endpoints.boxscoreplayertrackv3 import BoxScorePlayerTrackV3
from ..utils.decorators import endpoint_retry

@endpoint_retry #Decorator to apply retry/backoff and delay
def box_score_player_track_v3(gm_id: str) -> dict:
    
    bxs_track_obj = BoxScorePlayerTrackV3(
        game_id=gm_id
    )

    raw_box_score = bxs_track_obj.player_stats.get_json() #Straight to JSON as it needs to be inserted into DB (NVARCHAR)

    return raw_box_score