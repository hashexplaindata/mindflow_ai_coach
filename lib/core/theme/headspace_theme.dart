import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_spacing.dart';

/// MindFlow AI Coach Theme Configuration
/// Headspace-inspired "Warm Minimalism" design system
///
/// Key principles:
/// - Emotion-driven design (calm, safe, motivated, delighted)
/// - Generous "Air" spacing
/// - Soft & round everything
/// - Warm color palette
class HeadspaceTheme {
  HeadspaceTheme._();

  /// Light theme (default)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // ============================================
      // COLOR SCHEME
      // ============================================
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryOrange,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryOrangeLight,
        onPrimaryContainer: AppColors.neutralBlack,
        secondary: AppColors.sage,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.sageLight,
        onSecondaryContainer: AppColors.neutralBlack,
        tertiary: AppColors.accentBlue,
        onTertiary: Colors.white,
        error: AppColors.errorRed,
        onError: Colors.white,
        surface: AppColors.cream,
        onSurface: AppColors.neutralBlack,
        surfaceContainerHighest: AppColors.cardBackground,
        outline: AppColors.neutralMedium,
      ),

      // ============================================
      // SCAFFOLD
      // ============================================
      scaffoldBackgroundColor: AppColors.cream,

      // ============================================
      // APP BAR
      // ============================================
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.neutralBlack,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: AppTextStyles.headingSmall,
        iconTheme: IconThemeData(
          color: AppColors.neutralBlack,
          size: 24,
        ),
      ),

      // ============================================
      // CARDS
      // ============================================
      cardTheme: const CardThemeData(
        color: AppColors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.all(Radius.circular(AppSpacing.radiusCard)),
        ),
        margin: EdgeInsets.symmetric(
          horizontal: AppSpacing.spacing16,
          vertical: AppSpacing.spacing8,
        ),
      ),

      // ============================================
      // ELEVATED BUTTON (Primary CTA)
      // ============================================
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryOrange,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPaddingHorizontal,
            vertical: AppSpacing.buttonPaddingVertical,
          ),
          minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          ),
          textStyle: AppTextStyles.buttonPrimary,
        ),
      ),

      // ============================================
      // OUTLINED BUTTON (Secondary/Ghost)
      // ============================================
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.neutralDark,
          side: const BorderSide(
            color: AppColors.neutralDark,
            width: 2,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPaddingHorizontal,
            vertical: AppSpacing.buttonPaddingVertical,
          ),
          minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          ),
          textStyle: AppTextStyles.buttonSecondary,
        ),
      ),

      // ============================================
      // TEXT BUTTON
      // ============================================
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryOrange,
          textStyle: AppTextStyles.buttonSmall,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spacing16,
            vertical: AppSpacing.spacing8,
          ),
        ),
      ),

      // ============================================
      // INPUT DECORATION
      // ============================================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardBackground,
        contentPadding: const EdgeInsets.all(AppSpacing.inputPadding),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
          borderSide: const BorderSide(
            color: AppColors.neutralMedium,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
          borderSide: const BorderSide(
            color: AppColors.primaryOrange,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
          borderSide: const BorderSide(
            color: AppColors.errorRed,
            width: 1,
          ),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textHint,
        ),
        labelStyle: AppTextStyles.label,
        errorStyle: AppTextStyles.caption.copyWith(
          color: AppColors.errorRed,
        ),
      ),

      // ============================================
      // FLOATING ACTION BUTTON
      // ============================================
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryOrange,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
        ),
      ),

      // ============================================
      // BOTTOM NAVIGATION
      // ============================================
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardBackground,
        selectedItemColor: AppColors.primaryOrange,
        unselectedItemColor: AppColors.neutralMedium,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: AppTextStyles.caption,
        unselectedLabelStyle: AppTextStyles.caption,
      ),

      // ============================================
      // DIALOG
      // ============================================
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.cardBackground,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        ),
        titleTextStyle: AppTextStyles.headingMedium,
        contentTextStyle: AppTextStyles.bodyMedium,
      ),

      // ============================================
      // SNACKBAR (Use sparingly - prefer Soft Alerts)
      // ============================================
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.neutralBlack,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ============================================
      // PROGRESS INDICATORS
      // ============================================
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryOrange,
        linearTrackColor: AppColors.neutralLight,
        circularTrackColor: AppColors.neutralLight,
      ),

      // ============================================
      // DIVIDER
      // ============================================
      dividerTheme: const DividerThemeData(
        color: AppColors.neutralMedium,
        thickness: 1,
        space: AppSpacing.spacing24,
      ),

      // ============================================
      // CHIP
      // ============================================
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.neutralLight,
        selectedColor: AppColors.primaryOrangeLight,
        labelStyle: AppTextStyles.label,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spacing12,
          vertical: AppSpacing.spacing8,
        ),
      ),

      // ============================================
      // TEXT THEME
      // ============================================
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.headingLarge,
        displayMedium: AppTextStyles.headingMedium,
        displaySmall: AppTextStyles.headingSmall,
        headlineLarge: AppTextStyles.headingLarge,
        headlineMedium: AppTextStyles.headingMedium,
        headlineSmall: AppTextStyles.headingSmall,
        titleLarge: AppTextStyles.headingSmall,
        titleMedium: AppTextStyles.bodyLarge,
        titleSmall: AppTextStyles.bodyMedium,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.buttonPrimary,
        labelMedium: AppTextStyles.label,
        labelSmall: AppTextStyles.caption,
      ),
    );
  }

  // ============================================
  // CUSTOM DECORATIONS (For manual use)
  // ============================================

  /// Soft card shadow (Headspace style)
  static List<BoxShadow> get cardShadow => [
        const BoxShadow(
          color: Color(0x0F000000),
          blurRadius: AppSpacing.shadowBlur,
          offset: Offset(0, AppSpacing.shadowOffset),
        ),
      ];

  /// Primary button shadow
  static List<BoxShadow> get buttonShadow => [
        const BoxShadow(
          color: Color(0x4CF4A261),
          blurRadius: AppSpacing.buttonShadowBlur,
          offset: Offset(0, 4),
        ),
      ];

  /// Card decoration with soft shadow
  static BoxDecoration get cardDecoration => BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        boxShadow: cardShadow,
      );

  /// Primary gradient button decoration
  static BoxDecoration get primaryButtonDecoration => BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
        boxShadow: buttonShadow,
      );
}
