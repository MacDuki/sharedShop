import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../state/state.dart';
import '../../utils/app_colors.dart';

class BudgetSettingsScreen extends StatefulWidget {
  const BudgetSettingsScreen({super.key});

  @override
  State<BudgetSettingsScreen> createState() => _BudgetSettingsScreenState();
}

class _BudgetSettingsScreenState extends State<BudgetSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _budgetController = TextEditingController();
  BudgetPeriod? _selectedPeriod;
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final budgetProvider = context.read<BudgetProvider>();
    final household = budgetProvider.household;

    if (household != null) {
      _budgetController.text = household.budgetAmount.toStringAsFixed(2);
      _selectedPeriod = household.budgetPeriod as BudgetPeriod?;
      _customStartDate = household.customPeriodStart;
      _customEndDate = household.customPeriodEnd;
    }

    _budgetController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  @override
  void dispose() {
    _budgetController.removeListener(_onFieldChanged);
    _budgetController.dispose();
    super.dispose();
  }

  void _saveBudget() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_hasChanges) {
      Navigator.of(context).pop();
      return;
    }

    setState(() => _isLoading = true);

    final budgetProvider = context.read<BudgetProvider>();
    final newAmount = double.parse(_budgetController.text.trim());

    budgetProvider.updateBudget(
      budgetAmount: newAmount,
      budgetPeriod: _selectedPeriod!,
      customPeriodStart: _customStartDate,
      customPeriodEnd: _customEndDate,
    );

    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.budgetUpdatedSuccess),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );

    setState(() => _isLoading = false);
    Navigator.of(context).pop();
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
          l10n.configureBudget,
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
                // Información
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.darkCard,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.primaryBlue,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.budgetInfoText,
                          style: TextStyle(
                            color: AppColors.textGray,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Monto del presupuesto
                Text(
                  l10n.budgetAmountLabel,
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _budgetController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
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
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                    filled: true,
                    fillColor: AppColors.darkCard,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.budgetAmountRequired;
                    }
                    final amount = double.tryParse(value.trim());
                    if (amount == null || amount <= 0) {
                      return l10n.budgetAmountInvalid;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // Período del presupuesto
                Text(
                  l10n.budgetPeriodLabel,
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),

                // Semanal
                InkWell(
                  onTap: () {
                    setState(() {
                      _selectedPeriod = BudgetPeriod.weekly;
                      _hasChanges = true;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            _selectedPeriod == BudgetPeriod.weekly
                                ? AppColors.primaryBlue
                                : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                                  _selectedPeriod == BudgetPeriod.weekly
                                      ? AppColors.primaryBlue
                                      : AppColors.textGray,
                              width: 2,
                            ),
                            color:
                                _selectedPeriod == BudgetPeriod.weekly
                                    ? AppColors.primaryBlue
                                    : Colors.transparent,
                          ),
                          child:
                              _selectedPeriod == BudgetPeriod.weekly
                                  ? const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: AppColors.textWhite,
                                  )
                                  : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.weekly,
                                style: const TextStyle(
                                  color: AppColors.textWhite,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.weeklyDescription,
                                style: TextStyle(
                                  color: AppColors.textGray,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Mensual
                InkWell(
                  onTap: () {
                    setState(() {
                      _selectedPeriod = BudgetPeriod.monthly;
                      _hasChanges = true;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            _selectedPeriod == BudgetPeriod.monthly
                                ? AppColors.primaryBlue
                                : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                                  _selectedPeriod == BudgetPeriod.monthly
                                      ? AppColors.primaryBlue
                                      : AppColors.textGray,
                              width: 2,
                            ),
                            color:
                                _selectedPeriod == BudgetPeriod.monthly
                                    ? AppColors.primaryBlue
                                    : Colors.transparent,
                          ),
                          child:
                              _selectedPeriod == BudgetPeriod.monthly
                                  ? const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: AppColors.textWhite,
                                  )
                                  : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.monthly,
                                style: const TextStyle(
                                  color: AppColors.textWhite,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.monthlyDescription,
                                style: TextStyle(
                                  color: AppColors.textGray,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Custom
                InkWell(
                  onTap: () {
                    setState(() {
                      _selectedPeriod = BudgetPeriod.custom;
                      _hasChanges = true;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            _selectedPeriod == BudgetPeriod.custom
                                ? AppColors.primaryBlue
                                : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                                  _selectedPeriod == BudgetPeriod.custom
                                      ? AppColors.primaryBlue
                                      : AppColors.textGray,
                              width: 2,
                            ),
                            color:
                                _selectedPeriod == BudgetPeriod.custom
                                    ? AppColors.primaryBlue
                                    : Colors.transparent,
                          ),
                          child:
                              _selectedPeriod == BudgetPeriod.custom
                                  ? const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: AppColors.textWhite,
                                  )
                                  : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.customPeriod,
                                style: const TextStyle(
                                  color: AppColors.textWhite,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.customPeriodDescription,
                                style: TextStyle(
                                  color: AppColors.textGray,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Custom Date Picker
                if (_selectedPeriod == BudgetPeriod.custom) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primaryBlue.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Fecha de inicio
                        Text(
                          l10n.startDateLabel,
                          style: const TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () async {
                            final date = await _showStyledDatePicker(
                              context,
                              _customStartDate ?? DateTime.now(),
                              l10n.selectStartDate,
                            );
                            if (date != null) {
                              setState(() {
                                _customStartDate = date;
                                _hasChanges = true;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.darkBackground,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _customStartDate != null
                                      ? '${_customStartDate!.day}/${_customStartDate!.month}/${_customStartDate!.year}'
                                      : l10n.selectDate,
                                  style: TextStyle(
                                    color:
                                        _customStartDate != null
                                            ? AppColors.textWhite
                                            : AppColors.textGray,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Icon(
                                  Icons.calendar_today_outlined,
                                  color: AppColors.primaryBlue,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Fecha de fin
                        Text(
                          l10n.endDateLabel,
                          style: const TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () async {
                            final date = await _showStyledDatePicker(
                              context,
                              _customEndDate ??
                                  DateTime.now().add(const Duration(days: 7)),
                              l10n.selectEndDate,
                            );
                            if (date != null) {
                              setState(() {
                                _customEndDate = date;
                                _hasChanges = true;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.darkBackground,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _customEndDate != null
                                      ? '${_customEndDate!.day}/${_customEndDate!.month}/${_customEndDate!.year}'
                                      : l10n.selectDate,
                                  style: TextStyle(
                                    color:
                                        _customEndDate != null
                                            ? AppColors.textWhite
                                            : AppColors.textGray,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Icon(
                                  Icons.calendar_today_outlined,
                                  color: AppColors.primaryBlue,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 32),
                Consumer<BudgetProvider>(
                  builder: (context, budgetProvider, child) {
                    final currentBudget =
                        double.tryParse(_budgetController.text.trim()) ?? 0;
                    if (currentBudget > 0 && _hasChanges) {
                      final totalSpent = budgetProvider.totalSpent;
                      final newRemaining = currentBudget - totalSpent;
                      final percentage = (totalSpent / currentBudget) * 100;

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.darkCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primaryBlue.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.preview,
                              style: const TextStyle(
                                color: AppColors.textGray,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  l10n.spentLabel,
                                  style: const TextStyle(
                                    color: AppColors.textWhite,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '\$${totalSpent.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: AppColors.textWhite,
                                    fontSize: 14,
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
                                  l10n.remainingLabel,
                                  style: const TextStyle(
                                    color: AppColors.textWhite,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '\$${newRemaining.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color:
                                        newRemaining < 0
                                            ? AppColors.errorRed
                                            : AppColors.primaryGreen,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: percentage / 100,
                                backgroundColor: AppColors.darkBackground,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  percentage > 100
                                      ? AppColors.errorRed
                                      : percentage >= 70
                                      ? AppColors.warningAmber
                                      : AppColors.primaryGreen,
                                ),
                                minHeight: 8,
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

                // Botón guardar
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveBudget,
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
                              l10n.saveChanges,
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

  Future<DateTime?> _showStyledDatePicker(
    BuildContext context,
    DateTime initialDate,
    String title,
  ) async {
    return await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryBlue,
              onPrimary: AppColors.textWhite,
              surface: AppColors.darkCard,
              onSurface: AppColors.textWhite,
            ),
            dialogBackgroundColor: AppColors.darkCard,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
              ),
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: AppColors.darkCard,
              headerBackgroundColor: AppColors.primaryBlue,
              headerForegroundColor: AppColors.textWhite,
              dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.textWhite;
                }
                return AppColors.textWhite;
              }),
              dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.primaryBlue;
                }
                return Colors.transparent;
              }),
              todayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.primaryBlue;
                }
                return AppColors.primaryBlue.withOpacity(0.2);
              }),
              todayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.textWhite;
                }
                return AppColors.primaryBlue;
              }),
              dayShape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              dayOverlayColor: WidgetStateProperty.all(
                AppColors.primaryBlue.withOpacity(0.2),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
  }
}
