-- id: 20261014-oproom-specialites-salles
-- system: oproom
-- person_data: masked
-- purpose: interventions réalisées d'OpRoom par année, spécialité de la procédure et salle hors bloc ou non (salle GILLIES, salle virtuelle), pour savoir quelles spécialités une salle hors bloc gonfle (kb : gillies-room-outside-or ; #39, étape 5)
-- SQLite, sur l'extraction de QBLOCP par requete_oproom.py (table INTERVENTIONS, valeurs en texte, vide = NULL ; table META), chargée par scripts/cdk/executer_requetes_cdk.py de DIM-code. Ne lit ni NO_ADMISSION ni CHIRURGIEN_KEY.
-- SALLE_GILLIES : 'O' si SALLE_CODE ou SALLE contient GILLIES (sans tenir compte de la casse). N : interventions ; N_GILLIES ; N_SALLE_VIRTUELLE.
-- Masquage : chaque effectif < 10 sort en <10. Suppression secondaire (règle 4) : N sort en « masqué » dès qu'un complément (N moins une autre colonne) est entre 1 et 9. Aucune ligne de total.
WITH c AS (
  SELECT substr(DEBUT, 1, 4) AS ANNEE, IFNULL(SPEC, '(vide)') AS SPEC, COUNT(*) AS N,
         SUM(UPPER(IFNULL(SALLE_CODE, '') || ' ' || IFNULL(SALLE, '')) LIKE '%GILLIES%') AS C1,
         SUM(SALLE_VIRTUELLE = '1') AS C2
  FROM INTERVENTIONS WHERE DEBUT IS NOT NULL
  GROUP BY substr(DEBUT, 1, 4), IFNULL(SPEC, '(vide)')
),
m AS (SELECT BASE || ' (extraction du ' || EXTRAIT_LE || ')' AS DB FROM META)
SELECT '20261014-oproom-specialites-salles' AS query_id, (SELECT DB FROM m) AS database_name,
       strftime('%Y-%m-%d %H:%M', 'now', 'localtime') AS run_at,
       ANNEE, SPEC,
       CASE WHEN N < 10 THEN '<10' WHEN N - C1 BETWEEN 1 AND 9 OR N - C2 BETWEEN 1 AND 9 THEN 'masqué' ELSE CAST(N AS TEXT) END AS N,
       CASE WHEN C1 < 10 THEN '<10' ELSE CAST(C1 AS TEXT) END AS N_GILLIES,
       CASE WHEN C2 < 10 THEN '<10' ELSE CAST(C2 AS TEXT) END AS N_SALLE_VIRTUELLE
FROM c
ORDER BY ANNEE, SPEC;
