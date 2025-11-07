from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()

class User(db.Model):
    __tablename__ = 'user'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(100), unique=True, nullable=False)
    password = db.Column(db.String(255), nullable=False)

class Conversation(db.Model):
    __tablename__ = 'conversation'
    idconv = db.Column(db.Integer, primary_key=True)
    iduser1 = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    iduser2 = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)

class Message(db.Model):
    __tablename__ = 'message'
    idmessage = db.Column(db.Integer, primary_key=True)
    idcnv = db.Column(db.Integer, db.ForeignKey('conversation.idconv'), nullable=False)
    iduser = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    contenu = db.Column(db.Text, nullable=True)
    timestamp = db.Column(db.DateTime, server_default=db.func.now())
