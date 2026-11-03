-- id: 20261102-codes-mortinatalite-detail
-- system: cora
-- person_data: masked
-- purpose: voir comment CORA stocke les extensions des codes de mortinatalité (P95 sur le séjour de l'enfant, Z37 sur le séjour de la mère, depuis 2019 : 20261102-mortnes-p95-extensions ; Z37 : instruction-mort-nes-pmsi-2021, annexe I, § III.3.1) et combien de séjours portent chacune, par année, avec la part à 36 SA et plus : base du recensement des morts fœtales (étape 5 du plan, #42)
-- Oracle, schéma CORA_REC. Diagnostics de TB_DIAG rattachés à un mouvement (chemin-actes-diags-par-mouvement), datés par le début du mouvement (dater-diagnostic-par-mouvement), de 2018 à 2025 (periode-analyse-cora-2018).
-- Codes gardés : tout code qui commence par P95, Z37, P964 ou P015 (grossesse multiple côté enfant, instruction-mort-nes-pmsi-2021, annexe I, § III.2), points retirés. CODE sort tel que CORA le stocke après TRIM et sans les points, pour voir la forme des extensions (« + » ou autre).
-- Lignes : CODE × TYPE_DIAG ('P' DP, 'S' DAS, 'R' DR) × ANNEE. N : séjours (TB_MVT.ID_SEJOUR) qui portent ce code à ce rang cette année-là ; N_SA_36 : parmi eux, ceux dont la plus grande SEM_AMENORHEE des mouvements est 36 ou plus.
-- Masquage : chaque effectif < 10 sort en <10. N sort en « masqué » quand N moins N_SA_36 est entre 1 et 9. Aucune ligne de total.
WITH dx AS (
  SELECT DISTINCT m.ID_SEJOUR,
         REPLACE(TRIM(d.CODE_DIAG), '.', '') AS CODE,
         TRIM(d.TYPE_DIAG) AS TYPE_DIAG,
         EXTRACT(YEAR FROM m.DATE_DEBUT_MVT) AS ANNEE
  FROM CORA_REC.TB_DIAG d
  JOIN CORA_REC.TB_MVT m ON m.ID_MVT = d.ID_MVT
  WHERE (REPLACE(TRIM(d.CODE_DIAG), '.', '') LIKE 'P95%'
      OR REPLACE(TRIM(d.CODE_DIAG), '.', '') LIKE 'Z37%'
      OR REPLACE(TRIM(d.CODE_DIAG), '.', '') LIKE 'P964%'
      OR REPLACE(TRIM(d.CODE_DIAG), '.', '') LIKE 'P015%')
    AND m.DATE_DEBUT_MVT >= DATE '2018-01-01'
    AND m.DATE_DEBUT_MVT < DATE '2026-01-01'
),
sa AS (
  SELECT ID_SEJOUR, MAX(SEM_AMENORHEE) AS SA_MAX
  FROM CORA_REC.TB_MVT
  WHERE ID_SEJOUR IN (SELECT ID_SEJOUR FROM dx)
  GROUP BY ID_SEJOUR
),
t AS (
  SELECT dx.CODE, dx.TYPE_DIAG, dx.ANNEE,
         COUNT(DISTINCT dx.ID_SEJOUR) AS N,
         COUNT(DISTINCT CASE WHEN sa.SA_MAX >= 36 THEN dx.ID_SEJOUR END) AS C1
  FROM dx
  LEFT JOIN sa ON sa.ID_SEJOUR = dx.ID_SEJOUR
  GROUP BY dx.CODE, dx.TYPE_DIAG, dx.ANNEE
)
SELECT '20261102-codes-mortinatalite-detail' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       CODE, TYPE_DIAG, ANNEE,
       CASE WHEN N < 10 THEN '<10'
            WHEN N - C1 BETWEEN 1 AND 9 THEN 'masqué'
            ELSE TO_CHAR(N) END AS N,
       CASE WHEN C1 < 10 THEN '<10' ELSE TO_CHAR(C1) END AS N_SA_36
FROM t
ORDER BY CODE, TYPE_DIAG, ANNEE;
