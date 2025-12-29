import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/api_service.dart';
import '../utils/user_preferences.dart';
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
          SnackBar(content: Text('Failed to load invitations: $e')),
        );
      }
    }
  }

  Future<void> _respondToInvitation(int id, String status) async {
    try {
      final token = await UserPreferences.getUserToken();
      if (token != null) {
        await ApiService.respondToInvitation(id, status, token);
        _loadInvitations(); // Refresh list
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invitation $status')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to respond: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invitations', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold),
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
                MaterialPageRoute(builder: (context) => const SendInvitationPage()),
              ).then((_) => _loadInvitations());
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
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
      return Center(
        child: Text(
          "No received invitations",
          style: GoogleFonts.outfit(color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: receivedInvitations.length,
      itemBuilder: (context, index) {
        final invite = receivedInvitations[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Text(
                invite['sender_name'][0].toUpperCase(),
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
            title: Text(
              invite['sender_name'],
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(invite['sender_email']),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check_circle, color: Colors.green),
                  onPressed: () => _respondToInvitation(invite['id'], 'accepted'),
                ),
                IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.red),
                  onPressed: () => _respondToInvitation(invite['id'], 'rejected'),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: (index * 100).ms).slideX();
      },
    );
  }

  Widget _buildSentList() {
    if (sentInvitations.isEmpty) {
      return Center(
        child: Text(
          "No sent invitations",
          style: GoogleFonts.outfit(color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sentInvitations.length,
      itemBuilder: (context, index) {
        final invite = sentInvitations[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: const CircleAvatar(
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text(
              invite['receiver_name'],
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(invite['receiver_email']),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Pending",
                style: GoogleFonts.outfit(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ).animate().fadeIn(delay: (index * 100).ms).slideX();
      },
    );
  }
}
