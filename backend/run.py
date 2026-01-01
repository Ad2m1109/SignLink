import os
import sys
from app import app, socketio, db
from manage import create_database_if_not_exists
from flask_migrate import upgrade

def run():
    print("--- Starting HandTalk Backend ---")
    
    print("1. Ensuring database exists...")
    create_database_if_not_exists()
    
    print("2. Applying database migrations...")
    with app.app_context():
        try:
            upgrade()
            print("Migrations applied successfully.")
        except Exception as e:
            print(f"Could not apply migrations: {e}")
            print("HINT: You might need to create an initial migration with 'flask db migrate -m \"Initial migration\"'")
            
        print("3. Ensuring database tables...")
        try:
            db.create_all()
            print("Database tables ensured.")
        except Exception as e:
            print(f"Error ensuring database tables: {e}")

    print("4. Starting development server with WebSocket support...")
    # Use eventlet if available, otherwise falls back to gevent or werkzeug
    # Disabling reloader to avoid AssertionError with eventlet
    socketio.run(app, host='0.0.0.0', port=5000, debug=True, use_reloader=False)

if __name__ == '__main__':
    run()
