import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String get _baseUrl {
    if (kIsWeb) {
      return ''; // Indicates no backend on web for this MVP
    }
    return 'http://localhost:3000';
  }

  bool get _shouldMock {
    // FORCE MOCK FOR MOBILE MVP
    // Server backend is not reachable from mobile without deployment/network config.
    // We rely on local persistence and RevenueCat for MVP.
    return true; 
  }

  Future<Map<String, dynamic>> createUser(String id, String email) async {
    if (_shouldMock) {
      // Mock successful user creation
      return {
        'id': id,
        'email': email,
        'createdAt': DateTime.now().toIso8601String()
      };
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/api/users'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id, 'email': email}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create user: ${response.body}');
    }
  }

  Future<List<Map<String, dynamic>>> getProducts() async {
    if (_shouldMock) {
      // Mock products
      return [];
    }

    final response = await http.get(Uri.parse('$_baseUrl/api/products'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['products'] ?? []);
    } else {
      throw Exception('Failed to fetch products: ${response.body}');
    }
  }

  Future<String?> createCheckoutSession({
    required String priceId,
    String? userId,
    String? email,
    String? successUrl,
    String? cancelUrl,
  }) async {
    if (_shouldMock) {
      return null;
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/api/checkout'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'priceId': priceId,
        'userId': userId,
        'email': email,
        'successUrl': successUrl,
        'cancelUrl': cancelUrl,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['url'];
    } else {
      throw Exception('Failed to create checkout session: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getSubscription(String userId) async {
    if (_shouldMock) {
      // Mock no active subscription for free user
      return {'status': 'none'};
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/api/subscription/$userId'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch subscription: ${response.body}');
    }
  }

  Future<void> logSession({
    required String userId,
    required String meditationId,
    required int durationSeconds,
  }) async {
    if (_shouldMock) {
      return; // Successfully "logged" locally
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/api/sessions'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'meditationId': meditationId,
        'durationSeconds': durationSeconds,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to log session: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getProgress(String userId) async {
    if (_shouldMock) {
      // Return empty progress, reliance is on local storage in UserProvider
      return {
        'totalMinutes': 0,
        'currentStreak': 0,
        'sessionsCompleted': 0,
      };
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/api/progress/$userId'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch progress: ${response.body}');
    }
  }
}
