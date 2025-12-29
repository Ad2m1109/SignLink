import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'dart:io';
import 'main.dart';
import 'theme/app_theme.dart';

class SignLanguagePage extends StatefulWidget {
  const SignLanguagePage({super.key});

  @override
  State<SignLanguagePage> createState() => _SignLanguagePageState();
}

class _SignLanguagePageState extends State<SignLanguagePage> {
  CameraController? _controller;
  String gestureText = "No gesture detected";
  final PoseDetector _poseDetector =
      PoseDetector(options: PoseDetectorOptions());
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _initializeCamera() {
    if (cameras.isEmpty) {
      debugPrint('No cameras found');
      return;
    }

    _controller = CameraController(
      cameras[0],
      ResolutionPreset.medium,
      enableAudio: false,
    );
    _controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }
      _controller?.startImageStream(_processImage);
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        debugPrint('Camera Error: ${e.code}');
      }
    });
  }

  Future<void> _processImage(CameraImage image) async {
    if (_isBusy) return;
    _isBusy = true;

    try {
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage == null) return;

      final poses = await _poseDetector.processImage(inputImage);
      if (poses.isNotEmpty) {
        _analyzePose(poses.first);
      } else {
        if (mounted) {
          setState(() {
            gestureText = "No gesture detected";
          });
        }
      }
    } catch (e) {
      debugPrint("Error processing image: $e");
    } finally {
      _isBusy = false;
    }
  }

  void _analyzePose(Pose pose) {
    final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];

    if (rightWrist != null && rightShoulder != null) {
      if (rightWrist.y < rightShoulder.y) {
        if (mounted) {
          setState(() {
            gestureText = "Hello / Wave";
          });
        }
      } else {
        if (mounted) {
          setState(() {
            gestureText = "No gesture detected";
          });
        }
      }
    }
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_controller == null) return null;

    final camera = cameras[0];
    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
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
    _controller?.stopImageStream();
    _controller?.dispose();
    _poseDetector.close();
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
              child: _controller != null && _controller!.value.isInitialized
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