/// MindFlow AI Coach Spacing System
/// Based on Headspace "Air" Principle - 8dp grid
/// 
/// Key rules:
/// - Minimum 16dp padding inside ALL cards/containers
/// - Minimum 24dp margin between major sections
/// - Never stack elements tightly
/// - All spacing in multiples of 8
class AppSpacing {
  AppSpacing._();

  // ============================================
  // BASE SPACING UNITS (8dp Grid)
  // ============================================
  
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;
  static const double spacing64 = 64.0;
  
  // ============================================
  // SEMANTIC SPACING
  // ============================================
  
  /// Card internal padding (minimum 16dp per Headspace)
  static const double cardPadding = spacing16;
  static const double cardPaddingLarge = spacing24;
  
  /// Section gaps (minimum 24dp between major sections)
  static const double sectionGap = spacing24;
  static const double sectionGapLarge = spacing32;
  
  /// Icon to text gap
  static const double iconTextGap = spacing12;
  
  /// List item spacing
  static const double listItemGap = spacing12;
  
  /// Screen edge padding
  static const double screenPadding = spacing24;
  static const double screenPaddingSmall = spacing16;
  
  /// Button internal padding
  static const double buttonPaddingHorizontal = spacing24;
  static const double buttonPaddingVertical = spacing16;
  
  /// Input field padding
  static const double inputPadding = spacing16;
  
  // ============================================
  // BORDER RADIUS (Soft & Round Everything)
  // ============================================
  
  /// All cards - minimum 20dp per Headspace
  static const double radiusCard = 20.0;
  
  /// All buttons - pill-shaped, minimum 24dp
  static const double radiusButton = 24.0;
  
  /// All images
  static const double radiusImage = 16.0;
  
  /// Input fields
  static const double radiusInput = 16.0;
  
  /// Small elements (chips, badges)
  static const double radiusSmall = 12.0;
  
  /// Full round (avatars, icons)
  static const double radiusFull = 999.0;
  
  // ============================================
  // TOUCH TARGETS (Accessibility)
  // ============================================
  
  /// Minimum touch target size per Headspace
  static const double minTouchTarget = 48.0;
  
  /// Comfortable button height
  static const double buttonHeight = 56.0;
  
  /// Icon button size
  static const double iconButtonSize = 48.0;
  
  // ============================================
  // ELEVATION & SHADOWS
  // ============================================
  
  /// Card shadow blur radius
  static const double shadowBlur = 16.0;
  
  /// Card shadow offset
  static const double shadowOffset = 4.0;
  
  /// Button shadow blur
  static const double buttonShadowBlur = 12.0;
}
