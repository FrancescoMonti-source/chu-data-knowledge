---
review: unreviewed
id: provenance-urgences-rupture-2023
kind: empirical
author: Pierre
statement: "Dans CORA, ne pas repérer les entrées par les urgences avec TB_SYNTH_RSS.CODE_PROVENANCE = '5' (service d'urgence) : ce code existe de 2018 à 2023, s'effondre en 2023 et n'existe presque plus depuis 2024, et MODE_ENTREE ne le remplace pas, car il ne distingue pas les urgences."
scope: "CORA de production (CWPROD, schéma CORA_REC), tous les RSS de TB_SYNTH_RSS finis du 2018-01-01 au 2026-10-19, par année de DATE_FIN, lus le 2026-10-19"
refuted_if: "plus de 1 % des RSS d'une année de 2024 ou 2025 ont CODE_PROVENANCE = '5', ou plus de 5 % des RSS de provenance '5' d'une année visible ont un MODE_ENTREE autre que 8"
maturity: observed
lifecycle: active
terms: [cora:rss, cora:passage-urgences, pmsi:provenance-destination]
tables: [cora:TB_SYNTH_RSS]
supported_by: [20261019-provenance-mode-entree-rss-resultat, 20261019-forme-code-cim10-resultat, 20261019-version-groupage-semestre-resultat]
depends_on: []
---
## Pour s'en servir

Pour compter ou isoler les entrées par les urgences, ne pas filtrer `CODE_PROVENANCE = '5'` : sur 2018-2022, il ne donne qu'un ordre de grandeur dont la part varie d'une année à l'autre (de 2 à 10 % des RSS) sans que l'on sache pourquoi ; depuis 2024, il ne donne plus rien. Une série par CODE_PROVENANCE traverse donc une rupture en 2023 : ne pas comparer ses parts d'une année à l'autre.

MODE_ENTREE n'est pas un substitut : le mode d'entrée ne dit rien du passage aux urgences (dictionnaire : valeurs 0, 6, 7, 8 seulement) et tous les RSS de provenance '5' ont le mode 8, qui est aussi celui de presque tous les RSS. Aucun champ du RSS ni du séjour ne repère les urgences de façon fiable (sejour-sans-signal-urgences, drapeau-urgence-uf-non-fiable) : en attendant une méthode (#30), nommer les UF d'urgences retenues dans l'analyse et le dire. Depuis 2024, CODE_PROVENANCE est vide pour plus de 96 % des RSS (96,6 % en 2024, 96,3 % en 2025, 96,7 % en 2026, tous modes d'entrée) : ne pas le prendre pour repérer une autre provenance sans avoir compté sa couverture.

## Ce qui l'appuie

RSS par année de fin et CODE_PROVENANCE (20261019-provenance-mode-entree-rss-resultat), part des RSS de l'année (numérateur : RSS de la case ; dénominateur : RSS de l'année, 153 288 en 2018, 154 841, 142 646, 162 009, 161 592, 170 189, 178 692, 191 328 en 2025 et 158 598 en 2026) :

| Année de fin | CODE_PROVENANCE = '5' | part | provenance vide et MODE_ENTREE 8 |
|---|---|---|---|
| 2018 | 3 590 | 2,34 % | 95,9 % (déduit) |
| 2019 | 7 440 | 4,80 % | 91,5 % |
| 2020 | 10 134 | 7,10 % | 88,2 % |
| 2021 | 11 232 | 6,93 % | 90,6 % (déduit) |
| 2022 | 16 168 | 10,01 % | 87,0 % |
| 2023 | 5 306 | 3,12 % | 92,0 % |
| 2024 | <10 | | 96,3 % |
| 2025 | <10 | | 96,0 % |
| 2026 (au 19 octobre) | 60 | 0,04 % | 96,5 % (déduit) |

Les trois cases « masqué » (2018, 2021, 2026) sont retrouvées par différence : RSS de l'année moins les autres cases visibles (6 305, 15 297 et 5 554 RSS ; les nombres de RSS viennent de 20261019-forme-code-cim10-resultat pour 2018 et 2021 et de 20261019-version-groupage-semestre-resultat pour 2026 : 100 098 + 58 500), soit 146 983 RSS en 2018, 146 712 en 2021 et 153 044 en 2026, à moins de 10 près. Le code '5' n'apparaît qu'avec MODE_ENTREE 8 (domicile) : de 2018 à 2023, toutes les cases visibles de provenance '5' sont en mode 8 (aucune autre ligne). Le mode 8 est celui de 95,3 % (2023) à 98,2 % (2018) des RSS : la seule case « provenance vide, mode 8 » pèse de 87,0 % (2022) à 96,5 % (2026) des RSS de chaque année. La part de provenance vide monte de 87,0 % en 2022 à 96,3 % en 2024 et 96,0 % en 2025 pour la case « mode 8 » (elle était déjà de 95,9 % en 2018, quand '5' ne pesait que 2,3 %) : les entrées en provenance '5' ne semblent pas être redistribuées vers une autre provenance renseignée, elles ne sont plus renseignées.

Les autres provenances sont petites : '1' (unité de courte durée) de 1,7 % (2018 : 2 670 RSS) à 3,2 % (2023 : 5 476) des RSS, avec le mode 7 pour 87 % d'entre eux en 2018, 95 % en 2019 et 98,7 % ou plus ensuite ; '7' (hébergement médico-social), de 0,01 % en 2018 à 0,22 % en 2026. Les chiffres du brouillon d'origine (8 % en 2021, 10 % en 2022, 2 % en 2023, 0 % en 2024-2025) venaient des seuls RSS d'interventions de bloc (QBLOCT) : sur tous les RSS, 6,9 %, 10,0 % et 3,1 %, puis moins de 10 RSS, ce qui confirme la rupture.

Points ouverts : la cause de la rupture (changement de saisie ou d'interface en 2023 ?) et sa date exacte (une requête par mois de DATE_FIN la donnerait) ; pourquoi 60 RSS de provenance '5' reviennent en 2026 ; la part des RSS qui entrent réellement par les urgences, que les données ne donnent pas ; des valeurs hors dictionnaire (provenances 'R' et 'U', modes d'entrée 'N' et 'O') apparaissent dans TB_SYNTH_RSS.
