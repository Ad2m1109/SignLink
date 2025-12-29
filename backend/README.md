# HandTalk Backend

This is the Flask backend for the HandTalk application. It handles user authentication, conversation management, messaging, and invitations.

## Project Structure

- `app.py`: Application entry point and blueprint registration.
- `config/`: Configuration files (database, etc.).
- `controllers/`: Request handlers (routes).
- `models.py`: Database models (SQLAlchemy).
- `modules/`: Business logic and helper functions.
- `migrations/`: Database migration scripts.

## Setup

1.  **Install Dependencies:**
    ```bash
    pip install -r requirements.txt
    ```

2.  **Configuration:**
    -   Ensure you have a MySQL database running.
    -   Update `config/database.py` or set environment variables in `.env` for database connection.

3.  **Run the Server:**
    ```bash
    flask run
    ```
    The server will start at `http://127.0.0.1:5000`.

## API Endpoints

### Users (`/users`)
-   `POST /add_user`: Register a new user.
-   `POST /login`: Authenticate a user.
-   `GET /<user_id>`: Get user profile.
-   `POST /get_user_by_email`: Get user details by email.
-   `POST /add_friend`: Add a friend (creates a conversation).

### Conversations (`/conversations`)
-   `GET /<conversation_id>/messages`: Get messages for a conversation.
-   `POST /get_conversation_id`: Get conversation ID between two users.

### Messages (`/messages`)
-   `POST /add`: Send a message.

### Invitations (`/invitations`)
-   `POST /send`: Send an invitation.
-   `GET /received/<user_id>`: Get received invitations.
-   `GET /sent/<user_id>`: Get sent invitations.
-   `POST /respond`: Respond to an invitation (accept/decline).
