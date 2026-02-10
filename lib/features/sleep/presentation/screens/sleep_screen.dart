import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../meditation/domain/models/sample_data.dart';
import '../../../meditation/domain/models/meditation_session.dart';
import '../../../meditation/presentation/screens/player_screen.dart';
import '../../../subscription/presentation/screens/subscription_screen.dart';

class SleepScreen extends StatelessWidget {
  const SleepScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.jobsCream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.spacing16),
              const Text(
                'Sleep',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.jobsObsidian,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: AppSpacing.spacing8),
              Text(
                'Wind down and rest well',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 16,
                  color: AppColors.jobsObsidian.withValues(alpha: 0.6),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSpacing.spacing32),
              const Text(
                'Wind Down',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.jobsObsidian,
                ),
              ),
              const SizedBox(height: AppSpacing.spacing16),
              ...SampleData.breathingExercises.map((exercise) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _BreathingCard(exercise: exercise),
                  )),
              const SizedBox(height: AppSpacing.spacing24),
              const Text(
                'Sleep Stories',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.jobsObsidian,
                ),
              ),
              const SizedBox(height: AppSpacing.spacing16),
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: SampleData.sleepStories.length,
                  itemBuilder: (context, index) {
                    final story = SampleData.sleepStories[index];
                    return Padding(
                      padding: EdgeInsets.only(
                          right: index < SampleData.sleepStories.length - 1
                              ? 16
                              : 0),
                      child: _SleepStoryCard(story: story),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.spacing32),
              const Text(
                'Soundscapes',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.jobsObsidian,
                ),
              ),
              const SizedBox(height: AppSpacing.spacing16),
              Row(
                children: SampleData.soundscapes.map((soundscape) {
                  final index = SampleData.soundscapes.indexOf(soundscape);
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                          right: index < SampleData.soundscapes.length - 1
                              ? 12
                              : 0),
                      child: _SoundscapeCard(soundscape: soundscape),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.spacing24),
            ],
          ),
        ),
      ),
    );
  }
}

class _BreathingCard extends StatelessWidget {
  final BreathingExercise exercise;

  const _BreathingCard({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Starting ${exercise.title}...'),
            backgroundColor: AppColors.jobsSage,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.accentBlueDark.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text('🌬️', style: TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.title,
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.jobsObsidian,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    exercise.description,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 13,
                      color: AppColors.jobsObsidian.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${exercise.durationMinutes} min',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.jobsObsidian.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SleepStoryCard extends StatelessWidget {
  final SleepStory story;

  const _SleepStoryCard({required this.story});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (story.isPremium) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const SubscriptionScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Playing ${story.title}...'),
              backgroundColor: AppColors.jobsSage,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          );
        }
      },
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF2D3A4F),
              const Color(0xFF1D2633),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('📖', style: TextStyle(fontSize: 24)),
                if (story.isPremium)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.lock_rounded,
                      size: 14,
                      color: Colors.white70,
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Text(
              story.title,
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              'By ${story.narrator} • ${story.formattedDuration}',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SoundscapeCard extends StatelessWidget {
  final Soundscape soundscape;

  const _SoundscapeCard({required this.soundscape});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (soundscape.isPremium) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const SubscriptionScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Playing ${soundscape.title}...'),
              backgroundColor: AppColors.jobsSage,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Text(soundscape.icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 12),
            Text(
              soundscape.title,
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.jobsObsidian,
              ),
            ),
            if (soundscape.isPremium) ...[
              const SizedBox(height: 8),
              Icon(
                Icons.lock_rounded,
                size: 14,
                color: AppColors.primaryOrange,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
