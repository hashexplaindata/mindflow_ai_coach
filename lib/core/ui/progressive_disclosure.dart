import 'package:flutter/material.dart';
import '../theme/mindflow_theme.dart';

/// **Progressive Disclosure UI Patterns**
///
/// **Problem:** Information overload triggers cognitive fatigue and decision paralysis.
///
/// **Solution:** Progressive disclosure - show only what's needed right now,
/// reveal more as user demonstrates readiness (through engagement signals).
///
/// **The 3-Click Rule:** Any core action must be reachable in ≤3 taps.
///
/// **Cognitive Load Budget:** UI elements have a "load cost". Stay under budget.

class ProgressiveDisclosure {
  /// **Cognitive Load Cost Model**
  ///
  /// Each UI element has a cognitive "cost":
  /// - Button: 5 points
  /// - Text field: 10 points
  /// - Dropdown: 15 points
  /// - Multi-step form: 25+ points
  ///
  /// **Budget:** Screen should stay under 50 points total
  static Map<String, int> getLoadCosts() {
    return {
      'button': 5,
      'text_field': 10,
      'checkbox': 7,
      'dropdown': 15,
      'slider': 8,
      'multi_step_form': 25,
      'chart': 20,
    };
  }

  /// Validates that a screen stays under cognitive load budget
  static bool validateLoadBudget(Map<String, int> elements) {
    const maxBudget = 50;
    int totalLoad = 0;

    elements.forEach((element, count) {
      final cost = getLoadCosts()[element] ?? 0;
      totalLoad += cost * count;
    });

    return totalLoad <= maxBudget;
  }

  /// **Disclosure Levels** (Show info progressively)
  ///
  /// Level 1: Essential only (new users, high stress)
  /// Level 2: Add helpful context (engaged users)
  /// Level 3: Full insights (power users, high rapport)
  static Map<int, List<String>> getDisclosureLevels() {
    return {
      1: ['Start Session', 'View Streak'], // Minimal
      2: ['Start Session', 'View Streak', 'Insights', 'Settings'], // Standard
      3: [
        'Start Session',
        'View Streak',
        'Insights',
        'Settings',
        'Advanced Stats',
        'Export Data'
      ], // Power user
    };
  }

  /// Determines appropriate disclosure level based on user state
  static int determineLevel({
    required double cognitiveLoad,
    required double rapportScore,
    required int sessionCount,
  }) {
    // High load = minimal UI
    if (cognitiveLoad > 0.7) return 1;

    // New users = standard UI
    if (sessionCount < 10) return 2;

    // High rapport + low load = full UI
    if (rapportScore > 0.85 && cognitiveLoad < 0.3) return 3;

    // Default
    return 2;
  }
}

/// **Adaptive Card Component**
///
/// Reveals more detail on tap, collapses when not needed
class AdaptiveCard extends StatefulWidget {
  final String title;
  final String summary;
  final Widget? detailContent;
  final bool initiallyExpanded;

  const AdaptiveCard({
    super.key,
    required this.title,
    required this.summary,
    this.detailContent,
    this.initiallyExpanded = false,
  });

  @override
  State<AdaptiveCard> createState() => _AdaptiveCardState();
}

class _AdaptiveCardState extends State<AdaptiveCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: widget.detailContent != null
            ? () => setState(() => _isExpanded = !_isExpanded)
            : null,
        borderRadius: BorderRadius.circular(MindFlowTheme.radius16),
        child: Padding(
          padding: const EdgeInsets.all(MindFlowTheme.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  if (widget.detailContent != null)
                    Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: MindFlowTheme.sage,
                    ),
                ],
              ),
              const SizedBox(height: MindFlowTheme.spacing8),
              Text(
                widget.summary,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (_isExpanded && widget.detailContent != null) ...[
                const SizedBox(height: MindFlowTheme.spacing16),
                widget.detailContent!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// **Contextual Help System**
///
/// Shows help ONLY when user demonstrates confusion (long pauses, backtracking)
class ContextualHelp extends StatelessWidget {
  final String helpText;
  final bool shouldShow;

  const ContextualHelp({
    super.key,
    required this.helpText,
    required this.shouldShow,
  });

  @override
  Widget build(BuildContext context) {
    if (!shouldShow) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: MindFlowTheme.spacing8),
      padding: const EdgeInsets.all(MindFlowTheme.spacing12),
      decoration: BoxDecoration(
        color: MindFlowTheme.sageLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(MindFlowTheme.radius8),
        border: Border.all(
          color: MindFlowTheme.sage.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lightbulb_outline,
            color: MindFlowTheme.sage,
            size: 20,
          ),
          const SizedBox(width: MindFlowTheme.spacing8),
          Expanded(
            child: Text(
              helpText,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: MindFlowTheme.obsidian,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// **3-Click Rule Validator**
///
/// Ensures all core actions are reachable in ≤3 taps
class ThreeClickValidator {
  /// Maps core actions to their click depth
  static Map<String, int> getCoreActionPaths() {
    return {
      'Start Focus Session': 1, // 1 tap from home
      'View Insights': 2, // Tap tab → tap insight card
      'Log Mood': 1, // Quick action button
      'View Settings': 2, // Tab → settings
      'Export Data': 3, // Settings → Privacy → Export
      'Skip Session': 1, // Always visible option
    };
  }

  /// Validates that all core actions meet 3-click rule
  static bool validateAllActions() {
    final paths = getCoreActionPaths();
    return paths.values.every((clicks) => clicks <= 3);
  }

  /// Gets actions that violate the rule
  static List<String> getViolations() {
    final paths = getCoreActionPaths();
    return paths.entries
        .where((entry) => entry.value > 3)
        .map((entry) => entry.key)
        .toList();
  }
}
