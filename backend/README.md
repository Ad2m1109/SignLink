# HandTalk Backend: Real-Time Inference Engine

This directory contains the server-side inference pipeline responsible for temporal sequence processing, gesture classification, and WebSocket communication management.

---

## Architecture Overview

The backend implements a **stateless microservice architecture** optimized for horizontal scalability and low-latency inference. The system is designed around three core subsystems:

### 1. WebSocket Event Loop (Socket.io)
Manages bidirectional communication with Flutter clients through event-driven callbacks:
- `connect`: Establishes persistent connection, initializes client session
- `landmark_stream`: Receives normalized landmark vectors at 30 Hz
- `disconnect`: Cleans up client resources, logs session metrics

### 2. Preprocessing Pipeline
Transforms raw landmark data into model-ready tensors through multi-stage normalization:

```python
def preprocess_landmarks(raw_landmarks: np.ndarray) -> np.ndarray:
    """
    Applies geometric normalization to ensure invariance.
    
    Args:
        raw_landmarks: Shape (21, 3) for hand landmarks or (33, 3) for pose
        
    Returns:
        normalized: Shape (63,) flattened feature vector
    """
    # Stage 1: Translation invariance (centroid subtraction)
    centroid = np.mean(raw_landmarks[:, :2], axis=0)
    centered = raw_landmarks - np.concatenate([centroid, [0]])
    
    # Stage 2: Scale invariance (distance normalization)
    max_dist = np.max(np.linalg.norm(centered[:, :2], axis=1))
    if max_dist > 1e-6:  # Avoid division by zero
        scaled = centered / max_dist
    else:
        scaled = centered
    
    # Stage 3: Flatten to 1D vector
    return scaled.flatten()
```

### 3. Temporal Buffering & Inference
Maintains sliding windows of frames for sequence-based prediction:

```python
class TemporalBuffer:
    def __init__(self, window_size=30, feature_dim=63):
        self.buffer = deque(maxlen=window_size)
        self.window_size = window_size
        self.feature_dim = feature_dim
        
    def add_frame(self, features: np.ndarray) -> bool:
        """Adds frame to buffer, returns True if window is full."""
        self.buffer.append(features)
        return len(self.buffer) == self.window_size
    
    def get_sequence(self) -> np.ndarray:
        """Returns shape (1, window_size, feature_dim) tensor."""
        return np.array(self.buffer).reshape(1, self.window_size, self.feature_dim)
```

---

## Project Structure

```
backend/
├── run.py                    # Application entry point (Flask server initialization)
├── requirements.txt          # Python dependencies with pinned versions
├── config.py                 # Configuration management (env variables, hyperparameters)
├── models/
│   ├── bilstm_model.h5      # Pre-trained Bi-LSTM weights (TensorFlow SavedModel)
│   ├── label_encoder.pkl    # Scikit-learn LabelEncoder for class mapping
│   └── model_architecture.py # Model definition for training scripts
├── preprocessing/
│   ├── __init__.py
│   ├── normalization.py     # Landmark normalization utilities
│   └── augmentation.py      # Data augmentation for training (future)
├── inference/
│   ├── __init__.py
│   ├── predictor.py         # Inference engine with temporal buffering
│   └── postprocessing.py    # Confidence thresholding, label smoothing
├── api/
│   ├── __init__.py
│   ├── websocket_handler.py # Socket.io event handlers
│   └── http_routes.py       # REST endpoints (health checks, model info)
├── tests/
│   ├── test_preprocessing.py
│   ├── test_inference.py
│   └── test_websocket.py
└── logs/
    └── server.log           # Structured logging (timestamp, event, latency)
```

---

## Deep Dive: Model Inference Pipeline

### Asynchronous Prediction Flow

```python
from flask_socketio import SocketIO, emit
from inference.predictor import GesturePredictor

predictor = GesturePredictor(model_path='models/bilstm_model.h5')

@socketio.on('landmark_stream')
def handle_landmarks(data):
    """
    Processes incoming landmark data with temporal buffering.
    
    Args:
        data: {
            'landmarks': [[x1,y1,z1], [x2,y2,z2], ...],  # 21 hand keypoints
            'timestamp': float  # Client-side capture time
        }
    """
    try:
        # Preprocess raw landmarks
        features = preprocess_landmarks(np.array(data['landmarks']))
        
        # Add to temporal buffer
        if predictor.buffer.add_frame(features):
            # Buffer full, run inference
            sequence = predictor.buffer.get_sequence()
            prediction = predictor.predict(sequence)
            
            # Emit prediction back to client
            emit('prediction', {
                'label': prediction['label'],
                'confidence': prediction['confidence'],
                'latency_ms': prediction['inference_time'] * 1000
            })
    except Exception as e:
        emit('error', {'message': str(e)})
```

