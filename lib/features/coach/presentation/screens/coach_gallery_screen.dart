import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Standard provider
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../chat/presentation/providers/chat_provider.dart';
import '../../../subscription/presentation/providers/subscription_provider.dart';
import '../../../subscription/presentation/widgets/paywall_trigger.dart';
import '../../data/coach_repository.dart';
import '../../domain/models/coach.dart';

class CoachGalleryScreen extends StatelessWidget {
  const CoachGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.jobsCream,
      appBar: AppBar(
        backgroundColor: AppColors.jobsCream,
        elevation: 0,
        title: Text(
          'Choose Your Coach',
          style: AppTextStyles.headingSmall
              .copyWith(color: AppColors.jobsObsidian),
        ),
        iconTheme: const IconThemeData(color: AppColors.jobsObsidian),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: CoachRepository.availableCoaches.length,
        itemBuilder: (context, index) {
          final coach = CoachRepository.availableCoaches[index];
          return _FadeInItem(
            index: index,
            child: _CoachCard(coach: coach),
          );
        },
      ),
    );
  }
}

class _FadeInItem extends StatelessWidget {
  final int index;
  final Widget child;

  const _FadeInItem({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    // Simple delay based on index
    return FutureBuilder(
      future: Future.delayed(Duration(milliseconds: index * 50)),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Opacity(opacity: 0, child: SizedBox.shrink());
        }
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: child,
        );
      },
    );
  }
}

class _CoachCard extends StatelessWidget {
  final Coach coach;

  const _CoachCard({required this.coach});

  @override
  Widget build(BuildContext context) {
    // Use Provider context for ChatProvider and SubscriptionProvider
    final isPro = context.watch<SubscriptionProvider>().isPro;
    final isLocked = coach.isPremium && !isPro;

    return GestureDetector(
      onTap: () {
        if (isLocked) {
          PaywallTrigger.show(context);
        } else {
          // Set active coach and navigate to chat
          context.read<ChatProvider>().setActiveCoach(coach);
          if (context.canPop()) {
            context.pop();
          } else {
            // Handle if pushed via go_router
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: isLocked
              ? Border.all(
                  color: AppColors.neutralMedium.withValues(alpha: 0.3))
              : Border.all(color: Colors.transparent),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.jobsSage.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  coach.name[0],
                  style: AppTextStyles.headingMedium.copyWith(
                    color: AppColors.jobsSage,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        coach.name,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.jobsObsidian,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      if (isLocked) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.lock_rounded,
                          size: 16,
                          color: AppColors.neutralMedium,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    coach.specialty,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.jobsSage,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    coach.description,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.neutralDark,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Arrow
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.neutralMedium,
            ),
          ],
        ),
      ),
    );
  }
}
