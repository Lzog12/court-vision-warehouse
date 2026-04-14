from nba_api.stats.endpoints.playbyplayv3 import PlayByPlayV3


def play_by_play_v3(gm_id: str) -> dict:
    
    try:
        game_obj = PlayByPlayV3(
            game_id=gm_id
        )

        raw_game = game_obj.get_json() #Straight to JSON as it needs to be inserted into DB (NVARCHAR)

        return raw_game
    
    except Exception as e:
        raise RuntimeError(f'ERROR: {e}') from e