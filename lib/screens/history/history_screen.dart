import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
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
            final history = budgetProvider.budgetHistory;

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
                final household = budgetProvider.household;
                final budgetAmount = household?.budgetAmount ?? 0;
                final percentage =
                    budgetAmount > 0
                        ? (period.totalSpent / budgetAmount) * 100
                        : 0;

                return Dismissible(
                  key: Key(period.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    decoration: BoxDecoration(
                      color: AppColors.errorRed,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.delete,
                      color: AppColors.textWhite,
                      size: 28,
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: AppColors.darkCard,
                          title: const Text(
                            'Eliminar período',
                            style: TextStyle(color: AppColors.textWhite),
                          ),
                          content: Text(
                            '¿Estás seguro de que quieres eliminar este período del historial?',
                            style: TextStyle(color: AppColors.textGray),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancelar'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.errorRed,
                              ),
                              child: const Text('Eliminar'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  onDismissed: (direction) {
                    budgetProvider.deleteBudgetHistory(period.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Período eliminado del historial'),
                        backgroundColor: AppColors.errorRed,
                      ),
                    );
                  },
                  child: Container(
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
                                  color: AppColors.warningAmber.withOpacity(
                                    0.2,
                                  ),
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

                        // Diferencia
                        if (percentage > 100) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                Icons.arrow_upward,
                                size: 14,
                                color: AppColors.errorRed,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                l10n.exceededBy(
                                  '\$${(period.totalSpent - budgetAmount).toStringAsFixed(2)}',
                                ),
                                style: TextStyle(
                                  color: AppColors.errorRed,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ] else if (budgetAmount - period.totalSpent > 0) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                Icons.savings_outlined,
                                size: 14,
                                color: AppColors.primaryGreen,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                l10n.saved(
                                  '\$${(budgetAmount - period.totalSpent).toStringAsFixed(2)}',
                                ),
                                style: TextStyle(
                                  color: AppColors.primaryGreen,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
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
