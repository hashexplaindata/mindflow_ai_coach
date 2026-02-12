import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mindflow_ai_coach/features/coach/domain/models/coach.dart';

import '../../../onboarding/domain/models/nlp_profile.dart';
import '../../domain/models/message.dart';
import '../../domain/models/chat_session.dart';
import '../../../identity/domain/models/personality_vector.dart';
import '../../domain/models/conversation_context.dart';
import '../../data/chat_repository.dart';
import '../../data/gemini_service.dart';
import '../../data/genkit_service.dart';
import '../../../subscription/data/revenuecat_service.dart';

/// Chat Provider for MindFlow AI Coach
/// Manages chat state using ChangeNotifier pattern
///
/// Per @Architect rules:
/// - NO setState in widgets—use ref.watch(provider) equivalent
/// - Handle ALL loading/error states
/// - Controller pattern for methods
class ChatProvider extends ChangeNotifier {
  ChatProvider({
    ChatRepository? repository,
    GeminiService? geminiService,
    GenkitService? genkitService,
  })  : _repository = repository ?? ChatRepository(),
        _geminiService = geminiService ?? GeminiService(),
        _genkitService = genkitService ?? GenkitService();

  final ChatRepository _repository;
  final GeminiService
      _geminiService; // Keeping for legacy/offline tools if needed
  final GenkitService _genkitService;

  // State
  ChatSession? _currentSession;
  List<Message> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _errorMessage;
  NLPProfile _userProfile = NLPProfile.defaultProfile;
  bool _isProfileInferred = false;

  // Active Coach
  Coach _activeCoach = Coach.defaultCoach;

  // User ID (set after auth)
  String _userId = 'demo_user';

  // User context for personalization
  int _currentStreak = 0;
  int _totalSessions = 0;
  int _totalMinutes = 0;
  String? _activeGoal;
  double? _goalProgress;

  // Logical Home State
  String? _currentFocus;

  // Telemetry State
  int _messagesSinceLastSummary = 0;

  // Getters
  ChatSession? get currentSession => _currentSession;
  List<Message> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;
  NLPProfile get userProfile => _userProfile;
  bool get isProfileInferred => _isProfileInferred;
  Coach get activeCoach => _activeCoach;
  bool get hasMessages => _messages.isNotEmpty;
  int get currentStreak => _currentStreak;
  int get totalSessions => _totalSessions;

  // Focus Getter
  String? get currentFocus => _currentFocus;

  /// Initialize the provider
  Future<void> initialize() async {
    await _geminiService.initialize();
    _geminiService.setActiveCoach(_activeCoach);

    // Wire zero-shot inference callback so inferred profile persists in provider
    _geminiService.onProfileInferred = (inferredProfile) {
      _userProfile = inferredProfile;
      _isProfileInferred = true;
      notifyListeners();
      debugPrint(
          'ChatProvider: Profile updated via zero-shot inference → ${inferredProfile.displayName}');
    };
  }

  /// Set user ID (call after auth)
  void setUserId(String userId) {
    _userId = userId;
  }

  /// Set the active coach
  void setActiveCoach(Coach coach) {
    _activeCoach = coach;
    _geminiService.setActiveCoach(coach);
    notifyListeners();
  }

  /// Set user's NLP profile
  void setUserProfile(NLPProfile profile) {
    _userProfile = profile;
    _geminiService.setUserProfile(profile);
    notifyListeners();
  }

  /// Set user's Personality Vector (Layer 1)
  void setPersonality(PersonalityVector vector) {
    _geminiService.setPersonality(vector);
  }

  /// Set user progress context for personalized coaching
  void setProgressContext({
    int? currentStreak,
    int? totalSessions,
    int? totalMinutes,
    String? activeGoal,
    double? goalProgress,
  }) {
    if (currentStreak != null) _currentStreak = currentStreak;
    if (totalSessions != null) _totalSessions = totalSessions;
    if (totalMinutes != null) _totalMinutes = totalMinutes;
    _activeGoal = activeGoal ?? _activeGoal;
    _goalProgress = goalProgress ?? _goalProgress;

    _geminiService.setProgressContext(
      currentStreak: _currentStreak,
      totalSessions: _totalSessions,
      totalMinutes: _totalMinutes,
      activeGoal: _activeGoal,
      goalProgress: _goalProgress,
    );
    notifyListeners();
  }

  /// Get the current conversation context
  ConversationContext getConversationContext() {
    return ConversationContext(
      userProfile: _userProfile,
      currentStreak: _currentStreak,
      totalSessions: _totalSessions,
      totalMinutes: _totalMinutes,
      activeGoal: _activeGoal,
      goalProgress: _goalProgress,
      timeOfDay: ConversationContext.getCurrentTimeContext(),
    );
  }

