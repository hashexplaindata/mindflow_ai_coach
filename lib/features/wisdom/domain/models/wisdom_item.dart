import 'wisdom_category.dart';
import 'user_context.dart';

class WisdomItem {
  final String id;
  final String content;
  final WisdomCategory category;
  final WisdomTone tone;
  final String? author;
  final List<String> tags;
  final DateTime? dateShown;
  final bool isFavorite;
  final List<TimeOfDayPeriod> suitableTimeOfDay;
  final List<UserMood> suitableMoods;
  final List<ActivityContext> suitableActivities;

  const WisdomItem({
    required this.id,
    required this.content,
    required this.category,
    required this.tone,
    this.author,
    this.tags = const [],
    this.dateShown,
    this.isFavorite = false,
    this.suitableTimeOfDay = const [],
    this.suitableMoods = const [],
    this.suitableActivities = const [],
  });

  bool get isGoalOriented => tone == WisdomTone.motivation || tone == WisdomTone.growth;
  bool get isReliefSeeking => tone == WisdomTone.calm || tone == WisdomTone.mindfulness;

  bool isSuitableForTime(TimeOfDayPeriod period) {
    if (suitableTimeOfDay.isEmpty) return true;
    return suitableTimeOfDay.contains(period);
  }

  bool isSuitableForMood(UserMood? mood) {
    if (suitableMoods.isEmpty || mood == null) return true;
    return suitableMoods.contains(mood);
  }

  bool isSuitableForActivity(ActivityContext activity) {
    if (suitableActivities.isEmpty) return true;
    return suitableActivities.contains(activity);
  }

  WisdomItem copyWith({
    String? id,
    String? content,
    WisdomCategory? category,
    WisdomTone? tone,
    String? author,
    List<String>? tags,
    DateTime? dateShown,
    bool? isFavorite,
    List<TimeOfDayPeriod>? suitableTimeOfDay,
    List<UserMood>? suitableMoods,
    List<ActivityContext>? suitableActivities,
  }) {
    return WisdomItem(
      id: id ?? this.id,
      content: content ?? this.content,
      category: category ?? this.category,
      tone: tone ?? this.tone,
      author: author ?? this.author,
      tags: tags ?? this.tags,
      dateShown: dateShown ?? this.dateShown,
      isFavorite: isFavorite ?? this.isFavorite,
      suitableTimeOfDay: suitableTimeOfDay ?? this.suitableTimeOfDay,
      suitableMoods: suitableMoods ?? this.suitableMoods,
      suitableActivities: suitableActivities ?? this.suitableActivities,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'category': category.name,
      'tone': tone.name,
      'author': author,
      'tags': tags,
      'dateShown': dateShown?.toIso8601String(),
      'isFavorite': isFavorite,
      'suitableTimeOfDay': suitableTimeOfDay.map((e) => e.name).toList(),
      'suitableMoods': suitableMoods.map((e) => e.name).toList(),
      'suitableActivities': suitableActivities.map((e) => e.name).toList(),
    };
  }

  factory WisdomItem.fromJson(Map<String, dynamic> json) {
    return WisdomItem(
      id: json['id'] as String,
      content: json['content'] as String,
      category: WisdomCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => WisdomCategory.quote,
      ),
      tone: WisdomTone.values.firstWhere(
        (e) => e.name == json['tone'],
        orElse: () => WisdomTone.motivation,
      ),
      author: json['author'] as String?,
      tags: List<String>.from(json['tags'] ?? []),
      dateShown: json['dateShown'] != null
          ? DateTime.parse(json['dateShown'] as String)
          : null,
      isFavorite: json['isFavorite'] as bool? ?? false,
      suitableTimeOfDay: (json['suitableTimeOfDay'] as List<dynamic>?)
              ?.map((e) => TimeOfDayPeriod.values.firstWhere(
                    (t) => t.name == e,
                    orElse: () => TimeOfDayPeriod.morning,
                  ))
              .toList() ??
          [],
      suitableMoods: (json['suitableMoods'] as List<dynamic>?)
              ?.map((e) => UserMood.values.firstWhere(
                    (m) => m.name == e,
                    orElse: () => UserMood.neutral,
                  ))
              .toList() ??
          [],
      suitableActivities: (json['suitableActivities'] as List<dynamic>?)
              ?.map((e) => ActivityContext.values.firstWhere(
                    (a) => a.name == e,
                    orElse: () => ActivityContext.newUser,
                  ))
              .toList() ??
          [],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WisdomItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'WisdomItem(id: $id, category: $category, tone: $tone, content: ${content.substring(0, content.length > 30 ? 30 : content.length)}...)';
  }
}
