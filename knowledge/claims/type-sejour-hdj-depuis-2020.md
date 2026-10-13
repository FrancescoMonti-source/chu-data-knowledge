---
review: unreviewed
id: type-sejour-hdj-depuis-2020
kind: empirical
author: Pierre
statement: "Dans CORA, les séjours groupés en MCO sortis le jour de leur entrée passent de TYPE_SEJOUR 'MCO' à 'HDJ' à partir de 2020 : 0 % en 'HDJ' en 2018-2019, 20 % en 2020, 76 à 85 % de 2021 à 2025."
scope: "CORA de production (CWPROD, schéma CORA_REC), séjours reliés à un RSS par TB_MVT puis TB_MVT_RUM, sortis le jour de leur entrée, années de sortie 2018 à 2025"
refuted_if: "une année 2021-2025 où moins de la moitié de ces séjours sont en 'HDJ', ou une année 2018-2019 où 10 ou plus le sont"
maturity: observed
lifecycle: active
terms: [cora:sejour, cora:rss, cora:type-sejour]
tables: [cora:TB_SEJOUR, cora:TB_MVT, cora:TB_MVT_RUM]
supported_by: [20261013-type-sejour-mco-un-jour-resultat]
depends_on: []
---
Part en 'HDJ' parmi les séjours en 'MCO' ou 'HDJ', calculée depuis 20261013-type-sejour-mco-un-jour-resultat : 2018 et 2019, moins de 10 séjours ; 2020, 20,0 % ; 2021, 76,1 % ; 2022, 78,1 % ; 2023, 81,5 % ; 2024, 83,2 % ; 2025, 85,0 %. Les autres valeurs (EXT, PSY, REA, URG, SSR, LSJ, vide) restent sous 10 séjours par an.

Conséquence : un filtre TYPE_SEJOUR = 'MCO' perd la plupart des séjours d'un jour à partir de 2021, et une série annuelle par TYPE_SEJOUR montre une rupture en 2020-2021 qui vient du codage, pas de l'activité. Le dictionnaire CORA 2020 présente TYPE_SEJOUR comme un moyen de distinguer les sortes de séjours (sources/dictionnaire-cora-2020/TB_SEJOUR.txt) ; il ne le fait pas de façon constante dans le temps.

Le passage est progressif (2020 puis 2021), pas une date nette.

Points ouverts : ce que sont les 16 000 à 19 000 séjours d'un jour restés en 'MCO' chaque année depuis 2021 (séances, chirurgie ambulatoire, autre organisation des unités) ; le contexte du changement (paramétrage, interface, date exacte) ; les séjours sans RSS (#25), hors du champ de cette mesure.
