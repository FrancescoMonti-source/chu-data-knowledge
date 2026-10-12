# Preuves et sources

Une preuve enregistre ce qu'on a observé ; un claim dit ce que ça signifie. Une preuve peut soutenir plusieurs claims. Chaque preuve est un fichier dans le dossier evidence/ de son sujet (layout.md). Deux types : execution et reading.

Avant d'écrire une preuve : le filtre de privacy.md. L'en-tête suit les règles d'écriture de claims.md (texte libre entre guillemets doubles).

## Exécution

Une exécution d'une requête à l'hôpital, toujours dans `systems/<système>/evidence/`. Sous l'en-tête, le fichier ne contient que le résultat, en tableau Markdown, avec les colonnes telles qu'elles sont revenues : le contrôle des effectifs ne lit que les tableaux. La requête reste une seule fois dans requests/.

```markdown
---
id: 20261008-mvt-rum
type: execution
request: 20261007-mvt-rum
run_at: 2026-10-08 09:14
database: CORAPROD
executed_by: Francesco
modified: no
person_data: masked
---
| request_id | database_name | run_at | ANNEE | N_MVT |
|---|---|---|---|---|
| 20261007-mvt-rum | CORAPROD | 2026-10-08 09:14 | 2025 | 1520 |
```

| Champ | Valeurs |
|---|---|
| request | l'id de la requête |
| run_at, database | recopiés du résultat, où la requête les imprime |
| executed_by | la personne qui a exécuté (claims.md, « Les personnes ») |
| modified | no · yes · unknown. Si yes, la requête réellement exécutée suit le résultat, dans un bloc sql |
| person_data | recopié de la requête : masked ou no-person-data |

Une valeur inconnue s'écrit unknown. Un claim empirique observed demande une exécution sans unknown.

## Lecture

Un passage lu dans un document, dans le dossier evidence/ du système ou du domaine dont parle le passage.

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
| locator | l'endroit exact : page, chapitre, section |
| read_by | la personne pour qui l'agent lit, comme author (claims.md, « Les personnes ») |
| read_at | la date de la lecture |

Sous l'en-tête, une courte citation, en lignes qui commencent par >.

## Sources

Une fiche par document et par édition, dans sources/. Le document lui-même n'est ajouté que s'il peut être partagé : dans sources/, sous l'id de sa fiche, dans son format d'origine (dictionnaire-cora-2020.pdf).

```markdown
---
id: dictionnaire-cora-2020
title: "Dictionnaire des données CORA"
publisher: "l'éditeur de CORA"
edition: "2020"
location: "où le trouver"
authority: vendor-doc
---
```

location dit où lire le document. Pour un document public, c'est le lien vers le fichier de cette édition, chez son éditeur officiel : pour le PMSI, l'ATIH, le Bulletin officiel, Légifrance ou ameli. Une page « dernière version » change de document à chaque édition ; un fichier garde le sien. Un site qui regroupe les liens, comme lespmsi.com, aide à trouver le document ; la fiche cite le fichier de l'éditeur. (docs/adr/0013)

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
