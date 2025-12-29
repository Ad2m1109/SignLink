import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'utils/user_preferences.dart';
import 'theme/app_theme.dart';

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _addFriend() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an email address')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = await UserPreferences.getUserId();
      final token = await UserPreferences.getUserToken();

      if (userId != null && token != null) {
        await ApiService.addFriend(userId, _emailController.text.trim(), token);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Friend added successfully'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add friend: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Friend"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          children: [
            AppComponents.inputField(
              controller: _emailController,
              label: "Friend's Email",
              hint: "Enter email address",
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: AppTheme.spacing24),
            AppComponents.primaryButton(
              text: "Add Friend",
              onPressed: _addFriend,
              isLoading: _isLoading,
              icon: Icons.person_add,
            ),
          ],
        ),
      ),
    );
  }
}
