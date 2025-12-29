import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  // Keys
  static const _keyUserId = 'userId';
  static const _keyName = 'name';
  static const _keyEmail = 'email';
  static const _keyToken = 'token'; // Added for token management
  static const _keyRememberMe = 'rememberMe';
  static const _keyRememberedEmail = 'remembered_email';
  static const _keyRememberedPassword = 'remembered_password';

  // Get SharedPreferences instance
  static Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  // Save user information
  static Future<void> saveUserInfo(
      String userId, String name, String email) async {
    final prefs = await _getPrefs();
    await prefs.setString(_keyUserId, userId);
    await prefs.setString(_keyName, name); // Save the user's name
    await prefs.setString(_keyEmail, email);
  }

  // Save user token
  static Future<void> saveUserToken(String token) async {
    final prefs = await _getPrefs();
    await prefs.setString(_keyToken, token);
  }

  // Get user name
  static Future<String?> getUserName() async {
    try {
      final prefs = await _getPrefs();
      return prefs.getString(_keyName);
    } catch (e) {
      throw Exception('Failed to get user name: $e');
    }
  }

  // Get user ID
  static Future<String?> getUserId() async {
    try {
      final prefs = await _getPrefs();
      return prefs.getString(_keyUserId);
    } catch (e) {
      throw Exception('Failed to get user ID: $e');
    }
  }

  // Get user email
  static Future<String?> getUserEmail() async {
    try {
      final prefs = await _getPrefs();
      return prefs.getString(_keyEmail);
    } catch (e) {
      throw Exception('Failed to get user email: $e');
    }
  }

  // Get user token
  static Future<String?> getUserToken() async {
    try {
      final prefs = await _getPrefs();
      return prefs.getString(_keyToken);
    } catch (e) {
      throw Exception('Failed to get user token: $e');
    }
  }

  // Clear user data (for logout)
  static Future<bool> clearUserData() async {
    try {
      final prefs = await _getPrefs();
      await prefs.remove(_keyUserId);
      await prefs.remove(_keyName);
      await prefs.remove(_keyEmail);
      await prefs.remove(_keyToken); // Clear token on logout
      return true;
    } catch (e) {
      throw Exception('Failed to clear user data: $e');
    }
  }

  // Save remembered credentials when "Remember me" is checked
  static Future<void> saveRememberedCredentials(
      String email, String password, bool rememberMe) async {
    final prefs = await _getPrefs();
    await prefs.setString(_keyRememberedEmail, email);
    await prefs.setString(_keyRememberedPassword, password);
    await prefs.setBool(_keyRememberMe, rememberMe);
  }

  // Get remembered credentials
  static Future<Map<String, dynamic>> getRememberedCredentials() async {
    final prefs = await _getPrefs();
    return {
      'email': prefs.getString(_keyRememberedEmail) ?? '',
      'password': prefs.getString(_keyRememberedPassword) ?? '',
      'rememberMe': prefs.getBool(_keyRememberMe) ?? false,
    };
  }

  // Clear remembered credentials (useful when logging out)
  static Future<bool> clearRememberedCredentials() async {
    try {
      final prefs = await _getPrefs();
      await prefs.remove(_keyRememberMe);
      await prefs.remove(_keyRememberedEmail);
      await prefs.remove(_keyRememberedPassword);
      return true;
    } catch (e) {
      throw Exception('Failed to clear remembered credentials: $e');
    }
  }

  // Theme Preference
  static const _keyIsDarkMode = 'isDarkMode';

  static Future<void> saveThemeMode(bool isDarkMode) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_keyIsDarkMode, isDarkMode);
  }

  static Future<bool> getThemeMode() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_keyIsDarkMode) ?? false;
  }
}
