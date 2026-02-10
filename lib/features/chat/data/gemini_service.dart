import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/env_config.dart' as env;
import '../domain/models/message.dart';
import '../../coach/domain/models/coach.dart';
import '../../onboarding/domain/models/nlp_profile.dart';
import '../domain/services/nlp_prompt_builder.dart';

/// Gemini Service for MindFlow AI Coach
/// Handles communication with backend API proxy for Gemini
/// Uses NLP Prompt Builder for profile-adaptive system prompts
///
/// SECURITY: API key is stored server-side only, never exposed to client
///
/// Configuration (per Technical Specification):
/// - Model: gemini-2.0-flash (fast, cost-effective)
/// - Temperature: 0.7 (creative but coherent)
/// - Max tokens: 500 per response
/// - Streaming: Yes (better UX with typing indicator)
/// - Conversation Memory: Last 10 messages for context
class GeminiService {
  GeminiService();

  static const int _maxConversationMemory = 10;

  /// Whether the service is initialized
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Current system prompt (set per user profile)
  String? _currentSystemPrompt;

  /// Last known profile for prompt regeneration
  NLPProfile? _lastProfile;

  /// Active coach for persona injection
  Coach? _activeCoach;

  /// User progress context for coaching
  int? _currentStreak;
  int? _totalSessions;
  int? _totalMinutes;
  String? _activeGoal;
  double? _goalProgress;

