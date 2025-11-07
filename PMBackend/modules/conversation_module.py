from config.database import link

def create_conversation(iduser1, iduser2):
    cursor = link.cursor()
    query = "INSERT INTO conversation (iduser1, iduser2) VALUES (%s, %s)"
    values = (iduser1, iduser2)
    cursor.execute(query, values)
    link.commit()
    cursor.close()

def get_conversation_messages(conversation_id):
    cursor = link.cursor(dictionary=True)
    query = """
        SELECT idmessage, iduser, contenu, timestamp
        FROM message
        WHERE idcnv = %s
        ORDER BY timestamp ASC
    """  # Ensure iduser is included
    cursor.execute(query, (conversation_id,))
    messages = cursor.fetchall()
    cursor.close()
    return messages
