import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/csv_export.dart';
import '../../../models/enums.dart';
import '../../../models/user_model.dart';
import '../../../providers/repository_providers.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/error_state.dart';
import '../../../widgets/loading_indicator.dart';
import '../../../widgets/status_chip.dart';
import 'user_detail_screen.dart';

const _pageSize = 20;

/// Gestion des utilisateurs (ADMIN) : recherche, filtres, activation /
/// suspension / désactivation, export CSV, fiche détaillée par utilisateur.
/// `GET /users?role=&status=&q=&page=&pageSize=`, `PATCH /users/:id/status`.
class GestionUtilisateurs extends ConsumerStatefulWidget {
  const GestionUtilisateurs({super.key});

  @override
  ConsumerState<GestionUtilisateurs> createState() => _GestionUtilisateursState();
}

class _GestionUtilisateursState extends ConsumerState<GestionUtilisateurs> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Role? _roleFilter;
  UserStatus? _statusFilter;
  String _query = '';

  final List<UserModel> _users = [];
  int _page = 1;
  int _total = 0;
  bool _isLoadingFirstPage = true;
  bool _isLoadingMore = false;
  bool _isExporting = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadFirstPage();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isLoadingMore || _isLoadingFirstPage) return;
    if (_users.length >= _total) return;
    if (_scrollController.position.pixels > _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadFirstPage() async {
    setState(() {
      _isLoadingFirstPage = true;
      _error = null;
      _users.clear();
      _page = 1;
    });
    try {
      final result = await ref.read(userRepositoryProvider).list(
            role: _roleFilter,
            status: _statusFilter,
            q: _query,
            page: 1,
            pageSize: _pageSize,
          );
      setState(() {
        _users.addAll(result.items);
        _total = result.total;
        _page = result.page;
      });
    } catch (e) {
      setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _isLoadingFirstPage = false);
    }
  }

  Future<void> _loadMore() async {
    setState(() => _isLoadingMore = true);
    try {
      final result = await ref.read(userRepositoryProvider).list(
            role: _roleFilter,
            status: _statusFilter,
            q: _query,
            page: _page + 1,
            pageSize: _pageSize,
          );
      setState(() {
        _users.addAll(result.items);
        _total = result.total;
        _page = result.page;
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Impossible de charger la suite de la liste.")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _exportCsv() async {
    setState(() => _isExporting = true);
    try {
      final repo = ref.read(userRepositoryProvider);
      final all = <UserModel>[];
      var page = 1;
      while (true) {
        final result = await repo.list(
          role: _roleFilter,
          status: _statusFilter,
          q: _query,
          page: page,
          pageSize: 100,
        );
        all.addAll(result.items);
        if (all.length >= result.total || result.items.isEmpty) break;
        page++;
      }

      final buffer = StringBuffer('Prénom,Nom,Email,Téléphone,Ville,Rôle,Statut,Inscrit le\n');
      for (final u in all) {
        buffer.writeln(
          [
            u.prenom,
            u.nom,
            u.email,
            u.telephone,
            u.ville,
            u.role.label,
            u.status.label,
            u.createdAt.toIso8601String().split('T').first,
          ].map(_csvField).join(','),
        );
      }

      final filename =
          'utilisateurs_excellent_prof_${DateTime.now().toIso8601String().split('T').first}.csv';
      await exportCsv(filename, buffer.toString());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              kIsWeb
                  ? '${all.length} utilisateur(s) exporté(s).'
                  : '${all.length} utilisateur(s) copié(s) dans le presse-papier (format CSV).',
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Échec de l'export.")),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  String _csvField(String value) => '"${value.replaceAll('"', '""')}"';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        labelText: 'Rechercher (nom, email...)',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onSubmitted: (v) {
                        _query = v.trim();
                        _loadFirstPage();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _isExporting ? null : _exportCsv,
                    tooltip: 'Exporter en CSV',
                    icon: _isExporting
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.download_outlined),
                  ),
                ],
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
                      onChanged: (v) {
                        _roleFilter = v;
                        _loadFirstPage();
                      },
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
                      onChanged: (v) {
                        _statusFilter = v;
                        _loadFirstPage();
                      },
                    ),
                  ),
                ],
              ),
              if (_total > 0) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${_users.length} / $_total utilisateur(s)',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: _isLoadingFirstPage
              ? const LoadingIndicator()
              : _error != null
                  ? ErrorState(error: _error!, onRetry: _loadFirstPage)
                  : _users.isEmpty
                      ? const EmptyState(
                          message: 'Aucun utilisateur ne correspond à ces filtres.',
                          icon: Icons.people_outline,
                        )
                      : RefreshIndicator(
                          onRefresh: _loadFirstPage,
                          child: ListView.separated(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(12),
                            itemCount: _users.length + (_users.length < _total ? 1 : 0),
                            separatorBuilder: (_, _) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              if (index >= _users.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(child: CircularProgressIndicator()),
                                );
                              }
                              return _UserTile(
                                user: _users[index],
                                onChanged: _loadFirstPage,
                              );
                            },
                          ),
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
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => UserDetailScreen(userId: user.id)),
        ),
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
