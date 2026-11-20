---
id: 20261116-macro-sej-urg-cnam
type: reading
source: documentation-snds-20261102
locator: "snds/files/CNAM_NEW/bonnes_pratiques_sas/partage_de_programmes/10-PMSI_MACRO_URGENCE_SNDS.sas, macro SEJ_URG, critères de sélection"
read_by: Pierre
read_at: 2026-11-16
---
> « substr(t2.AUT_TYP1_UM,1,2) ='07'  /** Type d'autorisation 07 = UHCD **/ »

> « (t1.ENT_MOD = '8' AND t1.ENT_PRV in ('5','U') ) » pour les tables jusqu'en 2022 ; « (t1.ENT_MOD in( '8','7') AND (t1.ENT_PRV in ('5','U') OR T1.STC_URG in ('5','U','V') ) ) » à partir de 2023.

> « t2.UM_ORD_NUM = 1 /** Première unité médicale jusqu'en 2019 **/ » et « t2.RUM_ORD_NUM = 1 /** Première unité médicale à partir de 2020 **/ »
