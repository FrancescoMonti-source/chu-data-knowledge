---
review: unreviewed
id: code-destination-2-est-smr
kind: empirical
author: Pierre
statement: "Dans CORA, pour repérer les sorties d'un séjour MCO vers un SMR, filtrer TB_SEJOUR.CODE_DESTINATION = '2' (SSR/SMR) parmi les sorties de mode 6 ou 7, les modes qui portent une destination ; une destination vide ne dit rien (sortie à domicile ou décès), '3' désigne les soins de longue durée, pas le SMR, et les libellés des codes ne se lisent pas dans CORA (TB_MODE_ES_ADMIN et TB_MODE_ES sont vides)."
scope: "CORA de production (CWPROD, schéma CORA_REC), séjours de TB_SEJOUR reliés à un RSS, hors préadmissions, sortis du 2018-01-01 au 2026-10-19, par année de DATE_SORTIE, lus le 2026-10-19 ; lignes des tables de libellés TB_MODE_ES_ADMIN et TB_MODE_ES comptées le 2026-10-20"
refuted_if: "plus de 1 % des séjours de mode 8 ou 9 d'une année ont une CODE_DESTINATION renseignée, ou plus de 1 % de ceux de mode 6 ou 7 n'en ont pas, ou moins de 90 % des sorties de mode 6 et de destination 2 d'une année depuis 2021 sont suivies d'un séjour 'SSR' du même patient le même jour, ou TB_MODE_ES_ADMIN ou TB_MODE_ES compte des lignes dont le libellé donne à la destination '2' un autre sens que les soins de suite et de réadaptation"
maturity: observed
lifecycle: active
terms: [cora:sejour, pmsi:smr, pmsi:mode-entree-sortie, pmsi:provenance-destination]
tables: [cora:TB_SEJOUR, cora:TB_MODE_ES_ADMIN, cora:TB_MODE_ES]
supported_by: [20261019-destination-sortie-mco-resultat, 20261019-transfert-mco-smr-meme-jour-resultat, 20261019-libelles-destination-provenance-2-resultat]
depends_on: [type-sejour-ssr-seul-pour-le-smr]
---
## Pour s'en servir

Une sortie vers un SMR se lit ainsi : `MODE_SORTIE IN ('6', '7') AND CODE_DESTINATION = '2'`. Le mode 6 est une mutation (dans le CHU), le mode 7 un transfert vers une autre entité juridique (dictionnaire 2020, colonne CODE_PMSI de TB_MODE_ES_ADMIN) : le filtre sur la destination seule les réunit, et les deux ne sont pas interchangeables (transfert-smr-interne-meme-jour pour les distinguer). Ne pas déduire « pas un SMR » d'une destination vide ou autre que '2' sans avoir regardé le mode : pour les sorties à domicile (8) et les décès (9), la destination est vide (à 32 à 90 séjours de mode 8 par an près, de destination 7), et pour les modes 6 et 7 elle est toujours renseignée.

Ne pas prendre '3' pour le SMR : c'est une unité de soins de longue durée, de 7 à 10 fois moins fréquente que '2' de 2020 à 2026 (de 7,3 à 9,8 selon l'année, modes 6 et 7 réunis, cases <10 comptées 0 ; seulement 3,4 fois en 2018 et 4,2 fois en 2019, où la destination 2 n'existe qu'avec le mode 7). Codes de destination du dictionnaire (colonne CODE_DEST_PROV de TB_MODE_ES_ADMIN) : 1 courte durée, 2 SSR, 3 soins de longue durée, 4 psychiatrie, 6 hospitalisation à domicile, 7 structure d'hébergement médico-social. Ne pas chercher ces libellés dans CORA, ni les joindre : TB_MODE_ES_ADMIN et TB_MODE_ES sont vides, le sens d'un code se lit dans le dictionnaire et dans le recoupement ci-dessous. Avant 2021 (en partie en 2020), les mutations internes vers un SMR n'ont pas cette destination : voir mutation-mco-smr-mode-6-depuis-2021.

