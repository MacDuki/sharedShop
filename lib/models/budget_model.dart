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
    );
  }
}
