import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../../../core/config/env_config.dart' as env;
import '../domain/models/message.dart';
import '../../onboarding/domain/models/nlp_profile.dart';
import '../domain/services/nlp_prompt_builder.dart';

/// Gemini Service for MindFlow AI Coach
/// Handles communication with Google's Gemini API
/// Uses NLP Prompt Builder for profile-adaptive system prompts
/// 
/// Configuration (per Technical Specification):
/// - Model: gemini-2.0-flash (fast, cost-effective)
/// - Temperature: 0.7 (creative but coherent)
/// - Max tokens: 500 per response
/// - Streaming: Yes (better UX with typing indicator)
class GeminiService {
  GeminiService({
    String? apiKey,
  }) : _apiKey = apiKey ?? env.geminiApiKey;

  final String _apiKey;
  
  GenerativeModel? _model;
  ChatSession? _currentChat;

  /// Model configuration
  static const String modelName = 'gemini-2.0-flash';
  static const double temperature = 0.7;
  static const int maxOutputTokens = 500;

  /// Whether the service is initialized
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Current system prompt (set per user profile)
  String? _currentSystemPrompt;

  /// Initialize the service
  Future<void> initialize() async {
    if (_isInitialized) return;

    debugPrint('GeminiService: API key length: ${_apiKey.length}');
    
    if (_apiKey.isEmpty) {
      debugPrint('GeminiService: No API key configured');
      return;
    }
    
    debugPrint('GeminiService: API key found, initializing...');

    try {
      _model = GenerativeModel(
        model: modelName,
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          temperature: temperature,
          maxOutputTokens: maxOutputTokens,
        ),
      );
      
      _isInitialized = true;
      debugPrint('GeminiService: Initialized with model $modelName');
    } catch (e) {
      debugPrint('GeminiService: Initialization error: $e');
    }
  }

  /// Set the system prompt based on user's NLP profile
  /// Call this when user logs in or profile changes
  void setUserProfile(NLPProfile profile) {
    _currentSystemPrompt = NLPPromptBuilder.generateSystemPrompt(profile);
    debugPrint('GeminiService: System prompt updated for ${profile.displayName}');
  }

  /// Send a message and get streaming response
  /// Returns a stream of content chunks for real-time display
  Stream<String> sendMessageStream({
    required String userMessage,
    required List<Message> chatHistory,
    NLPProfile? profile,
  }) async* {
    // Update system prompt if profile provided
    if (profile != null) {
      setUserProfile(profile);
    }

    // Validate - fallback to mock if no API key
    if (_apiKey.isEmpty || _model == null) {
      debugPrint('GeminiService: No API key or model, using mock response');
      yield* _getMockResponse(userMessage, profile);
      return;
    }

    if (_currentSystemPrompt == null) {
      debugPrint('GeminiService: No system prompt set, using default');
      _currentSystemPrompt = NLPPromptBuilder.generateSystemPrompt(
        NLPProfile.defaultProfile,
      );
    }

    try {
      // Build chat history for context
      final history = chatHistory.where((msg) => msg.content.isNotEmpty).map((msg) {
        return Content(
          msg.isUser ? 'user' : 'model',
          [TextPart(msg.content)],
        );
      }).toList();
      
      // Create a new chat with system prompt
      _currentChat = _model!.startChat(
        history: [
          Content('user', [TextPart(_currentSystemPrompt!)]),
          Content('model', [TextPart('I understand. I will embody these principles in our conversation.')]),
          ...history,
        ],
      );
      
      // Send message and stream response
      final response = _currentChat!.sendMessageStream(
        Content.text(userMessage),
      );
      
      await for (final chunk in response) {
        final text = chunk.text;
        if (text != null) {
          yield text;
        }
      }
    } catch (e) {
      debugPrint('GeminiService: Error sending message: $e');
      yield 'I\'m having a moment of reflection. Could you try again?';
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

  /// Get a mock response for development/demo
  /// Implements NLP-adaptive language patterns
  Stream<String> _getMockResponse(String userMessage, NLPProfile? profile) async* {
    final effectiveProfile = profile ?? NLPProfile.defaultProfile;
    
    // Simulate streaming delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Check for crisis indicators (suppress humor if detected)
    final isCrisis = NLPPromptBuilder.containsCrisisIndicators(userMessage);
    
    // Generate adaptive response based on profile
    final response = _generateAdaptiveResponse(
      userMessage: userMessage,
      profile: effectiveProfile,
      isSerious: isCrisis,
    );

    // Simulate streaming by yielding chunks
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

    // PACING: Acknowledge their message first
    buffer.write(_getPacingPhrase(profile));
    buffer.write(' ');

    // LEADING: Guide toward insight
    buffer.write(_getLeadingPhrase(profile, userMessage));
    buffer.write('\n\n');

    // ACTION: Provide next step
    buffer.write(_getActionStep(profile));

    // HUMOR: Add if appropriate (15% chance, not for serious topics)
    if (!isSerious && _shouldAddHumor()) {
      buffer.write('\n\n');
      buffer.write(_getHumorPhrase(profile));
    }

    return buffer.toString();
  }

  String _getPacingPhrase(NLPProfile profile) {
    // Use their thinking style language
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
    // Combine motivation + thinking style
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
      // Away-From motivation
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
    // Combine reference + processing style
    if (profile.reference == 'internal') {
      if (profile.processing == 'options') {
        return "🎯 **Your move**: What feels like the most exciting option right now? Trust your instincts here—you know yourself best.";
      } else {
        return "🎯 **Next step**: Based on what YOU know works for you, what's the first concrete action? Sometimes one step is all we need.";
      }
    } else {
      // External reference
      if (profile.processing == 'options') {
        return "🎯 **Research shows**: The most effective people explore 2-3 options before committing. Which path do the experts in your situation recommend?";
      } else {
        return "🎯 **Proven method**: Step 1 is usually the hardest. Studies show that just starting creates momentum. What's ONE thing you can do in the next 5 minutes?";
      }
    }
  }

  bool _shouldAddHumor() {
    // 15% chance of humor
    return DateTime.now().millisecond % 7 == 0;
  }

  String _getHumorPhrase(NLPProfile profile) {
    // Profile-specific humor from NLP_Frameworks_Reference.md
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
    // TODO: Implement request cancellation
    debugPrint('GeminiService: Request cancelled');
  }

  /// Dispose resources
  void dispose() {
    // _currentChat = null;
  }
}
