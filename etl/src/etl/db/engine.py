import pyodbc
from pyodbc import Connection

"""PURPOSE OF engine.py"""
# Create skeleton for database connection
# DO NOT: Run SQL, contain biz logic, contain retry logic

# Class to connect to SQL Server using pyodbc driver
class SqlServerEngine:
    def __init__(self, conn_string: str):
        self.conn_string = conn_string

    def connect(self) -> Connection:
        return pyodbc.connect(self.conn_string) 
    # No need to close connection, handled by context manager
