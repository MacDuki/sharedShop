class UserModel {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final String? householdId; // Legacy support
  final List<String> budgetIds;
  final String? activeBudgetId;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.householdId,
    this.budgetIds = const [],
    this.activeBudgetId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      photoUrl: json['photoUrl'] as String?,
      householdId: json['householdId'] as String?,
      budgetIds:
          (json['budgetIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      activeBudgetId: json['activeBudgetId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'householdId': householdId,
      'budgetIds': budgetIds,
      'activeBudgetId': activeBudgetId,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    String? householdId,
    List<String>? budgetIds,
    String? activeBudgetId,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      householdId: householdId ?? this.householdId,
      budgetIds: budgetIds ?? this.budgetIds,
      activeBudgetId: activeBudgetId ?? this.activeBudgetId,
    );
  }
}
