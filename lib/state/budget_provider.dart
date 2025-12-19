import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/models.dart';

class BudgetProvider extends ChangeNotifier {
  // Legacy support
  HouseholdModel? _household;

  // Current user
  UserModel? _currentUser;

  // New multi-budget support
  List<BudgetModel> _budgets = [];
  BudgetModel? _activeBudget;

  List<ShoppingItemModel> _shoppingItems = [];
  List<BudgetHistoryModel> _budgetHistory = [];
  List<UserModel> _householdMembers = [];
  List<NotificationModel> _notifications = [];

  // Getters - Legacy
  HouseholdModel? get household => _household;

  // Getters - New
  UserModel? get currentUser => _currentUser;
  List<BudgetModel> get budgets => List.unmodifiable(_budgets);
  BudgetModel? get activeBudget => _activeBudget;

  List<ShoppingItemModel> get shoppingItems {
    // Filter items by active budget
    if (_activeBudget != null) {
      return List.unmodifiable(
        _shoppingItems.where((item) => item.budgetId == _activeBudget!.id),
      );
    }
    return List.unmodifiable(_shoppingItems);
  }

  List<BudgetHistoryModel> get budgetHistory {
    // Filter history by active budget
    if (_activeBudget != null) {
      return List.unmodifiable(
        _budgetHistory.where(
          (history) => history.budgetId == _activeBudget!.id,
        ),
      );
    }
    return List.unmodifiable(_budgetHistory);
  }

  List<UserModel> get householdMembers => List.unmodifiable(_householdMembers);

  // Notificaciones filtradas por presupuesto activo (para dashboard)
  List<NotificationModel> get notifications {
    if (_activeBudget != null) {
      return List.unmodifiable(
        _notifications.where(
          (notification) => notification.budgetId == _activeBudget!.id,
        ),
      );
    }
    return List.unmodifiable(_notifications);
  }

  // Todas las notificaciones sin filtrar (para pantalla see all)
  List<NotificationModel> get allNotifications =>
      List.unmodifiable(_notifications);

  // Budget calculations based on active budget
  double get totalSpent {
    if (_activeBudget == null) return 0.0;
    return _shoppingItems
        .where((item) => item.budgetId == _activeBudget!.id)
        .fold(0.0, (sum, item) => sum + item.estimatedPrice);
  }

  double get remainingBudget {
    if (_activeBudget == null) return 0.0;
    return _activeBudget!.budgetAmount - totalSpent;
  }

  double get budgetPercentage {
    if (_activeBudget == null || _activeBudget!.budgetAmount == 0) return 0.0;
    return (totalSpent / _activeBudget!.budgetAmount) * 100;
  }

  BudgetState get budgetState {
    final percentage = budgetPercentage;
    if (percentage > 100) return BudgetState.exceeded;
    if (percentage >= 70) return BudgetState.warning;
    return BudgetState.normal;
  }

