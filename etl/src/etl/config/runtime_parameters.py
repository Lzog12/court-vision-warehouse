# Runtime parameters: date, season, season type, date from, date to
from datetime import datetime
from nba_api.stats.library.parameters import SeasonTypePlayoffs
from nba_api.stats.library.parameters import SeasonTypePlayoffs
from nba_api.stats.library.parameters import Season

# Function to manipulate date selection. If we want to test or retrieve another day's data
def get_date(override: bool = False, alternate_date: str = '') -> str:
    # If custom date is chosen
    if override:
        return alternate_date

    # DATE PARAMETER - mm/dd/yyyy
    today = datetime.today()
    # Account for time zone (day -1)
    day = datetime(day=today.day - 1, month=today.month, year=today.year).strftime('%m-%d-%Y')

    return day    


# Season parameters
regular_season = SeasonTypePlayoffs.regular
playoff_season = SeasonTypePlayoffs.playoffs

# Can send season parameters as '2009' or '2009-10'
current_season = Season.current_season
