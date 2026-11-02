---
review: unreviewed
id: codes-cora-pas-en-char
kind: empirical
author: Pierre
statement: "Dans CORA de production, CODE_ACTE, CODE_DIAG, NO_SEJOUR, CODE_UNITE, UF_ENTREE et ID_UNITE_M ne sont pas des colonnes CHAR (le dictionnaire 2020 les donne en char) ; pour CODE_UNITE, UF_ENTREE et ID_UNITE_M, aucun blanc de fin n'est mesuré et la jointure directe retrouve les mêmes lignes qu'après TRIM ; les codes CHAR de CORA_REC sont d'autres colonnes (CODE_GHM, CODE_GHS, CODE_CMD, CODE_DIAG_PRINC_RETENU, UF_ATTRIB), à lire dans le catalogue avant de les comparer."
scope: "CORA de production (CWPROD, schéma CORA_REC), catalogue des colonnes CHAR de noms de code, et absence de blancs mesurée sur TB_UNITE, TB_SEJOUR (entrées de 2018 à octobre 2026) et TB_MVT (mouvements de 2018 à octobre 2026), lu le 2026-10-19"
refuted_if: "ALL_TAB_COLUMNS donne le type CHAR à l'une de ces six colonnes dans CORA_REC, ou plus de 10 valeurs de TB_UNITE.CODE_UNITE, TB_SEJOUR.UF_ENTREE ou TB_MVT.ID_UNITE_M d'une année portent un blanc de fin"
maturity: observed
lifecycle: active
terms: [cora:sejour, cora:uf, cora:acte, cora:diagnostic, cora:mouvement]
tables: [cora:TB_ACTE, cora:TB_DIAG, cora:TB_SEJOUR, cora:TB_MVT, cora:TB_UNITE, cora:TB_SEJOUR_LIE]
supported_by: [20261019-catalogue-types-colonnes-g3-resultat, 20261019-codes-char-blancs-resultat]
depends_on: []
---
## Pour s'en servir

- **Ces six codes** (acte, diagnostic, séjour, unité du séjour, unité du mouvement, code d'unité) : ne pas compter sur un remplissage de blancs par le type, puisqu'aucune n'est CHAR. Pour les trois codes d'unité mesurés (CODE_UNITE, UF_ENTREE, ID_UNITE_M), un `TRIM` est inutile et sans effet sur les lignes retrouvées (joindre-uf-par-code l'écrit par prudence : c'est sans conséquence) ; pour CODE_ACTE, CODE_DIAG et NO_SEJOUR, les valeurs n'ont pas été lues : l'absence de blancs de fin n'est pas mesurée. `TB_SEJOUR_LIE.NO_SEJOUR_MAITRE` et `NO_SEJOUR_LIE` sont des VARCHAR2 de 20.
- **Les codes réellement en CHAR** : CODE_GHM (4 caractères dans TB_SYNTH_RUM, TB_SYNTH_RUM_VERSION et PMSI_LIB_GHS_TARIF ; 6 dans TB_RSS_SUIVI), CODE_GHM_RACINE (5), CODE_GHS (4 dans TB_RSS_SUIVI), CODE_CMD (2), CODE_DIAG_PRINC_RETENU (4 dans TB_SYNTH_RSS_VERSION), UF_ATTRIB (10). Pour les comparer à une colonne VARCHAR2, appliquer TRIM aux deux côtés, car Oracle ne complète pas de blancs quand l'un des côtés est un VARCHAR2 (règle Oracle, non mesurée ici). Avant de poser un TRIM sur une autre colonne, lire son type : `SELECT DATA_TYPE, DATA_LENGTH FROM ALL_TAB_COLUMNS WHERE OWNER = 'CORA_REC' AND TABLE_NAME = ... AND COLUMN_NAME = ...`.

## Ce qui l'appuie

Catalogue (20261019-catalogue-types-colonnes-g3-resultat) : la requête liste les colonnes CHAR de CORA_REC dont le nom évoque CODE_ACTE, CODE_DIAG, NO_SEJOUR, UF, UNITE, CODE_GHM, CODE_GHS, CODE_CMD, DP ou DR. Aucune ligne pour CODE_ACTE, CODE_DIAG, NO_SEJOUR, CODE_UNITE, UF_ENTREE ni ID_UNITE_M : ces colonnes ne sont pas CHAR, alors que le dictionnaire 2020 donne CODE_ACTE et CODE_DIAG en char(16), NO_SEJOUR en char(20), CODE_UNITE et ID_UNITE_M en char(12). Sont revenues : CODE_CMD, CODE_GHM, CODE_GHM_RACINE, CODE_GHS, CODE_DIAG_PRINC_RETENU, UF_ATTRIB, et des drapeaux d'unité (SIGN_RUM_UF, TYPE_UNITE_PSY, UNITE_DEFAUT_AMBU_PSY, de longueur 1). CORA_REC compte 1 642 colonnes CHAR dans 419 tables ou vues (ALL_TAB_COLUMNS mêle tables et vues).

Blancs de fin (20261019-codes-char-blancs-resultat) : dans TB_UNITE, moins de 10 des 838 codes d'unité diffèrent de leur TRIM. Pour TB_SEJOUR.UF_ENTREE (par année d'entrée, de 732 697 séjours en 2020 à 922 017 en 2025, 753 219 en 2026 ; N masqué en 2019, où l'égalité retrouve 861 112 séjours) et TB_MVT.ID_UNITE_M (par année de début, de 794 042 mouvements en 2020 à 1 002 817 en 2025, 845 964 en 2026), moins de 10 valeurs par année diffèrent de leur TRIM, et l'égalité directe avec CODE_UNITE retrouve exactement le même effectif que l'égalité après TRIM, chaque année.

Points ouverts : la présence de blancs dans CODE_ACTE, CODE_DIAG et NO_SEJOUR (le type est lu, les valeurs ne le sont pas) ; l'effet réel d'une comparaison CHAR contre VARCHAR2 sur CODE_DIAG_PRINC_RETENU ou CODE_GHM (non mesuré) ; la raison des CODE_GHM de 4 caractères (le GHM complet est CODE_CMD || CODE_GHM : separer-ambulatoire-par-ghm).
