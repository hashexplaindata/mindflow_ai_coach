import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/env_config.dart';
import 'core/theme/mindflow_theme.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/app_spacing.dart';
import 'core/constants/app_text_styles.dart';
import 'shared/widgets/app_button.dart';
import 'shared/widgets/bottom_nav_bar.dart';

import 'features/onboarding/domain/models/nlp_profile.dart'; // TODO: Remove this legacy model eventually
import 'features/onboarding/presentation/screens/profiling_screen.dart';
import 'features/chat/presentation/providers/chat_provider.dart';
import 'features/subscription/presentation/providers/subscription_provider.dart';
import 'features/subscription/data/revenuecat_service.dart';
import 'features/auth/presentation/providers/user_provider.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'features/chat/presentation/screens/chat_screen.dart';
import 'features/identity/domain/models/personality_vector.dart';
import 'features/chat/data/gemini_service.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvConfig.initialize();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint(
        'Firebase initialization failed: (Missing google-services.json?) $e');
  }

  // Initialize RevenueCat before the UI builds
  await RevenueCatService.instance.initialize();

  runApp(const ProviderScope(child: MindFlowApp()));
}

class MindFlowApp extends ConsumerWidget {
  const MindFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return provider.MultiProvider(
      providers: [
        provider.ChangeNotifierProvider(
          create: (_) => ChatProvider()..initialize(),
        ),
        provider.ChangeNotifierProvider(
          create: (_) => SubscriptionProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'MindFlow',
        debugShowCheckedModeBanner: false,
        theme: MindFlowTheme.lightTheme,
        darkTheme: MindFlowTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const WelcomeScreen(),
        routes: {
          '/home': (context) => const MainAppShell(),
        },
      ),
    );
  }
}

class MainAppShell extends ConsumerStatefulWidget {
  const MainAppShell({super.key});

  @override
  ConsumerState<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends ConsumerState<MainAppShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    ChatScreen(), // The "Neural Mirror"
    ProfileScreen(), // The "Vector"
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userProvider.notifier).initialize();
    });
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Sync Personality Vector from UserProvider -> ChatProvider
    ref.listen(userProvider, (previous, next) {
      if (next.personality != previous?.personality) {
        context.read<ChatProvider>().setPersonality(next.personality);
      }
    });

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabChanged,
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
                Center(
                  child: Image.asset(
                    'assets/images/mindflow_logo.png',
                    height: 120,
                    width: 120,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing24),
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
                  'The Adaptive Cognition Engine\nfor High Performers',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.neutralDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.spacing48),
                const _FeatureCard(
                  icon: Icons.psychology_rounded,
                  iconGradient: AppColors.sageGradient,
                  title: 'Cognitive Profiling',
                  description:
                      'Analyzes your discipline, novelty, and reactivity needs.',
                ),
                const SizedBox(height: AppSpacing.spacing16),
                const _FeatureCard(
                  icon: Icons.chat_bubble_rounded,
                  iconColor: AppColors.primaryOrange,
                  title: 'Adaptive Coaching',
                  description: 'AI that adjusts its tone and strategy to YOU.',
                ),
                const SizedBox(height: AppSpacing.spacing32),
                AppButton(
                  text: 'Analyze Me',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ProfilingScreen(
                          onComplete: (vector) {
                            _navigateToMainApp(context, vector);
                          },
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.spacing16),
                // Optional skip for dev/testing
                TextButton(
                  onPressed: () {
                    // Default balanced vector for skip
                    const defaultVector = PersonalityVector(
                        discipline: 0.5,
                        novelty: 0.5,
                        reactivity: 0.5,
                        structure: 0.5);
                    GeminiService.instance.setPersonality(defaultVector);
                    _navigateToMainApp(context, defaultVector);
                  },
                  child: Text(
                    'Skip Analysis (Dev)',
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

  void _navigateToMainApp(BuildContext context, PersonalityVector vector) {
    // We already set this in ProfilingScreen, but good to be safe if passed here
    // The key is ensuring GeminiService has it.

    // Also set legacy profile for now to avoid crashes if used elsewhere
    final chatProvider = context.read<ChatProvider>();
    chatProvider.setUserProfile(NLPProfile.defaultProfile);

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
