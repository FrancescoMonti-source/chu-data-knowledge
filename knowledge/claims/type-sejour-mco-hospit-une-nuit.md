---
review: unreviewed
id: type-sejour-mco-hospit-une-nuit
kind: empirical
author: Pierre
statement: "Dans CORA, de 2018 à 2025, plus de 98 % des séjours groupés en MCO d'au moins une nuit ont TYPE_SEJOUR = 'MCO'."
scope: "CORA de production (CWPROD, schéma CORA_REC), séjours reliés à un RSS par TB_MVT puis TB_MVT_RUM, sortis au moins un jour après leur entrée, années de sortie 2018 à 2025"
refuted_if: "une année 2018-2025 où moins de 95 % de ces séjours ont TYPE_SEJOUR = 'MCO'"
maturity: observed
lifecycle: active
terms: [cora:sejour, cora:rss, cora:type-sejour]
tables: [cora:TB_SEJOUR, cora:TB_MVT, cora:TB_MVT_RUM]
supported_by: [20261013-type-sejour-mco-un-jour-resultat]
depends_on: []
---
Part en 'MCO' parmi les séjours en 'MCO' ou 'HDJ', calculée depuis 20261013-type-sejour-mco-un-jour-resultat : 100 % en 2018 et 2019 (moins de 10 séjours dans une autre valeur), 99,6 % en 2020, puis de 98,1 % à 98,5 % de 2021 à 2025. Le reste est en 'HDJ' : 240 à 1 259 séjours par an.

Conséquence : pour les séjours groupés d'au moins une nuit, TYPE_SEJOUR = 'MCO' reste stable sur la période, contrairement aux séjours d'un jour (type-sejour-hdj-depuis-2020). Il ne sert pas pour autant à repérer ces séjours parmi tous ceux de TB_SEJOUR : la mesure ne porte que sur les séjours reliés à un RSS.

Points ouverts : ce que sont les séjours d'au moins une nuit codés 'HDJ' (venues sur deux jours, erreurs de saisie).
