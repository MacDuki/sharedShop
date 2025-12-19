class NotificationModel {
  final String id;
  final String householdId;
  final String? budgetId; // Nuevo campo para anclar por presupuesto
  final String? userId; // Usuario que realizó la acción
  final String? userName; // Nombre del usuario
  final String? userPhotoUrl; // URL de la foto del usuario
  final NotificationType type;
  final String title;
  final String description;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  NotificationModel({
    required this.id,
    required this.householdId,
    this.budgetId,
    this.userId,
    this.userName,
    this.userPhotoUrl,
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
      budgetId: json['budgetId'] as String?,
      userId: json['userId'] as String?,
      userName: json['userName'] as String?,
      userPhotoUrl: json['userPhotoUrl'] as String?,
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
      'budgetId': budgetId,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
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
    String? budgetId,
    String? userId,
    String? userName,
    String? userPhotoUrl,
    NotificationType? type,
    String? title,
    String? description,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      budgetId: budgetId ?? this.budgetId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
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
  memberRemoved,
  itemAdded,
  itemDeleted,
  budgetExceeded,
  budgetWarning,
}
