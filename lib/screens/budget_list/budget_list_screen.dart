import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../state/state.dart';
import '../../utils/app_colors.dart';
import '../budget_form/budget_form_screen.dart';

class BudgetListScreen extends StatelessWidget {
  const BudgetListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
          l10n.myBudgets,
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
          final budgets = budgetProvider.budgets;

          if (budgets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 80,
                    color: AppColors.textGray.withOpacity(0.5),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.noBudgetsYet,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: AppColors.textGray,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.noBudgetsDescription,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textGrayLight,
                    ),
                  ),
                ],
              ),
            );
          }

          final personalBudgets =
              budgets.where((b) => b.type == BudgetType.personal).toList();
          final sharedBudgets =
              budgets.where((b) => b.type == BudgetType.shared).toList();

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Personal Budgets Section
              if (personalBudgets.isNotEmpty) ...[
                _SectionHeader(
                  title: l10n.personalBudgets,
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 12),
                ...personalBudgets.map(
                  (budget) => _BudgetCard(
                    budget: budget,
                    isActive: budget.id == budgetProvider.activeBudget?.id,
                    onTap: () => _handleBudgetTap(context, budget),
                    onEdit: () => _handleEditBudget(context, budget),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Shared Budgets Section
              if (sharedBudgets.isNotEmpty) ...[
                _SectionHeader(
                  title: l10n.sharedBudgets,
                  icon: Icons.people_outline,
                ),
                const SizedBox(height: 12),
                ...sharedBudgets.map(
                  (budget) => _BudgetCard(
                    budget: budget,
                    isActive: budget.id == budgetProvider.activeBudget?.id,
                    onTap: () => _handleBudgetTap(context, budget),
                    onEdit: () => _handleEditBudget(context, budget),
                  ),
                ),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _handleCreateBudget(context),
        icon: const Icon(Icons.add),
        label: Text(AppLocalizations.of(context)!.newBudget),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }

  void _handleBudgetTap(BuildContext context, BudgetModel budget) {
    final budgetProvider = context.read<BudgetProvider>();
    final l10n = AppLocalizations.of(context)!;
    budgetProvider.setActiveBudget(budget.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.switchedToBudget(budget.name)),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );

    Navigator.of(context).pop();
  }

  void _handleEditBudget(BuildContext context, BudgetModel budget) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BudgetFormScreen(budget: budget)),
    );
  }

  void _handleCreateBudget(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BudgetFormScreen()),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, color: AppColors.primaryBlue, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            color: AppColors.textWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _BudgetCard extends StatelessWidget {
  final BudgetModel budget;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const _BudgetCard({
    required this.budget,
    required this.isActive,
    required this.onTap,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border:
            isActive
                ? Border.all(color: AppColors.primaryGreen, width: 2)
                : isDark
                ? null
                : Border.all(color: Colors.grey.withOpacity(0.15), width: 1),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Budget Icon/Color
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _getBudgetColor().withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getBudgetIcon(),
                        color: _getBudgetColor(),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Budget Name and Type
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  budget.name,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: AppColors.textWhite,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isActive)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryGreen.withOpacity(
                                      0.15,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.activeBudget.toUpperCase(),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppColors.primaryGreen,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                budget.type == BudgetType.personal
                                    ? Icons.person_outline
                                    : Icons.people_outline,
                                size: 14,
                                color: AppColors.textGrayLight,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                budget.type == BudgetType.personal
                                    ? AppLocalizations.of(context)!.personal
                                    : AppLocalizations.of(
                                      context,
                                    )!.membersCount(budget.memberIds.length),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.textGrayLight,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Edit Button
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      color: AppColors.textGray,
                      onPressed: onEdit,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Budget Amount
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.budgetAmount,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textGrayLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${budget.budgetAmount.toStringAsFixed(2)}',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: AppColors.textWhite,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    // Period Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getPeriodText(context),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getBudgetColor() {
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

  IconData _getBudgetIcon() {
    if (budget.iconName != null) {
      // Map icon names to IconData
      switch (budget.iconName) {
        case 'shopping_cart':
          return Icons.shopping_cart_outlined;
        case 'home':
          return Icons.home_outlined;
        case 'restaurant':
          return Icons.restaurant_outlined;
        case 'local_grocery_store':
          return Icons.local_grocery_store_outlined;
        default:
          break;
      }
    }
    return budget.type == BudgetType.personal
        ? Icons.account_balance_wallet_outlined
        : Icons.people_outline;
  }

  String _getPeriodText(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (budget.budgetPeriod) {
      case BudgetPeriod.weekly:
        return l10n.weekly;
      case BudgetPeriod.monthly:
        return l10n.monthly;
      case BudgetPeriod.custom:
        return l10n.custom;
    }
  }
}
