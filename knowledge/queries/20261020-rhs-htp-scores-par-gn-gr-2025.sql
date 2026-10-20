-- id: 20261020-rhs-htp-scores-par-gn-gr-2025
-- system: cora
-- person_data: masked
-- purpose: pour les RHS de HTP (TYPE_HOSPIT_SSR = 2) dont la semaine débute en 2025, par GN et groupe de réadaptation du CODE_GME, donner le minimum, la moyenne et le maximum de SCORE_RR, PONDERATION_RR_RHS et PONDERATION_RR_TOTAL, pour trouver laquelle de ces colonnes est le score par jour du groupage et vérifier qu'elle respecte les seuils du GN (étape 4 du plan, issue 96)
-- Oracle. Un groupe de moins de 10 RHS sort entièrement comme <10, minimum et maximum compris.
SELECT '20261020-rhs-htp-scores-par-gn-gr-2025' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       SUBSTR(s.CODE_GME, 1, 4) AS GN,
       SUBSTR(s.CODE_GME, 5, 1) AS GR,
       CASE WHEN COUNT(*) < 10 THEN '<10' ELSE CAST(COUNT(*) AS VARCHAR2(12)) END AS N_RHS,
       CASE WHEN COUNT(*) < 10 THEN '<10' ELSE CAST(MIN(s.SCORE_RR) AS VARCHAR2(20)) END AS SCORE_RR_MIN,
       CASE WHEN COUNT(*) < 10 THEN '<10' ELSE CAST(ROUND(AVG(s.SCORE_RR), 1) AS VARCHAR2(20)) END AS SCORE_RR_MOY,
       CASE WHEN COUNT(*) < 10 THEN '<10' ELSE CAST(MAX(s.SCORE_RR) AS VARCHAR2(20)) END AS SCORE_RR_MAX,
       CASE WHEN COUNT(*) < 10 THEN '<10' ELSE CAST(MIN(s.PONDERATION_RR_RHS) AS VARCHAR2(20)) END AS POND_RHS_MIN,
       CASE WHEN COUNT(*) < 10 THEN '<10' ELSE CAST(ROUND(AVG(s.PONDERATION_RR_RHS), 1) AS VARCHAR2(20)) END AS POND_RHS_MOY,
       CASE WHEN COUNT(*) < 10 THEN '<10' ELSE CAST(MAX(s.PONDERATION_RR_RHS) AS VARCHAR2(20)) END AS POND_RHS_MAX,
       CASE WHEN COUNT(*) < 10 THEN '<10' ELSE CAST(MIN(s.PONDERATION_RR_TOTAL) AS VARCHAR2(20)) END AS POND_TOTAL_MIN,
       CASE WHEN COUNT(*) < 10 THEN '<10' ELSE CAST(ROUND(AVG(s.PONDERATION_RR_TOTAL), 1) AS VARCHAR2(20)) END AS POND_TOTAL_MOY,
       CASE WHEN COUNT(*) < 10 THEN '<10' ELSE CAST(MAX(s.PONDERATION_RR_TOTAL) AS VARCHAR2(20)) END AS POND_TOTAL_MAX
FROM CORA_REC.TB_MVT_SSR_SEM s
WHERE s.TYPE_HOSPIT_SSR = 2
  AND s.DATE_DEBUT_SEM >= DATE '2025-01-01' AND s.DATE_DEBUT_SEM < DATE '2026-01-01'
GROUP BY SUBSTR(s.CODE_GME, 1, 4), SUBSTR(s.CODE_GME, 5, 1)
ORDER BY 4, 5;
