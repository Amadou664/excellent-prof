# API Contract — L'Excellent Prof

Base URL (dev): `http://localhost:4000/api`. Toutes les routes sauf `POST /auth/register`
et `GET /annonces` (annonces publiques) exigent le header :

```
Authorization: Bearer <Firebase ID token>
```

Le backend vérifie le token avec le Firebase Admin SDK, en tire `firebaseUid` et
`email`, puis résout la ligne `User` correspondante (créée lors de `/auth/register`).

Enums partagés :

- `Role`: `PARENT | PROFESSEUR | ETUDIANT | PARTICULIER | ADMIN`
- `UserStatus`: `ACTIF | EN_ATTENTE | SUSPENDU | DESACTIVE`
- `Niveau`: `FONDAMENTAL | COLLEGE | LYCEE | SUPERIEUR`
- `Programme`: `FRANCAIS | MALIEN`
- `ModePref`: `DOMICILE | LIGNE | GROUPE`
- `DemandeStatus`: `NOUVELLE | PROF_PROPOSE | CONFIRMEE | EN_COURS | TERMINEE | ANNULEE`
- `StatutCandidature`: `SOUMISE | ENTRETIEN | VALIDEE | REFUSEE`
- `AnnonceType`: `RECRUTEMENT | FORMATION | EVENEMENT | RESULTAT | INFO`
- `Visibilite`: `PUBLIC | CONNECTES`
- `AvisStatut`: `VISIBLE | MASQUE`

Toutes les réponses en succès : `{ "data": ... }`. Erreurs : `{ "error": { "code": string, "message": string } }` avec status HTTP approprié (400/401/403/404/409/500).

---

## Auth

### POST /auth/register (public, appelé juste après la création du compte Firebase Auth)
Body :
```json
{
  "role": "PARENT | PROFESSEUR | ETUDIANT | PARTICULIER",
  "nom": "string", "prenom": "string", "telephone": "string", "ville": "string",
  "teacherProfile": { "specialites": ["string"], "bio": "string", "diplomesUrls": ["string"] },
  "studentSelf": { "niveau": "Niveau", "programme": "Programme", "dateNaissance": "ISO date" }
}
```
- Header `Authorization: Bearer <Firebase ID token>` requis (compte Firebase déjà créé côté client).
- `teacherProfile` fourni seulement si `role = PROFESSEUR` -> crée `TeacherProfile` avec `statutCandidature = SOUMISE`, `User.status = EN_ATTENTE`.
- `studentSelf` fourni si `role` in `ETUDIANT|PARTICULIER` -> crée un `Student` avec `userId` = l'utilisateur créé.
- Réponse : `{ "data": User }` (voir schéma `User` ci-dessous).

### GET /auth/me
Réponse : `{ "data": User & { teacherProfile?, students?: Student[] } }`.

### POST /auth/fcm-token
Body : `{ "token": "string" }` — enregistre le token FCM courant sur `User.fcmToken`.

`User` :
```json
{
  "id": "uuid", "firebaseUid": "string", "email": "string", "telephone": "string",
  "nom": "string", "prenom": "string", "role": "Role", "status": "UserStatus",
  "ville": "string", "photoUrl": "string|null", "createdAt": "ISO datetime"
}
```

---

## /users (ADMIN uniquement)
- `GET /users?role=&status=&q=` — liste + filtres, pagination `?page=&pageSize=`.
- `PATCH /users/:id/status` body `{ "status": "UserStatus" }` — activer/suspendre/désactiver.

## /teachers
- `GET /teachers/me` (PROFESSEUR) — profil + candidature.
- `PATCH /teachers/me` (PROFESSEUR) body `{ specialites?, bio?, disponibilites?, zoneGeo? }`.
- `GET /teachers?statutCandidature=&specialite=&ville=` (ADMIN) — liste pour validation/attribution.
- `PATCH /teachers/:id/candidature` (ADMIN) body `{ "statutCandidature": "VALIDEE|REFUSEE|ENTRETIEN" }` — si `VALIDEE`, passe aussi `User.status = ACTIF`.

`TeacherProfile` :
```json
{
  "id": "uuid", "userId": "uuid", "specialites": ["string"], "diplomesUrls": ["string"],
  "bio": "string", "zoneGeo": "string", "disponibilites": { "lundi": ["18:00-20:00"], "...": [] },
  "statutCandidature": "StatutCandidature", "noteMoyenne": 4.5, "nombreAvis": 12,
  "user": { "nom": "string", "prenom": "string", "ville": "string", "photoUrl": "string|null" }
}
```

## /students
- `GET /students/mine` (PARENT: enfants ; ETUDIANT/PARTICULIER: soi-même en tant que Student).
- `POST /students` (PARENT) body `{ nom, prenom, dateNaissance, niveau, programme }` — crée un enfant lié.
- `PATCH /students/:id`, `DELETE /students/:id` (propriétaire ou ADMIN).

