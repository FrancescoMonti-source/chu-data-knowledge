---
review: unreviewed
id: entree-future-sejour-programme
kind: empirical
author: Pierre
statement: "Dans CORA, environ 5 500 séjours ont une DATE_ENTREE postérieure au jour de l'extraction ; presque tous entrent dans le mois qui suit, ont déjà un mouvement, et plus de la moitié ont déjà une DATE_SORTIE, elle aussi future : ce sont des séjours programmés, et le filtre de exclure-sejours-sans-sortie-orphelins en laisse passer plus de la moitié."
scope: "CORA de production (CWPROD, schéma CORA_REC), séjours dont DATE_ENTREE est après le 2026-10-14, lus le 2026-10-14"
refuted_if: "à une autre date d'extraction, moins de 90 % des séjours à entrée future entrent dans le mois qui suit, ou la plupart n'ont aucun mouvement"
maturity: observed
lifecycle: active
terms: [cora:sejour, cora:preadmission, cora:mouvement]
tables: [cora:TB_SEJOUR, cora:TB_MVT]
supported_by: [20261014-entrees-futures-resultat]
depends_on: []
---
## Pour s'en servir

Quand la période d'une analyse va jusqu'à aujourd'hui, borner aussi l'entrée au jour de l'extraction, en plus du filtre de exclure-sejours-sans-sortie-orphelins, qui ne retire pas ces séjours :

```sql
WHERE s.DATE_ENTREE < TRUNC(SYSDATE) + 1
```

Sans cette borne, l'analyse compte des séjours qui n'ont pas encore eu lieu : quelques milliers, concentrés sur le mois qui suit l'extraction. Une DATE_SORTIE postérieure au jour de l'extraction est une sortie prévue, pas une sortie constatée : ne pas la prendre pour une durée de séjour.

## Ce qui l'appuie

Séjours à entrée future au 2026-10-14 (20261014-entrees-futures-resultat) : 5 466 entrent dans le mois qui suit, tous avec au moins un mouvement ; 2 347 sont des préadmissions et 3 071 ont déjà une DATE_SORTIE. Le filtre de exclure-sejours-sans-sortie-orphelins en laisse passer 3 119. Au-delà d'un mois : 43 séjours avec mouvement entre 1 et 3 mois, 12 entre 3 et 12 mois, 19 entre 1 et 5 ans, moins de 10 au-delà de 5 ans.

La kb de DIM-code donnait environ 6 000 séjours à entrée future à une autre date d'extraction. Le nombre dépend du jour de l'extraction ; seul l'ordre de grandeur et la concentration sur le mois qui suit sont le constat.
