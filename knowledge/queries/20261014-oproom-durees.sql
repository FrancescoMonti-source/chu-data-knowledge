-- id: 20261014-oproom-durees
-- system: oproom
-- person_data: masked
-- purpose: par année de début, ce que mesurent DEBUT et FIN d'une intervention réalisée d'OpRoom (le bionettoyage est-il compris dans FIN ?), le remplissage des phases, et les durées moyennes d'occupation (DEBUT → FIN), de TROS (DEBUT → début du bionettoyage, FIN à défaut), d'incision (phase OPERAT) et de bionettoyage (kb : actual-start-end-meaning, definition.tros ; #39, étape 3)
-- SQLite, sur l'extraction de QBLOCP par requete_oproom.py (table INTERVENTIONS, valeurs en texte, vide = NULL ; table META), chargée par scripts/cdk/executer_requetes_cdk.py de DIM-code. Ne lit ni NO_ADMISSION ni CHIRURGIEN_KEY. Durées en minutes : (julianday(fin) − julianday(début)) × 1440.
-- N : interventions ; N_SANS_FIN ; N_SANS_BIONET (pas de phase BIONET) ; N_BIONET_DANS_FIN (début du bionettoyage entre DEBUT et FIN) ; N_SANS_INCISION ; N_PHASES_MOINS_DE_5, N_PHASES_5_A_9, N_PHASES_10_ET_PLUS ; N_OCCUPATION_NEGATIVE, N_OCCUPATION_SUP_24H.
-- MOY_… : moyennes en minutes, arrondies à l'unité, sur les interventions où les deux bornes existent et la durée est entre 0 et 24 h ; NB_… : le nombre d'interventions de chaque moyenne.
-- Masquage : chaque effectif < 10 sort en <10, et une moyenne calculée sur moins de 10 interventions aussi. Suppression secondaire (règle 4) : N sort en « masqué » dès qu'un complément (N moins une colonne N_ ou NB_) est entre 1 et 9. Aucune ligne de total.
WITH i AS (
  SELECT substr(DEBUT, 1, 4) AS ANNEE,
         (julianday(FIN) - julianday(DEBUT)) * 1440 AS OCC,
         (julianday(IFNULL(DEBUT_BIONET, FIN)) - julianday(DEBUT)) * 1440 AS TROS,
         (julianday(FIN_INCISION) - julianday(DEBUT_INCISION)) * 1440 AS INC,
         (julianday(FIN) - julianday(DEBUT_BIONET)) * 1440 AS BIO,
         CAST(NB_PHASES AS INTEGER) AS NBP,
         DEBUT, FIN, DEBUT_BIONET, DEBUT_INCISION
  FROM INTERVENTIONS WHERE DEBUT IS NOT NULL
),
a AS (
  SELECT ANNEE, COUNT(*) AS N,
         SUM(FIN IS NULL) AS C1,
         SUM(DEBUT_BIONET IS NULL) AS C2,
         SUM(DEBUT_BIONET >= DEBUT AND DEBUT_BIONET < FIN) AS C3,
         SUM(DEBUT_INCISION IS NULL) AS C4,
         SUM(NBP < 5) AS C5, SUM(NBP BETWEEN 5 AND 9) AS C6, SUM(NBP >= 10) AS C7,
         SUM(OCC < 0) AS C8, SUM(OCC > 1440) AS C9,
         SUM(OCC BETWEEN 0 AND 1440) AS K1, AVG(CASE WHEN OCC BETWEEN 0 AND 1440 THEN OCC END) AS M1,
         SUM(TROS BETWEEN 0 AND 1440) AS K2, AVG(CASE WHEN TROS BETWEEN 0 AND 1440 THEN TROS END) AS M2,
         SUM(INC BETWEEN 0 AND 1440) AS K3, AVG(CASE WHEN INC BETWEEN 0 AND 1440 THEN INC END) AS M3,
         SUM(BIO BETWEEN 0 AND 1440) AS K4, AVG(CASE WHEN BIO BETWEEN 0 AND 1440 THEN BIO END) AS M4
  FROM i GROUP BY ANNEE
),
m AS (SELECT BASE || ' (extraction du ' || EXTRAIT_LE || ')' AS DB FROM META)
SELECT '20261014-oproom-durees' AS query_id, (SELECT DB FROM m) AS database_name,
       strftime('%Y-%m-%d %H:%M', 'now', 'localtime') AS run_at,
       ANNEE,
       CASE WHEN N < 10 THEN '<10'
            WHEN N - C1 BETWEEN 1 AND 9 OR N - C2 BETWEEN 1 AND 9 OR N - C3 BETWEEN 1 AND 9 OR N - C4 BETWEEN 1 AND 9
              OR N - C5 BETWEEN 1 AND 9 OR N - C6 BETWEEN 1 AND 9 OR N - C7 BETWEEN 1 AND 9 OR N - C8 BETWEEN 1 AND 9
              OR N - C9 BETWEEN 1 AND 9 OR N - K1 BETWEEN 1 AND 9 OR N - K2 BETWEEN 1 AND 9 OR N - K3 BETWEEN 1 AND 9
              OR N - K4 BETWEEN 1 AND 9
            THEN 'masqué' ELSE CAST(N AS TEXT) END AS N,
       CASE WHEN C1 < 10 THEN '<10' ELSE CAST(C1 AS TEXT) END AS N_SANS_FIN,
       CASE WHEN C2 < 10 THEN '<10' ELSE CAST(C2 AS TEXT) END AS N_SANS_BIONET,
       CASE WHEN C3 < 10 THEN '<10' ELSE CAST(C3 AS TEXT) END AS N_BIONET_DANS_FIN,
       CASE WHEN C4 < 10 THEN '<10' ELSE CAST(C4 AS TEXT) END AS N_SANS_INCISION,
       CASE WHEN C5 < 10 THEN '<10' ELSE CAST(C5 AS TEXT) END AS N_PHASES_MOINS_DE_5,
       CASE WHEN C6 < 10 THEN '<10' ELSE CAST(C6 AS TEXT) END AS N_PHASES_5_A_9,
       CASE WHEN C7 < 10 THEN '<10' ELSE CAST(C7 AS TEXT) END AS N_PHASES_10_ET_PLUS,
       CASE WHEN C8 < 10 THEN '<10' ELSE CAST(C8 AS TEXT) END AS N_OCCUPATION_NEGATIVE,
       CASE WHEN C9 < 10 THEN '<10' ELSE CAST(C9 AS TEXT) END AS N_OCCUPATION_SUP_24H,
       CASE WHEN K1 < 10 THEN '<10' ELSE CAST(K1 AS TEXT) END AS NB_OCCUPATION,
       CASE WHEN K1 < 10 THEN '<10' ELSE CAST(ROUND(M1) AS INTEGER) END AS MOY_OCCUPATION_MIN,
       CASE WHEN K2 < 10 THEN '<10' ELSE CAST(K2 AS TEXT) END AS NB_TROS,
       CASE WHEN K2 < 10 THEN '<10' ELSE CAST(ROUND(M2) AS INTEGER) END AS MOY_TROS_MIN,
       CASE WHEN K3 < 10 THEN '<10' ELSE CAST(K3 AS TEXT) END AS NB_INCISION,
       CASE WHEN K3 < 10 THEN '<10' ELSE CAST(ROUND(M3) AS INTEGER) END AS MOY_INCISION_MIN,
       CASE WHEN K4 < 10 THEN '<10' ELSE CAST(K4 AS TEXT) END AS NB_BIONET,
       CASE WHEN K4 < 10 THEN '<10' ELSE CAST(ROUND(M4) AS INTEGER) END AS MOY_BIONET_MIN
FROM a
ORDER BY ANNEE;
