import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/theme/mindflow_theme.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../identity/domain/models/personality_vector.dart';
import '../../domain/models/onboarding_question.dart';
import '../../../auth/presentation/providers/user_provider.dart';

/// Profiling Screen
/// 4-question Cognitive Assessment ("The Vector")
class ProfilingScreen extends ConsumerStatefulWidget {
  const ProfilingScreen({
    super.key,
    this.onComplete,
  });

  final void Function(PersonalityVector vector)? onComplete;

  @override
  ConsumerState<ProfilingScreen> createState() => _ProfilingScreenState();
}

class _ProfilingScreenState extends ConsumerState<ProfilingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();

  // Default balanced vector
  double _discipline = 0.5;
  double _novelty = 0.5;
  double _reactivity = 0.5;
  double _structure = 0.5;

  int _currentIndex = 0; // 0 = Intro, 1-4 = Questions
  bool _isSaving = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.fastOutSlowIn,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _selectOption(OnboardingQuestion question, QuestionOption option) {
    // Update vector
    setState(() {
      switch (question.dimension) {
        case 'discipline':
          _discipline = option.scoreImpact;
          break;
        case 'novelty':
          _novelty = option.scoreImpact;
          break;
        case 'reactivity':
        case 'volatility':
          _reactivity = option.scoreImpact;
          break;
        case 'structure':
          _structure = option.scoreImpact;
          break;
      }
    });

    // Short delay before advancing
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_currentIndex < OnboardingQuestions.questions.length) {
        _goToNext();
      } else {
        _completeOnboarding();
      }
    });
  }

  void _goToNext() {
    _fadeController.reverse().then((_) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
      setState(() {
        _currentIndex++;
      });
      _fadeController.forward();
    });
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      _fadeController.reverse().then((_) {
        _pageController.previousPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutCubic,
        );
        setState(() {
          _currentIndex--;
        });
        _fadeController.forward();
      });
    }
  }

  Future<void> _completeOnboarding() async {
    setState(() {
      _isSaving = true;
    });

    // Build Final Vector
    final vector = PersonalityVector(
      discipline: _discipline,
      novelty: _novelty,
      reactivity: _reactivity,
      structure: _structure,
    );

    // Save to Core Engine & cloud via UserProvider
    await ref.read(userProvider.notifier).updatePersonality(vector);

    if (mounted) {
      setState(() {
        _isSaving = false;
      });

      // The Artist Protocol: Direct fade to Chat (Home)
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    const questions = OnboardingQuestions.questions;
    final totalSteps = questions.length + 1; // Intro + 4 Questions

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Strict Protocol
      body: SafeArea(
        child: Column(
          children: [
            // Header (Progress)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
                vertical: AppSpacing.spacing24,
              ),
              child: Row(
                children: [
                  if (_currentIndex > 0)
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
                      onPressed: _goToPrevious,
                      color: MindFlowTheme.obsidian,
                    )
                  else
                    const SizedBox(width: 48), // Balance for title centering

                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          _currentIndex == 0
                              ? 'CALIBRATION'
                              : 'STEP $_currentIndex / ${questions.length}',
                          style: AppTextStyles.caption.copyWith(
                            letterSpacing: 2.0,
                            color: MindFlowTheme.obsidian.withOpacity(0.4),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_currentIndex > 0) ...[
                          const SizedBox(height: AppSpacing.spacing16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: (_currentIndex) /
                                  questions.length, // 1/4 to 4/4
                              backgroundColor: const Color(0xFFEEEEEE),
                              valueColor: const AlwaysStoppedAnimation(
                                MindFlowTheme.obsidian,
                              ),
                              minHeight: 2,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 48), // Balance
                ],
              ),
            ),

            // Questions PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: totalSteps,
                itemBuilder: (context, index) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: index == 0
                        ? _IntroCard(onStart: _goToNext)
                        : _QuestionCard(
                            question: questions[index - 1],
                            onSelect: (option) =>
                                _selectOption(questions[index - 1], option),
                          ),
                  );
                },
              ),
            ),

            if (_isSaving)
              const Padding(
                padding: EdgeInsets.all(AppSpacing.spacing24),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(MindFlowTheme.obsidian),
                  strokeWidth: 2,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.question,
    required this.onSelect,
  });

  final OnboardingQuestion question;
  final void Function(QuestionOption option) onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(flex: 1),
          Text(
            question.question,
            style: AppTextStyles.question.copyWith(
              color: MindFlowTheme.obsidian,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.spacing12),
          Text(
            question.subtitle,
            style: AppTextStyles.bodyMedium.copyWith(
              color: MindFlowTheme.obsidian.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(flex: 1),
          ...question.options.map((option) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.spacing16),
              child: _OptionCard(
                option: option,
                onTap: () => onSelect(option),
              ),
            );
          }),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: MindFlowTheme.sage.withOpacity(0.1),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              size: 48,
              color: MindFlowTheme.sage,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Let\'s calibrate your mind.',
            style: TextStyle(
              fontFamily: 'Fraunces',
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: MindFlowTheme.obsidian,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            '4 questions to customize your AI coach to your cognitive style.',
            style: AppTextStyles.bodyLarge.copyWith(
              color: MindFlowTheme.obsidian.withOpacity(0.7),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(flex: 3),
          AppButton(
            text: 'Begin Calibration',
            onPressed: onStart,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.option,
    required this.onTap,
  });

  final QuestionOption option;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            border: Border.all(color: AppColors.neutralMedium),
          ),
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Row(
            children: [
              Text(
                option.emoji ?? '',
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: AppSpacing.spacing16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.label,
                      style: AppTextStyles.label.copyWith(
                        fontWeight: FontWeight.w600,
                        color: MindFlowTheme.obsidian, // Strict Theme
                      ),
                    ),
                    Text(
                      option.description,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: MindFlowTheme.obsidian
                            .withOpacity(0.6), // Strict Theme
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
