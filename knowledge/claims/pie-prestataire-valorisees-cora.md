---
review: unreviewed
id: pie-prestataire-valorisees-cora
kind: empirical
author: Francesco
statement: "Dans CORA, les RSS du CHU prestataire d'une PIE (MODE_ENTREE et MODE_SORTIE à '0') ont un MONTANT_GHS et un MNT_TOTAL comme les autres, alors que, hors séances de dialyse, de radiothérapie et de chimiothérapie, ils ne sont pas facturés à l'assurance maladie ; le motif 5 de TB_VIDHOSP n'en marque qu'une partie : pour un montant facturé, les repérer par les modes '0'."
scope: "CORA de production (CWPROD, schéma CORA_REC), RSS groupés finis de 2022 à 2025, règles du guide méthodologique MCO 2026, lus le 2026-11-10"
refuted_if: "sur une année, plus de 10 RSS à modes d'entrée et de sortie '0' hors séances ont MONTANT_GHS nul ou vide, ou plus de 90 % d'entre eux ont TB_VIDHOSP.MOTIF_NON_FACT = '5'"
maturity: observed
lifecycle: active
terms: [pmsi:pie, cora:rss, pmsi:mode-entree-sortie]
tables: [cora:TB_SYNTH_RSS, cora:TB_VIDHOSP]
supported_by: [20261110-pie-rss-sejour-resultat, 20261110-guide-pie-prestataire, 20261110-guide-pie-seances]
depends_on: []
---
## Pour s'en servir

Pour un montant facturé à l'assurance maladie (somme de MONTANT_GHS ou de MNT_TOTAL), signaler ou écarter les RSS de PIE où le CHU est prestataire :

```sql
CASE WHEN TRIM(r.MODE_ENTREE) = '0' AND TRIM(r.MODE_SORTIE) = '0' THEN 1 ELSE 0 END AS PIE_PRESTATAIRE
```

Garder les séances de dialyse rénale, de radiothérapie et de chimiothérapie (à repérer par leur racine de GHM dans la CMD 28) : le CHU en facture le GHS ; la dialyse en unité de dialyse médicalisée se facture par un forfait D11. Les autres séances de la CMD 28 (transfusion, aphérèse…) suivent le cas général et s'écartent aussi. Ne pas se fier à TB_VIDHOSP.MOTIF_NON_FACT = '5' pour les repérer : il en manque la plupart. Pour une valorisation d'activité (ce que CORA calcule), les garder, et le dire.

## Ce qui l'appuie

Le guide MCO 2026 (20261110-guide-pie-prestataire) : le prestataire B produit un RSS aux modes d'entrée et de sortie « 0 », ne facture pas l'assurance maladie mais l'établissement demandeur, et code le séjour non facturable avec le motif 5. Les séances de dialyse rénale, de radiothérapie et de chimiothérapie font exception : B en facture le GHS ; pour la dialyse en unité de dialyse médicalisée, un forfait D11 (20261110-guide-pie-seances).

20261110-pie-rss-sejour-resultat : RSS à modes '0' et '0' : 10 en 2022, moins de 10 en 2023, 16 en 2024, 82 en 2025, presque tous hors CMD 28 (CMD 28 : moins de 10 par an). En 2024, les 16 hors CMD 28 ont un MONTANT_GHS positif, pour 18 635 € de GHS et 20 510 € de MNT_TOTAL ; en 2025, 148 140 € et 167 539 €. Le motif 5 de TB_VIDHOSP ne marque que 15 des RSS hors CMD 28 de 2025 (moins de 10 les autres années).

Points ouverts : la hausse de 2025 n'est pas expliquée ; le guide compte comme prestataire « une autre entité géographique de la même entité juridique » (20261110-guide-pie-prestataire) : des PIE entre deux sites du CHU l'expliqueraient, et aussi le motif 5 absent, à vérifier ; on ne sait pas si l'établissement demandeur a bien été facturé ; le motif 5 manquant n'a pas été confronté au fichier VID-HOSP transmis.
