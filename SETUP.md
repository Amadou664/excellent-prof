# L'Excellent Prof — Guide de démarrage

Ce dépôt contient deux projets indépendants qui communiquent via le contrat décrit dans
[`API_CONTRACT.md`](API_CONTRACT.md) :

- [`backend/`](backend/) — API Node.js + Express + TypeScript + Prisma (base Neon, déploiement Render).
- [`app/`](app/) — application mobile Flutter (Android/iOS), 5 espaces : parent, professeur,
  étudiant, particulier, admin.

Les deux compilent et s'analysent sans erreur dès maintenant (`npx tsc --noEmit`,
`flutter analyze`), mais **rien n'est fonctionnel de bout en bout tant que les 3 comptes
externes ci-dessous n'ont pas été créés** — je ne peux pas les créer à ta place, ce sont
tes comptes.

## Ordre à suivre

1. **Firebase** — crée un projet sur console.firebase.google.com, active Authentication
   (email/mot de passe), Storage et Cloud Messaging. Détails complets dans
   [`app/README.md`](app/README.md#️-étape-obligatoire-avant-de-lancer-lapp--configurer-firebase).
   - Récupère aussi les credentials **Firebase Admin** (compte de service) pour le
     backend : section 2 de [`backend/README.md`](backend/README.md).
2. **Neon** — crée une base Postgres gratuite sur neon.tech et récupère `DATABASE_URL`.
   Section 1 de [`backend/README.md`](backend/README.md).
3. **Backend** : `cd backend`, suis le README (`npm install`, `.env`, `npx prisma migrate
   dev`, `npm run dev`). Vérifie que `http://localhost:4000/api/annonces` répond.
4. **App Flutter** : `cd app`, lance `flutterfire configure` (étape Firebase ci-dessus),
   vérifie `lib/core/constants.dart` pointe vers ton backend (`10.0.2.2` pour l'émulateur
   Android), puis `flutter pub get && flutter run`.
5. **Render** (quand tu veux mettre le backend en ligne) — section 6 de
   [`backend/README.md`](backend/README.md), à partir de `backend/render.yaml`.

## Ce qui a déjà été vérifié

- Backend : `npm install`, `npx prisma validate`, `npx tsc --noEmit` passent sans erreur
  (aucune connexion réseau réelle nécessaire pour ces vérifications).
- App : `flutter pub get` et `flutter analyze` passent sans erreur (0 issue).
- J'ai relu le code des deux projets et corrigé 3 problèmes trouvés en le confrontant à
  l'usage réel côté app :
  - `GET /demandes/mine` ne renvoyait jamais rien pour un PROFESSEUR (il n'a pas de
    `Student` à lui) — un prof n'avait donc aucun moyen de voir les demandes qui lui sont
    proposées avant de les confirmer. Corrigé : pour ce rôle, la route renvoie les
    demandes où il est `professeurId`.
  - `GET /avis` exigeait `professeurId` et ne renvoyait que les avis `VISIBLE` — l'admin
    n'avait aucun moyen de lister les avis en attente de modération. Corrigé :
    `professeurId` est optionnel, et un ADMIN sans ce paramètre reçoit tous les avis
    (`MASQUE` en attente en premier).
  - `PATCH /seances/:id/statut` vérifiait le rôle (PROFESSEUR/ADMIN) mais pas la
    propriété de la séance : n'importe quel professeur aurait pu modifier le statut de la
    séance d'un autre. Corrigé : un PROFESSEUR ne peut modifier que ses propres séances.

  Ces trois points sont maintenant documentés dans `API_CONTRACT.md` et le code compile
  toujours sans erreur après correction.

## Ce qui reste à faire ensuite (hors scaffold initial)

- Brancher réellement Firebase (étape 1 ci-dessus) et tester l'inscription des 4 profils
  de bout en bout.
- Décider du moyen de paiement (mentionné comme "à approfondir dans le Business Plan" par
  le cahier des charges) — `chiffreAffaires` et `tauxFidelisation` sont pour l'instant à
  `0` dans `/admin/stats` (voir `backend/src/modules/admin/stats.service.ts`).
- Câblage des envois de notifications push réels (le token FCM est déjà collecté et
  stocké, l'envoi effectif via Firebase Admin reste à écrire selon les déclencheurs métier
  que tu voudras — ex: "un prof vous a été assigné").
- Identité visuelle définitive (le thème actuel reprend juste vert foncé + doré du logo
  fourni ; à affiner avec de vrais assets si tu as une charte graphique plus précise).
