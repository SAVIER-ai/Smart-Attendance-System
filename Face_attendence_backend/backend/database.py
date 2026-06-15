import mysql.connector
from config import *

def get_db_connection():
    try:
        conn = mysql.connector.connect(
            host=DB_HOST,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME
        )
        print("✅ Database connected successfully")
        return conn

    except mysql.connector.Error as err:
        print("❌ Error:", err)
        return None