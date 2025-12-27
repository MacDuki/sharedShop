import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/models.dart';

class BudgetProvider extends ChangeNotifier {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // Current user
  UserModel? _currentUser;

  // State: Budgets list (from getUserBudgets)
  List<BudgetModel> _budgets = [];
  bool _budgetsLoading = false;
  String? _budgetsError;

  // State: Active budget details (from getBudgetDetails)
  BudgetModel? _activeBudget;
  bool _activeBudgetLoading = false;
  String? _activeBudgetError;

  // State: Budget members (from getBudgetDetails)
  List<UserModel> _budgetMembers = [];
  bool _membersLoading = false;
  String? _membersError;

  // State: Shopping items (from getBudgetItems)
  List<ShoppingItemModel> _shoppingItems = [];
  bool _itemsLoading = false;
  String? _itemsError;

  // State: Budget history (from getBudgetHistory)
  List<BudgetHistoryModel> _budgetHistory = [];
  bool _historyLoading = false;
  String? _historyError;

  // State: Member expenses (from getMemberExpenses)
  List<MemberExpenseModel> _memberExpenses = [];
  double _memberExpensesGrandTotal = 0.0;
  int _memberExpensesTotalItems = 0;
  bool _memberExpensesLoading = false;
  String? _memberExpensesError;

  // State: Notifications
  List<NotificationModel> _notifications = [];

  // Getters - Current user
  UserModel? get currentUser => _currentUser;

  // Getters - Budgets list
  List<BudgetModel> get budgets => List.unmodifiable(_budgets);
  bool get budgetsLoading => _budgetsLoading;
  String? get budgetsError => _budgetsError;

  // Getters - Active budget
  BudgetModel? get activeBudget => _activeBudget;
  bool get activeBudgetLoading => _activeBudgetLoading;
  String? get activeBudgetError => _activeBudgetError;

  // Getters - Budget members
  List<UserModel> get budgetMembers => List.unmodifiable(_budgetMembers);
  bool get membersLoading => _membersLoading;
  String? get membersError => _membersError;

  // Getters - Shopping items (filtered by active budget)
  List<ShoppingItemModel> get shoppingItems {
    if (_activeBudget != null) {
      return List.unmodifiable(
        _shoppingItems.where((item) => item.budgetId == _activeBudget!.id),
      );
    }
    return List.unmodifiable(_shoppingItems);
  }

  bool get itemsLoading => _itemsLoading;
  String? get itemsError => _itemsError;

  // Getters - Budget history (filtered by active budget)
  List<BudgetHistoryModel> get budgetHistory {
    if (_activeBudget != null) {
      return List.unmodifiable(
        _budgetHistory.where(
          (history) => history.budgetId == _activeBudget!.id,
        ),
      );
    }
    return List.unmodifiable(_budgetHistory);
  }

  bool get historyLoading => _historyLoading;
  String? get historyError => _historyError;

  // Getters - Member expenses
  List<MemberExpenseModel> get memberExpenses =>
      List.unmodifiable(_memberExpenses);
  double get memberExpensesGrandTotal => _memberExpensesGrandTotal;
  int get memberExpensesTotalItems => _memberExpensesTotalItems;
  bool get memberExpensesLoading => _memberExpensesLoading;
  String? get memberExpensesError => _memberExpensesError;

  // Getters - Notifications (filtered by active budget)
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

  // All notifications unfiltered
  List<NotificationModel> get allNotifications =>
      List.unmodifiable(_notifications);

  // ============================================================================
  // FETCH METHODS - Single source of truth from backend
  // ============================================================================

  /// Fetches all budgets for the current user from backend.
  /// Calls: getUserBudgets Cloud Function
  /// Populates: _budgets
  Future<void> fetchUserBudgets() async {
    _budgetsLoading = true;
    _budgetsError = null;
    notifyListeners();

    try {
      final callable = _functions.httpsCallable('getUserBudgets');
      final result = await callable.call();

      final budgetsData = result.data['budgets'] as List;

      _budgets =
          budgetsData.map((data) {
            return BudgetModel(
              id: data['id'],
              name: data['name'],
              budgetAmount: data['budgetAmount'].toDouble(),
              ownerId: FirebaseAuth.instance.currentUser?.uid ?? '',
              type:
                  data['isOwner'] == true
                      ? BudgetType.personal
                      : BudgetType.shared,
              budgetPeriod: BudgetPeriod.monthly,
              createdAt: DateTime.now(),
              memberIds: [],
            );
          }).toList();

      _budgetsLoading = false;
      notifyListeners();
    } catch (e) {
      _budgetsError = e.toString();
      _budgetsLoading = false;
      debugPrint('Error fetching budgets: $e');
      notifyListeners();
    }
  }

