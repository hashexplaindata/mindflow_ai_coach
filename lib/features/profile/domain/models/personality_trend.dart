import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../identity/domain/models/personality_vector.dart';

class PersonalityTrend {
  final DateTime timestamp;
  final PersonalityVector vector;
  final String reason;

  const PersonalityTrend({
    required this.timestamp,
    required this.vector,
    required this.reason,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': Timestamp.fromDate(timestamp),
      'vector': vector.toJson(),
      'reason': reason,
    };
  }

  factory PersonalityTrend.fromJson(Map<String, dynamic> json) {
    return PersonalityTrend(
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      vector:
          PersonalityVector.fromJson(json['vector'] as Map<String, dynamic>),
      reason: json['reason'] as String? ?? 'Unknown Update',
    );
  }
}
