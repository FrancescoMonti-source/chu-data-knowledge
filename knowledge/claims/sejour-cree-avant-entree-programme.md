---
review: unreviewed
id: sejour-cree-avant-entree-programme
kind: empirical
author: Francesco
statement: "Dans CORA, un séjour MCO créé avant son jour d'entrée (jour de TB_SEJOUR.DATE_CREAT antérieur à celui de DATE_ENTREE) est un séjour programmé : moins de 0,2 % des séjours entrés par les urgences le sont. L'inverse ne vaut pas : un séjour créé le jour de son entrée n'est pas pour autant non programmé."
scope: "CORA de production (CWPROD, schéma CORA_REC), séjours de TB_SEJOUR sortis, reliés à un RSS, entrés de 2022 à 2025, lus le 2026-10-28"
refuted_if: "pour une année de 2022 à 2025, plus de 1 % des séjours entrés par 5701, 5802, 5709, 5015, 5010 ou 5720 sont créés avant leur jour d'entrée"
maturity: provisional
lifecycle: active
terms: [cora:preadmission, cora:sejour, cora:passage-urgences]
tables: [cora:TB_SEJOUR, cora:TB_SYNTH_RSS]
supported_by: [20261028-delai-creation-sejour-mco-resultat, 20261028-dictionnaire-statut-prog-date-creat]
depends_on: [drapeau-urgence-uf-non-fiable, joindre-rss-par-id-sejour]
---
## Pour s'en servir

Pour marquer un séjour programmé : `TRUNC(s.DATE_CREAT) < TRUNC(s.DATE_ENTREE)`. Un séjour créé le jour même ou après, sans entrée par les urgences, reste indéterminé : naissance, mutation, entrée directe, ou séjour programmé sans préadmission. Pour « non programmé », dire lequel des deux on retient : entrée par les urgences seule, ou tout séjour qui n'est pas créé avant son entrée. Ne pas prendre STATUT_PROG (statut-prog-a-sans-trace-de-preadmission).

## Ce qui l'appuie

Le dictionnaire CORA 2020 définit DATE_CREAT comme la « date de création de cet enregistrement » (20261028-dictionnaire-statut-prog-date-creat). Les préadmissions sont dans CORA avant l'entrée (20261014-entrees-futures-profil-resultat). Parmi les séjours MCO sortis avec un RSS, entrés de 2022 à 2025 (20261028-delai-creation-sejour-mco-resultat ; parts sur les cases visibles, cases <10 et « masqué » comptées pour 0) :

- entrés par une UF d'urgences : 99,4 % créés le jour de l'entrée avec au moins une nuit (123 876 séjours visibles), 99,5 % sans nuit (46 215) ; créés avant l'entrée : une seule case visible, 10 séjours en 2022, toutes les autres sous 10 ;
- sans urgence repérée, avec au moins une nuit : 45,6 % créés avant le jour d'entrée, 53,1 % le jour même, 1,4 % après (141 458 séjours visibles) ;
- sans urgence repérée, sans nuit : 85,4 % créés avant, 14,2 % le jour même (323 635).

Les séjours créés avant le sont surtout de 2 à 7 jours avant l'entrée (12 081 à 13 055 par an avec nuit, 37 387 à 56 491 sans nuit), plus rarement de 8 à 30 jours avant ; plus de 30 jours avant, au plus 30 par an avec nuit et de 82 à 135 sans nuit.

Points ouverts : la date de création est celle de l'enregistrement dans CORA, pas forcément celle de la décision d'hospitaliser ; ID_CREAT, qui dit quel utilisateur ou quelle application a créé l'enregistrement, n'est pas lu. Les séjours avec nuit sans urgence créés le jour même passent d'environ 16 600 par an (2022-2024) à 24 788 en 2025, cause inconnue. Les séjours d'avant 2022 ne sont pas mesurés.
