---
review: unreviewed
id: dater-diagnostic-par-mouvement
kind: empirical
author: Pierre
statement: "Dans CORA, ne pas dater ni sélectionner un diagnostic par TB_DIAG.DATE_DIAG : elle est vide pour la majorité des diagnostics, et presque toujours depuis 2021 ; dater par le mouvement ou le séjour."
scope: "CORA de production (CWPROD, schéma CORA_REC), table TB_DIAG, lue le 2026-10-14"
refuted_if: "une année depuis 2021 compte plus de 800 000 diagnostics avec DATE_DIAG"
maturity: observed
lifecycle: active
terms: [cora:diagnostic, cora:mouvement, cora:sejour]
tables: [cora:TB_DIAG, cora:TB_MVT, cora:TB_SEJOUR]
supported_by: [20261014-chemin-rss-actes-diags-resultat, 20261014-epoques-actes-resultat]
depends_on: []
---
## Pour s'en servir

Pour compter des diagnostics par période, les dater par leur mouvement (`TB_MVT.DATE_DEBUT_MVT`, par `TB_DIAG.ID_MVT`) ou par leur séjour. Un filtre sur `DATE_DIAG` perd presque tous les diagnostics depuis 2021, et la perte change d'une année à l'autre.

## Ce qui l'appuie

Diagnostics par année de DATE_DIAG (20261014-chemin-rss-actes-diags-resultat) : plus d'un million par an en 2014-2016 et 2018-2019, 661 315 en 2020, puis 4 027 en 2021, 11 069 en 2022, 349 223 en 2023, 358 313 en 2024 et 10 656 en 2025 ; 6 831 665 diagnostics n'ont pas de DATE_DIAG. La répartition par mois et par application d'origine (20261014-epoques-actes-resultat, niveau DIAGS) donne les mêmes volumes.
