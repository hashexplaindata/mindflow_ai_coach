import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/jobs_theme.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_spacing.dart';
import 'core/constants/app_text_styles.dart';
import 'shared/widgets/app_button.dart';

// Feature imports
import 'features/onboarding/domain/models/nlp_profile.dart';
import 'features/onboarding/presentation/screens/profiling_screen.dart';
import 'features/chat/presentation/screens/chat_screen.dart';
import 'features/chat/presentation/providers/chat_provider.dart';
import 'features/subscription/presentation/providers/subscription_provider.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';

void main() {
  runApp(const MindFlowApp());
}

/// MindFlow AI Coach
/// The first AI coach that actually understands how YOUR brain works
///
/// Built with:
/// - Flutter + Firebase + Gemini API + RevenueCat
/// - NLP frameworks from Bandler, Grinder, and James
/// - Headspace-inspired "Warm Minimalism" design
class MindFlowApp extends StatelessWidget {
  const MindFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ChatProvider()..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => SubscriptionProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'MindFlow AI Coach',
        debugShowCheckedModeBanner: false,
        theme: JobsTheme.lightTheme,
        home: const WelcomeScreen(),
      ),
    );
  }
}

/// Welcome Screen - Entry point for new users
/// Displays app value prop and CTA buttons
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

              // Welcome Header
              const Text(
                'Welcome to',
                style: AppTextStyles.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.spacing8),

              // App Name with Gradient Effect
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

              // Tagline
              Text(
                'The AI coach that understands\nhow YOUR brain works',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.neutralDark,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.spacing48),

              // Feature Card 1: NLP Psychology
              const _FeatureCard(
                icon: Icons.psychology_outlined,
                iconGradient: AppColors.sageGradient,
                title: 'Powered by NLP Psychology',
                description:
                    'Adapts to your unique decision-making patterns using frameworks from Bandler, Grinder, and James.',
              ),

              const SizedBox(height: AppSpacing.spacing16),

              // Feature Card 2: Personalized
              const _FeatureCard(
                icon: Icons.chat_bubble_outline_rounded,
                iconColor: AppColors.accentBlueDark,
                title: 'Truly Personalized',
                description:
                    'Speaks your brain\'s language—visual, auditory, or kinesthetic.',
              ),

              const Spacer(),

              // CTA Buttons
              AppButton(
                text: 'Get Started',
                icon: Icons.arrow_forward_rounded,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProfilingScreen(
                        onComplete: (profile) {
                          _navigateToDashboard(context, profile);
                        },
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.spacing16),

              // Skip to demo
              TextButton(
                onPressed: () {
                  _navigateToDashboard(context, NLPProfile.defaultProfile);
                },
                child: Text(
                  'Skip profiling (use default)',
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

  void _navigateToDashboard(BuildContext context, NLPProfile profile) {
    // Set profile in provider
    final chatProvider = context.read<ChatProvider>();
    chatProvider.setUserProfile(profile);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const DashboardScreen(),
      ),
    );
  }
}

/// Feature card for welcome screen
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
            color: Color(0x0D000000), // black at 5% opacity
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: iconGradient,
              color: iconGradient == null
                  ? const Color(0x26F4A261) // primaryOrange at 15% opacity
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

          // Text
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
