import 'dart:async';
import 'package:flutter/material.dart';

import '../../../onboarding/domain/models/nlp_profile.dart';
import '../../domain/models/message.dart';
import '../../domain/models/chat_session.dart';
import '../../data/chat_repository.dart';
import '../../data/gemini_service.dart';

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
  }) : _repository = repository ?? ChatRepository(),
       _geminiService = geminiService ?? GeminiService();

  final ChatRepository _repository;
  final GeminiService _geminiService;

  // State
  ChatSession? _currentSession;
  List<Message> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _errorMessage;
  NLPProfile _userProfile = NLPProfile.defaultProfile;

  // User ID (set after auth)
  String _userId = 'demo_user';

  // Getters
  ChatSession? get currentSession => _currentSession;
  List<Message> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;
  NLPProfile get userProfile => _userProfile;
  bool get hasMessages => _messages.isNotEmpty;

  /// Initialize the provider
  Future<void> initialize() async {
    await _geminiService.initialize();
  }

  /// Set user ID (call after auth)
  void setUserId(String userId) {
    _userId = userId;
  }

  /// Set user's NLP profile
  void setUserProfile(NLPProfile profile) {
    _userProfile = profile;
    _geminiService.setUserProfile(profile);
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

  /// Send a message to the AI coach
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;
    if (_isSending) return;

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

      // Save user message
      await _repository.saveMessage(
        userId: _userId,
        sessionId: _currentSession!.id,
        message: userMessage,
      );

      // Add placeholder for assistant response
      final assistantMessage = Message.assistantStreaming();
      _messages.add(assistantMessage);
      notifyListeners();

      // Stream response from Gemini
      final responseBuffer = StringBuffer();
      DateTime lastUpdate = DateTime.now();
      
      await for (final chunk in _geminiService.sendMessageStream(
        userMessage: content,
        chatHistory: _messages.where((m) => !m.isStreaming).toList(),
        profile: _userProfile,
      )) {
        responseBuffer.write(chunk);
        
        // Update the streaming message
        final updatedMessage = assistantMessage.copyWith(
          content: responseBuffer.toString(),
        );
        _messages[_messages.length - 1] = updatedMessage;

        // Throttle updates to ~100ms to avoid UI jank
        if (DateTime.now().difference(lastUpdate).inMilliseconds > 100) {
          lastUpdate = DateTime.now();
          notifyListeners();
        }
      }

      // Ensure the final content is shown before finalizing
      notifyListeners();

      // Finalize the message
      final finalMessage = assistantMessage.copyWith(
        content: responseBuffer.toString(),
        isStreaming: false,
      );
      _messages[_messages.length - 1] = finalMessage;

      // Save assistant message
      await _repository.saveMessage(
        userId: _userId,
        sessionId: _currentSession!.id,
        message: finalMessage,
      );

    } catch (e) {
      _errorMessage = 'Hmm, I need a moment to think. Mind trying again?';
      // Remove the streaming message on error
      if (_messages.isNotEmpty && _messages.last.isStreaming) {
        _messages.removeLast();
      }
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  /// Retry the last failed message
  Future<void> retryLastMessage() async {
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
      await sendMessage(lastUserMessage.content);
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

  @override
  void dispose() {
    _geminiService.dispose();
    super.dispose();
  }
}
