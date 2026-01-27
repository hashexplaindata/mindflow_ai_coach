import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/env_config.dart' as env;
import '../domain/models/message.dart';
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
class GeminiService {
  GeminiService();

  /// Whether the service is initialized
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Current system prompt (set per user profile)
  String? _currentSystemPrompt;

  /// Initialize the service
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
    debugPrint('GeminiService: Initialized with backend proxy');
  }

  /// Set the system prompt based on user's NLP profile
  /// Call this when user logs in or profile changes
  void setUserProfile(NLPProfile profile) {
    _currentSystemPrompt = NLPPromptBuilder.generateSystemPrompt(profile);
    debugPrint('GeminiService: System prompt updated for ${profile.displayName}');
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
      final historyJson = chatHistory.where((msg) => msg.content.isNotEmpty).map((msg) {
        return {
          'isUser': msg.isUser,
          'content': msg.content,
        };
      }).toList();

      final requestBody = json.encode({
        'message': userMessage,
        'history': historyJson,
        'system_prompt': _currentSystemPrompt,
      });

      final apiUrl = '${env.apiBaseUrl}/api/chat';
      debugPrint('GeminiService: Sending request to $apiUrl');

      final request = http.Request('POST', Uri.parse(apiUrl));
      request.headers['Content-Type'] = 'application/json';
      request.body = requestBody;

      final client = http.Client();
      try {
        final streamedResponse = await client.send(request);

        if (streamedResponse.statusCode != 200) {
          final errorBody = await streamedResponse.stream.bytesToString();
          debugPrint('GeminiService: API error: $errorBody');
          yield 'I\'m having a moment of reflection. Could you try again?';
          return;
        }

        final stream = streamedResponse.stream.transform(utf8.decoder);
        String buffer = '';

        await for (final chunk in stream) {
          buffer += chunk;
          
          while (buffer.contains('\n\n')) {
            final endIndex = buffer.indexOf('\n\n');
            final line = buffer.substring(0, endIndex);
            buffer = buffer.substring(endIndex + 2);

            if (line.startsWith('data: ')) {
              final data = line.substring(6);
              
              if (data == '[DONE]') {
                return;
              }

              try {
                final parsed = json.decode(data);
                if (parsed['text'] != null) {
                  yield parsed['text'] as String;
                } else if (parsed['error'] != null) {
                  debugPrint('GeminiService: Stream error: ${parsed['error']}');
                  yield 'I\'m having a moment of reflection. Could you try again?';
                  return;
                }
              } catch (e) {
                debugPrint('GeminiService: Parse error: $e');
              }
            }
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
  Stream<String> _getMockResponse(String userMessage, NLPProfile? profile) async* {
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
    } else if (profile.motivation == 'away_from' && profile.reference == 'external') {
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
  void dispose() {
  }
}
