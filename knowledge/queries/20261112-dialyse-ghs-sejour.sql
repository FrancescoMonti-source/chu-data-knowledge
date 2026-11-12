-- id: 20261112-dialyse-ghs-sejour
-- system: cora
-- person_data: masked
-- purpose: pour les séances d'hémodialyse (GHM 28Z04Z) de 2022 à 2025, comparer le GHS (9605 en centre, 9617 en centre pour enfants, arrêté « forfaits » art. 6, 7°) à l'âge et à l'UF 5624, et compter les NO_SEJOUR à côté des RSS, pour expliquer l'écart avec un comptage par GHS 9617 et par NO_SEJOUR (étape 2 du plan revu, #135)
-- Oracle, schéma CORA_REC. Mêmes définitions que 20261112-dialyse-pediatrique : RSS de TB_SYNTH_RSS finis de 2022 à 2025 (DATE_FIN) ; âge FLOOR((DATE_DEBUT − DATE_NAIS) / 365.25) ; « UF 5624 » si un RUM du RSS est hébergé par l'UF 5624 (TB_SYNTH_RUM.ID_UNITE_HEBERG → TB_UNITE.ID_UNITE). Séjour : TB_SYNTH_RSS.ID_SEJOUR → TB_SEJOUR.NO_SEJOUR.
-- N_PATIENTS : patients distincts ; N_SEJOURS : NO_SEJOUR distincts ; N_RSS : RSS ; NB_SEANCES : somme de NB_SEANCES.
-- Masquage : si N_PATIENTS < 10, toute la ligne sort en <10. Dans une ligne visible, un effectif dont l'écart à un autre effectif de la ligne vaut de 1 à 9 sort en « masqué » (événements contre entités distinctes).
-- Suppression secondaire entre résultats : 20261112-dialyse-pediatrique-resultat donne déjà le total de chaque groupe (année, âge, UF) tous GHS confondus ; si un groupe a une ligne <10, sa plus grande ligne sort aussi en « masqué ». Aucune ligne de total.
WITH r AS (
  SELECT EXTRACT(YEAR FROM x.DATE_FIN) AS ANNEE,
         NVL(TRIM(x.CODE_GHS), '(vide)') AS GHS,
         s.ID_PATIENT, s.NO_SEJOUR,
         CASE WHEN s.ID_PATIENT IS NULL THEN '4 sans patient'
              WHEN pa.DATE_NAIS IS NULL THEN '3 naissance absente'
              WHEN FLOOR((x.DATE_DEBUT - pa.DATE_NAIS) / 365.25) < 18 THEN '1 moins de 18 ans'
              ELSE '2 18 ans ou plus' END AS AGE,
         CASE WHEN EXISTS (SELECT 1 FROM CORA_REC.TB_SYNTH_RUM ru
                           JOIN CORA_REC.TB_UNITE u ON u.ID_UNITE = ru.ID_UNITE_HEBERG
                           WHERE ru.ID_RSS = x.ID_RSS AND TRIM(u.CODE_UNITE) = '5624')
              THEN 'UF 5624' ELSE 'autre UF' END AS UNITE,
         NVL(x.NB_SEANCES, 0) AS SEANCES
  FROM CORA_REC.TB_SYNTH_RSS x
  LEFT JOIN CORA_REC.TB_SEJOUR s ON s.ID_SEJOUR = x.ID_SEJOUR
  LEFT JOIN CORA_REC.TB_PATIENT pa ON pa.ID_PATIENT = s.ID_PATIENT
  WHERE x.DATE_FIN >= DATE '2022-01-01' AND x.DATE_FIN < DATE '2026-01-01'
    AND TRIM(x.CODE_CMD) = '28' AND TRIM(x.CODE_GHM) = 'Z04Z'
),
t AS (
  SELECT ANNEE, AGE, UNITE, GHS,
         COUNT(DISTINCT ID_PATIENT) AS P,
         COUNT(DISTINCT NO_SEJOUR) AS J,
         COUNT(*) AS R,
         SUM(SEANCES) AS S
  FROM r
  GROUP BY ANNEE, AGE, UNITE, GHS
),
m AS (
  SELECT ANNEE, AGE, UNITE, GHS, P, J, R, S,
         MAX(CASE WHEN P < 10 THEN 1 ELSE 0 END) OVER (PARTITION BY ANNEE, AGE, UNITE) AS GROUPE_MASQUE,
         ROW_NUMBER() OVER (PARTITION BY ANNEE, AGE, UNITE ORDER BY R DESC, GHS) AS RANG
  FROM t
)
SELECT '20261112-dialyse-ghs-sejour' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       ANNEE, AGE, UNITE, GHS,
       CASE WHEN P < 10 THEN '<10'
            WHEN GROUPE_MASQUE = 1 AND RANG = 1 THEN 'masqué'
            ELSE TO_CHAR(P) END AS N_PATIENTS,
       CASE WHEN P < 10 THEN '<10'
            WHEN GROUPE_MASQUE = 1 AND RANG = 1 THEN 'masqué'
            WHEN J - P BETWEEN 1 AND 9 OR R - J BETWEEN 1 AND 9 OR ABS(S - J) BETWEEN 1 AND 9 THEN 'masqué'
            ELSE TO_CHAR(J) END AS N_SEJOURS,
       CASE WHEN P < 10 THEN '<10'
            WHEN GROUPE_MASQUE = 1 AND RANG = 1 THEN 'masqué'
            WHEN R - P BETWEEN 1 AND 9 OR ABS(S - R) BETWEEN 1 AND 9 THEN 'masqué'
            ELSE TO_CHAR(R) END AS N_RSS,
       CASE WHEN P < 10 THEN '<10'
            WHEN GROUPE_MASQUE = 1 AND RANG = 1 THEN 'masqué'
            WHEN ABS(S - R) BETWEEN 1 AND 9 OR ABS(S - P) BETWEEN 1 AND 9 THEN 'masqué'
            ELSE TO_CHAR(S) END AS NB_SEANCES
FROM m
ORDER BY ANNEE, AGE, UNITE, GHS;
