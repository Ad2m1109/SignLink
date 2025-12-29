import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'welcome_screen.dart';
import 'utils/user_preferences.dart';
import 'theme/app_theme.dart';

List<CameraDescription> cameras = [];
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } catch (e) {
    print('Error in fetching the cameras: $e');
  }
  
  // Load saved theme preference
  final isDarkMode = await UserPreferences.getThemeMode();
  themeNotifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          title: 'HandTalk',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: const WelcomeScreen(),
        );
      },
    );
  }
}