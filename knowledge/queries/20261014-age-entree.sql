-- id: 20261014-age-entree
-- system: cora
-- person_data: masked
-- purpose: comparer TB_SYNTH_RSS.AGE_ENTREE à l'âge recalculé depuis TB_PATIENT.DATE_NAIS et le début du RSS, pour dire s'il peut servir et pourquoi la convention le recalcule (kb : convention.age-at-admission, #24)
-- Oracle, schéma CORA_REC. RSS de TB_SYNTH_RSS finis de 2018 à 2025, par année de DATE_FIN et par tranche d'âge recalculé (moins d'un an, un an ou plus, date de naissance absente). Patient : par le séjour d'un mouvement du RSS (TB_MVT_RUM → TB_MVT → TB_SEJOUR.ID_PATIENT). Âge recalculé : FLOOR((DATE_DEBUT − DATE_NAIS) / 365.25).
-- Aucune date de naissance ni aucun âge individuel ne sort : seulement des effectifs. AGE_ENTREE est lu comme un nombre entier s'il n'est fait que de chiffres, sinon compté comme non numérique.
-- N : RSS ; N_AGE_VIDE : AGE_ENTREE vide ; N_AGE_NON_NUMERIQUE ; N_EGAL : égal à l'âge recalculé ; N_ECART_1 : écart d'un an ; N_ECART_PLUS : écart de plus d'un an.
-- Masquage : chaque effectif < 10 sort en <10. Suppression secondaire (règle 4) : N sort en « masqué » dès qu'un complément (N moins une autre colonne) est entre 1 et 9. Aucune ligne de total.
WITH p AS (
  SELECT mr.ID_RSS, MIN(s.ID_PATIENT) AS ID_PATIENT
  FROM CORA_REC.TB_MVT_RUM mr
  JOIN CORA_REC.TB_MVT m ON m.ID_MVT = mr.ID_MVT
  JOIN CORA_REC.TB_SEJOUR s ON s.ID_SEJOUR = m.ID_SEJOUR
  GROUP BY mr.ID_RSS
),
r AS (
  SELECT EXTRACT(YEAR FROM x.DATE_FIN) AS ANNEE,
         CASE WHEN pa.DATE_NAIS IS NULL THEN 'naissance absente'
              WHEN FLOOR((x.DATE_DEBUT - pa.DATE_NAIS) / 365.25) < 1 THEN 'moins d''un an'
              ELSE 'un an ou plus' END AS TRANCHE,
         CASE WHEN x.AGE_ENTREE IS NULL THEN 'vide'
              WHEN NOT REGEXP_LIKE(TRIM(TO_CHAR(x.AGE_ENTREE)), '^[0-9]+$') THEN 'non numérique'
              ELSE 'numérique' END AS FORME,
         CASE WHEN REGEXP_LIKE(TRIM(TO_CHAR(x.AGE_ENTREE)), '^[0-9]+$') AND pa.DATE_NAIS IS NOT NULL
              THEN ABS(TO_NUMBER(TRIM(TO_CHAR(x.AGE_ENTREE))) - FLOOR((x.DATE_DEBUT - pa.DATE_NAIS) / 365.25)) END AS ECART
  FROM CORA_REC.TB_SYNTH_RSS x
  JOIN p ON p.ID_RSS = x.ID_RSS
  LEFT JOIN CORA_REC.TB_PATIENT pa ON pa.ID_PATIENT = p.ID_PATIENT
  WHERE x.DATE_FIN >= DATE '2018-01-01'
    AND x.DATE_FIN < DATE '2026-01-01'
),
t AS (
  SELECT ANNEE, TRANCHE, COUNT(*) AS N,
         SUM(CASE WHEN FORME = 'vide' THEN 1 ELSE 0 END) AS C1,
         SUM(CASE WHEN FORME = 'non numérique' THEN 1 ELSE 0 END) AS C2,
         SUM(CASE WHEN ECART = 0 THEN 1 ELSE 0 END) AS C3,
         SUM(CASE WHEN ECART = 1 THEN 1 ELSE 0 END) AS C4,
         SUM(CASE WHEN ECART > 1 THEN 1 ELSE 0 END) AS C5
  FROM r
  GROUP BY ANNEE, TRANCHE
)
SELECT '20261014-age-entree' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       ANNEE, TRANCHE,
       CASE WHEN N < 10 THEN '<10'
            WHEN N - C1 BETWEEN 1 AND 9 OR N - C2 BETWEEN 1 AND 9 OR N - C3 BETWEEN 1 AND 9
              OR N - C4 BETWEEN 1 AND 9 OR N - C5 BETWEEN 1 AND 9 THEN 'masqué'
            ELSE TO_CHAR(N) END AS N,
       CASE WHEN C1 < 10 THEN '<10' ELSE TO_CHAR(C1) END AS N_AGE_VIDE,
       CASE WHEN C2 < 10 THEN '<10' ELSE TO_CHAR(C2) END AS N_AGE_NON_NUMERIQUE,
       CASE WHEN C3 < 10 THEN '<10' ELSE TO_CHAR(C3) END AS N_EGAL,
       CASE WHEN C4 < 10 THEN '<10' ELSE TO_CHAR(C4) END AS N_ECART_1,
       CASE WHEN C5 < 10 THEN '<10' ELSE TO_CHAR(C5) END AS N_ECART_PLUS
FROM t
ORDER BY ANNEE, TRANCHE;
