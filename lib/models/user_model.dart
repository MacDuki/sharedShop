class UserModel {
  final String id;
  final String name;
  final String email;
  final String? householdId;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.householdId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      householdId: json['householdId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email, 'householdId': householdId};
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? householdId,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      householdId: householdId ?? this.householdId,
    );
  }
}
