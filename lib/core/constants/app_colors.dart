import 'package:flutter/material.dart';

/// MindFlow AI Coach Color System
/// Based on Headspace "Warm Minimalism" design language
///
/// Color philosophy: Calm, Safe, Motivated, Delighted
/// Never use pure black (#000000) or pure white (#FFFFFF)
class AppColors {
  AppColors._();

  // ============================================
  // PRIMARY PALETTE (Warm & Approachable)
  // ============================================

  /// Warm Orange/Peach - Primary Brand Color
  static const Color primaryOrange = Color(0xFFF4A261);
  static const Color primaryOrangeLight = Color(0xFFFFB88C);
  static const Color primaryOrangeDark = Color(0xFFE76F51);

  /// Burnt Orange - For strong CTAs (per @Architect rules)
  static const Color burntOrange = Color(0xFFCC5500);

  // ============================================
  // ACCENT PALETTE
  // ============================================

  /// Soft Blue - Calm & Trust
  static const Color accentBlue = Color(0xFF8ECAE6);
  static const Color accentBlueDark = Color(0xFF219EBC);

  /// Gentle Yellow - Energy & Optimism
  static const Color accentYellow = Color(0xFFFFC857);

  /// Muted Purple - Mindfulness
  static const Color accentPurple = Color(0xFFB8A9C9);

  /// Sage Green - Natural, calming (Simon's preferred)
  static const Color sage = Color(0xFFB2AC88);
  static const Color sageLight = Color(0xFFC5C0A0);
  static const Color sageDark = Color(0xFF9A9470);

  // ============================================
  // NEUTRAL PALETTE (Warm Grays)
  // ============================================

  /// Never pure white - use these instead
  static const Color cream = Color(0xFFF5F5DC);
  static const Color softWhite = Color(0xFFFAFAFA);
  static const Color neutralLight = Color(0xFFF8F8F8);
  static const Color neutralMedium = Color(0xFFE0E0E0);

  /// Never pure black - use these instead
  static const Color neutralDark = Color(0xFF4A4A4A);
  static const Color neutralBlack = Color(0xFF2B2B2B);

  // ============================================
  // BACKGROUND COLORS
  // ============================================

  /// Default screen background - warm cream
  static const Color background = cream;
  static const Color backgroundWhite = Color(0xFFFAFAFA);
  static const Color backgroundGray = Color(0xFFF5F5F5);

  /// Card backgrounds
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBackgroundElevated = Color(0xFFFFFFF8);

  // ============================================
  // SEMANTIC COLORS
  // ============================================

  /// Success - Gentle Green (not harsh)
  static const Color successGreen = Color(0xFF81C784);

  /// Warning - Soft Amber
  static const Color warningAmber = Color(0xFFFFD54F);

  /// Error - Muted Red (never harsh red)
  static const Color errorRed = Color(0xFFE57373);

  /// Info - Soft Blue
  static const Color infoBlue = accentBlue;

  // ============================================
  // SHADOW COLORS
  // ============================================

  /// Soft shadow for cards (Headspace style)
  static const Color shadowLight = Color(0x0F000000);
  static const Color shadowMedium = Color(0x1A000000);

  // ============================================
  // TEXT COLORS
  // ============================================

  /// Primary text color (never pure black)
  static const Color textPrimary = neutralBlack;

  /// Secondary text color
  static const Color textSecondary = neutralDark;

  /// Hint/placeholder text
  static const Color textHint = neutralMedium;

  /// Text on primary color buttons
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ============================================
  // GRADIENTS
  // ============================================

  /// Primary button gradient (Headspace style)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryOrange, primaryOrangeDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Calm background gradient
  static const LinearGradient calmGradient = LinearGradient(
    colors: [cream, softWhite],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Sage accent gradient
  static const LinearGradient sageGradient = LinearGradient(
    colors: [sageLight, sage],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============================================
  // JOBS PALETTE (Steve Jobs-inspired minimalism)
  // ============================================

  /// Cream - Primary background, warm and inviting
  static const Color jobsCream = Color(0xFFF9F9F2);

  /// Sage - Accent color, natural and calming
  static const Color jobsSage = Color(0xFF94A684);

  /// Obsidian - Text and primary elements, sophisticated black
  static const Color jobsObsidian = Color(0xFF1D1D1F);

  /// Jobs palette gradient
  static const LinearGradient jobsGradient = LinearGradient(
    colors: [jobsSage, Color(0xFF7A8C6A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
