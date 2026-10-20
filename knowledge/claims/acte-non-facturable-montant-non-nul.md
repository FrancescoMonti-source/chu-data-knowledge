---
review: unreviewed
id: acte-non-facturable-montant-non-nul
kind: empirical
author: Pierre
statement: "Dans CORA, ne pas lire TB_DET_ACTE.FACTURABLE = 'N' comme un montant nul : pour valoriser des actes de bloc, sommer MNT_TOTAL sans condition sur FACTURABLE ; les actes gratuits (ACTE_GRATUIT = 'O') et pour mémoire (POUR_MEMOIRE = 'O') sont à un montant quasi nul, et une part des 'N' l'est aussi : pour compter des actes valorisés, filtrer sur MNT_TOTAL > 0."
scope: "CORA de production (CWPROD, schéma CORA_REC), activités d'actes (TB_DET_ACTE, ID_ACTIVITE = 1) des actes de site de bloc (TB_SITE.BLOC = 'O', hors site 2620), datés de 2022 à octobre 2026, lu le 2026-10-19"
refuted_if: "une année complète de 2022 à 2025 où moins de 80 % des activités FACTURABLE = 'N' de ces actes portent un MNT_TOTAL positif"
maturity: observed
lifecycle: active
terms: [cora:acte]
tables: [cora:TB_DET_ACTE, cora:TB_ACTE, cora:TB_SITE]
supported_by: [20261019-bloc-montants-actes-resultat, 20261019-drapeaux-activite-resultat]
depends_on: [reperer-actes-de-bloc]
---
## Pour s'en servir

Valoriser des actes de bloc par `SUM(MNT_TOTAL)` sans filtre sur FACTURABLE : en exclure les `FACTURABLE = 'N'` perd des montants positifs (91 % des activités 'N' en 2022-2024, 80 % en 2025 : 15 306 sur 19 077, 50 % en 2026 : 3 325 sur 6 716). Pour compter des actes valorisés, filtrer sur `MNT_TOTAL > 0` : les gratuits, les pour mémoire et une part des 'N' sont à zéro. MNT_TOTAL est vide pour moins de 10 activités par année : la somme n'en est pas faussée.

Ne pas supposer que la part de FACTURABLE = 'N' est stable : elle tombe de 95 % des activités de bloc en 2022 (31 929 sur 33 545) à 18 % en 2026 (6 716 sur 36 503). Un comptage « d'actes facturables » change donc de sens d'une année à l'autre, indépendamment de l'activité.

## Ce qui l'appuie

Activités d'actes de bloc (20261019-bloc-montants-actes-resultat), par année de DATE_ACTE :

| Année | Activités | FACTURABLE = 'N' | dont MNT_TOTAL positif | MNT_TOTAL moyen des 'N' |
|---|---|---|---|---|
| 2022 | 33 545 | 31 929 (95,2 %) | 29 080 (91,1 %) | 253,59 € |
| 2023 | 35 535 | 33 684 (94,8 %) | 30 886 (91,7 %) | 276,70 € |
| 2024 | 36 132 | 31 156 (86,2 %) | 28 380 (91,1 %) | 278,13 € |
| 2025 | 43 564 | 19 077 (43,8 %) | 15 306 (80,2 %) | 285,08 € |
| 2026 (au 19 octobre) | 36 503 | 6 716 (18,4 %) | 3 325 (49,5 %) | 207,48 € |

Le nombre d'activités 'N' à montant nul, vide ou négatif (NVL(MNT_TOTAL, 0) <= 0 dans la requête) reste du même ordre (2 849, 2 798, 2 776, 3 771, 3 391) : c'est le nombre d'activités 'N' à montant positif qui s'effondre en 2025-2026 (29 080, 30 886, 28 380, 15 306, 3 325), et ces montants nuls pèsent 8,9 %, 8,3 %, 8,9 %, 19,8 % puis 50,5 % des 'N' (3 391 sur 6 716 en 2026), soit plus que les gratuits et les pour mémoire réunis : le recouvrement entre ces groupes n'est pas mesuré. Actes gratuits : de 1 312 à 1 404 par an de 2022 à 2025, 446 en 2026, MNT_TOTAL moyen entre 0,39 € et 0,86 € (0,00 € en 2026) ; actes pour mémoire : 30 à 50 par an de 2022 à 2025 (moins de 10 en 2026), MNT_TOTAL moyen 0,00 € de 2022 à 2025. Sur l'ensemble de TB_DET_ACTE, 54,0 % des lignes sont FACTURABLE = 'N' (20261019-drapeaux-activite-resultat).

Le dictionnaire 2020 dit FACTURABLE = 'N' « non facturable selon les règles de facturation et non selon l'information acte gratuit » : c'est cohérent avec un montant calculé malgré tout.

Points ouverts : la marge est étroite en 2025 (80,2 % des 'N' à montant positif pour un seuil de réfutation à 80 %) ; pourquoi la part de 'N' s'effondre en 2025-2026 (changement de paramétrage ou de saisie, non établi) ; la mesure porte sur les actes de site de bloc, non sur les interventions OpRoom ni sur les trois UF rangées dans le bloc (reperer-actes-de-bloc) ; elle ne dit pas si le montant 'N' est facturé.
