# L'Excellent Prof

Plateforme de mise en relation profs particuliers / élèves au Mali.

- `app/` — application Flutter (Android, iOS, Web)
- `backend/` — API Node.js/Express/Prisma (voir `backend/README.md` pour l'installation locale)

## Liens en production

| Quoi | Lien |
|---|---|
| App web | https://excellent-prof.web.app |
| APK Android à télécharger | https://excellent-prof.web.app/downloads/excellent-prof-apk.bin |
| Backend (API) | https://excellent-prof-backend.onrender.com |
| Dépôt GitHub | https://github.com/Amadou664/excellent-prof |
| Dashboard Render (backend) | https://dashboard.render.com |
| Dashboard Neon (base de données) | https://console.neon.tech |
| Console Firebase | https://console.firebase.google.com/project/excellent-prof |

## Comment tout redéployer après une modification

**Backend** : il suffit de pousser sur GitHub (`git push`) — Render redéploie automatiquement.

**App (web)** :
```
cd app
flutter build web
firebase deploy --only hosting --project excellent-prof
```
⚠️ Le dossier `build/web` est entièrement régénéré à chaque `flutter build web` : si tu veux garder
le lien de téléchargement de l'APK fonctionnel, recopie-le après le build et avant le déploiement :
```
Copy-Item app\build\app\outputs\flutter-apk\app-release.apk app\build\web\downloads\excellent-prof-apk.bin -Force
```

**App (APK Android)** :
```
cd app
flutter build apk --release
```
Le fichier est dans `app/build/app/outputs/flutter-apk/app-release.apk`.

---

## Activer le paiement en ligne (CinetPay)

Le code du paiement en ligne est prêt, mais il ne fonctionnera pas tant que tu n'as pas créé ton
propre compte CinetPay (obligatoire : c'est ton compte, donc c'est toi qui reçois l'argent, pas
Claude). Sans ça, le bouton "Payer maintenant" affichera juste un message d'erreur clair — le
reste de l'app continue de fonctionner normalement.

**Étapes (à faire une seule fois) :**

1. Va sur https://cinetpay.com et clique sur "Créer un compte" (choisis "Mali" comme pays).
2. CinetPay va te demander des documents pour vérifier ton identité/entreprise (KYC) — c'est
   normal, tous les services de paiement font ça. Ça peut prendre quelques jours.
3. Une fois le compte validé, connecte-toi sur https://app.cinetpay.com et va dans
   **Paramètres → Cle API** pour récupérer ta clé (`apikey`) et ton identifiant de site
   (`site_id`).
4. Va sur https://dashboard.render.com → ton service backend → onglet **Environment**, et ajoute
   deux nouvelles variables :
   - `CINETPAY_API_KEY` = ta clé API
   - `CINETPAY_SITE_ID` = ton identifiant de site
5. Render redémarre automatiquement le service après l'ajout. Le paiement est alors actif.
6. Fais un premier test toi-même avec un petit montant avant d'annoncer la fonctionnalité aux
   utilisateurs.

Pour l'instant, la plateforme ne prend **aucune commission** (le professeur reçoit 100% du
montant fixé par l'admin) et le paiement se fait **avant** le premier cours. Si tu veux changer
ça plus tard (ajouter une commission, permettre de payer après la séance...), reviens en discuter
avec Claude — ce sont des décisions qui te reviennent.

---

## Garder le projet en bon état dans le temps

Ce projet a été construit avec l'aide de Claude (IA). C'est très utile pour avancer vite, mais
un logiciel — codé par une IA ou par un humain — a toujours besoin d'un minimum d'entretien
régulier pour continuer à fonctionner. Voici une routine simple, à faire **une fois par mois**
environ, même sans être un développeur expérimenté.

### Checklist mensuelle (15-20 minutes)

1. **Vérifier que tout est en ligne**
   - Ouvrir https://excellent-prof.web.app et essayer de se connecter.
   - Ouvrir https://excellent-prof-backend.onrender.com/health → doit répondre
     `{"data":{"status":"ok"}}`.

2. **Vérifier les quotas gratuits** (pour ne pas être bloqué sans prévenir)
   - Neon (https://console.neon.tech) → onglet du projet → vérifier le stockage utilisé
     (limite gratuite : 0,5 Go).
   - Render (https://dashboard.render.com) → vérifier qu'il n'y a pas d'alerte de dépassement.
   - Firebase (https://console.firebase.google.com) → onglet "Usage and billing".

3. **Mettre à jour les dépendances (sans tout casser)**
   - Un robot GitHub (Dependabot, configuré dans ce dépôt) propose automatiquement des mises à
     jour chaque semaine sous forme de "Pull Requests" sur GitHub. Il suffit d'aller regarder
     l'onglet **"Pull requests"** du dépôt de temps en temps.
   - Ne jamais accepter une mise à jour "à l'aveugle" : demande à Claude (ou à un développeur)
     de vérifier que ça ne casse rien avant de fusionner ("merge").

4. **Garder une sauvegarde**
   - Le code est déjà sauvegardé sur GitHub à chaque `git push` — c'est la sauvegarde la plus
     importante.
   - Pour la base de données : Neon garde un historique de quelques jours sur le plan gratuit.
     Si tu veux une vraie sauvegarde longue durée, demande un export régulier de la base.

### Signes qu'il faut agir (pas d'affolement, juste prévoir)

- L'app met plus de 30-60 secondes à répondre → normal sur le plan gratuit Render (le serveur
  "dort"), pas une panne. Passer au plan payant (~7 $/mois) supprime ce délai.
- Neon annonce que le stockage est presque plein → passer à un plan payant Neon avant que ça
  bloque les écritures.
- Une mise à jour de dépendance casse quelque chose → ne pas paniquer, `git revert` permet de
  revenir en arrière immédiatement.

### En cas de blocage

Reviens simplement dans cette conversation (ou une nouvelle) avec Claude Code, explique ce qui
ne marche plus, et partage le message d'erreur exact si tu en as un. La plupart des problèmes se
diagnostiquent en quelques minutes avec les bonnes informations.
