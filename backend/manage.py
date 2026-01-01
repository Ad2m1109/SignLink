import os
import pymysql
import click
from dotenv import load_dotenv
from flask.cli import with_appcontext
from flask_migrate import upgrade

load_dotenv()

def create_database_if_not_exists():
    """Creates the database if it does not exist.

    This helper is exported so other modules (for example `app.py`) can
    ensure the database itself exists before SQLAlchemy tries to create
    tables or migrations are applied.
    """
    try:
        connection = pymysql.connect(
            host=os.getenv('DB_HOST'),
            user=os.getenv('DB_USER'),
            password=os.getenv('DB_PASSWORD'),
            port=int(os.getenv('DB_PORT'))
        )
        cursor = connection.cursor()
        db_name = os.getenv('DB_NAME')
        cursor.execute(f"CREATE DATABASE IF NOT EXISTS {db_name}")
        print(f"Database '{db_name}' created or already exists.")
        cursor.close()
        connection.close()
    except Exception as e:
        print(f"An error occurred during DB creation: {e}")
        exit(1)