---
review: unreviewed
id: developper-sur-qbloct
kind: decision
author: Pierre
statement: "Au CHU, une requête OpRoom se met au point sur QBLOCT, la base de test, et une mesure qui sert de preuve vient de QBLOCP, la base de production ; un résultat de QBLOCT ne décrit pas l'activité réelle."
scope: "OpRoom, toute requête et toute mesure"
responsible: Pierre
reconsider_when: "QBLOCT est rafraîchie à partir de la production et cesse de recevoir des saisies de test, ou Pierre obtient un accès direct à QBLOCP"
maturity: documented
lifecycle: active
terms: [oproom:base]
tables: []
supported_by: [20261014-decision-qbloct]
depends_on: []
---
## Pour s'en servir

- **Mettre au point :** écrire et tester la requête sur QBLOCT (`--base QBLOCT`, ou une extraction de QBLOCT), jusqu'à ce qu'elle tourne et que ses colonnes soient les bonnes.
- **Mesurer :** la faire exécuter sur QBLOCP, par une personne qui y a accès, et n'enregistrer comme preuve que ce résultat. Le champ database de la preuve dit QBLOCP, ou l'extraction de QBLOCP d'où vient le résultat.
- **Un chiffre de QBLOCT :** ne jamais le citer comme un volume d'activité. QBLOCT est une copie figée de la production au premier semestre 2025, à laquelle s'ajoutent des saisies de test en 2026 (README du dossier docs/oproom de DIM-code).

## Ce qui l'appuie

Pierre l'a fixé le 2026-10-14 (20261014-decision-qbloct). Pierre a accès à QBLOCT ; QBLOCP n'est atteinte que par une personne qui y a accès.
