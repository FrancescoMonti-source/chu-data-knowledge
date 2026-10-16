# 0029 — Suivre la pratique courante

Statut : proposé, 2026-10-16 (Claude, à la demande de Francesco, enquête revalorisation-chir-m8).

## Contexte

Les règles du dépôt sont écrites par des agents et décidées par le mainteneur. Un agent propose volontiers une solution neuve et bien argumentée, et le mainteneur ne peut pas vérifier chaque fois qu'elle ne réinvente pas un usage connu. La règle des ADR s'écartait ainsi de la pratique courante, sans raison écrite (0028).

Une pratique courante a été éprouvée par beaucoup d'équipes, et ses défauts sont décrits. Mais ses sources divergent parfois, et elle ne prévoit pas toujours ce qui est propre au dépôt : des agents qui écrivent et appliquent ses règles, des données de patients qui restent à l'hôpital.

## Décision

Une règle du dépôt qui compte suit la pratique courante, quand elle existe, d'après ses sources primaires. S'en écarter, ou choisir entre des sources qui divergent, tranche : l'ADR dit pourquoi. C'est le principe industry-practice d'AGENTS.md.

## Alternatives écartées

- **Décider chaque règle d'après les seuls besoins du dépôt :** on refait des erreurs que d'autres ont déjà corrigées.
- **Chercher la pratique courante avant tout changement de règle :** pour une correction ou une reformulation, la recherche coûte plus qu'elle ne rapporte.

## Conséquences

- Proposer une règle qui compte prend plus de temps : l'agent cherche d'abord la pratique courante.
- Un fait sur les données n'est pas une règle : il reste un claim, avec ses preuves.

## Sources

- Gouvernement britannique, Service Standard, point 13, « Use and contribute to open standards, common components and patterns » : https://www.gov.uk/service-manual/service-standard/point-13-use-common-standards-components-patterns
