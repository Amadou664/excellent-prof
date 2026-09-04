import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/message_model.dart';
import 'repository_providers.dart';

/// `GET /demandes/:id/messages`. `autoDispose` : la conversation est
/// rechargée à chaque ouverture de l'écran plutôt que mise en cache
/// indéfiniment (pas de temps réel, voir ChatScreen pour le rafraîchissement
/// périodique).
final messagesProvider = FutureProvider.autoDispose
    .family<List<MessageModel>, String>((ref, demandeId) {
      return ref.watch(demandeRepositoryProvider).messages(demandeId);
    });
