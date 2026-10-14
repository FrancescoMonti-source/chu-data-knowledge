-- id: 20261014-lien-sejour-rss
-- system: cora
-- person_data: masked
-- purpose: comparer les deux chemins d'un séjour vers son RSS, par les mouvements (TB_MVT → TB_MVT_RUM → TB_SYNTH_RSS) et par la jointure directe TB_SYNTH_RSS.ID_SEJOUR, et compter les séjours à plusieurs RSS (kb : stay-to-rss-link, #24)
-- Oracle, schéma CORA_REC. Deux niveaux :
--   SEJOURS : séjours clos, par année de sortie (2014-2025). N : séjours ; N_C1 : au moins un RSS par les mouvements ; N_C2 : plus d'un RSS distinct par les mouvements ; N_C3 : un RSS atteint par les mouvements porte le même ID_SEJOUR ; N_C4 : au moins une ligne de TB_SYNTH_RSS par ID_SEJOUR ; N_C5 : dont au moins une avec CODE_GHM.
--   RSS : lignes de TB_SYNTH_RSS par année de DATE_FIN (2014-2025). N : RSS ; N_C1 : ID_SEJOUR renseigné ; N_C2 : présent dans TB_MVT_RUM ; N_C3 : CODE_GHM renseigné ; N_C4 : CHRONO_RSS = 1 ; N_C5 vide.
-- Masquage : chaque effectif < 10 sort en <10. Suppression secondaire (règle 4) : la colonne N (séjours ou RSS) sort en « masqué » dès qu'un complément (N moins une autre colonne de la ligne) est entre 1 et 9. Aucune ligne de total.
WITH rm AS (
  SELECT m.ID_SEJOUR,
         COUNT(DISTINCT mr.ID_RSS) AS NB_RSS,
         SUM(CASE WHEN r.ID_SEJOUR = m.ID_SEJOUR THEN 1 ELSE 0 END) AS NB_MEME
  FROM CORA_REC.TB_MVT m
  JOIN CORA_REC.TB_MVT_RUM mr ON mr.ID_MVT = m.ID_MVT
  JOIN CORA_REC.TB_SYNTH_RSS r ON r.ID_RSS = mr.ID_RSS
  GROUP BY m.ID_SEJOUR
),
rd AS (
  SELECT ID_SEJOUR, COUNT(*) AS NB,
         SUM(CASE WHEN CODE_GHM IS NOT NULL THEN 1 ELSE 0 END) AS NB_GHM
  FROM CORA_REC.TB_SYNTH_RSS
  WHERE ID_SEJOUR IS NOT NULL
  GROUP BY ID_SEJOUR
),
sej AS (
  SELECT 'SEJOURS' AS NIVEAU,
         EXTRACT(YEAR FROM s.DATE_SORTIE) AS ANNEE,
         COUNT(*) AS N,
         SUM(CASE WHEN rm.ID_SEJOUR IS NOT NULL THEN 1 ELSE 0 END) AS C1,
         SUM(CASE WHEN rm.NB_RSS > 1 THEN 1 ELSE 0 END) AS C2,
         SUM(CASE WHEN rm.NB_MEME > 0 THEN 1 ELSE 0 END) AS C3,
         SUM(CASE WHEN rd.ID_SEJOUR IS NOT NULL THEN 1 ELSE 0 END) AS C4,
         SUM(CASE WHEN rd.NB_GHM > 0 THEN 1 ELSE 0 END) AS C5
  FROM CORA_REC.TB_SEJOUR s
  LEFT JOIN rm ON rm.ID_SEJOUR = s.ID_SEJOUR
  LEFT JOIN rd ON rd.ID_SEJOUR = s.ID_SEJOUR
  WHERE s.DATE_SORTIE >= DATE '2014-01-01'
    AND s.DATE_SORTIE < DATE '2026-01-01'
  GROUP BY EXTRACT(YEAR FROM s.DATE_SORTIE)
),
rss AS (
  SELECT 'RSS' AS NIVEAU,
         EXTRACT(YEAR FROM r.DATE_FIN) AS ANNEE,
         COUNT(*) AS N,
         SUM(CASE WHEN r.ID_SEJOUR IS NOT NULL THEN 1 ELSE 0 END) AS C1,
         SUM(CASE WHEN EXISTS (SELECT 1 FROM CORA_REC.TB_MVT_RUM mr WHERE mr.ID_RSS = r.ID_RSS) THEN 1 ELSE 0 END) AS C2,
         SUM(CASE WHEN r.CODE_GHM IS NOT NULL THEN 1 ELSE 0 END) AS C3,
         SUM(CASE WHEN r.CHRONO_RSS = 1 THEN 1 ELSE 0 END) AS C4,
         NULL AS C5
  FROM CORA_REC.TB_SYNTH_RSS r
  WHERE r.DATE_FIN >= DATE '2014-01-01'
    AND r.DATE_FIN < DATE '2026-01-01'
  GROUP BY EXTRACT(YEAR FROM r.DATE_FIN)
),
t AS (
  SELECT NIVEAU, ANNEE, N, C1, C2, C3, C4, C5 FROM sej
  UNION ALL
  SELECT NIVEAU, ANNEE, N, C1, C2, C3, C4, C5 FROM rss
)
SELECT '20261014-lien-sejour-rss' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       NIVEAU, ANNEE,
       CASE WHEN N < 10 THEN '<10'
            WHEN N - C1 BETWEEN 1 AND 9 OR N - C2 BETWEEN 1 AND 9 OR N - C3 BETWEEN 1 AND 9
              OR N - C4 BETWEEN 1 AND 9 OR N - NVL(C5, 0) BETWEEN 1 AND 9 THEN 'masqué'
            ELSE TO_CHAR(N) END AS N,
       CASE WHEN C1 < 10 THEN '<10' ELSE TO_CHAR(C1) END AS N_C1,
       CASE WHEN C2 < 10 THEN '<10' ELSE TO_CHAR(C2) END AS N_C2,
       CASE WHEN C3 < 10 THEN '<10' ELSE TO_CHAR(C3) END AS N_C3,
       CASE WHEN C4 < 10 THEN '<10' ELSE TO_CHAR(C4) END AS N_C4,
       CASE WHEN C5 IS NULL THEN NULL WHEN C5 < 10 THEN '<10' ELSE TO_CHAR(C5) END AS N_C5
FROM t
ORDER BY NIVEAU DESC, ANNEE;
