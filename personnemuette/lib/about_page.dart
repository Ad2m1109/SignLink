import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'theme/app_theme.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "About HandTalk",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Logo and Name
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacing24),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.waving_hand_rounded,
                      size: 60,
                      color: Colors.white,
                    ),
                  ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                  const SizedBox(height: AppTheme.spacing20),
                  Text(
                    "HandTalk",
                    style: GoogleFonts.outfit(
                      fontSize: AppTheme.fontSizeLarge,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: AppTheme.spacing8),
                  Text(
                    "Version 1.0.0",
                    style: GoogleFonts.outfit(
                      fontSize: AppTheme.fontSizeMedium,
                      color: AppTheme.textSecondaryLight,
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacing40),
            
            // Mission Section
            _buildSection(
              icon: Icons.lightbulb_outline,
              title: "Our Mission",
              content:
                  "HandTalk is designed to break down communication barriers and empower individuals with speech impairments. We believe everyone deserves to be heard and understood.",
              delay: 400,
            ),
            const SizedBox(height: AppTheme.spacing24),
            
            // Features Section
            _buildSection(
              icon: Icons.star_outline,
              title: "Key Features",
              content:
                  "• Real-time sign language recognition\n• Text-to-speech conversion\n• Instant messaging with friends\n• Dark mode support\n• User-friendly interface",
              delay: 500,
            ),
            const SizedBox(height: AppTheme.spacing24),
            
            // Technology Section
            _buildSection(
              icon: Icons.psychology_outlined,
              title: "Powered by AI",
              content:
                  "Our app uses advanced machine learning and pose detection to recognize sign language gestures in real-time, making communication seamless and natural.",
              delay: 600,
            ),
            const SizedBox(height: AppTheme.spacing24),
            
            // Contact Section
            _buildSection(
              icon: Icons.contact_support_outlined,
              title: "Get in Touch",
              content:
                  "Have questions or feedback? We'd love to hear from you!\n\nEmail: support@handtalk.app\nWebsite: www.handtalk.app",
              delay: 700,
            ),
            const SizedBox(height: AppTheme.spacing40),
            
            // Copyright
            Center(
              child: Text(
                "© 2024 HandTalk. All rights reserved.",
                style: GoogleFonts.outfit(
                  fontSize: AppTheme.fontSizeSmall,
                  color: AppTheme.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 800.ms),
            ),
            const SizedBox(height: AppTheme.spacing24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
    required int delay,
  }) {
    return AppComponents.card(
      padding: const EdgeInsets.all(AppTheme.spacing20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacing12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppTheme.spacing16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: AppTheme.fontSizeTitle,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing16),
          Text(
            content,
            style: GoogleFonts.outfit(
              fontSize: AppTheme.fontSizeBody,
              color: AppTheme.textSecondaryLight,
              height: 1.6,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms).slideX(begin: 0.2);
  }
}