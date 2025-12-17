class BudgetHistoryModel {
  final String id;
  final String householdId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final double totalSpent;

  BudgetHistoryModel({
    required this.id,
    required this.householdId,
    required this.periodStart,
    required this.periodEnd,
    required this.totalSpent,
  });

  factory BudgetHistoryModel.fromJson(Map<String, dynamic> json) {
    return BudgetHistoryModel(
      id: json['id'] as String,
      householdId: json['householdId'] as String,
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      totalSpent: (json['totalSpent'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'householdId': householdId,
      'periodStart': periodStart.toIso8601String(),
      'periodEnd': periodEnd.toIso8601String(),
      'totalSpent': totalSpent,
    };
  }

  BudgetHistoryModel copyWith({
    String? id,
    String? householdId,
    DateTime? periodStart,
    DateTime? periodEnd,
    double? totalSpent,
  }) {
    return BudgetHistoryModel(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      totalSpent: totalSpent ?? this.totalSpent,
    );
  }
}
