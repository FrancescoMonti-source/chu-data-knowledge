-- id: 20261027-tarif-ghs-5xxx-nuits-et-type
-- system: cora
-- person_data: masked
-- purpose: dire quels RSS le CHU groupe dans un GHS 5xxx, point ouvert de tarif-ghs-par-ghm-et-code-ghs (#103, étape 9 du plan revu du 2026-10-26) : s'ils sont presque tous de médecine sans nuitée, les GHS 5xxx peuvent être les GHS « intermédiaires » de la gradation des prises en charge ambulatoires ; s'il y a aussi des séjours avec nuitée ou de chirurgie, ils servent à autre chose
-- Oracle, schéma CORA_REC. RSS de TB_SYNTH_RSS finis en 2025, groupés (CODE_GHM renseigné), hors CMD 90 et GHS 9999 : mêmes filtres que le niveau RSS_5XXX de 20261026-tarif-ghs-5xxx-et-ecarts. GHS_5XXX : 'oui' quand CODE_GHS est de la forme 5xxx. TYPE_GHM : 3e caractère du GHM complet (CODE_CMD suivi de CODE_GHM), C, K, M ou Z, les autres en 'autre'. NUITS : '0' ou '1 ou plus', d'après TRUNC(DATE_FIN) − TRUNC(DATE_DEBUT) du RSS (duree-sejour), 'inconnu' sans date.
-- Masquage : tout effectif < 10 sort en <10. Suppression secondaire (règle 4) : le total des RSS en GHS 5xxx de 2025 est publié (20261026-tarif-ghs-5xxx-et-ecarts-resultat) ; dans chaque valeur de GHS_5XXX, quand les cases < 10 totalisent de 1 à 9, la plus grande case sort aussi en « masqué ». Une ligne par case, aucune ligne de total.
WITH rss AS (
  SELECT /*+ MATERIALIZE */
         CASE WHEN TRIM(r.CODE_GHS) LIKE '5___' THEN 'oui' ELSE 'non' END AS GHS_5XXX,
         CASE WHEN SUBSTR(TRIM(r.CODE_CMD) || TRIM(r.CODE_GHM), 3, 1) IN ('C', 'K', 'M', 'Z')
              THEN SUBSTR(TRIM(r.CODE_CMD) || TRIM(r.CODE_GHM), 3, 1) ELSE 'autre' END AS TYPE_GHM,
         CASE WHEN r.DATE_DEBUT IS NULL OR r.DATE_FIN IS NULL THEN 'inconnu'
              WHEN TRUNC(r.DATE_FIN) - TRUNC(r.DATE_DEBUT) < 1 THEN '0'
              ELSE '1 ou plus' END AS NUITS
  FROM CORA_REC.TB_SYNTH_RSS r
  WHERE r.DATE_FIN >= DATE '2025-01-01' AND r.DATE_FIN < DATE '2026-01-01'
    AND TRIM(r.CODE_GHM) IS NOT NULL AND TRIM(r.CODE_CMD) <> '90'
    AND TRIM(r.CODE_GHS) <> '9999'
),
g AS (
  SELECT GHS_5XXX, TYPE_GHM, NUITS, COUNT(*) AS N
  FROM rss
  GROUP BY GHS_5XXX, TYPE_GHM, NUITS
),
m AS (
  SELECT GHS_5XXX, TYPE_GHM, NUITS, N,
         SUM(CASE WHEN N < 10 THEN N ELSE 0 END) OVER (PARTITION BY GHS_5XXX) AS PETITS,
         ROW_NUMBER() OVER (PARTITION BY GHS_5XXX ORDER BY N DESC, TYPE_GHM, NUITS) AS RG
  FROM g
)
SELECT '20261027-tarif-ghs-5xxx-nuits-et-type' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       GHS_5XXX, TYPE_GHM, NUITS,
       CASE WHEN N < 10 THEN '<10'
            WHEN RG = 1 AND PETITS BETWEEN 1 AND 9 THEN 'masqué'
            ELSE TO_CHAR(N) END AS N_RSS
FROM m
ORDER BY GHS_5XXX, TYPE_GHM, NUITS;
