-- id: 20261120-z511-dp-das-par-annee
-- system: cora
-- person_data: masked
-- purpose: compter, de 2022 à 2025, les RSS avec Z511 en DP, avec Z511 en DAS et un DP de cancer, avec Z511 en DAS et un autre DP, et les RSS à DP de cancer sans Z511 en DAS, par type de prise en charge, pour mesurer combien de chimiothérapies ne se repèrent que par le DAS (étape 2 du plan, #148)
-- Oracle, schéma CORA_REC. RSS de TB_SYNTH_RSS finis de 2022 à 2025 (DATE_FIN). Codes sans point, par racine, sans TRIM (code-cim10-sans-point) : DP_RETENU LIKE 'Z511%' ; cancer = SUBSTR(DP_RETENU, 1, 3) entre C00 et C97. Z511 en DAS : un diagnostic TB_DIAG de TYPE_DIAG = 'S' dont le mouvement (TB_DIAG.ID_MVT -> TB_MVT.ID_SEJOUR) est celui du séjour du RSS (chemin-actes-diags-par-mouvement). Type de prise en charge : type-prise-en-charge-mco (CMD 28 = séance ; durée 0 = ambulatoire ; sinon hospitalisation complète).
-- Les quatre groupes sont disjoints et rangés dans l'ordre : DP_Z511, puis DAS_Z511_DP_CANCER, puis DP_CANCER_SANS_Z511, puis DAS_Z511_DP_AUTRE (un RSS n'est que dans un groupe). Un séjour à plusieurs RSS compte une fois par RSS dans N_RSS.
-- N_SEJOURS : ID_SEJOUR distincts ; N_RSS : RSS ; N_DR_CANCER : RSS dont DR_RETENU est un cancer (C00 à C97).
-- Masquage : si N_SEJOURS < 10, toute la ligne sort en <10. Dans une ligne visible, un effectif dont l'écart à un autre effectif de la ligne vaut de 1 à 9 sort en « masqué ». Aucune ligne de total : les groupes sont disjoints.
WITH das AS (
  SELECT DISTINCT m.ID_SEJOUR
  FROM CORA_REC.TB_DIAG d
  JOIN CORA_REC.TB_MVT m ON m.ID_MVT = d.ID_MVT
  WHERE d.TYPE_DIAG = 'S' AND d.CODE_DIAG LIKE 'Z511%'
),
r AS (
  SELECT x.ID_RSS, x.ID_SEJOUR,
         EXTRACT(YEAR FROM x.DATE_FIN) AS ANNEE,
         CASE WHEN TRIM(x.CODE_CMD) = '28' THEN '1 seance'
              WHEN x.DUREE_SEJOUR = 0 THEN '2 ambulatoire 0 nuit'
              ELSE '3 hospitalisation complete' END AS TYPE_PEC,
         CASE WHEN x.DP_RETENU LIKE 'Z511%' THEN '1 DP_Z511'
              WHEN SUBSTR(x.DP_RETENU, 1, 3) BETWEEN 'C00' AND 'C97' AND das.ID_SEJOUR IS NOT NULL THEN '2 DAS_Z511_DP_CANCER'
              WHEN SUBSTR(x.DP_RETENU, 1, 3) BETWEEN 'C00' AND 'C97' THEN '3 DP_CANCER_SANS_Z511'
              WHEN das.ID_SEJOUR IS NOT NULL THEN '4 DAS_Z511_DP_AUTRE'
         END AS GROUPE,
         CASE WHEN SUBSTR(x.DR_RETENU, 1, 3) BETWEEN 'C00' AND 'C97' THEN 1 ELSE 0 END AS DR_C
  FROM CORA_REC.TB_SYNTH_RSS x
  LEFT JOIN das ON das.ID_SEJOUR = x.ID_SEJOUR
  WHERE x.DATE_FIN >= DATE '2022-01-01' AND x.DATE_FIN < DATE '2026-01-01'
),
t AS (
  SELECT ANNEE, TYPE_PEC, GROUPE,
         COUNT(DISTINCT ID_SEJOUR) AS J, COUNT(*) AS R, SUM(DR_C) AS D
  FROM r
  WHERE GROUPE IS NOT NULL
  GROUP BY ANNEE, TYPE_PEC, GROUPE
)
SELECT '20261120-z511-dp-das-par-annee' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       ANNEE, TYPE_PEC, GROUPE,
       CASE WHEN J < 10 THEN '<10' ELSE TO_CHAR(J) END AS N_SEJOURS,
       CASE WHEN J < 10 THEN '<10'
            WHEN R - J BETWEEN 1 AND 9 THEN 'masqué'
            ELSE TO_CHAR(R) END AS N_RSS,
       CASE WHEN J < 10 THEN '<10'
            WHEN D BETWEEN 1 AND 9 THEN '<10'
            WHEN R - D BETWEEN 1 AND 9 OR ABS(J - D) BETWEEN 1 AND 9 THEN 'masqué'
            ELSE TO_CHAR(D) END AS N_DR_CANCER
FROM t
ORDER BY ANNEE, TYPE_PEC, GROUPE;
