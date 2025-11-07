import mysql.connector

config = {
    'user': 'root',
    'password': 'root',
    'host': 'localhost',  # Remove the port from here
    'port': 3306,         # Add the port as a separate key
    'database': 'personnemuette',
    'raise_on_warnings': True,
}

link = mysql.connector.connect(**config)
