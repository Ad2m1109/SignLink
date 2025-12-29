from models import db, Invitation, User, Conversation
from modules.user_module import find_user_by_email
from modules.conversation_module import create_conversation

def send_invitation(sender_id, receiver_email):
    receiver = find_user_by_email(receiver_email)
    if not receiver:
        raise Exception("User not found")
    
    if sender_id == receiver.id:
        raise Exception("Cannot invite yourself")

    # Check if invitation already exists
    existing_invitation = Invitation.query.filter(
        ((Invitation.sender_id == sender_id) & (Invitation.receiver_id == receiver.id)) |
        ((Invitation.sender_id == receiver.id) & (Invitation.receiver_id == sender_id))
    ).filter(Invitation.status == 'pending').first()

    if existing_invitation:
        raise Exception("Invitation already pending")

    # Check if already friends (conversation exists)
    existing_conversation = Conversation.query.filter(
        ((Conversation.iduser1 == sender_id) & (Conversation.iduser2 == receiver.id)) |
        ((Conversation.iduser1 == receiver.id) & (Conversation.iduser2 == sender_id))
    ).first()

    if existing_conversation:
        raise Exception("Already friends")

    new_invitation = Invitation(sender_id=sender_id, receiver_id=receiver.id)
    db.session.add(new_invitation)
    db.session.commit()
    return new_invitation

def get_received_invitations(user_id):
    invitations = db.session.query(Invitation, User).join(User, Invitation.sender_id == User.id).filter(
        Invitation.receiver_id == user_id,
        Invitation.status == 'pending'
    ).all()
    
    return [{'id': inv.id, 'sender_name': user.name, 'sender_email': user.email, 'timestamp': inv.timestamp} for inv, user in invitations]

def get_sent_invitations(user_id):
    invitations = db.session.query(Invitation, User).join(User, Invitation.receiver_id == User.id).filter(
        Invitation.sender_id == user_id,
        Invitation.status == 'pending'
    ).all()
    
    return [{'id': inv.id, 'receiver_name': user.name, 'receiver_email': user.email, 'timestamp': inv.timestamp} for inv, user in invitations]

def respond_to_invitation(invitation_id, status):
    invitation = Invitation.query.get(invitation_id)
    if not invitation:
        raise Exception("Invitation not found")
    
    if status not in ['accepted', 'rejected']:
        raise Exception("Invalid status")

    invitation.status = status
    
    if status == 'accepted':
        create_conversation(invitation.sender_id, invitation.receiver_id)
    
    db.session.commit()
    return invitation
