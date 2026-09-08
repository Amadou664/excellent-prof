import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/paiement_model.dart';
import '../../../providers/paiement_provider.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/error_state.dart';
import '../../../widgets/loading_indicator.dart';

/// Historique complet des paiements en ligne (ADMIN), tous statuts confondus
/// — y compris les tentatives echouees, contrairement a l'ecran "Demandes de
/// cours" qui ne montre que le statut payee/non payee de la demande elle-meme.
/// `GET /paiements`.
class GestionPaiements extends ConsumerWidget {
  const GestionPaiements({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paiementsAsync = ref.watch(paiementsAdminProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(paiementsAdminProvider),
      child: paiementsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorState(error: e, onRetry: () => ref.invalidate(paiementsAdminProvider)),
        data: (paiements) {
          if (paiements.isEmpty) {
            return ListView(
              children: const [
                SizedBox(height: 80),
                EmptyState(message: 'Aucun paiement en ligne pour le moment.', icon: Icons.payment_outlined),
              ],
            );
          }
          final totalRecu = paiements
              .where((p) => p.estReussi)
              .fold<int>(0, (sum, p) => sum + p.montant);
          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: AppColors.primaryDarkGreen,
                child: Text(
                  'Total reçu : $totalRecu FCFA',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: paiements.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) => _PaiementTile(paiement: paiements[index]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PaiementTile extends StatelessWidget {
  const _PaiementTile({required this.paiement});

  final PaiementModel paiement;

  Color get _couleurStatut {
    if (paiement.estReussi) return Colors.green;
    if (paiement.estEchoue) return AppColors.error;
    return Colors.orange;
  }

  String get _labelStatut {
    if (paiement.estReussi) return 'Réussi';
    if (paiement.estEchoue) return 'Échoué';
    return 'En attente';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    paiement.matiere,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _couleurStatut.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _labelStatut,
                    style: TextStyle(fontSize: 11, color: _couleurStatut, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('Élève : ${paiement.eleve}', style: const TextStyle(fontSize: 13)),
            if (paiement.professeur != null)
              Text('Professeur : ${paiement.professeur}', style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 6),
            Text(
              '${paiement.montant} ${paiement.devise}${paiement.moyenPaiement != null ? ' — ${paiement.moyenPaiement}' : ''}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('dd/MM/yyyy HH:mm').format(paiement.createdAt),
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
