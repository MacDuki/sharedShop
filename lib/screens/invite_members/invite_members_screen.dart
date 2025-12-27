import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../state/state.dart';
import '../../utils/app_colors.dart';

class InviteMembersScreen extends StatefulWidget {
  const InviteMembersScreen({super.key});

  @override
  State<InviteMembersScreen> createState() => _InviteMembersScreenState();
}

class _InviteMembersScreenState extends State<InviteMembersScreen> {
  void _copyToClipboard(String inviteCode) {
    Clipboard.setData(ClipboardData(text: inviteCode));
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.inviteCodeCopied),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareInvite(String inviteCode, BudgetType? budgetType) {
    final l10n = AppLocalizations.of(context)!;

    // Si el presupuesto es personal, mostrar advertencia
    if (budgetType == BudgetType.personal) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              backgroundColor: AppColors.darkCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                l10n.personalProjectWarningTitle,
                style: const TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: Text(
                l10n.personalProjectWarning,
                style: const TextStyle(
                  color: AppColors.textGray,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    l10n.cancel,
                    style: const TextStyle(color: AppColors.textGray),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _executeShare(inviteCode);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.warningAmber,
                    foregroundColor: AppColors.darkBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(l10n.continueButton),
                ),
              ],
            ),
      );
    } else {
      _executeShare(inviteCode);
    }
  }

  void _executeShare(String inviteCode) {
    // TODO: Implementar share real con share_plus package
    final l10n = AppLocalizations.of(context)!;
    final message = l10n.joinGroupMessage(inviteCode);
    Clipboard.setData(ClipboardData(text: message));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.inviteMessageCopied),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
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
          l10n.inviteMembers,
          style: const TextStyle(
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
            if (budgetProvider.activeBudgetLoading ||
                budgetProvider.membersLoading) {
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
                      const Text(
                        'Error al cargar los datos',
                        style: TextStyle(
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

            final activeBudget = budgetProvider.activeBudget;

            // Handle null budget
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
                        'No hay presupuesto activo',
                        style: TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Use budgetMembers from provider (already filtered by active budget)
            final members = budgetProvider.budgetMembers;

            // Generate invite code from budget ID (temporary solution until backend provides it)
            final inviteCode = 'BUDGET-${activeBudget.id.toUpperCase()}';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Texto explicativo sobre compartir presupuesto
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primaryBlue.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.share_rounded,
                            color: AppColors.primaryBlue,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.shareYourBudget,
                          style: const TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.shareYourBudgetDescription,
                          style: const TextStyle(
                            color: AppColors.textGray,
                            fontSize: 15,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Sección de invitación
                  Text(
                    l10n.inviteCode,
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primaryBlue.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.darkBackground,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  inviteCode,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.primaryBlue,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _copyToClipboard(inviteCode),
                                icon: const Icon(Icons.copy, size: 18),
                                label: Text(l10n.copy),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primaryBlue,
                                  side: const BorderSide(
                                    color: AppColors.primaryBlue,
                                    width: 1,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed:
                                    () => _shareInvite(
                                      inviteCode,
                                      activeBudget.type,
                                    ),
                                icon: const Icon(Icons.share, size: 18),
                                label: Text(l10n.share),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryBlue,
                                  foregroundColor: AppColors.textWhite,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Miembros actuales del presupuesto
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.currentBudgetMembers,
                        style: const TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              budgetProvider.activeBudget?.type ==
                                      BudgetType.personal
                                  ? AppColors.primaryPurple.withOpacity(0.2)
                                  : AppColors.primaryBlue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          activeBudget.type == BudgetType.personal
                              ? l10n.privateProject
                              : '${members.length}',
                          style: TextStyle(
                            color:
                                activeBudget.type == BudgetType.personal
                                    ? AppColors.primaryPurple
                                    : AppColors.primaryBlue,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Si es presupuesto personal, mostrar mensaje
                  if (activeBudget.type == BudgetType.personal)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.darkCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primaryPurple.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primaryPurple.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.lock,
                              color: AppColors.primaryPurple,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.onlyYou,
                                  style: const TextStyle(
                                    color: AppColors.textWhite,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.privateProjectNote,
                                  style: const TextStyle(
                                    color: AppColors.textGray,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  // Si es presupuesto compartido, mostrar miembros
                  else if (members.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppColors.darkCard,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.person_add_outlined,
                            size: 48,
                            color: AppColors.textGray.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.noMembersYet,
                            style: const TextStyle(
                              color: AppColors.textGray,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...members.map((member) {
                      final isOwner = member.id == activeBudget.ownerId;
                      final canRemove =
                          !isOwner &&
                          budgetProvider.currentUser?.id ==
                              activeBudget.ownerId;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.darkCard,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.primaryPurple.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  member.name.isNotEmpty
                                      ? member.name[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: AppColors.primaryPurple,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          member.name,
                                          style: const TextStyle(
                                            color: AppColors.textWhite,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (isOwner) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryBlue
                                                .withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: const Text(
                                            'Owner',
                                            style: TextStyle(
                                              color: AppColors.primaryBlue,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    member.email,
                                    style: const TextStyle(
                                      color: AppColors.textGray,
                                      fontSize: 13,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            if (canRemove)
                              IconButton(
                                icon: const Icon(
                                  Icons.person_remove_outlined,
                                  color: AppColors.errorRed,
                                  size: 20,
                                ),
                                onPressed:
                                    () => _showRemoveMemberDialog(
                                      context,
                                      budgetProvider,
                                      activeBudget,
                                      member,
                                    ),
                              ),
                          ],
                        ),
                      );
                    }),

                  const SizedBox(height: 24),

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
                            l10n.membersCanViewEdit,
                            style: const TextStyle(
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

  void _showRemoveMemberDialog(
    BuildContext context,
    BudgetProvider budgetProvider,
    BudgetModel budget,
    UserModel member,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.darkCard,
          title: Text(
            AppLocalizations.of(context)!.removeMember,
            style: const TextStyle(color: AppColors.textWhite),
          ),
          content: Text(
            '${AppLocalizations.of(context)!.removeMemberConfirm} ${member.name}?',
            style: const TextStyle(color: AppColors.textGray),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () async {
                final updatedBudget = budget.copyWith(
                  memberIds:
                      budget.memberIds.where((id) => id != member.id).toList(),
                );

                try {
                  await budgetProvider.updateBudgetData(updatedBudget);

                  if (context.mounted) {
                    Navigator.of(context).pop();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${member.name} ${AppLocalizations.of(context)!.removedSuccessfully}',
                        ),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Error al eliminar miembro: ${e.toString()}',
                        ),
                        backgroundColor: AppColors.errorRed,
                      ),
                    );
                  }
                }
              },
              child: Text(
                AppLocalizations.of(context)!.remove,
                style: const TextStyle(color: AppColors.errorRed),
              ),
            ),
          ],
        );
      },
    );
  }
}
