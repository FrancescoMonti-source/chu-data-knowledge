---
review: unreviewed
id: duree-sejour-en-journees
kind: decision
author: Pierre
statement: "Au CHU, la durée d'un séjour CORA se compte en journées, TRUNC(DATE_SORTIE) − TRUNC(DATE_ENTREE) + 1 (un séjour d'un jour compte une journée), et la DMS est la moyenne de ces journées ; les nuitées, sortie − entrée, ne se donnent que si elles sont demandées."
scope: "CORA, toute analyse de durée de séjour"
responsible: Pierre
reconsider_when: "une analyse doit suivre une définition externe de la durée (ATIH, ScanSanté) qui compte autrement"
maturity: documented
lifecycle: active
terms: [cora:sejour]
tables: [cora:TB_SEJOUR]
supported_by: [20261014-convention-duree-sejour]
depends_on: []
---
## Pour s'en servir

Calculer les journées par `TRUNC(s.DATE_SORTIE) - TRUNC(s.DATE_ENTREE) + 1`, à partir des dates du séjour, jamais en additionnant les durées des RUM ou des mouvements. Écrire l'unité dans les tableaux et les figures (« DMS en journées »). Ne donner les nuitées (`TRUNC(s.DATE_SORTIE) - TRUNC(s.DATE_ENTREE)`) que si on les demande.

Exclure de la durée les séjours sans DATE_SORTIE, sans les imputer, et dire combien sont exclus (date-sortie-manquante). Une DATE_SORTIE postérieure au jour de l'extraction est une sortie prévue : l'exclure aussi (borner-entree-date-extraction).

## Ce qui l'appuie

Pierre a fixé cette règle dans la kb de DIM-code, validée le 2026-10-08 (20261014-convention-duree-sejour). La règle remplace l'ancienne recette de la kb (DMS = sortie − entrée), devenue la définition des nuitées, et étend à tout le CHU la règle du projet SMR onco, qui comptait déjà + 1.
