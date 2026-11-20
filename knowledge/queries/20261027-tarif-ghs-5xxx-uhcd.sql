-- id: 20261027-tarif-ghs-5xxx-uhcd
-- system: cora
-- person_data: masked
-- purpose: éprouver l'hypothèse que les GHS 5xxx sont les GHS « monorum UHCD » de chaque racine (séjour dont l'unique RUM est en UHCD : un GHS par racine, un prix quelle que soit la durée, depuis la campagne MCO 2021), point ouvert de tarif-ghs-par-ghm-et-code-ghs (#103, étape 9 du plan revu du 2026-10-26). Elle tient si presque tous les RSS en GHS 5xxx n'ont qu'un RUM, dans une ou quelques UM d'UHCD, et si les RSS d'un seul RUM de ces UM sont presque tous en GHS 5xxx.
-- Oracle, schéma CORA_REC. RSS de TB_SYNTH_RSS finis en 2025, groupés (CODE_GHM renseigné), hors CMD 90 et GHS 9999 : mêmes filtres que 20261027-tarif-ghs-5xxx-nuits-et-type. RUM : TB_SYNTH_RUM par ID_RSS ; UM du RUM : TB_UNITE_MEDICALE par ID_UNITE_MEDICALE (comme 20261023-usip-typologie-flux).
-- Deux niveaux. RUM : RSS en GHS 5xxx par nombre de RUM ('0', '1', '2 ou plus'). UM : RSS d'un seul RUM, par UM de ce RUM ; N_RSS_5XXX : en GHS 5xxx ; N_RSS_AUTRES : dans un autre GHS. Les 15 UM qui ont le plus de RSS en GHS 5xxx ; les autres, et toute UM de moins de 10 RSS en GHS 5xxx, regroupées en « autres UM ».
-- Masquage : tout effectif < 10 sort en <10. Suppression secondaire (règle 4) : le total des RSS en GHS 5xxx de 2025 est publié (20261026-tarif-ghs-5xxx-et-ecarts-resultat), et celui des RSS d'un seul RUM l'est au niveau RUM ; dans chaque niveau, quand les cases de N_RSS_5XXX < 10 totalisent de 1 à 9, la plus grande case sort aussi en « masqué ». Aucune ligne de total.
WITH um_u AS (
  SELECT ID_UNITE_MED, TRIM(CODE_UNITE_MED) AS CODE_UM, TRIM(LIBELLE_UNITE_MED) AS LIBELLE_UM
  FROM CORA_REC.TB_UNITE_MEDICALE
),
rss AS (
  SELECT /*+ MATERIALIZE */ r.ID_RSS,
         CASE WHEN TRIM(r.CODE_GHS) LIKE '5___' THEN 1 ELSE 0 END AS EST_5
  FROM CORA_REC.TB_SYNTH_RSS r
  WHERE r.DATE_FIN >= DATE '2025-01-01' AND r.DATE_FIN < DATE '2026-01-01'
    AND TRIM(r.CODE_GHM) IS NOT NULL AND TRIM(r.CODE_CMD) <> '90'
    AND TRIM(r.CODE_GHS) <> '9999'
),
rums AS (
  SELECT /*+ MATERIALIZE */ ru.ID_RSS, COUNT(*) AS NB_RUM, MIN(ru.ID_UNITE_MEDICALE) AS ID_UM
  FROM CORA_REC.TB_SYNTH_RUM ru
  JOIN rss ON rss.ID_RSS = ru.ID_RSS
  GROUP BY ru.ID_RSS
),
b AS (
  SELECT rss.EST_5, NVL(rums.NB_RUM, 0) AS NB_RUM, rums.ID_UM
  FROM rss LEFT JOIN rums ON rums.ID_RSS = rss.ID_RSS
),
niv_rum AS (
  SELECT CASE WHEN NB_RUM = 0 THEN '0' WHEN NB_RUM = 1 THEN '1' ELSE '2 ou plus' END AS CLE,
         MIN(LEAST(NB_RUM, 2)) AS ORDRE, COUNT(*) AS N5
  FROM b
  WHERE EST_5 = 1
  GROUP BY CASE WHEN NB_RUM = 0 THEN '0' WHEN NB_RUM = 1 THEN '1' ELSE '2 ou plus' END
),
rum_m AS (
  SELECT CLE, ORDRE, N5,
         SUM(CASE WHEN N5 < 10 THEN N5 ELSE 0 END) OVER () AS PETITS,
         ROW_NUMBER() OVER (ORDER BY N5 DESC, CLE) AS RG
  FROM niv_rum
),
par_um AS (
  SELECT NVL(u.CODE_UM, 'inconnue') AS CODE_UM, MAX(u.LIBELLE_UM) AS LIBELLE_UM,
         SUM(b.EST_5) AS N5, SUM(1 - b.EST_5) AS NA
  FROM b LEFT JOIN um_u u ON u.ID_UNITE_MED = b.ID_UM
  WHERE b.NB_RUM = 1
  GROUP BY NVL(u.CODE_UM, 'inconnue')
),
rang AS (
  SELECT CODE_UM, LIBELLE_UM, N5, NA,
         CASE WHEN N5 >= 10 AND ROW_NUMBER() OVER (ORDER BY N5 DESC, CODE_UM) <= 15 THEN 1 ELSE 0 END AS GARDEE
  FROM par_um
),
grp AS (
  SELECT CASE WHEN GARDEE = 1 THEN CODE_UM ELSE 'autres UM' END AS CLE,
         MAX(CASE WHEN GARDEE = 1 THEN LIBELLE_UM END) AS LIBELLE,
         SUM(N5) AS N5, SUM(NA) AS NA
  FROM rang
  GROUP BY CASE WHEN GARDEE = 1 THEN CODE_UM ELSE 'autres UM' END
),
um_m AS (
  SELECT CLE, LIBELLE, N5, NA,
         SUM(CASE WHEN N5 < 10 THEN N5 ELSE 0 END) OVER () AS PETITS,
         ROW_NUMBER() OVER (ORDER BY N5 DESC, CLE) AS RG
  FROM grp
)
SELECT '20261027-tarif-ghs-5xxx-uhcd' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       x.NIVEAU, x.CLE, x.LIBELLE, x.N_RSS_5XXX, x.N_RSS_AUTRES
FROM (
  SELECT 'RUM' AS NIVEAU, CLE, CAST(NULL AS VARCHAR2(100)) AS LIBELLE, ORDRE,
         CASE WHEN N5 < 10 THEN '<10'
              WHEN RG = 1 AND PETITS BETWEEN 1 AND 9 THEN 'masqué'
              ELSE TO_CHAR(N5) END AS N_RSS_5XXX,
         CAST(NULL AS VARCHAR2(10)) AS N_RSS_AUTRES
  FROM rum_m
  UNION ALL
  SELECT 'UM', CLE, LIBELLE, RG,
         CASE WHEN N5 < 10 THEN '<10'
              WHEN RG = 1 AND PETITS BETWEEN 1 AND 9 THEN 'masqué'
              ELSE TO_CHAR(N5) END,
         CASE WHEN NA < 10 THEN '<10' ELSE TO_CHAR(NA) END
  FROM um_m
) x
ORDER BY x.NIVEAU, x.ORDRE;
