# HandTalk

HandTalk is a communication platform designed to assist individuals with speech impairments. It provides features like text messaging, voice messaging, and sign language recognition to facilitate seamless communication.

## Features

- **User Registration and Login**: Secure user authentication.
- **Text Messaging**: Send and receive text messages in real-time.
- **Voice Messaging**: Record and send voice messages.
- **Sign Language Recognition**: Detect and translate sign language gestures.
- **Friend Management**: Add friends and start conversations.
- **Dark Mode**: Toggle between light and dark themes.

## Technologies Used

- **Frontend**: Flutter
- **Backend**: Flask
- **Database**: MySQL
- **APIs**: RESTful APIs for communication between the frontend and backend.

## Setup Instructions

### Prerequisites

- Flutter SDK (>=3.6.0)
- Python (>=3.8)
- MySQL Server
- Node.js (for web-based camera access)

### Backend Setup

1. Navigate to the `backend` directory.
2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
3. Configure the database connection in `config/database.py` or `.env`.
4. Run the backend server:
   ```bash
   python3 run.py
   ```

### Frontend Setup

1. Navigate to the `personnemuette` directory.
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the Flutter app:
   ```bash
   flutter run
   ```

### Database Setup

1. Execute the SQL script in `databasecode.sql` to create the required database and tables:
   ```sql
   source databasecode.sql;
   ```

## Usage

1. Register a new user or log in with existing credentials.
2. Add friends using their email addresses.
3. Start conversations and send text or voice messages.
4. Use the sign language recognition feature to translate gestures into text or speech.

## Project Structure

- **Frontend**: `personnemuette` (Flutter app)
- **Backend**: `backend` (Flask app)
- **Database**: `databasecode.sql` (SQL schema)

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request with your changes.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.


