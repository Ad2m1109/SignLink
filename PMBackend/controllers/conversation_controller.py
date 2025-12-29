from flask import Blueprint, request, jsonify
from modules.conversation_module import create_conversation, get_conversation_messages, get_conversation_id

conversation_bp = Blueprint('conversation', __name__)

@conversation_bp.route('/', methods=['POST'])
def create_conversation_route():
    data = request.json
    create_conversation(data['iduser1'], data['iduser2'])
    return jsonify({'message': 'Conversation created successfully'}), 201

@conversation_bp.route('/<conversation_id>/messages', methods=['GET'])
def get_messages(conversation_id):
    messages = get_conversation_messages(conversation_id)
    return jsonify(messages), 200

@conversation_bp.route('/get_conversation_id', methods=['POST'])
def get_conversation_id_route():
    data = request.json
    user_id = data['userId']
    friend_email = data['friendEmail']
    try:
        conversation_id = get_conversation_id(user_id, friend_email)
        return jsonify({'conversationId': str(conversation_id)}), 200  # Ensure it's a string
    except Exception as e:
        return jsonify({'message': str(e)}), 404
