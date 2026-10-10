# Où va quoi

sources/ dit de quel document on parle ; systems/, domains/ et investigations/ rangent ce qu'on apprend.

| Dossier | Contient | Répond à | Exemple |
|---|---|---|---|
| `systems/<système>/` | ce qu'on sait d'un logiciel ou d'une base : tables, objets, comportements | comment ce système représente-t-il les choses ? | dans CORA, TB_MVT_RUM relie mouvements et RUM |
| `domains/<domaine>/` | concepts et règles qui ont un sens sans un logiciel précis, nationaux ou propres au CHU | que veut dire ce concept, quelle règle s'applique ? | un RUM décrit le séjour dans une seule unité médicale |
| `investigations/<enquête>/` | la réponse à une question précise, construite sur des claims réutilisables | que répond-on à cette question ? | un passage dans une UF correspond-il à un RUM ? |
| sources/ | la fiche de chaque document | quel document ? | dictionnaire-cora-2020.md |

Chaque système a la même forme ; un domaine aussi, sans requests/ :

```text
systems/cora/
  GLOSSARY.md   les termes du contexte
  requests/     les requêtes préparées (.sql)
  evidence/     une preuve par fichier
  claims/       un claim par fichier
```

Une enquête : voir investigations/README.md.

## Les règles

- **Le sujet décide.** Un claim va dans systems/ s'il décrit un système concret, dans domains/ s'il décrit le modèle d'un domaine. Règle pratique, contrôlée : un claim qui nomme des tables (tables non vide) va dans systems/. *À confirmer : docs/adr/0005.*
- **Une exécution lit toujours un système.** Sa preuve va dans `systems/<système>/evidence/`.
- **Une lecture va où va son sujet.** Un passage du dictionnaire CORA sur une règle du PMSI va dans domains/pmsi/evidence/ ; s'il décrit le comportement de CORA, dans systems/cora/evidence/. L'autorité vient de la source, jamais du dossier.
- **Une fiche, plusieurs preuves.** Un document lu dix fois donne une seule fiche dans sources/ et dix preuves.
- **PMSI par édition.** Le domaine pmsi suit les textes réglementaires et les guides de l'ATIH, dans leur champ et leur période d'application. Chaque édition remplace la précédente : l'id de la fiche porte l'année.
- **Réutilisable, dans son scope.** Les claims de systems/ et domains/ servent à plusieurs enquêtes, dans la portée qu'ils déclarent. Une enquête dépend d'eux, jamais l'inverse.
- **Promotion au réemploi.** Quand une conclusion d'enquête sert ailleurs, on déplace son fichier dans le système ou le domaine concerné, avec le même id, et le README.md de l'enquête la cite. On le fait au moment du réemploi, avec la relecture (review.md).
- **Position.** Un claim vit à côté de sa preuve principale. Les liens citent des ids, pas des chemins : déplacer un fichier ne casse aucun lien.

## Ids et noms de fichiers

- Le nom du fichier, sans extension, est l'id, unique dans tout le dépôt : minuscules, chiffres et tirets (mvt-rum-lien).
- Preuves et requêtes commencent par la date : 20261008-mvt-rum. Deux agents en parallèle ne choisissent pas le même nom.
- L'id d'une source finit par son édition : dictionnaire-cora-2020.
- On garde les mots de la source : mvt-rum, pas movement-rum.

## Termes et glossaires

- Le GLOSSARY.md de chaque système et de chaque domaine définit les termes de son contexte : un titre par terme (## cora:mouvement), puis la définition en français.
- Un claim cite ses termes dans terms. Un terme absent des glossaires bloque.
- Un glossaire définit des mots. Ce qui est vrai d'un système (une jointure, un piège) est un claim, avec ses preuves.
- GLOSSARY-MAP.md liste les contextes. Un pont entre deux contextes est un claim.

## Retrouver ce qu'on sait

Pas d'index : on cherche dans les champs des claims.

- **Termes :** les claims qui citent un terme dans terms.
- **Tables :** les claims qui citent une table dans tables.
- **Liens :** d'un claim, ses preuves (supported_by) et ses prémisses (depends_on). Pour savoir qui dépend d'un claim, chercher son id dans les depends_on des autres.
- **Enquêtes passées :** la première ligne de chaque README.md d'enquête est la question.

Un index viendra seulement si cette recherche ne suffit plus.
