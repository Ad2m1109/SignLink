import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/api_service.dart';
import '../utils/user_preferences.dart';
import '../theme/app_theme.dart';

class SendInvitationPage extends StatefulWidget {
  const SendInvitationPage({super.key});

  @override
  State<SendInvitationPage> createState() => _SendInvitationPageState();
}

class _SendInvitationPageState extends State<SendInvitationPage> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendInvitation() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter an email address'),
          backgroundColor: AppTheme.warningColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final token = await UserPreferences.getUserToken();
      final userId = await UserPreferences.getUserId();

      if (token != null && userId != null) {
        await ApiService.sendInvitation(userId, email, token);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Invitation sent successfully!'),
              backgroundColor: AppTheme.successColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send invitation: $e'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Invite Friend',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Illustration/Icon
            Center(
              child: Container(
                padding: const EdgeInsets.all(AppTheme.spacing32),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_add,
                  size: 80,
                  color: Colors.white,
                ),
              ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
            ),
            const SizedBox(height: AppTheme.spacing32),
            
            // Title and Description
            Text(
              "Invite a Friend",
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: AppTheme.fontSizeHeading,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
            const SizedBox(height: AppTheme.spacing12),
            Text(
              "Send an invitation to connect with your friends and start conversations.",
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: AppTheme.fontSizeBody,
                color: AppTheme.textSecondaryLight,
                height: 1.5,
              ),
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: AppTheme.spacing40),
            
            // Email Input Card
            AppComponents.card(
              padding: const EdgeInsets.all(AppTheme.spacing24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Friend's Email",
                    style: GoogleFonts.outfit(
                      fontSize: AppTheme.fontSizeBody,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  AppComponents.inputField(
                    controller: _emailController,
                    label: 'Email Address',
                    hint: 'friend@example.com',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: AppTheme.spacing24),
                  AppComponents.primaryButton(
                    text: "Send Invitation",
                    onPressed: _sendInvitation,
                    isLoading: _isLoading,
                    icon: Icons.send,
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
            const SizedBox(height: AppTheme.spacing24),
            
            // Info Card
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              decoration: BoxDecoration(
                color: AppTheme.infoColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                border: Border.all(
                  color: AppTheme.infoColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.infoColor,
                    size: 24,
                  ),
                  const SizedBox(width: AppTheme.spacing12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "How it works",
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.infoColor,
                            fontSize: AppTheme.fontSizeBody,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacing4),
                        Text(
                          "Your friend will receive an invitation notification. Once they accept, you can start chatting!",
                          style: GoogleFonts.outfit(
                            fontSize: AppTheme.fontSizeMedium,
                            color: AppTheme.textSecondaryLight,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 500.ms),
          ],
        ),
      ),
    );
  }
}