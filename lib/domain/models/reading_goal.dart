enum GoalType {
  pages,
  minutes,
  books,
}

enum GoalPeriod {
  daily,
  weekly,
  monthly,
}

class ReadingGoal {
  final String id;
  final GoalType type;
  final GoalPeriod period;
  final int targetValue;
  final bool isActive;

  const ReadingGoal({
    required this.id,
    required this.type,
    required this.period,
    required this.targetValue,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'period': period.name,
      'targetValue': targetValue,
      'isActive': isActive,
    };
  }

  factory ReadingGoal.fromJson(Map<String, dynamic> json) {
    return ReadingGoal(
      id: json['id'] as String,
      type: GoalType.values.firstWhere((g) => g.name == json['type'], orElse: () => GoalType.pages),
      period: GoalPeriod.values.firstWhere((p) => p.name == json['period'], orElse: () => GoalPeriod.daily),
      targetValue: json['targetValue'] as int? ?? 20,
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}