### Model Loading & Optimization

```python
import tensorflow as tf

class GesturePredictor:
    def __init__(self, model_path: str):
        # Load pre-trained model with optimization
        self.model = tf.keras.models.load_model(
            model_path,
            compile=False  # Skip recompilation for inference-only
        )
        
        # Convert to TensorFlow Lite for mobile deployment (optional)
        # self.model = self._convert_to_tflite(model_path)
        
        # Load label encoder
        with open('models/label_encoder.pkl', 'rb') as f:
            self.label_encoder = pickle.load(f)
    
    def predict(self, sequence: np.ndarray) -> dict:
        """
        Performs inference with timing metrics.
        
        Args:
            sequence: Shape (1, 30, 63)
            
        Returns:
            {
                'label': str,
                'confidence': float,
                'inference_time': float (seconds)
            }
        """
        start_time = time.time()
        
        # Forward pass
        predictions = self.model.predict(sequence, verbose=0)
        class_idx = np.argmax(predictions[0])
        confidence = float(predictions[0][class_idx])
        
        inference_time = time.time() - start_time
        
        return {
            'label': self.label_encoder.inverse_transform([class_idx])[0],
            'confidence': confidence,
            'inference_time': inference_time
        }
```

---

## API Documentation

### WebSocket Events

#### Client → Server

**Event**: `landmark_stream`  
**Payload**:
```json
{
  "landmarks": [
    [0.5, 0.3, 0.1],  // Thumb CMC
    [0.52, 0.28, 0.09],  // Thumb MCP
    ...  // 21 hand keypoints total
  ],
  "timestamp": 1704470400.123
}
```

#### Server → Client

**Event**: `prediction`  
**Payload**:
```json
{
  "label": "Hello",
  "confidence": 0.94,
  "latency_ms": 68.5
}
```

**Event**: `error`  
**Payload**:
```json
{
  "message": "Invalid landmark format: expected shape (21, 3)"
}
```

### REST Endpoints

#### `GET /health`
Health check endpoint for load balancers.

**Response**:
```json
{
  "status": "healthy",
  "model_loaded": true,
  "uptime_seconds": 3600
}
```

#### `GET /model/info`
Returns model metadata.

**Response**:
```json
{
  "architecture": "Bi-LSTM",
  "num_classes": 26,
  "input_shape": [30, 63],
  "parameters": 854320
}
```

---

## Configuration Management

### Environment Variables

Create a `.env` file in the backend directory:

```bash
# Flask Configuration
FLASK_ENV=production  # development | production
FLASK_DEBUG=0         # Enable debug mode (0 or 1)
SECRET_KEY=your_secret_key_here

# Server Settings
HOST=0.0.0.0          # Bind address (0.0.0.0 for all interfaces)
PORT=5000             # Server port

# Model Configuration
MODEL_PATH=models/bilstm_model.h5
LABEL_ENCODER_PATH=models/label_encoder.pkl
CONFIDENCE_THRESHOLD=0.75  # Minimum confidence for prediction emission

# Performance Tuning
BUFFER_SIZE=30        # Temporal window size (frames)
MAX_WORKERS=4         # Number of inference threads
ENABLE_GPU=true       # Use GPU acceleration if available

# Logging
LOG_LEVEL=INFO        # DEBUG | INFO | WARNING | ERROR
LOG_FILE=logs/server.log
```

### Loading Configuration

```python
# config.py
import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    FLASK_ENV = os.getenv('FLASK_ENV', 'development')
    HOST = os.getenv('HOST', '127.0.0.1')
    PORT = int(os.getenv('PORT', 5000))
    
    MODEL_PATH = os.getenv('MODEL_PATH', 'models/bilstm_model.h5')
    CONFIDENCE_THRESHOLD = float(os.getenv('CONFIDENCE_THRESHOLD', 0.75))
    BUFFER_SIZE = int(os.getenv('BUFFER_SIZE', 30))
```

---

## Performance Optimization

### 1. Model Quantization (TensorFlow Lite)

Reduce model size and inference latency by 4x with minimal accuracy loss:

```python
import tensorflow as tf

def convert_to_tflite(keras_model_path: str, output_path: str):
    """Converts Keras model to quantized TFLite format."""
    converter = tf.lite.TFLiteConverter.from_keras_model_file(keras_model_path)
    
    # Apply dynamic range quantization (weights: float32 → int8)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    
    tflite_model = converter.convert()
    with open(output_path, 'wb') as f:
        f.write(tflite_model)
```

