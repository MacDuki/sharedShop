import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../state/state.dart';
import '../../utils/app_colors.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  String _formatPeriod(DateTime start, DateTime end) {
    final startFormat = DateFormat('d MMM');
    final endFormat = DateFormat('d MMM yyyy');
    return '${startFormat.format(start)} - ${endFormat.format(end)}';
  }

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
          l10n.historyTitle,
          style: const TextStyle(
            color: AppColors.textWhite,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Consumer<BudgetProvider>(
          builder: (context, budgetProvider, child) {
            // Handle loading state
            if (budgetProvider.historyLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryBlue),
              );
            }

            // Handle error state
            if (budgetProvider.historyError != null) {
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
                        'Error al cargar el historial',
                        style: TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        budgetProvider.historyError!,
                        style: const TextStyle(
                          color: AppColors.textGray,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            final history = budgetProvider.budgetHistory;

            // Handle empty state
            if (history.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history,
                      size: 80,
                      color: AppColors.textGray.withOpacity(0.5),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Sin historial aún',
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48),
                      child: Text(
                        'El historial de períodos anteriores\naparecerá aquí',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textGray,
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: history.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final period = history[index];

                // Get budget data from backend - no fallback/invention
                final budget = budgetProvider.budgets.firstWhere(
                  (b) => b.id == period.budgetId,
                  orElse: () => null as BudgetModel,
                );

                // If budget not found, skip rendering this history item
                if (budget == null) {
                  return const SizedBox.shrink();
                }

                // Use percentage from backend, not calculated in UI
                final percentage = period.percentageUsed ?? 0.0;
                final budgetAmount = budget.budgetAmount;

                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.darkCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          percentage > 100
                              ? AppColors.errorRed.withOpacity(0.3)
                              : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Información del presupuesto
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  budget.name,
                                  style: const TextStyle(
                                    color: AppColors.textWhite,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      budget.type == BudgetType.personal
                                          ? Icons.person_outline
                                          : Icons.group_outlined,
                                      size: 14,
                                      color: AppColors.textGray,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      budget.type == BudgetType.personal
                                          ? l10n.personal
                                          : l10n.shared,
                                      style: const TextStyle(
                                        color: AppColors.textGray,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Período
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.darkBackground,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 14,
                                  color: AppColors.primaryBlue,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _formatPeriod(
                                    period.periodStart,
                                    period.periodEnd,
                                  ),
                                  style: TextStyle(
                                    color: AppColors.textWhite,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          // Badge de estado
                          if (percentage > 100)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.errorRed.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.warning_rounded,
                                    size: 12,
                                    color: AppColors.errorRed,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    l10n.exceeded,
                                    style: TextStyle(
                                      color: AppColors.errorRed,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else if (percentage >= 90)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.warningAmber.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                l10n.nearLimit,
                                style: TextStyle(
                                  color: AppColors.warningAmber,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    size: 12,
                                    color: AppColors.success,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    l10n.underControl,
                                    style: TextStyle(
                                      color: AppColors.success,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Total gastado
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.totalSpentLabel,
                                style: TextStyle(
                                  color: AppColors.textGray,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '\$${period.totalSpent.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color:
                                      percentage > 100
                                          ? AppColors.errorRed
                                          : AppColors.textWhite,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                l10n.ofAmount(
                                  '\$${budgetAmount.toStringAsFixed(2)}',
                                ),
                                style: TextStyle(
                                  color: AppColors.textGray,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${percentage.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  color:
                                      percentage > 100
                                          ? AppColors.errorRed
                                          : percentage >= 70
                                          ? AppColors.warningAmber
                                          : AppColors.primaryGreen,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Barra de progreso
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: percentage > 100 ? 1.0 : percentage / 100,
                          backgroundColor: AppColors.darkBackground,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            percentage > 100
                                ? AppColors.errorRed
                                : percentage >= 70
                                ? AppColors.warningAmber
                                : AppColors.primaryGreen,
                          ),
                          minHeight: 10,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
