---
review: unreviewed
id: uhcd-reperer-par-um
kind: empirical
author: Francesco
statement: "Au CHU, dans CORA, les UM d'UHCD sont 5701, 5720, 5802, 5015 et 5010 : l'UF de même code a, dans TB_UNITE, le type d'autorisation 07A (UHCD des urgences générales) ou 07B (UHCD des urgences pédiatriques). Ni le drapeau UHCD de TB_UNITE ni un GHS 5xxx ne repèrent l'UHCD."
scope: "CORA de production (CWPROD, schéma CORA_REC), UF de TB_UNITE des pôles qui contiennent une UF d'urgences, lues le 2026-10-14 ; RSS de TB_SYNTH_RSS finis en 2025, groupés, hors CMD 90 et GHS 9999, d'un seul RUM, lus le 2026-10-27"
refuted_if: "une UF de TB_UNITE hors de ces cinq a le type 07A ou 07B, ou, pour 2025, plus de 5 % des RSS d'un seul RUM dans l'UM 5701, 5720, 5015 ou 5010 sont groupés hors d'un GHS 5xxx"
maturity: observed
lifecycle: active
terms: [cora:rss, cora:passage-urgences]
tables: [cora:TB_UNITE, cora:TB_UNITE_MEDICALE, cora:TB_SYNTH_RSS, cora:TB_SYNTH_RUM]
supported_by: [20261014-structure-uf-urgences-resultat, 20261027-guide-mco-autorisation-uhcd, 20261027-arrete-forfaits-uhcd, 20261027-tarif-ghs-5xxx-uhcd-resultat]
depends_on: []
---
## Pour s'en servir

```sql
JOIN CORA_REC.TB_SYNTH_RUM ru ON ru.ID_RSS = s.ID_RSS
JOIN CORA_REC.TB_UNITE_MEDICALE u ON u.ID_UNITE_MED = ru.ID_UNITE_MEDICALE
WHERE TRIM(u.CODE_UNITE_MED) IN ('5701', '5720', '5802', '5015', '5010')
```

- Pour revoir la liste, lire les UF de TB_UNITE dont TYPE_AUTORISATION vaut '07A' ou '07B', comme la requête 20261014-structure-uf-urgences.
- Le drapeau UHCD de TB_UNITE ne repère rien : il n'est jamais 'O' (drapeaux-cora-valeurs-propres).
- Un GHS 5xxx ne repère pas l'UHCD : des GHS de l'annexe 1 et des GHS intermédiaires sont aussi en 5xxx (tarif-ghs-par-ghm-et-code-ghs).
- Ces codes sont aussi des codes d'UF : dans CORA, chacun est une UF de TB_UNITE liée à l'UM de même code et de même libellé (20261014-structure-uf-urgences-resultat), et un mouvement (TB_MVT.ID_UNITE_M) y porte ce code comme UF. Ce claim lit l'UM du RUM, dans le contexte cora ; hors de ce contexte (EDSaN par exemple), ne pas lire ces codes comme des UM sans le vérifier.

## Ce qui l'appuie

Le type d'autorisation d'une UM se déclare dans le fichier IUM, pas dans le RUM ; 07A est l'UHCD des structures des urgences générales, 07B celle des urgences pédiatriques (20261027-guide-mco-autorisation-uhcd). Parmi les UF de TB_UNITE des pôles qui contiennent une UF d'urgences, cinq ont l'un de ces types, chacune liée à l'UM de même code et de même libellé : 5701 (S.A.U. urgences médicales), 5720 (urgences St Julien) et 5802 (S.A.U. urgences chirurgicales) en 07A, 5015 et 5010 (urgences et UHCD pédiatriques, médicales et chirurgicales) en 07B (20261014-structure-uf-urgences-resultat).

Une prise en charge en UHCD qui ne produit qu'un RUM est facturée par un GHS monorum UHCD de l'annexe 1 ter, quelle que soit sa durée (art. 6 quater et 12, 20261027-arrete-forfaits-uhcd). Les RSS de 2025 vont dans ce sens : dans 5701, 5720, 5015 et 5010, 19 532 RSS d'un seul RUM sont dans un GHS 5xxx, et moins de 10 par UM dans un autre GHS (20261027-tarif-ghs-5xxx-uhcd-resultat).

Points ouverts : 5802 n'est pas parmi les quinze UM qui ont le plus de RSS d'un seul RUM en 5xxx en 2025, et son activité d'UHCD n'est pas mesurée ; les GHS de ces RSS ne sont pas confrontés code par code à l'annexe 1 ter ; les RSS de plusieurs RUM passés par ces UM ne sont pas comptés ; seule l'année 2025 est lue.
