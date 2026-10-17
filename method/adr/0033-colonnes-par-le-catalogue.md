# 0033 — Connaître les colonnes par le catalogue, sans SELECT *

Statut : proposé, 2026-10-17 (relecture à froid d'octobre, PR #62 ; repris seul après le découpage de cette PR). Modifie 0009 (exception WHERE 1=0).

## Contexte

La règle 2 de method/queries.md faisait connaître les colonnes d'une table par `SELECT * … WHERE 1=0`, le seul SELECT * admis. check.py portait un cas particulier pour elle : un seul SELECT, avec WHERE 1=0 (0009).

Aucune requête de knowledge/queries/ n'a suivi ce chemin. Quand une enquête a eu besoin des colonnes, l'agent a interrogé le catalogue Oracle (ALL_TABLES, ALL_TAB_COLUMNS) en no-person-data : 20261014-chercher-structure-schemas pour #24, 20261015-colonnes-hist-diag-synth-rss pour l'enquête revalorisation-chir-m8. Le catalogue répond aussi quand on ne connaît pas encore le nom de la table, et il donne le type et la taille de chaque colonne ; la réponse de WHERE 1=0 ne montre que les noms, pour une table déjà connue, et sans aucune ligne : elle ne peut pas montrer l'id de la requête (règle 5).

## Décision

Les tables et les colonnes que ni les claims ni sources/ ne donnent se cherchent dans le catalogue de la base, par une requête no-person-data. SELECT * est interdit sans exception, et toute requête, masked ou non, affiche son id dans la première colonne (method/queries.md, règles 2 et 5).

## Alternatives écartées

- **Garder WHERE 1=0 à côté du catalogue :** deux chemins pour la même chose, et un cas particulier du contrôle qu'aucune requête n'utilise.

## Conséquences

- Le contrôle refuse tout SELECT * et demande l'id dans toute requête. Les cinq requêtes no-person-data du dépôt l'affichent déjà.
- La réponse du catalogue a des lignes : relay (étape 5), le filtre de method/privacy.md et la règle 2 d'AGENTS.md ne demandent des agrégats que pour un résultat sur des personnes, comme queries.md le faisait déjà.
- Ce qu'on perd : si le compte de la personne ne peut pas lire le catalogue, la méthode n'offre plus d'autre requête pour connaître les colonnes ; l'agent les demande à la personne.
