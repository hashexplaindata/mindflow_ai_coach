import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/physics.dart';

import 'core/config/env_config.dart';
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvConfig.initialize();
  runApp(const ProviderScope(child: MindFlowApp()));
}

class MindFlowApp extends ConsumerWidget {
  const MindFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the Riverpod theme provider
    final themeMode = ref.watch(themeProvider);

    return provider.MultiProvider(
      providers: [
        // ThemeProvider is now handled by Riverpod
        // UserProvider is now handled by Riverpod
        provider.ChangeNotifierProvider(
          create: (_) => ChatProvider()..initialize(),
        ),
        provider.ChangeNotifierProvider(
          create: (_) => SubscriptionProvider(),
        ),
        provider.ChangeNotifierProvider(
          create: (_) => HabitProvider()..initialize(),
        ),
        provider.ChangeNotifierProvider(
          create: (_) => WisdomProvider()..initialize(),
        ),
        provider.ChangeNotifierProvider(
          create: (_) => BackgroundCoachProvider()..initialize(),
        ),
      ],
      child: MaterialApp(
        title: 'MindFlow',
        debugShowCheckedModeBanner: false,
        theme: JobsTheme.lightTheme,
        darkTheme: JobsTheme.darkTheme,
        themeMode: themeMode,
        home: const WelcomeScreen(),
      ),
    );
  }
}

class MainAppShell extends ConsumerStatefulWidget {
  const MainAppShell({super.key});

  @override
  ConsumerState<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends ConsumerState<MainAppShell>
    with WidgetsBindingObserver {
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
      // Initialize UserProvider safely after build
      ref.read(userProvider.notifier).initialize();
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
    final userState = ref.read(userProvider);
    final habitProvider = context.read<HabitProvider>();
    final coachProvider = context.read<BackgroundCoachProvider>();

    final now = DateTime.now();
    final lastSessionDate = userState.sessionsCompleted > 0 ? now : null;
    final daysSinceLastSession =
        lastSessionDate != null ? now.difference(lastSessionDate).inDays : 0;

    final hasCompletedTodaySession = habitProvider.todayProgress > 0;

    coachProvider.onAppResumed(
      currentStreak: userState.currentStreak,
      totalSessions: userState.sessionsCompleted,
      totalMinutes: userState.totalMinutes,
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

    final userState = ref.read(userProvider);
    final habitProvider = context.read<HabitProvider>();
    final coachProvider = context.read<BackgroundCoachProvider>();

    final now = DateTime.now();
    final lastSessionDate = userState.sessionsCompleted > 0 ? now : null;
    final daysSinceLastSession =
        lastSessionDate != null ? now.difference(lastSessionDate).inDays : 0;

    coachProvider.onTabChanged(
      currentStreak: userState.currentStreak,
      totalSessions: userState.sessionsCompleted,
      totalMinutes: userState.totalMinutes,
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
    // Ambient breathing
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

    // Spring press interaction will be handled by a separate widget wrapper
    // or we can implement it here if we want custom physics.
    // For now, let's strictly wrap the FAB in a springable widget or custom logic.
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
                  color: AppColors.jobsSage
                      .withValues(alpha: _glowAnimation.value),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            // Using a physics-based pressable widget instead of raw FAB
            child: _SpringPressable(
              onPressed: widget.onPressed,
              child: Container(
                height: 56,
                width: 56,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.jobsSage,
                ),
                child: const Icon(Icons.self_improvement_rounded,
                    color: Colors.white, size: 24),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SpringPressable extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;

  const _SpringPressable({required this.onPressed, required this.child});

  @override
  State<_SpringPressable> createState() => _SpringPressableState();
}

class _SpringPressableState extends State<_SpringPressable>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200), // Upper bound
    );
  }

  void _onTapDown(TapDownDetails details) {
    _controller.animateWith(
      SpringSimulation(
        const SpringDescription(mass: 1, stiffness: 300, damping: 20),
        0.0,
        1.0, // Compressed state
        0.0,
      ),
    );
  }

  void _onTapUp(TapUpDetails details) {
    _controller.animateWith(
      SpringSimulation(
        const SpringDescription(mass: 1, stiffness: 300, damping: 20),
        1.0,
        0.0, // Back to normal
        0.0,
      ),
    );
    widget.onPressed();
  }

  void _onTapCancel() {
    _controller.animateWith(
      SpringSimulation(
        const SpringDescription(mass: 1, stiffness: 300, damping: 20),
        1.0,
        0.0,
        0.0,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final scale = 1.0 - (_controller.value * 0.1); // Scale down to 0.9
          return Transform.scale(
            scale: scale,
            child: widget.child,
          );
        },
      ),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
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
                const SizedBox(height: AppSpacing.spacing32),
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
              color: iconGradient == null ? const Color(0x26F4A261) : null,
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