  /// Fetches complete details for a specific budget from backend.
  /// Calls: getBudgetDetails Cloud Function
  /// Populates: _activeBudget, _budgetMembers
  Future<void> fetchBudgetDetails(String budgetId) async {
    _activeBudgetLoading = true;
    _activeBudgetError = null;
    _membersLoading = true;
    _membersError = null;
    notifyListeners();

    try {
      final callable = _functions.httpsCallable('getBudgetDetails');
      final result = await callable.call({'budgetId': budgetId});

      final budgetData = result.data['budget'];

      // Parse budgetPeriod from backend
      BudgetPeriod parseBudgetPeriod(String? period) {
        switch (period) {
          case 'weekly':
            return BudgetPeriod.weekly;
          case 'monthly':
            return BudgetPeriod.monthly;
          case 'custom':
            return BudgetPeriod.custom;
          default:
            return BudgetPeriod.monthly; // Default fallback
        }
      }

      // Parse createdAt from backend (Timestamp or ISO string)
      DateTime parseCreatedAt(dynamic createdAt) {
        if (createdAt == null) return DateTime.now();
        if (createdAt is String) {
          return DateTime.parse(createdAt);
        }
        // Handle Firestore Timestamp
        if (createdAt is Map && createdAt['_seconds'] != null) {
          return DateTime.fromMillisecondsSinceEpoch(
            createdAt['_seconds'] * 1000,
          );
        }
        return DateTime.now();
      }

      _activeBudget = BudgetModel(
        id: budgetData['id'],
        name: budgetData['name'],
        description: budgetData['description'],
        budgetAmount: budgetData['budgetAmount'].toDouble(),
        ownerId: budgetData['ownerId'],
        type:
            budgetData['ownerId'] == FirebaseAuth.instance.currentUser?.uid
                ? BudgetType.personal
                : BudgetType.shared,
        budgetPeriod: parseBudgetPeriod(budgetData['budgetPeriod']),
        createdAt: parseCreatedAt(budgetData['createdAt']),
        memberIds:
            (budgetData['memberIds'] as List?)
                ?.map((id) => id as String)
                .toList() ??
            [],
        totalSpent: budgetData['totalSpent']?.toDouble(),
        remaining: budgetData['remaining']?.toDouble(),
        percentageUsed: budgetData['percentageUsed']?.toDouble(),
        status: budgetData['status'],
        daysRemaining: budgetData['daysRemaining'] as int?,
        iconName: budgetData['iconName'],
        colorHex: budgetData['colorHex'],
      );

      _budgetMembers =
          (budgetData['members'] as List).map((memberData) {
            return UserModel(
              id: memberData['userId'],
              name: memberData['name'],
              email: memberData['email'],
              photoUrl: memberData['photoURL'],
              householdId: '',
              budgetIds: [],
            );
          }).toList();

      _activeBudgetLoading = false;
      _membersLoading = false;
      notifyListeners();
    } catch (e) {
      _activeBudgetError = e.toString();
      _membersError = e.toString();
      _activeBudgetLoading = false;
      _membersLoading = false;
      debugPrint('Error fetching budget details: $e');
      notifyListeners();
    }
  }

  /// Fetches shopping items for a specific budget from backend.
  /// Calls: getBudgetItems Cloud Function
  /// Populates: _shoppingItems
  Future<void> fetchBudgetItems(String budgetId) async {
    _itemsLoading = true;
    _itemsError = null;
    notifyListeners();

    try {
      final callable = _functions.httpsCallable('getBudgetItems');
      final result = await callable.call({
        'budgetId': budgetId,
        'filter': 'all',
      });

      final itemsData = result.data['items'] as List;

      _shoppingItems =
          itemsData.map((data) {
            return ShoppingItemModel(
              id: data['id'],
              budgetId: budgetId,
              name: data['name'],
              estimatedPrice: data['estimatedPrice'].toDouble(),
              category: data['category'],
              isPurchased: data['isPurchased'],
              createdBy: data['createdBy'],
              createdAt:
                  data['createdAt'] != null
                      ? (data['createdAt'] as dynamic).toDate()
                      : DateTime.now(),
              purchasedBy: data['purchasedBy'],
              purchasedAt:
                  data['purchasedAt'] != null
                      ? (data['purchasedAt'] as dynamic).toDate()
                      : null,
            );
          }).toList();

      _itemsLoading = false;
      notifyListeners();
    } catch (e) {
      _itemsError = e.toString();
      _itemsLoading = false;
      debugPrint('Error fetching budget items: $e');
      notifyListeners();
    }
  }

