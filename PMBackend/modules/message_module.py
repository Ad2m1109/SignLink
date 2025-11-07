from config.database import link

def create_message(idcnv, iduser, contenu):
    cursor = link.cursor()
    query = """
        INSERT INTO message (idcnv, iduser, contenu) 
        VALUES (%s, %s, %s)
    """  # Added iduser to the query
    values = (idcnv, iduser, contenu)
    cursor.execute(query, values)
    link.commit()
    cursor.close()
