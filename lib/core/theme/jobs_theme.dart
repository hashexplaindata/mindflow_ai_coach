import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';

class JobsTheme {
  JobsTheme._();

  static const double _radius = 32.0;
  static const double _lineHeight = 1.5;
  static const String _fontFamily = 'DM Sans';

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: _fontFamily,
      colorScheme: const ColorScheme.light(
        primary: AppColors.jobsSage,
        onPrimary: AppColors.jobsCream,
        primaryContainer: AppColors.jobsSage,
        onPrimaryContainer: AppColors.jobsCream,
        secondary: AppColors.jobsSage,
        onSecondary: AppColors.jobsCream,
        secondaryContainer: AppColors.jobsSage,
        onSecondaryContainer: AppColors.jobsCream,
        surface: AppColors.jobsCream,
        onSurface: AppColors.jobsObsidian,
        surfaceContainerHighest: AppColors.jobsCream,
        outline: Colors.transparent,
        error: const Color(0xFFDC3545),
        onError: AppColors.jobsCream,
      ),
      scaffoldBackgroundColor: AppColors.jobsCream,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.jobsCream,
        foregroundColor: AppColors.jobsObsidian,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: _lineHeight,
          color: AppColors.jobsObsidian,
          letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.jobsObsidian,
          size: 24,
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.jobsCream,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(_radius)),
          side: BorderSide.none,
        ),
        margin: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.jobsObsidian,
          foregroundColor: AppColors.jobsCream,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
            side: BorderSide.none,
          ),
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: _lineHeight,
            letterSpacing: 0.3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.jobsObsidian,
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
          ),
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: _lineHeight,
            letterSpacing: 0.3,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.jobsSage,
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: _lineHeight,
            letterSpacing: 0.2,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: BorderSide.none,
        ),
        hintStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.normal,
          height: _lineHeight,
          color: AppColors.jobsObsidian.withValues(alpha: 0.4),
        ),
        labelStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: _lineHeight,
          color: AppColors.jobsObsidian,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.jobsSage,
        foregroundColor: AppColors.jobsCream,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.jobsCream,
        selectedItemColor: AppColors.jobsObsidian,
        unselectedItemColor: AppColors.jobsObsidian.withValues(alpha: 0.4),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: _lineHeight,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.normal,
          height: _lineHeight,
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.jobsCream,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(_radius)),
        ),
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          height: _lineHeight,
          color: AppColors.jobsObsidian,
        ),
        contentTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.normal,
          height: _lineHeight,
          color: AppColors.jobsObsidian,
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.jobsObsidian,
        contentTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.normal,
          height: _lineHeight,
          color: AppColors.jobsCream,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(_radius)),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.jobsSage,
        linearTrackColor: const Color(0xFFE5E5E0),
        circularTrackColor: const Color(0xFFE5E5E0),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.jobsObsidian.withValues(alpha: 0.1),
        thickness: 1,
        space: 32,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.jobsSage.withValues(alpha: 0.15),
        selectedColor: AppColors.jobsSage,
        labelStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: _lineHeight,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
          side: BorderSide.none,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          height: _lineHeight,
          color: AppColors.jobsObsidian,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          height: _lineHeight,
          color: AppColors.jobsObsidian,
          letterSpacing: -0.3,
        ),
        displaySmall: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          height: _lineHeight,
          color: AppColors.jobsObsidian,
          letterSpacing: -0.2,
        ),
        headlineLarge: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          height: _lineHeight,
          color: AppColors.jobsObsidian,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          height: _lineHeight,
          color: AppColors.jobsObsidian,
          letterSpacing: -0.3,
        ),
        headlineSmall: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: _lineHeight,
          color: AppColors.jobsObsidian,
          letterSpacing: -0.2,
        ),
        titleLarge: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: _lineHeight,
          color: AppColors.jobsObsidian,
        ),
        titleMedium: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w500,
          height: _lineHeight,
          color: AppColors.jobsObsidian,
        ),
        titleSmall: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: _lineHeight,
          color: AppColors.jobsObsidian,
        ),
        bodyLarge: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.normal,
          height: _lineHeight,
          color: AppColors.jobsObsidian,
        ),
        bodyMedium: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.normal,
          height: _lineHeight,
          color: AppColors.jobsObsidian,
        ),
        bodySmall: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.normal,
          height: _lineHeight,
          color: AppColors.jobsObsidian,
        ),
        labelLarge: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: _lineHeight,
          letterSpacing: 0.3,
        ),
        labelMedium: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: _lineHeight,
        ),
        labelSmall: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.normal,
          height: _lineHeight,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: _fontFamily,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.jobsSageDark,
        onPrimary: AppColors.jobsCreamDark,
        primaryContainer: AppColors.jobsSageDark,
        onPrimaryContainer: AppColors.jobsCreamDark,
        secondary: AppColors.jobsSageDark,
        onSecondary: AppColors.jobsCreamDark,
        secondaryContainer: AppColors.jobsSageDark,
        onSecondaryContainer: AppColors.jobsCreamDark,
        surface: AppColors.jobsCreamDark,
        onSurface: AppColors.jobsObsidianDark,
        surfaceContainerHighest: AppColors.surfaceDark,
        outline: Colors.transparent,
        error: const Color(0xFFCF6679),
        onError: AppColors.jobsCreamDark,
      ),
      scaffoldBackgroundColor: AppColors.jobsCreamDark,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.jobsCreamDark,
        foregroundColor: AppColors.jobsObsidianDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: _lineHeight,
          color: AppColors.jobsObsidianDark,
          letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.jobsObsidianDark,
          size: 24,
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.cardBackgroundDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(_radius)),
          side: BorderSide.none,
        ),
        margin: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.jobsObsidianDark,
          foregroundColor: AppColors.jobsCreamDark,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
            side: BorderSide.none,
          ),
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: _lineHeight,
            letterSpacing: 0.3,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        contentPadding: const EdgeInsets.all(20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: BorderSide.none,
        ),
        hintStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.normal,
          height: _lineHeight,
          color: AppColors.jobsObsidianDark.withValues(alpha: 0.4),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.jobsCreamDark,
        selectedItemColor: AppColors.jobsObsidianDark,
        unselectedItemColor: AppColors.jobsObsidianDark.withValues(alpha: 0.4),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: _lineHeight,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.normal,
          height: _lineHeight,
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.cardBackgroundDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(_radius)),
        ),
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          height: _lineHeight,
          color: AppColors.jobsObsidianDark,
        ),
        contentTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.normal,
          height: _lineHeight,
          color: AppColors.jobsObsidianDark,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          height: _lineHeight,
          color: AppColors.jobsObsidianDark,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          height: _lineHeight,
          color: AppColors.jobsObsidianDark,
          letterSpacing: -0.3,
        ),
        bodyLarge: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.normal,
          height: _lineHeight,
          color: AppColors.jobsObsidianDark,
        ),
        bodyMedium: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.normal,
          height: _lineHeight,
          color: AppColors.jobsObsidianDark,
        ),
        bodySmall: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.normal,
          height: _lineHeight,
          color: AppColors.jobsObsidianDark,
        ),
      ),
    );
  }

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: AppColors.jobsObsidian.withValues(alpha: 0.04),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get buttonShadow => [
        BoxShadow(
          color: AppColors.jobsSage.withValues(alpha: 0.2),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static BoxDecoration get cardDecoration => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_radius),
        boxShadow: cardShadow,
      );

  static BoxDecoration get primaryButtonDecoration => BoxDecoration(
        color: AppColors.jobsObsidian,
        borderRadius: BorderRadius.circular(_radius),
        boxShadow: buttonShadow,
      );

  static BoxDecoration get sageButtonDecoration => BoxDecoration(
        color: AppColors.jobsSage,
        borderRadius: BorderRadius.circular(_radius),
        boxShadow: buttonShadow,
      );
}
