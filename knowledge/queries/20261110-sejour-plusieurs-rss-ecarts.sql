-- id: 20261110-sejour-plusieurs-rss-ecarts
-- system: cora
-- person_data: masked
-- purpose: étape 6 du plan (#133, enquête ghs-par-sejour), suite de 20261110-sejour-plusieurs-rss-type-resultat : tester l'hypothèse de Francesco, l'hospitalisation de semaine (le patient rentre chez lui le week-end, revient en début de semaine sous le même numéro de séjour ; une absence de plus de 48 heures clôt le RUM, guide MCO 2026, chapitre I, « permission »), pour les séjours à plusieurs RSS sans séance
-- Oracle, schéma CORA_REC. Mêmes RSS et mêmes séjours que 20261110-sejour-plusieurs-rss-type : RSS groupés (CODE_GHM renseigné, CODE_CMD différent de '90'), DATE_FIN du 2022-01-01 au 2025-12-31 ; séjours (ID_SEJOUR) à deux RSS ou plus, dont aucun RSS n'est une séance (CMD 28) ; année du séjour = celle de la plus grande DATE_FIN de ses RSS.
-- Paires : un RSS et le suivant du même séjour, rangés par DATE_DEBUT. ECART_J = TRUNC(DATE_DEBUT du suivant) − TRUNC(DATE_FIN du précédent), en jours. Jour de la semaine lu par TO_CHAR(date, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH'), indépendant des réglages de la session.
-- Colonnes, par année : N_PAIRES ; par écart : N_ECART_0, N_ECART_1, N_ECART_2, N_ECART_3, N_ECART_4_7, N_ECART_8_30, N_ECART_31_PLUS ; N_SORTIE_VEN_SAM : le RSS précédent finit un vendredi ou un samedi ; N_RETOUR_DIM_LUN : le suivant commence un dimanche ou un lundi ; N_WEEKEND : les deux à la fois, avec un écart de 1 à 3 jours (le motif d'une hospitalisation de semaine) ; N_DUREE_PREC_1_5 : le RSS précédent dure de 1 à 5 nuits.
-- Masquage : tout effectif < 10 sort en <10. Suppression secondaire (règle 4) : les sept classes d'écart font N_PAIRES : si l'une vaut de 1 à 9, N_PAIRES sort en « masqué » ; N_SORTIE_VEN_SAM, N_RETOUR_DIM_LUN, N_DUREE_PREC_1_5 sortent en « masqué » si leur écart à N_PAIRES vaut de 1 à 9 ; N_WEEKEND si son écart à N_PAIRES, à N_SORTIE_VEN_SAM ou à N_RETOUR_DIM_LUN vaut de 1 à 9. Aucune ligne de total.
WITH r AS (
  SELECT s.ID_RSS, s.ID_SEJOUR, s.DATE_DEBUT, s.DATE_FIN,
         CASE WHEN TRIM(s.CODE_CMD) = '28' THEN 1 ELSE 0 END AS SEANCE
  FROM CORA_REC.TB_SYNTH_RSS s
  WHERE s.DATE_FIN >= DATE '2022-01-01' AND s.DATE_FIN < DATE '2026-01-01'
    AND TRIM(s.CODE_GHM) IS NOT NULL AND TRIM(s.CODE_CMD) <> '90'
),
multi AS (
  SELECT ID_SEJOUR, EXTRACT(YEAR FROM MAX(DATE_FIN)) AS ANNEE
  FROM r
  GROUP BY ID_SEJOUR
  HAVING COUNT(*) >= 2 AND MAX(SEANCE) = 0
),
ord AS (
  SELECT r.ID_SEJOUR, m.ANNEE, r.DATE_DEBUT, r.DATE_FIN,
         LEAD(r.DATE_DEBUT) OVER (PARTITION BY r.ID_SEJOUR ORDER BY r.DATE_DEBUT, r.DATE_FIN, r.ID_RSS) AS DEB_SUIV
  FROM r
  JOIN multi m ON m.ID_SEJOUR = r.ID_SEJOUR
),
p AS (
  SELECT ANNEE,
         TRUNC(DEB_SUIV) - TRUNC(DATE_FIN) AS ECART_J,
         TRUNC(DATE_FIN) - TRUNC(DATE_DEBUT) AS NUITS_PREC,
         TO_CHAR(DATE_FIN, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH') AS JOUR_FIN,
         TO_CHAR(DEB_SUIV, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH') AS JOUR_RETOUR
  FROM ord
  WHERE DEB_SUIV IS NOT NULL
),
a AS (
  SELECT ANNEE,
         COUNT(*) AS NP,
         SUM(CASE WHEN ECART_J <= 0 THEN 1 ELSE 0 END) AS E0,
         SUM(CASE WHEN ECART_J = 1 THEN 1 ELSE 0 END) AS E1,
         SUM(CASE WHEN ECART_J = 2 THEN 1 ELSE 0 END) AS E2,
         SUM(CASE WHEN ECART_J = 3 THEN 1 ELSE 0 END) AS E3,
         SUM(CASE WHEN ECART_J BETWEEN 4 AND 7 THEN 1 ELSE 0 END) AS E4,
         SUM(CASE WHEN ECART_J BETWEEN 8 AND 30 THEN 1 ELSE 0 END) AS E8,
         SUM(CASE WHEN ECART_J >= 31 THEN 1 ELSE 0 END) AS E31,
         SUM(CASE WHEN JOUR_FIN IN ('FRI', 'SAT') THEN 1 ELSE 0 END) AS VS,
         SUM(CASE WHEN JOUR_RETOUR IN ('SUN', 'MON') THEN 1 ELSE 0 END) AS DL,
         SUM(CASE WHEN JOUR_FIN IN ('FRI', 'SAT') AND JOUR_RETOUR IN ('SUN', 'MON')
                   AND ECART_J BETWEEN 1 AND 3 THEN 1 ELSE 0 END) AS WE,
         SUM(CASE WHEN NUITS_PREC BETWEEN 1 AND 5 THEN 1 ELSE 0 END) AS D15
  FROM p
  GROUP BY ANNEE
)
SELECT '20261110-sejour-plusieurs-rss-ecarts' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       ANNEE,
       CASE WHEN NP < 10 THEN '<10'
            WHEN E0 BETWEEN 1 AND 9 OR E1 BETWEEN 1 AND 9 OR E2 BETWEEN 1 AND 9 OR E3 BETWEEN 1 AND 9
              OR E4 BETWEEN 1 AND 9 OR E8 BETWEEN 1 AND 9 OR E31 BETWEEN 1 AND 9 THEN 'masqué'
            ELSE TO_CHAR(NP) END AS N_PAIRES,
       CASE WHEN E0 < 10 THEN '<10' ELSE TO_CHAR(E0) END AS N_ECART_0,
       CASE WHEN E1 < 10 THEN '<10' ELSE TO_CHAR(E1) END AS N_ECART_1,
       CASE WHEN E2 < 10 THEN '<10' ELSE TO_CHAR(E2) END AS N_ECART_2,
       CASE WHEN E3 < 10 THEN '<10' ELSE TO_CHAR(E3) END AS N_ECART_3,
       CASE WHEN E4 < 10 THEN '<10' ELSE TO_CHAR(E4) END AS N_ECART_4_7,
       CASE WHEN E8 < 10 THEN '<10' ELSE TO_CHAR(E8) END AS N_ECART_8_30,
       CASE WHEN E31 < 10 THEN '<10' ELSE TO_CHAR(E31) END AS N_ECART_31_PLUS,
       CASE WHEN VS < 10 THEN '<10' WHEN NP - VS BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(VS) END AS N_SORTIE_VEN_SAM,
       CASE WHEN DL < 10 THEN '<10' WHEN NP - DL BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(DL) END AS N_RETOUR_DIM_LUN,
       CASE WHEN WE < 10 THEN '<10'
            WHEN NP - WE BETWEEN 1 AND 9 OR VS - WE BETWEEN 1 AND 9 OR DL - WE BETWEEN 1 AND 9 THEN 'masqué'
            ELSE TO_CHAR(WE) END AS N_WEEKEND,
       CASE WHEN D15 < 10 THEN '<10' WHEN NP - D15 BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(D15) END AS N_DUREE_PREC_1_5
FROM a
ORDER BY ANNEE;
