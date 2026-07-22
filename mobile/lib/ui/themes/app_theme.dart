import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
<<<<<<< HEAD
import 'package:google_fonts/google_fonts.dart';

/// Editorial “repair studio” — warm paper surfaces, deep blue-slate accent (professional service brand).
class AppTheme {
  // ═══════════════════════════════════════════════════════════════════════════
  // COLOR PALETTE — warm paper + blue-slate primary
  // ═══════════════════════════════════════════════════════════════════════════

  /// Deep blue-slate — primary actions, gradients, key accents
  static const Color primaryColor = Color(0xFF1E4D6B);
  static const Color primaryLight = Color(0xFF2A6A8F);
  static const Color primaryDark = Color(0xFF153A52);
  static const Color primaryAccent = Color(0xFF2563A8);

  static const Color background = Color(0xFFF3EDE4);
  static const Color backgroundWhite = Color(0xFFFAF7F2);
  static const Color surface = Color(0xFFFFFCF8);
  static const Color surfaceLight = Color(0xFFF5EFE6);
  static const Color surfaceLighter = Color(0xFFEDE6DB);

  static const Color textPrimary = Color(0xFF1C1916);
  static const Color textSecondary = Color(0xFF5C5650);
  static const Color textTertiary = Color(0xFF8A837A);
  static const Color textMuted = Color(0xFFB8B0A6);

  static const Color hairline = Color(0xFFDCD4C8);

  static const Color success = Color(0xFF4A7C59);
  static const Color successLight = Color(0xFF6B9B7E);
  static const Color successBg = Color(0xFFE8F2EB);
  static const Color warning = Color(0xFFB8894A);
  static const Color warningLight = Color(0xFFD4A574);
  static const Color warningBg = Color(0xFFF8F0E4);
  static const Color error = Color(0xFFC45C4A);
  static const Color errorLight = Color(0xFFD17B6B);
  static const Color errorBg = Color(0xFFFCEEEB);
  static const Color info = Color(0xFF5F7280);
  static const Color infoLight = Color(0xFF8A9EAE);
  static const Color infoBg = Color(0xFFE9EEF2);

  /// Light washes for category / list accents
  static const Color pastelPink = Color(0xFFF5E8E6);
  static const Color pastelBlue = Color(0xFFE8EDF0);
  static const Color pastelGreen = Color(0xFFE8F0EA);
  static const Color pastelYellow = Color(0xFFF5EFE0);
  static const Color pastelPurple = Color(0xFFEDEAF2);
  static const Color pastelOrange = Color(0xFFE8EEF6); // cool wash (name kept for compatibility)
  static const Color pastelMint = Color(0xFFE6F0ED);
  static const Color pastelLavender = Color(0xFFEDEAF2);

  static const List<Color> primaryGradient = [Color(0xFF2A6A8F), Color(0xFF1E4D6B)];
  static const List<Color> accentGradient = [Color(0xFF3D7BA8), Color(0xFF1E4D6B)];
  static const List<Color> successGradient = [Color(0xFF7CB896), Color(0xFF4A7C59)];
  static const List<Color> warningGradient = [Color(0xFFE8C49A), Color(0xFFB8894A)];
  static const List<Color> errorGradient = [Color(0xFFE8A99D), Color(0xFFC45C4A)];
  static const List<Color> backgroundGradient = [Color(0xFFF3EDE4), Color(0xFFFAF7F2)];
  
  // Status Colors
  static const Color statusPending = Color(0xFFD4A574);
  static const Color statusAccepted = Color(0xFF8A9EAE);
  static const Color statusActive = Color(0xFF6B9B7E);
  static const Color statusCompleted = Color(0xFF1E4D6B);
  static const Color statusCancelled = Color(0xFFD17B6B);
=======

/// Dark Theme Design System
/// Blue and Orange professional theme
class AppTheme {
  // ═══════════════════════════════════════════════════════════════════════════
  // COLOR PALETTE - Dark Mode
  // ═══════════════════════════════════════════════════════════════════════════
  
  // Primary Colors
  static const Color primaryColor = Color(0xFF7C6FFF); // Indigo-purple for dark bg
  static const Color primaryLight = Color(0xFF9E94FF);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryAccent = Color(0xFFFF6B35); // Orange accent
  