  /// Fetches budget history for a specific budget from backend.
  /// Calls: getBudgetHistory Cloud Function
  /// Populates: _budgetHistory
  Future<void> fetchBudgetHistory(String budgetId) async {
    _historyLoading = true;
    _historyError = null;
    notifyListeners();

    try {
      final callable = _functions.httpsCallable('getBudgetHistory');
      final result = await callable.call({'budgetId': budgetId});

      final historyData = result.data['history'] as List;

      _budgetHistory =
          historyData.map((data) {
            // Parse periodStart and periodEnd
            DateTime parsePeriod(dynamic period) {
              if (period == null) return DateTime.now();
              if (period is String) return DateTime.parse(period);
              // Handle Firestore Timestamp
              if (period is Map && period['_seconds'] != null) {
                return DateTime.fromMillisecondsSinceEpoch(
                  period['_seconds'] * 1000,
                );
              }
              return DateTime.now();
            }

            return BudgetHistoryModel(
              id: data['id'],
              budgetId: data['budgetId'],
              periodStart: parsePeriod(data['periodStart']),
              periodEnd: parsePeriod(data['periodEnd']),
              totalSpent: (data['totalSpent'] ?? 0).toDouble(),
              percentageUsed: data['percentageUsed']?.toDouble(),
            );
          }).toList();

      _historyLoading = false;
      notifyListeners();
    } catch (e) {
      _historyError = e.toString();
      _historyLoading = false;
      debugPrint('Error fetching budget history: $e');
      notifyListeners();
    }
  }

  /// Fetches member expenses for a specific budget from backend.
  /// Calls: getMemberExpenses Cloud Function
  /// Populates: _memberExpenses, _memberExpensesGrandTotal, _memberExpensesTotalItems
  Future<void> fetchMemberExpenses(String budgetId) async {
    _memberExpensesLoading = true;
    _memberExpensesError = null;
    notifyListeners();

    try {
      final callable = _functions.httpsCallable('getMemberExpenses');
      final result = await callable.call({'budgetId': budgetId});

      final expensesData = result.data['memberExpenses'] as List;

      _memberExpenses =
          expensesData.map((data) {
            return MemberExpenseModel.fromJson(data);
          }).toList();

      _memberExpensesGrandTotal = (result.data['grandTotal'] ?? 0).toDouble();
      _memberExpensesTotalItems = result.data['totalItems'] as int? ?? 0;

      _memberExpensesLoading = false;
      notifyListeners();
    } catch (e) {
      _memberExpensesError = e.toString();
      _memberExpensesLoading = false;
      debugPrint('Error fetching member expenses: $e');
      notifyListeners();
    }
  }

  // ============================================================================
  // BUDGET MANAGEMENT - Write operations followed by fetch
  // ============================================================================

  /// Creates a new budget via Cloud Function.
  /// After success, re-fetches all budgets from backend.
  Future<void> addBudget(BudgetModel budget) async {
    try {
      final callable = _functions.httpsCallable('createBudget');
      final result = await callable.call({
        'name': budget.name,
        'description': budget.description,
        'budgetAmount': budget.budgetAmount,
        'budgetPeriod': budget.budgetPeriod.toString().split('.').last,
        'customPeriodEnd': budget.customPeriodEnd?.toIso8601String(),
        'iconName': budget.iconName,
        'colorHex': budget.colorHex,
      });

      debugPrint('Budget created: ${result.data}');

      // Re-fetch budgets from backend (single source of truth)
      await fetchUserBudgets();

      // If created successfully, fetch its details and set as active
      if (result.data != null && result.data['budgetId'] != null) {
        final newBudgetId = result.data['budgetId'];
        await fetchBudgetDetails(newBudgetId);
        await fetchBudgetItems(newBudgetId);

        debugPrint('New budget set as active: $newBudgetId');
      }
    } catch (e) {
      debugPrint('Error creating budget: $e');
      rethrow;
    }
  }

  /// Updates an existing budget via Cloud Function.
  /// After success, re-fetches affected data from backend.
  Future<void> updateBudgetData(BudgetModel updatedBudget) async {
    try {
      final callable = _functions.httpsCallable('updateBudget');
      await callable.call({
        'budgetId': updatedBudget.id,
        'name': updatedBudget.name,
        'description': updatedBudget.description,
        'budgetAmount': updatedBudget.budgetAmount,
        'budgetPeriod': updatedBudget.budgetPeriod.toString().split('.').last,
        'iconName': updatedBudget.iconName,
        'colorHex': updatedBudget.colorHex,
      });

      // Re-fetch from backend (no local state mutation)
      await fetchBudgetDetails(updatedBudget.id);
      await fetchUserBudgets();
    } catch (e) {
      debugPrint('Error updating budget: $e');
      rethrow;
    }
  }

