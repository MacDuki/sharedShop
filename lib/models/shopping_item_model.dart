class ShoppingItemModel {
  final String id;
  final String householdId;
  final String name;
  final double estimatedPrice;
  final String? category;
  final String createdBy;
  final DateTime createdAt;
  final bool isPurchased;

  ShoppingItemModel({
    required this.id,
    required this.householdId,
    required this.name,
    required this.estimatedPrice,
    this.category,
    required this.createdBy,
    required this.createdAt,
    this.isPurchased = false,
  });

  factory ShoppingItemModel.fromJson(Map<String, dynamic> json) {
    return ShoppingItemModel(
      id: json['id'] as String,
      householdId: json['householdId'] as String,
      name: json['name'] as String,
      estimatedPrice: (json['estimatedPrice'] as num).toDouble(),
      category: json['category'] as String?,
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isPurchased: json['isPurchased'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'householdId': householdId,
      'name': name,
      'estimatedPrice': estimatedPrice,
      'category': category,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'isPurchased': isPurchased,
    };
  }

  ShoppingItemModel copyWith({
    String? id,
    String? householdId,
    String? name,
    double? estimatedPrice,
    String? category,
    String? createdBy,
    DateTime? createdAt,
    bool? isPurchased,
  }) {
    return ShoppingItemModel(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      name: name ?? this.name,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      category: category ?? this.category,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      isPurchased: isPurchased ?? this.isPurchased,
    );
  }
}
