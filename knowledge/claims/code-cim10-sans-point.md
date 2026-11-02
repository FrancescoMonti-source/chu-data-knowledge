---
review: unreviewed
id: code-cim10-sans-point
kind: empirical
author: Pierre
statement: "Dans CORA, TB_DIAG.CODE_DIAG et TB_SYNTH_RSS.DP_RETENU sont stockés sans point, sans espace et en majuscules (C509, pas C50.9) : écrire les codes de comparaison, les LIKE et les listes sans point, sans normaliser la colonne."
scope: "CORA de production (CWPROD, schéma CORA_REC), TB_DIAG (lignes avec DATE_DIAG) par année de DATE_DIAG et DP des RSS par année de DATE_FIN, de 2018 à 2025, lus le 2026-10-19"
refuted_if: "plus de 0,1 % des codes de TB_DIAG.CODE_DIAG ou de TB_SYNTH_RSS.DP_RETENU d'une année de 2018 à 2025 ont un point, un espace ou une minuscule"
maturity: observed
lifecycle: active
terms: [cora:diagnostic, cora:rss]
tables: [cora:TB_DIAG, cora:TB_SYNTH_RSS]
supported_by: [20261019-forme-code-cim10-resultat, 20261019-dp-rum-marques-et-sans-diag-resultat]
depends_on: []
---
## Pour s'en servir

Écrire les codes CIM-10 sans point dans les filtres : `DP_RETENU = 'C509'`, `CODE_DIAG LIKE 'C50%'`, `SUBSTR(CODE_DIAG, 1, 3) BETWEEN 'C00' AND 'C97'`. Une liste de référence écrite avec point (C50.9) ne trouve rien : retirer le point de la liste (`REPLACE(code, '.', '')`), pas de la colonne. Ne pas envelopper la colonne dans `UPPER(REPLACE(REPLACE(TRIM(...))))` par précaution : c'est inutile et cela empêche d'utiliser un index.

Un code fait 3 à 6 caractères sans point (catégorie à 3 caractères, sous-catégorie à 4, extensions à 5 ou 6) : pour une plage de catégories, comparer `SUBSTR(CODE_DIAG, 1, 3)`, car `BETWEEN 'C00' AND 'C97'` écarterait C971. La colonne est un char(16) : les espaces de fin ne comptent pas (la mesure les a retirés par RTRIM).

DP_RETENU est vide pour les RSS non codés (CMD 90, voir rss-mois-recents-non-codes) : une comparaison sur le DP les écarte sans le dire.

## Ce qui l'appuie

Forme des codes par année (20261019-forme-code-cim10-resultat) : aucune ligne « avec point » et aucune ligne « espace en tête ou interne », ni dans TB_DIAG ni pour le DP des RSS, de 2018 à 2025 (la requête sort une ligne pour toute forme présente, même sous 10 : aucune absente par masquage). Seule exception, une case de minuscules de TB_DIAG en 2024, sous 10 lignes sur environ 358 000 (total de 2024 déduit des parts : 34 158 lignes de 3 caractères pèsent 9,53 %) : les codes sont en majuscules.

Longueur du code sans point (part des lignes de l'année) : pour le DP des RSS, 4 caractères de 78,1 à 81,2 % selon l'année (124 429 RSS en 2018, 154 355 en 2025), 5 caractères de 9,2 à 14,1 %, 3 caractères de 4,6 à 6,0 %, 6 caractères de 2,0 à 4,1 %. TB_DIAG est du même ordre (4 caractères : 66,7 à 76,2 % des lignes de chaque année ; 2024, où cette case est masquée : 69,9 % par différence avec les autres cases, 100 moins 9,53, 15,91 et 4,66). DP vide (code absent) : 2 123 RSS en 2018, 990 en 2019, aucun en 2020 et 2021, 43 en 2022, 615 en 2023, 87 en 2024 et 176 en 2025 : ce sont les RSS de CMD 90 (mêmes effectifs dans 20261019-dp-rum-marques-et-sans-diag-resultat, sauf 2024 où ce nombre est masqué).

Le brouillon d'origine (observation sur CORA : « C50.9 et C509 mêlés, espaces possibles ») est contredit : sur ces années, une seule forme existe. Il reste possible que d'autres tables (hors TB_DIAG et DP_RETENU) ou d'autres périodes mêlent les formes.

Points ouverts : la mesure de TB_DIAG ne porte que sur les lignes qui ont une DATE_DIAG (dater-diagnostic-par-mouvement : elle est presque toujours vide depuis 2021), soit de 661 000 à 1 040 000 lignes par an en 2018-2020, 349 223 en 2023, environ 358 000 en 2024, de 4 027 à 11 069 en 2021, 2022 et 2025 ; la forme des codes sans DATE_DIAG n'est pas mesurée (requête de suite : même mesure par année d'entrée du séjour, via TB_MVT). Les autres colonnes de codes CIM-10 (DAS, diagnostics des RUM, TB_SYNTH_RUM.DIAG_P) ne sont pas mesurées.