  // Initialize with sample data
  void initializeHousehold() {
    // Obtener el ID del usuario actual (Firebase o fallback)
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final currentUserId = firebaseUser?.uid ?? 'user1';

    // Legacy household for compatibility
    _household = HouseholdModel(
      id: '1',
      name: 'Mi Familia',
      budgetAmount: 500.0,
      budgetPeriod: BudgetPeriod.weekly as dynamic,
      createdAt: DateTime.now(),
    );

    // IDs de usuarios ficticios para presupuestos compartidos
    const user2Id = 'member_maria_garcia';
    const user3Id = 'member_juan_lopez';
    const user4Id = 'member_ana_martinez';
    const user5Id = 'member_carlos_rodriguez';

    // Initialize with sample budgets
    _budgets = [
      // 1. Presupuesto Personal con varios items
      BudgetModel(
        id: 'budget_personal',
        name: 'My Personal Budget',
        description: 'Personal expenses and shopping',
        ownerId: currentUserId,
        type: BudgetType.personal,
        budgetAmount: 800.0,
        budgetPeriod: BudgetPeriod.weekly,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        iconName: 'account_balance_wallet',
        colorHex: '#10B981',
        memberIds: [currentUserId],
      ),
      // 2. Presupuesto Grupal donde SOY el owner con 4+ miembros
      BudgetModel(
        id: 'budget_family',
        name: 'Family Budget',
        description: 'Shared family expenses and groceries',
        ownerId: currentUserId,
        type: BudgetType.shared,
        budgetAmount: 3500.0,
        budgetPeriod: BudgetPeriod.monthly,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        iconName: 'home',
        colorHex: '#8B5CF6',
        memberIds: [currentUserId, user2Id, user3Id, user4Id, user5Id],
      ),
      // 3. Presupuesto Grupal donde NO soy el owner
      BudgetModel(
        id: 'budget_roommates',
        name: 'Roommates Expenses',
        description: 'Shared apartment utilities and supplies',
        ownerId: user2Id, // Maria es la owner
        type: BudgetType.shared,
        budgetAmount: 1200.0,
        budgetPeriod: BudgetPeriod.monthly,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        iconName: 'people',
        colorHex: '#F59E0B',
        memberIds: [user2Id, currentUserId, user3Id],
      ),
    ];

    // Set first budget as active
    _activeBudget = _budgets.first;

    // Sample shopping items distribuidos entre los 3 presupuestos
    _shoppingItems = [
      // Items del presupuesto PERSONAL
      ShoppingItemModel(
        id: 'item_p1',
        budgetId: 'budget_personal',
        name: 'Coffee',
        estimatedPrice: 12.99,
        category: 'Beverages',
        createdBy: currentUserId,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      ShoppingItemModel(
        id: 'item_p2',
        budgetId: 'budget_personal',
        name: 'Cereal',
        estimatedPrice: 5.49,
        category: 'Breakfast',
        createdBy: currentUserId,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      ShoppingItemModel(
        id: 'item_p3',
        budgetId: 'budget_personal',
        name: 'Yogurt',
        estimatedPrice: 4.25,
        category: 'Dairy',
        createdBy: currentUserId,
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        isPurchased: true,
        purchasedBy: currentUserId,
        purchasedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      ShoppingItemModel(
        id: 'item_p4',
        budgetId: 'budget_personal',
        name: 'Orange Juice',
        estimatedPrice: 6.99,
        category: 'Beverages',
        createdBy: currentUserId,
        createdAt: DateTime.now(),
      ),
      ShoppingItemModel(
        id: 'item_p5',
        budgetId: 'budget_personal',
        name: 'Protein Bars',
        estimatedPrice: 15.99,
        category: 'Snacks',
        createdBy: currentUserId,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),

      // Items del presupuesto FAMILIAR (donde soy owner)
      ShoppingItemModel(
        id: 'item_f1',
        budgetId: 'budget_family',
        name: 'Milk',
        estimatedPrice: 3.50,
        category: 'Dairy',
        createdBy: currentUserId,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      ShoppingItemModel(
        id: 'item_f2',
        budgetId: 'budget_family',
        name: 'Bread',
        estimatedPrice: 2.99,
        category: 'Bakery',
        createdBy: user2Id,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        isPurchased: true,
        purchasedBy: user3Id,
        purchasedAt: DateTime.now().subtract(
          const Duration(days: 1, hours: 12),
        ),
      ),
      ShoppingItemModel(
        id: 'item_f3',
        budgetId: 'budget_family',
        name: 'Eggs (Dozen)',
        estimatedPrice: 4.50,
        category: 'Dairy',
        createdBy: currentUserId,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      ShoppingItemModel(
        id: 'item_f4',
        budgetId: 'budget_family',
        name: 'Chicken Breast',
        estimatedPrice: 18.99,
        category: 'Meat',
        createdBy: user3Id,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      ShoppingItemModel(
        id: 'item_f5',
        budgetId: 'budget_family',
        name: 'Rice (5kg)',
        estimatedPrice: 12.49,
        category: 'Grains',
        createdBy: currentUserId,
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      ShoppingItemModel(
        id: 'item_f6',
        budgetId: 'budget_family',
        name: 'Tomatoes',
        estimatedPrice: 5.99,
        category: 'Vegetables',
        createdBy: user2Id,
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
      ShoppingItemModel(
        id: 'item_f7',
        budgetId: 'budget_family',
        name: 'Pasta',
        estimatedPrice: 3.25,
        category: 'Grains',
        createdBy: currentUserId,
        createdAt: DateTime.now(),
      ),
      ShoppingItemModel(
        id: 'item_f8',
        budgetId: 'budget_family',
        name: 'Olive Oil',
        estimatedPrice: 9.99,
        category: 'Cooking',
        createdBy: user3Id,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        isPurchased: true,
        purchasedBy: currentUserId,
        purchasedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),

      // Items del presupuesto ROOMMATES (donde NO soy owner)
      ShoppingItemModel(
        id: 'item_r1',
        budgetId: 'budget_roommates',
        name: 'Toilet Paper',
        estimatedPrice: 12.99,
        category: 'Household',
        createdBy: user2Id,
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      ShoppingItemModel(
        id: 'item_r2',
        budgetId: 'budget_roommates',
        name: 'Dish Soap',
        estimatedPrice: 4.49,
        category: 'Cleaning',
        createdBy: currentUserId,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        isPurchased: true,
        purchasedBy: user2Id,
        purchasedAt: DateTime.now().subtract(const Duration(days: 2, hours: 8)),
      ),
      ShoppingItemModel(
        id: 'item_r3',
        budgetId: 'budget_roommates',
        name: 'Paper Towels',
        estimatedPrice: 8.99,
        category: 'Household',
        createdBy: user3Id,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      ShoppingItemModel(
        id: 'item_r4',
        budgetId: 'budget_roommates',
        name: 'Trash Bags',
        estimatedPrice: 11.49,
        category: 'Household',
        createdBy: user2Id,
        createdAt: DateTime.now().subtract(const Duration(hours: 10)),
      ),
      ShoppingItemModel(
        id: 'item_r5',
        budgetId: 'budget_roommates',
        name: 'Laundry Detergent',
        estimatedPrice: 13.99,
        category: 'Cleaning',
        createdBy: currentUserId,
        createdAt: DateTime.now(),
      ),
    ];

    _initializeHistory();
    _initializeMembers();

    notifyListeners();
  }

  // Budget Management
  void addBudget(BudgetModel budget) {
    _budgets.add(budget);
    // Set as active if it's the first budget
    if (_budgets.length == 1) {
      _activeBudget = budget;
    }
    notifyListeners();
  }

  void updateBudgetData(BudgetModel updatedBudget) {
    final index = _budgets.indexWhere((b) => b.id == updatedBudget.id);
    if (index != -1) {
      final oldBudget = _budgets[index];

      // Detectar cambios y generar notificaciones
      if (oldBudget.name != updatedBudget.name) {
        _addNotification(
          type: NotificationType.budgetUpdated,
          title: 'Budget name updated',
          description: 'From "${oldBudget.name}" to "${updatedBudget.name}"',
        );
      }

      if (oldBudget.budgetAmount != updatedBudget.budgetAmount) {
        _addNotification(
          type: NotificationType.budgetUpdated,
          title: 'Budget amount updated',
          description:
              'From \$${oldBudget.budgetAmount.toStringAsFixed(2)} to \$${updatedBudget.budgetAmount.toStringAsFixed(2)}',
        );
      }

      if (oldBudget.iconName != updatedBudget.iconName) {
        _addNotification(
          type: NotificationType.budgetUpdated,
          title: 'Budget icon updated',
          description: 'Icon changed for "${updatedBudget.name}"',
        );
      }

      if (oldBudget.colorHex != updatedBudget.colorHex) {
        _addNotification(
          type: NotificationType.budgetUpdated,
          title: 'Budget color updated',
          description: 'Color changed for "${updatedBudget.name}"',
        );
      }

      if (oldBudget.budgetPeriod != updatedBudget.budgetPeriod) {
        _addNotification(
          type: NotificationType.budgetUpdated,
          title: 'Budget period updated',
          description: 'Period changed for "${updatedBudget.name}"',
        );
      }

      if (oldBudget.type != updatedBudget.type) {
        _addNotification(
          type: NotificationType.budgetUpdated,
          title: 'Budget type updated',
          description:
              'Changed from ${oldBudget.type.name} to ${updatedBudget.type.name}',
        );
      }

      _budgets[index] = updatedBudget;
      // Update active budget if it's the one being edited
      if (_activeBudget?.id == updatedBudget.id) {
        _activeBudget = updatedBudget;
      }
      notifyListeners();
    }
  }

  void deleteBudget(String budgetId) {
    _budgets.removeWhere((b) => b.id == budgetId);
    // If active budget was deleted, set another as active
    if (_activeBudget?.id == budgetId) {
      _activeBudget = _budgets.isNotEmpty ? _budgets.first : null;
    }
    // Remove associated items
    _shoppingItems.removeWhere((item) => item.budgetId == budgetId);
    _budgetHistory.removeWhere((history) => history.budgetId == budgetId);
    notifyListeners();
  }

  void setActiveBudget(String budgetId) {
    final budget = _budgets.firstWhere(
      (b) => b.id == budgetId,
      orElse: () => _budgets.first,
    );
    _activeBudget = budget;
    notifyListeners();
  }

  // Get items for a specific budget
  List<ShoppingItemModel> getItemsForBudget(String budgetId) {
    return _shoppingItems.where((item) => item.budgetId == budgetId).toList();
  }

  // Shopping Item Management
  void addItem(ShoppingItemModel item) {
    _shoppingItems.add(item);

    _addNotification(
      type: NotificationType.itemAdded,
      title: 'New item added',
      description: '${item.name} - \$${item.estimatedPrice.toStringAsFixed(2)}',
      metadata: {'itemId': item.id, 'itemName': item.name},
    );

    notifyListeners();
  }

  void updateItem(String itemId, ShoppingItemModel updatedItem) {
    final index = _shoppingItems.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      _shoppingItems[index] = updatedItem;

      _addNotification(
        type: NotificationType.itemAdded,
        title: 'Item updated',
        description:
            '${updatedItem.name} - \$${updatedItem.estimatedPrice.toStringAsFixed(2)}',
        metadata: {'itemId': updatedItem.id, 'itemName': updatedItem.name},
      );

      notifyListeners();
    }
  }

  void deleteItem(String itemId) {
    final item = _shoppingItems.firstWhere((item) => item.id == itemId);
    _shoppingItems.removeWhere((item) => item.id == itemId);

    _addNotification(
      type: NotificationType.itemDeleted,
      title: 'Item deleted',
      description: '${item.name} was removed from the list',
      metadata: {'itemId': item.id, 'itemName': item.name},
    );

    notifyListeners();
  }

  void toggleItemPurchased(String itemId) {
    final index = _shoppingItems.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      final item = _shoppingItems[index];
      final newStatus = !item.isPurchased;
      final firebaseUser = FirebaseAuth.instance.currentUser;

      _shoppingItems[index] = item.copyWith(
        isPurchased: newStatus,
        purchasedBy: newStatus ? (firebaseUser?.uid ?? _currentUser?.id) : null,
        purchasedAt: newStatus ? DateTime.now() : null,
      );

      if (newStatus) {
        _addNotification(
          type: NotificationType.itemAdded,
          title: 'Purchase completed',
          description:
              '${item.name} marked as purchased - \$${item.estimatedPrice.toStringAsFixed(2)}',
          metadata: {
            'itemId': item.id,
            'itemName': item.name,
            'isPurchased': true,
          },
        );
      }

      notifyListeners();
    }
  }

  // Legacy budget update (for compatibility)
  void updateBudget({
    required double budgetAmount,
    required BudgetPeriod budgetPeriod,
    DateTime? customPeriodStart,
    DateTime? customPeriodEnd,
  }) {
    if (_household != null) {
      final oldAmount = _household!.budgetAmount;
      _household = _household!.copyWith(
        budgetAmount: budgetAmount,
        budgetPeriod: budgetPeriod as dynamic,
        customPeriodStart: customPeriodStart,
        customPeriodEnd: customPeriodEnd,
      );

      // Also update active budget if exists
      if (_activeBudget != null) {
        final updatedBudget = _activeBudget!.copyWith(
          budgetAmount: budgetAmount,
          budgetPeriod: budgetPeriod,
          customPeriodStart: customPeriodStart,
          customPeriodEnd: customPeriodEnd,
        );
        updateBudgetData(updatedBudget);
      }

      _addNotification(
        type: NotificationType.budgetUpdated,
        title: 'Budget updated',
        description:
            'From \$${oldAmount.toStringAsFixed(2)} to \$${budgetAmount.toStringAsFixed(2)}',
        metadata: {
          'oldAmount': oldAmount,
          'newAmount': budgetAmount,
          'period': budgetPeriod.toString(),
        },
      );

      notifyListeners();
    }
  }

  void updateHouseholdName(String newName) {
    if (_household != null) {
      _household = _household!.copyWith(name: newName);
      notifyListeners();
    }
  }

  void deleteBudgetHistory(String historyId) {
    _budgetHistory.removeWhere((history) => history.id == historyId);
    notifyListeners();
  }

  void _initializeHistory() {
    final now = DateTime.now();
    _budgetHistory = [
      // Historial del presupuesto PERSONAL
      BudgetHistoryModel(
        id: 'hist_p1',
        budgetId: 'budget_personal',
        periodStart: DateTime(now.year, now.month - 2, 1),
        periodEnd: DateTime(now.year, now.month - 2, 7),
        totalSpent: 456.75,
      ),
      BudgetHistoryModel(
        id: 'hist_p2',
        budgetId: 'budget_personal',
        periodStart: DateTime(now.year, now.month - 1, 8),
        periodEnd: DateTime(now.year, now.month - 1, 14),
        totalSpent: 523.40,
      ),
      BudgetHistoryModel(
        id: 'hist_p3',
        budgetId: 'budget_personal',
        periodStart: DateTime(now.year, now.month - 1, 15),
        periodEnd: DateTime(now.year, now.month - 1, 21),
        totalSpent: 687.90,
      ),

      // Historial del presupuesto FAMILIAR (donde soy owner)
      BudgetHistoryModel(
        id: 'hist_f1',
        budgetId: 'budget_family',
        periodStart: DateTime(now.year, now.month - 3, 1),
        periodEnd: DateTime(now.year, now.month - 2, 30),
        totalSpent: 2845.30,
      ),
      BudgetHistoryModel(
        id: 'hist_f2',
        budgetId: 'budget_family',
        periodStart: DateTime(now.year, now.month - 2, 1),
        periodEnd: DateTime(now.year, now.month - 1, 30),
        totalSpent: 3156.80,
      ),
      BudgetHistoryModel(
        id: 'hist_f3',
        budgetId: 'budget_family',
        periodStart: DateTime(now.year, now.month - 1, 1),
        periodEnd: DateTime(now.year, now.month, 1),
        totalSpent: 2923.45,
      ),

      // Historial del presupuesto ROOMMATES (donde NO soy owner)
      BudgetHistoryModel(
        id: 'hist_r1',
        budgetId: 'budget_roommates',
        periodStart: DateTime(now.year, now.month - 3, 1),
        periodEnd: DateTime(now.year, now.month - 2, 30),
        totalSpent: 987.60,
      ),
      BudgetHistoryModel(
        id: 'hist_r2',
        budgetId: 'budget_roommates',
        periodStart: DateTime(now.year, now.month - 2, 1),
        periodEnd: DateTime(now.year, now.month - 1, 30),
        totalSpent: 1045.25,
      ),
      BudgetHistoryModel(
        id: 'hist_r3',
        budgetId: 'budget_roommates',
        periodStart: DateTime(now.year, now.month - 1, 1),
        periodEnd: DateTime(now.year, now.month, 1),
        totalSpent: 1123.75,
      ),
    ];
  }

  void _initializeMembers() {
    // Obtener usuario actual de Firebase Auth
    final firebaseUser = FirebaseAuth.instance.currentUser;

    // Obtener IDs de los presupuestos creados
    final userBudgetIds = _budgets.map((b) => b.id).toList();
    final firstBudgetId = _budgets.isNotEmpty ? _budgets.first.id : null;
    final householdId = _household?.id ?? '1';

    if (firebaseUser != null) {
      _currentUser = UserModel(
        id: firebaseUser.uid,
        name: firebaseUser.displayName ?? 'Usuario',
        email: firebaseUser.email ?? 'email@ejemplo.com',
        householdId: householdId,
        budgetIds: userBudgetIds,
        activeBudgetId: firstBudgetId,
      );
    } else {
      // Fallback si no hay usuario autenticado
      _currentUser = UserModel(
        id: 'user1',
        name: 'Main User',
        email: 'user@example.com',
        householdId: householdId,
        budgetIds: userBudgetIds,
        activeBudgetId: firstBudgetId,
      );
    }

    // Crear miembros ficticios para los presupuestos compartidos
    _householdMembers = [
      _currentUser!,
      UserModel(
        id: 'member_maria_garcia',
        name: 'Maria Garcia',
        email: 'maria.garcia@example.com',
        householdId: householdId,
        budgetIds: ['budget_family', 'budget_roommates'],
        activeBudgetId: 'budget_roommates',
      ),
      UserModel(
        id: 'member_juan_lopez',
        name: 'Juan Lopez',
        email: 'juan.lopez@example.com',
        householdId: householdId,
        budgetIds: ['budget_family', 'budget_roommates'],
        activeBudgetId: 'budget_family',
      ),
      UserModel(
        id: 'member_ana_martinez',
        name: 'Ana Martinez',
        email: 'ana.martinez@example.com',
        householdId: householdId,
        budgetIds: ['budget_family'],
        activeBudgetId: 'budget_family',
      ),
      UserModel(
        id: 'member_carlos_rodriguez',
        name: 'Carlos Rodriguez',
        email: 'carlos.rodriguez@example.com',
        householdId: householdId,
        budgetIds: ['budget_family'],
        activeBudgetId: 'budget_family',
      ),
    ];
  }

  void _addNotification({
    required NotificationType type,
    required String title,
    required String description,
    Map<String, dynamic>? metadata,
  }) {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      householdId: _household?.id ?? '1',
      budgetId: _activeBudget?.id, // Anclar notificación al presupuesto activo
      userId: firebaseUser?.uid ?? _currentUser?.id,
      userName: firebaseUser?.displayName ?? _currentUser?.name ?? 'Usuario',
      userPhotoUrl: firebaseUser?.photoURL,
      type: type,
      title: title,
      description: description,
      createdAt: DateTime.now(),
      metadata: metadata,
    );

    _notifications.insert(0, notification);

    if (_notifications.length > 50) {
      _notifications = _notifications.sublist(0, 50);
    }
  }

  void deleteNotification(String notificationId) {
    _notifications.removeWhere(
      (notification) => notification.id == notificationId,
    );
    notifyListeners();
  }

  // Método público para agregar notificación de miembro eliminado
  void addMemberRemovedNotification(String memberName, String budgetName) {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      householdId: _household?.id ?? '1',
      budgetId: _activeBudget?.id,
      userId: firebaseUser?.uid ?? _currentUser?.id,
      userName: firebaseUser?.displayName ?? _currentUser?.name ?? 'Usuario',
      userPhotoUrl: firebaseUser?.photoURL,
      type: NotificationType.memberRemoved,
      title: 'Miembro eliminado',
      description: '$memberName fue eliminado del presupuesto "$budgetName"',
      createdAt: DateTime.now(),
    );

    _notifications.insert(0, notification);

    if (_notifications.length > 50) {
      _notifications = _notifications.sublist(0, 50);
    }

    notifyListeners();
  }

  void clearAllNotifications() {
    // Solo eliminar notificaciones del presupuesto activo
    if (_activeBudget != null) {
      _notifications.removeWhere(
        (notification) => notification.budgetId == _activeBudget!.id,
      );
    } else {
      _notifications.clear();
    }
    notifyListeners();
  }
}

enum BudgetState {
  normal, // < 70%
  warning, // 70-100%
  exceeded, // > 100%
}
