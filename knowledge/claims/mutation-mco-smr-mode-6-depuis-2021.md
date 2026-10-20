---
review: unreviewed
id: mutation-mco-smr-mode-6-depuis-2021
kind: empirical
author: Pierre
statement: "Dans CORA, les transferts internes MCO vers SMR ne sont codés en sortie par mutation (MODE_SORTIE 6, CODE_DESTINATION 2) qu'en partie en 2020 et presque tous depuis 2021 ; avant, le séjour MCO qui précède un séjour 'SSR' du même jour porte le mode 8 (domicile) : pour une série qui commence avant 2021, ne pas compter ces transferts par le mode 6 ni par la destination 2."
scope: "CORA de production (CWPROD, schéma CORA_REC), séjours MCO (reliés à un RSS) sortis de 2018 au 2026-10-19 et séjours 'SSR' entrés sur la même période, hors préadmissions, lus le 2026-10-19"
refuted_if: "plus de 10 % des séjours MCO suivis d'un séjour 'SSR' du même patient le même jour ont le mode de sortie 6 en 2018 ou 2019, ou moins de 90 % en ont le mode 6 sur une année de sortie depuis 2021"
maturity: observed
lifecycle: active
terms: [cora:sejour, pmsi:smr, pmsi:mode-entree-sortie]
tables: [cora:TB_SEJOUR, cora:TB_SYNTH_RSS]
supported_by: [20261019-transfert-mco-smr-meme-jour-resultat, 20261019-destination-sortie-mco-resultat]
depends_on: [transfert-smr-interne-meme-jour, code-destination-2-est-smr]
---
## Pour s'en servir

Pour compter ou suivre dans le temps les transferts internes MCO vers SMR, partir du rapprochement du même jour (transfert-smr-interne-meme-jour), non du mode de sortie MCO. Si une analyse emploie quand même `MODE_SORTIE = '6'` (ou la destination 2, code-destination-2-est-smr), la limiter aux sorties de 2021 et après et le dire : en 2018 et 2019 ce filtre ne trouve aucun transfert interne, et en 2020 il en trouve environ un quart. Une série annuelle de sorties vers un SMR par destination 2 monte de 354 et 296 (2018 et 2019, transferts de mode 7 seuls) à 3 038 à 3 360 par an de 2021 à 2025 : 1 667 à 1 907 par an de cette hausse sont des mutations de mode 6 (changement de codage des transferts internes), mais les sorties de mode 7 avec destination 2 passent aussi de 296 à 458 par an (2018-2020) à 1 306 à 1 495 (2021-2025), hausse que ce claim n'explique pas : ne pas l'attribuer tout entière au codage.

Côté SMR, le mode d'entrée 6 est présent sur 87 à 100 % des séjours 'SSR' précédés d'une sortie MCO le même jour, de 2018 à 2022 et de 2024 à 2026, mais seulement 60 % en 2023 (voir ci-dessous) : il est préférable au mode de sortie MCO avant 2021, pas en 2023.

## Ce qui l'appuie

Sorties MCO suivies d'un séjour 'SSR' du même patient le même jour (20261019-transfert-mco-smr-meme-jour-resultat ; voir le tableau de transfert-smr-interne-meme-jour) : part de ces sorties de mode 6, 0 % en 2018 (0 sur 1 820) et en 2019 (0 sur 2 065), 25,9 % en 2020 (508 sur 1 962), 97,6 % en 2021 (1 832 sur 1 878), 96,6 % en 2022 (1 690 sur 1 749), 94,1 % en 2023 (1 617 sur 1 718), 95,6 % en 2024 (1 729 sur 1 808), 94,5 % en 2025 (1 830 sur 1 936) et 93,1 % en 2026 (1 408 sur 1 512), cases sous 10 comptées 0. Sur 2018-2019, les sorties du même jour portent le mode 8 (1 764 en 2018, 1 990 en 2019), 1 353 en 2020 puis moins de 40 par an depuis 2021 : ce sont des séjours MCO sortis « à domicile » suivis d'un séjour 'SSR' le jour même.

Sorties de mode 6 et destination 2, par année de sortie (20261019-destination-sortie-mco-resultat) : aucune en 2018 et 2019 (aucune ligne), 523 en 2020, 1 907 en 2021, 1 749 en 2022, 1 667 en 2023, 1 732 en 2024, 1 839 en 2025.

Côté SMR (même preuve), part, parmi les séjours 'SSR' qui ont une sortie MCO le même jour (1 795 en 2018, 2 043, 1 938, 1 848, 1 713, 1 688 en 2023, 1 790, 1 933 et 1 494 en 2026), de ceux qui ont le mode d'entrée 6 (par exemple 1 020 sur 1 688 en 2023) : 92,4 % en 2018, 100 % en 2019, 97,9 % en 2020, 91,0 % en 2021, 87,2 % en 2022, 60,4 % en 2023 (596 séjours au mode d'entrée 7, transfert, contre au plus 87 par an les autres années), 99,2 % en 2024, 97,1 % en 2025 et 98,1 % en 2026. Les séjours 'SSR' au mode d'entrée 8 (domicile) avec une sortie MCO de mode 6 le même jour sont 141 en 2021 et 209 en 2022.

Points ouverts : le mois exact du changement de codage en 2020 (une requête par mois de sortie le donnerait) ; la cause du mode d'entrée 7 de 2023 (570 des 596 ont une sortie MCO de mode 6 le même jour) ; le mode 8 d'avant 2021 est inféré du rapprochement (rien ne dit que chacun de ces séjours est un vrai transfert) ; la même mesure pour les transferts vers d'autres secteurs (psychiatrie, soins de longue durée) ; la cause de la hausse des sorties de mode 7 avec destination 2 en 2021 (de 296-458 à 1 306-1 495 par an).
