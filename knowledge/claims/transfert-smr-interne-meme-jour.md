---
review: unreviewed
id: transfert-smr-interne-meme-jour
kind: empirical
author: Pierre
statement: "Dans CORA, pour retrouver un transfert interne MCO vers SMR, rapprocher par patient le jour civil de sortie d'un séjour MCO et le jour civil d'entrée d'un séjour 'SSR' ; ne pas élargir au lendemain sans mesurer les rapprochements ajoutés, et ne pas se fier au seul mode de sortie 6, qui ne repère pas ces transferts avant 2021."
scope: "CORA de production (CWPROD, schéma CORA_REC), séjours MCO (reliés à un RSS) sortis et séjours 'SSR' entrés du 2018-01-01 au 2026-10-19, hors préadmissions, lus le 2026-10-19"
refuted_if: "élargir le rapprochement au lendemain de la sortie ajoute plus de 10 % de rapprochements sur une année, ou moins de 90 % des sorties MCO de mode 6 et de destination 2 d'une année depuis 2021 sont suivies d'un séjour 'SSR' du même patient le même jour"
maturity: observed
lifecycle: active
terms: [cora:sejour, pmsi:smr, pmsi:mode-entree-sortie]
tables: [cora:TB_SEJOUR, cora:TB_SYNTH_RSS]
supported_by: [20261019-transfert-mco-smr-meme-jour-resultat]
depends_on: [type-sejour-ssr-seul-pour-le-smr]
---
## Pour s'en servir

Joindre un séjour MCO (avec RSS) et un séjour `TYPE_SEJOUR = 'SSR'` (type-sejour-ssr-seul-pour-le-smr) par `ID_PATIENT` avec `TRUNC(DATE_SORTIE)` du MCO = `TRUNC(DATE_ENTREE)` du SMR, la jointure se faisant dans Oracle (l'ID_PATIENT ne sort pas : seuls des agrégats). La fenêtre du lendemain n'ajoute presque rien (moins de 4 % des rapprochements) et n'est pas justifiée sans mesure : ne pas l'élargir en heures ni en jours.

Ne pas remplacer ce rapprochement par `MODE_SORTIE = '6'` pour les sorties d'avant 2021 : le mode 6 n'y repère rien (mutation-mco-smr-mode-6-depuis-2021). À partir de 2021, le mode 6 (avec destination 2) repère 93 à 98 % des rapprochements (1 832 sur 1 878 en 2021, 1 408 sur 1 512 en 2026) ; le reste (transferts de mode 7, sorties de mode 8) existe et se lit par le même rapprochement. Les sorties de mode 7 avec destination 2 sont des transferts vers un SMR extérieur à CORA : le rapprochement ne les trouve pas (code-destination-2-est-smr).

## Ce qui l'appuie

Séjours MCO suivis d'un séjour 'SSR' du même patient le même jour (vue MCO de 20261019-transfert-mco-smr-meme-jour-resultat ; cases visibles ; part calculée sur leur somme) :

| Année de sortie | rapprochements du même jour | dont mode de sortie 6 | dont 7 | dont 8 | ajoutés par le lendemain seul |
|---|---|---|---|---|---|
| 2018 | 1 820 | 0 | 56 | 1 764 | <10 |
| 2019 | 2 065 | 0 | 75 | 1 990 | <10 |
| 2020 | 1 962 | 508 | 101 | 1 353 | <10 |
| 2021 | 1 878 | 1 832 | 31 | 15 | <10 |
| 2022 | 1 749 | 1 690 | 46 | 13 | <10 |
| 2023 | 1 718 | 1 617 | 85 | 16 | <10 |
| 2024 | 1 808 | 1 729 | 51 | 28 | 21 |
| 2025 | 1 936 | 1 830 | 73 | 33 | 71 |
| 2026 (au 19 octobre) | 1 512 | 1 408 | 83 | 21 | 53 |

Les rapprochements ajoutés par le lendemain (séjour 'SSR' commençant le lendemain d'une sortie sans séjour 'SSR' le jour même) sont sous 10 par case jusqu'en 2023 puis 1,2 % (2024 : 21 sur 1 808), 3,7 % (2025 : 71 sur 1 936) et 3,5 % (2026 : 53 sur 1 512) des rapprochements du même jour : le seuil de 10 % n'est atteint par aucune année. Presque tous sont des sorties de mode 8, et leur hausse depuis 2024 n'est pas expliquée.

Du côté des séjours 'SSR' entrés, 1 688 à 2 043 par an de 2018 à 2025 (1 494 en 2026) ont une sortie MCO du même patient le même jour (somme des cases visibles). Le mode de sortie 6 repère 93 à 98 % des rapprochements de 2021 à 2026, mais 0 % en 2018 et 2019 et 26 % en 2020 : voir mutation-mco-smr-mode-6-depuis-2021. Parmi les sorties MCO de mode 6 et de destination 2 depuis 2021, 96,3 à 100 % des cases visibles ont un séjour 'SSR' le même jour (cases sous 10 comptées 0 ; 1 832 sur 1 902 en 2021, 1 408 sur 1 408 en 2026).

Points ouverts : les faux rapprochements (même patient, même jour, sans lien de soins) ne sont pas mesurés ; les séjours d'un patient avec plusieurs sorties MCO le même jour sont comptés chacun côté MCO ; le sens de la hausse des rapprochements du lendemain depuis 2024 ; un séjour de SMR sans TYPE_SEJOUR 'SSR' n'est pas vu.
