---
review: unreviewed
id: seances-dialyse-un-rss-par-seance
kind: empirical
author: Francesco
statement: "Dans CORA, chaque séance de dialyse (GHM 28Z01Z à 28Z04Z) a son propre RSS, et un même NO_SEJOUR réunit souvent une série de ces RSS : compter les RSS ou sommer NB_SEANCES, jamais les séjours ; NB_DIALYSE et NB_DIP valent 0 sur ces RSS et ne comptent que les suppléments de dialyse des RSS d'hospitalisation, qui ne sont pas des séances."
scope: "CORA de production (CWPROD, schéma CORA_REC), TB_SYNTH_RSS et TB_SEJOUR, RSS de GHM 28Z01Z à 28Z04Z et RSS hors CMD 28 avec NB_DIALYSE ou NB_DIP > 0, finis de 2022 à 2025, lus le 2026-11-12 ; seules les lignes d'au moins 10 patients sont visibles, en pratique 28Z04Z"
refuted_if: "pour une année de 2022 à 2025, la somme de NB_SEANCES des RSS de 28Z04Z d'un groupe d'au moins 10 patients diffère de leur nombre, NB_DIALYSE y est non nul, ou ce groupe a autant de NO_SEJOUR distincts que de RSS"
maturity: observed
lifecycle: active
terms: [cora:rss, cora:sejour, cora:type-prise-en-charge]
tables: [cora:TB_SYNTH_RSS, cora:TB_SEJOUR]
supported_by: [20261112-dialyse-pediatrique-resultat, 20261112-dialyse-ghs-sejour-resultat, 20261112-arrete-forfaits-hemodialyse-ghs]
depends_on: []
---
## Pour s'en servir

Pour compter les séances de dialyse, prendre les RSS de `TRIM(CODE_CMD) = '28' AND TRIM(CODE_GHM) IN ('Z01Z', 'Z02Z', 'Z03Z', 'Z04Z')` et sommer NB_SEANCES ; au CHU, compter ces RSS donne le même chiffre. Ne pas compter les NO_SEJOUR ni les ID_SEJOUR : un séjour porte une série de séances. Ne pas compter NB_DIALYSE : il vaut 0 sur les séances. Les dialyses d'un patient hospitalisé en MCO sont dans NB_DIALYSE (et NB_DIP) des RSS hors CMD 28 : les compter à part, comme suppléments, jamais dans les séances.

Pour les séances des enfants, filtrer sur l'âge recalculé (age-entree-a-recalculer), pas sur le GHS : le GHS 9617 de 28Z04Z marque une prise en charge « en centre pour enfants », sans condition d'âge (arrêté « forfaits », art. 6, 7°). Au CHU, il couvre l'UF 5624, adultes compris.

## Ce qui l'appuie

Le guide méthodologique MCO (2026, chap. VII, § 1 et 2 ; même texte en 2024) permet un RSS par séance ou un RSS réunissant plusieurs séances, avec leur nombre dans « nombre de séances », et met la dialyse d'un patient hospitalisé en MCO dans le RSS de son séjour, en actes et suppléments. Pour la chimiothérapie il demande un numéro de séjour par RSS ; il ne le demande pas pour la dialyse. Le dictionnaire de CORA décrit NB_DIALYSE comme « Nb de dialyse dans le RSS », sans dire qu'il exclut les séances.

Résultat 20261112-dialyse-pediatrique-resultat : pour 28Z04Z, la somme de NB_SEANCES égale le nombre de RSS dans chaque ligne visible (par exemple 11 738 RSS et 11 738 séances pour les patients de 18 ans ou plus en 2025), et NB_DIALYSE comme NB_DIP y valent 0. Les RSS d'hospitalisation avec un supplément ont NB_SEANCES à 0 (de 381 à 431 RSS par an pour les adultes, de 1 594 à 1 802 suppléments de dialyse par an).

Résultat 20261112-dialyse-ghs-sejour-resultat : les séances de 28Z04Z des moins de 18 ans sont toutes dans l'UF 5624 et en GHS 9617, de 2023 à 2025 ; en 2025, 802 RSS pour 60 NO_SEJOUR et 12 patients (1 154 RSS pour 85 séjours en 2023, 1 078 pour 77 en 2024). Moins de 10 patients de 18 ans ou plus ont aussi des séances en GHS 9617 dans l'UF 5624 en 2024 et 2025. Les adultes hors UF 5624 sont en GHS 9605, et moins de 10 patients par an en D11 (hémodialyse en unité de dialyse médicalisée) ou 9999, dont le nombre de RSS est masqué.

Points ouverts : 28Z01Z à 28Z03Z n'ont que des lignes de moins de 10 patients, masquées : l'égalité n'y est pas vue. Ce qui décide du découpage d'une série en séjours (mois, venue) n'est pas mesuré. Une réforme du financement de la dialyse chronique est annoncée pour 2027 : selon un résumé non officiel, un RSS par patient et par semaine, de nouveaux DP Z49.3 à Z49.5 et la fin des anciens GHM et GHS de dialyse ; le texte officiel n'est pas lu. Ne pas appliquer ce claim aux RSS de 2027 sans le relire contre ce texte.
