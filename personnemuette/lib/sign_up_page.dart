import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'sign_in_page.dart';
import 'services/api_service.dart';

import 'theme/app_theme.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formSignupKey = GlobalKey<FormState>();
  bool agreePersonalData = true;
  bool _isLoading = false;
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String nameError = '';
  String emailError = '';
  String passwordError = '';

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool isValidName(String name) {
    return name.length > 5;
  }

  bool isValidEmail(String email) {
    return email.contains('@') && email.contains('.') && email.length > 9;
  }

  bool isValidPassword(String password) {
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasDigits = password.contains(RegExp(r'[0-9]'));
    return hasUppercase && hasLowercase && hasDigits && password.length > 7;
  }

  Future<void> _signUp() async {
    setState(() {
      nameError = '';
      emailError = '';
      passwordError = '';
    });

    if (_formSignupKey.currentState!.validate() && agreePersonalData) {
      if (!isValidName(_fullNameController.text.trim())) {
        setState(() {
          nameError = 'Name must be more than 5 characters';
        });
        return;
      }

      if (!isValidEmail(_emailController.text.trim())) {
        setState(() {
          emailError = 'Invalid email format';
        });
        return;
      }

      if (!isValidPassword(_passwordController.text.trim())) {
        setState(() {
          passwordError =
              'Password must contain upper and lower case letters, numbers, and be more than 7 characters';
        });
        return;
      }

      setState(() => _isLoading = true);

      try {
        await ApiService.addUser({
          'fullName': _fullNameController.text.trim(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Signup successful! Please sign in.'),
              backgroundColor: AppTheme.successColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SignInPage()),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Signup failed: ${e.toString()}'),
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
    } else if (!agreePersonalData) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please agree to the Terms and Conditions'),
          backgroundColor: AppTheme.warningColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacing16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              
              // Form Content
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(
                    AppTheme.spacing24,
                    AppTheme.spacing32,
                    AppTheme.spacing24,
                    AppTheme.spacing24,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppTheme.radiusXLarge),
                      topRight: Radius.circular(AppTheme.radiusXLarge),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formSignupKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Create Account',
                            style: GoogleFonts.outfit(
                              fontSize: AppTheme.fontSizeLarge,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ).animate().fadeIn().slideY(begin: 0.2),
                          const SizedBox(height: AppTheme.spacing8),
                          Text(
                            'Sign up to get started',
                            style: GoogleFonts.outfit(
                              fontSize: AppTheme.fontSizeBody,
                              color: AppTheme.textSecondaryLight,
                            ),
                          ).animate().fadeIn(delay: 100.ms),
                          const SizedBox(height: AppTheme.spacing32),
                          
                          // Full Name
                          AppComponents.inputField(
                            controller: _fullNameController,
                            label: 'Full Name',
                            hint: 'Enter your full name',
                            prefixIcon: Icons.person_outline,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your full name';
                              }
                              if (nameError.isNotEmpty) {
                                return nameError;
                              }
                              return null;
                            },
                          ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),
                          const SizedBox(height: AppTheme.spacing20),
                          
                          // Email
                          AppComponents.inputField(
                            controller: _emailController,
                            label: 'Email',
                            hint: 'Enter your email',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (emailError.isNotEmpty) {
                                return emailError;
                              }
                              return null;
                            },
                          ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.2),
                          const SizedBox(height: AppTheme.spacing20),
                          
                          // Password
                          AppComponents.inputField(
                            controller: _passwordController,
                            label: 'Password',
                            hint: 'Create a strong password',
                            prefixIcon: Icons.lock_outline,
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a password';
                              }
                              if (passwordError.isNotEmpty) {
                                return passwordError;
                              }
                              return null;
                            },
                          ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.2),
                          const SizedBox(height: AppTheme.spacing20),
                          
                          // Terms Checkbox
                          Row(
                            children: [
                              SizedBox(
                                height: 24,
                                width: 24,
                                child: Checkbox(
                                  value: agreePersonalData,
                                  activeColor: AppTheme.primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  onChanged: (bool? value) {
                                    setState(() {
                                      agreePersonalData = value!;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: AppTheme.spacing8),
                              Expanded(
                                child: Text(
                                  'I agree to the Terms and Conditions',
                                  style: GoogleFonts.outfit(
                                    color: AppTheme.textSecondaryLight,
                                    fontSize: AppTheme.fontSizeMedium,
                                  ),
                                ),
                              ),
                            ],
                          ).animate().fadeIn(delay: 500.ms),
                          const SizedBox(height: AppTheme.spacing32),
                          
                          // Sign Up Button
                          AppComponents.primaryButton(
                            text: "Sign Up",
                            onPressed: _signUp,
                            isLoading: _isLoading,
                          ).animate().fadeIn(delay: 600.ms).scale(),
                          const SizedBox(height: AppTheme.spacing24),
                          
                          // Sign In Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account? ',
                                style: GoogleFonts.outfit(
                                  color: AppTheme.textSecondaryLight,
                                  fontSize: AppTheme.fontSizeMedium,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const SignInPage(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Sign In',
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                    fontSize: AppTheme.fontSizeMedium,
                                  ),
                                ),
                              ),
                            ],
                          ).animate().fadeIn(delay: 700.ms),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}