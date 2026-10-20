---
review: unreviewed
id: dates-creation-actes-avant-2020-sont-des-reprises
kind: empirical
author: Pierre
statement: "Dans CORA, ne pas employer TB_ACTE.DATE_CREAT pour mesurer un délai de saisie ou de codage sur les actes réalisés avant octobre 2020 : pour 2014 à 2019 elle date les reprises d'historique, presque jamais la saisie."
scope: "CORA de production (CWPROD, schéma CORA_REC), TB_ACTE, actes réalisés de 2014 à 2020, lu le 2026-10-19"
refuted_if: "plus de 10 % des actes d'une année de 2014 à 2016, 2018 ou 2019 ont une DATE_CREAT dans l'année même de leur réalisation"
maturity: observed
lifecycle: active
terms: [cora:acte]
tables: [cora:TB_ACTE]
supported_by: [20261019-dates-creation-actes-reprises-resultat]
depends_on: [epoques-codage-actes]
---
## Pour s'en servir

- **Délai de saisie ou de codage** (DATE_CREAT moins DATE_ACTE) : ne le calculer que sur les actes réalisés depuis octobre 2020, et dire cette limite dans l'analyse (actes-derniers-mois-incomplets donne le profil du délai depuis cette date).
- **Actes plus anciens :** DATE_CREAT n'est pas une date de saisie. Pour dater un acte, prendre DATE_ACTE.
- **Actes de 2020 avant octobre :** par prudence, les traiter comme les actes d'avant 2020 (voir Points ouverts).

## Ce qui l'appuie

Actes de 2014 à 2020 par année (puis par mois de 2018 à 2020) et application (20261019-dates-creation-actes-reprises-resultat). Les parts sont calculées avec les cases <10 comptées 0, sur les actes datés, en excluant les lignes à effectif masqué : les actes sans application de 2014, 2015 et 2016 (dont la date de création est vide pour 1 804, 421 et 205 d'entre eux) et trois lignes d'application 10 de 2019 (février, mai, août ; l'application 10 compte 1 323 actes de 2019 sur les lignes visibles, 0,4 % des actes).

| Actes réalisés en | créés la même année | créés l'année suivante | créés plus de 365 jours après |
|---|---|---|---|
| 2014 | moins de 10 | moins de 10 | 100 % (279 986 sur 279 986) |
| 2015 | moins de 10 | 98 % (293 603 sur 300 156) | 95 % (286 122) |
| 2016 | 23 sur environ 284 000 | 100 % (283 945) | 28 % (80 451) |
| 2018 | 0,1 % (362 sur 293 427) | 24 | 99,9 % (293 027) |
| 2019 | 0,1 % (392 sur 338 875) | 99,7 % (337 818 sur 338 875) | 60 % (203 644) |
| 2020, janvier à septembre | 99,1 % (259 442 sur 261 782) | 0,9 % | 0,1 % |
| 2020, octobre à décembre | 94,6 % (175 840 sur 185 898) | 5,4 % | moins de 0,1 % |

Plus de 99 % des actes de 2014 à 2016 sont de la reprise (application −3010 ; le reste est sans application et sans date de création), presque tous ceux de 2018 et 2019 (99,7 % et 99,6 %) de la seconde reprise sans application (epoques-codage-actes) : leur création est presque toujours postérieure à l'année de réalisation (2014 et 2018 : plus d'un an après ; 2015, 2016 et 2019 : l'année suivante pour presque tous). Pour 2019, la création suit la réalisation d'environ douze mois : plus d'un an après pour presque tous les actes de janvier à août (26 090 sur 26 133 en janvier), 27 % de ceux de septembre (6 404 sur 23 301), presque aucun d'octobre à décembre. L'année 2017 (environ 9 200 actes, 11 % créés la même année) est la lacune déjà signalée dans epoques-codage-actes, hors périmètre.

Points ouverts : de janvier à septembre 2020, les actes sont créés la même année (99 %), si bien que la requête, qui compare des années, ne dit pas si cette date est celle d'une saisie ou d'un import en lot ; la limite d'octobre 2020 vient de la fin des imports sans application (epoques-codage-actes) et reste une prudence, pas une mesure. Requête de suite : répartition des actes de 2018 à septembre 2020 par mois de DATE_CREAT, pour dater les reprises. DATE_CREAT est vide pour 1 804 actes de 2014, 421 de 2015 et 205 de 2016 (sans application).
