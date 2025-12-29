import 'package:flutter/material.dart';
import 'another_screen.dart';
import 'invitations/invitations_page.dart'; // Import InvitationsPage
import 'about_page.dart';
import 'sign_in_page.dart';
import 'services/api_service.dart';
import 'utils/user_preferences.dart';
import 'conversation_page.dart';
import 'main.dart'; // Import main.dart to access themeNotifier

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = "Loading...";
  List<String> friends = [];
  List<String> filteredFriends = []; // Add a filtered list
  final TextEditingController _searchController =
      TextEditingController(); // Add a search controller

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _searchController.addListener(_filterFriends); // Listen for search input
  }

  @override
  void dispose() {
    _searchController.dispose(); // Dispose the controller
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final userId = await UserPreferences.getUserId();
      final token = await UserPreferences.getUserToken();
      if (userId != null && token != null) {
        final userProfile = await ApiService.getUserProfile(userId, token);
        if (mounted) {
          setState(() {
            userName = userProfile['name']; // Use the connected user's name
            friends = List<String>.from(userProfile['friends']); // Fetch friends
            filteredFriends = friends; // Initialize filtered list
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load user data: $e')),
        );
      }
    }
  }

  void _filterFriends() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredFriends = friends
          .where((friend) => friend.toLowerCase().contains(query))
          .toList();
    });
  }

  void _toggleDarkMode() {
    final isDark = themeNotifier.value == ThemeMode.dark;
    themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
    UserPreferences.saveThemeMode(!isDark);
  }

  void _showCloseAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Close Account"),
        content: Text("Are you sure you want to close your account?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("No"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SignInPage()),
              );
            },
            child: Text("Yes"),
          ),
        ],
      ),
    );
  }

  void _navigateToInvitations() async {
    // Navigate to InvitationsPage and wait for it to return
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => InvitationsPage()),
    );
    // Reload the friends list after returning (in case a friend request was accepted)
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Disable the back arrow
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.blue,
        title: Text(
          userName, // Dynamically display the connected user's name
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black, // Adjust color
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: _toggleDarkMode,
          ),
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout), // Changed icon to logout for clarity
            onPressed: _showCloseAccountDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search friends...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredFriends.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        isDarkMode ? Colors.grey[700] : Colors.blue[100],
                    child: Text(
                      filteredFriends[index][0].toUpperCase(),
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  title: Text(
                    filteredFriends[index],
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  onTap: () async {
                    try {
                      final userId = await UserPreferences.getUserId();
                      final token = await UserPreferences.getUserToken();

                      if (userId != null && token != null) {
                        // Fetch the conversation ID for the selected friend
                        final conversationId =
                            await ApiService.getConversationId(
                          userId,
                          filteredFriends[index],
                          token,
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ConversationPage(
                              friendEmail: filteredFriends[index],
                              conversationId: conversationId,
                              isDarkMode: isDarkMode, // Pass dark mode state
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Failed to load conversation: $e')),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToInvitations, // Use the new method
        child: Icon(Icons.person_add), // Icon for invitations/add friend
        backgroundColor: isDarkMode ? Colors.grey[800] : Colors.blue,
      ),
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
    );
  }
}
