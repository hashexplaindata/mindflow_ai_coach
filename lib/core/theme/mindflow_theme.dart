import 'package:flutter/material.dart';

/// **MindFlow Design System**
///
/// **Philosophy:** Jobs-inspired minimalism meets neuroscience.
///
/// **Core Principles:**
/// 1. **Base-8 Modular Scale**: All spacing/sizing in multiples of 8px
/// 2. **Cream Background**: Warm, calming (not harsh white)
/// 3. **Sage Accents**: Natural, grounding green tones
/// 4. **Obsidian Text**: Softer than pure black, easier on eyes
/// 5. **Golden Ratio**: Typography scales at 1.618x
/// 6. **Zero Friction**: Every interaction feels inevitable
///
/// **The Story:** Like Apple's Jony Ive meets B.J. Fogg's behavior model.
/// Beautiful enough to inspire, simple enough to disappear.

class MindFlowTheme {
  // =============================================================================
  // COLOR PALETTE (Jobs-Inspired Minimalism)
  // =============================================================================

  /// Primary background - Warm cream (reduces eye strain vs white)
  static const Color cream = Color(0xFFFAF8F3);

  /// Secondary background - Lighter cream for cards
  static const Color creamLight = Color(0xFFFFFDFA);

  /// Sage green - Natural, grounding accent
  static const Color sage = Color(0xFF8B9D83);
  static const Color sageLight = Color(0xFFA8B8A0);
  static const Color sageDark = Color(0xFF6B7D63);

  /// Obsidian - Softer than black, easier on eyes
  static const Color obsidian = Color(0xFF2D2D2D);
  static const Color obsidianLight = Color(0xFF4A4A4A);

  /// Flow state indicator - Vibrant but not alarming
  static const Color flowBlue = Color(0xFF5B9BD5);

  /// Crisis/Alert - Warm red (not harsh)
  static const Color warmRed = Color(0xFFD97373);

  /// Success/Habit - Natural green
  static const Color successGreen = Color(0xFF7EBD9F);

  // =============================================================================
  // BASE-8 SPACING SYSTEM
  // =============================================================================

  /// Base unit = 8px (4px for hairline dividers only)
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing16 = 16.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing12 = 12.0;
  static const double spacing48 = 48.0;
  static const double spacing64 = 64.0;
  static const double spacing96 = 96.0;

  /// Border radius (multiples of 8)
  static const double radius8 = 8.0;
  static const double radius16 = 16.0;
  static const double radius24 = 24.0;

  // =============================================================================
  // TYPOGRAPHY (Golden Ratio Scale: 1.618)
  // =============================================================================

  /// Base font size = 16px
  static const double fontBase = 16.0;

  /// Golden ratio scale
  static const double fontSmall = 13.0; // 16 / 1.231
  static const double fontMedium = 16.0; // Base
  static const double fontLarge = 21.0; // 16 * 1.313
  static const double fontXLarge = 26.0; // 16 * 1.625
  static const double fontXXLarge = 42.0; // 16 * 2.618
  static const double fontDisplay = 68.0; // 16 * 4.236

  /// Font weights (restricted palette for clarity)
  static const FontWeight weightRegular = FontWeight.w400;
  static const FontWeight weightMedium = FontWeight.w500;
  static const FontWeight weightSemiBold = FontWeight.w600;

  // =============================================================================
  // THEME DATA (Flutter Integration)
  // =============================================================================

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.light(
          primary: sage,
          onPrimary: cream,
          secondary: sageLight,
          onSecondary: obsidian,
          surface: cream,
          onSurface: obsidian,
          error: warmRed,
          onError: cream,
        ),
        scaffoldBackgroundColor: cream,
        cardColor: creamLight,
        dividerColor: obsidian.withValues(alpha: 0.1),

