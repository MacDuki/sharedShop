import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../state/state.dart';
import '../../utils/app_colors.dart';
import '../budget_form/budget_form_screen.dart';

class BudgetDetailsScreen extends StatelessWidget {
  final BudgetModel budget;

  const BudgetDetailsScreen({super.key, required this.budget});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
          AppLocalizations.of(context)!.budgetDetails,
          style: const TextStyle(
            color: AppColors.textWhite,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.primaryBlue),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BudgetFormScreen(budget: budget),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<BudgetProvider>(
        builder: (context, budgetProvider, child) {
          final currentBudget = budgetProvider.budgets.firstWhere(
            (b) => b.id == budget.id,
            orElse: () => budget,
          );

          final items = budgetProvider.getItemsForBudget(currentBudget.id);
          final totalSpent = items.fold(
            0.0,
            (sum, item) => sum + item.estimatedPrice,
          );
          final remaining = currentBudget.budgetAmount - totalSpent;
          final percentage =
              currentBudget.budgetAmount > 0
                  ? (totalSpent / currentBudget.budgetAmount * 100).clamp(
                    0.0,
                    100.0,
                  )
                  : 0.0;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Budget Header Card
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
                    // Icon
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: _getBudgetColor(currentBudget).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        _getBudgetIcon(currentBudget),
                        color: _getBudgetColor(currentBudget),
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Budget Name
                    Text(
                      currentBudget.name,
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (currentBudget.description != null &&
                        currentBudget.description!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        currentBudget.description!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textGray,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 16),
                    // Type Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: (currentBudget.type == BudgetType.personal
                                ? AppColors.primaryBlue
                                : AppColors.primaryPurple)
                            .withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            currentBudget.type == BudgetType.personal
                                ? Icons.person_outline
                                : Icons.people_outline,
                            size: 16,
                            color:
                                currentBudget.type == BudgetType.personal
                                    ? AppColors.primaryBlue
                                    : AppColors.primaryPurple,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            currentBudget.type == BudgetType.personal
                                ? AppLocalizations.of(context)!.personalBudget
                                : AppLocalizations.of(context)!.sharedBudget,
                            style: TextStyle(
                              color:
                                  currentBudget.type == BudgetType.personal
                                      ? AppColors.primaryBlue
                                      : AppColors.primaryPurple,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Budget Overview Card
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.budgetOverview,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Progress Bar
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.spent,
                              style: theme.textTheme.bodyMedium,
                            ),
                            Text(
                              '${percentage.toStringAsFixed(1)}%',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            minHeight: 10,
                            backgroundColor: AppColors.textGrayLight
                                .withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getProgressColor(percentage),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Budget Stats
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            theme,
                            AppLocalizations.of(context)!.totalBudget,
                            '\$${currentBudget.budgetAmount.toStringAsFixed(2)}',
                            AppColors.primaryBlue,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 50,
                          color: AppColors.textGrayLight.withOpacity(0.2),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            theme,
                            AppLocalizations.of(context)!.spent,
                            '\$${totalSpent.toStringAsFixed(2)}',
                            AppColors.warningAmber,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 50,
                          color: AppColors.textGrayLight.withOpacity(0.2),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            theme,
                            AppLocalizations.of(context)!.remaining,
                            '\$${remaining.toStringAsFixed(2)}',
                            remaining >= 0
                                ? AppColors.success
                                : AppColors.errorRed,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Period Info
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.period,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      context,
                      Icons.calendar_today_outlined,
                      AppLocalizations.of(context)!.duration,
                      _getPeriodText(context, currentBudget.budgetPeriod),
                    ),
                    if (currentBudget.budgetPeriod == BudgetPeriod.custom &&
                        currentBudget.customPeriodStart != null &&
                        currentBudget.customPeriodEnd != null) ...[
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        context,
                        Icons.date_range_outlined,
                        AppLocalizations.of(context)!.from,
                        _formatDate(currentBudget.customPeriodStart!),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        context,
                        Icons.date_range_outlined,
                        AppLocalizations.of(context)!.to,
                        _formatDate(currentBudget.customPeriodEnd!),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Members Section (for shared budgets)
              if (currentBudget.type == BudgetType.shared) ...[
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.members,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: AppColors.textWhite,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              // TODO: Navigate to member management
                            },
                            icon: const Icon(
                              Icons.person_add_outlined,
                              size: 18,
                            ),
                            label: Text(AppLocalizations.of(context)!.invite),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppLocalizations.of(
                          context,
                        )!.membersCount(currentBudget.memberIds.length),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textGray,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Recent Items
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.recentItems,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (items.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            AppLocalizations.of(context)!.noItemsYet,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textGray,
                            ),
                          ),
                        ),
                      )
                    else
                      ...items
                          .take(5)
                          .map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryBlue.withOpacity(
                                        0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.shopping_bag_outlined,
                                      color: AppColors.primaryBlue,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: theme.textTheme.bodyLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                        if (item.category != null)
                                          Text(
                                            item.category!,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  color:
                                                      AppColors.textGrayLight,
                                                ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '\$${item.estimatedPrice.toStringAsFixed(2)}',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: AppColors.textWhite,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatItem(
    ThemeData theme,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textGrayLight,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryBlue),
        const SizedBox(width: 12),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textGray),
        ),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

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

  Color _getProgressColor(double percentage) {
    if (percentage >= 100) return AppColors.errorRed;
    if (percentage >= 70) return AppColors.warningAmber;
    return AppColors.success;
  }

  String _getPeriodText(BuildContext context, BudgetPeriod period) {
    final l10n = AppLocalizations.of(context)!;
    switch (period) {
      case BudgetPeriod.weekly:
        return l10n.weekly;
      case BudgetPeriod.monthly:
        return l10n.monthly;
      case BudgetPeriod.custom:
        return l10n.custom;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