## Ce qui l'appuie

Séjours MCO par année de sortie, MODE_SORTIE et CODE_DESTINATION (20261019-destination-sortie-mco-resultat), cases visibles :

| Année de sortie | mode 6, destination 2 | mode 7, destination 2 | mode 7, destination 3 |
|---|---|---|---|
| 2018 | 0 | 354 | 104 |
| 2019 | 0 | 296 | 71 |
| 2020 | 523 | 458 | 111 |
| 2021 | 1 907 | 1 453 | 344 |
| 2022 | 1 749 | 1 456 | 371 |
| 2023 | 1 667 | 1 495 | 341 |
| 2024 | 1 732 | 1 306 | 310 |
| 2025 | 1 839 | 1 446 | 341 |
| 2026 (au 19 octobre) | 1 412 | 1 119 | 271 |

Aucune ligne de mode 6 ou 7 n'a une destination vide, et il n'y a aucune ligne de mode 6 avec la destination 2 en 2018 et 2019 : la requête sort toute combinaison présente, même sous 10, donc l'absence de ligne vaut zéro. Les modes 8 (sortie à domicile) et 9 (décès) ont une destination vide, sauf le mode 8 avec la destination 7 (de 32 à 90 séjours par an, 0,02 à 0,05 % des séjours) et moins de 10 séjours de mode 9 en 2025.

Recoupement avec les séjours de SMR (20261019-transfert-mco-smr-meme-jour-resultat) : parmi les sorties MCO de mode 6 et de destination 2, 97,3 % en 2020 (508 sur 522), 96,3 % en 2021, 96,8 % en 2022 et 97,1 % en 2023 (cases visibles) sont suivies d'un séjour 'SSR' du même patient le même jour, puis 100 % des cases visibles de 2024 à 2026 (cases sous 10 comptées 0 ; au moins 98 % si chacune valait 9 ; par exemple 1 832 sur 1 902 en 2021, 1 830 sur 1 830 en 2025) ; les sorties de mode 6 et de destination autre que 2 ne le sont que pour moins de 10 séjours par an. À l'inverse, les sorties de mode 7 et de destination 2 ne le sont presque jamais (au plus 48 séjours par an en cases visibles, en 2023 ; de 11 à 14 en 2018, 2019 et 2022, moins de 10 les autres années ; contre 1 306 à 1 495 sorties de ce type par an de 2021 à 2025) : ce sont des transferts vers un SMR hors CORA. Ces deux observations donnent à '2' le sens SMR pour le CHU, sans dépendre du seul dictionnaire.

Libellés dans CORA (20261019-libelles-destination-provenance-2-resultat, lu le 2026-10-20) : TB_MODE_ES et TB_MODE_ES_ADMIN existent dans CORA_REC (type TABLE, état VALID), et leur comptage exact donne 0 ligne, comme les statistiques Oracle (NUM_ROWS = 0). Les tables sont donc vides, ni illisibles ni mal interrogées : la première requête (20261019-libelles-destination-provenance, 0 ligne sans date) ne disait rien d'autre. Aucun libellé de destination ne se lit dans CORA ; le sens de '2' repose sur le dictionnaire CORA 2020 (sources/dictionnaire-cora-2020/TB_MODE_ES_ADMIN.txt, colonne CODE_DEST_PROV) et sur le recoupement ci-dessus, qui lui donne le sens SMR pour le CHU.

Points ouverts : si un libellé de destination était un jour renseigné dans CORA et disait autre chose pour '2', ce claim serait à revoir ; d'où viennent les libellés que l'interface de CORA affiche (une autre table ou le code applicatif : non cherché). Au niveau du RSS (TB_SYNTH_RSS), le mode de sortie 6 existe (1 056 RSS en 2025 avec la destination 2) alors que le dictionnaire écrit qu'il est « forcément différent de 6 » : le niveau du séjour est le seul mesuré ici pour les règles ci-dessus.
