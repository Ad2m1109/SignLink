import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'sign_up_page.dart';
import 'services/api_service.dart';
import 'utils/user_preferences.dart';
import 'main_screen.dart';
import 'theme/app_theme.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formSignInKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool rememberPassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final savedCredentials = await UserPreferences.getRememberedCredentials();
    setState(() {
      _emailController.text = savedCredentials['email'];
      _passwordController.text = savedCredentials['password'];
      rememberPassword = savedCredentials['rememberMe'];
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> signInUser() async {
    if (_formSignInKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final response = await ApiService.signIn(
            _emailController.text.trim(), _passwordController.text.trim());

        final userId = response['userId'].toString();
        final name = response['name'];
        final email = _emailController.text.trim();
        final token = response['token'];

        await UserPreferences.saveUserInfo(userId, name, email);
        await UserPreferences.saveUserToken(token);
        await UserPreferences.saveRememberedCredentials(
            _emailController.text.trim(),
            _passwordController.text.trim(),
            rememberPassword);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Login failed: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
          ));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacing24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacing24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.waving_hand_rounded,
                      size: 60,
                      color: Colors.white,
                    ),
                  ).animate().scale(
                    duration: 600.ms,
                    curve: Curves.easeOutBack,
                  ),
                  const SizedBox(height: AppTheme.spacing24),
                  
                  // Welcome Text
                  Text(
                    "Welcome Back!",
                    style: GoogleFonts.outfit(
                      fontSize: AppTheme.fontSizeLarge,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
                  const SizedBox(height: AppTheme.spacing8),
                  Text(
                    "Sign in to continue",
                    style: GoogleFonts.outfit(
                      fontSize: AppTheme.fontSizeBody,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: AppTheme.spacing40),
                  
                  // Form Container
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacing24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
                      boxShadow: AppTheme.elevatedShadow,
                    ),
                    child: Form(
                      key: _formSignInKey,
                      child: Column(
                        children: [
                          // Email Field
                          AppComponents.inputField(
                            controller: _emailController,
                            label: 'Email',
                            hint: 'Enter your email',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) => (value == null || value.isEmpty)
                                ? 'Please enter your email'
                                : null,
                          ),
                          const SizedBox(height: AppTheme.spacing20),
                          
                          // Password Field
                          AppComponents.inputField(
                            controller: _passwordController,
                            label: 'Password',
                            hint: 'Enter your password',
                            prefixIcon: Icons.lock_outline,
                            obscureText: true,
                            validator: (value) => (value == null || value.isEmpty)
                                ? 'Please enter your password'
                                : null,
                          ),
                          const SizedBox(height: AppTheme.spacing12),
                          
                          // Remember Me
                          Row(
                            children: [
                              SizedBox(
                                height: 24,
                                width: 24,
                                child: Checkbox(
                                  value: rememberPassword,
                                  activeColor: AppTheme.primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  onChanged: (val) =>
                                      setState(() => rememberPassword = val!),
                                ),
                              ),
                              const SizedBox(width: AppTheme.spacing8),
                              Text(
                                "Remember me",
                                style: GoogleFonts.outfit(
                                  color: AppTheme.textSecondaryLight,
                                  fontSize: AppTheme.fontSizeMedium,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.spacing24),
                          
                          // Sign In Button
                          AppComponents.primaryButton(
                            text: "Sign In",
                            onPressed: signInUser,
                            isLoading: _isLoading,
                          ),
                          const SizedBox(height: AppTheme.spacing20),
                          
                          // Sign Up Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: GoogleFonts.outfit(
                                  color: AppTheme.textSecondaryLight,
                                  fontSize: AppTheme.fontSizeMedium,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SignUpPage(),
                                  ),
                                ),
                                child: Text(
                                  "Sign Up",
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                    fontSize: AppTheme.fontSizeMedium,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}