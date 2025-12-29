from models import db, User, Conversation
import hashlib

def create_user(name, email, password):
    hashed_password = hashlib.sha256(password.encode()).hexdigest()
    new_user = User(name=name, email=email, password=hashed_password)
    db.session.add(new_user)
    db.session.commit()

def find_user_by_email(email):
    return User.query.filter_by(email=email).first()

def authenticate_user(email, password):
    hashed_password = hashlib.sha256(password.encode()).hexdigest()
    return User.query.filter_by(email=email, password=hashed_password).first()

def get_user_profile(user_id):
    user = User.query.get(user_id)
    if not user:
        return None

    friends = db.session.query(User.email).join(Conversation, (Conversation.iduser1 == User.id) | (Conversation.iduser2 == User.id)).filter(
        ((Conversation.iduser1 == user_id) | (Conversation.iduser2 == user_id)) & (User.id != user_id)
    ).all()

    friend_emails = [email for email, in friends]

    return {
        'name': user.name,
        'email': user.email,
        'friends': friend_emails
    }
