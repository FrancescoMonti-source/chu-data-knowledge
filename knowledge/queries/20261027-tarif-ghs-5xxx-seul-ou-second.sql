-- id: 20261027-tarif-ghs-5xxx-seul-ou-second
-- system: cora
-- person_data: masked
-- purpose: éprouver la piste de Francesco (#103, étape 9 du plan revu du 2026-10-26) : un GHS 5xxx peut être le GHS ordinaire de son GHM (5500 pour 14Z15Z), et non une seconde ligne à côté d'un GHS ordinaire comme le GHS monorum UHCD. Si les RSS en GHS 5xxx des UM d'obstétrique (6163, 6167) sont dans des GHM dont toutes les lignes sont en 5xxx, la piste explique pourquoi ces UM ont, comme l'UHCD, presque tous leurs RSS d'un seul RUM en 5xxx (points ouverts de uhcd-reperer-par-um et de tarif-ghs-par-ghm-et-code-ghs).
-- Oracle, schéma CORA_REC. Ligne valide à la date d : TRUNC(DATE_DEBUT) <= d <= TRUNC(DATE_FIN) (referentiels-pmsi-dans-cora). GHM complet : TRIM(GHS) de PMSI_LIB_GHS_TARIF, TRIM(CODE_CMD) || TRIM(CODE_GHM) de TB_SYNTH_RSS.
-- Trois niveaux. Référentiel, aucune personne, lignes valides au 2025-06-30 : CMD (par CMD, les GHM dont aucune ligne n'est en 5xxx, ceux qui ont une ligne 5xxx et une autre, ceux dont toutes les lignes sont en 5xxx ; plus petit et plus grand CODE_GHS hors 5xxx) ; EXEMPLE (les lignes des GHM de la racine 14Z15). Personnes, masqué : UM (RSS finis en 2025, groupés, hors CMD 90 et GHS 9999, groupés dans un GHS 5xxx ; mêmes lignes que le niveau UM de 20261027-tarif-ghs-5xxx-uhcd : RSS d'un seul RUM par UM de ce RUM, les 15 UM qui en ont le plus, les autres et toute UM de moins de 10 RSS en « autres UM » ; plus une ligne « plusieurs RUM » et, s'il y en a, « sans RUM »). N_SECOND : le GHM du RSS a aussi, à la DATE_FIN du RSS, une ligne valide hors 5xxx ; N_SEUL : toutes ses lignes valides sont en 5xxx ; N_SANS_LIGNE : aucune ligne valide.
-- Comptes du référentiel nommés …_COMPTES : ce ne sont pas des personnes. Masquage : tout effectif de RSS < 10 sort en <10. Suppression secondaire (règle 4) : le total de chaque ligne du niveau UM est publié (20261027-tarif-ghs-5xxx-uhcd-resultat) ; dans chaque ligne, quand les cases < 10 totalisent de 1 à 9, la plus grande case sort aussi en « masqué ». Aucune ligne ni colonne de total.
WITH lig AS (
  SELECT TRIM(GHS) AS GHM6, TRIM(CODE_GHS) AS CODE_GHS, TRIM(LIBELLE_GHS) AS LIBELLE_GHS,
         PRIX, BAS, HAUT,
         CASE WHEN TRIM(CODE_GHS) LIKE '5___' THEN 1 ELSE 0 END AS EST_5
  FROM CORA_REC.PMSI_LIB_GHS_TARIF
  WHERE TRUNC(DATE_DEBUT) <= DATE '2025-06-30' AND TRUNC(DATE_FIN) >= DATE '2025-06-30'
),
ghm AS (
  SELECT GHM6, MAX(EST_5) AS A_5, MIN(EST_5) AS TOUT_5
  FROM lig
  GROUP BY GHM6
),
cmd AS (
  SELECT g.CMD, g.G_HORS, g.G_MIXTE, g.G_5_SEUL, h.GHS_MIN, h.GHS_MAX
  FROM (
    SELECT SUBSTR(GHM6, 1, 2) AS CMD,
           SUM(CASE WHEN A_5 = 0 THEN 1 ELSE 0 END) AS G_HORS,
           SUM(CASE WHEN A_5 = 1 AND TOUT_5 = 0 THEN 1 ELSE 0 END) AS G_MIXTE,
           SUM(CASE WHEN TOUT_5 = 1 THEN 1 ELSE 0 END) AS G_5_SEUL
    FROM ghm
    GROUP BY SUBSTR(GHM6, 1, 2)
  ) g
  LEFT JOIN (
    SELECT SUBSTR(GHM6, 1, 2) AS CMD, MIN(CODE_GHS) AS GHS_MIN, MAX(CODE_GHS) AS GHS_MAX
    FROM lig
    WHERE EST_5 = 0
    GROUP BY SUBSTR(GHM6, 1, 2)
  ) h ON h.CMD = g.CMD
),
um_u AS (
  SELECT ID_UNITE_MED, TRIM(CODE_UNITE_MED) AS CODE_UM, TRIM(LIBELLE_UNITE_MED) AS LIBELLE_UM
  FROM CORA_REC.TB_UNITE_MEDICALE
),
rss AS (
  SELECT /*+ MATERIALIZE */ r.ID_RSS,
         TRIM(r.CODE_CMD) || TRIM(r.CODE_GHM) AS GHM6,
         TRUNC(r.DATE_FIN) AS D
  FROM CORA_REC.TB_SYNTH_RSS r
  WHERE r.DATE_FIN >= DATE '2025-01-01' AND r.DATE_FIN < DATE '2026-01-01'
    AND TRIM(r.CODE_GHM) IS NOT NULL AND TRIM(r.CODE_CMD) <> '90'
    AND TRIM(r.CODE_GHS) <> '9999'
    AND TRIM(r.CODE_GHS) LIKE '5___'
),
genre AS (
  SELECT rss.ID_RSS,
         CASE WHEN COUNT(t.CODE_GHS) = 0 THEN 'sans ligne'
              WHEN MAX(CASE WHEN TRIM(t.CODE_GHS) LIKE '5___' THEN 0 ELSE 1 END) = 1 THEN 'second'
              ELSE 'seul' END AS GENRE
  FROM rss
  LEFT JOIN CORA_REC.PMSI_LIB_GHS_TARIF t
    ON TRIM(t.GHS) = rss.GHM6
   AND TRUNC(t.DATE_DEBUT) <= rss.D AND TRUNC(t.DATE_FIN) >= rss.D
  GROUP BY rss.ID_RSS
),
rums AS (
  SELECT /*+ MATERIALIZE */ ru.ID_RSS, COUNT(*) AS NB_RUM, MIN(ru.ID_UNITE_MEDICALE) AS ID_UM
  FROM CORA_REC.TB_SYNTH_RUM ru
  JOIN rss ON rss.ID_RSS = ru.ID_RSS
  GROUP BY ru.ID_RSS
),
b AS (
  SELECT g.GENRE, NVL(rums.NB_RUM, 0) AS NB_RUM, rums.ID_UM
  FROM genre g LEFT JOIN rums ON rums.ID_RSS = g.ID_RSS
),
par_um AS (
  SELECT NVL(u.CODE_UM, 'inconnue') AS CODE_UM, MAX(u.LIBELLE_UM) AS LIBELLE_UM,
         COUNT(*) AS N5,
         SUM(CASE WHEN b.GENRE = 'second' THEN 1 ELSE 0 END) AS NS,
         SUM(CASE WHEN b.GENRE = 'seul' THEN 1 ELSE 0 END) AS NU,
         SUM(CASE WHEN b.GENRE = 'sans ligne' THEN 1 ELSE 0 END) AS NL
  FROM b LEFT JOIN um_u u ON u.ID_UNITE_MED = b.ID_UM
  WHERE b.NB_RUM = 1
  GROUP BY NVL(u.CODE_UM, 'inconnue')
),
rang AS (
  SELECT CODE_UM, LIBELLE_UM, N5, NS, NU, NL,
         CASE WHEN N5 >= 10 AND ROW_NUMBER() OVER (ORDER BY N5 DESC, CODE_UM) <= 15 THEN 1 ELSE 0 END AS GARDEE
  FROM par_um
),
grp AS (
  SELECT CASE WHEN GARDEE = 1 THEN CODE_UM ELSE 'autres UM' END AS CLE,
         MAX(CASE WHEN GARDEE = 1 THEN LIBELLE_UM END) AS LIBELLE,
         SUM(N5) AS N5, SUM(NS) AS NS, SUM(NU) AS NU, SUM(NL) AS NL
  FROM rang
  GROUP BY CASE WHEN GARDEE = 1 THEN CODE_UM ELSE 'autres UM' END
),
lignes_um AS (
  SELECT CLE, LIBELLE, LPAD(TO_CHAR(ROW_NUMBER() OVER (ORDER BY N5 DESC, CLE)), 3, '0') AS ORDRE, NS, NU, NL
  FROM grp
  UNION ALL
  SELECT CASE WHEN NB_RUM = 0 THEN 'sans RUM' ELSE 'plusieurs RUM' END,
         CAST(NULL AS VARCHAR2(100)),
         CASE WHEN NB_RUM = 0 THEN '901' ELSE '900' END,
         SUM(CASE WHEN GENRE = 'second' THEN 1 ELSE 0 END),
         SUM(CASE WHEN GENRE = 'seul' THEN 1 ELSE 0 END),
         SUM(CASE WHEN GENRE = 'sans ligne' THEN 1 ELSE 0 END)
  FROM b
  WHERE NB_RUM <> 1
  GROUP BY CASE WHEN NB_RUM = 0 THEN 'sans RUM' ELSE 'plusieurs RUM' END,
           CASE WHEN NB_RUM = 0 THEN '901' ELSE '900' END
),
um_m AS (
  SELECT CLE, LIBELLE, ORDRE, NS, NU, NL,
         CASE WHEN NS < 10 THEN NS ELSE 0 END + CASE WHEN NU < 10 THEN NU ELSE 0 END
           + CASE WHEN NL < 10 THEN NL ELSE 0 END AS PETITS,
         GREATEST(NS, NU, NL) AS GRAND
  FROM lignes_um
)
SELECT '20261027-tarif-ghs-5xxx-seul-ou-second' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       x.NIVEAU, x.CLE, x.LIBELLE, x.CODE_GHS, x.PRIX, x.BAS, x.HAUT,
       x.GHM_HORS_5XXX_COMPTES, x.GHM_MIXTES_COMPTES, x.GHM_5XXX_SEUL_COMPTES, x.GHS_HORS_5XXX_MIN, x.GHS_HORS_5XXX_MAX,
       x.N_SECOND, x.N_SEUL, x.N_SANS_LIGNE
FROM (
  SELECT 'CMD' AS NIVEAU, CMD AS CLE, CAST(NULL AS VARCHAR2(200)) AS LIBELLE, CMD AS ORDRE,
         CAST(NULL AS VARCHAR2(10)) AS CODE_GHS, CAST(NULL AS NUMBER) AS PRIX,
         CAST(NULL AS NUMBER) AS BAS, CAST(NULL AS NUMBER) AS HAUT,
         G_HORS AS GHM_HORS_5XXX_COMPTES, G_MIXTE AS GHM_MIXTES_COMPTES, G_5_SEUL AS GHM_5XXX_SEUL_COMPTES,
         GHS_MIN AS GHS_HORS_5XXX_MIN, GHS_MAX AS GHS_HORS_5XXX_MAX,
         CAST(NULL AS VARCHAR2(10)) AS N_SECOND, CAST(NULL AS VARCHAR2(10)) AS N_SEUL,
         CAST(NULL AS VARCHAR2(10)) AS N_SANS_LIGNE
  FROM cmd
  UNION ALL
  SELECT 'EXEMPLE', GHM6, LIBELLE_GHS, GHM6 || CODE_GHS,
         CODE_GHS, PRIX, BAS, HAUT,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
  FROM lig
  WHERE GHM6 LIKE '14Z15%'
  UNION ALL
  SELECT 'UM', CLE, LIBELLE, ORDRE,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         CASE WHEN NS < 10 THEN '<10' WHEN PETITS BETWEEN 1 AND 9 AND NS = GRAND THEN 'masqué' ELSE TO_CHAR(NS) END,
         CASE WHEN NU < 10 THEN '<10' WHEN PETITS BETWEEN 1 AND 9 AND NU = GRAND THEN 'masqué' ELSE TO_CHAR(NU) END,
         CASE WHEN NL < 10 THEN '<10' WHEN PETITS BETWEEN 1 AND 9 AND NL = GRAND THEN 'masqué' ELSE TO_CHAR(NL) END
  FROM um_m
) x
ORDER BY x.NIVEAU, x.ORDRE;
