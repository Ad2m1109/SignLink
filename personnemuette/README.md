# HandTalk Frontend: Real-Time Landmark Processing Client

The HandTalk frontend is a high-performance Flutter application that serves as the primary data acquisition and visualization layer for the sign language recognition pipeline. It handles real-time computer vision tasks on-device and manages low-latency communication with the inference backend.

## 🏗️ Technical Architecture

### 1. Landmark Extraction Pipeline (`lib/sign_language.dart`)
- **Google ML Kit Integration**: Utilizes the `google_mlkit_pose_detection` package to extract body landmarks at 30+ FPS.
- **Coordinate Normalization**: Implements on-device preprocessing to ensure model robustness:
  - **Centroid Subtraction**: Centers the landmarks relative to their geometric mean.
  - **Unit Scaling**: Scales landmarks to a unit hypersphere to handle varying user distances from the camera.
- **Sliding Window Buffer**: Maintains a 30-frame temporal buffer (`List<List<double>>`) to capture the dynamics of a gesture.

### 2. Real-Time Streaming (`lib/services/socket_service.dart`)
- **Socket.io Client**: Establishes a persistent WebSocket connection to the Flask backend.
- **Sequence Streaming**: Automatically triggers a `stream_data` event whenever the sliding window buffer is full.
- **Asynchronous Feedback**: Listens for `prediction_result` events and updates the UI state reactively using a `ValueNotifier`.

### 3. UI/UX & Design System (`lib/theme/app_theme.dart`)
- **Material 3 Design**: A modern, accessible interface built with custom theme tokens.
- **Micro-Animations**: Uses `flutter_animate` for smooth state transitions and user feedback.
- **Mock Mode Engine**: A built-in simulation layer for non-mobile platforms (Web/Linux) that generates synthetic landmark data to verify the backend pipeline.

## 📊 Data Flow Logic

1. **Capture**: `CameraController` captures raw image frames.
2. **Detect**: `PoseDetector` extracts (x, y, z) coordinates for 33 landmarks.
3. **Pre-process**: Landmarks are centered and scaled on the main thread (optimized for performance).
4. **Buffer**: The frame is added to a 30-frame sliding window.
5. **Stream**: The window is serialized and sent to the backend via WebSockets.
6. **Display**: The predicted label is received and displayed in real-time.

## 🚀 Development & Setup

### Prerequisites
- Flutter SDK 3.6.0+
- Android Studio / VS Code
- Physical Android/iOS device (for ML Kit support)

### Installation
```bash
flutter pub get
```

### Configuration
Update the backend IP address in `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'http://192.168.1.207:5000';
```

### Running the App
```bash
flutter run
```

---
*Technical Note: On non-mobile platforms, the app automatically switches to "Mock Mode," simulating the landmark extraction process for pipeline verification.*