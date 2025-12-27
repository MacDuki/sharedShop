import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../state/state.dart';
import '../../utils/app_colors.dart';
import '../../widgets/shopping/shopping_item_card.dart';
import '../add_item/add_item_screen.dart';

class ShoppingListScreen extends StatelessWidget {
  const ShoppingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Consumer<BudgetProvider>(
          builder: (context, budgetProvider, child) {
            // Estado de carga inicial
            if (budgetProvider.activeBudgetLoading ||
                budgetProvider.itemsLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryBlue),
              );
            }

            // Estado de error
            if (budgetProvider.activeBudgetError != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.errorRed,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.errorLoadingBudget,
                      style: const TextStyle(
                        fontSize: 18,
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        budgetProvider.activeBudgetError!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textGray,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            // Estado sin presupuesto activo
            if (budgetProvider.activeBudget == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 64,
                      color: AppColors.textGray,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noBudgetSelected,
                      style: const TextStyle(
                        fontSize: 18,
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }

            // Datos del backend - sin procesamiento local
            final items = budgetProvider.shoppingItems;
            final activeBudget = budgetProvider.activeBudget!;

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
                              l10n.shoppingList,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textGray,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              items.length == 1
                                  ? l10n.item(items.length)
                                  : l10n.items(items.length),
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

                // Budget Summary Card - Datos del backend
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
                                    l10n.total,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textGray,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    activeBudget.totalSpent != null
                                        ? '\$${activeBudget.totalSpent!.toStringAsFixed(2)}'
                                        : '\$0.00',
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
                                    l10n.remaining,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textGray,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    activeBudget.remaining != null
                                        ? '\$${activeBudget.remaining!.toStringAsFixed(2)}'
                                        : '\$${activeBudget.budgetAmount.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: _getStatusColor(
                                        activeBudget.status,
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
                                activeBudget.percentageUsed != null
                                    ? (activeBudget.percentageUsed! > 100
                                        ? 1.0
                                        : activeBudget.percentageUsed! / 100)
                                    : 0.0,
                            minHeight: 10,
                            backgroundColor: AppColors.darkBackground,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getStatusColor(activeBudget.status),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              activeBudget.percentageUsed != null
                                  ? l10n.percentageUsed(
                                    activeBudget.percentageUsed!
                                        .toStringAsFixed(0),
                                  )
                                  : l10n.percentageUsed('0'),
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textGray,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (activeBudget.status == 'exceeded')
                              Row(
                                children: [
                                  const Icon(
                                    Icons.warning_rounded,
                                    size: 14,
                                    color: AppColors.errorRed,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    l10n.budgetExceeded,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.errorRed,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                            else if (activeBudget.status == 'warning')
                              Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    size: 14,
                                    color: AppColors.warningAmber,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    l10n.nearLimit,
                                    style: const TextStyle(
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
                                    color: AppColors.textGray.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  l10n.emptyShoppingList,
                                  style: const TextStyle(
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
                                    l10n.emptyShoppingListDescription,
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
                                  label: Text(l10n.addFirstItem),
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
                              return ShoppingItemCard(
                                item: item,
                                onTap: () {
                                  _showEditItemDialog(
                                    context,
                                    item,
                                    budgetProvider,
                                  );
                                },
                                onTogglePurchased: (value) {
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

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'exceeded':
        return AppColors.errorRed;
      case 'warning':
        return AppColors.warningAmber;
      case 'normal':
      default:
        return AppColors.primaryGreen;
    }
  }

  void _showEditItemDialog(
    BuildContext context,
    ShoppingItemModel item,
    BudgetProvider budgetProvider,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController(text: item.name);
    final priceController = TextEditingController(
      text: item.estimatedPrice.toString(),
    );
    final categoryController = TextEditingController(text: item.category ?? '');

    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(l10n.editItem),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: l10n.nameRequired,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: priceController,
                    decoration: InputDecoration(
                      labelText: l10n.estimatedPriceRequired,
                      border: const OutlineInputBorder(),
                      prefixText: '\$ ',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: categoryController,
                    decoration: InputDecoration(
                      labelText: l10n.categoryOptional,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                onPressed: () async {
                  final navigator = Navigator.of(dialogContext);
                  final messenger = ScaffoldMessenger.of(context);

                  final name = nameController.text.trim();
                  final priceStr = priceController.text.trim();
                  final category = categoryController.text.trim();

                  if (name.isEmpty || priceStr.isEmpty) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(l10n.requiredFieldsMissing),
                        backgroundColor: AppColors.errorRed,
                      ),
                    );
                    return;
                  }

                  final price = double.tryParse(priceStr);
                  if (price == null || price <= 0) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(l10n.invalidPriceError),
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

                  try {
                    await budgetProvider.updateItem(item.id, updatedItem);
                    navigator.pop();
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(l10n.itemUpdated),
                        backgroundColor: AppColors.primaryGreen,
                      ),
                    );
                  } catch (e) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                        backgroundColor: AppColors.errorRed,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                ),
                child: Text(l10n.save),
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
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(l10n.deleteItemTitle),
            content: Text(l10n.deleteItemConfirm(item.name)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                onPressed: () async {
                  final navigator = Navigator.of(dialogContext);
                  final messenger = ScaffoldMessenger.of(context);
                  final itemName = item.name;

                  try {
                    await budgetProvider.deleteItem(item.id);
                    navigator.pop();
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(l10n.itemDeleted(itemName)),
                        backgroundColor: AppColors.errorRed,
                      ),
                    );
                  } catch (e) {
                    navigator.pop();
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                        backgroundColor: AppColors.errorRed,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.errorRed,
                ),
                child: Text(l10n.delete),
              ),
            ],
          ),
    );
  }
}
