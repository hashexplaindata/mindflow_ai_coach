import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/models/habit.dart';
import '../../data/default_habits.dart';
import '../providers/habit_provider.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _nameController = TextEditingController();
  String _selectedIcon = '🎯';
  HabitCategory _selectedCategory = HabitCategory.morning;
  final List<int> _selectedDays = [1, 2, 3, 4, 5, 6, 7];
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createHabit() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a habit name'),
          backgroundColor: AppColors.primaryOrangeDark,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isCreating = true);

    final habit = Habit(
      id: 'habit_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      icon: _selectedIcon,
      category: _selectedCategory,
      targetDays: _selectedDays,
      createdAt: DateTime.now(),
    );

    await context.read<HabitProvider>().addHabit(habit);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _selectSuggestion(HabitSuggestion suggestion) {
    setState(() {
      _nameController.text = suggestion.name;
      _selectedIcon = suggestion.icon;
      _selectedCategory = suggestion.category;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.jobsCream,
      appBar: AppBar(
        backgroundColor: AppColors.jobsCream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.jobsObsidian),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'New Habit',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.jobsObsidian,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: _isCreating ? null : _createHabit,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: _isCreating
                      ? AppColors.jobsObsidian.withValues(alpha: 0.3)
                      : AppColors.jobsObsidian,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: _isCreating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.jobsCream,
                        ),
                      )
                    : const Text(
                        'Save',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.jobsCream,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _showIconPicker(),
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.jobsSage.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              _selectedIcon,
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _nameController,
                          style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.jobsObsidian,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Habit name',
                            hintStyle: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color:
                                  AppColors.jobsObsidian.withValues(alpha: 0.3),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.spacing24),
            const Text(
              'Time of Day',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.jobsObsidian,
              ),
            ),
            const SizedBox(height: AppSpacing.spacing12),
            _CategorySelector(
              selectedCategory: _selectedCategory,
              onChanged: (category) {
                setState(() => _selectedCategory = category);
              },
            ),
            const SizedBox(height: AppSpacing.spacing24),
            const Text(
              'Repeat',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.jobsObsidian,
              ),
            ),
            const SizedBox(height: AppSpacing.spacing12),
            _DaySelector(
              selectedDays: _selectedDays,
              onChanged: (days) {
                setState(() {
                  _selectedDays.clear();
                  _selectedDays.addAll(days);
                });
              },
            ),
            const SizedBox(height: AppSpacing.spacing32),
            const Text(
              'Suggestions',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.jobsObsidian,
              ),
            ),
            const SizedBox(height: AppSpacing.spacing12),
            _SuggestionsList(
              suggestions: DefaultHabits.suggestions,
              onSelect: _selectSuggestion,
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  void _showIconPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.jobsObsidian.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Choose an Icon',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.jobsObsidian,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: DefaultHabits.availableIcons.map((icon) {
                  final isSelected = icon == _selectedIcon;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedIcon = icon);
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.jobsSage.withValues(alpha: 0.2)
                            : AppColors.jobsObsidian.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected
                            ? Border.all(color: AppColors.jobsSage, width: 2)
                            : null,
                      ),
                      child: Center(
                        child: Text(icon, style: const TextStyle(fontSize: 24)),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

class _CategorySelector extends StatelessWidget {
  final HabitCategory selectedCategory;
  final ValueChanged<HabitCategory> onChanged;

  const _CategorySelector({
    required this.selectedCategory,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.jobsObsidian.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _CategoryChip(
            category: HabitCategory.morning,
            isSelected: selectedCategory == HabitCategory.morning,
            onTap: () => onChanged(HabitCategory.morning),
          ),
          _CategoryChip(
            category: HabitCategory.afternoon,
            isSelected: selectedCategory == HabitCategory.afternoon,
            onTap: () => onChanged(HabitCategory.afternoon),
          ),
          _CategoryChip(
            category: HabitCategory.evening,
            isSelected: selectedCategory == HabitCategory.evening,
            onTap: () => onChanged(HabitCategory.evening),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final HabitCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.jobsSage : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                category.emoji,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 6),
              Text(
                category.displayName,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : AppColors.jobsObsidian.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DaySelector extends StatelessWidget {
  final List<int> selectedDays;
  final ValueChanged<List<int>> onChanged;

  const _DaySelector({
    required this.selectedDays,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.jobsObsidian.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (index) {
          final dayNumber = index + 1;
          final isSelected = selectedDays.contains(dayNumber);

          return GestureDetector(
            onTap: () {
              final newDays = List<int>.from(selectedDays);
              if (isSelected) {
                newDays.remove(dayNumber);
              } else {
                newDays.add(dayNumber);
              }
              onChanged(newDays);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.jobsSage : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  days[index],
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : AppColors.jobsObsidian.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _SuggestionsList extends StatelessWidget {
  final List<HabitSuggestion> suggestions;
  final ValueChanged<HabitSuggestion> onSelect;

  const _SuggestionsList({
    required this.suggestions,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: suggestions.map((suggestion) {
        return GestureDetector(
          onTap: () => onSelect(suggestion),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.jobsObsidian.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(suggestion.icon, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  suggestion.name,
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.jobsObsidian,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
