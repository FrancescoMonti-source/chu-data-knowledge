---
review: unreviewed
id: dater-diagnostic-par-mouvement
kind: empirical
author: Pierre
statement: "Dans CORA, TB_DIAG.DATE_DIAG est vide pour environ 6,8 millions de diagnostics, et presque toujours depuis 2021 : moins de 12 000 diagnostics datés par an en 2021, 2022 et 2025, contre plus d'un million par an en 2014-2016 et 2018-2019 ; un diagnostic se date par son mouvement ou son séjour, jamais par DATE_DIAG."
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

Pour compter des diagnostics par période, les dater par leur mouvement (`TB_MVT.DATE_DEBUT_MVT`) ou par leur séjour, en passant par `TB_DIAG.ID_MVT`. Filtrer sur `DATE_DIAG` perd presque tous les diagnostics depuis 2021, et la perte change d'une année à l'autre (350 000 diagnostics datés en 2023 et 2024, 10 000 en 2025).

## Ce qui l'appuie

Diagnostics par année de DATE_DIAG (20261014-chemin-rss-actes-diags-resultat) : 1 066 361 en 2014, 1 225 407 en 2015, 1 470 627 en 2016, 26 024 en 2017, 1 040 319 en 2018, 1 038 588 en 2019, 661 315 en 2020, 4 027 en 2021, 11 069 en 2022, 349 223 en 2023, 358 313 en 2024, 10 656 en 2025 ; sans DATE_DIAG : 6 831 665 lignes, dont 4 977 843 dans un RSS. La répartition par mois et par application d'origine (20261014-epoques-actes-resultat, niveau DIAGS) donne les mêmes volumes : les diagnostics datés viennent de l'application −3010 en 2018-2020, de l'application 0 depuis 2021.
