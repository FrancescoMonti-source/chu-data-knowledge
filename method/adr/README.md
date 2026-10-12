# Les ADR

Un ADR (architecture decision record) garde la raison d'une règle du dépôt. Une décision du mainteneur sur une règle en reçoit un (AGENTS.md, règle 7). Une décision sur les données n'est pas un ADR : un claim decision (method/claims.md) si elle vaut pour toutes les enquêtes, une ligne de la section Choix du README de l'enquête sinon (0010).

- Un seul dossier, method/adr/, pour tout le dépôt. Nom : `NNNN-titre-court.md`, avec le numéro qui suit le plus haut du dossier.
- Première ligne : `# NNNN — Titre`. Puis : `Statut : accepté, AAAA-MM-JJ (qui a décidé, à quelle occasion).`
- Puis les sections qui servent : Contexte, Décision, Conséquences ; Raisons ou Alternatives quand un autre choix était possible.
- Une décision qui en change une autre reçoit son propre ADR. L'ancien garde son texte ; son Statut dit ce qui le modifie (« La retro est modifiée par 0008 »).
