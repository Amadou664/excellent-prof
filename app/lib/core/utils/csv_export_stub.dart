import 'package:flutter/services.dart';

/// Mobile (pas de téléchargement de fichier natif ici pour rester simple) :
/// copie le CSV dans le presse-papier.
Future<void> exportCsv(String filename, String csvContent) async {
  await Clipboard.setData(ClipboardData(text: csvContent));
}
