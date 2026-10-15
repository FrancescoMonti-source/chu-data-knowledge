---
review: unreviewed
id: uf-sortie-dernier-mouvement
kind: empirical
author: Pierre
statement: "Dans CORA, le dernier mouvement d'un séjour clos (le plus tardif par DATE_DEBUT_MVT, HEURE_DEBUT_MVT, ID_MVT) n'est presque jamais un mouvement de plateau technique (FLAG_MVT_SITE = 'X') : moins de 10 séjours par an de 2018 à 2025. L'UF du dernier mouvement est l'UF de sortie, sans avoir à exclure ces mouvements."
scope: "CORA de production (CWPROD, schéma CORA_REC), séjours clos de 2018 à 2025, lus le 2026-10-14"
refuted_if: "plus de 0,1 % des séjours clos d'une année ont pour dernier mouvement un mouvement de plateau technique"
maturity: observed
lifecycle: active
terms: [cora:sejour, cora:mouvement, cora:uf]
tables: [cora:TB_SEJOUR, cora:TB_MVT]
supported_by: [20261014-sortie-et-dernier-mvt-resultat]
depends_on: [joindre-uf-par-code]
---
## Pour s'en servir

Pour l'UF de sortie d'un séjour, prendre l'UF du dernier mouvement, trié par `DATE_DEBUT_MVT, HEURE_DEBUT_MVT, ID_MVT`, puis la joindre par son code (joindre-uf-par-code) :

```sql
MAX(TRIM(m.ID_UNITE_M)) KEEP (DENSE_RANK LAST ORDER BY m.DATE_DEBUT_MVT, m.HEURE_DEBUT_MVT, m.ID_MVT)
```

Les mouvements de plateau technique (FLAG_MVT_SITE = 'X') ne tombent pas en dernier : pas besoin de les écarter du tri.

## Ce qui l'appuie

Séjours clos par année de sortie (20261014-sortie-et-dernier-mvt-resultat) : de 672 956 à 897 247 séjours par an, dont moins de 10 chaque année ont un dernier mouvement avec FLAG_MVT_SITE = 'X'.

Le dernier mouvement ainsi trié finit le jour de la sortie pour 99 % ou plus des séjours depuis 2018 (dernier-mouvement-date-la-sortie).
