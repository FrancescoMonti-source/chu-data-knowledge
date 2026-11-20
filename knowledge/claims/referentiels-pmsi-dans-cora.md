---
review: unreviewed
id: referentiels-pmsi-dans-cora
kind: empirical
author: Pierre
statement: "Dans CORA, les tarifs des GHS se trouvent dans CORA_REC.PMSI_LIB_GHS_TARIF, avec une période de validité (DATE_DEBUT, DATE_FIN) ; les listes d'exclusion de CMA (CIM_DP_EXCLU, CIM_LISTE_DIAG_EXCLU, CIM_LISTE_EXCLU_CAV, FG_DP_EXCLUANT) et CIM_HIERARCHIE, qui porte CMA et NIVEAU_SEVERITE par diagnostic, se lisent par CORA_REC.<nom> depuis le 2026-11-03 (elles étaient invisibles avant fin octobre 2026) ; table des applications émettrices renseignée : aucune (TB_APPLICATION_TRANSFERT est vide)."
scope: "CORA de production (CWPROD), catalogue Oracle lu les 2026-10-15, 2026-10-19 et 2026-10-26, comptages des listes d'exclusion le 2026-11-03 ; version des listes et correspondance avec les règles du groupeur de l'ATIH non établies"
refuted_if: "TB_APPLICATION_TRANSFERT compte des lignes, ou un comptage de CORA_REC.CIM_DP_EXCLU ou CIM_HIERARCHIE échoue ou revient vide, ou CIM_HIERARCHIE.CMA est vide pour tous les diagnostics"
maturity: observed
lifecycle: active
terms: [cora:rss, cora:acte]
tables: [cora:PMSI_LIB_GHS_TARIF, cora:PMSI_LIB_GHS, cora:PMSI_LIB_GMT_TARIF, cora:TB_APPLICATION_TRANSFERT, cora:TB_INT_APPLICATION]
supported_by: [20261015-catalogue-referentiels-resultat, 20261019-catalogue-objets-g3-resultat, 20261019-ghs-tarif-periodes-2-resultat, 20261026-schemas-objets-resultat, 20261103-exclusions-cma-lecture-resultat, 20261103-colonnes-exclusions-specialites-resultat]
depends_on: []
---
## Pour s'en servir

- **Tarif d'un GHS :** le lire dans `PMSI_LIB_GHS_TARIF` (colonnes GHS, CODE_GHS, PRIX, BAS, HAUT, CODE_GHM_RACINE), en prenant la ligne où `DATE_DEBUT <= d <= DATE_FIN` pour la date d choisie, et dire laquelle. DATE_FIN est inclusive et jamais vide : ne pas tester « DATE_FIN vide = période en cours » (date de sortie du RSS, ou une date fixe dans l'année). Un GHM peut avoir plusieurs GHS. `PMSI_LIB_GHS`, sans dates, est plus ancienne et plus courte : ne pas la prendre. Les tarifs des GMT (SMR) sont dans `PMSI_LIB_GMT_TARIF`.
- **Listes d'exclusion de CMA, niveau de CMA et de sévérité d'un diagnostic :** lire `CORA_REC.CIM_DP_EXCLU` (DP, DAS), `CIM_LISTE_DIAG_EXCLU` et `CIM_LISTE_EXCLU_CAV` (CODE_DIAG, liste en texte, VERSION_FG), `FG_DP_EXCLUANT` (VERSION_FG, CODE_DP, CODE_DAS) et `CIM_HIERARCHIE` (colonnes CMA, NIVEAU_SEVERITE, ACTIF, VERSION, DATE_DEBUT, DATE_FIN, LISTE_PEDIATRIE). Les tables comptent respectivement 459 856, 207 338, 59 322, 288 709 et 20 121 lignes. Elles portent une version de la fonction groupage (VERSION_FG) : filtrer sur celle qui correspond à l'année du séjour et la dire. Leur concordance avec les annexes de l'ATIH n'est pas vérifiée ; en cas de doute, les prendre à l'ATIH (manuel des GHM, annexes). **ICR :** icr-table-cora-ccam.
- **Nom d'une application émettrice (ID_APPLICATION_TRANSFERT) :** `TB_APPLICATION_TRANSFERT` est vide ; les noms sont dans `TB_INT_APPLICATION` (applications-emettrices).

## Ce qui l'appuie

Catalogue de CWPROD (20261015-catalogue-referentiels-resultat), pour les tables dont le nom évoque les applications, les CMA, la sévérité, les GHS ou les tarifs :

- **Tarifs :** PMSI_LIB_GHS_TARIF (environ 71 500 lignes d'après les statistiques Oracle, avec DATE_DEBUT et DATE_FIN), PMSI_LIB_GHS (891 lignes, sans dates) et PMSI_LIB_GMT_TARIF (environ 23 000 lignes).
- **Applications :** TB_APPLICATION_TRANSFERT (0 ligne d'après les statistiques, avec ID_APPLI et NOM_APPLI) et TB_INT_APPLICATION (17 lignes).
- **Au 2026-10-15, aucune table de CMA ni de sévérité n'était visible :** SEMANTIQUE_EXCLUSION ne contient qu'une colonne MOT, et TB_NIVEAU_PERTINENCE, vide, porte sur la pertinence. Les tables de CORA_CCAM (ci-dessus) n'étaient pas encore visibles au compte.

Périodes de PMSI_LIB_GHS_TARIF (20261019-ghs-tarif-periodes-2-resultat, comptages exacts) : 71 529 lignes pour 7 105 couples GHS-activité, de 2003 à 2026 ; aucune DATE_FIN ni DATE_DEBUT vide ; la période suivante commence le lendemain de la DATE_FIN pour 99,96 % des lignes, avec 22 trous de 2 jours ou plus et moins de 10 chevauchements. Recherche par nom exact des tables d'exclusion, de CIM_HIERARCHIE et de PMSI_CCAM_ICR le 2026-10-19 : aucune visible (20261019-catalogue-objets-g3-resultat) ; le 2026-10-26, après l'ajout des schémas CORA au compte, toutes sont visibles dans CORA_CCAM (20261026-schemas-objets-resultat), et le 2026-11-03 elles se lisent par leurs synonymes de CORA_REC (20261103-exclusions-cma-lecture-resultat ; colonnes dans 20261103-colonnes-exclusions-specialites-resultat). La conclusion « absent » du 2026-10-19 voulait dire illisible pour le compte, pas absent de la base.

Les nombres de lignes sont ceux des statistiques Oracle (ALL_TABLES.NUM_ROWS), qui peuvent dater.
