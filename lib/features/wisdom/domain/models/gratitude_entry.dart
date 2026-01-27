class GratitudeEntry {
  final String id;
  final String userId;
  final String content;
  final String? promptId;
  final DateTime createdAt;

  const GratitudeEntry({
    required this.id,
    required this.userId,
    required this.content,
    this.promptId,
    required this.createdAt,
  });

  factory GratitudeEntry.create({
    required String userId,
    required String content,
    String? promptId,
  }) {
    return GratitudeEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      content: content,
      promptId: promptId,
      createdAt: DateTime.now(),
    );
  }

  bool get isFromToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entryDate = DateTime(createdAt.year, createdAt.month, createdAt.day);
    return today.isAtSameMomentAs(entryDate);
  }

  String get formattedDate {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[createdAt.month - 1]} ${createdAt.day}, ${createdAt.year}';
  }

  String get formattedTime {
    final hour = createdAt.hour > 12 ? createdAt.hour - 12 : createdAt.hour;
    final period = createdAt.hour >= 12 ? 'PM' : 'AM';
    final minute = createdAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  GratitudeEntry copyWith({
    String? id,
    String? userId,
    String? content,
    String? promptId,
    DateTime? createdAt,
  }) {
    return GratitudeEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      promptId: promptId ?? this.promptId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
      'promptId': promptId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory GratitudeEntry.fromJson(Map<String, dynamic> json) {
    return GratitudeEntry(
      id: json['id'] as String,
      userId: json['userId'] as String,
      content: json['content'] as String,
      promptId: json['promptId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GratitudeEntry &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
