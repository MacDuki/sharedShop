import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../utils/app_colors.dart';

class ShoppingItemCard extends StatelessWidget {
  final ShoppingItemModel item;
  final VoidCallback? onTap;
  final ValueChanged<bool?>? onTogglePurchased;
  final VoidCallback? onDelete;

  const ShoppingItemCard({
    super.key,
    required this.item,
    this.onTap,
    this.onTogglePurchased,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Checkbox
                Checkbox(
                  value: item.isPurchased,
                  onChanged: onTogglePurchased,
                  activeColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),

                // Información del item
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          decoration:
                              item.isPurchased
                                  ? TextDecoration.lineThrough
                                  : null,
                        ),
                      ),
                      if (item.category != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.category!,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Precio
                Text(
                  '\$${item.estimatedPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color:
                        item.isPurchased
                            ? AppColors.textSecondary
                            : AppColors.primaryGreen,
                    decoration:
                        item.isPurchased ? TextDecoration.lineThrough : null,
                  ),
                ),

                // Botón eliminar
                if (onDelete != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: AppColors.errorRed,
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
