# Les ADR

Un ADR (architecture decision record) garde la raison d'une décision sur une règle du dépôt, pour le lecteur futur (S1, S28) : celui qui se demandera pourquoi la règle existe, souvent un agent qui part de zéro et ne lit que les fichiers. Une décision sur les données n'est pas un ADR : un claim decision (method/claims.md) si elle vaut pour toutes les enquêtes, une ligne de la section Choix du README de l'enquête sinon (0010).

Ce guide suit la pratique courante des ADR (0028). Une ligne tirée de la pratique cite ses sources, comme (S1) ; leurs citations sont dans pratique-courante.md. Avant de changer une ligne, relire ses sources ; une ligne qui s'en écarte dit pourquoi.

## Quand en écrire un

Une décision reçoit un ADR quand elle compte et qu'elle tranche (0028) :

1. **Elle compte :** elle change ce sur quoi d'autres s'appuient (un format, le rangement, une garantie du contrôle, une étape que suit chaque session), ou elle coûterait cher à défaire (S1, S12, S15, S21).
2. **Elle tranche :** une autre option sérieuse existait, et sans la raison, un lecteur pourrait rouvrir la question ou défaire la règle (S16, S22, S23).

Un renommage ou une reformulation ne tranche rien (S21, S28, S31) : sa raison va dans la pull request. Adaptation au dépôt, sans source (pratique-courante.md, « Ce que les sources ne disent pas »), parce que l'agent suivant ne lit que les fichiers : quand l'agent qui applique la règle a besoin de la raison, la règle elle-même la dit en quelques mots. Par exemple, evidence.md dit d'un document en texte : « le contrôle le lit, et un agent y cherche plus facilement ». Dans le doute, l'agent pose la question aux mainteneurs dans la pull request.

## Comment l'écrire

- Un seul dossier, method/adr/, pour tout le dépôt. Nom : `NNNN-titre-court.md`, avec le numéro qui suit le plus haut du dossier (S1, S6).
- Première ligne : `# NNNN — Titre`. Puis la ligne Statut (plus bas).
- Une décision par ADR, une page au plus (S1, S9).
- **Contexte :** les forces en jeu et ce qui les oppose, en faits, pour le lecteur futur (S1).
- **Décision :** une ou deux phrases. Les règles vivent dans AGENTS.md, method/, les skills ou checks/ : l'ADR y renvoie (S12, S15, S24, S30).
- **Raisons :** seulement quand le contexte ne les dit pas déjà.
- **Alternatives écartées :** celles qu'on a vraiment envisagées, chacune avec sa raison (S9, S24).
- **Conséquences :** aussi ce qu'on perd, par exemple ce que le contrôle ne vérifie plus (S1, S24).

## Statut

- Tant qu'aucun mainteneur n'a tranché : `Statut : proposé, AAAA-MM-JJ (qui propose, à quelle occasion).` On corrige alors l'ADR librement (S1, S19).
- Quand un mainteneur tranche, l'agent écrit avant la fusion : `Statut : accepté, AAAA-MM-JJ (qui a décidé, à quelle occasion).` Un fichier ne change pas seul à la fusion : un mainteneur ne fusionne qu'un ADR accepté.
- Après la fusion, seul le Statut change (S12, S15). Une décision qui en change une autre reçoit son propre ADR ; son Statut dit ce qu'elle modifie, et celui de l'ancien dit ce qui le modifie, comme « Modifié par 0008 : … » (S1).
