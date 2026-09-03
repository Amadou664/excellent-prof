import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../providers/annonces_provider.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/error_state.dart';
import '../../../widgets/loading_indicator.dart';
import '../../../widgets/status_chip.dart';

/// Détail d'une annonce.
///
/// NOTE : API_CONTRACT.md ne documente pas de `GET /annonces/:id` dédié
/// (seul `GET /annonces` en liste existe). On récupère donc la liste
/// (potentiellement déjà en cache via [annoncesProvider]) et on cherche
/// l'annonce par [id] dedans.
class AnnonceDetailScreen extends ConsumerWidget {
  const AnnonceDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final annoncesAsync = ref.watch(annoncesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Annonce')),
      body: annoncesAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorState(error: e, onRetry: () => ref.invalidate(annoncesProvider)),
        data: (annonces) {
          final match = annonces.where((a) => a.id == id);
          if (match.isEmpty) {
            return const EmptyState(message: 'Annonce introuvable.', icon: Icons.error_outline);
          }
          final annonce = match.first;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (annonce.imageUrl != null)
                  CachedNetworkImage(
                    imageUrl: annonce.imageUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => const SizedBox(height: 0),
                  ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        children: [
                          StatusChip(label: annonce.type.label, color: Colors.teal),
                          StatusChip(label: annonce.visibilite.label, color: Colors.indigo),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(annonce.titre, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(
                        DateFormat('dd/MM/yyyy').format(annonce.datePublication),
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      Text(annonce.contenu, style: const TextStyle(fontSize: 15, height: 1.5)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
