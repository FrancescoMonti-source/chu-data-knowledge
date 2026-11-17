---
review: unreviewed
id: seuil-duree-niveaux-severite
kind: empirical
author: Pierre
statement: "Dans CORA, un RSS de GHM de type M ou C n'a un niveau de sévérité 2, 3 ou 4 (6e caractère de CODE_CMD || CODE_GHM) qu'à partir de 3, 4 ou 5 nuitées (TRUNC(DATE_FIN) − TRUNC(DATE_DEBUT)) : un RSS plus court est au plus du niveau inférieur."
scope: "CORA de production (CWPROD, schéma CORA_REC), RSS de TB_SYNTH_RSS finis du 2018-01-01 au 2026-10-19, de type M ou C, niveaux 1 à 4, hors CMD 90, lus le 2026-10-19"
refuted_if: "une cellule du tableau niveau × classe de nuitées, d'effectif visible d'au moins 10, sous le seuil : niveau 2 à moins de 3 nuitées, niveau 3 à moins de 4, niveau 4 à moins de 5"
maturity: observed
lifecycle: active
terms: [cora:rss, pmsi:ghm]
tables: [cora:TB_SYNTH_RSS]
supported_by: [20261019-severite-nuitees-resultat, 20261113-seuils-duree-niveaux-manuel-ghm-2025]
depends_on: []
---
## Pour s'en servir

Pour borner le niveau de sévérité qu'un RSS peut atteindre, ou pour repérer une durée ou un niveau à contrôler, appliquer ces seuils en nuitées : niveau 2 à partir de 3 nuitées, niveau 3 à partir de 4, niveau 4 à partir de 5. Mesurer la durée sur les dates (`TRUNC(DATE_FIN) - TRUNC(DATE_DEBUT)`) ; `DUREE_SEJOUR` donne les mêmes classes sur ces RSS. Le niveau est le 6e caractère du GHM complet `TRIM(CODE_CMD) || TRIM(CODE_GHM)` (CODE_GHM n'a que 4 caractères, separer-ambulatoire-par-ghm) : les lettres J, T, E et Z du 6e caractère ne sont pas des niveaux. La règle est mesurée pour les niveaux 1 à 4 des types M et C ; le manuel des GHM applique les mêmes seuils aux niveaux B, C et D des CMD 14, 15 et 25 (non mesuré ici). Les RSS de CMD 90 (non codés) n'ont pas de niveau.

Ce sont des durées de RSS, pas de séjour ni de RUM. Un RSS d'une durée égale au seuil est possible et fréquent : ne pas exclure l'égalité.

## Ce qui l'appuie

RSS de type M ou C, niveaux 1 à 4, par classe de nuitées (20261019-severite-nuitees-resultat ; toutes années de fin réunies ; aucune ligne, même sous 10, n'existe pour une classe sous le seuil) :

| Type | Niveau | 0 à 2 nuitées | 3 | 4 | 5 et plus |
|---|---|---|---|---|---|
| M | 2 | aucune | 16 743 | 8 897 | 33 725 |
| M | 3 | aucune | aucune | 7 224 | 55 966 |
| M | 4 | aucune | aucune | aucune | 21 787 |
| C | 2 | aucune | 4 566 | 3 108 | 18 499 |
| C | 3 | aucune | aucune | 1 250 | 18 446 |
| C | 4 | aucune | aucune | aucune | 11 108 |

À l'inverse, le niveau 1 couvre toutes les durées (type M : 18 529 RSS de 0 nuit, 30 587 d'une nuit, 35 954 de deux nuits ; type C : 1 020, 25 777 et 21 249). Le seuil est atteint pour des effectifs importants (16 743 RSS de type M de niveau 2 à 3 nuitées) : il joue comme une borne de la classification, non comme un hasard. Le nombre de nuitées de `DUREE_SEJOUR` et celui des dates donnent exactement les mêmes effectifs dans chaque case : DUREE_SEJOUR du RSS est ici compté en nuitées.

Le manuel des GHM 2025 fixe ces seuils (20261113-seuils-duree-niveaux-manuel-ghm-2025) : une durée de séjour minimale de 3 jours pour le niveau 2, 4 pour le niveau 3, 5 pour le niveau 4 ; un RSS plus court que le seuil de sa CMA est groupé au niveau inférieur dont il remplit la durée. Les « jours » du manuel sont ceux que mesurent les dates : les cases à 3, 4 et 5 nuitées du tableau sont pleines, celles d'en dessous vides.

Le brouillon d'origine partait d'un paramètre de l'étude PMCT 6103 (« min_nuits », à valider d'après son propre code) : les données le confirment sur ces RSS.

Points ouverts : le manuel lu est celui de 2025, la mesure couvre 2018-2026 ; les types K, J, T, E et Z ne sont pas mesurés ; la mesure réunit toutes les années de fin ; comme aucune case sous le seuil n'existe pour l'ensemble, aucune année ne peut en avoir une.