`Student` :
```json
{
  "id": "uuid", "nom": "string", "prenom": "string", "dateNaissance": "ISO date",
  "niveau": "Niveau", "programme": "Programme", "parentId": "uuid|null", "userId": "uuid|null"
}
```

## /demandes (processus de réservation)
- `POST /demandes` (PARENT/ETUDIANT/PARTICULIER) body `{ studentId, matiere, modePref, notes? }` -> `status = NOUVELLE`.
- `GET /demandes/mine` — demandes de l'utilisateur courant (via ses students).
- `GET /demandes?status=` (ADMIN) — file d'attente à traiter.
- `GET /demandes/mine` — comportement selon le rôle de l'appelant : pour PARENT/ETUDIANT/PARTICULIER, les demandes de ses students ; pour PROFESSEUR, les demandes où il est `professeurId` (donc `PROF_PROPOSE`, `CONFIRMEE`, `EN_COURS`...) — c'est le seul moyen pour un prof de découvrir une demande qui lui est proposée avant de la confirmer.
- `PATCH /demandes/:id/assigner` (ADMIN) body `{ "professeurId": "uuid" }` -> `status = PROF_PROPOSE`.
- `PATCH /demandes/:id/confirmer` (PROFESSEUR assigné) -> `status = CONFIRMEE`, crée la première `Seance`.
- `PATCH /demandes/:id/annuler` (propriétaire ou ADMIN) -> `status = ANNULEE`.

`Demande` :
```json
{
  "id": "uuid", "studentId": "uuid", "matiere": "string", "modePref": "ModePref",
  "status": "DemandeStatus", "professeurId": "uuid|null", "createdAt": "ISO datetime"
}
```

## /seances + /cahier-texte
- `GET /seances/mine` (PROFESSEUR: ses séances ; PARENT/ETUDIANT/PARTICULIER: séances de leurs students).
- `POST /seances` (PROFESSEUR ou ADMIN) body `{ demandeId, dateSeance }`.
- `PATCH /seances/:id/statut` body `{ "statut": "EFFECTUEE|ANNULEE" }`.
- `PUT /seances/:id/cahier-texte` (PROFESSEUR assigné à la séance) body
  `{ "contenu": "string", "exercices": "string", "devoirs": "string", "observations": "string" }`
  — upsert (un seul cahier de texte par séance).
- `GET /seances/:id/cahier-texte` (PROFESSEUR concerné, PARENT du student, ADMIN).

`CahierDeTexte` :
```json
{ "id": "uuid", "seanceId": "uuid", "contenu": "string", "exercices": "string",
  "devoirs": "string", "observations": "string", "updatedAt": "ISO datetime" }
```

## /annonces
- `GET /annonces` (public) — uniquement `visibilite = PUBLIC`.
- `GET /annonces` (authentifié) — `PUBLIC` + `CONNECTES`.
- `POST /annonces`, `PATCH /annonces/:id`, `DELETE /annonces/:id` (ADMIN).

`Annonce` :
```json
{ "id": "uuid", "titre": "string", "contenu": "string", "type": "AnnonceType",
  "visibilite": "Visibilite", "imageUrl": "string|null", "datePublication": "ISO datetime" }
```

## /cours-pour-tous
- `GET /cours-pour-tous` (public/authentifié) — campagnes à venir.
- `POST /cours-pour-tous/:id/inscription` (utilisateur connecté) body `{ "studentId": "uuid" }`.
- `POST /cours-pour-tous`, `PATCH /cours-pour-tous/:id`, `DELETE /cours-pour-tous/:id` (ADMIN).

`CoursPourTous` :
```json
{ "id": "uuid", "titre": "string", "description": "string", "matiere": "string",
  "dateDebut": "ISO datetime", "dateFin": "ISO datetime", "tarif": 5000,
  "placesDisponibles": 30, "placesRestantes": 12 }
```

## /avis
- `POST /avis` (PARENT/ETUDIANT/PARTICULIER) body `{ "professeurId": "uuid", "note": 1-5, "commentaire": "string" }`.
- `GET /avis?professeurId=` — avis `VISIBLE` d'un prof (recalcule `noteMoyenne`/`nombreAvis`).
- `GET /avis` (sans `professeurId`, ADMIN uniquement) — file de modération : tous les avis
  (`VISIBLE` + `MASQUE`), `MASQUE` (en attente) en premier. Un avis est créé `MASQUE` par défaut ;
  `avisEnAttenteModeration` dans `/admin/stats` = `count(statut = MASQUE)`.
- `PATCH /avis/:id/statut` (ADMIN) body `{ "statut": "VISIBLE|MASQUE" }`.
- `DELETE /avis/:id` (ADMIN).

## /admin/stats (ADMIN)
```json
{
  "enseignantsValides": 0, "enseignantsEnAttente": 0, "famillesClientes": 0,
  "elevesInscrits": 0, "demandesEnCours": 0, "avisEnAttenteModeration": 0
}
```
(Chiffre d'affaires / taux de fidélisation : champs prévus mais calcul réel hors scope
tant que le paiement n'est pas défini — renvoyer 0 avec un TODO explicite dans le code.)
