import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_provider.dart';
import '../../utils/app_colors.dart';

class UserSettingsScreen extends StatefulWidget {
  const UserSettingsScreen({super.key});

  @override
  State<UserSettingsScreen> createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<UserSettingsScreen> {
  String selectedTheme = 'Dark';
  String selectedLanguage = 'Español';
  String selectedPlan = 'Free';

  @override
  void initState() {
    super.initState();
    // Sincronizar el tema seleccionado con el estado actual del AppProvider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      setState(() {
        selectedTheme = appProvider.isDarkMode ? 'Dark' : 'Light';
      });
    });
  }

  void _changeProfilePhoto() {
    // TODO: Implementar selección de foto con image_picker
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: theme.cardTheme.color,
            title: Text(
              'Cambiar foto de perfil',
              style: theme.textTheme.headlineSmall,
            ),
            content: Text(
              'Esta funcionalidad se implementará con image_picker en una futura versión.',
              style: theme.textTheme.bodyMedium,
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

  void _showEditNameDialog() {
    final nameController = TextEditingController(text: 'Usuario Principal');
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: theme.cardTheme.color,
            title: Text('Editar nombre', style: theme.textTheme.headlineSmall),
            content: TextField(
              controller: nameController,
              style: theme.textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: 'Nombre',
                hintStyle: theme.textTheme.bodyMedium,
                filled: true,
                fillColor: theme.scaffoldBackgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  // TODO: Guardar nombre en el backend
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nombre actualizado'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                ),
                child: const Text('Guardar'),
              ),
            ],
          ),
    );
  }

  void _showEditEmailDialog() {
    final emailController = TextEditingController(text: 'usuario@ejemplo.com');
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: theme.cardTheme.color,
            title: Text(
              'Editar correo electrónico',
              style: theme.textTheme.headlineSmall,
            ),
            content: TextField(
              controller: emailController,
              style: theme.textTheme.bodyLarge,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Correo electrónico',
                hintStyle: theme.textTheme.bodyMedium,
                filled: true,
                fillColor: theme.scaffoldBackgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  // TODO: Guardar email en el backend
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Correo actualizado'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                ),
                child: const Text('Guardar'),
              ),
            ],
          ),
    );
  }

  void _showPlanDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: theme.cardTheme.color,
            title: Text('Cambiar plan', style: theme.textTheme.headlineSmall),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PlanOption(
                  title: 'Free',
                  description: 'Funcionalidades básicas',
                  price: 'Gratis',
                  isSelected: selectedPlan == 'Free',
                  onTap: () {
                    setState(() => selectedPlan = 'Free');
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 12),
                _PlanOption(
                  title: 'Premium',
                  description: 'Todas las funcionalidades',
                  price: '\$9.99/mes',
                  isSelected: selectedPlan == 'Premium',
                  onTap: () {
                    setState(() => selectedPlan = 'Premium');
                    Navigator.pop(context);
                    // TODO: Implementar compra in-app
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardTheme.color,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Configuración', style: theme.textTheme.headlineMedium),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Foto de perfil
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        color: AppColors.primaryPurple,
                        size: 60,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _changeProfilePhoto,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.scaffoldBackgroundColor,
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

              // Sección de perfil
              const Text(
                'Perfil',
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),

              _SettingItem(
                icon: Icons.person_outline,
                title: 'Nombre',
                value: 'Usuario Principal',
                onTap: _showEditNameDialog,
              ),
              const SizedBox(height: 12),
              _SettingItem(
                icon: Icons.email_outlined,
                title: 'Correo electrónico',
                value: 'usuario@ejemplo.com',
                onTap: _showEditEmailDialog,
              ),

              const SizedBox(height: 32),

              // Sección de apariencia
              const Text(
                'Apariencia',
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),

              _SettingItem(
                icon: Icons.palette_outlined,
                title: 'Tema',
                value: selectedTheme,
                onTap: () {
                  final dialogTheme = Theme.of(context);
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          backgroundColor: dialogTheme.cardTheme.color,
                          title: Text(
                            'Seleccionar tema',
                            style: dialogTheme.textTheme.headlineSmall,
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _RadioOption(
                                title: 'Dark',
                                isSelected: selectedTheme == 'Dark',
                                onTap: () {
                                  setState(() => selectedTheme = 'Dark');
                                  Provider.of<AppProvider>(
                                    context,
                                    listen: false,
                                  ).setTheme(true);
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Tema oscuro activado'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                },
                              ),
                              _RadioOption(
                                title: 'Light',
                                isSelected: selectedTheme == 'Light',
                                onTap: () {
                                  setState(() => selectedTheme = 'Light');
                                  Provider.of<AppProvider>(
                                    context,
                                    listen: false,
                                  ).setTheme(false);
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Tema claro activado'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _SettingItem(
                icon: Icons.language_outlined,
                title: 'Idioma',
                value: selectedLanguage,
                onTap: () {
                  final dialogTheme = Theme.of(context);
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          backgroundColor: dialogTheme.cardTheme.color,
                          title: Text(
                            'Seleccionar idioma',
                            style: dialogTheme.textTheme.headlineSmall,
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _RadioOption(
                                title: 'Español',
                                isSelected: selectedLanguage == 'Español',
                                onTap: () {
                                  setState(() => selectedLanguage = 'Español');
                                  Navigator.pop(context);
                                },
                              ),
                              _RadioOption(
                                title: 'English',
                                isSelected: selectedLanguage == 'English',
                                onTap: () {
                                  setState(() => selectedLanguage = 'English');
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'El idioma inglés se implementará en una futura versión',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // Sección de suscripción
              const Text(
                'Suscripción',
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),

              _SettingItem(
                icon: Icons.card_membership_outlined,
                title: 'Plan actual',
                value: selectedPlan,
                onTap: _showPlanDialog,
                showBadge: selectedPlan == 'Premium',
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
                        'Versión 1.0.0\nDesarrollado para gestión de presupuestos compartidos',
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
        ),
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;
  final bool showBadge;

  const _SettingItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primaryBlue, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(value, style: theme.textTheme.titleLarge),
                      if (showBadge) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'PRO',
                            style: TextStyle(
                              color: AppColors.primaryGreen,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textGray,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _RadioOption extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _RadioOption({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    final subtleColor = theme.textTheme.bodyMedium?.color ?? Colors.grey;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : Colors.transparent,
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
                  color: isSelected ? AppColors.primaryBlue : subtleColor,
                  width: 2,
                ),
                color: isSelected ? AppColors.primaryBlue : Colors.transparent,
              ),
              child:
                  isSelected
                      ? const Icon(
                        Icons.check,
                        size: 16,
                        color: AppColors.textWhite,
                      )
                      : null,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? textColor : subtleColor,
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanOption extends StatelessWidget {
  final String title;
  final String description;
  final String price;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlanOption({
    required this.title,
    required this.description,
    required this.price,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    final subtleColor = theme.textTheme.bodyMedium?.color ?? Colors.grey;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (title == 'Premium') ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'POPULAR',
                            style: TextStyle(
                              color: AppColors.primaryGreen,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(color: subtleColor, fontSize: 13),
                  ),
                ],
              ),
            ),
            Text(
              price,
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
