import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/models/habit.dart';
import '../../domain/models/daily_ritual.dart';
import '../providers/habit_provider.dart';
import '../widgets/ritual_card.dart';
import '../widgets/habit_tile.dart';
import 'add_habit_screen.dart';
import 'habit_detail_screen.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HabitProvider>().initialize();
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _getDateString() {
    final now = DateTime.now();
    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.jobsCream,
      body: SafeArea(
        child: Consumer<HabitProvider>(
          builder: (context, habitProvider, child) {
            if (habitProvider.isLoading && !habitProvider.isInitialized) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.jobsSage,
                ),
              );
            }

            final rituals = habitProvider.todayRituals;

            return RefreshIndicator(
              onRefresh: () async {
                await habitProvider.initialize();
              },
              color: AppColors.jobsSage,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.screenPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: AppSpacing.spacing8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getGreeting(),
                                    style: const TextStyle(
                                      fontFamily: 'DM Sans',
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.jobsObsidian,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _getDateString(),
                                    style: TextStyle(
                                      fontFamily: 'DM Sans',
                                      fontSize: 14,
                                      color: AppColors.jobsObsidian
                                          .withValues(alpha: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const AddHabitScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.jobsObsidian,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.add_rounded,
                                    color: AppColors.jobsCream,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.spacing24),
                          _TodayProgressCard(
                            completed: habitProvider.todayCompletedCount,
                            total: habitProvider.todayTotalCount,
                            progress: habitProvider.todayProgress,
                          ),
                          const SizedBox(height: AppSpacing.spacing32),
                        ],
                      ),
                    ),
                  ),
                  if (rituals.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.screenPadding),
                        child: _EmptyState(
                          onAddHabit: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const AddHabitScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final ritual = rituals[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.screenPadding,
                            ),
                            child: _RitualSection(
                              ritual: ritual,
                              onToggleHabit: (habitId) {
                                habitProvider.toggleHabitComplete(habitId);
                              },
                              onHabitTap: (habit) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        HabitDetailScreen(habit: habit),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        childCount: rituals.length,
                      ),
                    ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TodayProgressCard extends StatelessWidget {
  final int completed;
  final int total;
  final double progress;

  const _TodayProgressCard({
    required this.completed,
    required this.total,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.jobsSage,
            AppColors.jobsSage.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.jobsSage.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's Progress",
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$completed of $total',
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'habits completed',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${(progress * 100).toInt()}%',
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class _RitualSection extends StatelessWidget {
  final DailyRitual ritual;
  final ValueChanged<String> onToggleHabit;
  final ValueChanged<Habit> onHabitTap;

  const _RitualSection({
    required this.ritual,
    required this.onToggleHabit,
    required this.onHabitTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              ritual.emoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 10),
            Text(
              ritual.title,
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.jobsObsidian,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: ritual.isComplete
                    ? AppColors.jobsSage.withValues(alpha: 0.15)
                    : AppColors.jobsObsidian.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${ritual.completedHabits}/${ritual.totalHabits}',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: ritual.isComplete
                      ? AppColors.jobsSage
                      : AppColors.jobsObsidian.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.spacing12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.jobsObsidian.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: ritual.habits.asMap().entries.map((entry) {
              final index = entry.key;
              final habit = entry.value;
              return Column(
                children: [
                  HabitTile(
                    habit: habit,
                    onToggle: () => onToggleHabit(habit.id),
                    onTap: () => onHabitTap(habit),
                  ),
                  if (index < ritual.habits.length - 1)
                    Divider(
                      height: 1,
                      indent: 60,
                      endIndent: 16,
                      color: AppColors.jobsObsidian.withValues(alpha: 0.05),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.spacing24),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAddHabit;

  const _EmptyState({required this.onAddHabit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.jobsObsidian.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.jobsSage.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                '🌱',
                style: TextStyle(fontSize: 36),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.spacing24),
          const Text(
            'Start Building Habits',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.jobsObsidian,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first habit to begin\nyour wellness journey',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 14,
              color: AppColors.jobsObsidian.withOpacity(0.6),
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.spacing24),
          GestureDetector(
            onTap: onAddHabit,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.jobsObsidian,
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Text(
                'Add Your First Habit',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.jobsCream,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
