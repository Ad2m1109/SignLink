import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'utils/user_preferences.dart';

class AddFriendScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();

  Future<void> _addFriend(BuildContext context) async {
    try {
      final userId = await UserPreferences.getUserId();
      final token = await UserPreferences.getUserToken();

      if (userId != null && token != null) {
        await ApiService.addFriend(userId, _emailController.text.trim(), token);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Friend added successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add friend: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("Add New Friend"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Friend's Email",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _addFriend(context),
              child: Text("Add Friend"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
