-- id: 20261019-date-heure-colonnes
-- system: cora
-- person_data: masked
-- purpose: pour DATE_ENTREE et DATE_SORTIE de TB_SEJOUR, DATE_DEBUT_MVT et DATE_FIN_MVT de TB_MVT, DATE_ACTE de TB_ACTE, par année de la date, mesurer la part de dates qui portent une heure non nulle et ce que contient la colonne HEURE_* associée (renseignée ? même jour que la date ? date fictive du type 1899/1900 ?), pour trancher date-et-heure-dans-deux-colonnes (réfuté si plus de 1 % des DATE_SORTIE d'une année ont une heure non nulle, ou si la date de HEURE_* est la vraie date pour plus de 99 % des lignes ; confirmé sinon, et la date fictive dit comment extraire l'heure)
-- Oracle, schéma CORA_REC. Lignes dont la date est du 2018-01-01 à aujourd'hui, année = année de cette date. Couples : TB_SEJOUR (DATE_ENTREE, HEURE_ENTREE) et (DATE_SORTIE, HEURE_SORTIE), TB_MVT (DATE_DEBUT_MVT, HEURE_DEBUT_MVT) et (DATE_FIN_MVT, HEURE_FIN_MVT), TB_ACTE (DATE_ACTE, HEURE_ACTE). Noms des colonnes d'après le dictionnaire 2020 et 20261019-catalogue-types-colonnes-g3.
-- N : lignes ; N_DATE_AVEC_HEURE : DATE_* différente de TRUNC(DATE_*) ; N_HEURE_RENSEIGNEE : HEURE_* non vide ; N_HEURE_MEME_JOUR : HEURE_* non vide dont la partie date égale celle de DATE_* ; N_HEURE_DATE_FICTIVE : HEURE_* non vide dont la partie date est avant 1950 ; N_HEURE_NON_NULLE : HEURE_* non vide dont l'heure n'est pas 00:00:00.
-- PCT_DATE_AVEC_HEURE et PCT_HEURE_MEME_JOUR (pourcentage de N et de N_HEURE_RENSEIGNEE) ne sortent que si le numérateur et le dénominateur sont visibles (sinon vides).
-- Masquage : chaque effectif < 10 sort en <10. Suppression secondaire (règle 4) : N sort en « masqué » dès que N moins N_DATE_AVEC_HEURE ou N moins N_HEURE_RENSEIGNEE vaut de 1 à 9 ; N_HEURE_RENSEIGNEE de même avec N_HEURE_MEME_JOUR et N_HEURE_DATE_FICTIVE. Aucune ligne de total.
WITH u AS (
  SELECT 'TB_SEJOUR' AS T, 'DATE_ENTREE' AS COL, DATE_ENTREE AS D, HEURE_ENTREE AS H
  FROM CORA_REC.TB_SEJOUR WHERE DATE_ENTREE >= DATE '2018-01-01' AND DATE_ENTREE < TRUNC(SYSDATE) + 1
  UNION ALL
  SELECT 'TB_SEJOUR', 'DATE_SORTIE', DATE_SORTIE, HEURE_SORTIE
  FROM CORA_REC.TB_SEJOUR WHERE DATE_SORTIE >= DATE '2018-01-01' AND DATE_SORTIE < TRUNC(SYSDATE) + 1
  UNION ALL
  SELECT 'TB_MVT', 'DATE_DEBUT_MVT', DATE_DEBUT_MVT, HEURE_DEBUT_MVT
  FROM CORA_REC.TB_MVT WHERE DATE_DEBUT_MVT >= DATE '2018-01-01' AND DATE_DEBUT_MVT < TRUNC(SYSDATE) + 1
  UNION ALL
  SELECT 'TB_MVT', 'DATE_FIN_MVT', DATE_FIN_MVT, HEURE_FIN_MVT
  FROM CORA_REC.TB_MVT WHERE DATE_FIN_MVT >= DATE '2018-01-01' AND DATE_FIN_MVT < TRUNC(SYSDATE) + 1
  UNION ALL
  SELECT 'TB_ACTE', 'DATE_ACTE', DATE_ACTE, HEURE_ACTE
  FROM CORA_REC.TB_ACTE WHERE DATE_ACTE >= DATE '2018-01-01' AND DATE_ACTE < TRUNC(SYSDATE) + 1
),
a AS (
  SELECT T, COL, EXTRACT(YEAR FROM D) AS ANNEE,
         COUNT(*) AS N,
         SUM(CASE WHEN D <> TRUNC(D) THEN 1 ELSE 0 END) AS C1,
         SUM(CASE WHEN H IS NOT NULL THEN 1 ELSE 0 END) AS C2,
         SUM(CASE WHEN H IS NOT NULL AND TRUNC(H) = TRUNC(D) THEN 1 ELSE 0 END) AS C3,
         SUM(CASE WHEN H IS NOT NULL AND TRUNC(H) < DATE '1950-01-01' THEN 1 ELSE 0 END) AS C4,
         SUM(CASE WHEN H IS NOT NULL AND H <> TRUNC(H) THEN 1 ELSE 0 END) AS C5
  FROM u
  GROUP BY T, COL, EXTRACT(YEAR FROM D)
)
SELECT '20261019-date-heure-colonnes' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       T AS TABLE_NAME, COL AS COLONNE_DATE, ANNEE,
       CASE WHEN N < 10 THEN '<10'
            WHEN N - C1 BETWEEN 1 AND 9 OR N - C2 BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(N) END AS N,
       CASE WHEN C1 < 10 THEN '<10' ELSE TO_CHAR(C1) END AS N_DATE_AVEC_HEURE,
       CASE WHEN N >= 10 AND C1 >= 10 AND N - C1 NOT BETWEEN 1 AND 9 AND N - C2 NOT BETWEEN 1 AND 9
            THEN TO_CHAR(ROUND(100 * C1 / N, 3)) END AS PCT_DATE_AVEC_HEURE,
       CASE WHEN C2 < 10 THEN '<10'
            WHEN C2 - C3 BETWEEN 1 AND 9 OR C2 - C4 BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(C2) END AS N_HEURE_RENSEIGNEE,
       CASE WHEN C3 < 10 THEN '<10' ELSE TO_CHAR(C3) END AS N_HEURE_MEME_JOUR,
       CASE WHEN C2 >= 10 AND C3 >= 10 AND C2 - C3 NOT BETWEEN 1 AND 9 AND C2 - C4 NOT BETWEEN 1 AND 9
            THEN TO_CHAR(ROUND(100 * C3 / C2, 3)) END AS PCT_HEURE_MEME_JOUR,
       CASE WHEN C4 < 10 THEN '<10' ELSE TO_CHAR(C4) END AS N_HEURE_DATE_FICTIVE,
       CASE WHEN C5 < 10 THEN '<10' ELSE TO_CHAR(C5) END AS N_HEURE_NON_NULLE
FROM a
ORDER BY T, COL, ANNEE;
