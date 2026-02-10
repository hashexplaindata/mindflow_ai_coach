import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' hide Consumer;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/flow_streak_ring.dart';
import '../../../auth/presentation/providers/user_provider.dart';
import '../../../meditation/domain/models/meditation_session.dart';
import '../../../meditation/domain/models/meditation_category.dart';
import '../../../meditation/domain/models/sample_data.dart';
import '../../../meditation/presentation/screens/player_screen.dart';
import '../../../explore/presentation/screens/explore_screen.dart';
import '../../../coach/domain/models/coaching_intervention.dart';
import '../../../coach/domain/services/proactive_coach_service.dart';
import '../../../coach/presentation/widgets/coach_nudge_card.dart';
import '../../../coach/presentation/screens/coach_gallery_screen.dart';
import '../../../wisdom/presentation/providers/wisdom_provider.dart';
import '../../../wisdom/presentation/widgets/wisdom_card.dart';
import '../../../wisdom/presentation/screens/wisdom_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _nudgeDismissed = false;
  CoachingIntervention? _currentNudge;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userProvider.notifier).refreshProgress();
      _generateNudge();
    });
  }

  void _generateNudge() {
    final userState = ref.read(userProvider);
    final nudge = ProactiveCoachService.getProactiveNudge(
      currentStreak: userState.currentStreak,
      totalSessions: userState.sessionsCompleted,
      totalMinutes: userState.totalMinutes,
      lastSessionDate: null,
    );
    if (mounted) {
      setState(() {
        _currentNudge = nudge;
      });
    }
  }

  void _dismissNudge() {
    setState(() {
      _nudgeDismissed = true;
    });
  }

  void _handleNudgeAction(CoachingIntervention nudge) {
    final category = nudge.metadata?['category'] as String?;
    MeditationCategory meditationCategory;

    switch (category) {
      case 'focus':
        meditationCategory = MeditationCategory.focus;
        break;
      case 'stress':
        meditationCategory = MeditationCategory.stress;
        break;
      case 'sleep':
        meditationCategory = MeditationCategory.sleep;
        break;
      case 'anxiety':
        meditationCategory = MeditationCategory.anxiety;
        break;
      default:
        meditationCategory = MeditationCategory.focus;
    }

    _navigateToCategory(context, meditationCategory);
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _getSubtitle() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Start your day with mindfulness';
    if (hour < 17) return 'Take a moment to center yourself';
    return 'Wind down and relax';
  }

  @override
  Widget build(BuildContext context) {
    final featured = SampleData.getFeaturedMeditation();

    return Scaffold(
      backgroundColor: AppColors.jobsCream,
      body: SafeArea(
        child: Builder(
          builder: (context) {
            final userState = ref.watch(userProvider);
            return RefreshIndicator(
              onRefresh: () =>
                  ref.read(userProvider.notifier).refreshProgress(),
              color: AppColors.jobsSage,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.spacing16),
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
                      _getSubtitle(),
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 16,
                        color: AppColors.jobsObsidian.withValues(alpha: 0.6),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spacing24),
                    if (_currentNudge != null && !_nudgeDismissed)
                      Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppSpacing.spacing24),
                        child: CoachNudgeCard(
                          intervention: _currentNudge!,
                          onAction: () => _handleNudgeAction(_currentNudge!),
                          onDismiss: _dismissNudge,
                        ),
                      ),
                    Builder(
                      builder: (context) {
                        final wisdomProvider = context.watch<WisdomProvider>();
                        final todaysWisdom = wisdomProvider.todaysWisdom;
                        if (todaysWisdom == null) {
                          return const SizedBox.shrink();
                        }

                        wisdomProvider.updateUserProgress(
                          currentStreak: userState.currentStreak,
                          daysSinceLastSession: 0,
                          totalSessions: userState.sessionsCompleted,
                          totalMinutes: userState.totalMinutes,
                        );

                        final hasResonated =
                            wisdomProvider.getWisdomFeedback(todaysWisdom.id);

                        return Padding(
                          padding: const EdgeInsets.only(
                              bottom: AppSpacing.spacing24),
                          child: WisdomCardHero(
                            wisdom: todaysWisdom,
                            isFavorite:
                                wisdomProvider.isFavorite(todaysWisdom.id),
                            hasResonated: hasResonated,
                            greeting: wisdomProvider.wisdomGreeting,
                            onFavoriteToggle: () {
                              wisdomProvider.toggleFavorite(todaysWisdom.id);
                              HapticFeedback.lightImpact();
                            },
                            onResonates: () {
                              wisdomProvider
                                  .recordWisdomResonates(todaysWisdom.id);
                              HapticFeedback.mediumImpact();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Thanks! We\'ll find more like this.',
                                    style: TextStyle(
                                      fontFamily: 'DM Sans',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: AppColors.jobsSage,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            onShowAnother: () {
                              wisdomProvider.requestNewWisdom();
                              HapticFeedback.lightImpact();
                            },
                            onTap: () {
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      const WisdomScreen(),
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    );
                                  },
                                  transitionDuration:
                                      const Duration(milliseconds: 200),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                    Center(
                      child: FlowStreakRing(
                        streakDays: userState.currentStreak,
                        maxDays: 30,
                        size: 160,
                        strokeWidth: 12,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spacing8),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            userState.totalMinutes > 0
                                ? '${userState.totalMinutes} minutes meditated'
                                : 'Start your mindfulness journey',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color:
                                  AppColors.jobsObsidian.withValues(alpha: 0.5),
                            ),
                          ),
                          if (userState.currentStreak > 0) ...[
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.local_fire_department_rounded,
                                  size: 16,
                                  color: AppColors.primaryOrange,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${userState.currentStreak} day streak!',
                                  style: const TextStyle(
                                    fontFamily: 'DM Sans',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryOrange,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spacing32),
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.jobsObsidian,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spacing16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _QuickActionChip(
                          label: 'Stress',
                          emoji: '🧘',
                          category: MeditationCategory.stress,
                          onTap: () => _navigateToCategory(
                              context, MeditationCategory.stress),
                        ),
                        _QuickActionChip(
                          label: 'Focus',
                          emoji: '🎯',
                          category: MeditationCategory.focus,
                          onTap: () => _navigateToCategory(
                              context, MeditationCategory.focus),
                        ),
                        _QuickActionChip(
                          label: 'Sleep',
                          emoji: '🌙',
                          category: MeditationCategory.sleep,
                          onTap: () => _navigateToCategory(
                              context, MeditationCategory.sleep),
                        ),
                        _QuickActionChip(
                          label: 'Anxiety',
                          emoji: '🌊',
                          category: MeditationCategory.anxiety,
                          onTap: () => _navigateToCategory(
                              context, MeditationCategory.anxiety),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.spacing32),
                    _CoachGalleryCard(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CoachGalleryScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.spacing32),
                    const Text(
                      "Today's Meditation",
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.jobsObsidian,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spacing16),
                    if (featured != null)
                      _FeaturedMeditationCard(meditation: featured),
                    const SizedBox(height: AppSpacing.spacing32),
                    const Text(
                      'Continue Where You Left Off',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.jobsObsidian,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spacing16),
                    _ContinueCard(
                      meditation: SampleData.allMeditations[4],
                      progress: 0.6,
                    ),
                    const SizedBox(height: AppSpacing.spacing24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _navigateToCategory(BuildContext context, MeditationCategory category) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ExploreScreen(initialCategory: category),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }
}

class _CoachGalleryCard extends StatelessWidget {
  final VoidCallback onTap;

  const _CoachGalleryCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.jobsSage.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: AppColors.jobsSage.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.jobsSage.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.people_alt_rounded,
                color: AppColors.jobsSage,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Meet Your Coaches',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.jobsObsidian,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Browse and select specialized AI guides',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14,
                      color: AppColors.jobsObsidian.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.jobsObsidian.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final String label;
  final String emoji;
  final MeditationCategory category;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.label,
    required this.emoji,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: AppColors.jobsObsidian.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.jobsObsidian,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedMeditationCard extends StatelessWidget {
  final MeditationSession meditation;

  const _FeaturedMeditationCard({required this.meditation});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                PlayerScreen(meditation: meditation),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.jobsSage,
              AppColors.jobsSage.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: AppColors.jobsSage.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'FEATURED',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withOpacity(0.9),
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              meditation.title,
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              meditation.description,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14,
                color: Colors.white.withOpacity(0.85),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 16,
                  color: Colors.white.withOpacity(0.8),
                ),
                const SizedBox(width: 4),
                Text(
                  meditation.formattedDuration,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: AppColors.jobsSage,
                    size: 24,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  final MeditationSession meditation;
  final double progress;

  const _ContinueCard({
    required this.meditation,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                PlayerScreen(meditation: meditation),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 200),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: AppColors.jobsObsidian.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.jobsSage.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  meditation.category.icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meditation.title,
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.jobsObsidian,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(progress * 100).toInt()}% complete • ${meditation.formattedDuration}',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 13,
                      color: AppColors.jobsObsidian.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.jobsSage.withOpacity(0.15),
                    valueColor:
                        const AlwaysStoppedAnimation(AppColors.jobsSage),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.jobsObsidian,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: AppColors.jobsCream,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
