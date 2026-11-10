-- id: 20261110-sejour-plusieurs-rss
-- system: cora
-- person_data: masked
-- purpose: étape 6 du plan (#133, enquête ghs-par-sejour) : dire pourquoi environ 3 900 séjours par an ont plusieurs RSS (20261110-pie-rss-sejour-resultat), en testant l'hypothèse d'un passage dans une unité hors MCO entre deux RSS (dictionnaire-cora-2020, TB_SYNTH_RSS) et celle des séances (un RSS par séance)
-- Oracle, schéma CORA_REC. Mêmes RSS et même année que 20261110-pie-rss-sejour : RSS groupés (CODE_GHM renseigné, CODE_CMD différent de '90') dont DATE_FIN va du 2022-01-01 au 2025-12-31 ; un séjour (ID_SEJOUR) en a plusieurs quand il en compte deux ou plus ; son année est celle de la plus grande DATE_FIN de ses RSS.
-- Paires : les RSS d'un séjour rangés par DATE_DEBUT ; une paire = un RSS et le suivant. ECART_J = TRUNC(DATE_DEBUT du suivant) − TRUNC(DATE_FIN du précédent), en jours : chevauchement (< 0), même jour (0), écart (>= 1).
-- Mouvement hors RSS dans l'intervalle : un mouvement du séjour (TB_MVT.ID_SEJOUR) absent de TB_MVT_RUM, dont le jour de début (DATE_DEBUT_MVT) va du jour de fin du RSS précédent au jour de début du suivant. Son unité : TB_UNITE joint par TRIM(CODE_UNITE) = TRIM(TB_MVT.ID_UNITE_M) (joindre-uf-par-code), drapeaux SSR, PSY, HAD, URGENCE, UHCD, EXTERNE, GESTION_PMSI à 'O' (dictionnaire-cora-2020, TB_UNITE ; drapeaux-cora-valeurs-propres). Un séjour compte dans chaque drapeau qu'a l'un de ses mouvements : les colonnes de drapeaux se recouvrent. N_SEJ_HORS_SANS_DRAPEAU : aucun drapeau, ou UF introuvable.
-- Séances : RSS de CMD 28. N_SEJ_AVEC_SEANCE : au moins un RSS de séance ; N_SEJ_TOUT_SEANCE : tous ses RSS en sont.
-- Colonnes : N_SEJ ; N_SEJ_2_RSS, N_SEJ_3_RSS_PLUS ; N_PAIRES, N_PAIRES_CHEVAUCHE, N_PAIRES_MEME_JOUR, N_PAIRES_ECART ; N_SEJ_MVT_HORS_RSS, puis N_SEJ_HORS_<drapeau> ; N_SEJ_AVEC_SEANCE, N_SEJ_TOUT_SEANCE.
-- Masquage : tout effectif < 10 sort en <10. Suppression secondaire (règle 4) : N_SEJ_2_RSS et N_SEJ_3_RSS_PLUS font N_SEJ : si l'un vaut de 1 à 9, l'autre sort en « masqué » ; les trois sortes de paires font N_PAIRES : si l'une vaut de 1 à 9, N_PAIRES sort en « masqué », et de même si N_PAIRES − N_SEJ vaut de 1 à 9 ; chaque colonne N_SEJ_HORS_… sort en « masqué » si son écart à N_SEJ ou à N_SEJ_MVT_HORS_RSS vaut de 1 à 9, N_SEJ_MVT_HORS_RSS si son écart à N_SEJ vaut de 1 à 9 ; N_SEJ_AVEC_SEANCE et N_SEJ_TOUT_SEANCE si leur écart entre eux ou à N_SEJ vaut de 1 à 9. Aucune ligne de total.
WITH r AS (
  SELECT s.ID_RSS, s.ID_SEJOUR, s.DATE_DEBUT, s.DATE_FIN,
         CASE WHEN TRIM(s.CODE_CMD) = '28' THEN 1 ELSE 0 END AS SEANCE
  FROM CORA_REC.TB_SYNTH_RSS s
  WHERE s.DATE_FIN >= DATE '2022-01-01' AND s.DATE_FIN < DATE '2026-01-01'
    AND TRIM(s.CODE_GHM) IS NOT NULL AND TRIM(s.CODE_CMD) <> '90'
),
multi AS (
  SELECT ID_SEJOUR, EXTRACT(YEAR FROM MAX(DATE_FIN)) AS ANNEE, COUNT(*) AS NB_RSS,
         MAX(SEANCE) AS AVEC_SEANCE, MIN(SEANCE) AS TOUT_SEANCE
  FROM r
  GROUP BY ID_SEJOUR
  HAVING COUNT(*) >= 2
),
ord AS (
  SELECT r.ID_SEJOUR, r.DATE_FIN,
         LEAD(r.DATE_DEBUT) OVER (PARTITION BY r.ID_SEJOUR ORDER BY r.DATE_DEBUT, r.DATE_FIN, r.ID_RSS) AS DEB_SUIV
  FROM r
  JOIN multi m ON m.ID_SEJOUR = r.ID_SEJOUR
),
paires AS (
  SELECT ID_SEJOUR, DATE_FIN AS FIN_PREC, DEB_SUIV,
         TRUNC(DEB_SUIV) - TRUNC(DATE_FIN) AS ECART_J
  FROM ord
  WHERE DEB_SUIV IS NOT NULL
),
mvt_hors AS (
  SELECT DISTINCT p.ID_SEJOUR, mv.ID_MVT, TRIM(mv.ID_UNITE_M) AS UF
  FROM paires p
  JOIN CORA_REC.TB_MVT mv ON mv.ID_SEJOUR = p.ID_SEJOUR
  WHERE TRUNC(mv.DATE_DEBUT_MVT) >= TRUNC(p.FIN_PREC)
    AND TRUNC(mv.DATE_DEBUT_MVT) <= TRUNC(p.DEB_SUIV)
    AND NOT EXISTS (SELECT 1 FROM CORA_REC.TB_MVT_RUM mr WHERE mr.ID_MVT = mv.ID_MVT)
),
drap AS (
  SELECT h.ID_SEJOUR,
         MAX(CASE WHEN TRIM(u.SSR) = 'O' THEN 1 ELSE 0 END) AS D_SSR,
         MAX(CASE WHEN TRIM(u.PSY) = 'O' THEN 1 ELSE 0 END) AS D_PSY,
         MAX(CASE WHEN TRIM(u.HAD) = 'O' THEN 1 ELSE 0 END) AS D_HAD,
         MAX(CASE WHEN TRIM(u.URGENCE) = 'O' THEN 1 ELSE 0 END) AS D_URG,
         MAX(CASE WHEN TRIM(u.UHCD) = 'O' THEN 1 ELSE 0 END) AS D_UHCD,
         MAX(CASE WHEN TRIM(u.EXTERNE) = 'O' THEN 1 ELSE 0 END) AS D_EXT,
         MAX(CASE WHEN TRIM(u.GESTION_PMSI) = 'O' THEN 1 ELSE 0 END) AS D_MCO,
         MAX(CASE WHEN u.CODE_UNITE IS NULL
                    OR NOT (TRIM(u.SSR) = 'O' OR TRIM(u.PSY) = 'O' OR TRIM(u.HAD) = 'O' OR TRIM(u.URGENCE) = 'O'
                            OR TRIM(u.UHCD) = 'O' OR TRIM(u.EXTERNE) = 'O' OR TRIM(u.GESTION_PMSI) = 'O')
                  THEN 1 ELSE 0 END) AS D_AUCUN
  FROM mvt_hors h
  LEFT JOIN CORA_REC.TB_UNITE u ON TRIM(u.CODE_UNITE) = h.UF
  GROUP BY h.ID_SEJOUR
),
agg_s AS (
  SELECT m.ANNEE,
         COUNT(*) AS N_SEJ,
         SUM(CASE WHEN m.NB_RSS = 2 THEN 1 ELSE 0 END) AS N2,
         SUM(CASE WHEN m.NB_RSS >= 3 THEN 1 ELSE 0 END) AS N3,
         SUM(CASE WHEN d.ID_SEJOUR IS NOT NULL THEN 1 ELSE 0 END) AS NH,
         SUM(NVL(d.D_SSR, 0)) AS H_SSR, SUM(NVL(d.D_PSY, 0)) AS H_PSY, SUM(NVL(d.D_HAD, 0)) AS H_HAD,
         SUM(NVL(d.D_URG, 0)) AS H_URG, SUM(NVL(d.D_UHCD, 0)) AS H_UHCD, SUM(NVL(d.D_EXT, 0)) AS H_EXT,
         SUM(NVL(d.D_MCO, 0)) AS H_MCO, SUM(NVL(d.D_AUCUN, 0)) AS H_AUCUN,
         SUM(m.AVEC_SEANCE) AS SA, SUM(m.TOUT_SEANCE) AS ST
  FROM multi m
  LEFT JOIN drap d ON d.ID_SEJOUR = m.ID_SEJOUR
  GROUP BY m.ANNEE
),
agg_p AS (
  SELECT m.ANNEE,
         COUNT(*) AS NP,
         SUM(CASE WHEN p.ECART_J < 0 THEN 1 ELSE 0 END) AS P_CHEV,
         SUM(CASE WHEN p.ECART_J = 0 THEN 1 ELSE 0 END) AS P_JOUR,
         SUM(CASE WHEN p.ECART_J >= 1 THEN 1 ELSE 0 END) AS P_ECART
  FROM paires p
  JOIN multi m ON m.ID_SEJOUR = p.ID_SEJOUR
  GROUP BY m.ANNEE
),
t AS (
  SELECT s.*, p.NP, p.P_CHEV, p.P_JOUR, p.P_ECART
  FROM agg_s s
  JOIN agg_p p ON p.ANNEE = s.ANNEE
)
SELECT '20261110-sejour-plusieurs-rss' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       ANNEE,
       CASE WHEN N_SEJ < 10 THEN '<10' ELSE TO_CHAR(N_SEJ) END AS N_SEJ,
       CASE WHEN N2 < 10 THEN '<10' WHEN N3 BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(N2) END AS N_SEJ_2_RSS,
       CASE WHEN N3 < 10 THEN '<10' WHEN N2 BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(N3) END AS N_SEJ_3_RSS_PLUS,
       CASE WHEN NP < 10 THEN '<10'
            WHEN P_CHEV BETWEEN 1 AND 9 OR P_JOUR BETWEEN 1 AND 9 OR P_ECART BETWEEN 1 AND 9
              OR NP - N_SEJ BETWEEN 1 AND 9 THEN 'masqué'
            ELSE TO_CHAR(NP) END AS N_PAIRES,
       CASE WHEN P_CHEV < 10 THEN '<10' ELSE TO_CHAR(P_CHEV) END AS N_PAIRES_CHEVAUCHE,
       CASE WHEN P_JOUR < 10 THEN '<10' ELSE TO_CHAR(P_JOUR) END AS N_PAIRES_MEME_JOUR,
       CASE WHEN P_ECART < 10 THEN '<10' ELSE TO_CHAR(P_ECART) END AS N_PAIRES_ECART,
       CASE WHEN NH < 10 THEN '<10' WHEN N_SEJ - NH BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(NH) END AS N_SEJ_MVT_HORS_RSS,
       CASE WHEN H_SSR < 10 THEN '<10' WHEN N_SEJ - H_SSR BETWEEN 1 AND 9 OR NH - H_SSR BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(H_SSR) END AS N_SEJ_HORS_SSR,
       CASE WHEN H_PSY < 10 THEN '<10' WHEN N_SEJ - H_PSY BETWEEN 1 AND 9 OR NH - H_PSY BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(H_PSY) END AS N_SEJ_HORS_PSY,
       CASE WHEN H_HAD < 10 THEN '<10' WHEN N_SEJ - H_HAD BETWEEN 1 AND 9 OR NH - H_HAD BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(H_HAD) END AS N_SEJ_HORS_HAD,
       CASE WHEN H_URG < 10 THEN '<10' WHEN N_SEJ - H_URG BETWEEN 1 AND 9 OR NH - H_URG BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(H_URG) END AS N_SEJ_HORS_URGENCE,
       CASE WHEN H_UHCD < 10 THEN '<10' WHEN N_SEJ - H_UHCD BETWEEN 1 AND 9 OR NH - H_UHCD BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(H_UHCD) END AS N_SEJ_HORS_UHCD,
       CASE WHEN H_EXT < 10 THEN '<10' WHEN N_SEJ - H_EXT BETWEEN 1 AND 9 OR NH - H_EXT BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(H_EXT) END AS N_SEJ_HORS_EXTERNE,
       CASE WHEN H_MCO < 10 THEN '<10' WHEN N_SEJ - H_MCO BETWEEN 1 AND 9 OR NH - H_MCO BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(H_MCO) END AS N_SEJ_HORS_GESTION_PMSI,
       CASE WHEN H_AUCUN < 10 THEN '<10' WHEN N_SEJ - H_AUCUN BETWEEN 1 AND 9 OR NH - H_AUCUN BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(H_AUCUN) END AS N_SEJ_HORS_SANS_DRAPEAU,
       CASE WHEN SA < 10 THEN '<10' WHEN N_SEJ - SA BETWEEN 1 AND 9 OR SA - ST BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(SA) END AS N_SEJ_AVEC_SEANCE,
       CASE WHEN ST < 10 THEN '<10' WHEN N_SEJ - ST BETWEEN 1 AND 9 OR SA - ST BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(ST) END AS N_SEJ_TOUT_SEANCE
FROM t
ORDER BY ANNEE;
