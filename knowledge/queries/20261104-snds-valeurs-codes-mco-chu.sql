-- id: 20261104-snds-valeurs-codes-mco-chu
-- system: snds
-- person_data: masked
-- purpose: valeurs des codes du PMSI MCO du CHU utiles à l'étude de mortalité (SEJ_NP, STC_URG, ENT_MOD, SOR_MOD, SEJ_TYP), clé de jointure PMSI-référentiel (étape 4 du plan, #127)
-- Oracle. Lit T_MCO25B et T_MCO25C du FINESS juridique 760780239 et IR_BEN_R (une seule lecture, bornée). IR_PRS_F n'est pas lue.
-- Lignes : une par variable et valeur ; nir_ano_17_dans_ir_ben_r : au plus 5000 NIR_ANO_17 distincts des sorties du CHU en 2025 à NIR valide, comptés selon qu'ils sont ou non un BEN_NIR_PSA du référentiel (un seul passage sur IR_BEN_R, bornée par la liste des 5000). Ici N_SEJ compte des NIR distincts.
-- Masquage : N_SEJ sort en <10 sous 10 (de 0 à 9). Pas de total.
SELECT '20261104-snds-valeurs-codes-mco-chu' AS QUERY_ID,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS DATABASE_NAME,
       TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI') AS RUN_AT,
       t.VARIABLE,
       t.VALEUR,
       CASE WHEN t.N < 10 THEN '<10' ELSE TO_CHAR(t.N) END AS N_SEJ
FROM (
  SELECT 'SEJ_NP' AS VARIABLE, NVL(TO_CHAR(B.SEJ_NP), 'NULL') AS VALEUR, COUNT(*) AS N
  FROM T_MCO25B B WHERE B.ETA_NUM = '760780239' GROUP BY B.SEJ_NP
  UNION ALL
  SELECT 'STC_URG' AS VARIABLE, NVL(TO_CHAR(B.STC_URG), 'NULL') AS VALEUR, COUNT(*) AS N
  FROM T_MCO25B B WHERE B.ETA_NUM = '760780239' GROUP BY B.STC_URG
  UNION ALL
  SELECT 'ENT_MOD' AS VARIABLE, NVL(TO_CHAR(B.ENT_MOD), 'NULL') AS VALEUR, COUNT(*) AS N
  FROM T_MCO25B B WHERE B.ETA_NUM = '760780239' GROUP BY B.ENT_MOD
  UNION ALL
  SELECT 'SOR_MOD' AS VARIABLE, NVL(TO_CHAR(B.SOR_MOD), 'NULL') AS VALEUR, COUNT(*) AS N
  FROM T_MCO25B B WHERE B.ETA_NUM = '760780239' GROUP BY B.SOR_MOD
  UNION ALL
  SELECT 'SEJ_TYP' AS VARIABLE, NVL(TO_CHAR(B.SEJ_TYP), 'NULL') AS VALEUR, COUNT(*) AS N
  FROM T_MCO25B B WHERE B.ETA_NUM = '760780239' GROUP BY B.SEJ_TYP
  UNION ALL
  SELECT 'nir_ano_17_dans_ir_ben_r', CASE WHEN x.BEN_NIR_PSA IS NULL THEN 'non' ELSE 'oui' END, COUNT(*)
  FROM (
    WITH s AS (SELECT NIR_ANO_17 FROM (SELECT DISTINCT C.NIR_ANO_17 FROM T_MCO25C C
                                       WHERE C.ETA_NUM = '760780239' AND C.NIR_RET = '0' ORDER BY C.NIR_ANO_17)
               WHERE ROWNUM <= 5000)
    SELECT s.NIR_ANO_17, r.BEN_NIR_PSA
    FROM s LEFT JOIN (SELECT DISTINCT R.BEN_NIR_PSA FROM IR_BEN_R R WHERE R.BEN_NIR_PSA IN (SELECT NIR_ANO_17 FROM s)) r
      ON r.BEN_NIR_PSA = s.NIR_ANO_17
  ) x
  GROUP BY CASE WHEN x.BEN_NIR_PSA IS NULL THEN 'non' ELSE 'oui' END
) t;
