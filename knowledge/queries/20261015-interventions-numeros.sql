-- id: 20261015-interventions-numeros
-- system: cora
-- person_data: masked
-- purpose: par mois depuis novembre 2023, la forme de TB_INTERVENTION.NO_INTERVENTION_EXT (n° OpRoom attendu sur 10 chiffres suivis d'un tiret et d'un suffixe), et le rattachement de l'intervention aux actes par TB_ACTE.NO_INTERVENTION et par NO_INTERVENTION_CCAM, pour préparer le chaînage OpRoom ↔ CORA (kb : links/oproom-cora, backlog i-id-prefix-match, definition.intervention-numbers)
-- Oracle, schéma CORA_REC. Aucun numéro ne sort : seulement des effectifs par forme de numéro.
-- FORME_NO_EXT : '10 chiffres-suffixe', 'autre' ou '(vide)'. N : interventions ; N_ACTES_PAR_NO_INTERVENTION ; N_ACTES_PAR_CCAM : au moins un acte avec le même NO_INTERVENTION_CCAM ; N_LES_DEUX.
-- Masquage : chaque effectif < 10 sort en <10. Suppression secondaire (règle 4) : N sort en « masqué » dès qu'un complément (N moins une autre colonne) est entre 1 et 9. Aucune ligne de total.
WITH par_id AS (
  SELECT DISTINCT TRIM(TO_CHAR(NO_INTERVENTION)) AS K FROM CORA_REC.TB_ACTE WHERE NO_INTERVENTION IS NOT NULL
),
par_ccam AS (
  SELECT DISTINCT TRIM(TO_CHAR(NO_INTERVENTION_CCAM)) AS K FROM CORA_REC.TB_ACTE
  WHERE NO_INTERVENTION_CCAM IS NOT NULL AND DATE_ACTE >= DATE '2023-10-01'
),
i AS (
  SELECT TO_CHAR(x.DATE_INTERVENTION, 'YYYY-MM') AS MOIS,
         CASE WHEN TRIM(x.NO_INTERVENTION_EXT) IS NULL THEN '(vide)'
              WHEN REGEXP_LIKE(TRIM(x.NO_INTERVENTION_EXT), '^[0-9]{10}-.+$') THEN '10 chiffres-suffixe'
              ELSE 'autre' END AS FORME,
         CASE WHEN a.K IS NOT NULL THEN 1 ELSE 0 END AS P1,
         CASE WHEN c.K IS NOT NULL THEN 1 ELSE 0 END AS P2
  FROM CORA_REC.TB_INTERVENTION x
  LEFT JOIN par_id a ON a.K = TRIM(TO_CHAR(x.ID_INTERVENTION))
  LEFT JOIN par_ccam c ON c.K = TRIM(TO_CHAR(x.NO_INTERVENTION_CCAM))
  WHERE x.DATE_INTERVENTION >= DATE '2023-11-01' AND x.DATE_INTERVENTION < TRUNC(SYSDATE) + 1
),
g AS (
  SELECT MOIS, FORME, COUNT(*) AS N, SUM(P1) AS C1, SUM(P2) AS C2, SUM(P1 * P2) AS C3
  FROM i GROUP BY MOIS, FORME
)
SELECT '20261015-interventions-numeros' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       MOIS, FORME,
       CASE WHEN N < 10 THEN '<10'
            WHEN N - C1 BETWEEN 1 AND 9 OR N - C2 BETWEEN 1 AND 9 OR N - C3 BETWEEN 1 AND 9 THEN 'masqué'
            ELSE TO_CHAR(N) END AS N,
       CASE WHEN C1 < 10 THEN '<10' ELSE TO_CHAR(C1) END AS N_ACTES_PAR_NO_INTERVENTION,
       CASE WHEN C2 < 10 THEN '<10' ELSE TO_CHAR(C2) END AS N_ACTES_PAR_CCAM,
       CASE WHEN C3 < 10 THEN '<10' ELSE TO_CHAR(C3) END AS N_LES_DEUX
FROM g
ORDER BY MOIS, FORME;
