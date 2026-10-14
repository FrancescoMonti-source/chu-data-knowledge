-- id: 20261014-groupes-ccam
-- system: cora
-- person_data: masked
-- purpose: vérifier qu'un groupe d'actes de même TB_ACTE.NO_INTERVENTION_CCAM reste sur un seul mouvement, un seul jour et un seul séjour, pour savoir s'il peut servir d'identifiant d'intervention (kb : convention.intervention-id-no-intervention-ccam, #24)
-- Oracle, schéma CORA_REC. Groupes d'actes de même NO_INTERVENTION_CCAM (non vide), par année du premier acte du groupe, de 2014 à 2025.
-- N : groupes ; N_PLUSIEURS_MVT : plus d'un ID_MVT ; N_PLUSIEURS_JOURS : plus d'un jour de DATE_ACTE ; N_PLUSIEURS_SEJOURS : plus d'un ID_SEJOUR ; N_UN_ACTE : un seul acte.
-- Masquage : chaque effectif < 10 sort en <10. Suppression secondaire (règle 4) : N sort en « masqué » dès qu'un complément (N moins une autre colonne) est entre 1 et 9. Aucune ligne de total.
WITH g AS (
  SELECT NO_INTERVENTION_CCAM,
         EXTRACT(YEAR FROM MIN(DATE_ACTE)) AS ANNEE,
         COUNT(*) AS NB_ACTES,
         COUNT(DISTINCT ID_MVT) AS NB_MVT,
         COUNT(DISTINCT TRUNC(DATE_ACTE)) AS NB_JOURS,
         COUNT(DISTINCT ID_SEJOUR) AS NB_SEJ
  FROM CORA_REC.TB_ACTE
  WHERE NO_INTERVENTION_CCAM IS NOT NULL
    AND DATE_ACTE >= DATE '2014-01-01'
    AND DATE_ACTE < DATE '2026-01-01'
  GROUP BY NO_INTERVENTION_CCAM
),
t AS (
  SELECT ANNEE,
         COUNT(*) AS N,
         SUM(CASE WHEN NB_MVT > 1 THEN 1 ELSE 0 END) AS C1,
         SUM(CASE WHEN NB_JOURS > 1 THEN 1 ELSE 0 END) AS C2,
         SUM(CASE WHEN NB_SEJ > 1 THEN 1 ELSE 0 END) AS C3,
         SUM(CASE WHEN NB_ACTES = 1 THEN 1 ELSE 0 END) AS C4
  FROM g
  GROUP BY ANNEE
)
SELECT '20261014-groupes-ccam' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       ANNEE,
       CASE WHEN N < 10 THEN '<10'
            WHEN N - C1 BETWEEN 1 AND 9 OR N - C2 BETWEEN 1 AND 9 OR N - C3 BETWEEN 1 AND 9 OR N - C4 BETWEEN 1 AND 9 THEN 'masqué'
            ELSE TO_CHAR(N) END AS N,
       CASE WHEN C1 < 10 THEN '<10' ELSE TO_CHAR(C1) END AS N_PLUSIEURS_MVT,
       CASE WHEN C2 < 10 THEN '<10' ELSE TO_CHAR(C2) END AS N_PLUSIEURS_JOURS,
       CASE WHEN C3 < 10 THEN '<10' ELSE TO_CHAR(C3) END AS N_PLUSIEURS_SEJOURS,
       CASE WHEN C4 < 10 THEN '<10' ELSE TO_CHAR(C4) END AS N_UN_ACTE
FROM t
ORDER BY ANNEE;
