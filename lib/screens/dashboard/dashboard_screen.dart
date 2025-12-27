import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../state/state.dart';
import '../../utils/app_colors.dart';
import '../budget_details/budget_details_screen.dart';
import '../budget_form/budget_form_screen.dart';
import '../budget_list/budget_list_screen.dart';
import '../history/history_screen.dart';
import '../invite_members/invite_members_screen.dart';
import '../notifications/notifications_screen.dart';
import '../shopping_list/shopping_list_screen.dart';
import '../user_settings/user_settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final budgetProvider = context.read<BudgetProvider>();
      // Fetch budgets from backend via provider
      budgetProvider.fetchUserBudgets().then((_) {
        debugPrint('Budgets loaded: ${budgetProvider.budgets.length}');
        debugPrint('Active budget: ${budgetProvider.activeBudget?.name}');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Consumer<BudgetProvider>(
          builder: (context, budgetProvider, child) {
            final activeBudget = budgetProvider.activeBudget;
            final isLoading = budgetProvider.activeBudgetLoading;
            final error = budgetProvider.activeBudgetError;

            // Loading state
            if (isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryBlue),
              );
            }

            // Error state
            if (error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: AppColors.errorRed,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: $error',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            // Empty state
            if (activeBudget == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 64,
                        color: AppColors.textGray,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No hay presupuestos disponibles',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Crea tu primer presupuesto para comenzar a gestionar tus gastos',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const BudgetFormScreen(),
                            ),
                          );

                          // Recargar budgets después de crear
                          if (mounted) {
                            await budgetProvider.fetchUserBudgets();
                          }
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Crear Presupuesto'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Data from backend - no calculations in UI
            final remainingBudget = activeBudget.remaining ?? 0.0;
            final totalSpent = activeBudget.totalSpent ?? 0.0;
            final percentageUsed = activeBudget.percentageUsed ?? 0.0;
            final budgetTotal = activeBudget.budgetAmount;
            final daysLeft = activeBudget.daysRemaining ?? 0;

            return Column(
              children: [
                // Custom Header with Budget Selector
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.dashboard,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.dashboardGreeting(
                                  budgetProvider.currentUser?.name ?? 'Usuario',
                                ),
                                style: theme.textTheme.displayMedium?.copyWith(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: theme.cardTheme.color,
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  isDark
                                      ? null
                                      : Border.all(
                                        color: Colors.grey.withOpacity(0.15),
                                        width: 1,
                                      ),
                              boxShadow:
                                  isDark
                                      ? null
                                      : [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.04),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                            ),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const UserSettingsScreen(),
                                  ),
                                );
                              },
                              child: Icon(
                                Icons.settings_outlined,
                                color: theme.iconTheme.color,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Budget Selector
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const BudgetListScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.cardTheme.color,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.primaryGreen.withOpacity(0.3),
                              width: 2,
                            ),
                            boxShadow:
                                isDark
                                    ? null
                                    : [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _getBudgetColor(
                                    activeBudget,
                                  ).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  _getBudgetIcon(activeBudget),
                                  color: _getBudgetColor(activeBudget),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      activeBudget.name,
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(
                                            color: AppColors.textWhite,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Icon(
                                          activeBudget.type ==
                                                  BudgetType.personal
                                              ? Icons.person_outline
                                              : Icons.people_outline,
                                          size: 12,
                                          color: AppColors.textGrayLight,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          activeBudget.type ==
                                                  BudgetType.personal
                                              ? 'Personal'
                                              : 'Shared',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: AppColors.textGrayLight,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: AppColors.textGray,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),

                        // Main Budget Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: theme.cardTheme.color,
                            borderRadius: BorderRadius.circular(24),
                            border:
                                isDark
                                    ? null
                                    : Border.all(
                                      color: Colors.grey.withOpacity(0.15),
                                      width: 1,
                                    ),
                            boxShadow:
                                isDark
                                    ? null
                                    : [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    l10n.remainingBudget,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      // Verificar permisos: personal o admin de compartido
                                      final canEdit =
                                          activeBudget.type ==
                                              BudgetType.personal ||
                                          (activeBudget.type ==
                                                  BudgetType.shared &&
                                              activeBudget.ownerId ==
                                                  budgetProvider
                                                      .currentUser
                                                      ?.id);

                                      if (canEdit) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => BudgetFormScreen(
                                                  budget: activeBudget,
                                                ),
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              l10n.noEditPermission,
                                            ),
                                            backgroundColor: AppColors.errorRed,
                                            duration: const Duration(
                                              seconds: 2,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryBlue
                                            .withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        Icons.settings_outlined,
                                        color: AppColors.primaryBlue,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '\$${remainingBudget.toStringAsFixed(2)}',
                                style: theme.textTheme.displayLarge?.copyWith(
                                  fontSize: 64,
                                  fontWeight: FontWeight.bold,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Items comprados/pendientes Badge (clickeable)
                              // Data comes from provider - no business logic in UI
                              Builder(
                                builder: (context) {
                                  final allItems = budgetProvider.shoppingItems;
                                  final purchasedItems =
                                      allItems
                                          .where((item) => item.isPurchased)
                                          .length;
                                  final pendingItems =
                                      allItems.length - purchasedItems;
                                  final totalItems = allItems.length;

                                  // Simple color indicator - complex rules should be in backend/provider
                                  Color badgeColor =
                                      totalItems == 0
                                          ? AppColors.textGray
                                          : (pendingItems == 0
                                              ? AppColors.success
                                              : AppColors.primaryBlue);

                                  return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) =>
                                                  const ShoppingListScreen(),
                                        ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: badgeColor.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: badgeColor.withOpacity(0.25),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.check_circle,
                                            color: badgeColor,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '$purchasedItems',
                                            style: TextStyle(
                                              color: badgeColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(
                                            Icons.warning_amber_rounded,
                                            color: badgeColor,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '$pendingItems',
                                            style: TextStyle(
                                              color: badgeColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 32),

                              // Progress Bar - data from backend
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    l10n.percentageRemaining(
                                      (100 - percentageUsed).toStringAsFixed(0),
                                    ),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryBlue,
                                    ),
                                  ),
                                  Text(
                                    l10n.amountSpent(
                                      totalSpent.toStringAsFixed(2),
                                    ),
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: percentageUsed / 100,
                                  minHeight: 10,
                                  backgroundColor:
                                      theme.brightness == Brightness.dark
                                          ? AppColors.darkCardSecondary
                                          : Colors.grey.shade300,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _getProgressBarColor(percentageUsed),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Total and Days Left Cards
                        Row(
                          children: [
                            Expanded(
                              child: _InfoCard(
                                icon: Icons.account_balance_wallet_outlined,
                                iconColor: AppColors.iconBlue,
                                iconBackground: AppColors.iconBlue.withOpacity(
                                  0.15,
                                ),
                                title: l10n.total,
                                value: '\$${budgetTotal.toStringAsFixed(0)}',
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _InfoCard(
                                icon: Icons.calendar_today_outlined,
                                iconColor: AppColors.iconPurple,
                                iconBackground: AppColors.iconPurple
                                    .withOpacity(0.15),
                                title: l10n.daysLeftLabel,
                                value: '$daysLeft',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Recent Activity Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.notificationsLabel,
                              style: theme.textTheme.headlineMedium,
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const NotificationsScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                l10n.viewAll,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Recent Activity List
                        ...budgetProvider.notifications
                            .take(3)
                            .map(
                              (notification) => _NotificationItem(
                                notification: notification,
                                onDelete: () {
                                  budgetProvider.deleteNotification(
                                    notification.id,
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(l10n.notificationDeleted),
                                      backgroundColor: AppColors.success,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                              ),
                            ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          border:
              isDark
                  ? null
                  : Border(
                    top: BorderSide(
                      color: Colors.grey.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.1 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: l10n.home,
                  isSelected: _selectedIndex == 0,
                  onTap: () => setState(() => _selectedIndex = 0),
                ),
                _NavItem(
                  icon: Icons.pie_chart_outline_rounded,
                  label: l10n.budget,
                  isSelected: _selectedIndex == 1,
                  onTap: () {
                    final budgetProvider = context.read<BudgetProvider>();
                    final activeBudget = budgetProvider.activeBudget;

                    if (activeBudget != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  BudgetDetailsScreen(budget: activeBudget),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(width: 60),
                _NavItem(
                  icon: Icons.receipt_long_outlined,
                  label: l10n.history,
                  isSelected: _selectedIndex == 2,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HistoryScreen(),
                      ),
                    );
                  },
                ),
                _NavItem(
                  icon: Icons.share_outlined,
                  label: l10n.share,
                  isSelected: _selectedIndex == 3,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const InviteMembersScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ShoppingListScreen()),
          );
        },
        backgroundColor: AppColors.primaryBlue,
        elevation: 4,
        child: const Icon(Icons.add, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // Pure presentation logic - maps backend data to Flutter widgets
  Color _getBudgetColor(BudgetModel budget) {
    if (budget.colorHex != null) {
      try {
        return Color(int.parse(budget.colorHex!.replaceFirst('#', '0xFF')));
      } catch (e) {
        // Fallback color
      }
    }
    return budget.type == BudgetType.personal
        ? AppColors.primaryBlue
        : AppColors.primaryPurple;
  }

  // Pure presentation logic - maps backend iconName to Flutter IconData
  IconData _getBudgetIcon(BudgetModel budget) {
    if (budget.iconName != null) {
      switch (budget.iconName) {
        case 'shopping_cart':
          return Icons.shopping_cart_outlined;
        case 'home':
          return Icons.home_outlined;
        case 'restaurant':
          return Icons.restaurant_outlined;
        case 'local_grocery_store':
          return Icons.local_grocery_store_outlined;
        case 'flight':
          return Icons.flight_outlined;
        default:
          break;
      }
    }
    return budget.type == BudgetType.personal
        ? Icons.account_balance_wallet_outlined
        : Icons.people_outline;
  }

  // Pure presentation logic - maps percentage to color
  // Business rules about when budget is critical should come from backend 'status' field
  Color _getProgressBarColor(double percentage) {
    if (percentage >= 90) {
      return AppColors.errorRed;
    } else if (percentage >= 70) {
      return AppColors.warningAmber;
    } else if (percentage >= 50) {
      return AppColors.primaryBlue;
    } else {
      return AppColors.success;
    }
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border:
            isDark
                ? null
                : Border.all(color: Colors.grey.withOpacity(0.15), width: 1),
        boxShadow:
            isDark
                ? null
                : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.displaySmall?.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onDelete;

  const _NotificationItem({required this.notification, required this.onDelete});

  // Pure presentation logic - maps notification type to icon
  IconData _getIcon() {
    switch (notification.type) {
      case NotificationType.budgetUpdated:
        return Icons.account_balance_wallet_outlined;
      case NotificationType.memberAdded:
        return Icons.person_add_outlined;
      case NotificationType.memberRemoved:
        return Icons.person_remove_outlined;
      case NotificationType.itemAdded:
        return Icons.add_shopping_cart_outlined;
      case NotificationType.itemDeleted:
        return Icons.remove_shopping_cart_outlined;
      case NotificationType.budgetExceeded:
        return Icons.warning_amber_outlined;
      case NotificationType.budgetWarning:
        return Icons.info_outlined;
    }
  }

  // Pure presentation logic - maps notification type to color
  Color _getIconColor() {
    switch (notification.type) {
      case NotificationType.budgetUpdated:
        return AppColors.primaryBlue;
      case NotificationType.memberAdded:
        return AppColors.primaryGreen;
      case NotificationType.memberRemoved:
        return AppColors.errorRed;
      case NotificationType.itemAdded:
        return AppColors.primaryGreen;
      case NotificationType.itemDeleted:
        return AppColors.errorRed;
      case NotificationType.budgetExceeded:
        return AppColors.errorRed;
      case NotificationType.budgetWarning:
        return AppColors.warningAmber;
    }
  }

  // Pure presentation logic - formats date as relative time
  String _getTimeAgo(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    final l10n = AppLocalizations.of(context)!;

    if (difference.inSeconds < 60) {
      return l10n.now;
    } else if (difference.inMinutes < 60) {
      return l10n.minutesAgo(difference.inMinutes);
    } else if (difference.inHours < 24) {
      return l10n.hoursAgo(difference.inHours);
    } else if (difference.inDays == 1) {
      return l10n.yesterday;
    } else if (difference.inDays < 7) {
      return l10n.daysAgo(difference.inDays);
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border:
            isDark
                ? null
                : Border.all(color: Colors.grey.withOpacity(0.15), width: 1),
        boxShadow:
            isDark
                ? null
                : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _getIconColor().withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_getIcon(), color: _getIconColor(), size: 20),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${notification.description} • ${_getTimeAgo(context, notification.createdAt)}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),

          // Delete Button
          InkWell(
            onTap: onDelete,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.errorRed.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.delete_outline,
                color: AppColors.errorRed,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = theme.textTheme.bodyMedium?.color ?? Colors.grey;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primaryBlue : baseColor,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? AppColors.primaryBlue : baseColor,
            ),
          ),
        ],
      ),
    );
  }
}
