from datetime import datetime
# This is where dates for the season are handled



# Provide way (override) to alter the date and retrieve earlier dates



"""
Date and time utility helpers for ETL pipelines.

This module contains small, pure functions for working with dates and
date ranges used by extractors and pipelines, such as:
- Computing rolling or fixed date windows
- Converting season identifiers to date ranges
- Parsing and normalizing date inputs
- Supporting incremental load window calculations

Functions in this module must be deterministic and side-effect free.
No database access, API calls, or orchestration logic should live here.
"""
