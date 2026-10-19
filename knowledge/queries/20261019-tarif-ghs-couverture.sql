-- id: 20261019-tarif-ghs-couverture
-- system: cora
-- person_data: masked
-- purpose: par année de fin de RSS, mesurer la part de RSS groupés qui ne trouvent aucune ligne de CORA_REC.PMSI_LIB_GHS_TARIF selon la condition de jointure (GHM complet CODE_CMD || CODE_GHM contre TRIM(GHS) avec période de validité, borne DATE_FIN exclusive ou inclusive, sans la période, par CODE_GHS, par CODE_GHM seul), pour trancher tarif-ghs-jointure-couverture (réfuté si, pour une année, plus de 95 % des RSS MCO groupés trouvent une ligne valide à leur date ; confirmé sinon, et les autres conditions disent laquelle perd les RSS) ; la borne exclusive ou inclusive nourrit l'AM10 (c) de referentiels-pmsi-dans-cora
-- Oracle, schéma CORA_REC. RSS dont DATE_FIN va du 2018-01-01 au 2025-12-31 ; groupé : CODE_GHM renseigné et CODE_CMD différent de '90'. Date de valeur : TRUNC(TB_SYNTH_RSS.DATE_FIN) (fin du RSS). Colonnes de PMSI_LIB_GHS_TARIF d'après 20261015-catalogue-referentiels-resultat : GHS (GHM complet sur 6 caractères d'après DIM-code), CODE_GHS, CODE_GHM, DATE_DEBUT, DATE_FIN, PRIX. Toutes comparées après TRIM. Ligne valide à la date d : DATE_DEBUT <= d et DATE_FIN vide ou DATE_FIN > d (borne exclusive, valorisation.py) ; inclusive : DATE_FIN >= d (construire_referentiel_ghm.py). Les années avant celle du premier tarif de la table sortent naturellement sans tarif.
-- Les variantes : EXCL = GHM complet + période, borne exclusive (condition du claim) ; INCL = idem, borne inclusive ; SANS_DATE = GHM complet seul, sans période ; PAR_CODE_GHS = TRIM(CODE_GHS) du RSS = TRIM(CODE_GHS) du tarif, avec période exclusive ; PAR_CODE_GHM4 = TRIM(CODE_GHM) du RSS = TRIM(CODE_GHM) du tarif, avec période exclusive.
-- N_RSS ; N_GHS_9999 (TRIM(CODE_GHS) = '9999') ; N_SANS_TARIF_EXCL, N_SANS_TARIF_INCL, N_SANS_TARIF_SANS_DATE, N_SANS_TARIF_PAR_CODE_GHS, N_SANS_TARIF_PAR_CODE_GHM4 : RSS sans aucune ligne selon la variante ; N_SANS_TARIF_EXCL_HORS_9999 : parmi N_SANS_TARIF_EXCL, ceux dont le GHS n'est pas 9999 ; N_BORNE_DECIDE : sans ligne en EXCL mais une ligne en INCL (RSS dont la date de fin est la DATE_FIN d'une ligne) ; N_PLUSIEURS_EXCL et N_PLUSIEURS_INCL : RSS qui trouvent plus d'une ligne (périodes qui se chevauchent ou doublons).
-- PCT_AVEC_TARIF_EXCL = 100 × (N_RSS − N_SANS_TARIF_EXCL) / N_RSS, et PCT_AVEC_TARIF_EXCL_HORS_9999 sur les RSS hors GHS 9999, seulement si numérateur et dénominateur sont visibles.
-- Masquage : chaque effectif < 10 sort en <10. Suppression secondaire (règle 4) : N_RSS sort en « masqué » dès que N_RSS moins N_GHS_9999, N_SANS_TARIF_EXCL, N_SANS_TARIF_INCL, N_SANS_TARIF_PAR_CODE_GHS ou N_SANS_TARIF_PAR_CODE_GHM4 vaut de 1 à 9 ; N_SANS_TARIF_EXCL de même avec N_SANS_TARIF_EXCL_HORS_9999 et N_BORNE_DECIDE. Aucune ligne de total.
-- Performance : trois jointures de 1 à 2 millions de RSS sur environ 71 500 lignes de tarif, agrégées par RSS ; viser quelques minutes.
WITH tt AS (
  SELECT TRIM(GHS) AS GHM6, TRIM(CODE_GHS) AS GHS_NUM, TRIM(CODE_GHM) AS GHM4,
         TRUNC(DATE_DEBUT) AS DD, TRUNC(DATE_FIN) AS DF
  FROM CORA_REC.PMSI_LIB_GHS_TARIF
),
r AS (
  SELECT s.ID_RSS, EXTRACT(YEAR FROM s.DATE_FIN) AS ANNEE, TRUNC(s.DATE_FIN) AS D,
         TRIM(s.CODE_CMD) || TRIM(s.CODE_GHM) AS GHM6, TRIM(s.CODE_GHS) AS GHS_NUM, TRIM(s.CODE_GHM) AS GHM4
  FROM CORA_REC.TB_SYNTH_RSS s
  WHERE s.DATE_FIN >= DATE '2018-01-01' AND s.DATE_FIN < DATE '2026-01-01'
    AND TRIM(s.CODE_GHM) IS NOT NULL AND TRIM(s.CODE_CMD) <> '90'
),
ma AS (
  SELECT r.ID_RSS,
         COUNT(tt.GHM6) AS M_CLE,
         SUM(CASE WHEN tt.DD <= r.D AND (tt.DF IS NULL OR tt.DF > r.D) THEN 1 ELSE 0 END) AS M_EXCL,
         SUM(CASE WHEN tt.DD <= r.D AND (tt.DF IS NULL OR tt.DF >= r.D) THEN 1 ELSE 0 END) AS M_INCL
  FROM r
  LEFT JOIN tt ON tt.GHM6 = r.GHM6
  GROUP BY r.ID_RSS
),
mb AS (
  SELECT r.ID_RSS, COUNT(tt.GHM6) AS M_GHS
  FROM r
  LEFT JOIN tt ON tt.GHS_NUM = r.GHS_NUM AND tt.DD <= r.D AND (tt.DF IS NULL OR tt.DF > r.D)
  GROUP BY r.ID_RSS
),
mc AS (
  SELECT r.ID_RSS, COUNT(tt.GHM6) AS M_GHM4
  FROM r
  LEFT JOIN tt ON tt.GHM4 = r.GHM4 AND tt.DD <= r.D AND (tt.DF IS NULL OR tt.DF > r.D)
  GROUP BY r.ID_RSS
),
a AS (
  SELECT r.ANNEE,
         COUNT(*) AS N,
         SUM(CASE WHEN r.GHS_NUM = '9999' THEN 1 ELSE 0 END) AS C9,
         SUM(CASE WHEN ma.M_EXCL = 0 THEN 1 ELSE 0 END) AS S1,
         SUM(CASE WHEN ma.M_INCL = 0 THEN 1 ELSE 0 END) AS S2,
         SUM(CASE WHEN ma.M_CLE = 0 THEN 1 ELSE 0 END) AS S3,
         SUM(CASE WHEN mb.M_GHS = 0 THEN 1 ELSE 0 END) AS S4,
         SUM(CASE WHEN mc.M_GHM4 = 0 THEN 1 ELSE 0 END) AS S5,
         SUM(CASE WHEN ma.M_EXCL = 0 AND NVL(r.GHS_NUM, 'x') <> '9999' THEN 1 ELSE 0 END) AS S1H,
         SUM(CASE WHEN ma.M_EXCL = 0 AND ma.M_INCL > 0 THEN 1 ELSE 0 END) AS B,
         SUM(CASE WHEN ma.M_EXCL > 1 THEN 1 ELSE 0 END) AS P1,
         SUM(CASE WHEN ma.M_INCL > 1 THEN 1 ELSE 0 END) AS P2
  FROM r
  JOIN ma ON ma.ID_RSS = r.ID_RSS
  JOIN mb ON mb.ID_RSS = r.ID_RSS
  JOIN mc ON mc.ID_RSS = r.ID_RSS
  GROUP BY r.ANNEE
)
SELECT '20261019-tarif-ghs-couverture' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       ANNEE,
       CASE WHEN N < 10 THEN '<10'
            WHEN N - C9 BETWEEN 1 AND 9 OR N - S1 BETWEEN 1 AND 9 OR N - S2 BETWEEN 1 AND 9
              OR N - S4 BETWEEN 1 AND 9 OR N - S5 BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(N) END AS N_RSS,
       CASE WHEN C9 < 10 THEN '<10' ELSE TO_CHAR(C9) END AS N_GHS_9999,
       CASE WHEN S1 < 10 THEN '<10'
            WHEN S1 - S1H BETWEEN 1 AND 9 OR S1 - B BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(S1) END AS N_SANS_TARIF_EXCL,
       CASE WHEN S2 < 10 THEN '<10' ELSE TO_CHAR(S2) END AS N_SANS_TARIF_INCL,
       CASE WHEN S3 < 10 THEN '<10' ELSE TO_CHAR(S3) END AS N_SANS_TARIF_SANS_DATE,
       CASE WHEN S4 < 10 THEN '<10' ELSE TO_CHAR(S4) END AS N_SANS_TARIF_PAR_CODE_GHS,
       CASE WHEN S5 < 10 THEN '<10' ELSE TO_CHAR(S5) END AS N_SANS_TARIF_PAR_CODE_GHM4,
       CASE WHEN S1H < 10 THEN '<10' ELSE TO_CHAR(S1H) END AS N_SANS_TARIF_EXCL_HORS_9999,
       CASE WHEN B < 10 THEN '<10' ELSE TO_CHAR(B) END AS N_BORNE_DECIDE,
       CASE WHEN P1 < 10 THEN '<10' ELSE TO_CHAR(P1) END AS N_PLUSIEURS_EXCL,
       CASE WHEN P2 < 10 THEN '<10' ELSE TO_CHAR(P2) END AS N_PLUSIEURS_INCL,
       CASE WHEN N >= 10 AND S1 >= 10 AND N - C9 NOT BETWEEN 1 AND 9 AND N - S1 NOT BETWEEN 1 AND 9
                 AND N - S2 NOT BETWEEN 1 AND 9 AND N - S4 NOT BETWEEN 1 AND 9 AND N - S5 NOT BETWEEN 1 AND 9
                 AND S1 - S1H NOT BETWEEN 1 AND 9 AND S1 - B NOT BETWEEN 1 AND 9
            THEN TO_CHAR(ROUND(100 * (N - S1) / N, 2), 'FM990.00', 'NLS_NUMERIC_CHARACTERS=''. ''') END AS PCT_AVEC_TARIF_EXCL,
       CASE WHEN N - C9 >= 10 AND S1H >= 10 AND N - C9 NOT BETWEEN 1 AND 9 AND N - S1 NOT BETWEEN 1 AND 9
                 AND N - S2 NOT BETWEEN 1 AND 9 AND N - S4 NOT BETWEEN 1 AND 9 AND N - S5 NOT BETWEEN 1 AND 9
                 AND S1 - S1H NOT BETWEEN 1 AND 9 AND S1 - B NOT BETWEEN 1 AND 9
            THEN TO_CHAR(ROUND(100 * (N - C9 - S1H) / (N - C9), 2), 'FM990.00', 'NLS_NUMERIC_CHARACTERS=''. ''') END AS PCT_AVEC_TARIF_EXCL_HORS_9999
FROM a
ORDER BY ANNEE;
