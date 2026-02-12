import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../../features/subscription/data/revenuecat_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  final FirebaseFirestore? _firestore;

  ApiService._internal() : _firestore = _initFirestore();

  static FirebaseFirestore? _initFirestore() {
    try {
      if (Firebase.apps.isNotEmpty) {
        return FirebaseFirestore.instance;
      }
    } catch (e) {
      debugPrint('ApiService: Firebase not initialized: $e');
    }
    return null;
  }

  /// Create or update user in Firestore
  Future<Map<String, dynamic>> createUser(String id, String email) async {
    if (_firestore == null) {
      debugPrint(
          'ApiService: Offline/No-Firebase mode. Simulation user creation.');
      return {'id': id, 'email': email};
    }

    try {
      final userRef = _firestore.collection('users').doc(id);
      final userData = {
        'id': id,
        'email': email,
        'lastActive': FieldValue.serverTimestamp(),
        // Merge true so we don't overwrite existing fields if user exists
      };

      await userRef.set(userData, SetOptions(merge: true));
      return userData;
    } catch (e) {
      debugPrint('ApiService: Error creating user in Firestore: $e');
      // Fallback/Silent fail for offline support
      return {'id': id, 'email': email};
    }
  }

  /// Get available products (Deferred to RevenueCat)
  Future<List<Map<String, dynamic>>> getProducts() async {
    // We strictly use RevenueCat for products in this MVP
    return [];
  }

  /// Create checkout session
  /// (Deprecated in favor of in-app purchases via RevenueCat)
  Future<String?> createCheckoutSession({
    required String priceId,
    String? userId,
    String? email,
    String? successUrl,
    String? cancelUrl,
  }) async {
    debugPrint('ApiService: Checkout session requested but we use RevenueCat.');
    return null;
  }

  /// Get subscription status
  /// (Primarily handled by RevenueCat, but we can store a cached status in Firestore)
  Future<Map<String, dynamic>> getSubscription(String userId) async {
    try {
      // 1. Check RevenueCat first (Source of Truth)
      final isPro = await RevenueCatService.instance.checkProStatus();

      // 2. Update Firestore for backend visibility
      if (_firestore != null) {
        await _firestore.collection('users').doc(userId).set({
          'isPro': isPro,
          'lastCheck': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      return {'isPro': isPro};
    } catch (e) {
      debugPrint('ApiService: Error checking subscription: $e');
      return {'isPro': false};
    }
  }

  /// Log a session to Firestore
  Future<void> logSession(
      String userId, Map<String, dynamic> sessionData) async {
    if (_firestore == null) return;
    try {
      await _firestore.collection('sessions').add({
        'userId': userId,
        ...sessionData,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('ApiService: Error logging session: $e');
    }
  }

  /// Get aggregated progress from Firestore
  Future<Map<String, dynamic>> getProgress(String userId) async {
    // If offline, return empty so provider falls back to local storage
    if (_firestore == null) {
      return {};
    }

    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        return {
          'totalMinutes': data['totalMinutes'] ?? 0,
          'currentStreak': data['currentStreak'] ?? 0,
          'sessionsCompleted': data['sessionsCompleted'] ?? 0,
        };
      }
      return {
        'totalMinutes': 0,
        'currentStreak': 0,
        'sessionsCompleted': 0,
      };
    } catch (e) {
      debugPrint('ApiService: Error fetching progress from Firestore: $e');
      return {};
    }
  }
}
