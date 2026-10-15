---
review: unreviewed
id: chainage-actes-oproom-progressif
kind: documentary
author: Pierre
statement: "Le chaînage direct d'un acte CCAM de CORA à son intervention OpRoom (n° d'intervention saisi dans l'acte) couvre environ 4 % des interventions jusqu'à 02/2025, plus de 45 % dès 04/2025 et environ 95 % en 12/2025, sans rattrapage de l'historique."
scope: "OpRoom et CORA, 2023-2026"
maturity: documented
lifecycle: active
terms: [oproom:intervention, cora:acte]
tables: [cora:TB_ACTE, cora:TB_INTERVENTION, oproom:OR_INTERVENTIONS]
supported_by: [20261015-kb-chainage-oproom-cora]
depends_on: []
---
## Pour s'en servir

Ne pas comparer 2025 et 2026 sur le nombre d'actes par intervention, la part d'interventions à plusieurs actes ou l'acte principal sans contrôler le niveau de chaînage : le chaînage direct est rare en 2025 et général en 2026, et les autres voies de rattachement (seule intervention du séjour, date la plus proche, vote par le mapping procédure → CCAM) sont moins directes. Comparer avec un niveau de chaînage constant n'est pas possible quand le chaînage direct est rare l'année de référence ; dire alors que ces comparaisons sont à lire avec réserve.

## Ce qui l'appuie

Couverture mesurée par dim-code (note link:oproom-cora, validée le 08/10/2026), sans rattrapage de l'historique. Relevé de l'étude casemix (QBLOCP, janvier à septembre, hors bloc d'urgence, interventions avec acte), non rejoué par relay : la part des interventions au niveau « chaîné » passe d'environ 20 % en 2025 à environ 77 % en 2026 ; la part des interventions à plusieurs actes passe d'environ 34 % à 42 %. Une standardisation grossière sur le niveau de chaînage attribue environ 70 % de cette hausse au changement de répartition entre niveaux.

Points ouverts : le relevé de l'étude n'est pas une preuve du dépôt ; la standardisation a été faite à la main à partir de deux tableaux.
