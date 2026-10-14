-- id: 20261014-rss-recents
-- system: cora
-- person_data: masked
-- purpose: par mois de fin du RSS, sur les 15 derniers mois, la part des RSS sans DP, sans GHM, en erreur (CMD 90) ou sans diagnostic, selon VALID_DIM, pour savoir combien de mois récents sont incomplets (kb : rss-before-validation, #24)
-- Oracle, schéma CORA_REC. RSS de TB_SYNTH_RSS dont DATE_FIN tombe entre le premier jour du mois, 15 mois avant l'exécution, et le jour de l'exécution. VALID_DIM : valeur en texte, '(vide)' sinon.
-- N : RSS ; N_SANS_DP : DP_RETENU vide ; N_SANS_GHM : CODE_GHM vide ; N_CMD_90 : CODE_CMD = '90' ; N_SANS_DIAG : aucun diagnostic (TB_DIAG) sur les mouvements du RSS (TB_MVT_RUM).
-- Masquage : chaque effectif < 10 sort en <10. Suppression secondaire (règle 4) : N sort en « masqué » dès qu'un complément (N moins une autre colonne) est entre 1 et 9. Aucune ligne de total.
WITH r AS (
  SELECT x.ID_RSS,
         TO_CHAR(x.DATE_FIN, 'YYYY-MM') AS MOIS,
         NVL(TRIM(TO_CHAR(x.VALID_DIM)), '(vide)') AS VALID_DIM,
         CASE WHEN TRIM(x.DP_RETENU) IS NULL THEN 1 ELSE 0 END AS SANS_DP,
         CASE WHEN TRIM(x.CODE_GHM) IS NULL THEN 1 ELSE 0 END AS SANS_GHM,
         CASE WHEN TRIM(x.CODE_CMD) = '90' THEN 1 ELSE 0 END AS CMD_90,
         CASE WHEN EXISTS (SELECT 1 FROM CORA_REC.TB_MVT_RUM mr JOIN CORA_REC.TB_DIAG d ON d.ID_MVT = mr.ID_MVT
                           WHERE mr.ID_RSS = x.ID_RSS) THEN 0 ELSE 1 END AS SANS_DIAG
  FROM CORA_REC.TB_SYNTH_RSS x
  WHERE x.DATE_FIN >= ADD_MONTHS(TRUNC(SYSDATE, 'MM'), -15)
    AND x.DATE_FIN < TRUNC(SYSDATE) + 1
),
t AS (
  SELECT MOIS, VALID_DIM, COUNT(*) AS N,
         SUM(SANS_DP) AS C1, SUM(SANS_GHM) AS C2, SUM(CMD_90) AS C3, SUM(SANS_DIAG) AS C4
  FROM r
  GROUP BY MOIS, VALID_DIM
)
SELECT '20261014-rss-recents' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       MOIS, VALID_DIM,
       CASE WHEN N < 10 THEN '<10'
            WHEN N - C1 BETWEEN 1 AND 9 OR N - C2 BETWEEN 1 AND 9 OR N - C3 BETWEEN 1 AND 9 OR N - C4 BETWEEN 1 AND 9 THEN 'masqué'
            ELSE TO_CHAR(N) END AS N,
       CASE WHEN C1 < 10 THEN '<10' ELSE TO_CHAR(C1) END AS N_SANS_DP,
       CASE WHEN C2 < 10 THEN '<10' ELSE TO_CHAR(C2) END AS N_SANS_GHM,
       CASE WHEN C3 < 10 THEN '<10' ELSE TO_CHAR(C3) END AS N_CMD_90,
       CASE WHEN C4 < 10 THEN '<10' ELSE TO_CHAR(C4) END AS N_SANS_DIAG
FROM t
ORDER BY MOIS, VALID_DIM;
