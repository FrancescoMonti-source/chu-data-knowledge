---
review: unreviewed
id: tb-sejour-hospitalisations-et-externes
kind: documentary
author: Pierre
statement: "Dans CORA, TB_SEJOUR enregistre dans une même table les hospitalisations et les consultations externes."
scope: "CORA, dictionnaire des données 2020, table TB_SEJOUR"
maturity: documented
lifecycle: active
terms: [cora:sejour, cora:consultation-externe]
tables: [cora:TB_SEJOUR]
supported_by: [20261013-dictionnaire-tb-sejour]
depends_on: []
---
Le titre de la table dans le dictionnaire de l'éditeur range les deux sortes de séjours ensemble. Un comptage de TB_SEJOUR sans filtre compte donc aussi des consultations externes.

Le dictionnaire ne dit pas dans quelle proportion. Il présente TYPE_SEJOUR comme le moyen de distinguer l'externe de l'hospitalisation ; dim-code a observé que ce champ n'est pas fiable (étape 4 du plan).

Points ouverts : la proportion de consultations externes (étape 2 du plan) ; le dictionnaire date de 2020 et n'a pas été comparé à la version installée au CHU.
