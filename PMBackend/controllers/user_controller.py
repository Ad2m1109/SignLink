from flask import Blueprint, request, jsonify
from modules.user_module import create_user, authenticate_user, get_user_profile, create_conversation, find_user_by_email

user_bp = Blueprint('user', __name__)

@user_bp.route('/add_user', methods=['POST'])
def create_user_route():
    data = request.json
    create_user(data['name'], data['email'], data['password'])
    return jsonify({'message': 'User created successfully'}), 201

@user_bp.route('/login', methods=['POST'])
def login_user_route():
    data = request.json
    user = authenticate_user(data['email'], data['password'])
    if user:
        return jsonify({
            'userId': user['id'],
            'name': user['name'],
            'token': 'dummy_token'  # Replace with actual token generation logic
        }), 200
    return jsonify({'message': 'Invalid email or password'}), 401

@user_bp.route('/<user_id>', methods=['GET'])
def get_user_profile_route(user_id):
    user = get_user_profile(user_id)
    if user:
        return jsonify(user), 200
    return jsonify({'message': 'User not found'}), 404

@user_bp.route('/add_friend', methods=['POST'])
def add_friend_route():
    data = request.json
    user1_id = data['user1_id']
    friend_email = data['friend_email']

    # Find the friend's user ID by email
    friend = find_user_by_email(friend_email)
    if not friend:
        return jsonify({'message': 'Friend not found'}), 404

    user2_id = friend['id']

    # Create a new conversation
    create_conversation(user1_id, user2_id)

    return jsonify({'message': 'Friend added and conversation created successfully'}), 201

@user_bp.route('/get_user_by_email', methods=['POST'])
def get_user_by_email_route():
    data = request.json
    email = data['email']
    user = find_user_by_email(email)
    if user:
        return jsonify({'name': user['name'], 'email': user['email']}), 200
    return jsonify({'message': 'User not found'}), 404
