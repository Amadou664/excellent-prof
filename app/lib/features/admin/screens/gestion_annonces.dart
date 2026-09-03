import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../models/annonce_model.dart';
import '../../../models/enums.dart';
import '../../../providers/annonces_provider.dart';
import '../../../providers/repository_providers.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/error_state.dart';
import '../../../widgets/inline_error_banner.dart';
import '../../../widgets/loading_indicator.dart';

/// Gestion (CRUD) des annonces (ADMIN). `POST/PATCH/DELETE /annonces`.
class GestionAnnonces extends ConsumerWidget {
  const GestionAnnonces({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final annoncesAsync = ref.watch(annoncesProvider);

    return Scaffold(
      body: annoncesAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorState(error: e, onRetry: () => ref.invalidate(annoncesProvider)),
        data: (annonces) {
          if (annonces.isEmpty) {
            return const EmptyState(message: 'Aucune annonce publiée.', icon: Icons.campaign_outlined);
          }
          final sorted = [...annonces]..sort((a, b) => b.datePublication.compareTo(a.datePublication));
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: sorted.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final annonce = sorted[index];
              return Card(
                child: ListTile(
                  title: Text(annonce.titre, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    '${annonce.type.label} • ${annonce.visibilite.label}\n'
                    '${DateFormat('dd/MM/yyyy').format(annonce.datePublication)}',
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'edit') _openForm(context, ref, annonce: annonce);
                      if (v == 'delete') _delete(context, ref, annonce);
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'edit', child: Text('Modifier')),
                      PopupMenuItem(value: 'delete', child: Text('Supprimer')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, AnnonceModel annonce) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer cette annonce ?'),
        content: Text(annonce.titre),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(annonceRepositoryProvider).delete(annonce.id);
      ref.invalidate(annoncesProvider);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Suppression impossible.')));
      }
    }
  }

  void _openForm(BuildContext context, WidgetRef ref, {AnnonceModel? annonce}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: _AnnonceFormSheet(annonce: annonce),
      ),
    );
  }
}

class _AnnonceFormSheet extends ConsumerStatefulWidget {
  const _AnnonceFormSheet({this.annonce});

  final AnnonceModel? annonce;

  @override
  ConsumerState<_AnnonceFormSheet> createState() => _AnnonceFormSheetState();
}

class _AnnonceFormSheetState extends ConsumerState<_AnnonceFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titreController;
  late final TextEditingController _contenuController;
  late final TextEditingController _imageUrlController;
  late AnnonceType _type;
  late Visibilite _visibilite;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final a = widget.annonce;
    _titreController = TextEditingController(text: a?.titre ?? '');
    _contenuController = TextEditingController(text: a?.contenu ?? '');
    _imageUrlController = TextEditingController(text: a?.imageUrl ?? '');
    _type = a?.type ?? AnnonceType.info;
    _visibilite = a?.visibilite ?? Visibilite.public;
  }

  @override
  void dispose() {
    _titreController.dispose();
    _contenuController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });
    try {
      final repo = ref.read(annonceRepositoryProvider);
      final imageUrl = _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim();
      if (widget.annonce == null) {
        await repo.create(
          titre: _titreController.text.trim(),
          contenu: _contenuController.text.trim(),
          type: _type,
          visibilite: _visibilite,
          imageUrl: imageUrl,
        );
      } else {
        await repo.update(
          id: widget.annonce!.id,
          titre: _titreController.text.trim(),
          contenu: _contenuController.text.trim(),
          type: _type,
          visibilite: _visibilite,
          imageUrl: imageUrl,
        );
      }
      ref.invalidate(annoncesProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _errorMessage = "Impossible d'enregistrer l'annonce.");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.annonce == null ? 'Nouvelle annonce' : "Modifier l'annonce",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null) ...[
              InlineErrorBanner(message: _errorMessage!),
              const SizedBox(height: 16),
            ],
            AppTextField(
              label: 'Titre',
              controller: _titreController,
              validator: (v) => v == null || v.trim().isEmpty ? 'Champ requis' : null,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Contenu',
              controller: _contenuController,
              maxLines: 4,
              validator: (v) => v == null || v.trim().isEmpty ? 'Champ requis' : null,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: "URL de l'image (optionnel)",
              controller: _imageUrlController,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<AnnonceType>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: "Type d'annonce"),
              items: AnnonceType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label))).toList(),
              onChanged: (v) => setState(() => _type = v ?? _type),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Visibilite>(
              initialValue: _visibilite,
              decoration: const InputDecoration(labelText: 'Visibilité'),
              items: Visibilite.values.map((v) => DropdownMenuItem(value: v, child: Text(v.label))).toList(),
              onChanged: (v) => setState(() => _visibilite = v ?? _visibilite),
            ),
            const SizedBox(height: 20),
            AppButton(label: 'Enregistrer', isLoading: _isSaving, onPressed: _submit),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
