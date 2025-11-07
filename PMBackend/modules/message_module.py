from models import db, Message

def create_message(idcnv, iduser, contenu):
    new_message = Message(idcnv=idcnv, iduser=iduser, contenu=contenu)
    db.session.add(new_message)
    db.session.commit()