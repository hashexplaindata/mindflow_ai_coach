import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' show WatchContext;
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../auth/presentation/providers/user_provider.dart';
import '../../../subscription/presentation/screens/subscription_screen.dart';
import '../../../coach/presentation/screens/goals_screen.dart';
import '../../../coach/presentation/widgets/goal_card.dart';
import '../../../coach/domain/models/wellness_goal.dart';
import '../../../chat/presentation/providers/chat_provider.dart';
import '../widgets/mindset_card.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userProvider.notifier).refreshProgress();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Builder(
          builder: (context) {
            final userState = ref.watch(userProvider);
            // Check if loading and not initialized (implicit logic from old provider)
            if (userState.isLoading && userState.userId == null) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(AppColors.jobsSage),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () =>
                  ref.read(userProvider.notifier).refreshProgress(),
              color: AppColors.jobsSage,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.spacing16),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.jobsSage.withValues(alpha: 0.3),
                            AppColors.jobsSage.withValues(alpha: 0.15),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 48,
                        color: AppColors.jobsSage,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spacing16),
                    Text(
                      'Mindful User',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spacing8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: userState.isSubscribed
                            ? AppColors.primaryOrange.withValues(alpha: 0.15)
                            : AppColors.jobsSage.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (userState.isSubscribed) ...[
                            const Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: AppColors.primaryOrange,
                            ),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            userState.isSubscribed ? 'Premium' : 'Free Plan',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: userState.isSubscribed
                                  ? AppColors.primaryOrange
                                  : AppColors.jobsSage,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spacing32),

                    // — Mindset Card (Inferred NLP Profile)
                    const _MindsetSection(),
                    const SizedBox(height: AppSpacing.spacing32),

                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            value: '${userState.totalMinutes}',
                            label: 'Minutes',
                            icon: Icons.timer_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            value: '${userState.currentStreak}',
                            label: 'Day Streak',
                            icon: Icons.local_fire_department_rounded,
                            isHighlighted: userState.currentStreak > 0,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            value: '${userState.sessionsCompleted}',
                            label: 'Sessions',
                            icon: Icons.self_improvement_rounded,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.spacing24),
                    if (userState.userId != null)
                      _GoalsSummarySection(
                        userId: userState.userId!,
                        onNavigateToGoals: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => GoalsScreen(
                                userId: userState.userId!,
                              ),
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: AppSpacing.spacing24),
                    Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.cardBackgroundDark
                            : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          _SettingsItem(
                            icon: Icons.notifications_outlined,
                            title: 'Notifications',
                            onTap: () {
                              _showComingSoonSnackbar(context);
                            },
                          ),
                          _Divider(isDark: isDark),
                          Consumer(
                            builder: (context, ref, _) {
                              final themeMode = ref.watch(themeProvider);
                              final isDarkMode = themeMode == ThemeMode.dark;
                              return _SettingsItem(
                                icon: isDarkMode
                                    ? Icons.dark_mode_outlined
                                    : Icons.light_mode_outlined,
                                title: 'Dark Mode',
                                trailing: Switch.adaptive(
                                  value: isDarkMode,
                                  onChanged: (_) => ref
                                      .read(themeProvider.notifier)
                                      .toggleTheme(),
                                  activeColor: AppColors.jobsSage,
                                ),
                                onTap: () => ref
                                    .read(themeProvider.notifier)
                                    .toggleTheme(),
                              );
                            },
                          ),
                          _Divider(isDark: isDark),
                          _SettingsItem(
                            icon: Icons.person_outline,
                            title: 'Account',
                            onTap: () {
                              _showComingSoonSnackbar(context);
                            },
                          ),
                          _Divider(isDark: isDark),
                          _SettingsItem(
                            icon: Icons.workspace_premium_outlined,
                            title: 'Subscription',
                            trailing: userState.isSubscribed
                                ? Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.jobsSage
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'ACTIVE',
                                      style: TextStyle(
                                        fontFamily: 'DM Sans',
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.jobsSage,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  )
                                : Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryOrange
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'UPGRADE',
                                      style: TextStyle(
                                        fontFamily: 'DM Sans',
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primaryOrange,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                            onTap: () {
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      const SubscriptionScreen(),
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    return SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0, 1),
                                        end: Offset.zero,
                                      ).animate(CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOutCubic,
                                      )),
                                      child: child,
                                    );
                                  },
                                  transitionDuration:
                                      const Duration(milliseconds: 300),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spacing24),
                    Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.cardBackgroundDark
                            : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          _SettingsItem(
                            icon: Icons.help_outline,
                            title: 'Help & Support',
                            onTap: () {
                              _showComingSoonSnackbar(context);
                            },
                          ),
                          _Divider(isDark: isDark),
                          _SettingsItem(
                            icon: Icons.privacy_tip_outlined,
                            title: 'Privacy Policy',
                            onTap: () {
                              _showComingSoonSnackbar(context);
                            },
                          ),
                          _Divider(isDark: isDark),
                          _SettingsItem(
                            icon: Icons.description_outlined,
                            title: 'Terms of Service',
                            onTap: () {
                              _showComingSoonSnackbar(context);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spacing24),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Logged out'),
                              backgroundColor: AppColors.jobsSage,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Log Out',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.errorRed,
                          ),
                        ),
                      ),
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

  void _showComingSoonSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Coming soon!'),
        backgroundColor: AppColors.jobsSage,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final bool isHighlighted;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 24,
            color: isHighlighted ? AppColors.primaryOrange : AppColors.jobsSage,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isHighlighted
                  ? AppColors.primaryOrange
                  : AppColors.jobsObsidian,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.jobsObsidian.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: textColor.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
            if (trailing != null) trailing!,
            if (trailing == null)
              Icon(
                Icons.chevron_right_rounded,
                color: textColor.withValues(alpha: 0.3),
              ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isDark;

  const _Divider({this.isDark = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      color: isDark
          ? AppColors.jobsObsidianDark.withValues(alpha: 0.1)
          : AppColors.jobsObsidian.withValues(alpha: 0.05),
    );
  }
}

