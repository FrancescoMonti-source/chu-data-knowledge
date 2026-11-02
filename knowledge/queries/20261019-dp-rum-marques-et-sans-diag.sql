-- id: 20261019-dp-rum-marques-et-sans-diag
-- system: cora
-- person_data: masked
-- purpose: pour rss-mois-recents-non-codes (amendement : le DP du RSS se lit dans TB_SYNTH_RUM.DIAG_P du RUM marqué DP_MVT_RETENU = 'X' ; un seul RUM marqué par RSS codé ? ; un séjour sans ligne TB_DIAG via TB_MVT n'est pas codé, au MCO comme au SMR). Niveau RUM : combien de RUM marqués par RSS, et le DIAG_P du RUM marqué égale-t-il DP_RETENU. Niveau MOIS : part des RSS MCO et des séjours SMR sans aucun diagnostic, par mois récent. Si plusieurs RUM sont marqués pour plus de quelques RSS codés, « le » RUM du DP n'est pas unique ; si des RSS codés n'ont aucun RUM marqué, le DP du RSS ne se lit pas par ce marqueur.
-- Oracle 11g, schéma CORA_REC. Niveau RUM : RSS de TB_SYNTH_RSS finis de 2018 à aujourd'hui, par année de DATE_FIN, reliés à TB_SYNTH_RUM par ID_RSS. Niveau MOIS : MCO = RSS finis du 2025-07-01 à aujourd'hui, par mois de DATE_FIN (un RSS par ligne de TB_SYNTH_RSS, relié à son séjour par ID_SEJOUR) ; SMR = séjours de TYPE_SEJOUR 'SSR' ou 'SMR' sortis du 2025-07-01 à aujourd'hui, par mois de DATE_SORTIE, hors préadmission. Sans diagnostic : aucune ligne de TB_DIAG sur un mouvement (TB_MVT.ID_SEJOUR) du séjour.
-- Colonnes : NIVEAU, PERIODE (année ou mois YYYY-MM), DIM_1, DIM_2, DIM_3, N, PCT_GROUPE. Niveau RUM : DIM_1 = CMD 90 ou autre, DIM_2 = nombre de RUM marqués X ('0', '1', '2+'), DIM_3 = lien entre DIAG_P du RUM marqué et DP_RETENU du RSS ('sans RUM marqué', 'plusieurs marqués', 'DIAG_P vide', 'égal', 'différent') ; groupe du pourcentage : l'année et DIM_1. Niveau MOIS : DIM_1 = secteur (MCO, SMR), DIM_2 = sans diagnostic (oui, non), DIM_3 vide ; groupe : le mois et le secteur. N : RSS ou séjours.
-- Masquage : chaque effectif < 10 sort en <10. Suppression secondaire (règle 4) : quand les cases masquées d'un groupe totalisent de 1 à 9, la plus grande case du groupe sort aussi en « masqué ». Aucune ligne de total ; le pourcentage n'est donné que pour une case visible.
WITH x AS (
  SELECT ID_RSS,
         SUM(CASE WHEN TRIM(DP_MVT_RETENU) = 'X' THEN 1 ELSE 0 END) AS NBX,
         MAX(CASE WHEN TRIM(DP_MVT_RETENU) = 'X' THEN TRIM(DIAG_P) END) AS DPX
  FROM CORA_REC.TB_SYNTH_RUM
  GROUP BY ID_RSS
),
rr AS (
  SELECT 'RUM' AS NIVEAU, TO_CHAR(EXTRACT(YEAR FROM r.DATE_FIN)) AS PERIODE,
         CASE WHEN TRIM(r.CODE_CMD) = '90' THEN 'CMD 90' ELSE 'autre CMD' END AS DIM_1,
         CASE WHEN NVL(x.NBX, 0) = 0 THEN '0' WHEN x.NBX = 1 THEN '1' ELSE '2+' END AS DIM_2,
         CASE WHEN NVL(x.NBX, 0) = 0 THEN 'sans RUM marqué'
              WHEN x.NBX > 1 THEN 'plusieurs marqués'
              WHEN x.DPX IS NULL THEN 'DIAG_P vide'
              WHEN x.DPX = TRIM(r.DP_RETENU) THEN 'égal'
              ELSE 'différent' END AS DIM_3,
         COUNT(*) AS N
  FROM CORA_REC.TB_SYNTH_RSS r
  LEFT JOIN x ON x.ID_RSS = r.ID_RSS
  WHERE r.DATE_FIN >= DATE '2018-01-01' AND r.DATE_FIN < TRUNC(SYSDATE) + 1
  GROUP BY TO_CHAR(EXTRACT(YEAR FROM r.DATE_FIN)),
           CASE WHEN TRIM(r.CODE_CMD) = '90' THEN 'CMD 90' ELSE 'autre CMD' END,
           CASE WHEN NVL(x.NBX, 0) = 0 THEN '0' WHEN x.NBX = 1 THEN '1' ELSE '2+' END,
           CASE WHEN NVL(x.NBX, 0) = 0 THEN 'sans RUM marqué'
                WHEN x.NBX > 1 THEN 'plusieurs marqués'
                WHEN x.DPX IS NULL THEN 'DIAG_P vide'
                WHEN x.DPX = TRIM(r.DP_RETENU) THEN 'égal'
                ELSE 'différent' END
),
mco AS (
  SELECT 'MOIS' AS NIVEAU, TO_CHAR(r.DATE_FIN, 'YYYY-MM') AS PERIODE, 'MCO' AS DIM_1,
         CASE WHEN EXISTS (SELECT 1 FROM CORA_REC.TB_MVT mv
                           JOIN CORA_REC.TB_DIAG d ON d.ID_MVT = mv.ID_MVT
                           WHERE mv.ID_SEJOUR = r.ID_SEJOUR) THEN 'non' ELSE 'oui' END AS DIM_2,
         CAST(NULL AS VARCHAR2(1)) AS DIM_3,
         1 AS UN
  FROM CORA_REC.TB_SYNTH_RSS r
  WHERE r.DATE_FIN >= DATE '2025-07-01' AND r.DATE_FIN < TRUNC(SYSDATE) + 1
    AND r.ID_SEJOUR IS NOT NULL
),
smr AS (
  SELECT 'MOIS' AS NIVEAU, TO_CHAR(s.DATE_SORTIE, 'YYYY-MM') AS PERIODE, 'SMR' AS DIM_1,
         CASE WHEN EXISTS (SELECT 1 FROM CORA_REC.TB_MVT mv
                           JOIN CORA_REC.TB_DIAG d ON d.ID_MVT = mv.ID_MVT
                           WHERE mv.ID_SEJOUR = s.ID_SEJOUR) THEN 'non' ELSE 'oui' END AS DIM_2,
         CAST(NULL AS VARCHAR2(1)) AS DIM_3,
         1 AS UN
  FROM CORA_REC.TB_SEJOUR s
  WHERE s.DATE_SORTIE >= DATE '2025-07-01' AND s.DATE_SORTIE < TRUNC(SYSDATE) + 1
    AND NVL(s.STATUT_PROG, '-') <> 'P'
    AND TRIM(s.TYPE_SEJOUR) IN ('SSR', 'SMR')
),
mm AS (
  SELECT NIVEAU, PERIODE, DIM_1, DIM_2, DIM_3, COUNT(*) AS N
  FROM (SELECT NIVEAU, PERIODE, DIM_1, DIM_2, DIM_3 FROM mco
        UNION ALL
        SELECT NIVEAU, PERIODE, DIM_1, DIM_2, DIM_3 FROM smr)
  GROUP BY NIVEAU, PERIODE, DIM_1, DIM_2, DIM_3
),
c AS (
  SELECT NIVEAU, PERIODE, DIM_1, DIM_2, DIM_3, N FROM rr
  UNION ALL
  SELECT NIVEAU, PERIODE, DIM_1, DIM_2, DIM_3, N FROM mm
),
m AS (
  SELECT NIVEAU, PERIODE, DIM_1, DIM_2, DIM_3, N,
         SUM(N) OVER (PARTITION BY NIVEAU, PERIODE, DIM_1) AS TOT,
         SUM(CASE WHEN N < 10 THEN N ELSE 0 END) OVER (PARTITION BY NIVEAU, PERIODE, DIM_1) AS CACHE,
         ROW_NUMBER() OVER (PARTITION BY NIVEAU, PERIODE, DIM_1 ORDER BY N DESC, DIM_2, DIM_3) AS RANG
  FROM c
)
SELECT '20261019-dp-rum-marques-et-sans-diag' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       NIVEAU, PERIODE, DIM_1, DIM_2, DIM_3,
       CASE WHEN N < 10 THEN '<10' WHEN CACHE BETWEEN 1 AND 9 AND RANG = 1 THEN 'masqué' ELSE TO_CHAR(N) END AS N,
       CASE WHEN N < 10 OR (CACHE BETWEEN 1 AND 9 AND RANG = 1) THEN NULL ELSE ROUND(100 * N / TOT, 2) END AS PCT_GROUPE
FROM m
ORDER BY NIVEAU, PERIODE, DIM_1, DIM_2, DIM_3;
