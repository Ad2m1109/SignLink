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