import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../providers/auth_providers.dart';
import '../../../providers/cours_pour_tous_provider.dart';
import '../../../providers/repository_providers.dart';
import '../../../providers/students_provider.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/error_state.dart';
import '../../../widgets/inline_error_banner.dart';
import '../../../widgets/loading_indicator.dart';

/// Inscription à une campagne "cours pour tous" (utilisateur connecté).
/// `POST /cours-pour-tous/:id/inscription` body `{ studentId }`.
class InscriptionScreen extends ConsumerStatefulWidget {
  const InscriptionScreen({super.key, required this.coursId});

  final String coursId;

  @override
  ConsumerState<InscriptionScreen> createState() => _InscriptionScreenState();
}

class _InscriptionScreenState extends ConsumerState<InscriptionScreen> {
  String? _studentId;
  bool _isLoading = false;
  bool _success = false;
  String? _errorMessage;

  Future<void> _submit() async {
    if (_studentId == null) {
      setState(() => _errorMessage = 'Sélectionnez un élève.');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await ref.read(coursPourTousRepositoryProvider).inscrire(
            coursId: widget.coursId,
            studentId: _studentId!,
          );
      ref.invalidate(coursPourTousProvider);
      setState(() => _success = true);
    } catch (e) {
      setState(() => _errorMessage = "Impossible de finaliser l'inscription.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Inscription')),
      body: SafeArea(
        child: userAsync.when(
          loading: () => const LoadingIndicator(),
          error: (e, _) => ErrorState(error: e, onRetry: () => ref.invalidate(currentUserProvider)),
          data: (user) {
            if (user == null) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: EmptyState(
                  message: 'Connectez-vous pour vous inscrire à cette campagne.',
                  icon: Icons.lock_outline,
                  actionLabel: 'Se connecter',
                  onAction: () => context.push(AppRoutes.login),
                ),
              );
            }
            if (_success) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 72),
                    const SizedBox(height: 16),
                    const Text(
                      'Inscription confirmée !',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    AppButton(label: 'Retour', onPressed: () => context.pop()),
                  ],
                ),
              );
            }
            final studentsAsync = ref.watch(studentsMineProvider);
            return studentsAsync.when(
              loading: () => const LoadingIndicator(),
              error: (e, _) => ErrorState(error: e, onRetry: () => ref.invalidate(studentsMineProvider)),
              data: (students) {
                if (students.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: EmptyState(
                      message: "Ajoutez d'abord un élève avant de vous inscrire.",
                      icon: Icons.person_add_alt,
                    ),
                  );
                }
                _studentId ??= students.first.id;
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_errorMessage != null) ...[
                        InlineErrorBanner(message: _errorMessage!),
                        const SizedBox(height: 16),
                      ],
                      const Text('Élève à inscrire', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _studentId,
                        items: students
                            .map((s) => DropdownMenuItem(value: s.id, child: Text(s.nomComplet)))
                            .toList(),
                        onChanged: (v) => setState(() => _studentId = v),
                      ),
                      const SizedBox(height: 24),
                      AppButton(label: "Confirmer l'inscription", isLoading: _isLoading, onPressed: _submit),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
