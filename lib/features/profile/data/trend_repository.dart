import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/models/personality_trend.dart';

class TrendRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveTrend(String uid, PersonalityTrend trend) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('trends')
        .add(trend.toJson());
  }

  Future<List<PersonalityTrend>> getTrends(String uid) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('trends')
        .orderBy('timestamp', descending: true)
        .limit(20) // Limit to last 20 points for chart clarity
        .get();

    return snapshot.docs
        .map((doc) => PersonalityTrend.fromJson(doc.data()))
        .toList();
  }
}
