---
review: unreviewed
id: type-sejour-suit-mode-hospit-um
kind: empirical
author: Francesco
statement: "Dans CORA, depuis 2021, TYPE_SEJOUR d'un séjour qui a un RSS suit le mode d'hospitalisation de l'UM retenue, même pour un séjour de 0 nuit : 'HDJ' pour une UM d'hospitalisation partielle ou mixte, 'MCO' pour une UM d'hospitalisation complète ; jusqu'en 2019, tout est 'MCO'. Pour classer par type d'unité sur une période qui commence avant 2021, lire TB_UNITE_MEDICALE.MODE_HOSPIT de l'UM retenue."
scope: "CORA de production (CWPROD, schéma CORA_REC), séjours 'MCO' et 'HDJ' reliés à un RSS par TB_SYNTH_RSS.ID_SEJOUR, sortis de 2018 à août 2026, lus le 2026-11-02"
refuted_if: "pour une année de 2021 à 2025, plus de 2 % des séjours 'HDJ' dont l'UM retenue a un mode sont dans une UM C, ou plus de 2 % des séjours 'MCO' dans une UM P ou M"
maturity: observed
lifecycle: active
terms: [cora:type-sejour, cora:rss, cora:sejour]
tables: [cora:TB_SEJOUR, cora:TB_SYNTH_RSS, cora:TB_UNITE_MEDICALE]
supported_by: [20261102-type-sejour-mode-hospit-um-resultat]
depends_on: []
---
## Pour s'en servir

TYPE_SEJOUR mêle deux choses : le champ d'activité ('MCO', 'SSR', 'PSY') et une forme de prise en charge ('HDJ', 'EXT', 'URG'). Pour les séjours MCO depuis 2021, 'HDJ' et 'MCO' disent le type de l'unité, pas la durée : un séjour 'MCO' de 0 nuit est un séjour dans une UM d'hospitalisation complète, pas une erreur de codage.

- **Classer par type d'unité (partielle ou complète), sur toutes les années :** joindre TB_SYNTH_RSS.ID_UM_RETENU à TB_UNITE_MEDICALE.ID_UNITE_MED et lire MODE_HOSPIT (C complète, P partielle, M mixte). Compter à part les RSS sans mode.
- **Classer par durée (ambulatoire ou hospitalisation complète, au sens du groupage) :** type-prise-en-charge-mco. Les deux classements diffèrent pour les séjours de 0 nuit en UM C (environ 16 000 par an) : dire lequel on suit.
- **Ne pas** faire une série annuelle sur TYPE_SEJOUR qui commence avant 2021.

## Ce qui l'appuie

Séjours 'MCO' et 'HDJ' ayant un RSS, par année de sortie, type de séjour et mode de l'UM retenue (20261102-type-sejour-mode-hospit-um-resultat), parmi ceux dont l'UM a un mode :

- **2018-2019 :** tout est 'MCO' ; 39 à 41 % des séjours sont en UM P (56 706 et 61 374 de 0 nuit).
- **2020 :** année de bascule ; les séjours en UM P se partagent entre 'HDJ' (13 657) et 'MCO' (38 663).
- **2021 à 2026 :** 'HDJ' est en UM P ou M pour plus de 99,8 % des séjours chaque année (en UM C : 0 à 68) ; 'MCO' est en UM C pour 99,4 à 99,6 % (en UM P : 310 à 515).
- **Séjours 'MCO' de 0 nuit en UM C :** 15 998 à 19 304 par an de 2018 à 2025 (11 237 pour janvier à août 2026), sans rupture en 2020-2021. Ce sont les séjours d'un jour « restés en 'MCO' » de type-sejour-non-fiable : ils sont en UM d'hospitalisation complète.

Le guide méthodologique MCO 2026 type chaque UM en hospitalisation partielle, complète ou mixte (atih-guide-mco-2026, chapitre I, point 2.4) ; CORA reprend ce type dans TB_UNITE_MEDICALE.MODE_HOSPIT (sources/dictionnaire-cora-2020/TB_UNITE_MEDICALE.txt), et relie le RSS à son UM retenue par TB_SYNTH_RSS.ID_UM_RETENU (sources/dictionnaire-cora-2020/TB_SYNTH_RSS.txt).

Points ouverts : MODE_HOSPIT est la valeur actuelle de l'UM, sans historique ; une UM qui a changé de type serait mal classée pour les années anciennes. Un séjour à plusieurs RSS d'UM de modes différents compte dans chaque ligne. Les séjours 'HDJ' d'au moins une nuit en UM P (environ 1 000 à 1 250 par an) ne sont pas expliqués : RSS-séances sur plusieurs dates, ou conversions vers l'hospitalisation complète (TB_MVT.CONVERSION_HP_HC).
