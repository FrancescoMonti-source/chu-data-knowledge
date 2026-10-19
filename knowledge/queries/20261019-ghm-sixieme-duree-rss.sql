-- id: 20261019-ghm-sixieme-duree-rss
-- system: cora
-- person_data: masked
-- purpose: deux mesures de TB_SYNTH_RSS par année de fin. GHM : répartition du 6e caractère du GHM complet (CODE_CMD || CODE_GHM) par type de GHM (1er caractère de CODE_GHM) et longueur de TRIM(CODE_GHM), pour separer-ambulatoire-par-ghm (amendement : le GHM complet a 6 caractères, les lettres J, T, E, Z et A à D ne sont pas des niveaux ordinaux ; une longueur de CODE_GHM autre que 4 change la règle SUBSTR(...,-1)). DUREE : écart entre DUREE_SEJOUR et DATE_FIN − DATE_DEBUT en nuitées, pour duree-sejour-journees-ou-nuitees (DUREE_SEJOUR du RSS est-il en nuitées, en journées ou autre ; part d'écart par année)
-- Oracle 11g, schéma CORA_REC. RSS de TB_SYNTH_RSS dont DATE_FIN va du 2018-01-01 à aujourd'hui, par année de DATE_FIN. Valeurs vides en « (vide) ».
-- Niveau GHM : DIM_1 = type de GHM, DIM_2 = 6e caractère de TRIM(CODE_CMD) || TRIM(CODE_GHM), DIM_3 = longueur de TRIM(CODE_GHM). Niveau DUREE : DIM_1 = DUREE_SEJOUR − (TRUNC(DATE_FIN) − TRUNC(DATE_DEBUT)) en classes '<-1', '-1', '0', '+1', '>+1' ('(vide)' si l'une des valeurs manque), DIM_2 = classe de nuitées des dates ('0 nuit', '1 nuit', '2+ nuits'), DIM_3 = CMD ('28' séances, '90' erreurs, 'autre').
-- Colonnes : NIVEAU, ANNEE, DIM_1, DIM_2, DIM_3, N (RSS), PCT_GROUPE (part de la ligne dans son groupe : le type de GHM pour GHM, la classe de nuitées pour DUREE ; vide quand N est masqué).
-- Masquage : chaque effectif < 10 sort en <10. Suppression secondaire (règle 4) : quand les cases masquées d'un niveau, d'une année et d'un groupe totalisent de 1 à 9, la plus grande case du groupe sort aussi en « masqué ». Aucune ligne de total.
WITH r AS (
  SELECT EXTRACT(YEAR FROM DATE_FIN) AS ANNEE,
         NVL(SUBSTR(TRIM(CODE_GHM), 1, 1), '(vide)') AS TYPE_GHM,
         NVL(SUBSTR(TRIM(CODE_CMD) || TRIM(CODE_GHM), 6, 1), '(vide)') AS SIXIEME,
         NVL(TO_CHAR(LENGTH(TRIM(CODE_GHM))), '(vide)') AS LONGUEUR,
         CASE WHEN DUREE_SEJOUR IS NULL OR DATE_DEBUT IS NULL THEN '(vide)'
              WHEN DUREE_SEJOUR - (TRUNC(DATE_FIN) - TRUNC(DATE_DEBUT)) < -1 THEN '<-1'
              WHEN DUREE_SEJOUR - (TRUNC(DATE_FIN) - TRUNC(DATE_DEBUT)) = -1 THEN '-1'
              WHEN DUREE_SEJOUR - (TRUNC(DATE_FIN) - TRUNC(DATE_DEBUT)) = 0 THEN '0'
              WHEN DUREE_SEJOUR - (TRUNC(DATE_FIN) - TRUNC(DATE_DEBUT)) = 1 THEN '+1'
              ELSE '>+1' END AS ECART,
         CASE WHEN DATE_DEBUT IS NULL THEN '(vide)'
              WHEN TRUNC(DATE_FIN) - TRUNC(DATE_DEBUT) <= 0 THEN '0 nuit'
              WHEN TRUNC(DATE_FIN) - TRUNC(DATE_DEBUT) = 1 THEN '1 nuit'
              ELSE '2+ nuits' END AS CLASSE_NUITEES,
         CASE WHEN TRIM(CODE_CMD) = '28' THEN '28' WHEN TRIM(CODE_CMD) = '90' THEN '90' ELSE 'autre' END AS CMD
  FROM CORA_REC.TB_SYNTH_RSS
  WHERE DATE_FIN >= DATE '2018-01-01' AND DATE_FIN < TRUNC(SYSDATE) + 1
),
c AS (
  SELECT 'GHM' AS NIVEAU, ANNEE, TYPE_GHM AS DIM_1, SIXIEME AS DIM_2, LONGUEUR AS DIM_3,
         TYPE_GHM AS GROUPE, COUNT(*) AS N
  FROM r
  GROUP BY ANNEE, TYPE_GHM, SIXIEME, LONGUEUR
  UNION ALL
  SELECT 'DUREE', ANNEE, ECART, CLASSE_NUITEES, CMD, CLASSE_NUITEES, COUNT(*)
  FROM r
  GROUP BY ANNEE, ECART, CLASSE_NUITEES, CMD
),
m AS (
  SELECT NIVEAU, ANNEE, DIM_1, DIM_2, DIM_3, GROUPE, N,
         SUM(N) OVER (PARTITION BY NIVEAU, ANNEE, GROUPE) AS TOT,
         SUM(CASE WHEN N < 10 THEN N ELSE 0 END) OVER (PARTITION BY NIVEAU, ANNEE, GROUPE) AS CACHE,
         ROW_NUMBER() OVER (PARTITION BY NIVEAU, ANNEE, GROUPE ORDER BY N DESC, DIM_1, DIM_2, DIM_3) AS RANG
  FROM c
)
SELECT '20261019-ghm-sixieme-duree-rss' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       NIVEAU, ANNEE, DIM_1, DIM_2, DIM_3,
       CASE WHEN N < 10 THEN '<10' WHEN CACHE BETWEEN 1 AND 9 AND RANG = 1 THEN 'masqué' ELSE TO_CHAR(N) END AS N,
       CASE WHEN N < 10 OR (CACHE BETWEEN 1 AND 9 AND RANG = 1) THEN NULL ELSE ROUND(100 * N / TOT, 2) END AS PCT_GROUPE
FROM m
ORDER BY NIVEAU, ANNEE, DIM_1, DIM_2, DIM_3;
