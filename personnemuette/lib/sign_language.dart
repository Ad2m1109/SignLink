import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'dart:async';
import 'dart:math' as math;
import 'main.dart';
import 'theme/app_theme.dart';
import 'services/socket_service.dart';
import 'services/api_service.dart';

class SignLanguagePage extends StatefulWidget {
  const SignLanguagePage({super.key});

  @override
  State<SignLanguagePage> createState() => _SignLanguagePageState();
}

class _SignLanguagePageState extends State<SignLanguagePage> {
  CameraController? _controller;
  String gestureText = "No gesture detected";
  PoseDetector? _poseDetector;
  bool _isBusy = false;
  bool get _isMobile => !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);
  Timer? _mockTimer;
  
  // Sliding window buffer
  final List<List<double>> _frameBuffer = [];
  static const int _windowSize = 30;

  @override
  void initState() {
    super.initState();
    _initializePoseDetector();
    _initializeCamera();
    _initializeSocket();
  }

  void _initializeSocket() {
    SocketService().connect(ApiService.baseUrl);
    SocketService().predictionNotifier.addListener(() {
      if (mounted) {
        setState(() {
          gestureText = SocketService().predictionNotifier.value;
        });
      }
    });
  }

  void _initializePoseDetector() {
    if (_isMobile) {
      _poseDetector = PoseDetector(options: PoseDetectorOptions());
    } else {
      debugPrint("Running on non-mobile platform. ML Kit disabled. Using Mock Mode.");
    }
  }

  void _initializeCamera() {
    if (cameras.isEmpty) {
      debugPrint('No cameras found. Starting Mock Timer.');
      _startMockTimer();
      return;
    }

    _controller = CameraController(
      cameras[0],
      ResolutionPreset.medium,
      enableAudio: false,
    );
    _controller?.initialize().then((_) {
      if (!mounted) return;
      setState(() {});

      // startImageStream is only supported on Android/iOS
      if (_isMobile) {
        _controller?.startImageStream((image) {
          if (_isBusy) return;
          _isBusy = true;
          _processCameraImage(image);
        });
      } else {
        debugPrint("Camera stream not supported on this platform. Using Mock Mode.");
        _startMockTimer();
      }
    }).catchError((Object e) {
      if (e is CameraException) {
        debugPrint('Camera Error: ${e.code}');
      }
    });
  }

  Future<void> _processCameraImage(CameraImage image) async {
    try {
      if (_isMobile && _poseDetector != null) {
        final inputImage = _inputImageFromCameraImage(image);
        if (inputImage == null) return;

        final poses = await _poseDetector!.processImage(inputImage);
        if (poses.isNotEmpty) {
          _analyzePose(poses.first);
        } else {
          if (mounted) {
            setState(() {
              gestureText = "No gesture detected";
            });
          }
        }
      } else {
        // Mock Mode for Linux/Web
        _generateMockPose();
      }
    } catch (e) {
      debugPrint("Error processing image: $e");
    } finally {
      _isBusy = false;
    }
  }

  void _startMockTimer() {
    _mockTimer?.cancel();
    _mockTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted) {
        _generateMockPose();
      }
    });
  }

  void _generateMockPose() {
    // Generate 33 random landmarks to simulate movement
    List<double> mockKeypoints = [];
    final random = math.Random();
    for (int i = 0; i < 99; i++) {
      mockKeypoints.add(random.nextDouble());
    }

    final normalized = _normalizeKeypoints(mockKeypoints, 33);
    _frameBuffer.add(normalized);
    if (_frameBuffer.length > _windowSize) {
      _frameBuffer.removeAt(0);
    }

    if (_frameBuffer.length == _windowSize) {
      _streamSequenceToBackend();
    }

    if (mounted) {
      setState(() {
        gestureText = "Mocking Hand Data (Web/Linux)...";
      });
    }
  }

  void _analyzePose(Pose pose) {
    // Extract keypoints (x, y, z) - Using 33 body landmarks for now
    List<double> keypoints = [];
    for (final landmark in pose.landmarks.values) {
      keypoints.add(landmark.x);
      keypoints.add(landmark.y);
      keypoints.add(landmark.z);
    }

    if (keypoints.length == 99) { // 33 landmarks * 3
      // 1. Coordinate Normalization
      final normalizedKeypoints = _normalizeKeypoints(keypoints, 33);

      // 2. Sliding Window Buffer
      _frameBuffer.add(normalizedKeypoints);
      if (_frameBuffer.length > _windowSize) {
        _frameBuffer.removeAt(0);
      }

      // 3. Trigger Backend Streaming
      if (_frameBuffer.length == _windowSize) {
        _streamSequenceToBackend();
      }
    }

    // Simple heuristic for UI feedback
    final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    if (rightWrist != null && rightShoulder != null) {
      if (rightWrist.y < rightShoulder.y) {
        if (mounted) {
          setState(() {
            gestureText = "Pose Detected / Active";
          });
        }
      }
    }
  }

  List<double> _normalizeKeypoints(List<double> keypoints, int count) {
    // Centroid Subtraction
    double sumX = 0, sumY = 0, sumZ = 0;
    for (int i = 0; i < keypoints.length; i += 3) {
      sumX += keypoints[i];
      sumY += keypoints[i + 1];
      sumZ += keypoints[i + 2];
    }
    double centerX = sumX / count;
    double centerY = sumY / count;
    double centerZ = sumZ / count;

    List<double> centered = [];
    double maxDist = 0;
    for (int i = 0; i < keypoints.length; i += 3) {
      double dx = keypoints[i] - centerX;
      double dy = keypoints[i + 1] - centerY;
      double dz = keypoints[i + 2] - centerZ;
      centered.addAll([dx, dy, dz]);
      
      double dist = dx * dx + dy * dy + dz * dz;
      if (dist > maxDist) maxDist = dist;
    }

    // Distance Scaling
    maxDist = maxDist > 0 ? math.sqrt(maxDist) : 1.0;
    return centered.map((val) => val / maxDist).toList();
  }

  void _streamSequenceToBackend() {
    SocketService().streamSequence(_frameBuffer);
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_controller == null) return null;

    final camera = cameras[0];
    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      var rotationCompensation =
          _orientations[_controller!.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        rotationCompensation =
            (sensorOrientation + rotationCompensation) % 360;
      } else {
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) return null;

    if (image.planes.length != 1) return null;
    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: InputImageFormat.bgra8888,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  static const _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  @override
  void dispose() {
    if (_isMobile) {
      _controller?.stopImageStream();
    }
    _controller?.dispose();
    _poseDetector?.close();
    _mockTimer?.cancel();
    SocketService().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          "Sign Language",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Camera Preview
          Expanded(
            flex: 7,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(AppTheme.radiusXLarge),
                ),
                boxShadow: AppTheme.elevatedShadow,
              ),
              clipBehavior: Clip.antiAlias,
              child: _isMobile
                  ? (_controller != null && _controller!.value.isInitialized
                      ? CameraPreview(_controller!)
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                color: AppTheme.primaryColor,
                              ),
                              const SizedBox(height: AppTheme.spacing16),
                              Text(
                                "Initializing camera...",
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: AppTheme.fontSizeBody,
                                ),
                              ),
                            ],
                          ),
                        ))
                  : Container(
                      color: Colors.black87,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.computer,
                                size: 80, color: Colors.blueAccent),
                            const SizedBox(height: 20),
                            Text(
                              "Mock Mode Active",
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Streaming simulated hand data to backend",
                              style: GoogleFonts.outfit(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 30),
                            const CircularProgressIndicator(
                                color: Colors.blueAccent),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
          
          // Control Panel
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(AppTheme.spacing24),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppTheme.radiusXLarge),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Gesture Display Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppTheme.spacing20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor.withOpacity(0.1),
                          AppTheme.secondaryColor.withOpacity(0.1),
                        ],
                      ),
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusLarge),
                      border: Border.all(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.gesture,
                          color: AppTheme.primaryColor,
                          size: 28,
                        ),
                        const SizedBox(width: AppTheme.spacing12),
                        Flexible(
                          child: Text(
                            gestureText,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: AppTheme.fontSizeTitle,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn().scale(),
                  const SizedBox(height: AppTheme.spacing24),
                  
                  // Send Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final message = gestureText.trim();
                        if (message.isNotEmpty &&
                            message != "No gesture detected") {
                          Navigator.pop(context, message);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  const Text('No gesture detected to send'),
                              backgroundColor: AppTheme.warningColor,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusMedium,
                                ),
                              ),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.send, size: 22),
                      label: Text(
                        "Send Gesture",
                        style: GoogleFonts.outfit(
                          fontSize: AppTheme.fontSizeBody,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppTheme.spacing16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}