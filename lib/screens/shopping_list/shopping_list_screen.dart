import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../state/state.dart';
import '../../utils/app_colors.dart';
import '../add_item/add_item_screen.dart';

enum SortOption { name, price, status }

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  String? _selectedCategory;
  SortOption _sortOption = SortOption.name;
  bool _ascending = true;

  List<ShoppingItemModel> _filterAndSortItems(List<ShoppingItemModel> items) {
    // Filtrar por categoría
    List<ShoppingItemModel> filtered;
    if (_selectedCategory != null && _selectedCategory != 'all') {
      filtered =
          items.where((item) => item.category == _selectedCategory).toList();
    } else {
      filtered = List.from(items); // Crear copia mutable
    }

    // Ordenar
    filtered.sort((a, b) {
      int comparison = 0;
      switch (_sortOption) {
        case SortOption.name:
          comparison = a.name.toLowerCase().compareTo(b.name.toLowerCase());
          break;
        case SortOption.price:
          comparison = a.estimatedPrice.compareTo(b.estimatedPrice);
          break;
        case SortOption.status:
          comparison = (a.isPurchased ? 1 : 0).compareTo(b.isPurchased ? 1 : 0);
          break;
      }
      return _ascending ? comparison : -comparison;
    });

    return filtered;
  }

  Set<String> _getCategories(List<ShoppingItemModel> items) {
    return items
        .map((item) => item.category)
        .where((category) => category != null)
        .cast<String>()
        .toSet();
  }

  void _showFilterDialog(BuildContext context, List<ShoppingItemModel> items) {
    final l10n = AppLocalizations.of(context)!;
    final categories = _getCategories(items);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.75,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 24,
                      right: 24,
                      top: 24,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.filterAndSort,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textWhite,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Filtro por categoría
                        Text(
                          l10n.filterAndSort,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textWhite,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Filtro por categoría
                        Text(
                          l10n.category,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textGray,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            FilterChip(
                              label: Text(l10n.all),
                              selected:
                                  _selectedCategory == null ||
                                  _selectedCategory == 'all',
                              onSelected: (selected) {
                                setState(
                                  () =>
                                      _selectedCategory =
                                          selected ? 'all' : null,
                                );
                                setModalState(() {});
                              },
                              backgroundColor: AppColors.darkBackground,
                              selectedColor: AppColors.primaryBlue.withValues(
                                alpha: 0.3,
                              ),
                              labelStyle: TextStyle(
                                color:
                                    (_selectedCategory == null ||
                                            _selectedCategory == 'all')
                                        ? AppColors.primaryBlue
                                        : AppColors.textGray,
                              ),
                            ),
                            ...categories.map(
                              (category) => FilterChip(
                                label: Text(category),
                                selected: _selectedCategory == category,
                                onSelected: (selected) {
                                  setState(
                                    () =>
                                        _selectedCategory =
                                            selected ? category : null,
                                  );
                                  setModalState(() {});
                                },
                                backgroundColor: AppColors.darkBackground,
                                selectedColor: AppColors.primaryBlue.withValues(
                                  alpha: 0.3,
                                ),
                                labelStyle: TextStyle(
                                  color:
                                      _selectedCategory == category
                                          ? AppColors.primaryBlue
                                          : AppColors.textGray,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Ordenar por
                        Text(
                          l10n.sortBy,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textGray,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Column(
                          children: [
                            RadioListTile<SortOption>(
                              title: Text(
                                l10n.name,
                                style: const TextStyle(
                                  color: AppColors.textWhite,
                                ),
                              ),
                              value: SortOption.name,
                              groupValue: _sortOption,
                              onChanged: (value) {
                                setState(() => _sortOption = value!);
                                setModalState(() {});
                              },
                              activeColor: AppColors.primaryBlue,
                            ),
                            RadioListTile<SortOption>(
                              title: Text(
                                l10n.price,
                                style: const TextStyle(
                                  color: AppColors.textWhite,
                                ),
                              ),
                              value: SortOption.price,
                              groupValue: _sortOption,
                              onChanged: (value) {
                                setState(() => _sortOption = value!);
                                setModalState(() {});
                              },
                              activeColor: AppColors.primaryBlue,
                            ),
                            RadioListTile<SortOption>(
                              title: Text(
                                l10n.status,
                                style: const TextStyle(
                                  color: AppColors.textWhite,
                                ),
                              ),
                              value: SortOption.status,
                              groupValue: _sortOption,
                              onChanged: (value) {
                                setState(() => _sortOption = value!);
                                setModalState(() {});
                              },
                              activeColor: AppColors.primaryBlue,
                            ),
                          ],
                        ),

                        // Orden ascendente/descendente
                        SwitchListTile(
                          title: Text(
                            _ascending ? l10n.ascending : l10n.descending,
                            style: const TextStyle(color: AppColors.textWhite),
                          ),
                          value: _ascending,
                          onChanged: (value) {
                            setState(() => _ascending = value);
                            setModalState(() {});
                          },
                          activeColor: AppColors.primaryBlue,
                        ),

                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(l10n.apply),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Consumer<BudgetProvider>(
          builder: (context, budgetProvider, child) {
            final allItems = budgetProvider.shoppingItems;
            final items = _filterAndSortItems(allItems);
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
                              l10n.shoppingList,
                              style: TextStyle(
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
                      // Botón de filtro
                      if (allItems.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: AppColors.darkCard,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () => _showFilterDialog(context, allItems),
                            child: Icon(
                              Icons.filter_list,
                              color:
                                  (_selectedCategory != null &&
                                          _selectedCategory != 'all')
                                      ? AppColors.primaryBlue
                                      : AppColors.textWhite,
                              size: 24,
                            ),
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
                                    l10n.total,
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
                                    l10n.remaining,
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
                              l10n.percentageUsed(
                                budgetProvider.budgetPercentage.toStringAsFixed(
                                  0,
                                ),
                              ),
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
                                    l10n.budgetExceeded,
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
                                    l10n.nearLimit,
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
                onPressed: () {
                  final name = nameController.text.trim();
                  final priceStr = priceController.text.trim();
                  final category = categoryController.text.trim();

                  if (name.isEmpty || priceStr.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.requiredFieldsMissing),
                        backgroundColor: AppColors.errorRed,
                      ),
                    );
                    return;
                  }

                  final price = double.tryParse(priceStr);
                  if (price == null || price <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
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

                  budgetProvider.updateItem(item.id, updatedItem);
                  Navigator.pop(dialogContext);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.itemUpdated),
                      backgroundColor: AppColors.primaryGreen,
                    ),
                  );
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
                onPressed: () {
                  budgetProvider.deleteItem(item.id);
                  Navigator.pop(dialogContext);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.itemDeleted(item.name)),
                      backgroundColor: AppColors.errorRed,
                    ),
                  );
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
                  ? AppColors.primaryGreen.withValues(alpha: 0.3)
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
                      color: AppColors.errorRed.withValues(alpha: 0.1),
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
