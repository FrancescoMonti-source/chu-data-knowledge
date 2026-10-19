-- id: 20261019-tarif-ghs-couverture-2
-- system: cora
-- person_data: masked
-- purpose: par année de fin de RSS (2022 à aujourd'hui), mesurer la part de RSS groupés qui ne trouvent aucune ligne de CORA_REC.PMSI_LIB_GHS_TARIF selon la condition de jointure (GHM complet CODE_CMD || CODE_GHM contre TRIM(GHS) avec période de validité, borne DATE_FIN exclusive ou inclusive, sans la période, par CODE_GHS), pour trancher tarif-ghs-jointure-couverture (réfuté si, pour une année, plus de 95 % des RSS MCO groupés trouvent une ligne valide à leur date ; confirmé sinon, et les autres conditions disent laquelle perd les RSS) ; la borne exclusive ou inclusive nourrit l'AM10 (c) de referentiels-pmsi-dans-cora
-- Nouvelle version de 20261019-tarif-ghs-couverture, arrêtée par le délai de 900 s. Allègements : (1) les RSS sont d'abord regroupés par (année, date de fin, GHM complet, GHS) avant toute jointure, la jointure porte sur ces groupes et non sur chaque RSS, et les effectifs sont repondérés par le nombre de RSS du groupe ; (2) la table de tarif est lue une fois, déjà nettoyée (TRIM, TRUNC) ; (3) la période va de 2022-01-01 à aujourd'hui au lieu de 2018 ; (4) la variante par CODE_GHM seul (4 caractères, la moins sélective, partagée entre CMD) est retirée ; elle ne tranchait pas le claim.
-- Oracle 11g, schéma CORA_REC. RSS dont DATE_FIN va du 2022-01-01 à aujourd'hui ; groupé : CODE_GHM renseigné et CODE_CMD différent de '90'. Date de valeur : TRUNC(TB_SYNTH_RSS.DATE_FIN) (fin du RSS). Colonnes de PMSI_LIB_GHS_TARIF d'après 20261015-catalogue-referentiels-resultat : GHS (GHM complet sur 6 caractères), CODE_GHS, DATE_DEBUT, DATE_FIN, PRIX. Toutes comparées après TRIM. Ligne valide à la date d : DATE_DEBUT <= d et DATE_FIN vide ou DATE_FIN > d (borne exclusive, valorisation.py) ; inclusive : DATE_FIN >= d (construire_referentiel_ghm.py).
-- Les variantes : EXCL = GHM complet + période, borne exclusive (condition du claim) ; INCL = idem, borne inclusive ; SANS_DATE = GHM complet seul, sans période ; PAR_CODE_GHS = TRIM(CODE_GHS) du RSS = TRIM(CODE_GHS) du tarif, avec période exclusive.
-- N_RSS ; N_GHS_9999 (TRIM(CODE_GHS) = '9999') ; N_SANS_TARIF_EXCL, N_SANS_TARIF_INCL, N_SANS_TARIF_SANS_DATE, N_SANS_TARIF_PAR_CODE_GHS : RSS sans aucune ligne selon la variante ; N_SANS_TARIF_EXCL_HORS_9999 : parmi N_SANS_TARIF_EXCL, ceux dont le GHS n'est pas 9999 ; N_BORNE_DECIDE : sans ligne en EXCL mais une ligne en INCL ; N_PLUSIEURS_EXCL et N_PLUSIEURS_INCL : RSS qui trouvent plus d'une ligne (périodes qui se chevauchent ou doublons).
-- PCT_AVEC_TARIF_EXCL = 100 x (N_RSS - N_SANS_TARIF_EXCL) / N_RSS, et PCT_AVEC_TARIF_EXCL_HORS_9999 sur les RSS hors GHS 9999, seulement si numérateur et dénominateur sont visibles.
-- Masquage : chaque effectif < 10 sort en <10. Suppression secondaire (règle 4) : N_RSS sort en « masqué » dès que N_RSS moins N_GHS_9999, N_SANS_TARIF_EXCL, N_SANS_TARIF_INCL ou N_SANS_TARIF_PAR_CODE_GHS vaut de 1 à 9 ; N_SANS_TARIF_EXCL de même avec N_SANS_TARIF_EXCL_HORS_9999 et N_BORNE_DECIDE. Aucune ligne de total.
-- Performance : environ 800 000 RSS réduits à quelques centaines de milliers de groupes, joints à environ 71 500 lignes de tarif ; viser moins de 2 minutes.
WITH tt AS (
  SELECT /*+ MATERIALIZE */ TRIM(GHS) AS GHM6, TRIM(CODE_GHS) AS GHS_NUM,
         TRUNC(DATE_DEBUT) AS DD, TRUNC(DATE_FIN) AS DF
  FROM CORA_REC.PMSI_LIB_GHS_TARIF
),
g0 AS (
  SELECT EXTRACT(YEAR FROM s.DATE_FIN) AS ANNEE, TRUNC(s.DATE_FIN) AS D,
         TRIM(s.CODE_CMD) || TRIM(s.CODE_GHM) AS GHM6, TRIM(s.CODE_GHS) AS GHS_NUM,
         COUNT(*) AS N
  FROM CORA_REC.TB_SYNTH_RSS s
  WHERE s.DATE_FIN >= DATE '2022-01-01' AND s.DATE_FIN < TRUNC(SYSDATE) + 1
    AND TRIM(s.CODE_GHM) IS NOT NULL AND TRIM(s.CODE_CMD) <> '90'
  GROUP BY EXTRACT(YEAR FROM s.DATE_FIN), TRUNC(s.DATE_FIN),
           TRIM(s.CODE_CMD) || TRIM(s.CODE_GHM), TRIM(s.CODE_GHS)
),
g AS (
  SELECT g0.ANNEE, g0.D, g0.GHM6, g0.GHS_NUM, g0.N,
         ROW_NUMBER() OVER (ORDER BY g0.ANNEE, g0.D, g0.GHM6, g0.GHS_NUM) AS GID
  FROM g0
),
ma AS (
  SELECT g.GID,
         COUNT(tt.GHM6) AS M_CLE,
         SUM(CASE WHEN tt.DD <= g.D AND (tt.DF IS NULL OR tt.DF > g.D) THEN 1 ELSE 0 END) AS M_EXCL,
         SUM(CASE WHEN tt.DD <= g.D AND (tt.DF IS NULL OR tt.DF >= g.D) THEN 1 ELSE 0 END) AS M_INCL
  FROM g
  LEFT JOIN tt ON tt.GHM6 = g.GHM6
  GROUP BY g.GID
),
mb AS (
  SELECT g.GID, COUNT(tt.GHM6) AS M_GHS
  FROM g
  LEFT JOIN tt ON tt.GHS_NUM = g.GHS_NUM AND tt.DD <= g.D AND (tt.DF IS NULL OR tt.DF > g.D)
  GROUP BY g.GID
),
a AS (
  SELECT g.ANNEE,
         SUM(g.N) AS N,
         SUM(CASE WHEN g.GHS_NUM = '9999' THEN g.N ELSE 0 END) AS C9,
         SUM(CASE WHEN ma.M_EXCL = 0 THEN g.N ELSE 0 END) AS S1,
         SUM(CASE WHEN ma.M_INCL = 0 THEN g.N ELSE 0 END) AS S2,
         SUM(CASE WHEN ma.M_CLE = 0 THEN g.N ELSE 0 END) AS S3,
         SUM(CASE WHEN mb.M_GHS = 0 THEN g.N ELSE 0 END) AS S4,
         SUM(CASE WHEN ma.M_EXCL = 0 AND NVL(g.GHS_NUM, 'x') <> '9999' THEN g.N ELSE 0 END) AS S1H,
         SUM(CASE WHEN ma.M_EXCL = 0 AND ma.M_INCL > 0 THEN g.N ELSE 0 END) AS B,
         SUM(CASE WHEN ma.M_EXCL > 1 THEN g.N ELSE 0 END) AS P1,
         SUM(CASE WHEN ma.M_INCL > 1 THEN g.N ELSE 0 END) AS P2
  FROM g
  JOIN ma ON ma.GID = g.GID
  JOIN mb ON mb.GID = g.GID
  GROUP BY g.ANNEE
)
SELECT '20261019-tarif-ghs-couverture-2' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       ANNEE,
       CASE WHEN N < 10 THEN '<10'
            WHEN N - C9 BETWEEN 1 AND 9 OR N - S1 BETWEEN 1 AND 9 OR N - S2 BETWEEN 1 AND 9
              OR N - S4 BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(N) END AS N_RSS,
       CASE WHEN C9 < 10 THEN '<10' ELSE TO_CHAR(C9) END AS N_GHS_9999,
       CASE WHEN S1 < 10 THEN '<10'
            WHEN S1 - S1H BETWEEN 1 AND 9 OR S1 - B BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(S1) END AS N_SANS_TARIF_EXCL,
       CASE WHEN S2 < 10 THEN '<10' ELSE TO_CHAR(S2) END AS N_SANS_TARIF_INCL,
       CASE WHEN S3 < 10 THEN '<10' ELSE TO_CHAR(S3) END AS N_SANS_TARIF_SANS_DATE,
       CASE WHEN S4 < 10 THEN '<10' ELSE TO_CHAR(S4) END AS N_SANS_TARIF_PAR_CODE_GHS,
       CASE WHEN S1H < 10 THEN '<10' ELSE TO_CHAR(S1H) END AS N_SANS_TARIF_EXCL_HORS_9999,
       CASE WHEN B < 10 THEN '<10' ELSE TO_CHAR(B) END AS N_BORNE_DECIDE,
       CASE WHEN P1 < 10 THEN '<10' ELSE TO_CHAR(P1) END AS N_PLUSIEURS_EXCL,
       CASE WHEN P2 < 10 THEN '<10' ELSE TO_CHAR(P2) END AS N_PLUSIEURS_INCL,
       CASE WHEN N >= 10 AND S1 >= 10 AND N - C9 NOT BETWEEN 1 AND 9 AND N - S1 NOT BETWEEN 1 AND 9
                 AND N - S2 NOT BETWEEN 1 AND 9 AND N - S4 NOT BETWEEN 1 AND 9
                 AND S1 - S1H NOT BETWEEN 1 AND 9 AND S1 - B NOT BETWEEN 1 AND 9
            THEN TO_CHAR(ROUND(100 * (N - S1) / N, 2), 'FM990.00', 'NLS_NUMERIC_CHARACTERS=''. ''') END AS PCT_AVEC_TARIF_EXCL,
       CASE WHEN N - C9 >= 10 AND S1H >= 10 AND N - C9 NOT BETWEEN 1 AND 9 AND N - S1 NOT BETWEEN 1 AND 9
                 AND N - S2 NOT BETWEEN 1 AND 9 AND N - S4 NOT BETWEEN 1 AND 9
                 AND S1 - S1H NOT BETWEEN 1 AND 9 AND S1 - B NOT BETWEEN 1 AND 9
            THEN TO_CHAR(ROUND(100 * (N - C9 - S1H) / (N - C9), 2), 'FM990.00', 'NLS_NUMERIC_CHARACTERS=''. ''') END AS PCT_AVEC_TARIF_EXCL_HORS_9999
FROM a
ORDER BY ANNEE;
