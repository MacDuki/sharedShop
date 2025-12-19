import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../state/budget_provider.dart';
import '../../utils/app_colors.dart';

class ShoppingItemCard extends StatefulWidget {
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
  State<ShoppingItemCard> createState() => _ShoppingItemCardState();
}

class _ShoppingItemCardState extends State<ShoppingItemCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);

    // Obtener información del creador dinámicamente
    final creator = budgetProvider.householdMembers.firstWhere(
      (member) => member.id == widget.item.createdBy,
      orElse:
          () => UserModel(
            id: widget.item.createdBy,
            name: 'Unknown User',
            email: '',
            householdId: '',
            budgetIds: [],
          ),
    );

    // Obtener información de quién completó el item (si está completado)
    UserModel? purchaser;
    if (widget.item.isPurchased && widget.item.purchasedBy != null) {
      purchaser = budgetProvider.householdMembers.firstWhere(
        (member) => member.id == widget.item.purchasedBy,
        orElse:
            () => UserModel(
              id: widget.item.purchasedBy!,
              name: 'Unknown User',
              email: '',
              householdId: '',
              budgetIds: [],
            ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color:
            widget.item.isPurchased
                ? AppColors.primaryGreen.withOpacity(0.1)
                : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border:
            widget.item.isPurchased
                ? Border.all(
                  color: AppColors.primaryGreen.withOpacity(0.3),
                  width: 2,
                )
                : null,
        boxShadow: [
          BoxShadow(
            color:
                widget.item.isPurchased
                    ? AppColors.primaryGreen.withOpacity(0.1)
                    : Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            InkWell(
              onTap: widget.onTap,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
                bottom: Radius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Foto del creador
                    _buildCreatorAvatar(creator),
                    const SizedBox(width: 8),

                    // Checkbox
                    Checkbox(
                      value: widget.item.isPurchased,
                      onChanged: widget.onTogglePurchased,
                      activeColor: AppColors.primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(width: 8),

                    // Información del item
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.item.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color:
                                  widget.item.isPurchased
                                      ? AppColors.textSecondary
                                      : AppColors.textPrimary,
                              decoration:
                                  widget.item.isPurchased
                                      ? TextDecoration.lineThrough
                                      : null,
                            ),
                          ),
                          if (widget.item.category != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              widget.item.category!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                          if (widget.item.isPurchased) ...[
                            const SizedBox(height: 2),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 14,
                                  color: AppColors.primaryGreen,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    'Completed',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.primaryGreen,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Precio
                    Text(
                      '\$${widget.item.estimatedPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color:
                            widget.item.isPurchased
                                ? AppColors.textSecondary
                                : AppColors.primaryGreen,
                        decoration:
                            widget.item.isPurchased
                                ? TextDecoration.lineThrough
                                : null,
                      ),
                    ),

                    // Botón expandir
                    const SizedBox(width: 4),
                    IconButton(
                      icon: RotationTransition(
                        turns: Tween(
                          begin: 0.0,
                          end: 0.5,
                        ).animate(_expandAnimation),
                        child: const Icon(Icons.keyboard_arrow_down, size: 20),
                      ),
                      color: AppColors.textSecondary,
                      onPressed: _toggleExpanded,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),

                    // Botón eliminar
                    if (widget.onDelete != null) ...[
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        color: AppColors.errorRed,
                        onPressed: widget.onDelete,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Contenido expandible
            SizeTransition(
              sizeFactor: _expandAnimation,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  children: [
                    Divider(
                      color: AppColors.textSecondary.withOpacity(0.2),
                      height: 1,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      icon: Icons.person_outline,
                      label: 'Created by',
                      value: creator.name,
                      avatar: creator,
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      icon: Icons.calendar_today,
                      label: 'Created on',
                      value: _formatDateTime(widget.item.createdAt),
                    ),
                    if (widget.item.isPurchased && purchaser != null) ...[
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        icon: Icons.check_circle_outline,
                        label: 'Completed by',
                        value: purchaser.name,
                        avatar: purchaser,
                        valueColor: AppColors.primaryGreen,
                      ),
                      if (widget.item.purchasedAt != null) ...[
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          icon: Icons.event_available,
                          label: 'Completed on',
                          value: _formatDateTime(widget.item.purchasedAt!),
                          valueColor: AppColors.primaryGreen,
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreatorAvatar(UserModel creator) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryPurple.withOpacity(0.2),
        border: Border.all(
          color:
              widget.item.isPurchased
                  ? AppColors.primaryGreen.withOpacity(0.5)
                  : AppColors.primaryPurple.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          creator.name.isNotEmpty ? creator.name[0].toUpperCase() : '?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color:
                widget.item.isPurchased
                    ? AppColors.primaryGreen
                    : AppColors.primaryPurple,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    UserModel? avatar,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        if (avatar != null) ...[
          const SizedBox(width: 4),
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryPurple.withOpacity(0.2),
            ),
            child: Center(
              child: Text(
                avatar.name.isNotEmpty ? avatar.name[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryPurple,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
        ],
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${DateFormat('HH:mm').format(dateTime)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(dateTime);
    }
  }
}
