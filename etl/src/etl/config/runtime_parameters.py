# Runtime parameters: date, season, season type, date from, date to
from datetime import datetime
from nba_api.stats.library.parameters import SeasonTypePlayoffs
from nba_api.stats.library.parameters import SeasonTypePlayoffs
from nba_api.stats.library.parameters import Season

# DATE PARAMETER - mm/dd/yyyy
today = datetime.today()
# Account for time zone (day -1)
day = datetime(day=today.day - 1, month=today.month, year=today.year).strftime('%m/%d/%Y')

# SHOT CHART DETAIL PARAMETERS
regular_season = SeasonTypePlayoffs.regular
playoff_season = SeasonTypePlayoffs.playoffs

# Can send season parameters as '2009' or '2009-10'
current_season = Season.current_season
