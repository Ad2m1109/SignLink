from flask import Blueprint, request, jsonify
from modules.message_module import create_message
from modules.user_module import find_user_by_email

message_bp = Blueprint('message', __name__)

@message_bp.route('/add_user', methods=['POST'])
def create_message_route():
    data = request.json
    create_message(data['idcnv'], data['iduser'], data['contenu'])
    return jsonify({'message': 'Message created successfully'}), 201

@message_bp.route('/add', methods=['POST'])
def add_message_route():
    data = request.json
    conversation_id = data['conversationId']
    user_id = data['userId']
    content = data['content']

    try:
        create_message(conversation_id, user_id, content)
        return jsonify({'message': 'Message added successfully'}), 201
    except Exception as e:
        return jsonify({'message': str(e)}), 500

