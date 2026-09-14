import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/activity_log_model.dart';
import '../../../providers/activity_provider.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/error_state.dart';
import '../../../widgets/loading_indicator.dart';
import 'activity_labels.dart';

/// Journal d'activité (ADMIN) : chaque requête reçue par le serveur, tous
/// utilisateurs et tous modules confondus, plus les vues d'écran envoyées
/// par l'application — traduit en phrases claires (voir `activity_labels.dart`),
/// jamais en jargon technique brut. `GET /activity`.
class GestionActivite extends ConsumerStatefulWidget {
  const GestionActivite({super.key});

  @override
  ConsumerState<GestionActivite> createState() => _GestionActiviteState();
}

class _GestionActiviteState extends ConsumerState<GestionActivite> {
  String _recherche = '';

  @override
  Widget build(BuildContext context) {
    final activityAsync = ref.watch(activityAdminProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Rechercher (nom, rôle...)',
              prefixIcon: Icon(Icons.search, size: 20),
              isDense: true,
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => setState(() => _recherche = v),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => ref.invalidate(activityAdminProvider),
            child: activityAsync.when(
              loading: () => const LoadingIndicator(),
              error: (e, _) => ErrorState(
                error: e,
                onRetry: () => ref.invalidate(activityAdminProvider),
              ),
              data: (logs) {
                final q = _recherche.trim().toLowerCase();
                final filtres = q.isEmpty
                    ? logs
                    : logs.where((l) {
                        return nomActeur(l).toLowerCase().contains(q) ||
                            libelleRole(l.role).toLowerCase().contains(q) ||
                            libelleActivite(l).toLowerCase().contains(q);
                      }).toList();
                if (filtres.isEmpty) {
                  return ListView(
                    children: const [
                      SizedBox(height: 80),
                      EmptyState(
                        message: 'Aucune activité pour le moment.',
                        icon: Icons.history_outlined,
                      ),
                    ],
                  );
                }
                return ListView.separated(
                  itemCount: filtres.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) =>
                      _ActivityRow(log: filtres[index]),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.log});

  final ActivityLogModel log;

  Color get _couleurStatut {
    if (log.estUneVue) return AppColors.info;
    if (log.estUneErreur) return AppColors.error;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    final role = libelleRole(log.role);
    return ListTile(
      dense: true,
      leading: Container(
        width: 8,
        height: 8,
        margin: const EdgeInsets.only(top: 4),
        decoration: BoxDecoration(
          color: _couleurStatut,
          shape: BoxShape.circle,
        ),
      ),
      title: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: nomActeur(log),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            if (role.isNotEmpty)
              TextSpan(
                text: ' ($role)',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        style: const TextStyle(fontSize: 13),
      ),
      subtitle: Text(
        libelleActivite(log),
        style: const TextStyle(fontSize: 12),
      ),
      trailing: Text(
        DateFormat('dd/MM HH:mm:ss').format(log.createdAt),
        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
      ),
    );
  }
}
