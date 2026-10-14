---
review: unreviewed
id: preadmission-sans-sortie-sans-activite
kind: empirical
author: Pierre
statement: "Dans CORA, une préadmission (STATUT_PROG = 'P') sans DATE_SORTIE ne porte presque jamais d'acte ni de RSS, sauf en 2016 ; une minorité porte un diagnostic depuis 2021."
scope: "CORA de production (CWPROD, schéma CORA_REC), séjours entrés de 2014 à 2025, lus le 2026-10-14"
refuted_if: "au moins 10 % des préadmissions sans DATE_SORTIE d'une année d'entrée autre que 2016 reliées à un acte ou à un RSS"
maturity: observed
lifecycle: active
terms: [cora:sejour, cora:preadmission, cora:rss]
tables: [cora:TB_SEJOUR, cora:TB_MVT, cora:TB_ACTE, cora:TB_DIAG, cora:TB_MVT_RUM]
supported_by: [20261014-sejours-orphelins-resultat]
depends_on: []
---
## Pour s'en servir

Une préadmission restée sans sortie n'est pas un séjour réalisé : son mouvement, quand il existe, ne porte presque jamais d'acte ni de RSS. Ne pas la compter comme un séjour (exclure-sejours-sans-sortie-orphelins). Son mouvement est souvent resté ouvert : elle ressemble alors à un séjour resté ouvert (#33), mais n'en est pas un.

## Ce qui l'appuie

Préadmissions sans DATE_SORTIE, par année d'entrée (20261014-sejours-orphelins-resultat) :

- avec un mouvement : environ 78 900, dont 69 527 en 2017, 7 561 en 2018, 328 en 2019, puis 54 à 213 par an depuis 2021. Reliées à un acte : 10 en 2017, 11 en 2024, moins de 10 les autres années. Reliées à un RSS : 862 sur 885 en 2016, moins de 10 les autres années. Reliées à un diagnostic : 61 sur 110 en 2021, 13 sur 84 en 2022, 23 sur 114 en 2025, moins de 10 ailleurs ;
- sans mouvement : environ 12 900, reliées à rien (sejour-sans-sortie-ni-mouvement-vide).

Points ouverts : ce que sont les préadmissions de 2016 qui ont un RSS (séjours réalisés restés au statut « P » ?) ; d'où viennent les diagnostics des préadmissions depuis 2021.
