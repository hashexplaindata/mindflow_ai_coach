import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import '../../onboarding/domain/models/nlp_profile.dart'; // Reusing this for vector for now or creating new

/// The bridge to the "Core Weapon" (Genkit Backend)
class GenkitService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<String> generateCoachingResponse({
    required String message,
    required bool isPro,
    Map<String, double>? personalityVector,
    String? context,
  }) async {
    try {
      final result = await _functions.httpsCallable('coachingFlow').call({
        'message': message,
        'isPro': isPro,
        'personalityVector': personalityVector,
        'context': context,
      });

      final data = result.data as Map<String, dynamic>;
      final text = data['text'] as String;
      final breakthrough = data['breakthroughDetected'] as bool? ?? false;

      if (breakthrough) {
        debugPrint('GenkitService: Breakthrough detected by backend!');
        // Potentially notify provider to save artifact
      }

      return text;
    } catch (e) {
      debugPrint('GenkitService Error: $e');
      // Fallback or rethrow?
      // For now, return a safe fallback if backend fails (e.g. offline)
      if (e.toString().contains('offline')) {
        return "I'm having trouble connecting to my brain. Please check your connection.";
      }
      rethrow;
    }
  }
}
