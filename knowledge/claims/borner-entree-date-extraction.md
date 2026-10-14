---
review: unreviewed
id: borner-entree-date-extraction
kind: empirical
author: Pierre
statement: "Dans CORA, borner DATE_ENTREE au jour de l'extraction retire les séjours à venir : environ 5 650 au 2026-10-14, soit 0,8 % des séjours entrés depuis le 1er janvier et 6,5 % d'un mois d'entrées. Ce sont des venues programmées dans le mois qui suit (consultations externes déjà datées, préadmissions surtout en hôpital de jour), sans RUM, RSS, acte ni diagnostic ; les dates aberrantes sont rares (moins de 100 séjours au-delà d'un mois)."
scope: "CORA de production (CWPROD, schéma CORA_REC), séjours dont DATE_ENTREE est après le 2026-10-14, lus le 2026-10-14"
refuted_if: "à une autre extraction, plus de 10 % des séjours à entrée future entrent au-delà du mois qui suit, ou plus de 10 % ont un RUM, un acte ou un diagnostic"
maturity: observed
lifecycle: active
terms: [cora:sejour, cora:preadmission, cora:mouvement, cora:type-sejour]
tables: [cora:TB_SEJOUR, cora:TB_MVT, cora:TB_MVT_RUM, cora:TB_SYNTH_RSS, cora:TB_ACTE, cora:TB_DIAG]
supported_by: [20261014-entrees-futures-resultat, 20261014-entrees-futures-profil-resultat]
depends_on: []
---
## Pour s'en servir

Quand la période d'une analyse va jusqu'à aujourd'hui, borner l'entrée au jour de l'extraction :

```sql
WHERE s.DATE_ENTREE < TRUNC(SYSDATE) + 1
```

Le filtre de exclure-sejours-sans-sortie-orphelins ne suffit pas : il retire les préadmissions sans sortie, mais pas les consultations externes à venir, qui ont déjà une DATE_SORTIE. Sans la borne, l'analyse compte quelques milliers de venues qui n'ont pas eu lieu, toutes dans le mois qui suit l'extraction : l'erreur est faible sur une année, forte sur le dernier mois.

Une DATE_SORTIE postérieure au jour de l'extraction est une sortie prévue, pas une sortie constatée : ne pas en tirer de durée de séjour. CORA est la base de production : le nombre de séjours à venir change d'une heure à l'autre.

## Ce qui l'appuie

Profil au 2026-10-14, 15:30 (20261014-entrees-futures-profil-resultat) : dans le mois qui suit, 3 190 séjours de STATUT_PROG A et de TYPE_SEJOUR EXT, dont 3 142 ont déjà une DATE_SORTIE ; 2 008 préadmissions (STATUT_PROG P) en HDJ, 248 en MCO, 136 en SSR, moins de 10 en LSJ, sans DATE_SORTIE. Tous ces séjours n'ont que des mouvements commençant dans le futur ; dans chaque catégorie, moins de 10 ont un RUM, un RSS, un acte ou un diagnostic. Au-delà d'un mois : 64 consultations externes et moins de 10 séjours dans chacune des autres catégories. Séjours entrés du 1er janvier au jour de l'extraction : 741 193 ; dans les 30 derniers jours : 86 606.

Répartition par horizon à 15:13 (20261014-entrees-futures-resultat) : 5 466 dans le mois qui suit, 43 avec mouvement entre 1 et 3 mois, 12 entre 3 et 12 mois, 19 entre 1 et 5 ans, moins de 10 au-delà ; le filtre de exclure-sejours-sans-sortie-orphelins en laisse passer 3 119. Entre les deux exécutions, à 17 minutes d'écart, le mois qui suit a gagné plus d'une centaine de séjours : la base reçoit les rendez-vous en continu.

La kb de DIM-code donnait environ 6 000 séjours à entrée future à une autre date d'extraction.