  // Background Colors - Dark
  static const Color background = Color(0xFF0F1117); // Near black
  static const Color backgroundWhite = Color(0xFF1A1D26); // Dark surface
  static const Color surface = Color(0xFF1E2130); // Card surface
  static const Color surfaceLight = Color(0xFF252837); // Slightly lighter
  static const Color surfaceLighter = Color(0xFF2C3044); // Input fill
  
  // Text Colors - Light on dark background
  static const Color textPrimary = Color(0xFFF1F5F9); // Near white
  static const Color textSecondary = Color(0xFF94A3B8); // Muted blue-gray
  static const Color textTertiary = Color(0xFF64748B); // Dim gray
  static const Color textMuted = Color(0xFF374151); // Very dim
  
  // Soft Accent Colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF6EE7B7);
  static const Color successBg = Color(0xFF064E3B);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFCD34D);
  static const Color warningBg = Color(0xFF78350F);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFCA5A5);
  static const Color errorBg = Color(0xFF7F1D1D);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF93C5FD);
  static const Color infoBg = Color(0xFF1E3A5F);
  
  // Category Colors - Dark Pastels
  static const Color pastelPink = Color(0xFF3D1F24);
  static const Color pastelBlue = Color(0xFF1E2F4A);
  static const Color pastelGreen = Color(0xFF1A3328);
  static const Color pastelYellow = Color(0xFF3D2E0A);
  static const Color pastelPurple = Color(0xFF2A2450);
  static const Color pastelOrange = Color(0xFF3D2510);
  static const Color pastelMint = Color(0xFF0F302B);
  static const Color pastelLavender = Color(0xFF2A2450);
  
  // Gradient Colors
  static const List<Color> primaryGradient = [Color(0xFF7C6FFF), Color(0xFF4F46E5)];
  static const List<Color> accentGradient = [Color(0xFFFF6B35), Color(0xFFEA4C1E)];
  static const List<Color> successGradient = [Color(0xFF6EE7B7), Color(0xFF10B981)];
  static const List<Color> warningGradient = [Color(0xFFFCD34D), Color(0xFFF59E0B)];
  static const List<Color> errorGradient = [Color(0xFFFCA5A5), Color(0xFFEF4444)];
  static const List<Color> backgroundGradient = [Color(0xFF0F1117), Color(0xFF1A1D26)];
  
  // Status Colors
  static const Color statusPending = Color(0xFFF59E0B);
  static const Color statusAccepted = Color(0xFF3B82F6);
  static const Color statusActive = Color(0xFF10B981);
  static const Color statusCompleted = Color(0xFF6366F1);
  static const Color statusCancelled = Color(0xFFEF4444);
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739

  // ═══════════════════════════════════════════════════════════════════════════
  // SPACING - Clean Scale
  // ═══════════════════════════════════════════════════════════════════════════
  static const double spacing2xs = 2.0;
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacing2xl = 48.0;
  static const double spacing3xl = 64.0;

  // ═══════════════════════════════════════════════════════════════════════════
  // BORDER RADIUS - Smooth Rounded
  // ═══════════════════════════════════════════════════════════════════════════
  static const double radiusXs = 8.0;
  static const double radiusSm = 12.0;
  static const double radiusMd = 16.0;
  static const double radiusLg = 20.0;
  static const double radiusXl = 24.0;
  static const double radius2xl = 32.0;
  static const double radiusFull = 999.0;

  // ═══════════════════════════════════════════════════════════════════════════
  // SHADOWS - Soft, Light Shadows
  // ═══════════════════════════════════════════════════════════════════════════
  static List<BoxShadow> get shadowSm => [
    BoxShadow(
<<<<<<< HEAD
      color: const Color(0x12000000),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get shadowMd => [
    BoxShadow(
      color: const Color(0x16000000),
      blurRadius: 18,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get shadowLg => [
    BoxShadow(
      color: const Color(0x1A000000),
=======
      color: const Color(0x40000000),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> get shadowMd => [
    BoxShadow(
      color: const Color(0x50000000),
      blurRadius: 14,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get shadowLg => [
    BoxShadow(
      color: const Color(0x60000000),
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
      blurRadius: 28,
      offset: const Offset(0, 8),
    ),
  ];

  // ═══════════════════════════════════════════════════════════════════════════
  // CARD DECORATIONS
  // ═══════════════════════════════════════════════════════════════════════════
  static BoxDecoration get softCard => BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(radiusLg),
    boxShadow: shadowSm,
  );
  
  static BoxDecoration get cardWithBorder => BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(radiusLg),
<<<<<<< HEAD
    border: Border.all(color: hairline, width: 1),
=======
    border: Border.all(color: const Color(0xFF2C3044), width: 1),
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
    boxShadow: shadowSm,
  );
  
  static BoxDecoration softButton({List<Color>? gradient}) => BoxDecoration(
    gradient: gradient != null 
      ? LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight)
      : null,
    color: gradient == null ? surface : null,
    borderRadius: BorderRadius.circular(radiusFull),
    boxShadow: shadowSm,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // ANIMATION DURATIONS
  // ═══════════════════════════════════════════════════════════════════════════
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animNormal = Duration(milliseconds: 300);
  static const Duration animSlow = Duration(milliseconds: 500);

  // ═══════════════════════════════════════════════════════════════════════════
  // CURVES
  // ═══════════════════════════════════════════════════════════════════════════
  static const Curve curveFast = Curves.easeOutCubic;
  static const Curve curveNormal = Curves.easeInOutCubic;
  static const Curve curveSpring = Curves.easeOutBack;

  // ═══════════════════════════════════════════════════════════════════════════
<<<<<<< HEAD
  // THEME DATA — editorial typography (Fraunces display + DM Sans UI)
  // ═══════════════════════════════════════════════════════════════════════════

  static TextTheme get editorialTextTheme {
    return GoogleFonts.dmSansTextTheme(ThemeData.light().textTheme).copyWith(
      displayLarge: GoogleFonts.fraunces(
        fontSize: 34,
        fontWeight: FontWeight.w500,
        color: textPrimary,
        height: 1.12,
        letterSpacing: -0.9,
      ),
      displayMedium: GoogleFonts.fraunces(
        fontSize: 28,
        fontWeight: FontWeight.w500,
        color: textPrimary,
        height: 1.14,
        letterSpacing: -0.7,
      ),
      displaySmall: GoogleFonts.fraunces(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        color: textPrimary,
        height: 1.18,
        letterSpacing: -0.5,
      ),
      headlineLarge: GoogleFonts.fraunces(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.22,
        letterSpacing: -0.4,
      ),
      headlineMedium: GoogleFonts.fraunces(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: textPrimary,
        height: 1.28,
        letterSpacing: -0.3,
      ),
      headlineSmall: GoogleFonts.fraunces(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: textPrimary,
        height: 1.32,
        letterSpacing: -0.2,
      ),
      titleLarge: GoogleFonts.dmSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.4,
      ),
      titleMedium: GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.45,
      ),
      titleSmall: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textSecondary,
        height: 1.5,
      ),
      bodyLarge: GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        height: 1.55,
      ),
      bodyMedium: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        height: 1.55,
      ),
      bodySmall: GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textTertiary,
        height: 1.45,
      ),
      labelLarge: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        height: 1.4,
      ),
      labelMedium: GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: textSecondary,
        height: 1.4,
      ),
      labelSmall: GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: textTertiary,
        height: 1.4,
      ),
    );
  }

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: background,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      onPrimary: Colors.white,
      secondary: primaryAccent,
      onSecondary: Colors.white,
      surface: surface,
      onSurface: textPrimary,
      error: error,
      onError: Colors.white,
    ).copyWith(
      surfaceContainerHighest: surfaceLight,
      onSurfaceVariant: textSecondary,
      outline: hairline,
    ),

    appBarTheme: AppBarTheme(
=======
  // THEME DATA - Dark Theme
  // ═══════════════════════════════════════════════════════════════════════════
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: primaryAccent,
      surface: surface,
      surfaceContainerHighest: surfaceLight,
      onSurface: textPrimary,
      onSurfaceVariant: textSecondary,
      error: error,
      onError: Colors.white,
      outline: Color(0xFF2C3044),
    ),
    
    // AppBar Theme - Dark
    appBarTheme: const AppBarTheme(
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
      backgroundColor: background,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: true,
<<<<<<< HEAD
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: GoogleFonts.dmSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: -0.2,
=======
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: -0.3,
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
      ),
    ),
    
    // Card Theme - Clean white with soft shadow
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLg),
      ),
    ),
    
    // Elevated Button Theme - Soft gradient
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: spacingLg,
          vertical: spacingMd,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusFull),
        ),
