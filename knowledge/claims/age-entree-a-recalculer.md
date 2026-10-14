---
review: unreviewed
id: age-entree-a-recalculer
kind: empirical
author: Pierre
statement: "Dans CORA, TB_SYNTH_RSS.AGE_ENTREE est vide pour les enfants de moins d'un an et faux de plus d'un an pour 21 % des RSS de 2022 ; ailleurs il est égal à l'âge recalculé pour 99,7 % des RSS. L'âge à l'entrée se recalcule : FLOOR((TB_SYNTH_RSS.DATE_DEBUT − TB_PATIENT.DATE_NAIS) / 365,25)."
scope: "CORA de production (CWPROD, schéma CORA_REC), RSS de TB_SYNTH_RSS finis de 2018 à 2025, lus le 2026-10-14"
refuted_if: "AGE_ENTREE est renseigné pour plus de 10 % des RSS d'enfants de moins d'un an d'une année, ou l'écart de plus d'un an touche moins de 1 % des RSS de 2022"
maturity: observed
lifecycle: active
terms: [cora:rss, cora:sejour]
tables: [cora:TB_SYNTH_RSS, cora:TB_PATIENT, cora:TB_SEJOUR, cora:TB_MVT, cora:TB_MVT_RUM]
supported_by: [20261014-age-entree-resultat]
depends_on: []
---
## Pour s'en servir

Recalculer l'âge à l'entrée plutôt que lire AGE_ENTREE :

```sql
FLOOR((r.DATE_DEBUT - p.DATE_NAIS) / 365.25) AS AGE_ENTREE_CALCULE
```

avec le patient du séjour (TB_SEJOUR.ID_PATIENT vers TB_PATIENT). AGE_ENTREE ferait disparaître les nourrissons (vide) et fausserait 2022. Le calcul lit DATE_NAIS : la requête ne sort que des agrégats (tranches d'âge, effectifs masqués), jamais l'âge ni la date d'un patient.

## Ce qui l'appuie

RSS par année de fin et tranche d'âge recalculé (20261014-age-entree-resultat) :

- **Moins d'un an :** AGE_ENTREE vide pour 5 853 des 5 863 RSS de 2018, pour tous ceux de 2021 et de 2024 ; les autres années, N est masqué mais AGE_ENTREE est vide pour 4 777 à 5 913 RSS et moins de 10 sont comparables.
- **Un an ou plus :** égal à l'âge recalculé pour 99,7 à 99,95 % des RSS, sauf en 2022 : 122 110 égaux, 437 à un an près et 33 005 à plus d'un an d'écart sur 155 552 (21,2 %). Écart de plus d'un an les autres années : de moins de 10 à 80 RSS.

Le patient vient du séjour d'un mouvement du RSS (TB_MVT_RUM → TB_MVT → TB_SEJOUR).
