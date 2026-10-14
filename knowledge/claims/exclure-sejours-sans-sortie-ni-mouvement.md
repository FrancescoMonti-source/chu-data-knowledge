---
review: unreviewed
id: exclure-sejours-sans-sortie-ni-mouvement
kind: decision
author: Pierre
statement: "Au CHU, un séjour CORA sans DATE_SORTIE et sans aucun mouvement est exclu de tout comptage de séjours, préadmission ou non."
scope: "CORA, séjours entrés à partir de 2014"
responsible: Pierre
reconsider_when: "des séjours sans sortie ni mouvement portent des actes, des diagnostics ou un RSS (sejour-sans-sortie-ni-mouvement-vide contesté)"
maturity: documented
lifecycle: active
terms: [cora:sejour]
tables: [cora:TB_SEJOUR, cora:TB_MVT]
supported_by: [20261014-decision-sejours-sans-mouvement]
depends_on: [sejour-sans-sortie-ni-mouvement-vide]
---
## Pour s'en servir

Avant de compter des séjours, retirer ceux qui n'ont ni DATE_SORTIE ni ligne dans TB_MVT (filtre SQL : sejour-sans-sortie-ni-mouvement-vide). Dire dans l'analyse combien de séjours ont été retirés.

Ce filtre ne règle ni les préadmissions sans sortie qui ont un mouvement (#32), ni les séjours restés ouverts, à un mouvement sans fin (#33).

## Ce qui l'appuie

Ces séjours ne sont reliés à rien (sejour-sans-sortie-ni-mouvement-vide). Pierre avait posé la règle avant la mesure : un séjour qui n'est chaîné à rien est retiré (20261014-decision-sejours-sans-mouvement).
