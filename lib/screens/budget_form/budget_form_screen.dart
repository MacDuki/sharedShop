import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../state/state.dart';
import '../../utils/app_colors.dart';

class BudgetFormScreen extends StatefulWidget {
  final BudgetModel? budget; // null for create, populated for edit

  const BudgetFormScreen({super.key, this.budget});

  @override
  State<BudgetFormScreen> createState() => _BudgetFormScreenState();
}

class _BudgetFormScreenState extends State<BudgetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  BudgetType _selectedType = BudgetType.personal;
  BudgetPeriod _selectedPeriod = BudgetPeriod.monthly;
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  String? _selectedIcon;
  String? _selectedColor;

  bool _isLoading = false;
  bool get _isEditing => widget.budget != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.budget!.name;
      _descriptionController.text = widget.budget!.description ?? '';
      _amountController.text = widget.budget!.budgetAmount.toStringAsFixed(2);
      _selectedType = widget.budget!.type;
      _selectedPeriod = widget.budget!.budgetPeriod;
      _customStartDate = widget.budget!.customPeriodStart;
      _customEndDate = widget.budget!.customPeriodEnd;
      _selectedIcon = widget.budget!.iconName;
      _selectedColor = widget.budget!.colorHex;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _saveBudget() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedPeriod == BudgetPeriod.custom) {
      if (_customStartDate == null || _customEndDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.selectStartEndDates),
            backgroundColor: AppColors.errorRed,
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    final budgetProvider = context.read<BudgetProvider>();

    try {
      if (_isEditing) {
        // Update existing budget
        final updatedBudget = widget.budget!.copyWith(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          budgetAmount: double.parse(_amountController.text.trim()),
          type: _selectedType,
          budgetPeriod: _selectedPeriod,
          customPeriodStart: _customStartDate,
          customPeriodEnd: _customEndDate,
          iconName: _selectedIcon,
          colorHex: _selectedColor,
        );
        budgetProvider.updateBudgetData(updatedBudget);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.budgetUpdatedSuccess),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        // Create new budget
        final newBudget = BudgetModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          ownerId: 'current_user_id', // TODO: Get from auth
          type: _selectedType,
          budgetAmount: double.parse(_amountController.text.trim()),
          budgetPeriod: _selectedPeriod,
          createdAt: DateTime.now(),
          customPeriodStart: _customStartDate,
          customPeriodEnd: _customEndDate,
          iconName: _selectedIcon,
          colorHex: _selectedColor,
          memberIds: ['current_user_id'], // Owner is always a member
        );
        budgetProvider.addBudget(newBudget);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.budgetCreatedSuccess),
            backgroundColor: AppColors.success,
          ),
        );
      }

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _deleteBudget() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.darkCard,
            title: Text(
              l10n.deleteBudget,
              style: const TextStyle(color: AppColors.textWhite),
            ),
            content: Text(
              l10n.deleteBudgetConfirmation,
              style: const TextStyle(color: AppColors.textGray),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.errorRed,
                ),
                child: Text(l10n.delete),
              ),
            ],
          ),
    );

    if (confirmed == true && mounted) {
      final budgetProvider = context.read<BudgetProvider>();
      budgetProvider.deleteBudget(widget.budget!.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.budgetDeleted),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

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
          _isEditing ? l10n.editBudget : l10n.createBudget,
          style: const TextStyle(
            color: AppColors.textWhite,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.errorRed),
              onPressed: _deleteBudget,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Budget Name
            _buildSectionTitle(l10n.budgetName),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _nameController,
              hintText: l10n.budgetNameHint,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.enterBudgetName;
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Description (Optional)
            _buildSectionTitle(l10n.descriptionOptional),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _descriptionController,
              hintText: l10n.addDescription,
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Budget Type
            _buildSectionTitle(l10n.budgetType),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTypeCard(
                    type: BudgetType.personal,
                    icon: Icons.person_outline,
                    title: l10n.personal,
                    description: l10n.onlyForYou,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTypeCard(
                    type: BudgetType.shared,
                    icon: Icons.people_outline,
                    title: l10n.shared,
                    description: l10n.withOthers,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Budget Amount
            _buildSectionTitle(l10n.budgetAmount),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _amountController,
              hintText: '0.00',
              prefixText: '\$ ',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.enterBudgetAmount;
                }
                final amount = double.tryParse(value.trim());
                if (amount == null || amount <= 0) {
                  return l10n.enterValidAmount;
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Budget Period
            _buildSectionTitle(l10n.budgetPeriod),
            const SizedBox(height: 12),
            _buildPeriodSelector(),
            const SizedBox(height: 16),

            // Custom Date Range (if custom period selected)
            if (_selectedPeriod == BudgetPeriod.custom) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildDateField(
                      label: l10n.startDate,
                      date: _customStartDate,
                      onTap: () => _selectDate(true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDateField(
                      label: l10n.endDate,
                      date: _customEndDate,
                      onTap: () => _selectDate(false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],

            // Icon Selection
            _buildSectionTitle(l10n.iconOptional),
            const SizedBox(height: 12),
            _buildIconSelector(),
            const SizedBox(height: 24),

            // Color Selection
            _buildSectionTitle(l10n.colorOptional),
            const SizedBox(height: 12),
            _buildColorSelector(),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveBudget,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: AppColors.textWhite,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.textWhite,
                            strokeWidth: 2,
                          ),
                        )
                        : Text(
                          _isEditing ? l10n.saveChanges : l10n.createBudget,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textWhite,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    String? prefixText,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      style: const TextStyle(color: AppColors.textWhite),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: AppColors.textGrayLight),
        prefixText: prefixText,
        prefixStyle: const TextStyle(color: AppColors.textWhite),
        filled: true,
        fillColor: AppColors.darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorRed, width: 1),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildTypeCard({
    required BudgetType type,
    required IconData icon,
    required String title,
    required String description,
  }) {
    final isSelected = _selectedType == type;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.primaryGreen.withOpacity(0.15)
                  : AppColors.darkCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primaryGreen : AppColors.textGray,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color:
                    isSelected ? AppColors.primaryGreen : AppColors.textWhite,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textGrayLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(child: _buildPeriodChip(BudgetPeriod.weekly, l10n.weekly)),
        const SizedBox(width: 8),
        Expanded(child: _buildPeriodChip(BudgetPeriod.monthly, l10n.monthly)),
        const SizedBox(width: 8),
        Expanded(child: _buildPeriodChip(BudgetPeriod.custom, l10n.custom)),
      ],
    );
  }

  Widget _buildPeriodChip(BudgetPeriod period, String label) {
    final isSelected = _selectedPeriod == period;

    return GestureDetector(
      onTap: () => setState(() => _selectedPeriod = period),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.primaryBlue.withOpacity(0.15)
                  : AppColors.darkCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? AppColors.primaryBlue : AppColors.textGray,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textGrayLight,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date != null
                  ? '${date.day}/${date.month}/${date.year}'
                  : 'Select date',
              style: const TextStyle(
                color: AppColors.textWhite,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(bool isStartDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryGreen,
              surface: AppColors.darkCard,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _customStartDate = picked;
        } else {
          _customEndDate = picked;
        }
      });
    }
  }

  Widget _buildIconSelector() {
    final icons = [
      {'name': 'shopping_cart', 'icon': Icons.shopping_cart_outlined},
      {'name': 'home', 'icon': Icons.home_outlined},
      {'name': 'restaurant', 'icon': Icons.restaurant_outlined},
      {
        'name': 'local_grocery_store',
        'icon': Icons.local_grocery_store_outlined,
      },
      {
        'name': 'account_balance_wallet',
        'icon': Icons.account_balance_wallet_outlined,
      },
      {'name': 'flight', 'icon': Icons.flight_outlined},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children:
          icons.map((iconData) {
            final isSelected = _selectedIcon == iconData['name'];
            return GestureDetector(
              onTap:
                  () => setState(
                    () => _selectedIcon = iconData['name'] as String,
                  ),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? AppColors.primaryBlue.withOpacity(0.15)
                          : AppColors.darkCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        isSelected ? AppColors.primaryBlue : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Icon(
                  iconData['icon'] as IconData,
                  color:
                      isSelected ? AppColors.primaryBlue : AppColors.textGray,
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildColorSelector() {
    final colors = [
      {'name': 'Blue', 'hex': '#3B82F6'},
      {'name': 'Green', 'hex': '#10B981'},
      {'name': 'Purple', 'hex': '#8B5CF6'},
      {'name': 'Orange', 'hex': '#F59E0B'},
      {'name': 'Red', 'hex': '#EF4444'},
      {'name': 'Pink', 'hex': '#EC4899'},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children:
          colors.map((colorData) {
            final isSelected = _selectedColor == colorData['hex'];
            final color = Color(
              int.parse(colorData['hex']!.replaceFirst('#', '0xFF')),
            );

            return GestureDetector(
              onTap: () => setState(() => _selectedColor = colorData['hex']),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        isSelected ? AppColors.textWhite : Colors.transparent,
                    width: 3,
                  ),
                ),
                child:
                    isSelected
                        ? const Icon(Icons.check, color: AppColors.textWhite)
                        : null,
              ),
            );
          }).toList(),
    );
  }
}
