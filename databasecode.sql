-- Create the database
CREATE DATABASE IF NOT EXISTS personnemuette;
USE personnemuette;

-- Create user table
CREATE TABLE IF NOT EXISTS user (
    id INT(11) NOT NULL AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    password VARCHAR(255) NOT NULL,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create conversation table
CREATE TABLE IF NOT EXISTS conversation (
    idconv INT(11) NOT NULL AUTO_INCREMENT,
    iduser1 INT(11) NOT NULL,
    iduser2 INT(11) NOT NULL,
    PRIMARY KEY (idconv),
    FOREIGN KEY (iduser1) REFERENCES user(id),
    FOREIGN KEY (iduser2) REFERENCES user(id),
    INDEX (iduser1, iduser2)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create message table
CREATE TABLE IF NOT EXISTS message (
    idcnv INT(11) NOT NULL,
    idmessage INT(11) NOT NULL AUTO_INCREMENT,
    contenu TEXT,
    iduser INT(11) NOT NULL,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (idmessage),
    FOREIGN KEY (idcnv) REFERENCES conversation(idconv),
    FOREIGN KEY (iduser) REFERENCES user(id),
    INDEX (idcnv)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;