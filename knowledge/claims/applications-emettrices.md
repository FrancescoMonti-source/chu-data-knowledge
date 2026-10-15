---
review: unreviewed
id: applications-emettrices
kind: empirical
author: Pierre
statement: "Dans CORA, ID_APPLICATION_TRANSFERT dit d'où vient une ligne, et TB_INT_APPLICATION en donne le nom : 10 = flux CPage de production (actes, depuis 2020), 16 = flux OpRoom (interventions, depuis novembre 2023), 17 = Sancare PMSI (diagnostics, depuis décembre 2025), 7 = flux de validation CPage (actes, 2020 seulement) ; −3010, la reprise d'historique, et 0, sans transfert, n'y figurent pas."
scope: "CORA de production (CWPROD, schéma CORA_REC), tables TB_ACTE, TB_DIAG, TB_INTERVENTION et TB_INT_APPLICATION, lues le 2026-10-15"
refuted_if: "TB_INT_APPLICATION donne un autre libellé pour 10, 16 ou 17, ou une de ces applications porte des lignes d'une table ou d'une période autres que celles dites ici"
maturity: observed
lifecycle: active
terms: [cora:acte, cora:diagnostic, cora:intervention]
tables: [cora:TB_INT_APPLICATION, cora:TB_ACTE, cora:TB_DIAG, cora:TB_INTERVENTION]
supported_by: [20261015-applications-libelles-resultat, 20261015-applications-emettrices-resultat]
depends_on: [epoques-codage-actes]
---
## Pour s'en servir

Pour savoir d'où vient un acte, un diagnostic ou une intervention, joindre `ID_APPLICATION_TRANSFERT` à `TB_INT_APPLICATION.ID` :

| Code | Nom dans TB_INT_APPLICATION | Ce qu'il porte |
|---|---|---|
| 10 | CPAGE_PROD->CORA | actes du flux CPage, importés (TYPE_TRANSFERT = 'R') |
| 16 | BLOC_OPROOM_XML=>CORA | interventions du flux OpRoom |
| 17 | SANCARE_PMSI=>CORA | diagnostics venus de Sancare, depuis décembre 2025 (libellé IDG dans TB_DIAG.APPLI_TRANSFERT) |
| 7 | CPAGE_VALID=>CORA | environ 1 200 actes, en 2020 seulement : sans doute le flux de l'environnement de validation de CPage, à écarter |
| −3010 | absent | reprise d'historique : actes de 2014-2016, diagnostics de 2017-2020 (libellé RCP) |
| 0 | absent | diagnostics sans transfert, saisis dans CORA |
| vide | — | actes importés sans application (seconde reprise, 2018-2020) ou saisis dans CORA (ECRAN renseigné) : epoques-codage-actes |

TB_APPLICATION_TRANSFERT, que le dictionnaire désigne, est vide (referentiels-pmsi-dans-cora). Les actes sans application et importés ont des DATE_ACTE aberrantes, de 1900 à 2097 : borner les dates.

## Ce qui l'appuie

TB_INT_APPLICATION (20261015-applications-libelles-resultat) : 17 applications ; 10 CPAGE_PROD->CORA créée en août 2020, 16 BLOC_OPROOM_XML=>CORA en novembre 2023, 17 SANCARE_PMSI=>CORA en décembre 2025, 7 CPAGE_VALID=>CORA sans date ; ni −3010 ni 0.

Lignes par table et application (20261015-applications-emettrices-resultat) : TB_ACTE, application 10, 4,3 millions de lignes ; −3010, environ 870 000 ; 7, 1 205 lignes en 2020 ; sans application, environ 817 000 importées (dates de 1900 à 2097) et 557 000 non importées. TB_DIAG : 0, 4,4 millions depuis 2013 ; −3010 (RCP), 2,7 millions de 2017 à 2020 ; 17 (IDG), 220 lignes en 2025-2026 ; sans application, 2,7 millions (RCP) et 4,3 millions jusqu'en 2017. TB_INTERVENTION : 16, 44 127 lignes depuis 2023.
