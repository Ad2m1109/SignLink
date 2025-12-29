import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Design System for HandTalk App
class AppTheme {
  // Brand Colors
  static const Color primaryColor = Color(0xFF6750A4); // Deep Purple
  static const Color secondaryColor = Color(0xFF03DAC6); // Teal
  static const Color accentColor = Color(0xFF625B71); // Muted Purple
  
  // Background Colors
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF1E1E1E);
  
  // Text Colors
  static const Color textPrimaryLight = Color(0xFF1C1B1F);
  static const Color textSecondaryLight = Color(0xFF49454F);
  static const Color textPrimaryDark = Color(0xFFE6E1E5);
  static const Color textSecondaryDark = Color(0xFFCAC4D0);
  
  // Status Colors
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFEF5350);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color infoColor = Color(0xFF2196F3);
  
  // Spacing System (8px base)
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;
  
  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  static const double radiusRound = 30.0;
  
  // Elevation
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;
  
  // Font Sizes
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeBody = 16.0;
  static const double fontSizeTitle = 18.0;
  static const double fontSizeHeading = 24.0;
  static const double fontSizeLarge = 32.0;
  
  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      secondary: secondaryColor,
      brightness: Brightness.light,
    ),
    textTheme: GoogleFonts.outfitTextTheme(),
    scaffoldBackgroundColor: backgroundLight,
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: surfaceLight,
      foregroundColor: textPrimaryLight,
      titleTextStyle: GoogleFonts.outfit(
        fontSize: fontSizeTitle,
        fontWeight: FontWeight.bold,
        color: textPrimaryLight,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: elevationLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
      ),
      color: surfaceLight,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: spacing24,
          vertical: spacing16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        elevation: elevationLow,
        textStyle: GoogleFonts.outfit(
          fontSize: fontSizeBody,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacing20,
        vertical: spacing16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      labelStyle: GoogleFonts.outfit(color: textSecondaryLight),
      hintStyle: GoogleFonts.outfit(color: Colors.grey[400]),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: elevationMedium,
    ),
  );
  
  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      secondary: secondaryColor,
      brightness: Brightness.dark,
    ),
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
    scaffoldBackgroundColor: backgroundDark,
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: surfaceDark,
      foregroundColor: textPrimaryDark,
      titleTextStyle: GoogleFonts.outfit(
        fontSize: fontSizeTitle,
        fontWeight: FontWeight.bold,
        color: textPrimaryDark,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: elevationLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
      ),
      color: surfaceDark,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: spacing24,
          vertical: spacing16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        elevation: elevationLow,
        textStyle: GoogleFonts.outfit(
          fontSize: fontSizeBody,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[850],
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacing20,
        vertical: spacing16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: secondaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      labelStyle: GoogleFonts.outfit(color: textSecondaryDark),
      hintStyle: GoogleFonts.outfit(color: Colors.grey[600]),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: elevationMedium,
    ),
  );
  
  // Reusable Gradients
  static LinearGradient primaryGradient = const LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient subtleGradient(BuildContext context) {
    return LinearGradient(
      colors: [
        Theme.of(context).primaryColor.withOpacity(0.1),
        Colors.transparent,
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }
  
  // Box Shadow
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 20,
      offset: const Offset(0, 5),
    ),
  ];
}

// Reusable Components
class AppComponents {
  // Primary Button
  static Widget primaryButton({
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
    IconData? icon,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : icon != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 20),
                      const SizedBox(width: AppTheme.spacing8),
                      Text(text),
                    ],
                  )
                : Text(text),
      ),
    );
  }
  
  // Secondary Button
  static Widget secondaryButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppTheme.primaryColor, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
        ),
        child: icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 20, color: AppTheme.primaryColor),
                  const SizedBox(width: AppTheme.spacing8),
                  Text(
                    text,
                    style: const TextStyle(color: AppTheme.primaryColor),
                  ),
                ],
              )
            : Text(
                text,
                style: const TextStyle(color: AppTheme.primaryColor),
              ),
      ),
    );
  }
  
  // Input Field
  static Widget inputField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? prefixIcon,
    bool obscureText = false,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      ),
    );
  }
  
  // Card Container
  static Widget card({
    required Widget child,
    EdgeInsetsGeometry? padding,
    Color? color,
  }) {
    return Container(
      padding: padding ?? const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.cardShadow,
      ),
      child: child,
    );
  }
  
  // Empty State
  static Widget emptyState({
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[400]),
          const SizedBox(height: AppTheme.spacing16),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: AppTheme.fontSizeTitle,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppTheme.spacing8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: AppTheme.fontSizeMedium,
                color: Colors.grey[500],
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  // Loading Indicator
  static Widget loading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
  
  // Avatar
  static Widget avatar({
    required String name,
    double size = 40,
    Color? backgroundColor,
  }) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: backgroundColor ?? AppTheme.primaryColor.withOpacity(0.1),
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: GoogleFonts.outfit(
          fontSize: size / 2.5,
          fontWeight: FontWeight.bold,
          color: backgroundColor ?? AppTheme.primaryColor,
        ),
      ),
    );
  }
}