        // Typography
        textTheme: TextTheme(
          displayLarge: TextStyle(
            fontSize: fontDisplay,
            fontWeight: weightSemiBold,
            color: obsidian,
            height: 1.1,
          ),
          displayMedium: TextStyle(
            fontSize: fontXXLarge,
            fontWeight: weightSemiBold,
            color: obsidian,
            height: 1.2,
          ),
          headlineLarge: TextStyle(
            fontSize: fontXLarge,
            fontWeight: weightMedium,
            color: obsidian,
            height: 1.3,
          ),
          headlineMedium: TextStyle(
            fontSize: fontLarge,
            fontWeight: weightMedium,
            color: obsidian,
            height: 1.4,
          ),
          bodyLarge: TextStyle(
            fontSize: fontMedium,
            fontWeight: weightRegular,
            color: obsidian,
            height: 1.5,
          ),
          bodyMedium: TextStyle(
            fontSize: fontMedium,
            fontWeight: weightRegular,
            color: obsidianLight,
            height: 1.5,
          ),
          bodySmall: TextStyle(
            fontSize: fontSmall,
            fontWeight: weightRegular,
            color: obsidianLight,
            height: 1.4,
          ),
        ),

        // Elevation (subtle shadows in cream theme)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: sage,
            foregroundColor: cream,
            padding: const EdgeInsets.symmetric(
              horizontal: spacing24,
              vertical: spacing16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius16),
            ),
            elevation: 0, // Flat design
          ),
        ),

        // Cards
        cardTheme: CardThemeData(
          color: creamLight,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius16),
            side: BorderSide(
              color: obsidian.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
        ),

        // App bar (invisible, content-first)
        appBarTheme: const AppBarTheme(
          backgroundColor: cream,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: fontXLarge,
            fontWeight: weightMedium,
            color: obsidian,
          ),
        ),
      );

  // =============================================================================
  // ANIMATION DURATIONS (Based on Human Perception)
  // =============================================================================

  /// Instant feedback (button press)
  static const Duration durationInstant = Duration(milliseconds: 100);

  /// Quick transitions (card flip, modal)
  static const Duration durationQuick = Duration(milliseconds: 250);

  /// Standard animation (page transition)
  static const Duration durationStandard = Duration(milliseconds: 400);

  /// Slow reveal (focus induction start)
  static const Duration durationSlow = Duration(milliseconds: 800);

  /// Breathing animation cycle
  static const Duration durationBreath = Duration(milliseconds: 4000);

  // =============================================================================
  // ANIMATION CURVES (Physics-Based)
  // =============================================================================

  /// Default curve (feels natural)
  static const Curve curveStandard = Curves.easeInOutCubic;

  /// Bounce curve (playful feedback)
  static const Curve curveBounce = Curves.elasticOut;

  /// Deceleration (drawer close)
  static const Curve curveDecelerate = Curves.easeOut;

  /// Acceleration (drawer open)
  static const Curve curveAccelerate = Curves.easeIn;

  // =============================================================================
  // HELPER METHODS
  // =============================================================================

  /// Creates a subtle shadow for cards (depth without harshness)
  static BoxShadow get subtleShadow => BoxShadow(
        color: obsidian.withValues(alpha: 0.06),
        blurRadius: 8,
        offset: const Offset(0, 2),
      );

  /// Creates a gradient background for special states
  static LinearGradient get creamGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [cream, creamLight],
      );

  /// Flow state gradient (subtle blue shimmer)
  static LinearGradient get flowGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          flowBlue.withValues(alpha: 0.1),
          flowBlue.withValues(alpha: 0.05),
        ],
      );
}

// =============================================================================
// REUSABLE UI COMPONENTS
// =============================================================================

/// **MindFlow Card**
///
/// A minimal card with Base-8 spacing and subtle borders
class MindFlowCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  const MindFlowCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(MindFlowTheme.radius16),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(MindFlowTheme.spacing16),
          child: child,
        ),
      ),
    );
  }
}

/// **MindFlow Button**
///
/// Primary action button with SpringSimulation physics
class MindFlowButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  const MindFlowButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(MindFlowTheme.cream),
              ),
            )
          : Text(label),
    );
  }
}
