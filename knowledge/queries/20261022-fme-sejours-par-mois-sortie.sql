-- id: 20261022-fme-sejours-par-mois-sortie
-- system: cora
-- person_data: masked
-- purpose: voir, mois de sortie par mois de sortie, si le codage de 2026 est incomplet ou si la durée des séjours de nouveau-nés (CMD 15) change en 2026 pour le pôle femme-mère-enfant (étape 6 du plan revu de l'enquête uf-um-rum, constat de Pierre sur l'étude DIM-code dms_fme)
-- Oracle, schéma CORA_REC. Mêmes séjours que l'étude dms_fme (voir 20261022-fme-binomes-ghm-dp-pole-par-annee) : une ligne par année et mois de sortie, de janvier à septembre.
-- Masquage : tout effectif < 10 sort en <10 ; NB_NUITEES_CMD15 est NULL quand N_CMD15 < 10. Aucune ligne de total : rien ne permet de recalculer une case masquée.
WITH um_fme AS (
  SELECT DISTINCT pum.ID_UNITE_MED, pum.DATE_DEBUT, pum.DATE_FIN,
         CASE WHEN TRIM(ume.CODE_UNITE_MED) IN ('5010', '5015') THEN 0 ELSE 1 END AS QUALIFIE
  FROM CORA_REC.TB_UNITE_POLE_UM pum
  JOIN CORA_REC.TB_UNITE_POLE p ON p.ID_POLE = pum.ID_POLE
  JOIN CORA_REC.TB_UNITE_MEDICALE ume ON ume.ID_UNITE_MED = pum.ID_UNITE_MED
  WHERE TRIM(p.CODE_POLE) = 'menf'
), sej AS (
  SELECT r.ID_RSS, EXTRACT(YEAR FROM r.DATE_FIN) AS ANNEE, EXTRACT(MONTH FROM r.DATE_FIN) AS MOIS,
         TRIM(r.CODE_CMD) AS CMD, TRIM(r.DP_RETENU) AS DP, r.DUREE_SEJOUR
  FROM CORA_REC.TB_SYNTH_RSS r
  WHERE r.DATE_FIN >= DATE '2022-01-01' AND r.DATE_FIN < DATE '2027-01-01'
    AND EXTRACT(MONTH FROM r.DATE_FIN) <= 9
    AND r.DUREE_SEJOUR >= 1 AND TRIM(r.CODE_CMD) <> '28'
    AND EXISTS (SELECT 1 FROM CORA_REC.TB_SYNTH_RUM u JOIN um_fme f ON f.ID_UNITE_MED = u.ID_UNITE_MEDICALE AND f.QUALIFIE = 1
                 AND (f.DATE_DEBUT IS NULL OR f.DATE_DEBUT <= u.DATE_FIN_RUM)
                 AND (f.DATE_FIN IS NULL OR f.DATE_FIN >= u.DATE_FIN_RUM)
                WHERE u.ID_RSS = r.ID_RSS)
), agr AS (
  SELECT ANNEE, MOIS, COUNT(*) AS N,
         SUM(CASE WHEN CMD = '90' THEN 1 ELSE 0 END) AS N90,
         SUM(CASE WHEN DP IS NULL THEN 1 ELSE 0 END) AS NDP,
         SUM(CASE WHEN CMD = '15' THEN 1 ELSE 0 END) AS N15,
         SUM(CASE WHEN CMD = '15' THEN DUREE_SEJOUR ELSE 0 END) AS NUIT15
  FROM sej
  GROUP BY ANNEE, MOIS
)
SELECT '20261022-fme-sejours-par-mois-sortie' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       ANNEE, MOIS,
       CASE WHEN N < 10 THEN '<10' ELSE TO_CHAR(N) END AS N_RSS,
       CASE WHEN N90 BETWEEN 1 AND 9 THEN '<10' ELSE TO_CHAR(N90) END AS N_CMD90,
       CASE WHEN NDP BETWEEN 1 AND 9 THEN '<10' ELSE TO_CHAR(NDP) END AS N_DP_VIDE,
       CASE WHEN N15 BETWEEN 1 AND 9 THEN '<10' ELSE TO_CHAR(N15) END AS N_CMD15,
       CASE WHEN N15 < 10 THEN NULL ELSE NUIT15 END AS NB_NUITEES_CMD15
FROM agr
ORDER BY ANNEE, MOIS
