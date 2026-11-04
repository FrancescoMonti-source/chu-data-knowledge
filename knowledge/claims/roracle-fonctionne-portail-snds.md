---
review: unreviewed
id: roracle-fonctionne-portail-snds
kind: empirical
author: Pierre
statement: "Sur le portail SNDS (profil 108), ROracle se connecte à IPIAMPR2.WORLD et exécute des requêtes, bien que la liste des packages de la Cnam du 17/11/2025 le dise non fonctionnel : interroger les tables depuis R par ROracle."
scope: "portail SNDS de la Cnam, RStudio Server, profil 108, depuis novembre 2026"
refuted_if: "sur le profil 108, DBI::dbConnect(ROracle::Oracle(), dbname = \"IPIAMPR2.WORLD\") échoue, ou une requête du catalogue ne revient pas"
maturity: observed
lifecycle: active
terms: [snds:portail, snds:profil-108]
tables: []
supported_by: [20261104-snds-familles-tables-resultat, 20261104-packages-r-roracle, 20261104-acces-r-oravue]
depends_on: []
---
## Pour s'en servir

Ouvrir la connexion par `DBI::dbConnect(ROracle::Oracle(), dbname = "IPIAMPR2.WORLD")`, puis `DBI::dbGetQuery()` ou dplyr/dbplyr, qui font calculer Oracle. Ne pas chercher de contournement (odbc, passage par SAS) à cause de la mention « non fonctionnel » de la liste de la Cnam. Dans DIM-code, `executer_requete_cdk()` (src/snds_r/requete_cdk.R) ouvre cette connexion.

## Ce qui l'appuie

La liste des packages en production de la Cnam (17/11/2025) classe ROracle « installé - non fonctionnel » (20261104-packages-r-roracle). La note d'accès à R de la Cnam (04/03/2026) donne pourtant ROracle comme mode d'accès aux tables Oracle pour l'accès permanent (20261104-acces-r-oravue). Le 4 novembre 2026, la requête 20261104-snds-familles-tables, exécutée par ROracle depuis RStudio, est revenue de la base IPIAMPR2 avec 4394 lignes (20261104-snds-familles-tables-resultat).

Points ouverts : la liste de la Cnam peut viser une autre région ou un autre profil ; seul le profil 108 est observé.
