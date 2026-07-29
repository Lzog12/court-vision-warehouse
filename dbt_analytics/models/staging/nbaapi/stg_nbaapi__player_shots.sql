select
    *
from {{ source('nba_api', 'shot_chart_detail') }}