<<<<<<< HEAD
        textStyle: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: textPrimary,
        side: const BorderSide(color: hairline, width: 1.5),
=======
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    ),
    
    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: textPrimary,
        side: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
        padding: const EdgeInsets.symmetric(
          horizontal: spacingLg,
          vertical: spacingMd,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusFull),
        ),
<<<<<<< HEAD
        textStyle: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        ),
      ),
    ),

=======
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    ),
    
    // Input Decoration Theme - Dark
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceLighter,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
<<<<<<< HEAD
        borderSide: const BorderSide(color: hairline, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: hairline, width: 1),
=======
        borderSide: const BorderSide(color: Color(0xFF2C3044), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: Color(0xFF2C3044), width: 1),
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: error, width: 2),
      ),
      contentPadding: const EdgeInsets.all(spacingMd),
      hintStyle: const TextStyle(
        color: textTertiary,
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
      labelStyle: const TextStyle(
        color: textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      prefixIconColor: textTertiary,
      suffixIconColor: textTertiary,
    ),
<<<<<<< HEAD

    textTheme: editorialTextTheme,

    dividerTheme: const DividerThemeData(
      color: hairline,
      thickness: 1,
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
=======
    
    // Text Theme - Clean typography
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: textPrimary,
        letterSpacing: -0.5,
        height: 1.2,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textPrimary,
        letterSpacing: -0.5,
        height: 1.2,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textPrimary,
        letterSpacing: -0.3,
        height: 1.3,
      ),
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: -0.3,
        height: 1.3,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: -0.2,
        height: 1.4,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: -0.1,
        height: 1.4,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.4,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0.1,
        height: 1.5,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textSecondary,
        letterSpacing: 0.1,
        height: 1.5,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        letterSpacing: 0,
        height: 1.6,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        letterSpacing: 0,
        height: 1.6,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textTertiary,
        letterSpacing: 0,
        height: 1.5,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        letterSpacing: 0.1,
        height: 1.4,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: textSecondary,
        letterSpacing: 0.1,
        height: 1.4,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: textTertiary,
        letterSpacing: 0.2,
        height: 1.4,
      ),
    ),
    
    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: Color(0xFF2C3044),
      thickness: 1,
    ),
    
    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
      backgroundColor: surface,
      selectedItemColor: primaryColor,
      unselectedItemColor: textTertiary,
      type: BottomNavigationBarType.fixed,
