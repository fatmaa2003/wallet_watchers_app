class Participant {
  final String userId;
  final String name;
  final double savedAmount;
  final String status; // "pending", "accepted", "rejected"

  Participant({
    required this.userId,
    required this.name,
    required this.savedAmount,
    required this.status,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    final dynamic userJson = json['userId'];
    final String userId;
    final String name;

    // Handle both nested user object and flat string userId
    if (userJson is Map<String, dynamic>) {
      userId = userJson['_id'];
      name = "${userJson['firstName']} ${userJson['lastName']}";
    } else {
      userId = userJson.toString();
      name = "Unknown";
    }

    return Participant(
      userId: userId,
      name: name,
      savedAmount: (json['savedAmount'] as num).toDouble(),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'savedAmount': savedAmount,
      'status': status,
    };
  }
}

class CollaborativeGoal {
  final String id;
  final String title;
  final double totalTargetPerUser;
  final String createdBy;
  final List<Participant> participants;

  CollaborativeGoal({
    required this.id,
    required this.title,
    required this.totalTargetPerUser,
    required this.createdBy,
    required this.participants,
  });

  factory CollaborativeGoal.fromJson(Map<String, dynamic> json) {
    return CollaborativeGoal(
      id: json['_id'],
      title: json['title'],
      totalTargetPerUser: (json['totalTargetPerUser'] as num).toDouble(),
      createdBy: json['createdBy'],
      participants: (json['participants'] as List)
          .map((p) => Participant.fromJson(p))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'totalTargetPerUser': totalTargetPerUser,
      'createdBy': createdBy,
      'participants': participants.map((p) => p.toJson()).toList(),
    };
  }
}
