import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String get _baseUrl {
    if (kIsWeb) {
      return '';
    }
    return 'http://localhost:3000';
  }

  Future<Map<String, dynamic>> createUser(String id, String email) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/users'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id, 'email': email}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['user'];
    } else {
      throw Exception('Failed to create user: ${response.body}');
    }
  }

  Future<List<Map<String, dynamic>>> getProducts() async {
    final response = await http.get(Uri.parse('$_baseUrl/api/products'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['data'] ?? []);
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

  Future<Map<String, dynamic>?> getSubscription(String userId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/subscription?userId=$userId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['subscription'];
    } else {
      throw Exception('Failed to fetch subscription: ${response.body}');
    }
  }

  Future<void> logSession({
    required String userId,
    required String meditationId,
    required int durationSeconds,
  }) async {
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
    final response = await http.get(
      Uri.parse('$_baseUrl/api/progress/$userId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'totalMinutes': data['progress']?['totalMinutes'] ?? 0,
        'currentStreak': data['progress']?['currentStreak'] ?? 0,
        'longestStreak': data['progress']?['longestStreak'] ?? 0,
        'sessionsCompleted': (data['recentSessions'] as List?)?.length ?? 0,
        'recentSessions': data['recentSessions'] ?? [],
      };
    } else {
      throw Exception('Failed to fetch progress: ${response.body}');
    }
  }
}
