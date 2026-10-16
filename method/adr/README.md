# Les ADR

Un ADR (architecture decision record) garde la raison d'une décision sur une règle du dépôt, pour le lecteur futur : celui qui se demandera pourquoi la règle existe, souvent un agent qui part de zéro et ne lit que les fichiers. La pull request fusionnée garde déjà qui a décidé, quoi et quand (AGENTS.md, règles 7 et 8). Une décision sur les données n'est pas un ADR : un claim decision (method/claims.md) si elle vaut pour toutes les enquêtes, une ligne de la section Choix du README de l'enquête sinon (0010).

## Quand en écrire un

Une décision reçoit un ADR quand elle compte et qu'elle tranche (0028) :

1. **Elle compte :** elle change ce sur quoi d'autres s'appuient (un format, le rangement, une garantie du contrôle, une étape que suit chaque session), ou elle coûterait cher à défaire.
2. **Elle tranche :** une autre option sérieuse existait, et sans la raison, un lecteur pourrait rouvrir la question ou défaire la règle.

Un renommage, une reformulation, une correction ou une précision ne tranche rien. Sa raison va dans la pull request. Quand l'agent qui applique la règle a besoin de la raison, la règle elle-même la dit en quelques mots, comme evidence.md pour un document en texte : « le contrôle le lit, et un agent y cherche plus facilement ». Dans le doute, l'agent pose la question au mainteneur dans la pull request.

## Comment l'écrire

- Un seul dossier, method/adr/, pour tout le dépôt. Nom : `NNNN-titre-court.md`, avec le numéro qui suit le plus haut du dossier.
- Première ligne : `# NNNN — Titre`. Puis la ligne Statut (plus bas).
- Une décision par ADR, une page au plus.
- **Contexte :** les forces en jeu et ce qui les oppose, en faits. Il répond au lecteur futur, qui veut savoir ce qui tirait dans des sens opposés.
- **Décision :** une ou deux phrases. Les règles vivent dans method/, les skills ou checks/ : l'ADR y renvoie.
- **Raisons :** seulement quand le contexte ne les dit pas déjà.
- **Alternatives écartées :** celles qu'on a vraiment envisagées, ou qu'un lecteur proposerait, chacune avec sa raison.
- **Conséquences :** aussi ce qu'on perd, par exemple ce que le contrôle ne vérifie plus.

## Statut

- Tant que le mainteneur n'a pas tranché : `Statut : proposé, AAAA-MM-JJ (qui propose, à quelle occasion).` On corrige alors l'ADR librement.
- Quand il tranche, sur une carte, dans le fil ou dans la pull request, l'agent écrit avant la fusion : `Statut : accepté, AAAA-MM-JJ (qui a décidé, à quelle occasion).` Le mainteneur fusionne seulement un ADR accepté.
- Après la fusion, seul le Statut change. Une décision qui en change une autre reçoit son propre ADR ; son Statut dit ce qu'elle modifie, et celui de l'ancien dit ce qui le modifie (« Modifié par 0008 : … »).
