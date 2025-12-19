import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../state/state.dart';
import '../../utils/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkCard,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.notificationsLabel,
          style: const TextStyle(
            color: AppColors.textWhite,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Consumer<BudgetProvider>(
            builder: (context, budgetProvider, child) {
              if (budgetProvider.notifications.isEmpty) return const SizedBox();

              return TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          backgroundColor: AppColors.darkCard,
                          title: Text(
                            l10n.deleteAll,
                            style: const TextStyle(color: AppColors.textWhite),
                          ),
                          content: Text(
                            l10n.deleteAllConfirm,
                            style: const TextStyle(color: AppColors.textGray),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(l10n.cancel),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                budgetProvider.clearAllNotifications();
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.errorRed,
                              ),
                              child: Text(l10n.delete),
                            ),
                          ],
                        ),
                  );
                },
                child: Text(
                  l10n.clearAll,
                  style: const TextStyle(
                    color: AppColors.errorRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<BudgetProvider>(
        builder: (context, budgetProvider, child) {
          final allNotifications = budgetProvider.allNotifications;

          if (allNotifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.notifications_none_outlined,
                      size: 64,
                      color: AppColors.textGray,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.emptyNotifications,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textWhite,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.emptyNotificationsDescription,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textGray,
                    ),
                  ),
                ],
              ),
            );
          }

          // Agrupar notificaciones por presupuesto
          final groupedNotifications = <String, List<NotificationModel>>{};
          for (final notification in allNotifications) {
            final budgetId = notification.budgetId ?? 'no_budget';
            if (!groupedNotifications.containsKey(budgetId)) {
              groupedNotifications[budgetId] = [];
            }
            groupedNotifications[budgetId]!.add(notification);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: groupedNotifications.length,
            itemBuilder: (context, groupIndex) {
              final budgetId = groupedNotifications.keys.elementAt(groupIndex);
              final notificationsForBudget = groupedNotifications[budgetId]!;

              // Encontrar el presupuesto correspondiente
              final budget = budgetProvider.budgets.firstWhere(
                (b) => b.id == budgetId,
                orElse: () => budgetProvider.budgets.first,
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header del grupo de presupuesto
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12, top: 8),
                    child: Row(
                      children: [
                        Icon(
                          budget.type == BudgetType.personal
                              ? Icons.person_outline
                              : Icons.group_outlined,
                          color: AppColors.primaryBlue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          budget.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textWhite,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${notificationsForBudget.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Lista de notificaciones del presupuesto
                  ...notificationsForBudget.map((notification) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _NotificationItem(
                        notification: notification,
                        onDelete: () {
                          budgetProvider.deleteNotification(notification.id);
                        },
                      ),
                    );
                  }),

                  const SizedBox(height: 16),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onDelete;

  const _NotificationItem({required this.notification, required this.onDelete});

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

  String _getTimeAgo(BuildContext context, DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final difference = now.difference(date);

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
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.errorRed,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: AppColors.textWhite,
          size: 28,
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Avatar
            CircleAvatar(
              radius: 20,
              backgroundColor: _getIconColor().withOpacity(0.2),
              backgroundImage:
                  notification.userPhotoUrl != null
                      ? NetworkImage(notification.userPhotoUrl!)
                      : null,
              child:
                  notification.userPhotoUrl == null
                      ? Icon(Icons.person, color: _getIconColor(), size: 20)
                      : null,
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            // Nombre del usuario
                            Text(
                              notification.userName ?? 'Usuario',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                            const SizedBox(width: 6),
                            // Icono de acción
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: _getIconColor().withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                _getIcon(),
                                color: _getIconColor(),
                                size: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _getTimeAgo(context, notification.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textGray,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textWhite,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textGray,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