<<<<<<< HEAD
      elevation: 0,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedLabelStyle: GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),
  );

  // Dark palette — warm charcoal, same brand primary
  static const Color darkBg = Color(0xFF1C1916);
  static const Color darkSurface = Color(0xFF2A2620);
  static const Color darkSurfaceHigh = Color(0xFF36312A);
  static const Color darkTextPrimary = Color(0xFFF3EDE4);
  static const Color darkTextSecondary = Color(0xFFC4BCB2);
  static const Color darkHairline = Color(0xFF4A443C);

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBg,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.dark(
      primary: primaryLight,
      onPrimary: Colors.black,
      secondary: primaryAccent,
      onSecondary: Colors.white,
      surface: darkSurface,
      onSurface: darkTextPrimary,
      error: errorLight,
      onError: Colors.black,
    ).copyWith(
      surfaceContainerHighest: darkSurfaceHigh,
      onSurfaceVariant: darkTextSecondary,
      outline: darkHairline,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: darkBg,
      foregroundColor: darkTextPrimary,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: GoogleFonts.dmSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: darkTextPrimary,
        letterSpacing: -0.2,
      ),
    ),
    cardTheme: CardThemeData(
      color: darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLg),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: spacingLg,
          vertical: spacingMd,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusFull),
        ),
        textStyle: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: darkTextPrimary,
        side: const BorderSide(color: darkHairline, width: 1.5),
        padding: const EdgeInsets.symmetric(
          horizontal: spacingLg,
          vertical: spacingMd,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusFull),
        ),
        textStyle: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurfaceHigh,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: darkHairline, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: darkHairline, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: errorLight, width: 2),
      ),
      contentPadding: const EdgeInsets.all(spacingMd),
      hintStyle: const TextStyle(
        color: darkTextSecondary,
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
      labelStyle: const TextStyle(
        color: darkTextSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      prefixIconColor: darkTextSecondary,
      suffixIconColor: darkTextSecondary,
    ),
    textTheme: GoogleFonts.dmSansTextTheme(ThemeData.dark().textTheme).apply(
      bodyColor: darkTextPrimary,
      displayColor: darkTextPrimary,
    ),
    dividerTheme: const DividerThemeData(
      color: darkHairline,
      thickness: 1,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: darkSurface,
      selectedItemColor: primaryLight,
      unselectedItemColor: darkTextSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedLabelStyle: GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.dmSans(
=======
      elevation: 8,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}

<<<<<<< HEAD
=======
// ═══════════════════════════════════════════════════════════════════════════
// SOFT GRADIENT BUTTON WIDGET
// ═══════════════════════════════════════════════════════════════════════════
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
class SoftGradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final List<Color>? gradient;
  final Widget? icon;
  final double? width;
  final double height;
  final bool isLoading;
  final bool isOutlined;

  const SoftGradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.gradient,
    this.icon,
    this.width,
    this.height = 52,
    this.isLoading = false,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: width ?? double.infinity,
        height: height,
        decoration: isOutlined
          ? BoxDecoration(
<<<<<<< HEAD
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              border: Border.all(color: AppTheme.hairline, width: 1.5),
=======
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
            )
          : BoxDecoration(
              gradient: LinearGradient(
                colors: gradient ?? AppTheme.primaryGradient,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              boxShadow: AppTheme.shadowSm,
            ),
        child: Center(
          child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      color: isOutlined ? AppTheme.textPrimary : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SOFT CARD WIDGET
// ═══════════════════════════════════════════════════════════════════════════
class SoftCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final VoidCallback? onTap;

  const SoftCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: borderColor != null 
          ? Border.all(color: borderColor!, width: 1.5)
          : null,
        boxShadow: AppTheme.shadowSm,
      ),
      child: child,
    );

    if (onTap != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: cardContent,
          ),
        ),
      );
    }

    return cardContent;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CATEGORY CHIP WIDGET
