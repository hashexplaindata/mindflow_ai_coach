// 1. The Identity Engine (Layer 1)
// Goal: Convert user inputs into a deterministic PersonalityVector.

class PersonalityVector {
  final double discipline; // 0.0 (Chaos) -> 1.0 (Order)
  final double novelty; // 0.0 (Traditional) -> 1.0 (Seeker)
  final double volatility; // 0.0 (Stoic) -> 1.0 (Reactive)
  final double structure; // 0.0 (Flow) -> 1.0 (Grid)

  const PersonalityVector({
    required this.discipline,
    required this.novelty,
    required this.volatility,
    required this.structure,
  });

  // Default "balanced" profile
  static const PersonalityVector defaultProfile = PersonalityVector(
    discipline: 0.5,
    novelty: 0.5,
    volatility: 0.5,
    structure: 0.5,
  );

  // JSON Serialization
  Map<String, dynamic> toJson() {
    return {
      'discipline': discipline,
      'novelty': novelty,
      'volatility': volatility,
      'structure': structure,
    };
  }

  factory PersonalityVector.fromJson(Map<String, dynamic> json) {
    return PersonalityVector(
      discipline: (json['discipline'] as num?)?.toDouble() ?? 0.5,
      novelty: (json['novelty'] as num?)?.toDouble() ?? 0.5,
      volatility: (json['volatility'] as num?)?.toDouble() ?? 0.5,
      structure: (json['structure'] as num?)?.toDouble() ?? 0.5,
    );
  }

  // CopyWith for immutable updates
  PersonalityVector copyWith({
    double? discipline,
    double? novelty,
    double? volatility,
    double? structure,
  }) {
    return PersonalityVector(
      discipline: discipline ?? this.discipline,
      novelty: novelty ?? this.novelty,
      volatility: volatility ?? this.volatility,
      structure: structure ?? this.structure,
    );
  }

  // Computed Properties for Prompting (The "Logic Matrix")
  bool get needsToughLove => discipline < 0.3 && volatility < 0.6;
  bool get needsValidation => volatility > 0.7;
  bool get needsShortAnswers => novelty > 0.8;
  bool get needsStepByStep => structure > 0.7;

  @override
  String toString() {
    return 'PersonalityVector(D:${discipline.toStringAsFixed(2)}, N:${novelty.toStringAsFixed(2)}, V:${volatility.toStringAsFixed(2)}, S:${structure.toStringAsFixed(2)})';
  }
}
