import '../../../onboarding/domain/models/nlp_profile.dart';

class ConversationContext {
  const ConversationContext({
    required this.userProfile,
    this.currentStreak = 0,
    this.totalSessions = 0,
    this.totalMinutes = 0,
    this.practiceStage = PracticeStage.beginner,
    this.lastSessionDate,
    this.activeGoal,
    this.goalProgress,
    this.timeOfDay = TimeOfDayContext.afternoon,
  });

  final NLPProfile userProfile;
  final int currentStreak;
  final int totalSessions;
  final int totalMinutes;
  final PracticeStage practiceStage;
  final DateTime? lastSessionDate;
  final String? activeGoal;
  final double? goalProgress;
  final TimeOfDayContext timeOfDay;

  static TimeOfDayContext getCurrentTimeContext() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return TimeOfDayContext.morning;
    } else if (hour >= 12 && hour < 17) {
      return TimeOfDayContext.afternoon;
    } else if (hour >= 17 && hour < 21) {
      return TimeOfDayContext.evening;
    } else {
      return TimeOfDayContext.night;
    }
  }

  List<String> getSuggestedStarters() {
    final timeContext = getCurrentTimeContext();
    
    switch (timeContext) {
      case TimeOfDayContext.morning:
        return [
          'Help me start my day mindfully',
          'I need focus for today',
          'Set my intention for today',
          'I woke up feeling anxious',
        ];
      case TimeOfDayContext.afternoon:
        return [
          'I need a mental reset',
          'Help me stay focused',
          'I\'m feeling overwhelmed',
          'Motivate me to keep going',
        ];
      case TimeOfDayContext.evening:
        return [
          'Help me unwind',
          'Reflect on my day',
          'I\'m stressed from work',
          'Prepare me for restful sleep',
        ];
      case TimeOfDayContext.night:
        return [
          'I can\'t sleep',
          'Quiet my racing thoughts',
          'Help me relax',
          'Guide me to peaceful rest',
        ];
    }
  }

  List<QuickAction> getQuickActions() {
    return [
      const QuickAction(
        label: 'Help me relax',
        emoji: '🧘',
        message: 'I need help relaxing right now',
      ),
      const QuickAction(
        label: 'I\'m stressed',
        emoji: '😰',
        message: 'I\'m feeling stressed and need support',
      ),
      const QuickAction(
        label: 'Motivate me',
        emoji: '💪',
        message: 'I need some motivation right now',
      ),
      const QuickAction(
        label: 'Breathing',
        emoji: '🌬️',
        message: 'Guide me through a quick breathing exercise',
      ),
    ];
  }

  String getWelcomeGreeting() {
    final timeContext = getCurrentTimeContext();
    final practiceMessage = _getPracticeStageMessage();
    
    switch (timeContext) {
      case TimeOfDayContext.morning:
        return 'Good morning. $practiceMessage';
      case TimeOfDayContext.afternoon:
        return 'Good afternoon. $practiceMessage';
      case TimeOfDayContext.evening:
        return 'Good evening. $practiceMessage';
      case TimeOfDayContext.night:
        return 'It\'s quiet now. $practiceMessage';
    }
  }

  String _getPracticeStageMessage() {
    if (currentStreak > 0) {
      if (currentStreak == 1) {
        return 'You started something yesterday. Let\'s keep it going.';
      } else if (currentStreak < 7) {
        return '$currentStreak days of showing up. Something is building.';
      } else if (currentStreak < 30) {
        return '$currentStreak days. This is becoming who you are.';
      } else {
        return '$currentStreak days. You\'ve built something beautiful.';
      }
    }
    
    if (totalSessions == 0) {
      return 'What brings you here today?';
    } else if (totalSessions < 5) {
      return 'Welcome back. I remember you.';
    } else {
      return 'Good to see you again.';
    }
  }

  ConversationContext copyWith({
    NLPProfile? userProfile,
    int? currentStreak,
    int? totalSessions,
    int? totalMinutes,
    PracticeStage? practiceStage,
    DateTime? lastSessionDate,
    String? activeGoal,
    double? goalProgress,
    TimeOfDayContext? timeOfDay,
  }) {
    return ConversationContext(
      userProfile: userProfile ?? this.userProfile,
      currentStreak: currentStreak ?? this.currentStreak,
      totalSessions: totalSessions ?? this.totalSessions,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      practiceStage: practiceStage ?? this.practiceStage,
      lastSessionDate: lastSessionDate ?? this.lastSessionDate,
      activeGoal: activeGoal ?? this.activeGoal,
      goalProgress: goalProgress ?? this.goalProgress,
      timeOfDay: timeOfDay ?? this.timeOfDay,
    );
  }
}

enum PracticeStage {
  beginner,
  developing,
  intermediate,
  established,
  advanced,
}

enum TimeOfDayContext {
  morning,
  afternoon,
  evening,
  night,
}

class QuickAction {
  const QuickAction({
    required this.label,
    required this.emoji,
    required this.message,
  });

  final String label;
  final String emoji;
  final String message;
}
