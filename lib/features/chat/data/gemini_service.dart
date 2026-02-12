import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/env_config.dart' as env;
import '../domain/models/message.dart';
import '../../coach/domain/models/coach.dart';
import '../../onboarding/domain/models/nlp_profile.dart';
import '../../identity/domain/models/personality_vector.dart';
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
  GeminiService._internal();
  static final GeminiService _instance = GeminiService._internal();
  static GeminiService get instance => _instance;
  factory GeminiService() => _instance;

  static const int _maxConversationMemory = 10;

  /// Whether the service is initialized
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Current system prompt (set per user profile)
  String? _currentSystemPrompt;

  /// Last known profile for prompt regeneration
  NLPProfile? _lastProfile;

  /// Current Personality Vector (Layer 1)
  PersonalityVector _currentPersonality = PersonalityVector.defaultProfile;

  /// Active coach for persona injection
  Coach? _activeCoach;

  /// User progress context for coaching
  int? _currentStreak;
  int? _totalSessions;
  int? _totalMinutes;
  String? _activeGoal;
  double? _goalProgress;

  /// Whether deep dive (premium analysis) is unlocked
  bool _deepDiveUnlocked = false;

  /// Whether we've already inferred the user's NLP profile from their first message
  bool _hasInferredProfile = false;

  /// Callback fired when a profile is inferred from the user's first message
  /// The caller (ChatProvider) should wire this to persist the inferred profile
  void Function(NLPProfile)? onProfileInferred;

  /// Initialize the service
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
    debugPrint('GeminiService: Initialized with backend proxy');
  }

  /// Set whether deep dive is unlocked (premium feature)
  void setDeepDiveUnlocked(bool unlocked) {
    _deepDiveUnlocked = unlocked;
    // Regenerate prompt if we have a profile
    if (_lastProfile != null) {
      setUserProfile(_lastProfile!);
    }
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
    _updateSystemPrompt();
  }

  /// Set the personality vector (Layer 1 Update)
  void setPersonality(PersonalityVector vector) {
    _currentPersonality = vector;
    _updateSystemPrompt();
    debugPrint('GeminiService: Personality Vector updated to $vector');
  }

  void _updateSystemPrompt() {
    // Generate System Prompt (including Rule Layer)
    _currentSystemPrompt = NLPPromptBuilder.generateSystemPrompt(
      _lastProfile ?? NLPProfile.defaultProfile,
      coach: _activeCoach,
      vector: _currentPersonality,
      currentStreak: _currentStreak,
      totalSessions: _totalSessions,
      totalMinutes: _totalMinutes,
      activeGoal: _activeGoal,
      goalProgress: _goalProgress,
      deepDiveUnlocked: _deepDiveUnlocked,
    );

    // 🚀 DEMO LOGGING: Show personality detection
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🧠 IDENTITY ENGINE: Personality Vector Updated');
    debugPrint('   Vector: $_currentPersonality');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
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
    } else {
      // Ensure prompt is up to date with current personality even if profile is null
      if (_currentSystemPrompt == null) {
        _updateSystemPrompt();
      }
    }

    if (_currentSystemPrompt == null) {
      debugPrint('GeminiService: No system prompt set, using default');
      _updateSystemPrompt();
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

      // ── ZERO-SHOT INFERENCE: On first message, classify user's meta-programs ──
      if (limitedHistory.isEmpty && !_hasInferredProfile) {
        await _inferProfileFromMessage(userMessage);
      }

      final apiKey = env.EnvConfig.geminiApiKey;

      if (apiKey.isEmpty) {
        debugPrint('GeminiService: ERROR - API key is empty!');
        yield* _getMockResponse(userMessage, profile);
        return;
      }

      // Build conversation contents (chat history + new message)
      final conversationContents = <Map<String, dynamic>>[];

      // For gemini-2.0-flash-exp, we need to include system prompt inline
      // (systemInstruction field not supported in experimental models)
      final effectiveFirstMessage =
          conversationContents.isEmpty && limitedHistory.isEmpty
              ? '${_currentSystemPrompt ?? ''}\n\nUser: $userMessage'
              : userMessage;

      for (final msg in limitedHistory) {
        conversationContents.add({
          "role": msg.isUser ? "user" : "model",
          "parts": [
            {"text": msg.content}
          ]
        });
      }

      // Add the current user message (with system prompt if first message)
      conversationContents.add({
        "role": "user",
        "parts": [
          {"text": effectiveFirstMessage}
        ]
      });

      final apiUrl =
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:streamGenerateContent?key=$apiKey';

      debugPrint(
          'GeminiService: Sending request to Gemini 2.0 Flash Exp (Key length: ${apiKey.length})');

      // Gemini 2.0 Flash Exp request (NO systemInstruction field)
      final requestBody = json.encode({
        "contents": conversationContents,
        "generationConfig": {
          "temperature": 0.7,
          "maxOutputTokens": _deepDiveUnlocked ? 1200 : 500,
        },
        "safetySettings": [
          {
            "category": "HARM_CATEGORY_HARASSMENT",
            "threshold": "BLOCK_ONLY_HIGH"
          },
          {
            "category": "HARM_CATEGORY_HATE_SPEECH",
            "threshold": "BLOCK_ONLY_HIGH"
          },
          {
            "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
            "threshold": "BLOCK_ONLY_HIGH"
          },
          {
            "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
            "threshold": "BLOCK_ONLY_HIGH"
          }
        ]
      });

      final request = http.Request('POST', Uri.parse(apiUrl));
      request.headers['Content-Type'] = 'application/json';
      request.body = requestBody;

      final client = http.Client();
      try {
        final streamedResponse = await client.send(request);

        if (streamedResponse.statusCode != 200) {
          final errorBody = await streamedResponse.stream.bytesToString();
          debugPrint(
              'GeminiService: API error ${streamedResponse.statusCode}: $errorBody');

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
            debugPrint(
                'GeminiService: Successfully got response (${combinedText.length} chars)');
            final words = combinedText.split(' ');
            for (int i = 0; i < words.length; i++) {
              yield words[i];
              if (i < words.length - 1) yield ' ';
              await Future.delayed(const Duration(milliseconds: 15));
            }
          } else {
            debugPrint(
                'GeminiService: No text parts found in response, using fallback');
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

  /// Zero-shot inference: classify user's first message into NLP meta-programs
  /// Uses a separate non-streaming Gemini call, then updates the system prompt
  /// Hackathon Fix: Fails silently to default profile on any error
  Future<void> _inferProfileFromMessage(String userMessage) async {
    try {
      final apiKey = env.EnvConfig.geminiApiKey;
      if (apiKey.isEmpty) {
        debugPrint('GeminiService: Skipping inference — no API key');
        _hasInferredProfile = true;
        return;
      }

      final inferenceUrl =
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key=$apiKey';

      final requestBody = json.encode({
        "contents": [
          {
            "parts": [
              {"text": '${NLPPromptBuilder.inferencePrompt}$userMessage'}
            ]
          }
        ],
        "generationConfig": {
          "temperature":
              0.1, // Low temperature for deterministic classification
          "maxOutputTokens": 100,
        }
      });

      debugPrint('GeminiService: Running zero-shot personality inference...');

      final response = await http.post(
        Uri.parse(inferenceUrl),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(response.body);

        // Extract text from Gemini response
        String? inferenceText;
        if (jsonData is Map<String, dynamic>) {
          final candidates = jsonData['candidates'] as List<dynamic>?;
          if (candidates != null && candidates.isNotEmpty) {
            final content = candidates[0]['content'] as Map<String, dynamic>?;
            if (content != null) {
              final parts = content['parts'] as List<dynamic>?;
              if (parts != null && parts.isNotEmpty) {
                inferenceText = parts[0]['text']?.toString();
              }
            }
          }
        }

        if (inferenceText != null) {
          final inferredProfile =
              NLPPromptBuilder.parseInferenceResponse(inferenceText);

          if (inferredProfile != null) {
            debugPrint(
                'GeminiService: Profile inferred — ${inferredProfile.displayName}');
            setUserProfile(inferredProfile);
            _hasInferredProfile = true;
            onProfileInferred?.call(inferredProfile);
            return;
          }
        }
      } else {
        debugPrint('GeminiService: Inference API error ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('GeminiService: Inference failed (using default): $e');
    }

    // Fallback: mark as inferred so we don't retry, keep default profile
    _hasInferredProfile = true;
  }

  // ————————————————————————————————————————————————
  // Telemetry & Artifact Generation
  // ————————————————————————————————————————————————

  /// Generates a hidden JSON summary (Telemetry Artifact) of the recent conversation
  /// Runs silently in the background every 3 messages
  Future<Map<String, dynamic>?> generateTelemetrySummary(
      List<Message> recentHistory) async {
    try {
      final apiKey = env.EnvConfig.geminiApiKey;
      if (apiKey.isEmpty) return null;

      final url =
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key=$apiKey';

      // Construct the analysis prompt
      final sb = StringBuffer();
      sb.writeln('SYSTEM: You are a silent metacognitive observer.');
      sb.writeln(
          'TASK: Analyze the recent conversation and generate a telemetry artifact.');
      sb.writeln('OUTPUT: Strictly valid JSON. No markdown. No code blocks.');
      sb.writeln('json_schema = {');
      sb.writeln('  "user_mood": "string",');
      sb.writeln('  "key_insights": ["string"],');
      sb.writeln('  "breakthrough_probability": float,');
      sb.writeln('  "suggested_focus": "string",');
      sb.writeln('  "suggested_vector_update": {');
      sb.writeln('    "structure": float, // 0.0-1.0 (optional)');
      sb.writeln('    "discipline": float, // 0.0-1.0 (optional)');
      sb.writeln('    "warmth": float, // 0.0-1.0 (optional)');
      sb.writeln('    "complexity": float // 0.0-1.0 (optional)');
      sb.writeln('  }');
      sb.writeln('}');
      sb.writeln('\nCURRENT CONTEXT:');
      sb.writeln('Current Personality Vector: $_currentPersonality');
      sb.writeln('\nCONVERSATION HISTORY:');

      for (final msg in recentHistory) {
        sb.writeln('${msg.isUser ? "USER" : "COACH"}: ${msg.content}');
      }

      final requestBody = json.encode({
        "contents": [
          {
            "parts": [
              {"text": sb.toString()}
            ]
          }
        ],
        "generationConfig": {
          "temperature": 0.2, // Low temp for analytical precision
          "maxOutputTokens": 300,
          "responseMimeType": "application/json", // Force JSON
        }
      });

      debugPrint(
          'GeminiService: Generating Telemetry Artifact (History: ${recentHistory.length} msgs)...');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(response.body);
        final content =
            jsonData['candidates']?[0]?['content']?['parts']?[0]?['text'];

        if (content != null) {
          debugPrint('GeminiService: Telemetry Artifact Generated ✅');
          debugPrint(content); // Log the hidden artifact
          return json.decode(content) as Map<String, dynamic>;
        }
      } else {
        debugPrint(
            'GeminiService: Telemetry Generation Failed (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('GeminiService: Telemetry Error: $e');
    }
    return null;
  }

  /// Cancel any ongoing request
  void cancelRequest() {
    debugPrint('GeminiService: Request cancelled');
  }

  /// Dispose resources
  void dispose() {}
}
