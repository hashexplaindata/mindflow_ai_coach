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

  int _currentIndex = 0;
  bool _isSaving = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
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
        case 'volatility': // Keep legacy key support just in case, or map it
          _reactivity = option.scoreImpact;
          break;
        case 'structure':
          _structure = option.scoreImpact;
          break;
      }
    });

    // Short delay before advancing
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_currentIndex < OnboardingQuestions.questions.length - 1) {
        _goToNext();
      } else {
        _completeOnboarding();
      }
    });
  }

  void _goToNext() {
    _fadeController.reverse().then((_) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
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
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
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

      // Navigate to result
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              ProfileResultScreen(vector: vector, onStart: widget.onComplete),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const questions = OnboardingQuestions.questions;
    final progress = (_currentIndex + 1) / questions.length;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Row(
                children: [
                  if (_currentIndex > 0)
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded),
                      onPressed: _goToPrevious,
                      color: AppColors.neutralDark,
                    )
                  else
                    const SizedBox(width: 48),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Analysis ${_currentIndex + 1}/${questions.length}',
                          style: AppTextStyles.caption
                              .copyWith(letterSpacing: 1.5),
                        ),
                        const SizedBox(height: AppSpacing.spacing8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: AppColors.neutralLight,
                            valueColor: const AlwaysStoppedAnimation(
                              MindFlowTheme.sage,
                            ),
                            minHeight: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Questions PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final question = questions[index];
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: _QuestionCard(
                      question: question,
                      onSelect: (option) => _selectOption(question, option),
                    ),
                  );
                },
              ),
            ),

            if (_isSaving)
              const Padding(
                padding: EdgeInsets.all(AppSpacing.spacing24),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(MindFlowTheme.sage),
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
            style: AppTextStyles.question,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.spacing12),
          Text(
            question.subtitle,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
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
                      style: AppTextStyles.label
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      option.description,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary),
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

class ProfileResultScreen extends StatelessWidget {
  const ProfileResultScreen({
    super.key,
    required this.vector,
    this.onStart,
  });

  final PersonalityVector vector;
  final void Function(PersonalityVector)? onStart;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 1),

              Text(
                '🧠 Analysis Complete',
                style: AppTextStyles.headingMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.spacing8),
              Text(
                'Your Cognitive Vector',
                style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 16,
                    color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Vector Visualization Card
              MindFlowCard(
                child: Column(
                  children: [
                    _TraitBar(
                        'Structure', vector.structure, '🌊 Flow', '📋 Grid'),
                    const SizedBox(height: 24),
                    _TraitBar(
                        'Novelty', vector.novelty, '🏠 Routine', '🌟 Seeker'),
                    const SizedBox(height: 24),
                    _TraitBar('Reactivity', vector.reactivity, '🤖 Stoic',
                        '❤️‍🔥 Reactive'),
                    const SizedBox(height: 24),
                    _TraitBar('Discipline', vector.discipline, '⏰ Pressure',
                        '✅ Order'),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              AppButton(
                text: 'Enter MindFlow',
                onPressed: () {
                  if (onStart != null) {
                    onStart!(vector);
                  } else {
                    // Force navigation if no callback
                    Navigator.of(context).pushReplacementNamed('/home');
                  }
                },
              ),
              const SizedBox(height: AppSpacing.spacing24),
            ],
          ),
        ),
      ),
    );
  }
}

class _TraitBar extends StatelessWidget {
  const _TraitBar(this.label, this.value, this.leftLabel, this.rightLabel);

  final String label;
  final double value;
  final String leftLabel;
  final String rightLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(leftLabel,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
            Text(label.toUpperCase(),
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1)),
            Text(rightLabel,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: AppColors.neutralLight,
            valueColor: const AlwaysStoppedAnimation(MindFlowTheme.obsidian),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
