import 'dart:convert';
import 'dart:html' as html;

/// Web : déclenche un vrai téléchargement de fichier via un Blob.
/// Le BOM UTF-8 (`﻿`) évite les accents cassés à l'ouverture dans Excel.
Future<void> exportCsv(String filename, String csvContent) async {
  final bytes = utf8.encode('﻿$csvContent');
  final blob = html.Blob([bytes], 'text/csv;charset=utf-8');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..click();
  html.Url.revokeObjectUrl(url);
}
