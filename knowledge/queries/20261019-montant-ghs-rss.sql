-- id: 20261019-montant-ghs-rss
-- system: cora
-- person_data: masked
-- purpose: par année de fin de RSS (DATE_FIN), mesurer la part de RSS groupés dont TB_SYNTH_RSS.MONTANT_GHS est positif (en distinguant les RSS de GHS 9999), le rapport MNT_TOTAL / MONTANT_GHS, et lister les GHM dont le code GHS vaut 9999 ; pour trancher montant-ghs-rss (réfuté si moins de 85 % des RSS MCO groupés ont un MONTANT_GHS positif ; le rapport dit si MNT_TOTAL est bien une autre grandeur que le GHS ; la liste des GHM de GHS 9999 vérifie 14Z08Z et 09Z02A). La seconde partie de la réfutation (écart au tarif de l'année) est testée par 20261019-tarif-ghs-couverture et le référentiel, pas ici
-- Oracle, schéma CORA_REC. RSS dont DATE_FIN va du 2018-01-01 au 2025-12-31 (les mois récents ne sont pas encore codés : rss-mois-recents-non-codes). RSS groupé : CODE_GHM renseigné et CODE_CMD différent de '90' (CMD 90 = non groupable). GHM complet = TRIM(CODE_CMD) || TRIM(CODE_GHM) (CODE_GHM porte 4 caractères : separer-ambulatoire-par-ghm). GHS 9999 : TRIM(CODE_GHS) = '9999'.
-- Niveau ANNEE : N_RSS ; N_GHS_9999 ; N_MONTANT_POSITIF (MONTANT_GHS > 0) ; N_POSITIF_HORS_9999 (MONTANT_GHS > 0 et GHS différent de 9999) ; PCT_POSITIF (sur tous les RSS groupés) ; PCT_POSITIF_HORS_9999 (sur les RSS hors GHS 9999) ; N_RSS_RAPPORT : RSS à MONTANT_GHS > 0 et MNT_TOTAL renseigné ; RAPPORT_MNT_TOTAL_SUR_GHS = somme des MNT_TOTAL / somme des MONTANT_GHS sur ces RSS.
-- Niveau GHM_9999 (toutes années 2018 à 2025 ensemble) : un GHM par ligne, N_RSS et N_MONTANT_POSITIF. Niveau GHM_SANS_MONTANT : GHM hors GHS 9999 qui ont au moins 100 RSS à MONTANT_GHS nul, vide ou négatif, N_RSS = ces RSS (pour repérer un tarif absent hors 9999).
-- Masquage : chaque effectif < 10 sort en <10 ; les pourcentages et le rapport ne sortent que si numérateur et dénominateur sont visibles. Suppression secondaire (règle 4) : N_RSS sort en « masqué » dès que N_RSS moins N_GHS_9999, ou moins N_MONTANT_POSITIF, vaut de 1 à 9 ; N_MONTANT_POSITIF de même avec N_POSITIF_HORS_9999. Aucune ligne de total entre niveaux.
WITH r AS (
  SELECT EXTRACT(YEAR FROM s.DATE_FIN) AS ANNEE,
         TRIM(s.CODE_CMD) || TRIM(s.CODE_GHM) AS GHM,
         CASE WHEN TRIM(s.CODE_GHS) = '9999' THEN 1 ELSE 0 END AS EST_9999,
         CASE WHEN s.MONTANT_GHS > 0 THEN 1 ELSE 0 END AS POS,
         s.MONTANT_GHS, s.MNT_TOTAL
  FROM CORA_REC.TB_SYNTH_RSS s
  WHERE s.DATE_FIN >= DATE '2018-01-01' AND s.DATE_FIN < DATE '2026-01-01'
    AND TRIM(s.CODE_GHM) IS NOT NULL AND TRIM(s.CODE_CMD) <> '90'
),
an AS (
  SELECT 'ANNEE' AS NIVEAU, TO_CHAR(ANNEE) AS CLE,
         COUNT(*) AS N,
         SUM(EST_9999) AS C1,
         SUM(POS) AS C2,
         SUM(CASE WHEN POS = 1 AND EST_9999 = 0 THEN 1 ELSE 0 END) AS C3,
         SUM(CASE WHEN POS = 1 AND MNT_TOTAL IS NOT NULL THEN 1 ELSE 0 END) AS K,
         SUM(CASE WHEN POS = 1 AND MNT_TOTAL IS NOT NULL THEN MNT_TOTAL END) AS S_TOT,
         SUM(CASE WHEN POS = 1 AND MNT_TOTAL IS NOT NULL THEN MONTANT_GHS END) AS S_GHS
  FROM r
  GROUP BY ANNEE
),
g9 AS (
  SELECT 'GHM_9999' AS NIVEAU, GHM AS CLE, COUNT(*) AS N, 0 AS C1, SUM(POS) AS C2, 0 AS C3, 0 AS K,
         CAST(NULL AS NUMBER) AS S_TOT, CAST(NULL AS NUMBER) AS S_GHS
  FROM r
  WHERE EST_9999 = 1
  GROUP BY GHM
),
gs AS (
  SELECT 'GHM_SANS_MONTANT' AS NIVEAU, GHM AS CLE, COUNT(*) AS N, 0 AS C1, 0 AS C2, 0 AS C3, 0 AS K,
         CAST(NULL AS NUMBER) AS S_TOT, CAST(NULL AS NUMBER) AS S_GHS
  FROM r
  WHERE EST_9999 = 0 AND POS = 0
  GROUP BY GHM
  HAVING COUNT(*) >= 100
),
t AS (
  SELECT NIVEAU, CLE, N, C1, C2, C3, K, S_TOT, S_GHS FROM an
  UNION ALL
  SELECT NIVEAU, CLE, N, C1, C2, C3, K, S_TOT, S_GHS FROM g9
  UNION ALL
  SELECT NIVEAU, CLE, N, C1, C2, C3, K, S_TOT, S_GHS FROM gs
)
SELECT '20261019-montant-ghs-rss' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       NIVEAU, CLE,
       CASE WHEN N < 10 THEN '<10'
            WHEN NIVEAU = 'ANNEE' AND (N - C1 BETWEEN 1 AND 9 OR N - C2 BETWEEN 1 AND 9) THEN 'masqué'
            ELSE TO_CHAR(N) END AS N_RSS,
       CASE WHEN NIVEAU <> 'ANNEE' THEN NULL WHEN C1 < 10 THEN '<10' ELSE TO_CHAR(C1) END AS N_GHS_9999,
       CASE WHEN NIVEAU = 'GHM_SANS_MONTANT' THEN NULL WHEN C2 < 10 THEN '<10'
            WHEN NIVEAU = 'ANNEE' AND C2 - C3 BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(C2) END AS N_MONTANT_POSITIF,
       CASE WHEN NIVEAU <> 'ANNEE' THEN NULL WHEN C3 < 10 THEN '<10' ELSE TO_CHAR(C3) END AS N_POSITIF_HORS_9999,
       CASE WHEN NIVEAU = 'ANNEE' AND N >= 10 AND C2 >= 10 AND N - C1 NOT BETWEEN 1 AND 9 AND N - C2 NOT BETWEEN 1 AND 9
            THEN TO_CHAR(ROUND(100 * C2 / N, 2), 'FM990.00', 'NLS_NUMERIC_CHARACTERS=''. ''') END AS PCT_POSITIF,
       CASE WHEN NIVEAU = 'ANNEE' AND N - C1 >= 10 AND C3 >= 10 AND N - C1 NOT BETWEEN 1 AND 9 AND C2 - C3 NOT BETWEEN 1 AND 9
            THEN TO_CHAR(ROUND(100 * C3 / (N - C1), 2), 'FM990.00', 'NLS_NUMERIC_CHARACTERS=''. ''') END AS PCT_POSITIF_HORS_9999,
       CASE WHEN NIVEAU <> 'ANNEE' THEN NULL WHEN K < 10 THEN '<10' ELSE TO_CHAR(K) END AS N_RSS_RAPPORT,
       CASE WHEN NIVEAU = 'ANNEE' AND K >= 10 AND S_GHS <> 0
            THEN TO_CHAR(ROUND(S_TOT / S_GHS, 4), 'FM990.0000', 'NLS_NUMERIC_CHARACTERS=''. ''') END AS RAPPORT_MNT_TOTAL_SUR_GHS
FROM t
ORDER BY NIVEAU, CLE;
