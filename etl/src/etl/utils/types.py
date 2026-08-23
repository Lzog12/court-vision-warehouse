from typing import NamedTuple # Lightweight object that works like a regular tuple but more readable

class PlayerShots(NamedTuple):
    player_id: int
    game_id: str
    game_date: str
    season: str
    season_segment: str
    shots_data: dict


class PlayerGame(NamedTuple):
    player_id: int
    game_id: str
    game_date: str
    season: str
    season_segment: str
    game_data: dict


class PlayByPlay(NamedTuple):
    game_id: str
    game_date: str
    season: str
    pbp_data: dict


class LeagueGame(NamedTuple):
    game_date: str
    season: str
    season_segment: str
    game_data: dict