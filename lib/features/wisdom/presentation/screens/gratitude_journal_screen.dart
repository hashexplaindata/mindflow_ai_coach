import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/models/gratitude_entry.dart';
import '../providers/wisdom_provider.dart';
import '../widgets/gratitude_prompt_card.dart';

class GratitudeJournalScreen extends StatefulWidget {
  const GratitudeJournalScreen({super.key});

  @override
  State<GratitudeJournalScreen> createState() => _GratitudeJournalScreenState();
}

class _GratitudeJournalScreenState extends State<GratitudeJournalScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.jobsCream,
      body: SafeArea(
        child: Consumer<WisdomProvider>(
          builder: (context, wisdomProvider, child) {
            final entries = wisdomProvider.gratitudeEntries;
            final weeklyCount = wisdomProvider.gratitudeEntriesThisWeek;

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: AppColors.jobsCream,
                  elevation: 0,
                  pinned: true,
                  expandedHeight: 140,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Gratitude Journal',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.jobsObsidian,
                              height: 1.2,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$weeklyCount entries this week',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 16,
                              color:
                                  AppColors.jobsObsidian.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.screenPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _WeeklyProgress(
                          count: weeklyCount,
                          goal: 7,
                        ),
                        const SizedBox(height: 24),
                        GratitudePromptCard(
                          prompt: wisdomProvider.gratitudePrompt,
                          hasWrittenToday:
                              wisdomProvider.hasWrittenGratitudeToday,
                          onSubmit: (content) {
                            wisdomProvider.addGratitudeEntry(
                              content: content,
                              promptId: wisdomProvider.gratitudePrompt?.id,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Gratitude saved'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            const Text(
                              'Past Entries',
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.jobsObsidian,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${entries.length} total',
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 14,
                                color: AppColors.jobsObsidian
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (entries.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color:
                                  AppColors.accentYellow.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text(
                                '🙏',
                                style: TextStyle(fontSize: 36),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'No entries yet',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color:
                                  AppColors.jobsObsidian.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start your gratitude practice above',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 14,
                              color:
                                  AppColors.jobsObsidian.withValues(alpha: 0.5),
                            ),
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final entry = entries[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.screenPadding,
                            vertical: 6,
                          ),
                          child: _GratitudeEntryCard(
                            entry: entry,
                            onDelete: () =>
                                _confirmDelete(context, entry, wisdomProvider),
                          ),
                        );
                      },
                      childCount: entries.length,
                    ),
                  ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 40),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    GratitudeEntry entry,
    WisdomProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content:
            const Text('Are you sure you want to delete this gratitude entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteGratitudeEntry(entry.id);
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.errorRed,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _WeeklyProgress extends StatelessWidget {
  final int count;
  final int goal;

  const _WeeklyProgress({
    required this.count,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (count / goal).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accentYellow.withValues(alpha: 0.3),
            AppColors.accentYellow.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '🙏',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Text(
                'Weekly Goal',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.jobsObsidian.withValues(alpha: 0.8),
                ),
              ),
              const Spacer(),
              Text(
                '$count / $goal',
                style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.jobsObsidian,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.5),
              valueColor: const AlwaysStoppedAnimation(AppColors.accentYellow),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            progress >= 1.0
                ? 'Goal achieved! Keep going!'
                : '${goal - count} more to reach your goal',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 13,
              color: AppColors.jobsObsidian.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _GratitudeEntryCard extends StatelessWidget {
  final GratitudeEntry entry;
  final VoidCallback? onDelete;

  const _GratitudeEntryCard({
    required this.entry,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.jobsObsidian.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.accentYellow.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🙏', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      entry.formattedDate,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.jobsObsidian.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                entry.formattedTime,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 12,
                  color: AppColors.jobsObsidian.withValues(alpha: 0.4),
                ),
              ),
              if (onDelete != null) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onDelete,
                  child: Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: AppColors.jobsObsidian.withValues(alpha: 0.3),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(
            entry.content,
            style: const TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 15,
              color: AppColors.jobsObsidian,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
