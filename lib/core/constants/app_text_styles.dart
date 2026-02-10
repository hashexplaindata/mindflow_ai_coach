import 'package:flutter/material.dart';
import 'app_colors.dart';

/// MindFlow AI Coach Typography System
/// Based on Headspace design language
///
/// Key principles:
/// - System fonts for performance (SF Pro on iOS, Roboto on Android)
/// - Generous line height (min 1.4x)
/// - No pure black for text
/// - Bold for headings only, medium weight for body
class AppTextStyles {
  AppTextStyles._();

  // ============================================
  // HEADINGS
  // ============================================

  /// Large heading - Welcome screens, section titles
  static const TextStyle headingLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
    color: AppColors.neutralBlack,
    letterSpacing: -0.5,
  );

  /// Medium heading - Card titles, dialog headers
  static const TextStyle headingMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.3,
    color: AppColors.neutralBlack,
    letterSpacing: -0.3,
  );

  /// Small heading - Section headers, list titles
  static const TextStyle headingSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.neutralBlack,
    letterSpacing: -0.2,
  );

  // ============================================
  // BODY TEXT
  // ============================================

  /// Large body - Featured content, lead paragraphs
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.normal,
    height: 1.6,
    color: AppColors.neutralDark,
  );

  /// Medium body - Default text, chat messages
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.6,
    color: AppColors.neutralDark,
  );

  /// Small body - Secondary text, helper text
  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: AppColors.neutralDark,
  );

  // ============================================
  // CAPTIONS & LABELS
  // ============================================

  /// Caption - Timestamps, labels, hints
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.4,
    color: AppColors.neutralMedium,
  );

  /// Label - Form labels, tab labels
  static const TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.neutralDark,
    letterSpacing: 0.1,
  );

  /// Overline - Category labels, small headers
  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 1.5,
    color: AppColors.neutralMedium,
    letterSpacing: 1.5,
  );

  // ============================================
  // BUTTONS
  // ============================================

  /// Primary button text
  static const TextStyle buttonPrimary = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: Colors.white,
  );

  /// Secondary button text
  static const TextStyle buttonSecondary = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: AppColors.neutralDark,
  );

  /// Small button / link text
  static const TextStyle buttonSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    color: AppColors.primaryOrange,
  );

  /// Medium button text
  static const TextStyle buttonMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
    color: AppColors.neutralDark,
  );

  // ============================================
  // CHAT-SPECIFIC
  // ============================================

  /// User message text
  static const TextStyle chatUser = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: Colors.white,
  );

  /// Assistant message text
  static const TextStyle chatAssistant = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: AppColors.neutralBlack,
  );

  /// Chat timestamp
  static const TextStyle chatTimestamp = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.normal,
    height: 1.3,
    color: AppColors.neutralMedium,
  );

  // ============================================
  // NLP PROFILE SPECIFIC
  // ============================================

  /// Profile type name (e.g., "The Visionary Achiever")
  static const TextStyle profileType = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.2,
    color: AppColors.primaryOrange,
    letterSpacing: -0.3,
  );

  /// Question text in onboarding
  static const TextStyle question = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.neutralBlack,
  );

  /// Answer option text
  static const TextStyle answerOption = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
    color: AppColors.neutralDark,
  );
}
