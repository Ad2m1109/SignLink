# HandTalk: Real-Time Sign Language Recognition Pipeline

HandTalk is a research-ready prototype for real-time sign language recognition, bridging the gap between computer vision and accessible communication. The system implements a robust **Sequence-to-Label** deep learning pipeline that translates dynamic hand/body gestures into text and speech.

## 🏗️ Architecture

The system is built on a distributed architecture designed for low-latency inference and high scalability:

- **Frontend (Flutter)**: A cross-platform mobile application that handles high-frequency camera stream processing and real-time UI updates.
- **Data Pipeline (MediaPipe & Socket.io)**: Landmarks are extracted on-device and streamed via full-duplex WebSockets to the inference engine.
- **Backend (Flask & TensorFlow)**: A high-performance inference server hosting a Bi-directional LSTM model, optimized for temporal sequence analysis.

## 🧠 Deep Learning Logic: Sequence-to-Label

The core of HandTalk is its sophisticated data processing and classification pipeline:

### 1. Feature Extraction & Normalization
- **Landmark Detection**: The system extracts 21-33 MediaPipe landmarks per frame, capturing precise (x, y, z) coordinates of hand and body joints.
- **Centroid Subtraction**: To ensure translation invariance, all coordinates are normalized by subtracting the centroid of the landmark set.
- **Distance Scaling**: Landmarks are scaled relative to the maximum distance from the centroid, ensuring the model is robust to varying distances from the camera.

### 2. Temporal Modeling (Bi-LSTM)
- **Sliding Window Buffer**: Frames are collected into a **30-frame sliding window**, creating a 3D tensor of shape `(1, 30, Features)`.
- **Bi-directional LSTM**: The model uses two layers of Bi-LSTMs to capture temporal patterns in both forward and backward directions. This allows the system to understand the context of a gesture from start to finish, significantly improving accuracy over static frame analysis.
- **Softmax Classification**: The final dense layer outputs a probability distribution across gesture labels (e.g., "Hello", "Thank You", "I Love You").

## ⚡ Performance Optimization

- **WebSocket Streaming**: By using `Socket.io`, the system avoids the overhead of traditional HTTP requests, enabling real-time feedback loops.
- **Asynchronous Processing**: The Flutter frontend uses a non-blocking image stream, ensuring the UI remains responsive at 60 FPS while the ML pipeline runs in the background.
- **Mock Mode for Research**: A built-in simulation engine allows developers to test the backend pipeline on non-mobile platforms (Web/Linux) without requiring a physical camera or ML Kit support.

## 🚀 Setup & Deployment

### Backend
```bash
cd backend
pip install -r requirements.txt
python3 run.py
```

### Frontend
```bash
cd personne_muette
flutter pub get
flutter run
```

---
*This project is a prototype designed for academic research and further development in the field of assistive technologies.*


