-- id: 20261015-m8-ecart-themes
-- system: cora
-- person_data: masked
-- purpose: par thème de DAS et mois de sortie des RSS MCO finis de janvier à août 2026, les RSS qui ont le thème aujourd'hui et ceux qui l'ont reçu après l'envoi M8 (2026-10-02 07:47:40), avec la ligne tout_das comme repère du codage tardif (étape 1 du plan)
-- Oracle, schéma CORA_REC. Chemin PMSI : TB_SYNTH_RSS -> TB_MVT_RUM -> TB_DIAG (chemin-actes-diags-par-mouvement). DAS : TYPE_DIAG = 'S'.
-- La date d'un DAS est TB_DIAG.DATE_CREAT, pas DATE_DIAG (dater-diagnostic-par-mouvement). Sa fiabilité est testée à l'étape 2 du plan.
-- N_RSS_THEME_APRES_M8 : tous les DAS du thème sur le RSS ont été créés après M8 (le RSS n'avait pas le thème dans M8).
-- N_RSS_UN_DAS_APRES_M8 : au moins un DAS du thème créé après M8.
-- N_RSS_SANS_DATE_CREAT : au moins un DAS du thème sans DATE_CREAT (ces RSS ne comptent dans aucune des deux colonnes précédentes).
WITH d0 AS (
  SELECT r.ID_RSS,
         TO_CHAR(r.DATE_FIN, 'YYYY-MM') AS MOIS_SORTIE,
         d.DATE_CREAT,
         REPLACE(TRIM(d.CODE_DIAG), '.', '') AS CODE
  FROM CORA_REC.TB_SYNTH_RSS r
  JOIN CORA_REC.TB_MVT_RUM mr ON mr.ID_RSS = r.ID_RSS
  JOIN CORA_REC.TB_DIAG d ON d.ID_MVT = mr.ID_MVT
  WHERE r.DATE_FIN >= DATE '2026-01-01'
    AND r.DATE_FIN <  DATE '2026-09-01'
    AND TRIM(d.TYPE_DIAG) = 'S'
),
d1 AS (
  SELECT ID_RSS, MOIS_SORTIE, DATE_CREAT,
         CASE
           WHEN SUBSTR(CODE, 1, 3) IN ('E40','E41','E42','E43','E44','E45','E46') THEN 'denutrition'
           WHEN CODE LIKE 'L89%' THEN 'escarres'
           WHEN CODE LIKE 'R33%' THEN 'retention_urine'
           WHEN CODE LIKE 'R521%' OR CODE LIKE 'R522%' THEN 'douleur_chronique'
           WHEN SUBSTR(CODE, 1, 3) IN ('U82','U83','U84','U85') THEN 'resistance_atb'
           WHEN CODE LIKE 'Z290%' THEN 'isolement_prophylactique'
         END AS THEME
  FROM d0
),
dx AS (
  SELECT ID_RSS, MOIS_SORTIE, DATE_CREAT, THEME FROM d1 WHERE THEME IS NOT NULL
  UNION ALL
  SELECT ID_RSS, MOIS_SORTIE, DATE_CREAT, 'tout_das' AS THEME FROM d0
),
par_rss AS (
  SELECT THEME, MOIS_SORTIE, ID_RSS,
         MIN(DATE_CREAT) AS PREMIER_DAS,
         MAX(DATE_CREAT) AS DERNIER_DAS,
         COUNT(*) - COUNT(DATE_CREAT) AS NB_SANS_DATE
  FROM dx
  GROUP BY THEME, MOIS_SORTIE, ID_RSS
),
rss_mois AS (
  SELECT TO_CHAR(DATE_FIN, 'YYYY-MM') AS MOIS_SORTIE, COUNT(*) AS NB
  FROM CORA_REC.TB_SYNTH_RSS
  WHERE DATE_FIN >= DATE '2026-01-01'
    AND DATE_FIN <  DATE '2026-09-01'
  GROUP BY TO_CHAR(DATE_FIN, 'YYYY-MM')
),
agg AS (
  SELECT THEME, MOIS_SORTIE,
         COUNT(*) AS NB_AUJ,
         SUM(CASE WHEN NB_SANS_DATE = 0 AND PREMIER_DAS > TIMESTAMP '2026-10-02 07:47:40' THEN 1 ELSE 0 END) AS NB_THEME_APRES,
         SUM(CASE WHEN NB_SANS_DATE = 0 AND DERNIER_DAS > TIMESTAMP '2026-10-02 07:47:40' THEN 1 ELSE 0 END) AS NB_UN_APRES,
         SUM(CASE WHEN NB_SANS_DATE > 0 THEN 1 ELSE 0 END) AS NB_SANS_DATE
  FROM par_rss
  GROUP BY THEME, MOIS_SORTIE
)
SELECT '20261015-m8-ecart-themes' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       a.THEME,
       a.MOIS_SORTIE,
       CASE WHEN m.NB < 10 THEN '<10' ELSE TO_CHAR(m.NB) END AS N_RSS_MOIS,
       CASE WHEN a.NB_AUJ < 10 THEN '<10' ELSE TO_CHAR(a.NB_AUJ) END AS N_RSS_AUJOURDHUI,
       CASE WHEN a.NB_THEME_APRES < 10 THEN '<10' ELSE TO_CHAR(a.NB_THEME_APRES) END AS N_RSS_THEME_APRES_M8,
       CASE WHEN a.NB_UN_APRES < 10 THEN '<10' ELSE TO_CHAR(a.NB_UN_APRES) END AS N_RSS_UN_DAS_APRES_M8,
       CASE WHEN a.NB_SANS_DATE < 10 THEN '<10' ELSE TO_CHAR(a.NB_SANS_DATE) END AS N_RSS_SANS_DATE_CREAT
FROM agg a
JOIN rss_mois m ON m.MOIS_SORTIE = a.MOIS_SORTIE
ORDER BY a.THEME, a.MOIS_SORTIE;
