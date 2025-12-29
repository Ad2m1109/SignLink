import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'invitations/invitations_page.dart';
import 'about_page.dart';
import 'sign_in_page.dart';
import 'services/api_service.dart';
import 'utils/user_preferences.dart';
import 'conversation_page.dart';
import 'main.dart';
import 'theme/app_theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = "Loading...";
  List<String> friends = [];
  List<String> filteredFriends = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _searchController.addListener(_filterFriends);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final userId = await UserPreferences.getUserId();
      final token = await UserPreferences.getUserToken();
      if (userId != null && token != null) {
        final userProfile = await ApiService.getUserProfile(userId, token);
        if (mounted) {
          setState(() {
            userName = userProfile['name'];
            friends = List<String>.from(userProfile['friends']);
            filteredFriends = friends;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load user data: $e'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
          ),
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

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        title: Text(
          "Sign Out",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Are you sure you want to sign out?",
          style: GoogleFonts.outfit(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: GoogleFonts.outfit(color: AppTheme.textSecondaryLight),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SignInPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
            ),
            child: Text("Sign Out", style: GoogleFonts.outfit()),
          ),
        ],
      ),
    );
  }

  void _navigateToInvitations() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const InvitationsPage()),
    );
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            AppComponents.avatar(name: userName, size: 40),
            const SizedBox(width: AppTheme.spacing12),
            Text(
              userName,
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: _toggleDarkMode,
            tooltip: 'Toggle Theme',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutPage()),
              );
            },
            tooltip: 'About',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _showLogoutDialog,
            tooltip: 'Sign Out',
          ),
          const SizedBox(width: AppTheme.spacing8),
        ],
      ),
      body: _isLoading
          ? AppComponents.loading()
          : Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(AppTheme.spacing16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search friends...",
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _filterFriends();
                              },
                            )
                          : null,
                    ),
                  ).animate().fadeIn().slideY(begin: -0.2),
                ),
                
                // Friends List
                Expanded(
                  child: filteredFriends.isEmpty
                      ? AppComponents.emptyState(
                          icon: Icons.people_outline,
                          title: friends.isEmpty
                              ? "No Friends Yet"
                              : "No Results Found",
                          subtitle: friends.isEmpty
                              ? "Add friends to start conversations"
                              : "Try a different search term",
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacing16,
                          ),
                          itemCount: filteredFriends.length,
                          itemBuilder: (context, index) {
                            return Card(
                              margin: const EdgeInsets.only(
                                bottom: AppTheme.spacing12,
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: AppTheme.spacing16,
                                  vertical: AppTheme.spacing8,
                                ),
                                leading: AppComponents.avatar(
                                  name: filteredFriends[index],
                                  size: 50,
                                ),
                                title: Text(
                                  filteredFriends[index],
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w600,
                                    fontSize: AppTheme.fontSizeBody,
                                  ),
                                ),
                                subtitle: Text(
                                  "Tap to chat",
                                  style: GoogleFonts.outfit(
                                    fontSize: AppTheme.fontSizeMedium,
                                    color: AppTheme.textSecondaryLight,
                                  ),
                                ),
                                trailing: Icon(
                                  Icons.chat_bubble_outline,
                                  color: Theme.of(context).primaryColor,
                                ),
                                onTap: () async {
                                  try {
                                    final userId =
                                        await UserPreferences.getUserId();
                                    final token =
                                        await UserPreferences.getUserToken();

                                    if (userId != null && token != null) {
                                      final conversationId =
                                          await ApiService.getConversationId(
                                        userId,
                                        filteredFriends[index],
                                        token,
                                      );

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ConversationPage(
                                            friendEmail: filteredFriends[index],
                                            conversationId: conversationId,
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Failed to load conversation: $e'),
                                        backgroundColor: AppTheme.errorColor,
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
                              ),
                            )
                                .animate()
                                .fadeIn(delay: (index * 50).ms)
                                .slideX(begin: 0.2);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToInvitations,
        icon: const Icon(Icons.person_add),
        label: Text("Invite", style: GoogleFonts.outfit()),
        tooltip: 'Invite Friends',
      ).animate().scale(delay: 400.ms),
    );
  }
}