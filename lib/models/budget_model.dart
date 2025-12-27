enum BudgetType { personal, shared }

enum BudgetPeriod { weekly, monthly, custom }

class BudgetModel {
  final String id;
  final String name;
  final String? description;
  final String ownerId;
  final BudgetType type;
  final double budgetAmount;
  final BudgetPeriod budgetPeriod;
  final DateTime createdAt;
  final DateTime? customPeriodStart;
  final DateTime? customPeriodEnd;
  final String? iconName;
  final String? colorHex;
  final List<String> memberIds;
  final bool isActive;

  // Calculated fields from backend
  final double? totalSpent;
  final double? remaining;
  final double? percentageUsed;
  final String? status;
  final int? daysRemaining;

  BudgetModel({
    required this.id,
    required this.name,
    this.description,
    required this.ownerId,
    required this.type,
    required this.budgetAmount,
    required this.budgetPeriod,
    required this.createdAt,
    this.customPeriodStart,
    this.customPeriodEnd,
    this.iconName,
    this.colorHex,
    this.memberIds = const [],
    this.isActive = true,
    this.totalSpent,
    this.remaining,
    this.percentageUsed,
    this.status,
    this.daysRemaining,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      ownerId: json['ownerId'] as String,
      type: BudgetType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => BudgetType.personal,
      ),
      budgetAmount: (json['budgetAmount'] as num).toDouble(),
      budgetPeriod: BudgetPeriod.values.firstWhere(
        (e) => e.name == json['budgetPeriod'],
        orElse: () => BudgetPeriod.monthly,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      customPeriodStart:
          json['customPeriodStart'] != null
              ? DateTime.parse(json['customPeriodStart'] as String)
              : null,
      customPeriodEnd:
          json['customPeriodEnd'] != null
              ? DateTime.parse(json['customPeriodEnd'] as String)
              : null,
      iconName: json['iconName'] as String?,
      colorHex: json['colorHex'] as String?,
      memberIds:
          (json['memberIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isActive: json['isActive'] as bool? ?? true,
      totalSpent:
          json['totalSpent'] != null
              ? (json['totalSpent'] as num).toDouble()
              : null,
      remaining:
          json['remaining'] != null
              ? (json['remaining'] as num).toDouble()
              : null,
      percentageUsed:
          json['percentageUsed'] != null
              ? (json['percentageUsed'] as num).toDouble()
              : null,
      status: json['status'] as String?,
      daysRemaining: json['daysRemaining'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ownerId': ownerId,
      'type': type.name,
      'budgetAmount': budgetAmount,
      'budgetPeriod': budgetPeriod.name,
      'createdAt': createdAt.toIso8601String(),
      'customPeriodStart': customPeriodStart?.toIso8601String(),
      'customPeriodEnd': customPeriodEnd?.toIso8601String(),
      'iconName': iconName,
      'colorHex': colorHex,
      'memberIds': memberIds,
      'isActive': isActive,
      'totalSpent': totalSpent,
      'remaining': remaining,
      'percentageUsed': percentageUsed,
      'status': status,
      'daysRemaining': daysRemaining,
    };
  }

  BudgetModel copyWith({
    String? id,
    String? name,
    String? description,
    String? ownerId,
    BudgetType? type,
    double? budgetAmount,
    BudgetPeriod? budgetPeriod,
    DateTime? createdAt,
    DateTime? customPeriodStart,
    DateTime? customPeriodEnd,
    String? iconName,
    String? colorHex,
    List<String>? memberIds,
    bool? isActive,
    double? totalSpent,
    double? remaining,
    double? percentageUsed,
    String? status,
    int? daysRemaining,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      type: type ?? this.type,
      budgetAmount: budgetAmount ?? this.budgetAmount,
      budgetPeriod: budgetPeriod ?? this.budgetPeriod,
      createdAt: createdAt ?? this.createdAt,
      customPeriodStart: customPeriodStart ?? this.customPeriodStart,
      customPeriodEnd: customPeriodEnd ?? this.customPeriodEnd,
      iconName: iconName ?? this.iconName,
      colorHex: colorHex ?? this.colorHex,
      memberIds: memberIds ?? this.memberIds,
      isActive: isActive ?? this.isActive,
      totalSpent: totalSpent ?? this.totalSpent,
      remaining: remaining ?? this.remaining,
      percentageUsed: percentageUsed ?? this.percentageUsed,
      status: status ?? this.status,
      daysRemaining: daysRemaining ?? this.daysRemaining,
    );
  }
}
