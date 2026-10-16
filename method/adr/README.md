# Les ADR

Un ADR (architecture decision record) garde la raison d'une décision sur une règle du dépôt, pour le lecteur futur : celui qui se demandera pourquoi la règle existe, souvent un agent qui part de zéro et ne lit que les fichiers. La pull request fusionnée garde déjà qui a décidé, quoi et quand (AGENTS.md, règles 7 et 8). Une décision sur les données n'est pas un ADR : un claim decision (method/claims.md) si elle vaut pour toutes les enquêtes, une ligne de la section Choix du README de l'enquête sinon (0010).

Ce guide suit la pratique courante des ADR, dont les sources sont dans 0028. Là où il l'adapte au dépôt, il dit pourquoi (AGENTS.md, principe industry-practice).

## Quand en écrire un

Une décision reçoit un ADR quand elle compte et qu'elle tranche (0028) :

1. **Elle compte :** elle change ce sur quoi d'autres s'appuient (un format, le rangement, une garantie du contrôle, une étape que suit chaque session), ou elle coûterait cher à défaire.
2. **Elle tranche :** une autre option sérieuse existait, et sans la raison, un lecteur pourrait rouvrir la question ou défaire la règle.

Un renommage, une reformulation, une correction ou une précision ne tranche rien : sa raison va dans la pull request. Adaptation au dépôt, parce que l'agent suivant ne lit que les fichiers : quand l'agent qui applique la règle a besoin de la raison, la règle elle-même la dit en quelques mots. Par exemple, evidence.md dit d'un document en texte : « le contrôle le lit, et un agent y cherche plus facilement ». Dans le doute, l'agent pose la question au mainteneur dans la pull request.

## Comment l'écrire

- Un seul dossier, method/adr/, pour tout le dépôt. Nom : `NNNN-titre-court.md`, avec le numéro qui suit le plus haut du dossier.
- Première ligne : `# NNNN — Titre`. Puis la ligne Statut (plus bas).
- Une décision par ADR, une page au plus.
- **Contexte :** les forces en jeu et ce qui les oppose, en faits. Il répond au lecteur futur, qui veut savoir ce qui tirait dans des sens opposés.
- **Décision :** une ou deux phrases. Les règles vivent dans method/, les skills ou checks/ : l'ADR y renvoie.
- **Raisons :** seulement quand le contexte ne les dit pas déjà.
- **Alternatives écartées :** celles qu'on a vraiment envisagées, ou qu'un lecteur proposerait, chacune avec sa raison. Quand l'ADR s'écarte de la pratique courante, elle en fait partie.
- **Conséquences :** aussi ce qu'on perd, par exemple ce que le contrôle ne vérifie plus.
- **Sources :** les liens vers la pratique courante que l'ADR suit ou dont il s'écarte.

## Statut

- Tant que le mainteneur n'a pas tranché : `Statut : proposé, AAAA-MM-JJ (qui propose, à quelle occasion).` On corrige alors l'ADR librement.
- Quand il tranche, sur une carte, dans le fil ou dans la pull request, l'agent écrit avant la fusion : `Statut : accepté, AAAA-MM-JJ (qui a décidé, à quelle occasion).` Un fichier ne change pas seul à la fusion : le mainteneur fusionne seulement un ADR accepté.
- Après la fusion, seul le Statut change. Une décision qui en change une autre reçoit son propre ADR ; son Statut dit ce qu'elle modifie, et celui de l'ancien dit ce qui le modifie (« Modifié par 0008 : … »).
