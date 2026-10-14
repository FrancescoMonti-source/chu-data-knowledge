---
review: unreviewed
id: dernier-mouvement-date-la-sortie
kind: empirical
author: Pierre
statement: "Dans CORA, pour un séjour clos, le dernier mouvement se termine le jour de la sortie (99 % ou plus des séjours de chaque année d'entrée, sauf 2017 : 92 %), et le RSS aussi quand il existe (98,5 % ou plus, sauf 2017)."
scope: "CORA de production (CWPROD, schéma CORA_REC), séjours entrés de 2014 à 2025 avec DATE_SORTIE, lus le 2026-10-14"
refuted_if: "la fin du dernier mouvement tombe un autre jour que DATE_SORTIE pour plus de 2 % des séjours clos d'une année d'entrée autre que 2017"
maturity: observed
lifecycle: active
terms: [cora:sejour, cora:mouvement, cora:rss]
tables: [cora:TB_SEJOUR, cora:TB_MVT, cora:TB_MVT_RUM, cora:TB_SYNTH_RSS]
supported_by: [20261014-sorties-manquantes-resultat]
depends_on: []
---
## Pour s'en servir

Pour dater un séjour sans DATE_SORTIE (date-sortie-manquante), la fin de son dernier mouvement est un bon substitut : sur les séjours clos, elle tombe le jour de la sortie. Dernier mouvement : le plus tardif par DATE_DEBUT_MVT, HEURE_DEBUT_MVT puis ID_MVT.

Ce substitut est éprouvé pour la fin du mouvement seulement. Quand le dernier mouvement est resté ouvert (DATE_FIN_MVT vide, le cas le plus fréquent des séjours sans sortie), seul son début est connu : c'est une approximation, à signaler. Sur les séjours entrés en 2017, l'accord est moins bon : le dire.

## Ce qui l'appuie

Séjours clos dont le dernier mouvement finit le jour de la sortie (20261014-sorties-manquantes-resultat) : 99,8 % en 2014 et 2015, 99,9 % en 2016, 92,1 % en 2017, 99,2 % en 2018, 99,3 % en 2019, 99,6 % en 2020, 99,9 % ou plus de 2021 à 2025.

Séjours clos reliés à un RSS dont le RSS finit le jour de la sortie : plus de 99,9 % en 2014-2016 (l'écart est sous 10 séjours, masqué), 88,3 % en 2017 (993 sur 1 124), 98,5 % en 2018, 98,7 % en 2019, 99,9 % ou plus de 2020 à 2025.

Points ouverts : la cause de l'écart de 2017 ; l'écart en jours quand la fin du mouvement ne tombe pas le jour de la sortie.