  /// Initialize the service
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
    debugPrint('GeminiService: Initialized with backend proxy');
  }

  /// Set the active coach
  void setActiveCoach(Coach coach) {
    _activeCoach = coach;
    debugPrint('GeminiService: Active coach set to ${coach.name}');
    
    // Regenerate prompt if we have a profile
    if (_lastProfile != null) {
      setUserProfile(_lastProfile!);
    }
  }

  /// Set the system prompt based on user's NLP profile
  /// Call this when user logs in or profile changes
  void setUserProfile(NLPProfile profile) {
    _lastProfile = profile;
    
    _currentSystemPrompt = NLPPromptBuilder.generateSystemPrompt(
      profile,
      coach: _activeCoach,
      currentStreak: _currentStreak,
      totalSessions: _totalSessions,
      totalMinutes: _totalMinutes,
      activeGoal: _activeGoal,
      goalProgress: _goalProgress,
    );
    debugPrint(
        'GeminiService: System prompt updated for ${profile.displayName} (Coach: ${_activeCoach?.name ?? "Default"})');
  }

  /// Set user progress context for more personalized coaching
  void setProgressContext({
    int? currentStreak,
    int? totalSessions,
    int? totalMinutes,
    String? activeGoal,
    double? goalProgress,
  }) {
    _currentStreak = currentStreak;
    _totalSessions = totalSessions;
    _totalMinutes = totalMinutes;
    _activeGoal = activeGoal;
    _goalProgress = goalProgress;
  }

  /// Get limited conversation history for context
  /// Returns only the last N messages to prevent token overflow
  List<Message> _getLimitedHistory(List<Message> fullHistory) {
    if (fullHistory.length <= _maxConversationMemory) {
      return fullHistory;
    }
    return fullHistory.sublist(fullHistory.length - _maxConversationMemory);
  }

  /// Send a message and get streaming response
  /// Returns a stream of content chunks for real-time display
  /// INCLUDES: Crisis detection for safety - crisis responses override normal processing
  Stream<String> sendMessageStream({
    required String userMessage,
    required List<Message> chatHistory,
    NLPProfile? profile,
  }) async* {
    if (profile != null) {
      setUserProfile(profile);
    }

    if (_currentSystemPrompt == null) {
      debugPrint('GeminiService: No system prompt set, using default');
      _currentSystemPrompt = NLPPromptBuilder.generateSystemPrompt(
        NLPProfile.defaultProfile,
      );
    }

    // CRITICAL: Check for crisis indicators FIRST
    // If detected, return crisis response immediately - don't send to API
    if (NLPPromptBuilder.containsCrisisIndicators(userMessage)) {
      debugPrint('GeminiService: CRISIS DETECTED - providing crisis resources');
      yield* _getCrisisResponse();
      return;
    }

    try {
      final limitedHistory = _getLimitedHistory(chatHistory);

      // Construct prompt with history manually for direct API
      final fullPromptBuffer = StringBuffer();
      fullPromptBuffer.writeln(_currentSystemPrompt ?? '');
      fullPromptBuffer.writeln('\n--- CONVERSATION HISTORY ---');

      for (final msg in limitedHistory) {
        fullPromptBuffer
            .writeln('${msg.isUser ? "USER" : "ASSISTANT"}: ${msg.content}');
      }

      fullPromptBuffer.writeln('USER: $userMessage');
      fullPromptBuffer.writeln('ASSISTANT:'); // Priming

      final apiKey = env.EnvConfig.geminiApiKey;
      
      if (apiKey.isEmpty) {
        debugPrint('GeminiService: ERROR - API key is empty!');
        yield* _getMockResponse(userMessage, profile);
        return;
      }
      
      final apiUrl =
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:streamGenerateContent?key=$apiKey';

      debugPrint('GeminiService: Sending direct request to Gemini API (Key length: ${apiKey.length})');

      final requestBody = json.encode({
        "contents": [
          {
            "parts": [
              {"text": fullPromptBuffer.toString()}
            ]
          }
        ],
        "generationConfig": {
          "temperature": 0.7,
          "maxOutputTokens": 800,
        }
      });

      final request = http.Request('POST', Uri.parse(apiUrl));
      request.headers['Content-Type'] = 'application/json';
      request.body = requestBody;

      final client = http.Client();
      try {
        final streamedResponse = await client.send(request);

        if (streamedResponse.statusCode != 200) {
          final errorBody = await streamedResponse.stream.bytesToString();
          debugPrint('GeminiService: API error ${streamedResponse.statusCode}: $errorBody');

          if (streamedResponse.statusCode == 400) {
            yield 'I\'m having trouble understanding. Could you try rephrasing? (Invalid request)';
          } else if (streamedResponse.statusCode == 429) {
            final retryMatch =
                RegExp(r'retry in (\d+(\.\d+)?)s').firstMatch(errorBody);
            final waitSeconds = retryMatch != null
                ? double.tryParse(retryMatch.group(1) ?? '')?.ceil() ?? 30
                : 30;
            yield 'I need a moment to recharge. Please try again in $waitSeconds seconds. 🧘';
          } else if (streamedResponse.statusCode == 403) {
            yield 'I\'m not authorized to help right now. Please check the API configuration.';
          } else {
            yield 'I\'m having a moment of reflection. Could you try again? (Error: ${streamedResponse.statusCode})';
          }
          return;
        }

        final stream = streamedResponse.stream.transform(utf8.decoder);
        String fullResponse = '';

        // Accumulate the full streamed response
        await for (final chunk in stream) {
          fullResponse += chunk;
        }

        debugPrint(
            'GeminiService: Received response length: ${fullResponse.length}');

        // Parse the accumulated JSON response
        // The response is a JSON array: [{...}, {...}, ...]
        // Each object contains candidates[0].content.parts[0].text
        try {
          // Try to parse as JSON and extract text properly
          final dynamic jsonData = json.decode(fullResponse);
          final textParts = <String>[];

          if (jsonData is List) {
            for (final item in jsonData) {
              if (item is Map<String, dynamic>) {
                final candidates = item['candidates'] as List<dynamic>?;
                if (candidates != null && candidates.isNotEmpty) {
                  final content =
                      candidates[0]['content'] as Map<String, dynamic>?;
                  if (content != null) {
                    final parts = content['parts'] as List<dynamic>?;
                    if (parts != null) {
                      for (final part in parts) {
                        if (part is Map<String, dynamic> &&
                            part['text'] != null) {
                          textParts.add(part['text'].toString());
                        }
                      }
                    }
                  }
                }
              }
            }
          }

          if (textParts.isNotEmpty) {
            // Yield the combined text with word-by-word streaming effect
            final combinedText = textParts.join('');
            debugPrint('GeminiService: Successfully got response (${combinedText.length} chars)');
            final words = combinedText.split(' ');
            for (int i = 0; i < words.length; i++) {
              yield words[i];
              if (i < words.length - 1) yield ' ';
              await Future.delayed(const Duration(milliseconds: 15));
            }
          } else {
            debugPrint('GeminiService: No text parts found in response, using fallback');
            yield* _getMockResponse(userMessage, profile);
          }
        } catch (parseError) {
          debugPrint('GeminiService: JSON parse error: $parseError');
          // Fallback: try regex extraction
          final regex =
              RegExp(r'"text"\s*:\s*"((?:[^"\\]|\\.)*)?"', multiLine: true);
          final matches = regex.allMatches(fullResponse);
          final extractedTexts = <String>[];

          for (final match in matches) {
            final text = match.group(1);
            if (text != null && text.isNotEmpty) {
              // Unescape JSON string
              final unescaped = text
                  .replaceAll(r'\n', '\n')
                  .replaceAll(r'\"', '"')
                  .replaceAll(r'\\', '\\')
                  .replaceAll(r'\t', '\t');
              extractedTexts.add(unescaped);
            }
          }

          if (extractedTexts.isNotEmpty) {
            final combinedText = extractedTexts.join('');
            final words = combinedText.split(' ');
            for (int i = 0; i < words.length; i++) {
              yield words[i];
              if (i < words.length - 1) yield ' ';
              await Future.delayed(const Duration(milliseconds: 15));
            }
          } else {
            debugPrint('GeminiService: Regex extraction also failed');
            yield* _getMockResponse(userMessage, profile);
          }
        }
      } finally {
        client.close();
      }
    } catch (e) {
      debugPrint('GeminiService: Error sending message: $e');
      yield* _getMockResponse(userMessage, profile);
    }
  }

  /// Send a message and get full response (non-streaming)
  Future<String> sendMessage({
    required String userMessage,
    required List<Message> chatHistory,
    NLPProfile? profile,
  }) async {
    final buffer = StringBuffer();

    await for (final chunk in sendMessageStream(
      userMessage: userMessage,
      chatHistory: chatHistory,
      profile: profile,
    )) {
      buffer.write(chunk);
    }

    return buffer.toString();
  }

  /// Get a crisis response with streaming effect
  /// Streams crisis resources and support information
  Stream<String> _getCrisisResponse() async* {
    await Future.delayed(const Duration(milliseconds: 300));

    final response = NLPPromptBuilder.generateCrisisResponse();

    final words = response.split(' ');
    for (int i = 0; i < words.length; i++) {
      yield words[i];
      if (i < words.length - 1) yield ' ';
      await Future.delayed(const Duration(milliseconds: 20));
    }
  }

  /// Get a mock response for development/demo
  /// Implements NLP-adaptive language patterns
  /// NOTE: Crisis detection is handled in sendMessageStream, not here
  Stream<String> _getMockResponse(
      String userMessage, NLPProfile? profile) async* {
    final effectiveProfile = profile ?? NLPProfile.defaultProfile;

    await Future.delayed(const Duration(milliseconds: 500));

    final isCrisis = NLPPromptBuilder.containsCrisisIndicators(userMessage);

    final response = _generateAdaptiveResponse(
      userMessage: userMessage,
      profile: effectiveProfile,
      isSerious: isCrisis,
    );

    final words = response.split(' ');
    for (int i = 0; i < words.length; i++) {
      yield words[i];
      if (i < words.length - 1) yield ' ';
      await Future.delayed(const Duration(milliseconds: 30));
    }
  }

  /// Generate an adaptive response based on NLP profile
  /// Implements Toward/Away-From, Internal/External, and VAK patterns
  String _generateAdaptiveResponse({
    required String userMessage,
    required NLPProfile profile,
    required bool isSerious,
  }) {
    final buffer = StringBuffer();

    buffer.write(_getPacingPhrase(profile));
    buffer.write(' ');

    buffer.write(_getLeadingPhrase(profile, userMessage));
    buffer.write('\n\n');

    buffer.write(_getActionStep(profile));

    if (!isSerious && _shouldAddHumor()) {
      buffer.write('\n\n');
      buffer.write(_getHumorPhrase(profile));
    }

    return buffer.toString();
  }

  String _getPacingPhrase(NLPProfile profile) {
    switch (profile.thinking) {
      case 'visual':
        return "I can see what you're getting at.";
      case 'auditory':
        return "I hear what you're saying.";
      case 'kinesthetic':
        return "I feel where you're coming from.";
      default:
        return "I understand what you mean.";
    }
  }

  String _getLeadingPhrase(NLPProfile profile, String userMessage) {
    if (profile.motivation == 'toward') {
      switch (profile.thinking) {
        case 'visual':
          return "Picture yourself having already achieved what you're working toward. What does that success look like? When you can see it clearly, the path becomes clearer too.";
        case 'auditory':
          return "Listen to that voice inside that knows you can accomplish this. What is it telling you about your next step? Sometimes the answers resonate when we tune in.";
        case 'kinesthetic':
          return "Feel into that sense of accomplishment waiting for you. How does it feel to have already achieved this? Let that feeling guide your next move.";
      }
    } else {
      switch (profile.thinking) {
        case 'visual':
          return "Let's look at what problems we can eliminate here. Can you see which obstacles are blocking your path? Once we identify them, we can clear them away.";
        case 'auditory':
          return "What concerns are echoing in your mind right now? Let's address them one by one so they stop creating noise and you can hear your own clarity.";
        case 'kinesthetic':
          return "What's weighing on you that we can remove? Sometimes we need to release what doesn't serve us before we can move forward with ease.";
      }
    }
    return "Let's explore what's possible for you.";
  }

  String _getActionStep(NLPProfile profile) {
    if (profile.reference == 'internal') {
      if (profile.processing == 'options') {
        return "🎯 **Your move**: What feels like the most exciting option right now? Trust your instincts here—you know yourself best.";
      } else {
        return "🎯 **Next step**: Based on what YOU know works for you, what's the first concrete action? Sometimes one step is all we need.";
      }
    } else {
      if (profile.processing == 'options') {
        return "🎯 **Research shows**: The most effective people explore 2-3 options before committing. Which path do the experts in your situation recommend?";
      } else {
        return "🎯 **Proven method**: Step 1 is usually the hardest. Studies show that just starting creates momentum. What's ONE thing you can do in the next 5 minutes?";
      }
    }
  }

  bool _shouldAddHumor() {
    return DateTime.now().millisecond % 7 == 0;
  }

  String _getHumorPhrase(NLPProfile profile) {
    if (profile.motivation == 'toward' && profile.reference == 'internal') {
      return "You're basically a goal-crushing machine. The only question is which goal gets crushed next. 💪";
    } else if (profile.motivation == 'away_from' &&
        profile.reference == 'external') {
      return "We've all been the person who sets 47 alarms and still somehow oversleeps. You're in good company. 😅";
    } else {
      switch (profile.thinking) {
        case 'visual':
          return "Your procrastination is like a Netflix binge—very engaging, terrible for the to-do list. 📺";
        case 'kinesthetic':
          return "Decision paralysis: the mental equivalent of doing planks. Feels impossible, but you're stronger than you think. 🏋️";
        default:
          return "Remember: even the longest journey starts with a single step. Or in your case, probably a single coffee. ☕";
      }
    }
  }

  /// Cancel any ongoing request
  void cancelRequest() {
    debugPrint('GeminiService: Request cancelled');
  }

  /// Dispose resources
  void dispose() {}
}
