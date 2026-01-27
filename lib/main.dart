import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/jobs_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_spacing.dart';
import 'core/constants/app_text_styles.dart';
import 'shared/widgets/app_button.dart';
import 'shared/widgets/bottom_nav_bar.dart';

import 'features/onboarding/domain/models/nlp_profile.dart';
import 'features/onboarding/presentation/screens/profiling_screen.dart';
import 'features/chat/presentation/providers/chat_provider.dart';
import 'features/subscription/presentation/providers/subscription_provider.dart';
import 'features/auth/presentation/providers/user_provider.dart';
import 'features/habits/presentation/providers/habit_provider.dart';
import 'features/wisdom/presentation/providers/wisdom_provider.dart';
import 'features/coach/presentation/providers/background_coach_provider.dart';
import 'features/coach/presentation/widgets/coach_intervention_overlay.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/explore/presentation/screens/explore_screen.dart';
import 'features/sleep/presentation/screens/sleep_screen.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'features/habits/presentation/screens/habits_screen.dart';
import 'features/chat/presentation/screens/chat_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MindFlowApp());
}

class MindFlowApp extends StatelessWidget {
  const MindFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => UserProvider()..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => ChatProvider()..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => SubscriptionProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => HabitProvider()..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => WisdomProvider()..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => BackgroundCoachProvider()..initialize(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'MindFlow',
            debugShowCheckedModeBanner: false,
            theme: JobsTheme.lightTheme,
            darkTheme: JobsTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const WelcomeScreen(),
          );
        },
      ),
    );
  }
}

class MainAppShell extends StatefulWidget {
  const MainAppShell({super.key});

  @override
  State<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> with WidgetsBindingObserver {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ExploreScreen(),
    HabitsScreen(),
    SleepScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForInterventions();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _checkForInterventions();
    }
  }

  void _checkForInterventions() {
    final userProvider = context.read<UserProvider>();
    final habitProvider = context.read<HabitProvider>();
    final coachProvider = context.read<BackgroundCoachProvider>();

    final now = DateTime.now();
    final lastSessionDate = userProvider.sessionsCompleted > 0 ? now : null;
    final daysSinceLastSession = lastSessionDate != null
        ? now.difference(lastSessionDate).inDays
        : 0;

    final hasCompletedTodaySession = habitProvider.todayProgress > 0;

    coachProvider.onAppResumed(
      currentStreak: userProvider.currentStreak,
      totalSessions: userProvider.sessionsCompleted,
      totalMinutes: userProvider.totalMinutes,
      daysSinceLastSession: daysSinceLastSession,
      habits: habitProvider.activeHabits,
      hasCompletedTodaySession: hasCompletedTodaySession,
      weeklyGoalProgress: habitProvider.todayProgress,
    );
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });

    final userProvider = context.read<UserProvider>();
    final habitProvider = context.read<HabitProvider>();
    final coachProvider = context.read<BackgroundCoachProvider>();

    final now = DateTime.now();
    final lastSessionDate = userProvider.sessionsCompleted > 0 ? now : null;
    final daysSinceLastSession = lastSessionDate != null
        ? now.difference(lastSessionDate).inDays
        : 0;

    coachProvider.onTabChanged(
      currentStreak: userProvider.currentStreak,
      totalSessions: userProvider.sessionsCompleted,
      totalMinutes: userProvider.totalMinutes,
      daysSinceLastSession: daysSinceLastSession,
      habits: habitProvider.activeHabits,
      hasCompletedTodaySession: habitProvider.todayProgress > 0,
    );
  }

  void _navigateToMeditation() {
    setState(() {
      _currentIndex = 1;
    });
  }

  void _navigateToHabits() {
    setState(() {
      _currentIndex = 2;
    });
  }

  void _navigateToProgress() {
    setState(() {
      _currentIndex = 4;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CoachInterventionManager(
      onNavigateToMeditation: _navigateToMeditation,
      onNavigateToHabits: _navigateToHabits,
      onNavigateToProgress: _navigateToProgress,
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        floatingActionButton: _CoachFloatingButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ChatScreen(),
              ),
            );
          },
        ),
        bottomNavigationBar: BottomNavBar(
          currentIndex: _currentIndex,
          onTap: _onTabChanged,
        ),
      ),
    );
  }
}

class _CoachFloatingButton extends StatefulWidget {
  const _CoachFloatingButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_CoachFloatingButton> createState() => _CoachFloatingButtonState();
}

class _CoachFloatingButtonState extends State<_CoachFloatingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.jobsSage.withOpacity(_glowAnimation.value),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: widget.onPressed,
              backgroundColor: AppColors.jobsSage,
              elevation: 8,
              child: const Text(
                '🧘',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
        );
      },
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.spacing48),

              const Text(
                'Welcome to',
                style: AppTextStyles.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.spacing8),

              ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.primaryGradient.createShader(bounds),
                child: const Text(
                  'MindFlow',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.spacing12),

              Text(
                'Your personal meditation\n& wellness companion',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.neutralDark,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.spacing48),

              const _FeatureCard(
                icon: Icons.self_improvement_rounded,
                iconGradient: AppColors.sageGradient,
                title: 'Mindful Meditation',
                description:
                    'Guided sessions for stress, sleep, focus, and more.',
              ),

              const SizedBox(height: AppSpacing.spacing16),

              const _FeatureCard(
                icon: Icons.nightlight_round,
                iconColor: AppColors.accentBlueDark,
                title: 'Better Sleep',
                description:
                    'Sleep stories, soundscapes, and wind-down exercises.',
              ),

              const SizedBox(height: AppSpacing.spacing16),

              const _FeatureCard(
                icon: Icons.trending_up_rounded,
                iconColor: AppColors.primaryOrange,
                title: 'Track Progress',
                description:
                    'Build healthy habits with streaks and daily goals.',
              ),

              const Spacer(),

              AppButton(
                text: 'Get Started',
                icon: Icons.arrow_forward_rounded,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProfilingScreen(
                        onComplete: (profile) {
                          _navigateToMainApp(context, profile);
                        },
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.spacing16),

              TextButton(
                onPressed: () {
                  _navigateToMainApp(context, NLPProfile.defaultProfile);
                },
                child: Text(
                  'Skip to app',
                  style: AppTextStyles.buttonSmall.copyWith(
                    color: AppColors.neutralMedium,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.spacing24),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToMainApp(BuildContext context, NLPProfile profile) {
    final chatProvider = context.read<ChatProvider>();
    chatProvider.setUserProfile(profile);

    final wisdomProvider = context.read<WisdomProvider>();
    wisdomProvider.setUserProfile(profile);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const MainAppShell(),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    this.iconGradient,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String description;
  final LinearGradient? iconGradient;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: iconGradient,
              color: iconGradient == null
                  ? const Color(0x26F4A261)
                  : null,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconGradient != null
                  ? Colors.white
                  : (iconColor ?? AppColors.primaryOrange),
              size: 24,
            ),
          ),

          const SizedBox(width: AppSpacing.spacing16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.label.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing4),
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
