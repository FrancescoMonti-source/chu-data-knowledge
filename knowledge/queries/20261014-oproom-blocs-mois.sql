-- id: 20261014-oproom-blocs-mois
-- system: oproom
-- person_data: masked
-- purpose: interventions réalisées d'OpRoom par mois de début et par bloc (site physique de la salle), pour dater l'arrivée de chaque bloc dans OpRoom, dont la pédiatrie (kb : pediatrics-from-2023-05 ; #39, étape 4)
-- SQLite, sur l'extraction de QBLOCP par requete_oproom.py (table INTERVENTIONS, valeurs en texte, vide = NULL ; table META), chargée par scripts/cdk/executer_requetes_cdk.py de DIM-code. Ne lit ni NO_ADMISSION ni CHIRURGIEN_KEY.
-- Masquage : chaque effectif < 10 sort en <10. Suppression secondaire (règle 4) : quand les cases masquées d'un mois totalisent de 1 à 9, la plus grande case de ce mois sort aussi en « masqué ». Aucune ligne de total.
WITH c AS (
  SELECT substr(DEBUT, 1, 7) AS MOIS, IFNULL(BLOC, '(vide)') AS BLOC, COUNT(*) AS N
  FROM INTERVENTIONS WHERE DEBUT IS NOT NULL
  GROUP BY substr(DEBUT, 1, 7), IFNULL(BLOC, '(vide)')
),
r AS (
  SELECT MOIS, BLOC, N,
         SUM(CASE WHEN N < 10 THEN N ELSE 0 END) OVER (PARTITION BY MOIS) AS CACHE,
         ROW_NUMBER() OVER (PARTITION BY MOIS ORDER BY N DESC, BLOC) AS RANG
  FROM c
),
m AS (SELECT BASE || ' (extraction du ' || EXTRAIT_LE || ')' AS DB FROM META)
SELECT '20261014-oproom-blocs-mois' AS query_id, (SELECT DB FROM m) AS database_name,
       strftime('%Y-%m-%d %H:%M', 'now', 'localtime') AS run_at,
       MOIS, BLOC,
       CASE WHEN N < 10 THEN '<10' WHEN CACHE BETWEEN 1 AND 9 AND RANG = 1 THEN 'masqué' ELSE CAST(N AS TEXT) END AS N
FROM r
ORDER BY MOIS, BLOC;
