# 0025 — La finalité du dépôt

Statut : accepté, 2026-10-16 (Francesco, carte de l'enquête revalorisation-chir-m8). Proposé le 2026-10-14 par Pierre ; accord de principe de Francesco sur #26.

## Contexte

AGENTS.md disait ce que le dépôt garde (ce qu'on découvre sur les données du CHU) et pourquoi il exige des preuves. Il ne disait pas à qui ni à quoi sert ce qu'il garde. La méthode s'est donc construite sur la seule vérité d'un claim : preuves, refuted_if, empreinte, relecture, un claim par test. Rien ne demandait qu'un claim soit utile.

Pendant la migration de la base de connaissances de dim-code (#24), l'agent a écrit des claims vrais et bien prouvés mais inutilisables (des pourcentages par année et par sous-population), puis un claim qui recopiait le dictionnaire CORA. #26 et #28 corrigeaient ces cas un par un.

## Décision

- AGENTS.md, « Pourquoi ce dépôt », dit la finalité : donner à l'agent de la prochaine analyse un contexte précis et vérifié, pour interroger les données, interpréter les résultats et produire à son tour des claims.
- Un claim doit être utile, vrai et vérifié, et conforme. Les trois ensemble : un claim vrai mais inutile n'entre pas, un claim utile mais non prouvé non plus.
- Les règles de method/ et les skills se lisent à partir de cette finalité. Une règle qui ne sert aucune des trois qualités est à revoir.

## Conséquences

- 0022 applique la qualité « utile » à claims.md et aux skills ; 0023 et 0024 l'appliquent aux preuves.
- La qualité « utile » reste une règle de confiance : check.py ne sait pas la contrôler. La relecture au réemploi la vérifie de fait : un claim que personne ne réutilise ne sert pas.

## Alternative

Garder la section et corriger règle par règle, comme #26 et #28 l'ont fait d'abord. Chaque nouvelle dérive aurait demandé une nouvelle règle.
