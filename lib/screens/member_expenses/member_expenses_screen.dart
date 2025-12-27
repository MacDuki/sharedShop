import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../state/state.dart';
import '../../utils/app_colors.dart';

class MemberExpensesScreen extends StatefulWidget {
  final BudgetModel budget;

  const MemberExpensesScreen({super.key, required this.budget});

  @override
  State<MemberExpensesScreen> createState() => _MemberExpensesScreenState();
}

class _MemberExpensesScreenState extends State<MemberExpensesScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch member expenses when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BudgetProvider>().fetchMemberExpenses(widget.budget.id);
    });
  }

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
          // Handle loading state
          if (budgetProvider.memberExpensesLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            );
          }

          // Handle error state
          if (budgetProvider.memberExpensesError != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.errorRed,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Error al cargar gastos',
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      budgetProvider.memberExpensesError!,
                      style: const TextStyle(
                        color: AppColors.textGray,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        budgetProvider.fetchMemberExpenses(widget.budget.id);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Get data from provider (backend source of truth)
          final memberExpenses = budgetProvider.memberExpenses;
          final grandTotal = budgetProvider.memberExpensesGrandTotal;
          final totalItems = budgetProvider.memberExpensesTotalItems;

          // Handle empty state
          if (memberExpenses.isEmpty) {
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

          // Display member expenses from backend
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
                      '$totalItems ${l10n.itemsPurchased}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textGray,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Members list
              ...memberExpenses.map((memberExpense) {
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
                                    memberExpense.photoURL != null
                                        ? NetworkImage(memberExpense.photoURL!)
                                        : null,
                                child:
                                    memberExpense.photoURL == null
                                        ? Text(
                                          memberExpense.name.isNotEmpty
                                              ? memberExpense.name[0]
                                                  .toUpperCase()
                                              : '?',
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      memberExpense.name,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textWhite,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      l10n.itemsCompletedCount(
                                        memberExpense.itemCount,
                                      ),
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(color: AppColors.textGray),
                                    ),
                                  ],
                                ),
                              ),
                              // Amount
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '\$${memberExpense.totalSpent.toStringAsFixed(2)}',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: AppColors.primaryBlue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n.contributionPercentage(
                                      memberExpense.percentage.toStringAsFixed(
                                        1,
                                      ),
                                    ),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppColors.textGray,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Progress bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: memberExpense.percentage / 100,
                              minHeight: 8,
                              backgroundColor: AppColors.textGrayLight
                                  .withOpacity(0.2),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primaryBlue,
                              ),
                            ),
                          ),
                        ],
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
