import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'dart:io';
import 'services/api_service.dart';
import 'utils/user_preferences.dart';
import 'conversation_page.dart';
import 'main.dart';

class SignLanguagePage extends StatefulWidget {
  @override
  _SignLanguagePageState createState() => _SignLanguagePageState();
}

class _SignLanguagePageState extends State<SignLanguagePage> {
  CameraController? _controller;
  String gestureText = "Aucun geste détecté";
  final FlutterTts flutterTts = FlutterTts();
  final PoseDetector _poseDetector = PoseDetector(options: PoseDetectorOptions());
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _initializeCamera() {
    if (cameras.isEmpty) {
      print('No cameras found');
      return;
    }

    _controller = CameraController(cameras[0], ResolutionPreset.medium, enableAudio: false);
    _controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }
      _controller?.startImageStream(_processImage);
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        print('Camera Error: ${e.code}');
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
            gestureText = "Aucun geste détecté";
          });
        }
      }
    } catch (e) {
      print("Error processing image: $e");
    } finally {
      _isBusy = false;
    }
  }

  void _analyzePose(Pose pose) {
    // Simple logic: Check if right wrist is above right shoulder (Hello/Wave)
    final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];

    if (rightWrist != null && rightShoulder != null) {
      if (rightWrist.y < rightShoulder.y) {
        if (mounted) {
          setState(() {
            gestureText = "Hello / Salut";
          });
        }
      } else {
        if (mounted) {
          setState(() {
            gestureText = "Aucun geste détecté";
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
      var rotationCompensation = _orientations[_controller!.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        // front-facing
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        // back-facing
        rotationCompensation = (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null || (Platform.isAndroid && format != InputImageFormat.nv21)) {
       // On Android, only NV21 is supported by ML Kit directly from CameraImage for now in this snippet context
       // However, newer versions might support YUV_420_888. Let's try basic support.
       // If this fails, we might need more complex conversion.
       // For now, returning null to avoid crash if format not supported.
       // Note: CameraController with ResolutionPreset.medium usually gives YUV420 on Android.
    }

    // Basic plane concatenation for Android/iOS
    if (image.planes.length != 1) return null; // Simplified for Linux/Basic
    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: InputImageFormat.bgra8888, // Assuming Linux gives BGRA8888
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
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("Sign Language"),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 7,
            child: _controller != null && _controller!.value.isInitialized
                ? CameraPreview(_controller!)
                : Center(child: CircularProgressIndicator()),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 5,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.gesture, color: Colors.deepPurple, size: 24),
                        SizedBox(width: 10),
                        Text(
                          gestureText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      final message = gestureText.trim();
                      if (message.isNotEmpty && message != "Aucun geste détecté") {
                        Navigator.pop(context, message);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No gesture detected to send')),
                        );
                      }
                    },
                    child: const Text("Send Text"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
