---
review: unreviewed
id: statut-prog-a-sans-trace-de-preadmission
kind: empirical
author: Francesco
statement: "Dans CORA, TB_SEJOUR.STATUT_PROG = 'A' ne garde pas la trace d'une préadmission, contrairement au dictionnaire : presque tous les séjours MCO passés ont 'A', y compris ceux entrés par les urgences. Ne pas s'en servir pour séparer les séjours programmés des autres."
scope: "CORA de production (CWPROD, schéma CORA_REC), séjours de TB_SEJOUR sortis, reliés à un RSS, entrés de 2022 à 2025, lus le 2026-10-28"
refuted_if: "pour une année de 2022 à 2025, moins de 95 % des séjours entrés par 5701, 5802, 5709, 5015, 5010 ou 5720 ont STATUT_PROG = 'A', ou une autre valeur que 'A' dépasse 1 % des séjours sans urgence repérée"
maturity: provisional
lifecycle: active
terms: [cora:preadmission, cora:sejour, cora:passage-urgences]
tables: [cora:TB_SEJOUR, cora:TB_SYNTH_RSS]
supported_by: [20261028-statut-prog-urgences-mco-resultat, 20261028-dictionnaire-statut-prog-date-creat, 20261014-entrees-futures-profil-resultat]
depends_on: [drapeau-urgence-uf-non-fiable, joindre-rss-par-id-sejour]
---
## Pour s'en servir

Ne pas filtrer STATUT_PROG pour repérer un séjour programmé ou non programmé : sur les séjours passés, il vaut 'A' presque partout. Pour repérer un séjour programmé, prendre sa date de création (sejour-cree-avant-entree-programme). 'P' ne marque que les préadmissions encore à venir. Les autres valeurs ('S', 'H', 'h', 'a', vide) sont rares : ne pas les interpréter sans les mesurer.

## Ce qui l'appuie

Le dictionnaire CORA 2020 dit que 'A' marque un séjour « passé en Admission » dont « on garde la trace comme quoi il a été en preadmission » (20261028-dictionnaire-statut-prog-date-creat). Les données ne gardent pas cette différence. Parmi les séjours MCO sortis avec un RSS, entrés de 2022 à 2025 (20261028-statut-prog-urgences-mco-resultat) :

- entrés par une UF d'urgences, avec au moins une nuit : 34 335 séjours 'A' en 2022, 32 188 en 2023, 32 218 en 2024 et 25 231 en 2025, et moins de 10 par autre valeur ;
- sans urgence repérée, avec au moins une nuit : 32 671, 32 504, 33 361 et 42 932 séjours 'A' ; une autre valeur ne dépasse jamais 20 séjours ;
- même profil sans nuit (65 247 à 97 246 séjours 'A' par an sans urgence repérée).

'P' n'apparaît que sur moins de 10 séjours passés par case, alors qu'il marque les séjours MCO et d'hospitalisation de jour à venir (20261014-entrees-futures-profil-resultat : 248 séjours MCO 'P' dans le mois suivant au 14 octobre 2026). Un séjour programmé passe donc de 'P' à 'A' à l'admission, sans que 'A' le distingue d'une entrée par les urgences.

Points ouverts : les valeurs 'H', 'h' et 'a', absentes du dictionnaire ; les séjours d'avant 2022 et ceux sans RSS ne sont pas mesurés ; TB_HIST_SEJOUR, qui garde l'historique du séjour, pourrait garder l'ancien 'P'.
