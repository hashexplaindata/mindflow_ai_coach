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
import 'features/home/presentation/screens/home_screen.dart';
import 'features/explore/presentation/screens/explore_screen.dart';
import 'features/sleep/presentation/screens/sleep_screen.dart';
import 'features/profile/presentation/screens/profile_screen.dart';

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

class _MainAppShellState extends State<MainAppShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ExploreScreen(),
    SleepScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
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
