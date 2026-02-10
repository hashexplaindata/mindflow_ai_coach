import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/jobs_theme.dart';
import '../../../../shared/widgets/flow_streak_ring.dart';
import '../../../chat/presentation/screens/chat_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.jobsCream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppSpacing.spacing48),
              const _GreetingHeader(),
              const SizedBox(height: AppSpacing.spacing48),
              const FlowStreakRing(
                streakDays: 7,
                maxDays: 30,
                size: 200,
                strokeWidth: 14,
              ),
              const SizedBox(height: AppSpacing.spacing16),
              Text(
                'Keep your streak going!',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.jobsObsidian.withValues(alpha: 0.6),
                  letterSpacing: 0.2,
                ),
              ),
              const Spacer(),
              const _InsightCard(),
              const SizedBox(height: AppSpacing.spacing24),
              _StartCoachingButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ChatScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.spacing48),
            ],
          ),
        ),
      ),
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader();

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          _getGreeting(),
          style: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.jobsObsidian,
            height: 1.2,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.spacing8),
        Text(
          'Ready for today\'s session?',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 18,
            fontWeight: FontWeight.normal,
            color: AppColors.jobsObsidian.withValues(alpha: 0.6),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPaddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.jobsSage,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.spacing8),
              Text(
                'Today\'s insight',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.jobsObsidian.withValues(alpha: 0.5),
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spacing16),
          const Text(
            '"The only way to do great work is to love what you do."',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.jobsObsidian,
              height: 1.5,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _StartCoachingButton extends StatelessWidget {
  const _StartCoachingButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.jobsObsidian,
          foregroundColor: AppColors.jobsCream,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
        child: const Text(
          'Start Coaching',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
