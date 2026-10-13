---
review: unreviewed
id: type-sejour-non-fiable
kind: empirical
author: Pierre
statement: "Dans CORA, TYPE_SEJOUR ne permet pas de classer les séjours MCO par type de prise en charge : les séjours d'un jour, codés 'MCO' jusqu'en 2019, passent en 'HDJ' en 2020-2021, et 15 à 24 % restent en 'MCO' depuis."
scope: "CORA de production (CWPROD, schéma CORA_REC), séjours reliés à un RSS par TB_MVT puis TB_MVT_RUM, années de sortie 2018 à 2025"
refuted_if: "une même valeur de TYPE_SEJOUR pour presque tous (plus de 98 %) les séjours groupés en MCO sortis le jour de leur entrée, chaque année de 2018 à 2025"
maturity: observed
lifecycle: active
terms: [cora:sejour, cora:rss, cora:type-sejour]
tables: [cora:TB_SEJOUR, cora:TB_MVT, cora:TB_MVT_RUM]
supported_by: [20261013-type-sejour-mco-un-jour-resultat]
depends_on: []
---
## Pour s'en servir

Ne pas filtrer ni ventiler les séjours sur TYPE_SEJOUR : un filtre 'MCO' perd la plupart des séjours d'un jour à partir de 2021, un filtre 'HDJ' ne trouve rien avant 2020 et en manque ensuite, et une série annuelle par TYPE_SEJOUR montre une rupture qui vient du codage. Pour classer un séjour MCO, suivre type-prise-en-charge-mco.

## Ce qui l'appuie

Séjours groupés en MCO sortis le jour de leur entrée, part codée 'HDJ' parmi 'MCO' et 'HDJ' (20261013-type-sejour-mco-un-jour-resultat) : moins de 10 séjours en 2018 et 2019, 20,0 % en 2020, 76,1 % en 2021, 78,1 % en 2022, 81,5 % en 2023, 83,2 % en 2024, 85,0 % en 2025. Les séjours d'au moins une nuit restent en 'MCO' à plus de 98 % chaque année ; les autres valeurs (EXT, PSY, REA, URG, SSR, LSJ, vide) restent sous 10 séjours par an.

Le dictionnaire CORA 2020 présente TYPE_SEJOUR comme un moyen de distinguer les sortes de séjours (sources/dictionnaire-cora-2020/TB_SEJOUR.txt) ; les données ne le permettent pas de façon constante.

Points ouverts : ce que sont les séjours d'un jour restés en 'MCO' depuis 2021 ; le contexte du changement (paramétrage, interface, date exacte) ; les séjours sans RSS (#25), hors du champ de la mesure.
