from nba_api.stats.endpoints.shotchartdetail import ShotChartDetail

CONTEXT_MEASURE = 'FGA'

def shot_chart_detail(tm_id: int, pl_id: int, season: str, season_type: str, date_from: str, date_to: str) -> dict:

    try:
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

    except Exception as e:
        raise RuntimeError(f'ERROR: {e}') from e