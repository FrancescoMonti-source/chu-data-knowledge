---
review: unreviewed
id: mode-sortie-du-sejour
kind: empirical
author: Pierre
statement: "Dans CORA, TB_SEJOUR.MODE_SORTIE est égal au mode de sortie du dernier RSS pour 98 à 99,9 % des séjours qui ont un RSS ; il est vide pour 1 à 23 % des séjours clos selon l'année (15 à 23 % en 2018-2019, 1 à 2 % en 2024-2025), surtout sur des séjours sans RSS."
scope: "CORA de production (CWPROD, schéma CORA_REC), séjours clos de 2018 à 2025, lus le 2026-10-14"
refuted_if: "pour une année, MODE_SORTIE diffère du mode du dernier RSS pour plus de 3 % des séjours qui ont un RSS"
maturity: observed
lifecycle: active
terms: [cora:sejour, cora:rss]
tables: [cora:TB_SEJOUR, cora:TB_SYNTH_RSS, cora:TB_MVT, cora:TB_MVT_RUM]
supported_by: [20261014-sortie-et-dernier-mvt-resultat]
depends_on: []
---
## Pour s'en servir

Pour le mode de sortie d'un séjour, lire `TB_SEJOUR.MODE_SORTIE` : pour une hospitalisation (un séjour avec RSS), il redit celui du dernier RSS. Le mode du dernier RSS, ou d'un RUM, ne sert que pour les mutations internes.

Sur les séjours sans RSS (consultations externes surtout), MODE_SORTIE est souvent vide, surtout en 2018-2019 : une répartition par mode de sortie doit garder une modalité « vide » et dire combien de séjours elle contient.

## Ce qui l'appuie

Séjours clos par année de sortie (20261014-sortie-et-dernier-mvt-resultat) : MODE_SORTIE vide pour 122 003 des 784 929 séjours de 2018 (15,5 %), 185 728 en 2019 (23,5 %), 27 060 en 2020 (4,0 %), 58 581 en 2021 (7,0 %), 70 065 en 2022 (8,6 %), 64 006 en 2023 (7,6 %), 8 577 en 2024 (1,0 %) et 18 381 en 2025 (2,1 %). Égal au mode du dernier RSS : 149 120 des 151 757 séjours avec RSS en 2018 (98,3 %), de 98,7 à 99,9 % les autres années. Les séjours avec RSS dont le mode diffère ou manque sont au plus 2 637 par an : au moins 80 % des séjours sans MODE_SORTIE de chaque année n'ont pas de RSS (81 % en 2024, 98 % en 2018).
