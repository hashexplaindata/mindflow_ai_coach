import 'dart:math';

import '../../../onboarding/domain/models/nlp_profile.dart';
import '../models/wisdom_category.dart';
import '../models/wisdom_item.dart';
import '../models/user_context.dart';
import '../../data/wisdom_content.dart';
import 'wisdom_predictor.dart';

class WisdomService {
  WisdomService._();

  static WisdomItem getPredictedDailyWisdom({
    required NLPProfile? profile,
    required UserContext context,
  }) {
    final candidates = WisdomContent.allWisdom;
    
    return WisdomPredictor.predictBestWisdom(
      userProfile: profile,
      context: context,
      candidates: candidates,
    );
  }

  static WisdomItem getTodaysWisdom({
    required NLPProfile? profile,
    required List<String> recentlyShownIds,
    WisdomCategory? preferredCategory,
  }) {
    final context = UserContext.fromCurrentState(
      currentStreak: 0,
      daysSinceLastSession: 0,
      totalSessions: 0,
      totalMinutes: 0,
      recentlyShownWisdomIds: recentlyShownIds,
    );
    
    List<WisdomItem> pool = _getPersonalizedPool(profile, preferredCategory);

    pool = pool.where((item) => !recentlyShownIds.contains(item.id)).toList();

    if (pool.isEmpty) {
      pool = _getPersonalizedPool(profile, preferredCategory);
    }

    return WisdomPredictor.predictBestWisdom(
      userProfile: profile,
      context: context,
      candidates: pool,
    );
  }

  static List<WisdomItem> _getPersonalizedPool(
    NLPProfile? profile,
    WisdomCategory? preferredCategory,
  ) {
    if (profile == null) {
      return WisdomContent.allWisdom;
    }

    List<WisdomItem> pool = [];

    if (preferredCategory != null) {
      pool = WisdomContent.getWisdomByCategory(preferredCategory);
    } else {
      final isGoalOriented = profile.motivation == 'toward';

      if (isGoalOriented) {
        pool = [
          ...WisdomContent.getWisdomByTone(WisdomTone.motivation),
          ...WisdomContent.getWisdomByTone(WisdomTone.growth),
          ...WisdomContent.getWisdomByTone(WisdomTone.gratitude).take(3),
        ];
      } else {
        pool = [
          ...WisdomContent.getWisdomByTone(WisdomTone.calm),
          ...WisdomContent.getWisdomByTone(WisdomTone.mindfulness),
          ...WisdomContent.getWisdomByTone(WisdomTone.gratitude).take(3),
        ];
      }
    }

    return pool.isEmpty ? WisdomContent.allWisdom : pool;
  }

  static WisdomItem getRandomWisdom({WisdomTone? tone}) {
    List<WisdomItem> pool;

    if (tone != null) {
      pool = WisdomContent.getWisdomByTone(tone);
    } else {
      pool = WisdomContent.allWisdom;
    }

    final random = Random();
    return pool[random.nextInt(pool.length)];
  }

  static WisdomItem getContextualWisdom({
    required UserContext context,
    NLPProfile? profile,
  }) {
    return WisdomPredictor.predictBestWisdom(
      userProfile: profile,
      context: context,
      candidates: WisdomContent.allWisdom,
    );
  }

  static WisdomItem getGratitudePrompt({
    required List<String> recentlyShownIds,
  }) {
    var prompts = WisdomContent.getWisdomByCategory(WisdomCategory.gratitudePrompt);

    prompts = prompts.where((item) => !recentlyShownIds.contains(item.id)).toList();

    if (prompts.isEmpty) {
      prompts = WisdomContent.getWisdomByCategory(WisdomCategory.gratitudePrompt);
    }

    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final random = Random(dayOfYear + 1000);

    return prompts[random.nextInt(prompts.length)];
  }

  static WisdomItem getMindfulnessInsight({
    required List<String> recentlyShownIds,
  }) {
    var insights = WisdomContent.getWisdomByCategory(WisdomCategory.insight);

    insights = insights.where((item) => !recentlyShownIds.contains(item.id)).toList();

    if (insights.isEmpty) {
      insights = WisdomContent.getWisdomByCategory(WisdomCategory.insight);
    }

    final random = Random();
    return insights[random.nextInt(insights.length)];
  }

  static String getWisdomGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 6) {
      return 'In the quiet of night';
    } else if (hour < 12) {
      return 'Start your day with wisdom';
    } else if (hour < 17) {
      return 'A moment of reflection';
    } else if (hour < 21) {
      return 'Evening wisdom';
    } else {
      return 'Before you rest';
    }
  }

  static String getPersonalizedGreeting(UserContext context) {
    switch (context.timeOfDay) {
      case TimeOfDayPeriod.morning:
        if (context.currentStreak > 0) {
          return 'Rise and shine, mindful one';
        }
        return 'Start your day with intention';
      case TimeOfDayPeriod.afternoon:
        if (context.inferredMood == UserMood.stressed) {
          return 'A moment of calm for you';
        }
        return 'A midday pause for reflection';
      case TimeOfDayPeriod.evening:
        if (context.currentStreak > 7) {
          return 'Celebrate your dedication';
        }
        return 'Wind down with wisdom';
      case TimeOfDayPeriod.night:
        return 'Before you rest';
    }
  }

  static List<WisdomItem> getFavoriteWisdom(List<String> favoriteIds) {
    return WisdomContent.allWisdom
        .where((item) => favoriteIds.contains(item.id))
        .toList();
  }

  static List<WisdomItem> searchWisdom(String query) {
    final lowerQuery = query.toLowerCase();

    return WisdomContent.allWisdom.where((item) {
      return item.content.toLowerCase().contains(lowerQuery) ||
          (item.author?.toLowerCase().contains(lowerQuery) ?? false) ||
          item.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  static List<WisdomItem> getTopRecommendations({
    required NLPProfile? profile,
    required UserContext context,
    int count = 5,
  }) {
    return WisdomPredictor.getTopCandidates(
      userProfile: profile,
      context: context,
      allWisdom: WisdomContent.allWisdom,
      count: count,
    );
  }
}
