from flask import Blueprint, request, jsonify
from modules.invitation_module import send_invitation, get_received_invitations, get_sent_invitations, respond_to_invitation

invitation_bp = Blueprint('invitation', __name__)

@invitation_bp.route('/send', methods=['POST'])
def send_invitation_route():
    data = request.json
    try:
        send_invitation(data['sender_id'], data['receiver_email'])
        return jsonify({'message': 'Invitation sent successfully'}), 201
    except Exception as e:
        print(f"Error sending invitation: {e}")
        return jsonify({'message': str(e)}), 400

@invitation_bp.route('/received/<user_id>', methods=['GET'])
def get_received_invitations_route(user_id):
    try:
        invitations = get_received_invitations(user_id)
        return jsonify(invitations), 200
    except Exception as e:
        print(f"Error getting received invitations: {e}")
        return jsonify({'message': str(e)}), 400

@invitation_bp.route('/sent/<user_id>', methods=['GET'])
def get_sent_invitations_route(user_id):
    try:
        invitations = get_sent_invitations(user_id)
        return jsonify(invitations), 200
    except Exception as e:
        print(f"Error getting sent invitations: {e}")
        return jsonify({'message': str(e)}), 400

@invitation_bp.route('/respond', methods=['POST'])
def respond_to_invitation_route():
    data = request.json
    try:
        respond_to_invitation(data['invitation_id'], data['status'])
        return jsonify({'message': f'Invitation {data["status"]}'}), 200
    except Exception as e:
        return jsonify({'message': str(e)}), 400
