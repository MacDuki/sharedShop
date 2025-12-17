enum InvitationStatus { pending, accepted, rejected, cancelled }

class BudgetInvitationModel {
  final String id;
  final String budgetId;
  final String inviterUserId;
  final String invitedEmail;
  final String? invitedUserId;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final InvitationStatus status;

  BudgetInvitationModel({
    required this.id,
    required this.budgetId,
    required this.inviterUserId,
    required this.invitedEmail,
    this.invitedUserId,
    required this.createdAt,
    this.acceptedAt,
    this.status = InvitationStatus.pending,
  });

  factory BudgetInvitationModel.fromJson(Map<String, dynamic> json) {
    return BudgetInvitationModel(
      id: json['id'] as String,
      budgetId: json['budgetId'] as String,
      inviterUserId: json['inviterUserId'] as String,
      invitedEmail: json['invitedEmail'] as String,
      invitedUserId: json['invitedUserId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      acceptedAt:
          json['acceptedAt'] != null
              ? DateTime.parse(json['acceptedAt'] as String)
              : null,
      status: InvitationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => InvitationStatus.pending,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'budgetId': budgetId,
      'inviterUserId': inviterUserId,
      'invitedEmail': invitedEmail,
      'invitedUserId': invitedUserId,
      'createdAt': createdAt.toIso8601String(),
      'acceptedAt': acceptedAt?.toIso8601String(),
      'status': status.name,
    };
  }

  BudgetInvitationModel copyWith({
    String? id,
    String? budgetId,
    String? inviterUserId,
    String? invitedEmail,
    String? invitedUserId,
    DateTime? createdAt,
    DateTime? acceptedAt,
    InvitationStatus? status,
  }) {
    return BudgetInvitationModel(
      id: id ?? this.id,
      budgetId: budgetId ?? this.budgetId,
      inviterUserId: inviterUserId ?? this.inviterUserId,
      invitedEmail: invitedEmail ?? this.invitedEmail,
      invitedUserId: invitedUserId ?? this.invitedUserId,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      status: status ?? this.status,
    );
  }
}
