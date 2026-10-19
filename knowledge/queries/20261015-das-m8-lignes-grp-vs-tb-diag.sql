-- id: 20261015-das-m8-lignes-grp-vs-tb-diag
-- system: cora
-- person_data: masked
-- purpose: pour les RSS MCO à un seul RUM finis de janvier à août 2026, comparer les DAS lus dans la ligne groupée (LIGNES_GRP) de la version à M8 (2026-10-02 07:47:40) aux DAS que la reconstitution tire de TB_DIAG et TB_HIST_DIAG, par thème et pour tous les DAS ; et faire la même comparaison aujourd'hui, comme témoin de la lecture (étape 2 du plan)
-- Oracle, schéma CORA_REC. Mise en page de LIGNES_GRP : celle du fichier groupé, longueur = somme des tailles des champs (20261015-forme-lignes-grp-resultat). nDA en 134-135, DA n° k de 206 + 8 (k - 1), sur 8 caractères.
-- Seuls les RSS à un seul RUM (NB_RUM = 1 dans la version lue) : pour plusieurs RUM, le séparateur des lignes dans LIGNES_GRP n'est pas encore connu.
-- Version à M8 : la version actuelle si elle a été groupée avant la coupure, sinon la dernière copie de TB_HIST_SYNTH_RSS groupée avant ; les RSS sans version à M8 sont écartés de l'état m8.
-- Reconstitution à M8 : DAS de TB_DIAG créés avant la coupure, plus ceux de TB_HIST_DIAG supprimés après la coupure et créés avant (comme 20261015-classes-themes-m8). Aujourd'hui : DAS de TB_DIAG.
-- Unité : un couple (RSS, thème) pour les lignes de thème ; un couple (RSS, code) pour la ligne tout_das. Codes comparés sans point ni espace.
-- N_LES_DEUX : le couple est des deux côtés. N_SEULEMENT_LIGNE_GRP : dans la ligne groupée seulement. N_SEULEMENT_TB_DIAG : dans TB_DIAG (ou la reconstitution) seulement.
-- Règle 4 : pas de colonne total ni de ligne total ; les trois colonnes partagent les couples de la ligne sans total affiché.
WITH r AS (
  SELECT s.ID_RSS, s.NB_RUM, s.LIGNES_GRP,
         TO_DATE(TO_CHAR(s.DATE_FABRICATION, 'YYYY-MM-DD') || ' ' || NVL(TO_CHAR(s.HEURE_FABRICATION, 'HH24:MI:SS'), '00:00:00'),
                 'YYYY-MM-DD HH24:MI:SS') AS FAB
  FROM CORA_REC.TB_SYNTH_RSS s
  WHERE s.DATE_FIN >= DATE '2026-01-01'
    AND s.DATE_FIN <  DATE '2026-09-01'
),
hv AS (
  SELECT ID_RSS, NB_RUM, LIGNES_GRP
  FROM (
    SELECT x.ID_RSS, x.NB_RUM, x.LIGNES_GRP,
           ROW_NUMBER() OVER (PARTITION BY x.ID_RSS ORDER BY x.FAB DESC, x.DATE_INFO DESC) AS RN
    FROM (
      SELECT h.ID_RSS, h.NB_RUM, h.LIGNES_GRP, h.DATE_INFO,
             TO_DATE(TO_CHAR(h.DATE_FABRICATION, 'YYYY-MM-DD') || ' ' || NVL(TO_CHAR(h.HEURE_FABRICATION, 'HH24:MI:SS'), '00:00:00'),
                     'YYYY-MM-DD HH24:MI:SS') AS FAB
      FROM CORA_REC.TB_HIST_SYNTH_RSS h
      WHERE h.ID_RSS IN (SELECT ID_RSS FROM r)
    ) x
    WHERE x.FAB < TIMESTAMP '2026-10-02 07:47:40'
  )
  WHERE RN = 1
),
v AS (
  SELECT 'aujourdhui' AS ETAT, r.ID_RSS,
         RTRIM(DBMS_LOB.SUBSTR(r.LIGNES_GRP, 4000, 1), CHR(13) || CHR(10)) AS L
  FROM r
  WHERE r.NB_RUM = 1
  UNION ALL
  SELECT 'm8', r.ID_RSS,
         RTRIM(DBMS_LOB.SUBSTR(r.LIGNES_GRP, 4000, 1), CHR(13) || CHR(10))
  FROM r
  WHERE r.NB_RUM = 1 AND r.FAB < TIMESTAMP '2026-10-02 07:47:40'
  UNION ALL
  SELECT 'm8', hv.ID_RSS,
         RTRIM(DBMS_LOB.SUBSTR(hv.LIGNES_GRP, 4000, 1), CHR(13) || CHR(10))
  FROM hv
  JOIN r ON r.ID_RSS = hv.ID_RSS
  WHERE hv.NB_RUM = 1 AND r.FAB >= TIMESTAMP '2026-10-02 07:47:40'
),
n AS (
  SELECT LEVEL AS K FROM DUAL CONNECT BY LEVEL <= 99
),
cote_grp AS (
  SELECT DISTINCT v.ETAT, v.ID_RSS,
         REPLACE(REPLACE(TRIM(SUBSTR(v.L, 206 + 8 * (n.K - 1), 8)), '.', ''), ' ', '') AS CODE
  FROM v
  JOIN n ON n.K <= CASE WHEN REGEXP_LIKE(SUBSTR(v.L, 134, 2), '^[0-9]{2}$') THEN TO_NUMBER(SUBSTR(v.L, 134, 2)) ELSE 0 END
),
das AS (
  SELECT mr.ID_RSS, REPLACE(REPLACE(TRIM(d.CODE_DIAG), '.', ''), ' ', '') AS CODE, d.DATE_CREAT, 1 AS ACTUEL
  FROM CORA_REC.TB_MVT_RUM mr
  JOIN CORA_REC.TB_DIAG d ON d.ID_MVT = mr.ID_MVT
  WHERE mr.ID_RSS IN (SELECT ID_RSS FROM v)
    AND TRIM(d.TYPE_DIAG) = 'S'
  UNION ALL
  SELECT mr.ID_RSS, REPLACE(REPLACE(TRIM(h.CODE_DIAG), '.', ''), ' ', ''), h.DATE_CREAT, 0
  FROM CORA_REC.TB_MVT_RUM mr
  JOIN CORA_REC.TB_HIST_DIAG h ON h.ID_MVT = mr.ID_MVT
  WHERE mr.ID_RSS IN (SELECT ID_RSS FROM v)
    AND TRIM(h.TYPE_DIAG) = 'S'
    AND TRIM(h.TYPE_INFO) IN ('R', 'N')
    AND TO_DATE(TO_CHAR(h.DATE_INFO, 'YYYY-MM-DD') || ' ' || TO_CHAR(NVL(h.HEURE_INFO, h.DATE_INFO), 'HH24:MI:SS'),
                'YYYY-MM-DD HH24:MI:SS') >= TIMESTAMP '2026-10-02 07:47:40'
),
cote_diag AS (
  SELECT DISTINCT 'aujourdhui' AS ETAT, ID_RSS, CODE FROM das WHERE ACTUEL = 1
  UNION
  SELECT DISTINCT 'm8', ID_RSS, CODE FROM das WHERE DATE_CREAT < TIMESTAMP '2026-10-02 07:47:40'
),
diag_v AS (
  SELECT c.ETAT, c.ID_RSS, c.CODE
  FROM cote_diag c
  WHERE EXISTS (SELECT 1 FROM v WHERE v.ETAT = c.ETAT AND v.ID_RSS = c.ID_RSS)
),
paires AS (
  SELECT NVL(g.ETAT, d.ETAT) AS ETAT, NVL(g.ID_RSS, d.ID_RSS) AS ID_RSS, NVL(g.CODE, d.CODE) AS CODE,
         CASE WHEN g.CODE IS NOT NULL THEN 1 ELSE 0 END AS IN_GRP,
         CASE WHEN d.CODE IS NOT NULL THEN 1 ELSE 0 END AS IN_DIAG
  FROM (SELECT ETAT, ID_RSS, CODE FROM cote_grp WHERE CODE IS NOT NULL) g
  FULL OUTER JOIN diag_v d ON d.ETAT = g.ETAT AND d.ID_RSS = g.ID_RSS AND d.CODE = g.CODE
),
pt AS (
  SELECT ETAT, ID_RSS, IN_GRP, IN_DIAG,
         CASE
           WHEN SUBSTR(CODE, 1, 3) IN ('E40','E41','E42','E43','E44','E45','E46') THEN 'denutrition'
           WHEN CODE LIKE 'L89%' THEN 'escarres'
           WHEN CODE LIKE 'R33%' THEN 'retention_urine'
           WHEN CODE LIKE 'R521%' OR CODE LIKE 'R522%' THEN 'douleur_chronique'
           WHEN SUBSTR(CODE, 1, 3) IN ('U82','U83','U84','U85') THEN 'resistance_atb'
           WHEN CODE LIKE 'Z290%' THEN 'isolement_prophylactique'
         END AS THEME
  FROM paires
),
par_theme AS (
  SELECT ETAT, THEME, ID_RSS, MAX(IN_GRP) AS IN_GRP, MAX(IN_DIAG) AS IN_DIAG
  FROM pt
  WHERE THEME IS NOT NULL
  GROUP BY ETAT, THEME, ID_RSS
),
unites AS (
  SELECT ETAT, THEME, IN_GRP, IN_DIAG FROM par_theme
  UNION ALL
  SELECT ETAT, 'tout_das', IN_GRP, IN_DIAG FROM paires
),
agg AS (
  SELECT ETAT, THEME,
         SUM(CASE WHEN IN_GRP = 1 AND IN_DIAG = 1 THEN 1 ELSE 0 END) AS NB_DEUX,
         SUM(CASE WHEN IN_GRP = 1 AND IN_DIAG = 0 THEN 1 ELSE 0 END) AS NB_GRP,
         SUM(CASE WHEN IN_GRP = 0 AND IN_DIAG = 1 THEN 1 ELSE 0 END) AS NB_DIAG
  FROM unites
  GROUP BY ETAT, THEME
)
SELECT '20261015-das-m8-lignes-grp-vs-tb-diag' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       ETAT,
       THEME,
       CASE WHEN NB_DEUX < 10 THEN '<10' ELSE TO_CHAR(NB_DEUX) END AS N_LES_DEUX,
       CASE WHEN NB_GRP < 10 THEN '<10' ELSE TO_CHAR(NB_GRP) END AS N_SEULEMENT_LIGNE_GRP,
       CASE WHEN NB_DIAG < 10 THEN '<10' ELSE TO_CHAR(NB_DIAG) END AS N_SEULEMENT_TB_DIAG
FROM agg
ORDER BY ETAT, THEME;
