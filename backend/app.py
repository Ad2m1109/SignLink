from flask import Flask
from flask_cors import CORS
from flask_migrate import Migrate
from flask_socketio import SocketIO
from config.database import Config
from models import db
from controllers.user_controller import user_bp
from controllers.conversation_controller import conversation_bp
from controllers.message_controller import message_bp
from controllers.invitation_controller import invitation_bp
from manage import create_database_if_not_exists

app = Flask(__name__)
app.config.from_object(Config)
CORS(app)
socketio = SocketIO(app, cors_allowed_origins="*")

# Ensure the physical database exists before SQLAlchemy initialization.
# This will create the database itself (server-level) if it does not exist.
create_database_if_not_exists()

db.init_app(app)
migrate = Migrate(app, db)


# Register blueprints
app.register_blueprint(user_bp, url_prefix='/users')
app.register_blueprint(conversation_bp, url_prefix='/conversations')
app.register_blueprint(message_bp, url_prefix='/messages')
app.register_blueprint(invitation_bp, url_prefix='/invitations')

# Import socket handlers after socketio initialization
from controllers.socket_controller import register_socket_handlers
register_socket_handlers(socketio)

if __name__ == '__main__':
    # Create missing tables from models if they don't exist yet. Using
    # db.create_all() is a convenience step for development; in production
    # you should rely on migrations (Flask-Migrate / Alembic).
    with app.app_context():
        try:
            db.create_all()
            print("Database tables ensured (db.create_all() completed).")
        except Exception as e:
            print(f"Error ensuring database tables: {e}")

    socketio.run(app, debug=True)
