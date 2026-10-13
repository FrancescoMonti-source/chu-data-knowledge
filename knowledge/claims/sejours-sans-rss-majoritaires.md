---
review: unreviewed
id: sejours-sans-rss-majoritaires
kind: empirical
author: Pierre
statement: "Dans CORA, de 2018 à 2025, 80 à 83 % des séjours sortis chaque année ne sont reliés à aucun RSS par leurs mouvements."
scope: "CORA de production (CWPROD, schéma CORA_REC), séjours avec une date de sortie, années de sortie 2018 à 2025"
refuted_if: "une année de sortie de 2018 à 2025 où moins de 75 % des séjours sortis n'ont aucun RSS par TB_MVT puis TB_MVT_RUM"
maturity: observed
lifecycle: active
terms: [cora:sejour, cora:rss]
tables: [cora:TB_SEJOUR, cora:TB_MVT, cora:TB_MVT_RUM]
supported_by: [20261013-sejours-sans-rss-resultat]
depends_on: [tb-sejour-hospitalisations-et-externes]
---
Part des séjours sans RSS, calculée depuis 20261013-sejours-sans-rss-resultat : 80,7 % en 2018 et 2019, 80,1 % en 2020, 82,6 % en 2021, 82,2 % en 2022, 81,8 % en 2023, 81,9 % en 2024, 80,2 % en 2025. Les effectifs vont de 673 000 à 897 000 séjours sortis par an.

Conséquence pour qui compte : un comptage de TB_SEJOUR sans filtre est fait aux quatre cinquièmes de séjours sans RSS. Ce n'est pas un comptage d'hospitalisations MCO.

Limites :
- « Sans RSS » ne veut pas dire « consultation externe ». Le groupe comprend aussi, sans les distinguer, les séjours d'unités qui n'ont pas de RSS (SMR, psychiatrie, HAD, unités hors PMSI), si CORA les enregistre dans TB_SEJOUR.
- La part des séjours sans RSS sortis le jour de leur entrée varie trop pour appuyer seule l'interprétation « consultation externe » : 86 à 93 % en 2018-2019, 8 à 16 % de 2020 à 2023, 65 % en 2024, 79 % en 2025.
- Avant 2018, la mesure ne suit pas la même logique : 3 à 4 % sans RSS en 2014-2015 (128 000 à 141 000 séjours), 97 % en 2016 et 100 % en 2017. Ces années relèvent d'autres claims (étapes 2 et 9 du plan, #24).

Points ouverts : ce qui compose les séjours sans RSS (externes, autres champs PMSI, hors PMSI) ; la chute de la part sortie le jour même entre 2020 et 2023 ; le contenu de TB_SEJOUR avant 2016.
