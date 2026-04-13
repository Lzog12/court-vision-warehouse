from typing import NamedTuple # Lightweight object that works like a regular tuple but more readable

class PlayerShots(NamedTuple):
    player_id: int
    game_id: str
    day: str
    season: str
    shots: dict


class PlayerGame(NamedTuple):
    player_id: int
    game_id: str
    day: str
    season: str
    game: dict


class PlayByPlay(NamedTuple):
    game_id: str
    game_date: str
    season: str
    pbp_info: dict


class BoxScore(NamedTuple):
    game_id: str
    game_date: str
    season: str
    bxs_info: dict