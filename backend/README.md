# HandTalk Backend: Bi-LSTM Inference Engine

The HandTalk backend is a specialized inference server designed to process high-frequency landmark sequences and return real-time sign language predictions. It leverages a Bi-directional Long Short-Term Memory (Bi-LSTM) architecture to capture temporal dependencies in human gestures.

## 🛠️ Core Components

### 1. Bi-LSTM Inference Engine (`modules/sign_language_module.py`)
- **Model Architecture**: A 2-layer Bi-directional LSTM implemented in TensorFlow/Keras.
  - Layer 1: 64 units, Bi-LSTM (returns sequences).
  - Layer 2: 128 units, Bi-LSTM (returns final state).
  - Dense Layers: Relu activation followed by a Softmax output layer.
- **Input Specification**: Accepts a 3D tensor of shape `(Batch, 30, 99)`, where 99 represents 33 landmarks with (x, y, z) coordinates.
- **Singleton Pattern**: The model is loaded as a singleton to ensure memory efficiency and rapid inference response.

### 2. Real-Time Communication (`controllers/socket_controller.py`)
- **Socket.io Integration**: Handles full-duplex communication with the Flutter client.
- **Stream Handler**: Listens for `stream_data` events containing normalized landmark sequences.
- **Prediction Emission**: Emits `prediction_result` events back to the specific client session ID (`request.sid`).

### 3. Database & API (`models.py`, `controllers/`)
- **SQLAlchemy ORM**: Manages user profiles, friends, and conversation history.
- **RESTful Endpoints**: Handles non-real-time operations like authentication and invitation management.

## 📊 Data Pipeline Logic

1. **Reception**: Receives a 30-frame sequence of normalized landmarks.
2. **Pre-processing**: Validates the sequence length and shape.
3. **Inference**: Passes the tensor through the Bi-LSTM model.
4. **Post-processing**: Maps the Softmax output index to a human-readable label using `labels.txt`.
5. **Feedback**: Returns the predicted label to the frontend in < 50ms.

## 🚀 Development & Setup

### Prerequisites
- Python 3.10+
- TensorFlow 2.13.0
- MySQL Server

### Installation
```bash
pip install -r requirements.txt
```

### Running the Server
**Important**: Always use `run.py` to ensure proper WebSocket initialization:
```bash
python3 run.py
```

---
*Technical Note: The model is currently trained on a research dataset. For production deployment, quantization (TFLite/TensorRT) is recommended to further reduce latency.*
