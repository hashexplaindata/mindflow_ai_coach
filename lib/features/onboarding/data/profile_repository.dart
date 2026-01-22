// import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/models/nlp_profile.dart';

/// User Profile Repository
/// Handles persistence of user profile and NLP data to Firestore
/// 
/// Firestore structure:
/// users/{userId}/
///   - email: string
///   - name: string
///   - createdAt: timestamp
///   - isPro: boolean
///   - nlpProfile: {
///       motivation: 'toward' | 'away_from'
///       reference: 'internal' | 'external'
///       thinking: 'visual' | 'auditory' | 'kinesthetic'
///       processing: 'options' | 'procedures'
///       change: 'sameness' | 'difference'
///     }
class UserProfileRepository {
  // TODO: Uncomment when Firebase is configured
  // final FirebaseFirestore _firestore;
  // 
  // UserProfileRepository({FirebaseFirestore? firestore})
  //     : _firestore = firestore ?? FirebaseFirestore.instance;

  UserProfileRepository();

  /// Collection reference for users
  // CollectionReference<Map<String, dynamic>> get _usersCollection =>
  //     _firestore.collection('users');

  /// Save NLP profile for a user
  /// Called after completing onboarding
  Future<void> saveNLPProfile({
    required String userId,
    required NLPProfile profile,
  }) async {
    try {
      // TODO: Uncomment when Firebase is configured
      // await _usersCollection.doc(userId).set({
      //   'nlpProfile': profile.toMap(),
      //   'hasCompletedOnboarding': true,
      //   'updatedAt': FieldValue.serverTimestamp(),
      // }, SetOptions(merge: true));
      
      print('UserProfileRepository: Saved NLP profile for $userId');
      print('Profile: ${profile.toMap()}');
    } catch (e) {
      print('UserProfileRepository: Error saving profile: $e');
      rethrow;
    }
  }

  /// Get NLP profile for a user
  Future<NLPProfile?> getNLPProfile(String userId) async {
    try {
      // TODO: Uncomment when Firebase is configured
      // final doc = await _usersCollection.doc(userId).get();
      // 
      // if (!doc.exists) return null;
      // 
      // final data = doc.data();
      // if (data == null || data['nlpProfile'] == null) return null;
      // 
      // return NLPProfile.fromMap(data['nlpProfile'] as Map<String, dynamic>);
      
      // For development: return default profile
      return NLPProfile.defaultProfile;
    } catch (e) {
      print('UserProfileRepository: Error getting profile: $e');
      return null;
    }
  }

  /// Check if user has completed onboarding
  Future<bool> hasCompletedOnboarding(String userId) async {
    try {
      // TODO: Uncomment when Firebase is configured
      // final doc = await _usersCollection.doc(userId).get();
      // 
      // if (!doc.exists) return false;
      // 
      // final data = doc.data();
      // return data?['hasCompletedOnboarding'] == true;
      
      return false;
    } catch (e) {
      print('UserProfileRepository: Error checking onboarding: $e');
      return false;
    }
  }

  /// Create initial user document after signup
  Future<void> createUserProfile({
    required String userId,
    required String email,
    String? displayName,
  }) async {
    try {
      // TODO: Uncomment when Firebase is configured
      // await _usersCollection.doc(userId).set({
      //   'email': email,
      //   'name': displayName,
      //   'createdAt': FieldValue.serverTimestamp(),
      //   'isPro': false,
      //   'hasCompletedOnboarding': false,
      // }, SetOptions(merge: true));
      
      print('UserProfileRepository: Created user profile for $userId');
    } catch (e) {
      print('UserProfileRepository: Error creating profile: $e');
      rethrow;
    }
  }

  /// Update Pro status (called by RevenueCat sync)
  Future<void> updateProStatus({
    required String userId,
    required bool isPro,
  }) async {
    try {
      // TODO: Uncomment when Firebase is configured
      // await _usersCollection.doc(userId).update({
      //   'isPro': isPro,
      //   'updatedAt': FieldValue.serverTimestamp(),
      // });
      
      print('UserProfileRepository: Updated Pro status for $userId: $isPro');
    } catch (e) {
      print('UserProfileRepository: Error updating Pro status: $e');
      rethrow;
    }
  }

  /// Get daily chat count for free tier limiting
  Future<int> getDailyChatCount(String userId) async {
    try {
      // TODO: Uncomment when Firebase is configured
      // final today = DateTime.now();
      // final dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      // 
      // final doc = await _usersCollection
      //     .doc(userId)
      //     .collection('dailyChats')
      //     .doc(dateStr)
      //     .get();
      // 
      // if (!doc.exists) return 0;
      // 
      // return (doc.data()?['count'] as int?) ?? 0;
      
      return 0;
    } catch (e) {
      print('UserProfileRepository: Error getting daily chat count: $e');
      return 0;
    }
  }

  /// Increment daily chat count
  Future<void> incrementDailyChatCount(String userId) async {
    try {
      // TODO: Uncomment when Firebase is configured
      // final today = DateTime.now();
      // final dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      // 
      // await _usersCollection
      //     .doc(userId)
      //     .collection('dailyChats')
      //     .doc(dateStr)
      //     .set({
      //       'count': FieldValue.increment(1),
      //       'lastUpdated': FieldValue.serverTimestamp(),
      //     }, SetOptions(merge: true));
      
      print('UserProfileRepository: Incremented daily chat count for $userId');
    } catch (e) {
      print('UserProfileRepository: Error incrementing chat count: $e');
      rethrow;
    }
  }
}
