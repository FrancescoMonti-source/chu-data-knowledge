---
review: unreviewed
id: schemas-cwprod-visibles
kind: empirical
author: Pierre
statement: "Sur CWPROD, le compte de l'utilisateur DIM ne voit des objets que dans 8 schémas sur 93 : les référentiels de codage et de tarification (CIM-10, CCAM, CSARR, ICR, listes d'exclusion, DATIM, LPP) sont dans CORA_CCAM et atteints par des synonymes de CORA_REC ; la structure de l'établissement n'est que dans CORA_REC. Avant d'écrire qu'une table « n'existe pas dans CORA », la chercher dans CORA_CCAM et CORA_CCAM_CNAM."
scope: "CWPROD, catalogue Oracle des schémas non maintenus par Oracle, objets visibles par le compte de l'utilisateur DIM, lu le 2026-10-26"
refuted_if: "ALL_TABLES, lu avec le compte de l'utilisateur DIM, montre des tables dans un schéma autre que CORA_REC, CORA_CCAM, CORA_CCAM_CNAM, CORA_UTIL, CORA_LOG, CORA_GEN, INTEG ou ZEXPLOIT, ou une table de structure d'établissement (UF, UM, service, pôle) dans CORA_CCAM, CORA_UTIL ou CORA_LOG"
maturity: observed
lifecycle: active
terms: [cora:uf, cora:um]
tables: [cora:PMSI_CCAM_ICR, cora:CIM_HIERARCHIE, cora:TB_UNITE]
supported_by: [20261026-schemas-inventaire-resultat, 20261026-schemas-objets-resultat]
depends_on: []
---
## Pour s'en servir

- **Chercher une table :** dans CORA_REC d'abord (638 tables, 8 vues, 330 synonymes qui pointent vers les autres schémas CORA : 170 vers CORA_CCAM, 72 vers CORA_CCAM_CNAM, 82 vers CORA_UTIL, 6 vers CORA_GEN et CORA_LOG), puis dans CORA_CCAM (245 tables) pour les référentiels de codage : CIM (CIM_HIERARCHIE, CIM_DP_EXCLU, CIM_LISTE_DIAG_EXCLU), CCAM_NV, ICR (PMSI_CCAM_ICR), CSARR, LPP, FG_* (groupage), DATIM_*, ORPHA. CORA_CCAM_CNAM (74 tables R_*) porte la CCAM de la CNAM.
- **Structure de l'établissement :** TB_UNITE, TB_UNITE_MEDICALE, TB_UNITE_M_UNITE, TB_UNITE_POLE, TB_UNITE_POLE_UM, TB_SITE, TB_REGROUPEMENT et leurs historiques TB_HIST_UNITE et TB_HIST_UNITE_M_UNITE sont dans CORA_REC. Les nouveaux schémas ne contiennent aucune autre table de structure : ne pas chercher de service ni de pôle ailleurs (service : fichier Structure, service-et-pole-depuis-fichier-structure).
- **À ne pas lire :** CORA_UTIL contient les utilisateurs, droits et paramétrages (UTIL, TB_DROIT_*, TB_ETABLISSEMENT avec des colonnes de connexion) : données de personnel et de configuration, hors périmètre des requêtes de preuve. CORA_LOG contient les journaux des flux d'interface. CORA_GEN a cinq tables vides.
- **85 autres schémas** (CCAM, CIM10, CW_PROD, BLOC, DMI…) existent mais n'ont ni table ni vue visible : droit de lecture à demander à l'administrateur du compte si l'on a besoin d'une table qui n'est dans aucun schéma listé.

## Ce qui l'appuie

L'inventaire (20261026-schemas-inventaire-resultat) donne 93 schémas non maintenus par Oracle ; 8 ont des tables ou des vues (638, 245, 74, 125, 123, 5, 1 et 1 tables). Les statistiques Oracle sont de 2026-10-25. La liste des objets (20261026-schemas-objets-resultat) place les référentiels de codage dans CORA_CCAM avec leurs volumes : par exemple CIM_DP_EXCLU environ 460 000 lignes, CIM_LISTE_DIAG_EXCLU environ 207 000, FG_DP_EXCLUANT environ 289 000, CIM_HIERARCHIE environ 20 000, PMSI_CCAM_ICR environ 29 800. Les 330 synonymes de CORA_REC visent 170 tables de CORA_CCAM, 72 de CORA_CCAM_CNAM, 82 de CORA_UTIL, 4 de CORA_GEN et 2 de CORA_LOG ; CIM_DP_EXCLU, CIM_LISTE_DIAG_EXCLU, FG_DP_EXCLUANT, CIM_HIERARCHIE et PMSI_CCAM_ICR en font partie, donc `CORA_REC.<nom>` les atteint.

Points ouverts : visible dans le catalogue ne prouve pas que SELECT réussit (le droit n'est pas lu) ; les volumes sont ceux des statistiques Oracle ; le contenu de ces tables n'est pas lu.
