# Où va quoi

Le type d'un fichier décide de son dossier, quel que soit son sujet.

| Dossier | Un fichier par… | Format |
|---|---|---|
| sources/ | document : sa fiche, et le texte d'un document hors ligne | evidence.md, « Sources » |
| knowledge/claims/ | claim | claims.md |
| knowledge/evidence/ | preuve : une lecture ou une exécution | evidence.md |
| knowledge/queries/ | requête préparée pour l'hôpital (.sql) | queries.md |
| knowledge/glossaries/ | contexte : son glossaire ; README.md est la carte des contextes | « Termes et glossaires », plus bas |
| investigations/<id>/ | enquête : son README.md, seul | investigations/README.md |

Un document lu dix fois donne une fiche dans sources/ et dix preuves dans knowledge/evidence/.

Le sujet s'écrit dans le fichier : les terms d'un claim (pmsi:rum), ses tables (cora:TB_MVT_RUM), le system d'une requête. Un pont entre deux contextes est un claim de knowledge/claims/, comme les autres. La réponse d'une enquête aussi : le README de l'enquête la cite dans Conclusions.

Le reste du dépôt dit comment on travaille : AGENTS.md, les conventions (method/), leurs raisons (method/adr/), les étapes (.agents/skills/), les contrôles (checks/). Un fait vaut par ses preuves, une règle du dépôt par la décision du mainteneur : ce qu'on découvre sur les données du CHU, même un piège de jointure, devient un claim avec ses preuves.

## Ids et noms de fichiers

- Le nom du fichier, sans extension, est l'id, unique dans tout le dépôt : minuscules, chiffres et tirets (mvt-rum-lien).
- Preuves et requêtes commencent par la date : 20261008-mvt-rum. Deux agents en parallèle ne choisissent pas le même nom.
- L'id d'une source finit par son édition : dictionnaire-cora-2020.
- On garde les mots de la source : mvt-rum, pas movement-rum.

## Termes et glossaires

- Un terme s'écrit avec son contexte : pmsi:rum. Il est défini dans le glossaire de ce contexte, et seulement là : knowledge/glossaries/pmsi.md, sous un titre `## pmsi:rum`, puis la définition en français.
- La carte, knowledge/glossaries/README.md, liste les contextes : chacun avec sa sorte, système ou domaine, et son glossaire.
- Un claim cite au moins un terme. Un terme entre dans son glossaire avec le premier claim qui le cite.
- La définition d'un terme fait partie du sens des claims qui le citent : la changer périme leur relecture (review.md).
- Un glossaire définit des mots. Ce qui est vrai d'un système (une jointure, un piège) est un claim, avec ses preuves.
- Le savoir propre au CHU, une convention ou une façon de compter, est un claim comme les autres.
- Un nouveau contexte naît avec le premier fichier qui en a besoin, requête ou claim : son glossaire, et sa ligne dans la carte.
- **PMSI par édition.** Le domaine pmsi suit les textes réglementaires et les guides de l'ATIH, dans leur champ et leur période d'application. Chaque édition remplace la précédente : l'id de la fiche porte l'année.

## Retrouver ce qu'on sait

Pas d'index : on cherche dans knowledge/claims/. Dans tout le dépôt, les fichiers de sources/ noient la recherche.

```text
git grep -n "cora:mouvement" -- knowledge/claims/
```

- **Termes et tables :** chercher le terme (cora:mouvement) ou la table (cora:TB_MVT_RUM).
- **Liens :** d'un claim, ses preuves (supported_by) et ses prémisses (depends_on). Pour savoir qui dépend d'un claim, chercher son id.
- **Enquêtes passées :** la première ligne de chaque investigations/<id>/README.md est la question.

Un index viendra seulement si cette recherche ne suffit plus.
