/// Message Model for MindFlow Chat
/// Represents a single message in a conversation
class Message {
  const Message({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.isStreaming = false,
    this.isLoading = false,
  });

  /// Unique message identifier
  final String id;

  /// Message role: 'user' or 'assistant'
  final String role;

  /// Message text content
  final String content;

  /// When the message was sent
  final DateTime timestamp;

  /// Whether the message is still being streamed
  final bool isStreaming;

  /// Whether the message is in loading state (waiting for response)
  final bool isLoading;

  /// Check if message is from user
  bool get isUser => role == 'user';

  /// Check if message is from AI coach
  bool get isAssistant => role == 'assistant';

  /// Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'role': role,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Create from Firestore Map
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] ?? '',
      role: map['role'] ?? 'user',
      content: map['content'] ?? '',
      timestamp: map['timestamp'] is String
          ? DateTime.parse(map['timestamp'])
          : (map['timestamp']?.toDate() ?? DateTime.now()),
    );
  }

  /// Create a user message
  factory Message.user({
    required String content,
    String? id,
  }) {
    return Message(
      id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'user',
      content: content,
      timestamp: DateTime.now(),
    );
  }

  /// Create an assistant message (streaming)
  factory Message.assistantStreaming({String? id}) {
    return Message(
      id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'assistant',
      content: '',
      timestamp: DateTime.now(),
      isStreaming: true,
    );
  }

  /// Create an assistant message
  factory Message.assistant({
    required String content,
    String? id,
    bool isStreaming = false,
  }) {
    return Message(
      id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'assistant',
      content: content,
      timestamp: DateTime.now(),
      isStreaming: isStreaming,
    );
  }

  /// Copy with modifications
  Message copyWith({
    String? id,
    String? role,
    String? content,
    DateTime? timestamp,
    bool? isStreaming,
    bool? isLoading,
  }) {
    return Message(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isStreaming: isStreaming ?? this.isStreaming,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  String toString() {
    return 'Message(id: $id, role: $role, content: ${content.substring(0, content.length > 50 ? 50 : content.length)}...)';
  }
}
