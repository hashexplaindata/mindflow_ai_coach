import 'meditation_category.dart';

class MeditationSession {
  final String id;
  final String title;
  final String description;
  final int durationMinutes;
  final MeditationCategory category;
  final bool isPremium;
  final String? imageUrl;

  const MeditationSession({
    required this.id,
    required this.title,
    required this.description,
    required this.durationMinutes,
    required this.category,
    this.isPremium = false,
    this.imageUrl,
  });

  String get formattedDuration {
    if (durationMinutes < 60) {
      return '$durationMinutes min';
    }
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
  }
}

class SleepStory {
  final String id;
  final String title;
  final String narrator;
  final int durationMinutes;
  final bool isPremium;

  const SleepStory({
    required this.id,
    required this.title,
    required this.narrator,
    required this.durationMinutes,
    this.isPremium = false,
  });

  String get formattedDuration => '$durationMinutes min';
}

class Soundscape {
  final String id;
  final String title;
  final String icon;
  final bool isPremium;

  const Soundscape({
    required this.id,
    required this.title,
    required this.icon,
    this.isPremium = false,
  });
}

class BreathingExercise {
  final String id;
  final String title;
  final String description;
  final int durationMinutes;

  const BreathingExercise({
    required this.id,
    required this.title,
    required this.description,
    required this.durationMinutes,
  });
}
