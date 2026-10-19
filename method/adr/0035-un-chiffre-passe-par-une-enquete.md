# 0035 — Un chiffre passe par une enquête ; sans rien à faire entrer, elle se ferme sans pull request

Statut : proposé, 2026-10-18 (Francesco, révision des skills ; séparé de 0034 le 2026-10-19). Modifie 0012 (fermer sans merge) et 0023 (sediment fait les deux tris à l'étape 5).

## Contexte

Depuis 0032, une enquête peut finir sans claim : sa réponse va dans le commentaire qui ferme l'issue. C'est le cas ordinaire d'une question qui ne demande qu'un chiffre de l'hôpital (method/claims.md, « Ce qui mérite un claim »). Mais sediment ouvrait toujours une pull request, et une enquête sans claim n'y faisait entrer que son README.

## Décision

Un chiffre de l'hôpital, même seul, passe par une enquête. Quand elle n'a rien à faire entrer ni à retirer de main, elle se ferme sans pull request. Les règles : .agents/skills/frame/SKILL.md (ce qui manque) et .agents/skills/sediment/SKILL.md (étapes 5 et 6).

## Raisons

- Un chiffre passe par une enquête parce que son issue rend la question visible à l'étape 1 de frame pour les autres, que la CI contrôle sa requête (privacy.md), et que le commentaire de fermeture garde la question, le cadrage et la réponse. Sans claim, une pull request ne ferait entrer qu'un README.

## Alternatives écartées

- Un relay sans enquête pour un seul chiffre, la requête contrôlée sur le poste et le chiffre donné dans la conversation : plus rapide, mais rien ne garde la question pour les autres, ni la trace d'un chiffre faux.
- Une enquête de chiffre fermée par une pull request : elle fait entrer un README sans claim, et chaque chiffre attend un mainteneur.

## Conséquences

- Un chiffre coûte une issue, une branche, une requête et sa preuve, puis la fermeture ; une routine, une pull request.
- Une enquête fermée sans claim perd son README, ses choix, ses requêtes et ses preuves : seule son issue reste, et l'étape 1 de frame cherche aussi les issues fermées.
