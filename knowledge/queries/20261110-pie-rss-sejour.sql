-- id: 20261110-pie-rss-sejour
-- system: cora
-- person_data: masked
-- purpose: étape 2 du plan (#133, enquête ghs-par-sejour) : dire si CORA valorise (MONTANT_GHS, MNT_TOTAL) les RSS que le CHU produit comme prestataire d'une prestation interétablissement (PIE, modes d'entrée et de sortie « 0 »), que le guide méthodologique MCO 2026 dit non facturables à l'assurance maladie hors séances ; si VID-HOSP les marque non facturables (motif 5) ; combien de RSS portent Z75.80 (le CHU demandeur) ; et, par séjour, si le NO_SEJOUR est unique et si les séjours à plusieurs RSS s'expliquent par un RSS de PIE
-- Oracle, schéma CORA_REC. RSS de TB_SYNTH_RSS dont DATE_FIN va du 2022-01-01 au 2025-12-31 (les mois récents ne sont pas encore codés : rss-mois-recents-non-codes), groupés : CODE_GHM renseigné et CODE_CMD différent de '90' (montant-ghs-rss).
-- PIE prestataire : TRIM(MODE_ENTREE) = '0' et TRIM(MODE_SORTIE) = '0' (guide MCO 2026, chapitre I, 3.3.1 ; même critère dans la requête CORA par défaut « analyse detaillee des PIE A et PIE B »). Séance : CODE_CMD = '28' (le guide, 3.3.2, fait facturer le GHS des séances par le prestataire).
-- VID-HOSP non facturable pour PIE : un enregistrement de TB_VIDHOSP du même ID_SEJOUR avec FACTURABLE_AM = '0' et MOTIF_NON_FACT = '5' (dictionnaire-cora-2020, TB_VIDHOSP ; requête CORA par défaut « PIE B de RSS et pad de VIDHOSP »). Lu par EXISTS : un séjour à plusieurs VID-HOSP ne double pas ses RSS.
-- PIE demandeur : un diagnostic 'Z7580' (Z75.80, tout type) sur un mouvement du RSS (TB_MVT_RUM.ID_RSS → ID_MVT → TB_DIAG.ID_MVT ; code sans point : code-cim10-sans-point).
-- Niveau RSS (une ligne par année de DATE_FIN) :
--   N_RSS ; N_ME0_ET_MS0 : RSS PIE prestataire ; N_ME0_OU_MS0_SEUL : un seul des deux modes vaut 0 (attendu rare) ;
--   pour les PIE hors séances (PB) puis les PIE séances (PS) : N_*, N_*_GHS_POS (MONTANT_GHS > 0), N_*_VH_NON_FACT (VID-HOSP motif 5), EUR_*_MONTANT_GHS et EUR_*_MNT_TOTAL (sommes en euros) ;
--   N_Z7580 : RSS qui portent Z75.80 ; N_Z7580_ET_ME0_MS0 : parmi eux, RSS aussi PIE prestataire.
-- Niveau SEJOUR (une ligne par année de la plus grande DATE_FIN de ses RSS) :
--   N_SEJ : séjours (ID_SEJOUR) qui ont au moins un RSS de la période ; N_SEJ_PLUSIEURS_RSS : ceux qui en ont deux ou plus ; N_SEJ_PLUSIEURS_DONT_PIE : parmi eux, au moins un RSS PIE prestataire ;
--   N_NO_SEJOUR : valeurs distinctes de TRIM(TB_SEJOUR.NO_SEJOUR) parmi ces séjours, dans l'année ; N_NO_SEJOUR_PARTAGE : valeurs portées par deux ID_SEJOUR ou plus ; N_SEJ_SANS_NO_SEJOUR : NO_SEJOUR vide.
-- Masquage : tout effectif < 10 sort en <10 ; une somme en euros ne sort que si son effectif est visible. Suppression secondaire (règle 4) : un effectif inclus dans un autre (N_PB_GHS_POS dans N_PB, N_SEJ_PLUSIEURS_DONT_PIE dans N_SEJ_PLUSIEURS_RSS…) sort en « masqué » quand l'écart entre les deux vaut de 1 à 9 ; N_NO_SEJOUR sort en « masqué » quand l'écart à N_SEJ vaut de 1 à 9. Aucune ligne de total.
WITH r AS (
  SELECT s.ID_RSS, s.ID_SEJOUR,
         EXTRACT(YEAR FROM s.DATE_FIN) AS ANNEE,
         s.DATE_FIN,
         CASE WHEN TRIM(s.MODE_ENTREE) = '0' AND TRIM(s.MODE_SORTIE) = '0' THEN 1 ELSE 0 END AS PIE,
         CASE WHEN (TRIM(s.MODE_ENTREE) = '0' OR TRIM(s.MODE_SORTIE) = '0')
               AND NOT (TRIM(s.MODE_ENTREE) = '0' AND TRIM(s.MODE_SORTIE) = '0') THEN 1 ELSE 0 END AS UN_SEUL_0,
         CASE WHEN TRIM(s.CODE_CMD) = '28' THEN 1 ELSE 0 END AS SEANCE,
         CASE WHEN s.MONTANT_GHS > 0 THEN 1 ELSE 0 END AS GHS_POS,
         NVL(s.MONTANT_GHS, 0) AS MONTANT_GHS,
         NVL(s.MNT_TOTAL, 0) AS MNT_TOTAL,
         CASE WHEN EXISTS (SELECT 1 FROM CORA_REC.TB_VIDHOSP v
                           WHERE v.ID_SEJOUR = s.ID_SEJOUR
                             AND TRIM(v.FACTURABLE_AM) = '0' AND TRIM(v.MOTIF_NON_FACT) = '5')
              THEN 1 ELSE 0 END AS VH_NON_FACT,
         CASE WHEN EXISTS (SELECT 1 FROM CORA_REC.TB_MVT_RUM mr
                           JOIN CORA_REC.TB_DIAG d ON d.ID_MVT = mr.ID_MVT
                           WHERE mr.ID_RSS = s.ID_RSS AND TRIM(d.CODE_DIAG) = 'Z7580')
              THEN 1 ELSE 0 END AS Z7580
  FROM CORA_REC.TB_SYNTH_RSS s
  WHERE s.DATE_FIN >= DATE '2022-01-01' AND s.DATE_FIN < DATE '2026-01-01'
    AND TRIM(s.CODE_GHM) IS NOT NULL AND TRIM(s.CODE_CMD) <> '90'
),
niv_rss AS (
  SELECT 'RSS' AS NIVEAU, ANNEE,
         COUNT(*) AS N_RSS,
         SUM(PIE) AS N_PIE,
         SUM(UN_SEUL_0) AS N_UN_SEUL_0,
         SUM(CASE WHEN PIE = 1 AND SEANCE = 0 THEN 1 ELSE 0 END) AS N_PB,
         SUM(CASE WHEN PIE = 1 AND SEANCE = 0 THEN GHS_POS ELSE 0 END) AS N_PB_POS,
         SUM(CASE WHEN PIE = 1 AND SEANCE = 0 THEN VH_NON_FACT ELSE 0 END) AS N_PB_VH,
         SUM(CASE WHEN PIE = 1 AND SEANCE = 0 THEN MONTANT_GHS ELSE 0 END) AS E_PB_GHS,
         SUM(CASE WHEN PIE = 1 AND SEANCE = 0 THEN MNT_TOTAL ELSE 0 END) AS E_PB_TOT,
         SUM(CASE WHEN PIE = 1 AND SEANCE = 1 THEN 1 ELSE 0 END) AS N_PS,
         SUM(CASE WHEN PIE = 1 AND SEANCE = 1 THEN GHS_POS ELSE 0 END) AS N_PS_POS,
         SUM(CASE WHEN PIE = 1 AND SEANCE = 1 THEN VH_NON_FACT ELSE 0 END) AS N_PS_VH,
         SUM(CASE WHEN PIE = 1 AND SEANCE = 1 THEN MONTANT_GHS ELSE 0 END) AS E_PS_GHS,
         SUM(CASE WHEN PIE = 1 AND SEANCE = 1 THEN MNT_TOTAL ELSE 0 END) AS E_PS_TOT,
         SUM(Z7580) AS N_Z,
         SUM(CASE WHEN Z7580 = 1 AND PIE = 1 THEN 1 ELSE 0 END) AS N_Z_PIE
  FROM r
  GROUP BY ANNEE
),
sej AS (
  SELECT r.ID_SEJOUR,
         EXTRACT(YEAR FROM MAX(r.DATE_FIN)) AS ANNEE,
         COUNT(*) AS NB_RSS,
         MAX(r.PIE) AS A_PIE
  FROM r
  GROUP BY r.ID_SEJOUR
),
sej_no AS (
  SELECT sj.ID_SEJOUR, sj.ANNEE, sj.NB_RSS, sj.A_PIE, TRIM(t.NO_SEJOUR) AS NO_SEJ
  FROM sej sj
  JOIN CORA_REC.TB_SEJOUR t ON t.ID_SEJOUR = sj.ID_SEJOUR
),
no_partage AS (
  SELECT ANNEE, NO_SEJ, COUNT(DISTINCT ID_SEJOUR) AS NB_ID
  FROM sej_no
  WHERE NO_SEJ IS NOT NULL
  GROUP BY ANNEE, NO_SEJ
),
agg_sej AS (
  SELECT ANNEE,
         COUNT(*) AS N_SEJ,
         SUM(CASE WHEN NB_RSS >= 2 THEN 1 ELSE 0 END) AS N_PLUS,
         SUM(CASE WHEN NB_RSS >= 2 AND A_PIE = 1 THEN 1 ELSE 0 END) AS N_PLUS_PIE,
         SUM(CASE WHEN NO_SEJ IS NULL THEN 1 ELSE 0 END) AS N_SANS_NO
  FROM sej_no
  GROUP BY ANNEE
),
agg_no AS (
  SELECT ANNEE, COUNT(*) AS N_NO,
         SUM(CASE WHEN NB_ID >= 2 THEN 1 ELSE 0 END) AS N_NO_PARTAGE
  FROM no_partage
  GROUP BY ANNEE
),
niv_sej AS (
  SELECT 'SEJOUR' AS NIVEAU, a.ANNEE, a.N_SEJ, a.N_PLUS, a.N_PLUS_PIE, a.N_SANS_NO,
         NVL(b.N_NO, 0) AS N_NO, NVL(b.N_NO_PARTAGE, 0) AS N_NO_PARTAGE
  FROM agg_sej a
  LEFT JOIN agg_no b ON b.ANNEE = a.ANNEE
)
SELECT '20261110-pie-rss-sejour' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       NIVEAU, ANNEE,
       CASE WHEN N_RSS < 10 THEN '<10' ELSE TO_CHAR(N_RSS) END AS N_RSS,
       CASE WHEN N_PIE < 10 THEN '<10' ELSE TO_CHAR(N_PIE) END AS N_ME0_ET_MS0,
       CASE WHEN N_UN_SEUL_0 < 10 THEN '<10' ELSE TO_CHAR(N_UN_SEUL_0) END AS N_ME0_OU_MS0_SEUL,
       CASE WHEN N_PB < 10 THEN '<10' WHEN N_PIE - N_PB BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(N_PB) END AS N_PB,
       CASE WHEN N_PB_POS < 10 THEN '<10' WHEN N_PB - N_PB_POS BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(N_PB_POS) END AS N_PB_GHS_POS,
       CASE WHEN N_PB_VH < 10 THEN '<10' WHEN N_PB - N_PB_VH BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(N_PB_VH) END AS N_PB_VH_NON_FACT,
       CASE WHEN N_PB_POS < 10 THEN NULL ELSE TO_CHAR(ROUND(E_PB_GHS)) END AS EUR_PB_MONTANT_GHS,
       CASE WHEN N_PB < 10 THEN NULL ELSE TO_CHAR(ROUND(E_PB_TOT)) END AS EUR_PB_MNT_TOTAL,
       CASE WHEN N_PS < 10 THEN '<10' WHEN N_PIE - N_PS BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(N_PS) END AS N_PS,
       CASE WHEN N_PS_POS < 10 THEN '<10' WHEN N_PS - N_PS_POS BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(N_PS_POS) END AS N_PS_GHS_POS,
       CASE WHEN N_PS_VH < 10 THEN '<10' WHEN N_PS - N_PS_VH BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(N_PS_VH) END AS N_PS_VH_NON_FACT,
       CASE WHEN N_PS_POS < 10 THEN NULL ELSE TO_CHAR(ROUND(E_PS_GHS)) END AS EUR_PS_MONTANT_GHS,
       CASE WHEN N_PS < 10 THEN NULL ELSE TO_CHAR(ROUND(E_PS_TOT)) END AS EUR_PS_MNT_TOTAL,
       CASE WHEN N_Z < 10 THEN '<10' ELSE TO_CHAR(N_Z) END AS N_Z7580,
       CASE WHEN N_Z_PIE < 10 THEN '<10' WHEN N_Z - N_Z_PIE BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(N_Z_PIE) END AS N_Z7580_ET_ME0_MS0,
       CAST(NULL AS VARCHAR2(20)) AS N_SEJ,
       CAST(NULL AS VARCHAR2(20)) AS N_SEJ_PLUSIEURS_RSS,
       CAST(NULL AS VARCHAR2(20)) AS N_SEJ_PLUSIEURS_DONT_PIE,
       CAST(NULL AS VARCHAR2(20)) AS N_NO_SEJOUR,
       CAST(NULL AS VARCHAR2(20)) AS N_NO_SEJOUR_PARTAGE,
       CAST(NULL AS VARCHAR2(20)) AS N_SEJ_SANS_NO_SEJOUR
FROM niv_rss
UNION ALL
SELECT '20261110-pie-rss-sejour', SYS_CONTEXT('USERENV', 'DB_NAME'), TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI'),
       NIVEAU, ANNEE,
       NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
       CASE WHEN N_SEJ < 10 THEN '<10' ELSE TO_CHAR(N_SEJ) END,
       CASE WHEN N_PLUS < 10 THEN '<10' ELSE TO_CHAR(N_PLUS) END,
       CASE WHEN N_PLUS_PIE < 10 THEN '<10' WHEN N_PLUS - N_PLUS_PIE BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(N_PLUS_PIE) END,
       CASE WHEN N_NO < 10 THEN '<10' WHEN N_SEJ - N_NO BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(N_NO) END,
       CASE WHEN N_NO_PARTAGE < 10 THEN '<10' ELSE TO_CHAR(N_NO_PARTAGE) END,
       CASE WHEN N_SANS_NO < 10 THEN '<10' ELSE TO_CHAR(N_SANS_NO) END
FROM niv_sej
ORDER BY 4, 5;
