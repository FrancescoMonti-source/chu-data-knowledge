---
review: unreviewed
id: tarif-ghs-jointure-couverture
kind: empirical
author: Pierre
statement: "Dans CORA, le tarif d'un RSS se retrouve dans PMSI_LIB_GHS_TARIF en joignant CODE_CMD || CODE_GHM à TRIM(GHS) (le GHM complet, pas CODE_GHS), sur la ligne dont la période contient la date choisie ; même ainsi, une part des RSS groupés de 2022 à 2025 ne trouve aucune ligne : mesurer cette part avant de valoriser et ne pas exclure ces RSS en silence."
scope: "CORA de production (CWPROD, schéma CORA_REC), RSS de TB_SYNTH_RSS groupés (CODE_GHM renseigné, CMD différente de 90) finis de 2022 au 2026-10-20, tarif lu au dernier jour du mois de fin du RSS (approximation mensuelle), lus le 2026-10-20"
refuted_if: "au jour près, plus de 95 % des RSS groupés d'une année de 2022 à 2025 trouvent une ligne valide de PMSI_LIB_GHS_TARIF, ou la jointure par CODE_GHS retrouve autant de tarifs que celle par le GHM complet"
maturity: observed
lifecycle: active
terms: [cora:rss, pmsi:ghm]
tables: [cora:PMSI_LIB_GHS_TARIF, cora:TB_SYNTH_RSS]
supported_by: [20261019-tarif-ghs-couverture-4-resultat, 20261019-ghs-tarif-periodes-2-resultat]
depends_on: [referentiels-pmsi-dans-cora]
---
## Pour s'en servir

Pour valoriser un RSS avec le tarif de son GHS :

- **Clé :** `TRIM(s.CODE_CMD) || TRIM(s.CODE_GHM) = TRIM(t.GHS)`. La colonne GHS de PMSI_LIB_GHS_TARIF porte le GHM complet sur 6 caractères (dictionnaire CORA 2020, sources/dictionnaire-cora-2020/PMSI_LIB_GHS_TARIF.txt) ; CODE_GHS est le code du GHS sur 4 caractères, et la colonne de 4 caractères du GHM est CODE_GHM seul. Ne pas joindre par CODE_GHM seul.
- **Période :** la ligne où `DATE_DEBUT <= d <= DATE_FIN` pour la date d choisie (referentiels-pmsi-dans-cora), et dire d.
- **RSS sans ligne :** compter les RSS sans tarif par année avant de valoriser, les montrer à part et ne pas les exclure en silence ; pour les années récentes (2026), la part est quasi nulle, pour 2022 à 2025 elle ne l'est pas.
- Les RSS de GHS 9999 (hors du tarif) sont à part : CODE_GHS = '9999'.

## Ce qui l'appuie

Par année de fin de RSS (20261019-tarif-ghs-couverture-4-resultat), tarif cherché au dernier jour du mois de fin du RSS, GHM complet contre TRIM(GHS), cases <10 comptées 0 :

| Année | RSS groupés | sans ligne de tarif | part avec tarif | dont GHS 9999 |
|---|---|---|---|---|
| 2022 | 161 549 | 12 831 | 92,06 % | 525 |
| 2023 | 169 574 | 13 985 | 91,75 % | 526 |
| 2024 | 178 604 | 14 739 | 91,75 % | 469 |
| 2025 | 191 152 | 31 234 | 83,66 % | 443 |
| 2026 (au 20 octobre) | 138 983 | moins de 10 | 100 % | 275 |

Avec cette clé, presque tous les RSS de 2026 trouvent un tarif : la clé est bonne ; l'écart des années précédentes ne vient donc pas d'une clé erronée. Les RSS de GHS 9999 sont beaucoup moins nombreux que les RSS sans tarif (par exemple 525 contre 12 831 en 2022) : ils n'expliquent pas l'écart.

Périodes de la table (20261019-ghs-tarif-periodes-2-resultat) : DATE_DEBUT la plus récente au 2026-01-01 ; 22 trous de 2 jours ou plus entre deux périodes d'un même couple, moins de 10 chevauchements. Ces trous ne suffisent pas à expliquer 8 à 16 % de RSS sans tarif.

Points ouverts : la cause des RSS sans tarif de 2022 à 2025 n'est pas établie (GHM disparus de la table à la suite des changements de classification, ou périodes manquantes) ; le tarif est lu au dernier jour du mois, non au jour de fin du RSS, donc un RSS fini avant un changement de tarif en cours de mois est comparé au tarif suivant, et la part peut différer légèrement au jour près ; la mesure ne compare pas la jointure par CODE_GHS (la seconde moitié de refuted_if n'est pas testée) ; requête de suite : GHM complets sans tarif par année, en agrégats masqués. Cette mesure dit si un tarif existe, pas s'il est égal à MONTANT_GHS (montant-ghs-rss).
