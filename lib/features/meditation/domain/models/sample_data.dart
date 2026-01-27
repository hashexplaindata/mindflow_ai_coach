import 'meditation_session.dart';
import 'meditation_category.dart';

class SampleData {
  static const List<MeditationSession> allMeditations = [
    // Stress
    MeditationSession(
      id: 'stress_1',
      title: 'Release Tension',
      description: 'Let go of built-up stress with this calming session',
      durationMinutes: 10,
      category: MeditationCategory.stress,
    ),
    MeditationSession(
      id: 'stress_2',
      title: 'Stress SOS',
      description: 'Quick relief when you need it most',
      durationMinutes: 5,
      category: MeditationCategory.stress,
    ),
    MeditationSession(
      id: 'stress_3',
      title: 'Deep Relaxation',
      description: 'A complete body and mind relaxation experience',
      durationMinutes: 20,
      category: MeditationCategory.stress,
      isPremium: true,
    ),
    MeditationSession(
      id: 'stress_4',
      title: 'Calm in Chaos',
      description: 'Find peace even in stressful moments',
      durationMinutes: 15,
      category: MeditationCategory.stress,
      isPremium: true,
    ),

    // Anxiety
    MeditationSession(
      id: 'anxiety_1',
      title: 'Ease Anxiety',
      description: 'Gentle techniques to soothe anxious thoughts',
      durationMinutes: 10,
      category: MeditationCategory.anxiety,
    ),
    MeditationSession(
      id: 'anxiety_2',
      title: 'Grounding Practice',
      description: 'Come back to the present moment',
      durationMinutes: 8,
      category: MeditationCategory.anxiety,
    ),
    MeditationSession(
      id: 'anxiety_3',
      title: 'Worry Release',
      description: 'Let go of worries and find calm',
      durationMinutes: 15,
      category: MeditationCategory.anxiety,
      isPremium: true,
    ),
    MeditationSession(
      id: 'anxiety_4',
      title: 'Panic Relief',
      description: 'Quick help during moments of panic',
      durationMinutes: 5,
      category: MeditationCategory.anxiety,
    ),

    // Sleep
    MeditationSession(
      id: 'sleep_1',
      title: 'Sleepy Time',
      description: 'Drift off to peaceful sleep',
      durationMinutes: 20,
      category: MeditationCategory.sleep,
    ),
    MeditationSession(
      id: 'sleep_2',
      title: 'Body Scan for Sleep',
      description: 'Relax every part of your body',
      durationMinutes: 15,
      category: MeditationCategory.sleep,
    ),
    MeditationSession(
      id: 'sleep_3',
      title: 'Moonlight Journey',
      description: 'A guided visualization for deep sleep',
      durationMinutes: 30,
      category: MeditationCategory.sleep,
      isPremium: true,
    ),
    MeditationSession(
      id: 'sleep_4',
      title: 'Quick Wind Down',
      description: 'Short session to prepare for rest',
      durationMinutes: 10,
      category: MeditationCategory.sleep,
    ),

    // Focus
    MeditationSession(
      id: 'focus_1',
      title: 'Sharpen Focus',
      description: 'Train your attention and concentration',
      durationMinutes: 10,
      category: MeditationCategory.focus,
    ),
    MeditationSession(
      id: 'focus_2',
      title: 'Work Flow',
      description: 'Get into the zone for productivity',
      durationMinutes: 15,
      category: MeditationCategory.focus,
    ),
    MeditationSession(
      id: 'focus_3',
      title: 'Deep Concentration',
      description: 'Extended session for laser focus',
      durationMinutes: 25,
      category: MeditationCategory.focus,
      isPremium: true,
    ),
    MeditationSession(
      id: 'focus_4',
      title: 'Quick Reset',
      description: 'Brief mental refresh between tasks',
      durationMinutes: 5,
      category: MeditationCategory.focus,
    ),

    // Relationships
    MeditationSession(
      id: 'rel_1',
      title: 'Loving Kindness',
      description: 'Cultivate compassion for yourself and others',
      durationMinutes: 10,
      category: MeditationCategory.relationships,
    ),
    MeditationSession(
      id: 'rel_2',
      title: 'Forgiveness',
      description: 'Let go of resentment and find peace',
      durationMinutes: 15,
      category: MeditationCategory.relationships,
      isPremium: true,
    ),
    MeditationSession(
      id: 'rel_3',
      title: 'Connection',
      description: 'Strengthen bonds with loved ones',
      durationMinutes: 12,
      category: MeditationCategory.relationships,
    ),
    MeditationSession(
      id: 'rel_4',
      title: 'Gratitude Practice',
      description: 'Appreciate the people in your life',
      durationMinutes: 8,
      category: MeditationCategory.relationships,
    ),

    // Self-Esteem
    MeditationSession(
      id: 'self_1',
      title: 'Self-Compassion',
      description: 'Be kind to yourself',
      durationMinutes: 10,
      category: MeditationCategory.selfEsteem,
    ),
    MeditationSession(
      id: 'self_2',
      title: 'Inner Confidence',
      description: 'Build unshakeable self-belief',
      durationMinutes: 15,
      category: MeditationCategory.selfEsteem,
      isPremium: true,
    ),
    MeditationSession(
      id: 'self_3',
      title: 'Embrace Yourself',
      description: 'Accept and love who you are',
      durationMinutes: 12,
      category: MeditationCategory.selfEsteem,
    ),
    MeditationSession(
      id: 'self_4',
      title: 'Positive Affirmations',
      description: 'Reinforce positive self-image',
      durationMinutes: 8,
      category: MeditationCategory.selfEsteem,
      isPremium: true,
    ),
  ];

