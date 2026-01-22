/// Chat Session Model for MindFlow
/// Represents a conversation with the AI coach
class ChatSession {
  const ChatSession({
    required this.id,
    required this.createdAt,
    this.summary,
    this.messageCount = 0,
    this.lastMessageAt,
  });

  /// Unique session identifier
  final String id;

  /// When the session was created
  final DateTime createdAt;

  /// Summary of the conversation (usually first message or AI-generated)
  final String? summary;

  /// Number of messages in the session
  final int messageCount;

  /// When the last message was sent
  final DateTime? lastMessageAt;

  /// Display title for the session
  String get displayTitle {
    if (summary != null && summary!.isNotEmpty) {
      // Truncate to 50 chars
      return summary!.length > 50 
          ? '${summary!.substring(0, 50)}...'
          : summary!;
    }
    return 'New Conversation';
  }

  /// Format the date for display
  String get formattedDate {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${createdAt.month}/${createdAt.day}/${createdAt.year}';
    }
  }

  /// Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'summary': summary,
      'messageCount': messageCount,
      'lastMessageAt': lastMessageAt?.toIso8601String(),
    };
  }

  /// Create from Firestore Map
  factory ChatSession.fromMap(Map<String, dynamic> map) {
    return ChatSession(
      id: map['id'] ?? '',
      createdAt: map['createdAt'] is String
          ? DateTime.parse(map['createdAt'])
          : (map['createdAt']?.toDate() ?? DateTime.now()),
      summary: map['summary'],
      messageCount: map['messageCount'] ?? 0,
      lastMessageAt: map['lastMessageAt'] != null
          ? (map['lastMessageAt'] is String
              ? DateTime.parse(map['lastMessageAt'])
              : map['lastMessageAt']?.toDate())
          : null,
    );
  }

  /// Create a new session
  factory ChatSession.create() {
    return ChatSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
    );
  }

  /// Copy with modifications
  ChatSession copyWith({
    String? id,
    DateTime? createdAt,
    String? summary,
    int? messageCount,
    DateTime? lastMessageAt,
  }) {
    return ChatSession(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      summary: summary ?? this.summary,
      messageCount: messageCount ?? this.messageCount,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
    );
  }

  @override
  String toString() {
    return 'ChatSession(id: $id, summary: $summary, messageCount: $messageCount)';
  }
}
