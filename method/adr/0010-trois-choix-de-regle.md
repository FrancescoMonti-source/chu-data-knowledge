# 0010 — Promotion, décisions de méthode, maturité dérivée

Statut : accepté, 2026-10-11 (Francesco, les trois choix laissés ouverts par la relecture à froid, docs/adr/0009). Modifié par 0018 : plus de promotion, et un claim decision va dans knowledge/claims/ comme les autres.

## Contexte

La relecture à froid a trouvé trois règles qu'un agent ne pouvait pas suivre sans tomber sur un ROUGE ou sans choisir seul :

- La réponse d'une enquête ne cite que des prémisses (supported_by: []). Promue dans systems/ ou domains/, elle devait avoir une preuve propre : la promotion échouait au contrôle.
- Une décision propre à une enquête devait être un claim d'enquête, qui demande une preuve ; et la section Choix du README n'était écrite par aucune étape.
- La maturité d'un claim sans preuve propre ne devait pas dépasser celle de sa prémisse la moins mûre, sans ordre écrit entre documented et observed.

## Décision

- **Promotion :** un claim de systems/ ou domains/ peut ne citer que des prémisses. Promu, il garde son id, son contenu et sa forme ; ses prémisses sont déjà dans systems/ ou domains/, avec leurs preuves.
- **Décisions de méthode :** une décision propre à une enquête n'est pas un claim. C'est une ligne de la section Choix du README, avec sa raison, écrite quand elle est prise. Un claim decision vaut pour toutes les enquêtes et va dans domains/.
- **Maturité dérivée :** documented et observed disent ce qui appuie un claim, pas à quel point il est sûr. Seul provisional est plus faible. Sans preuve propre, un claim est provisional si une prémisse l'est ; sinon observed s'il est empirical et qu'une prémisse au moins est observed ; sinon documented. provisional reste toujours permis. Le contrôle vérifie cette règle (ROUGE).

## Conséquences

- La promotion n'ajoute aucune preuve : le fichier change seulement de dossier.
- La raison d'un « Plan revu » va aussi dans Choix : l'issue finit fermée, le README reste.
- Un claim sans preuve propre ne peut plus se dire observed sur des prémisses toutes documented.
