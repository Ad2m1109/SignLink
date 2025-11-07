from flask import Flask
from flask_cors import CORS  # Import CORS
from config.database import link
from controllers.user_controller import user_bp
from controllers.conversation_controller import conversation_bp
from controllers.message_controller import message_bp

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Register blueprints
app.register_blueprint(user_bp, url_prefix='/users')
app.register_blueprint(conversation_bp, url_prefix='/conversations')
app.register_blueprint(message_bp, url_prefix='/messages')

if __name__ == '__main__':
    link.ping(reconnect=True)  # Ensure database connection is active
    app.run(debug=True)
