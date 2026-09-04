import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../models/demande_model.dart';
import '../../../models/enums.dart';
import '../../../models/teacher_profile_model.dart';
import '../../../providers/demandes_provider.dart';
import '../../../providers/repository_providers.dart';
import '../../../providers/teachers_provider.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/error_state.dart';
import '../../../widgets/loading_indicator.dart';
import '../../../widgets/status_chip.dart';

/// File d'attente des demandes de cours à traiter (ADMIN) : attribution
/// d'un professeur validé à une demande `NOUVELLE`. `GET /demandes?status=`,
/// `PATCH /demandes/:id/assigner`.
class AttributionDemandes extends ConsumerStatefulWidget {
  const AttributionDemandes({super.key});

  @override
  ConsumerState<AttributionDemandes> createState() => _AttributionDemandesState();
}

class _AttributionDemandesState extends ConsumerState<AttributionDemandes> {
  DemandeStatus? _filter = DemandeStatus.nouvelle;

  @override
  Widget build(BuildContext context) {
    final demandesAsync = ref.watch(demandesAdminProvider(_filter));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Toutes'),
                selected: _filter == null,
                onSelected: (_) => setState(() => _filter = null),
              ),
              ...DemandeStatus.values.map(
                (s) => ChoiceChip(
                  label: Text(s.label),
                  selected: _filter == s,
                  onSelected: (_) => setState(() => _filter = s),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: demandesAsync.when(
            loading: () => const LoadingIndicator(),
            error: (e, _) => ErrorState(
              error: e,
              onRetry: () => ref.invalidate(demandesAdminProvider(_filter)),
            ),
            data: (demandes) {
              if (demandes.isEmpty) {
                return const EmptyState(
                  message: 'Aucune demande ne correspond à ce filtre.',
                  icon: Icons.inbox_outlined,
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: demandes.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) => _DemandeTile(
                  demande: demandes[index],
                  onChanged: () => ref.invalidate(demandesAdminProvider(_filter)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DemandeTile extends ConsumerWidget {
  const _DemandeTile({required this.demande, required this.onChanged});

  final DemandeModel demande;
  final VoidCallback onChanged;

  Future<void> _togglePaye(BuildContext context, WidgetRef ref) async {
    int? montant = demande.montant;
    if (!demande.paye) {
      final controller = TextEditingController(
        text: montant?.toString() ?? '',
      );
      final saisi = await showDialog<int>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Marquer comme payé'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Montant (FCFA, optionnel)'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, int.tryParse(controller.text)),
              child: const Text('Confirmer'),
            ),
          ],
        ),
      );
      if (saisi != null) montant = saisi;
    }
    try {
      await ref.read(demandeRepositoryProvider).updatePaiement(
            demandeId: demande.id,
            paye: !demande.paye,
            montant: montant,
          );
      onChanged();
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible de mettre à jour le paiement.')),
        );
      }
    }
  }

  Future<void> _assigner(BuildContext context, WidgetRef ref) async {
    final teachersAsync = await ref.read(
      teachersAdminProvider(const TeacherFilter(statutCandidature: StatutCandidature.validee)).future,
    );
    if (!context.mounted) return;
    if (teachersAsync.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun professeur validé disponible.')),
      );
      return;
    }
    final selected = await showDialog<TeacherProfileModel>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Choisir un professeur'),
        children: teachersAsync
            .map(
              (t) => SimpleDialogOption(
                onPressed: () => Navigator.pop(context, t),
                child: Text(t.user?.nomComplet ?? t.id),
              ),
            )
            .toList(),
      ),
    );
    if (selected == null) return;
    try {
      await ref.read(demandeRepositoryProvider).assigner(
            demandeId: demande.id,
            professeurId: selected.userId,
          );
      onChanged();
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'assigner ce professeur.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(demande.matiere, style: const TextStyle(fontWeight: FontWeight.bold))),
                StatusChip.demandeStatus(demande.status),
              ],
            ),
            Text('Mode : ${demande.modePref.label}'),
            Text(
              'Créée le ${DateFormat('dd/MM/yyyy').format(demande.createdAt)}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            if (demande.paye)
              Text(
                'Payé${demande.montant != null ? ' — ${demande.montant} FCFA' : ''}',
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                if (demande.status == DemandeStatus.nouvelle)
                  ElevatedButton.icon(
                    onPressed: () => _assigner(context, ref),
                    icon: const Icon(Icons.person_add_alt),
                    label: const Text('Assigner un professeur'),
                  ),
                if (demande.professeurId != null)
                  OutlinedButton.icon(
                    onPressed: () => _togglePaye(context, ref),
                    icon: Icon(
                      demande.paye ? Icons.money_off : Icons.attach_money,
                      size: 18,
                    ),
                    label: Text(demande.paye ? 'Marquer non payé' : 'Marquer payé'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
