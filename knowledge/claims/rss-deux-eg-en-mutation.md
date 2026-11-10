---
review: unreviewed
id: rss-deux-eg-en-mutation
kind: empirical
author: Francesco
statement: "Dans CORA, environ 200 RSS par an (de 2022 à 2025) ont des RUM sur deux entités géographiques du CHU, l'UM changeant de site par une mutation (6), contre la règle du guide MCO qui veut un RSS par site ; la cause (paramétrage du groupage par FINESS géographique, saisie des mouvements, liens d'UF sans dates) n'est pas connue."
scope: "CORA de production (CWPROD, schéma CORA_REC), RSS groupés à deux RUM ou plus finis de 2022 à 2025, site lu par l'UF d'hébergement et par les UF de l'UM, lus le 2026-11-10"
refuted_if: "pour une année, moins de 50 ou plus de 1 000 RSS ont des RUM sur deux entités géographiques, ou plus de 10 de ces RSS gardent la même UM au changement de site"
maturity: provisional
lifecycle: active
terms: [cora:rss, cora:rum, cora:um, cora:eg, pmsi:mode-entree-sortie]
tables: [cora:TB_SYNTH_RSS, cora:TB_SYNTH_RUM, cora:TB_EG_UNITE, cora:TB_UNITE_M_UNITE, cora:TB_CONFIG_LISTE]
supported_by: [20261110-rss-plusieurs-eg-resultat, 20261110-rss-plusieurs-eg-um-resultat, 20261110-sejour-plusieurs-rss-eg-resultat, 20261110-guide-sejour-patient-eg, 20261110-guide-un-rss-par-eg, 20261110-guide-mode-sortie-6-7, 20261110-dictionnaire-groupage-finess-geo]
depends_on: [eg-du-rum-par-uf-hebergement]
---
## Pour s'en servir

- Ne pas supposer qu'un RSS est sur un seul site : pour le site, lire chaque RUM (eg-du-rum-par-uf-hebergement). Pour compter les changements de site, compter les paires de RSS d'un même séjour sur deux sites, plus les changements de site entre RUM d'un même RSS (environ 7 % du total).
- Ne pas écrire que ces RSS sont des erreurs de codage : ils contredisent le guide, mais la cause n'est pas établie. Avant de les donner comme liste de contrôle qualité, lire dans TB_CONFIG_LISTE la date d'activation du groupage par FINESS géographique (GRP_FINESS_GEOD) et l'exclusion des RSS antérieurs (GRP_FINESS_GEOE), requête 20261110-config-groupage-finess-geo.

## Ce qui l'appuie

Le guide MCO 2026 : une UM est située dans un seul établissement géographique, et une prise en charge dans deux entités géographiques donne deux séjours-patients (20261110-guide-sejour-patient-eg) ; un seul RSS par séjour-patient dans une entité géographique (20261110-guide-un-rss-par-eg) ; la mutation (6) reste dans la même entité géographique (20261110-guide-mode-sortie-6-7). Le dictionnaire CORA 2020 décrit un réglage du groupage par FINESS géographique, daté, qui peut exclure les RSS générés avant (20261110-dictionnaire-groupage-finess-geo) : le découpage par site dépend donc aussi du paramétrage de CORA.

20261110-rss-plusieurs-eg-resultat : sur 38 451 à 39 358 RSS à deux RUM ou plus par an, de 2022 à 2025, 192, 230, 225 et 203 changent de site d'hébergement par une mutation (6), moins de 10 par un transfert (7), moins de 10 autrement ; 124 à 143 par an sont le seul RSS de leur séjour. Les changements de site entre deux RSS d'un même séjour sont environ 2 900 à 3 200 par an de 2022 à 2024 (20261110-sejour-plusieurs-rss-eg-resultat) : ceux qui restent dans un RSS en font environ 7 %.

20261110-rss-plusieurs-eg-um-resultat : au premier changement de site, pour tous ces RSS et chaque année, l'UM du RUM suivant est sur un autre site que celle du précédent (seule classe présente : « UM d'EG différente ») ; aucun ne garde la même UM. Ce n'est donc pas un simple hébergement sur un autre site. Le site d'une UM est déduit de ses UF (TB_UNITE_M_UNITE), le dictionnaire ne lui donnant pas de site.

Points ouverts : la valeur de GRP_FINESS_GEOD et GRP_FINESS_GEOE au CHU n'est pas lue ; TB_EG_UNITE et TB_UNITE_M_UNITE sont lus sans dates, et une UF déménagée paraîtrait changer de site ; les mouvements (TB_MVT) de ces RSS n'ont pas été regardés.
