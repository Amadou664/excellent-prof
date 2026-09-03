import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/enums.dart';

/// Badge coloré générique pour représenter un statut (UserStatus,
/// DemandeStatus, StatutCandidature, AvisStatut, SeanceStatut...).
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  factory StatusChip.userStatus(UserStatus status) {
    final color = switch (status) {
      UserStatus.actif => AppColors.statutActif,
      UserStatus.enAttente => AppColors.statutEnAttente,
      UserStatus.suspendu => AppColors.statutSuspendu,
      UserStatus.desactive => AppColors.statutDesactive,
    };
    return StatusChip(label: status.label, color: color);
  }

  factory StatusChip.demandeStatus(DemandeStatus status) {
    final color = switch (status) {
      DemandeStatus.nouvelle => AppColors.info,
      DemandeStatus.profPropose => AppColors.warning,
      DemandeStatus.confirmee => AppColors.success,
      DemandeStatus.enCours => AppColors.lightGreen,
      DemandeStatus.terminee => AppColors.primaryDarkGreen,
      DemandeStatus.annulee => AppColors.error,
    };
    return StatusChip(label: status.label, color: color);
  }

  factory StatusChip.candidature(StatutCandidature statut) {
    final color = switch (statut) {
      StatutCandidature.soumise => AppColors.statutSoumise,
      StatutCandidature.entretien => AppColors.statutEntretien,
      StatutCandidature.validee => AppColors.statutValidee,
      StatutCandidature.refusee => AppColors.statutRefusee,
    };
    return StatusChip(label: statut.label, color: color);
  }

  factory StatusChip.avisStatut(AvisStatut statut) {
    final color = switch (statut) {
      AvisStatut.visible => AppColors.success,
      AvisStatut.masque => AppColors.textSecondary,
    };
    return StatusChip(label: statut.label, color: color);
  }

  factory StatusChip.seanceStatut(SeanceStatut statut) {
    final color = switch (statut) {
      SeanceStatut.planifiee => AppColors.info,
      SeanceStatut.effectuee => AppColors.success,
      SeanceStatut.annulee => AppColors.error,
    };
    return StatusChip(label: statut.label, color: color);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
