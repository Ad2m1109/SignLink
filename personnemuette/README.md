# 🤝 HandTalk

**HandTalk** is a Flutter-based communication application designed to break down barriers for individuals with speech impairments. Using real-time sign language recognition and text-to-speech conversion, HandTalk empowers everyone to communicate naturally and effortlessly.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![ML Kit](https://img.shields.io/badge/ML_Kit-4285F4?style=for-the-badge&logo=google&logoColor=white)

## ✨ Features

### 🎯 Core Features
- **🤖 Real-time Sign Language Recognition** - AI-powered gesture detection using Google ML Kit Pose Detection
- **🗣️ Text-to-Speech Conversion** - Convert recognized gestures to spoken words
- **💬 Instant Messaging** - Chat with friends using text or sign language
- **👥 Friend Management** - Send and receive friend invitations
- **📱 Guest Mode** - Try gesture-to-speech without creating an account
- **🌓 Dark Mode Support** - Full theme switching for comfortable viewing
- **🎨 Modern UI/UX** - Material 3 design with smooth animations

### 🔐 Authentication
- Secure sign-up and sign-in
- Email validation
- Password strength requirements
- Remember me functionality

### 👫 Social Features
- Send friend invitations via email
- Accept or reject incoming invitations
- View sent and received invitations
- Search friends list
- Real-time conversation polling

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / VS Code with Flutter extensions
- A physical device or emulator with camera support

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/handtalk.git
   cd handtalk
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API endpoint**
   
   Update the API base URL in `lib/services/api_service.dart`:
   ```dart
   static const String baseUrl = 'YOUR_API_ENDPOINT';
   ```

4. **Run the app**
   ```bash
   # For Android
   flutter run -d android
   
   # For iOS
   flutter run -d ios
   
   # For Linux
   flutter run -d linux
   ```

## 📁 Project Structure

```
lib/
├── main.dart                      # App entry point
├── theme/
│   └── app_theme.dart            # Design system & theme configuration
├── services/
│   └── api_service.dart          # Backend API integration
├── utils/
│   └── user_preferences.dart     # Local storage utilities
├── invitations/
│   ├── invitations_page.dart     # Invitations list view
│   └── send_invitation_page.dart # Send invitation form
├── welcome_screen.dart           # Landing page
├── sign_in_page.dart             # Authentication - Sign In
├── sign_up_page.dart             # Authentication - Sign Up
├── main_screen.dart              # Home page with friends list
├── conversation_page.dart        # Chat interface
├── sign_language.dart            # Sign language recognition
├── another_screen.dart           # Guest mode
└── about_page.dart               # App information
```

## 🎨 Design System

HandTalk uses a unified design system with:

- **Color Palette**: Deep Purple (#6750A4) and Teal (#03DAC6)
- **Typography**: Google Fonts - Outfit
- **Spacing**: 8px grid system
- **Components**: Reusable buttons, inputs, cards, and avatars
- **Animations**: Smooth transitions using flutter_animate

## 📦 Dependencies

### Core Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  camera: ^0.10.5
  google_mlkit_pose_detection: ^0.11.0
  flutter_tts: ^3.8.3
  google_fonts: ^6.1.0
  flutter_animate: ^4.3.0
  shared_preferences: ^2.2.2
  http: ^1.1.2
```

## 🛠️ Configuration

### Camera Permissions

**Android** - Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-feature android:name="android.hardware.camera"/>
```

**iOS** - Add to `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>Camera access is required for sign language recognition</string>
```

### API Integration

The app requires a backend API with the following endpoints:

- `POST /api/auth/signin` - User authentication
- `POST /api/auth/signup` - User registration
- `GET /api/users/:id` - Get user profile
- `GET /api/users/email/:email` - Get user by email
- `POST /api/invitations/send` - Send friend invitation
- `GET /api/invitations/received/:userId` - Get received invitations
- `GET /api/invitations/sent/:userId` - Get sent invitations
- `PUT /api/invitations/:id/respond` - Accept/reject invitation
- `GET /api/conversations/:userId/:friendEmail` - Get conversation ID
- `GET /api/conversations/:id/messages` - Get conversation messages
- `POST /api/conversations/:id/messages` - Send message

## 🤖 Sign Language Recognition

HandTalk uses **Google ML Kit Pose Detection** to analyze camera input and recognize gestures:

- Real-time pose landmark detection
- Gesture analysis based on body keypoints
- Currently supports basic gestures (Hello/Wave)
- Expandable to custom gesture recognition

### Adding New Gestures

To add new gesture recognition, modify `_analyzePose()` in `sign_language.dart`:

```dart
void _analyzePose(Pose pose) {
  final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];
  final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
  
  // Add your gesture logic here
  if (rightWrist != null && rightShoulder != null) {
    if (rightWrist.y < rightShoulder.y) {
      setState(() {
        gestureText = "Hello / Wave";
      });
    }
  }
}
```

## 📱 Screenshots

### Light Mode
| Welcome | Sign In | Home | Chat |
|---------|---------|------|------|
| ![Welcome](screenshots/welcome_light.png) | ![Sign In](screenshots/signin_light.png) | ![Home](screenshots/home_light.png) | ![Chat](screenshots/chat_light.png) |

### Dark Mode
| Welcome | Sign In | Home | Chat |
|---------|---------|------|------|
| ![Welcome](screenshots/welcome_dark.png) | ![Sign In](screenshots/signin_dark.png) | ![Home](screenshots/home_dark.png) | ![Chat](screenshots/chat_dark.png) |

## 🧪 Testing

Run tests with:
```bash
flutter test
```

## 🔧 Troubleshooting

### Camera not initializing
- Ensure camera permissions are granted
- Check if the device has a working camera
- Verify camera package version compatibility

### Pose detection not working
- Ensure ML Kit models are downloaded
- Check internet connection for first-time model download
- Verify google_mlkit_pose_detection package is properly configured

### Build errors
```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Rebuild
flutter run
```

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'feat: Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Commit Convention
We follow [Conventional Commits](https://www.conventionalcommits.org/):
- `feat:` - New features
- `fix:` - Bug fixes
- `docs:` - Documentation changes
- `style:` - Code style changes (formatting, etc.)
- `refactor:` - Code refactoring
- `test:` - Adding tests
- `chore:` - Maintenance tasks

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Authors

- **Your Name** - *Initial work* - [YourGitHub](https://github.com/yourusername)

## 🙏 Acknowledgments

- Google ML Kit team for pose detection capabilities
- Flutter team for the amazing framework
- All contributors who help improve HandTalk

## 📞 Support

For support, email support@handtalk.app or join our Slack channel.

## 🗺️ Roadmap

- [ ] Enhanced gesture recognition with more signs
- [ ] Video call support
- [ ] Group conversations
- [ ] Gesture tutorials and learning mode
- [ ] Multi-language support
- [ ] Offline mode
- [ ] Cloud backup for conversations
- [ ] Custom gesture creation
- [ ] Accessibility improvements
- [ ] Web version

## 📊 Status

![Build Status](https://img.shields.io/badge/build-passing-brightgreen)
![Version](https://img.shields.io/badge/version-1.0.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)

---

<p align="center">Made with ❤️ for accessibility</p>
<p align="center">© 2024 HandTalk. All rights reserved.</p>