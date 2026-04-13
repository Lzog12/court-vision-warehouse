from dotenv import load_dotenv
import os

load_dotenv()

# Load vars from .env
DB_PASSWORD = os.getenv('MSSQL_PW')
DB_UID = os.getenv('MSSQL_UID')
DB_SERVER = os.getenv('MSSQL_SERVER')
DB_NAME = os.getenv('DB_NAME')
DB_DRIVER = os.getenv('DB_DRIVER')

# Function to add all the variables in the connection string
def build_connection_string() -> str:
    return (
            "Driver={ODBC Driver 18 for SQL Server};"
            f"Server={DB_SERVER};"
            f"Database={DB_NAME};"
            f"Uid={DB_UID};"
            f"Pwd={DB_PASSWORD};"
            "Encrypt=yes;"
            "TrustServerCertificate=no;"
            "Connection Timeout=60;"
           )

"""ADD RETRIES
* MAX_RETRIES = 5
* INITIAL_BACKOFF_SECONDS = 1
* BACKOFF_MULTIPLIER = 2
"""


"""
'This script should also define the default runtime parameters for the ETL - 
Values the pipeline uses unless explicitly overridden'

* Could create a separate file for this as they will be extensive parameters which end up reaching every endpoint
"""
