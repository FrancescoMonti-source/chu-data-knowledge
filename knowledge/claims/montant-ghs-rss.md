---
review: unreviewed
id: montant-ghs-rss
kind: empirical
author: Pierre
statement: "Dans CORA, pour la valorisation GHS d'un RSS groupé, lire TB_SYNTH_RSS.MONTANT_GHS, renseigné et positif pour presque tous les RSS ; ne pas prendre MNT_TOTAL, une autre grandeur plus élevée ; et traiter à part les RSS de GHS 9999, qui n'ont jamais de MONTANT_GHS positif."
scope: "CORA de production (CWPROD, schéma CORA_REC), TB_SYNTH_RSS, RSS groupés (CODE_GHM renseigné, CODE_CMD différent de 90) dont DATE_FIN va de 2018 à 2025, lu le 2026-10-19"
refuted_if: "pour une année de 2018 à 2025, moins de 99 % des RSS groupés hors GHS 9999 ont un MONTANT_GHS positif, ou un RSS de GHS 9999 en a un"
maturity: observed
lifecycle: active
terms: [cora:rss]
tables: [cora:TB_SYNTH_RSS]
supported_by: [20261019-montant-ghs-rss-resultat]
depends_on: [separer-ambulatoire-par-ghm, rss-mois-recents-non-codes]
---
## Pour s'en servir

- **Valoriser le GHS d'un RSS :** `TB_SYNTH_RSS.MONTANT_GHS`. Il est positif pour plus de 99,9 % des RSS groupés qui ont un GHS autre que 9999 (99,975 % au plus bas, en 2022 : 160 984 sur 161 024 ; 100 % les autres années), et pour 99,47 % à 99,77 % de tous les RSS groupés, GHS 9999 compris.
- **GHS 9999 :** `TRIM(CODE_GHS) = '9999'` marque un GHM sans tarif GHS ; MONTANT_GHS n'y est jamais positif. Les exclure ou les isoler dans la valorisation, et le dire. Le GHM complet est `TRIM(CODE_CMD) || TRIM(CODE_GHM)` (separer-ambulatoire-par-ghm).
- **MNT_TOTAL :** autre grandeur, supérieure de 14 % à 17 % au MONTANT_GHS ; ne pas l'employer comme « le GHS ». L'écart vient très probablement des suppléments (réanimation, soins intensifs, surveillance continue, néonatologie, etc.) et des écarts de bornes (EXB, EXH), d'après le dictionnaire, qui liste de nombreuses colonnes MNT_* de suppléments dans TB_SYNTH_RSS, et la convention de DIM-code (« GHS + borne haute − borne basse + suppléments ») ; cela n'est pas mesuré ici : la composition exacte de MNT_TOTAL reste à vérifier (requête 20261020-montant-total-composantes).
- **Période :** les RSS de DATE_FIN en 2026 ne sont pas mesurés (rss-mois-recents-non-codes).

## Ce qui l'appuie

RSS groupés par année de DATE_FIN (20261019-montant-ghs-rss-resultat) :

| Année | RSS groupés | GHS 9999 | MONTANT_GHS positif | hors GHS 9999, positifs | MNT_TOTAL / MONTANT_GHS |
|---|---|---|---|---|---|
| 2018 | 151 165 | 804 | 99,47 % | 100,00 % | 1,139 |
| 2019 | 153 851 | 758 | 99,51 % | 100,00 % | 1,147 |
| 2020 | 142 646 | 660 | 99,54 % | 100,00 % | 1,154 |
| 2021 | 162 009 | 689 | 99,57 % | 100,00 % | 1,157 |
| 2022 | 161 549 | 525 | 99,65 % | 99,98 % | 1,170 |
| 2023 | 169 574 | 526 | 99,69 % | 100,00 % | 1,161 |
| 2024 | 178 604 | 469 | 99,74 % | 100,00 % | 1,152 |
| 2025 | 191 152 | 443 | 99,77 % | 100,00 % | 1,156 |

Chaque année, le nombre de RSS à MONTANT_GHS positif est égal au nombre de RSS positifs hors GHS 9999 : aucun RSS de GHS 9999 n'est valorisé. Le rapport est la somme des MNT_TOTAL sur la somme des MONTANT_GHS, pour les RSS à MONTANT_GHS positif.

GHM de GHS 9999, toutes années 2018-2025 (même preuve) : 14Z08Z 3 962 RSS, 15Z10E 568, 09Z02A 149, 23Z03Z 29, 23M20T 17, puis 04M22Z, 23M15Z et 28Z04Z 11 chacun, et 53 autres GHM, chacun sous 10 RSS, dont 51 médicaux (lettre M). Aucun GHM hors GHS 9999 n'a 100 RSS ou plus sans MONTANT_GHS positif (la requête n'a sorti aucune ligne à ce niveau ; au total, 40 RSS hors GHS 9999 sont sans MONTANT_GHS positif, tous en 2022) : aucun tarif manquant ne se concentre sur un GHM. Les 4 874 RSS de GHS 9999 de 2018 à 2025 se répartissent ainsi : 14Z08Z 81,3 % (3 962), 15Z10E 11,7 % (568).

Points ouverts : l'accord de MONTANT_GHS avec le tarif de PMSI_LIB_GHS_TARIF pour la date retenue n'est pas vérifié (les requêtes ghs-tarif-periodes et tarif-ghs-couverture n'ont pas abouti) : MONTANT_GHS est lu comme présent et positif, non comme juste ; ce que MNT_TOTAL additionne ; la liste de GHS 9999 sort plus large que 14Z08Z et 09Z02A.
