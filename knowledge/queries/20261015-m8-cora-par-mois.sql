-- id: 20261015-m8-cora-par-mois
-- system: cora
-- person_data: masked
-- purpose: par mois de sortie des RSS MCO finis de janvier à août 2026 qui avaient une version groupée à M8 (2026-10-02 07:47:40), compter les RSS, ceux en CMD 90, ceux en GHM chirurgical, ceux qui portent un DAS de chacun des six thèmes, et le nombre de DAS, selon deux reconstitutions de l'état M8 : la ligne groupée stockée (LIGNES_GRP) et les DAS créés avant la coupure (DATE_CREAT) ; pour les comparer aux mêmes comptages lus dans le fichier .grp (étape 2 du plan)
-- Oracle, schéma CORA_REC. Version à M8 : la version actuelle si elle a été groupée avant la coupure, sinon la dernière copie de TB_HIST_SYNTH_RSS groupée avant. CMD, GHM et ligne groupée viennent de cette version.
-- Mois de sortie : TB_SYNTH_RSS.DATE_FIN. GHM chirurgical : CMD autre que 90 et 1er caractère de CODE_GHM = C.
-- N_LIGNE_GRP : DAS lus dans LIGNES_GRP de la version à M8 (NB_RUM lignes séparées par CHR(13) ; nDA en 134-135, DA n° k de 206 + 8 (k - 1)).
-- N_DATE_CREAT : DAS de TB_DIAG créés avant la coupure, plus ceux de TB_HIST_DIAG supprimés après la coupure et créés avant ; chemin TB_MVT_RUM par ID_MVT.
-- INDICATEUR : rss, cmd90, chirurgie, un thème (RSS qui en portent au moins un DAS), das (couples RSS-code distincts). Les lignes rss, cmd90 et chirurgie ont la même valeur dans les deux colonnes.
-- Règle 3 : chaque effectif sous 10 sort <10. Règle 4 : une ligne qui compte une partie des RSS du mois sort « masqué » quand la ligne rss moins elle vaut de 1 à 9.
WITH r AS (
  SELECT /*+ MATERIALIZE */ s.ID_RSS, s.CODE_CMD, s.CODE_GHM, s.NB_RUM,
         TO_CHAR(s.DATE_FIN, 'YYYY-MM') AS MOIS_SORTIE,
         TO_DATE(TO_CHAR(s.DATE_FABRICATION, 'YYYY-MM-DD') || ' ' || NVL(TO_CHAR(s.HEURE_FABRICATION, 'HH24:MI:SS'), '00:00:00'),
                 'YYYY-MM-DD HH24:MI:SS') AS FAB
  FROM CORA_REC.TB_SYNTH_RSS s
  WHERE s.DATE_FIN >= DATE '2026-01-01'
    AND s.DATE_FIN <  DATE '2026-09-01'
),
hv AS (
  SELECT /*+ MATERIALIZE */ ID_RSS, CODE_CMD, CODE_GHM, NB_RUM, ID_LIGNE
  FROM (
    SELECT x.ID_RSS, x.CODE_CMD, x.CODE_GHM, x.NB_RUM, x.RID AS ID_LIGNE,
           ROW_NUMBER() OVER (PARTITION BY x.ID_RSS ORDER BY x.FAB DESC, x.DATE_INFO DESC) AS RN
    FROM (
      SELECT h.ID_RSS, h.CODE_CMD, h.CODE_GHM, h.NB_RUM, h.DATE_INFO, h.ROWID AS RID,
             TO_DATE(TO_CHAR(h.DATE_FABRICATION, 'YYYY-MM-DD') || ' ' || NVL(TO_CHAR(h.HEURE_FABRICATION, 'HH24:MI:SS'), '00:00:00'),
                     'YYYY-MM-DD HH24:MI:SS') AS FAB
      FROM CORA_REC.TB_HIST_SYNTH_RSS h
      WHERE h.ID_RSS IN (SELECT ID_RSS FROM r WHERE FAB >= TIMESTAMP '2026-10-02 07:47:40')
        AND h.DATE_FABRICATION < DATE '2026-10-03'
    ) x
    WHERE x.FAB < TIMESTAMP '2026-10-02 07:47:40'
  )
  WHERE RN = 1
),
v AS (
  SELECT /*+ MATERIALIZE */ r.ID_RSS, r.MOIS_SORTIE, TRIM(r.CODE_CMD) AS CMD, TRIM(r.CODE_GHM) AS GHM, r.NB_RUM, s.LIGNES_GRP AS T
  FROM r JOIN CORA_REC.TB_SYNTH_RSS s ON s.ID_RSS = r.ID_RSS
  WHERE r.FAB < TIMESTAMP '2026-10-02 07:47:40'
  UNION ALL
  SELECT r.ID_RSS, r.MOIS_SORTIE, TRIM(hv.CODE_CMD), TRIM(hv.CODE_GHM), hv.NB_RUM, h.LIGNES_GRP
  FROM hv
  JOIN r ON r.ID_RSS = hv.ID_RSS
  JOIN CORA_REC.TB_HIST_SYNTH_RSS h ON h.ROWID = hv.ID_LIGNE
),
k AS (
  SELECT LEVEL AS K FROM DUAL CONNECT BY LEVEL <= 99
),
lignes AS (
  SELECT /*+ MATERIALIZE */ v.ID_RSS,
         DBMS_LOB.SUBSTR(v.T, 1200, CASE WHEN k.K = 1 THEN 1 ELSE DBMS_LOB.INSTR(v.T, CHR(13), 1, k.K - 1) + 1 END) AS L
  FROM v
  JOIN k ON k.K <= NVL(v.NB_RUM, 1)
  WHERE v.T IS NOT NULL
),
code_grp AS (
  SELECT DISTINCT g.ID_RSS,
         REPLACE(REPLACE(TRIM(SUBSTR(g.L, 206 + 8 * (k.K - 1), 8)), '.', ''), ' ', '') AS CODE
  FROM lignes g
  JOIN k ON k.K <= CASE WHEN REGEXP_LIKE(SUBSTR(g.L, 134, 2), '^[0-9]{2}$') THEN TO_NUMBER(SUBSTR(g.L, 134, 2)) ELSE 0 END
),
code_diag AS (
  SELECT DISTINCT mr.ID_RSS, REPLACE(REPLACE(TRIM(d.CODE_DIAG), '.', ''), ' ', '') AS CODE
  FROM CORA_REC.TB_MVT_RUM mr
  JOIN CORA_REC.TB_DIAG d ON d.ID_MVT = mr.ID_MVT
  WHERE mr.ID_RSS IN (SELECT ID_RSS FROM v)
    AND TRIM(d.TYPE_DIAG) = 'S'
    AND d.DATE_CREAT < TIMESTAMP '2026-10-02 07:47:40'
  UNION
  SELECT mr.ID_RSS, REPLACE(REPLACE(TRIM(h.CODE_DIAG), '.', ''), ' ', '')
  FROM CORA_REC.TB_MVT_RUM mr
  JOIN CORA_REC.TB_HIST_DIAG h ON h.ID_MVT = mr.ID_MVT
  WHERE mr.ID_RSS IN (SELECT ID_RSS FROM v)
    AND TRIM(h.TYPE_DIAG) = 'S'
    AND TRIM(h.TYPE_INFO) IN ('R', 'N')
    AND h.DATE_CREAT < TIMESTAMP '2026-10-02 07:47:40'
    AND TO_DATE(TO_CHAR(h.DATE_INFO, 'YYYY-MM-DD') || ' ' || TO_CHAR(NVL(h.HEURE_INFO, h.DATE_INFO), 'HH24:MI:SS'),
                'YYYY-MM-DD HH24:MI:SS') >= TIMESTAMP '2026-10-02 07:47:40'
),
codes AS (
  SELECT 'ligne_grp' AS SOURCE, ID_RSS, CODE FROM code_grp WHERE CODE IS NOT NULL
  UNION ALL
  SELECT 'date_creat', ID_RSS, CODE FROM code_diag WHERE CODE IS NOT NULL
),
ct AS (
  SELECT c.SOURCE, c.ID_RSS, c.CODE,
         CASE
           WHEN SUBSTR(c.CODE, 1, 3) IN ('E40','E41','E42','E43','E44','E45','E46') THEN 'denutrition'
           WHEN c.CODE LIKE 'L89%' THEN 'escarres'
           WHEN c.CODE LIKE 'R33%' THEN 'retention_urine'
           WHEN c.CODE LIKE 'R521%' OR c.CODE LIKE 'R522%' THEN 'douleur_chronique'
           WHEN SUBSTR(c.CODE, 1, 3) IN ('U82','U83','U84','U85') THEN 'resistance_atb'
           WHEN c.CODE LIKE 'Z290%' THEN 'isolement_prophylactique'
         END AS THEME
  FROM codes c
),
vm AS (
  SELECT DISTINCT ID_RSS, MOIS_SORTIE, CMD, GHM FROM v
),
ind AS (
  SELECT MOIS_SORTIE, 'rss' AS INDICATEUR, COUNT(*) AS NB_GRP, COUNT(*) AS NB_DC FROM vm GROUP BY MOIS_SORTIE
  UNION ALL
  SELECT MOIS_SORTIE, 'cmd90', SUM(CASE WHEN CMD = '90' THEN 1 ELSE 0 END), SUM(CASE WHEN CMD = '90' THEN 1 ELSE 0 END) FROM vm GROUP BY MOIS_SORTIE
  UNION ALL
  SELECT MOIS_SORTIE, 'chirurgie', SUM(CASE WHEN CMD <> '90' AND SUBSTR(GHM, 1, 1) = 'C' THEN 1 ELSE 0 END),
         SUM(CASE WHEN CMD <> '90' AND SUBSTR(GHM, 1, 1) = 'C' THEN 1 ELSE 0 END) FROM vm GROUP BY MOIS_SORTIE
  UNION ALL
  SELECT vm.MOIS_SORTIE, ct.THEME,
         COUNT(DISTINCT CASE WHEN ct.SOURCE = 'ligne_grp' THEN ct.ID_RSS END),
         COUNT(DISTINCT CASE WHEN ct.SOURCE = 'date_creat' THEN ct.ID_RSS END)
  FROM ct JOIN vm ON vm.ID_RSS = ct.ID_RSS
  WHERE ct.THEME IS NOT NULL
  GROUP BY vm.MOIS_SORTIE, ct.THEME
  UNION ALL
  SELECT vm.MOIS_SORTIE, 'das',
         SUM(CASE WHEN ct.SOURCE = 'ligne_grp' THEN 1 ELSE 0 END),
         SUM(CASE WHEN ct.SOURCE = 'date_creat' THEN 1 ELSE 0 END)
  FROM ct JOIN vm ON vm.ID_RSS = ct.ID_RSS
  GROUP BY vm.MOIS_SORTIE
),
w AS (
  SELECT i.MOIS_SORTIE, i.INDICATEUR, i.NB_GRP, i.NB_DC,
         MAX(CASE WHEN i.INDICATEUR = 'rss' THEN i.NB_GRP END) OVER (PARTITION BY i.MOIS_SORTIE) AS NB_RSS
  FROM ind i
)
SELECT '20261015-m8-cora-par-mois' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       MOIS_SORTIE,
       INDICATEUR,
       CASE WHEN NB_GRP < 10 THEN '<10'
            WHEN INDICATEUR NOT IN ('rss', 'das') AND NB_RSS - NB_GRP BETWEEN 1 AND 9 THEN 'masqué'
            ELSE TO_CHAR(NB_GRP) END AS N_LIGNE_GRP,
       CASE WHEN NB_DC < 10 THEN '<10'
            WHEN INDICATEUR NOT IN ('rss', 'das') AND NB_RSS - NB_DC BETWEEN 1 AND 9 THEN 'masqué'
            ELSE TO_CHAR(NB_DC) END AS N_DATE_CREAT
FROM w
ORDER BY MOIS_SORTIE, INDICATEUR;
