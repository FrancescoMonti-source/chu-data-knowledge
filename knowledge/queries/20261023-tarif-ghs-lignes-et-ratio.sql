-- id: 20261023-tarif-ghs-lignes-et-ratio
-- system: cora
-- person_data: masked
-- purpose: comprendre pourquoi PRIX_2026_MOY vaut environ la moitié de MONTANT_GHS_MOY dans 20261023-usip-dms-valorisation-2 (hypothèse de #103 : le plus petit PRIX d'un GHM n'est pas son tarif) ; dire combien de lignes PMSI_LIB_GHS_TARIF valides au 2026-06-30 porte un même GHM, et comparer MONTANT_GHS au PRIX de la ligne du même GHM et du même CODE_GHS, puis au plus petit PRIX du GHM, pour choisir le tarif d'une valorisation à tarif constant (étape 4 du plan)
-- Oracle, schéma CORA_REC. Colonnes de PMSI_LIB_GHS_TARIF d'après 20261015-catalogue-referentiels-resultat. Ligne valide à la date d : DATE_DEBUT <= d <= DATE_FIN (DATE_FIN inclusive, referentiels-pmsi-dans-cora).
-- Trois niveaux. LIGNES (référentiel, aucune personne) : les lignes valides au 2026-06-30 des racines 04C02, 05C02, 05C03, 05C10, 06C03, 06C04, 07C09 : GHM6, CODE_GHS, TYPE_ACTIVITE, VERSION, PRIX, BAS, HAUT, GET_LIBELLE. GHM_PAR_LIGNES (référentiel) : nombre de GHM (GHM_COMPTES, pas des personnes) qui ont 1, 2, 3 lignes ou plus valides au 2026-06-30 (CLASSE). RATIO (personnes, masqué) : RSS finis d'octobre 2025 à août 2026, au moins une nuit, hors GHS 9999 et CMD 90 et 28, par racine de la liste et 'toutes racines' ; N_RSS ; N_AVEC_LIGNE_GHS : RSS dont le GHM et le CODE_GHS trouvent une ligne valide à leur DATE_FIN ; RATIO_MED_GHS : médiane de MONTANT_GHS / PRIX de cette ligne ; RATIO_MED_MIN : médiane de MONTANT_GHS / plus petit PRIX du GHM valide à leur DATE_FIN.
-- Masquage : au niveau RATIO, chaque effectif < 10 sort en <10, et les médianes sont vides sous 10 RSS. Suppression secondaire (règle 4) : N_RSS sort en « masqué » quand N_RSS moins N_AVEC_LIGNE_GHS vaut de 1 à 9. Les lignes « toutes racines » contiennent celles des racines, sans autre total : rien ne permet d'y recalculer une case masquée, les racines n'étant qu'une partie de l'ensemble.
WITH t AS (
  SELECT /*+ MATERIALIZE */ TRIM(GHS) AS GHM6, TRIM(CODE_GHS) AS CODE_GHS, TRIM(TYPE_ACTIVITE) AS TYPE_ACT,
         TRIM(VERSION) AS VERSION, PRIX, BAS, HAUT, TRIM(GET_LIBELLE) AS GET_LIB,
         TRUNC(DATE_DEBUT) AS DD, TRUNC(DATE_FIN) AS DF
  FROM CORA_REC.PMSI_LIB_GHS_TARIF
),
racines AS (
  SELECT '04C02' AS R FROM DUAL UNION ALL SELECT '05C02' FROM DUAL UNION ALL SELECT '05C03' FROM DUAL
  UNION ALL SELECT '05C10' FROM DUAL UNION ALL SELECT '06C03' FROM DUAL UNION ALL SELECT '06C04' FROM DUAL
  UNION ALL SELECT '07C09' FROM DUAL
),
lignes AS (
  SELECT 'LIGNES' AS NIVEAU, t.GHM6 AS CLE, t.CODE_GHS, t.TYPE_ACT, t.VERSION, t.PRIX, t.BAS, t.HAUT, t.GET_LIB,
         CAST(NULL AS VARCHAR2(20)) AS GHM_COMPTES, CAST(NULL AS VARCHAR2(20)) AS N_RSS,
         CAST(NULL AS VARCHAR2(20)) AS N_AVEC_LIGNE_GHS, CAST(NULL AS NUMBER) AS RATIO_MED_GHS, CAST(NULL AS NUMBER) AS RATIO_MED_MIN
  FROM t
  WHERE SUBSTR(t.GHM6, 1, 5) IN (SELECT R FROM racines)
    AND t.DD <= DATE '2026-06-30' AND t.DF >= DATE '2026-06-30'
),
par_ghm AS (
  SELECT GHM6, COUNT(*) AS L
  FROM t
  WHERE DD <= DATE '2026-06-30' AND DF >= DATE '2026-06-30'
  GROUP BY GHM6
),
classes AS (
  SELECT 'GHM_PAR_LIGNES' AS NIVEAU,
         CASE WHEN L = 1 THEN '1 ligne' WHEN L = 2 THEN '2 lignes' ELSE '3 lignes ou plus' END AS CLE,
         CAST(NULL AS VARCHAR2(10)) AS CODE_GHS, CAST(NULL AS VARCHAR2(10)) AS TYPE_ACT, CAST(NULL AS VARCHAR2(10)) AS VERSION,
         CAST(NULL AS NUMBER) AS PRIX, CAST(NULL AS NUMBER) AS BAS, CAST(NULL AS NUMBER) AS HAUT, CAST(NULL AS VARCHAR2(10)) AS GET_LIB,
         TO_CHAR(COUNT(*)) AS GHM_COMPTES, CAST(NULL AS VARCHAR2(20)) AS N_RSS,
         CAST(NULL AS VARCHAR2(20)) AS N_AVEC_LIGNE_GHS, CAST(NULL AS NUMBER) AS RATIO_MED_GHS, CAST(NULL AS NUMBER) AS RATIO_MED_MIN
  FROM par_ghm
  GROUP BY CASE WHEN L = 1 THEN '1 ligne' WHEN L = 2 THEN '2 lignes' ELSE '3 lignes ou plus' END
),
rss AS (
  SELECT /*+ MATERIALIZE */ ROWNUM AS RN, TRIM(r.CODE_CMD) || TRIM(r.CODE_GHM) AS GHM6, TRIM(r.CODE_GHS) AS CODE_GHS,
         TRUNC(r.DATE_FIN) AS D, r.MONTANT_GHS
  FROM CORA_REC.TB_SYNTH_RSS r
  WHERE r.DATE_FIN >= DATE '2025-10-01' AND r.DATE_FIN < DATE '2026-09-01'
    AND TRIM(r.CODE_GHM) IS NOT NULL AND TRIM(r.CODE_CMD) NOT IN ('90', '28')
    AND TRIM(r.CODE_GHS) <> '9999'
    AND TRUNC(r.DATE_FIN) - TRUNC(r.DATE_DEBUT) >= 1
),
pg AS (
  SELECT rss.RN, MIN(t.PRIX) AS PRIX_GHS
  FROM rss JOIN t ON t.GHM6 = rss.GHM6 AND t.CODE_GHS = rss.CODE_GHS AND t.DD <= rss.D AND t.DF >= rss.D
  GROUP BY rss.RN
),
pm AS (
  SELECT rss.RN, MIN(t.PRIX) AS PRIX_MIN
  FROM rss JOIN t ON t.GHM6 = rss.GHM6 AND t.DD <= rss.D AND t.DF >= rss.D
  GROUP BY rss.RN
),
rp AS (
  SELECT rss.GHM6, rss.MONTANT_GHS, pg.PRIX_GHS, pm.PRIX_MIN
  FROM rss
  LEFT JOIN pg ON pg.RN = rss.RN
  LEFT JOIN pm ON pm.RN = rss.RN
),
rr AS (
  SELECT SUBSTR(GHM6, 1, 5) AS CLE, MONTANT_GHS, PRIX_GHS, PRIX_MIN FROM rp WHERE SUBSTR(GHM6, 1, 5) IN (SELECT R FROM racines)
  UNION ALL
  SELECT 'toutes racines', MONTANT_GHS, PRIX_GHS, PRIX_MIN FROM rp
),
ra AS (
  SELECT CLE, COUNT(*) AS N, COUNT(PRIX_GHS) AS NG,
         MEDIAN(CASE WHEN PRIX_GHS > 0 THEN MONTANT_GHS / PRIX_GHS END) AS MG,
         MEDIAN(CASE WHEN PRIX_MIN > 0 THEN MONTANT_GHS / PRIX_MIN END) AS MM
  FROM rr
  GROUP BY CLE
),
ratio AS (
  SELECT 'RATIO' AS NIVEAU, CLE,
         CAST(NULL AS VARCHAR2(10)) AS CODE_GHS, CAST(NULL AS VARCHAR2(10)) AS TYPE_ACT, CAST(NULL AS VARCHAR2(10)) AS VERSION,
         CAST(NULL AS NUMBER) AS PRIX, CAST(NULL AS NUMBER) AS BAS, CAST(NULL AS NUMBER) AS HAUT, CAST(NULL AS VARCHAR2(10)) AS GET_LIB,
         CAST(NULL AS VARCHAR2(20)) AS GHM_COMPTES,
         CASE WHEN N < 10 THEN '<10' WHEN N - NG BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(N) END AS N_RSS,
         CASE WHEN NG < 10 THEN '<10' ELSE TO_CHAR(NG) END AS N_AVEC_LIGNE_GHS,
         CASE WHEN NG >= 10 THEN ROUND(MG, 3) END AS RATIO_MED_GHS,
         CASE WHEN N >= 10 THEN ROUND(MM, 3) END AS RATIO_MED_MIN
  FROM ra
)
SELECT '20261023-tarif-ghs-lignes-et-ratio' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       x.NIVEAU, x.CLE, x.CODE_GHS, x.TYPE_ACT, x.VERSION, x.PRIX, x.BAS, x.HAUT, x.GET_LIB,
       x.GHM_COMPTES, x.N_RSS, x.N_AVEC_LIGNE_GHS, x.RATIO_MED_GHS, x.RATIO_MED_MIN
FROM (
  SELECT NIVEAU, CLE, CODE_GHS, TYPE_ACT, VERSION, PRIX, BAS, HAUT, GET_LIB, GHM_COMPTES, N_RSS, N_AVEC_LIGNE_GHS, RATIO_MED_GHS, RATIO_MED_MIN FROM lignes
  UNION ALL
  SELECT NIVEAU, CLE, CODE_GHS, TYPE_ACT, VERSION, PRIX, BAS, HAUT, GET_LIB, GHM_COMPTES, N_RSS, N_AVEC_LIGNE_GHS, RATIO_MED_GHS, RATIO_MED_MIN FROM classes
  UNION ALL
  SELECT NIVEAU, CLE, CODE_GHS, TYPE_ACT, VERSION, PRIX, BAS, HAUT, GET_LIB, GHM_COMPTES, N_RSS, N_AVEC_LIGNE_GHS, RATIO_MED_GHS, RATIO_MED_MIN FROM ratio
) x
ORDER BY x.NIVEAU, x.CLE, x.CODE_GHS;
