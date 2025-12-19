import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../state/state.dart';
import '../../utils/app_colors.dart';
import 'member_items_detail_screen.dart';

class MemberExpensesScreen extends StatelessWidget {
  final BudgetModel budget;

  const MemberExpensesScreen({super.key, required this.budget});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

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
          l10n.expensesByMember,
          style: const TextStyle(
            color: AppColors.textWhite,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<BudgetProvider>(
        builder: (context, budgetProvider, child) {
          // Obtener todos los ítems comprados de este presupuesto
          final allItems = budgetProvider.getItemsForBudget(budget.id);
          final purchasedItems =
              allItems.where((item) => item.isPurchased).toList();

          if (purchasedItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 80,
                    color: AppColors.textGray.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noMemberExpenses,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.noMemberExpensesDescription,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textGray,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // Agrupar ítems por miembro
          final Map<String, List<ShoppingItemModel>> itemsByMember = {};
          final Map<String, double> totalByMember = {};

          for (final item in purchasedItems) {
            if (item.purchasedBy != null) {
              itemsByMember.putIfAbsent(item.purchasedBy!, () => []);
              itemsByMember[item.purchasedBy!]!.add(item);

              totalByMember[item.purchasedBy!] =
                  (totalByMember[item.purchasedBy!] ?? 0) + item.estimatedPrice;
            }
          }

          // Calcular el total general
          final grandTotal = totalByMember.values.fold(
            0.0,
            (sum, val) => sum + val,
          );

          // Obtener miembros del presupuesto
          final members =
              budgetProvider.householdMembers
                  .where((member) => budget.memberIds.contains(member.id))
                  .toList();

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Total overview card
              Container(
                padding: const EdgeInsets.all(20),
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
                child: Column(
                  children: [
                    Text(
                      l10n.totalPurchased,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textGray,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${grandTotal.toStringAsFixed(2)}',
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${purchasedItems.length} ${l10n.itemsPurchased}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textGray,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Members list
              ...members.map((member) {
                final memberItems = itemsByMember[member.id] ?? [];
                final memberTotal = totalByMember[member.id] ?? 0.0;
                final percentage =
                    grandTotal > 0 ? (memberTotal / grandTotal * 100) : 0.0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
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
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap:
                            memberItems.isNotEmpty
                                ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => MemberItemsDetailScreen(
                                            budget: budget,
                                            member: member,
                                            items: memberItems,
                                          ),
                                    ),
                                  );
                                }
                                : null,
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  // Avatar
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: AppColors.primaryBlue
                                        .withOpacity(0.2),
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
                                                fontSize: 18,
                                              ),
                                            )
                                            : null,
                                  ),
                                  const SizedBox(width: 16),
                                  // Member info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          member.name,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textWhite,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          memberItems.isEmpty
                                              ? l10n.noPurchasedItems
                                              : l10n.itemsCompletedCount(
                                                memberItems.length,
                                              ),
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: AppColors.textGray,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Amount
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '\$${memberTotal.toStringAsFixed(2)}',
                                        style: theme.textTheme.titleLarge
                                            ?.copyWith(
                                              color:
                                                  memberTotal > 0
                                                      ? AppColors.primaryBlue
                                                      : AppColors.textGray,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      if (memberTotal > 0) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          l10n.contributionPercentage(
                                            percentage.toStringAsFixed(1),
                                          ),
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: AppColors.textGray,
                                              ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                              if (memberItems.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                // Progress bar
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: percentage / 100,
                                    minHeight: 8,
                                    backgroundColor: AppColors.textGrayLight
                                        .withOpacity(0.2),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.primaryBlue,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // View details button
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      l10n.viewItemDetails,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: AppColors.primaryBlue,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 12,
                                      color: AppColors.primaryBlue,
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
