-- id: 20261104-snds-profondeur-mco-deces
-- system: snds
-- person_data: masked
-- purpose: profondeur des tables PMSI MCO du CHU (2020 à 2025) et des décès du référentiel, pour l'étude de mortalité à 90 jours après chirurgie oncologique digestive (étape 4 du plan, #127)
-- Oracle. Lit T_MCO20 à T_MCO25 (B, C) pour le FINESS juridique 760780239 (CHU de Rouen), IR_BEN_R pour les décès, et le catalogue par noms exacts (pas de motif : le catalogue est très lent).
-- Lignes : sorties du CHU par mois ; sorties à chaînage valide par an ; sorties avec mode de sortie 9 (décès) par an ; décès du référentiel par mois depuis 2024 ; existence des tables de 2026.
-- Masquage : N_LIGNES sort en <10 sous 10 (de 0 à 9). Pas de total.
-- Peut durer plusieurs minutes : IR_BEN_R est lu en entier (un seul passage).
SELECT '20261104-snds-profondeur-mco-deces' AS QUERY_ID,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS DATABASE_NAME,
       TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI') AS RUN_AT,
       t.SOURCE,
       t.PERIODE,
       CASE WHEN t.N < 10 THEN '<10' ELSE TO_CHAR(t.N) END AS N_LIGNES
