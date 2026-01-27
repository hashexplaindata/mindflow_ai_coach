import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../auth/presentation/providers/user_provider.dart';
import '../../../subscription/presentation/screens/subscription_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().refreshProgress();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.jobsCream,
      body: SafeArea(
        child: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            if (userProvider.isLoading && !userProvider.isInitialized) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(AppColors.jobsSage),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => userProvider.refreshProgress(),
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
                            AppColors.jobsSage.withOpacity(0.3),
                            AppColors.jobsSage.withOpacity(0.15),
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
                    
                    const Text(
                      'Mindful User',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.jobsObsidian,
                      ),
                    ),
                    
                    const SizedBox(height: AppSpacing.spacing8),
                    
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: userProvider.isSubscribed
                            ? AppColors.primaryOrange.withOpacity(0.15)
                            : AppColors.jobsSage.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (userProvider.isSubscribed) ...[
                            const Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: AppColors.primaryOrange,
                            ),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            userProvider.isSubscribed ? 'Premium' : 'Free Plan',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: userProvider.isSubscribed
                                  ? AppColors.primaryOrange
                                  : AppColors.jobsSage,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: AppSpacing.spacing32),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            value: '${userProvider.totalMinutes}',
                            label: 'Minutes',
                            icon: Icons.timer_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            value: '${userProvider.currentStreak}',
                            label: 'Day Streak',
                            icon: Icons.local_fire_department_rounded,
                            isHighlighted: userProvider.currentStreak > 0,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            value: '${userProvider.sessionsCompleted}',
                            label: 'Sessions',
                            icon: Icons.self_improvement_rounded,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppSpacing.spacing32),
                    
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
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
                          const _Divider(),
                          _SettingsItem(
                            icon: Icons.palette_outlined,
                            title: 'Theme',
                            onTap: () {
                              _showComingSoonSnackbar(context);
                            },
                          ),
                          const _Divider(),
                          _SettingsItem(
                            icon: Icons.person_outline,
                            title: 'Account',
                            onTap: () {
                              _showComingSoonSnackbar(context);
                            },
                          ),
                          const _Divider(),
                          _SettingsItem(
                            icon: Icons.workspace_premium_outlined,
                            title: 'Subscription',
                            trailing: userProvider.isSubscribed
                                ? Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.jobsSage.withOpacity(0.15),
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
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryOrange.withOpacity(0.15),
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
                                  pageBuilder: (context, animation, secondaryAnimation) =>
                                      const SubscriptionScreen(),
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
                                  transitionDuration: const Duration(milliseconds: 300),
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
                        color: Colors.white,
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
                          const _Divider(),
                          _SettingsItem(
                            icon: Icons.privacy_tip_outlined,
                            title: 'Privacy Policy',
                            onTap: () {
                              _showComingSoonSnackbar(context);
                            },
                          ),
                          const _Divider(),
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
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              color: isHighlighted ? AppColors.primaryOrange : AppColors.jobsObsidian,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.jobsObsidian.withOpacity(0.5),
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
              color: AppColors.jobsObsidian.withOpacity(0.6),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.jobsObsidian,
                ),
              ),
            ),
            if (trailing != null) trailing!,
            if (trailing == null)
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.jobsObsidian.withOpacity(0.3),
              ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      color: AppColors.jobsObsidian.withOpacity(0.05),
    );
  }
}
