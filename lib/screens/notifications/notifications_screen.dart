import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../state/state.dart';
import '../../utils/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkCard,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Notificaciones',
          style: TextStyle(
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
                          title: const Text(
                            'Eliminar todas',
                            style: TextStyle(color: AppColors.textWhite),
                          ),
                          content: const Text(
                            '¿Estás seguro de que quieres eliminar todas las notificaciones?',
                            style: TextStyle(color: AppColors.textGray),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancelar'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                budgetProvider.clearAllNotifications();
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.errorRed,
                              ),
                              child: const Text('Eliminar'),
                            ),
                          ],
                        ),
                  );
                },
                child: const Text(
                  'Limpiar',
                  style: TextStyle(
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
          final notifications = budgetProvider.notifications;

          if (notifications.isEmpty) {
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
                    'No hay notificaciones',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textWhite,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Las notificaciones aparecerán aquí',
                    style: TextStyle(fontSize: 14, color: AppColors.textGray),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: notifications.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _NotificationItem(
                notification: notification,
                onDelete: () {
                  budgetProvider.deleteNotification(notification.id);
                },
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

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays}d';
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
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getIconColor().withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_getIcon(), color: _getIconColor(), size: 24),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textWhite,
                          ),
                        ),
                      ),
                      Text(
                        _getTimeAgo(notification.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textGray,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification.description,
                    style: TextStyle(
                      fontSize: 14,
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
