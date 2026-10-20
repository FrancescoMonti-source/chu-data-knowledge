# Preuves et sources

Une preuve enregistre ce qu'on a observé ; un claim dit ce que ça signifie. Une preuve peut soutenir plusieurs claims. Chaque preuve est un fichier dans knowledge/evidence/. Deux types : execution et reading.

Avant d'écrire une preuve : le filtre de privacy.md. L'en-tête suit les règles d'écriture de claims.md (texte libre entre guillemets doubles).

## Exécution

Une exécution d'une requête à l'hôpital. Elle prend le système de sa requête, sans le recopier. Sous l'en-tête, le fichier ne contient que le résultat, en tableau Markdown, avec les colonnes telles qu'elles sont revenues : le contrôle des effectifs ne lit que les tableaux. La requête reste une seule fois dans knowledge/queries/.

```markdown
---
id: 20261008-mvt-rum
type: execution
query: 20261007-mvt-rum
run_at: 2026-10-08 09:14
database: CORAPROD
executed_by: Francesco
modified: no
person_data: masked
---
| query_id | database_name | run_at | ANNEE | N_MVT |
|---|---|---|---|---|
| 20261007-mvt-rum | CORAPROD | 2026-10-08 09:14 | 2025 | 1520 |
```

| Champ | Valeurs |
|---|---|
| query | l'id de la requête |
| run_at, database | recopiés du résultat, où la requête les imprime ; pour un script, database est le nom du fichier lu |
| executed_by | la personne qui a exécuté (claims.md, « Les personnes ») |
| modified | no · yes · unknown. Si yes, la requête réellement exécutée suit le résultat, dans un bloc sql (r ou python pour un script) |
| person_data | recopié de la requête : masked ou no-person-data |

Une valeur inconnue s'écrit unknown. Un claim empirique observed demande une exécution sans unknown.

## Lire un résultat masqué

Dans un résultat masqué, `<10` veut dire un effectif de 0 à 9, pas une valeur manquante. Pour tout chiffre qu'on tire d'une exécution (moyenne, somme, part) :

- une cellule `<10` compte pour 0 dans une moyenne ou une somme, et le chiffre le dit (« cellules <10 comptées pour 0 ») ; ne pas exclure la période ou la ligne ;
- une cellule masquée dont le total et les autres cellules sont visibles se retrouve par différence (queries.md, règle 4) ; sans total, elle reste inconnue, et le chiffre qui en dépend aussi ;
- le chiffre cité dans un claim est recalculé depuis le fichier de preuve, avec ces règles ; il n'est jamais repris d'un message ou d'une analyse précédente.

## Lecture

Un passage lu dans un document.

```markdown
---
id: 20261007-dictionnaire-mvt-rum
type: reading
source: dictionnaire-cora-2020
locator: "page 42"
read_by: Francesco
read_at: 2026-10-07
---
> « … » (courte citation)
```

| Champ | Valeurs |
|---|---|
| source | l'id de la fiche dans sources/ |
| locator | l'endroit exact : page, chapitre, section, ou le fichier dans le dossier de la fiche |
| read_by | la personne pour qui l'agent lit, comme author (claims.md, « Les personnes ») |
| read_at | la date de la lecture |

Sous l'en-tête, une courte citation, en lignes qui commencent par >.

## Sources

Une fiche par document et par édition, dans sources/. Un document en ligne reste chez son éditeur, car une copie vieillirait sans qu'on le voie : la fiche donne son lien (location, plus bas). Un document hors ligne qui peut être partagé entre dans sources/, sous l'id de sa fiche. En texte quand la conversion garde tout ce qui compte : le contrôle le lit, et un agent y cherche plus facilement. Un document fait de parties qui se lisent séparément (les tables d'un dictionnaire, les requêtes d'un catalogue) devient un dossier du nom de sa fiche, avec un fichier par partie, du nom de la partie (dictionnaire-cora-2020/TB_MVT_RUM.txt) : l'agent ouvre la partie qu'il cherche, pas le document entier. Sinon, par exemple pour garder des schémas, dans son format d'origine.

```markdown
---
id: dictionnaire-cora-2020
title: "Dictionnaire des données CORA"
publisher: "l'éditeur de CORA"
edition: "2020"
location: "sources/dictionnaire-cora-2020/, un fichier texte par table, tiré du PDF original"
authority: vendor-doc
---
```

location dit où lire le document. Pour un document hors ligne, c'est son fichier ou son dossier dans sources/ ; s'il n'y entre pas, l'endroit où la personne le trouve. Pour un document public, c'est le lien vers le fichier de cette édition, chez son éditeur officiel : pour le PMSI, l'ATIH, le Bulletin officiel, Légifrance ou ameli. Une page « dernière version » change de document à chaque édition ; un fichier garde le sien. Un site qui regroupe les liens, comme lespmsi.com, aide à trouver le document ; la fiche cite le fichier de l'éditeur.

```markdown
---
id: atih-guide-mco-2024
title: "Guide méthodologique de production des informations relatives à l'activité médicale et à sa facturation en MCO"
publisher: "ATIH, Bulletin officiel Santé n° 22 du 1er août 2024"
edition: "2024"
location: "https://atih.sante.fr/sites/default/files/public/content/4709/2024.22.sante_.pdf"
authority: official
---
```

| authority | Sens |
|---|---|
| official | texte réglementaire, guide de l'ATIH |
| vendor-doc | documentation de l'éditeur d'un logiciel |
| local | document du CHU |
| unknown | origine inconnue |

L'autorité dit d'où vient le document, pas s'il a raison : une documentation d'éditeur peut se tromper.
