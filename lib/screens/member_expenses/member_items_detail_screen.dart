import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../utils/app_colors.dart';

class MemberItemsDetailScreen extends StatelessWidget {
  final BudgetModel budget;
  final UserModel member;
  final List<ShoppingItemModel> items;

  const MemberItemsDetailScreen({
    super.key,
    required this.budget,
    required this.member,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    // Calcular total
    final total = items.fold(0.0, (sum, item) => sum + item.estimatedPrice);

    // Ordenar ítems por fecha de completado (más reciente primero)
    final sortedItems = List<ShoppingItemModel>.from(items)..sort((a, b) {
      if (a.purchasedAt == null && b.purchasedAt == null) return 0;
      if (a.purchasedAt == null) return 1;
      if (b.purchasedAt == null) return -1;
      return b.purchasedAt!.compareTo(a.purchasedAt!);
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.itemDetails,
          style: const TextStyle(
            color: AppColors.textWhite,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Member Header Card
          Container(
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
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
            ),
            child: Column(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primaryBlue.withOpacity(0.2),
                  backgroundImage:
                      member.photoUrl != null
                          ? NetworkImage(member.photoUrl!)
                          : null,
                  child:
                      member.photoUrl == null
                          ? Text(
                            member.name[0].toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w600,
                              fontSize: 32,
                            ),
                          )
                          : null,
                ),
                const SizedBox(height: 16),
                // Member Name
                Text(
                  member.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  member.email,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textGray,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // Stats
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn(
                        theme,
                        l10n.itemsPurchased,
                        '${items.length}',
                        Icons.check_circle_outline,
                        AppColors.success,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: AppColors.textGrayLight.withOpacity(0.2),
                      ),
                      _buildStatColumn(
                        theme,
                        l10n.totalPurchased,
                        '\$${total.toStringAsFixed(2)}',
                        Icons.payments_outlined,
                        AppColors.primaryBlue,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Budget name
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 16,
                  color: AppColors.textGray,
                ),
                const SizedBox(width: 8),
                Text(
                  budget.name,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textGray,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // Items List
          ...sortedItems.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  border:
                      isDark
                          ? null
                          : Border.all(
                            color: Colors.grey.withOpacity(0.15),
                            width: 1,
                          ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Checkmark icon
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Item info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textWhite,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 12,
                                  color: AppColors.textGray,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDate(item.purchasedAt),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.textGray,
                                  ),
                                ),
                                if (item.category != null) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryBlue.withOpacity(
                                        0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      item.category!,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: AppColors.primaryBlue,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Price
                      Text(
                        '\$${item.estimatedPrice.toStringAsFixed(2)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatColumn(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textGray),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(date);
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }
}
