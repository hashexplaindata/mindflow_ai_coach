import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../auth/presentation/providers/user_provider.dart';
import '../../../subscription/presentation/screens/subscription_screen.dart';
import '../widgets/personality_graph.dart';
import '../../../identity/domain/models/personality_vector.dart';

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
                    const SizedBox(height: AppSpacing.spacing24),

                    // Personality Graph Widget
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.cardBackgroundDark
                            : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Cognitive Profile',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: PersonalityGraph(
                              vector: userState.personality ??
                                  PersonalityVector.defaultProfile,
                              showLabels: true,
                              size: 200.0,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _DimensionRow(
                              'Discipline',
                              userState.personality?.discipline ?? 0.5,
                              Icons.check_circle,
                              theme,
                              'Your ability to focus and follow through on tasks.'),
                          const SizedBox(height: 12),
                          _DimensionRow(
                              'Novelty',
                              userState.personality?.novelty ?? 0.5,
                              Icons.explore,
                              theme,
                              'Your openness to new experiences and ideas.'),
                          const SizedBox(height: 12),
                          _DimensionRow(
                              'Volatility',
                              userState.personality?.volatility ?? 0.5,
                              Icons.waves,
                              theme),
                          const SizedBox(height: 12),
                          _DimensionRow(
                              'Structure',
                              userState.personality?.structure ?? 0.5,
                              Icons.grid_on,
                              theme),
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

// Helper widget to display personality dimensions
Widget _DimensionRow(String label, double value, IconData icon, ThemeData theme,
    [String? tooltip]) {
  return Row(
    children: [
      Icon(
        icon,
        size: 20,
        color: AppColors.jobsSage,
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
      Text(
        '${(value * 100).toInt()}%',
        style: TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.jobsObsidian,
        ),
      ),
      if (tooltip != null) ...[
        const SizedBox(width: 8),
        Tooltip(
          message: tooltip,
          triggerMode: TooltipTriggerMode.tap,
          child: Icon(
            Icons.info_outline,
            size: 16,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      ],
    ],
  );
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
