---
review: unreviewed
id: referentiels-pmsi-dans-cora
kind: empirical
author: Pierre
statement: "Dans CORA, les tarifs des GHS se trouvent dans CORA_REC.PMSI_LIB_GHS_TARIF, avec une période de validité (DATE_DEBUT, DATE_FIN) ; CWPROD ne contient ni les listes d'exclusion de CMA, ni la colonne CMA des diagnostics (CIM_HIERARCHIE n'est pas lisible), ni les règles de niveau de sévérité, ni de table des applications émettrices renseignée (TB_APPLICATION_TRANSFERT est vide)."
scope: "CORA de production (CWPROD), catalogue Oracle des schémas non maintenus par Oracle, lu le 2026-10-15"
refuted_if: "une table de CWPROD contient les listes d'exclusion de CMA par diagnostic principal, ou TB_APPLICATION_TRANSFERT compte des lignes"
maturity: observed
lifecycle: active
terms: [cora:rss, cora:acte]
tables: [cora:PMSI_LIB_GHS_TARIF, cora:PMSI_LIB_GHS, cora:PMSI_LIB_GMT_TARIF, cora:TB_APPLICATION_TRANSFERT, cora:TB_INT_APPLICATION]
supported_by: [20261015-catalogue-referentiels-resultat, 20261019-catalogue-objets-g3-resultat, 20261019-ghs-tarif-periodes-2-resultat]
depends_on: []
---
## Pour s'en servir

- **Tarif d'un GHS :** le lire dans `PMSI_LIB_GHS_TARIF` (colonnes GHS, CODE_GHS, PRIX, BAS, HAUT, CODE_GHM_RACINE), en prenant la ligne où `DATE_DEBUT <= d <= DATE_FIN` pour la date d choisie, et dire laquelle. DATE_FIN est inclusive et jamais vide : ne pas tester « DATE_FIN vide = période en cours » (date de sortie du RSS, ou une date fixe dans l'année). Un GHM peut avoir plusieurs GHS. `PMSI_LIB_GHS`, sans dates, est plus ancienne et plus courte : ne pas la prendre. Les tarifs des GMT (SMR) sont dans `PMSI_LIB_GMT_TARIF`.
- **Listes d'exclusion de CMA, niveau de CMA d'un diagnostic, seuils de sévérité :** ils ne sont pas lisibles dans CORA (ni CIM_DP_EXCLU, CIM_LISTE_DIAG_EXCLU, FG_DP_EXCLUANT, CIM_HIERARCHIE, ni PMSI_CCAM_ICR). Les prendre dans les référentiels de l'ATIH (manuel des GHM, annexes), ou dans un package qui les reprend.
- **Nom d'une application émettrice (ID_APPLICATION_TRANSFERT) :** `TB_APPLICATION_TRANSFERT` est vide ; les noms sont dans `TB_INT_APPLICATION` (applications-emettrices).

## Ce qui l'appuie

Catalogue de CWPROD (20261015-catalogue-referentiels-resultat), pour les tables dont le nom évoque les applications, les CMA, la sévérité, les GHS ou les tarifs :

- **Tarifs :** PMSI_LIB_GHS_TARIF (environ 71 500 lignes d'après les statistiques Oracle, avec DATE_DEBUT et DATE_FIN), PMSI_LIB_GHS (891 lignes, sans dates) et PMSI_LIB_GMT_TARIF (environ 23 000 lignes).
- **Applications :** TB_APPLICATION_TRANSFERT (0 ligne d'après les statistiques, avec ID_APPLI et NOM_APPLI) et TB_INT_APPLICATION (17 lignes).
- **Aucune table de CMA ni de sévérité :** SEMANTIQUE_EXCLUSION ne contient qu'une colonne MOT, et TB_NIVEAU_PERTINENCE, vide, porte sur la pertinence.

Périodes de PMSI_LIB_GHS_TARIF (20261019-ghs-tarif-periodes-2-resultat, comptages exacts) : 71 529 lignes pour 7 105 couples GHS-activité, de 2003 à 2026 ; aucune DATE_FIN ni DATE_DEBUT vide ; la période suivante commence le lendemain de la DATE_FIN pour 99,96 % des lignes, avec 22 trous de 2 jours ou plus et moins de 10 chevauchements. Recherche par nom exact des tables d'exclusion, de CIM_HIERARCHIE et de PMSI_CCAM_ICR : aucune visible (20261019-catalogue-objets-g3-resultat) ; absent veut dire absent ou illisible pour le compte de Pierre.

Les nombres de lignes sont ceux des statistiques Oracle (ALL_TABLES.NUM_ROWS), qui peuvent dater.
