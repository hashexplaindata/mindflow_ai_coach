import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/config/env_config.dart';
import '../../domain/models/wellness_goal.dart';
import '../widgets/goal_card.dart';

class GoalsScreen extends StatefulWidget {
  final String userId;

  const GoalsScreen({
    super.key,
    required this.userId,
  });

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<WellnessGoal> _activeGoals = [];
  List<WellnessGoal> _completedGoals = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadGoals();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadGoals() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final baseUrl = apiBaseUrl.isEmpty ? '' : apiBaseUrl;
      final response = await http.get(
        Uri.parse('$baseUrl/api/goals/${widget.userId}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final goals = (data['goals'] as List)
            .map((g) => WellnessGoal.fromJson(g))
            .toList();

        setState(() {
          _activeGoals =
              goals.where((g) => g.status == GoalStatus.active).toList();
          _completedGoals =
              goals.where((g) => g.status == GoalStatus.completed).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createGoal(GoalTemplate template) async {
    final goal = WellnessGoal(
      id: const Uuid().v4(),
      type: template.type,
      targetValue: template.targetValue,
      currentValue: 0,
      createdAt: DateTime.now(),
      status: GoalStatus.active,
      category: template.category,
    );

    try {
      final baseUrl = apiBaseUrl.isEmpty ? '' : apiBaseUrl;
      final response = await http.post(
        Uri.parse('$baseUrl/api/goals'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': widget.userId,
          ...goal.toJson(),
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        setState(() {
          _activeGoals.insert(0, goal);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Goal created! Let\'s achieve it together.'),
              backgroundColor: AppColors.successGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _activeGoals.insert(0, goal);
      });
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _showNewGoalSheet() {
    final suggestedGoals = GoalTemplate.getNextGoals(_completedGoals.length);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.jobsCream,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.jobsObsidian.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing24),
                const Text(
                  'Set a New Goal',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.jobsObsidian,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _completedGoals.isEmpty
                      ? 'Start small. Build momentum.'
                      : 'Ready for your next challenge?',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 15,
                    color: AppColors.jobsObsidian.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing24),
                Text(
                  _completedGoals.isEmpty
                      ? 'Suggested for beginners'
                      : _completedGoals.length < 5
                          ? 'Level up your practice'
                          : 'Advanced challenges',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.jobsObsidian.withValues(alpha: 0.5),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing12),
                ...suggestedGoals.map((template) => Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppSpacing.spacing12),
                      child: GoalTemplateCard(
                        template: template,
                        onSelect: () => _createGoal(template),
                      ),
                    )),
                const SizedBox(height: AppSpacing.spacing16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.jobsCream,
      appBar: AppBar(
        backgroundColor: AppColors.jobsCream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.jobsObsidian),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'My Goals',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.jobsObsidian,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.jobsObsidian,
          unselectedLabelColor: AppColors.jobsObsidian.withValues(alpha: 0.4),
          indicatorColor: AppColors.jobsSage,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          tabs: [
            Tab(text: 'Active (${_activeGoals.length})'),
            Tab(text: 'Completed (${_completedGoals.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AppColors.jobsSage),
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildActiveGoalsTab(),
                _buildCompletedGoalsTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showNewGoalSheet,
        backgroundColor: AppColors.jobsSage,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'New Goal',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildActiveGoalsTab() {
    if (_activeGoals.isEmpty) {
      return _buildEmptyState(
        icon: Icons.flag_outlined,
        title: 'No active goals',
        subtitle: 'Set a goal to track your progress\nand stay motivated',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadGoals,
      color: AppColors.jobsSage,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        itemCount: _activeGoals.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.spacing16),
            child: GoalCard(goal: _activeGoals[index]),
          );
        },
      ),
    );
  }

  Widget _buildCompletedGoalsTab() {
    if (_completedGoals.isEmpty) {
      return _buildEmptyState(
        icon: Icons.emoji_events_outlined,
        title: 'No completed goals yet',
        subtitle: 'Complete your first goal\nto see it here',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadGoals,
      color: AppColors.jobsSage,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        itemCount: _completedGoals.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.spacing16),
            child: GoalCard(
              goal: _completedGoals[index],
              showCelebration: true,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacing32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.jobsSage.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: AppColors.jobsSage,
              ),
            ),
            const SizedBox(height: AppSpacing.spacing24),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.jobsObsidian,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 15,
                color: AppColors.jobsObsidian.withValues(alpha: 0.6),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
