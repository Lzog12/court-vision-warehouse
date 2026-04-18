from nba_api.stats.endpoints.shotchartdetail import ShotChartDetail
from ..utils.decorators import endpoint_retry

CONTEXT_MEASURE = 'FGA'

@endpoint_retry #Decorator to apply retry/backoff and delay
def shot_chart_detail(tm_id: int, pl_id: int, season: str, season_type: str, date_from: str, date_to: str) -> dict:
    
    """
    Function to call ShotCharDetail endpoint with parameters to retrieve all shots from a given player in a given day

    :param tm_id: team id of current iteration
    :param pl_id: player id of current iteration
    :param season: season i.e. '2024-25', '2025-26'
    :param season_type: season segment i.e. regular season, playoffs
    :param date_from: start date
    :param date_to: end date
    
    :return: JSON payload containing shot data of a given player
    """

    shots_obj = ShotChartDetail(
        team_id=tm_id,
        player_id=pl_id,
        season_nullable=season,
        season_type_all_star=season_type,
        date_from_nullable=date_from,
        date_to_nullable=date_to,
        # Ensures made and missed field goals are returned
        context_measure_simple=CONTEXT_MEASURE
        )

    raw_shots = shots_obj.shot_chart_detail.get_json() #Straight to JSON as it needs to be inserted into DB (NVARCHAR)

    return raw_shots
