-- id: 20261014-sortie-et-dernier-mvt
-- system: cora
-- person_data: masked
-- purpose: pour les séjours clos, mesurer ce que décident deux conventions de dim-code : le mode de sortie pris dans TB_SEJOUR.MODE_SORTIE (vide ? égal à celui du dernier RSS ?) et l'UF de sortie prise au dernier mouvement (combien de derniers mouvements sont des mouvements de plateau technique, FLAG_MVT_SITE = 'X') (kb : convention.exit-mode, convention.last-movement-uf, #24)
-- Oracle, schéma CORA_REC. Séjours clos de 2018 à 2025, par année de sortie. Dernier mouvement : le plus tardif par DATE_DEBUT_MVT, HEURE_DEBUT_MVT, ID_MVT. Dernier RSS : celui de DATE_FIN la plus tardive parmi les RSS atteints par les mouvements.
-- N : séjours ; N_MODE_VIDE : MODE_SORTIE vide ; N_AVEC_RSS ; N_MODE_EGAL_RSS : MODE_SORTIE égal à celui du dernier RSS ; N_DERNIER_MVT_PLATEAU : dernier mouvement de plateau technique.
-- Masquage : chaque effectif < 10 sort en <10. Suppression secondaire (règle 4) : N sort en « masqué » dès qu'un complément (N moins une autre colonne) est entre 1 et 9. Aucune ligne de total.
WITH dm AS (
  SELECT ID_SEJOUR,
         MAX(CASE WHEN UPPER(TRIM(FLAG_MVT_SITE)) = 'X' THEN 1 ELSE 0 END)
           KEEP (DENSE_RANK LAST ORDER BY DATE_DEBUT_MVT, HEURE_DEBUT_MVT, ID_MVT) AS PLATEAU
  FROM CORA_REC.TB_MVT
  GROUP BY ID_SEJOUR
),
dr AS (
  SELECT m.ID_SEJOUR,
         MAX(TRIM(TO_CHAR(r.MODE_SORTIE))) KEEP (DENSE_RANK LAST ORDER BY r.DATE_FIN, r.ID_RSS) AS MODE_RSS
  FROM CORA_REC.TB_MVT m
  JOIN CORA_REC.TB_MVT_RUM mr ON mr.ID_MVT = m.ID_MVT
  JOIN CORA_REC.TB_SYNTH_RSS r ON r.ID_RSS = mr.ID_RSS
  GROUP BY m.ID_SEJOUR
),
t AS (
  SELECT EXTRACT(YEAR FROM s.DATE_SORTIE) AS ANNEE,
         COUNT(*) AS N,
         SUM(CASE WHEN TRIM(TO_CHAR(s.MODE_SORTIE)) IS NULL THEN 1 ELSE 0 END) AS C1,
         SUM(CASE WHEN dr.ID_SEJOUR IS NOT NULL THEN 1 ELSE 0 END) AS C2,
         SUM(CASE WHEN dr.MODE_RSS = TRIM(TO_CHAR(s.MODE_SORTIE)) THEN 1 ELSE 0 END) AS C3,
         SUM(CASE WHEN dm.PLATEAU = 1 THEN 1 ELSE 0 END) AS C4
  FROM CORA_REC.TB_SEJOUR s
  LEFT JOIN dm ON dm.ID_SEJOUR = s.ID_SEJOUR
  LEFT JOIN dr ON dr.ID_SEJOUR = s.ID_SEJOUR
  WHERE s.DATE_SORTIE >= DATE '2018-01-01'
    AND s.DATE_SORTIE < DATE '2026-01-01'
  GROUP BY EXTRACT(YEAR FROM s.DATE_SORTIE)
)
SELECT '20261014-sortie-et-dernier-mvt' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       ANNEE,
       CASE WHEN N < 10 THEN '<10'
            WHEN N - C1 BETWEEN 1 AND 9 OR N - C2 BETWEEN 1 AND 9 OR N - C3 BETWEEN 1 AND 9 OR N - C4 BETWEEN 1 AND 9 THEN 'masqué'
            ELSE TO_CHAR(N) END AS N,
       CASE WHEN C1 < 10 THEN '<10' ELSE TO_CHAR(C1) END AS N_MODE_VIDE,
       CASE WHEN C2 < 10 THEN '<10' ELSE TO_CHAR(C2) END AS N_AVEC_RSS,
       CASE WHEN C3 < 10 THEN '<10' ELSE TO_CHAR(C3) END AS N_MODE_EGAL_RSS,
       CASE WHEN C4 < 10 THEN '<10' ELSE TO_CHAR(C4) END AS N_DERNIER_MVT_PLATEAU
FROM t
ORDER BY ANNEE;
