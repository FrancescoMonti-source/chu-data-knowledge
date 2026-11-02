-- id: 20261020-rhs-htp-gn-gr-montants-2025
-- system: cora
-- person_data: masked
-- purpose: pour les RHS de HTP (TYPE_HOSPIT_SSR = 2) dont la semaine débute en 2025, par GN et groupe de réadaptation du CODE_GME, compter les RHS, leurs jours de présence et les montants MNT_GMT, MNT_GMT_HEBDO et MNT_TOTAL, et dire si CODE_GMT et GMT_HEBDO diffèrent, pour savoir ce que ces colonnes mesurent (étapes 4 et 5 du plan, issue 96)
-- Oracle. GN = 4 premiers caractères du CODE_GME, groupe de réadaptation = 5e caractère. Un effectif de moins de 10 sort comme <10, et les sommes de montants avec lui.
SELECT '20261020-rhs-htp-gn-gr-montants-2025' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       SUBSTR(s.CODE_GME, 1, 4) AS GN,
       SUBSTR(s.CODE_GME, 5, 1) AS GR,
       CASE WHEN COUNT(*) < 10 THEN '<10' ELSE CAST(COUNT(*) AS VARCHAR2(12)) END AS N_RHS,
       CASE WHEN COUNT(*) < 10 THEN '<10' ELSE CAST(SUM(s.NBJ_PRES) AS VARCHAR2(12)) END AS N_JOURS_PRESENCE,
       CASE WHEN COUNT(*) < 10 THEN '<10' ELSE CAST(ROUND(SUM(s.MNT_GMT), 2) AS VARCHAR2(20)) END AS MNT_GMT_SOMME,
       CASE WHEN COUNT(*) < 10 THEN '<10' ELSE CAST(ROUND(SUM(s.MNT_GMT_HEBDO), 2) AS VARCHAR2(20)) END AS MNT_GMT_HEBDO_SOMME,
       CASE WHEN COUNT(*) < 10 THEN '<10' ELSE CAST(ROUND(SUM(s.MNT_TOTAL), 2) AS VARCHAR2(20)) END AS MNT_TOTAL_SOMME,
       CASE WHEN COUNT(CASE WHEN s.CODE_GMT <> s.GMT_HEBDO THEN 1 END) < 10 THEN '<10' ELSE CAST(COUNT(CASE WHEN s.CODE_GMT <> s.GMT_HEBDO THEN 1 END) AS VARCHAR2(12)) END AS N_GMT_DIFF_HEBDO,
       CASE WHEN COUNT(*) < 10 THEN '<10' ELSE CAST(ROUND(AVG(s.SCORE_RR_SEM), 1) AS VARCHAR2(12)) END AS SCORE_RR_SEM_MOYEN
FROM CORA_REC.TB_MVT_SSR_SEM s
WHERE s.TYPE_HOSPIT_SSR = 2
  AND s.DATE_DEBUT_SEM >= DATE '2025-01-01' AND s.DATE_DEBUT_SEM < DATE '2026-01-01'
GROUP BY SUBSTR(s.CODE_GME, 1, 4), SUBSTR(s.CODE_GME, 5, 1)
ORDER BY 4, 5;
