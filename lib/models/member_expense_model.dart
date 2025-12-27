class MemberExpenseModel {
  final String userId;
  final String name;
  final String email;
  final String? photoURL;
  final double totalSpent;
  final int itemCount;
  final double percentage;
  final List<ExpenseItemModel> items;

  MemberExpenseModel({
    required this.userId,
    required this.name,
    required this.email,
    this.photoURL,
    required this.totalSpent,
    required this.itemCount,
    required this.percentage,
    required this.items,
  });

  factory MemberExpenseModel.fromJson(Map<String, dynamic> json) {
    return MemberExpenseModel(
      userId: json['userId'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      photoURL: json['photoURL'] as String?,
      totalSpent: (json['totalSpent'] as num).toDouble(),
      itemCount: json['itemCount'] as int,
      percentage: (json['percentage'] as num).toDouble(),
      items:
          (json['items'] as List<dynamic>)
              .map(
                (item) =>
                    ExpenseItemModel.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'photoURL': photoURL,
      'totalSpent': totalSpent,
      'itemCount': itemCount,
      'percentage': percentage,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class ExpenseItemModel {
  final String id;
  final String name;
  final double estimatedPrice;
  final String category;
  final dynamic purchasedAt;

  ExpenseItemModel({
    required this.id,
    required this.name,
    required this.estimatedPrice,
    required this.category,
    this.purchasedAt,
  });

  factory ExpenseItemModel.fromJson(Map<String, dynamic> json) {
    return ExpenseItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      estimatedPrice: (json['estimatedPrice'] as num).toDouble(),
      category: json['category'] as String,
      purchasedAt: json['purchasedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'estimatedPrice': estimatedPrice,
      'category': category,
      'purchasedAt': purchasedAt,
    };
  }
}
