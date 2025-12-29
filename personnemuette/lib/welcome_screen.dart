import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'sign_in_page.dart';
import 'sign_up_page.dart';
import 'another_screen.dart';
import 'theme/app_theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Main Content
              Column(
                children: [
                  // Logo and Title Section
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppTheme.spacing24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.waving_hand_rounded,
                              size: 80,
                              color: Colors.white,
                            ),
                          ).animate().scale(
                            duration: 800.ms,
                            curve: Curves.elasticOut,
                          ),
                          const SizedBox(height: AppTheme.spacing32),
                          Text(
                            "HandTalk",
                            style: GoogleFonts.outfit(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
                          const SizedBox(height: AppTheme.spacing12),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacing40,
                            ),
                            child: Text(
                              "Bridge the gap with sign language\nand connect with everyone",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                fontSize: AppTheme.fontSizeBody,
                                color: Colors.white.withOpacity(0.9),
                                height: 1.5,
                              ),
                            ),
                          ).animate().fadeIn(delay: 400.ms),
                        ],
                      ),
                    ),
                  ),
                  
                  // Buttons Section
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.all(AppTheme.spacing24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppTheme.radiusXLarge),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SignUpPage(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppTheme.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusMedium,
                                  ),
                                ),
                                elevation: AppTheme.elevationMedium,
                              ),
                              child: Text(
                                "Get Started",
                                style: GoogleFonts.outfit(
                                  fontSize: AppTheme.fontSizeBody,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
                          const SizedBox(height: AppTheme.spacing16),
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SignInPage(),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusMedium,
                                  ),
                                ),
                              ),
                              child: Text(
                                "Sign In",
                                style: GoogleFonts.outfit(
                                  fontSize: AppTheme.fontSizeBody,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              // Guest Mode Button (Top Right)
              Positioned(
                top: AppTheme.spacing16,
                right: AppTheme.spacing16,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.people_alt_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AnotherScreen(),
                        ),
                      );
                    },
                    tooltip: 'Guest Mode',
                  ),
                ),
              ).animate().fadeIn(delay: 800.ms).scale(),
            ],
          ),
        ),
      ),
    );
  }
}