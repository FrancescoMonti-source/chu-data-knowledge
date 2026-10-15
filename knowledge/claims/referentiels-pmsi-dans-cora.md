---
review: unreviewed
id: referentiels-pmsi-dans-cora
kind: empirical
author: Pierre
statement: "Dans CORA, les tarifs des GHS se trouvent dans CORA_REC.PMSI_LIB_GHS_TARIF, avec une période de validité (DATE_DEBUT, DATE_FIN) ; CWPROD ne contient ni les listes d'exclusion de CMA, ni les règles de niveau de sévérité, ni de table des applications émettrices renseignée (TB_APPLICATION_TRANSFERT est vide)."
scope: "CORA de production (CWPROD), catalogue Oracle des schémas non maintenus par Oracle, lu le 2026-10-15"
refuted_if: "une table de CWPROD contient les listes d'exclusion de CMA par diagnostic principal, ou TB_APPLICATION_TRANSFERT compte des lignes"
maturity: observed
lifecycle: active
terms: [cora:rss, cora:acte]
tables: [cora:PMSI_LIB_GHS_TARIF, cora:PMSI_LIB_GHS, cora:PMSI_LIB_GMT_TARIF, cora:TB_APPLICATION_TRANSFERT, cora:TB_INT_APPLICATION]
supported_by: [20261015-catalogue-referentiels-resultat]
depends_on: []
---
## Pour s'en servir

- **Tarif d'un GHS :** le lire dans `PMSI_LIB_GHS_TARIF` (colonnes GHS, CODE_GHS, PRIX, BAS, HAUT, CODE_GHM_RACINE), en prenant la ligne dont `DATE_DEBUT`–`DATE_FIN` contient la date choisie, et dire laquelle (date de sortie du RSS, ou une date fixe dans l'année). Un GHM peut avoir plusieurs GHS. `PMSI_LIB_GHS`, sans dates, est plus ancienne et plus courte : ne pas la prendre. Les tarifs des GMT (SMR) sont dans `PMSI_LIB_GMT_TARIF`.
- **Listes d'exclusion de CMA, seuils de sévérité :** ils ne sont pas dans CORA. Les prendre dans les référentiels de l'ATIH (manuel des GHM, annexes), ou dans un package qui les reprend.
- **Nom d'une application émettrice (ID_APPLICATION_TRANSFERT) :** `TB_APPLICATION_TRANSFERT` est vide ; les noms sont dans `TB_INT_APPLICATION` (applications-emettrices).

## Ce qui l'appuie

Catalogue de CWPROD (20261015-catalogue-referentiels-resultat), pour les tables dont le nom évoque les applications, les CMA, la sévérité, les GHS ou les tarifs :

- **Tarifs :** PMSI_LIB_GHS_TARIF (environ 71 500 lignes d'après les statistiques Oracle, avec DATE_DEBUT et DATE_FIN), PMSI_LIB_GHS (891 lignes, sans dates) et PMSI_LIB_GMT_TARIF (environ 23 000 lignes).
- **Applications :** TB_APPLICATION_TRANSFERT (0 ligne d'après les statistiques, avec ID_APPLI et NOM_APPLI) et TB_INT_APPLICATION (17 lignes).
- **Aucune table de CMA ni de sévérité :** SEMANTIQUE_EXCLUSION ne contient qu'une colonne MOT, et TB_NIVEAU_PERTINENCE, vide, porte sur la pertinence.

Les nombres de lignes sont ceux des statistiques Oracle (ALL_TABLES.NUM_ROWS), qui peuvent dater.