FROM (
  SELECT 'pmsi_chu_sorties_par_mois' AS SOURCE, TO_CHAR(C.EXE_SOI_DTF, 'YYYY-MM') AS PERIODE, COUNT(*) AS N
  FROM T_MCO20C C WHERE C.ETA_NUM = '760780239' GROUP BY TO_CHAR(C.EXE_SOI_DTF, 'YYYY-MM')
  UNION ALL
  SELECT 'pmsi_chu_sorties_par_mois' AS SOURCE, TO_CHAR(C.EXE_SOI_DTF, 'YYYY-MM') AS PERIODE, COUNT(*) AS N
  FROM T_MCO21C C WHERE C.ETA_NUM = '760780239' GROUP BY TO_CHAR(C.EXE_SOI_DTF, 'YYYY-MM')
  UNION ALL
  SELECT 'pmsi_chu_sorties_par_mois' AS SOURCE, TO_CHAR(C.EXE_SOI_DTF, 'YYYY-MM') AS PERIODE, COUNT(*) AS N
  FROM T_MCO22C C WHERE C.ETA_NUM = '760780239' GROUP BY TO_CHAR(C.EXE_SOI_DTF, 'YYYY-MM')
  UNION ALL
  SELECT 'pmsi_chu_sorties_par_mois' AS SOURCE, TO_CHAR(C.EXE_SOI_DTF, 'YYYY-MM') AS PERIODE, COUNT(*) AS N
  FROM T_MCO23C C WHERE C.ETA_NUM = '760780239' GROUP BY TO_CHAR(C.EXE_SOI_DTF, 'YYYY-MM')
  UNION ALL
  SELECT 'pmsi_chu_sorties_par_mois' AS SOURCE, TO_CHAR(C.EXE_SOI_DTF, 'YYYY-MM') AS PERIODE, COUNT(*) AS N
  FROM T_MCO24C C WHERE C.ETA_NUM = '760780239' GROUP BY TO_CHAR(C.EXE_SOI_DTF, 'YYYY-MM')
  UNION ALL
  SELECT 'pmsi_chu_sorties_par_mois' AS SOURCE, TO_CHAR(C.EXE_SOI_DTF, 'YYYY-MM') AS PERIODE, COUNT(*) AS N
  FROM T_MCO25C C WHERE C.ETA_NUM = '760780239' GROUP BY TO_CHAR(C.EXE_SOI_DTF, 'YYYY-MM')
  UNION ALL
  SELECT 'pmsi_chu_chainage_valide_par_an', TO_CHAR(C.EXE_SOI_DTF, 'YYYY'), COUNT(*)
  FROM T_MCO20C C WHERE C.ETA_NUM = '760780239' AND C.NIR_RET = '0' AND C.NAI_RET = '0' AND C.SEX_RET = '0' AND C.SEJ_RET = '0'
    AND C.FHO_RET = '0' AND C.PMS_RET = '0' AND C.DAT_RET = '0' AND C.COH_NAI_RET = '0' AND C.COH_SEX_RET = '0'
  GROUP BY TO_CHAR(C.EXE_SOI_DTF, 'YYYY')
  UNION ALL
  SELECT 'pmsi_chu_chainage_valide_par_an', TO_CHAR(C.EXE_SOI_DTF, 'YYYY'), COUNT(*)
  FROM T_MCO21C C WHERE C.ETA_NUM = '760780239' AND C.NIR_RET = '0' AND C.NAI_RET = '0' AND C.SEX_RET = '0' AND C.SEJ_RET = '0'
    AND C.FHO_RET = '0' AND C.PMS_RET = '0' AND C.DAT_RET = '0' AND C.COH_NAI_RET = '0' AND C.COH_SEX_RET = '0'
  GROUP BY TO_CHAR(C.EXE_SOI_DTF, 'YYYY')
  UNION ALL
  SELECT 'pmsi_chu_chainage_valide_par_an', TO_CHAR(C.EXE_SOI_DTF, 'YYYY'), COUNT(*)
  FROM T_MCO22C C WHERE C.ETA_NUM = '760780239' AND C.NIR_RET = '0' AND C.NAI_RET = '0' AND C.SEX_RET = '0' AND C.SEJ_RET = '0'
    AND C.FHO_RET = '0' AND C.PMS_RET = '0' AND C.DAT_RET = '0' AND C.COH_NAI_RET = '0' AND C.COH_SEX_RET = '0'
  GROUP BY TO_CHAR(C.EXE_SOI_DTF, 'YYYY')
  UNION ALL
  SELECT 'pmsi_chu_chainage_valide_par_an', TO_CHAR(C.EXE_SOI_DTF, 'YYYY'), COUNT(*)
  FROM T_MCO23C C WHERE C.ETA_NUM = '760780239' AND C.NIR_RET = '0' AND C.NAI_RET = '0' AND C.SEX_RET = '0' AND C.SEJ_RET = '0'
    AND C.FHO_RET = '0' AND C.PMS_RET = '0' AND C.DAT_RET = '0' AND C.COH_NAI_RET = '0' AND C.COH_SEX_RET = '0'
  GROUP BY TO_CHAR(C.EXE_SOI_DTF, 'YYYY')
  UNION ALL
  SELECT 'pmsi_chu_chainage_valide_par_an', TO_CHAR(C.EXE_SOI_DTF, 'YYYY'), COUNT(*)
  FROM T_MCO24C C WHERE C.ETA_NUM = '760780239' AND C.NIR_RET = '0' AND C.NAI_RET = '0' AND C.SEX_RET = '0' AND C.SEJ_RET = '0'
    AND C.FHO_RET = '0' AND C.PMS_RET = '0' AND C.DAT_RET = '0' AND C.COH_NAI_RET = '0' AND C.COH_SEX_RET = '0'
  GROUP BY TO_CHAR(C.EXE_SOI_DTF, 'YYYY')
  UNION ALL
  SELECT 'pmsi_chu_chainage_valide_par_an', TO_CHAR(C.EXE_SOI_DTF, 'YYYY'), COUNT(*)
  FROM T_MCO25C C WHERE C.ETA_NUM = '760780239' AND C.NIR_RET = '0' AND C.NAI_RET = '0' AND C.SEX_RET = '0' AND C.SEJ_RET = '0'
    AND C.FHO_RET = '0' AND C.PMS_RET = '0' AND C.DAT_RET = '0' AND C.COH_NAI_RET = '0' AND C.COH_SEX_RET = '0'
  GROUP BY TO_CHAR(C.EXE_SOI_DTF, 'YYYY')
  UNION ALL
  SELECT 'pmsi_chu_sortie_deces_par_an', '2020', COUNT(*)
  FROM T_MCO20B B WHERE B.ETA_NUM = '760780239' AND B.SOR_MOD = '9'
  UNION ALL
  SELECT 'pmsi_chu_sortie_deces_par_an', '2021', COUNT(*)
  FROM T_MCO21B B WHERE B.ETA_NUM = '760780239' AND B.SOR_MOD = '9'
  UNION ALL
  SELECT 'pmsi_chu_sortie_deces_par_an', '2022', COUNT(*)
  FROM T_MCO22B B WHERE B.ETA_NUM = '760780239' AND B.SOR_MOD = '9'
  UNION ALL
  SELECT 'pmsi_chu_sortie_deces_par_an', '2023', COUNT(*)
  FROM T_MCO23B B WHERE B.ETA_NUM = '760780239' AND B.SOR_MOD = '9'
  UNION ALL
  SELECT 'pmsi_chu_sortie_deces_par_an', '2024', COUNT(*)
  FROM T_MCO24B B WHERE B.ETA_NUM = '760780239' AND B.SOR_MOD = '9'
  UNION ALL
  SELECT 'pmsi_chu_sortie_deces_par_an', '2025', COUNT(*)
  FROM T_MCO25B B WHERE B.ETA_NUM = '760780239' AND B.SOR_MOD = '9'
  UNION ALL
  SELECT 'ir_ben_r_deces_par_mois', TO_CHAR(R.BEN_DCD_DTE, 'YYYY-MM'), COUNT(DISTINCT R.BEN_IDT_ANO)
  FROM IR_BEN_R R WHERE R.BEN_DCD_DTE >= DATE '2024-01-01' AND R.BEN_DCD_DTE < DATE '2100-01-01'
  GROUP BY TO_CHAR(R.BEN_DCD_DTE, 'YYYY-MM')
  UNION ALL
  SELECT 'tables_2026_visibles', O.OBJECT_NAME, COUNT(*)
  FROM ALL_OBJECTS O WHERE O.OBJECT_NAME IN ('T_MCO25B', 'T_MCO26B', 'T_MCO26C') GROUP BY O.OBJECT_NAME
) t;
