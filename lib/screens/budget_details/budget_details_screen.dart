import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../state/state.dart';
import '../../utils/app_colors.dart';
import '../budget_form/budget_form_screen.dart';
import '../invite_members/invite_members_screen.dart';
import '../member_expenses/member_expenses_screen.dart';
import '../shopping_list/shopping_list_screen.dart';

class BudgetDetailsScreen extends StatefulWidget {
  final BudgetModel budget;

  const BudgetDetailsScreen({super.key, required this.budget});

  @override
  State<BudgetDetailsScreen> createState() => _BudgetDetailsScreenState();
}

class _BudgetDetailsScreenState extends State<BudgetDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch budget details from backend
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<BudgetProvider>();
      provider.fetchBudgetDetails(widget.budget.id);
      provider.fetchBudgetItems(widget.budget.id);
      provider.fetchBudgetHistory(widget.budget.id);
    });
  }

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
              final provider = context.read<BudgetProvider>();
              if (provider.activeBudget != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            BudgetFormScreen(budget: provider.activeBudget!),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Consumer<BudgetProvider>(
        builder: (context, budgetProvider, child) {
          // Handle loading state
          if (budgetProvider.activeBudgetLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            );
          }

          // Handle error state
          if (budgetProvider.activeBudgetError != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.errorRed,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.errorLoadingBudget,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.textWhite,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    budgetProvider.activeBudgetError!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textGray,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      budgetProvider.fetchBudgetDetails(widget.budget.id);
                      budgetProvider.fetchBudgetItems(widget.budget.id);
                      budgetProvider.fetchBudgetHistory(widget.budget.id);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                    ),
                    child: Text(AppLocalizations.of(context)!.retry),
                  ),
                ],
              ),
            );
          }

          // Handle empty state
          final currentBudget = budgetProvider.activeBudget;
          if (currentBudget == null) {
            return Center(
              child: Text(
                AppLocalizations.of(context)!.budgetNotFound,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textGray,
                ),
              ),
            );
          }

          // Use data from backend (no calculations)
          final totalSpent = currentBudget.totalSpent ?? 0.0;
          final remaining = currentBudget.remaining ?? 0.0;
          final percentage = currentBudget.percentageUsed ?? 0.0;

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
                        const SizedBox(height: 12),
                        // Período dentro del progress bar
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: AppColors.textGray,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${AppLocalizations.of(context)!.duration}: ${_getPeriodText(context, currentBudget.budgetPeriod)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.textGray,
                              ),
                            ),
                          ],
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
                          Row(
                            children: [
                              Text(
                                AppLocalizations.of(context)!.members,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: AppColors.textWhite,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.people,
                                      size: 14,
                                      color: AppColors.primaryBlue,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${budgetProvider.budgetMembers.length}',
                                      style: const TextStyle(
                                        color: AppColors.primaryBlue,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => const InviteMembersScreen(),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.person_add_outlined,
                              size: 18,
                            ),
                            label: Text(AppLocalizations.of(context)!.invite),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Botón Ver Gastos por Miembro
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => MemberExpensesScreen(
                                      budget: currentBudget,
                                    ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.pie_chart_outline, size: 20),
                          label: Text(
                            AppLocalizations.of(context)!.viewExpensesByMember,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Lista de miembros
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight:
                              budgetProvider.budgetMembers.length > 3
                                  ? 250
                                  : double.infinity,
                        ),
                        child: ListView(
                          shrinkWrap: true,
                          physics:
                              budgetProvider.budgetMembers.length > 3
                                  ? const AlwaysScrollableScrollPhysics()
                                  : const NeverScrollableScrollPhysics(),
                          children:
                              budgetProvider.budgetMembers.map((member) {
                                final isOwner =
                                    member.id == currentBudget.ownerId;
                                final canRemove =
                                    !isOwner &&
                                    budgetProvider.currentUser?.id ==
                                        currentBudget.ownerId;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: AppColors.primaryBlue
                                            .withOpacity(0.2),
                                        child: Text(
                                          member.name[0].toUpperCase(),
                                          style: const TextStyle(
                                            color: AppColors.primaryBlue,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  member.name,
                                                  style: theme
                                                      .textTheme
                                                      .bodyLarge
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                ),
                                                if (isOwner) ...[
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: AppColors
                                                          .primaryBlue
                                                          .withOpacity(0.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            4,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      'Owner',
                                                      style: TextStyle(
                                                        color:
                                                            AppColors
                                                                .primaryBlue,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            Text(
                                              member.email,
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    color:
                                                        AppColors.textGrayLight,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (canRemove)
                                        IconButton(
                                          icon: const Icon(
                                            Icons.person_remove_outlined,
                                            color: AppColors.errorRed,
                                            size: 20,
                                          ),
                                          onPressed:
                                              () => _showRemoveMemberDialog(
                                                context,
                                                budgetProvider,
                                                currentBudget,
                                                member,
                                              ),
                                        ),
                                    ],
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Historial del presupuesto
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
                      AppLocalizations.of(context)!.historyTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Handle history loading state
                    if (budgetProvider.historyLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      )
                    // Handle history error state
                    else if (budgetProvider.historyError != null)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: AppColors.errorRed,
                                size: 48,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                budgetProvider.historyError!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.textGray,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    // Show history list
                    else if (budgetProvider.budgetHistory.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            AppLocalizations.of(context)!.noHistoryYet,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textGray,
                            ),
                          ),
                        ),
                      )
                    else
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 400),
                        child: ListView(
                          shrinkWrap: true,
                          physics:
                              budgetProvider.budgetHistory.length > 5
                                  ? const AlwaysScrollableScrollPhysics()
                                  : const NeverScrollableScrollPhysics(),
                          children:
                              budgetProvider.budgetHistory.map((history) {
                                // Use percentageUsed from backend (no calculation)
                                final percentage =
                                    history.percentageUsed ?? 0.0;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: InkWell(
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
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: theme.scaffoldBackgroundColor,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.grey.withOpacity(0.1),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color:
                                                  percentage > 100
                                                      ? AppColors.errorRed
                                                          .withOpacity(0.15)
                                                      : AppColors.success
                                                          .withOpacity(0.15),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Icon(
                                              percentage > 100
                                                  ? Icons.warning_outlined
                                                  : Icons.check_circle_outline,
                                              color:
                                                  percentage > 100
                                                      ? AppColors.errorRed
                                                      : AppColors.success,
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
                                                  '${_formatDate(history.periodStart)} - ${_formatDate(history.periodEnd)}',
                                                  style: theme
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                ),
                                                Text(
                                                  '\$${history.totalSpent.toStringAsFixed(2)} (${percentage.toStringAsFixed(0)}%)',
                                                  style: theme
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color:
                                                            AppColors
                                                                .textGrayLight,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Icon(
                                            Icons.arrow_forward_ios,
                                            size: 16,
                                            color: AppColors.textGrayLight,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
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

  void _showRemoveMemberDialog(
    BuildContext context,
    BudgetProvider budgetProvider,
    BudgetModel budget,
    UserModel member,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardTheme.color,
          title: Text(
            AppLocalizations.of(context)!.removeMember,
            style: const TextStyle(color: AppColors.textWhite),
          ),
          content: Text(
            '${AppLocalizations.of(context)!.removeMemberConfirm} ${member.name}?',
            style: const TextStyle(color: AppColors.textGray),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () {
                // Remove member from budget
                final updatedBudget = budget.copyWith(
                  memberIds:
                      budget.memberIds.where((id) => id != member.id).toList(),
                );
                budgetProvider.updateBudgetData(updatedBudget);

                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${member.name} ${AppLocalizations.of(context)!.removedSuccessfully}',
                    ),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              child: Text(
                AppLocalizations.of(context)!.remove,
                style: const TextStyle(color: AppColors.errorRed),
              ),
            ),
          ],
        );
      },
    );
  }
}
