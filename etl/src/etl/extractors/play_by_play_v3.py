from nba_api.stats.endpoints.playbyplayv3 import PlayByPlayV3


def play_by_play_v3(gm_id: str) -> dict:

    game_obj = PlayByPlayV3(
        game_id=gm_id
    )

    raw_game = game_obj.get_dict()

    return raw_game

