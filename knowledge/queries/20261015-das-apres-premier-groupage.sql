-- id: 20261015-das-apres-premier-groupage
-- system: cora
-- person_data: masked
-- purpose: par thème de DAS et mois de sortie des RSS MCO finis de janvier à août 2026, les RSS dont le thème est arrivé plus de 24 heures après le premier groupage sans erreur (TB_CHRONO_CODAGE.DATE_GRP), c'est-à-dire « récupérés » ; tout_das sert de repère (étape 3 du plan revu, #49)
-- Oracle, schéma CORA_REC. Même population et même chemin que 20261015-m8-ecart-themes. TB_CHRONO_CODAGE n'a encore aucun claim : la requête mesure aussi son remplissage.
-- N_RSS_THEME_APRES_GRP : tous les DAS du thème sur le RSS ont été créés plus de 24 h après DATE_GRP (le thème manquait au premier groupage).
-- N_RSS_UN_DAS_APRES_GRP : au moins un DAS du thème créé plus de 24 h après DATE_GRP (pour tout_das : RSS repris après leur premier groupage).
-- N_RSS_THEME_SANS_DATE_GRP : RSS du thème sans ligne dans TB_CHRONO_CODAGE ou sans DATE_GRP ; ils ne comptent dans aucune autre colonne.
-- N_RSS_MOIS_SANS_DATE_GRP, N_RSS_MOIS_PLUSIEURS_CHRONO : tous les RSS du mois, avec ou sans DAS ; répétés sur chaque ligne du mois.
-- Règle 4 : N_RSS_AUJOURDHUI de 20261015-m8-ecart-themes donne le total ; si le reste (AUJOURDHUI - APRES_GRP - SANS_DATE_GRP) ou l'écart (UN_DAS - THEME) est sous 10, les colonnes qui le livreraient sont masquées.
WITH chrono AS (
  SELECT ID_RSS, MIN(DATE_GRP) AS DATE_GRP, COUNT(*) AS NB_LIGNES
  FROM CORA_REC.TB_CHRONO_CODAGE
  GROUP BY ID_RSS
),
rss AS (
  SELECT r.ID_RSS, TO_CHAR(r.DATE_FIN, 'YYYY-MM') AS MOIS_SORTIE, c.DATE_GRP, c.NB_LIGNES
  FROM CORA_REC.TB_SYNTH_RSS r
  LEFT JOIN chrono c ON c.ID_RSS = r.ID_RSS
  WHERE r.DATE_FIN >= DATE '2026-01-01'
    AND r.DATE_FIN <  DATE '2026-09-01'
),
rss_mois AS (
  SELECT MOIS_SORTIE,
         SUM(CASE WHEN DATE_GRP IS NULL THEN 1 ELSE 0 END) AS NB_SANS_GRP,
         SUM(CASE WHEN NB_LIGNES > 1 THEN 1 ELSE 0 END) AS NB_PLUSIEURS
  FROM rss
  GROUP BY MOIS_SORTIE
),
d0 AS (
  SELECT x.ID_RSS, x.MOIS_SORTIE, x.DATE_GRP, d.DATE_CREAT,
         REPLACE(TRIM(d.CODE_DIAG), '.', '') AS CODE
  FROM rss x
  JOIN CORA_REC.TB_MVT_RUM mr ON mr.ID_RSS = x.ID_RSS
  JOIN CORA_REC.TB_DIAG d ON d.ID_MVT = mr.ID_MVT
  WHERE TRIM(d.TYPE_DIAG) = 'S'
),
d1 AS (
  SELECT ID_RSS, MOIS_SORTIE, DATE_GRP, DATE_CREAT,
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
  SELECT ID_RSS, MOIS_SORTIE, DATE_GRP, DATE_CREAT, THEME FROM d1 WHERE THEME IS NOT NULL
  UNION ALL
  SELECT ID_RSS, MOIS_SORTIE, DATE_GRP, DATE_CREAT, 'tout_das' AS THEME FROM d0
),
par_rss AS (
  SELECT THEME, MOIS_SORTIE, ID_RSS, MAX(DATE_GRP) AS DATE_GRP,
         MIN(DATE_CREAT) AS PREMIER_DAS, MAX(DATE_CREAT) AS DERNIER_DAS
  FROM dx
  GROUP BY THEME, MOIS_SORTIE, ID_RSS
),
agg AS (
  SELECT THEME, MOIS_SORTIE,
         COUNT(*) AS NB_AUJ,
         SUM(CASE WHEN DATE_GRP IS NULL THEN 1 ELSE 0 END) AS NB_SANS_GRP,
         SUM(CASE WHEN DATE_GRP IS NOT NULL AND PREMIER_DAS > DATE_GRP + 1 THEN 1 ELSE 0 END) AS NB_THEME_APRES,
         SUM(CASE WHEN DATE_GRP IS NOT NULL AND DERNIER_DAS > DATE_GRP + 1 THEN 1 ELSE 0 END) AS NB_UN_APRES
  FROM par_rss
  GROUP BY THEME, MOIS_SORTIE
)
SELECT '20261015-das-apres-premier-groupage' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       a.THEME,
       a.MOIS_SORTIE,
       CASE WHEN a.NB_THEME_APRES < 10 OR a.NB_AUJ - a.NB_THEME_APRES - a.NB_SANS_GRP < 10 THEN '<10'
            ELSE TO_CHAR(a.NB_THEME_APRES) END AS N_RSS_THEME_APRES_GRP,
       CASE WHEN a.NB_UN_APRES < 10 OR a.NB_UN_APRES - a.NB_THEME_APRES < 10 THEN '<10'
            ELSE TO_CHAR(a.NB_UN_APRES) END AS N_RSS_UN_DAS_APRES_GRP,
       CASE WHEN a.NB_SANS_GRP < 10 OR a.NB_AUJ - a.NB_THEME_APRES - a.NB_SANS_GRP < 10 THEN '<10'
            ELSE TO_CHAR(a.NB_SANS_GRP) END AS N_RSS_THEME_SANS_DATE_GRP,
       CASE WHEN m.NB_SANS_GRP < 10 THEN '<10' ELSE TO_CHAR(m.NB_SANS_GRP) END AS N_RSS_MOIS_SANS_DATE_GRP,
       CASE WHEN m.NB_PLUSIEURS < 10 THEN '<10' ELSE TO_CHAR(m.NB_PLUSIEURS) END AS N_RSS_MOIS_PLUSIEURS_CHRONO
FROM agg a
JOIN rss_mois m ON m.MOIS_SORTIE = a.MOIS_SORTIE
ORDER BY a.THEME, a.MOIS_SORTIE;
