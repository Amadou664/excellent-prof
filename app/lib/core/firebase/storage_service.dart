import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

/// Upload de fichiers vers Firebase Storage.
///
/// Le backend attend des URLs (string) dans ses payloads (`photoUrl`,
/// `diplomesUrls`) : cette couche fait l'upload et renvoie l'URL de
/// téléchargement publique à transmettre telle quelle à l'API.
class StorageService {
  StorageService(this._storage);

  final FirebaseStorage _storage;

  /// Upload une photo de profil pour l'utilisateur [uid] et retourne son URL
  /// de téléchargement.
  Future<String> uploadProfilePhoto({
    required String uid,
    required File file,
  }) async {
    final ext = file.path.split('.').last;
    final ref = _storage
        .ref()
        .child('profile_photos')
        .child('$uid.$ext');
    final task = await ref.putFile(file);
    return task.ref.getDownloadURL();
  }

  /// Upload un document/diplôme pour la candidature enseignant [uid] et
  /// retourne son URL de téléchargement (à ajouter à `diplomesUrls`).
  Future<String> uploadDiplome({
    required String uid,
    required File file,
    required String fileName,
  }) async {
    final ref = _storage
        .ref()
        .child('teacher_documents')
        .child(uid)
        .child(fileName);
    final task = await ref.putFile(file);
    return task.ref.getDownloadURL();
  }

  /// Upload générique, utilisé par exemple pour l'image d'une annonce (côté
  /// admin).
  Future<String> uploadFile({
    required String storagePath,
    required File file,
  }) async {
    final ref = _storage.ref().child(storagePath);
    final task = await ref.putFile(file);
    return task.ref.getDownloadURL();
  }
}