### 2. Batch Inference (Future Enhancement)

For high-throughput scenarios, accumulate multiple client requests:

```python
class BatchedPredictor:
    def __init__(self, batch_size=8, max_latency_ms=100):
        self.batch_buffer = []
        self.batch_size = batch_size
        self.max_latency_ms = max_latency_ms
    
    async def predict(self, sequence):
        self.batch_buffer.append(sequence)
        if len(self.batch_buffer) >= self.batch_size:
            return await self._flush_batch()
        # Otherwise wait for timeout or full batch
```

### 3. GPU Memory Management

Prevent memory leaks during long-running inference:

```python
import tensorflow as tf

# Limit GPU memory growth
gpus = tf.config.list_physical_devices('GPU')
for gpu in gpus:
    tf.config.experimental.set_memory_growth(gpu, True)
```

---

## Deployment Guide

### Local Development

```bash
# Activate virtual environment
source venv/bin/activate  # Linux/Mac
# venv\Scripts\activate   # Windows

# Install dependencies
pip install -r requirements.txt

# Run development server
python run.py
```

### Production Deployment (Docker)

**Dockerfile**:
```dockerfile
FROM python:3.9-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Expose port
EXPOSE 5000

# Run server
CMD ["python", "run.py"]
```

**Build and Run**:
```bash
docker build -t handtalk-backend .
docker run -d -p 5000:5000 \
    -e FLASK_ENV=production \
    -e MODEL_PATH=/app/models/bilstm_model.h5 \
    handtalk-backend
```

### Kubernetes Deployment (Scalable Production)

**deployment.yaml**:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: handtalk-backend
spec:
  replicas: 3  # Horizontal scaling
  selector:
    matchLabels:
      app: handtalk-backend
  template:
    metadata:
      labels:
        app: handtalk-backend
    spec:
      containers:
      - name: backend
        image: handtalk-backend:latest
        ports:
        - containerPort: 5000
        resources:
          requests:
            memory: "512Mi"
            cpu: "500m"
          limits:
            memory: "1Gi"
            cpu: "1000m"
        env:
        - name: FLASK_ENV
          value: "production"
        - name: MODEL_PATH
          value: "/app/models/bilstm_model.h5"
```

---

## Testing & Validation

### Unit Tests

```bash
# Run all tests
pytest tests/

# Run with coverage report
pytest tests/ --cov=. --cov-report=html
```

### Load Testing (Locust)

Simulate 100 concurrent clients:

```python
# tests/load_test.py
from locust import User, task, between
import socketio

class HandTalkUser(User):
    wait_time = between(0.03, 0.05)  # 30 FPS
    
    def on_start(self):
        self.sio = socketio.Client()
        self.sio.connect('http://localhost:5000')
    
    @task
    def send_landmarks(self):
        landmarks = np.random.rand(21, 3).tolist()
        self.sio.emit('landmark_stream', {'landmarks': landmarks})
```

```bash
locust -f tests/load_test.py --host=http://localhost:5000
```

---

## Troubleshooting

### Issue: High Inference Latency (>200ms)

**Diagnosis**:
```python
# Add profiling to inference pipeline
import cProfile

profiler = cProfile.Profile()
profiler.enable()
prediction = predictor.predict(sequence)
profiler.disable()
profiler.print_stats(sort='cumulative')
```

**Solutions**:
1. Enable GPU acceleration (`ENABLE_GPU=true`)
2. Reduce temporal window size (`BUFFER_SIZE=20`)
3. Apply model quantization (see Optimization section)

### Issue: Memory Leaks During Long Sessions

**Diagnosis**:
```bash
# Monitor memory usage
watch -n 1 'ps aux | grep python'
```

**Solution**:
```python
# Clear Keras backend session periodically
import gc
from tensorflow.keras import backend as K

@socketio.on('disconnect')
def handle_disconnect():
    K.clear_session()
    gc.collect()
```

---

## Future Enhancements

1. **Model Versioning**: Implement A/B testing infrastructure for comparing model versions
2. **Explainability**: Integrate Grad-CAM visualizations for temporal attention
3. **Edge Deployment**: Compile models for TensorFlow Lite Micro (microcontrollers)
4. **Multi-Model Ensemble**: Combine Bi-LSTM with Transformer architectures for accuracy boost

---

## References

- Flask-SocketIO Documentation: https://flask-socketio.readthedocs.io/
- TensorFlow Performance Guide: https://www.tensorflow.org/guide/profiler
- WebSocket Protocol (RFC 6455): https://tools.ietf.org/html/rfc6455

---

## License

MIT License - See root directory LICENSE file