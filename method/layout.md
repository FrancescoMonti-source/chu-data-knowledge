# Où va la connaissance

Le type d'un fichier décide de son dossier, quel que soit son sujet.

| Dossier | Un fichier par… | Format |
|---|---|---|
| sources/ | document : sa fiche, et le texte d'un document hors ligne | evidence.md, « Sources » |
| knowledge/claims/ | claim | claims.md |
| knowledge/evidence/ | preuve : une lecture ou une exécution | evidence.md |
| knowledge/queries/ | requête préparée pour l'hôpital (.sql, ou .R ou .py pour un fichier) | queries.md |
| knowledge/routines/<id>/ | routine : son code et son README.md | queries.md, « Une routine » |
| knowledge/glossaries/ | contexte : son glossaire ; README.md est la carte des contextes | « Termes et glossaires », plus bas |
| investigations/<id>/ | enquête : son README.md, seul | investigations/README.md |

Un document lu dix fois donne une fiche dans sources/ et dix preuves dans knowledge/evidence/.

Le sujet s'écrit dans le fichier : les terms d'un claim (pmsi:rum), ses tables (cora:TB_MVT_RUM), le system d'une requête. Un pont entre deux contextes est un claim de knowledge/claims/, comme les autres.

Le reste du dépôt dit comment on travaille : AGENTS.md, les conventions (method/), les raisons des choix difficiles à défaire (method/adr/), les skills (.agents/skills/), les contrôles (checks/). Un fait vaut par ses preuves, une règle du dépôt par la décision d'un mainteneur : ce qu'on découvre sur les données du CHU, même un piège de jointure, devient un claim avec ses preuves.

## Ids et noms de fichiers

- Le nom du fichier, sans extension, est l'id, unique dans tout le dépôt : minuscules, chiffres et tirets (mvt-rum-lien).
- Preuves et requêtes commencent par la date : 20261008-mvt-rum. Deux agents en parallèle ne choisissent pas le même nom.
- L'id d'une source finit par son édition : dictionnaire-cora-2020.
- On garde les mots de la source : mvt-rum, pas movement-rum.

## Termes et glossaires

- Un terme s'écrit avec son contexte : pmsi:rum. Il est défini dans le glossaire de ce contexte, et seulement là : knowledge/glossaries/pmsi.md, sous un titre `## pmsi:rum`, puis la définition en français.
- **Alias.** Les autres mots qu'on emploie pour le terme, sigles et jargon compris, vont sur une ligne qui commence par `Alias :`, juste sous le titre. Elle sert à retrouver le terme à partir des mots d'une question ; elle ne fait pas partie de la définition, et la changer ne périme aucune relecture (method/adr/0021). Un mot qui a un autre sens dans le même contexte n'y entre pas : c'est un autre terme.

```text
## pmsi:rss

Alias : résumé de sortie standardisé, résumé de sortie

La définition, en français…
```
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

- **Des mots de la question au terme :** chercher chaque mot dans les glossaires, titres et lignes « Alias » : `git grep -n -i -w "dms" -- knowledge/glossaries/`. Le titre au-dessus de la ligne trouvée est le terme.
- **Termes et tables :** chercher le terme (cora:mouvement) ou la table (cora:TB_MVT_RUM).
- **Colonnes et valeurs d'une table de CORA :** avant d'écrire une requête pour les apprendre, chercher la table dans le dictionnaire et les requêtes par défaut de CORA : `git grep -n "TB_DIAG" -- sources/dictionnaire-cora-2020/ sources/requetes-cora-par-defaut-v1/`.
- **Liens :** d'un claim, ses preuves (supported_by) et ses prémisses (depends_on). Pour savoir qui dépend d'un claim, chercher son id.
- **Lire un claim :** son en-tête et son corps, et ceux de ses prémisses, suffisent pour l'utiliser ; vérifier que sa portée (scope) couvre la question. Ses preuves s'ouvrent à la relecture (review.md, « Quand relire »).
- **Routines :** chercher la table dans knowledge/routines/, puis lire le README.md de la routine : comparer ce qu'elle compte et ses limites à la question, et chercher les claims sur lesquels elle s'appuie.
- **Preuves qu'aucun claim ne cite :** chercher la table dans knowledge/queries/ : `git grep -n "TB_SEJOUR" -- knowledge/queries/`, et lire la ligne purpose de chaque requête trouvée. Puis chercher l'id de la requête dans knowledge/evidence/ : la preuve qui le porte dans query est son résultat. Il s'ouvre quand le purpose répond à la question cadrée, avec sa date ; sinon, dans relay, avant d'écrire une requête (relay, étape 2).
- **Enquêtes passées :** la première ligne de chaque investigations/<id>/README.md est la question ; sa réponse est dans Conclusions, ou dans le commentaire qui ferme son issue (Issue : #N). Une enquête fermée sans claim ne garde que son issue, avec la réponse et le cadrage (investigations/README.md, « La branche », Retrouver).

Un index viendra seulement si cette recherche ne suffit plus.
