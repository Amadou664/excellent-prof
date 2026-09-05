import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/enums.dart';
import '../../../models/user_detail_model.dart';
import '../../../providers/repository_providers.dart';
import '../../../widgets/error_state.dart';
import '../../../widgets/loading_indicator.dart';
import '../../../widgets/status_chip.dart';

/// Fiche détaillée d'un utilisateur (ADMIN). `GET /users/:id`.
class UserDetailScreen extends ConsumerWidget {
  const UserDetailScreen({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailFuture = ref.watch(_userDetailProvider(userId));

    return Scaffold(
      appBar: AppBar(title: const Text('Fiche utilisateur')),
      body: detailFuture.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorState(
          error: e,
          onRetry: () => ref.invalidate(_userDetailProvider(userId)),
        ),
        data: (detail) => _UserDetailBody(detail: detail),
      ),
    );
  }
}

final _userDetailProvider = FutureProvider.autoDispose
    .family<UserDetailModel, String>((ref, id) {
      return ref.watch(userRepositoryProvider).getDetail(id);
    });

class _UserDetailBody extends StatelessWidget {
  const _UserDetailBody({required this.detail});

  final UserDetailModel detail;

  @override
  Widget build(BuildContext context) {
    final user = detail.user;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.paleGold,
            backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
            child: user.photoUrl == null
                ? Text(
                    user.prenom.isNotEmpty ? user.prenom[0].toUpperCase() : '?',
                    style: const TextStyle(fontSize: 28, color: AppColors.primaryDarkGreen),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(user.nomComplet, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Wrap(
              spacing: 8,
              alignment: WrapAlignment.center,
              children: [
                Chip(label: Text(user.role.label)),
                StatusChip.userStatus(user.status),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        _Section(
          title: 'Coordonnées',
          children: [
            _Row(icon: Icons.email_outlined, label: 'Email', value: user.email),
            _Row(icon: Icons.phone_outlined, label: 'Téléphone', value: user.telephone),
            _Row(icon: Icons.location_city_outlined, label: 'Ville', value: user.ville),
            _Row(
              icon: Icons.calendar_today_outlined,
              label: 'Inscrit le',
              value: DateFormat('dd/MM/yyyy').format(user.createdAt),
            ),
          ],
        ),
        if (user.role == Role.professeur) ...[
          const SizedBox(height: 20),
          _Section(
            title: 'Activité professeur',
            children: [
              _Row(
                icon: Icons.assignment_turned_in_outlined,
                label: 'Demandes assignées',
                value: detail.demandesCommeProf.toString(),
              ),
              _Row(
                icon: Icons.reviews_outlined,
                label: 'Avis reçus (visibles)',
                value: detail.avisRecus.toString(),
              ),
              if (detail.teacherProfile != null) ...[
                _Row(
                  icon: Icons.workspace_premium_outlined,
                  label: 'Candidature',
                  value: detail.teacherProfile!.statutCandidature.label,
                ),
                _Row(
                  icon: Icons.star_outline,
                  label: 'Note moyenne',
                  value:
                      '${detail.teacherProfile!.noteMoyenne.toStringAsFixed(1)} / 5 (${detail.teacherProfile!.nombreAvis} avis)',
                ),
                if (detail.teacherProfile!.specialites.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: detail.teacherProfile!.specialites
                          .map((s) => Chip(label: Text(s)))
                          .toList(),
                    ),
                  ),
              ],
            ],
          ),
        ],
        if (user.role == Role.parent ||
            user.role == Role.etudiant ||
            user.role == Role.particulier) ...[
          const SizedBox(height: 20),
          _Section(
            title: 'Activité famille',
            children: [
              _Row(
                icon: Icons.assignment_outlined,
                label: 'Demandes de cours créées',
                value: detail.demandesCommeFamille.toString(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _Section(
            title: user.role == Role.parent ? 'Enfants' : 'Élève',
            children: detail.students.isEmpty
                ? [const Text('Aucun élève enregistré.', style: TextStyle(color: AppColors.textSecondary))]
                : detail.students
                    .map(
                      (s) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            const Icon(Icons.school_outlined, size: 18, color: AppColors.primaryGreen),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '${s.nomComplet} — ${s.niveau.label}, ${s.programme.label}',
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
          ),
        ],
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primaryGreen),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                Text(value.isEmpty ? '—' : value, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