// ═══════════════════════════════════════════════════════════════════════════
class CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: AppTheme.spacingSm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? iconColor.withOpacity(0.2) : backgroundColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: isSelected 
            ? Border.all(color: iconColor, width: 1.5)
            : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: iconColor,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? iconColor : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Professional Confirm Modal ────────────────────────────────────────────────
Future<bool> showConfirmModal(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = 'Cancel',
  Color confirmColor = AppTheme.error,
  IconData icon = Icons.warning_amber_rounded,
  Color iconColor = AppTheme.error,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.6),
    builder: (ctx) => _ConfirmModal(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      confirmColor: confirmColor,
      icon: icon,
      iconColor: iconColor,
    ),
  );
  return result == true;
}

class _ConfirmModal extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final Color confirmColor;
  final IconData icon;
  final Color iconColor;

  const _ConfirmModal({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.confirmColor,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        padding: const EdgeInsets.all(AppTheme.spacingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon circle
            Container(
              width: 68, height: 68,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 34, color: iconColor),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            // Title
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            // Message
            Text(
              message,
              style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingXl),
            // Buttons
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context, false),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        border: Border.all(color: AppTheme.surfaceLighter),
                      ),
                      child: Center(
                        child: Text(
                          cancelLabel,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context, true),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: confirmColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        border: Border.all(color: confirmColor.withOpacity(0.45)),
                      ),
                      child: Center(
                        child: Text(
                          confirmLabel,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: confirmColor),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
