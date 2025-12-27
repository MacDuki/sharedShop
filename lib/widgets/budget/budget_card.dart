import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';

class BudgetCard extends StatelessWidget {
  final double totalBudget;
  final double? totalSpent;
  final double? remaining;
  final double? percentage;
  final String? status;

  const BudgetCard({
    super.key,
    required this.totalBudget,
    this.totalSpent,
    this.remaining,
    this.percentage,
    this.status,
  });

  Color _getProgressColor() {
    if (status == null) return AppColors.primaryBlue;

    switch (status!.toLowerCase()) {
      case 'exceeded':
        return AppColors.errorRed;
      case 'warning':
        return AppColors.warningAmber;
      case 'normal':
      default:
        return AppColors.primaryBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Text(
            'Presupuesto Compartido',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),

          // Monto restante (elemento principal)
          Row(
            children: [
              Text(
                remaining != null ? '\$${remaining!.toStringAsFixed(2)}' : '—',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: _getProgressColor(),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'restante',
                style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Barra de progreso
          if (percentage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: percentage! / 100,
                minHeight: 12,
                backgroundColor: AppColors.background,
                valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor()),
              ),
            ),
          if (percentage != null) const SizedBox(height: 16),

          // Detalles
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDetailItem('Total', '\$${totalBudget.toStringAsFixed(2)}'),
              _buildDetailItem(
                'Gastado',
                totalSpent != null
                    ? '\$${totalSpent!.toStringAsFixed(2)}'
                    : '—',
              ),
              _buildDetailItem(
                'Porcentaje',
                percentage != null ? '${percentage!.toStringAsFixed(0)}%' : '—',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
