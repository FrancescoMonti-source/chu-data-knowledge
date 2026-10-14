---
review: unreviewed
id: exclure-sejours-sans-sortie-orphelins
kind: decision
author: Pierre
statement: "Au CHU, un séjour CORA sans DATE_SORTIE est exclu de tout comptage de séjours quand il n'a aucun mouvement, ou quand c'est une préadmission (STATUT_PROG = 'P'), même avec un mouvement, un diagnostic ou un RSS."
scope: "CORA, séjours entrés à partir de 2014"
responsible: Pierre
reconsider_when: "des séjours sans sortie ni mouvement portent des actes, des diagnostics ou un RSS (sejour-sans-sortie-ni-mouvement-vide contesté) ; les préadmissions sans sortie portent des actes ou des RSS en nombre (preadmission-sans-sortie-sans-activite contesté)"
maturity: documented
lifecycle: active
terms: [cora:sejour, cora:preadmission]
tables: [cora:TB_SEJOUR, cora:TB_MVT]
supported_by: [20261014-decision-sejours-sans-mouvement]
depends_on: [sejour-sans-sortie-ni-mouvement-vide, preadmission-sans-sortie-sans-activite]
---
## Pour s'en servir

Avant de compter des séjours, retirer les séjours sans DATE_SORTIE qui n'ont aucun mouvement ou qui sont des préadmissions :

```sql
WHERE NOT (s.DATE_SORTIE IS NULL
           AND (s.STATUT_PROG = 'P'
                OR NOT EXISTS (SELECT 1 FROM CORA_REC.TB_MVT m WHERE m.ID_SEJOUR = s.ID_SEJOUR)))
```

Dire dans l'analyse combien de séjours ont été retirés. Ce filtre ne règle pas les autres séjours sans sortie, restés ouverts à un mouvement sans fin (#33).

## Ce qui l'appuie

Les séjours sans sortie ni mouvement ne sont reliés à rien (sejour-sans-sortie-ni-mouvement-vide) ; les préadmissions sans sortie ne portent presque jamais d'acte ni de RSS (preadmission-sans-sortie-sans-activite). Pierre avait posé la règle avant la mesure, « si elles ne sont chaînées à rien, on peut les virer », puis l'a étendue à toutes les préadmissions sans sortie, y compris celles de 2016 qui ont un RSS et celles qui ont un diagnostic (20261014-decision-sejours-sans-mouvement).