  /// Deletes a budget via Cloud Function.
  /// After success, re-fetches all budgets from backend.
  Future<void> deleteBudget(String budgetId) async {
    try {
      final callable = _functions.httpsCallable('deleteBudget');
      await callable.call({'budgetId': budgetId});

      // Clear active budget if it was deleted
      if (_activeBudget?.id == budgetId) {
        _activeBudget = null;
      }

      // Re-fetch budgets from backend
      await fetchUserBudgets();
    } catch (e) {
      debugPrint('Error deleting budget: $e');
      rethrow;
    }
  }

  /// Sets the active budget and fetches its data from backend.
  Future<void> setActiveBudget(String budgetId) async {
    await fetchBudgetDetails(budgetId);
    await fetchBudgetItems(budgetId);
  }

  // ============================================================================
  // ITEM MANAGEMENT - Write operations followed by fetch
  // ============================================================================

  /// Adds a new shopping item via Cloud Function.
  /// Implements optimistic update for instant UI feedback.
  /// After success, re-fetches items from backend.
  Future<void> addItem(ShoppingItemModel item) async {
    if (_activeBudget == null) return;

    // Optimistic update: Add item to local list immediately
    _shoppingItems.add(item);
    notifyListeners(); // Instant UI feedback

    try {
      final callable = _functions.httpsCallable('addShoppingItem');
      await callable.call({
        'budgetId': _activeBudget!.id,
        'name': item.name,
        'estimatedPrice': item.estimatedPrice,
        'category': item.category ?? '',
      });

      // Re-fetch from backend (single source of truth)
      await fetchBudgetItems(_activeBudget!.id);
      await fetchBudgetDetails(_activeBudget!.id);
      // notifyListeners() is called inside fetch methods
    } catch (e) {
      // Rollback optimistic update on error
      _shoppingItems.removeWhere((i) => i.id == item.id);
      notifyListeners();
      debugPrint('Error adding item: $e');
      rethrow;
    }
  }

  /// Updates an existing shopping item via Cloud Function.
  /// After success, re-fetches items from backend.
  Future<void> updateItem(String itemId, ShoppingItemModel updatedItem) async {
    if (_activeBudget == null) return;

    try {
      final callable = _functions.httpsCallable('updateShoppingItem');
      await callable.call({
        'itemId': itemId,
        'name': updatedItem.name,
        'estimatedPrice': updatedItem.estimatedPrice,
        'category': updatedItem.category,
      });

      // Re-fetch from backend (single source of truth)
      await fetchBudgetItems(_activeBudget!.id);
      await fetchBudgetDetails(_activeBudget!.id);
      // notifyListeners() is called inside fetch methods
    } catch (e) {
      debugPrint('Error updating item: $e');
      rethrow;
    }
  }

  /// Deletes a shopping item via Cloud Function.
  /// After success, re-fetches items from backend.
  Future<void> deleteItem(String itemId) async {
    if (_activeBudget == null) return;

    try {
      final callable = _functions.httpsCallable('deleteShoppingItem');
      await callable.call({'itemId': itemId});

      // Re-fetch from backend (single source of truth)
      await fetchBudgetItems(_activeBudget!.id);
      await fetchBudgetDetails(_activeBudget!.id);
      // notifyListeners() is called inside fetch methods
    } catch (e) {
      debugPrint('Error deleting item: $e');
      rethrow;
    }
  }

  /// Toggles item purchased status via Cloud Function.
  /// After success, re-fetches items from backend.
  Future<void> toggleItemPurchased(String itemId) async {
    if (_activeBudget == null) return;

    final item = _shoppingItems.firstWhere(
      (item) => item.id == itemId,
      orElse: () => throw Exception('Item not found'),
    );

    final newStatus = !item.isPurchased;

    try {
      final callable = _functions.httpsCallable('updateShoppingItem');
      await callable.call({'itemId': itemId, 'isPurchased': newStatus});

      // Re-fetch from backend (single source of truth)
      await fetchBudgetItems(_activeBudget!.id);
      await fetchBudgetDetails(_activeBudget!.id);
      // notifyListeners() is called inside fetch methods
    } catch (e) {
      debugPrint('Error toggling item purchased: $e');
      rethrow;
    }
  }

  // ============================================================================
  // NOTIFICATIONS - Local state only
  // ============================================================================

  void deleteNotification(String notificationId) {
    _notifications.removeWhere(
      (notification) => notification.id == notificationId,
    );
    notifyListeners();
  }

  void clearAllNotifications() {
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
