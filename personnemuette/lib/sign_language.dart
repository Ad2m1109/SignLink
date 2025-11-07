import 'dart:html'; // For accessing the camera on the web
import 'dart:ui_web' as ui_web; // For platformViewRegistry
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'services/api_service.dart';
import 'utils/user_preferences.dart';
import 'conversation_page.dart';

class SignLanguagePage extends StatefulWidget {
  @override
  _SignLanguagePageState createState() => _SignLanguagePageState();
}

class _SignLanguagePageState extends State<SignLanguagePage> {
  late VideoElement _videoElement;
  String gestureText = "Aucun geste détecté"; // Added gesture text
  final FlutterTts flutterTts = FlutterTts(); // Initialize TTS

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _initializeCamera() {
    // Create a video element
    _videoElement = VideoElement();
    _videoElement.style.width = '100%';
    _videoElement.style.height = '100%';

    // Register the video element as a Flutter view
    ui_web.platformViewRegistry.registerViewFactory(
      'camera-view',
      (int viewId) => _videoElement,
    );

    // Request access to the camera
    window.navigator.mediaDevices
        ?.getUserMedia({'video': true}).then((MediaStream stream) {
      _videoElement.srcObject = stream;
      _videoElement.play();
    }).catchError((error) {
      print('Error accessing the camera: $error');
    });
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
            child: HtmlElementView(viewType: 'camera-view'),
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
                    onPressed: () async {
                      final message = gestureText.trim();
                      if (message.isNotEmpty) {
                        try {
                          final userId = await UserPreferences.getUserId();
                          final token = await UserPreferences.getUserToken();
                          final conversationId = ModalRoute.of(context)
                              ?.settings
                              .arguments as String?;

                          if (userId == null ||
                              token == null ||
                              conversationId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Failed to send message: Missing required data')),
                            );
                            return;
                          }

                          // Send the message
                          await ApiService.sendMessage(
                              conversationId, userId, message, token);

                          // Navigate back to the conversation page and refresh it
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ConversationPage(
                                friendEmail:
                                    '', // Pass the friend's email if available
                                conversationId: conversationId,
                                isDarkMode:
                                    false, // Pass the isDarkMode parameter
                              ),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Failed to send message: $e')),
                          );
                        }
                      }
                    },
                    child: Text("Send Text"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 20),
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