  static List<MeditationSession> getMeditationsByCategory(MeditationCategory category) {
    return allMeditations.where((m) => m.category == category).toList();
  }

  static MeditationSession? getFeaturedMeditation() {
    return allMeditations.firstWhere(
      (m) => !m.isPremium,
      orElse: () => allMeditations.first,
    );
  }

  static const List<SleepStory> sleepStories = [
    SleepStory(
      id: 'story_1',
      title: 'The Enchanted Forest',
      narrator: 'Sarah',
      durationMinutes: 25,
    ),
    SleepStory(
      id: 'story_2',
      title: 'Ocean Voyage',
      narrator: 'Michael',
      durationMinutes: 30,
      isPremium: true,
    ),
    SleepStory(
      id: 'story_3',
      title: 'Mountain Retreat',
      narrator: 'Emma',
      durationMinutes: 20,
    ),
    SleepStory(
      id: 'story_4',
      title: 'Starlight Dreams',
      narrator: 'James',
      durationMinutes: 35,
      isPremium: true,
    ),
  ];

  static const List<Soundscape> soundscapes = [
    Soundscape(
      id: 'sound_1',
      title: 'Rain',
      icon: '🌧️',
    ),
    Soundscape(
      id: 'sound_2',
      title: 'Ocean',
      icon: '🌊',
    ),
    Soundscape(
      id: 'sound_3',
      title: 'Forest',
      icon: '🌲',
      isPremium: true,
    ),
  ];

  static const List<BreathingExercise> breathingExercises = [
    BreathingExercise(
      id: 'breath_1',
      title: '4-7-8 Breathing',
      description: 'Inhale 4s, hold 7s, exhale 8s',
      durationMinutes: 5,
    ),
    BreathingExercise(
      id: 'breath_2',
      title: 'Box Breathing',
      description: 'Equal inhale, hold, exhale, hold',
      durationMinutes: 5,
    ),
    BreathingExercise(
      id: 'breath_3',
      title: 'Deep Belly Breathing',
      description: 'Slow, deep diaphragmatic breaths',
      durationMinutes: 10,
    ),
  ];
}
