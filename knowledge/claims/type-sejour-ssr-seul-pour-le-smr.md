---
review: unreviewed
id: type-sejour-ssr-seul-pour-le-smr
kind: empirical
author: Pierre
statement: "Dans CORA, filtrer les séjours de SMR sur TB_SEJOUR.TYPE_SEJOUR = 'SSR' : la valeur 'SMR' n'existe pour aucun séjour de 2018 à 2026, et le drapeau CODE_AUTORISATION_SSR de TB_UNITE est vide, donc ne repère pas non plus les unités de SMR."
scope: "CORA de production (CWPROD, schéma CORA_REC), séjours de TB_SEJOUR entrés du 2018-01-01 au 2026-10-19, hors préadmissions (STATUT_PROG = 'P'), par année d'entrée, lus le 2026-10-19"
refuted_if: "au moins 10 séjours de TYPE_SEJOUR = 'SMR' sur une année d'entrée de 2018 à 2026, ou une UF d'entrée de séjours 'SSR' avec CODE_AUTORISATION_SSR renseigné"
maturity: observed
lifecycle: active
terms: [cora:sejour, cora:type-sejour, pmsi:smr]
tables: [cora:TB_SEJOUR, cora:TB_UNITE]
supported_by: [20261019-type-sejour-ssr-smr-resultat, 20261019-transfert-mco-smr-meme-jour-resultat]
depends_on: [joindre-uf-par-code]
---
## Pour s'en servir

Pour sélectionner les séjours de SMR (soins médicaux et de réadaptation, ex-SSR), écrire `TRIM(TYPE_SEJOUR) = 'SSR'`. Écrire `IN ('SSR', 'SMR')` est inoffensif mais inutile : un filtre sur 'SMR' seul ne renvoie aucun séjour, quelle que soit l'année. Une série annuelle de séjours de SMR ne rompt pas par le codage : 'SSR' reste la valeur après le renommage du SSR en SMR.

Ne pas contrôler ce filtre par CODE_AUTORISATION_SSR de l'unité d'entrée (TB_UNITE, jointure par code, joindre-uf-par-code) : il est vide pour toutes les UF d'entrée de ces séjours, comme pour celles des autres séjours. TYPE_SEJOUR n'est en revanche pas fiable pour classer le MCO (type-sejour-non-fiable) : ce claim ne vaut que pour le SMR.

## Ce qui l'appuie

Séjours par année d'entrée et TYPE_SEJOUR (20261019-type-sejour-ssr-smr-resultat) : 'SSR' compte 5 318 séjours en 2018, 4 566 en 2019, 2 949 en 2020, 4 088 en 2021, 4 058 en 2022, 3 751 en 2023, 4 351 en 2024, 4 970 en 2025 et 4 112 en 2026 (année en cours), répartis sur 12 à 14 UF d'entrée distinctes par année. La requête sort une ligne pour toute valeur présente, même sous 10 : il n'y a aucune ligne 'SMR'. Les autres valeurs de TYPE_SEJOUR sont EXT, HDJ, MCO, URG, PSY, LSJ, HAD (et REA, LS et la valeur vide, sous 10).

CODE_AUTORISATION_SSR : pour tous les séjours 'SSR' de chaque année (niveau UNITES de la requête), l'UF d'entrée a un code d'autorisation vide, comme pour toutes les autres valeurs de TYPE_SEJOUR (niveau TYPE). La jointure par code ne perd pas de lignes (joindre-uf-par-code) ; mais la requête est une jointure externe, donc « vide » regroupe un code d'autorisation vide et une UF d'entrée absente de TB_UNITE, que la mesure ne distingue pas.

Contrôle indirect que les séjours 'SSR' sont bien les séjours de SMR : parmi les sorties MCO par mutation vers la destination 2 (SSR/SMR), de 96,3 % (2021) à 100 % (2024-2026, cases sous 10 comptées 0) des cases visibles ont un séjour de type 'SSR' du même patient commençant le même jour (par exemple 1 832 sur 1 902 en 2021, 1 830 sur 1 830 en 2025) (20261019-transfert-mco-smr-meme-jour-resultat). Le brouillon d'origine (« selon l'année, 'SSR', 'SMR' ou les deux ») est contredit.

Points ouverts : la part des UF d'entrée absentes de TB_UNITE dans le « vide » de CODE_AUTORISATION_SSR n'est pas mesurée ; la requête de transfert a filtré `IN ('SSR','SMR')` (équivalent à 'SSR' seul) ; un séjour de SMR qui porterait un autre TYPE_SEJOUR (par exemple 'HDJ' en hospitalisation de jour de SMR) n'est pas mesuré ; la part de ces 'SSR' en hospitalisation complète ou de jour ; les séjours 'SSR' de 2026 (année en cours).
