import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/demande_model.dart';
import '../../../models/enums.dart';
import '../../../providers/demandes_provider.dart';
import '../../../providers/repository_providers.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/error_state.dart';
import '../../../widgets/loading_indicator.dart';
import '../../../widgets/status_chip.dart';
import '../../avis/widgets/avis_form.dart';

/// Liste des demandes de cours de l'utilisateur courant (`GET
/// /demandes/mine`), avec possibilité d'annuler une demande active ou de
/// laisser un avis une fois la demande `TERMINEE`.
///
/// Réutilisé par l'espace Parent et l'espace Étudiant/Particulier (les deux
/// utilisent la même route `/demandes/mine` scoping automatiquement côté
/// backend selon l'utilisateur connecté).
class DemandesListView extends ConsumerStatefulWidget {
  const DemandesListView({super.key});

  @override
  ConsumerState<DemandesListView> createState() => _DemandesListViewState();
}

class _DemandesListViewState extends ConsumerState<DemandesListView>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Après un paiement CinetPay, l'utilisateur revient sur cette page depuis l'onglet de
    // paiement (ou l'app mobile reprend le premier plan) : on rafraîchit automatiquement au
    // lieu d'attendre que l'utilisateur pense à tirer vers le bas.
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(demandesMineProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final demandesAsync = ref.watch(demandesMineProvider);

    return demandesAsync.when(
      loading: () => const LoadingIndicator(),
      error: (e, _) => ErrorState(
        error: e,
        onRetry: () => ref.invalidate(demandesMineProvider),
      ),
      data: (demandes) {
        if (demandes.isEmpty) {
          return const EmptyState(
            message: 'Aucune demande de cours pour le moment.',
            icon: Icons.assignment_outlined,
          );
        }
        final sorted = [...demandes]
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(demandesMineProvider),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: sorted.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) =>
                _DemandeTile(demande: sorted[index]),
          ),
        );
      },
    );
  }
}

class _DemandeTile extends ConsumerWidget {
  const _DemandeTile({required this.demande});

  final DemandeModel demande;

  Future<void> _annuler(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler la demande ?'),
        content: Text('Voulez-vous annuler la demande "${demande.matiere}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(demandeRepositoryProvider).annuler(demande.id);
      ref.invalidate(demandesMineProvider);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Impossible d'annuler la demande.")),
        );
      }
    }
  }

  Future<void> _payer(BuildContext context, WidgetRef ref) async {
    try {
      final paymentUrl = await ref
          .read(paiementRepositoryProvider)
          .initier(demandeId: demande.id);
      await launchUrl(
        Uri.parse(paymentUrl),
        mode: LaunchMode.externalApplication,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Terminez le paiement dans la page ouverte, puis revenez ici — la mise à jour est automatique.',
            ),
            duration: Duration(seconds: 6),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Impossible de lancer le paiement. Réessayez."),
          ),
        );
      }
    }
  }

  Future<void> _voirRecu(BuildContext context, WidgetRef ref) async {
    try {
      final statut = await ref
          .read(paiementRepositoryProvider)
          .statut(demande.id);
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Reçu de paiement'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LigneRecu('Matière', demande.matiere),
              _LigneRecu(
                'Montant',
                statut.montant != null ? '${statut.montant} FCFA' : '—',
              ),
              _LigneRecu(
                'Moyen de paiement',
                statut.moyenPaiement ??
                    'Enregistré manuellement par l\'administration',
              ),
              _LigneRecu(
                'Date',
                statut.datePaiement != null
                    ? DateFormat(
                        'dd/MM/yyyy à HH:mm',
                      ).format(statut.datePaiement!)
                    : '—',
              ),
              if (statut.transactionId != null)
                _LigneRecu('Référence', statut.transactionId!),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ],
        ),
      );
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible de récupérer le reçu.')),
        );
      }
    }
  }

  void _laisserUnAvis(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: AvisForm(
          professeurId: demande.professeurId!,
          onSubmitted: () => Navigator.pop(context),
        ),
      ),
    );
  }

  bool get _peutEtreAnnulee =>
      demande.status == DemandeStatus.nouvelle ||
      demande.status == DemandeStatus.profPropose ||
      demande.status == DemandeStatus.confirmee;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    demande.matiere,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                StatusChip.demandeStatus(demande.status),
              ],
            ),
            const SizedBox(height: 6),
            Text('Mode : ${demande.modePref.label}'),
            Text(
              'Créée le ${DateFormat('dd/MM/yyyy').format(demande.createdAt)}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            if (demande.notes != null && demande.notes!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(demande.notes!),
            ],
            if (demande.montant != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    demande.paye ? Icons.check_circle : Icons.pending_outlined,
                    size: 16,
                    color: demande.paye ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    demande.paye
                        ? '${demande.montant} FCFA payé'
                        : '${demande.montant} FCFA à payer',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                if (demande.professeurId != null &&
                    demande.status != DemandeStatus.annulee)
                  OutlinedButton.icon(
                    onPressed: () =>
                        context.push(AppRoutes.chatPath(demande.id)),
                    icon: Icon(
                      demande.montant != null && !demande.paye
                          ? Icons.lock_outline
                          : Icons.chat_bubble_outline,
                      size: 18,
                    ),
                    label: Text(
                      demande.montant != null && !demande.paye
                          ? 'Discuter (verrouillé)'
                          : 'Discuter',
                    ),
                  ),
                if (demande.montant != null &&
                    !demande.paye &&
                    demande.status != DemandeStatus.annulee)
                  ElevatedButton.icon(
                    onPressed: () => _payer(context, ref),
                    icon: const Icon(Icons.payment, size: 18),
                    label: const Text('Payer maintenant'),
                  ),
                if (demande.paye)
                  OutlinedButton.icon(
                    onPressed: () => _voirRecu(context, ref),
                    icon: const Icon(Icons.receipt_long_outlined, size: 18),
                    label: const Text('Voir le reçu'),
                  ),
                if (_peutEtreAnnulee)
                  OutlinedButton(
                    onPressed: () => _annuler(context, ref),
                    child: const Text('Annuler'),
                  ),
                if (demande.status == DemandeStatus.terminee &&
                    demande.professeurId != null)
                  ElevatedButton.icon(
                    onPressed: () => _laisserUnAvis(context),
                    icon: const Icon(Icons.star_outline, size: 18),
                    label: const Text('Laisser un avis'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LigneRecu extends StatelessWidget {
  const _LigneRecu(this.label, this.valeur);

  final String label;
  final String valeur;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              valeur,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
