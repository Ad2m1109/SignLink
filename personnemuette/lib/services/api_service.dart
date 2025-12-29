import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://localhost:5000";

  // Add a new user (register)
  static Future<void> addUser(Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/add_user'), // Matches Flask route
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': userData['fullName'], // Matches Flask expected keys
        'email': userData['email'],
        'password': userData['password'],
      }),
    );

    if (response.statusCode != 201) {
      final errorData = json.decode(response.body);
      final errorMessage = errorData['message'] ?? 'Failed to add user';
      throw Exception(errorMessage);
    }
  }

  // Sign in (login)
  static Future<Map<String, dynamic>> signIn(
      String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/login'), // Updated to match Flask route
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final errorData = json.decode(response.body);
      final errorMessage = errorData['message'] ?? 'Invalid email or password';
      throw Exception(errorMessage);
    }
  }

  // Get user profile
  static Future<Map<String, dynamic>> getUserProfile(
      String userId, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Includes the friends list
    } else {
      final errorData = json.decode(response.body);
      final errorMessage = errorData['message'] ?? 'Failed to get user profile';
      throw Exception(errorMessage);
    }
  }

  // Get user profile by email
  static Future<Map<String, dynamic>> getUserProfileByEmail(
      String email, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/get_user_by_email'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final errorData = json.decode(response.body);
      final errorMessage =
          errorData['message'] ?? 'Failed to fetch user profile';
      throw Exception(errorMessage);
    }
  }

  // Add a friend
  static Future<void> addFriend(
      String userId, String friendEmail, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/add_friend'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'user1_id': userId,
        'friend_email': friendEmail,
      }),
    );

    if (response.statusCode != 201) {
      final errorData = json.decode(response.body);
      final errorMessage = errorData['message'] ?? 'Failed to add friend';
      throw Exception(errorMessage);
    }
  }

  // Fetch messages for a specific conversation
  static Future<List<Map<String, dynamic>>> getConversationMessages(
      String conversationId, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/conversations/$conversationId/messages'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      final errorData = json.decode(response.body);
      final errorMessage = errorData['message'] ?? 'Failed to load messages';
      throw Exception(errorMessage);
    }
  }

  // Fetch conversation ID for a specific user and friend
  static Future<String> getConversationId(
      String userId, String friendEmail, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/conversations/get_conversation_id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'userId': userId,
        'friendEmail': friendEmail,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['conversationId'];
    } else {
      final errorData = json.decode(response.body);
      final errorMessage =
          errorData['message'] ?? 'Failed to fetch conversation ID';
      throw Exception(errorMessage);
    }
  }

  // Send a new message
  static Future<void> sendMessage(String conversationId, String userId,
      String content, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/messages/add'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'conversationId': conversationId,
        'userId': userId, // Ensure userId is included
        'content': content,
      }),
    );

    if (response.statusCode != 201) {
      final errorData = json.decode(response.body);
      final errorMessage = errorData['message'] ?? 'Failed to send message';
      throw Exception(errorMessage);
    }
  }

  // Invitation Methods

  static Future<void> sendInvitation(
      String senderId, String receiverEmail, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/invitations/send'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'sender_id': senderId,
        'receiver_email': receiverEmail,
      }),
    );

    if (response.statusCode != 201) {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to send invitation');
    }
  }

  static Future<List<dynamic>> getReceivedInvitations(
      String userId, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/invitations/received/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load received invitations');
    }
  }

  static Future<List<dynamic>> getSentInvitations(
      String userId, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/invitations/sent/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load sent invitations');
    }
  }

  static Future<void> respondToInvitation(
      int invitationId, String status, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/invitations/respond'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'invitation_id': invitationId,
        'status': status,
      }),
    );

    if (response.statusCode != 200) {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to respond to invitation');
    }
  }
}
