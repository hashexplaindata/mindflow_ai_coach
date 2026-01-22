import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/theme/headspace_theme.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../domain/models/nlp_profile.dart';
import '../../domain/models/onboarding_question.dart';
import '../../data/profile_repository.dart';

/// Profiling Screen
/// 5-question NLP assessment with Headspace-style UI
/// Saves results to UserProfileRepository
class ProfilingScreen extends StatefulWidget {
  const ProfilingScreen({
    super.key,
    this.userId,
    this.onComplete,
  });

  final String? userId;
  final void Function(NLPProfile profile)? onComplete;

  @override
  State<ProfilingScreen> createState() => _ProfilingScreenState();
}

class _ProfilingScreenState extends State<ProfilingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  final UserProfileRepository _repository = UserProfileRepository();

  int _currentIndex = 0;
  final Map<String, String> _answers = {};
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

  void _selectOption(String questionId, String value) {
    setState(() {
      _answers[questionId] = value;
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

    // Build NLP profile from answers
    final profile = NLPProfile(
      motivation: _answers['motivation'] ?? 'toward',
      reference: _answers['reference'] ?? 'internal',
      thinking: _answers['thinking'] ?? 'visual',
      processing: _answers['processing'] ?? 'options',
      change: _answers['change'] ?? 'sameness',
    );

    // Save to repository
    if (widget.userId != null) {
      await _repository.saveNLPProfile(
        userId: widget.userId!,
        profile: profile,
      );
    }

    setState(() {
      _isSaving = false;
    });

    // Navigate to result screen or call callback
    if (mounted) {
      if (widget.onComplete != null) {
        widget.onComplete!(profile);
      } else {
        // Navigate to result screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ProfileResultScreen(profile: profile),
          ),
        );
      }
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
            // Header with back button and progress
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Row(
                children: [
                  // Back button
                  if (_currentIndex > 0)
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded),
                      onPressed: _goToPrevious,
                      color: AppColors.neutralDark,
                    )
                  else
                    const SizedBox(width: 48),

                  // Progress indicator
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Question ${_currentIndex + 1} of ${questions.length}',
                          style: AppTextStyles.caption,
                        ),
                        const SizedBox(height: AppSpacing.spacing8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: AppColors.neutralLight,
                            valueColor: const AlwaysStoppedAnimation(
                              AppColors.primaryOrange,
                            ),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Skip button
                  TextButton(
                    onPressed: () {
                      // Skip onboarding with default profile
                      const profile = NLPProfile.defaultProfile;
                      if (widget.onComplete != null) {
                        widget.onComplete!(profile);
                      }
                    },
                    child: Text(
                      'Skip',
                      style: AppTextStyles.buttonSmall.copyWith(
                        color: AppColors.neutralMedium,
                      ),
                    ),
                  ),
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
                      selectedValue: _answers[question.id],
                      onSelect: (value) => _selectOption(question.id, value),
                    ),
                  );
                },
              ),
            ),

            // Loading indicator when saving
            if (_isSaving)
              const Padding(
                padding: EdgeInsets.all(AppSpacing.spacing24),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(AppColors.primaryOrange),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Individual question card widget
class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.question,
    required this.selectedValue,
    required this.onSelect,
  });

  final OnboardingQuestion question;
  final String? selectedValue;
  final void Function(String value) onSelect;

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

          // Question text
          Text(
            question.question,
            style: AppTextStyles.question,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.spacing12),

          // Subtitle
          Text(
            question.subtitle,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),

          const Spacer(flex: 1),

          // Options
          ...question.options.map((option) {
            final isSelected = selectedValue == option.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.spacing16),
              child: _OptionCard(
                option: option,
                isSelected: isSelected,
                onTap: () => onSelect(option.value),
              ),
            );
          }),

          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

/// Individual option card
class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final QuestionOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0x1AF4A261) // primaryOrange at 10% opacity
            : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(
          color: isSelected ? AppColors.primaryOrange : AppColors.neutralMedium,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected ? HeadspaceTheme.cardShadow : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Row(
              children: [
                // Emoji
                if (option.emoji != null)
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(
                              0x33F4A261) // primaryOrange at 20% opacity
                          : AppColors.neutralLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        option.emoji!,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                const SizedBox(width: AppSpacing.spacing16),

                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.label,
                        style: AppTextStyles.label.copyWith(
                          color: isSelected
                              ? AppColors.primaryOrange
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.spacing4),
                      Text(
                        option.description,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Checkmark
                if (isSelected)
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryOrange,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Profile Result Screen
/// Shows the user their personality type after completing profiling
class ProfileResultScreen extends StatelessWidget {
  const ProfileResultScreen({
    super.key,
    required this.profile,
  });

  final NLPProfile profile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 1),

              // Celebration emoji
              Text(
                '${profile.emoji} 🎉',
                style: const TextStyle(fontSize: 64),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.spacing24),

              // You are...
              Text(
                'You are',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.spacing8),

              // Profile type name
              Text(
                profile.displayName,
                style: AppTextStyles.profileType,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.spacing32),

              // Profile breakdown card
              Container(
                decoration: HeadspaceTheme.cardDecoration,
                padding: const EdgeInsets.all(AppSpacing.cardPaddingLarge),
                child: Column(
                  children: [
                    _ProfileTraitRow(
                      label: 'Motivation',
                      value: profile.motivation == 'toward'
                          ? 'Goal-focused'
                          : 'Problem-solver',
                      emoji: profile.motivation == 'toward' ? '🚀' : '🛡️',
                    ),
                    const SizedBox(height: AppSpacing.spacing16),
                    _ProfileTraitRow(
                      label: 'Decisions',
                      value: profile.reference == 'internal'
                          ? 'Trust your gut'
                          : 'Research-driven',
                      emoji: profile.reference == 'internal' ? '💭' : '📊',
                    ),
                    const SizedBox(height: AppSpacing.spacing16),
                    _ProfileTraitRow(
                      label: 'Thinking',
                      value: profile.thinking == 'visual'
                          ? 'Visual thinker'
                          : profile.thinking == 'auditory'
                              ? 'Auditory thinker'
                              : 'Kinesthetic thinker',
                      emoji: profile.emoji,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.spacing24),

              // What this means
              Text(
                'Your coach will now speak your language and match your decision-making style.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 2),

              // CTA Button
              AppButton(
                text: 'Start Coaching',
                onPressed: () {
                  // Navigate to chat screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Welcome, ${profile.displayName}! 🧠'),
                      backgroundColor: AppColors.sage,
                    ),
                  );
                  // TODO: Navigate to chat screen
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

class _ProfileTraitRow extends StatelessWidget {
  const _ProfileTraitRow({
    required this.label,
    required this.value,
    required this.emoji,
  });

  final String label;
  final String value;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(width: AppSpacing.spacing12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: AppTextStyles.label,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
