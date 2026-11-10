---
review: unreviewed
id: sejour-plusieurs-rss-changement-eg
kind: empirical
author: Francesco
statement: "Dans CORA, hors séries de séances (CMD 28), un séjour (ID_SEJOUR, un NO_SEJOUR) a plusieurs RSS parce que le patient change d'entité géographique du CHU : un RSS par site, le suivant commençant le jour où le précédent finit, en sortie et en entrée 7 ; un transfert (7) entre deux RSS d'un même séjour n'est donc pas une sortie du CHU. Environ 7 % des changements de site restent pourtant dans un seul RSS, codés en mutation (6) alors que l'UM change de site : une erreur de codage."
scope: "CORA de production (CWPROD, schéma CORA_REC), RSS groupés finis de 2022 à 2025 et leurs séjours, règles du guide méthodologique MCO 2026, lus le 2026-11-10"
refuted_if: "pour une année, plus de 10 % des paires de RSS consécutifs d'un même séjour sans séance sont dans la même entité géographique, ou ne s'enchaînent pas le même jour, ou plus de 20 % des changements de site d'une année restent dans un seul RSS, ou plus de 10 de ces RSS gardent la même UM"
maturity: observed
lifecycle: active
terms: [cora:sejour, cora:rss, cora:eg, pmsi:mode-entree-sortie, pmsi:pie]
tables: [cora:TB_SYNTH_RSS, cora:TB_SYNTH_RUM, cora:TB_SEJOUR, cora:TB_EG_UNITE, cora:TB_EG]
supported_by: [20261110-rss-plusieurs-eg-um-resultat, 20261110-sejour-plusieurs-rss-resultat, 20261110-sejour-plusieurs-rss-type-resultat, 20261110-sejour-plusieurs-rss-ecarts-resultat, 20261110-sejour-plusieurs-rss-etab-resultat, 20261110-sejour-plusieurs-rss-eg-resultat, 20261110-rss-plusieurs-eg-resultat, 20261110-pie-rss-sejour-resultat, 20261110-guide-sejour-patient-eg, 20261110-guide-un-rss-par-eg, 20261110-guide-mode-sortie-6-7, 20261110-guide-pie-demandeur]
depends_on: [eg-du-rum-par-uf-hebergement]
---
## Pour s'en servir

- **Compter des séjours :** compter les ID_SEJOUR (ou NO_SEJOUR) distincts, pas les RSS. Environ 3 900 séjours par an ont plusieurs RSS.
- **Montant d'un séjour :** chaque RSS est valorisé à part ; le montant du séjour est la somme de ses RSS, PIE prestataires écartées pour un montant facturé (pie-prestataire-valorisees-cora). Le GHS ne s'additionne pas : un séjour à deux sites a deux GHS.
- **Transferts :** une sortie 7 suivie, le même jour, d'un RSS du même séjour est un changement de site du CHU, pas un transfert vers un autre établissement. Pour compter les transferts hors du CHU, écarter les RSS dont le séjour a un RSS suivant.
- **Durée ou parcours d'un séjour :** de la DATE_DEBUT du premier RSS à la DATE_FIN du dernier ; le site de chaque RSS se lit par ses RUM (eg-du-rum-par-uf-hebergement).
- **Changement de site dans un seul RSS :** il existe (environ 200 RSS par an, presque tous en mutation 6, avec une UM d'un autre site : une erreur de codage, contre la règle du guide). Un RSS n'est donc pas toujours mono-site : pour le site, lire chaque RUM. Pour un contrôle qualité du codage, ces RSS sont la liste à revoir.

## Ce qui l'appuie

Le guide MCO 2026 : une prise en charge successive dans deux entités géographiques donne deux séjours-patients (20261110-guide-sejour-patient-eg) ; un seul RSS par séjour-patient dans une entité géographique (20261110-guide-un-rss-par-eg) ; la mutation (6) reste dans la même entité géographique, le transfert (7) en sort (20261110-guide-mode-sortie-6-7).

Séjours à plusieurs RSS (20261110-sejour-plusieurs-rss-resultat) : 3 897, 4 095, 3 875 et 3 912 de 2022 à 2025. Environ 1 090 par an ont au moins un RSS de séance (presque tous n'ont que des séances) : une série de séances, à plusieurs jours d'écart. Aucun mouvement hors MCO, ou presque, entre deux RSS.

Les autres, environ 2 800 par an, sont des séjours de TYPE_SEJOUR MCO (HDJ : moins de 10, sauf 94 en 2024), à 89 % en GHM de type M (20261110-sejour-plusieurs-rss-type-resultat). Leurs RSS consécutifs s'enchaînent le jour même (écart de 0 jour pour 3 218 paires en 2025 ; les autres écarts sont sous 10 par classe, 20261110-sejour-plusieurs-rss-ecarts-resultat), ce qui écarte l'hospitalisation de semaine. En 2024, 2 963 des 3 071 paires sortent en 7 et 2 968 entrent en 7 (20261110-sejour-plusieurs-rss-etab-resultat).

Les deux RSS d'une paire sont dans deux sites différents (20261110-sejour-plusieurs-rss-eg-resultat, 2022 à 2024) : Charles Nicolle vers Bois-Guillaume 1 206, 1 337, 1 260 ; Saint-Julien vers Charles Nicolle 963, 935, 886 ; Charles Nicolle vers Saint-Julien 601, 648, 485 ; Bois-Guillaume vers Charles Nicolle 213, 228, 222. Même site : 15 et moins de 10 en 2022, deux fois moins de 10 en 2023, 105 et moins de 10 en 2024. Un RSS à cheval sur deux sites : 2 à 3 % des paires.

Les PIE n'expliquent pas ces séjours : moins de 10 séjours à plusieurs RSS par an en ont une (20261110-pie-rss-sejour-resultat), et l'établissement demandeur garde un seul RSS (20261110-guide-pie-demandeur).

Changements de site dans un seul RSS (20261110-rss-plusieurs-eg-resultat) : sur environ 39 000 RSS à deux RUM ou plus par an, 192, 230, 225 et 203 changent de site par une mutation (6), moins de 10 par un transfert (7), moins de 10 autrement ; 124 à 143 par an sont le seul RSS de leur séjour. Rapportés aux changements de site entre RSS (environ 2 900 à 3 200 par an), ils en font environ 7 %. Au premier changement de site, l'UM du RUM suivant est d'un autre site que celle du précédent pour tous ces RSS, chaque année : la seule classe présente est « UM d'EG différente », aucun RSS ne garde la même UM ni deux UM du même site (20261110-rss-plusieurs-eg-um-resultat ; site d'une UM déduit de ses UF par TB_UNITE_M_UNITE, une UM étant située dans un seul établissement géographique, 20261110-guide-sejour-patient-eg). Ce n'est donc pas un simple hébergement sur un autre site.

Points ouverts : les 105 paires Charles Nicolle vers Charles Nicolle de 2024 ne sont pas expliquées ; TB_EG_UNITE n'a pas de dates ; les liens UF-site et UF-UM sont ceux d'aujourd'hui, sans dates ; la cause des mutations entre sites (saisie des mouvements, paramétrage du découpage des RSS) n'est pas connue.
