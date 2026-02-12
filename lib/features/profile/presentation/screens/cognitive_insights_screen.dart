import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/mindflow_theme.dart';
import '../../../auth/presentation/providers/user_provider.dart';
import '../../../subscription/presentation/screens/subscription_screen.dart';

class CognitiveInsightsScreen extends ConsumerWidget {
  const CognitiveInsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    final vector = userState.personality;
    final isPro = userState.isSubscribed;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: MindFlowTheme.obsidian, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'COGNITIVE INSIGHTS',
          style: TextStyle(
            fontFamily: 'Fraunces',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: MindFlowTheme.obsidian,
            letterSpacing: 1.0,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Vector Scores Panel
            _SectionHeader('VECTOR ANALYSIS'),
            const SizedBox(height: AppSpacing.spacing16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.neutralMedium),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _VectorBar('Structure', vector.structure),
                  const SizedBox(height: 24),
                  _VectorBar('Novelty', vector.novelty),
                  const SizedBox(height: 24),
                  _VectorBar('Reactivity', vector.reactivity),
                  const SizedBox(height: 24),
                  _VectorBar('Discipline', vector.discipline),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 2. Behavioral Trends (GATED)
            _SectionHeader('BEHAVIORAL TRENDS'),
            const SizedBox(height: AppSpacing.spacing16),

            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Content (Hidden/Blurred if !Pro)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.neutralMedium),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TrendItem('Focus Consistency', '+12%', true),
                        const Divider(height: 32),
                        _TrendItem('Stress Resilience', 'Stable', true),
                        const Divider(height: 32),
                        _TrendItem('Creative Output', '-5%', false),
                        const Divider(height: 32),
                        const Text(
                          'Analysis based on last 7 days of interaction.',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                  // Blur Overlay
                  if (!isPro)
                    Positioned.fill(
                      child: Stack(
                        children: [
                          BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                            child: Container(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.lock_outline_rounded,
                                    size: 32, color: MindFlowTheme.obsidian),
                                const SizedBox(height: 12),
                                const Text(
                                  'Unlock Trends',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: MindFlowTheme.obsidian,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const SubscriptionScreen()),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: MindFlowTheme.obsidian,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(24)),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 12),
                                  ),
                                  child: const Text('Upgrade to Pro'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
        color: MindFlowTheme.obsidian.withOpacity(0.5),
      ),
    );
  }
}

class _VectorBar extends StatelessWidget {
  const _VectorBar(this.label, this.value);

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: MindFlowTheme.obsidian,
              ),
            ),
            Text(
              '${(value * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: MindFlowTheme.obsidian.withOpacity(0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: const Color(0xFFEEEEEE),
            valueColor: const AlwaysStoppedAnimation(MindFlowTheme.obsidian),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

class _TrendItem extends StatelessWidget {
  const _TrendItem(this.label, this.value, this.isPositive);

  final String label;
  final String value;
  final bool isPositive;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: MindFlowTheme.obsidian,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color:
                isPositive ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isPositive ? Colors.green[800] : Colors.red[800],
            ),
          ),
        ),
      ],
    );
  }
}
