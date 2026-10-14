---
review: unreviewed
id: sejour-sans-sortie-ni-mouvement-vide
kind: empirical
author: Pierre
statement: "Dans CORA, un séjour sans DATE_SORTIE et sans aucun mouvement n'est relié à rien : ni acte, ni diagnostic, ni RSS, préadmission ou non."
scope: "CORA de production (CWPROD, schéma CORA_REC), séjours entrés de 2014 à 2025, lus le 2026-10-14"
refuted_if: "au moins 10 séjours sans DATE_SORTIE et sans ligne dans TB_MVT, d'une même année d'entrée, reliés à un acte (TB_ACTE.ID_SEJOUR) ou à un diagnostic (TB_DIAG.ID_SEJOUR)"
maturity: observed
lifecycle: active
terms: [cora:sejour, cora:rss]
tables: [cora:TB_SEJOUR, cora:TB_MVT, cora:TB_ACTE, cora:TB_DIAG, cora:TB_MVT_RUM]
supported_by: [20261014-sejours-orphelins-resultat]
depends_on: []
---
## Pour s'en servir

Un séjour sans DATE_SORTIE et sans mouvement est un dossier vide : il ne porte aucune activité. Le retirer avant de compter des séjours (exclure-sejours-sans-sortie-orphelins) :

```sql
WHERE NOT (s.DATE_SORTIE IS NULL
           AND NOT EXISTS (SELECT 1 FROM CORA_REC.TB_MVT m WHERE m.ID_SEJOUR = s.ID_SEJOUR))
```

## Ce qui l'appuie

Séjours sans DATE_SORTIE et sans mouvement, entrés de 2014 à 2025 (20261014-sejours-orphelins-resultat) : environ 59 900 en tout, dont environ 12 900 préadmissions (STATUT_PROG = 'P'). Pour chaque année et chaque groupe, N_RELIE_A_RIEN est égal à N_SEJ, et les séjours reliés à un acte, un diagnostic ou un RSS restent sous 10. Ils pèsent surtout en 2014-2015 (environ 1 000 et 1 300 séjours, presque tous les séjours sans sortie de ces années) et en 2017-2019 (16 500 à 20 000 par an) ; quelques dizaines à quelques centaines par an depuis 2020.

Points ouverts : pourquoi CORA garde ces dossiers (création abandonnée, reprise d'historique en 2014-2015 ?).
