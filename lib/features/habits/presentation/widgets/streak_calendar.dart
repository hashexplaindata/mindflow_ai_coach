import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

class StreakCalendar extends StatefulWidget {
  final List<DateTime> completedDates;
  final DateTime? selectedDate;
  final ValueChanged<DateTime>? onDateSelected;
  final int weeksToShow;

  const StreakCalendar({
    super.key,
    required this.completedDates,
    this.selectedDate,
    this.onDateSelected,
    this.weeksToShow = 12,
  });

  @override
  State<StreakCalendar> createState() => _StreakCalendarState();
}

class _StreakCalendarState extends State<StreakCalendar> {
  late DateTime _focusedMonth;
  late DateTime _today;

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _focusedMonth = DateTime(_today.year, _today.month, 1);
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    final nextMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    if (nextMonth.isBefore(DateTime(_today.year, _today.month + 1, 1))) {
      setState(() {
        _focusedMonth = nextMonth;
      });
    }
  }

  bool _isCompleted(DateTime date) {
    return widget.completedDates.any((d) =>
        d.year == date.year && d.month == date.month && d.day == date.day);
  }

  bool _isToday(DateTime date) {
    return date.year == _today.year &&
        date.month == _today.month &&
        date.day == _today.day;
  }

  bool _isFuture(DateTime date) {
    final todayStart = DateTime(_today.year, _today.month, _today.day);
    return date.isAfter(todayStart);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        const SizedBox(height: AppSpacing.spacing16),
        _buildWeekdayLabels(),
        const SizedBox(height: AppSpacing.spacing8),
        _buildCalendarGrid(),
      ],
    );
  }

  Widget _buildHeader() {
    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    final isAtCurrentMonth = _focusedMonth.year == _today.year &&
        _focusedMonth.month == _today.month;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: _previousMonth,
          icon: const Icon(Icons.chevron_left_rounded),
          color: AppColors.jobsObsidian,
          iconSize: 28,
        ),
        Text(
          '${monthNames[_focusedMonth.month - 1]} ${_focusedMonth.year}',
          style: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.jobsObsidian,
          ),
        ),
        IconButton(
          onPressed: isAtCurrentMonth ? null : _nextMonth,
          icon: const Icon(Icons.chevron_right_rounded),
          color: isAtCurrentMonth
              ? AppColors.jobsObsidian.withOpacity(0.3)
              : AppColors.jobsObsidian,
          iconSize: 28,
        ),
      ],
    );
  }

  Widget _buildWeekdayLabels() {
    const days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: days
          .map((day) => SizedBox(
                width: 36,
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.jobsObsidian.withOpacity(0.4),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final startingWeekday = firstDayOfMonth.weekday % 7;

    final days = <Widget>[];

    for (int i = 0; i < startingWeekday; i++) {
      days.add(const SizedBox(width: 36, height: 36));
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
      days.add(_buildDayCell(date));
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: days,
    );
  }

  Widget _buildDayCell(DateTime date) {
    final isCompleted = _isCompleted(date);
    final isToday = _isToday(date);
    final isFuture = _isFuture(date);

    return GestureDetector(
      onTap: isFuture ? null : () => widget.onDateSelected?.call(date),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isCompleted
              ? AppColors.jobsSage
              : isToday
                  ? AppColors.jobsSage.withOpacity(0.15)
                  : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '${date.day}',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 14,
              fontWeight: isToday || isCompleted ? FontWeight.w600 : FontWeight.normal,
              color: isFuture
                  ? AppColors.jobsObsidian.withOpacity(0.2)
                  : isCompleted
                      ? Colors.white
                      : AppColors.jobsObsidian,
            ),
          ),
        ),
      ),
    );
  }
}

class StreakHeatmap extends StatelessWidget {
  final List<DateTime> completedDates;
  final int weeksToShow;

  const StreakHeatmap({
    super.key,
    required this.completedDates,
    this.weeksToShow = 12,
  });

  bool _isCompleted(DateTime date) {
    return completedDates.any((d) =>
        d.year == date.year && d.month == date.month && d.day == date.day);
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final startDate = today.subtract(Duration(days: weeksToShow * 7 - 1));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Activity',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.jobsObsidian,
              ),
            ),
            Row(
              children: [
                Text(
                  'Less',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 11,
                    color: AppColors.jobsObsidian.withOpacity(0.5),
                  ),
                ),
                const SizedBox(width: 4),
                _buildLegend(),
                const SizedBox(width: 4),
                Text(
                  'More',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 11,
                    color: AppColors.jobsObsidian.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.spacing16),
        SizedBox(
          height: 7 * 14.0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(weeksToShow, (weekIndex) {
              return Expanded(
                child: Column(
                  children: List.generate(7, (dayIndex) {
                    final date = startDate.add(Duration(days: weekIndex * 7 + dayIndex));
                    if (date.isAfter(today)) {
                      return const SizedBox(height: 12, width: 12);
                    }
                    return Padding(
                      padding: const EdgeInsets.all(1),
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _isCompleted(date)
                              ? AppColors.jobsSage
                              : AppColors.jobsSage.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: AppColors.jobsSage.withOpacity(0.1),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 2),
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: AppColors.jobsSage.withOpacity(0.4),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 2),
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: AppColors.jobsSage.withOpacity(0.7),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 2),
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: AppColors.jobsSage,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}
