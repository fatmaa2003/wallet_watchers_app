class Goal {
  final String id;
  final String title;
  final String icon;
  final double targetAmount;
  final double savedAmount;
  final bool isAchieved;

  Goal({
    required this.id,
    required this.title,
    required this.icon,
    required this.targetAmount,
    required this.savedAmount,
    required this.isAchieved,
  });

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      icon: json['icon'] ?? 'target',
      targetAmount: (json['targetAmount'] ?? 0).toDouble(),
      savedAmount: (json['savedAmount'] ?? 0).toDouble(),
      isAchieved: json['isAchieved'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'icon': icon,
      'targetAmount': targetAmount,
      'savedAmount': savedAmount,
      'isAchieved': isAchieved,
    };
  }

  Goal copyWith({
    String? title,
    String? icon,
    double? targetAmount,
    double? savedAmount,
    bool? isAchieved,
  }) {
    return Goal(
      id: id,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      targetAmount: targetAmount ?? this.targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
      isAchieved: isAchieved ?? this.isAchieved,
    );
  }
}
