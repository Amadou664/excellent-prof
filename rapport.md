# Rapport — Tout ce qui a été fait sur "L'Excellent Prof"

Ce fichier explique, en français très simple, tout ce qui a été construit sur ton
application depuis le début. C'est un résumé, pas tous les détails techniques.

## 3 septembre 2026 — Le début

- Création du projet : une application Flutter (l'app que voient les élèves et
  les professeurs) + un serveur (le "cerveau" qui gère les données, appelé
  backend).
- Mise en ligne des premières versions sur Render (le serveur) et connexion à
  la vraie base de données.
- Quelques réglages techniques pour que le serveur démarre correctement.

## 4-5 septembre 2026 — Les fonctions de base

- Ajout de l'envoi de fichiers, de la messagerie (chat), des notifications, et
  du suivi des paiements.
- Un professeur ou un élève peut modifier son propre profil.
- Ajout d'un système pour voir les diplômes envoyés par les professeurs.
- Ajout de la possibilité d'ajouter une photo aux annonces.
- Côté admin : liste des utilisateurs (avec pagination), export en fichier
  Excel/CSV, et une page détaillée pour chaque utilisateur.
- Ajout du vrai logo de l'application (icône, écran de démarrage) partout dans
  l'app.
- Ajout du changement de mot de passe et d'un centre de notifications.

## 7 septembre 2026 — Sécurité et règles

- Écriture d'un guide (README) qui explique comment maintenir le site.
- Renforcement de la sécurité : protection contre certaines attaques
  informatiques courantes sur le site web et sur l'envoi de fichiers.
- Mise en place d'un système qui redémarre automatiquement le serveur s'il
  plante, et qui vérifie que la base de données fonctionne bien.
- Ajout de la politique de confidentialité et des conditions d'utilisation
  (avec des règles pour protéger les enfants, vu que c'est du soutien scolaire
  à domicile).
- Un professeur doit maintenant envoyer une pièce d'identité pour être validé,
  et l'admin peut écrire des notes de vérification.
- Un utilisateur peut supprimer son compte, et peut signaler un autre
  utilisateur (avec alerte automatique à l'admin).
- Ajout de la vérification par email et de l'acceptation obligatoire des
  conditions d'utilisation.
- Ajout du paiement en ligne des demandes de cours via CinetPay (le service
  qui permet de payer par Mobile Money ou carte).

## 8 septembre 2026 — Paiements, surveillance, et assignation des profs

- Ajout d'un outil (Sentry) qui prévient automatiquement quand il y a une
  erreur sur le site, sans attendre qu'un utilisateur se plaigne.
- Nouvel écran admin "Paiements" : l'admin voit toutes les transactions.
- Ajout de tests automatiques sur le serveur, pour vérifier que les parties
  les plus sensibles (comme les paiements) fonctionnent bien avant chaque mise
  en ligne.
- Réglages pour que les paiements CinetPay soient plus fiables (moins de
  blocages, moins d'abus).
- Renforcement de la sécurité des en-têtes du site web.
- Les pièces d'identité des professeurs sont maintenant mieux protégées
  (seul l'admin peut les voir).
- Dans l'écran admin "Demandes de cours", le dialogue pour choisir un
  professeur montre maintenant en premier les professeurs qui enseignent déjà
  la matière demandée, avec leurs spécialités et leur ville affichées.

## 11 septembre 2026 — Aujourd'hui

- Amélioration du dialogue "Assigner un professeur" :
  - Ajout d'une barre de recherche (par nom, ville ou matière), utile quand il
    y a beaucoup de professeurs.
  - Affichage de la note du professeur (exemple : 4.5 / 5, 12 avis) pour
    aider à choisir.
- Le code a été vérifié (aucune erreur), envoyé sur GitHub, et l'application
  web + l'APK Android ont été reconstruits avec ce changement.
- Dernière étape : la mise en ligne finale sur le site (Firebase) doit être
  confirmée par toi directement, pour des raisons de sécurité.

---

*Ce rapport a été généré automatiquement. Si quelque chose n'est pas clair,
demande et je réexplique plus simplement.*
