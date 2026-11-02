---
review: unreviewed
id: duree-sejour-journees-ou-nuitees
kind: decision
author: Pierre
statement: "Au CHU, pour une hospitalisation complète CORA, le nombre de journées vaut sortie − entrée + 1 et le nombre de nuitées sortie − entrée ; quand on demande une durée de séjour, une DMS ou un équivalent sans préciser l'unité, demander s'il s'agit de journées ou de nuitées."
scope: "CORA, durée des séjours d'hospitalisation complète"
responsible: Pierre
reconsider_when: "une analyse doit suivre une définition externe de la durée (ATIH, ScanSanté) qui compte autrement, ou la règle doit s'étendre aux séjours hors hospitalisation complète"
maturity: documented
lifecycle: active
terms: [cora:sejour, cora:duree-sejour]
tables: [cora:TB_SEJOUR]
supported_by: [20261014-revue-pr38, 20261019-ghm-sixieme-duree-rss-resultat]
depends_on: []
---
## Pour s'en servir

Devant « durée de séjour », « DMS » ou « durée moyenne » sans unité, ne pas choisir : demander à la personne si elle veut des journées ou des nuitées. Puis, pour les séjours d'hospitalisation complète, à partir des dates du séjour (pour les nuitées d'un RSS, TB_SYNTH_RSS.DUREE_SEJOUR convient : elle est déjà en nuitées, égale à `TRUNC(DATE_FIN) - TRUNC(DATE_DEBUT)`, sauf pour les séances de la CMD 28, où elle vaut au moins 1) :

```sql
TRUNC(s.DATE_SORTIE) - TRUNC(s.DATE_ENTREE) + 1 AS NB_JOURNEES,
TRUNC(s.DATE_SORTIE) - TRUNC(s.DATE_ENTREE)     AS NB_NUITEES
```

Écrire l'unité dans les tableaux et les figures (« DMS en journées »). Ne pas additionner les durées des RUM ou des mouvements. Exclure les séjours sans DATE_SORTIE, sans les imputer, et dire combien sont exclus (date-sortie-manquante) ; exclure aussi une DATE_SORTIE postérieure au jour de l'extraction, qui est une sortie prévue (borner-entree-date-extraction).

## Ce qui l'appuie

Pierre l'a fixé dans sa revue de la PR #38 (20261014-revue-pr38). La kb de DIM-code comptait par défaut en journées ; Pierre préfère que l'agent demande l'unité.
