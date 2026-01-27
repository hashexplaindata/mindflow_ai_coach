import 'dart:math';
import '../../../onboarding/domain/models/nlp_profile.dart';
import '../models/user_context.dart';
import '../models/wisdom_item.dart';
import '../models/wisdom_category.dart';

class WisdomScore {
  final WisdomItem item;
  final double totalScore;
  final Map<String, double> componentScores;

  const WisdomScore({
    required this.item,
    required this.totalScore,
    required this.componentScores,
  });

  @override
  String toString() {
    return 'WisdomScore(id: ${item.id}, total: ${totalScore.toStringAsFixed(2)})';
  }
}

class WisdomPredictor {
  static const double _timeWeight = 0.20;
  static const double _moodWeight = 0.25;
  static const double _activityWeight = 0.20;
  static const double _personalityWeight = 0.15;
  static const double _noveltyWeight = 0.15;
  static const double _feedbackWeight = 0.05;

  WisdomPredictor._();

  static WisdomItem predictBestWisdom({
    required NLPProfile? userProfile,
    required UserContext context,
    required List<WisdomItem> candidates,
  }) {
    if (candidates.isEmpty) {
      throw ArgumentError('Candidates list cannot be empty');
    }

    if (candidates.length == 1) {
      return candidates.first;
    }

    final scores = candidates.map((item) {
      return _scoreWisdom(
        item: item,
        profile: userProfile,
        context: context,
      );
    }).toList();

    scores.sort((a, b) => b.totalScore.compareTo(a.totalScore));

    final topScores = scores.take(3).toList();
    if (topScores.length > 1 && 
        (topScores[0].totalScore - topScores[1].totalScore).abs() < 0.1) {
      final random = Random(DateTime.now().day);
      return topScores[random.nextInt(topScores.length)].item;
    }

    return scores.first.item;
  }

  static WisdomScore _scoreWisdom({
    required WisdomItem item,
    required NLPProfile? profile,
    required UserContext context,
  }) {
    final componentScores = <String, double>{};

    componentScores['time'] = _scoreTimeRelevance(item, context.timeOfDay);
    componentScores['mood'] = _scoreMoodAlignment(item, context.inferredMood);
    componentScores['activity'] = _scoreActivityContext(item, context.activityContext);
    componentScores['personality'] = _scorePersonalityMatch(item, profile);
    componentScores['novelty'] = _scoreNovelty(item, context.recentlyShownWisdomIds);
    componentScores['feedback'] = _scoreFeedbackHistory(item, context.wisdomFeedback);

    final totalScore = 
        componentScores['time']! * _timeWeight +
        componentScores['mood']! * _moodWeight +
        componentScores['activity']! * _activityWeight +
        componentScores['personality']! * _personalityWeight +
        componentScores['novelty']! * _noveltyWeight +
        componentScores['feedback']! * _feedbackWeight;

    return WisdomScore(
      item: item,
      totalScore: totalScore,
      componentScores: componentScores,
    );
  }

  static double _scoreTimeRelevance(WisdomItem item, TimeOfDayPeriod timeOfDay) {
    if (item.suitableTimeOfDay.isEmpty) {
      return _getDefaultTimeScore(item, timeOfDay);
    }

    if (item.suitableTimeOfDay.contains(timeOfDay)) {
      return 1.0;
    }

    return 0.3;
  }

  static double _getDefaultTimeScore(WisdomItem item, TimeOfDayPeriod timeOfDay) {
    switch (timeOfDay) {
      case TimeOfDayPeriod.morning:
        if (item.tone == WisdomTone.motivation || item.tone == WisdomTone.growth) {
          return 0.9;
        }
        if (item.tone == WisdomTone.gratitude) {
          return 0.8;
        }
        return 0.5;

      case TimeOfDayPeriod.afternoon:
        if (item.tone == WisdomTone.mindfulness) {
          return 0.8;
        }
        if (item.tone == WisdomTone.motivation) {
          return 0.7;
        }
        return 0.5;

      case TimeOfDayPeriod.evening:
        if (item.tone == WisdomTone.calm || item.tone == WisdomTone.gratitude) {
          return 0.9;
        }
        if (item.tone == WisdomTone.mindfulness) {
          return 0.8;
        }
        return 0.5;

      case TimeOfDayPeriod.night:
        if (item.tone == WisdomTone.calm) {
          return 1.0;
        }
        if (item.tone == WisdomTone.mindfulness) {
          return 0.8;
        }
        return 0.4;
    }
  }

