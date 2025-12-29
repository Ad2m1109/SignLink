import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:camera/camera.dart';
import 'main.dart';
import 'theme/app_theme.dart';

class AnotherScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureToSpeechScreen(),
      ),
    );
  }
}

class GestureToSpeechScreen extends StatefulWidget {
  @override
  _GestureToSpeechScreenState createState() => _GestureToSpeechScreenState();
}

class _GestureToSpeechScreenState extends State<GestureToSpeechScreen> {
  final FlutterTts flutterTts = FlutterTts();
  String gestureText = "No gesture detected";
  CameraController? _controller;

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

    _controller = CameraController(cameras[0], ResolutionPreset.max);
    _controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            debugPrint('User denied camera access.');
            break;
          default:
            debugPrint('Handle other errors.');
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // App Bar
        Container(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: AppTheme.spacing8),
              Text(
                "Guest Mode",
                style: GoogleFonts.outfit(
                  fontSize: AppTheme.fontSizeTitle,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        
        // Camera Preview
        Expanded(
          flex: 7,
          child: Container(
            margin: const EdgeInsets.all(AppTheme.spacing16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
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
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppTheme.radiusXLarge),
                topRight: Radius.circular(AppTheme.radiusXLarge),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Gesture Display
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
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
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
                
                // Speak Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      speak(gestureText);
                    },
                    icon: const Icon(Icons.volume_up, size: 24),
                    label: Text(
                      'Speak',
                      style: GoogleFonts.outfit(
                        fontSize: AppTheme.fontSizeBody,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusMedium,
                        ),
                      ),
                      elevation: AppTheme.elevationMedium,
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
              ],
            ),
          ),
        ),
      ],
    );
  }
}