class _GoalsSummarySection extends StatefulWidget {
  final String userId;
  final VoidCallback onNavigateToGoals;

  const _GoalsSummarySection({
    required this.userId,
    required this.onNavigateToGoals,
  });

  @override
  State<_GoalsSummarySection> createState() => _GoalsSummarySectionState();
}

class _GoalsSummarySectionState extends State<_GoalsSummarySection> {
  WellnessGoal? _activeGoal;
  int _completedCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    try {
      final response = await _fetchGoals();
      if (response != null) {
        final activeGoals =
            response.where((g) => g.status == GoalStatus.active).toList();
        final completedGoals =
            response.where((g) => g.status == GoalStatus.completed).toList();

        if (mounted) {
          setState(() {
            _activeGoal = activeGoals.isNotEmpty ? activeGoals.first : null;
            _completedCount = completedGoals.length;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<List<WellnessGoal>?> _fetchGoals() async {
    try {
      final uri = Uri.parse('/api/goals/${widget.userId}');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['goals'] as List)
            .map((g) => WellnessGoal.fromJson(g))
            .toList();
      }
    } catch (e) {
      // Silent fail, will show empty state
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.spacing24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(AppColors.jobsSage),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Goals',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.jobsObsidian,
                ),
              ),
              if (_completedCount > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.successGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.emoji_events_rounded,
                        size: 14,
                        color: AppColors.successGreen,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$_completedCount achieved',
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.successGreen,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.spacing12),
        CompactGoalCard(
          goal: _activeGoal,
          onTap: widget.onNavigateToGoals,
          onViewAll: widget.onNavigateToGoals,
        ),
      ],
    );
  }
}

class _MindsetSection extends StatelessWidget {
  const _MindsetSection();

  @override
  Widget build(BuildContext context) {
    // Watch standard provider (not Riverpod)
    final chatProvider = context.watch<ChatProvider>();

    if (!chatProvider.isProfileInferred) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        MindsetCard(profile: chatProvider.userProfile),
        const SizedBox(height: AppSpacing.spacing32),
      ],
    );
  }
}
