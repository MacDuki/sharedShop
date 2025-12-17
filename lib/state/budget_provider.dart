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
    // Legacy household for compatibility
    _household = HouseholdModel(
      id: '1',
      name: 'Mi Familia',
      budgetAmount: 500.0,
      budgetPeriod: BudgetPeriod.weekly as dynamic,
      createdAt: DateTime.now(),
    );

    // Initialize with sample budgets
    _budgets = [
      BudgetModel(
        id: 'budget_1',
        name: 'Groceries',
        description: 'Weekly grocery shopping',
        ownerId: 'user1',
        type: BudgetType.personal,
        budgetAmount: 500.0,
        budgetPeriod: BudgetPeriod.weekly,
        createdAt: DateTime.now(),
        iconName: 'local_grocery_store',
        colorHex: '#10B981',
        memberIds: ['user1'],
      ),
      BudgetModel(
        id: 'budget_2',
        name: 'Family Budget',
        description: 'Shared family expenses',
        ownerId: 'user1',
        type: BudgetType.shared,
        budgetAmount: 2000.0,
        budgetPeriod: BudgetPeriod.monthly,
        createdAt: DateTime.now(),
        iconName: 'home',
        colorHex: '#8B5CF6',
        memberIds: ['user1', 'user2'],
      ),
    ];

    // Set first budget as active
    _activeBudget = _budgets.first;

    // Sample shopping items
    _shoppingItems = [
      ShoppingItemModel(
        id: '1',
        budgetId: 'budget_1',
        name: 'Milk',
        estimatedPrice: 2.50,
        category: 'Dairy',
        createdBy: 'user1',
        createdAt: DateTime.now(),
      ),
      ShoppingItemModel(
        id: '2',
        budgetId: 'budget_1',
        name: 'Bread',
        estimatedPrice: 1.50,
        category: 'Bakery',
        createdBy: 'user1',
        createdAt: DateTime.now(),
      ),
      ShoppingItemModel(
        id: '3',
        budgetId: 'budget_2',
        name: 'Eggs',
        estimatedPrice: 3.20,
        category: 'Dairy',
        createdBy: 'user1',
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

      _shoppingItems[index] = item.copyWith(isPurchased: newStatus);

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
      BudgetHistoryModel(
        id: '1',
        budgetId: 'budget_1',
        periodStart: DateTime(now.year, now.month - 2, 1),
        periodEnd: DateTime(now.year, now.month - 2, 7),
        totalSpent: 245.80,
      ),
      BudgetHistoryModel(
        id: '2',
        budgetId: 'budget_1',
        periodStart: DateTime(now.year, now.month - 1, 8),
        periodEnd: DateTime(now.year, now.month - 1, 14),
        totalSpent: 312.50,
      ),
      BudgetHistoryModel(
        id: '3',
        budgetId: 'budget_2',
        periodStart: DateTime(now.year, now.month - 1, 15),
        periodEnd: DateTime(now.year, now.month - 1, 21),
        totalSpent: 487.20,
      ),
    ];
  }

  void _initializeMembers() {
    // Usuario actual
    _currentUser = UserModel(
      id: 'user1',
      name: 'Main User',
      email: 'user@example.com',
      householdId: '1',
      budgetIds: ['budget_1', 'budget_2'],
      activeBudgetId: 'budget_1',
    );

    _householdMembers = [
      _currentUser!,
      UserModel(
        id: 'user2',
        name: 'Maria Garcia',
        email: 'maria@example.com',
        householdId: '1',
        budgetIds: ['budget_2'],
        activeBudgetId: 'budget_2',
      ),
    ];
  }

  void _addNotification({
    required NotificationType type,
    required String title,
    required String description,
    Map<String, dynamic>? metadata,
  }) {
    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      householdId: _household?.id ?? '1',
      budgetId: _activeBudget?.id, // Anclar notificación al presupuesto activo
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
