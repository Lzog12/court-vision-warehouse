import pyodbc
from dotenv import load_dotenv
import os

load_dotenv()

# Load vars from .env
DB_PASSWORD = os.getenv('MSSQL_PW')
DB_UID = os.getenv('MSSQL_UID')
DB_SERVER = os.getenv('MSSQL_SERVER')
DB_NAME = os.getenv('DB_NAME')
DB_DRIVER = os.getenv('DB_DRIVER')

# print(pyodbc.drivers())

conn = pyodbc.connect(
            "Driver={ODBC Driver 18 for SQL Server};"
            f"Server={DB_SERVER};"
            f"Database={DB_NAME};"
            f"Uid={DB_UID};"
            f"Pwd={DB_PASSWORD};"
            "Encrypt=yes;"
            "TrustServerCertificate=no;"
            "Connection Timeout=60;")


cursor = conn.cursor()

player = "Steph"
player = "Lebron"
cursor.execute(f"SELECT * FROM dbo.court WHERE player NOT IN (?)", player)

results = cursor.fetchall()
for r in results:
    print(r)

conn.close()