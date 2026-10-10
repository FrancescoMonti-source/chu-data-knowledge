# 0001 — Les six révisions après la v0.4

Statut : accepté, 2026-10-10 (séance de questions après la v0.4, résumée dans SPEC.md sur la branche codex/initial-implementation).

## Contexte

Après la v0.4, une séance de questions a modifié l'architecture. SPEC.md la résume en six révisions acceptées.

## Décision

| Révision | Dans ce dépôt |
|---|---|
| 1. Une relecture vaut pour une version précise. | Empreinte du contenu (0003). |
| 2. Trois sortes de claims : documentaire, empirique, décision. refuted_if seulement pour les empiriques. | Champ kind ; decision ajoute responsible et reconsider_when (docs/agents/claims.md). |
| 3. L'autorité est dans la source ou la preuve, pas dans le claim. | authority dans la fiche de la source ; un claim avec authority est ROUGE. |
| 4. Un filtre avant tout enregistrement, et une procédure minimale d'incident. | docs/agents/privacy.md. Le contrôle cherche des valeurs, pas des libellés (Francesco, 2026-10-10). |
| 5. Des contrôles sur des propriétés définies ; des frictions légères. | Pas d'arrêt après deux échecs ; pas de contrôle des mots « non vérifié » ; debrief d'une ligne, remplacé par la retro en fin de session (0008). |
| 6. Organisation et procédures modifiables ; l'usage peut commencer sans nouveau pilote. | Une règle change par un ADR ; la première vraie enquête peut être le premier usage. |

## Conséquences

La v0.4 reste la base (0000) ; ces révisions la précisent.
