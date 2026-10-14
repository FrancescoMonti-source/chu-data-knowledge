---
review: unreviewed
id: rss-mois-recents-non-codes
kind: empirical
author: Pierre
statement: "Dans CORA, les RSS des deux derniers mois ne sont pas encore codés : au 14 octobre 2026, 99 % des RSS finis en octobre et 54 % de ceux de septembre n'ont pas de DP (et sont en CMD 90), contre 2 à 4 % pour juin à août et moins de 1 % avant ; VALID_DIM n'est jamais renseigné et ne dit pas qu'un mois est validé."
scope: "CORA de production (CWPROD, schéma CORA_REC), RSS de TB_SYNTH_RSS finis de juillet 2025 au 2026-10-14, lus le 2026-10-14"
refuted_if: "à une autre date, plus de 10 % des RSS du troisième mois avant l'extraction n'ont pas de DP, ou moins de 30 % de ceux du mois précédent"
maturity: observed
lifecycle: active
terms: [cora:rss]
tables: [cora:TB_SYNTH_RSS, cora:TB_MVT_RUM, cora:TB_DIAG]
supported_by: [20261014-rss-recents-resultat]
depends_on: []
---
## Pour s'en servir

Une analyse PMSI qui va jusqu'au mois de l'extraction doit exclure ou signaler les deux derniers mois, et dire que les mois 3 à 5 avant l'extraction sont encore complétés (quelques %). Pour mesurer la complétude d'un mois, compter les RSS sans DP : `TRIM(DP_RETENU) IS NULL`, qui coïncide avec `CODE_CMD = '90'`. Ne pas se fier à VALID_DIM ni à CODE_GHM, qui est renseigné même sans DP.

## Ce qui l'appuie

RSS par mois de fin au 2026-10-14 (20261014-rss-recents-resultat) : sans DP, 7 538 sur 7 611 en octobre 2026 (99,0 %), 9 509 sur 17 753 en septembre (53,6 %), 554 sur 13 805 en août (4,0 %), 509 sur 16 596 en juillet (3,1 %), 352 sur 17 946 en juin (2,0 %), 167 sur 15 173 en mai (1,1 %), 120 sur 16 768 en avril (0,7 %), puis 0,6 % ou moins, et moins de 10 par mois de juillet à septembre 2025. CMD 90 : le même nombre de RSS que sans DP, à moins de 10 près. CODE_GHM vide : moins de 10 par mois. VALID_DIM : vide pour tous les RSS. Sans aucun diagnostic sur ses mouvements : 6 945 en octobre 2026, 7 876 en septembre, moins de 10 de janvier à août 2026.
