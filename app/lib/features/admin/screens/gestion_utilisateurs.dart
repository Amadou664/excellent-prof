import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/enums.dart';
import '../../../models/user_model.dart';
import '../../../providers/admin_provider.dart';
import '../../../providers/repository_providers.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/error_state.dart';
import '../../../widgets/loading_indicator.dart';
import '../../../widgets/status_chip.dart';

/// Gestion des utilisateurs (ADMIN) : recherche, filtres, activation /
/// suspension / désactivation. `GET /users?role=&status=&q=`, `PATCH
/// /users/:id/status`.
class GestionUtilisateurs extends ConsumerStatefulWidget {
  const GestionUtilisateurs({super.key});

  @override
  ConsumerState<GestionUtilisateurs> createState() => _GestionUtilisateursState();
}

class _GestionUtilisateursState extends ConsumerState<GestionUtilisateurs> {
  final _searchController = TextEditingController();
  Role? _roleFilter;
  UserStatus? _statusFilter;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = UserFilter(role: _roleFilter, status: _statusFilter, q: _query);
    final usersAsync = ref.watch(adminUsersProvider(filter));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Rechercher (nom, email...)',
                  prefixIcon: Icon(Icons.search),
                ),
                onSubmitted: (v) => setState(() => _query = v.trim()),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<Role?>(
                      initialValue: _roleFilter,
                      decoration: const InputDecoration(labelText: 'Rôle'),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Tous')),
                        ...Role.values.map((r) => DropdownMenuItem(value: r, child: Text(r.label))),
                      ],
                      onChanged: (v) => setState(() => _roleFilter = v),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<UserStatus?>(
                      initialValue: _statusFilter,
                      decoration: const InputDecoration(labelText: 'Statut'),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Tous')),
                        ...UserStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.label))),
                      ],
                      onChanged: (v) => setState(() => _statusFilter = v),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: usersAsync.when(
            loading: () => const LoadingIndicator(),
            error: (e, _) => ErrorState(
              error: e,
              onRetry: () => ref.invalidate(adminUsersProvider(filter)),
            ),
            data: (users) {
              if (users.isEmpty) {
                return const EmptyState(
                  message: 'Aucun utilisateur ne correspond à ces filtres.',
                  icon: Icons.people_outline,
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: users.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) => _UserTile(
                  user: users[index],
                  onChanged: () => ref.invalidate(adminUsersProvider(filter)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _UserTile extends ConsumerWidget {
  const _UserTile({required this.user, required this.onChanged});

  final UserModel user;
  final VoidCallback onChanged;

  Future<void> _changeStatus(BuildContext context, WidgetRef ref, UserStatus status) async {
    if (status == UserStatus.suspendu || status == UserStatus.desactive) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('${status.label} ce compte ?'),
          content: Text(
            '${user.nomComplet} (${user.email}) sera immédiatement bloqué et ne pourra plus '
            'utiliser l\'application, même s\'il est déjà connecté.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(status.label, style: const TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    try {
      await ref.read(userRepositoryProvider).updateStatus(id: user.id, status: status);
      onChanged();
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible de mettre à jour ce statut.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        title: Text(user.nomComplet, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${user.role.label} • ${user.email}'),
        trailing: PopupMenuButton<UserStatus>(
          initialValue: user.status,
          onSelected: (status) => _changeStatus(context, ref, status),
          itemBuilder: (context) => UserStatus.values
              .map((s) => PopupMenuItem(value: s, child: Text(s.label)))
              .toList(),
          child: StatusChip.userStatus(user.status),
        ),
      ),
    );
  }
}
