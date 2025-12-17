class NotificationModel {
  final String id;
  final String householdId;
  final NotificationType type;
  final String title;
  final String description;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  NotificationModel({
    required this.id,
    required this.householdId,
    required this.type,
    required this.title,
    required this.description,
    required this.createdAt,
    this.metadata,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      householdId: json['householdId'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == 'NotificationType.${json['type']}',
      ),
      title: json['title'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'householdId': householdId,
      'type': type.toString().split('.').last,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? householdId,
    NotificationType? type,
    String? title,
    String? description,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }
}

enum NotificationType {
  budgetUpdated,
  memberAdded,
  itemAdded,
  itemDeleted,
  budgetExceeded,
  budgetWarning,
}
