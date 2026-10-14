---
review: unreviewed
id: actes-diags-hors-rss
kind: empirical
author: Pierre
statement: "Dans CORA, le chemin par le RSS (mouvement présent dans TB_MVT_RUM) ne voit qu'une partie des actes et des diagnostics : depuis 2021, moins de la moitié des actes (externes, séances) ; en 2018-2019, 99 % des actes et des diagnostics datés, en 2023-2024 95 à 96 % des diagnostics datés ; en 2016, presque rien. Le chemin par le mouvement (TB_MVT) les voit presque tous."
scope: "CORA de production (CWPROD, schéma CORA_REC), actes et diagnostics datés de 2014 à 2025, lus le 2026-10-14"
refuted_if: "pour une année depuis 2021, plus de 60 % des actes ont leur mouvement dans TB_MVT_RUM, ou plus de 1 % des actes ou des diagnostics ont un ID_MVT absent de TB_MVT"
maturity: observed
lifecycle: active
terms: [cora:acte, cora:diagnostic, cora:mouvement, cora:rss]
tables: [cora:TB_ACTE, cora:TB_DIAG, cora:TB_MVT, cora:TB_MVT_RUM, cora:TB_SYNTH_RSS]
supported_by: [20261014-chemin-rss-actes-diags-resultat]
depends_on: []
---
## Pour s'en servir

Choisir le chemin selon la question, et le dire :

- **Tous les actes ou diagnostics d'un séjour ou d'une période :** par le mouvement, `TB_ACTE.ID_MVT = TB_MVT.ID_MVT`, puis `TB_MVT.ID_SEJOUR`.
- **Le champ PMSI (ce qui a été groupé dans un RSS) :** par le RSS, `TB_MVT_RUM.ID_MVT = TB_ACTE.ID_MVT`. Depuis 2021, il écarte environ 400 000 actes par an, l'activité externe et les séances.

Un acte ou un diagnostic dont l'ID_MVT est absent de TB_MVT est rare (moins de 800 par an en 2018-2019, moins de 10 les autres années) : on peut l'ignorer en le disant. Une série qui compare les années doit garder le même chemin d'un bout à l'autre ; avant 2018 elle bute en plus sur 2016 et 2017 (epoques-codage-actes).

## Ce qui l'appuie

Actes par année de DATE_ACTE (20261014-chemin-rss-actes-diags-resultat) : la part vue par le RSS est de 99,4 % en 2014, 97,7 % en 2015, 3,5 % en 2016 (10 077 sur 284 199), 98,8 % en 2018, 99,0 % en 2019, 62,9 % en 2020, puis de 47,6 % à 49,4 % de 2021 à 2025 (404 320 sur 831 421 en 2025). Le chemin par le mouvement voit tous les actes, sauf 785 en 2018 et 653 en 2019 dont le mouvement manque mais le séjour existe.

Diagnostics par année de DATE_DIAG : 76 % et 73 % en 2014-2015, 2,7 % en 2016, 99 % de 2018 à 2020, 96,0 % en 2023 et 95,5 % en 2024 ; presque aucun en 2021, 2022 et 2025, années qui comptent très peu de diagnostics datés (dater-diagnostic-par-mouvement), et 6,8 millions de diagnostics n'ont pas de DATE_DIAG.
