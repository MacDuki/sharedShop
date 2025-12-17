import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../state/state.dart';
import '../../utils/app_colors.dart';
import '../add_item/add_item_screen.dart';

class ShoppingListScreen extends StatelessWidget {
  const ShoppingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Consumer<BudgetProvider>(
          builder: (context, budgetProvider, child) {
            final items = budgetProvider.shoppingItems;
            final household = budgetProvider.household;

            if (household == null) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryBlue),
              );
            }

            return Column(
              children: [
                // Custom Header
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  decoration: const BoxDecoration(
                    color: AppColors.darkBackground,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.darkCard,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.arrow_back,
                            color: AppColors.textWhite,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SHOPPING LIST',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textGray,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${items.length} ${items.length == 1 ? 'ítem' : 'ítems'}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textWhite,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.darkCard,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddItemScreen(),
                              ),
                            );
                          },
                          child: const Icon(
                            Icons.add,
                            color: AppColors.primaryBlue,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Budget Summary Card
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'TOTAL',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textGray,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '\$${budgetProvider.totalSpent.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textWhite,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 50,
                              color: AppColors.darkBackground,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'REMAINING',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textGray,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '\$${budgetProvider.remainingBudget.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: _getTotalColor(
                                        budgetProvider.budgetState,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value:
                                budgetProvider.budgetPercentage > 100
                                    ? 1.0
                                    : budgetProvider.budgetPercentage / 100,
                            minHeight: 10,
                            backgroundColor: AppColors.darkBackground,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getTotalColor(budgetProvider.budgetState),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${budgetProvider.budgetPercentage.toStringAsFixed(0)}% usado',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textGray,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (budgetProvider.budgetState ==
                                BudgetState.exceeded)
                              Row(
                                children: [
                                  Icon(
                                    Icons.warning_rounded,
                                    size: 14,
                                    color: AppColors.errorRed,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Presupuesto excedido',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.errorRed,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                            else if (budgetProvider.budgetState ==
                                BudgetState.warning)
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 14,
                                    color: AppColors.warningAmber,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Cerca del límite',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.warningAmber,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Lista de items
                Expanded(
                  child:
                      items.isEmpty
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: AppColors.darkCard,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.shopping_cart_outlined,
                                    size: 50,
                                    color: AppColors.textGray.withOpacity(0.5),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  'Lista vacía',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textWhite,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 48,
                                  ),
                                  child: Text(
                                    'Agrega ítems a tu lista de compras\npara comenzar',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: AppColors.textGray,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => const AddItemScreen(),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.add),
                                  label: const Text('Agregar Primer Ítem'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryBlue,
                                    foregroundColor: AppColors.textWhite,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                          : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                            itemCount: items.length,
                            separatorBuilder:
                                (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return _ItemCard(
                                item: item,
                                onTap: () {
                                  _showEditItemDialog(
                                    context,
                                    item,
                                    budgetProvider,
                                  );
                                },
                                onTogglePurchased: () {
                                  budgetProvider.toggleItemPurchased(item.id);
                                },
                                onDelete: () {
                                  _showDeleteConfirmation(
                                    context,
                                    item,
                                    budgetProvider,
                                  );
                                },
                              );
                            },
                          ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: Consumer<BudgetProvider>(
        builder: (context, budgetProvider, child) {
          final items = budgetProvider.shoppingItems;
          if (items.isEmpty) return const SizedBox.shrink();

          return FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddItemScreen()),
              );
            },
            backgroundColor: AppColors.primaryBlue,
            elevation: 4,
            child: const Icon(Icons.add, size: 28),
          );
        },
      ),
    );
  }

  Color _getTotalColor(BudgetState state) {
    switch (state) {
      case BudgetState.normal:
        return AppColors.primaryGreen;
      case BudgetState.warning:
        return AppColors.warningAmber;
      case BudgetState.exceeded:
        return AppColors.errorRed;
    }
  }

  void _showEditItemDialog(
    BuildContext context,
    ShoppingItemModel item,
    BudgetProvider budgetProvider,
  ) {
    final nameController = TextEditingController(text: item.name);
    final priceController = TextEditingController(
      text: item.estimatedPrice.toString(),
    );
    final categoryController = TextEditingController(text: item.category ?? '');

    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Editar Ítem'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: 'Precio Estimado *',
                      border: OutlineInputBorder(),
                      prefixText: '\$ ',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: categoryController,
                    decoration: const InputDecoration(
                      labelText: 'Categoría (opcional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  final priceStr = priceController.text.trim();
                  final category = categoryController.text.trim();

                  if (name.isEmpty || priceStr.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Por favor completa los campos obligatorios',
                        ),
                        backgroundColor: AppColors.errorRed,
                      ),
                    );
                    return;
                  }

                  final price = double.tryParse(priceStr);
                  if (price == null || price <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Por favor ingresa un precio válido'),
                        backgroundColor: AppColors.errorRed,
                      ),
                    );
                    return;
                  }

                  final updatedItem = item.copyWith(
                    name: name,
                    estimatedPrice: price,
                    category: category.isEmpty ? null : category,
                  );

                  budgetProvider.updateItem(item.id, updatedItem);
                  Navigator.pop(dialogContext);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ítem actualizado'),
                      backgroundColor: AppColors.primaryGreen,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                ),
                child: const Text('Guardar'),
              ),
            ],
          ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    ShoppingItemModel item,
    BudgetProvider budgetProvider,
  ) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Eliminar Ítem'),
            content: Text(
              '¿Estás seguro de que quieres eliminar "${item.name}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  budgetProvider.deleteItem(item.id);
                  Navigator.pop(dialogContext);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${item.name} eliminado'),
                      backgroundColor: AppColors.errorRed,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.errorRed,
                ),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final ShoppingItemModel item;
  final VoidCallback onTap;
  final VoidCallback onTogglePurchased;
  final VoidCallback onDelete;

  const _ItemCard({
    required this.item,
    required this.onTap,
    required this.onTogglePurchased,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              item.isPurchased
                  ? AppColors.primaryGreen.withOpacity(0.3)
                  : Colors.transparent,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Checkbox
                InkWell(
                  onTap: onTogglePurchased,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            item.isPurchased
                                ? AppColors.primaryGreen
                                : AppColors.textGray,
                        width: 2,
                      ),
                      color:
                          item.isPurchased
                              ? AppColors.primaryGreen
                              : Colors.transparent,
                    ),
                    child:
                        item.isPurchased
                            ? const Icon(
                              Icons.check,
                              size: 16,
                              color: AppColors.textWhite,
                            )
                            : null,
                  ),
                ),
                const SizedBox(width: 16),

                // Item info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color:
                              item.isPurchased
                                  ? AppColors.textGray
                                  : AppColors.textWhite,
                          decoration:
                              item.isPurchased
                                  ? TextDecoration.lineThrough
                                  : null,
                        ),
                      ),
                      if (item.category != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.darkBackground,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.category!,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textGray,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${item.estimatedPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color:
                            item.isPurchased
                                ? AppColors.textGray
                                : AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 8),

                // Delete button
                InkWell(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.errorRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: AppColors.errorRed,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
