# L'Excellent Prof — Backend

API Node.js + Express + TypeScript + Prisma pour la plateforme de mise en relation profs/eleves
au Mali. Implemente le contrat decrit dans `API_CONTRACT.md` (a la racine du depot).

## Stack

- Node.js + Express + TypeScript
- Prisma ORM + PostgreSQL (Neon en production)
- Authentification : Firebase Admin SDK (verification d'ID token cote serveur)
- Validation des payloads : Zod

## Structure du projet

```
backend/
  prisma/
    schema.prisma      # Tous les modeles + enums du contrat
    seed.ts             # Donnees de demo (annonces + cours pour tous)
  src/
    config/             # env, client Prisma singleton, init Firebase Admin
    middleware/          # auth (verifyFirebaseToken, requireRole), errorHandler
    modules/             # un dossier par domaine : routes + controller + service
    index.ts             # bootstrap Express
  render.yaml            # Blueprint de deploiement Render
  .env.example           # Variables d'environnement documentees
```

Dans chaque module, les `controller.ts` ne font que parser/valider le payload (Zod) et appeler
le `service.ts` correspondant ; toute la logique metier (transitions de statut, verifications
de propriete, recalculs, etc.) vit dans les services.

---

## 1. Creer une base Neon et recuperer `DATABASE_URL`

1. Aller sur https://neon.tech et creer un compte (gratuit).
2. Cliquer sur **New Project**, choisir une region proche (ex: Europe) et un nom de projet
   (ex: `excellent-prof`).
3. Neon cree automatiquement une base `neondb` et une "Connection string". Dans le dashboard du
   projet, section **Connection Details**, copier la chaine au format :
   ```
   postgresql://<user>:<password>@<host>/<database>?sslmode=require
   ```
4. Coller cette valeur dans la variable d'environnement `DATABASE_URL` (fichier `.env` en local,
   ou variable d'environnement Render en production). Le `?sslmode=require` est indispensable
   avec Neon.

## 2. Generer les credentials Firebase Admin (service account)

1. Ouvrir la [Console Firebase](https://console.firebase.google.com/), selectionner (ou creer)
   le projet utilise par l'application Flutter.
2. **Parametres du projet** (icone engrenage) → **Comptes de service** → onglet
   **Firebase Admin SDK** → bouton **Generer une nouvelle cle privee**. Un fichier JSON est
   telecharge (ex: `nom-du-projet-firebase-adminsdk-xxxx.json`). Ce fichier ne doit **jamais**
   etre commite dans le depot.
3. Deux facons de le fournir au backend (voir aussi les commentaires dans
   `src/config/firebaseAdmin.ts`) :

   **Option A (recommandee, surtout sur Render)** — tout le JSON encode en base64 sur une seule
   ligne, dans la variable `FIREBASE_SERVICE_ACCOUNT_JSON` :
   ```powershell
   # PowerShell
   [Convert]::ToBase64String([IO.File]::ReadAllBytes("chemin\vers\service-account.json"))
   ```
   ```bash
   # Linux / macOS
   base64 -w0 service-account.json
   ```
   Copier le resultat (une longue chaine sans retour a la ligne) dans
   `FIREBASE_SERVICE_ACCOUNT_JSON`.

   **Option B** — variables separees `FIREBASE_PROJECT_ID`, `FIREBASE_CLIENT_EMAIL`,
   `FIREBASE_PRIVATE_KEY` (valeurs prises directement dans le JSON telecharge). Dans un fichier
   `.env` classique, remplacer les retours a la ligne de la cle privee par des `\n` litteraux
   (le code les reconvertit automatiquement) — voir l'exemple dans `.env.example`.

4. Le SDK Firebase Admin n'est initialise qu'a la premiere requete authentifiee (lazy init) :
   `npm run build` / `npx tsc --noEmit` / `npx prisma validate` fonctionnent donc sans qu'aucune
   credential reelle ne soit renseignee.

## 3. Installer les dependances et configurer l'environnement local

```powershell
cd backend
npm install
Copy-Item .env.example .env
# Editer .env : renseigner au minimum DATABASE_URL une fois la base Neon creee (etape 1).
```

## 4. Appliquer le schema une fois `DATABASE_URL` renseigne

Une fois `DATABASE_URL` valide dans `.env` (base Neon reelle) :

```powershell
npx prisma migrate dev --name init
```

Cette commande cree les tables dans la base, genere le client Prisma, et garde un historique de
migrations dans `prisma/migrations/`. Elle necessite une vraie connexion reseau — ne pas la
lancer avant d'avoir une base valide.

Pour peupler la base avec quelques annonces et un cours pour tous de demonstration :

```powershell
npm run prisma:seed
```

Pour regenerer uniquement le client Prisma (sans toucher au schema de la base), par exemple
apres un `git pull` :

```powershell
npm run prisma:generate
```

## 5. Lancer le serveur en local

```powershell
npm run dev
```

Le serveur ecoute sur `http://localhost:4000` (`PORT` dans `.env`). Toutes les routes sont
montees sous `/api` (ex: `http://localhost:4000/api/auth/register`). Un endpoint `GET /health`
est disponible hors `/api` pour un check de disponibilite basique.

## 6. Deployer sur Render a partir de `render.yaml`

1. Pousser ce depot (dossier `backend/`) sur GitHub/GitLab.
2. Sur [Render](https://render.com), **New** → **Blueprint**, puis selectionner le depot
   contenant `render.yaml`.
3. Render detecte le service web `excellent-prof-backend` defini dans `render.yaml` :
   - Build : `npm install && npm run build && npx prisma generate`
   - Start : `npm run start`
4. Render demande de renseigner les variables marquees `sync: false` (valeurs non stockees dans
   le fichier) :
   - `DATABASE_URL` → la chaine de connexion Neon (etape 1).
   - `FIREBASE_SERVICE_ACCOUNT_JSON` → le JSON du service account encode en base64 (etape 2,
     option A).
   - `CORS_ORIGIN` → domaine(s) autorises (ex: URL de l'app Flutter web, ou `*` en attendant).
   `NODE_ENV=production` et `PORT=4000` sont deja fixes dans le blueprint.
5. Avant le tout premier deploiement (ou apres tout changement de `prisma/schema.prisma`),
   lancer manuellement `npx prisma migrate deploy` (via le Shell Render, ou en local avec
   `DATABASE_URL` pointant vers la base de prod) pour appliquer les migrations — `prisma
   generate` seul (dans le build command) ne modifie pas le schema de la base.

---

## Notes d'implementation

- Toutes les reponses en succes suivent `{ "data": ... }` ; toutes les erreurs suivent
  `{ "error": { "code": string, "message": string } }` (voir
  `src/middleware/errorHandler.ts`).
- `src/middleware/auth.ts` expose `verifyFirebaseToken` (auth complete + resolution du `User`
  Prisma), `verifyFirebaseTokenOnly` (utilise uniquement par `POST /auth/register`, avant que le
  `User` n'existe cote backend) et `optionalAuth` (routes publiques enrichies si authentifie,
  ex: `GET /annonces`).
- `GET /admin/stats` calcule tous les compteurs via `prisma.count()` ; `chiffreAffaires` et
  `tauxFidelisation` renvoient `0` avec un commentaire `// TODO: a calculer une fois le module de
  paiement defini` dans `src/modules/admin/stats.service.ts`.
- Quelques choix d'implementation non explicitement decrits par `API_CONTRACT.md` sont
  documentes en commentaire directement dans le code source (ex: etat initial d'une `Seance`,
  file de moderation des `Avis`, body de `PATCH /demandes/:id/confirmer`) — voir le rapport de
  livraison pour la liste complete.
