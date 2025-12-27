import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../state/state.dart';
import '../../utils/app_colors.dart';
import '../auth/auth_wrapper.dart';

class UserSettingsScreen extends StatefulWidget {
  const UserSettingsScreen({super.key});

  @override
  State<UserSettingsScreen> createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<UserSettingsScreen> {
  String selectedPlan = 'Free';

  String _getLanguageDisplayName(String languageCode) {
    return languageCode == 'es' ? 'Español' : 'English';
  }

  Future<void> _handleLogout() async {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: theme.cardTheme.color,
            title: Text(
              l10n.logoutConfirmTitle,
              style: theme.textTheme.headlineSmall,
            ),
            content: Text(
              l10n.logoutConfirmMessage,
              style: theme.textTheme.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.errorRed,
                ),
                child: Text(l10n.logout),
              ),
            ],
          ),
    );

    if (confirm == true && mounted) {
      try {
        // Cerrar sesión de Google Sign-In primero (si está logueado con Google)
        final googleSignIn = GoogleSignIn();
        if (await googleSignIn.isSignedIn()) {
          await googleSignIn.signOut();
        }

        // Cerrar sesión de Firebase Auth
        await FirebaseAuth.instance.signOut();

        // Navegar de vuelta al AuthWrapper eliminando toda la pila de navegación
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const AuthWrapper()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.logoutError}: ${e.toString()}'),
              backgroundColor: AppColors.errorRed,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  void _changeProfilePhoto() {
    // TODO: Implementar selección de foto con image_picker
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: theme.cardTheme.color,
            title: Text(
              l10n.changeProfilePhoto,
              style: theme.textTheme.headlineSmall,
            ),
            content: Text(
              l10n.photoFeatureNotImplemented,
              style: theme.textTheme.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.understood),
              ),
            ],
          ),
    );
  }

  void _showEditNameDialog() {
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
    final nameController = TextEditingController(
      text: budgetProvider.currentUser?.name ?? 'Usuario',
    );
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: theme.cardTheme.color,
            title: Text(l10n.editName, style: theme.textTheme.headlineSmall),
            content: TextField(
              controller: nameController,
              style: theme.textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: l10n.name,
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
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                onPressed: () {
                  // TODO: Guardar nombre en el backend
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.nameUpdated),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                ),
                child: Text(l10n.save),
              ),
            ],
          ),
    );
  }

  void _showEditEmailDialog() {
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
    final emailController = TextEditingController(
      text: budgetProvider.currentUser?.email ?? 'email@ejemplo.com',
    );
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardTheme.color,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(l10n.settings, style: theme.textTheme.headlineMedium),
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
                    Consumer<BudgetProvider>(
                      builder: (context, budgetProvider, child) {
                        final firebaseUser = FirebaseAuth.instance.currentUser;
                        final photoUrl = firebaseUser?.photoURL;

                        return Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image:
                                  photoUrl != null && photoUrl.isNotEmpty
                                      ? NetworkImage(photoUrl) as ImageProvider
                                      : const AssetImage(
                                        'assets/default_user.png',
                                      ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
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
              Text(
                l10n.profile,
                style: const TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),

              Consumer<BudgetProvider>(
                builder: (context, budgetProvider, child) {
                  final userName =
                      budgetProvider.currentUser?.name ?? 'Usuario';
                  final userEmail =
                      budgetProvider.currentUser?.email ?? 'email@ejemplo.com';

                  return Column(
                    children: [
                      _SettingItem(
                        icon: Icons.person_outline,
                        title: l10n.name,
                        value: userName,
                        onTap: _showEditNameDialog,
                      ),
                      const SizedBox(height: 12),
                      _SettingItem(
                        icon: Icons.email_outlined,
                        title: l10n.email,
                        value: userEmail,
                        onTap: _showEditEmailDialog,
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 32),

              // Sección de apariencia
              Text(
                l10n.appearance,
                style: const TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),

              Consumer<AppProvider>(
                builder: (context, appProvider, child) {
                  final currentLanguage = _getLanguageDisplayName(
                    appProvider.locale.languageCode,
                  );

                  return _SettingItem(
                    icon: Icons.language_outlined,
                    title: l10n.language,
                    value: currentLanguage,
                    onTap: () {
                      final dialogTheme = Theme.of(context);
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              backgroundColor: dialogTheme.cardTheme.color,
                              title: Text(
                                l10n.selectLanguage,
                                style: dialogTheme.textTheme.headlineSmall,
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _RadioOption(
                                    title: l10n.spanish,
                                    isSelected:
                                        appProvider.locale.languageCode == 'es',
                                    onTap: () {
                                      appProvider.setLocale(const Locale('es'));
                                      Navigator.pop(context);
                                    },
                                  ),
                                  _RadioOption(
                                    title: l10n.english,
                                    isSelected:
                                        appProvider.locale.languageCode == 'en',
                                    onTap: () {
                                      appProvider.setLocale(const Locale('en'));
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            ),
                      );
                    },
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

              const SizedBox(height: 24),

              // Botón de cerrar sesión
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleLogout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.errorRed,
                    foregroundColor: AppColors.textWhite,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.logout,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
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
                color: AppColors.primaryBlue.withValues(alpha: 0.2),
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
                            color: AppColors.primaryGreen.withValues(
                              alpha: 0.2,
                            ),
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
                            color: AppColors.primaryGreen.withValues(
                              alpha: 0.2,
                            ),
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
