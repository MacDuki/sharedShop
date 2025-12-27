import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../state/state.dart';
import '../../utils/app_colors.dart';

class GroupSettingsScreen extends StatefulWidget {
  const GroupSettingsScreen({super.key});

  @override
  State<GroupSettingsScreen> createState() => _GroupSettingsScreenState();
}

class _GroupSettingsScreenState extends State<GroupSettingsScreen> {
  final _nameController = TextEditingController();
  bool _isEditingName = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeNameController();
  }

  void _initializeNameController() {
    final budgetProvider = context.read<BudgetProvider>();
    final activeBudget = budgetProvider.activeBudget;
    _nameController.text = activeBudget?.name ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El nombre no puede estar vacío'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
      return;
    }

    final budgetProvider = context.read<BudgetProvider>();
    final currentBudget = budgetProvider.activeBudget;

    if (currentBudget == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo actualizar: presupuesto no encontrado'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Create updated budget with new name
      final updatedBudget = BudgetModel(
        id: currentBudget.id,
        name: newName,
        description: currentBudget.description,
        budgetAmount: currentBudget.budgetAmount,
        ownerId: currentBudget.ownerId,
        type: currentBudget.type,
        budgetPeriod: currentBudget.budgetPeriod,
        createdAt: currentBudget.createdAt,
        memberIds: currentBudget.memberIds,
        iconName: currentBudget.iconName,
        colorHex: currentBudget.colorHex,
      );

      // Update via backend through provider
      await budgetProvider.updateBudgetData(updatedBudget);

      if (mounted) {
        setState(() {
          _isEditingName = false;
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nombre actualizado correctamente'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: ${e.toString()}'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  void _changeGroupPhoto() {
    // TODO: Implementar selección de foto con image_picker
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.darkCard,
            title: const Text(
              'Cambiar foto del grupo',
              style: TextStyle(color: AppColors.textWhite),
            ),
            content: const Text(
              'Esta funcionalidad se implementará con image_picker en una futura versión.',
              style: TextStyle(color: AppColors.textGray),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Entendido'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkCard,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Configuración del Grupo',
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Consumer<BudgetProvider>(
          builder: (context, budgetProvider, child) {
            // Handle loading state
            if (budgetProvider.activeBudgetLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryBlue),
              );
            }

            // Handle error state
            if (budgetProvider.activeBudgetError != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.errorRed,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error al cargar los datos',
                        style: const TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        budgetProvider.activeBudgetError!,
                        style: const TextStyle(
                          color: AppColors.textGray,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            // Handle null/empty state
            final activeBudget = budgetProvider.activeBudget;
            if (activeBudget == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.inbox_outlined,
                        color: AppColors.textGray,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No hay grupo activo',
                        style: TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Selecciona o crea un grupo para ver su configuración',
                        style: TextStyle(
                          color: AppColors.textGray,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Foto del grupo
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.group,
                            color: AppColors.primaryBlue,
                            size: 60,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: _changeGroupPhoto,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.darkBackground,
                                  width: 3,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: AppColors.textWhite,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Nombre del grupo
                  const Text(
                    'Nombre del grupo',
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (_isEditingName)
                    Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          enabled: !_isSaving,
                          style: const TextStyle(color: AppColors.textWhite),
                          decoration: InputDecoration(
                            hintText: 'Nombre del grupo',
                            hintStyle: const TextStyle(
                              color: AppColors.textGray,
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
                          autofocus: true,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed:
                                    _isSaving
                                        ? null
                                        : () {
                                          _nameController.text =
                                              activeBudget.name;
                                          setState(
                                            () => _isEditingName = false,
                                          );
                                        },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.textGray,
                                  side: const BorderSide(
                                    color: AppColors.textGray,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                child: const Text('Cancelar'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isSaving ? null : _saveName,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryBlue,
                                  foregroundColor: AppColors.textWhite,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                child:
                                    _isSaving
                                        ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  AppColors.textWhite,
                                                ),
                                          ),
                                        )
                                        : const Text('Guardar'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  else
                    InkWell(
                      onTap: () => setState(() => _isEditingName = true),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.darkCard,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                activeBudget.name,
                                style: const TextStyle(
                                  color: AppColors.textWhite,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.edit,
                              color: AppColors.primaryBlue,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 32),

                  // Información
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppColors.primaryBlue,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Solo el usuario principal puede cambiar la foto del grupo. Todos los miembros pueden editar el nombre.',
                            style: TextStyle(
                              color: AppColors.textGray,
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
