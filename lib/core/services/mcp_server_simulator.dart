import 'package:mindflow_ai_coach/core/services/mcp_client_service.dart';

/// **MCP Server Simulator**
///
/// **The Story:** Since the actual MCP server is a separate process (Python/Dart),
/// we need a way to test the client without running a real server. This simulator
/// acts as a lightweight in-memory MCP server for development and testing.
///
/// **Use Case:** Local testing, unit tests, demo mode
///
/// **In Production:** Replace this with actual HTTP server
class MCPServerSimulator {
  // In-memory pattern storage (simulated database)
  final Map<String, List<BehavioralPattern>> _patternStore = {};

  // User retention policies (days)
  final Map<String, int> _retentionPolicies = {};

  /// Stores a pattern
  Future<void> storePattern(BehavioralPattern pattern, String userId) async {
    await Future.delayed(const Duration(milliseconds: 50)); // Simulate network

    _patternStore.putIfAbsent(userId, () => []).add(pattern);
  }

  /// Queries patterns for a user
  Future<List<BehavioralPattern>> queryPatterns({
    required String userId,
    required PatternType patternType,
  }) async {
    await Future.delayed(const Duration(milliseconds: 50)); // Simulate network

    final userPatterns = _patternStore[userId] ?? [];
    return userPatterns.where((p) => p.type == patternType).toList();
  }

  /// Deletes all patterns for a user (GDPR erasure)
  Future<void> deleteAllPatterns(String userId) async {
    await Future.delayed(const Duration(milliseconds: 50));

    _patternStore.remove(userId);
    _retentionPolicies.remove(userId);
  }

  /// Updates retention policy
  Future<void> updateRetention(String userId, int days) async {
    await Future.delayed(const Duration(milliseconds: 50));

    _retentionPolicies[userId] = days;
  }

  /// Health check
  Future<bool> isHealthy() async {
    return true; // Always healthy in simulator
  }

  /// Gets total patterns stored
  int get totalPatterns {
    int count = 0;
    _patternStore.forEach((_, patterns) => count += patterns.length);
    return count;
  }

  /// Clears all data (for testing)
  void clearAll() {
    _patternStore.clear();
    _retentionPolicies.clear();
  }
}

// =============================================================================
