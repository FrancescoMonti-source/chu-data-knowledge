-- id: 20261019-version-groupage-semestre
-- system: cora
-- person_data: masked
-- purpose: pour chaque semestre de fin de RSS, sur tout l'établissement, la répartition des RSS par TB_SYNTH_RSS.VERSION, pour tester version-groupage-mixte-par-semestre (réfuté si, pour un semestre, plus de 99 % des RSS portent une seule version ; sinon le référentiel de groupage se choisit par RSS selon VERSION et non par l'année de l'export)
-- Oracle 11g, schéma CORA_REC. RSS de TB_SYNTH_RSS dont DATE_FIN va du 2018-01-01 à aujourd'hui, par semestre de DATE_FIN (S1 : janvier à juin, S2 : juillet à décembre). VERSION vide sort en « (vide) ».
-- Colonnes : SEMESTRE, VERSION, N (RSS), PCT_SEMESTRE (part de la version dans le semestre, vide quand N est masqué).
-- Masquage : chaque effectif < 10 sort en <10. Suppression secondaire (règle 4) : quand les cases masquées d'un semestre totalisent de 1 à 9, la plus grande case du semestre sort aussi en « masqué ». Aucune ligne de total.
WITH g AS (
  SELECT TO_CHAR(DATE_FIN, 'YYYY') || '-S' || CASE WHEN EXTRACT(MONTH FROM DATE_FIN) <= 6 THEN '1' ELSE '2' END AS SEMESTRE,
         NVL(TO_CHAR(VERSION), '(vide)') AS VERSION,
         COUNT(*) AS N
  FROM CORA_REC.TB_SYNTH_RSS
  WHERE DATE_FIN >= DATE '2018-01-01' AND DATE_FIN < TRUNC(SYSDATE) + 1
  GROUP BY TO_CHAR(DATE_FIN, 'YYYY') || '-S' || CASE WHEN EXTRACT(MONTH FROM DATE_FIN) <= 6 THEN '1' ELSE '2' END,
           NVL(TO_CHAR(VERSION), '(vide)')
),
m AS (
  SELECT SEMESTRE, VERSION, N,
         SUM(N) OVER (PARTITION BY SEMESTRE) AS TOT,
         SUM(CASE WHEN N < 10 THEN N ELSE 0 END) OVER (PARTITION BY SEMESTRE) AS CACHE,
         ROW_NUMBER() OVER (PARTITION BY SEMESTRE ORDER BY N DESC, VERSION) AS RANG
  FROM g
)
SELECT '20261019-version-groupage-semestre' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       SEMESTRE, VERSION,
       CASE WHEN N < 10 THEN '<10' WHEN CACHE BETWEEN 1 AND 9 AND RANG = 1 THEN 'masqué' ELSE TO_CHAR(N) END AS N,
       CASE WHEN N < 10 OR (CACHE BETWEEN 1 AND 9 AND RANG = 1) THEN NULL ELSE ROUND(100 * N / TOT, 2) END AS PCT_SEMESTRE
FROM m
ORDER BY SEMESTRE, VERSION;
