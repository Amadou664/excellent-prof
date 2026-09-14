import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/activity_log_model.dart';
import '../../../providers/activity_provider.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/error_state.dart';
import '../../../widgets/loading_indicator.dart';

/// Journal d'activité (ADMIN) : chaque requête reçue par le serveur, tous
/// utilisateurs et tous modules confondus, plus les vues d'écran envoyées
/// par l'application. `GET /activity`.
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
              hintText: 'Rechercher (nom, rôle, écran, action...)',
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
                    : logs
                          .where(
                            (l) =>
                                (l.utilisateur?.toLowerCase().contains(q) ??
                                    false) ||
                                (l.role?.toLowerCase().contains(q) ?? false) ||
                                l.path.toLowerCase().contains(q) ||
                                l.method.toLowerCase().contains(q),
                          )
                          .toList();
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

  Color get _couleurMethode {
    if (log.estUneVue) return AppColors.info;
    if (log.estUneErreur) return AppColors.error;
    switch (log.method) {
      case 'POST':
        return AppColors.success;
      case 'PATCH':
      case 'PUT':
        return AppColors.warning;
      case 'DELETE':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Container(
        width: 8,
        height: 8,
        margin: const EdgeInsets.only(top: 4),
        decoration: BoxDecoration(
          color: _couleurMethode,
          shape: BoxShape.circle,
        ),
      ),
      title: Text(
        log.utilisateur ?? 'Utilisateur inconnu',
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
      subtitle: Text(
        [
          if (log.role != null) log.role,
          log.estUneVue ? 'a ouvert ${log.path}' : '${log.method} ${log.path}',
          if (log.statusCode != null) '(${log.statusCode})',
        ].join(' — '),
        style: const TextStyle(fontSize: 12),
      ),
      trailing: Text(
        DateFormat('dd/MM HH:mm:ss').format(log.createdAt),
        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
      ),
    );
  }
}
