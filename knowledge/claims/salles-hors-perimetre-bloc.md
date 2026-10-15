---
review: unreviewed
id: salles-hors-perimetre-bloc
kind: decision
author: Pierre
statement: "Au DIM, une analyse des blocs écarte les salles interventionnelles : la salle Gillies et les endoscopies (Endo 1 et Endo 2)."
scope: "OpRoom, analyses de casemix et de temps de bloc du DIM"
responsible: Pierre
reconsider_when: "ces salles entrent dans le périmètre d'une étude de bloc"
maturity: documented
lifecycle: active
terms: [oproom:intervention]
tables: [oproom:OR_INTERVENTIONS]
supported_by: [20261015-decision-salles-interventionnelles]
depends_on: []
---
## Pour s'en servir

Écarter les interventions de la salle Gillies (DEVE_GILLIES) et des endoscopies (DER_ENDO1, DER_ENDO2), repérées par le code de salle puis, par sécurité, par un nom qui contient Gillies ou Endo 1 ou 2. Garder les autres salles, dont la salle d'urgences de gynécologie.

## Ce qui l'appuie

Décision de Pierre le 08/10/2026, consignée dans la configuration de l'étude casemix de dim-code.

Points ouverts : le motif (activité interventionnelle hors bloc opératoire) n'est pas documenté ici.
