from models import db, Conversation, Message

def create_conversation(iduser1, iduser2):
    new_conversation = Conversation(iduser1=iduser1, iduser2=iduser2)
    db.session.add(new_conversation)
    db.session.commit()

def get_conversation_messages(conversation_id):
    messages = Message.query.filter_by(idcnv=conversation_id).order_by(Message.timestamp.asc()).all()
    return [
        {
            'idmessage': msg.idmessage,
            'iduser': msg.iduser,
            'contenu': msg.contenu,
            'timestamp': msg.timestamp.isoformat()
        }
        for msg in messages
    ]
def get_conversation_id(user_id, friend_email):
    from modules.user_module import find_user_by_email
    friend = find_user_by_email(friend_email)
    if not friend:
        raise Exception("Friend not found")
    
    conversation = Conversation.query.filter(
        ((Conversation.iduser1 == user_id) & (Conversation.iduser2 == friend.id)) |
        ((Conversation.iduser1 == friend.id) & (Conversation.iduser2 == user_id))
    ).first()

    if conversation:
        return conversation.idconv
    
    new_conversation = Conversation(iduser1=user_id, iduser2=friend.id)
    db.session.add(new_conversation)
    db.session.commit()
    return new_conversation.idconv
