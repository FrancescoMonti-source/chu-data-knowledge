-- id: 20261014-chemin-rss-actes-diags
-- system: cora
-- person_data: masked
-- purpose: savoir quelle part des actes et des diagnostics le chemin par le RSS atteint, comparé au chemin par le mouvement, et combien n'ont aucun mouvement (kb : rss-path-scope, #24)
-- Oracle, schéma CORA_REC. Deux niveaux, ACTES (TB_ACTE, par année de DATE_ACTE) et DIAGS (TB_DIAG, par année de DATE_DIAG ; '(vide)' sans date), de 2014 à 2025.
-- N : lignes ; N_MVT_EXISTE : ID_MVT présent dans TB_MVT (chemin par le mouvement) ; N_DANS_RUM : ID_MVT présent dans TB_MVT_RUM avec un RSS de TB_SYNTH_RSS (chemin par le RSS) ; N_SEJOUR_SANS_MVT : ID_MVT absent de TB_MVT mais ID_SEJOUR présent dans TB_SEJOUR.
-- Masquage : chaque effectif < 10 sort en <10. Suppression secondaire (règle 4) : N sort en « masqué » dès qu'un complément (N moins une autre colonne) est entre 1 et 9. Aucune ligne de total.
WITH mvt AS (
  SELECT DISTINCT ID_MVT FROM CORA_REC.TB_MVT
),
rum AS (
  SELECT DISTINCT mr.ID_MVT
  FROM CORA_REC.TB_MVT_RUM mr
  JOIN CORA_REC.TB_SYNTH_RSS r ON r.ID_RSS = mr.ID_RSS
),
sej AS (
  SELECT ID_SEJOUR FROM CORA_REC.TB_SEJOUR
),
a AS (
  SELECT 'ACTES' AS NIVEAU,
         TO_CHAR(EXTRACT(YEAR FROM x.DATE_ACTE)) AS ANNEE,
         COUNT(*) AS N,
         SUM(CASE WHEN mvt.ID_MVT IS NOT NULL THEN 1 ELSE 0 END) AS C1,
         SUM(CASE WHEN rum.ID_MVT IS NOT NULL THEN 1 ELSE 0 END) AS C2,
         SUM(CASE WHEN mvt.ID_MVT IS NULL AND sej.ID_SEJOUR IS NOT NULL THEN 1 ELSE 0 END) AS C3
  FROM CORA_REC.TB_ACTE x
  LEFT JOIN mvt ON mvt.ID_MVT = x.ID_MVT
  LEFT JOIN rum ON rum.ID_MVT = x.ID_MVT
  LEFT JOIN sej ON sej.ID_SEJOUR = x.ID_SEJOUR
  WHERE x.DATE_ACTE >= DATE '2014-01-01'
    AND x.DATE_ACTE < DATE '2026-01-01'
  GROUP BY TO_CHAR(EXTRACT(YEAR FROM x.DATE_ACTE))
),
d AS (
  SELECT 'DIAGS' AS NIVEAU,
         NVL(TO_CHAR(EXTRACT(YEAR FROM x.DATE_DIAG)), '(vide)') AS ANNEE,
         COUNT(*) AS N,
         SUM(CASE WHEN mvt.ID_MVT IS NOT NULL THEN 1 ELSE 0 END) AS C1,
         SUM(CASE WHEN rum.ID_MVT IS NOT NULL THEN 1 ELSE 0 END) AS C2,
         SUM(CASE WHEN mvt.ID_MVT IS NULL AND sej.ID_SEJOUR IS NOT NULL THEN 1 ELSE 0 END) AS C3
  FROM CORA_REC.TB_DIAG x
  LEFT JOIN mvt ON mvt.ID_MVT = x.ID_MVT
  LEFT JOIN rum ON rum.ID_MVT = x.ID_MVT
  LEFT JOIN sej ON sej.ID_SEJOUR = x.ID_SEJOUR
  WHERE x.DATE_DIAG IS NULL
     OR (x.DATE_DIAG >= DATE '2014-01-01' AND x.DATE_DIAG < DATE '2026-01-01')
  GROUP BY NVL(TO_CHAR(EXTRACT(YEAR FROM x.DATE_DIAG)), '(vide)')
),
t AS (
  SELECT NIVEAU, ANNEE, N, C1, C2, C3 FROM a
  UNION ALL
  SELECT NIVEAU, ANNEE, N, C1, C2, C3 FROM d
)
SELECT '20261014-chemin-rss-actes-diags' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       NIVEAU, ANNEE,
       CASE WHEN N < 10 THEN '<10'
            WHEN N - C1 BETWEEN 1 AND 9 OR N - C2 BETWEEN 1 AND 9 OR N - C3 BETWEEN 1 AND 9 THEN 'masqué'
            ELSE TO_CHAR(N) END AS N,
       CASE WHEN C1 < 10 THEN '<10' ELSE TO_CHAR(C1) END AS N_MVT_EXISTE,
       CASE WHEN C2 < 10 THEN '<10' ELSE TO_CHAR(C2) END AS N_DANS_RUM,
       CASE WHEN C3 < 10 THEN '<10' ELSE TO_CHAR(C3) END AS N_SEJOUR_SANS_MVT
FROM t
ORDER BY NIVEAU, ANNEE;
