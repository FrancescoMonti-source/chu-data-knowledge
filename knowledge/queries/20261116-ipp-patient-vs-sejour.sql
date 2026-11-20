-- id: 20261116-ipp-patient-vs-sejour
-- system: cora
-- person_data: masked
-- purpose: savoir où lire l'IPP d'un séjour : TB_SEJOUR.IPP_PATIENT ou TB_PATIENT.IPP_PATIENT (étape 1 du plan, #138)
-- Oracle, schéma CORA_REC. Séjours sortis de 2023 à 2026 (DATE_SORTIE), un patient par séjour (TB_SEJOUR.ID_PATIENT vers TB_PATIENT).
-- Renseigné = non NULL et non vide après TRIM. Les valeurs d'IPP ne servent qu'à la comparaison : la requête ne sort que des effectifs.
-- Lignes : ANNEE x MODALITE (cinq modalités qui partitionnent les séjours) ; N_SEJ : séjours de la modalité.
-- Masquage : chaque effectif < 10 sort en <10. Aucune ligne de total : les modalités ne se recalculent pas entre elles.
WITH base AS (
  SELECT EXTRACT(YEAR FROM s.DATE_SORTIE) AS ANNEE,
         CASE
           WHEN TRIM(s.IPP_PATIENT) IS NOT NULL AND TRIM(p.IPP_PATIENT) IS NOT NULL
                AND TRIM(s.IPP_PATIENT) = TRIM(p.IPP_PATIENT) THEN '3 les deux renseignés, égaux'
           WHEN TRIM(s.IPP_PATIENT) IS NOT NULL AND TRIM(p.IPP_PATIENT) IS NOT NULL THEN '4 les deux renseignés, différents'
           WHEN TRIM(s.IPP_PATIENT) IS NOT NULL THEN '2 séjour seul renseigné'
           WHEN TRIM(p.IPP_PATIENT) IS NOT NULL THEN '1 patient seul renseigné'
           ELSE '0 aucun renseigné'
         END AS MODALITE
  FROM CORA_REC.TB_SEJOUR s
  JOIN CORA_REC.TB_PATIENT p ON p.ID_PATIENT = s.ID_PATIENT
  WHERE s.DATE_SORTIE >= DATE '2023-01-01' AND s.DATE_SORTIE < DATE '2027-01-01'
)
SELECT '20261116-ipp-patient-vs-sejour' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       ANNEE,
       MODALITE,
       CASE WHEN COUNT(*) < 10 THEN '<10' ELSE TO_CHAR(COUNT(*)) END AS N_SEJ
FROM base
GROUP BY ANNEE, MODALITE
ORDER BY ANNEE, MODALITE