  /// Clear conversation history
  Future<void> clearHistory() async {
    _messages = [];
    _currentSession = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Start a new chat session
  Future<void> startNewChat() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentSession = await _repository.createSession(_userId);
      _messages = [];
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Could not start a new chat. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load an existing chat session
  Future<void> loadSession(String sessionId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _messages = await _repository.getMessages(
        userId: _userId,
        sessionId: sessionId,
      );
      // Find session from list
      final sessions = await _repository.getSessions(_userId);
      _currentSession = sessions.firstWhere(
        (s) => s.id == sessionId,
        orElse: () => ChatSession.create(),
      );
    } catch (e) {
      _errorMessage = 'Could not load chat. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Send a message to the AI coach (Genkit Powered)
  Future<void> sendMessage(String content, {bool isPro = false}) async {
    if (content.trim().isEmpty) return;
    if (_isSending) return;

    // Check free tier limits (5 messages max)
    if (!isPro) {
      final userMessageCount = _messages.where((m) => m.isUser).length;
      if (userMessageCount >= 5) {
        final didSubscribe = await RevenueCatService.instance.showPaywall();
        if (!didSubscribe) return;
        isPro = true;
      }
    }

    // Ensure we have a session
    if (_currentSession == null) {
      await startNewChat();
    }

    _isSending = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Add user message
      final userMessage = Message.user(content: content.trim());
      _messages.add(userMessage);
      notifyListeners();

      await _repository.saveMessage(
        userId: _userId,
        sessionId: _currentSession!.id,
        message: userMessage,
      );

      // Add placeholder for assistant response (Loading state)
      // Note: Genkit Cloud Functions are currently unary (not streaming) in this implementation
      final assistantMessage = Message.assistant(content: "Thinking...");
      _messages.add(assistantMessage);
      notifyListeners();

      // Call Genkit Cloud Function
      // TODO: Pass actual vector from user profile
      final responseText = await _genkitService.generateCoachingResponse(
        message: content,
        isPro: isPro,
        personalityVector: {
          // Mock vector for now, connect to _userProfile later if needed
          'discipline': 0.5,
          'noveltySeeking': 0.8,
        },
        context: getConversationContext().toPromptString(),
      );

      // Finalize the message
      final finalMessage = assistantMessage.copyWith(
        content: responseText,
        isStreaming: false,
      );
      _messages[_messages.length - 1] = finalMessage;

      await _repository.saveMessage(
        userId: _userId,
        sessionId: _currentSession!.id,
        message: finalMessage,
      );

      // 3. Closure Logic: Codify the breakthrough
      if (_shouldCodifyBreakthrough(finalMessage.content)) {
        await _saveBreakthroughArtifact(finalMessage);
      }

      // 4. Telemetry (Fire and Forget)
      _messagesSinceLastSummary++;
      if (_messagesSinceLastSummary >= 3) {
        _messagesSinceLastSummary = 0;
        // Mock telemetry since Genkit service handles breakthrough detection internally too
        _saveTelemetryArtifact({'type': 'summary_generated'});
      }
    } catch (e) {
      _errorMessage = 'Hmm, I need a moment to think. Mind trying again?';
      if (_messages.isNotEmpty && _messages.last.isAssistant) {
        _messages.removeLast();
      }
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  /// Retry the last failed message
  Future<void> retryLastMessage({bool isPro = false}) async {
    if (_messages.isEmpty) return;

    // Find the last user message
    Message? lastUserMessage;
    for (int i = _messages.length - 1; i >= 0; i--) {
      if (_messages[i].isUser) {
        lastUserMessage = _messages[i];
        break;
      }
    }

    if (lastUserMessage != null) {
      // Remove the failed assistant message if present
      if (_messages.isNotEmpty && _messages.last.isAssistant) {
        _messages.removeLast();
      }
      // Remove the user message (it will be re-added)
      _messages.removeWhere((m) => m.id == lastUserMessage!.id);
      notifyListeners();

      // Resend
      await sendMessage(lastUserMessage.content, isPro: isPro);
    }
  }

  /// Get all chat sessions
  Future<List<ChatSession>> getAllSessions() async {
    return _repository.getSessions(_userId);
  }

  /// Delete a chat session
  Future<void> deleteSession(String sessionId) async {
    try {
      await _repository.deleteSession(
        userId: _userId,
        sessionId: sessionId,
      );

      if (_currentSession?.id == sessionId) {
        _currentSession = null;
        _messages = [];
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Could not delete chat.';
      notifyListeners();
    }
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ————————————————————————————————————————————————
  // Logical Home Focus Methods
  // ————————————————————————————————————————————————

  /// Set the user's current focus (One Thing)
  void startNewFocus(String focus) {
    _currentFocus = focus;
    notifyListeners();
  }

  /// Clear the current focus to return to Intention Setting
  void clearFocus() {
    _currentFocus = null;
    notifyListeners();
  }

  // ————————————————————————————————————————————————
  // Telemetry & Breakthrough Logic
  // ————————————————————————————————————————————————

  bool _shouldCodifyBreakthrough(String text) {
    // Simple heuristic: check for breakthrough keywords or length
    final keywords = ['aha', 'realize', 'understand', 'epiphany', 'clear now'];
    final lowerText = text.toLowerCase();
    return keywords.any((k) => lowerText.contains(k)) || text.length > 500;
  }

  Future<void> _saveBreakthroughArtifact(Message message) async {
    // Mock breakthrough saving
    debugPrint(
        'ChatProvider: Breakthrough Saved — "${message.content.substring(0, 20)}..."');
  }

  Future<void> _saveTelemetryArtifact(Map<String, dynamic> data) async {
    // Mock telemetry artifact saving
    debugPrint('ChatProvider: 🧠 TELEMETRY LOGGED: $data');
    // Logic to save to a local "Telemetry" collection could go here
  }

  @override
  void dispose() {
    _geminiService.dispose();
    super.dispose();
  }
}
