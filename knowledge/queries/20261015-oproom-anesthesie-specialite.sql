-- id: 20261015-oproom-anesthesie-specialite
-- system: oproom
-- person_data: masked
-- purpose: interventions réalisées d'OpRoom par type d'anesthésie et spécialité de la procédure, pour savoir si AST et TOP sont des anesthésies ophtalmologiques et comment regrouper les types d'anesthésie (kb : backlog anesthesia-grouping ; #39)
-- SQLite, sur l'extraction de QBLOCP par requete_oproom.py (table INTERVENTIONS, valeurs en texte, vide = NULL ; table META), chargée par scripts/cdk/executer_requetes_cdk.py de DIM-code. Ne lit ni NO_ADMISSION ni CHIRURGIEN_KEY. Toutes années de l'extraction confondues (2023 au 2026-10-09).
-- Masquage : chaque effectif < 10 sort en <10. Suppression secondaire (règle 4) : quand les cases masquées d'un type d'anesthésie totalisent de 1 à 9, la plus grande case de ce type sort aussi en « masqué ». Aucune ligne de total.
WITH c AS (
  SELECT IFNULL(ANESTHESIE, '(vide)') AS ANESTHESIE, IFNULL(SPEC, '(vide)') AS SPEC, COUNT(*) AS N
  FROM INTERVENTIONS GROUP BY IFNULL(ANESTHESIE, '(vide)'), IFNULL(SPEC, '(vide)')
),
r AS (
  SELECT ANESTHESIE, SPEC, N,
         SUM(CASE WHEN N < 10 THEN N ELSE 0 END) OVER (PARTITION BY ANESTHESIE) AS CACHE,
         ROW_NUMBER() OVER (PARTITION BY ANESTHESIE ORDER BY N DESC, SPEC) AS RANG
  FROM c
),
m AS (SELECT BASE || ' (extraction du ' || EXTRAIT_LE || ')' AS DB FROM META)
SELECT '20261015-oproom-anesthesie-specialite' AS query_id, (SELECT DB FROM m) AS database_name,
       strftime('%Y-%m-%d %H:%M', 'now', 'localtime') AS run_at,
       ANESTHESIE, SPEC,
       CASE WHEN N < 10 THEN '<10' WHEN CACHE BETWEEN 1 AND 9 AND RANG = 1 THEN 'masqué' ELSE CAST(N AS TEXT) END AS N
FROM r
ORDER BY ANESTHESIE, N DESC, SPEC;
