enum MemberRole { owner, member }

class BudgetMemberModel {
  final String budgetId;
  final String userId;
  final MemberRole role;
  final DateTime joinedAt;
  final bool canEdit;
  final bool canInvite;

  BudgetMemberModel({
    required this.budgetId,
    required this.userId,
    required this.role,
    required this.joinedAt,
    this.canEdit = false,
    this.canInvite = false,
  });

  factory BudgetMemberModel.fromJson(Map<String, dynamic> json) {
    return BudgetMemberModel(
      budgetId: json['budgetId'] as String,
      userId: json['userId'] as String,
      role: MemberRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => MemberRole.member,
      ),
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      canEdit: json['canEdit'] as bool? ?? false,
      canInvite: json['canInvite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'budgetId': budgetId,
      'userId': userId,
      'role': role.name,
      'joinedAt': joinedAt.toIso8601String(),
      'canEdit': canEdit,
      'canInvite': canInvite,
    };
  }

  BudgetMemberModel copyWith({
    String? budgetId,
    String? userId,
    MemberRole? role,
    DateTime? joinedAt,
    bool? canEdit,
    bool? canInvite,
  }) {
    return BudgetMemberModel(
      budgetId: budgetId ?? this.budgetId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      canEdit: canEdit ?? this.canEdit,
      canInvite: canInvite ?? this.canInvite,
    );
  }
}
