// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../domain/models/message.dart';
import '../domain/models/chat_session.dart';

/// Chat Repository for MindFlow AI Coach
/// Handles persistence of chat sessions and messages to Firestore
///
/// Firestore structure:
/// users/{userId}/chats/{chatId}/
///   - createdAt: timestamp
///   - summary: string
///   - messageCount: number
///
///   messages/{messageId}/
///     - role: 'user' | 'assistant'
///     - content: string
///     - timestamp: timestamp
class ChatRepository {
  // TODO: Uncomment when Firebase is configured
  // final FirebaseFirestore _firestore;
  //
  // ChatRepository({FirebaseFirestore? firestore})
  //     : _firestore = firestore ?? FirebaseFirestore.instance;

  ChatRepository();

  // In-memory storage for development
  final Map<String, ChatSession> _sessions = {};
  final Map<String, List<Message>> _messages = {};

  /// Create a new chat session
  Future<ChatSession> createSession(String userId) async {
    final session = ChatSession.create();

    try {
      // TODO: Uncomment when Firebase is configured
      // await _firestore
      //     .collection('users')
      //     .doc(userId)
      //     .collection('chats')
      //     .doc(session.id)
      //     .set(session.toMap());

      // In-memory storage
      _sessions[session.id] = session;
      _messages[session.id] = [];

      debugPrint('ChatRepository: Created session ${session.id}');
      return session;
    } catch (e) {
      debugPrint('ChatRepository: Error creating session: $e');
      rethrow;
    }
  }

  /// Save a message to a chat session
  Future<void> saveMessage({
    required String userId,
    required String sessionId,
    required Message message,
  }) async {
    try {
      // TODO: Uncomment when Firebase is configured
      // final batch = _firestore.batch();
      //
      // // Add message
      // final messageRef = _firestore
      //     .collection('users')
      //     .doc(userId)
      //     .collection('chats')
      //     .doc(sessionId)
      //     .collection('messages')
      //     .doc(message.id);
      // batch.set(messageRef, message.toMap());
      //
      // // Update session metadata
      // final sessionRef = _firestore
      //     .collection('users')
      //     .doc(userId)
      //     .collection('chats')
      //     .doc(sessionId);
      // batch.update(sessionRef, {
      //   'messageCount': FieldValue.increment(1),
      //   'lastMessageAt': FieldValue.serverTimestamp(),
      //   if (message.isUser) 'summary': message.content.substring(
      //     0,
      //     message.content.length > 50 ? 50 : message.content.length,
      //   ),
      // });
      //
      // await batch.commit();

      // In-memory storage
      _messages[sessionId] ??= [];
      _messages[sessionId]!.add(message);

      // Update session
      if (_sessions.containsKey(sessionId)) {
        _sessions[sessionId] = _sessions[sessionId]!.copyWith(
          messageCount: _messages[sessionId]!.length,
          lastMessageAt: DateTime.now(),
          summary: message.isUser
              ? message.content.substring(
                  0, message.content.length > 50 ? 50 : message.content.length)
              : _sessions[sessionId]!.summary,
        );
      }

      debugPrint(
          'ChatRepository: Saved message ${message.id} to session $sessionId');
    } catch (e) {
      debugPrint('ChatRepository: Error saving message: $e');
      rethrow;
    }
  }

  /// Get messages for a session
  Future<List<Message>> getMessages({
    required String userId,
    required String sessionId,
    int limit = 50,
  }) async {
    try {
      // TODO: Uncomment when Firebase is configured
      // final snapshot = await _firestore
      //     .collection('users')
      //     .doc(userId)
      //     .collection('chats')
      //     .doc(sessionId)
      //     .collection('messages')
      //     .orderBy('timestamp', descending: false)
      //     .limit(limit)
      //     .get();
      //
      // return snapshot.docs
      //     .map((doc) => Message.fromMap(doc.data()))
      //     .toList();

      // In-memory storage
      return _messages[sessionId] ?? [];
    } catch (e) {
      debugPrint('ChatRepository: Error getting messages: $e');
      return [];
    }
  }

  /// Stream messages for real-time updates
  Stream<List<Message>> streamMessages({
    required String userId,
    required String sessionId,
  }) {
    // TODO: Uncomment when Firebase is configured
    // return _firestore
    //     .collection('users')
    //     .doc(userId)
    //     .collection('chats')
    //     .doc(sessionId)
    //     .collection('messages')
    //     .orderBy('timestamp', descending: false)
    //     .snapshots()
    //     .map((snapshot) => snapshot.docs
    //         .map((doc) => Message.fromMap(doc.data()))
    //         .toList());

    // In-memory: return current messages as a single-item stream
    return Stream.value(_messages[sessionId] ?? []);
  }

  /// Get all chat sessions for a user
  Future<List<ChatSession>> getSessions(String userId) async {
    try {
      // TODO: Uncomment when Firebase is configured
      // final snapshot = await _firestore
      //     .collection('users')
      //     .doc(userId)
      //     .collection('chats')
      //     .orderBy('createdAt', descending: true)
      //     .get();
      //
      // return snapshot.docs
      //     .map((doc) => ChatSession.fromMap(doc.data()))
      //     .toList();

      // In-memory storage
      return _sessions.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      debugPrint('ChatRepository: Error getting sessions: $e');
      return [];
    }
  }

  /// Delete a chat session
  Future<void> deleteSession({
    required String userId,
    required String sessionId,
  }) async {
    try {
      // TODO: Uncomment when Firebase is configured
      // // Delete all messages first
      // final messagesSnapshot = await _firestore
      //     .collection('users')
      //     .doc(userId)
      //     .collection('chats')
      //     .doc(sessionId)
      //     .collection('messages')
      //     .get();
      //
      // final batch = _firestore.batch();
      // for (final doc in messagesSnapshot.docs) {
      //   batch.delete(doc.reference);
      // }
      //
      // // Delete session
      // batch.delete(_firestore
      //     .collection('users')
      //     .doc(userId)
      //     .collection('chats')
      //     .doc(sessionId));
      //
      // await batch.commit();

      // In-memory storage
      _sessions.remove(sessionId);
      _messages.remove(sessionId);

      debugPrint('ChatRepository: Deleted session $sessionId');
    } catch (e) {
      debugPrint('ChatRepository: Error deleting session: $e');
      rethrow;
    }
  }

  /// Clear in-memory data
  void clearMemory() {
    _sessions.clear();
    _messages.clear();
  }
}
