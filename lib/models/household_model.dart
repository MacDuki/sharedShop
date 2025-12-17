enum BudgetPeriod { weekly, monthly, custom }

class HouseholdModel {
  final String id;
  final String name;
  final double budgetAmount;
  final BudgetPeriod budgetPeriod;
  final DateTime createdAt;
  final DateTime? customPeriodStart;
  final DateTime? customPeriodEnd;

  HouseholdModel({
    required this.id,
    required this.name,
    required this.budgetAmount,
    required this.budgetPeriod,
    required this.createdAt,
    this.customPeriodStart,
    this.customPeriodEnd,
  });

  factory HouseholdModel.fromJson(Map<String, dynamic> json) {
    return HouseholdModel(
      id: json['id'] as String,
      name: json['name'] as String,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'budgetAmount': budgetAmount,
      'budgetPeriod': budgetPeriod.name,
      'createdAt': createdAt.toIso8601String(),
      'customPeriodStart': customPeriodStart?.toIso8601String(),
      'customPeriodEnd': customPeriodEnd?.toIso8601String(),
    };
  }

  HouseholdModel copyWith({
    String? id,
    String? name,
    double? budgetAmount,
    BudgetPeriod? budgetPeriod,
    DateTime? createdAt,
    DateTime? customPeriodStart,
    DateTime? customPeriodEnd,
  }) {
    return HouseholdModel(
      id: id ?? this.id,
      name: name ?? this.name,
      budgetAmount: budgetAmount ?? this.budgetAmount,
      budgetPeriod: budgetPeriod ?? this.budgetPeriod,
      createdAt: createdAt ?? this.createdAt,
      customPeriodStart: customPeriodStart ?? this.customPeriodStart,
      customPeriodEnd: customPeriodEnd ?? this.customPeriodEnd,
    );
  }
}
