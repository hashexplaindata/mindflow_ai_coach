import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../onboarding/domain/models/nlp_profile.dart';

class MindsetCard extends StatefulWidget {
  final NLPProfile profile;

  const MindsetCard({
    super.key,
    required this.profile,
  });

  @override
  State<MindsetCard> createState() => _MindsetCardState();
}

class _MindsetCardState extends State<MindsetCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getGradientColor() {
    if (widget.profile.motivation == 'toward') {
      return AppColors.primaryOrange;
    } else {
      return AppColors.jobsSage;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = _getGradientColor();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [
                baseColor.withValues(alpha: isDark ? 0.15 : 0.1),
                baseColor.withValues(alpha: isDark ? 0.05 : 0.02),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: baseColor.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: baseColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      widget.profile.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'YOUR MINDSET',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: baseColor,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.profile.displayName,
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _TraitItem(
                    label: 'Motivation',
                    value: widget.profile.motivation == 'toward'
                        ? 'Toward'
                        : 'Away From',
                    icon: widget.profile.motivation == 'toward'
                        ? Icons.arrow_outward_rounded
                        : Icons.shield_outlined,
                    color: baseColor,
                  ),
                  _TraitItem(
                    label: 'Reference',
                    value: widget.profile.reference == 'internal'
                        ? 'Internal'
                        : 'External',
                    icon: widget.profile.reference == 'internal'
                        ? Icons.person_outline
                        : Icons.group_outlined,
                    color: baseColor,
                  ),
                  _TraitItem(
                    label: 'Thinking',
                    value: widget.profile.thinking[0].toUpperCase() +
                        widget.profile.thinking.substring(1),
                    icon: _getThinkingIcon(widget.profile.thinking),
                    color: baseColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getThinkingIcon(String thinking) {
    switch (thinking) {
      case 'visual':
        return Icons.visibility_outlined;
      case 'auditory':
        return Icons.hearing_outlined;
      case 'kinesthetic':
        return Icons.touch_app_outlined;
      default:
        return Icons.lightbulb_outline;
    }
  }
}

class _TraitItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _TraitItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;

    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: color.withValues(alpha: 0.8),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: textColor.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
