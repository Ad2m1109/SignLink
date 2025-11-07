from config.database import link
import hashlib

def create_user(name, email, password):
    cursor = link.cursor()
    hashed_password = hashlib.sha256(password.encode()).hexdigest()
    query = "INSERT INTO user (name, email, password) VALUES (%s, %s, %s)"
    values = (name, email, hashed_password)
    cursor.execute(query, values)
    link.commit()
    cursor.close()

def find_user_by_email(email):
    cursor = link.cursor(dictionary=True)  # Use dictionary cursor
    query = "SELECT * FROM user WHERE email = %s"
    cursor.execute(query, (email,))
    user = cursor.fetchone()
    cursor.close()
    return user

def authenticate_user(email, password):
    cursor = link.cursor(dictionary=True)
    query = "SELECT * FROM user WHERE email = %s AND password = %s"
    hashed_password = hashlib.sha256(password.encode()).hexdigest()
    cursor.execute(query, (email, hashed_password))
    user = cursor.fetchone()
    cursor.close()
    return user

def get_user_profile(user_id):
    cursor = link.cursor(dictionary=True)
    query_user = "SELECT name, email FROM user WHERE id = %s"
    query_friends = """
        SELECT u.email 
        FROM conversation c
        JOIN user u ON (c.iduser1 = u.id OR c.iduser2 = u.id)
        WHERE (c.iduser1 = %s OR c.iduser2 = %s) AND u.id != %s
    """
    cursor.execute(query_user, (user_id,))
    user = cursor.fetchone()
    if user:
        cursor.execute(query_friends, (user_id, user_id, user_id))
        friends = [row['email'] for row in cursor.fetchall()]
        user['friends'] = friends
    cursor.close()
    return user

def create_conversation(user1_id, user2_id):
    cursor = link.cursor()
    query = "INSERT INTO conversation (iduser1, iduser2) VALUES (%s, %s)"
    cursor.execute(query, (user1_id, user2_id))
    link.commit()
    cursor.close()

def get_conversation_messages(conversation_id):
    cursor = link.cursor(dictionary=True)
    query = """
        SELECT idmessage, iduser, contenu, timestamp
        FROM message
        WHERE idcnv = %s
        ORDER BY timestamp ASC
    """
    cursor.execute(query, (conversation_id,))
    messages = cursor.fetchall()
    cursor.close()
    return messages

def get_conversation_id(user_id, friend_email):
    cursor = link.cursor(dictionary=True)
    query = """
        SELECT c.idconv
        FROM conversation c
        JOIN user u1 ON c.iduser1 = u1.id
        JOIN user u2 ON c.iduser2 = u2.id
        WHERE (c.iduser1 = %s AND u2.email = %s)
           OR (c.iduser2 = %s AND u1.email = %s)
    """
    cursor.execute(query, (user_id, friend_email, user_id, friend_email))
    result = cursor.fetchone()
    cursor.close()
    if result:
        return str(result['idconv'])  # Convert to string
    else:
        raise Exception("Conversation not found")

def add_message(conversation_id, user_id, content, message_type='text', voice_path=None):
    cursor = link.cursor()
    query = """
        INSERT INTO message (idcnv, iduser, contenu, message_type, voice_path)
        VALUES (%s, %s, %s, %s, %s)
    """
    cursor.execute(query, (conversation_id, user_id, content, message_type, voice_path))
    link.commit()
    cursor.close()
