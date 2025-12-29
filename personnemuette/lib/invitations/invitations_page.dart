import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/api_service.dart';
import '../utils/user_preferences.dart';
import '../theme/app_theme.dart';
import 'send_invitation_page.dart';

class InvitationsPage extends StatefulWidget {
  const InvitationsPage({super.key});

  @override
  State<InvitationsPage> createState() => _InvitationsPageState();
}

class _InvitationsPageState extends State<InvitationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> receivedInvitations = [];
  List<dynamic> sentInvitations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadInvitations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInvitations() async {
    setState(() => isLoading = true);
    try {
      final token = await UserPreferences.getUserToken();
      final userId = await UserPreferences.getUserId();

      if (token != null && userId != null) {
        final received = await ApiService.getReceivedInvitations(userId, token);
        final sent = await ApiService.getSentInvitations(userId, token);

        if (mounted) {
          setState(() {
            receivedInvitations = received;
            sentInvitations = sent;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load invitations: $e'),
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

  Future<void> _respondToInvitation(int id, String status) async {
    try {
      final token = await UserPreferences.getUserToken();
      if (token != null) {
        await ApiService.respondToInvitation(id, status, token);
        _loadInvitations();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Invitation ${status == 'accepted' ? 'accepted' : 'rejected'}'),
              backgroundColor: status == 'accepted' 
                  ? AppTheme.successColor 
                  : AppTheme.errorColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to respond: $e'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Invitations',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: AppTheme.fontSizeBody,
          ),
          unselectedLabelStyle: GoogleFonts.outfit(
            fontSize: AppTheme.fontSizeBody,
          ),
          indicatorColor: Theme.of(context).primaryColor,
          labelColor: Theme.of(context).primaryColor,
          tabs: const [
            Tab(text: 'Received'),
            Tab(text: 'Sent'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SendInvitationPage(),
                ),
              ).then((_) => _loadInvitations());
            },
            tooltip: 'Send Invitation',
          ),
          const SizedBox(width: AppTheme.spacing8),
        ],
      ),
      body: isLoading
          ? AppComponents.loading()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildReceivedList(),
                _buildSentList(),
              ],
            ),
    );
  }

  Widget _buildReceivedList() {
    if (receivedInvitations.isEmpty) {
      return AppComponents.emptyState(
        icon: Icons.mail_outline,
        title: "No Invitations",
        subtitle: "You don't have any pending invitations",
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      itemCount: receivedInvitations.length,
      itemBuilder: (context, index) {
        final invite = receivedInvitations[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            child: Row(
              children: [
                AppComponents.avatar(
                  name: invite['sender_name'],
                  size: 50,
                ),
                const SizedBox(width: AppTheme.spacing16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invite['sender_name'],
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: AppTheme.fontSizeBody,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacing4),
                      Text(
                        invite['sender_email'],
                        style: GoogleFonts.outfit(
                          fontSize: AppTheme.fontSizeMedium,
                          color: AppTheme.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle, size: 28),
                      color: AppTheme.successColor,
                      onPressed: () => _respondToInvitation(
                        invite['id'],
                        'accepted',
                      ),
                      tooltip: 'Accept',
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel, size: 28),
                      color: AppTheme.errorColor,
                      onPressed: () => _respondToInvitation(
                        invite['id'],
                        'rejected',
                      ),
                      tooltip: 'Reject',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.2);
      },
    );
  }

  Widget _buildSentList() {
    if (sentInvitations.isEmpty) {
      return AppComponents.emptyState(
        icon: Icons.send_outlined,
        title: "No Sent Invitations",
        subtitle: "Send an invitation to connect with friends",
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      itemCount: sentInvitations.length,
      itemBuilder: (context, index) {
        final invite = sentInvitations[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            child: Row(
              children: [
                AppComponents.avatar(
                  name: invite['receiver_name'],
                  size: 50,
                  backgroundColor: Colors.grey[300],
                ),
                const SizedBox(width: AppTheme.spacing16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invite['receiver_name'],
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: AppTheme.fontSizeBody,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacing4),
                      Text(
                        invite['receiver_email'],
                        style: GoogleFonts.outfit(
                          fontSize: AppTheme.fontSizeMedium,
                          color: AppTheme.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing12,
                    vertical: AppTheme.spacing8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.warningColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                  ),
                  child: Text(
                    "Pending",
                    style: GoogleFonts.outfit(
                      color: AppTheme.warningColor,
                      fontWeight: FontWeight.bold,
                      fontSize: AppTheme.fontSizeSmall,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.2);
      },
    );
  }
}