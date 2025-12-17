import 'package:flutter/foundation.dart';

import '../models/models.dart';

class BudgetProvider extends ChangeNotifier {
  // Estado actual
  HouseholdModel? _household;
  List<ShoppingItemModel> _shoppingItems = [];
  List<BudgetHistoryModel> _budgetHistory = [];
  List<UserModel> _householdMembers = [];
  List<NotificationModel> _notifications = [];

  // Getters
  HouseholdModel? get household => _household;
  List<ShoppingItemModel> get shoppingItems =>
      List.unmodifiable(_shoppingItems);
  List<BudgetHistoryModel> get budgetHistory =>
      List.unmodifiable(_budgetHistory);
  List<UserModel> get householdMembers => List.unmodifiable(_householdMembers);
  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);

  // Cálculos del presupuesto
  double get totalSpent {
    return _shoppingItems.fold(0.0, (sum, item) => sum + item.estimatedPrice);
  }

  double get remainingBudget {
    if (_household == null) return 0.0;
    return _household!.budgetAmount - totalSpent;
  }

  double get budgetPercentage {
    if (_household == null || _household!.budgetAmount == 0) return 0.0;
    return (totalSpent / _household!.budgetAmount) * 100;
  }

  // Estado visual del presupuesto
  BudgetState get budgetState {
    final percentage = budgetPercentage;
    if (percentage > 100) return BudgetState.exceeded;
    if (percentage >= 70) return BudgetState.warning;
    return BudgetState.normal;
  }

  // Inicializar household (datos de ejemplo para MVP)
  void initializeHousehold() {
    _household = HouseholdModel(
      id: '1',
      name: 'Mi Familia',
      budgetAmount: 500.0,
      budgetPeriod: BudgetPeriod.weekly,
      createdAt: DateTime.now(),
    );

    // Datos de ejemplo
    _shoppingItems = [
      ShoppingItemModel(
        id: '1',
        householdId: '1',
        name: 'Leche',
        estimatedPrice: 2.50,
        category: 'Lácteos',
        createdBy: 'user1',
        createdAt: DateTime.now(),
      ),
      ShoppingItemModel(
        id: '2',
        householdId: '1',
        name: 'Pan',
        estimatedPrice: 1.50,
        category: 'Panadería',
        createdBy: 'user1',
        createdAt: DateTime.now(),
      ),
      ShoppingItemModel(
        id: '3',
        householdId: '1',
        name: 'Huevos',
        estimatedPrice: 3.20,
        category: 'Lácteos',
        createdBy: 'user1',
        createdAt: DateTime.now(),
      ),
    ];

    _initializeHistory();
    _initializeMembers();

    notifyListeners();
  }

  // Agregar item
  void addItem(ShoppingItemModel item) {
    _shoppingItems.add(item);

    // Crear notificación
    _addNotification(
      type: NotificationType.itemAdded,
      title: 'Nuevo item agregado',
      description: '${item.name} - \$${item.estimatedPrice.toStringAsFixed(2)}',
      metadata: {'itemId': item.id, 'itemName': item.name},
    );

    notifyListeners();
  }

  // Editar item
  void updateItem(String itemId, ShoppingItemModel updatedItem) {
    final index = _shoppingItems.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      _shoppingItems[index] = updatedItem;

      // Crear notificación
      _addNotification(
        type: NotificationType.itemAdded,
        title: 'Item actualizado',
        description:
            '${updatedItem.name} - \$${updatedItem.estimatedPrice.toStringAsFixed(2)}',
        metadata: {'itemId': updatedItem.id, 'itemName': updatedItem.name},
      );

      notifyListeners();
    }
  }

  // Eliminar item
  void deleteItem(String itemId) {
    final item = _shoppingItems.firstWhere((item) => item.id == itemId);
    _shoppingItems.removeWhere((item) => item.id == itemId);

    // Crear notificación
    _addNotification(
      type: NotificationType.itemDeleted,
      title: 'Item eliminado',
      description: '${item.name} fue eliminado de la lista',
      metadata: {'itemId': item.id, 'itemName': item.name},
    );

    notifyListeners();
  }

  // Marcar item como comprado
  void toggleItemPurchased(String itemId) {
    final index = _shoppingItems.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      final item = _shoppingItems[index];
      final newStatus = !item.isPurchased;

      _shoppingItems[index] = item.copyWith(isPurchased: newStatus);

      // Crear notificación
      if (newStatus) {
        _addNotification(
          type: NotificationType.itemAdded,
          title: 'Compra realizada',
          description:
              '${item.name} marcado como comprado - \$${item.estimatedPrice.toStringAsFixed(2)}',
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

  // Actualizar presupuesto
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
        budgetPeriod: budgetPeriod,
        customPeriodStart: customPeriodStart,
        customPeriodEnd: customPeriodEnd,
      );

      // Crear notificación
      _addNotification(
        type: NotificationType.budgetUpdated,
        title: 'Presupuesto actualizado',
        description:
            'De \$${oldAmount.toStringAsFixed(2)} a \$${budgetAmount.toStringAsFixed(2)}',
        metadata: {
          'oldAmount': oldAmount,
          'newAmount': budgetAmount,
          'period': budgetPeriod.toString(),
        },
      );

      notifyListeners();
    }
  }

  // Actualizar nombre del household
  void updateHouseholdName(String newName) {
    if (_household != null) {
      _household = _household!.copyWith(name: newName);
      notifyListeners();
    }
  }

  // Eliminar período del historial
  void deleteBudgetHistory(String historyId) {
    _budgetHistory.removeWhere((history) => history.id == historyId);
    notifyListeners();
  }

  // Agregar historial (datos de ejemplo para MVP)
  void _initializeHistory() {
    final now = DateTime.now();
    _budgetHistory = [
      BudgetHistoryModel(
        id: '1',
        householdId: '1',
        periodStart: DateTime(now.year, now.month - 2, 1),
        periodEnd: DateTime(now.year, now.month - 2, 7),
        totalSpent: 245.80,
      ),
      BudgetHistoryModel(
        id: '2',
        householdId: '1',
        periodStart: DateTime(now.year, now.month - 1, 8),
        periodEnd: DateTime(now.year, now.month - 1, 14),
        totalSpent: 312.50,
      ),
      BudgetHistoryModel(
        id: '3',
        householdId: '1',
        periodStart: DateTime(now.year, now.month - 1, 15),
        periodEnd: DateTime(now.year, now.month - 1, 21),
        totalSpent: 487.20,
      ),
    ];
  }

  // Inicializar miembros (datos de ejemplo para MVP)
  void _initializeMembers() {
    _householdMembers = [
      UserModel(
        id: 'user1',
        name: 'Usuario Principal',
        email: 'usuario@ejemplo.com',
        householdId: '1',
      ),
      UserModel(
        id: 'user2',
        name: 'María García',
        email: 'maria@ejemplo.com',
        householdId: '1',
      ),
    ];
  }

  // Método helper para crear notificaciones
  void _addNotification({
    required NotificationType type,
    required String title,
    required String description,
    Map<String, dynamic>? metadata,
  }) {
    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      householdId: _household?.id ?? '1',
      type: type,
      title: title,
      description: description,
      createdAt: DateTime.now(),
      metadata: metadata,
    );

    _notifications.insert(0, notification);

    // Mantener solo las últimas 50 notificaciones
    if (_notifications.length > 50) {
      _notifications = _notifications.sublist(0, 50);
    }
  }

  // Eliminar una notificación
  void deleteNotification(String notificationId) {
    _notifications.removeWhere(
      (notification) => notification.id == notificationId,
    );
    notifyListeners();
  }

  // Eliminar todas las notificaciones
  void clearAllNotifications() {
    _notifications.clear();
    notifyListeners();
  }
}

enum BudgetState {
  normal, // < 70%
  warning, // 70-100%
  exceeded, // > 100%
}
