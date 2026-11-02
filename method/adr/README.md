# Les ADR

Un ADR (architecture decision record) garde la raison d'un choix difficile à défaire, ou coûteux si on le défaisait par erreur : le format des fichiers, l'empreinte, le rangement, la confidentialité, qui décide. Il sert au lecteur futur, souvent un agent qui part de zéro et ne lit que les fichiers, quand il se demande pourquoi le dépôt fait ainsi.

Une décision sur les données n'est pas un ADR : c'est un claim decision (method/claims.md) si elle vaut pour toutes les enquêtes, une ligne de la section Choix du README de l'enquête sinon.

Ce guide suit la pratique courante des ADR, sauf sur deux points : qui demande un ADR, et ce qu'il devient quand la décision change. pratique-courante.md dit pourquoi.

## Quand en écrire un

Seulement quand un mainteneur le demande. Sinon, la raison d'une décision va dans la pull request, et dans la règle elle-même, en quelques mots, quand l'agent qui applique la règle en a besoin. Par exemple, evidence.md dit d'un document en texte : « le contrôle le lit, et un agent y cherche plus facilement ».

## Lire un ADR

Un ADR est une raison à peser, jamais un motif de refus. Quand un changement défait un ADR, l'agent cite la raison de l'ADR dans la pull request et demande si elle tient encore. Les mainteneurs décident.

## Comment l'écrire

- Un seul dossier, method/adr/. Nom : `NNNN-titre-court.md`, avec le numéro qui suit le plus haut jamais pris. Un numéro ne sert qu'une fois, même après la suppression de son ADR : un lien dans l'historique git mène toujours à la bonne décision.
- Première ligne : `# NNNN — Titre`. Puis la ligne Statut.
- Une décision par ADR, une page au plus.
- **Contexte :** les forces en jeu et ce qui les oppose, en faits.
- **Décision :** une ou deux phrases. La règle vit dans AGENTS.md, method/, les skills ou checks/ : l'ADR y renvoie.
- **Alternatives écartées :** celles qu'on a vraiment envisagées, chacune avec sa raison.
- **Conséquences :** aussi ce qu'on perd, par exemple ce que le contrôle ne vérifie plus.

## Statut

- Tant qu'aucun mainteneur n'a tranché : `Statut : proposé, AAAA-MM-JJ (qui l'a demandé, à quelle occasion).`
- Quand un mainteneur tranche, l'agent écrit avant la fusion : `Statut : accepté, AAAA-MM-JJ (qui a décidé, à quelle occasion).`

## Changer ou supprimer

Chaque ADR dit la décision en vigueur et se lit seul. Quand la décision change, la pull request qui change la règle change aussi l'ADR, en place, et ajoute au Statut la date et ce qui a changé. Quand la décision ne tient plus, ou que le choix est devenu facile à défaire, la pull request supprime l'ADR. L'historique git garde l'ancien texte : `git log --follow -- method/adr/<fichier>`.
