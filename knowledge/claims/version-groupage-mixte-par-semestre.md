---
review: unreviewed
id: version-groupage-mixte-par-semestre
kind: empirical
author: Pierre
statement: "Dans CORA, les RSS finis au premier semestre d'une année portent deux versions de groupage différentes (TB_SYNTH_RSS.VERSION) de 2018 à 2025 : choisir le référentiel de groupage (CMA, regroupements, tarifs) RSS par RSS d'après VERSION, non d'après l'année ni le semestre de fin."
scope: "CORA de production (CWPROD, schéma CORA_REC), RSS de TB_SYNTH_RSS finis du 2018-01-01 au 2026-10-19, par semestre de DATE_FIN, lus le 2026-10-19"
refuted_if: "pour un premier semestre de 2018 à 2025, plus de 99 % des RSS finis portent une seule VERSION"
maturity: observed
lifecycle: active
terms: [cora:rss, pmsi:groupage]
tables: [cora:TB_SYNTH_RSS]
supported_by: [20261019-version-groupage-semestre-resultat]
depends_on: []
---
## Pour s'en servir

Pour appliquer un référentiel de groupage à un RSS (CMA, regroupements de GHM, GHS et tarifs), lire sa `TB_SYNTH_RSS.VERSION` et prendre le référentiel de cette version ; ne jamais appliquer un seul référentiel à tout un semestre ni à toute une année de fin. Pour une comparaison entre RSS d'une même année, regrouper par VERSION. Dans une série annuelle, dire que la version change en cours d'année.

Le second semestre ne porte qu'une version (celle de l'année) : le mélange est propre au premier semestre. Cette preuve ne dit pas quel référentiel de CORA correspond à quelle VERSION, ni à partir de quelle date exacte la nouvelle version s'applique : voir les points ouverts.

## Ce qui l'appuie

RSS par semestre de fin et VERSION (20261019-version-groupage-semestre-resultat). Premiers semestres (part = RSS de la version sur les RSS du semestre, par exemple 25 456 sur 78 305 en 2018-S1) : 2018-S1, 17 (32,5 %) et 18 (67,5 %) ; 2019-S1, 18 (33,2 %) et 19 (66,8 %) ; 2020-S1, 19 (39,6 %) et 20 (60,4 %) ; 2021-S1, 20 (34,9 %) et 21 (65,1 %) ; 2022-S1, 21 (32,1 %) et 22 (67,9 %) ; 2023-S1, 22 (34,0 %) et 23 (66,0 %) ; 2024-S1, 23 (33,3 %) et 24 (66,7 %) ; 2025-S1, 24 (32,5 %) et 25 (67,5 %). La version ancienne pèse environ un tiers des RSS du semestre (32 à 40 %, de 25 456 à 30 940 RSS), ce qui correspond à peu près à deux mois sur six ; la part monte à 39,6 % en 2020 (cause non vérifiée). Les seconds semestres de 2018 à 2025 portent une seule version (100 %) : 18, 19, 20, 21, 22, 23, 24, 25.

Le numéro de version suit l'année de fin (version 18 en fin 2018, 25 en fin 2025). En 2026, tous les RSS finis portent la version 26, premier et second semestre (100 098 RSS en S1, 58 500 en S2) : aucune version mixte cette année.

Points ouverts : le mois exact du changement (le tiers observé est compatible avec un changement début mars, à vérifier par une requête par mois de DATE_FIN) ; pourquoi 2026 n'a pas de version mixte (version 26 appliquée dès janvier ?) ; la correspondance entre VERSION et les tables de référentiel de CORA (referentiels-pmsi-dans-cora) ; si VERSION est la version du groupage du RSS ou celle de sa dernière mise à jour.