  static double _scoreMoodAlignment(WisdomItem item, UserMood? mood) {
    if (mood == null) {
      return 0.5;
    }

    if (item.suitableMoods.isNotEmpty && item.suitableMoods.contains(mood)) {
      return 1.0;
    }

    return _getDefaultMoodScore(item, mood);
  }

  static double _getDefaultMoodScore(WisdomItem item, UserMood mood) {
    switch (mood) {
      case UserMood.stressed:
        if (item.tone == WisdomTone.calm) return 1.0;
        if (item.tone == WisdomTone.mindfulness) return 0.9;
        if (item.tags.contains('breath') || item.tags.contains('peace')) return 0.85;
        return 0.3;

      case UserMood.anxious:
        if (item.tone == WisdomTone.calm) return 1.0;
        if (item.tone == WisdomTone.mindfulness) return 0.9;
        if (item.tags.contains('present') || item.tags.contains('safety')) return 0.85;
        return 0.3;

      case UserMood.tired:
        if (item.tone == WisdomTone.calm) return 0.9;
        if (item.tags.contains('rest') || item.tags.contains('ease')) return 0.85;
        if (item.tone == WisdomTone.motivation) return 0.4;
        return 0.5;

      case UserMood.motivated:
        if (item.tone == WisdomTone.motivation) return 1.0;
        if (item.tone == WisdomTone.growth) return 0.95;
        if (item.tags.contains('goals') || item.tags.contains('action')) return 0.9;
        return 0.5;

      case UserMood.calm:
        if (item.tone == WisdomTone.mindfulness) return 0.9;
        if (item.tone == WisdomTone.gratitude) return 0.85;
        if (item.tone == WisdomTone.growth) return 0.8;
        return 0.6;

      case UserMood.neutral:
        return 0.5;
    }
  }

  static double _scoreActivityContext(WisdomItem item, ActivityContext activity) {
    if (item.suitableActivities.isNotEmpty && item.suitableActivities.contains(activity)) {
      return 1.0;
    }

    return _getDefaultActivityScore(item, activity);
  }

  static double _getDefaultActivityScore(WisdomItem item, ActivityContext activity) {
    switch (activity) {
      case ActivityContext.newUser:
        if (item.tags.contains('beginnings') || item.tags.contains('journey')) return 1.0;
        if (item.tone == WisdomTone.motivation) return 0.9;
        if (item.tags.contains('potential')) return 0.85;
        return 0.5;

      case ActivityContext.streakBroken:
        if (item.tags.contains('persistence') || item.tags.contains('courage')) return 1.0;
        if (item.tags.contains('beginnings') || item.tags.contains('fresh')) return 0.9;
        if (item.tone == WisdomTone.growth) return 0.85;
        if (item.tone == WisdomTone.calm) return 0.7;
        return 0.4;

      case ActivityContext.streakMaintained:
        if (item.tags.contains('progress') || item.tags.contains('growth')) return 1.0;
        if (item.tone == WisdomTone.motivation) return 0.9;
        if (item.tone == WisdomTone.gratitude) return 0.85;
        return 0.6;

      case ActivityContext.returning:
        if (item.tags.contains('journey') || item.tags.contains('return')) return 0.9;
        if (item.tone == WisdomTone.calm) return 0.8;
        return 0.5;

      case ActivityContext.longAbsence:
        if (item.tags.contains('beginnings') || item.tags.contains('fresh')) return 1.0;
        if (item.tags.contains('compassion') || item.tags.contains('acceptance')) return 0.9;
        if (item.tone == WisdomTone.calm) return 0.8;
        return 0.5;

      case ActivityContext.preMeditation:
        if (item.tone == WisdomTone.mindfulness) return 1.0;
        if (item.tone == WisdomTone.calm) return 0.9;
        if (item.tags.contains('breath') || item.tags.contains('present')) return 0.85;
        return 0.5;

      case ActivityContext.postMeditation:
        if (item.tone == WisdomTone.gratitude) return 1.0;
        if (item.tone == WisdomTone.growth) return 0.9;
        if (item.tags.contains('peace') || item.tags.contains('wisdom')) return 0.85;
        return 0.5;
    }
  }

