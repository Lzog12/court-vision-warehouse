from nba_api.stats.endpoints.boxscoreplayertrackv3 import BoxScorePlayerTrackV3

def box_score_player_track_v3(gm_id: str) -> dict:
    
    bxs_track_obj = BoxScorePlayerTrackV3(
        game_id=gm_id
    )

    raw_box_score = bxs_track_obj.player_stats.get_dict()

    return raw_box_score