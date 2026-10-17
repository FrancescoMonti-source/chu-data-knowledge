-- id: 20261015-classes-m8-regroupes
-- system: cora
-- person_data: masked
-- purpose: pour les RSS MCO finis de janvier à août 2026, groupés hors CMD 90 aujourd'hui et regroupés après l'état M8 (2026-10-02 07:47:40), en GHM chirurgical ou non, compter par thème ceux qui ont gagné ou perdu un DAS du thème entre la ligne groupée de la version à M8 et la ligne groupée actuelle, répartis en classes A, B, C, et chiffrer la classe B (étapes 3, 4 et 5 du plan). Version rapide de 20261015-classes-themes-m8-lignes-grp, arrêtée après 30 minutes sans résultat.
-- Oracle, schéma CORA_REC. État d'un RSS = les DAS de sa ligne groupée (LIGNES_GRP), tous RUM compris : ce que le groupage a vu.
-- Seuls les RSS regroupés après la coupure peuvent avoir changé : pour les autres, la ligne de M8 est la ligne actuelle. C'est ce qui rend la requête rapide.
-- Lecture de LIGNES_GRP : NB_RUM lignes séparées par CHR(13) (20261015-separateur-lignes-grp-resultat) ; nDA en 134-135, DA n° k de 206 + 8 (k - 1), sur 8 caractères (20261015-forme-lignes-grp-resultat).
-- Version à M8 : la dernière copie de TB_HIST_SYNTH_RSS groupée avant la coupure. Date de groupage : jour de DATE_FABRICATION, heure de HEURE_FABRICATION.
-- GROUPE : chirurgie si le 1er caractère de CODE_GHM aujourd'hui vaut C, sinon hors_chirurgie. Pas de ligne qui somme les deux groupes.
-- Colonnes de classe (chaque RSS dans une seule) :
--   N_RSS_A_CMD90_M8 : en CMD 90 à M8. N_RSS_A_SANS_VERSION_M8 : aucune version groupée avant la coupure.
--   N_RSS_B_NIVEAU_MONTE, N_RSS_C_MEME_NIVEAU, N_RSS_NIVEAU_BAISSE : même type de GHM à M8 et aujourd'hui, niveau 1-4 aux deux dates.
--   N_RSS_C_SANS_NIVEAU : même type, mais un niveau hors 1-4 (J, T, lettre) à M8 ou aujourd'hui.
--   N_RSS_TYPE_CHANGE : type de GHM différent à M8 (changé pour une autre raison qu'un DAS) ; hors des classes.
-- N_RSS_DAS_SAISI_AVANT_M8 : pour un gain, le DAS du thème a été créé (TB_DIAG.DATE_CREAT) avant la coupure, mais le RSS n'avait pas été regroupé avant M8. Il compte aussi dans sa colonne de classe.
-- EUROS_B : somme de MONTANT_GHS aujourd'hui moins MONTANT_GHS à M8, sur la classe B.
-- Ligne THEME = tous : RSS qui ont gagné (ou perdu) au moins un thème, comptés une fois.
-- Règle 3 : chaque effectif sous 10 sort <10 ; EUROS_B sort <10 quand la classe B a moins de 10 RSS.
-- Règle 4 : pas de colonne total ni de ligne qui somme les groupes. N_RSS_DAS_SAISI_AVANT_M8 sort « masqué » quand l'effectif de la ligne moins elle vaut de 1 à 9.
WITH r AS (
  SELECT /*+ MATERIALIZE */ ID_RSS, CODE_CMD, CODE_GHM, MONTANT_GHS, NB_RUM, GROUPE
  FROM (
    SELECT s.ID_RSS, s.CODE_CMD, s.CODE_GHM, s.MONTANT_GHS, s.NB_RUM,
           CASE WHEN SUBSTR(TRIM(s.CODE_GHM), 1, 1) = 'C' THEN 'chirurgie' ELSE 'hors_chirurgie' END AS GROUPE,
           TO_DATE(TO_CHAR(s.DATE_FABRICATION, 'YYYY-MM-DD') || ' ' || NVL(TO_CHAR(s.HEURE_FABRICATION, 'HH24:MI:SS'), '00:00:00'),
                   'YYYY-MM-DD HH24:MI:SS') AS FAB
    FROM CORA_REC.TB_SYNTH_RSS s
    WHERE s.DATE_FIN >= DATE '2026-01-01'
      AND s.DATE_FIN <  DATE '2026-09-01'
      AND TRIM(s.CODE_CMD) <> '90'
      AND s.DATE_FABRICATION >= DATE '2026-10-02'
  )
  WHERE FAB >= TIMESTAMP '2026-10-02 07:47:40'
),
hv AS (
  SELECT /*+ MATERIALIZE */ ID_RSS, CODE_CMD, CODE_GHM, MONTANT_GHS, NB_RUM, ID_LIGNE
  FROM (
    SELECT x.ID_RSS, x.CODE_CMD, x.CODE_GHM, x.MONTANT_GHS, x.NB_RUM, x.RID AS ID_LIGNE,
           ROW_NUMBER() OVER (PARTITION BY x.ID_RSS ORDER BY x.FAB DESC, x.DATE_INFO DESC) AS RN
    FROM (
      SELECT h.ID_RSS, h.CODE_CMD, h.CODE_GHM, h.MONTANT_GHS, h.NB_RUM, h.DATE_INFO, h.ROWID AS RID,
             TO_DATE(TO_CHAR(h.DATE_FABRICATION, 'YYYY-MM-DD') || ' ' || NVL(TO_CHAR(h.HEURE_FABRICATION, 'HH24:MI:SS'), '00:00:00'),
                     'YYYY-MM-DD HH24:MI:SS') AS FAB
      FROM CORA_REC.TB_HIST_SYNTH_RSS h
      WHERE h.ID_RSS IN (SELECT ID_RSS FROM r)
        AND h.DATE_FABRICATION < DATE '2026-10-03'
    ) x
    WHERE x.FAB < TIMESTAMP '2026-10-02 07:47:40'
  )
  WHERE RN = 1
),
etat AS (
  SELECT r.ID_RSS, r.GROUPE,
         TRIM(r.CODE_GHM) AS GHM_AUJ, r.MONTANT_GHS AS MNT_AUJ,
         TRIM(hv.CODE_CMD) AS CMD_M8, TRIM(hv.CODE_GHM) AS GHM_M8, hv.MONTANT_GHS AS MNT_M8,
         CASE WHEN hv.ID_RSS IS NOT NULL THEN 1 ELSE 0 END AS A_VERSION
  FROM r
  LEFT JOIN hv ON hv.ID_RSS = r.ID_RSS
),
k AS (
  SELECT LEVEL AS K FROM DUAL CONNECT BY LEVEL <= 99
),
txt AS (
  SELECT /*+ MATERIALIZE */ 'aujourdhui' AS ETAT, r.ID_RSS, r.NB_RUM, s.LIGNES_GRP AS T
  FROM r JOIN CORA_REC.TB_SYNTH_RSS s ON s.ID_RSS = r.ID_RSS
  UNION ALL
  SELECT 'm8', hv.ID_RSS, hv.NB_RUM, h.LIGNES_GRP
  FROM hv JOIN CORA_REC.TB_HIST_SYNTH_RSS h ON h.ROWID = hv.ID_LIGNE
),
lignes AS (
  SELECT /*+ MATERIALIZE */ t.ETAT, t.ID_RSS,
         DBMS_LOB.SUBSTR(t.T, 1200, CASE WHEN k.K = 1 THEN 1 ELSE DBMS_LOB.INSTR(t.T, CHR(13), 1, k.K - 1) + 1 END) AS L
  FROM txt t
  JOIN k ON k.K <= NVL(t.NB_RUM, 1)
  WHERE t.T IS NOT NULL
),
codes AS (
  SELECT DISTINCT g.ETAT, g.ID_RSS,
         REPLACE(REPLACE(TRIM(SUBSTR(g.L, 206 + 8 * (k.K - 1), 8)), '.', ''), ' ', '') AS CODE
  FROM lignes g
  JOIN k ON k.K <= CASE WHEN REGEXP_LIKE(SUBSTR(g.L, 134, 2), '^[0-9]{2}$') THEN TO_NUMBER(SUBSTR(g.L, 134, 2)) ELSE 0 END
),
ct AS (
  SELECT ETAT, ID_RSS,
         CASE
           WHEN SUBSTR(CODE, 1, 3) IN ('E40','E41','E42','E43','E44','E45','E46') THEN 'denutrition'
           WHEN CODE LIKE 'L89%' THEN 'escarres'
           WHEN CODE LIKE 'R33%' THEN 'retention_urine'
           WHEN CODE LIKE 'R521%' OR CODE LIKE 'R522%' THEN 'douleur_chronique'
           WHEN SUBSTR(CODE, 1, 3) IN ('U82','U83','U84','U85') THEN 'resistance_atb'
           WHEN CODE LIKE 'Z290%' THEN 'isolement_prophylactique'
         END AS THEME
  FROM codes
),
th AS (
  SELECT ID_RSS, THEME,
         MAX(CASE WHEN ETAT = 'aujourdhui' THEN 1 ELSE 0 END) AS AUJ,
         MAX(CASE WHEN ETAT = 'm8' THEN 1 ELSE 0 END) AS M8
  FROM ct
  WHERE THEME IS NOT NULL
  GROUP BY ID_RSS, THEME
),
das AS (
  SELECT mr.ID_RSS, REPLACE(TRIM(d.CODE_DIAG), '.', '') AS CODE, d.DATE_CREAT
  FROM CORA_REC.TB_MVT_RUM mr
  JOIN CORA_REC.TB_DIAG d ON d.ID_MVT = mr.ID_MVT
  WHERE mr.ID_RSS IN (SELECT ID_RSS FROM th WHERE AUJ = 1 AND M8 = 0)
    AND TRIM(d.TYPE_DIAG) = 'S'
),
saisie AS (
  SELECT ID_RSS, THEME, MIN(DATE_CREAT) AS PREMIER
  FROM (
    SELECT ID_RSS, DATE_CREAT,
           CASE
             WHEN SUBSTR(CODE, 1, 3) IN ('E40','E41','E42','E43','E44','E45','E46') THEN 'denutrition'
             WHEN CODE LIKE 'L89%' THEN 'escarres'
             WHEN CODE LIKE 'R33%' THEN 'retention_urine'
             WHEN CODE LIKE 'R521%' OR CODE LIKE 'R522%' THEN 'douleur_chronique'
             WHEN SUBSTR(CODE, 1, 3) IN ('U82','U83','U84','U85') THEN 'resistance_atb'
             WHEN CODE LIKE 'Z290%' THEN 'isolement_prophylactique'
           END AS THEME
    FROM das
  )
  WHERE THEME IS NOT NULL
  GROUP BY ID_RSS, THEME
),
mv AS (
  SELECT t.ID_RSS, t.THEME, CASE WHEN t.AUJ = 1 THEN 'gain' ELSE 'perte' END AS SENS,
         CASE WHEN t.AUJ = 1 AND s.PREMIER < TIMESTAMP '2026-10-02 07:47:40' THEN 1 ELSE 0 END AS SAISI_AVANT
  FROM th t
  LEFT JOIN saisie s ON s.ID_RSS = t.ID_RSS AND s.THEME = t.THEME
  WHERE t.AUJ <> t.M8
),
mv2 AS (
  SELECT ID_RSS, THEME, SENS, SAISI_AVANT FROM mv
  UNION ALL
  SELECT ID_RSS, 'tous', SENS, MAX(SAISI_AVANT) FROM mv GROUP BY ID_RSS, SENS
),
cl AS (
  SELECT e.GROUPE, m.SENS, m.THEME, m.ID_RSS, m.SAISI_AVANT,
         CASE
           WHEN e.A_VERSION = 0 THEN 'A_SANS_VERSION'
           WHEN e.CMD_M8 = '90' THEN 'A_CMD90'
           WHEN SUBSTR(e.GHM_M8, 1, 1) <> SUBSTR(e.GHM_AUJ, 1, 1) THEN 'TYPE_CHANGE'
           WHEN SUBSTR(e.GHM_M8, -1, 1) NOT IN ('1','2','3','4') OR SUBSTR(e.GHM_AUJ, -1, 1) NOT IN ('1','2','3','4') THEN 'C_SANS_NIVEAU'
           WHEN SUBSTR(e.GHM_AUJ, -1, 1) > SUBSTR(e.GHM_M8, -1, 1) THEN 'B'
           WHEN SUBSTR(e.GHM_AUJ, -1, 1) = SUBSTR(e.GHM_M8, -1, 1) THEN 'C'
           ELSE 'BAISSE'
         END AS CLASSE,
         NVL(e.MNT_AUJ, 0) - NVL(e.MNT_M8, 0) AS DELTA
  FROM mv2 m
  JOIN etat e ON e.ID_RSS = m.ID_RSS
),
agg AS (
  SELECT GROUPE, SENS, THEME,
         COUNT(*) AS NB,
         SUM(CASE WHEN CLASSE = 'A_CMD90' THEN 1 ELSE 0 END) AS NB_A90,
         SUM(CASE WHEN CLASSE = 'A_SANS_VERSION' THEN 1 ELSE 0 END) AS NB_ASV,
         SUM(CASE WHEN CLASSE = 'B' THEN 1 ELSE 0 END) AS NB_B,
         SUM(CASE WHEN CLASSE = 'C' THEN 1 ELSE 0 END) AS NB_C,
         SUM(CASE WHEN CLASSE = 'BAISSE' THEN 1 ELSE 0 END) AS NB_BAISSE,
         SUM(CASE WHEN CLASSE = 'C_SANS_NIVEAU' THEN 1 ELSE 0 END) AS NB_CSN,
         SUM(CASE WHEN CLASSE = 'TYPE_CHANGE' THEN 1 ELSE 0 END) AS NB_TC,
         SUM(SAISI_AVANT) AS NB_SAISI,
         SUM(CASE WHEN CLASSE = 'B' THEN DELTA ELSE 0 END) AS EUR_B
  FROM cl
  GROUP BY GROUPE, SENS, THEME
)
SELECT '20261015-classes-m8-regroupes' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       GROUPE,
       SENS,
       THEME,
       CASE WHEN NB_A90 < 10 THEN '<10' ELSE TO_CHAR(NB_A90) END AS N_RSS_A_CMD90_M8,
       CASE WHEN NB_ASV < 10 THEN '<10' ELSE TO_CHAR(NB_ASV) END AS N_RSS_A_SANS_VERSION_M8,
       CASE WHEN NB_B < 10 THEN '<10' ELSE TO_CHAR(NB_B) END AS N_RSS_B_NIVEAU_MONTE,
       CASE WHEN NB_C < 10 THEN '<10' ELSE TO_CHAR(NB_C) END AS N_RSS_C_MEME_NIVEAU,
       CASE WHEN NB_BAISSE < 10 THEN '<10' ELSE TO_CHAR(NB_BAISSE) END AS N_RSS_NIVEAU_BAISSE,
       CASE WHEN NB_CSN < 10 THEN '<10' ELSE TO_CHAR(NB_CSN) END AS N_RSS_C_SANS_NIVEAU,
       CASE WHEN NB_TC < 10 THEN '<10' ELSE TO_CHAR(NB_TC) END AS N_RSS_TYPE_CHANGE,
       CASE WHEN NB_SAISI < 10 THEN '<10' WHEN NB - NB_SAISI BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(NB_SAISI) END AS N_RSS_DAS_SAISI_AVANT_M8,
       CASE WHEN NB_B < 10 THEN '<10' ELSE TO_CHAR(ROUND(EUR_B)) END AS EUROS_B
FROM agg
ORDER BY GROUPE, SENS, THEME;