  static double _scorePersonalityMatch(WisdomItem item, NLPProfile? profile) {
    if (profile == null) {
      return 0.5;
    }

    double score = 0.5;

    if (profile.motivation == 'toward') {
      if (item.tone == WisdomTone.motivation || item.tone == WisdomTone.growth) {
        score += 0.3;
      }
      if (item.tags.any((t) => ['goals', 'dreams', 'potential', 'success'].contains(t))) {
        score += 0.15;
      }
    } else {
      if (item.tone == WisdomTone.calm || item.tone == WisdomTone.mindfulness) {
        score += 0.3;
      }
      if (item.tags.any((t) => ['peace', 'safety', 'release', 'acceptance'].contains(t))) {
        score += 0.15;
      }
    }

    if (profile.thinking == 'visual') {
      if (item.content.contains('see') || 
          item.content.contains('imagine') || 
          item.content.contains('vision') ||
          item.content.contains('light')) {
        score += 0.1;
      }
    } else if (profile.thinking == 'kinesthetic') {
      if (item.content.contains('feel') || 
          item.content.contains('breath') || 
          item.content.contains('body') ||
          item.content.contains('flow')) {
        score += 0.1;
      }
    }

    if (profile.change == 'sameness' && item.tags.contains('stability')) {
      score += 0.05;
    } else if (profile.change == 'difference' && item.tags.contains('change')) {
      score += 0.05;
    }

    return score.clamp(0.0, 1.0);
  }

  static double _scoreNovelty(WisdomItem item, List<String> recentlyShownIds) {
    if (recentlyShownIds.isEmpty) {
      return 1.0;
    }

    final index = recentlyShownIds.indexOf(item.id);
    
    if (index == -1) {
      return 1.0;
    }

    final recencyPenalty = 1.0 - (index / recentlyShownIds.length);
    return (0.2 + (0.8 * (1.0 - recencyPenalty))).clamp(0.0, 0.5);
  }

  static double _scoreFeedbackHistory(WisdomItem item, Map<String, bool> feedback) {
    if (feedback.isEmpty) {
      return 0.5;
    }

    if (feedback.containsKey(item.id)) {
      return feedback[item.id]! ? 0.3 : 0.1;
    }

    int positiveCount = 0;
    int negativeCount = 0;

    for (final entry in feedback.entries) {
      if (entry.value) {
        positiveCount++;
      } else {
        negativeCount++;
      }
    }

    if (positiveCount + negativeCount == 0) {
      return 0.5;
    }

    return 0.5 + (0.2 * (positiveCount - negativeCount) / (positiveCount + negativeCount));
  }

  static List<WisdomItem> getTopCandidates({
    required NLPProfile? userProfile,
    required UserContext context,
    required List<WisdomItem> allWisdom,
    int count = 5,
  }) {
    final scores = allWisdom.map((item) {
      return _scoreWisdom(
        item: item,
        profile: userProfile,
        context: context,
      );
    }).toList();

    scores.sort((a, b) => b.totalScore.compareTo(a.totalScore));

    return scores.take(count).map((s) => s.item).toList();
  }
}
