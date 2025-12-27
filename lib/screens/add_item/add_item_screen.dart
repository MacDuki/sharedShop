import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../state/state.dart';
import '../../utils/app_colors.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _addItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    setState(() => _isLoading = true);

    final budgetProvider = context.read<BudgetProvider>();
    final activeBudget = budgetProvider.activeBudget;

    if (activeBudget == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.budgetNotFound),
          backgroundColor: AppColors.errorRed,
        ),
      );
      setState(() => _isLoading = false);
      return;
    }

    final price = double.parse(_priceController.text.trim());

    final item = ShoppingItemModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      budgetId: activeBudget.id,
      name: _nameController.text.trim(),
      estimatedPrice: price,
      category:
          _categoryController.text.trim().isEmpty
              ? null
              : _categoryController.text.trim(),
      createdBy: budgetProvider.currentUser?.id ?? 'unknown',
      createdAt: DateTime.now(),
    );

    try {
      await budgetProvider.addItem(item);

      if (!mounted) return;

      // Get updated budget data from backend
      final updatedBudget = budgetProvider.activeBudget;
      if (updatedBudget != null) {
        final remaining = updatedBudget.remaining ?? 0.0;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.itemAddedRemaining('\$${remaining.toStringAsFixed(2)}'),
            ),
            backgroundColor:
                remaining < 0
                    ? AppColors.errorRed
                    : (updatedBudget.status == 'warning' ||
                        updatedBudget.status == 'exceeded')
                    ? AppColors.warningAmber
                    : AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorAddingItem),
          backgroundColor: AppColors.errorRed,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
          icon: const Icon(Icons.close, color: AppColors.textWhite),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.addItemTitle,
          style: const TextStyle(
            color: AppColors.textWhite,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Nombre del ítem
                Text(
                  l10n.itemNameLabel,
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: AppColors.textWhite),
                  decoration: InputDecoration(
                    hintText: l10n.itemNameHint,
                    hintStyle: const TextStyle(color: AppColors.textGray),
                    filled: true,
                    fillColor: AppColors.darkCard,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.itemNameRequired;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Precio estimado
                Text(
                  l10n.estimatedPrice,
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 18,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: const TextStyle(color: AppColors.textGray),
                    prefixText: '\$ ',
                    prefixStyle: const TextStyle(
                      color: AppColors.primaryGreen,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    filled: true,
                    fillColor: AppColors.darkCard,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.priceRequired;
                    }
                    final price = double.tryParse(value.trim());
                    if (price == null || price <= 0) {
                      return l10n.priceInvalid;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Categoría (opcional)
                Text(
                  l10n.categoryOptional,
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _categoryController,
                  style: const TextStyle(color: AppColors.textWhite),
                  decoration: InputDecoration(
                    hintText: l10n.categoryHint,
                    hintStyle: const TextStyle(color: AppColors.textGray),
                    filled: true,
                    fillColor: AppColors.darkCard,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Current budget status from backend
                Consumer<BudgetProvider>(
                  builder: (context, budgetProvider, child) {
                    final activeBudget = budgetProvider.activeBudget;

                    if (activeBudget == null) {
                      return const SizedBox.shrink();
                    }

                    // Use data from backend (no calculations)
                    final currentRemaining = activeBudget.remaining ?? 0.0;
                    final budgetAmount = activeBudget.budgetAmount;
                    final totalSpent = activeBudget.totalSpent ?? 0.0;
                    final percentage = activeBudget.percentageUsed ?? 0.0;

                    // Predictive feedback (visual only, not business logic)
                    final itemPrice =
                        double.tryParse(_priceController.text.trim()) ?? 0;
                    final predictedRemaining = currentRemaining - itemPrice;

                    if (itemPrice > 0) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.darkCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                predictedRemaining < 0
                                    ? AppColors.errorRed
                                    : AppColors.primaryBlue.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.currentBudgetStatus,
                              style: const TextStyle(
                                color: AppColors.textGray,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  l10n.currentRemaining,
                                  style: const TextStyle(
                                    color: AppColors.textWhite,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '\$${currentRemaining.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color:
                                        currentRemaining < 0
                                            ? AppColors.errorRed
                                            : AppColors.primaryGreen,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  l10n.afterAdding,
                                  style: const TextStyle(
                                    color: AppColors.primaryBlue,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '\$${predictedRemaining.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color:
                                        predictedRemaining < 0
                                            ? AppColors.errorRed
                                            : AppColors.primaryGreen,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            if (predictedRemaining < 0)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.warning_rounded,
                                      color: AppColors.errorRed,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        l10n.budgetWillBeExceeded,
                                        style: const TextStyle(
                                          color: AppColors.errorRed,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                const SizedBox(height: 32),

                // Botón agregar
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _addItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: AppColors.textWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: AppColors.textWhite,
                                strokeWidth: 2,
                              ),
                            )
                            : Text(
                              l10n.addItemTitle,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
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
