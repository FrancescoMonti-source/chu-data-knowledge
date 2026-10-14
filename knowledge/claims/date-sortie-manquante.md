---
review: unreviewed
id: date-sortie-manquante
kind: empirical
author: Pierre
statement: "Dans CORA, DATE_SORTIE manque pour une part des séjours qui varie selon l'année d'entrée (environ 30 % en 2017, 1 à 9 % les autres années depuis 2016, sauf 2020) ; ces séjours n'ont presque jamais de RSS, et la plupart n'ont qu'un mouvement resté ouvert."
scope: "CORA de production (CWPROD, schéma CORA_REC), séjours entrés de 2014 à 2025, lus le 2026-10-14"
refuted_if: "DATE_SORTIE renseignée pour plus de 99 % des séjours entrés en 2017, ou un RSS relié (TB_MVT → TB_MVT_RUM) à plus de 1 % des séjours sans DATE_SORTIE d'une année d'entrée"
maturity: observed
lifecycle: active
terms: [cora:sejour, cora:mouvement, cora:rss]
tables: [cora:TB_SEJOUR, cora:TB_MVT, cora:TB_MVT_RUM, cora:TB_SYNTH_RSS]
supported_by: [20261014-sorties-manquantes-resultat]
depends_on: []
---
## Pour s'en servir

Ne pas sélectionner une période sur DATE_SORTIE brute, ni filtrer DATE_SORTIE IS NOT NULL sans le dire : le filtre perd près d'un tiers des séjours entrés en 2017 et plusieurs pour cent des autres années, et la perte varie d'une année à l'autre, ce qui crée de fausses tendances. Annoncer, dans toute série par année, la part des séjours sans sortie.

La sortie manquante ne se retrouve pas par le RSS : ces séjours n'en ont presque jamais. Le dernier mouvement est le seul repère (dernier-mouvement-date-la-sortie).

Avant 2020, une part des séjours sans sortie sont des préadmissions (TB_SEJOUR.STATUT_PROG = 'P') ou des séjours sans aucun mouvement : les traiter à part.

## Ce qui l'appuie

Séjours sans DATE_SORTIE par année d'entrée (20261014-sorties-manquantes-resultat). Les totaux sont masqués pour 2014-2023 (une case est sous 10) ; les parts ci-dessous viennent de la somme des cases visibles, à quelques séjours près :

| Année d'entrée | Sans sortie | Part | dont préadmissions | dont un seul mouvement, ouvert, sans RSS | dont aucun mouvement |
|---|---|---|---|---|---|
| 2014 | ≈ 1 050 | 0,8 % | < 10 | 3 % | 95 % |
| 2015 | ≈ 1 320 | 0,9 % | < 10 | 2 % | 97 % |
| 2016 | ≈ 14 900 | 6,8 % | 6 % | 80 % | 16 % |
| 2017 | ≈ 266 800 | 30,4 % | 26 % | 92 % | 7 % |
| 2018 | ≈ 72 900 | 8,5 % | 16 % | 77 % | 23 % |
| 2019 | ≈ 52 100 | 6,0 % | 16 % | 62 % | 38 % |
| 2020 | ≈ 610 | 0,1 % | 4 % | 90 % | 10 % |
| 2021 | ≈ 16 740 | 2,0 % | 1 % | 100 % | 0 % |
| 2022 | ≈ 55 100 | 6,5 % | 0 % | 100 % | 0 % |
| 2023 | ≈ 14 400 | 1,7 % | 1 % | 97 % | 3 % |
| 2024 | 40 832 | 4,6 % | 1 % | 99 % | 1 % |
| 2025 | 28 707 | 3,1 % | 1 % | 98 % | 1 % |

Un RSS relié : moins de 10 séjours sans sortie par année jusqu'en 2023, 11 en 2024, 20 en 2025.

D'après dim-code (non mesuré ici), ces séjours se concentrent dans les UF d'urgences : passages jamais clôturés. Leur repérage attend #30.

Points ouverts : la part change d'une année à l'autre sans explication établie (campagnes de clôture ?) ; le contenu des séjours sans aucun mouvement de 2014-2015 et 2018-2019.
