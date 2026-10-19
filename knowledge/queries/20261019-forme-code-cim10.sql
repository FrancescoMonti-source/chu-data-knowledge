-- id: 20261019-forme-code-cim10
-- system: cora
-- person_data: masked
-- purpose: pour chaque année, la forme des codes CIM-10 de TB_DIAG.CODE_DIAG et du DP des RSS (TB_SYNTH_RSS.DP_RETENU) : avec ou sans point, espace en tête ou interne, minuscule, longueur du code normalisé, pour tester code-cim10-avec-ou-sans-point (réfuté si plus de 99 % des codes d'une année ont la même forme, sans espace ni minuscule ; sinon la normalisation UPPER(REPLACE(REPLACE(TRIM(...),'.',''),' ','')) reste obligatoire et on dit quelle forme domine)
-- Oracle 11g, schéma CORA_REC. TB_DIAG par année de DATE_DIAG et DP des RSS par année de DATE_FIN, de 2018 à 2025. Les codes vides sont comptés en forme « vide ».
-- Colonnes : NIVEAU (TB_DIAG ou DP_RSS), ANNEE, POINT (avec point, sans point, vide), ESPACE (aucun, en tête, interne ; les espaces de fin ne comptent pas, la colonne est un char(16)), CASSE (majuscule ou minuscule), LONGUEUR (nombre de caractères du code sans point ni espace : <3, 3, 4, 5, 6, 7+), N, PCT_ANNEE (part de la ligne dans son niveau et son année, vide quand N est masqué).
-- Masquage : chaque effectif < 10 sort en <10. Suppression secondaire (règle 4) : quand les cases masquées d'un niveau et d'une année totalisent de 1 à 9, la plus grande case du groupe sort aussi en « masqué ». Aucune ligne de total ; le pourcentage n'est donné que pour une case visible.
WITH c AS (
  SELECT 'TB_DIAG' AS NIVEAU, EXTRACT(YEAR FROM DATE_DIAG) AS ANNEE, RTRIM(CODE_DIAG) AS CODE
  FROM CORA_REC.TB_DIAG
  WHERE DATE_DIAG >= DATE '2018-01-01' AND DATE_DIAG < DATE '2026-01-01'
  UNION ALL
  SELECT 'DP_RSS', EXTRACT(YEAR FROM DATE_FIN), RTRIM(DP_RETENU)
  FROM CORA_REC.TB_SYNTH_RSS
  WHERE DATE_FIN >= DATE '2018-01-01' AND DATE_FIN < DATE '2026-01-01'
),
f AS (
  SELECT NIVEAU, ANNEE,
         CASE WHEN TRIM(CODE) IS NULL THEN 'vide'
              WHEN INSTR(CODE, '.') > 0 THEN 'avec point' ELSE 'sans point' END AS POINT,
         CASE WHEN TRIM(CODE) IS NULL THEN 'aucun'
              WHEN CODE <> LTRIM(CODE) THEN 'en tête'
              WHEN INSTR(CODE, ' ') > 0 THEN 'interne' ELSE 'aucun' END AS ESPACE,
         CASE WHEN CODE <> UPPER(CODE) THEN 'minuscule' ELSE 'majuscule' END AS CASSE,
         CASE WHEN TRIM(CODE) IS NULL THEN '<3'
              WHEN LENGTH(REPLACE(REPLACE(TRIM(CODE), '.', ''), ' ', '')) < 3 THEN '<3'
              WHEN LENGTH(REPLACE(REPLACE(TRIM(CODE), '.', ''), ' ', '')) >= 7 THEN '7+'
              ELSE TO_CHAR(LENGTH(REPLACE(REPLACE(TRIM(CODE), '.', ''), ' ', ''))) END AS LONGUEUR
  FROM c
),
g AS (
  SELECT NIVEAU, ANNEE, POINT, ESPACE, CASSE, LONGUEUR, COUNT(*) AS N
  FROM f
  GROUP BY NIVEAU, ANNEE, POINT, ESPACE, CASSE, LONGUEUR
),
m AS (
  SELECT NIVEAU, ANNEE, POINT, ESPACE, CASSE, LONGUEUR, N,
         SUM(N) OVER (PARTITION BY NIVEAU, ANNEE) AS TOT,
         SUM(CASE WHEN N < 10 THEN N ELSE 0 END) OVER (PARTITION BY NIVEAU, ANNEE) AS CACHE,
         ROW_NUMBER() OVER (PARTITION BY NIVEAU, ANNEE ORDER BY N DESC, POINT, ESPACE, CASSE, LONGUEUR) AS RANG
  FROM g
)
SELECT '20261019-forme-code-cim10' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       NIVEAU, ANNEE, POINT, ESPACE, CASSE, LONGUEUR,
       CASE WHEN N < 10 THEN '<10' WHEN CACHE BETWEEN 1 AND 9 AND RANG = 1 THEN 'masqué' ELSE TO_CHAR(N) END AS N,
       CASE WHEN N < 10 OR (CACHE BETWEEN 1 AND 9 AND RANG = 1) THEN NULL ELSE ROUND(100 * N / TOT, 2) END AS PCT_ANNEE
FROM m
ORDER BY NIVEAU, ANNEE, POINT, ESPACE, CASSE, LONGUEUR;
